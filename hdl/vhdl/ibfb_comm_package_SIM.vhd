------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
------------------------------------------------------------------------------
-- Unit    : ibfb_comm_package.vhd
-- Author  : Alessandro Malatesta, Section Diagnostic
-- Version : $Revision: 1.1 $
--         : $Revision: 1.1 $
------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
------------------------------------------------------------------------------
-- Comment : This package contains the components used to implement the 
--           communication protocol in the IBFB subsystem.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use work.virtex5_gtx_package.all;

package ibfb_comm_package is

    constant BPM_BITS : natural := 2; --number of used BPMs will be 2**BPM_BITS

    type bpm_id_t is array (0 to 2**BPM_BITS-1) of std_logic_vector(7 downto 0);
    type array3  is array (natural range <>) of std_logic_vector(2 downto 0);
    type array4  is array (natural range <>) of std_logic_vector(3 downto 0);
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
        o_rx_data  : out ibfb_comm_packet --tx data (packet fields)
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
        i_rx_data  : in  ibfb_comm_packet; --rx data (packet fields)
        --Stats
        i_reset_cnt    : in  std_logic;
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
        --setup
        i_bpm_id         : in  bpm_id_t; --allowed BPM ids 
        --
        i_clk            : in  std_logic;
        i_rst            : in  std_logic;
        i_trig           : in  std_logic; --reset RX flags (takes 4096 clock cycles, during which o_resetting stays high)
        o_resetting      : out std_logic; --when high, core is resetting RAMs that store flags. No incoming data will be processed. Duration 4096 clock cycles.
        o_pkt_valid      : out std_logic; --detected EOP on currently active input channel.
        o_pkt_discard    : out std_logic; --to be sampled when o_pkt_valid is high: notifies filtered packet (K_EOP replaced with K_BAD)
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
        --Output channel (FIFO interface, FWFT)
        i_output_next     : in  std_logic;
        o_output_valid    : out std_logic;
        o_output_charisk  : out std_logic_vector(3 downto 0);
        o_output_data     : out std_logic_vector(31 downto 0)
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
        N_INPUT_PORTS  : natural := 2;
        N_OUTPUT_PORTS : natural := 1
    );
    port(
        i_clk     : in  std_logic;
        i_rst     : in  std_logic;
        i_err_rst : in  std_logic; --reset error flag
        --input (FIFO, FWFT)
        o_next    : out std_logic_vector(0 to N_INPUT_PORTS-1);
        i_valid   : in  std_logic_vector(0 to N_INPUT_PORTS-1);
        i_charisk : in  array4(0 to N_INPUT_PORTS-1);
        i_data    : in  array32(0 to N_INPUT_PORTS-1);
        --output (STREAMING. i_next is used only to detect errors, but does not control data flow)
        i_next    : in  std_logic_vector(0 to N_OUTPUT_PORTS-1);
        o_valid   : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
        o_err     : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
        o_charisk : out array4(0 to N_OUTPUT_PORTS-1);
        o_data    : out array32(0 to N_OUTPUT_PORTS-1)
    );
    end component ibfb_packet_router;

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
o_busy <= valid or valid_r; --'0' when (s = "000") and i_fifo_full = '0' else '1';

--TX process
TX_P : process(i_clk)
begin   
    if rising_edge(i_clk) then
        if i_rst = '1' then
            s <= (others => '1');
        else
            case s is
                when "000" => --send SOP, BTRL, BPM
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
    i_data      : in  std_logic_vector(31 downto 0)
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
crc_rst   <= not crc_valid;

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
    i_rx_data  : in  ibfb_comm_packet; --rx data (packet fields)
    --Stats
    i_reset_cnt    : in  std_logic;
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
        if (i_rst = '1' or i_reset_cnt = '1') then
            bad_data_cnt <= (others => '0');
            pkt_cnt      <= (others => '0');
            bad_pkt_cnt  <= (others => '0');
        else
            if i_bad_data = '1' then
                bad_data_cnt <= bad_data_cnt+1;
            end if;

            if i_valid =  '1' then
                pkt_cnt <= pkt_cnt+1;
            end if;

            if i_valid = '1' and i_crc_good = '0' then
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
    --setup
    i_bpm_id         : in  bpm_id_t; --allowed BPM ids 
    --
    i_clk            : in  std_logic;
    i_rst            : in  std_logic;
    i_trig           : in  std_logic; --reset RX flags
    o_resetting      : out std_logic;
    o_pkt_valid      : out std_logic;
    o_pkt_discard    : out std_logic;
    --Input channel 0 (RXFIFO 0)
    o_rxfifo_next0    : out std_logic;
    i_rxfifo_empty0   : in  std_logic;
    i_rxfifo_charisk0 : in  std_logic_vector(3 downto 0);
    i_rxfifo_data0    : in  std_logic_vector(31 downto 0);
    --Input channel 1 (RXFIFO 1)
    o_rxfifo_next1    : out std_logic;
    i_rxfifo_empty1   : in  std_logic;
    i_rxfifo_charisk1 : in  std_logic_vector(3 downto 0);
    i_rxfifo_data1    : in  std_logic_vector(31 downto 0);
    --Output channel
    i_output_next      : in  std_logic; --backpressure
    o_output_valid    : out std_logic;
    o_output_charisk  : out std_logic_vector(3 downto 0);
    o_output_data     : out std_logic_vector(31 downto 0)
);
end entity ibfb_packet_filter;

architecture rtl of ibfb_packet_filter is

component ram_infer is
generic(
    ADDR_W : natural := 12;
    DATA_W : natural := 36 
);
port(
    clk   : in std_logic;
    --port1 (read/write)
    en  : in std_logic;
    we  : in std_logic;
    addr : in std_logic_vector(ADDR_W-1 downto 0);
    di  : in std_logic_vector(DATA_W-1 downto 0);
    do : out std_logic_vector(DATA_W-1 downto 0)
);
end component ram_infer;

signal chan : std_logic;
signal s    : unsigned(3 downto 0);
signal sop, eop, nxt, valid, ovalid : std_logic;
signal isk : std_logic_vector(3 downto 0);
signal b0, b1, b2, b3 : std_logic_vector(7 downto 0);

signal trig_r : std_logic_vector(3 downto 0);
signal ctrl, bpm : std_logic_vector(7 downto 0);
signal bucket : std_logic_vector(15 downto 0);
signal reset_addr : unsigned(11 downto 0);
signal filt : natural range 0 to 255;
signal pkt_valid, pkt_discard, switch_channel : std_logic;

constant BKT_BITS : natural := 12; --bits needed to count 2700 buckets
constant BPM_N : natural := 2**BPM_BITS;
constant ZERO : std_logic_vector(BPM_N-1 downto 0) := (others => '0');
constant LAST_ADDR : unsigned(11 downto 0) := (others => '1');
--
signal flag, reset_flags, flag_update : std_logic;
signal flag_set : std_logic_vector(0 downto 0);
signal bpm_mask, flag_write_v, flag_v, flag_m : std_logic_vector(BPM_N-1 downto 0);
signal flag_addr : std_logic_vector(BKT_BITS-1 downto 0);
signal oreg_full, next_s : std_logic;

signal bpm_id : bpm_id_t; --allowed BPM ids 

begin

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
valid <= not i_rxfifo_empty0 when chan = '0' else 
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
        if (i_rst = '1' or reset_flags = '1') then
            s <= (others => '1');
        else
            case s is
            when X"0" =>
                flag_update <= '0';
                if valid = '1' and sop = '1' then
                    ctrl <= b1;
                    bpm  <= b0;
                    if next_s = '1' then --advance only when data is sampled
                        s <= s+1;
                    end if;
                else
                    chan <= not chan;
                end if;
            when X"1" =>
                if valid = '1' then
                    bucket <= b2 & b3;
                    --xpos(15 downto 0) <= b0 & b1;
                    if next_s = '1' then
                        s <= s+1;
                    end if;
                end if;
            when X"2" =>
                if valid = '1' then
                    --xpos(31 downto 16) <= b2 & b3;
                    --ypos(15 downto  0) <= b0 & b1;
                    if next_s = '1' then
                        s <= s+1;
                    end if;
                end if;
            when X"3" =>
                if valid = '1' then
                    --ypos(31 downto 16) <= b2 & b3;
                    --crc <= b1;
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


--check whether bpm code matches one of the allowed ones
--Result is a mask vector when only 1 bit is asserted (i_BPM_id values shall be unique)
BPM_ID_REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        bpm_id <= i_bpm_id;
    end if;
end process;

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
    FLAG_RAM_i : ram_infer
    generic map(
        ADDR_W => BKT_BITS,
        DATA_W => 1
    )
    port map(
        clk  => i_clk,
        en   => '1',
        --port1 (read/write)
        we   => flag_write_v(i),
        addr => flag_addr,
        di   => flag_set, --same for all. control via flag_write_v
        do(0)=> flag_v(i)
    );
end generate;

--mask flag values according to the active BPM
FLAG_M_GEN : for i in flag_m'range generate
    flag_m(i) <= flag_v(i) and bpm_mask(i);
end generate;
flag   <= '0' when flag_m = ZERO else '1'; --OR-reduce

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

--discard a packet when the flag is already set OR when BPM does not match
--(meaning that a packet has already been forwarded with the same filtering field value)
pkt_valid <= '1' when s = X"3" and eop = '1' else
             '0';
pkt_discard <= '1' when (pkt_valid = '1') and ((flag = '1') or (bpm_mask = ZERO)) else '0';

--Data not valid when:
--    <valid> signal is low OR
--    expecting SOP and other data is received OR
--    downstream component not ready
--garbage <= '1' when (valid = '0') or ((s = X"0") and (sop = '0')) or (i_output_next = '0') else '0';
ovalid <= '0' when (valid = '0') or ( s = X"0" and sop = '0') else '1';

--control outputs
OUT_REG : process(i_clk)
begin
    if rising_edge(i_clk) then
        if (i_rst = '1') then
            --o_output_valid <= '0';
            oreg_full <= '0';
        else
            if oreg_full = '0' then --outreg empty
                if ovalid = '1' then --data available
                    --load output register
                    oreg_full <= '1';
                    --o_output_valid   <= ovalid; --all valid data, except bad SOPs
                    o_output_charisk <= isk;
                    o_output_data(31 downto 8) <= b3&b2&b1;
                    if pkt_discard = '1' then --valid packet, flag set
                        --replace EOP with
                        --o_output_data <= b3&b2&b1&K_BAD;
                        o_output_data(7 downto 0) <= K_BAD;
                    else
                        --o_output_data <= b3&b2&b1&b0;
                        o_output_data(7 downto 0) <= b0;
                    end if;
                --else: do nothing
                end if;
            else -- oreg_full = '1'
                if i_output_next = '1' then --reading output register
                    if ovalid = '1' then --data available: reload register
                        o_output_charisk <= isk;
                        o_output_data(31 downto 8) <= b3&b2&b1;
                        if pkt_discard = '1' then --valid packet, flag set
                            --replace EOP with
                            --o_output_data <= b3&b2&b1&K_BAD;
                            o_output_data(7 downto 0) <= K_BAD;
                        else
                            --o_output_data <= b3&b2&b1&b0;
                            o_output_data(7 downto 0) <= b0;
                        end if;
                    else --no data available: empty register
                        oreg_full <= '0';
                    end if;
                --else --oreg_full and no data request: do nothing
                end if;
            end if;
        end if;
    end if;
end process;

o_output_valid <= oreg_full;
next_s <= (not oreg_full) or (oreg_full and i_output_next);

o_pkt_valid   <= pkt_valid;
o_pkt_discard <= pkt_discard;

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
            when others =>
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
    N_INPUT_PORTS  : natural := 2;
    N_OUTPUT_PORTS : natural := 1
);
port(
    i_clk     : in  std_logic;
    i_rst     : in  std_logic;
    i_err_rst : in  std_logic;
    --input
    o_next    : out std_logic_vector(0 to N_INPUT_PORTS-1);
    i_valid   : in  std_logic_vector(0 to N_INPUT_PORTS-1);
    i_charisk : in  array4(0 to N_INPUT_PORTS-1);
    i_data    : in  array32(0 to N_INPUT_PORTS-1);
    --output
    i_next    : in  std_logic_vector(0 to N_OUTPUT_PORTS-1);
    o_valid   : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
    o_err     : out std_logic_vector(0 to N_OUTPUT_PORTS-1);
    o_charisk : out array4(0 to N_OUTPUT_PORTS-1);
    o_data    : out array32(0 to N_OUTPUT_PORTS-1)
);
end entity ibfb_packet_router;

architecture rtl of ibfb_packet_router is

constant ZERO     : std_logic_vector(0 to N_INPUT_PORTS-1) := (others => '0');

signal in_next    : std_logic_vector(0 to N_INPUT_PORTS-1);
signal in_valid   : std_logic_vector(0 to N_INPUT_PORTS-1);
signal in_charisk : array4(0 to N_INPUT_PORTS-1);
signal in_data    : array32(0 to N_INPUT_PORTS-1);

signal in_port : natural range 0 to N_INPUT_PORTS-1;
signal nxt : std_logic;
signal s : natural range 0 to 3;

signal ovalid : std_logic_vector(0 to N_OUTPUT_PORTS-1);

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
                    s <= s+1;
                else --if no data available, try next port
                    if in_port = N_INPUT_PORTS-1 then
                        in_port <= 0;
                    else
                        in_port <= in_port+1;
                    end if;
                end if;
            when 1 | 2 =>
                if in_valid(in_port) = '1' then
                    s <= s+1;
                end if;
            --when 3 =>
            when others =>
                if in_valid(in_port) = '1' then
                    if (in_valid /= ZERO) then --change port only if there's data available on other ports
                        if in_port = N_INPUT_PORTS-1 then
                            in_port <= 0;
                        else
                            in_port <= in_port+1;
                        end if;
                    end if;
                    s <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--Connect currently selected input channel to all output channels
--No backpressure supported: if output channels are not available, data is lost
OUT_REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        for i in 0 to N_OUTPUT_PORTS-1 loop
            ovalid(i)    <= in_next(in_port);
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


end architecture rtl; --of ibfb_packet_router
