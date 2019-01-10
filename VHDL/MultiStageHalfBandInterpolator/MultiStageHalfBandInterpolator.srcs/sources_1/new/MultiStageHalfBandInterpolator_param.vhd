----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2018 05:18:37 PM
-- Design Name: 
-- Module Name: MultiStageHalfBandInterpolator_param - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package MultiStageHalfBandInterpolator_param is
  constant C_S_AXI_DATA_WIDTH: integer:= 32;                --Data Width of AXI bus (default)
  ---------------------------------------------------------------------------------------------------------------------------------
  --i) Declare IPversion,subversion and revision here ....  
  ---------------------------------------------------------------------------------------------------------------------------------
    constant IPVersion:	 integer := 0;
    constant IPSubversion: integer := 0;
    constant IPRevision:   integer := 1;
  ---------------------------------------------------------------------------------------------------------------------------------
  
  ---------------------------------------------------------------------------------------------------------------------------------
  --ii) Declare how many components are going to be instantiated here...
  ---------------------------------------------------------------------------------------------------------------------------------
    constant PERIPHERAL_NUMBER: integer:=3;
  ---------------------------------------------------------------------------------------------------------------------------------
  
  ---------------------------------------------------------------------------------------------------------------------------------
  --iii) Declare peripheral user logic parameters here...
  ---------------------------------------------------------------------------------------------------------------------------------
    constant CLOCK_FREQUENCY_MHz:           integer:=100;
  
  ---------------------------------------------------------------------------------------------------------------------------------
	--iv) Filter definitions
	---------------------------------------------------------------------------------------------------------------------------------
	
	constant C_S_SAMPLE_DATA_WIDTH : integer:= 13;
	constant C_S_COEFF_DATA_WIDTH : integer:= 16;
	type CoeffsArray is array (integer range <>) of signed(15 downto 0);
	subtype Coeff is signed(C_S_COEFF_DATA_WIDTH-1 downto 0);
	
	constant PrescalerHB3: integer := 24;
	-- <16,15>
	constant C_HB3_0: Coeff:= to_signed(636,C_S_COEFF_DATA_WIDTH);
	constant C_HB3_1: Coeff:= to_signed(-3809,C_S_COEFF_DATA_WIDTH);
	constant C_HB3_2: Coeff:= to_signed(19569,C_S_COEFF_DATA_WIDTH);
								
	constant PrescalerHB2: integer := 12; 														
	constant C_HB2_0: Coeff := to_signed(435,C_S_COEFF_DATA_WIDTH);
	constant C_HB2_1: Coeff := to_signed(-3345,C_S_COEFF_DATA_WIDTH);
	constant C_HB2_2: Coeff := to_signed(19294,C_S_COEFF_DATA_WIDTH);

		
	constant PrescalerHB1: integer := 6;	
	constant C_HB1_0: Coeff := to_signed(-2086,C_S_COEFF_DATA_WIDTH);
	constant C_HB1_1: Coeff := to_signed(18470,C_S_COEFF_DATA_WIDTH);
	
  ---------------------------------------------------------------------------------------------------------------------------------
  --AXI Bus Communication Interface Parameters 
  ---------------------------------------------------------------------------------------------------------------------------------
	
	--Records for the Slave AXI Bus Interface in "S_AXI_lite.vhd" file
	type GLOBAL2SAXIS is record
	 s_axi_aclk		: std_logic;                                            --! Global Clock Signal.
	 s_axi_aresetn	: std_logic;                                            --! Global Reset Signal. This Signal is Active LOW.
	 s_axi_tdata		: std_logic_vector	(C_S_AXI_DATA_WIDTH-1 downto 0);    --! Write data (issued by master, acceped by Slave) 
	 s_axi_tvalid	    : std_logic;                                            --! Write valid. This signal indicates that valid write data and strobes are available.		
	end record GLOBAL2SAXIS;	
	
	type SAXIS2GLOBAL is record														
	 s_axi_tready     : std_logic;                                            --! Write ready. This signal indicates that the slave can accept the write data.
	 end record SAXIS2GLOBAL;
	
	constant GLOBAL2SAXIS_INIT : GLOBAL2SAXIS := (
		s_axi_aclk => '0',
		s_axi_aresetn => '0',																					
		s_axi_tdata => (others => '0'),
		s_axi_tvalid => '0');
		
	constant SAXIS2GLOBAL_INIT : SAXIS2GLOBAL := (
				s_axi_tready => '0');
	
	--Records for the Slave AXI Bus Interface in "S_AXI_lite.vhd" file
	type MAXIS2GLOBAL is record
	 m_axi_aclk		: std_logic;                                            --! Global Clock Signal.
	 m_axi_aresetn	: std_logic;                                            --! Global Reset Signal. This Signal is Active LOW.
	 m_axi_tdata		: std_logic_vector	(C_S_AXI_DATA_WIDTH-1 downto 0);    --! Write data (issued by master, acceped by Slave) 
	 m_axi_tvalid	    : std_logic;                                            --! Write valid. This signal indicates that valid write data and strobes are available.		
	 end record MAXIS2GLOBAL;	
	type GLOBAL2MAXIS is record														
		m_axi_tready     : std_logic;                                            --! Write ready. This signal indicates that the slave can accept the write data.
	end record GLOBAL2MAXIS;	
	
	constant MAXIS2GLOBAL_INIT : MAXIS2GLOBAL := (
			m_axi_aclk => '0',
			m_axi_aresetn => '0',																					
			m_axi_tdata => (others => '0'),
			m_axi_tvalid => '0');
			
		constant GLOBAL2MAXIS_INIT : GLOBAL2MAXIS := (
					m_axi_tready => '0');
	
end MultiStageHalfBandInterpolator_param;

package body MultiStageHalfBandInterpolator_param is
end package body;