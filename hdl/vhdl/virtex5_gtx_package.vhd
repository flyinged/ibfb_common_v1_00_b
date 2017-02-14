------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
------------------------------------------------------------------------------
-- Unit    : mgt_virtex5_gtx.vhd
-- Author  : Goran Marinkovic, Section Diagnostic
--         : Waldemar Koprek, Section Diagnostic
-- Version : $Revision: 1.2 $
------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
------------------------------------------------------------------------------
-- Comment : This is the package for the MGT Virtex5 GTX.
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Module MGT Virtex5 GTX Package
------------------------------------------------------------------------------
-- Std. library (platform) ---------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

-- Work library (platform) ---------------------------------------------------

-- Work library (application) ------------------------------------------------

package virtex5_gtx_package is

   ---------------------------------------------------------------------------
   -- Type
   ---------------------------------------------------------------------------
   type mgt_ctrl_in_type is record
      -- Global ports
      GTXRESET                    : std_ulogic;
      -- PLL
      CLKIN                       : std_ulogic;
      REFCLKPWRDNB                : std_ulogic;
--      PLLPOWERDOWN                : std_ulogic;
      -- Loopback
      LOOPBACK0                   : std_logic_vector( 2 downto  0);
      LOOPBACK1                   : std_logic_vector( 2 downto  0);
   end record mgt_ctrl_in_type;

   type mgt_ctrl_out_type is record
      -- Global ports
      RESETDONE0                  : std_ulogic;
      RESETDONE1                  : std_ulogic;
      -- PLL
      REFCLKOUT                   : std_ulogic;
      PLLLKDET                    : std_ulogic;
   end record mgt_ctrl_out_type;

   type mgt_drp_in_type is record
      -- Dynamic Reconfiguration Port (DRP)
      DCLK                        : std_ulogic;
      DEN                         : std_ulogic;
      DWE                         : std_ulogic;
      DADDR                       : std_logic_vector( 6 downto  0);
      DI                          : std_logic_vector(15 downto  0);
   end record mgt_drp_in_type;

   type mgt_drp_out_type is record
      -- Dynamic Reconfiguration Port (DRP)
      DO                          : std_logic_vector(15 downto  0);
      DRDY                        : std_ulogic;
   end record mgt_drp_out_type;

   type mgt_rx_in_type is record
      -- RX resets
      RXRESET                     : std_ulogic;
      -- RX power control
--      RXPOWERDOWN                 : std_logic_vector( 1 downto  0);
      -- RX user clocks
      RXUSRCLK                    : std_ulogic;
      RXUSRCLK2                   : std_ulogic;
      -- RX serial ports
      RXP                         : std_ulogic;
      RXN                         : std_ulogic;
      -- RX EQualizer (EQ)
--      RXENEQB                     : std_ulogic;
--      RXEQMIX                     : std_logic_vector( 1 downto  0);
--      RXEQPOLE                    : std_logic_vector( 3 downto  0);
      -- RX Decision Feedback Equalizer(DFE)
--      DFECLKDLYADJ                : std_logic_vector( 5 downto  0);
--      DFETAP1                     : std_logic_vector( 4 downto  0);
--      DFETAP2                     : std_logic_vector( 4 downto  0);
--      DFETAP3                     : std_logic_vector( 3 downto  0);
--      DFETAP4                     : std_logic_vector( 3 downto  0);
      -- RX Clock Data Recovery (CDR)
--      RXCDRRESET                  : std_ulogic;
      -- RX oversampling
--      RXENSAMPLEALIGN             : std_ulogic;
      -- RX polarity
--      RXPOLARITY                  : std_ulogic;
      -- RX Pseudo Random Bit Sequences (PRBS)
--      PRBSCNTRESET                : std_ulogic;
--      RXENPRBSTST                 : std_logic_vector( 1 downto  0);
      -- RX comma detection and alignment
--      RXCOMMADETUSE               : std_ulogic;
      RXENMCOMMAALIGN             : std_ulogic;
      RXENPCOMMAALIGN             : std_ulogic;
--      RXSLIDE                     : std_ulogic;
      -- RX 8b10b decoder
--      RXDATAWIDTH                 : std_logic_vector( 1 downto  0);
--      RXDEC8B10BUSE               : std_ulogic;
      -- RX elastic buffer
--      RXBUFRESET                  : std_ulogic;
      RXENPMAPHASEALIGN           : std_ulogic;
      RXPMASETPHASE               : std_ulogic;
      -- RX channel bonding
--      RXCHBONDI                   : std_logic_vector( 3 downto  0);
--      RXENCHANSYNC                : std_ulogic;
      -- RX 64b66b and 64b67b gearbox
--      RXGEARBOXSLIP               : std_ulogic;
   end record mgt_rx_in_type;

   type mgt_rx_in_array_type is array (0 to 1) of mgt_rx_in_type;

   type mgt_rx_out_type is record
      -- RX user clocks
      RXRECCLK                      : std_ulogic;
      -- RX Decision Feedback Equalizer(DFE)
--      DFECLKDLYADJMONITOR         : std_logic_vector( 5 downto  0);
--      DFEEYEDACMONITOR            : std_logic_vector( 4 downto  0);
--      DFESENSCAL                  : std_logic_vector( 2 downto  0);
--      DFETAP1MONITOR              : std_logic_vector( 4 downto  0);
--      DFETAP2MONITOR              : std_logic_vector( 4 downto  0);
--      DFETAP3MONITOR              : std_logic_vector( 3 downto  0);
--      DFETAP4MONITOR              : std_logic_vector( 3 downto  0);
      -- RX Out Of Band (OOB)
      RXELECIDLE                  : std_ulogic;
--      RXVALID                     : std_ulogic;
--      PHYSTATUS                   : std_ulogic;
      -- RX oversampling
--      RXOVERSAMPLEERR             : std_ulogic;
      -- RX Pseudo Random Bit Sequences (PRBS)
--      RXPRBSERR                   : std_ulogic;
      -- RX comma detection and alignment
--      RXBYTEISALIGNED             : std_ulogic;
--      RXBYTEREALIGN               : std_ulogic;
--      RXCOMMADET                  : std_ulogic;
      -- RX loss of sync fsm
      RXLOSSOFSYNC                : std_logic_vector( 1 downto  0);
      -- RX 8b10b decoder
      RXCHARISCOMMA               : std_logic_vector( 3 downto  0);
      RXCHARISK                   : std_logic_vector( 3 downto  0);
      RXDISPERR                   : std_logic_vector( 3 downto  0);
      RXNOTINTABLE                : std_logic_vector( 3 downto  0);
      RXRUNDISP                   : std_logic_vector( 3 downto  0);
      -- RX elastic buffer
--      RXBUFSTATUS                 : std_logic_vector( 2 downto  0);
--      RXSTATUS                    : std_logic_vector( 2 downto  0);
      -- RX clock correction
--      RXCLKCORCNT                 : std_logic_vector( 2 downto  0);
      -- RX channel bonding
--      RXCHANBONDSEQ               : std_ulogic;
--      RXCHANISALIGNED             : std_ulogic;
--      RXCHANREALIGN               : std_ulogic;
--      RXCHBONDO                   : std_logic_vector( 3 downto  0);
      -- RX 64b66b and 64b67b gearbox
--      RXDATAVALID                 : std_ulogic;
--      RXHEADER                    : std_logic_vector( 2 downto  0);
--      RXHEADERVALID               : std_ulogic;
--      RXSTARTOFSEQ                : std_ulogic;
      -- RX data ports
      RXDATA                      : std_logic_vector(31 downto  0);
   end record mgt_rx_out_type;

   type mgt_rx_out_array_type is array (0 to 1) of mgt_rx_out_type;

   type mgt_tx_in_type is record
      -- TX resets
      TXRESET                     : std_ulogic;
      -- TX power control
--      TXPOWERDOWN                 : std_logic_vector( 1 downto  0);
      -- TX user clocks
      TXUSRCLK                    : std_ulogic;
      TXUSRCLK2                   : std_ulogic;
      -- TX data ports
--      TXDATAWIDTH                 : std_logic_vector( 1 downto  0);
      TXDATA                      : std_logic_vector(31 downto  0);
      -- TX 8b10b encoder
      TXBYPASS8B10B               : std_logic_vector( 3 downto  0);
      TXCHARDISPMODE              : std_logic_vector( 3 downto  0);
      TXCHARDISPVAL               : std_logic_vector( 3 downto  0);
      TXCHARISK                   : std_logic_vector( 3 downto  0);
--      TXENC8B10BUSE               : std_ulogic;
      -- TX 64b66b and 64b67b gearbox
--      TXHEADER                    : std_logic_vector( 2 downto  0);
--      TXSEQUENCE                  : std_logic_vector( 6 downto  0);
--      TXSTARTSEQ                  : std_ulogic;
      -- TX Pseudo Random Bit Sequences (PRBS)
--      TXENPRBSTST                 : std_logic_vector( 1 downto  0);
      -- TX phase alignment fifo
--      TXENPMAPHASEALIGN           : std_ulogic;
--      TXPMASETPHASE               : std_ulogic;
      -- TX polarity
--      TXPOLARITY                  : std_ulogic;
      -- TX Out Of Band (OOB) beaconing
--      TXELECIDLE                  : std_ulogic;
      -- TX PCIexpress
--      TXDETECTRX                  : std_ulogic;
      -- TX SATA
--      TXCOMSTART                  : std_ulogic;
--      TXCOMTYPE                   : std_ulogic;
      -- TX driver
--      TXBUFDIFFCTRL               : std_logic_vector( 2 downto  0);
      TXDIFFCTRL                  : std_logic_vector( 2 downto  0);
      TXPREEMPHASIS               : std_logic_vector( 3 downto  0);
 --     TXINHIBIT                   : std_ulogic;
   end record mgt_tx_in_type;

   type mgt_tx_in_array_type is array (0 to 1) of mgt_tx_in_type;

   type mgt_tx_out_type is record
      -- TX user clocks
      TXOUTCLK                    : std_ulogic;
      -- TX 8b10b encoder
      TXKERR                      : std_logic_vector( 3 downto  0);
      TXRUNDISP                   : std_logic_vector( 3 downto  0);
      -- TX 64b66b and 64b67b gearbox
--      TXGEARBOXREADY              : std_ulogic;
      -- TX elastic buffer
--      TXBUFSTATUS                 : std_logic_vector( 1 downto  0);
      -- TX serial ports
      TXP                         : std_ulogic;
      TXN                         : std_ulogic;
   end record mgt_tx_out_type;

   type mgt_tx_out_array_type is array (0 to 1) of mgt_tx_out_type;

   type mgt_in_type is record
      ctrl                        : mgt_ctrl_in_type;
      drp                         : mgt_drp_in_type;
      rx                          : mgt_rx_in_array_type;
      tx                          : mgt_tx_in_array_type;
   end record mgt_in_type;

   type mgt_out_type is record
      ctrl                        : mgt_ctrl_out_type;
      drp                         : mgt_drp_out_type;
      rx                          : mgt_rx_out_array_type;
      tx                          : mgt_tx_out_array_type;
   end record mgt_out_type;

   ---------------------------------------------------------------------------
   -- Module mgt_virtex5_gtx
   ---------------------------------------------------------------------------
  component mgt_virtex5_gtx
    generic (
      -- Simulation attributes
      SIM_MODE                        : string      := "FAST";   -- Set to Fast Functional Simulation Model
      SIM_GTXRESET_SPEEDUP            : integer     := 0;        -- Set to 1 to speed up sim reset
      SIM_PLL_PERDIV2                 : bit_vector  := X"0FA";   -- Set to the VCO Unit Interval time 
      --PLL settings
      G_GTX_TILE_REFCLK_FREQ          : integer     := 125;      -- GTX_REFCLK (125, 150)
      -- GTX Baud Rate for GTX_REFCLK=125 (7812500, 937500, 1250000, 1562500, 1875000, 2500000, 3125000, 3750000, 5000000)   
      -- GTX Baud Rate for GTX_REFCLK=150 (750000, 937500, 1125000, 1500000, 1875000, 2250000, 3000000, 3750000, 4500000)
      G_GTX_BAUD_RATE                 : integer     := 2500000   
    );
    port(
      i_mgt                       : in    mgt_in_type;
      o_mgt                       : out   mgt_out_type
    );
   end component;

   -- ---------------------------------------------------------------------------
   -- -- Module mgt_32bit_align
   -- ---------------------------------------------------------------------------
   -- component mgt_32bit_align
   -- port
   -- (
      -- i_clk                       : in    std_logic;
      -- i_RXCHARISCOMMA             : in    std_logic_vector( 3 downto  0);
      -- i_RXCHARISK                 : in    std_logic_vector( 3 downto  0);
      -- i_RXDATA                    : in    std_logic_vector(31 downto  0);
      -- o_RXCHARISCOMMA             : out   std_logic_vector( 3 downto  0);
      -- o_RXCHARISK                 : out   std_logic_vector( 3 downto  0);
      -- o_RXDATA                    : out   std_logic_vector(31 downto  0)
   -- );
   -- end component;

   ---------------------------------------------------------------------------
   -- Module mgt_32bit_fifo
   ---------------------------------------------------------------------------
   component mgt_32bit_fifo
   port
   (
      -- CPU interface
      i_cpu_rst                   : in    std_logic;
      i_cpu_clk                   : in    std_logic;

      i_cpu_tx_en                 : in    std_logic;
      o_cpu_tx_full               : out   std_logic;
      i_cpu_tx_charisk            : in    std_logic_vector( 3 downto  0);
      i_cpu_tx_data               : in    std_logic_vector(31 downto  0);

      o_cpu_rx_empty              : out   std_logic;
      o_cpu_rx_almost_empty       : out   std_logic;
      i_cpu_rx_en                 : in    std_logic;
      o_cpu_rx_charisk            : out   std_logic_vector( 3 downto  0);
      o_cpu_rx_data               : out   std_logic_vector(31 downto  0);
      -- MGT interface
      i_mgt_tx_clk                : in    std_logic;
      o_mgt_tx_charisk            : out   std_logic_vector( 3 downto  0);
      o_mgt_tx_data               : out   std_logic_vector(31 downto  0);

      i_mgt_rx_rst                : in    std_logic;
      i_mgt_rx_clk                : in    std_logic;
      i_mgt_rx_lossofsync         : in    std_logic;
      i_mgt_rx_chariscomma        : in    std_logic_vector( 3 downto  0);
      i_mgt_rx_charisk            : in    std_logic_vector( 3 downto  0);
      i_mgt_rxdata                : in    std_logic_vector(31 downto  0);
      -- Test interfaec
      o_tx_vld								    : out   std_logic;
      o_rx_vld								    : out   std_logic      
   );
   end component;

    --ML84 added
    component gtx_tile is
    generic(
        G_GTX_REFCLK_SEL       : std_logic;
        G_GTX_TILE_REFCLK_FREQ : integer := 125; --MHz 
        G_GTX_BAUD_RATE        : integer := 2500000 --Kbps
    );
    port (
        ------------------------------------------------------------------------
        -- GTX SETTINGS & STATUS
        ------------------------------------------------------------------------
        i_loopback0 : in  std_logic_vector(2 downto 0);
        i_loopback1 : in  std_logic_vector(2 downto 0);
        o_mgt       : out mgt_out_type;
        o_mgt_in    : out mgt_in_type;
        ------------------------------------------------------------------------
        -- GTX INTERFACE
        ------------------------------------------------------------------------
        I_GTX_REFCLK1_IN            : in  std_logic;
        I_GTX_REFCLK2_IN            : in  std_logic;
        O_GTX_REFCLK_OUT            : out std_logic;
        I_GTX_RX_N                  : in  std_logic_vector(1 downto 0);
        I_GTX_RX_P                  : in  std_logic_vector(1 downto 0);
        O_GTX_TX_N                  : out std_logic_vector(1 downto 0);
        O_GTX_TX_P                  : out std_logic_vector(1 downto 0);
        ------------------------------------------------------------------------
        -- FIFO interface
        ------------------------------------------------------------------------
        i_clk             : in  std_logic;
        --Channel 0
        i_fifo_reset0     : in  std_logic;
        --TX
        o_tx_vld0         : out std_logic;
        o_txfifo_full0    : out std_logic;
        i_txfifo_write0   : in  std_logic;
        i_txfifo_charisk0 : in  std_logic_vector(3 downto 0);
        i_txfifo_data0    : in  std_logic_vector(31 downto 0);
        --RX
        o_rx_sync_done0   : out std_logic;
        o_rx_vld0         : out std_logic;
        i_rxfifo_next0    : in  std_logic;
        o_rxfifo_empty0   : out std_logic;
        o_rxfifo_charisk0 : out std_logic_vector(3 downto 0);
        o_rxfifo_data0    : out std_logic_vector(31 downto 0);
        --Channel 1
        i_fifo_reset1     : in  std_logic;
        --TX
        o_tx_vld1         : out std_logic;
        o_txfifo_full1    : out std_logic;
        i_txfifo_write1   : in  std_logic;
        i_txfifo_charisk1 : in  std_logic_vector(3 downto 0);
        i_txfifo_data1    : in  std_logic_vector(31 downto 0);
        --RX
        o_rx_sync_done1   : out std_logic;
        o_rx_vld1         : out std_logic;
        i_rxfifo_next1    : in  std_logic;
        o_rxfifo_empty1   : out std_logic;
        o_rxfifo_charisk1 : out std_logic_vector(3 downto 0);
        o_rxfifo_data1    : out std_logic_vector(31 downto 0)
    );
    end component gtx_tile;

end package virtex5_gtx_package;

------------------------------------------------------------------------------
-- End of package
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Module gtx_tile       
------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.virtex5_gtx_package.all;

--ML84 added
entity gtx_tile is
generic(
    G_GTX_REFCLK_SEL       : std_logic;
    G_GTX_TILE_REFCLK_FREQ : integer := 125; --MHz 
    G_GTX_BAUD_RATE        : integer := 2500000 --Kbps
);
port (
    ------------------------------------------------------------------------
    -- GTX SETTINGS & STATUS
    ------------------------------------------------------------------------
    i_loopback0 : in  std_logic_vector(2 downto 0);
    i_loopback1 : in  std_logic_vector(2 downto 0);
    o_mgt       : out mgt_out_type;
    o_mgt_in    : out mgt_in_type;
    ------------------------------------------------------------------------
    -- GTX INTERFACE
    ------------------------------------------------------------------------
    I_GTX_REFCLK1_IN            : in  std_logic;
    I_GTX_REFCLK2_IN            : in  std_logic;
    O_GTX_REFCLK_OUT            : out std_logic;
    I_GTX_RX_N                  : in  std_logic_vector(1 downto 0);
    I_GTX_RX_P                  : in  std_logic_vector(1 downto 0);
    O_GTX_TX_N                  : out std_logic_vector(1 downto 0);
    O_GTX_TX_P                  : out std_logic_vector(1 downto 0);
    ------------------------------------------------------------------------
    -- FIFO interface
    ------------------------------------------------------------------------
    i_clk             : in  std_logic;
    --Channel 0
    i_fifo_reset0     : in  std_logic;
    --TX
    o_tx_vld0         : out std_logic;
    o_txfifo_full0    : out std_logic;
    i_txfifo_write0   : in  std_logic;
    i_txfifo_charisk0 : in  std_logic_vector(3 downto 0);
    i_txfifo_data0    : in  std_logic_vector(31 downto 0);
    --RX
    o_rx_sync_done0   : out std_logic;
    o_rx_vld0         : out std_logic;
    i_rxfifo_next0    : in  std_logic;
    o_rxfifo_empty0   : out std_logic;
    o_rxfifo_charisk0 : out std_logic_vector(3 downto 0);
    o_rxfifo_data0    : out std_logic_vector(31 downto 0);
    --Channel 1
    i_fifo_reset1     : in  std_logic;
    --TX
    o_rx_sync_done1   : out std_logic;
    o_tx_vld1         : out std_logic;
    o_txfifo_full1    : out std_logic;
    i_txfifo_write1   : in  std_logic;
    i_txfifo_charisk1 : in  std_logic_vector(3 downto 0);
    i_txfifo_data1    : in  std_logic_vector(31 downto 0);
    --RX
    o_rx_vld1         : out std_logic;
    i_rxfifo_next1    : in  std_logic;
    o_rxfifo_empty1   : out std_logic;
    o_rxfifo_charisk1 : out std_logic_vector(3 downto 0);
    o_rxfifo_data1    : out std_logic_vector(31 downto 0)
);
end entity gtx_tile;

architecture struct of gtx_tile is

    component RX_SYNC is
    port(
        RXENPMAPHASEALIGN   :   out   std_logic;              
        RXPMASETPHASE       :   out   std_logic;              
        SYNC_DONE           :   out   std_logic;              
        USER_CLK            :   in    std_logic;               
        RESET               :   in    std_logic           
    );
    end component RX_SYNC;

    signal mgt_rstdone0_n, mgt_rstdone1_n : std_logic;

    signal mgt_in  : mgt_in_type;
    signal mgt_out : mgt_out_type;
    
begin

--clock connection ------------------------------------------------------------------------------------
mgt_in.ctrl.CLKIN <= I_GTX_REFCLK1_IN when G_GTX_REFCLK_SEL = '0' else I_GTX_REFCLK2_IN;

--tile instantiation ------------------------------------------------------------------------------------
mgt_virtex5_gtx_inst: mgt_virtex5_gtx
generic map(
    SIM_MODE                  => "FAST",
    SIM_GTXRESET_SPEEDUP      => 0,
    SIM_PLL_PERDIV2           => X"0FA",
    G_GTX_TILE_REFCLK_FREQ    => G_GTX_TILE_REFCLK_FREQ,
    G_GTX_BAUD_RATE           => G_GTX_BAUD_RATE
)
port map(
    i_mgt                     => mgt_in,
    o_mgt                     => mgt_out
);

--RX0 PHASE ALIGNMENT
mgt_rstdone0_n <= not mgt_out.ctrl.RESETDONE0;
--
inst_rx0_sync : RX_SYNC
port map(
    RXENPMAPHASEALIGN   => mgt_in.rx(0).RXENPMAPHASEALIGN,
    RXPMASETPHASE       => mgt_in.rx(0).RXPMASETPHASE,
    SYNC_DONE           => o_rx_sync_done0,
    USER_CLK            => mgt_out.rx(0).RXRECCLK,
    RESET               => mgt_rstdone0_n
);

--RX1 PHASE ALIGNMENT
mgt_rstdone1_n <= not mgt_out.ctrl.RESETDONE1;
--
inst_rx1_sync : RX_SYNC
port map(
    RXENPMAPHASEALIGN   => mgt_in.rx(1).RXENPMAPHASEALIGN,
    RXPMASETPHASE       => mgt_in.rx(1).RXPMASETPHASE,
    SYNC_DONE           => o_rx_sync_done1,
    USER_CLK            => mgt_out.rx(1).RXRECCLK,
    RESET               => mgt_rstdone1_n
);

----TILE IOs ----------------------------------------------------------------------------------
-- GTX0 serial interface
mgt_in.rx(0).RXP         <= I_GTX_RX_P(0);
mgt_in.rx(0).RXN         <= I_GTX_RX_N(0);
O_GTX_TX_P(0)            <= mgt_out.tx(0).TXP;
O_GTX_TX_N(0)            <= mgt_out.tx(0).TXN;
-- GTX1 serial interface  
mgt_in.rx(1).RXP         <= I_GTX_RX_P(1);
mgt_in.rx(1).RXN         <= I_GTX_RX_N(1);
O_GTX_TX_P(1)            <= mgt_out.tx(1).TXP;
O_GTX_TX_N(1)            <= mgt_out.tx(1).TXN;
-- GTX TILE
mgt_in.ctrl.GTXRESET     <= '0';
mgt_in.ctrl.REFCLKPWRDNB <= '1';

---- PLB interface ----------------------------------------------------------------------------
-- GTX CONTROL
mgt_in.ctrl.LOOPBACK0    <= i_loopback0;
mgt_in.ctrl.LOOPBACK1    <= i_loopback1;
--GTX STATUS 
o_mgt                    <= mgt_out;
o_mgt_in                 <= mgt_in; 
              
----FIFO (CHANNEL 0) ---------------------------------------------------------------------------------
inst_gtx0_fifo: mgt_32bit_fifo 
port map (
    -- USER interface
    i_cpu_rst                   => i_fifo_reset0,
    i_cpu_clk                   => i_clk,
    --TX                    
    i_cpu_tx_en                 => i_txfifo_write0,  
    o_cpu_tx_full               => o_txfifo_full0,   
    i_cpu_tx_charisk            => i_txfifo_charisk0,
    i_cpu_tx_data               => i_txfifo_data0,  
    --RX                      
    o_cpu_rx_empty              => o_rxfifo_empty0,
    o_cpu_rx_almost_empty       => open,
    i_cpu_rx_en                 => i_rxfifo_next0,
    o_cpu_rx_charisk            => o_rxfifo_charisk0,
    o_cpu_rx_data               => o_rxfifo_data0,
    -- MGT interface   
    i_mgt_tx_clk                => mgt_out.tx(0).TXOUTCLK,
    o_mgt_tx_charisk            => mgt_in.tx(0).TXCHARISK,
    o_mgt_tx_data               => mgt_in.tx(0).TXDATA,
                              
    i_mgt_rx_rst                => i_fifo_reset0,
    i_mgt_rx_clk                => mgt_out.rx(0).RXRECCLK,
    i_mgt_rx_lossofsync         => mgt_out.rx(0).RXLOSSOFSYNC( 1),
    i_mgt_rx_chariscomma        => mgt_out.rx(0).RXCHARISCOMMA,
    i_mgt_rx_charisk            => mgt_out.rx(0).RXCHARISK,
    i_mgt_rxdata                => mgt_out.rx(0).RXDATA,
    o_tx_vld                    => o_tx_vld0,
    o_rx_vld                    => o_rx_vld0
);         

-- GTX0 RX
mgt_in.rx(0).RXRESET           <= '0';
mgt_in.rx(0).RXUSRCLK          <= mgt_out.rx(0).RXRECCLK;
mgt_in.rx(0).RXUSRCLK2         <= mgt_out.rx(0).RXRECCLK;
mgt_in.rx(0).RXENMCOMMAALIGN   <= '1';
mgt_in.rx(0).RXENPCOMMAALIGN   <= '1';      
-- GTX0 TX
mgt_in.tx(0).TXRESET           <= '0';
mgt_in.tx(0).TXUSRCLK          <= mgt_out.tx(0).TXOUTCLK;
mgt_in.tx(0).TXUSRCLK2         <= mgt_out.tx(0).TXOUTCLK;
mgt_in.tx(0).TXBYPASS8B10B     <= "0000";
mgt_in.tx(0).TXCHARDISPMODE    <= "0000";
mgt_in.tx(0).TXCHARDISPVAL     <= "0000";
mgt_in.tx(0).TXDIFFCTRL        <= "000";
mgt_in.tx(0).TXPREEMPHASIS     <= "0000";

----FIFO (CHANNEL 1) ---------------------------------------------------------------------------------
inst_gtx1_fifo: mgt_32bit_fifo 
port map (
    -- USER interface
    i_cpu_rst                   => i_fifo_reset1,
    i_cpu_clk                   => i_clk,
    --TX                        
    i_cpu_tx_en                 => i_txfifo_write1,
    o_cpu_tx_full               => o_txfifo_full1,
    i_cpu_tx_charisk            => i_txfifo_charisk1,
    i_cpu_tx_data               => i_txfifo_data1,
    --RX                                  
    o_cpu_rx_empty              => o_rxfifo_empty1,
    o_cpu_rx_almost_empty       => open,
    i_cpu_rx_en                 => i_rxfifo_next1,
    o_cpu_rx_charisk            => o_rxfifo_charisk1,
    o_cpu_rx_data               => o_rxfifo_data1,
    -- MGT interface   
    i_mgt_tx_clk                => mgt_out.tx(1).TXOUTCLK,
    o_mgt_tx_charisk            => mgt_in.tx(1).TXCHARISK,
    o_mgt_tx_data               => mgt_in.tx(1).TXDATA,
                                      
    i_mgt_rx_rst                => i_fifo_reset1,
    i_mgt_rx_clk                => mgt_out.rx(1).RXRECCLK,
    i_mgt_rx_lossofsync         => mgt_out.rx(1).RXLOSSOFSYNC( 1),
    i_mgt_rx_chariscomma        => mgt_out.rx(1).RXCHARISCOMMA,
    i_mgt_rx_charisk            => mgt_out.rx(1).RXCHARISK,
    i_mgt_rxdata                => mgt_out.rx(1).RXDATA,
    o_tx_vld                    => o_tx_vld1,
    o_rx_vld                    => o_rx_vld1
);         

-- GTX1 RX
mgt_in.rx(1).RXRESET           <= '0';
mgt_in.rx(1).RXUSRCLK          <= mgt_out.rx(1).RXRECCLK;
mgt_in.rx(1).RXUSRCLK2         <= mgt_out.rx(1).RXRECCLK;
mgt_in.rx(1).RXENMCOMMAALIGN   <= '1';
mgt_in.rx(1).RXENPCOMMAALIGN   <= '1';      
-- GTX1 TX
mgt_in.tx(1).TXRESET           <= '0';
mgt_in.tx(1).TXUSRCLK          <= mgt_out.tx(1).TXOUTCLK;
mgt_in.tx(1).TXUSRCLK2         <= mgt_out.tx(1).TXOUTCLK;
mgt_in.tx(1).TXBYPASS8B10B     <= "0000";
mgt_in.tx(1).TXCHARDISPMODE    <= "0000";
mgt_in.tx(1).TXCHARDISPVAL     <= "0000";
mgt_in.tx(1).TXDIFFCTRL        <= "000";
mgt_in.tx(1).TXPREEMPHASIS     <= "0000";
        
-- DRP
mgt_in.drp.DCLK                <= '0';
mgt_in.drp.DEN                 <= '0';
mgt_in.drp.DWE                 <= '0';
mgt_in.drp.DADDR               <= (others => '0');
mgt_in.drp.DI                  <= (others => '0');
          
end architecture struct;

------------------------------------------------------------------------------
-- Module mgt_virtex5_gtx
------------------------------------------------------------------------------
-- Std. library (platform) ---------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-- synopsys translate_off
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
-- synopsys translate_on

use work.virtex5_gtx_package.all;

entity mgt_virtex5_gtx is
  generic (
    -- Simulation attributes
    SIM_MODE                        : string      := "FAST";   -- Set to Fast Functional Simulation Model
    SIM_GTXRESET_SPEEDUP            : integer     := 0;        -- Set to 1 to speed up sim reset
    SIM_PLL_PERDIV2                 : bit_vector  := X"0FA";   -- Set to the VCO Unit Interval time 
    --PLL settings
    G_GTX_TILE_REFCLK_FREQ          : integer     := 125;      -- GTX_REFCLK (125, 150)
    -- GTX Baud Rate for GTX_REFCLK=125 (7812500, 937500, 1250000, 1562500, 1875000, 2500000, 3125000, 3750000, 5000000)   
    -- GTX Baud Rate for GTX_REFCLK=150 (750000, 937500, 1125000, 1500000, 1875000, 2250000, 3000000, 3750000, 4500000)
    G_GTX_BAUD_RATE                 : integer     := 2500000   
  );
  port (
    i_mgt                          : in    mgt_in_type;
    o_mgt                          : out   mgt_out_type
  );
end mgt_virtex5_gtx;

architecture structural of mgt_virtex5_gtx is

   ---------------------------------------------------------------------------
   -- Constant
   ---------------------------------------------------------------------------
   constant HIGH                  : std_logic := '1';
   constant LOW                   : std_logic := '0';
   constant LOW8                  : std_logic_vector( 7 downto  0) := (others => '0');
   ---------------------------------------------------------------------------
   -- Signals
   ---------------------------------------------------------------------------
   ---------------------------------------------------------------------------
   -- Attributes
   ---------------------------------------------------------------------------
   attribute BOX_TYPE             : string;
   ---------------------------------------------------------------------------
   -- Component
   ---------------------------------------------------------------------------
   component GTX_DUAL
   generic
   (
      ------------------------------------------------------------------------
      -- Simulation
      ------------------------------------------------------------------------
      SIM_RECEIVER_DETECT_PASS_0  : boolean := TRUE;
      SIM_RECEIVER_DETECT_PASS_1  : boolean := TRUE;
      SIM_MODE                    : string := "FAST";
      SIM_GTXRESET_SPEEDUP        : integer := 1;
      SIM_PLL_PERDIV2             : bit_vector := X"140";
      ------------------------------------------------------------------------
      -- CTRL
      ------------------------------------------------------------------------
      -- PLL
      OVERSAMPLE_MODE             : boolean := FALSE;
      PLL_DIVSEL_FB               : integer := 2;
      PLL_DIVSEL_REF              : integer := 1;

      PLL_COM_CFG                 : bit_vector := X"21680a";
      PLL_CP_CFG                  : bit_vector := X"00";
      PLL_FB_DCCEN                : boolean := FALSE;
      PLL_LKDET_CFG               : bit_vector := "101";
      PLL_TDCC_CFG                : bit_vector := "000";
      PMA_COM_CFG                 : bit_vector := X"000000000000000000";

      PLL_SATA_0                  : boolean := FALSE;
      PLL_SATA_1                  : boolean := FALSE;
      -- Shared clocking
      CLK25_DIVIDER               : integer := 10;
      CLKINDC_B                   : boolean := TRUE;
      CLKRCV_TRST                 : boolean := TRUE;
      -- Termination
      TERMINATION_CTRL            : bit_vector := "10100";
      TERMINATION_OVRD            : boolean := FALSE;
      -- RX Decision Feedback Equalizer(DFE)
      DFE_CAL_TIME                : bit_vector := "00110";
      -- RX Out Of Band (OOB)
      OOB_CLK_DIVIDER             : integer := 6;
      -- RX Clock Data Recovery (CDR)
      CDR_PH_ADJ_TIME             : bit_vector := "01010";
      RX_EN_IDLE_RESET_FR         : boolean := TRUE;
      RX_EN_IDLE_HOLD_CDR         : boolean := FALSE;
      RX_EN_IDLE_RESET_PH         : boolean := TRUE;
      ------------------------------------------------------------------------
      -- RX 0
      ------------------------------------------------------------------------
      -- RX serial ports
      AC_CAP_DIS_0                : boolean := TRUE;
      CM_TRIM_0                   : bit_vector := "10";
      RCV_TERM_GND_0              : boolean := FALSE;
      RCV_TERM_VTTRX_0            : boolean := FALSE;
      TERMINATION_IMP_0           : integer := 50;
      -- RX Decision Feedback Equalizer(DFE)
      DFE_CFG_0                   : bit_vector := "1101111011";
      RX_EN_IDLE_HOLD_DFE_0       : boolean := TRUE;
      -- RX Out Of Band (OOB)
      OOBDETECT_THRESHOLD_0       : bit_vector := "110";
      RX_STATUS_FMT_0             : string := "PCIE";
      -- RX PCIexpress
      RX_IDLE_HI_CNT_0            : bit_vector := "1000";
      RX_IDLE_LO_CNT_0            : bit_vector := "0000";
      -- RX SATA
      SATA_BURST_VAL_0            : bit_vector := "100";
      SATA_IDLE_VAL_0             : bit_vector := "100";
      SATA_MAX_BURST_0            : integer := 7;
      SATA_MAX_INIT_0             : integer := 22;
      SATA_MAX_WAKE_0             : integer := 7;
      SATA_MIN_BURST_0            : integer := 4;
      SATA_MIN_INIT_0             : integer := 12;
      SATA_MIN_WAKE_0             : integer := 4;
      TRANS_TIME_FROM_P2_0        : bit_vector := X"03c";
      TRANS_TIME_NON_P2_0         : bit_vector := X"19";
      TRANS_TIME_TO_P2_0          : bit_vector := X"064";
      -- RX Clock Data Recovery (CDR)
      PMA_CDR_SCAN_0              : bit_vector := X"6404035";
      PMA_RX_CFG_0                : bit_vector := X"0f44089";
      -- RX serial line rate clocks
      PLL_RXDIVSEL_OUT_0          : integer := 1;
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBS_ERR_THRESHOLD_0        : bit_vector := X"00000001";
      -- RX comma detection and alignment
      ALIGN_COMMA_WORD_0          : integer := 1;
      COMMA_10B_ENABLE_0          : bit_vector := "0001111111";
      COMMA_DOUBLE_0              : boolean := FALSE;
      MCOMMA_10B_VALUE_0          : bit_vector := "1010000011";
      MCOMMA_DETECT_0             : boolean := TRUE;
      PCOMMA_10B_VALUE_0          : bit_vector := "0101111100";
      PCOMMA_DETECT_0             : boolean := TRUE;
      RX_SLIDE_MODE_0             : string := "PCS";
      -- RX loss of sync fsm
      RX_LOS_INVALID_INCR_0       : integer := 1;
      RX_LOS_THRESHOLD_0          : integer := 4;
      RX_LOSS_OF_SYNC_FSM_0       : boolean := FALSE;
      -- RX 8b10b decoder
      DEC_MCOMMA_DETECT_0         : boolean := TRUE;
      DEC_PCOMMA_DETECT_0         : boolean := TRUE;
      DEC_VALID_COMMA_ONLY_0      : boolean := TRUE;
      -- RX elastic buffer
      PMA_RXSYNC_CFG_0            : bit_vector := X"00";
      RX_BUFFER_USE_0             : boolean := FALSE;
      RX_EN_IDLE_RESET_BUF_0      : boolean := TRUE;
      RX_XCLK_SEL_0               : string := "RXUSR";
      -- RX clock correction
      CLK_CORRECT_USE_0           : boolean := TRUE;
      CLK_COR_ADJ_LEN_0           : integer := 1;
      CLK_COR_DET_LEN_0           : integer := 1;
      CLK_COR_INSERT_IDLE_FLAG_0  : boolean := FALSE;
      CLK_COR_KEEP_IDLE_0         : boolean := FALSE;
      CLK_COR_MAX_LAT_0           : integer := 20;
      CLK_COR_MIN_LAT_0           : integer := 18;
      CLK_COR_PRECEDENCE_0        : boolean := TRUE;
      CLK_COR_REPEAT_WAIT_0       : integer := 0;
      CLK_COR_SEQ_1_1_0           : bit_vector := "0100011100";
      CLK_COR_SEQ_1_2_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_1_3_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_1_4_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_1_ENABLE_0      : bit_vector := "0001";
      CLK_COR_SEQ_2_1_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_2_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_3_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_4_0           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_ENABLE_0      : bit_vector := "0000";
      CLK_COR_SEQ_2_USE_0         : boolean := FALSE;
      RX_DECODE_SEQ_MATCH_0       : boolean := TRUE;
      -- RX channel bonding
      CB2_INH_CC_PERIOD_0         : integer := 8;
      CHAN_BOND_1_MAX_SKEW_0      : integer := 7;
      CHAN_BOND_2_MAX_SKEW_0      : integer := 7;
      CHAN_BOND_KEEP_ALIGN_0      : boolean := FALSE;
      CHAN_BOND_LEVEL_0           : integer := 0;
      CHAN_BOND_MODE_0            : string := "OFF";
      CHAN_BOND_SEQ_1_1_0         : bit_vector := "0101111100";
      CHAN_BOND_SEQ_1_2_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_1_3_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_1_4_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_1_ENABLE_0    : bit_vector := "0001";
      CHAN_BOND_SEQ_2_1_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_2_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_3_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_4_0         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_ENABLE_0    : bit_vector := "0000";
      CHAN_BOND_SEQ_2_USE_0       : boolean := FALSE;
      CHAN_BOND_SEQ_LEN_0         : integer := 1;
      PCI_EXPRESS_MODE_0          : boolean := FALSE;
      -- RX 64b66b and 64b67b gearbox
      RXGEARBOX_USE_0             : boolean := FALSE;
      ------------------------------------------------------------------------
      -- TX 0
      ------------------------------------------------------------------------
      -- TX 64b66b and 64b67b gearbox
      GEARBOX_ENDEC_0             : bit_vector := "000";
      TXGEARBOX_USE_0             : boolean := FALSE;
      -- TX serial line rate clocks
      PLL_TXDIVSEL_OUT_0          : integer := 1;
      -- TX elastic buffer
      TX_BUFFER_USE_0             : boolean := TRUE;
      TX_XCLK_SEL_0               : string := "TXOUT";
      TXRX_INVERT_0               : bit_vector := "011";
      -- TX Out Of Band (OOB) beaconing
      COM_BURST_VAL_0             : bit_vector := "1111";
      PMA_TX_CFG_0                : bit_vector := X"80082";
      TX_DETECT_RX_CFG_0          : bit_vector := X"1832";
      TX_IDLE_DELAY_0             : bit_vector := "010";
      ------------------------------------------------------------------------
      -- RX 1
      ------------------------------------------------------------------------
      -- RX serial ports
      AC_CAP_DIS_1                : boolean := TRUE;
      CM_TRIM_1                   : bit_vector := "10";
      RCV_TERM_GND_1              : boolean := FALSE;
      RCV_TERM_VTTRX_1            : boolean := FALSE;
      TERMINATION_IMP_1           : integer := 50;
      -- RX Decision Feedback Equalizer(DFE)
      DFE_CFG_1                   : bit_vector := "1101111011";
      RX_EN_IDLE_HOLD_DFE_1       : boolean := TRUE;
      -- RX Out Of Band (OOB)
      OOBDETECT_THRESHOLD_1       : bit_vector := "110";
      RX_STATUS_FMT_1             : string := "PCIE";
      -- RX PCIexpress
      RX_IDLE_HI_CNT_1            : bit_vector := "1000";
      RX_IDLE_LO_CNT_1            : bit_vector := "0000";
      -- RX SATA
      SATA_BURST_VAL_1            : bit_vector := "100";
      SATA_IDLE_VAL_1             : bit_vector := "100";
      SATA_MAX_BURST_1            : integer := 7;
      SATA_MAX_INIT_1             : integer := 22;
      SATA_MAX_WAKE_1             : integer := 7;
      SATA_MIN_BURST_1            : integer := 4;
      SATA_MIN_INIT_1             : integer := 12;
      SATA_MIN_WAKE_1             : integer := 4;
      TRANS_TIME_FROM_P2_1        : bit_vector := X"03c";
      TRANS_TIME_NON_P2_1         : bit_vector := X"19";
      TRANS_TIME_TO_P2_1          : bit_vector := X"064";
      -- RX Clock Data Recovery (CDR)
      PMA_CDR_SCAN_1              : bit_vector := X"6404035";
      PMA_RX_CFG_1                : bit_vector := X"0f44089";
      -- RX serial line rate clocks
      PLL_RXDIVSEL_OUT_1          : integer := 1;
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBS_ERR_THRESHOLD_1        : bit_vector := X"00000001";
      -- RX comma detection and alignment
      ALIGN_COMMA_WORD_1          : integer := 1;
      COMMA_10B_ENABLE_1          : bit_vector := "0001111111";
      COMMA_DOUBLE_1              : boolean := FALSE;
      MCOMMA_10B_VALUE_1          : bit_vector := "1010000011";
      MCOMMA_DETECT_1             : boolean := TRUE;
      PCOMMA_10B_VALUE_1          : bit_vector := "0101111100";
      PCOMMA_DETECT_1             : boolean := TRUE;
      RX_SLIDE_MODE_1             : string := "PCS";
      -- RX loss of sync fsm
      RX_LOS_INVALID_INCR_1       : integer := 1;
      RX_LOS_THRESHOLD_1          : integer := 4;
      RX_LOSS_OF_SYNC_FSM_1       : boolean := FALSE;
      -- RX 8b10b decoder
      DEC_MCOMMA_DETECT_1         : boolean := TRUE;
      DEC_PCOMMA_DETECT_1         : boolean := TRUE;
      DEC_VALID_COMMA_ONLY_1      : boolean := TRUE;
      -- RX elastic buffer
      PMA_RXSYNC_CFG_1            : bit_vector := X"00";
      RX_BUFFER_USE_1             : boolean := FALSE;
      RX_EN_IDLE_RESET_BUF_1      : boolean := TRUE;
      RX_XCLK_SEL_1               : string := "RXREC";
      -- RX clock correction
      CLK_CORRECT_USE_1           : boolean := TRUE;
      CLK_COR_ADJ_LEN_1           : integer := 1;
      CLK_COR_DET_LEN_1           : integer := 1;
      CLK_COR_INSERT_IDLE_FLAG_1  : boolean := FALSE;
      CLK_COR_KEEP_IDLE_1         : boolean := FALSE;
      CLK_COR_MAX_LAT_1           : integer := 20;
      CLK_COR_MIN_LAT_1           : integer := 18;
      CLK_COR_PRECEDENCE_1        : boolean := TRUE;
      CLK_COR_REPEAT_WAIT_1       : integer := 0;
      CLK_COR_SEQ_1_1_1           : bit_vector := "0100011100";
      CLK_COR_SEQ_1_2_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_1_3_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_1_4_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_1_ENABLE_1      : bit_vector := "0001";
      CLK_COR_SEQ_2_1_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_2_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_3_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_4_1           : bit_vector := "0000000000";
      CLK_COR_SEQ_2_ENABLE_1      : bit_vector := "0000";
      CLK_COR_SEQ_2_USE_1         : boolean := FALSE;
      RX_DECODE_SEQ_MATCH_1       : boolean := TRUE;
      -- RX channel bonding
      CB2_INH_CC_PERIOD_1         : integer := 8;
      CHAN_BOND_1_MAX_SKEW_1      : integer := 7;
      CHAN_BOND_2_MAX_SKEW_1      : integer := 7;
      CHAN_BOND_KEEP_ALIGN_1      : boolean := FALSE;
      CHAN_BOND_LEVEL_1           : integer := 0;
      CHAN_BOND_MODE_1            : string := "OFF";
      CHAN_BOND_SEQ_1_1_1         : bit_vector := "0101111100";
      CHAN_BOND_SEQ_1_2_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_1_3_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_1_4_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_1_ENABLE_1    : bit_vector := "0001";
      CHAN_BOND_SEQ_2_1_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_2_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_3_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_4_1         : bit_vector := "0000000000";
      CHAN_BOND_SEQ_2_ENABLE_1    : bit_vector := "0000";
      CHAN_BOND_SEQ_2_USE_1       : boolean := FALSE;
      CHAN_BOND_SEQ_LEN_1         : integer := 1;
      PCI_EXPRESS_MODE_1          : boolean := FALSE;
      -- RX 64b66b and 64b67b gearbox
      RXGEARBOX_USE_1             : boolean := FALSE;
      ------------------------------------------------------------------------
      -- TX 1
      ------------------------------------------------------------------------
      -- TX 64b66b and 64b67b gearbox
      GEARBOX_ENDEC_1             : bit_vector := "000";
      TXGEARBOX_USE_1             : boolean := FALSE;
      -- TX serial line rate clocks
      PLL_TXDIVSEL_OUT_1          : integer := 1;
      -- TX elastic buffer
      TX_BUFFER_USE_1             : boolean := TRUE;
      TX_XCLK_SEL_1               : string := "TXOUT";
      TXRX_INVERT_1               : bit_vector := "011";
      -- TX Out Of Band (OOB) beaconing
      COM_BURST_VAL_1             : bit_vector := "1111";
      PMA_TX_CFG_1                : bit_vector := X"80082";
      TX_DETECT_RX_CFG_1          : bit_vector := X"1832";
      TX_IDLE_DELAY_1             : bit_vector := "010"
   );
   port
   (
      ------------------------------------------------------------------------
      -- CTRL
      ------------------------------------------------------------------------
      -- Xilinx test ports
      GTXTEST                     : in    std_logic_vector(13 downto  0);
      -- Global ports
      GTXRESET                    : in    std_ulogic;
      RESETDONE0                  : out   std_ulogic;
      RESETDONE1                  : out   std_ulogic;
      INTDATAWIDTH                : in    std_ulogic;
      -- PLL
      CLKIN                       : in    std_ulogic;
      REFCLKPWRDNB                : in    std_ulogic;
      REFCLKOUT                   : out   std_ulogic;
      PLLLKDET                    : out   std_ulogic;
      PLLLKDETEN                  : in    std_ulogic;
      PLLPOWERDOWN                : in    std_ulogic;
      -- Loopback
      LOOPBACK0                   : in    std_logic_vector( 2 downto  0);
      LOOPBACK1                   : in    std_logic_vector( 2 downto  0);
      ------------------------------------------------------------------------
      -- DRP
      ------------------------------------------------------------------------
      -- Dynamic Reconfiguration Port (DRP)
      DCLK                        : in    std_ulogic;
      DEN                         : in    std_ulogic;
      DWE                         : in    std_ulogic;
      DADDR                       : in    std_logic_vector( 6 downto  0);
      DI                          : in    std_logic_vector(15 downto  0);
      DO                          : out   std_logic_vector(15 downto  0);
      DRDY                        : out   std_ulogic;
      ------------------------------------------------------------------------
      -- RX 0
      ------------------------------------------------------------------------
      -- RX resets
      RXRESET0                    : in    std_ulogic;
      -- RX power control
      RXPOWERDOWN0                : in    std_logic_vector( 1 downto  0);
      -- RX user clocks
      RXRECCLK0                   : out   std_ulogic;
      RXUSRCLK0                   : in    std_ulogic;
      RXUSRCLK20                  : in    std_ulogic;
      -- RX serial ports
      RXP0                        : in    std_ulogic;
      RXN0                        : in    std_ulogic;
      -- RX EQualizer (EQ)
      RXENEQB0                    : in    std_ulogic;
      RXEQMIX0                    : in    std_logic_vector( 1 downto  0);
      RXEQPOLE0                   : in    std_logic_vector( 3 downto  0);
      -- RX Decision Feedback Equalizer(DFE)
      DFECLKDLYADJ0               : in    std_logic_vector( 5 downto  0);
      DFECLKDLYADJMONITOR0        : out   std_logic_vector( 5 downto  0);
      DFEEYEDACMONITOR0           : out   std_logic_vector( 4 downto  0);
      DFESENSCAL0                 : out   std_logic_vector( 2 downto  0);
      DFETAP10                    : in    std_logic_vector( 4 downto  0);
      DFETAP1MONITOR0             : out   std_logic_vector( 4 downto  0);
      DFETAP20                    : in    std_logic_vector( 4 downto  0);
      DFETAP2MONITOR0             : out   std_logic_vector( 4 downto  0);
      DFETAP30                    : in    std_logic_vector( 3 downto  0);
      DFETAP3MONITOR0             : out   std_logic_vector( 3 downto  0);
      DFETAP40                    : in    std_logic_vector( 3 downto  0);
      DFETAP4MONITOR0             : out   std_logic_vector( 3 downto  0);
      -- RX Out Of Band (OOB)
      RXELECIDLE0                 : out   std_ulogic;
      RXVALID0                    : out   std_ulogic;
      PHYSTATUS0                  : out   std_ulogic;
      -- RX Clock Data Recovery (CDR)
      RXCDRRESET0                 : in    std_ulogic;
      -- RX oversampling
      RXENSAMPLEALIGN0            : in    std_ulogic;
      RXOVERSAMPLEERR0            : out   std_ulogic;
      -- RX polarity
      RXPOLARITY0                 : in    std_ulogic;
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBSCNTRESET0               : in    std_ulogic;
      RXENPRBSTST0                : in    std_logic_vector( 1 downto  0);
      RXPRBSERR0                  : out   std_ulogic;
      -- RX comma detection and alignment
      RXBYTEISALIGNED0            : out   std_ulogic;
      RXBYTEREALIGN0              : out   std_ulogic;
      RXCOMMADET0                 : out   std_ulogic;
      RXCOMMADETUSE0              : in    std_ulogic;
      RXENMCOMMAALIGN0            : in    std_ulogic;
      RXENPCOMMAALIGN0            : in    std_ulogic;
      RXSLIDE0                    : in    std_ulogic;
      -- RX loss of sync fsm
      RXLOSSOFSYNC0               : out   std_logic_vector( 1 downto  0);
      -- RX 8b10b decoder
      RXCHARISCOMMA0              : out   std_logic_vector( 3 downto  0);
      RXCHARISK0                  : out   std_logic_vector( 3 downto  0);
      RXDATAWIDTH0                : in    std_logic_vector( 1 downto  0);
      RXDEC8B10BUSE0              : in    std_ulogic;
      RXDISPERR0                  : out   std_logic_vector( 3 downto  0);
      RXNOTINTABLE0               : out   std_logic_vector( 3 downto  0);
      RXRUNDISP0                  : out   std_logic_vector( 3 downto  0);
      -- RX elastic buffer
      RXBUFRESET0                 : in    std_ulogic;
      RXBUFSTATUS0                : out   std_logic_vector( 2 downto  0);
      RXENPMAPHASEALIGN0          : in    std_ulogic;
      RXPMASETPHASE0              : in    std_ulogic;
      RXSTATUS0                   : out   std_logic_vector( 2 downto  0);
      -- RX clock correction
      RXCLKCORCNT0                : out   std_logic_vector( 2 downto  0);
      -- RX channel bonding
      RXCHANBONDSEQ0              : out   std_ulogic;
      RXCHANISALIGNED0            : out   std_ulogic;
      RXCHANREALIGN0              : out   std_ulogic;
      RXCHBONDI0                  : in    std_logic_vector( 3 downto  0);
      RXCHBONDO0                  : out   std_logic_vector( 3 downto  0);
      RXENCHANSYNC0               : in    std_ulogic;
      -- RX 64b66b and 64b67b gearbox
      RXDATAVALID0                : out   std_ulogic;
      RXGEARBOXSLIP0              : in    std_ulogic;
      RXHEADER0                   : out   std_logic_vector( 2 downto  0);
      RXHEADERVALID0              : out   std_ulogic;
      RXSTARTOFSEQ0               : out   std_ulogic;
      -- RX data ports
      RXDATA0                     : out   std_logic_vector(31 downto  0);
      ------------------------------------------------------------------------
      -- TX 0
      ------------------------------------------------------------------------
      -- TX resets
      TXRESET0                    : in    std_ulogic;
      -- TX power control
      TXPOWERDOWN0                : in    std_logic_vector( 1 downto  0);
      -- TX user clocks
      TXOUTCLK0                   : out   std_ulogic;
      TXUSRCLK0                   : in    std_ulogic;
      TXUSRCLK20                  : in    std_ulogic;
      -- TX data ports
      TXDATAWIDTH0                : in    std_logic_vector( 1 downto  0);
      TXDATA0                     : in    std_logic_vector(31 downto  0);
      -- TX 8b10b encoder
      TXBYPASS8B10B0              : in    std_logic_vector( 3 downto  0);
      TXCHARDISPMODE0             : in    std_logic_vector( 3 downto  0);
      TXCHARDISPVAL0              : in    std_logic_vector( 3 downto  0);
      TXCHARISK0                  : in    std_logic_vector( 3 downto  0);
      TXENC8B10BUSE0              : in    std_ulogic;
      TXKERR0                     : out   std_logic_vector( 3 downto  0);
      TXRUNDISP0                  : out   std_logic_vector( 3 downto  0);
      -- TX 64b66b and 64b67b gearbox
      TXGEARBOXREADY0             : out   std_ulogic;
      TXHEADER0                   : in    std_logic_vector( 2 downto  0);
      TXSEQUENCE0                 : in    std_logic_vector( 6 downto  0);
      TXSTARTSEQ0                 : in    std_ulogic;
      -- TX Pseudo Random Bit Sequences (PRBS)
      TXENPRBSTST0                : in    std_logic_vector( 1 downto  0);
      -- TX elastic buffer
      TXBUFSTATUS0                : out   std_logic_vector( 1 downto  0);
      -- TX phase alignment fifo
      TXENPMAPHASEALIGN0          : in    std_ulogic;
      TXPMASETPHASE0              : in    std_ulogic;
      -- TX polarity
      TXPOLARITY0                 : in    std_ulogic;
      -- TX Out Of Band (OOB) beaconing
      TXELECIDLE0                 : in    std_ulogic;
      -- TX PCIexpress
      TXDETECTRX0                 : in    std_ulogic;
      -- TX SATA
      TXCOMSTART0                 : in    std_ulogic;
      TXCOMTYPE0                  : in    std_ulogic;
      -- TX driver
      TXBUFDIFFCTRL0              : in    std_logic_vector( 2 downto  0);
      TXDIFFCTRL0                 : in    std_logic_vector( 2 downto  0);
      TXPREEMPHASIS0              : in    std_logic_vector( 3 downto  0);
      TXINHIBIT0                  : in    std_ulogic;
      -- TX serial ports
      TXP0                        : out   std_ulogic;
      TXN0                        : out   std_ulogic;
      ------------------------------------------------------------------------
      -- RX 1
      ------------------------------------------------------------------------
      -- RX resets
      RXRESET1                    : in    std_ulogic;
      -- RX power control
      RXPOWERDOWN1                : in    std_logic_vector( 1 downto  0);
      -- RX user clocks
      RXRECCLK1                   : out   std_ulogic;
      RXUSRCLK1                   : in    std_ulogic;
      RXUSRCLK21                  : in    std_ulogic;
      -- RX serial ports
      RXP1                        : in    std_ulogic;
      RXN1                        : in    std_ulogic;
      -- RX EQualizer (EQ)
      RXENEQB1                    : in    std_ulogic;
      RXEQMIX1                    : in    std_logic_vector( 1 downto  0);
      RXEQPOLE1                   : in    std_logic_vector( 3 downto  0);
      -- RX Decision Feedback Equalizer(DFE)
      DFECLKDLYADJ1               : in    std_logic_vector( 5 downto  0);
      DFECLKDLYADJMONITOR1        : out   std_logic_vector( 5 downto  0);
      DFEEYEDACMONITOR1           : out   std_logic_vector( 4 downto  0);
      DFESENSCAL1                 : out   std_logic_vector( 2 downto  0);
      DFETAP11                    : in    std_logic_vector( 4 downto  0);
      DFETAP1MONITOR1             : out   std_logic_vector( 4 downto  0);
      DFETAP21                    : in    std_logic_vector( 4 downto  0);
      DFETAP2MONITOR1             : out   std_logic_vector( 4 downto  0);
      DFETAP31                    : in    std_logic_vector( 3 downto  0);
      DFETAP3MONITOR1             : out   std_logic_vector( 3 downto  0);
      DFETAP41                    : in    std_logic_vector( 3 downto  0);
      DFETAP4MONITOR1             : out   std_logic_vector( 3 downto  0);
      -- RX Out Of Band (OOB)
      RXELECIDLE1                 : out   std_ulogic;
      RXVALID1                    : out   std_ulogic;
      PHYSTATUS1                  : out   std_ulogic;
      -- RX Clock Data Recovery (CDR)
      RXCDRRESET1                 : in    std_ulogic;
      -- RX oversampling
      RXENSAMPLEALIGN1            : in    std_ulogic;
      RXOVERSAMPLEERR1            : out   std_ulogic;
      -- RX polarity
      RXPOLARITY1                 : in    std_ulogic;
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBSCNTRESET1               : in    std_ulogic;
      RXENPRBSTST1                : in    std_logic_vector( 1 downto  0);
      RXPRBSERR1                  : out   std_ulogic;
      -- RX comma detection and alignment
      RXBYTEISALIGNED1            : out   std_ulogic;
      RXBYTEREALIGN1              : out   std_ulogic;
      RXCOMMADET1                 : out   std_ulogic;
      RXCOMMADETUSE1              : in    std_ulogic;
      RXENMCOMMAALIGN1            : in    std_ulogic;
      RXENPCOMMAALIGN1            : in    std_ulogic;
      RXSLIDE1                    : in    std_ulogic;
      -- RX loss of sync fsm
      RXLOSSOFSYNC1               : out   std_logic_vector( 1 downto  0);
      -- RX 8b10b decoder
      RXCHARISCOMMA1              : out   std_logic_vector( 3 downto  0);
      RXCHARISK1                  : out   std_logic_vector( 3 downto  0);
      RXDATAWIDTH1                : in    std_logic_vector( 1 downto  0);
      RXDEC8B10BUSE1              : in    std_ulogic;
      RXDISPERR1                  : out   std_logic_vector( 3 downto  0);
      RXNOTINTABLE1               : out   std_logic_vector( 3 downto  0);
      RXRUNDISP1                  : out   std_logic_vector( 3 downto  0);
      -- RX elastic buffer
      RXBUFRESET1                 : in    std_ulogic;
      RXBUFSTATUS1                : out   std_logic_vector( 2 downto  0);
      RXENPMAPHASEALIGN1          : in    std_ulogic;
      RXPMASETPHASE1              : in    std_ulogic;
      RXSTATUS1                   : out   std_logic_vector( 2 downto  0);
      -- RX clock correction
      RXCLKCORCNT1                : out   std_logic_vector( 2 downto  0);
      -- RX channel bonding
      RXCHANBONDSEQ1              : out   std_ulogic;
      RXCHANISALIGNED1            : out   std_ulogic;
      RXCHANREALIGN1              : out   std_ulogic;
      RXCHBONDI1                  : in    std_logic_vector( 3 downto  0);
      RXCHBONDO1                  : out   std_logic_vector( 3 downto  0);
      RXENCHANSYNC1               : in    std_ulogic;
      -- RX 64b66b and 64b67b gearbox
      RXDATAVALID1                : out   std_ulogic;
      RXGEARBOXSLIP1              : in    std_ulogic;
      RXHEADER1                   : out   std_logic_vector( 2 downto  0);
      RXHEADERVALID1              : out   std_ulogic;
      RXSTARTOFSEQ1               : out   std_ulogic;
      -- RX data ports
      RXDATA1                     : out   std_logic_vector(31 downto  0);
      ------------------------------------------------------------------------
      -- TX 1
      ------------------------------------------------------------------------
      -- TX resets
      TXRESET1                    : in    std_ulogic;
      -- TX power control
      TXPOWERDOWN1                : in    std_logic_vector( 1 downto  0);
      -- TX user clocks
      TXOUTCLK1                   : out   std_ulogic;
      TXUSRCLK1                   : in    std_ulogic;
      TXUSRCLK21                  : in    std_ulogic;
      -- TX data ports
      TXDATAWIDTH1                : in    std_logic_vector( 1 downto  0);
      TXDATA1                     : in    std_logic_vector(31 downto  0);
      -- TX 8b10b encoder
      TXBYPASS8B10B1              : in    std_logic_vector( 3 downto  0);
      TXCHARDISPMODE1             : in    std_logic_vector( 3 downto  0);
      TXCHARDISPVAL1              : in    std_logic_vector( 3 downto  0);
      TXCHARISK1                  : in    std_logic_vector( 3 downto  0);
      TXENC8B10BUSE1              : in    std_ulogic;
      TXKERR1                     : out   std_logic_vector( 3 downto  0);
      TXRUNDISP1                  : out   std_logic_vector( 3 downto  0);
      -- TX 64b66b and 64b67b gearbox
      TXGEARBOXREADY1             : out   std_ulogic;
      TXHEADER1                   : in    std_logic_vector( 2 downto  0);
      TXSEQUENCE1                 : in    std_logic_vector( 6 downto  0);
      TXSTARTSEQ1                 : in    std_ulogic;
      -- TX Pseudo Random Bit Sequences (PRBS)
      TXENPRBSTST1                : in    std_logic_vector( 1 downto  0);
      -- TX elastic buffer
      TXBUFSTATUS1                : out   std_logic_vector( 1 downto  0);
      -- TX phase alignment fifo
      TXENPMAPHASEALIGN1          : in    std_ulogic;
      TXPMASETPHASE1              : in    std_ulogic;
      -- TX polarity
      TXPOLARITY1                 : in    std_ulogic;
      -- TX Out Of Band (OOB) beaconing
      TXELECIDLE1                 : in    std_ulogic;
      -- TX PCIexpress
      TXDETECTRX1                 : in    std_ulogic;
      -- TX SATA
      TXCOMSTART1                 : in    std_ulogic;
      TXCOMTYPE1                  : in    std_ulogic;
      -- TX driver
      TXBUFDIFFCTRL1              : in    std_logic_vector( 2 downto  0);
      TXDIFFCTRL1                 : in    std_logic_vector( 2 downto  0);
      TXPREEMPHASIS1              : in    std_logic_vector( 3 downto  0);
      TXINHIBIT1                  : in    std_ulogic;
      -- TX serial ports
      TXP1                        : out   std_ulogic;
      TXN1                        : out   std_ulogic
   );
   end component;
   attribute BOX_TYPE of GTX_DUAL   : component is "PRIMITIVE";
  
  -- type gtx_baud_rate_params is record
    -- REF_CLK_FREQ              : integer;
    -- GTX_BAUD_RATE             : integer;
    -- CLK25_DIVIDER             : integer;
    -- PLL_DIVSEL_REF            : integer;
    -- PLL_DIVSEL_FB             : integer;
    -- PLL_RXDIVSEL_OUT_0        : integer;
    -- PLL_RXDIVSEL_OUT_1        : integer;
    -- PLL_TXDIVSEL_OUT_0        : integer;
    -- PLL_TXDIVSEL_OUT_1        : integer;
    -- PMA_CDR_SCAN_0            : bit_vector(26 downto 0);
    -- PMA_CDR_SCAN_1            : bit_vector(26 downto 0);
  -- end record gtx_baud_rate_params;
   
  -- type gtx_baud_rate_params_table is array (0 to 19) of gtx_baud_rate_params;
  
  -- constant c_gtx_baud_rate_params : gtx_baud_rate_params_table := (
   -- --REF_CLK_FREQ, GTX_BAUD_RATE, CLK25_DIVIDER, PLL_DIVSEL_REF, PLL_DIVSEL_FB, PLL_RXDIVSEL_OUT_0, PLL_RXDIVSEL_OUT_1, PLL_TXDIVSEL_OUT_0, PLL_TXDIVSEL_OUT_1,    PMA_CDR_SCAN_0,    PMA_CDR_SCAN_1
    -- (         125,        781.25,             5,              2,             5,                  4,                  4,                  4,                  4, "110" & X"404035", "110" & X"404035"),
  -- );
   
  function F_GET_PLL_PARAM (C_REF_CLK : integer; C_BAUD_RATE : integer; C_PARAM : integer) return integer is
    variable v_CLK25_DIVIDER  : integer;
    variable v_PLL_DIVSEL_REF : integer;
    variable v_PLL_DIVSEL_FB  : integer;
    variable v_PLL_DIVSEL_OUT : integer;
   begin
      case C_REF_CLK is 
        when 125 =>
          v_CLK25_DIVIDER   := 5;
          if    C_BAUD_RATE = 7812500 then
            v_PLL_DIVSEL_REF  := 2;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 937500  then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 3;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 1250000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 4;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 1562500 then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 1875000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 3;
            v_PLL_DIVSEL_OUT  := 2;
          elsif C_BAUD_RATE = 2500000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 4;
            v_PLL_DIVSEL_OUT  := 2;          
          elsif C_BAUD_RATE = 3125000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 2;
          elsif C_BAUD_RATE = 3750000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 3;
            v_PLL_DIVSEL_OUT  := 1;
          elsif C_BAUD_RATE = 5000000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 4;
            v_PLL_DIVSEL_OUT  := 1;
          elsif C_BAUD_RATE = 6250000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 1;
          else
            v_PLL_DIVSEL_REF  := 0;
            v_PLL_DIVSEL_FB   := 0;
            v_PLL_DIVSEL_OUT  := 0;
            assert false report "Invalid GTX baud rate = " & integer'image(C_BAUD_RATE) severity error;
          end if;
        when 150 =>
          v_CLK25_DIVIDER   := 6;
          if    C_BAUD_RATE = 750000    then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 2;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 937500  then
            v_PLL_DIVSEL_REF  := 2;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 1125000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 3;
            v_PLL_DIVSEL_OUT  := 4;
          elsif C_BAUD_RATE = 1500000 then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 2;
            v_PLL_DIVSEL_OUT  := 2;
          elsif C_BAUD_RATE = 1875000   then
            v_PLL_DIVSEL_REF  := 2;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 2;
          elsif C_BAUD_RATE = 2250000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 3;
            v_PLL_DIVSEL_OUT  := 2;
          elsif C_BAUD_RATE = 3000000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 4;
            v_PLL_DIVSEL_OUT  := 2;
          elsif C_BAUD_RATE = 3750000   then
            v_PLL_DIVSEL_REF  := 2;
            v_PLL_DIVSEL_FB   := 5;
            v_PLL_DIVSEL_OUT  := 1;
          elsif C_BAUD_RATE = 4500000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 3;
            v_PLL_DIVSEL_OUT  := 1;
          elsif C_BAUD_RATE = 6000000   then
            v_PLL_DIVSEL_REF  := 1;
            v_PLL_DIVSEL_FB   := 4;
            v_PLL_DIVSEL_OUT  := 1;
          else
            v_PLL_DIVSEL_REF  := 0;
            v_PLL_DIVSEL_FB   := 0;
            v_PLL_DIVSEL_OUT  := 0;
            assert false report "Invalid GTX baud rate = " & integer'image(C_BAUD_RATE) severity error;
          end if;
        when others =>
          v_CLK25_DIVIDER     := 0;
          v_PLL_DIVSEL_REF    := 0;
          v_PLL_DIVSEL_FB     := 0;
          v_PLL_DIVSEL_OUT    := 0;
          assert false report "Invalid GTX reference frequency = " & integer'image(C_REF_CLK) severity error;
      end case;
      
      case C_PARAM is
        when 0 => --C_CLK25_DIVIDER
          return v_CLK25_DIVIDER;
        when 1 => --C_PLL_DIVSEL_REF
          return v_PLL_DIVSEL_REF;
        when 2 => --C_PLL_DIVSEL_FB
          return v_PLL_DIVSEL_FB;
        when 3 => --C_PLL_DIVSEL_OUT
          return v_PLL_DIVSEL_OUT;
        when others =>
          assert false report "Request for invalid parameter number = " & integer'image(C_PARAM) severity error;
          return 0;
      end case;
      
   end F_GET_PLL_PARAM;
   
  function F_GET_CDR_SCAN_PARAM (C_PLL_DIVSEL_OUT : integer; C_BAUD_RATE : integer ) return bit_vector is
    
  begin
    if C_PLL_DIVSEL_OUT = 2 or C_PLL_DIVSEL_OUT = 4 then
      return "110" & X"404035";
    else
      if C_BAUD_RATE = 3000000 then
        return "110" & X"40403B";
      elsif C_BAUD_RATE = 3750000 then
        return "110" & X"404039";
      elsif C_BAUD_RATE = 4500000 then
        return "110" & X"404038";
      elsif C_BAUD_RATE = 6000000 then
        return "110" & X"404035";
      else
        return "110" & X"404035";
      end if;
    end if;
    
  end F_GET_CDR_SCAN_PARAM;
   
   
  constant C_CLK25_DIVIDER         : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 0);
  constant C_PLL_DIVSEL_REF        : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 1);
  constant C_PLL_DIVSEL_FB         : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 2);
  constant C_PLL_RXDIVSEL_OUT_0    : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 3); 
  constant C_PLL_RXDIVSEL_OUT_1    : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 3); 
  constant C_PLL_TXDIVSEL_OUT_0    : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 3); 
  constant C_PLL_TXDIVSEL_OUT_1    : integer := F_GET_PLL_PARAM(G_GTX_TILE_REFCLK_FREQ, G_GTX_BAUD_RATE, 3); 
  constant C_PMA_CDR_SCAN_0        : bit_vector(26 downto 0) := F_GET_CDR_SCAN_PARAM(C_PLL_RXDIVSEL_OUT_0, G_GTX_BAUD_RATE);
  constant C_PMA_CDR_SCAN_1        : bit_vector(26 downto 0) := F_GET_CDR_SCAN_PARAM(C_PLL_RXDIVSEL_OUT_1, G_GTX_BAUD_RATE);
begin

   ---------------------------------------------------------------------------
   -- GTX Instantiation
   ---------------------------------------------------------------------------
   gtx_dual_i:GTX_DUAL
   generic map
   (
      ------------------------------------------------------------------------
      -- Simulation
      ------------------------------------------------------------------------
      SIM_RECEIVER_DETECT_PASS_0  => TRUE,
      SIM_RECEIVER_DETECT_PASS_1  => TRUE,
      SIM_MODE                    => SIM_MODE,
      SIM_GTXRESET_SPEEDUP        => SIM_GTXRESET_SPEEDUP,
      SIM_PLL_PERDIV2             => SIM_PLL_PERDIV2,
      ------------------------------------------------------------------------
      -- CTRL
      ------------------------------------------------------------------------
      -- PLL
      OVERSAMPLE_MODE             => FALSE,
      PLL_DIVSEL_FB               => C_PLL_DIVSEL_FB,
      PLL_DIVSEL_REF              => C_PLL_DIVSEL_REF,

      PLL_COM_CFG                 => X"21680A",                              -- Tile and PLL Attributes badly documented
      PLL_CP_CFG                  => X"00",                                  -- Tile and PLL Attributes badly documented
      PLL_FB_DCCEN                => FALSE,                                  -- Tile and PLL Attributes badly documented
      PLL_LKDET_CFG               => "101",                                  -- Tile and PLL Attributes badly documented
      PLL_TDCC_CFG                => "000",                                  -- Tile and PLL Attributes badly documented
      PMA_COM_CFG                 => X"000000000000000000",                  -- Tile and PLL Attributes badly documented

      PLL_SATA_0                  => FALSE,
      PLL_SATA_1                  => FALSE,
      -- Shared clocking
      CLK25_DIVIDER               => 5, 
      CLKINDC_B                   => TRUE,
      CLKRCV_TRST                 => TRUE,
      -- Termination
      TERMINATION_CTRL            => "10100",
      TERMINATION_OVRD            => FALSE,
      -- RX Decision Feedback Equalizer(DFE)
      DFE_CAL_TIME                => "00110",
      -- RX Out Of Band (OOB)
      OOB_CLK_DIVIDER             => 4,
      -- RX Clock Data Recovery (CDR)
      CDR_PH_ADJ_TIME             => "01010",
      RX_EN_IDLE_RESET_FR         => TRUE,
      RX_EN_IDLE_HOLD_CDR         => FALSE,
      RX_EN_IDLE_RESET_PH         => TRUE,
      ------------------------------------------------------------------------
      -- RX 0
      ------------------------------------------------------------------------
      -- RX serial ports
      AC_CAP_DIS_0                => FALSE, --TRUE,
      CM_TRIM_0                   => "10",
      RCV_TERM_GND_0              => FALSE,
      RCV_TERM_VTTRX_0            => TRUE,
      TERMINATION_IMP_0           => 50,
      -- RX Decision Feedback Equalizer(DFE)
      DFE_CFG_0                   => "1001111011",
      RX_EN_IDLE_HOLD_DFE_0       => TRUE,
      -- RX Out Of Band (OOB)
      OOBDETECT_THRESHOLD_0       => "111",
      RX_STATUS_FMT_0             => "PCIE",
      -- RX PCIexpress
      RX_IDLE_HI_CNT_0            => "1000",
      RX_IDLE_LO_CNT_0            => "0000",
      -- RX SATA
      SATA_BURST_VAL_0            => "100",
      SATA_IDLE_VAL_0             => "100",
      SATA_MAX_BURST_0            => 7,
      SATA_MAX_INIT_0             => 22,
      SATA_MAX_WAKE_0             => 7,
      SATA_MIN_BURST_0            => 4,
      SATA_MIN_INIT_0             => 12,
      SATA_MIN_WAKE_0             => 4,
      TRANS_TIME_FROM_P2_0        => X"003C",
      TRANS_TIME_NON_P2_0         => X"0019",
      TRANS_TIME_TO_P2_0          => X"0064",
      -- RX Clock Data Recovery (CDR)
      PMA_CDR_SCAN_0              => C_PMA_CDR_SCAN_0, --X"6404035", -- for PLL_RXDIVSEL_OUT=1 X"6404037", for PLL_RXDIVSEL_OUT=2 or 4 X"6404035"
      PMA_RX_CFG_0                => X"0F44089",
      -- RX serial line rate clocks
      PLL_RXDIVSEL_OUT_0          => C_PLL_RXDIVSEL_OUT_0,
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBS_ERR_THRESHOLD_0        => X"00000001",
      -- RX comma detection and alignment
      ALIGN_COMMA_WORD_0          => 2,
      COMMA_10B_ENABLE_0          => "1111111111",
      COMMA_DOUBLE_0              => FALSE,
      MCOMMA_10B_VALUE_0          => "1010000011",
      MCOMMA_DETECT_0             => TRUE,
      PCOMMA_10B_VALUE_0          => "0101111100",
      PCOMMA_DETECT_0             => TRUE,
      RX_SLIDE_MODE_0             => "PMA",
      -- RX loss of sync fsm
      --LOSS OF SYNC (10). Start status
      --    If good characters are received, transition to RESYNC status (01)
      --RESYNC (01)
      --    If good characters
      RX_LOS_INVALID_INCR_0       => 4, --good characters needed to DECREMENT the error count
      RX_LOS_THRESHOLD_0          => 4,   --error count needed to disconnect
      RX_LOSS_OF_SYNC_FSM_0       => TRUE,
      -- RX 8b10b decoder
      DEC_MCOMMA_DETECT_0         => TRUE,
      DEC_PCOMMA_DETECT_0         => TRUE,
      DEC_VALID_COMMA_ONLY_0      => FALSE,
      -- RX elastic buffer
      PMA_RXSYNC_CFG_0            => X"00",                                  -- RX Elastic Buffer and Phase alignment Attributes badly described
      RX_BUFFER_USE_0             => FALSE,
      RX_EN_IDLE_RESET_BUF_0      => TRUE,
      RX_XCLK_SEL_0               => "RXUSR",
      -- RX clock correction
      CLK_CORRECT_USE_0           => FALSE,
      CLK_COR_ADJ_LEN_0           => 3,
      CLK_COR_DET_LEN_0           => 1,
      CLK_COR_INSERT_IDLE_FLAG_0  => FALSE,
      CLK_COR_KEEP_IDLE_0         => FALSE,
      CLK_COR_MAX_LAT_0           => 18,
      CLK_COR_MIN_LAT_0           => 16,
      CLK_COR_PRECEDENCE_0        => TRUE,
      CLK_COR_REPEAT_WAIT_0       => 0,
      CLK_COR_SEQ_1_1_0           => "0000000000",
      CLK_COR_SEQ_1_2_0           => "0000000000",
      CLK_COR_SEQ_1_3_0           => "0000000000",
      CLK_COR_SEQ_1_4_0           => "0000000000",
      CLK_COR_SEQ_1_ENABLE_0      => "0000",
      CLK_COR_SEQ_2_1_0           => "0000000000",
      CLK_COR_SEQ_2_2_0           => "0000000000",
      CLK_COR_SEQ_2_3_0           => "0000000000",
      CLK_COR_SEQ_2_4_0           => "0000000000",
      CLK_COR_SEQ_2_ENABLE_0      => "0000",
      CLK_COR_SEQ_2_USE_0         => FALSE,
      RX_DECODE_SEQ_MATCH_0       => TRUE,
      -- RX channel bonding
      CB2_INH_CC_PERIOD_0         => 8,
      CHAN_BOND_1_MAX_SKEW_0      => 1,
      CHAN_BOND_2_MAX_SKEW_0      => 1,
      CHAN_BOND_KEEP_ALIGN_0      => FALSE,
      CHAN_BOND_LEVEL_0           => 0,
      CHAN_BOND_MODE_0            => "OFF",
      --ML84: changed according to AR29218
      CHAN_BOND_SEQ_1_1_0         => "0100000000", --"0000000000",
      CHAN_BOND_SEQ_1_2_0         => "0100000000", --"0000000000",
      CHAN_BOND_SEQ_1_3_0         => "0100000000", --"0000000000", 
      CHAN_BOND_SEQ_1_4_0         => "0100000000", --"0000000000", 
      CHAN_BOND_SEQ_1_ENABLE_0    => "0001", --"0000", 
      CHAN_BOND_SEQ_2_1_0         => "0100000000", --"0000000000",
      CHAN_BOND_SEQ_2_2_0         => "0100000000", --"0000000000",
      CHAN_BOND_SEQ_2_3_0         => "0100000000", --"0000000000",
      CHAN_BOND_SEQ_2_4_0         => "0100000000", --"0000000000",
      CHAN_BOND_SEQ_2_ENABLE_0    => "0001", --"0000",
      CHAN_BOND_SEQ_2_USE_0       => FALSE,  
      CHAN_BOND_SEQ_LEN_0         => 1,
      PCI_EXPRESS_MODE_0          => FALSE,
      -- RX 64b66b and 64b67b gearbox
      RXGEARBOX_USE_0             => FALSE,
      ------------------------------------------------------------------------
      -- TX 0
      ------------------------------------------------------------------------
      -- TX 64b66b and 64b67b gearbox
      GEARBOX_ENDEC_0             => "000", 
      TXGEARBOX_USE_0             => FALSE,
      -- TX serial line rate clocks
      PLL_TXDIVSEL_OUT_0          => C_PLL_TXDIVSEL_OUT_0,
      -- TX elastic buffer
      TX_BUFFER_USE_0             => TRUE,
      TX_XCLK_SEL_0               => "TXOUT",
      TXRX_INVERT_0               => "011",
      -- TX Out Of Band (OOB) beaconing
      COM_BURST_VAL_0             => "1111",
      PMA_TX_CFG_0                => X"80082",
      TX_DETECT_RX_CFG_0          => X"1832",                                -- TX Driver and OOB signalling badly documented
      TX_IDLE_DELAY_0             => "010",                                  -- TX Driver and OOB signalling badly documented
      ------------------------------------------------------------------------
      -- RX 1
      ------------------------------------------------------------------------
      -- RX serial ports
      AC_CAP_DIS_1                => FALSE, --TRUE,
      CM_TRIM_1                   => "10",
      RCV_TERM_GND_1              => FALSE,
      RCV_TERM_VTTRX_1            => TRUE,
      TERMINATION_IMP_1           => 50,
      -- RX Decision Feedback Equalizer(DFE)
      DFE_CFG_1                   => "1001111011",
      RX_EN_IDLE_HOLD_DFE_1       => TRUE,
      -- RX Out Of Band (OOB)
      OOBDETECT_THRESHOLD_1       => "111",
      RX_STATUS_FMT_1             => "PCIE",
      -- RX PCIexpress
      RX_IDLE_HI_CNT_1            => "1000",
      RX_IDLE_LO_CNT_1            => "0000",
      -- RX SATA
      SATA_BURST_VAL_1            => "100",
      SATA_IDLE_VAL_1             => "100",
      SATA_MAX_BURST_1            => 7,
      SATA_MAX_INIT_1             => 22,
      SATA_MAX_WAKE_1             => 7,
      SATA_MIN_BURST_1            => 4,
      SATA_MIN_INIT_1             => 12,
      SATA_MIN_WAKE_1             => 4,
      TRANS_TIME_FROM_P2_1        => X"003C",
      TRANS_TIME_NON_P2_1         => X"0019",
      TRANS_TIME_TO_P2_1          => X"0064",
      -- RX Clock Data Recovery (CDR)
      PMA_CDR_SCAN_1              => C_PMA_CDR_SCAN_1, --X"6404035", -- for PLL_RXDIVSEL_OUT=1 X"6404037", for PLL_RXDIVSEL_OUT=2 or 4 X"6404035"
      PMA_RX_CFG_1                => X"0F44089",  
      -- RX serial line rate clocks
      PLL_RXDIVSEL_OUT_1          => C_PLL_RXDIVSEL_OUT_1,
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBS_ERR_THRESHOLD_1        => X"00000001",
      -- RX comma detection and alignment
      ALIGN_COMMA_WORD_1          => 2,
      COMMA_10B_ENABLE_1          => "1111111111",
      COMMA_DOUBLE_1              => FALSE,
      MCOMMA_10B_VALUE_1          => "1010000011",
      MCOMMA_DETECT_1             => TRUE,
      PCOMMA_10B_VALUE_1          => "0101111100",
      PCOMMA_DETECT_1             => TRUE,
      RX_SLIDE_MODE_1             => "PMA",
      -- RX loss of sync fsm
      RX_LOS_INVALID_INCR_1       => 4, --
      RX_LOS_THRESHOLD_1          => 4,
      RX_LOSS_OF_SYNC_FSM_1       => TRUE,
      -- RX 8b10b decoder
      DEC_MCOMMA_DETECT_1         => TRUE,
      DEC_PCOMMA_DETECT_1         => TRUE,
      DEC_VALID_COMMA_ONLY_1      => FALSE,
      -- RX elastic buffer
      PMA_RXSYNC_CFG_1            => X"00",                                  -- RX Elastic Buffer and Phase alignment Attributes badly described
      RX_BUFFER_USE_1             => FALSE,
      RX_EN_IDLE_RESET_BUF_1      => TRUE,
      RX_XCLK_SEL_1               => "RXUSR",
      -- RX clock correction
      CLK_CORRECT_USE_1           => FALSE,
      CLK_COR_ADJ_LEN_1           => 3,
      CLK_COR_DET_LEN_1           => 1,
      CLK_COR_INSERT_IDLE_FLAG_1  => FALSE,
      CLK_COR_KEEP_IDLE_1         => FALSE,
      CLK_COR_MAX_LAT_1           => 18,
      CLK_COR_MIN_LAT_1           => 16,
      CLK_COR_PRECEDENCE_1        => TRUE,
      CLK_COR_REPEAT_WAIT_1       => 0,
      CLK_COR_SEQ_1_1_1           => "0000000000",
      CLK_COR_SEQ_1_2_1           => "0000000000",
      CLK_COR_SEQ_1_3_1           => "0000000000",
      CLK_COR_SEQ_1_4_1           => "0000000000",
      CLK_COR_SEQ_1_ENABLE_1      => "0000",
      CLK_COR_SEQ_2_1_1           => "0000000000",
      CLK_COR_SEQ_2_2_1           => "0000000000",
      CLK_COR_SEQ_2_3_1           => "0000000000",
      CLK_COR_SEQ_2_4_1           => "0000000000",
      CLK_COR_SEQ_2_ENABLE_1      => "0000",
      CLK_COR_SEQ_2_USE_1         => FALSE,
      RX_DECODE_SEQ_MATCH_1       => TRUE,
      -- RX channel bonding
      CB2_INH_CC_PERIOD_1         => 8,
      CHAN_BOND_1_MAX_SKEW_1      => 1,
      CHAN_BOND_2_MAX_SKEW_1      => 1,
      CHAN_BOND_KEEP_ALIGN_1      => FALSE,
      CHAN_BOND_LEVEL_1           => 0,
      CHAN_BOND_MODE_1            => "OFF",
      CHAN_BOND_SEQ_1_1_1         => "0000000000",
      CHAN_BOND_SEQ_1_2_1         => "0000000000",
      CHAN_BOND_SEQ_1_3_1         => "0000000000",
      CHAN_BOND_SEQ_1_4_1         => "0000000000",
      CHAN_BOND_SEQ_1_ENABLE_1    => "0000",
      CHAN_BOND_SEQ_2_1_1         => "0000000000",
      CHAN_BOND_SEQ_2_2_1         => "0000000000",
      CHAN_BOND_SEQ_2_3_1         => "0000000000",
      CHAN_BOND_SEQ_2_4_1         => "0000000000",
      CHAN_BOND_SEQ_2_ENABLE_1    => "0000",
      CHAN_BOND_SEQ_2_USE_1       => FALSE,  
      CHAN_BOND_SEQ_LEN_1         => 1,
      PCI_EXPRESS_MODE_1          => FALSE,
      -- RX 64b66b and 64b67b gearbox
      RXGEARBOX_USE_1             => FALSE,
      ------------------------------------------------------------------------
      -- TX 1
      ------------------------------------------------------------------------
      -- TX 64b66b and 64b67b gearbox
      GEARBOX_ENDEC_1             => "000", 
      TXGEARBOX_USE_1             => FALSE,
      -- TX serial line rate clocks
      PLL_TXDIVSEL_OUT_1          => C_PLL_TXDIVSEL_OUT_1,
      -- TX elastic buffer
      TX_BUFFER_USE_1             => TRUE,
      TX_XCLK_SEL_1               => "TXOUT",
      TXRX_INVERT_1               => "011",
      -- TX Out Of Band (OOB) beaconing
      COM_BURST_VAL_1             => "1111",
      PMA_TX_CFG_1                => X"80082",
      TX_DETECT_RX_CFG_1          => X"1832",                                -- TX Driver and OOB signalling badly documented
      TX_IDLE_DELAY_1             => "010"                                   -- TX Driver and OOB signalling badly documented
   )
   port map
   (
      ------------------------------------------------------------------------
      -- CTRL
      ------------------------------------------------------------------------
      -- Xilinx test ports
      GTXTEST                     => "10000000000000",
      -- Global ports
      GTXRESET                    => i_mgt.ctrl.GTXRESET,
      RESETDONE0                  => o_mgt.ctrl.RESETDONE0,
      RESETDONE1                  => o_mgt.ctrl.RESETDONE1,
      INTDATAWIDTH                => HIGH,
      -- PLL
      CLKIN                       => i_mgt.ctrl.CLKIN,
      REFCLKPWRDNB                => i_mgt.ctrl.REFCLKPWRDNB,
      REFCLKOUT                   => o_mgt.ctrl.REFCLKOUT,
      PLLLKDET                    => o_mgt.ctrl.PLLLKDET,
      PLLLKDETEN                  => HIGH,
      PLLPOWERDOWN                => LOW,
      -- Loopback
      LOOPBACK0                   => i_mgt.ctrl.LOOPBACK0,
      LOOPBACK1                   => i_mgt.ctrl.LOOPBACK1,
      ------------------------------------------------------------------------
      -- DRP
      ------------------------------------------------------------------------
      -- Dynamic Reconfiguration Port (DRP)
      DCLK                        => i_mgt.drp.DCLK,
      DEN                         => i_mgt.drp.DEN,
      DWE                         => i_mgt.drp.DWE,
      DADDR                       => i_mgt.drp.DADDR,
      DI                          => i_mgt.drp.DI,
      DO                          => o_mgt.drp.DO,
      DRDY                        => o_mgt.drp.DRDY,
      ------------------------------------------------------------------------
      -- RX 0
      ------------------------------------------------------------------------
      -- RX resets
      RXRESET0                    => i_mgt.rx( 0).RXRESET,
      -- RX power control
      RXPOWERDOWN0                => "00",
      -- RX user clocks
      RXRECCLK0                   => o_mgt.rx( 0).RXRECCLK,
      RXUSRCLK0                   => i_mgt.rx( 0).RXUSRCLK,
      RXUSRCLK20                  => i_mgt.rx( 0).RXUSRCLK2,
      -- RX serial ports
      RXP0                        => i_mgt.rx( 0).RXP,
      RXN0                        => i_mgt.rx( 0).RXN,
      -- RX EQualizer (EQ)          
      RXENEQB0                    => '0',
      RXEQMIX0                    => "00",
      RXEQPOLE0                   => "0000",
      -- RX Decision Feedback Equalizer(DFE)
      DFECLKDLYADJ0               => "000000",
      DFECLKDLYADJMONITOR0        => open,
      DFEEYEDACMONITOR0           => open,
      DFESENSCAL0                 => open,
      DFETAP10                    => "00000",
      DFETAP1MONITOR0             => open,
      DFETAP20                    => "00000",
      DFETAP2MONITOR0             => open,
      DFETAP30                    => "0000",
      DFETAP3MONITOR0             => open,
      DFETAP40                    => "0000",
      DFETAP4MONITOR0             => open,
      -- RX Out Of Band (OOB)
      RXELECIDLE0                 => o_mgt.rx( 0).RXELECIDLE,
      RXVALID0                    => open,
      PHYSTATUS0                  => open,
      -- RX Clock Data Recovery (CDR)
      RXCDRRESET0                 => '0',
      -- RX oversampling
      RXENSAMPLEALIGN0            => '0',
      RXOVERSAMPLEERR0            => open,
      -- RX polarity
      RXPOLARITY0                 => '0',
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBSCNTRESET0               => '0',
      RXENPRBSTST0                => "00",
      RXPRBSERR0                  => open,
      -- RX comma detection and alignment
      RXBYTEISALIGNED0            => open,
      RXBYTEREALIGN0              => open,
      RXCOMMADET0                 => open,
      RXCOMMADETUSE0              => '1',
      RXENMCOMMAALIGN0            => i_mgt.rx( 0).RXENMCOMMAALIGN,
      RXENPCOMMAALIGN0            => i_mgt.rx( 0).RXENPCOMMAALIGN,
      RXSLIDE0                    => '0',
      -- RX loss of sync fsm
      RXLOSSOFSYNC0               => o_mgt.rx( 0).RXLOSSOFSYNC,
      -- RX 8b10b decoder
      RXCHARISCOMMA0              => o_mgt.rx( 0).RXCHARISCOMMA,
      RXCHARISK0                  => o_mgt.rx( 0).RXCHARISK,
      RXDATAWIDTH0                => "01",
      RXDEC8B10BUSE0              => '1',
      RXDISPERR0                  => o_mgt.rx( 0).RXDISPERR,
      RXNOTINTABLE0               => o_mgt.rx( 0).RXNOTINTABLE,
      RXRUNDISP0                  => o_mgt.rx( 0).RXRUNDISP,
      -- RX elastic buffer
      RXBUFRESET0                 => LOW,
      RXBUFSTATUS0                => open,
      RXENPMAPHASEALIGN0          => i_mgt.rx( 0).RXENPMAPHASEALIGN,
      RXPMASETPHASE0              => i_mgt.rx( 0).RXPMASETPHASE,
      RXSTATUS0                   => open,
      -- RX clock correction
      RXCLKCORCNT0                => open,
      -- RX channel bonding
      RXCHANBONDSEQ0              => open,
      RXCHANISALIGNED0            => open,
      RXCHANREALIGN0              => open,
      RXCHBONDI0                  => "0000",
      RXCHBONDO0                  => open,
      RXENCHANSYNC0               => '0',
      -- RX 64b66b and 64b67b gearbox
      RXDATAVALID0                => open,
      RXGEARBOXSLIP0              => '0',
      RXHEADER0                   => open,
      RXHEADERVALID0              => open,
      RXSTARTOFSEQ0               => open,
      -- RX data ports
      RXDATA0                     => o_mgt.rx( 0).RXDATA,
      ------------------------------------------------------------------------
      -- TX 0
      ------------------------------------------------------------------------
      -- TX resets
      TXRESET0                    => i_mgt.tx( 0).TXRESET,
      -- TX power control
      TXPOWERDOWN0                => "00",
      -- TX user clocks
      TXOUTCLK0                   => o_mgt.tx( 0).TXOUTCLK,
      TXUSRCLK0                   => i_mgt.tx( 0).TXUSRCLK,
      TXUSRCLK20                  => i_mgt.tx( 0).TXUSRCLK2,
      -- TX data ports
      TXDATAWIDTH0                => "01",
      TXDATA0                     => i_mgt.tx( 0).TXDATA,
      -- TX 8b10b encoder
      TXBYPASS8B10B0              => i_mgt.tx( 0).TXBYPASS8B10B,
      TXCHARDISPMODE0             => i_mgt.tx( 0).TXCHARDISPMODE,
      TXCHARDISPVAL0              => i_mgt.tx( 0).TXCHARDISPVAL,
      TXCHARISK0                  => i_mgt.tx( 0).TXCHARISK,
      TXENC8B10BUSE0              => '1',
      TXKERR0                     => o_mgt.tx( 0).TXKERR,
      TXRUNDISP0                  => o_mgt.tx( 0).TXRUNDISP,
      -- TX 64b66b and 64b67b gearbox
      TXGEARBOXREADY0             => open,
      TXHEADER0                   => "000",
      TXSEQUENCE0                 => "0000000",
      TXSTARTSEQ0                 => '0',
      -- TX Pseudo Random Bit Sequences (PRBS)
      TXENPRBSTST0                => "00",
      -- TX elastic buffer
      TXBUFSTATUS0                => open,
      -- TX phase alignment fifo
      TXENPMAPHASEALIGN0          => '0',
      TXPMASETPHASE0              => '0',
      -- TX polarity
      TXPOLARITY0                 => '0',
      -- TX Out Of Band (OOB) beaconing
      TXELECIDLE0                 => '0',
      -- TX PCIexpress
      TXDETECTRX0                 => '0',
      -- TX SATA
      TXCOMSTART0                 => '0',
      TXCOMTYPE0                  => '0',
      -- TX driver
      TXBUFDIFFCTRL0              => "101",
      TXDIFFCTRL0                 => i_mgt.tx( 0).TXDIFFCTRL,
      TXPREEMPHASIS0(3)           => '0',
      TXPREEMPHASIS0(2 downto 0)  => i_mgt.tx( 0).TXPREEMPHASIS( 2 downto 0),
      TXINHIBIT0                  => '0',
      -- TX serial ports
      TXP0                        => o_mgt.tx( 0).TXP,
      TXN0                        => o_mgt.tx( 0).TXN,
      ------------------------------------------------------------------------
      -- RX 1
      ------------------------------------------------------------------------
      -- RX resets
      RXRESET1                    => i_mgt.rx( 1).RXRESET,
      -- RX power control
      RXPOWERDOWN1                => "00",
      -- RX user clocks
      RXRECCLK1                   => o_mgt.rx( 1).RXRECCLK,
      RXUSRCLK1                   => i_mgt.rx( 1).RXUSRCLK,
      RXUSRCLK21                  => i_mgt.rx( 1).RXUSRCLK2,
      -- RX serial ports
      RXP1                        => i_mgt.rx( 1).RXP,
      RXN1                        => i_mgt.rx( 1).RXN,
      -- RX EQualizer (EQ)          
      RXENEQB1                    => '0',
      RXEQMIX1                    => "00",
      RXEQPOLE1                   => "0000",
      -- RX Decision Feedback Equalizer(DFE)
      DFECLKDLYADJ1               => "000000",
      DFECLKDLYADJMONITOR1        => open,
      DFEEYEDACMONITOR1           => open,
      DFESENSCAL1                 => open,
      DFETAP11                    => "00000",
      DFETAP1MONITOR1             => open,
      DFETAP21                    => "00000",
      DFETAP2MONITOR1             => open,
      DFETAP31                    => "0000",
      DFETAP3MONITOR1             => open,
      DFETAP41                    => "0000",
      DFETAP4MONITOR1             => open,
      -- RX Out Of Band (OOB)
      RXELECIDLE1                 => o_mgt.rx( 1).RXELECIDLE,
      RXVALID1                    => open,
      PHYSTATUS1                  => open,
      -- RX Clock Data Recovery (CDR)
      RXCDRRESET1                 => '0',
      -- RX oversampling
      RXENSAMPLEALIGN1            => '0',
      RXOVERSAMPLEERR1            => open,
      -- RX polarity
      RXPOLARITY1                 => '0',
      -- RX Pseudo Random Bit Sequences (PRBS)
      PRBSCNTRESET1               => '0',
      RXENPRBSTST1                => "00",
      RXPRBSERR1                  => open,
      -- RX comma detection and alignment
      RXBYTEISALIGNED1            => open,
      RXBYTEREALIGN1              => open,
      RXCOMMADET1                 => open,
      RXCOMMADETUSE1              => '1',
      RXENMCOMMAALIGN1            => i_mgt.rx( 1).RXENMCOMMAALIGN,
      RXENPCOMMAALIGN1            => i_mgt.rx( 1).RXENPCOMMAALIGN,
      RXSLIDE1                    => '0',
      -- RX loss of sync fsm
      RXLOSSOFSYNC1               => o_mgt.rx( 1).RXLOSSOFSYNC,
      -- RX 8b10b decoder
      RXCHARISCOMMA1              => o_mgt.rx( 1).RXCHARISCOMMA,
      RXCHARISK1                  => o_mgt.rx( 1).RXCHARISK,
      RXDATAWIDTH1                => "01",
      RXDEC8B10BUSE1              => '1',
      RXDISPERR1                  => o_mgt.rx( 1).RXDISPERR,
      RXNOTINTABLE1               => o_mgt.rx( 1).RXNOTINTABLE,
      RXRUNDISP1                  => o_mgt.rx( 1).RXRUNDISP,
      -- RX elastic buffer
      RXBUFRESET1                 => LOW,
      RXBUFSTATUS1                => open,
      RXENPMAPHASEALIGN1          => i_mgt.rx( 1).RXENPMAPHASEALIGN,
      RXPMASETPHASE1              => i_mgt.rx( 1).RXPMASETPHASE,
      RXSTATUS1                   => open,
      -- RX clock correction
      RXCLKCORCNT1                => open,
      -- RX channel bonding
      RXCHANBONDSEQ1              => open,
      RXCHANISALIGNED1            => open,
      RXCHANREALIGN1              => open,
      RXCHBONDI1                  => "0000",
      RXCHBONDO1                  => open,
      RXENCHANSYNC1               => '0',
      -- RX 64b66b and 64b67b gearbox
      RXDATAVALID1                => open,
      RXGEARBOXSLIP1              => '0',
      RXHEADER1                   => open,
      RXHEADERVALID1              => open,
      RXSTARTOFSEQ1               => open,
      -- RX data ports
      RXDATA1                     => o_mgt.rx( 1).RXDATA,
      ------------------------------------------------------------------------
      -- TX 1
      ------------------------------------------------------------------------
      -- TX resets
      TXRESET1                    => i_mgt.tx( 1).TXRESET,
      -- TX power control
      TXPOWERDOWN1                => "00",
      -- TX user clocks
      TXOUTCLK1                   => o_mgt.tx( 1).TXOUTCLK,
      TXUSRCLK1                   => i_mgt.tx( 1).TXUSRCLK,
      TXUSRCLK21                  => i_mgt.tx( 1).TXUSRCLK2,
      -- TX data ports
      TXDATAWIDTH1                => "01",
      TXDATA1                     => i_mgt.tx( 1).TXDATA,
      -- TX 8b10b encoder
      TXBYPASS8B10B1              => i_mgt.tx( 1).TXBYPASS8B10B,
      TXCHARDISPMODE1             => i_mgt.tx( 1).TXCHARDISPMODE,
      TXCHARDISPVAL1              => i_mgt.tx( 1).TXCHARDISPVAL,
      TXCHARISK1                  => i_mgt.tx( 1).TXCHARISK,
      TXENC8B10BUSE1              => '1',
      TXKERR1                     => o_mgt.tx( 1).TXKERR,
      TXRUNDISP1                  => o_mgt.tx( 1).TXRUNDISP,
      -- TX 64b66b and 64b67b gearbox
      TXGEARBOXREADY1             => open,
      TXHEADER1                   => "000",
      TXSEQUENCE1                 => "0000000",
      TXSTARTSEQ1                 => '0',
      -- TX Pseudo Random Bit Sequences (PRBS)
      TXENPRBSTST1                => "00",
      -- TX elastic buffer
      TXBUFSTATUS1                => open,
      -- TX phase alignment fifo
      TXENPMAPHASEALIGN1          => '0',
      TXPMASETPHASE1              => '0',
      -- TX polarity
      TXPOLARITY1                 => '0',
      -- TX Out Of Band (OOB) beaconing
      TXELECIDLE1                 => '0',
      -- TX PCIexpress
      TXDETECTRX1                 => '0',
      -- TX SATA
      TXCOMSTART1                 => '0',
      TXCOMTYPE1                  => '0',
      -- TX driver
      TXBUFDIFFCTRL1              => "101",
      TXDIFFCTRL1                 => i_mgt.tx( 1).TXDIFFCTRL,
      TXPREEMPHASIS1(3)           => '0',
      TXPREEMPHASIS1(2 downto 0)  => i_mgt.tx( 1).TXPREEMPHASIS( 2 downto 0),
      TXINHIBIT1                  => '0',
      -- TX serial ports
      TXP1                        => o_mgt.tx( 1).TXP,
      TXN1                        => o_mgt.tx( 1).TXN
   );

end structural;

-- ------------------------------------------------------------------------------
-- -- Module mgt_32bit_align
-- ------------------------------------------------------------------------------
-- -- Std. library (platform) ---------------------------------------------------
-- library IEEE;
-- use IEEE.std_logic_1164.all;

-- -- Work library (platform) ---------------------------------------------------

-- -- Work library (application) ------------------------------------------------

-- entity mgt_32bit_align is
   -- port
   -- (
      -- i_clk                       : in    std_logic;
      -- i_RXCHARISCOMMA             : in    std_logic_vector( 3 downto  0);
      -- i_RXCHARISK                 : in    std_logic_vector( 3 downto  0);
      -- i_RXDATA                    : in    std_logic_vector(31 downto  0);
      -- o_RXCHARISCOMMA             : out   std_logic_vector( 3 downto  0);
      -- o_RXCHARISK                 : out   std_logic_vector( 3 downto  0);
      -- o_RXDATA                    : out   std_logic_vector(31 downto  0)
   -- );
-- end mgt_32bit_align;

-- architecture behavioral of mgt_32bit_align is

   -- ---------------------------------------------------------------------------
   -- -- Signals
   -- ---------------------------------------------------------------------------
   -- signal   comma                 : std_logic_vector( 3 downto  0) := (others => '0');
   -- signal   rxchariscomma         : std_logic_vector( 3 downto  0) := (others => '0');
   -- signal   rxcharisk             : std_logic_vector( 3 downto  0) := (others => '0');
   -- signal   rxdata                : std_logic_vector(31 downto  0) := (others => '0');

-- begin

   -- process (i_clk)
   -- begin
      -- if rising_edge(i_clk) then
         -- if (i_RXCHARISCOMMA /= X"0") then
            -- comma                 <= i_RXCHARISCOMMA;
         -- end if;
         -- rxchariscomma            <= i_RXCHARISCOMMA;
         -- rxcharisk                <= i_RXCHARISK;
         -- rxdata                   <= i_RXDATA;
      -- end if;
   -- end process;

   -- o_RXCHARISCOMMA       <=                                 rxchariscomma( 3 downto  0) when (comma = X"1") else
                            -- i_RXCHARISCOMMA( 0          ) & rxchariscomma( 3 downto  1) when (comma = X"2") else
                            -- i_RXCHARISCOMMA( 1 downto  0) & rxchariscomma( 3 downto  2) when (comma = X"4") else
                            -- i_RXCHARISCOMMA( 2 downto  0) & rxchariscomma( 3          ) when (comma = X"8") else
                            -- i_RXCHARISCOMMA;            

   -- o_RXCHARISK           <=                             rxcharisk( 3 downto  0) when (comma = X"1") else
                            -- i_RXCHARISK( 0          ) & rxcharisk( 3 downto  1) when (comma = X"2") else
                            -- i_RXCHARISK( 1 downto  0) & rxcharisk( 3 downto  2) when (comma = X"4") else
                            -- i_RXCHARISK( 2 downto  0) & rxcharisk( 3          ) when (comma = X"8") else
                            -- i_RXCHARISK;            

   -- o_RXDATA              <=                          rxdata(31 downto  0) when (comma = X"1") else
                            -- i_RXDATA( 7 downto  0) & rxdata(31 downto  8) when (comma = X"2") else
                            -- i_RXDATA(15 downto  0) & rxdata(31 downto 16) when (comma = X"4") else
                            -- i_RXDATA(23 downto  0) & rxdata(31 downto 24) when (comma = X"8") else
                            -- i_RXDATA;

-- end behavioral;

------------------------------------------------------------------------------
-- Module mgt_32bit_fifo
------------------------------------------------------------------------------
-- Std. library (platform) ---------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

-- synopsys translate_off
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
-- synopsys translate_on

-- Work library (platform) ---------------------------------------------------

-- Work library (application) ------------------------------------------------
--use work.virtex5_gtx_package.all;

--Contains two 32+4 FIFO, 1K deep
--Idle transmission sequence is kBC,d00,kBC....
--Data written to TX FIFO is sent in 2 parts (lower 16 bits first)
--Data received from transceiver is reassembled in 32-bit (getting only lower 16bit), then written to RX FIFO
--***TODO*** add overflow monitor to RX FIFO (write when full)
entity mgt_32bit_fifo is
   port
   (
      -- CPU interface
      i_cpu_rst                   : in    std_logic; --reset TX FIFO
      i_cpu_clk                   : in    std_logic; --write clk for TX FIFO
      --TX
      i_cpu_tx_en                 : in    std_logic; --wren TX FIFO
      o_cpu_tx_full               : out   std_logic; --TX FIFO full
      i_cpu_tx_charisk            : in    std_logic_vector( 3 downto  0);
      i_cpu_tx_data               : in    std_logic_vector(31 downto  0);
      --RX
      o_cpu_rx_empty              : out   std_logic; --when 0, o_cpu_rx_data is valid
      o_cpu_rx_almost_empty       : out   std_logic; --14 left in RX FIFO
      i_cpu_rx_en                 : in    std_logic; --advance RX FIFO (FWFT)
      o_cpu_rx_charisk            : out   std_logic_vector( 3 downto  0);
      o_cpu_rx_data               : out   std_logic_vector(31 downto  0);
      -- MGT interface
      i_mgt_tx_clk                : in    std_logic; --read clk for TX FIFO
      o_mgt_tx_charisk            : out   std_logic_vector( 3 downto  0);
      o_mgt_tx_data               : out   std_logic_vector(31 downto  0);
			-- 
      i_mgt_rx_rst                : in    std_logic;
      i_mgt_rx_clk                : in    std_logic;
      i_mgt_rx_lossofsync         : in    std_logic;
      i_mgt_rx_chariscomma        : in    std_logic_vector( 3 downto  0);
      i_mgt_rx_charisk            : in    std_logic_vector( 3 downto  0);
      i_mgt_rxdata                : in    std_logic_vector(31 downto  0);
      -- Test interfaec
      o_tx_vld								    : out   std_logic; --Reading TX fifo (transmitting)
      o_rx_vld								    : out   std_logic  --receiving non-K characters from GTX    
   );                 
end mgt_32bit_fifo;

architecture structural of mgt_32bit_fifo is

   ---------------------------------------------------------------------------
   -- Signals
   ---------------------------------------------------------------------------
   signal   rx_vld                : std_logic := '0';
   -- MGT tx fifo interface
   signal   fifo_tx_empty         : std_logic := '0';
   signal   fifo_tx_empty_d       : std_logic := '0';
   signal   fifo_tx_rd_en         : std_logic := '0';
   signal   fifo_tx_charisk       : std_logic_vector( 3 downto  0) := (others => '0');
   signal   fifo_tx_data          : std_logic_vector(31 downto  0) := (others => '0');
   
   type     t_tx_fsm is (st_wait_for_word, st_read_word);
   signal   s_tx_fsm              : t_tx_fsm;
   -- MGT rx alignment interface
   signal   rx_align_chariscomma  : std_logic_vector( 3 downto  0) := (others => '0');
   signal   rx_align_charisk      : std_logic_vector( 3 downto  0) := (others => '0');
   signal   rx_align_data         : std_logic_vector(31 downto  0) := (others => '0');
   -- MGT rx fifo interface
   signal   fifo_rx_lossofsync    : std_logic_vector( 3 downto  0) := (others => '1');
   signal   fifo_rx_en            : std_logic := '0';
   signal   s_rx_data_32          : std_logic_vector(31 downto 0);
   signal   s_rx_data_16          : std_logic_vector(15 downto 0);
   signal   s_rx_charisk_4        : std_logic_vector( 3 downto 0); --ml84 added
   signal   s_rx_charisk_2        : std_logic_vector( 1 downto 0); --ml84 added
   signal   s_even_byte           : std_logic;
   ---------------------------------------------------------------------------
   -- Attributes
   ---------------------------------------------------------------------------
   attribute BOX_TYPE             : string;
   ---------------------------------------------------------------------------
   -- FIFO36
   ---------------------------------------------------------------------------
   component FIFO36
   generic
   (
      DATA_WIDTH                  : integer := 4;
      ALMOST_FULL_OFFSET          : bit_vector := X"0080";
      ALMOST_EMPTY_OFFSET         : bit_vector := X"0080";
      DO_REG                      : integer := 1;
      EN_SYN                      : boolean := FALSE;
      FIRST_WORD_FALL_THROUGH     : boolean := FALSE
--      SIM_MODE                    : string := "SAFE"
   );
   port
   (
      RST                         : in   std_ulogic;

      WRCLK                       : in    std_ulogic;
      FULL                        : out   std_ulogic;
      ALMOSTFULL                  : out   std_ulogic;
      WREN                        : in    std_ulogic;
      WRCOUNT                     : out   std_logic_vector(12 downto  0);
      WRERR                       : out   std_ulogic;
      DIP                         : in    std_logic_vector( 3 downto  0);
      DI                          : in    std_logic_vector(31 downto  0);

      RDCLK                       : in    std_ulogic;
      EMPTY                       : out   std_ulogic;
      ALMOSTEMPTY                 : out   std_ulogic;
      RDEN                        : in    std_ulogic;
      RDCOUNT                     : out   std_logic_vector(12 downto  0);
      RDERR                       : out   std_ulogic;
      DOP                         : out   std_logic_vector( 3 downto  0);
      DO                          : out   std_logic_vector(31 downto  0)
   );
   end component;

   attribute BOX_TYPE of FIFO36 : component is "PRIMITIVE";

begin

   ---------------------------------------------------------------------------
   -- Tx fifo interface
   ---------------------------------------------------------------------------
   mgt_wr_fifo36_inst: FIFO36
   generic map
   (
      DATA_WIDTH                  => 36, --36 bit width
      ALMOST_FULL_OFFSET          => X"010", --almost full when FIFO contains less than 16 free location
      ALMOST_EMPTY_OFFSET         => X"010", --almost empty when FIFO contains less than 16 values
      DO_REG                      => 1, --enable data pipeline register
      EN_SYN                      => FALSE, --no multirate
      FIRST_WORD_FALL_THROUGH     => TRUE 
   )
   port map
   (
      RST                         => i_cpu_rst,

      WRCLK                       => i_cpu_clk,
      FULL                        => o_cpu_tx_full,
      ALMOSTFULL                  => open,
      WREN                        => i_cpu_tx_en,
      WRCOUNT                     => open,
      WRERR                       => open,
      DIP                         => i_cpu_tx_charisk,
      DI                          => i_cpu_tx_data,

      RDCLK                       => i_mgt_tx_clk,
      EMPTY                       => fifo_tx_empty,
      ALMOSTEMPTY                 => open,
      RDEN                        => fifo_tx_rd_en,
      RDCOUNT                     => open,
      RDERR                       => open,
      DOP                         => fifo_tx_charisk,
      DO                          => fifo_tx_data
   );

   --fifo_tx_rd_en                  <= not fifo_tx_empty;

   -- fifo_tx_empty_d_proc: process(i_mgt_tx_clk) is
   -- begin
      -- if rising_edge(i_mgt_tx_clk) then
         -- fifo_tx_empty_d          <= fifo_tx_empty;
      -- end if;
   -- end process fifo_tx_empty_d_proc;

   -- o_mgt_tx_charisk               <= fifo_tx_charisk when (fifo_tx_empty_d = '0') else X"5";
   -- o_mgt_tx_data                  <= fifo_tx_data    when (fifo_tx_empty_d = '0') else X"00BC00BC";

  --tx process
  --check TX fifo. When not empty (TX data available) send lower 16 bits of data
  prc_32fifo_to_16tx : process ( i_mgt_tx_clk )
  begin
    if rising_edge( i_mgt_tx_clk ) then
--      if fifo_tx_empty_d = '0' then
        case s_tx_fsm is 
          when st_wait_for_word =>
            fifo_tx_rd_en       <= '0';
            o_mgt_tx_charisk    <= X"1";
            o_mgt_tx_data       <= X"000000BC";
            if fifo_tx_empty = '0' then --send lower 16 bits and read the word from FIFO
              fifo_tx_rd_en       <= '1';
              o_mgt_tx_charisk  <= "00" & fifo_tx_charisk(1 downto 0);
              o_mgt_tx_data     <= X"0000" & fifo_tx_data(15 downto 0);
              s_tx_fsm          <= st_read_word;
            end if;
          when st_read_word => --send higher 16 bits 
            fifo_tx_rd_en       <= '0';
            o_mgt_tx_charisk    <= "00" & fifo_tx_charisk(3 downto 2);
            o_mgt_tx_data       <= X"0000" & fifo_tx_data(31 downto 16);
            s_tx_fsm            <= st_wait_for_word;
          when others =>
            s_tx_fsm            <= st_wait_for_word;
        end case;
--      end if;
    end if;
  end process ;
   
  o_tx_vld	<=  fifo_tx_rd_en;
  
  ----------------------------------------------------------------------------------------------------
  -- RX FIFO -----------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------
  
  rx_align_chariscomma  <= i_mgt_rx_chariscomma;
  rx_align_charisk      <= i_mgt_rx_charisk;
  rx_align_data         <= i_mgt_rxdata;
  
  --notify valid data whenever received sequence is different from (D00.0,K28.5)
  rx_vld    <= '0' when rx_align_charisk(1 downto 0) = "01" and rx_align_data(15 downto 0) = X"00BC"
               else '1';
  o_rx_vld	<= rx_vld; 

  --sample every two DATA bytes from GTX and store in s_rx_data_16 (lower). Reset on loss of sync
  prc_16b_2_32bit_data : process(i_mgt_rx_clk) is 
  begin
    if rising_edge( i_mgt_rx_clk ) then
        if i_mgt_rx_lossofsync = '1' or i_mgt_rx_rst = '1' then
            s_even_byte <= '0';
        else
            if rx_vld = '1' then
                s_rx_data_16   <= rx_align_data(15 downto 0);
                s_rx_charisk_2 <= rx_align_charisk(1 downto 0); --ml84 added
                if s_even_byte = '0' then
                    s_even_byte <= '1';
                else
                    s_even_byte <= '0';
                end if;
            else
                s_even_byte <= '0';
            end if;
        end if;
    end if;
  end process;

  s_rx_data_32    <= rx_align_data(15 downto 0)   & s_rx_data_16; --build data word 
  s_rx_charisk_4  <= rx_align_charisk(1 downto 0) & s_rx_charisk_2; --ml84 added: build charisk 
  fifo_rx_en      <= s_even_byte when i_mgt_rx_lossofsync = '0' else '0'; --write to FIFO

   mgt_rd_fifo36_inst: FIFO36
   generic map
   (
      DATA_WIDTH                  => 36,
      ALMOST_FULL_OFFSET          => X"010",
      ALMOST_EMPTY_OFFSET         => X"00E",
      DO_REG                      => 1,
      EN_SYN                      => FALSE,
      FIRST_WORD_FALL_THROUGH     => TRUE
   )
   port map
   (
      RST                         => i_mgt_rx_rst,

      WRCLK                       => i_mgt_rx_clk,
      FULL                        => open,
      ALMOSTFULL                  => open,
      WREN                        => fifo_rx_en,
      WRCOUNT                     => open,
      WRERR                       => open,
      DIP                         => s_rx_charisk_4, --rx_align_charisk, --ml84
      DI                          => s_rx_data_32,

      RDCLK                       => i_cpu_clk,
      EMPTY                       => o_cpu_rx_empty,
      ALMOSTEMPTY                 => o_cpu_rx_almost_empty,
      RDEN                        => i_cpu_rx_en,
      RDCOUNT                     => open,
      RDERR                       => open,
      DOP                         => o_cpu_rx_charisk,
      DO                          => o_cpu_rx_data
   );

   
end structural;

------------------------------------------------------------------------------
-- End of file
------------------------------------------------------------------------------
