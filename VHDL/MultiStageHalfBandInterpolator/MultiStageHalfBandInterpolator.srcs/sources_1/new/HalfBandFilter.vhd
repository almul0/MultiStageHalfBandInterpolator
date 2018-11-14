----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2018 09:52:48 AM
-- Design Name: 
-- Module Name: HalfBandFilter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.ALL;
use work.MultiStageHalfBandInterpolator_param.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity HalfBandFilter is
	Generic(
		 SAMPLE_DATA_WIDTH: integer;
     PRESCALER: integer;
     COEFFS:    CoeffsArray
     );
	Port(
			SlaveAxi_RI : in GLOBAL2SAXILITE;
			SlaveAxi_RO : out SAXILITE2GLOBAL;
			
			MasterAxi_RI : in GLOBAL2MAXILITE;
			MasterAxi_RO : out MAXILITE2GLOBAL
		);
end HalfBandFilter;

architecture Behavioral of HalfBandFilter is
	signal SampleIn_D : std_logic_vector(SAMPLE_DATA_WIDTH-1 downto 0):= (others => '0');
	signal SampleIn_DN : std_logic_vector(SAMPLE_DATA_WIDTH-1 downto 0):= (others => '0');
	type AxiStateType is (IDLE, WAIT_WREADY, WAIT_WVALID, WAIT_BVALID, WAIT_BREADY);  -- Define the states
	signal SlaveAxiState_S, SlaveAxiState_SN : AxiStateType;    -- Create a signal that uses
	signal MasterAxiState_S, MasterAxiState_SN : AxiStateType;    -- Create a signal that uses
	
	type DelayLineArray is array (0 to ((COEFFS'LENGTH * 2)-1)) of std_logic_vector(SAMPLE_DATA_WIDTH-1 downto 0);
	signal DelayLine: DelayLineArray;

	signal ClkDividerCounter_S,ClkDividerCounter_SN: unsigned(integer(floor(log2(real(PRESCALER)))) downto 0) := (others => '0');
	signal OutEnable_S,OutEnable_SN: std_logic := '0';

	signal Out1_D: std_logic_vector(SAMPLE_DATA_WIDTH-1 downto 0) := "00" & x"00FF";
	signal Out2_D: std_logic_vector(SAMPLE_DATA_WIDTH-1 downto 0) := "00" & x"FF00";
	signal Out_D : std_logic_vector(SAMPLE_DATA_WIDTH-1 downto 0) := (others => '0');
	signal OutSelector_S,OutSelector_SN: std_logic := '0';

begin

	Out_D <= Out1_D when OutSelector_S = '0' else Out2_D;  
	MasterAxi_RO.m_axi_aclk <= SlaveAxi_RI.s_axi_aclk;
	MasterAxi_RO.m_axi_aresetn <= SlaveAxi_RI.s_axi_aresetn;
	
	--seq_proc
	process(SlaveAxi_RI.s_axi_aclk,SlaveAxi_RI.s_axi_aresetn)
	begin
	
	    if(SlaveAxi_RI.s_axi_aresetn = '0') then    --active high reset for the counter.
	        OutSelector_S <= '0';
	        ClkDividerCounter_S <= (others => '0');
	        SampleIn_D <= (others => '0');
	        OutEnable_S <= '0';
	        OutSelector_SN <= '0';
	        SlaveAxiState_S <= IDLE;
	        MasterAxiState_S <= IDLE;
	    elsif(rising_edge(SlaveAxi_RI.s_axi_aclk)) then
	    	
	    	OutSelector_S <= OutSelector_SN;
	    	ClkDividerCounter_S <= ClkDividerCounter_SN;
	    	SampleIn_D <= SampleIn_DN;
	    	OutEnable_S <= OutEnable_SN;
	    	SlaveAxiState_S <= SlaveAxiState_SN;
	    	MasterAxiState_S <= MasterAxiState_SN;
	    end if; 
	end process;

	MASTERAXI_DECODE: process(MasterAxiState_S, OutEnable_S, ClkDividerCounter_S, MasterAxi_RI.m_axi_wready, MasterAxi_RI.m_axi_bvalid)
	begin
				
		-- State Machine controlling data output
		MasterAxi_RO.m_axi_wvalid <= '0';
		MasterAxi_RO.m_axi_bready <= '0';
		MasterAxi_RO.m_axi_wstrb <= (others => '1');
		MasterAxi_RO.m_axi_wdata <= (others => '0');
		
		MasterAxiState_SN <= MasterAxiState_S;
		
		case MasterAxiState_S is
			when IDLE =>
				if ( (OutEnable_S = '1' AND ClkDividerCounter_S = 0)
					  	OR (OutEnable_S = '0' AND ClkDividerCounter_S = PRESCALER) ) then 		  
					  	  	
					MasterAxi_RO.m_axi_wdata <= (MasterAxi_RO.m_axi_wdata'length-1 downto Out_D'length => '0') & Out_D;
					MasterAxi_RO.m_axi_wvalid <= '1';
					
					if (MasterAxi_RI.m_axi_wready = '0') then
						MasterAxiState_SN <= WAIT_WREADY;
					else  
						MasterAxiState_SN <= WAIT_BREADY;
						
					end if;
				end if;
							

			when WAIT_WREADY =>		
					MasterAxi_RO.m_axi_wdata <= (MasterAxi_RO.m_axi_wdata'length-1 downto Out_D'length => '0') & Out_D;
					MasterAxi_RO.m_axi_wvalid <= '1';
					
					if MasterAxi_RI.m_axi_wready = '1' then
						MasterAxiState_SN <= WAIT_BVALID;
						MasterAxi_RO.m_axi_wdata <= (others => '0');
						MasterAxi_RO.m_axi_wvalid <= '0';
						MasterAxi_RO.m_axi_bready <= '1';							
					end if;
					
			when WAIT_BREADY =>	
				MasterAxi_RO.m_axi_bready <= '1';
				if MasterAxi_RI.m_axi_bvalid = '1' then			
					MasterAxiState_SN <= IDLE;
			 	else
					MasterAxiState_SN <= WAIT_BVALID;
				end if;
				
			when WAIT_BVALID =>											
					MasterAxi_RO.m_axi_bready <= '1';
					if MasterAxi_RI.m_axi_bvalid = '1' then			
						MasterAxi_RO.m_axi_bready <= '0';				
						MasterAxiState_SN <= IDLE;
					end if;
					
			when others =>
				MasterAxiState_SN <= IDLE;
		end case;
	end process;
	
	 
	SLAVEAXI_DECODE: process(SlaveAxiState_S, ClkDividerCounter_S, SlaveAxi_RI.s_axi_wvalid, SlaveAxi_RI.s_axi_bready)
	begin
		-- State Machine controlling data input
		SlaveAxi_RO.s_axi_bresp  <= "00";
		SlaveAxi_RO.s_axi_wready <= '0';
		SlaveAxi_RO.s_axi_bvalid <= '0';
		SampleIn_DN <= SampleIn_D;
		OutEnable_SN <= '0';
		OutSelector_SN <= '0';
		SlaveAxiState_SN <= SlaveAxiState_S;
		
		if ( (ClkDividerCounter_S > 0 AND ClkDividerCounter_S <= PRESCALER) OR OutEnable_S = '1') then
			ClkDividerCounter_SN <= ClkDividerCounter_S + 1;
		else 
		 	OutSelector_SN <= '1';
		end if;
		
		case SlaveAxiState_S is
			when IDLE =>
				SlaveAxiState_SN <= WAIT_WVALID;
				SlaveAxi_RO.s_axi_wready <= '1';
			when WAIT_WVALID =>
				SlaveAxi_RO.s_axi_wready <= '1';
				if SlaveAxi_RI.s_axi_wvalid = '1' then
					SampleIn_DN <= SlaveAxi_RI.s_axi_wdata(17 downto 0);
					OutEnable_SN <= '1';
					OutSelector_SN <= '0';
					ClkDividerCounter_SN <= (others => '0');
					SlaveAxiState_SN <= WAIT_BREADY;
				end if;
			when WAIT_BREADY =>		
				SlaveAxi_RO.s_axi_bvalid <= '1';
				if SlaveAxi_RI.s_axi_bready = '1' then							
					SlaveAxiState_SN <= IDLE;
				end if;
			when others =>
				SlaveAxiState_SN <= IDLE;
		end case;
	end process;
	


end Behavioral;
