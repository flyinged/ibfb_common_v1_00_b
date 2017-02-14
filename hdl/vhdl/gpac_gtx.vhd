------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
------------------------------------------------------------------------------
-- Unit    : virtex5_gtx_pcore.vhd
-- Author  : Goran Marinkovic, Section Diagnostic
--         : Waldemar Koprek, Section Diagnostic
-- Version : $Revision: 1.1 $
------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
------------------------------------------------------------------------------
-- Comment : This is the package for the MGT Virtex5 GTX.
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library gpac_gtx_v1_01_a;
use gpac_gtx_v1_01_a.virtex5_gtx_package.all;

entity gpac_gtx is
  generic (
    C_GTX_TILE_REFCLK_FREQ     : integer    := 125;         -- GTX_REFCLK (125, 150) [MHz]
    C_GTX_125_BAUD_RATE        : integer    := 2500000;     -- GTX Baud Rate for GTX_REFCLK=125 in [kb/s]
    C_GTX_150_BAUD_RATE        : integer    := 3000000      -- GTX Baud Rate for GTX_REFCLK=150 in [kb/s] 
  );
  port (
    --GTX interface
    I_GTX_REFCLK_IN               : in  std_logic;
    O_GTX_REFCLK_OUT              : out std_logic;
    I_GTX_RX0_N                   : in  std_logic;
    I_GTX_RX0_P                   : in  std_logic;
    O_GTX_TX0_N                   : out std_logic;
    O_GTX_TX0_P                   : out std_logic;
    I_GTX_RX1_N                   : in  std_logic;
    I_GTX_RX1_P                   : in  std_logic;
    O_GTX_TX1_N                   : out std_logic;
    O_GTX_TX1_P                   : out std_logic;
    --User interface
    O_GTX_STATUS                  : out std_logic_vector(31 downto 0);
    I_GTX_CONTROL                 : in  std_logic_vector(31 downto 0);
    O_GTX_TX0_CLK                 : out std_logic;
    I_GTX_TX0_DATA                : in  std_logic_vector(31 downto 0);
    I_GTX_TX0_CHARISK             : in  std_logic_vector( 3 downto 0);
    O_GTX_RX0_CLK                 : out std_logic;
    O_GTX_RX0_DATA                : out std_logic_vector(31 downto 0);
    O_GTX_RX0_CHARISK             : out std_logic_vector( 3 downto 0);
    O_GTX_RX0_CHARISCOMMA         : out std_logic_vector( 3 downto 0);
    O_GTX_TX1_CLK                 : out std_logic;
    I_GTX_TX1_DATA                : in  std_logic_vector(31 downto 0);
    I_GTX_TX1_CHARISK             : in  std_logic_vector( 3 downto 0);
    O_GTX_RX1_CLK                 : out std_logic;
    O_GTX_RX1_DATA                : out std_logic_vector(31 downto 0);
    O_GTX_RX1_CHARISK             : out std_logic_vector( 3 downto 0);
    O_GTX_RX1_CHARISCOMMA         : out std_logic_vector( 3 downto 0)
  );
end gpac_gtx;

architecture structural of gpac_gtx is
  signal i_mgt                    : mgt_in_type;
  signal o_mgt                    : mgt_out_type;
  
  function F_GET_GTX_BAUD_RATE (C_REF_CLK : integer; C_125_BAUD_RATE : integer; C_150_BAUD_RATE : integer) return integer is
    variable v_CLK25_DIVIDER  : integer;
    variable v_PLL_DIVSEL_REF : integer;
    variable v_PLL_DIVSEL_FB  : integer;
    variable v_PLL_DIVSEL_OUT : integer;
   begin
    if C_REF_CLK = 125 then
      return C_125_BAUD_RATE;
    elsif C_REF_CLK = 150 then
      return C_150_BAUD_RATE;
    else
      assert false report "Invalid GTX reference frequency = " & integer'image(C_REF_CLK) severity error;
      return 0;
    end if;
   end F_GET_GTX_BAUD_RATE;
  
  constant C_GTX_BAUD_RATE        : integer := F_GET_GTX_BAUD_RATE(C_GTX_TILE_REFCLK_FREQ, C_GTX_125_BAUD_RATE, C_GTX_150_BAUD_RATE);
begin

  --tile instantiation
  mgt_virtex5_gtx_inst: mgt_virtex5_gtx
    generic map
    (
      SIM_MODE                  => "FAST",
      SIM_GTXRESET_SPEEDUP      => 0,
      SIM_PLL_PERDIV2           => X"0FA",
      G_GTX_TILE_REFCLK_FREQ    => C_GTX_TILE_REFCLK_FREQ,
      G_GTX_BAUD_RATE           => C_GTX_BAUD_RATE
    )
    port map
    (
      i_mgt                     => i_mgt,
      o_mgt                     => o_mgt
    );
    
  -- GTX0 serial interface
  i_mgt.rx(0).RXP               <= I_GTX_RX0_P;
  i_mgt.rx(0).RXN               <= I_GTX_RX0_N;
  O_GTX_TX0_P                   <= o_mgt.tx(0).TXP;
  O_GTX_TX0_N                   <= o_mgt.tx(0).TXN;
  
  -- GTX1 serial interface
  i_mgt.rx(1).RXP               <= I_GTX_RX1_P;
  i_mgt.rx(1).RXN               <= I_GTX_RX1_N;
  O_GTX_TX1_P                   <= o_mgt.tx(1).TXP;
  O_GTX_TX1_N                   <= o_mgt.tx(1).TXN;
    
  -- GTX ctrl
  i_mgt.ctrl.GTXRESET           <= '0';
  i_mgt.ctrl.CLKIN              <= I_GTX_REFCLK_IN;
  i_mgt.ctrl.REFCLKPWRDNB       <= '1';
  
    -- Loopback
  i_mgt.ctrl.LOOPBACK0          <= I_GTX_CONTROL( 2 downto  0); 
  i_mgt.ctrl.LOOPBACK1          <= I_GTX_CONTROL(18 downto 16);
  
    -- GTX0 RX
  O_GTX_RX0_CLK                 <= o_mgt.rx(0).RXRECCLK;
  i_mgt.rx(0).RXRESET           <= '0';
  i_mgt.rx(0).RXUSRCLK          <= '0';
  i_mgt.rx(0).RXUSRCLK2         <= '0';
  i_mgt.rx(0).RXENMCOMMAALIGN   <= '1';
  i_mgt.rx(0).RXENPCOMMAALIGN   <= '1';
  O_GTX_RX0_DATA                <= o_mgt.rx(0).RXDATA;
  O_GTX_RX0_CHARISK             <= o_mgt.rx(0).RXCHARISK;
  O_GTX_RX0_CHARISCOMMA         <= o_mgt.rx(0).RXCHARISCOMMA;
  
    -- GTX0 TX
  O_GTX_TX0_CLK                 <= o_mgt.tx(0).TXOUTCLK;
  i_mgt.tx(0).TXRESET           <= '0';
  i_mgt.tx(0).TXUSRCLK          <= '0';
  i_mgt.tx(0).TXUSRCLK2         <= '0';
  i_mgt.tx(0).TXBYPASS8B10B     <= "0000";
  i_mgt.tx(0).TXCHARDISPMODE    <= "0000";
  i_mgt.tx(0).TXCHARDISPVAL     <= "0000";
  i_mgt.tx(0).TXDIFFCTRL        <= I_GTX_CONTROL( 5 downto  3); 
  i_mgt.tx(0).TXPREEMPHASIS     <= "0" & I_GTX_CONTROL( 8 downto  6);
  i_mgt.tx(0).TXDATA            <= I_GTX_TX0_DATA; 
  i_mgt.tx(0).TXCHARISK         <= I_GTX_TX0_CHARISK; 
  
    -- GTX1 RX
  O_GTX_RX1_CLK                 <= o_mgt.rx(1).RXRECCLK;
  i_mgt.rx(1).RXRESET           <= '0';
  i_mgt.rx(1).RXUSRCLK          <= '0';
  i_mgt.rx(1).RXUSRCLK2         <= '0';
  i_mgt.rx(1).RXENMCOMMAALIGN   <= '1';
  i_mgt.rx(1).RXENPCOMMAALIGN   <= '1';
  O_GTX_RX1_DATA                <= o_mgt.rx(1).RXDATA;
  O_GTX_RX1_CHARISK             <= o_mgt.rx(1).RXCHARISK;
  O_GTX_RX1_CHARISCOMMA         <= o_mgt.rx(1).RXCHARISCOMMA;  
  
  -- GTX1 TX
  O_GTX_TX1_CLK                 <= o_mgt.tx(1).TXOUTCLK;
  i_mgt.tx(1).TXRESET           <= '0';
  i_mgt.tx(1).TXUSRCLK          <= '0';
  i_mgt.tx(1).TXUSRCLK2         <= '0';
  i_mgt.tx(1).TXBYPASS8B10B     <= "0000";
  i_mgt.tx(1).TXCHARDISPMODE    <= "0000";
  i_mgt.tx(1).TXCHARDISPVAL     <= "0000";
  i_mgt.tx(1).TXDIFFCTRL        <= I_GTX_CONTROL( 21 downto  19); --"010";"010";
  i_mgt.tx(1).TXPREEMPHASIS     <= "0" & I_GTX_CONTROL( 24 downto  22); --"0000";
  i_mgt.tx(1).TXDATA            <= I_GTX_TX1_DATA; 
  i_mgt.tx(1).TXCHARISK         <= I_GTX_TX1_CHARISK; 
  
  -- DRP
  i_mgt.drp.DCLK                <= '0';
  i_mgt.drp.DEN                 <= '0';
  i_mgt.drp.DWE                 <= '0';
  i_mgt.drp.DADDR               <= (others => '0');
  i_mgt.drp.DI                  <= (others => '0');
  
  --GTX STATUS 
  O_GTX_STATUS( 0)              <= o_mgt.ctrl.PLLLKDET;
  O_GTX_STATUS( 1)              <= o_mgt.ctrl.RESETDONE0;
  O_GTX_STATUS( 2)              <= o_mgt.ctrl.RESETDONE1;
  O_GTX_STATUS( 8)              <= o_mgt.rx(0).RXLOSSOFSYNC( 1);
  O_GTX_STATUS(16)              <= o_mgt.rx(1).RXLOSSOFSYNC( 1);
  
end structural;
