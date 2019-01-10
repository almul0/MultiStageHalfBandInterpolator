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
use IEEE.NUMERIC_STD.ALL;
use work.MultiStageHalfBandInterpolator_param.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MultiStageHalfBandInterpolator is
--  Port ( );
	Port(
		SlaveAxi_RI : in GLOBAL2SAXIS;
		SlaveAxi_RO : out SAXIS2GLOBAL;
		
		MasterAxi_RI : in GLOBAL2MAXIS;
		MasterAxi_RO : out MAXIS2GLOBAL
	);
end MultiStageHalfBandInterpolator;

architecture Behavioral of MultiStageHalfBandInterpolator is
	COMPONENT HalfBandFilterThreeTaps
	Generic(
	     PRESCALER: integer;
	     COEFF0: Coeff;
			 COEFF1: Coeff;
			 COEFF2: Coeff
	     );
	PORT(
			SlaveAxi_RI : in GLOBAL2SAXIS;
			SlaveAxi_RO : out SAXIS2GLOBAL;
			
			MasterAxi_RI : in GLOBAL2MAXIS;
			MasterAxi_RO : out MAXIS2GLOBAL
			);
	END COMPONENT;
	COMPONENT HalfBandFilterTwoTaps
		Generic(
		     PRESCALER: integer;
		     COEFF0: Coeff;
				 COEFF1: Coeff
		     );
		PORT(
				SlaveAxi_RI : in GLOBAL2SAXIS;
				SlaveAxi_RO : out SAXIS2GLOBAL;
				
				MasterAxi_RI : in GLOBAL2MAXIS;
				MasterAxi_RO : out MAXIS2GLOBAL
				);
		END COMPONENT;
	
	signal Master03Axi_RI : GLOBAL2MAXIS;
	signal Master03Axi_RO : MAXIS2GLOBAL;
	
	signal Master02Axi_RI : GLOBAL2MAXIS;
	signal Master02Axi_RO : MAXIS2GLOBAL;
	
begin
	HB3: HalfBandFilterThreeTaps
	GENERIC MAP(
		PRESCALER => PrescalerHB3,
		COEFF0 => C_HB3_0,
		COEFF1 => C_HB3_1,
		COEFF2 => C_HB3_2
	)
	PORT MAP(
		SlaveAxi_RI.s_axi_aclk     => SlaveAxi_RI.s_axi_aclk,
		SlaveAxi_RI.s_axi_aresetn  => SlaveAxi_RI.s_axi_aresetn,
		SlaveAxi_RI.s_axi_tdata    => SlaveAxi_RI.s_axi_tdata,
		SlaveAxi_RI.s_axi_tvalid   => SlaveAxi_RI.s_axi_tvalid,

		SlaveAxi_RO.s_axi_tready   => SlaveAxi_RO.s_axi_tready,
		
		MasterAxi_RO.m_axi_aclk    => Master03Axi_RO.m_axi_aclk,
		MasterAxi_RO.m_axi_aresetn => Master03Axi_RO.m_axi_aresetn,
		MasterAxi_RO.m_axi_tdata   => Master03Axi_RO.m_axi_tdata,
		MasterAxi_RO.m_axi_tvalid  => Master03Axi_RO.m_axi_tvalid,

		MasterAxi_RI.m_axi_tready  => Master03Axi_RI.m_axi_tready
	);
	
	HB2: HalfBandFilterThreeTaps
		GENERIC MAP(
			PRESCALER => PrescalerHB2,
				COEFF0 => C_HB2_0,
				COEFF1 => C_HB2_1,
				COEFF2 => C_HB2_2
		)
		PORT MAP(
			SlaveAxi_RI.s_axi_aclk     => Master03Axi_RO.m_axi_aclk,
			SlaveAxi_RI.s_axi_aresetn  => Master03Axi_RO.m_axi_aresetn,
			SlaveAxi_RI.s_axi_tdata    => Master03Axi_RO.m_axi_tdata,
			SlaveAxi_RI.s_axi_tvalid   => Master03Axi_RO.m_axi_tvalid,
	
			SlaveAxi_RO.s_axi_tready   => Master03Axi_RI.m_axi_tready,
			
			MasterAxi_RO.m_axi_aclk    => Master02Axi_RO.m_axi_aclk,
			MasterAxi_RO.m_axi_aresetn => Master02Axi_RO.m_axi_aresetn,
			MasterAxi_RO.m_axi_tdata   => Master02Axi_RO.m_axi_tdata,
			MasterAxi_RO.m_axi_tvalid  => Master02Axi_RO.m_axi_tvalid,

			MasterAxi_RI.m_axi_tready  => Master02Axi_RI.m_axi_tready
			
		);
		
		HB1: HalfBandFilterTwoTaps
			GENERIC MAP(
				PRESCALER => PrescalerHB1,
				COEFF0 => C_HB1_0,
				COEFF1 => C_HB1_1
			)
			PORT MAP(
				SlaveAxi_RI.s_axi_aclk     => Master02Axi_RO.m_axi_aclk,
				SlaveAxi_RI.s_axi_aresetn  => Master02Axi_RO.m_axi_aresetn,
				SlaveAxi_RI.s_axi_tdata    => Master02Axi_RO.m_axi_tdata,
				SlaveAxi_RI.s_axi_tvalid   => Master02Axi_RO.m_axi_tvalid,
		
				SlaveAxi_RO.s_axi_tready   => Master02Axi_RI.m_axi_tready,
				
				MasterAxi_RO.m_axi_aclk    => MasterAxi_RO.m_axi_aclk,
				MasterAxi_RO.m_axi_aresetn => MasterAxi_RO.m_axi_aresetn,
				MasterAxi_RO.m_axi_tdata   => MasterAxi_RO.m_axi_tdata,
				MasterAxi_RO.m_axi_tvalid  => MasterAxi_RO.m_axi_tvalid,
	
				MasterAxi_RI.m_axi_tready  => MasterAxi_RI.m_axi_tready
			);
	
end Behavioral;
