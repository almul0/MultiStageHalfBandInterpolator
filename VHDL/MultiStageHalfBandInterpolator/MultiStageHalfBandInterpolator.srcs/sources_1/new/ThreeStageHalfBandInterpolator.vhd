----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/12/2018 04:12:40 PM
-- Design Name: 
-- Module Name: ThreeStageHalfBandInterpolator - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ThreeStageHalfBandInterpolator is
--  Port ( );
	Port(
		-- Clock and Reset
		S_AXI_ACLK : in std_logic;
		S_AXI_ARESETN : in std_logic;
		-- Write Data Channel
		S_AXI_WDATA : in std_logic_vector(31 downto 0);
		S_AXI_WSTRB : in std_logic_vector(3 downto 0);
		S_AXI_WVALID : in std_logic;
		-- Write Response Channel
		S_AXI_BRESP : out std_logic_vector(1 downto 0);
		S_AXI_BVALID : out std_logic;
		S_AXI_BREADY : in std_logic;
		
		-- Clock and Reset
		M_AXI_ACLK : out std_logic;
		M_AXI_ARESETN : out std_logic;
		-- Write Data Channel
		M_AXI_WDATA : out std_logic_vector(31 downto 0);
		M_AXI_WSTRB : out std_logic_vector(3 downto 0);
		M_AXI_WVALID : out std_logic;
		-- Write Response Channel
		M_AXI_BRESP : in std_logic_vector(1 downto 0);
		M_AXI_BVALID : in std_logic;
		M_AXI_BREADY : in std_logic
	);
end ThreeStageHalfBandInterpolator;

architecture Behavioral of ThreeStageHalfBandInterpolator is
	COMPONENT HalfBandFilter
	PORT(
			 CLK : IN  std_logic;
			 RESET : IN  std_logic;
			 SAL : OUT  std_logic_vector(20 downto 0)
			);
	END COMPONENT;

begin
	
end Behavioral;
