------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
------------------------------------------------------------------------------
-- Unit    : ibfb_comm_package.vhd
-- Author  : Alessandro Malatesta, Section Diagnostic
-- Version : $Revision: 1.5 $
--         : $Revision: 1.5 $
------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
------------------------------------------------------------------------------
-- Comment : This package contains the components used to implement the 
--           communication protocol in the IBFB subsystem.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.virtex5_gtx_package.all;

package ibfb_comm_package is

    constant BPM_BITS : natural := 2; --number of used BPMs will be 2**BPM_BITS
    type bpm_id_t is array (0 to 2**BPM_BITS-1) of std_logic_vector(7 downto 0);
    type array3  is array (natural range <>) of std_logic_vector(2 downto 0);
    type array4  is array (natural range <>) of std_logic_vector(3 downto 0);
    type array8  is array (natural range <>) of std_logic_vector(7 downto 0);
    type array16 is array (natural range <>) of std_logic_vector(15 downto 0);
    type array32 is array (natural range <>) of std_logic_vector(31 downto 0);


    --Record that contains all the fields in the IBFB packet
    --Packet TX/RX sequence:
    -- D.00 K.SOP | D.CTRL D.BPM | D.BK0 D.BK1 | 4x(D.XPOS) | 4x(D.YPOS) | D.CRC K.EOP
    type ibfb_comm_packet is record
        ctrl   : std_logic_vector( 7 downto 0);
        bpm    : std_logic_vector( 7 downto 0);
        bucket : std_logic_vector(15 downto 0);
        xpos   : std_logic_vector(31 downto 0);
        ypos   : std_logic_vector(31 downto 0);
        crc    : std_logic_vector( 7 downto 0);
    end record ibfb_comm_packet;

    -- KW84, 08.08.2016, filter statistics
    type ibfb_comm_filter_statistics is record
        packets_chan0_in    : std_logic_vector(15 downto 0);
        packets_chan1_in    : std_logic_vector(15 downto 0);
        packets_discarded_x : std_logic_vector(15 downto 0);
        packets_discarded_y : std_logic_vector(15 downto 0);
        wrong_bpm_id_x      : std_logic_vector( 7 downto 0);
        wrong_bpm_id_y      : std_logic_vector( 7 downto 0);
        packets_passed_x    : std_logic_vector(15 downto 0);
        packets_passed_y    : std_logic_vector(15 downto 0);
    end record ibfb_comm_filter_statistics;

    type t_qdr2_single_out is record
        qdr2_trg    : std_logic;
        qdr2_we     : std_logic;
        qdr2_data0  : std_logic_vector(35 downto 0);
        qdr2_data1  : std_logic_vector(35 downto 0);
        qdr2_data2  : std_logic_vector(35 downto 0);
        qdr2_data3  : std_logic_vector(35 downto 0);
    end record t_qdr2_single_out;
    
    --Format data into a packet and write it to MGT FIFO
    --Packet data is provided as a set of separate fields.
    --Transmitted packet format is as follows (32-bit dwords):
    --dword0: 0x00       | K(SOP)     | CTRL     | BPM 
    --dword1: bucket(B0) | bucket(B1) | XPOS(B0) | XPOS(B1) 
    --dword2: XPOS(B2)   | XPOS(B3)   | YPOS(B0) | YPOS(B1)
    --dword3: YPOS(B2)   | YPOS(B3)   | CRC      | K(EOP)
    --
    --USAGE
    --When busy = 0, assert tx_valid and tx_data. If busy = 1, input data won't be sampled. 
    --If next tx_valid/tx_data are asserted as soon as busy becomes '0' again, then
    -- writes to FIFO are performed without pause.
    --If EXTERNAL_CRC = 1, the CRC input field will be transmitted. Otherwise the CRC will be
    -- calculated internally (CRC8 on 32bit data), and the input field ignored.
    component ibfb_packet_tx is
    generic(
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0);
        EXTERNAL_CRC : std_logic := '0'
    );
    port(
        i_rst       : in  std_logic;
        i_clk       : in  std_logic;
        --user interface
        o_sample    : out std_logic; --'1' when sampling inputs (used for back to back transfers)
        o_busy      : out std_logic;
        i_tx_valid  : in  std_logic;
        i_tx_data   : in  ibfb_comm_packet; --tx data (packet fields)
        --MGT FIFO interface
        i_fifo_full : in  std_logic;
        o_valid     : out std_logic;
        o_charisk   : out std_logic_vector(3 downto 0);
        o_data      : out std_logic_vector(31 downto 0)
     );
    end component ibfb_packet_tx;

    --Reads packet from MGT FIFO and unpacks single data fields
    --Received format shall be as follows (32-bit dwords):
    --dword0: 0x00       | K(SOP)     | CTRL     | BPM 
    --dword1: bucket(B0) | bucket(B1) | XPOS(B0) | XPOS(B1) 
    --dword2: XPOS(B2)   | XPOS(B3)   | YPOS(B0) | YPOS(B1)
    --dword3: YPOS(B2)   | YPOS(B3)   | CRC      | K(EOP)
    --
    --USAGE
    --As soon as available, data is read from FIFO and processed.
    --If data is not compliant with the input format, it will be discarded.
    --A discarded data word from FIFO is signalled with o_bad_data = '1'.
    --o_rx_data is valid whenever o_eop = '1'.
    --o_crc_good is valid whenever o_eop = '1' and provides the outcome of the 
    --internal CRC check (expecting CRC8 calculated on 32bit words, see ibfb_packet_tx).
    component ibfb_packet_rx is
    generic(
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0)
    );
    port(
        i_rst : in std_logic;
        i_clk : in std_logic;
        --MGT FIFO interface
        o_next      : out std_logic;
        i_valid     : in  std_logic;
        i_charisk   : in  std_logic_vector(3 downto 0);
        i_data      : in  std_logic_vector(31 downto 0);
        --user interface
        o_bad_data : out std_logic; 
        o_eop      : out std_logic;
        o_crc_good : out std_logic;
        o_rx_data  : out ibfb_comm_packet; --tx data (packet fields)
        --debug
        o_csp_clk   : out std_logic;
        o_csp_data  : out std_logic_vector(63 downto 0)        
     );
    end component ibfb_packet_rx;

    --This module is only for test purposes.
    --o_bad_data counts the number of clock cycles the input i_bad_data is sampled high
    --o_pkt_cnt counts the number of clock cycles the input i_valid is sampled high (number of received packets)
    --o_bad_pkt_cnt counts the number of received packets for which i_crc_good is low (bad packets)
    --i_reset_cnt resets all the counters (level-sensitive)
    component ibfb_rx_packet_stat is
    port(
        i_rst : in std_logic;
        i_clk : in std_logic;
        --packet interface
        i_bad_data : in  std_logic; 
        i_valid    : in  std_logic;
        i_crc_good : in  std_logic;
        --i_rx_data  : in  ibfb_comm_packet; --rx data (packet fields)
        --Stats
        i_reset_cnt    : in  std_logic;
        -- KW84, 17.08.2016 - Reset packet counter by trigger
        i_trg          : in  std_logic;
        o_bad_data_cnt : out std_logic_vector(31 downto 0);
        o_pkt_cnt      : out std_logic_vector(31 downto 0);
        o_bad_pkt_cnt  : out std_logic_vector(31 downto 0)
     );
    end component ibfb_rx_packet_stat;

    --Filters packets incoming from 2 MGT-FIFOs
    --Packets are read round robin from the two FIFOs.
    --If a valid packet is received, its BPM field is checked: if a packet with the same BPM field value has already been received,
    --then the packet is marked as bad (ie: the K_EOP symbol is replaced with K_BAD) and o_pkt_discard goes high for 1 clock cycle.
    --If no packets with the same BPM value have been received, the packet is forwarded as-is and o_pkt_pass goes high for 1 clock cycle.
    --Rising edge of the i_trig input resets the history of already received packets.
    --No backpressure mechanism is provided for the output: if o_output_valid = '1' and the output data is not sampled, that data is lost.
    component ibfb_packet_filter is
    generic(
        --protocol
        K_SOP : std_logic_vector(7 downto 0); --start of packet
        K_EOP : std_logic_vector(7 downto 0); --end of packet
        K_BAD : std_logic_vector(7 downto 0)  --EOP if replaced by this character for discarded packets
    );
    port(
        --debug
        o_flag_ram_wen   : out std_logic_vector(2**BPM_BITS-1 downto 0);
        o_flag_ram_waddr : out std_logic_vector(11 downto 0);
        o_flag_ram_wdata : out std_logic;
        --setup
        i_bpm_id         : in  bpm_id_t; --allowed BPM ids (0,1 => X, 2,3 => Y)
        i_bkt_min        : in  std_logic_vector(15 downto 0); --lowest bucket accepted
        i_bkt_max        : in  std_logic_vector(15 downto 0); --highest bucket accepted
        --PING
        i_ping_enable0   : in  std_logic; --enable sending of ping packets (channel 0)
        i_ping_enable1   : in  std_logic; --enable sending of ping packets (channel 1)
        o_ping_rx0       : out std_logic; --ping receved from channel 0 during last train
        o_ping_rx1       : out std_logic; --ping receved from channel 1 during last train
        o_ping_latency0  : out std_logic_vector(31 downto 0); --latency of ping packet during last train (valid if o_ping_rx0=1)
        o_ping_latency1  : out std_logic_vector(31 downto 0); --latency of ping packet during last train (valid if o_ping_rx1=1)
        i_ram_clk        : in  std_logic;
        i_ram_raddr      : in  std_logic_vector(11 downto 0); --sized to address 2700 buckets
        o_ram_rdata      : out std_logic_vector(2**BPM_BITS-1 downto 0);
        --
        i_clk            : in  std_logic;
        i_rst            : in  std_logic;
        i_trig           : in  std_logic; --reset RX flags (takes 4096 clock cycles, during which o_resetting stays high)
        o_resetting      : out std_logic; --when high, core is resetting RAMs that store flags. No incoming data will be processed. Duration 4096 clock cycles.
        o_pkt_valid      : out std_logic; --detected EOP on currently active input channel.
        o_pkt_discard_x    : out std_logic; --to be sampled when o_pkt_valid is high: notifies filtered packet (K_EOP replaced with K_BAD)
        o_pkt_discard_y    : out std_logic; --to be sampled when o_pkt_valid is high: notifies filtered packet (K_EOP replaced with K_BAD)
        --Input channel 0 (RXFIFO 0, FWFT)
        o_rxfifo_next0    : out std_logic;
        i_rxfifo_empty0   : in  std_logic;
        i_rxfifo_charisk0 : in  std_logic_vector(3 downto 0);
        i_rxfifo_data0    : in  std_logic_vector(31 downto 0);
        --Input channel 1 (RXFIFO 1, FWFT)
        o_rxfifo_next1    : out std_logic;
        i_rxfifo_empty1   : in  std_logic;
        i_rxfifo_charisk1 : in  std_logic_vector(3 downto 0);
        i_rxfifo_data1    : in  std_logic_vector(31 downto 0);
        --Output SFP channel 0 (TXFIFO 0) PING TRANSMISSION
        i_txfifo_full0    : in  std_logic;
        o_txfifo_write0   : out std_logic;
        o_txfifo_charisk0 : out std_logic_vector(3 downto 0);
        o_txfifo_data0    : out std_logic_vector(31 downto 0);
        --Output SFP channel 1 (TXFIFO 1) PING TRANSMISSION
        i_txfifo_full1    : in  std_logic;
        o_txfifo_write1   : out std_logic;
        o_txfifo_charisk1 : out std_logic_vector(3 downto 0);
        o_txfifo_data1    : out std_logic_vector(31 downto 0);
        --Output channel (FIFO interface, FWFT)
        i_output_next_x     : in  std_logic; --backpressure
        o_output_valid_x    : out std_logic;
        o_output_charisk_x  : out std_logic_vector(3 downto 0);
        o_output_data_x     : out std_logic_vector(31 downto 0);
        i_output_next_y     : in  std_logic; --backpressure
        o_output_valid_y    : out std_logic;
        o_output_charisk_y  : out std_logic_vector(3 downto 0);
        o_output_data_y     : out std_logic_vector(31 downto 0);
        --ML84, added QDR2 interface (logging)
        o_qdr2_out          : out t_qdr2_single_out;
        --KW84, 08.08.2016
        o_statistics      : out ibfb_comm_filter_statistics
    );
    end component ibfb_packet_filter;

    --This component gets input data from a FIFO.
    --Data is read whenever available and stored. If data is not valid (no SOP/EOP when expected), data is discarded.
    --Whenever a valid packet is in the buffer, the component waits until the packet is read from the output port.
    --The core can be used also to discard packets marked as bad. To mark a packet as bad, just replace K_EOP with some other symbol.
    component ibfb_packet_buffer is
    generic(
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0)
    );
    port(
        i_clk            : in  std_logic;
        i_rst            : in  std_logic;
        --input
        o_next    : out std_logic;
        i_valid   : in  std_logic;
        i_charisk : in  std_logic_vector( 3 downto 0);
        i_data    : in  std_logic_vector(31 downto 0);
        --output
        i_next    : in  std_logic;
        o_valid   : out std_logic;
        o_charisk : out std_logic_vector( 3 downto 0);
        o_data    : out std_logic_vector(31 downto 0)
    );
    end component ibfb_packet_buffer;

    --Reads round robin for the input channels (number of channels selected via generic), 
    --discards bad data (including packets whose K_EOP character has been replaced),
    --and sends the data on all the ouput channels simultaneously.
    component ibfb_packet_router is
    generic(
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0);
        N_INPUT_PORTS  : natural range 1 to 32 := 2;
        N_OUTPUT_PORTS : natural range 1 to 32 := 1 
    );
    port(
        i_clk     : in  std_logic;
        i_rst     : in  std_logic;
        i_err_rst : in  std_logic; --not used
        i_routing_table : in array32(0 to N_INPUT_PORTS-1);
        --input (FIFO, FWFT)
        o_next    : out std_logic_vector(0 to N_INPUT_PORTS-1);
        i_valid   : in  std_logic_vector(0 to N_INPUT_PORTS-1);
        i_charisk : in  array4(0 to N_INPUT_PORTS-1);
        i_data    : in  array32(0 to N_INPUT_PORTS-1);
        --output (STREAMING. i_next is used only to detect errors, but does not control data flow)
        i_out_en  : in  std_logic_vector(0 to N_OUTPUT_PORTS-1); --disabled (use routing table instead)
        i_next    : in  std_logic_vector(0 to N_OUTPUT_PORTS-1);
        o_valid   : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
        o_err     : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
        o_charisk : out array4(0 to N_OUTPUT_PORTS-1);
        o_data    : out array32(0 to N_OUTPUT_PORTS-1)
    );
    end component ibfb_packet_router;

    --This component contains a GTX tile connected to TX and RX fifos.
    --The RX FIFOs are connected to ibfb_packet_rx instances.
    --The TX FIFOs are connected to ibfb_packet_tx instances.
    component ibfb_gtx_tile is
    generic(
        --protocol
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0);
        --mgt
        G_GTX_REFCLK_SEL       : std_logic;
        G_GTX_TILE_REFCLK_FREQ : integer := 125; --MHz 
        G_GTX_BAUD_RATE        : integer := 2500000 --Kbps
    );
    port(
        --DEBUG
        o_DBG_x0 : out std_logic;
        o_DBG_v0 : out std_logic;
        o_DBG_k0 : out std_logic_vector(3 downto 0);
        o_DBG_d0 : out std_logic_vector(31 downto 0);
        o_DBG_x1 : out std_logic;
        o_DBG_v1 : out std_logic;
        o_DBG_k1 : out std_logic_vector(3 downto 0);
        o_DBG_d1 : out std_logic_vector(31 downto 0);
        --debug
        o_csp_clk   : out std_logic;
        o_csp_data  : out std_logic_vector(63 downto 0);    
        --MGT
        I_GTX_REFCLK1_IN : in  std_logic;
        I_GTX_REFCLK2_IN : in  std_logic;
        I_GTX_RX_N       : in  std_logic_vector(1 downto 0);
        I_GTX_RX_P       : in  std_logic_vector(1 downto 0);
        O_GTX_TX_N       : out std_logic_vector(1 downto 0);
        O_GTX_TX_P       : out std_logic_vector(1 downto 0);
        --
        i_loopback0      : in  std_logic_vector(2 downto 0);
        i_loopback1      : in  std_logic_vector(2 downto 0);
        o_mgt            : out mgt_out_type;
        --user
        i_clk            : in  std_logic;
        i_rst            : in  std_logic;
        --Channel 0 ----------------------------------------------------------------------------------------
        --TX interface
        o_tx_busy0       : out std_logic; --assert valid/data only when this bit is low
        i_tx_valid0      : in  std_logic; --assert to send tx_data through MGT
        i_tx_data0       : in  ibfb_comm_packet; --tx data 
        --RX interface
        o_rx_bad_data0   : out std_logic; --received data non compliant with protocol (misalignment/error)
        o_rx_valid0      : out std_logic; --rx_data valid
        o_rx_crc_good0   : out std_logic; --rx packet had correct crc (sample when valid = '1')
        o_rx_data0       : out ibfb_comm_packet; --rx data (sample when valid = '1')
        --Channel 1 ----------------------------------------------------------------------------------------
        --TX interface
        o_tx_busy1       : out std_logic; --assert valid/data only when this bit is low
        i_tx_valid1      : in  std_logic; --assert to send tx_data through MGT
        i_tx_data1       : in  ibfb_comm_packet; --tx data 
        --RX interface
        o_rx_bad_data1   : out std_logic; --received data non compliant with protocol (misalignment/error)
        o_rx_valid1      : out std_logic; --rx_data valid
        o_rx_crc_good1   : out std_logic; --rx packet had correct crc (sample when valid = '1')
        o_rx_data1       : out ibfb_comm_packet --rx data (sample when valid = '1')
    );
    end component ibfb_gtx_tile;

    --Format data into a packet and write it to MGT FIFO
    --Packet data is provided as a set of separate fields.
    --Transmitted packet format is as follows (32-bit dwords):
    --dword0: 0x00       | K(SOP)     | SPARE    | SPARE
    --dword1: SPARE      | SPARE      | MON0(B0) | MON0(B1) 
    --dword2: MON1(B0)   | MON1(B1)   | MON2(B0) | MON2(B1)
    --dword3: MON3(B0)   | MON3(B1)   | CRC      | K(EOP)
    --
    --USAGE
    --When busy = 0, assert tx_valid and tx_data. If busy = 1, input data won't be sampled. 
    --If next tx_valid/tx_data are asserted as soon as busy becomes '0' again, then
    -- writes to FIFO are performed without pause.
    --Te CRC will be calculated internally (CRC8 on 32bit data).
    component ibfb_mon_packet_tx is
    generic(
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0)
    );
    port(
        i_rst       : in  std_logic;
        i_clk       : in  std_logic;
        o_status    : out std_logic_vector(2 downto 0);
        --user interface
        o_sample    : out std_logic; --'1' when sampling inputs (used for back to back transfers)
        o_busy      : out std_logic;
        i_tx_valid  : in  std_logic;
        i_bkt_id    : in  std_logic_vector(15 downto 0);
        i_mon_0     : in  std_logic_vector(15 downto 0);
        i_mon_1     : in  std_logic_vector(15 downto 0);
        i_mon_2     : in  std_logic_vector(15 downto 0);
        i_mon_3     : in  std_logic_vector(15 downto 0);
        --MGT FIFO interface
        i_fifo_full : in  std_logic;
        o_valid     : out std_logic;
        o_charisk   : out std_logic_vector(3 downto 0);
        o_data      : out std_logic_vector(31 downto 0)
     );
    end component ibfb_mon_packet_tx;

    --Reads packet from MGT FIFO and unpacks single data fields
    --Received format shall be as follows (32-bit dwords):
    --dword0: 0x00       | K(SOP)     | SPARE    | SPARE
    --dword1: SPARE      | SPARE      | MON0(B0) | MON0(B1) 
    --dword2: MON1(B0)   | MON1(B1)   | MON2(B0) | MON2(B1)
    --dword3: MON3(B0)   | MON3(B1)   | CRC      | K(EOP)
    --
    --USAGE
    --As soon as available, data is read from FIFO and processed.
    --If data is not compliant with the input format, it will be discarded.
    --A discarded data word from FIFO is signalled with o_bad_data = '1'.
    --o_rx_data is valid whenever o_eop = '1'.
    --o_crc_good is valid whenever o_eop = '1' and provides the outcome of the 
    --internal CRC check (expecting CRC8 calculated on 32bit words, see ibfb_packet_tx).
    component ibfb_mon_packet_rx is
    generic(
        K_SOP : std_logic_vector(7 downto 0);
        K_EOP : std_logic_vector(7 downto 0)
    );
    port(
        i_rst : in std_logic;
        i_clk : in std_logic;
        --MGT FIFO interface
        o_next      : out std_logic;
        i_valid     : in  std_logic;
        i_charisk   : in  std_logic_vector(3 downto 0);
        i_data      : in  std_logic_vector(31 downto 0);
        --user interface
        o_bad_data : out std_logic; 
        o_eop      : out std_logic;
        o_crc_good : out std_logic;
        o_bkt_id   : out std_logic_vector(15 downto 0);
        o_data_0   : out std_logic_vector(15 downto 0);
        o_data_1   : out std_logic_vector(15 downto 0);
        o_data_2   : out std_logic_vector(15 downto 0);
        o_data_3   : out std_logic_vector(15 downto 0);
        --debug
        o_csp_clk   : out std_logic;
        o_csp_data  : out std_logic_vector(63 downto 0)        
     );
    end component ibfb_mon_packet_rx;

end package;

--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ibfb_comm_package.ibfb_comm_packet;
use work.pkg_crc.all;

--Format data into a packet and write it to MGT FIFO
--Packet format is as follows (32-bit dwords):
--dword0: 0x00       | K(SOP)     | CTRL     | BPM 
--dword1: bucket(B0) | bucket(B1) | XPOS(B0) | XPOS(B1) 
--dword2: XPOS(B2)   | xpos(B3)   | ypos(B0) | ypos(B1)
--dword3: ypos(B2)   | ypos(B3)   | CRC      | K(EOP)
--
--USAGE
--When busy = 0, assert tx_valid and tx_data. Deassert tx_valid only when busy = 1.
--If next tx_valid/tx_data are asserted as soon as busy becomes '0' again, then
-- writes to FIFO are performed without pause.
entity ibfb_packet_tx is
generic(
    K_SOP : std_logic_vector(7 downto 0); --start of packet k-character
    K_EOP : std_logic_vector(7 downto 0); --end of packet k-character
    EXTERNAL_CRC : std_logic := '0'       --enable internal CRC calulation (if 0, then input CRC value is used)
);
port(
    i_rst       : in  std_logic;
    i_clk       : in  std_logic;
    --user interface
    o_sample    : out std_logic; --'1' when sampling inputs
    o_busy      : out std_logic; --inputs not sampled when busy = '1'
    i_tx_valid  : in  std_logic; --when asserted and busy = '0', then i_tx_data is sampled and transmitted
    i_tx_data   : in  ibfb_comm_packet; --tx data (packet fields)
    --MGT FIFO interface
    i_fifo_full : in  std_logic; 
    o_valid     : out std_logic; --connect to FIFO write-enable
    o_charisk   : out std_logic_vector(3 downto 0);
    o_data      : out std_logic_vector(31 downto 0)
 );
end entity ibfb_packet_tx;

architecture rtl of ibfb_packet_tx is

signal start_r, valid, valid_r, crc_rst : std_logic;
signal s         : unsigned(2 downto 0);
signal b0, b1, x0, x1, x2, x3, y0, y1, y2, y3, crc_out, checksum : std_logic_vector(7 downto 0);
signal ocharisk, ocharisk_r : std_logic_vector(3 downto 0);
signal odata, odata_r : std_logic_vector(31 downto 0);

begin

--name data bytes
REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_tx_valid = '1' and s = "000" then
            b0 <= std_logic_vector(i_tx_data.bucket( 7 downto  0));
            b1 <= std_logic_vector(i_tx_data.bucket(15 downto  8));
            x0 <= std_logic_vector(i_tx_data.xpos( 7 downto  0));
            x1 <= std_logic_vector(i_tx_data.xpos(15 downto  8));
            x2 <= std_logic_vector(i_tx_data.xpos(23 downto 16));
            x3 <= std_logic_vector(i_tx_data.xpos(31 downto 24));
            y0 <= std_logic_vector(i_tx_data.ypos( 7 downto  0));
            y1 <= std_logic_vector(i_tx_data.ypos(15 downto  8));
            y2 <= std_logic_vector(i_tx_data.ypos(23 downto 16));
            y3 <= std_logic_vector(i_tx_data.ypos(31 downto 24));
        end if;
    end if;
end process;

o_sample <= '1' when s = "000" and i_tx_valid = '1' and i_fifo_full = '0' else '0';
o_busy   <= valid or valid_r; --'0' when (s = "000") and i_fifo_full = '0' else '1';

--TX process
TX_P : process(i_clk)
begin   
    if rising_edge(i_clk) then
        if i_rst = '1' then
            s <= (others => '1');
        else
            case s is
                when "000" => --send SOP, CTRL, BPM
                    if i_tx_valid = '1' and i_fifo_full = '0' then
                        valid   <= '1';
                        ocharisk <= "0100";
                        odata    <= X"00" & K_SOP & i_tx_data.ctrl & i_tx_data.bpm;
                        s         <= s+1;
                    else
                        valid     <= '0';
                    end if;
                when "001" => --send bucket, xpos MSBs
                    if i_fifo_full = '0' then
                        valid     <= '1';
                        ocharisk <= "0000";
                        odata    <= b0 & b1 & x0 & x1;
                        s         <= s+1;
                    end if;
                when "010" => --send xpos MSBs, ypos LSBs
                    if i_fifo_full = '0' then
                        valid     <= '1';
                        ocharisk <= "0000";
                        odata    <= x2 & x3 & y0 & y1;
                        s         <= s+1;
                    end if;
                when "011" => --send ypos MSBs, Checksum, EOP 
                    if i_fifo_full = '0' then
                        valid     <= '1';
                        ocharisk <= "0001";
                        odata    <= y2 & y3 & X"00" & K_EOP;
                        s <= s+1;
                    end if;
                when "100" =>
                    valid <= '0';
                    s     <= "000";
                when others => --reset state
                    s        <= (others => '0');
                    valid    <= '0';
            end case;
        end if;
    end if;
end process;

crc_rst <= not valid;

CRC_CALC_I : crc8_in32
port map( 
    data_in => odata,
    crc_en  => valid,
    rst     => crc_rst,
    clk     => i_clk,
    crc_out => crc_out
);

OUTPUT_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        valid_r    <= valid;
        odata_r    <= odata;
        ocharisk_r <= ocharisk;
    end if;
end process;

checksum <= crc_out when EXTERNAL_CRC = '0' else
            i_tx_data.crc;

o_valid <= valid_r and not i_fifo_full;
o_charisk <= ocharisk_r;
o_data(31 downto 16) <= odata_r(31 downto 16);
o_data(15 downto  8) <= checksum when s = "000" else
                        odata_r(15 downto  8);
o_data( 7 downto  0) <= odata_r( 7 downto  0);

end architecture rtl;

--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ibfb_comm_package.ibfb_comm_packet;
use work.pkg_crc.all;

--Reads packet from MGT FIFO and unpacks single data fields
--Packet format is as follows (32-bit dwords):
--dword0: 0x00       | K(SOP)     | CTRL     | BPM 
--dword1: bucket(B0) | bucket(B1) | XPOS(B0) | XPOS(B1) 
--dword2: XPOS(B2)   | xpos(B3)   | ypos(B0) | ypos(B1)
--dword3: ypos(B2)   | ypos(B3)   | CRC      | K(EOP)
--
--USAGE
--When busy = 0, assert tx_valid and tx_data. Deassert tx_valid only when busy = 1.
--If next tx_valid/tx_data are asserted as soon as busy becomes '0' again, then
-- writes to FIFO are performed without pause.
entity ibfb_packet_rx is
generic(
    K_SOP : std_logic_vector(7 downto 0);
    K_EOP : std_logic_vector(7 downto 0)
);
port(
    i_rst : in std_logic;
    i_clk : in std_logic;
    --user interface
    --add CRC check?
    o_bad_data : out std_logic; 
    o_eop      : out std_logic;
    o_crc_good : out std_logic;
    o_rx_data  : out ibfb_comm_packet; --tx data (packet fields)
    --MGT FIFO interface
    o_next      : out std_logic;
    i_valid     : in  std_logic;
    i_charisk   : in  std_logic_vector(3 downto 0);
    i_data      : in  std_logic_vector(31 downto 0);
    --debug
    o_csp_clk   : out std_logic;
    o_csp_data  : out std_logic_vector(63 downto 0)
);
end entity ibfb_packet_rx;

architecture rtl of ibfb_packet_rx is

signal s    : unsigned(3 downto 0);
signal csum : unsigned(7 downto 0);
signal sop, eop, oeop : std_logic;
signal b0, b1, b2, b3 : std_logic_vector(7 downto 0);

signal crc_valid, crc_rst : std_logic;
signal crc_in : std_logic_vector(31 downto 0);
signal crc_rx, crc_out : std_logic_vector(7 downto 0);

begin

o_csp_clk <= i_clk;
o_csp_data(0)            <= oeop;
o_csp_data(1)            <= crc_valid;
o_csp_data(2)            <= crc_rst;
o_csp_data(3)            <= sop;
o_csp_data(4)            <= eop;
o_csp_data(5)            <= i_valid;
o_csp_data(15 downto  8) <= crc_out;
o_csp_data(23 downto 16) <= crc_rx;
o_csp_data(27 downto 24) <= std_logic_vector(s);
o_csp_data(63 downto 32) <= i_data;


b0 <= i_data( 7 downto  0);
b1 <= i_data(15 downto  8);
b2 <= i_data(23 downto 16);
b3 <= i_data(31 downto 24);

--start of packet: data valid and upper 2 bytes = D.00, K.SOP
sop <= '1' when (i_charisk(3 downto 2) = "01") and 
                (b3 = X"00")                   and 
                (b2 = K_SOP)                   
           else '0';

--end of packet: lowest byte = K.EOP
eop <= '1' when (i_charisk(0) = '1') and
                (b0 = K_EOP) 
           else '0';

--advance the FIFO as soon as data becomes available
o_next <= i_valid when i_rst = '0' and (s /= X"4") else '0';

--signal when an expectied SOP/EOP is missing
o_bad_data <= '1' when ((s = X"0") and (i_valid = '1') and (sop = '0')) or
                       ((s = X"3") and (i_valid = '1') and (eop = '0')) 
              else '0';

RX_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            s <= (others => '1'); --goto reset state
        else
            case s is 
            when X"0" =>
                oeop <= '0'; 
                if i_valid = '1' and sop = '1' then
                    o_rx_data.ctrl <= b1;
                    o_rx_data.bpm  <= b0;
                    s <= s+1;
                end if;
            when X"1" =>
                if i_valid = '1' then
                    o_rx_data.bucket <= b2 & b3;
                    o_rx_data.xpos(15 downto 0) <= b0 & b1;
                    s <= s+1;
                end if;
            when X"2" =>
                if i_valid = '1' then
                    o_rx_data.xpos(31 downto 16) <= b2 & b3;
                    o_rx_data.ypos(15 downto  0) <= b0 & b1;
                    s <= s+1;
                end if;
            when X"3" =>
                if i_valid = '1' then
                    o_rx_data.ypos(31 downto 16) <= b2 & b3;
                    crc_rx        <= b1;
                    oeop          <= eop; 
                    s <= s+1;
                    --s <= X"0";
                end if;
            when others =>
                oeop <= '0'; 
                s     <= X"0";
            end case;
        end if;
    end if;
end process;


--force RX crc field to 0x00 for computation
crc_in(31 downto 16) <= i_data(31 downto 16);
crc_in(15 downto  8) <= X"00" when s = X"3" else
                        i_data(15 downto  8);
crc_in( 7 downto  0) <= i_data( 7 downto  0);

crc_valid <= '0' when (i_valid = '0') or --data not valid
                      (s = X"0" and sop = '0') or --missing SOP
                      (s = X"4") else --idle cycle
             '1';
-- KW84, 25.05.2016 - bugfix in reset for frames with gaps             
--crc_rst   <= not crc_valid;
crc_rst   <= '1' when (s = X"0" and i_valid = '0') or (s = X"4") else '0';  

CRC_CALC_I : crc8_in32
port map( 
    data_in => crc_in,
    crc_en  => crc_valid,
    rst     => crc_rst,
    clk     => i_clk,
    crc_out => crc_out
);

o_rx_data.crc <= crc_rx;
o_eop <= oeop;
o_crc_good <= '1' when oeop = '1' and crc_out = crc_rx else '0';

end architecture rtl;

---------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ibfb_comm_package.ibfb_comm_packet;

entity ibfb_rx_packet_stat is
port(
    i_rst : in std_logic;
    i_clk : in std_logic;
    --packet interface
    i_bad_data : in  std_logic; 
    i_valid    : in  std_logic;
    i_crc_good : in  std_logic;
    --i_rx_data  : in  ibfb_comm_packet; --rx data (packet fields)
    --Stats
    i_reset_cnt    : in  std_logic;
    -- KW84, 17.08.2016 - Reset packet counter by trigger
    i_trg          : in  std_logic;
    o_bad_data_cnt : out std_logic_vector(31 downto 0);
    o_pkt_cnt      : out std_logic_vector(31 downto 0);
    o_bad_pkt_cnt  : out std_logic_vector(31 downto 0)
 );
end entity ibfb_rx_packet_stat;

architecture rtl of ibfb_rx_packet_stat is

signal bad_pkt_cnt  : unsigned(31 downto 0);
signal pkt_cnt      : unsigned(31 downto 0);
signal bad_data_cnt : unsigned(31 downto 0);

begin

CNT_PROC : process(i_clk)
begin
  if rising_edge(i_clk) then
    -- KW84, 17.08.2016 - Reset packet counter by trigger
    if i_trg = '1' then
      pkt_cnt      <= (others => '0');
    else
      if i_valid =  '1'  and pkt_cnt(31) = '0' then
          pkt_cnt <= pkt_cnt+1;
      end if;
    end if;
    if (i_rst = '1' or i_reset_cnt = '1') then
      bad_data_cnt <= (others => '0');
      bad_pkt_cnt  <= (others => '0');
    else
      if i_bad_data = '1'  and bad_data_cnt(31) = '0' then
          bad_data_cnt <= bad_data_cnt+1;
      end if;
      if i_valid = '1' and i_crc_good = '0' and bad_pkt_cnt(31) = '0' then
          bad_pkt_cnt <= bad_pkt_cnt+1;
      end if;
    end if;
  end if;
end process;

o_bad_data_cnt  <= std_logic_vector(bad_data_cnt);
o_pkt_cnt      <= std_logic_vector(pkt_cnt);
o_bad_pkt_cnt <= std_logic_vector(bad_pkt_cnt);

end architecture rtl;


------------------------------------------------------------------------------
-- PACKET FILTER
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.ibfb_comm_package.all;

--Interface directly with two receive channels from one or more gtx_tile components
--
entity ibfb_packet_filter is
generic(
    --protocol
    K_SOP : std_logic_vector(7 downto 0); --start of packet
    K_EOP : std_logic_vector(7 downto 0); --end of packet
    K_BAD : std_logic_vector(7 downto 0)  --EOP if replaced by this character for discarded packets
);
port(
    --debug
    o_flag_ram_wen   : out std_logic_vector(2**BPM_BITS-1 downto 0);
    o_flag_ram_waddr : out std_logic_vector(11 downto 0);
    o_flag_ram_wdata : out std_logic;
    --setup
    i_bpm_id         : in  bpm_id_t; --allowed BPM ids 
    i_bkt_min        : in  std_logic_vector(15 downto 0); --lowest bucket accepted
    i_bkt_max        : in  std_logic_vector(15 downto 0); --highest bucket accepted
    --PING
    i_ping_enable0   : in  std_logic; --enable sending of ping packets (channel 0)
    i_ping_enable1   : in  std_logic; --enable sending of ping packets (channel 0)
    o_ping_rx0       : out std_logic; --ping receved from channel 0 during last train
    o_ping_rx1       : out std_logic; --ping receved from channel 1 during last train
    o_ping_latency0  : out std_logic_vector(31 downto 0); --latency of ping packet during last train (valid if o_ping_rx0=1)
    o_ping_latency1  : out std_logic_vector(31 downto 0); --latency of ping packet during last train (valid if o_ping_rx1=1)
    --
    i_ram_clk        : in  std_logic;
    i_ram_raddr      : in  std_logic_vector(11 downto 0); --sized to address 2700 buckets
    o_ram_rdata      : out std_logic_vector(2**BPM_BITS-1 downto 0);
    --
    i_clk            : in  std_logic;
    i_rst            : in  std_logic;
    i_trig           : in  std_logic; --reset RX flags
    o_resetting      : out std_logic;
    o_pkt_valid      : out std_logic;
    o_pkt_discard_x  : out std_logic;
    o_pkt_discard_y  : out std_logic;
    --Input SFP channel 0 (RXFIFO 0)
    o_rxfifo_next0    : out std_logic;
    i_rxfifo_empty0   : in  std_logic;
    i_rxfifo_charisk0 : in  std_logic_vector(3 downto 0);
    i_rxfifo_data0    : in  std_logic_vector(31 downto 0);
    --Input SFP channel 1 (RXFIFO 1)
    o_rxfifo_next1    : out std_logic;
    i_rxfifo_empty1   : in  std_logic;
    i_rxfifo_charisk1 : in  std_logic_vector(3 downto 0);
    i_rxfifo_data1    : in  std_logic_vector(31 downto 0);
    --Output SFP channel 0 (TXFIFO 0) PING TRANSMISSION
    i_txfifo_full0    : in  std_logic;
    o_txfifo_write0   : out std_logic;
    o_txfifo_charisk0 : out std_logic_vector(3 downto 0);
    o_txfifo_data0    : out std_logic_vector(31 downto 0);
    --Output SFP channel 1 (TXFIFO 1) PING TRANSMISSION
    i_txfifo_full1    : in  std_logic;
    o_txfifo_write1   : out std_logic;
    o_txfifo_charisk1 : out std_logic_vector(3 downto 0);
    o_txfifo_data1    : out std_logic_vector(31 downto 0);
    --Output channel XY (new)
    i_output_next_x     : in  std_logic; --backpressure
    o_output_valid_x    : out std_logic;
    o_output_charisk_x  : out std_logic_vector(3 downto 0);
    o_output_data_x     : out std_logic_vector(31 downto 0);
    i_output_next_y     : in  std_logic; --backpressure
    o_output_valid_y    : out std_logic;
    o_output_charisk_y  : out std_logic_vector(3 downto 0);
    o_output_data_y     : out std_logic_vector(31 downto 0);
    --ML84, added QDR2 interface (logging)
    o_qdr2_out          : out t_qdr2_single_out;
    --KW84, 08.08.2016
    o_statistics      : out ibfb_comm_filter_statistics
);
end entity ibfb_packet_filter;

architecture rtl of ibfb_packet_filter is

component ram_infer_dual is
generic(
    ADDR_W : natural := 13;
    DATA_W : natural := 32 
);
port(
    --port A (read/write)
    clka  : in  std_logic;
    ena   : in  std_logic;
    wea   : in  std_logic;
    addra : in  std_logic_vector(ADDR_W-1 downto 0);
    dia   : in  std_logic_vector(DATA_W-1 downto 0);
    doa   : out std_logic_vector(DATA_W-1 downto 0);
    --port B
    clkb  : in  std_logic;
    enb   : in  std_logic;
    addrb : in  std_logic_vector(ADDR_W-1 downto 0);
    dob   : out std_logic_vector(DATA_W-1 downto 0)
);
end component ram_infer_dual;

signal chan : std_logic;
signal s    : unsigned(3 downto 0);
signal sop, eop, nxt, ivalid, ovalid, off_range : std_logic;
signal isk : std_logic_vector(3 downto 0);
signal b0, b1, b2, b3 : std_logic_vector(7 downto 0);

signal trig_r : std_logic_vector(3 downto 0);
signal ctrl, bpm, crc : std_logic_vector(7 downto 0);
signal bucket : std_logic_vector(15 downto 0);
signal reset_addr : unsigned(11 downto 0);
signal filt : natural range 0 to 255;
signal pkt_valid, switch_channel : std_logic;
signal pkt_discard_x, pkt_discard_y : std_logic;

constant BKT_BITS : natural := 12; --bits needed to count 2700 buckets
constant BPM_N : natural := 2**BPM_BITS;
constant ZERO : std_logic_vector(BPM_N-1 downto 0) := (others => '0');
constant ZERO_BKT_BITS : std_logic_vector(BKT_BITS-1 downto 0) := (others => '0');
constant LAST_ADDR : unsigned(11 downto 0) := (others => '1');
--
signal flag, reset_flags, flag_update : std_logic;
signal flag_set : std_logic_vector(0 downto 0);
signal bpm_mask, flag_write_v, flag_v, flag_m : std_logic_vector(BPM_N-1 downto 0);
signal flag_addr : std_logic_vector(BKT_BITS-1 downto 0);
signal next_s : std_logic;
signal oreg_full_x, next_s_x : std_logic;
signal oreg_full_y, next_s_y : std_logic;
signal oreg_free_x, oreg_free_y : std_logic;

signal bpm_id : bpm_id_t; --allowed BPM ids 

signal bpm_r : std_logic_vector(7 downto 0);
signal bpm_mask_r : std_logic_vector(BPM_N-1 downto 0);
signal chan_r, dpkt_valid, dpkt_valid_r, pkt_valid_r, pkt_discard_x_r, pkt_discard_y_r : std_logic;

--Ping packet generation
signal trig_cnt : unsigned(7 downto 0);
signal timer : unsigned(31 downto 0);
signal ping0_sent : std_logic;
signal ptx0_busy, ptx0_valid : std_logic;
signal ptx0_data : ibfb_comm_packet;
signal ping1_sent : std_logic;
signal ptx1_busy, ptx1_valid : std_logic;
signal ptx1_data : ibfb_comm_packet;

signal rx_is_ping0, rx_is_ping1, ping0_rx, ping1_rx : std_logic;
signal ping0_latency, ping1_latency : unsigned(31 downto 0);
signal rx_time : std_logic_vector(31 downto 0);

signal bkt_min, bkt_max : std_logic_vector(15 downto 0);

--ML84 added 9.9.16 for QDR2 data logging
signal bunch_timer : unsigned(31 downto 0);
signal rx_pkt_cnt : unsigned(13 downto 0);
signal rx_pkt_cnt0, rx_pkt_cnt1 : unsigned(13 downto 0); --max 16383 packets
signal xpos, ypos : std_logic_vector(31 downto 0);

-- KW84, 08.08.2016, filter statistics
signal r_statistics : ibfb_comm_filter_statistics;

--Cxxx
signal ovalid_r : std_logic;
signal isk_r : std_logic_vector(3 downto 0);
signal b0_r, b1_r, b2_r, b3_r : std_logic_vector(7 downto 0);

signal ocnt_x, ocnt_y : natural range 0 to 7;

begin

--ML84 added 9.9.16 (QDR2 logging)
--clock and clock.ready are assigned at the uppel hierarchy level (2 filters => 1 QDR)
QDR_LOG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        o_qdr2_out.qdr2_trg     <= i_trig;  
        o_qdr2_out.qdr2_we      <= pkt_valid_r and not rx_pkt_cnt(rx_pkt_cnt'left) and (not rx_is_ping0) and (not rx_is_ping1); --CHANGE: pkt_valid_r
        o_qdr2_out.qdr2_data0   <= std_logic_vector(rx_pkt_cnt( 3 downto  0)) & std_logic_vector(bunch_timer);
        o_qdr2_out.qdr2_data1   <= std_logic_vector(rx_pkt_cnt( 7 downto  4)) & ctrl & bpm & bucket;
        o_qdr2_out.qdr2_data2   <= std_logic_vector(rx_pkt_cnt(11 downto  8)) & xpos;
        o_qdr2_out.qdr2_data3   <= '0' & chan_r & std_logic_vector(rx_pkt_cnt(13 downto 12)) & ypos;
    end if;
end process;

rx_pkt_cnt <= rx_pkt_cnt0 when chan_r = '0' else
              rx_pkt_cnt1;

--select inputs according to current channel (CHAN register)
b0    <= i_rxfifo_data0( 7 downto  0) when chan = '0' else
         i_rxfifo_data1( 7 downto  0);
b1    <= i_rxfifo_data0(15 downto  8) when chan = '0' else
         i_rxfifo_data1(15 downto  8);
b2    <= i_rxfifo_data0(23 downto 16) when chan = '0' else
         i_rxfifo_data1(23 downto 16);
b3    <= i_rxfifo_data0(31 downto 24) when chan = '0' else
         i_rxfifo_data1(31 downto 24);
isk   <= i_rxfifo_charisk0 when chan = '0' else
         i_rxfifo_charisk1;
ivalid <= not i_rxfifo_empty0 when chan = '0' else 
         not i_rxfifo_empty1 ;

--advance the FIFO as soon as data becomes available
o_rxfifo_next0 <= not i_rxfifo_empty0 and next_s when chan = '0' else '0';
o_rxfifo_next1 <= not i_rxfifo_empty1 and next_s when chan = '1' else '0';

--switch only if the OTHER channel has available data
--switch_channel <= not i_rxfifo_empty1 when chan = '0' else 
--                  not i_rxfifo_empty0;
SWITCH_CH_P : process(i_clk) --register for speed
begin
    if rising_edge(i_clk) then
        if chan = '0' then
            switch_channel <= not i_rxfifo_empty1;
        else
            switch_channel <= not i_rxfifo_empty0;
        end if;
    end if;
end process;


--start of packet: data valid and upper 2 bytes = D.00, K.SOP
sop <= '1' when (isk(3 downto 2) = "01") and 
                (b3 = X"00")             and 
                (b2 = K_SOP)                   
           else '0';

--end of packet: lowest byte = K.EOP
eop <= '1' when (isk(0) = '1') and
                (b0 = K_EOP) 
           else '0';


--Read input FIFOs round robin.
--Filtering is performed according to the value of the BPM and BUCKET fields
--There's a flag for each of the possible combination <F>.
--If FLAG(F) is set, then the packet is marked as bad (EOP is replaced by a BAD character)
--If FLAG(F) is not set, then the packet is forwarded and the flag is set.
--
MAIN_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if (i_rst = '1') then
            s <= (others => '1');
        else
            case s is
            when X"0" =>
                flag_update <= '0';
                if ivalid = '1' and sop = '1' then
                    ctrl <= b1;
                    bpm  <= b0;
                    if next_s = '1' then --advance only when data is sampled
                        s <= s+1;
                    end if;
                else
                    chan <= not chan;
                end if;
            when X"1" =>
                if ivalid = '1' then
                    bucket <= b2 & b3;
                    xpos(15 downto 0) <= b0 & b1;
                    rx_time(15 downto 0) <= b0 & b1;
                    if next_s = '1' then
                        s <= s+1;
                    end if;
                end if;
            when X"2" =>
                if ivalid = '1' then
                    xpos(31 downto 16) <= b2 & b3;
                    rx_time(31 downto 16) <= b2 & b3;
                    ypos(15 downto  0) <= b0 & b1;
                    if next_s = '1' then
                        s <= s+1;
                    end if;
                end if;
            when X"3" =>
                if ivalid = '1' then
                    ypos(31 downto 16) <= b2 & b3;
                    crc <= b1;
                    --eop 
                    if next_s = '1' then
                        flag_update <= '1';
                        if switch_channel = '1' then
                            chan <= not chan;
                        end if;
                        s <= X"0";
                    end if;
                end if;
            when others =>
                flag_update <= '0';
                chan <= '0';
                s <= (others => '0');
            end case;
        end if;
    end if;
end process;

--------------------------------------------------------------------
-- V2.1, ML84 added PING RX logic
--------------------------------------------------------------------
PING_RX_P : process(i_clk) 
begin
    if rising_edge(i_clk) then
        
        if ctrl = X"10" then 
            rx_is_ping0 <= '1';
        else
            rx_is_ping0 <= '0';
        end if;

        if ctrl = X"11" then 
            rx_is_ping1 <= '1';
        else
            rx_is_ping1 <= '0';
        end if;

        if i_rst = '1' or trig_r(2 downto 1) = "01" then 
            --store value on output port before reset
            ping0_rx <= '0';
            ping1_rx <= '0';
        else
            if pkt_valid_r = '1' then --CHANGED (pkt_Valid_r)
                if rx_is_ping0 = '1' and bpm = std_logic_vector(trig_cnt) then
                    ping0_rx <= '1';
                    ping0_latency <= timer - unsigned(rx_time);
                elsif rx_is_ping1 = '1' and bpm = std_logic_vector(trig_cnt) then
                    ping1_rx <= '1';
                    ping1_latency <= timer - unsigned(rx_time);
                end if;
            end if;
        end if;
    end if;
end process;

o_ping_rx0 <= ping0_rx;
o_ping_rx1 <= ping1_rx;
o_ping_latency0 <= std_logic_vector(ping0_latency);
o_ping_latency1 <= std_logic_vector(ping1_latency);

--------------------------------------------------------------------

--Register allowed BPM ids (static values)
BPM_ID_REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        bpm_id <= i_bpm_id;
    end if;
end process;

--check whether bpm code matches one of the allowed ones
--Result is a mask vector when maximum 1 bit is asserted (i_BPM_id values shall be unique)
BPM_COMPARATORS : for i in 0 to (BPM_N-1) generate
  --registered to break combinatorial paths
  BPM_MASK_REG_P : process(i_clk)
  begin
      if rising_edge(i_clk) then
          if bpm = bpm_id(i) then
              bpm_mask(i) <= '1';
          else
              bpm_mask(i) <= '0';
          end if;
      end if;
  end process;
  --bpm_mask(i) <= '1' when bpm = bpm_id(i) else '0';
end generate;

flag_addr    <= bucket(BKT_BITS-1 downto 0) when reset_flags = '0' else --each BPM RAM is addressed by the bucket number
                std_logic_vector(reset_addr);
flag_write_v <= (others => '1') when reset_flags = '1' else --during reset all write enables are active
                bpm_mask        when flag_update = '1' else --write enable is masked according to the currently active RAM
                (others => '0');                                   
flag_set(0) <= '1' when (reset_flags = '0') else '0'; --flag are always set in normal operation, reset after trigger

--Instantiate a 4Kx1bit RAM component for each allowed BPM code
RAMGEN : for i in 0 to (BPM_N-1) generate

    FLAG_RAM_i : ram_infer_dual
    generic map(
        ADDR_W => BKT_BITS,
        DATA_W => 1
    )
    port map(
        clka   => i_clk,
        --port A (read/write)
        ena    => '1',
        wea    => flag_write_v(i),
        addra  => flag_addr,
        dia    => flag_set, --same for all. control via flag_write_v
        doa(0) => flag_v(i),
        --port B (read only)
        clkb   => '0', --i_ram_clk,
        enb    => '1',
        addrb  => ZERO_BKT_BITS, --i_ram_raddr,
        dob => open --o_ram_rdata(i)
    );

end generate;

o_flag_ram_wen   <= (others => '0'); --flag_write_v;
o_flag_ram_waddr <= (others => '0'); --flag_addr;
o_flag_ram_wdata <= '0'; --flag_set(0);

--FLAG_V is a 4-bit vector. If flag_v(i) is set, it means that BPM_ID(i) has already been received during this bunch
--Flag_v is masked so that only the bit relative to the current BPM_ID is left
FLAG_M_GEN : for i in flag_m'range generate
    flag_m(i) <= flag_v(i) and bpm_mask(i);
end generate;
--flag   <= '0' when flag_m = ZERO else '1'; --OR-reduce: if '1' then BPM_ID has already been received
flag   <= or_reduce(flag_m);

--Manage flags.
--Flags are reset whenever a trigger is detected
--During reset process the filter is blind to incoming data.
FLAG_RESET_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        --trig_r: t(-4), t(-3), t(-2), t(-1) <== t(0)
        trig_r <= trig_r(trig_r'left-1 downto 0) & i_trig;

        if (i_rst = '1' or trig_r(2 downto 1) = "01") then
            reset_flags <= '1';
            reset_addr <= (others => '0');
        else
            if reset_flags = '1' then
                if reset_addr = LAST_ADDR then
                    reset_addr <= (others => '0');
                    reset_flags <= '0';
                else
                    reset_addr <= reset_addr+1;
                end if;
            end if;
        end if;
    end if;
end process;

o_resetting <= reset_flags;

-------------------------------------------------------------------
--v2.1, ML84added PING transmission
-------------------------------------------------------------------

--Bunch trigger counter (used as SERIAL field for PING packets)
TRIG_CNT_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            trig_cnt <= (others => '0');
        elsif trig_r(2 downto 1) = "01" then
            trig_cnt <= trig_cnt+1;
        end if;
    end if;
end process;

--Free running clock counter (used as SEND_TIME field for PING packets)
TIMER_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            timer <= (others => '0');
        else
            timer <= timer+1;
        end if;
    end if;
end process;

--Bunch timer (counts time from last trigger)
BTIMER_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' or i_trig = '1' then
            bunch_timer <= (others => '0');
        else
            bunch_timer <= bunch_timer+1;
        end if;
    end if;
end process;

--RX Packet counter (reset on trigger, incremented on pkt_valid)
--PKT_CNT_P : process(i_clk)
--begin
--    if rising_edge(i_clk) then
--        if i_rst = '1' or i_trig = '1' then
--            rx_pkt_cnt <= (others => '0');
--        elsif pkt_valid_r = '1' and rx_pkt_cnt(rx_pkt_cnt'left) = '0' then --CHANGE (pkt_valid_r)
--            rx_pkt_cnt <= rx_pkt_cnt+1;
--        end if;
--    end if;
--end process;

PKT_CNT0_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' or i_trig = '1' then
            rx_pkt_cnt0 <= (others => '0');
        elsif pkt_valid_r = '1' and rx_pkt_cnt0(rx_pkt_cnt0'left) = '0' and chan_r = '0' then --CHANGE (pkt_valid_r)
            rx_pkt_cnt0 <= rx_pkt_cnt0+1;
        end if;
    end if;
end process;

PKT_CNT1_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' or i_trig = '1' then
            rx_pkt_cnt1 <= (others => '0');
        elsif pkt_valid_r = '1' and rx_pkt_cnt1(rx_pkt_cnt1'left) = '0' and chan_r = '1' then --CHANGE (pkt_valid_r)
            rx_pkt_cnt1 <= rx_pkt_cnt1+1;
        end if;
    end if;
end process;

--Channel 0 PING packet transmission
-------------------------------------------------------------------
ptx0_data.ctrl <= X"10"; --ping packet
ptx0_data.bpm  <= std_logic_vector(trig_cnt); --bpm field used as PING packet serial number
ptx0_data.bucket <= (others => '0'); --not used
ptx0_data.xpos   <= std_logic_vector(timer); --xpos field used as PING send time
ptx0_data.ypos   <= (others => '0'); --not used
--Data-valid generation
SEND_PING0 : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' or reset_flags = '0' or i_ping_enable0 = '0' then
            ptx0_valid <= '0';
            ping0_sent <= '0';
        else
            if ping0_sent = '0' and ptx0_busy = '0' then 
               ptx0_valid <= '1';
               ping0_sent <= '1';
            else
               ptx0_valid <= '0';
            end if;
        end if;
    end if;
end process;
--Packet transmitter
PING_PKT_TX0 : ibfb_packet_tx
generic map(
    K_SOP        => K_SOP,
    K_EOP        => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst        => i_rst,
    i_clk        => i_clk,
    --user interface
    o_busy       => ptx0_busy,
    i_tx_valid   => ptx0_valid,
    i_tx_data    => ptx0_data,
    --MGT FIFO interface
    i_fifo_full  => i_txfifo_full0,
    o_valid      => o_txfifo_write0,
    o_charisk    => o_txfifo_charisk0,
    o_data       => o_txfifo_data0
 );

--Channel 1 PING packet transmission
-------------------------------------------------------------------
ptx1_data.ctrl <= X"11"; --ping packet
ptx1_data.bpm  <= std_logic_vector(trig_cnt); --bpm field used as PING packet serial number
ptx1_data.bucket <= (others => '0'); --not used
ptx1_data.xpos   <= std_logic_vector(timer); --xpos field used as PING send time
ptx1_data.ypos   <= (others => '0'); --not used
--Data-valid generation
SEND_PING1 : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' or reset_flags = '0' or i_ping_enable1 = '0' then
            ptx1_valid <= '0';
            ping1_sent <= '0';
        else
            if ping1_sent = '0' and ptx1_busy = '0' then 
               ptx1_valid <= '1';
               ping1_sent <= '1';
            else
               ptx1_valid <= '0';
            end if;
        end if;
    end if;
end process;
--Packet transmitter
PING_PKT_TX1 : ibfb_packet_tx
generic map(
    K_SOP        => K_SOP,
    K_EOP        => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst        => i_rst,
    i_clk        => i_clk,
    --user interface
    o_busy       => ptx1_busy,
    i_tx_valid   => ptx1_valid,
    i_tx_data    => ptx1_data,
    --MGT FIFO interface
    i_fifo_full  => i_txfifo_full1,
    o_valid      => o_txfifo_write1,
    o_charisk    => o_txfifo_charisk1,
    o_data       => o_txfifo_data1
 );

-------------------------------------------------------------------------------------

--packet valid means that the last packet word is being output (the one containing the EOP K-character)
pkt_valid <= '1' when s = X"3" and eop = '1' else 
             '0';

--ML84 added range filtering
RANGE_CHECK_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        pkt_valid_r <= pkt_valid;
        bkt_min     <= i_bkt_min;
        bkt_max     <= i_bkt_max;
        if (unsigned(bucket) < unsigned(bkt_min)) or (unsigned(bucket) > unsigned(bkt_max)) then
            off_range <= '1';
        else
            off_range <= '0';
        end if;
    end if;
end process;

--discard a packet when:
--  1. packet is valid (sending data word containing EOP. When packet is bad, EOP is replaced with a BAD marker) AND
--    1.1. the flag is already set (meaning that a packet has already been forwarded with the same BPM_ID) OR
--    1.2. BPM_ID is not allowed (bpm_mask)
--    1.3. BUCKET is out of the allowed range
--    1.4. packet is a PING

--ML84 23.8.16 - Split output (X and Y)
pkt_discard_x <= '1' when 
                     --(pkt_valid = '1') and 
                     (pkt_valid_r = '1') and --C001 
                     (
                        ((flag = '1') or (bpm_mask(1 downto 0) = "00")) or
                        (off_range = '1') or
                        (rx_is_ping0 = '1' or rx_is_ping1 = '1')
                     )
                     else '0';
pkt_discard_y <= '1' when 
                     --(pkt_valid = '1') and --C001
                     (pkt_valid_r = '1') and 
                     (
                        ((flag = '1') or (bpm_mask(3 downto 2) = "00")) or
                        (off_range = '1') or
                        (rx_is_ping0 = '1' or rx_is_ping1 = '1')
                     )
                     else '0';

--Data NOT valid when:
--    <valid> signal is low OR
--    other data is received while expecting a SOP
ovalid <= '0' when (ivalid = '0') or ( s = X"0" and sop = '0') else '1';

--OUTPUT REGISTER
--After reset output registers are empty (oreg_full = '0')
--When data is available (ovalid) then output registers are loaded and marked as full (oreg_full <= '1')
--When output registers are full, wait until data is read (i_output_next). 
--  If new data is already available, then reload output registers immediately, otherwise mark them as empty. 

--can write on register when it's empty or it's being read (emptied) right now
oreg_free_x <= (not oreg_full_x) or i_output_next_x;
oreg_free_y <= (not oreg_full_y) or i_output_next_y;

OUT_REG_X : process(i_clk)
begin
    if rising_edge(i_clk) then
        if (i_rst = '1') then
            oreg_full_x <= '0';
            ovalid_r    <= '0';
            ocnt_x <= 0;
        else
            assert not(pkt_discard_x = '1' and ocnt_x /= 3) report "PKT_DISCARD_X: BAD SAMPLING" severity error;

            ovalid_r <= ovalid;

            if oreg_full_x = '0' then
                if ovalid_r = '1' and oreg_free_y = '1' then --this reg is empty, other can be loaded, data is available
                    --load register (other will be loaded too)
                    oreg_full_x <= '1';

                    case ocnt_x is
                        when 0 =>
                            o_output_charisk_x <= X"4";
                            o_output_data_x    <= X"00" & K_SOP & ctrl & bpm;
                            ocnt_x <= 1;
                        when 1 =>
                            o_output_charisk_x <= X"0";
                            o_output_data_x    <= bucket(7 downto 0) & bucket(15 downto 8) & xpos(7 downto 0) & xpos(15 downto 8); 
                            ocnt_x <= 2;
                        when 2 =>
                            o_output_charisk_x <= X"0";
                            o_output_data_x    <= xpos(23 downto 16) & xpos(31 downto 24)  & ypos(7 downto 0) & ypos(15 downto 8);
                            ocnt_x <= 3;
                        when others => --3 =>
                            o_output_charisk_x <= X"1";
                            o_output_data_x(31 downto 8) <= ypos(23 downto 16) & ypos(31 downto 24)  & crc;
                            if pkt_discard_x = '1' then
                                o_output_data_x(7 downto 0) <= K_BAD;
                            else      
                                o_output_data_x(7 downto 0) <= K_EOP;
                            end if;
                            ocnt_x <= 0;
                    end case;
                    --o_output_charisk_x <= isk;
                    --o_output_data_x(31 downto 8) <= b3&b2&b1;
                    --if pkt_discard_x = '1' then --valid packet, flag set
                    --    --replace EOP with
                    --    o_output_data_x(7 downto 0) <= K_BAD;
                    --else
                    --    o_output_data_x(7 downto 0) <= b0;
                    --end if;
                --else: do nothing
                end if;
            else --if oreg_full_x = '1' then
                if i_output_next_x = '1' then
                    if ovalid_r = '1' and oreg_free_y = '1' then --data available and both registers ready: reload register

                        case ocnt_x is
                        when 0 =>
                            o_output_charisk_x <= X"4";
                            o_output_data_x    <= X"00" & K_SOP & ctrl & bpm;
                            ocnt_x <= 1;
                        when 1 =>
                            o_output_charisk_x <= X"0";
                            o_output_data_x    <= bucket(7 downto 0) & bucket(15 downto 8) & xpos(7 downto 0) & xpos(15 downto 8); 
                            ocnt_x <= 2;
                        when 2 =>
                            o_output_charisk_x <= X"0";
                            o_output_data_x    <= xpos(23 downto 16) & xpos(31 downto 24)  & ypos(7 downto 0) & ypos(15 downto 8);
                            ocnt_x <= 3;
                        when others => --3 =>
                            o_output_charisk_x <= X"1";
                            o_output_data_x(31 downto 8) <= ypos(23 downto 16) & ypos(31 downto 24)  & crc;
                            if pkt_discard_x = '1' then
                                o_output_data_x(7 downto 0) <= K_BAD;
                            else      
                                o_output_data_x(7 downto 0) <= K_EOP;
                            end if;
                            ocnt_x <= 0;
                        end case;

                        --o_output_charisk_x <= isk;
                        --o_output_data_x(31 downto 8) <= b3&b2&b1;
                        --if pkt_discard_x = '1' then --valid packet, flag set
                        --    --replace EOP with
                        --    o_output_data_x(7 downto 0) <= K_BAD;
                        --else
                        --    o_output_data_x(7 downto 0) <= b0;
                        --end if;
                    else --no data available or other register not ready: empty register
                        oreg_full_x <= '0';
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

OUT_REG_Y : process(i_clk)
begin
    if rising_edge(i_clk) then
        if (i_rst = '1') then
            oreg_full_y <= '0';
            ocnt_y <= 0;
        else
            assert not(pkt_discard_y = '1' and ocnt_y /= 3) report "PKT_DISCARD_Y: BAD SAMPLING" severity error;

            if oreg_full_y = '0' then
                if ovalid_r = '1' and oreg_free_x = '1' then --this reg is empty, other can be loaded, data is available
                    --load register
                    oreg_full_y <= '1';

                    case ocnt_y is
                        when 0 =>
                            o_output_charisk_y <= X"4";
                            o_output_data_y    <= X"00" & K_SOP & ctrl & bpm;
                            ocnt_y <= 1;
                        when 1 =>
                            o_output_charisk_y <= X"0";
                            o_output_data_y    <= bucket(7 downto 0) & bucket(15 downto 8) & xpos(7 downto 0) & xpos(15 downto 8); 
                            ocnt_y <= 2;
                        when 2 =>
                            o_output_charisk_y <= X"0";
                            o_output_data_y    <= xpos(23 downto 16) & xpos(31 downto 24)  & ypos(7 downto 0) & ypos(15 downto 8);
                            ocnt_y <= 3;
                        when others => --3 =>
                            o_output_charisk_y <= X"1";
                            o_output_data_y(31 downto 8) <= ypos(23 downto 16) & ypos(31 downto 24)  & crc;
                            if pkt_discard_y = '1' then
                                o_output_data_y(7 downto 0) <= K_BAD;
                            else      
                                o_output_data_y(7 downto 0) <= K_EOP;
                            end if;
                            ocnt_y <= 0;
                    end case;

                    --o_output_charisk_y <= isk;
                    --o_output_data_y(31 downto 8) <= b3&b2&b1;
                    --if pkt_discard_y = '1' then --valid packet, flag set
                    --    --replace EOP with
                    --    o_output_data_y(7 downto 0) <= K_BAD;
                    --else
                    --    o_output_data_y(7 downto 0) <= b0;
                    --end if;
                --else: do nothing
                end if;
            else -- oreg_full_y = '1'
                if i_output_next_y = '1' then
                    if ovalid_r = '1' and oreg_free_x = '1' then --data available and both registers ready: reload register

                        case ocnt_y is
                        when 0 =>
                            o_output_charisk_y <= X"4";
                            o_output_data_y    <= X"00" & K_SOP & ctrl & bpm;
                            ocnt_y <= 1;
                        when 1 =>
                            o_output_charisk_y <= X"0";
                            o_output_data_y    <= bucket(7 downto 0) & bucket(15 downto 8) & xpos(7 downto 0) & xpos(15 downto 8); 
                            ocnt_y <= 2;
                        when 2 =>
                            o_output_charisk_y <= X"0";
                            o_output_data_y    <= xpos(23 downto 16) & xpos(31 downto 24)  & ypos(7 downto 0) & ypos(15 downto 8);
                            ocnt_y <= 3;
                        when others => --3 =>
                            o_output_charisk_y <= X"1";
                            o_output_data_y(31 downto 8) <= ypos(23 downto 16) & ypos(31 downto 24)  & crc;
                            if pkt_discard_y = '1' then
                                o_output_data_y(7 downto 0) <= K_BAD;
                            else      
                                o_output_data_y(7 downto 0) <= K_EOP;
                            end if;
                            ocnt_y <= 0;
                        end case;
                        --o_output_charisk_y <= isk;
                        --o_output_data_y(31 downto 8) <= b3&b2&b1;
                        --if pkt_discard_y = '1' then --valid packet, flag set
                        --    --replace EOP with
                        --    o_output_data_y(7 downto 0) <= K_BAD;
                        --else
                        --    o_output_data_y(7 downto 0) <= b0;
                        --end if;
                    else --no data available or other register not ready: empty register
                        oreg_full_y <= '0';
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

--advance input FIFO when output register is empty or it's being read right now
--next_s <= (not oreg_full) or (oreg_full and i_output_next);

--NEW: advance FIFO when both registers are empty or are going to be empty on next cycle (reading right now)
--next_s_x <= (not oreg_full_x) or (oreg_full_x and i_output_next_x);
--next_s_y <= (not oreg_full_y) or (oreg_full_y and i_output_next_y);
next_s   <= oreg_free_x and oreg_free_y; --next_s_x and next_s_y;

--KW84, 08.08.2016, filter statistics
--ML84, 24.08.2016, duplicated for X and Y outputs
prc_statistics : process(i_clk)
    variable vsl_catched_x : std_logic;
    variable vsl_catched_y : std_logic;
begin
    if rising_edge(i_clk) then
        if i_trig = '1' then
            r_statistics.packets_chan0_in     <= (others => '0');
            r_statistics.packets_chan1_in     <= (others => '0');
            r_statistics.packets_discarded_x  <= (others => '0');    
            r_statistics.packets_passed_x     <= (others => '0');    
            r_statistics.packets_discarded_y  <= (others => '0');    
            r_statistics.packets_passed_y     <= (others => '0');    
            r_statistics.wrong_bpm_id_x       <= (others => '0');
            r_statistics.wrong_bpm_id_y       <= (others => '0');
            vsl_catched_x                     := '0';
            vsl_catched_y                     := '0';
        else
            --register for speed
            dpkt_valid      <= pkt_valid and (not rx_is_ping0) and (not rx_is_ping1); --data packets only
            dpkt_valid_r    <= dpkt_valid;
            chan_r          <= chan;
            pkt_discard_x_r <= pkt_discard_x;
            pkt_discard_y_r <= pkt_discard_y;
            bpm_mask_r      <= bpm_mask;
            bpm_r           <= bpm;

            -- packets arrived to interface 0
            if dpkt_valid = '1' and chan_r = '0' then
              r_statistics.packets_chan0_in <= 
                std_logic_vector(unsigned(r_statistics.packets_chan0_in) + X"1");
            end if;
            -- packets arrived to interface 1
            if dpkt_valid = '1' and chan_r = '1' then
                r_statistics.packets_chan1_in <= 
                    std_logic_vector(unsigned(r_statistics.packets_chan1_in) + X"1");
            end if;

            -- packet passed to the output of the filter
            if dpkt_valid_r = '1' and pkt_discard_x_r = '0' then
                r_statistics.packets_passed_x <= 
                    std_logic_vector(unsigned(r_statistics.packets_passed_x) + X"1");
            end if;
            if dpkt_valid_r = '1' and pkt_discard_y_r = '0' then
                r_statistics.packets_passed_y <= 
                    std_logic_vector(unsigned(r_statistics.packets_passed_y) + X"1");
            end if;

            -- number of discarded packets
            if dpkt_valid = '1' and bpm_mask_r = ZERO then
                r_statistics.packets_discarded_x <= 
                    std_logic_vector(unsigned(r_statistics.packets_discarded_x) + X"1");
                if vsl_catched_x = '0' then
                    r_statistics.wrong_bpm_id_x     <= bpm_r;
                    vsl_catched_x := '1';
                end if;
            end if;
        end if;      
    end if;
end process;

o_statistics    <= r_statistics;
--o_output_valid  <= oreg_full;
o_output_valid_x  <= oreg_full_x;
o_output_valid_y  <= oreg_full_y;
o_pkt_valid     <= pkt_valid;
o_pkt_discard_x   <= pkt_discard_x;
o_pkt_discard_y   <= pkt_discard_y;

end architecture rtl; --of ibfb_packet_filter

------------------------------------------------------------------------------
-- PACKET BUFFER
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--buffers packet data from a FIFO.
--Whenever a good packet is found, waits until the packet is read
entity ibfb_packet_buffer is
generic(
    K_SOP : std_logic_vector(7 downto 0);
    K_EOP : std_logic_vector(7 downto 0)
);
port(
    i_clk            : in  std_logic;
    i_rst            : in  std_logic;
    --input
    o_next    : out std_logic;
    i_valid   : in  std_logic;
    i_charisk : in  std_logic_vector( 3 downto 0);
    i_data    : in  std_logic_vector(31 downto 0);
    --output
    i_next    : in  std_logic;
    o_valid   : out std_logic;
    o_charisk : out std_logic_vector( 3 downto 0);
    o_data    : out std_logic_vector(31 downto 0)
);
end entity ibfb_packet_buffer;


architecture rtl of ibfb_packet_buffer is

type sr_t is array(0 to 3) of std_logic_Vector(35 downto 0);
signal sr : sr_t;
signal sop, eop, out_valid : std_logic;
signal b0, b1, b2, b3 : std_logic_vector(7 downto 0);
signal s : unsigned(2 downto 0);

begin

b0 <= i_data( 7 downto  0);
b1 <= i_data(15 downto  8);
b2 <= i_data(23 downto 16);
b3 <= i_data(31 downto 24);

--start of packet: data valid and upper 2 bytes = D.00, K.SOP
sop <= '1' when (i_charisk(3 downto 2) = "01") and 
                (b3 = X"00")                   and 
                (b2 = K_SOP)                   
           else '0';

--end of packet: lowest byte = K.EOP
eop <= '1' when (i_charisk(0) = '1') and
                (b0 = K_EOP) 
           else '0';

o_next <= '1' when s < "100" and i_valid = '1' else '0';

MAIN_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            s <= "000";
        else
            case s is
            when "000" =>
                if i_valid = '1' and sop = '1' then
                    s <= s+1;
                end if;
            when "001" | "010" =>
                if i_valid = '1' then
                    s <= s+1;
                end if;
            when "011" =>
                if i_valid = '1' then
                    if eop = '1' then
                        s <= s+1;
                    else --bad packet
                        s <= "000";
                    end if;
                end if;
            when others => --increment until state counter flips
                if i_next = '1' then
                    s <= s+1;
                end if;
            end case;
        end if;
    end if;
end process;

--shift register containing the data
SR_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if (i_valid = '1' and s < "100") or (i_next = '1' and out_valid = '1') then
            sr(0) <= i_charisk&i_data;
            sr(1) <= sr(0);
            sr(2) <= sr(1);
            sr(3) <= sr(2);
        end if;
    end if;
end process;

out_valid <= '1' when s > "011" else '0';
o_valid   <= out_valid;
o_charisk <= sr(3)(35 downto 32);
o_data    <= sr(3)(31 downto  0);

end architecture rtl; --of ibfb_packet_buffer

------------------------------------------------------------------------------
-- PACKET ROUTER
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ibfb_comm_package.all;

entity ibfb_packet_router is
generic(
    K_SOP : std_logic_vector(7 downto 0);
    K_EOP : std_logic_vector(7 downto 0);
    N_INPUT_PORTS  : natural range 1 to 32 := 2;
    N_OUTPUT_PORTS : natural range 1 to 32 := 1
);
port(
    i_clk     : in  std_logic;
    i_rst     : in  std_logic;
    i_err_rst : in  std_logic; --not used
    i_routing_table : in array32(0 to N_INPUT_PORTS-1); --i_routing_table(i)(o) = 1 => input(i) is forwarded to output(o)
    --input
    o_next    : out std_logic_vector(0 to N_INPUT_PORTS-1);
    i_valid   : in  std_logic_vector(0 to N_INPUT_PORTS-1);
    i_charisk : in  array4(0 to N_INPUT_PORTS-1);
    i_data    : in  array32(0 to N_INPUT_PORTS-1);
    --output
    i_out_en  : in  std_logic_vector(0 to N_OUTPUT_PORTS-1); --disabled (use routing table instead)  
    i_next    : in  std_logic_vector(0 to N_OUTPUT_PORTS-1);
    o_valid   : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
    o_err     : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
    o_charisk : out array4(0 to N_OUTPUT_PORTS-1);
    o_data    : out array32(0 to N_OUTPUT_PORTS-1)
);
end entity ibfb_packet_router;

-------------------------------------------------------------------------------
-- pkt_buf architecture: uses a packet buffer on the inputs
-------------------------------------------------------------------------------
architecture pkt_buf of ibfb_packet_router is

constant ZERO     : std_logic_vector(0 to N_INPUT_PORTS-1) := (others => '0');

signal in_next    : std_logic_vector(0 to N_INPUT_PORTS-1);
signal in_valid   : std_logic_vector(0 to N_INPUT_PORTS-1);
signal in_charisk : array4(0 to N_INPUT_PORTS-1);
signal in_data    : array32(0 to N_INPUT_PORTS-1);

signal in_port : natural range 0 to N_INPUT_PORTS-1;
signal nxt : std_logic;
signal s : natural range 0 to 3;

signal ovalid : std_logic_vector(0 to N_OUTPUT_PORTS-1);
--signal b0, b1, b2, b3 : array8(0 to N_INPUT_PORTS-1);
--signal sop, eop : std_logic_vector(0 to N_INPUT_PORTS);
--ML84 added 16.8.16
type nat_array is array(natural range <>) of natural range 0 to N_INPUT_PORTS-1;
signal next_port : nat_array(0 to N_INPUT_PORTS-1);

signal routing_table : array32(0 to N_INPUT_PORTS-1); 

begin

--Generate one packet buffer for each of the input channels
ICHAN_G : for i in 0 to N_INPUT_PORTS-1 generate

    PKT_BUF_I : ibfb_packet_buffer
    generic map(
        K_SOP => K_SOP,
        K_EOP => K_EOP
    )
    port map(
        i_clk     => i_clk,
        i_rst     => i_rst,
        --input
        o_next    => o_next(i),
        i_valid   => i_valid(i),
        i_charisk => i_charisk(i),
        i_data    => i_data(i),
        --output
        i_next    => in_next(i),
        o_valid   => in_valid(i),
        o_charisk => in_charisk(i),
        o_data    => in_data(i)
    );

    in_next(i) <= in_valid(i) when in_port = i else '0';

end generate; --ICHAN_G

--Get data from input ports and send it to output ports
MAIN_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            in_port <= 0;
            nxt     <= '0';
            s       <= 0;
        else
            case s is
            when 0 => 
                --check for incoming data on current port.
                if in_valid(in_port) = '1' then
                    --read packet's word 0
                    s <= s+1;
                else --if no data available, try next port
                    --ML84 added 16.8.16
                    in_port <= next_port(in_port);
                end if;
            when 1 | 2 =>
                --read packet's words 1 & 2
                if in_valid(in_port) = '1' then
                    s <= s+1;
                end if;
            --when 3 =>
            when others =>
                --read packet's last word
                if in_valid(in_port) = '1' then
                    if (in_valid /= ZERO) then --change port only if there's data available on other ports
                        --ML84 added 16.8.16
                        in_port <= next_port(in_port);
                    end if;
                    s <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--Optimized next port selection: check if it meets timing.
NEXT_PORT_G: for i in 0 to N_INPUT_PORTS-1 generate

    INPORT_i : process(in_valid)
        variable nxt : natural;
        variable found : std_logic;
    begin
        found := '0';
        for j in i+1 to N_INPUT_PORTS-1 loop
            if found = '0' and in_valid(j) = '1' then
                nxt := j;
                found := '1';
            end if;
        end loop;
        for j in 0 to i-1 loop
            if found = '0' and in_valid(j) = '1' then
                nxt := j;
                found := '1';
            end if;
        end loop;

        if found = '0' then
            next_port(i) <= i;
        else
            next_port(i) <= nxt;
        end if;
    end process;

end generate;

--Connect currently selected input channel to all output channels
--No backpressure supported: if output channels are not available, data is lost
OUT_REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        routing_table <= i_routing_table; --register: static value

        for i in 0 to N_OUTPUT_PORTS-1 loop
            ovalid(i)    <= in_next(in_port) and ROUTING_TABLE(in_port)(i); -- and i_out_en(i); --write only to enabled outputs
            o_charisk(i) <= in_charisk(in_port);
            o_data(i)    <= in_data(in_port);
        end loop;
    end if;
end process;

o_valid <= ovalid;

--Set error flag when trying to write to an output channel while it is not ready
ERR_DETECT_P : process(i_clk)
begin
    if rising_edge(i_clk) then
            for i in 0 to N_OUTPUT_PORTS-1 loop
                o_err(i) <= ovalid(i) and not i_next(i);
            end loop;
    end if;
end process;


end architecture pkt_buf; --of ibfb_packet_router

-------------------------------------------------------------------------------
-- no_pkt_buf architecture: without input packet buffers (lower latency)
-- TODO: add a filter to avoid forwarding garbage from the input channels (bad K-chars)
-------------------------------------------------------------------------------
architecture no_pkt_buf of ibfb_packet_router is

constant ZERO     : std_logic_vector(0 to N_INPUT_PORTS-1) := (others => '0');

signal in_next    : std_logic_vector(0 to N_INPUT_PORTS-1);
signal in_valid   : std_logic_vector(0 to N_INPUT_PORTS-1);
signal in_charisk : array4(0 to N_INPUT_PORTS-1);
signal in_data    : array32(0 to N_INPUT_PORTS-1);

signal in_port : natural range 0 to N_INPUT_PORTS-1;
signal nxt : std_logic;
signal s : natural range 0 to 3;

signal ovalid : std_logic_vector(0 to N_OUTPUT_PORTS-1);
signal b0, b1, b2, b3 : array8(0 to N_INPUT_PORTS-1);
signal sop, eop : std_logic_vector(0 to N_INPUT_PORTS);

type nat_array is array(natural range <>) of natural range 0 to N_INPUT_PORTS-1;
signal next_port : nat_array(0 to N_INPUT_PORTS-1);

signal routing_table : array32(0 to N_INPUT_PORTS-1); 

begin

--Connect input channels
ICHAN_G : for i in 0 to N_INPUT_PORTS-1 generate

    --Direct connection
    in_next(i)    <= i_valid(i) when in_port = i else '0';
    in_valid(i)   <= i_valid(i);
    in_charisk(i) <= i_charisk(i);
    in_data(i)    <= i_data(i);

    o_next(i) <= in_next(i);

    b0(i) <= i_data(i)( 7 downto  0);
    b1(i) <= i_data(i)(15 downto  8);
    b2(i) <= i_data(i)(23 downto 16);
    b3(i) <= i_data(i)(31 downto 24);

    --start of packet: data valid and upper 2 bytes = D.00, K.SOP
    sop(i) <= '1' when (i_charisk(i)(3 downto 2) = "01") and 
                       (b3(i) = X"00")                   and 
                       (b2(i) = K_SOP)                   
              else '0';

    --end of packet: lowest byte = K.EOP
    eop(i) <= '1' when (i_charisk(i)(0) = '1') and
                       (b0(i) = K_EOP) 
              else '0';

end generate; --ICHAN_G

--Get data from input ports and send it to output ports
MAIN_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            in_port <= 0;
            nxt     <= '0';
            s       <= 0;
        else
            case s is
            when 0 => 
                --check for incoming data on current port.
                if in_valid(in_port) = '1' and sop(in_port) = '1' then
                    --read packet's word 0
                    s <= s+1;
                else --if no data available, try next port
                    in_port <= next_port(in_port);
                    --if in_port = N_INPUT_PORTS-1 then
                    --    in_port <= 0;
                    --else
                    --    in_port <= in_port+1;
                    --end if;
                end if;
            when 1 | 2 =>
                --read packet's words 1 & 2
                if in_valid(in_port) = '1' then
                    s <= s+1;
                end if;
            --when 3 =>
            when others =>
                --read packet's last word
                if in_valid(in_port) = '1' then --no need to check for EOP
                    if (in_valid /= ZERO) then --change port only if there's data available on other ports
                        in_port <= next_port(in_port);
                        --if in_port = N_INPUT_PORTS-1 then
                        --    in_port <= 0;
                        --else
                        --    in_port <= in_port+1;
                        --end if;
                    end if;
                    s <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--Optimized next port selection: check if it meets timing.
NEXT_PORT_G: for i in 0 to N_INPUT_PORTS-1 generate

    INPORT_i : process(in_valid)
        variable nxt : natural;
        variable found : std_logic;
    begin
        found := '0';
        for j in i+1 to N_INPUT_PORTS-1 loop
            if found = '0' and in_valid(j) = '1' then
                nxt := j;
                found := '1';
            end if;
        end loop;
        for j in 0 to i-1 loop
            if found = '0' and in_valid(j) = '1' then
                nxt := j;
                found := '1';
            end if;
        end loop;

        if found = '0' then
            next_port(i) <= i;
        else
            next_port(i) <= nxt;
        end if;
    end process;

end generate;

--Connect currently selected input channel to all output channels
--No backpressure supported: if output channels are not available, data is lost
OUT_REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        routing_table <= i_routing_table; --register: static value

        for i in 0 to N_OUTPUT_PORTS-1 loop
            ovalid(i)    <= in_next(in_port) and ROUTING_TABLE(in_port)(i); -- and i_out_en(i); --write only to enabled outputs
            o_charisk(i) <= in_charisk(in_port);
            o_data(i)    <= in_data(in_port);
        end loop;
    end if;
end process;

o_valid <= ovalid;

--Set error flag when trying to write to an output channel while it is not ready
ERR_DETECT_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' or i_err_rst = '1' then
            o_err <= (others => '0');
        else
            for i in 0 to N_OUTPUT_PORTS-1 loop
                if i_next(i) = '0' and ovalid(i) = '1' then
                    o_err(i) <= '1';
                end if;
            end loop;
        end if;
    end if;
end process;


end architecture no_pkt_buf; --of ibfb_packet_router

------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
------------------------------------------------------------------------------
-- Unit    : ibfb_gtx_tile.vhd
-- Author  : Alessandro Malatesta, Section Diagnostic
-- Version : $Revision: 1.5 $
------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
------------------------------------------------------------------------------
-- Comment : Component used to handle the IBFB packet protocol through GTX
--           Contains a GTX tile (2 channels).
--           Each TX channel uses an TX FIFO and a component that encodes data
--           into IBFB packets.
--           Each RX channel uses an RX FIFO and a component that decodes data
--           from IBFB packets.
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.virtex5_gtx_package.all;
use work.ibfb_comm_package.all;

entity ibfb_gtx_tile is
generic(
    --protocol
    K_SOP : std_logic_vector(7 downto 0);
    K_EOP : std_logic_vector(7 downto 0);
    --mgt
    G_GTX_REFCLK_SEL       : std_logic;
    G_GTX_TILE_REFCLK_FREQ : integer := 125; --MHz 
    G_GTX_BAUD_RATE        : integer := 2500000 --Kbps
);
port(
    --DEBUG
    o_DBG_x0 : out std_logic;
    o_DBG_v0 : out std_logic;
    o_DBG_k0 : out std_logic_vector(3 downto 0);
    o_DBG_d0 : out std_logic_vector(31 downto 0);
    o_DBG_x1 : out std_logic;
    o_DBG_v1 : out std_logic;
    o_DBG_k1 : out std_logic_vector(3 downto 0);
    o_DBG_d1 : out std_logic_vector(31 downto 0);
    --debug
    o_csp_clk   : out std_logic;
    o_csp_data  : out std_logic_vector(63 downto 0);  
    --MGT
    I_GTX_REFCLK1_IN : in  std_logic;
    I_GTX_REFCLK2_IN : in  std_logic;
    I_GTX_RX_N       : in  std_logic_vector(1 downto 0);
    I_GTX_RX_P       : in  std_logic_vector(1 downto 0);
    O_GTX_TX_N       : out std_logic_vector(1 downto 0);
    O_GTX_TX_P       : out std_logic_vector(1 downto 0);
    --
    i_loopback0      : in  std_logic_vector(2 downto 0);
    i_loopback1      : in  std_logic_vector(2 downto 0);
    o_mgt            : out mgt_out_type;
    --user
    i_clk            : in  std_logic;
    i_rst            : in  std_logic;
    --Channel 0 ----------------------------------------------------------------------------------------
    --TX interface
    o_tx_busy0       : out std_logic; --assert valid/data only when this bit is low
    i_tx_valid0      : in  std_logic; --assert to send tx_data through MGT
    i_tx_data0       : in  ibfb_comm_packet; --tx data 
    --RX interface
    o_rx_bad_data0   : out std_logic; --received data non compliant with protocol (misalignment/error)
    o_rx_valid0      : out std_logic; --rx_data valid
    o_rx_crc_good0   : out std_logic; --rx packet had correct crc (sample when valid = '1')
    o_rx_data0       : out ibfb_comm_packet; --rx data (sample when valid = '1')
    --Channel 1 ----------------------------------------------------------------------------------------
    --TX interface
    o_tx_busy1       : out std_logic; --assert valid/data only when this bit is low
    i_tx_valid1      : in  std_logic; --assert to send tx_data through MGT
    i_tx_data1       : in  ibfb_comm_packet; --tx data 
    --RX interface
    o_rx_bad_data1   : out std_logic; --received data non compliant with protocol (misalignment/error)
    o_rx_valid1      : out std_logic; --rx_data valid
    o_rx_crc_good1   : out std_logic; --rx packet had correct crc (sample when valid = '1')
    o_rx_data1       : out ibfb_comm_packet --rx data (sample when valid = '1')
);
end entity ibfb_gtx_tile;

architecture struct of ibfb_gtx_tile is

signal txfifo_full0    : std_logic;
signal txfifo_write0   : std_logic;
signal txfifo_charisk0 : std_logic_vector(3 downto 0);
signal txfifo_data0    : std_logic_vector(31 downto 0);

signal rxfifo_next0    : std_logic;
signal rxfifo_valid0   : std_logic;
signal rxfifo_empty0   : std_logic;
signal rxfifo_charisk0 : std_logic_vector(3 downto 0);
signal rxfifo_data0    : std_logic_vector(31 downto 0);

signal txfifo_full1    : std_logic;
signal txfifo_write1   : std_logic;
signal txfifo_charisk1 : std_logic_vector(3 downto 0);
signal txfifo_data1    : std_logic_vector(31 downto 0);

signal rxfifo_next1    : std_logic;
signal rxfifo_valid1   : std_logic;
signal rxfifo_empty1   : std_logic;
signal rxfifo_charisk1 : std_logic_vector(3 downto 0);
signal rxfifo_data1    : std_logic_vector(31 downto 0);

begin

o_DBG_x0 <= rxfifo_next0;
o_DBG_v0 <= rxfifo_valid0;
o_DBG_k0 <= rxfifo_charisk0;
o_DBG_d0 <= rxfifo_data0;
o_DBG_x1 <= rxfifo_next1;
o_DBG_v1 <= rxfifo_valid1;
o_DBG_k1 <= rxfifo_charisk1;
o_DBG_d1 <= rxfifo_data1;

--MGT TILE (GTX_DUAL+FIFOs)
TILE_inst : gtx_tile
generic map(
    G_GTX_REFCLK_SEL       => G_GTX_REFCLK_SEL,
    G_GTX_TILE_REFCLK_FREQ => G_GTX_TILE_REFCLK_FREQ,
    G_GTX_BAUD_RATE        => G_GTX_BAUD_RATE
)
port map(
    ------------------------------------------------------------------------
    -- GTX SETTINGS & STATUS
    ------------------------------------------------------------------------
    i_loopback0 => i_loopback0,
    i_loopback1 => i_loopback1,
    o_mgt       => o_mgt,
    ------------------------------------------------------------------------
    -- GTX INTERFACE
    ------------------------------------------------------------------------
    I_GTX_REFCLK1_IN            => I_GTX_REFCLK1_IN,
    I_GTX_REFCLK2_IN            => I_GTX_REFCLK2_IN,
    O_GTX_REFCLK_OUT            => open,
    I_GTX_RX_N                  => I_GTX_RX_N,
    I_GTX_RX_P                  => I_GTX_RX_P,
    O_GTX_TX_N                  => O_GTX_TX_N,
    O_GTX_TX_P                  => O_GTX_TX_P,
    ------------------------------------------------------------------------
    -- FIFO interface
    ------------------------------------------------------------------------
    i_clk             => i_clk,
    --Channel 0
    i_fifo_reset0     => i_rst,
    --TX
    o_txfifo_full0    => txfifo_full0,
    i_txfifo_write0   => txfifo_write0,
    i_txfifo_charisk0 => txfifo_charisk0,
    i_txfifo_data0    => txfifo_data0,
    --RX
    i_rxfifo_next0    => rxfifo_next0,
    o_rxfifo_empty0   => rxfifo_empty0,
    o_rxfifo_charisk0 => rxfifo_charisk0,
    o_rxfifo_data0    => rxfifo_data0,
    --Channel 1
    i_fifo_reset1     => i_rst,
    --TX
    o_txfifo_full1    => txfifo_full1,
    i_txfifo_write1   => txfifo_write1,
    i_txfifo_charisk1 => txfifo_charisk1,
    i_txfifo_data1    => txfifo_data1,
    --RX
    i_rxfifo_next1    => rxfifo_next1,
    o_rxfifo_empty1   => rxfifo_empty1,
    o_rxfifo_charisk1 => rxfifo_charisk1,
    o_rxfifo_data1    => rxfifo_data1
);

rxfifo_valid0 <= not rxfifo_empty0;
rxfifo_valid1 <= not rxfifo_empty1;

----------------CHANNEL 0 --------------------------------------------
--Packet generator 0 (TX channel 0)
PACK_TX0_inst : ibfb_packet_tx
generic map(
    K_SOP        => K_SOP,
    K_EOP        => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst        => i_rst,
    i_clk        => i_clk,
    --user interface
    o_busy       => o_tx_busy0,
    i_tx_valid   => i_tx_valid0,
    i_tx_data    => i_tx_data0,
    --MGT FIFO interface
    i_fifo_full  => txfifo_full0,
    o_valid      => txfifo_write0,
    o_charisk    => txfifo_charisk0,
    o_data       => txfifo_data0
 );

--Packet parser 0 (RX channel 0)
PACK_RX0_inst : ibfb_packet_rx
generic map(
    K_SOP      => K_SOP,
    K_EOP      => K_EOP
)
port map(
    i_rst      => i_rst,
    i_clk      => i_clk,
    --user interface
    o_bad_data => o_rx_bad_data0,
    o_eop      => o_rx_valid0,
    o_crc_good => o_rx_crc_good0,
    o_rx_data  => o_rx_data0,
    --MGT FIFO interface
    o_next     => rxfifo_next0,
    i_valid    => rxfifo_valid0,
    i_charisk  => rxfifo_charisk0,
    i_data     => rxfifo_data0
);

----------------CHANNEL 1 --------------------------------------------
--Packet generator 1 (TX channel 1)
PACK_TX1_inst : ibfb_packet_tx
generic map(
    K_SOP        => K_SOP,
    K_EOP        => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst        => i_rst,
    i_clk        => i_clk,
    --user interface
    o_busy       => o_tx_busy1,
    i_tx_valid   => i_tx_valid1,
    i_tx_data    => i_tx_data1,
    --MGT FIFO interface
    i_fifo_full  => txfifo_full1,
    o_valid      => txfifo_write1,
    o_charisk    => txfifo_charisk1,
    o_data       => txfifo_data1
 );

--Packet parser 1 (RX channel 1)
PACK_RX1_inst : ibfb_packet_rx
generic map(
    K_SOP      => K_SOP,
    K_EOP      => K_EOP
)
port map(
    i_rst      => i_rst,
    i_clk      => i_clk,
    --user interface
    o_bad_data => o_rx_bad_data1,
    o_eop      => o_rx_valid1,
    o_crc_good => o_rx_crc_good1,
    o_rx_data  => o_rx_data1,
    --MGT FIFO interface
    o_next     => rxfifo_next1,
    i_valid    => rxfifo_valid1,
    i_charisk  => rxfifo_charisk1,
    i_data     => rxfifo_data1,
    o_csp_clk  => o_csp_clk,
    o_csp_data => o_csp_data
);

end architecture struct;

-----------------------------------------------------------------------------
--ML84 02.11.2016
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pkg_crc.all;

--Format data into a packet and write it to MGT FIFO
--Packet format is as follows (32-bit dwords):
--dword0: 0x00       | K(SOP)     | CTRL     | BPM 
--dword1: bucket(B0) | bucket(B1) | XPOS(B0) | XPOS(B1) 
--dword2: XPOS(B2)   | xpos(B3)   | ypos(B0) | ypos(B1)
--dword3: ypos(B2)   | ypos(B3)   | CRC      | K(EOP)
--
--USAGE
--When busy = 0, assert tx_valid and tx_data. Deassert tx_valid only when busy = 1.
--If next tx_valid/tx_data are asserted as soon as busy becomes '0' again, then
-- writes to FIFO are performed without pause.
entity ibfb_mon_packet_tx is
generic(
    K_SOP : std_logic_vector(7 downto 0); --start of packet k-character
    K_EOP : std_logic_vector(7 downto 0)  --end of packet k-character
);
port(
    i_rst       : in  std_logic;
    i_clk       : in  std_logic;
    o_status    : out std_logic_vector(2 downto 0);
    --user interface
    o_sample    : out std_logic; --'1' when sampling inputs
    o_busy      : out std_logic; --inputs not sampled when busy = '1'
    i_tx_valid  : in  std_logic; --when asserted and busy = '0', then i_tx_data is sampled and transmitted
    i_bkt_id    : in  std_logic_vector(15 downto 0);
    i_mon_0     : in  std_logic_vector(15 downto 0);
    i_mon_1     : in  std_logic_vector(15 downto 0);
    i_mon_2     : in  std_logic_vector(15 downto 0);
    i_mon_3     : in  std_logic_vector(15 downto 0);
    --MGT FIFO interface
    i_fifo_full : in  std_logic; 
    o_valid     : out std_logic; --connect to FIFO write-enable
    o_charisk   : out std_logic_vector(3 downto 0);
    o_data      : out std_logic_vector(31 downto 0)
 );
end entity ibfb_mon_packet_tx;


--ML84 TODO
architecture rtl of ibfb_mon_packet_tx is

signal start_r, valid, valid_r, crc_rst : std_logic;
signal s         : unsigned(2 downto 0);
signal b0, b1, x0, x1, x2, x3, y0, y1, y2, y3, crc_out, checksum : std_logic_vector(7 downto 0);
signal ocharisk, ocharisk_r : std_logic_vector(3 downto 0);
signal odata, odata_r : std_logic_vector(31 downto 0);

begin

--name data bytes
REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_tx_valid = '1' and s = "000" then
            b0 <= i_bkt_id(7 downto 0);
            b1 <= i_bkt_id(15 downto 8);
            x0 <= i_mon_0( 7 downto  0);
            x1 <= i_mon_0(15 downto  8);
            x2 <= i_mon_1( 7 downto  0);
            x3 <= i_mon_1(15 downto  8);
            y0 <= i_mon_2( 7 downto  0);
            y1 <= i_mon_2(15 downto  8);
            y2 <= i_mon_3( 7 downto  0);
            y3 <= i_mon_3(15 downto  8);
        end if;
    end if;
end process;

o_sample <= '1' when s = "000" and i_tx_valid = '1' and i_fifo_full = '0' else '0';
o_busy   <= valid or valid_r; --'0' when (s = "000") and i_fifo_full = '0' else '1';

--TX process
TX_P : process(i_clk)
begin   
    if rising_edge(i_clk) then
        if i_rst = '1' then
            s <= (others => '1');
        else
            case s is
                when "000" => --send SOP, (two spare bytes set to 0x0)
                    if i_tx_valid = '1' and i_fifo_full = '0' then
                        valid   <= '1';
                        ocharisk <= "0100";
                        odata    <= X"00" & K_SOP & X"2000";
                        s         <= s+1;
                    else
                        valid     <= '0';
                    end if;
                when "001" => --send two spare bytes, then first data value
                    if i_fifo_full = '0' then
                        valid     <= '1';
                        ocharisk <= "0000";
                        odata    <= b0 & b1 & x0 & x1;
                        s         <= s+1;
                    end if;
                when "010" => --send second and third data values
                    if i_fifo_full = '0' then
                        valid     <= '1';
                        ocharisk <= "0000";
                        odata    <= x2 & x3 & y0 & y1;
                        s         <= s+1;
                    end if;
                when "011" => --send fourth data value, Checksum, EOP 
                    if i_fifo_full = '0' then
                        valid     <= '1';
                        ocharisk <= "0001";
                        odata    <= y2 & y3 & X"00" & K_EOP;
                        s <= s+1;
                    end if;
                when "100" =>
                    valid <= '0';
                    s     <= "000";
                when others => --reset state
                    s        <= (others => '0');
                    valid    <= '0';
            end case;
        end if;
    end if;
end process;

crc_rst <= not valid;

CRC_CALC_I : crc8_in32
port map( 
    data_in => odata,
    crc_en  => valid,
    rst     => crc_rst,
    clk     => i_clk,
    crc_out => crc_out
);

OUTPUT_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        valid_r    <= valid;
        odata_r    <= odata;
        ocharisk_r <= ocharisk;
    end if;
end process;

checksum <= crc_out; 

o_status <= std_logic_vector(s);
o_valid <= valid_r and not i_fifo_full;
o_charisk <= ocharisk_r;
o_data(31 downto 16) <= odata_r(31 downto 16);
o_data(15 downto  8) <= checksum when s = "000" else
                        odata_r(15 downto  8);
o_data( 7 downto  0) <= odata_r( 7 downto  0);

end architecture rtl; --of ibfb_mon_packet_tx


--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ibfb_comm_package.ibfb_comm_packet;
use work.pkg_crc.all;

--Reads packet from MGT FIFO and unpacks single data fields
--Packet format is as follows (32-bit dwords):
--dword0: 0x00       | K(SOP)     | SPARE    | SPARE
--dword1: SPARE      | SPARE      | MON0(B0) | MON0(B1) 
--dword2: MON1(B0)   | MON1(B1)   | MON2(B0) | MON2(B1)
--dword3: MON3(B0)   | MON3(B1)   | CRC      | K(EOP)
--
--USAGE
--As soon as available, data is read from FIFO and processed.
--If data is not compliant with the input format, it will be discarded.
--A discarded data word from FIFO is signalled with o_bad_data = '1'.
--o_rx_data is valid whenever o_eop = '1'.
--o_crc_good is valid whenever o_eop = '1' and provides the outcome of the 
--internal CRC check (expecting CRC8 calculated on 32bit words, see ibfb_packet_tx).
entity ibfb_mon_packet_rx is
generic(
    K_SOP : std_logic_vector(7 downto 0);
    K_EOP : std_logic_vector(7 downto 0)
);
port(
    i_rst : in std_logic;
    i_clk : in std_logic;
    --user interface
    o_bad_data : out std_logic; 
    o_eop      : out std_logic;
    o_crc_good : out std_logic;
    o_bkt_id   : out std_logic_vector(15 downto 0);
    o_data_0   : out std_logic_vector(15 downto 0);
    o_data_1   : out std_logic_vector(15 downto 0);
    o_data_2   : out std_logic_vector(15 downto 0);
    o_data_3   : out std_logic_vector(15 downto 0);
    --MGT FIFO interface
    o_next      : out std_logic;
    i_valid     : in  std_logic;
    i_charisk   : in  std_logic_vector(3 downto 0);
    i_data      : in  std_logic_vector(31 downto 0);
    --debug
    o_csp_clk   : out std_logic;
    o_csp_data  : out std_logic_vector(63 downto 0)
);
end entity ibfb_mon_packet_rx;

architecture rtl of ibfb_mon_packet_rx is

signal s    : unsigned(3 downto 0);
signal csum : unsigned(7 downto 0);
signal sop, eop, oeop : std_logic;
signal b0, b1, b2, b3 : std_logic_vector(7 downto 0);

signal crc_valid, crc_rst : std_logic;
signal crc_in : std_logic_vector(31 downto 0);
signal crc_rx, crc_out : std_logic_vector(7 downto 0);

begin

o_csp_clk <= i_clk;
DBG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
o_csp_data(0)            <= oeop;
o_csp_data(1)            <= crc_valid;
o_csp_data(2)            <= crc_rst;
o_csp_data(3)            <= sop;
o_csp_data(4)            <= eop;
o_csp_data(5)            <= i_valid;
o_csp_data(6)            <= i_rst;
o_csp_data(15 downto  8) <= crc_out;
o_csp_data(23 downto 16) <= crc_rx;
o_csp_data(27 downto 24) <= std_logic_vector(s);
o_csp_data(63 downto 32) <= i_data;
    end if;
end process;


b0 <= i_data( 7 downto  0);
b1 <= i_data(15 downto  8);
b2 <= i_data(23 downto 16);
b3 <= i_data(31 downto 24);

--start of packet: data valid and upper 2 bytes = D.00, K.SOP
sop <= '1' when (i_charisk(3 downto 2) = "01") and 
                (b3 = X"00")                   and 
                (b2 = K_SOP)                   
           else '0';

--end of packet: lowest byte = K.EOP
eop <= '1' when (i_charisk(0) = '1') and
                (b0 = K_EOP) 
           else '0';

--advance the FIFO as soon as data becomes available
o_next <= i_valid when i_rst = '0' and (s /= X"4") else '0';

--signal when an expectied SOP/EOP is missing
o_bad_data <= '1' when ((s = X"0") and (i_valid = '1') and (sop = '0')) or
                       ((s = X"3") and (i_valid = '1') and (eop = '0')) 
              else '0';

RX_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            s <= (others => '1'); --goto reset state
        else
            case s is 
            when X"0" =>
                oeop <= '0'; 
                if i_valid = '1' and sop = '1' then
                    --o_rx_data.ctrl <= b1; --Eventually check CTRL field (should be 0x20)
                    --o_rx_data.bpm  <= b0; --empty field
                    s        <= s+1;
                end if;
            when X"1" =>
                if i_valid = '1' then
                    o_bkt_id <= b2 & b3; 
                    o_data_0 <= b0 & b1;
                    s        <= s+1;
                end if;
            when X"2" =>
                if i_valid = '1' then
                    o_data_1 <= b2 & b3;
                    o_data_2 <= b0 & b1;
                    s        <= s+1;
                end if;
            when X"3" =>
                if i_valid = '1' then
                    o_data_3 <= b2 & b3;
                    crc_rx   <= b1;
                    oeop     <= eop; 
                    s        <= s+1;
                    --s <= X"0";
                end if;
            when others =>
                oeop <= '0'; 
                s     <= X"0";
            end case;
        end if;
    end if;
end process;


--force RX crc field to 0x00 for computation
crc_in(31 downto 16) <= i_data(31 downto 16);
crc_in(15 downto  8) <= X"00" when s = X"3" else
                        i_data(15 downto  8);
crc_in( 7 downto  0) <= i_data( 7 downto  0);

crc_valid <= '0' when (i_valid = '0') or --data not valid
                      (s = X"0" and sop = '0') or --missing SOP
                      (s = X"4") else --idle cycle
             '1';
-- KW84, 25.05.2016 - bugfix in reset for frames with gaps             
--crc_rst   <= not crc_valid;
crc_rst   <= '1' when (s = X"0" and i_valid = '0') or (s = X"4") else '0';  

CRC_CALC_I : crc8_in32
port map( 
    data_in => crc_in,
    crc_en  => crc_valid,
    rst     => crc_rst,
    clk     => i_clk,
    crc_out => crc_out
);

--o_rx_data.crc <= crc_rx;
o_eop <= oeop;
o_crc_good <= '1' when oeop = '1' and crc_out = crc_rx else '0';

end architecture rtl;
