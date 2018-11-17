----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2018 10:18:43 AM
-- Design Name: 
-- Module Name: tb_MultiStageHalfBandInterpolator - Behavioral
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
use STD.textio.all;
use ieee.std_logic_textio.all;
use work.MultiStageHalfBandInterpolator_param.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_MultiStageHalfBandInterpolator is
--  Port ( );
end tb_MultiStageHalfBandInterpolator;

architecture Behavioral of tb_MultiStageHalfBandInterpolator is
	COMPONENT MultiStageHalfBandInterpolator
		Port(
			SlaveAxi_RI : in GLOBAL2SAXILITE;
			SlaveAxi_RO : out SAXILITE2GLOBAL;
			
			MasterAxi_RI : in GLOBAL2MAXILITE;
			MasterAxi_RO : out MAXILITE2GLOBAL
		);
	END COMPONENT;
	
	signal SlaveAxi_RI : GLOBAL2SAXILITE := GLOBAL2SAXILITE_INIT;
	signal SlaveAxi_RO : SAXILITE2GLOBAL := SAXILITE2GLOBAL_INIT;
	
	signal MasterAxi_RI : GLOBAL2MAXILITE := GLOBAL2MAXILITE_INIT;
	signal MasterAxi_RO : MAXILITE2GLOBAL := MAXILITE2GLOBAL_INIT;
	
	-----------------------------------------------------------------------------
	-- Testbench Internal Signals
	-----------------------------------------------------------------------------
	
	constant CLK_PERIOD : time := 10 ns;
	constant ADC_PERIOD : time := 480 ns;	
	
	signal signal_debug: integer:= 0;
	
	signal file_ended: std_logic:= '0';
	
begin

	uut: MultiStageHalfBandInterpolator PORT MAP(
	
		SlaveAxi_RI.s_axi_aclk     => MasterAxi_RO.m_axi_aclk,
		SlaveAxi_RI.s_axi_aresetn  => MasterAxi_RO.m_axi_aresetn,
		SlaveAxi_RI.s_axi_wdata    => MasterAxi_RO.m_axi_wdata,
		SlaveAxi_RI.s_axi_wstrb    => MasterAxi_RO.m_axi_wstrb,
		SlaveAxi_RI.s_axi_wvalid   => MasterAxi_RO.m_axi_wvalid,
		SlaveAxi_RI.s_axi_bready   => MasterAxi_RO.m_axi_bready,

		SlaveAxi_RO.s_axi_wready   => MasterAxi_RI.m_axi_wready,
		SlaveAxi_RO.s_axi_bresp    => MasterAxi_RI.m_axi_bresp,
		SlaveAxi_RO.s_axi_bvalid   => MasterAxi_RI.m_axi_bvalid,	
		
		MasterAxi_RO.m_axi_aclk    => SlaveAxi_RI.s_axi_aclk,
		MasterAxi_RO.m_axi_aresetn => SlaveAxi_RI.s_axi_aresetn,
		MasterAxi_RO.m_axi_wdata   => SlaveAxi_RI.s_axi_wdata,
		MasterAxi_RO.m_axi_wstrb   => SlaveAxi_RI.s_axi_wstrb,
		MasterAxi_RO.m_axi_wvalid  => SlaveAxi_RI.s_axi_wvalid,
		MasterAxi_RO.m_axi_bready  => SlaveAxi_RI.s_axi_bready,

		MasterAxi_RI.m_axi_wready  => SlaveAxi_RO.s_axi_wready,
		MasterAxi_RI.m_axi_bresp   => SlaveAxi_RO.s_axi_bresp,
		MasterAxi_RI.m_axi_bvalid  => SlaveAxi_RO.s_axi_bvalid		
	);
	
	clk_proc: process
	begin
		MasterAxi_RO.m_axi_aclk <= '0';
		wait for CLK_PERIOD/2;
		MasterAxi_RO.m_axi_aclk <= '1';
		wait for CLK_PERIOD/2;
	end process;
	
	MasterAxi_RO.m_axi_aresetn <= '0','1' after 11 ns ;
	

	adc_proc: process
		file file_SIGNAL : text open read_mode is "test_signal_5.dat";
		variable v_row          : line;
		Variable v_data_read  : integer;
	begin
		
		wait for 10 ns;
		
		while not endfile(file_SIGNAL) loop
		
			readline(file_SIGNAL, v_row);
			read(v_row, v_data_read);
			
			MasterAxi_RO.m_axi_wdata <= std_logic_vector(to_signed(v_data_read,C_S_AXI_DATA_WIDTH));
			MasterAxi_RO.m_axi_wvalid <= '1';
			
			wait until rising_edge(MasterAxi_RO.m_axi_aclk);
			
			if ( MasterAxi_RI.m_axi_wready = '0' ) then
				wait until MasterAxi_RI.m_axi_wready = '1';										
			end if;
			wait for CLK_PERIOD;
			
			MasterAxi_RO.m_axi_wdata <= (others => '0');
			MasterAxi_RO.m_axi_bready <= '1';
			MasterAxi_RO.m_axi_wvalid <= '0';
			
			if ( MasterAxi_RI.m_axi_bvalid = '0' ) then
				wait until MasterAxi_RI.m_axi_bvalid = '1';										
			end if;
			wait for CLK_PERIOD;
				
			MasterAxi_RO.m_axi_bready <= '0';
			
			wait for ADC_PERIOD-2*CLK_PERIOD;
			
		end loop;
		     
		file_ended <= '1';
	end process;
	
	read_proc: process
		file file_RESULTS     : text open write_mode is "/home/almul0/Universidad/ityst/17-18/TFG/TFG-Code/signal_characterization/test_results_5.dat";
		variable v_row          : line;
		Variable v_data_write  : integer;
		variable f_status: FILE_OPEN_STATUS;
	begin
			wait for 10 ns;
			
			CASE f_status is
				WHEN OPEN_OK =>
					while file_ended = '0' loop
							
							SlaveAxi_RO.s_axi_wready <= '1';
							
							if ( SlaveAxi_RI.s_axi_wvalid = '0' ) then
								wait until SlaveAxi_RI.s_axi_wvalid = '1';
							end if;
							
							
							signal_debug <=to_integer(signed(SlaveAxi_RI.s_axi_wdata(C_S_SAMPLE_DATA_WIDTH-1 downto 0)));
							v_data_write := to_integer(signed(SlaveAxi_RI.s_axi_wdata(C_S_SAMPLE_DATA_WIDTH-1 downto 0)));
							write(v_row, v_data_write);
							writeline(file_RESULTS, v_row);
							
							wait until rising_edge(MasterAxi_RO.m_axi_aclk);
							SlaveAxi_RO.s_axi_wready <= '0';
							--wait until SlaveAxi_RI.s_axi_wvalid = '0';
							
							SlaveAxi_RO.s_axi_bvalid <= '1';
							
							
							
							if ( SlaveAxi_RI.s_axi_bready = '0' ) then
								wait until SlaveAxi_RI.s_axi_bready = '1';										
							end if;
							
							wait until rising_edge(MasterAxi_RO.m_axi_aclk);				
							SlaveAxi_RO.s_axi_bvalid <= '0';
							
						end loop;
						file_close(file_RESULTS);
						ASSERT FALSE         
						REPORT "FILE CLOSED";
				when OTHERS => 
					ASSERT FALSE         
					REPORT "FILE ERROR";
							
			end case;
			
			
			
			
			
			
	end process;

end Behavioral;
