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
	
	constant C_S_SAMPLE_DATA_WIDTH : integer:= 12;
	constant C_S_COEFF_DATA_WIDTH : integer:= 16;
	type CoeffsArray is array (integer range <>) of signed(15 downto 0);
	subtype Coeff is signed(C_S_COEFF_DATA_WIDTH-1 downto 0);
	
	constant PrescalerHB3: integer := 24;
	-- <16,15>
	constant C_HB3_0: Coeff:= to_signed(694,C_S_COEFF_DATA_WIDTH);
	constant C_HB3_1: Coeff:= to_signed(-3918,C_S_COEFF_DATA_WIDTH);
	constant C_HB3_2: Coeff:= to_signed(19628,C_S_COEFF_DATA_WIDTH);
								
	constant PrescalerHB2: integer := 12; 														
	constant C_HB2_0: Coeff := to_signed(-2234,C_S_COEFF_DATA_WIDTH);
	constant C_HB2_1: Coeff := to_signed(18608,C_S_COEFF_DATA_WIDTH);
		
	constant PrescalerHB1: integer := 6;	
	constant C_HB1_0: Coeff := to_signed(-2093,C_S_COEFF_DATA_WIDTH);
	constant C_HB1_1: Coeff := to_signed(18476,C_S_COEFF_DATA_WIDTH);
	
  ---------------------------------------------------------------------------------------------------------------------------------
  --AXI Bus Communication Interface Parameters 
  ---------------------------------------------------------------------------------------------------------------------------------
	
	--Records for the Slave AXI Bus Interface in "S_AXI_lite.vhd" file
	type GLOBAL2SAXILITE is record
	 s_axi_aclk		: std_logic;                                            --! Global Clock Signal.
	 s_axi_aresetn	: std_logic;                                            --! Global Reset Signal. This Signal is Active LOW.
	 --s_axi_awaddr	    : std_logic_vector	(C_S_AXI_ADDR_WIDTH-1 downto 0);    --! Write address (issued by master, acceped by Slave).
	 --s_axi_awprot	    : std_logic_vector	(2 downto 0);                       --! Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
	 --s_axi_awvalid	: std_logic;                                            --! Write address valid. This signal indicates that the master signaling valid write address and control information.
	 s_axi_wdata		: std_logic_vector	(C_S_AXI_DATA_WIDTH-1 downto 0);    --! Write data (issued by master, acceped by Slave) 
	 s_axi_wstrb		: std_logic_vector	((C_S_AXI_DATA_WIDTH/8)-1 downto 0);--! Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.  
	 s_axi_wvalid	    : std_logic;                                            --! Write valid. This signal indicates that valid write data and strobes are available.		
	 s_axi_bready	    : std_logic;                                            --! Response ready. This signal indicates that the master can accept a write response.
	 --s_axi_araddr	    : std_logic_vector	(C_S_AXI_ADDR_WIDTH-1 downto 0);    --! Read address (issued by master, acceped by Slave)
	 --s_axi_arprot	    : std_logic_vector	(2 downto 0);                       --! Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
	 --s_axi_arvalid	: std_logic;                                            --! Read address valid. This signal indicates that the channel is signaling valid read address and control information.
	 --s_axi_rready	    : std_logic;                                            --! Read ready. This signal indicates that the master can accept the read data and response information.	
	end record GLOBAL2SAXILITE;	
	
	type SAXILITE2GLOBAL is record														
	 --s_axi_awready    : std_logic;                                            --! Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.														--! Write valid. This signal indicates that valid write data and strobes are available.		
	 s_axi_wready     : std_logic;                                            --! Write ready. This signal indicates that the slave can accept the write data.
	 s_axi_bresp      : std_logic_vector	(1 downto 0);                       --! Write response. This signal indicates the status of the write transaction.
	 s_axi_bvalid     : std_logic;                                            --! Write response valid. This signal indicates that the channel is signaling a valid write response.														--! Read address valid. This signal indicates that the channel is signaling valid read address and control information.
	 --s_axi_arready    : std_logic;                                            --! Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
	 --s_axi_rdata      : std_logic_vector	(C_S_AXI_DATA_WIDTH-1 downto 0);    --! Read data (issued by slave) 
	 --s_axi_rresp      : std_logic_vector	(1 downto 0);                       --! Read response. This signal indicates the status of the read transfer.
	 --s_axi_rvalid     : std_logic;                                            --! Read valid. This signal indicates that the channel is signaling the required read data.
	end record SAXILITE2GLOBAL;
	
	constant GLOBAL2SAXILITE_INIT : GLOBAL2SAXILITE := (
		s_axi_aclk => '0',
		s_axi_aresetn => '0',																					
		s_axi_wdata => (others => '0'),
		s_axi_wstrb =>(others => '1'),
		s_axi_wvalid => '0',
		s_axi_bready => '0');
		
	constant SAXILITE2GLOBAL_INIT : SAXILITE2GLOBAL := (
				s_axi_wready => '0',
				s_axi_bresp => (others => '0'),																					
				s_axi_bvalid => '0');
	
	--Records for the Slave AXI Bus Interface in "S_AXI_lite.vhd" file
	type MAXILITE2GLOBAL is record
	 m_axi_aclk		: std_logic;                                            --! Global Clock Signal.
	 m_axi_aresetn	: std_logic;                                            --! Global Reset Signal. This Signal is Active LOW.
	 --s_axi_awaddr	    : std_logic_vector	(C_S_AXI_ADDR_WIDTH-1 downto 0);    --! Write address (issued by master, acceped by Slave).
	 --s_axi_awprot	    : std_logic_vector	(2 downto 0);                       --! Write channel Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
	 --s_axi_awvalid	: std_logic;                                            --! Write address valid. This signal indicates that the master signaling valid write address and control information.
	 m_axi_wdata		: std_logic_vector	(C_S_AXI_DATA_WIDTH-1 downto 0);    --! Write data (issued by master, acceped by Slave) 
	 m_axi_wstrb		: std_logic_vector	((C_S_AXI_DATA_WIDTH/8)-1 downto 0);--! Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.  
	 m_axi_wvalid	    : std_logic;                                            --! Write valid. This signal indicates that valid write data and strobes are available.		
	 m_axi_bready	    : std_logic;                                            --! Response ready. This signal indicates that the master can accept a write response.
	 --s_axi_araddr	    : std_logic_vector	(C_S_AXI_ADDR_WIDTH-1 downto 0);    --! Read address (issued by master, acceped by Slave)
	 --s_axi_arprot	    : std_logic_vector	(2 downto 0);                       --! Protection type. This signal indicates the privilege and security level of the transaction, and whether the transaction is a data access or an instruction access.
	 --s_axi_arvalid	: std_logic;                                            --! Read address valid. This signal indicates that the channel is signaling valid read address and control information.
	 --s_axi_rready	    : std_logic;                                            --! Read ready. This signal indicates that the master can accept the read data and response information.	
	end record MAXILITE2GLOBAL;	
	type GLOBAL2MAXILITE is record														
	 --s_axi_awready    : std_logic;                                            --! Write address ready. This signal indicates that the slave is ready to accept an address and associated control signals.														--! Write valid. This signal indicates that valid write data and strobes are available.		
	 m_axi_wready     : std_logic;                                            --! Write ready. This signal indicates that the slave can accept the write data.
	 m_axi_bresp      : std_logic_vector	(1 downto 0);                       --! Write response. This signal indicates the status of the write transaction.
	 m_axi_bvalid     : std_logic;                                            --! Write response valid. This signal indicates that the channel is signaling a valid write response.														--! Read address valid. This signal indicates that the channel is signaling valid read address and control information.
	 --s_axi_arready    : std_logic;                                            --! Read address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
	 --s_axi_rdata      : std_logic_vector	(C_S_AXI_DATA_WIDTH-1 downto 0);    --! Read data (issued by slave) 
	 --s_axi_rresp      : std_logic_vector	(1 downto 0);                       --! Read response. This signal indicates the status of the read transfer.
	 --s_axi_rvalid     : std_logic;                                            --! Read valid. This signal indicates that the channel is signaling the required read data.
	end record GLOBAL2MAXILITE;	
	
	constant MAXILITE2GLOBAL_INIT : MAXILITE2GLOBAL := (
			m_axi_aclk => '0',
			m_axi_aresetn => '0',																					
			m_axi_wdata => (others => '0'),
			m_axi_wstrb =>(others => '1'),
			m_axi_wvalid => '0',
			m_axi_bready => '0');
			
		constant GLOBAL2MAXILITE_INIT : GLOBAL2MAXILITE := (
					m_axi_wready => '0',
					m_axi_bresp => (others => '0'),																					
					m_axi_bvalid => '0');
	
end MultiStageHalfBandInterpolator_param;

package body MultiStageHalfBandInterpolator_param is
end package body;