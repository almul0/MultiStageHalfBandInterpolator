--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.2.2 (lin64) Build 2348494 Mon Oct  1 18:25:39 MDT 2018
--Date        : Thu Nov 15 00:06:07 2018
--Host        : cerebellum running 64-bit Debian GNU/Linux unstable (sid)
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  end component design_1;
begin
design_1_i: component design_1
 ;
end STRUCTURE;
