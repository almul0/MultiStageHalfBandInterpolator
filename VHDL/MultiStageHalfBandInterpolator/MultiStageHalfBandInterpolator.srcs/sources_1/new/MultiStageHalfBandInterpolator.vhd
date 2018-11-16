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
		SlaveAxi_RI : in GLOBAL2SAXILITE;
		SlaveAxi_RO : out SAXILITE2GLOBAL;
		
		MasterAxi_RI : in GLOBAL2MAXILITE;
		MasterAxi_RO : out MAXILITE2GLOBAL
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
			SlaveAxi_RI : in GLOBAL2SAXILITE;
			SlaveAxi_RO : out SAXILITE2GLOBAL;
			
			MasterAxi_RI : in GLOBAL2MAXILITE;
			MasterAxi_RO : out MAXILITE2GLOBAL
			);
	END COMPONENT;
	COMPONENT HalfBandFilterTwoTaps
		Generic(
		     PRESCALER: integer;
		     COEFF0: Coeff;
				 COEFF1: Coeff
		     );
		PORT(
				SlaveAxi_RI : in GLOBAL2SAXILITE;
				SlaveAxi_RO : out SAXILITE2GLOBAL;
				
				MasterAxi_RI : in GLOBAL2MAXILITE;
				MasterAxi_RO : out MAXILITE2GLOBAL
				);
		END COMPONENT;
	
	signal Master03Axi_RI : GLOBAL2MAXILITE;
	signal Master03Axi_RO : MAXILITE2GLOBAL;
	
	signal Master02Axi_RI : GLOBAL2MAXILITE;
	signal Master02Axi_RO : MAXILITE2GLOBAL;
	
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
		SlaveAxi_RI.s_axi_wdata    => SlaveAxi_RI.s_axi_wdata,
		SlaveAxi_RI.s_axi_wstrb    => SlaveAxi_RI.s_axi_wstrb,
		SlaveAxi_RI.s_axi_wvalid   => SlaveAxi_RI.s_axi_wvalid,
		SlaveAxi_RI.s_axi_bready   => SlaveAxi_RI.s_axi_bready,

		SlaveAxi_RO.s_axi_wready   => SlaveAxi_RO.s_axi_wready,
		SlaveAxi_RO.s_axi_bresp    => SlaveAxi_RO.s_axi_bresp,
		SlaveAxi_RO.s_axi_bvalid   => SlaveAxi_RO.s_axi_bvalid,	
		
		MasterAxi_RO.m_axi_aclk    => Master03Axi_RO.m_axi_aclk,
		MasterAxi_RO.m_axi_aresetn => Master03Axi_RO.m_axi_aresetn,
		MasterAxi_RO.m_axi_wdata   => Master03Axi_RO.m_axi_wdata,
		MasterAxi_RO.m_axi_wstrb   => Master03Axi_RO.m_axi_wstrb,
		MasterAxi_RO.m_axi_wvalid  => Master03Axi_RO.m_axi_wvalid,
		MasterAxi_RO.m_axi_bready  => Master03Axi_RO.m_axi_bready,

		MasterAxi_RI.m_axi_wready  => Master03Axi_RI.m_axi_wready,
		MasterAxi_RI.m_axi_bresp   => Master03Axi_RI.m_axi_bresp,
		MasterAxi_RI.m_axi_bvalid  => Master03Axi_RI.m_axi_bvalid	
	);
	
	HB2: HalfBandFilterTwoTaps
		GENERIC MAP(
			PRESCALER => PrescalerHB2,
				COEFF0 => C_HB2_0,
				COEFF1 => C_HB2_1
		)
		PORT MAP(
			SlaveAxi_RI.s_axi_aclk     => Master03Axi_RO.m_axi_aclk,
			SlaveAxi_RI.s_axi_aresetn  => Master03Axi_RO.m_axi_aresetn,
			SlaveAxi_RI.s_axi_wdata    => Master03Axi_RO.m_axi_wdata,
			SlaveAxi_RI.s_axi_wstrb    => Master03Axi_RO.m_axi_wstrb,
			SlaveAxi_RI.s_axi_wvalid   => Master03Axi_RO.m_axi_wvalid,
			SlaveAxi_RI.s_axi_bready   => Master03Axi_RO.m_axi_bready,
	
			SlaveAxi_RO.s_axi_wready   => Master03Axi_RI.m_axi_wready,
			SlaveAxi_RO.s_axi_bresp    => Master03Axi_RI.m_axi_bresp,
			SlaveAxi_RO.s_axi_bvalid   => Master03Axi_RI.m_axi_bvalid,	
			
			MasterAxi_RO.m_axi_aclk    => Master02Axi_RO.m_axi_aclk,
			MasterAxi_RO.m_axi_aresetn => Master02Axi_RO.m_axi_aresetn,
			MasterAxi_RO.m_axi_wdata   => Master02Axi_RO.m_axi_wdata,
			MasterAxi_RO.m_axi_wstrb   => Master02Axi_RO.m_axi_wstrb,
			MasterAxi_RO.m_axi_wvalid  => Master02Axi_RO.m_axi_wvalid,
			MasterAxi_RO.m_axi_bready  => Master02Axi_RO.m_axi_bready,

			MasterAxi_RI.m_axi_wready  => Master02Axi_RI.m_axi_wready,
			MasterAxi_RI.m_axi_bresp   => Master02Axi_RI.m_axi_bresp,
			MasterAxi_RI.m_axi_bvalid  => Master02Axi_RI.m_axi_bvalid	
			
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
				SlaveAxi_RI.s_axi_wdata    => Master02Axi_RO.m_axi_wdata,
				SlaveAxi_RI.s_axi_wstrb    => Master02Axi_RO.m_axi_wstrb,
				SlaveAxi_RI.s_axi_wvalid   => Master02Axi_RO.m_axi_wvalid,
				SlaveAxi_RI.s_axi_bready   => Master02Axi_RO.m_axi_bready,
		
				SlaveAxi_RO.s_axi_wready   => Master02Axi_RI.m_axi_wready,
				SlaveAxi_RO.s_axi_bresp    => Master02Axi_RI.m_axi_bresp,
				SlaveAxi_RO.s_axi_bvalid   => Master02Axi_RI.m_axi_bvalid,	
				
				MasterAxi_RO.m_axi_aclk    => MasterAxi_RO.m_axi_aclk,
				MasterAxi_RO.m_axi_aresetn => MasterAxi_RO.m_axi_aresetn,
				MasterAxi_RO.m_axi_wdata   => MasterAxi_RO.m_axi_wdata,
				MasterAxi_RO.m_axi_wstrb   => MasterAxi_RO.m_axi_wstrb,
				MasterAxi_RO.m_axi_wvalid  => MasterAxi_RO.m_axi_wvalid,
				MasterAxi_RO.m_axi_bready  => MasterAxi_RO.m_axi_bready,
	
				MasterAxi_RI.m_axi_wready  => MasterAxi_RI.m_axi_wready,
				MasterAxi_RI.m_axi_bresp   => MasterAxi_RI.m_axi_bresp,
				MasterAxi_RI.m_axi_bvalid  => MasterAxi_RI.m_axi_bvalid	
			);
	
end Behavioral;
