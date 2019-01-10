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

entity HalfBandFilterThreeTaps is
  Generic(
    PRESCALER: integer;
    COEFF0:    Coeff;
    COEFF1:    Coeff;
    COEFF2:    Coeff
  );
  Port(
    SlaveAxi_RI : in GLOBAL2SAXIS;
    SlaveAxi_RO : out SAXIS2GLOBAL;

    MasterAxi_RI : in GLOBAL2MAXIS;
    MasterAxi_RO : out MAXIS2GLOBAL
  );
end HalfBandFilterThreeTaps;

architecture Behavioral of HalfBandFilterThreeTaps is

  constant N_OP: integer:= 4;
  constant N_COEFF: integer:= 3;

  signal SampleIn_D, SampleIn_DN : signed(C_S_SAMPLE_DATA_WIDTH-1 downto 0):= (others => '0');
  type SlaveAxiStateType is (IDLE, WAIT_WVALID);  -- Define the states
  type MasterAxiStateType is (IDLE, WAIT_WREADY);  -- Define the states
  
  
  signal SlaveAxiState_S, SlaveAxiState_SN : SlaveAxiStateType;    -- Create a signal that uses
  signal MasterAxiState_S, MasterAxiState_SN : MasterAxiStateType;    -- Create a signal that uses
  
  signal MasterAxi_tvalid_SN: std_logic := '0';
  signal MasterAxi_tready_S : std_logic := '0';
  signal MasterAxi_tdata_SN: std_logic_vector  (C_S_AXI_DATA_WIDTH-1 downto 0);
  
  signal SlaveAxi_tready_SN: std_logic := '0';
  signal SlaveAxi_tdata_S: std_logic_vector  (C_S_AXI_DATA_WIDTH-1 downto 0);
  signal SlaveAxi_tvalid_S: std_logic;
  
  -- Posicion 0 muestra actual
  -- Position 1-N linea de retardo
  type DelayLineArray is array (0 to (N_COEFF*2-1)-1) of signed(C_S_SAMPLE_DATA_WIDTH-1 downto 0);
  signal DelayLine: DelayLineArray;
  
  signal ClkDividerCounter_S,ClkDividerCounter_SN: unsigned(integer(floor(log2(real(PRESCALER)))) downto 0) := (others => '0');
  signal OutEnable_S,OutEnable_SN: std_logic := '0';
  signal OpEnable_S,OpEnable_SN: std_logic := '0';
  
  signal OpCounter_S, OpCounter_SN: unsigned(integer(floor(log2(real(N_OP+1)))) downto 0) := (others => '0');
  
  signal SumResult_S, SumResult_SN: signed(C_S_SAMPLE_DATA_WIDTH downto 0):= (others => '0');
  signal MultResult_S, MultResult_SN: signed(C_S_COEFF_DATA_WIDTH + SumResult_S'LENGTH - 1  downto 0) := (others => '0');
  
  signal MultA_S: signed(C_S_COEFF_DATA_WIDTH-1 downto 0);
  signal MultB_S: signed(C_S_SAMPLE_DATA_WIDTH downto 0);

  signal Out2_D, Out2_DN: signed(MultResult_S'LENGTH - 2 + integer(floor(log2(real(N_COEFF)))) downto 0) := (others => '0');
  signal Out_D : signed(C_S_SAMPLE_DATA_WIDTH-1 downto 0) := (others => '0');
  signal OutSelector_S,OutSelector_SN: std_logic := '0';
  
  
  -- Debug signals
  signal OutDebug_D: signed(C_S_SAMPLE_DATA_WIDTH-1 downto 0) := (others => '0');

begin

  MasterAxi_RO.m_axi_aclk <= SlaveAxi_RI.s_axi_aclk;
  MasterAxi_RO.m_axi_aresetn <= SlaveAxi_RI.s_axi_aresetn;
  
  --seq_proc
  process(SlaveAxi_RI.s_axi_aclk,SlaveAxi_RI.s_axi_aresetn)
  begin
  
      if(SlaveAxi_RI.s_axi_aresetn = '0') then    --active high reset for the counter.
          OutSelector_S <= '0';
          ClkDividerCounter_S <= (others => '0');
          
          OutEnable_S <= '0';
          OpEnable_S <= '0';
          SlaveAxiState_S <= IDLE;
          MasterAxiState_S <= IDLE;

      
          MasterAxi_RO.m_axi_tdata  <= (others => '0'); 
          MasterAxi_RO.m_axi_tvalid  <= '0';    
          
          SlaveAxi_RO.s_axi_tready <= '0';
          
          DelayLine <= (others => (others => '0'));
          
          SumResult_S <= (others => '0');
          MultResult_S <= (others => '0');
          
          SampleIn_D <= (others => '0');
          
          OpCounter_S <= (others => '0');
          
          MasterAxi_tready_S <= '0';
          SlaveAxi_tvalid_S <= '0';
          SlaveAxi_tdata_S <= (others => '0');
          
      elsif(rising_edge(SlaveAxi_RI.s_axi_aclk)) then
        
        OutSelector_S <= OutSelector_SN;
        ClkDividerCounter_S <= ClkDividerCounter_SN;
        
        OutEnable_S <= OutEnable_SN;
        OpEnable_S <= OpEnable_SN;
        SlaveAxiState_S <= SlaveAxiState_SN;
        MasterAxiState_S <= MasterAxiState_SN;      
        
        MasterAxi_RO.m_axi_tdata  <= MasterAxi_tdata_SN;
        MasterAxi_RO.m_axi_tvalid  <= MasterAxi_tvalid_SN;

        SlaveAxi_RO.s_axi_tready <= SlaveAxi_tready_SN;
        
        MasterAxi_tready_S <= MasterAxi_RI.m_axi_tready;
        SlaveAxi_tvalid_S <= SlaveAxi_RI.s_axi_tvalid;
        SlaveAxi_tdata_S <= SlaveAxi_RI.s_axi_tdata;
        
        Out2_D <= Out2_DN;
        
        SampleIn_D <= SampleIn_DN;
        OpCounter_S <= OpCounter_SN;
        
        MultResult_S <= MultResult_SN;
        SumResult_S <= SumResult_SN;
        
        if ( OpEnable_SN = '1') then
          DelayLine <= SampleIn_D & DelayLine(0 to DelayLine'length-2);
        end if;
        
      end if; 
  end process;
  
  

  MultResult_SN <= MultA_S * MultB_S;
  
  FILTER_OPS: process(OpCounter_S, OpEnable_S, OutEnable_S, SampleIn_D, ClkDividerCounter_S, MultResult_S, SumResult_S, DelayLine, Out2_D)
  begin
  
    OutSelector_SN <= '0';
    OutEnable_SN <= '0';
    Out2_DN <= Out2_D;
    
    if ( (ClkDividerCounter_S > 0 and ClkDividerCounter_S <= PRESCALER) OR OutEnable_S = '1') then
      ClkDividerCounter_SN <= ClkDividerCounter_S + 1;
    else
      ClkDividerCounter_SN <= ClkDividerCounter_S;
    end if;
    
    if ( ClkDividerCounter_S >= PRESCALER-1 ) then
        OutSelector_SN <= '1';
    end if;
  
    if ( (OpCounter_S > 0 and OpCounter_S <= N_OP) OR OpEnable_S = '1') then
      OpCounter_SN <= OpCounter_S + 1;
    else 
      OpCounter_SN <= (others => '0');
    end if;  
    
    MultA_S <= (others => '0');
    MultB_S <= (others => '0');
        
    if (OpCounter_S = 0 AND OpEnable_S = '1') then
      SumResult_SN <= resize(SampleIn_D,SumResult_SN'length) + DelayLine(DelayLine'LENGTH-1);
    elsif ( OpCounter_S = 1 ) then
      MultA_S <= COEFF0;
      MultB_S <= SumResult_S;
      SumResult_SN <= resize(DelayLine(to_integer(OpCounter_S)-1),SumResult_SN'length) + 
                      DelayLine(DelayLine'LENGTH-1-to_integer(OpCounter_S));
    elsif ( OpCounter_S = 2 ) then
      Out2_DN <= resize(MultResult_S(MultResult_S'length-2 downto 0),Out2_DN'length);
      MultA_S <= COEFF1;
      MultB_S <= SumResult_S;
      SumResult_SN <=  resize(DelayLine(to_integer(OpCounter_S)-1),SumResult_SN'length) + 
                       DelayLine(DelayLine'LENGTH-1-to_integer(OpCounter_S));
    elsif ( OpCounter_S = 3 ) then
      Out2_DN <= Out2_D + MultResult_S;
      MultA_S <= COEFF2;
      MultB_S <= SumResult_S;
      SumResult_SN <=  resize(DelayLine(to_integer(OpCounter_S)-1),SumResult_SN'length) + 
                             DelayLine(DelayLine'LENGTH-1-to_integer(OpCounter_S));
    elsif ( OpCounter_S = 4 ) then
      -- Quitamos bit de signo duplicado y sumamos
      Out2_DN <= Out2_D + MultResult_S;
      SumResult_SN <= (others => '0');
      OutEnable_SN <= '1';
      OutSelector_SN <= '0';
      
      ClkDividerCounter_SN <= (others => '0');
    else 
      SumResult_SN <= (others => '0');
    end if;
    
  end process;
  
  MASTERAXI_DECODE: process(MasterAxiState_S, OutEnable_S, OutSelector_S, DelayLine, ClkDividerCounter_S, Out2_D, MasterAxi_tready_S)
  variable axi_sample_data: signed(C_S_SAMPLE_DATA_WIDTH-1 downto 0);
  begin
        
    -- State Machine controlling data output

    MasterAxiState_SN <= MasterAxiState_S;
    
    OutDebug_D <= (others => '0');
    
    if ( OutSelector_S = '1' ) then
      axi_sample_data := DelayLine(1);
    else
      -- Truncamos a dos bits de parte entera para convertirlo en fraccionario
      axi_sample_data :=  shift_right(Out2_D,15)(axi_sample_data'length-1 downto 0);          
    end if;
    
    MasterAxi_tvalid_SN <= '0';  
    MasterAxi_tdata_SN <= (MasterAxi_RO.m_axi_tdata'length-1 downto axi_sample_data'length => '0') & std_logic_vector(axi_sample_data);
    OutDebug_D <=  axi_sample_data;
    
    case MasterAxiState_S is
      when IDLE =>
        if ( ClkDividerCounter_S = PRESCALER OR OutEnable_S = '1') then   
          MasterAxi_tvalid_SN <= '1';
          MasterAxiState_SN <= WAIT_WREADY;
        else
          MasterAxi_tdata_SN <= (others => '0');
        end if;
      
      when WAIT_WREADY =>              
          MasterAxi_tvalid_SN <= '1';
          if MasterAxi_tready_S = '1' then
            MasterAxiState_SN   <= IDLE;
            MasterAxi_tdata_SN  <= (others => '0');
            MasterAxi_tvalid_SN <= '0';
          end if;
          
      when others =>
        MasterAxiState_SN <= IDLE;
    end case;
  end process;

  SLAVEAXI_DECODE: process(SlaveAxiState_S, SampleIn_D, SlaveAxi_tvalid_S, SlaveAxi_tdata_S)
  begin
    -- State Machine controlling data input
    SlaveAxi_tready_SN <= '0';
    OpEnable_SN <= '0';
    
    SlaveAxiState_SN <= SlaveAxiState_S;
    SampleIn_DN <= SampleIn_D;    
    
    case SlaveAxiState_S is
      WHEN IDLE =>      
        SlaveAxi_tready_SN <= '1';
        SlaveAxiState_SN <= WAIT_WVALID;
        
      when WAIT_WVALID =>
        SlaveAxi_tready_SN <= '1';
        
        if SlaveAxi_tvalid_S = '1' then
          SlaveAxi_tready_SN <= '0';
          SampleIn_DN <= signed(SlaveAxi_tdata_S(C_S_SAMPLE_DATA_WIDTH-1 downto 0));
          
          OpEnable_SN <= '1';
          
          SlaveAxiState_SN <= IDLE;
        end if;
        
      when others =>
        SlaveAxiState_SN <= IDLE;
    end case;
  end process;
  


end Behavioral;
