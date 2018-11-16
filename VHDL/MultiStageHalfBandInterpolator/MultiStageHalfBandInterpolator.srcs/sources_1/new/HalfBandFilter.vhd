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

	signal SampleIn_DN : signed(SAMPLE_DATA_WIDTH-1 downto 0):= (others => '0');
	type AxiStateType is (IDLE, WAIT_WREADY, WAIT_WVALID, WAIT_BVALID, WAIT_BREADY);  -- Define the states
	signal SlaveAxiState_S, SlaveAxiState_SN : AxiStateType;    -- Create a signal that uses
	signal MasterAxiState_S, MasterAxiState_SN : AxiStateType;    -- Create a signal that uses
	
	-- Posicion 0 muestra actual
	-- Position 1-N linea de retardo
	type DelayLineArray is array (0 to ((COEFFS'LENGTH * 2))) of signed(SAMPLE_DATA_WIDTH-1 downto 0);
	signal DelayLine: DelayLineArray;
	
	signal ClkDividerCounter_S,ClkDividerCounter_SN: unsigned(integer(floor(log2(real(PRESCALER)))) downto 0) := (others => '0');
	signal OutEnable_S,OutEnable_SN: std_logic := '0';
	
	type SumResultArray is array (0 to COEFFS'LENGTH-1) of signed(SAMPLE_DATA_WIDTH-1 downto 0); -- <18,4>
	signal SumResult: SumResultArray;
	signal SumResult_S: signed(SAMPLE_DATA_WIDTH-1 downto 0);
	
	type MultResultArray is array (0 to COEFFS'LENGTH-1) of signed(COEFFS(0)'length + SAMPLE_DATA_WIDTH-1 downto 0); 
	signal MultResult: MultResultArray;
	
	signal MultResult_S: signed(COEFFS(0)'length + SAMPLE_DATA_WIDTH-1 downto 0);
	signal MultA_S: signed(COEFFS(0)'length-1 downto 0);									
	signal MultB_S: signed(SAMPLE_DATA_WIDTH-1 downto 0);
	
	-- Numero de operaciones
	signal OpCounter_S, OpCounter_SN: unsigned(integer(floor(log2(real(COEFFS'LENGTH)))) downto 0) := (others => '0');
	signal OpCounter2_S, OpCounter2_SN: std_logic;

	signal Out1_D, Out1_DN: signed(SAMPLE_DATA_WIDTH-1 downto 0) := "00" & x"00FF";
	signal Out2_D, Out2_DN: signed(SAMPLE_DATA_WIDTH-1 downto 0) := "00" & x"FF00";
	signal Out_D : signed(SAMPLE_DATA_WIDTH-1 downto 0) := (others => '0');
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
	        OpCounter_S <= (others => '0');
	        OpCounter2_S <= '0';
	        OutEnable_S <= '0';
	        SlaveAxiState_S <= IDLE;
	        MasterAxiState_S <= IDLE;
	        SumResult <= (others => (others => '0'));
	        MultResult <= (others => (others => '0'));
	        DelayLine <= (others => (others => '0'));
	        SumResult_S <= (others => '0');
	        MultResult_S <= (others => '0');
	        MultA_S <= (others => '0');
	        MultB_S <= (others => '0');
	    elsif(rising_edge(SlaveAxi_RI.s_axi_aclk)) then
	    	
	    	OutSelector_S <= OutSelector_SN;
	    	ClkDividerCounter_S <= ClkDividerCounter_SN;
	    	OpCounter_S <= OpCounter_SN;
	    	OutEnable_S <= OutEnable_SN;
	    	SlaveAxiState_S <= SlaveAxiState_SN;
	    	MasterAxiState_S <= MasterAxiState_SN;
	    	
	    	SumResult(to_integer(OpCounter_S)) <= DelayLine(to_integer(OpCounter_S)) + DelayLine(DelayLine'length-1 - to_integer(OpCounter_S));
	    	
	    	if ( OpCounter_S > 1 ) then
					MultResult(to_integer(OpCounter_S)-1) <= MultResult_S;
				end if;
				
				MultB_S <= SumResult(to_integer(OpCounter_S));
				MultA_S <= COEFFS(to_integer(OpCounter_S));
				
				Out1_D <= Out1_DN;
				Out2_D <= Out2_DN;
				
				OpCounter2_S <= OpCounter2_SN;

				
				if ( OutEnable_SN = '1') then
					DelayLine <= SampleIn_DN & DelayLine(0 to DelayLine'length-2);
					OpCounter_S <= (others => '0');
					OpCounter2_S <= '0';
					Out2_D <= (others => '0');
					Out1_D <= (others => '0');
				end if;
				
	    end if; 
	end process;

	
	MultResult_S <= MultA_S * MultB_S;
			
	Out1_DN <= DelayLine(2);
	
	FILTER_OPS: process(OpCounter_S, OutEnable_S, OpCounter2_S)
	begin
		
		if ( OutEnable_S = '1' ) then
			OpCounter2_SN <= '1';
			OpCounter_SN <= OpCounter_S;
		elsif ( (OpCounter_S > 0 AND OpCounter_S < COEFFS'length-1) OR OpCounter2_S = '1') then				
				OpCounter_SN <= OpCounter_S + 1; 
				OpCounter2_SN <= '0';
		else 
			OpCounter_SN <= OpCounter_S;
			OpCounter2_SN <= OpCounter2_S; 
		end if;
		
		if ( OpCounter_S = 0 and OutEnable_S = '1') then
			Out2_DN <= shift_right(MultResult(0),15)(SAMPLE_DATA_WIDTH-1 downto 0);
		elsif (OpCounter_S > 1 and OpCounter_S <= COEFFS'length) then			
			Out2_DN <= (Out_D + shift_right(MultResult(0),15)(SAMPLE_DATA_WIDTH-1 downto 0));	
		else 
			Out2_DN <= Out2_D; 
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
				if ( ClkDividerCounter_S = PRESCALER ) then 		  
					  	  	
					MasterAxi_RO.m_axi_wdata <= (MasterAxi_RO.m_axi_wdata'length-1 downto Out_D'length => '0') & std_logic_vector(Out_D);
					MasterAxi_RO.m_axi_wvalid <= '1';
					
					if (MasterAxi_RI.m_axi_wready = '0') then
						MasterAxiState_SN <= WAIT_WREADY;
					else  
						MasterAxiState_SN <= WAIT_BREADY;
						
					end if;
				end if;
							

			when WAIT_WREADY =>		
					MasterAxi_RO.m_axi_wdata <= (MasterAxi_RO.m_axi_wdata'length-1 downto Out_D'length => '0') & std_logic_vector(Out_D);
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
		OutEnable_SN <= '0';
		OutSelector_SN <= OutSelector_S;
		SlaveAxiState_SN <= SlaveAxiState_S;
		SampleIn_DN <= DelayLine(0);		
		
		if ( ClkDividerCounter_S < PRESCALER ) then
			ClkDividerCounter_SN <= ClkDividerCounter_S + 1;
		else 
		 	OutSelector_SN <= not OutSelector_S;
		 	ClkDividerCounter_SN <= (others => '0');
		end if;
		
		case SlaveAxiState_S is
			when IDLE =>
				SlaveAxiState_SN <= WAIT_WVALID;
				SlaveAxi_RO.s_axi_wready <= '1';
			when WAIT_WVALID =>
				SlaveAxi_RO.s_axi_wready <= '1';
				if SlaveAxi_RI.s_axi_wvalid = '1' then
				
					SampleIn_DN <= signed(SlaveAxi_RI.s_axi_wdata(17 downto 0));
					
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
