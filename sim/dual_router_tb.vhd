library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

use work.ibfb_comm_package.all;

---------------------------------------------------------------------------------------
-- ENTITY -----------------------------------------------------------------------------
---------------------------------------------------------------------------------------
entity dual_router_tb is
end entity dual_router_tb;

---------------------------------------------------------------------------------------
-- ARCHITECTURE -----------------------------------------------------------------------
---------------------------------------------------------------------------------------
architecture test of dual_router_tb is

component throughput_meter is
generic(
    CLK_FREQ_HZ     : real; --clock frequency
    DATA_WIDTH_BITS : real --width of the data bus
);
port(
    i_clk, i_rst : in std_logic;
    i_data_valid : in std_logic;
    o_bpc_max    : out real; 
    o_bps_max    : out real; 
    o_bpc        : out real; --bits per clock cycle
    o_bps        : out real  --bits per second
);
end component throughput_meter;

---------------------------------------------------------------------------------------
-- CONSTANTS --------------------------------------------------------------------------
---------------------------------------------------------------------------------------
constant K_SOP : std_logic_vector(7 downto 0) := X"FA";
constant K_EOP : std_logic_vector(7 downto 0) := X"FB";
constant K_BAD : std_logic_vector(7 downto 0) := X"FC";

---------------------------------------------------------------------------------------
-- SIGNALS ----------------------------------------------------------------------------
---------------------------------------------------------------------------------------
signal clk, clk2, rst, rst_n, btrig, ktrig_4x, ktrig_3x, ktrig_2x, ktrig_1x : std_logic := '0';
signal f02_btrig, f02_ktrig : std_logic;
signal  x0_btrig,  x0_ktrig : std_logic;
signal  x1_btrig,  x1_ktrig : std_logic;
signal  y0_btrig,  y0_ktrig : std_logic;
signal  y1_btrig,  y1_ktrig : std_logic;

signal good_bpm_id : bpm_id_t; --allowed BPM ids (0,1 => X, 2,3 => Y)

signal f02_en, x0_en, x1_en, y0_en, y1_en : std_logic;
signal fs0, xs0, xs1, ys0, ys1 : natural;
signal cnt_fs0, cnt_x0, cnt_x1, cnt_y0, cnt_y1 : natural;
signal pg0_bpm : unsigned(7 downto 0);
signal pg0_bkt, x0_bkt, x1_bkt, y0_bkt, y1_bkt : unsigned(15 downto 0);

signal pg0_in_sample, pg0_in_busy, pg0_in_valid : std_logic;
signal pg0_in_data : ibfb_comm_packet;
signal pg0_out_full, pg0_out_valid : std_logic;
signal pg0_out_isk : std_logic_vector(3 downto 0);
signal pg0_out_data : std_logic_vector(31 downto 0);

signal gen0_fifo_next, gen0_fifo_empty : std_logic;
signal gen0_fifo_isk : std_logic_vector(3 downto 0);
signal gen0_fifo_data : std_logic_vector(31 downto 0);
signal gen1_fifo_next, gen1_fifo_empty : std_logic;
signal gen1_fifo_isk : std_logic_vector(3 downto 0);
signal gen1_fifo_data : std_logic_vector(31 downto 0);

signal x0_in_sample, x0_in_busy, x0_in_valid : std_logic;
signal x0_in_data : ibfb_comm_packet;
signal x0_out_full, x0_out_valid : std_logic;
signal x0_out_isk : std_logic_vector(3 downto 0);
signal x0_out_data : std_logic_vector(31 downto 0);

signal x1_in_sample, x1_in_busy, x1_in_valid : std_logic;
signal x1_in_data : ibfb_comm_packet;
signal x1_out_full, x1_out_valid : std_logic;
signal x1_out_isk : std_logic_vector(3 downto 0);
signal x1_out_data : std_logic_vector(31 downto 0);

signal y0_in_sample, y0_in_busy, y0_in_valid : std_logic;
signal y0_in_data : ibfb_comm_packet;
signal y0_out_full, y0_out_valid : std_logic;
signal y0_out_isk : std_logic_vector(3 downto 0);
signal y0_out_data : std_logic_vector(31 downto 0);

signal y1_in_sample, y1_in_busy, y1_in_valid : std_logic;
signal y1_in_data : ibfb_comm_packet;
signal y1_out_full, y1_out_valid : std_logic;
signal y1_bpm : unsigned(7 downto 0);
signal y1_out_isk : std_logic_vector(3 downto 0);
signal y1_out_data : std_logic_vector(31 downto 0);

signal f02_resetting, f02_pkt_valid, f02_pkt_discard_x, f02_pkt_discard_y : std_logic;

signal f02_in0_next, f02_in0_empty, f02_in1_next, f02_in1_empty : std_logic;
signal f02_in0_isk, f02_in1_isk : std_logic_vector(3 downto 0);
signal f02_in0_data, f02_in1_data : std_logic_vector(31 downto 0);

signal f02_out0_full, f02_out0_write, f02_out1_full, f02_out1_write : std_logic;
signal f02_out0_isk, f02_out1_isk : std_logic_vector(3 downto 0);
signal f02_out0_data, f02_out1_data : std_logic_vector(31 downto 0);
signal f02_ping_en0, f02_ping_en1, f02_ping_rx0, f02_ping_rx1 : std_logic;
signal f02_ping_lat0, f02_ping_lat1 : std_logic_vector(31 downto 0);

signal ping0_fifo_empty, ping0_fifo_next, ping1_fifo_empty, ping1_fifo_next : std_logic;
signal ping0_fifo_isk, ping1_fifo_isk : std_logic_vector(3 downto 0);
signal ping0_fifo_data, ping1_fifo_data : std_logic_vector(31 downto 0);
signal ping0_dly_cnt, ping1_dly_cnt : natural;
signal ping0_fifo_empty_d, ping1_fifo_empty_d : std_logic;

signal xr_in_empty   : std_logic_vector(0 to 2);
signal xr_in_next    : std_logic_vector(0 to 2);
signal xr_in_valid   : std_logic_vector(0 to 2);
signal xr_in_isk     : array4(0 to 2);
signal xr_in_data    : array32(0 to 2);

signal xr_out_full    : std_logic;
signal xr_out_next    : std_logic_vector(0 to 0);
signal xr_out_valid   : std_logic_vector(0 to 0);
signal xr_out_err     : std_logic_vector(0 to 0);
signal xr_out_isk     : array4(0 to 0);
signal xr_out_data    : array32(0 to 0);

signal yr_in_empty   : std_logic_vector(0 to 2);
signal yr_in_next    : std_logic_vector(0 to 2);
signal yr_in_valid   : std_logic_vector(0 to 2);
signal yr_in_isk     : array4(0 to 2);
signal yr_in_data    : array32(0 to 2);

signal yr_out_full    : std_logic;
signal yr_out_next    : std_logic_vector(0 to 0);
signal yr_out_valid   : std_logic_vector(0 to 0);
signal yr_out_err     : std_logic_vector(0 to 0);
signal yr_out_isk     : array4(0 to 0);
signal yr_out_data    : array32(0 to 0);

signal ofifo_x_empty, ofifo_x_next, ofifo_x_valid : std_logic;
signal ofifo_x_isk  : std_logic_vector(3 downto 0);
signal ofifo_x_data : std_logic_vector(31 downto 0);
signal ofifo_y_empty, ofifo_y_next, ofifo_y_valid : std_logic;
signal ofifo_y_isk  : std_logic_vector(3 downto 0);
signal ofifo_y_data : std_logic_vector(31 downto 0);

signal xout_bad, xout_eop, xout_good, xout_error : std_logic;
signal xout_packet : ibfb_comm_packet;
signal yout_bad, yout_eop, yout_good, yout_error : std_logic;
signal yout_packet : ibfb_comm_packet;

signal bpm1_xcnt, bpm2_xcnt, bpm3_xcnt, bpm4_xcnt : natural;
signal bpm5_xcnt, bpm6_xcnt, bpm7_xcnt, bpm8_xcnt, bpm9_xcnt, bpmA_xcnt : natural;
signal bpm1_ycnt, bpm2_ycnt, bpm3_ycnt, bpm4_ycnt : natural;
signal bpm5_ycnt, bpm6_ycnt, bpm7_ycnt, bpm8_ycnt, bpm9_ycnt, bpmA_ycnt : natural;

signal fifo_cnt_f02, fifo_cnt_x0, fifo_cnt_x1, fifo_cnt_y0, fifo_cnt_y1 : natural;
signal fifo_wcnt_f02, fifo_wcnt_x0, fifo_wcnt_x1, fifo_wcnt_y0, fifo_wcnt_y1 : natural;
signal f02_in_cnt, xr_in_cnt0, xr_in_cnt1, xr_in_cnt2, yr_in_cnt0, yr_in_cnt1, yr_in_cnt2 : natural;
signal xr_out_cnt, yr_out_cnt : natural;
signal ofifo_x_cnt, ofifo_y_cnt : integer;
signal ofifo_x_wcnt, ofifo_y_wcnt : integer;
signal ofifo_x_rcnt, ofifo_y_rcnt : integer;

signal bpc_gen_filt, bps_gen_filt : real;
signal bpc_gen_x0,   bps_gen_x0   : real;
signal bpc_gen_x1,   bps_gen_x1   : real;
signal bpc_gen_y0,   bps_gen_y0   : real;
signal bpc_gen_y1,   bps_gen_y1   : real;
signal bpc_pkt_filt, bps_pkt_filt : real;
signal bpc_pkt_x0,   bps_pkt_x0   : real;
signal bpc_pkt_x1,   bps_pkt_x1   : real;
signal bpc_pkt_y0,   bps_pkt_y0   : real;
signal bpc_pkt_y1,   bps_pkt_y1   : real;
signal bpc_filt_in,  bps_filt_in  : real;
signal bpc_xr_in0, bps_xr_in0 : real;
signal bpc_xr_in1, bps_xr_in1 : real;
signal bpc_xr_in2, bps_xr_in2 : real;
signal bpc_yr_in0, bps_yr_in0 : real;
signal bpc_yr_in1, bps_yr_in1 : real;
signal bpc_yr_in2, bps_yr_in2 : real;
signal bpc_xr_out, bps_xr_out : real;
signal bpc_yr_out, bps_yr_out : real;
signal bpc_ofifo_x, bps_ofifo_x : real;
signal bpc_ofifo_y, bps_ofifo_y : real;
signal bpc_opkt_x, bps_opkt_x : real;
signal bpc_opkt_y, bps_opkt_y : real;

constant T125M : time := 8.0 ns;
constant T156M : time := 6.4 ns;
constant T166M : time := 6.0 ns;
constant T200M : time := 5 ns;
constant T216M : time := 4.6153 ns;
constant T250M : time := 4 ns;

constant CLK_FREQ  : real := 1000.0/6.0;
constant CLK2_FREQ : real := 1000.0/4.0;

constant TEST_PING : std_logic := '0';

constant routing_table : array32(0 to 3-1) := (X"FFFFFFFF",X"FFFFFFFF",X"FFFFFFFF");

signal gen1_fifo_empty_c : std_logic;
signal mask_cnt : natural;

begin

---------------------------------------------------------------------------------------
-- GLOBAL SIGNALS ---------------------------------------------------------------------
---------------------------------------------------------------------------------------

--generate clocks: clk=>logic, clk2=>output FIFOs
clk  <= '1' after T216M/2 when clk = '0' else
        '0' after T216M/2;
clk2 <= '1' after T216M/2 when clk2 = '0' else
        '0' after T216M/2;
rst     <= '1', '0' after 1 us;
rst_n   <= not rst;

--Generate bunch trigger
--Minimun repetition: 2700*222 ns = 599.4 us
--Start delay (trig to 1st bunch) at least 18 us
process
begin
    btrig <= '0';
    wait for 100 us;
    btrig <= '1';
    wait for 100 ns;
    btrig <= '0';
    wait for 899 us;
end process;

--generate various packet triggers
--1x: 1 packet  per bucket
--2x: 2 packets per bucket
--3x: 3 packets per bucket
--4x: 4 packets per bucket
ktrig_4x <= '1' after 45.5 ns when ktrig_4x = '0' else
            '0' after 10 ns; --55.5 (222/4)
ktrig_3x <= '1' after 64 ns when ktrig_3x = '0' else
            '0' after 10 ns; --74 (222/3)
ktrig_2x <= '1' after 101 ns when ktrig_2x = '0' else
            '0' after 10 ns; --111 (222/2)
ktrig_1x <= '1' after 212 ns when ktrig_1x = '0' else
            '0' after 10 ns; --111 (222/2)

--assign bunch trigger to different sources with different start delays
f02_btrig <= transport btrig after 0 ns;
 x0_btrig <= transport btrig after 50 ns;
 y0_btrig <= transport btrig after 60 ns;
 x1_btrig <= transport btrig after 150 ns;
 y1_btrig <= transport btrig after 160 ns;

--assign proper packet triggers
f02_ktrig <= ktrig_4x; --filter: 4 BPM => 4 packets per bucket
 x0_ktrig <= ktrig_2x; --X0: from 2nd filter, X-only
 y0_ktrig <= ktrig_2x; --Y0: from 2nd filter, Y-only
 x1_ktrig <= ktrig_2x; --X1: from filter in other FPGA, X-only
 y1_ktrig <= ktrig_3x when y1_bkt > X"0708" else --Y1: from filter and collimator BPM in other FPGA
             ktrig_1x;

--Enable data sources as needed
f02_en <= '1';
x0_en <= '1';
x1_en <= '1';
y0_en <= '1';
y1_en <= '1';

---------------------------------------------------------------------------------------
-- SETTINGS ---------------------------------------------------------------------------
---------------------------------------------------------------------------------------
good_bpm_id(0) <= X"01"; --X
good_bpm_id(1) <= X"02"; --X
good_bpm_id(2) <= X"03"; --Y
good_bpm_id(3) <= X"04"; --Y

---------------------------------------------------------------------------------------
-- DATA GENERATION --------------------------------------------------------------------
---------------------------------------------------------------------------------------

--To filter02: 2700/3=900 buckets every bunch from 4 BPMs => 3600 packets 
--Pattern: Two X positions (bpm_id 1,2) and two Y positions (bpm_id 3,4)
FILT_DATA_GEN : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fs0 <= 3;
        else
            case fs0 is
                when 0 => --wait at least 18 us (let the filter reset)
                    if cnt_fs0 = 2800 then
                        if f02_resetting = '0' then
                            cnt_fs0 <= 0;
                            fs0     <= 1;
                        end if;
                    else
                        cnt_fs0 <= cnt_fs0+1;
                    end if;
                when 1 => --
                    if f02_ktrig = '1' and pg0_in_busy = '0' then
                        --assign data
                        pg0_in_valid <= '1';
                        pg0_in_data.bpm    <= std_logic_vector(pg0_bpm);
                        pg0_in_data.bucket <= std_logic_vector(pg0_bkt);

                        if pg0_bpm < X"03" then
                            --X-data (BPM ID = 1,2)
                            pg0_in_data.ctrl <= X"01"; --Xvalid
                            pg0_in_data.xpos <= X"AAAAAAAA";
                            pg0_in_data.ypos <= X"00000000";
                        else
                            --Y-data (BPM ID = 3,4)
                            pg0_in_data.ctrl <= X"02"; --Yvalid
                            pg0_in_data.xpos <= X"00000000";
                            pg0_in_data.ypos <= X"AAAAAAAA";
                        end if;

                        fs0 <= 2;
                    end if;
                when 2 =>
                    pg0_in_valid <= '0';

                    if f02_ktrig = '0' and pg0_in_busy = '0' then --ready to go on
                        if pg0_bpm = X"04" then --end of bucket (4 BPMs sent)
                            pg0_bpm <= X"01"; --reset BPM id
                            if pg0_bkt = X"0384" then --900: one third of the bucket range
                                pg0_bkt <= X"0001";
                                fs0 <= 3; --end of train
                            else --next bucket
                                pg0_bkt <= pg0_bkt+1;
                                fs0 <= 1; --next bucket
                            end if;
                        else --same bucket, next BPM
                            pg0_bpm <= pg0_bpm+1;
                            fs0 <= 1;
                        end if;
                    end if;
            when others =>
                --wait for trigger or reset
                cnt_fs0 <= 0;
                pg0_bpm <= X"01";
                pg0_bkt <= X"0001";
                pg0_in_valid <= '0';
                pg0_in_data.ctrl   <= (others => '0');
                pg0_in_data.bpm    <= (others => '0');
                pg0_in_data.bucket <= (others => '0');
                pg0_in_data.xpos   <= (others => '0');
                pg0_in_data.ypos   <= (others => '0');
                pg0_in_data.crc    <= (others => '0');
                if f02_btrig = '1' and f02_en = '1' then
                    fs0 <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--To Xrouter input 1: 2700/3 buckets every bunch, 2 packets per bucket => 1800 packets. 
--Pattern: only X positions (bpm id 5)
X0_DATA_GEN : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            xs0 <= 3;
        else
            case xs0 is
                when 0 => --wait at least 18 us (let the filter reset)
                    if cnt_x0 = 2800 then
                        cnt_x0 <= 0;
                        xs0     <= 1;
                    else
                        cnt_x0 <= cnt_x0+1;
                    end if;
                when 1 => --
                    if x0_ktrig = '1' and x0_in_busy = '0' then
                        --assign data
                        if x0_bkt > X"0708" and x0_bkt <= X"0E10" then --buckets 1801:3600 (901 to 1800
                            x0_in_valid <= '1';
                        else
                            x0_in_valid <= '0';
                        end if;
                        x0_in_data.bpm    <= X"05";
                        x0_in_data.bucket <= std_logic_vector('0' & x0_bkt(x0_bkt'left downto 1));

                        --X-data
                        x0_in_data.ctrl <= X"01";
                        if (x0_bkt(0) = '0') then
                            x0_in_data.xpos <= X"BBBB0000";
                        else
                            x0_in_data.xpos <= X"BBBB1111";
                        end if;
                        x0_in_data.ypos <= X"00000000";

                        xs0 <= 2;
                    end if;
                when 2 =>
                    x0_in_valid <= '0';

                    if x0_ktrig = '0' and x0_in_busy = '0' then
                        if x0_bkt = X"1518" then
                            x0_bkt <= X"0001";
                            xs0 <= 3; --end of train
                        else
                            x0_bkt <= x0_bkt+1;
                            xs0 <= 1; --next bucket
                        end if;
                    end if;
            when others =>
                --wait for trigger or reset
                cnt_x0 <= 0;
                x0_bkt <= X"0001";
                x0_in_valid <= '0';
                x0_in_data.ctrl   <= (others => '0');
                x0_in_data.bpm    <= (others => '0');
                x0_in_data.bucket <= (others => '0');
                x0_in_data.xpos   <= (others => '0');
                x0_in_data.ypos   <= (others => '0');
                x0_in_data.crc    <= (others => '0');
                if x0_btrig = '1' and x0_en = '1' then
                    xs0 <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--To Xrouter input 2: 2700/3 buckets every bunch => 1800 packets
--Pattern: only X positions (bpm id 6)
X1_DATA_GEN : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            xs1    <= 3;
        else
            case xs1 is
                when 0 => --wait at least 18 us (let the filter reset)
                    if cnt_x1 = 2800 then
                        cnt_x1 <= 0;
                        xs1     <= 1;
                    else
                        cnt_x1 <= cnt_x1+1;
                    end if;
                when 1 => --
                    if x1_ktrig = '1' and x1_in_busy = '0' then
                        --assign data
                        if x1_bkt > X"0E10" then --buckets 1801 to 2700    
                            x1_in_valid <= '1';
                        end if;
                        x1_in_data.bpm    <= X"06";
                        x1_in_data.bucket <= std_logic_vector('0' & x1_bkt(x1_bkt'left downto 1));

                        --X-data
                        x1_in_data.ctrl <= X"01";
                        if (x0_bkt(0) = '0') then
                            x1_in_data.xpos <= X"CCCC0000";
                        else
                            x1_in_data.xpos <= X"CCCC1111";
                        end if;
                        x1_in_data.ypos <= X"00000000";

                        xs1 <= 2;
                    end if;
                when 2 =>
                    x1_in_valid <= '0';

                    if x1_ktrig = '0' and x1_in_busy = '0' then
                        if x1_bkt = X"1518" then
                            x1_bkt <= X"0001";
                            xs1 <= 3; --end of train
                        else
                            x1_bkt <= x1_bkt+1;
                            xs1 <= 1; --next bucket
                        end if;
                    end if;
            when others =>
                --wait for trigger or reset
                cnt_x1 <= 0;
                x1_bkt <= X"0001";
                x1_in_valid <= '0';
                x1_in_data.ctrl   <= (others => '0');
                x1_in_data.bpm    <= (others => '0');
                x1_in_data.bucket <= (others => '0');
                x1_in_data.xpos   <= (others => '0');
                x1_in_data.ypos   <= (others => '0');
                x1_in_data.crc    <= (others => '0');
                if x1_btrig = '1' and x1_en = '1' then 
                    xs1 <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--To Yrouter input 1: 2700/3 buckets every bunch => 1800 packets
--Pattern: only Y positions (bpm id 7)
Y0_DATA_GEN : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            ys0    <= 3;
        else
            case ys0 is
                when 0 => --wait at least 18 us (let the filter reset)
                    if cnt_y0 = 2800 then
                        cnt_y0 <= 0;
                        ys0     <= 1;
                    else
                        cnt_y0 <= cnt_y0+1;
                    end if;
                when 1 => --
                    if y0_ktrig = '1' and y0_in_busy = '0' then
                        --assign data
                        if y0_bkt > X"0708" and y0_bkt <= X"0E10" then --buckets 901 to 1800
                            y0_in_valid <= '1';
                        else
                            y0_in_valid <= '0';
                        end if;

                        y0_in_data.bpm    <= X"07";
                        y0_in_data.bucket <= std_logic_vector('0' & y0_bkt(y0_bkt'left downto 1));

                        --Y-data
                        y0_in_data.ctrl <= X"02";
                        y0_in_data.xpos <= X"00000000";
                        if (y0_bkt(0) = '0') then
                            y0_in_data.ypos <= X"DDDD0000";
                        else
                            y0_in_data.ypos <= X"DDDD1111";
                        end if;

                        ys0 <= 2;
                    end if;
                when 2 =>
                    y0_in_valid <= '0';

                    if y0_ktrig = '0' and y0_in_busy = '0' then
                        if y0_bkt = X"1518" then
                            y0_bkt <= X"0001";
                            ys0 <= 3; --end of train
                        else
                            y0_bkt <= y0_bkt+1;
                            ys0 <= 1; --next bucket
                        end if;
                    end if;
            when others =>
                --wait for trigger or reset
                cnt_y0 <= 0;
                y0_bkt <= X"0001";
                y0_in_valid <= '0';
                y0_in_data.ctrl   <= (others => '0');
                y0_in_data.bpm    <= (others => '0');
                y0_in_data.bucket <= (others => '0');
                y0_in_data.xpos   <= (others => '0');
                y0_in_data.ypos   <= (others => '0');
                y0_in_data.crc    <= (others => '0');
                if y0_btrig = '1'and y0_en = '1'  then
                    ys0 <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

--To Yrouter input 2: 3 BPM => 1800 packets from filter + 2700 from collimator
--Pattern: only Y positions (bpm id 8)
Y1_DATA_GEN : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            ys1    <= 3;
        else
            case ys1 is
                when 0 => --wait at least 18 us (let the filter reset)
                    if cnt_y1 = 2800 then
                        cnt_y1 <= 0;
                        ys1     <= 1;
                    else
                        cnt_y1 <= cnt_y1+1;
                    end if;
                when 1 => --
                    if y1_bkt > X"0708" and y1_bkt <= X"0A8C" then --3 packets per bucket
                        if ktrig_3x = '1' and y1_in_busy = '0' then
                            --assign data
                            y1_in_valid <= '1';
                            y1_in_data.bpm    <= std_logic_vector(y1_bpm);
                            y1_in_data.bucket <= std_logic_vector(y1_bkt);

                            --Y-data
                            y1_in_data.ctrl <= X"02";
                            y1_in_data.xpos <= X"00000000";
                            y1_in_data.ypos <= X"EEEE0000";

                            ys1 <= 2;
                        end if;
                    else --1 packet per bucket
                        if ktrig_1x = '1' and y1_in_busy = '0' then
                            --assign data
                            y1_in_valid <= '1';
                            y1_in_data.bpm    <= X"0A";
                            y1_in_data.bucket <= std_logic_vector(y1_bkt);

                            --Y-data
                            y1_in_data.ctrl <= X"02";
                            y1_in_data.xpos <= X"00000000";
                            y1_in_data.ypos <= X"EEEE1111";

                            ys1 <= 2;
                        end if;
                    end if;
                when 2 =>
                    y1_in_valid <= '0';

                    if y1_bkt > X"0708" and y1_bkt <= X"0A8C" then --3 packets per bucket
                        if ktrig_3x = '0' and y1_in_busy = '0' then
                            if y1_bpm = X"09" then --end of bucket
                                y1_bpm <= X"0A"; --reset BPM id
                                if y1_bkt = X"0A8C" then
                                    y1_bkt <= X"0001";
                                    ys1 <= 3; --end of train
                                else
                                    y1_bkt <= y1_bkt+1;
                                    ys1 <= 1; --next bucket
                                end if;
                            else --same bucket, next BPM
                                if y1_bpm = X"0A" then
                                    y1_bpm <= X"08";
                                else --08
                                    y1_bpm <= X"09";
                                end if;
                                ys1 <= 1;
                            end if;
                        end if;
                    else --1 packet per bucket
                        if ktrig_1x = '0' and y1_in_busy = '0' then
                            y1_bkt <= y1_bkt+1;
                            y1_bpm <= X"0A";
                            ys1 <= 1;
                        end if;
                    end if;
            when others =>
                --wait for trigger or reset
                cnt_y1 <= 0;
                y1_bkt <= X"0001";
                y1_bpm <= X"0A";
                y1_in_valid <= '0';
                y1_in_data.ctrl   <= (others => '0');
                y1_in_data.bpm    <= (others => '0');
                y1_in_data.bucket <= (others => '0');
                y1_in_data.xpos   <= (others => '0');
                y1_in_data.ypos   <= (others => '0');
                y1_in_data.crc    <= (others => '0');
                if y1_btrig = '1' and y1_en = '1' then
                    ys1 <= 0;
                end if;
            end case;
        end if;
    end if;
end process;

---------------------------------------------------------------------------------------
-- PACKET TRANSMITTERS ----------------------------------------------------------------
---------------------------------------------------------------------------------------

--Filter input
PG0 : ibfb_packet_tx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst       => rst,
    i_clk       => clk,
    --user interface
    o_sample    => pg0_in_sample,
    o_busy      => pg0_in_busy,
    i_tx_valid  => pg0_in_valid,
    i_tx_data   => pg0_in_data,
    --MGT FIFO interface
    i_fifo_full => pg0_out_full,
    o_valid     => pg0_out_valid,
    o_charisk   => pg0_out_isk,
    o_data      => pg0_out_data
);

PG0_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => pg0_out_full,
    ALMOSTFULL  => open,
    WREN        => pg0_out_valid,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => pg0_out_isk,
    DI          => pg0_out_data,
    --
    RDCLK       => clk,
    EMPTY       => gen0_fifo_empty,
    ALMOSTEMPTY => open,
    RDEN        => gen0_fifo_next,
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => gen0_fifo_isk,
    DO          => gen0_fifo_data
);

PG1_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => open, --pg0_out_full,
    ALMOSTFULL  => open,
    WREN        => pg0_out_valid,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => pg0_out_isk,
    DI          => pg0_out_data,
    --
    RDCLK       => clk,
    EMPTY       => gen1_fifo_empty_c,
    ALMOSTEMPTY => open,
    RDEN        => gen1_fifo_next,
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => gen1_fifo_isk,
    DO          => gen1_fifo_data
);

MASK_FIFO2 : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            mask_cnt <= 0;
        else
            if mask_cnt = 0 then --counter not started
                if gen0_fifo_empty = '0' then
                    mask_cnt <= 1; --start counter
                end if;
            else
                mask_cnt <= mask_cnt+1;
            end if;
        end if;
    end if;
end process;

gen1_fifo_empty <= gen1_fifo_empty_c when mask_cnt > 100 else
                   '1';


--X-Router input 1
X0 : ibfb_packet_tx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst       => rst,
    i_clk       => clk,
    --user interface
    o_sample    => x0_in_sample,
    o_busy      => x0_in_busy,
    i_tx_valid  => x0_in_valid,
    i_tx_data   => x0_in_data,
    --MGT FIFO interface
    i_fifo_full => x0_out_full,
    o_valid     => x0_out_valid,
    o_charisk   => x0_out_isk,
    o_data      => x0_out_data
);

X0_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => x0_out_full,
    ALMOSTFULL  => open,
    WREN        => x0_out_valid,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => x0_out_isk,
    DI          => x0_out_data,
    --
    RDCLK       => clk,
    EMPTY       => xr_in_empty(1),
    ALMOSTEMPTY => open,
    RDEN        => xr_in_next(1),
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => xr_in_isk(1),
    DO          => xr_in_data(1)
);

xr_in_valid(1) <= not xr_in_empty(1);

--X-Router input 2
X1 : ibfb_packet_tx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst       => rst,
    i_clk       => clk,
    --user interface
    o_sample    => x1_in_sample,
    o_busy      => x1_in_busy,
    i_tx_valid  => x1_in_valid,
    i_tx_data   => x1_in_data,
    --MGT FIFO interface
    i_fifo_full => x1_out_full,
    o_valid     => x1_out_valid,
    o_charisk   => x1_out_isk,
    o_data      => x1_out_data
);

X1_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => x1_out_full,
    ALMOSTFULL  => open,
    WREN        => x1_out_valid,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => x1_out_isk,
    DI          => x1_out_data,
    --
    RDCLK       => clk,
    EMPTY       => xr_in_empty(2),
    ALMOSTEMPTY => open,
    RDEN        => xr_in_next(2),
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => xr_in_isk(2),
    DO          => xr_in_data(2)
);
xr_in_valid(2) <= not xr_in_empty(2);

--Y-Router input 1
Y0 : ibfb_packet_tx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst       => rst,
    i_clk       => clk,
    --user interface
    o_sample    => y0_in_sample,
    o_busy      => y0_in_busy,
    i_tx_valid  => y0_in_valid,
    i_tx_data   => y0_in_data,
    --MGT FIFO interface
    i_fifo_full => y0_out_full,
    o_valid     => y0_out_valid,
    o_charisk   => y0_out_isk,
    o_data      => y0_out_data
);

Y0_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => y0_out_full,
    ALMOSTFULL  => open,
    WREN        => y0_out_valid,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => y0_out_isk,
    DI          => y0_out_data,
    --
    RDCLK       => clk,
    EMPTY       => yr_in_empty(1),
    ALMOSTEMPTY => open,
    RDEN        => yr_in_next(1),
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => yr_in_isk(1),
    DO          => yr_in_data(1)
);
yr_in_valid(1) <= not yr_in_empty(1);

--Y-Router input 2
Y1 : ibfb_packet_tx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    EXTERNAL_CRC => '0'
)
port map(
    i_rst       => rst,
    i_clk       => clk,
    --user interface
    o_sample    => y1_in_sample,
    o_busy      => y1_in_busy,
    i_tx_valid  => y1_in_valid,
    i_tx_data   => y1_in_data,
    --MGT FIFO interface
    i_fifo_full => y1_out_full,
    o_valid     => y1_out_valid,
    o_charisk   => y1_out_isk,
    o_data      => y1_out_data
);

Y1_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => y1_out_full,
    ALMOSTFULL  => open,
    WREN        => y1_out_valid,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => y1_out_isk,
    DI          => y1_out_data,
    --
    RDCLK       => clk,
    EMPTY       => yr_in_empty(2),
    ALMOSTEMPTY => open,
    RDEN        => yr_in_next(2),
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => yr_in_isk(2),
    DO          => yr_in_data(2)
);
yr_in_valid(2) <= not yr_in_empty(2);

---------------------------------------------------------------------------------------
-- UNIT UNDER TEST --------------------------------------------------------------------
---------------------------------------------------------------------------------------

--connect filter inputs
gen0_fifo_next  <= f02_in0_next when TEST_PING = '0' 
                   else '0';
ping0_fifo_next <= f02_in0_next when TEST_PING = '1' 
                   else '0';

f02_in0_empty  <= gen0_fifo_empty when TEST_PING = '0' 
                  else ping0_fifo_empty_d;
f02_in0_isk    <= gen0_fifo_isk   when TEST_PING = '0' 
                  else ping0_fifo_isk;
f02_in0_data   <= gen0_fifo_data  when TEST_PING = '0' 
                  else ping0_fifo_data;

gen1_fifo_next  <= f02_in1_next when TEST_PING = '0' 
                   else '0';
ping1_fifo_next <= f02_in1_next when TEST_PING = '1'
                   else '0';

f02_in1_empty  <= gen1_fifo_empty when TEST_PING = '0' else 
                  ping1_fifo_empty_d;
f02_in1_isk    <= gen1_fifo_isk   when TEST_PING = '0' else
                  ping1_fifo_isk;
f02_in1_data   <= gen1_fifo_data  when TEST_PING = '0' else
                  ping1_fifo_data;

f02_ping_en0  <= '1';
f02_ping_en1  <= '1';

FILTER02 : ibfb_packet_filter
generic map(
    --protocol
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    K_BAD => K_BAD
)
port map(
    --debug
    o_flag_ram_wen   => open,
    o_flag_ram_waddr => open,
    o_flag_ram_wdata => open,
    --setup
    i_bpm_id         => good_bpm_id,
    i_bkt_min        => X"0000",
    i_bkt_max        => X"FFFF",
    --
    i_ping_enable0   => f02_ping_en0,
    i_ping_enable1   => f02_ping_en1,
    o_ping_rx0       => f02_ping_rx0,
    o_ping_rx1       => f02_ping_rx1,
    o_ping_latency0  => f02_ping_lat0,
    o_ping_latency1  => f02_ping_lat1,

    --
    i_ram_clk        => clk,
    i_ram_raddr      => X"000",
    o_ram_rdata      => open,
    --
    i_clk            => clk,
    i_rst            => rst,
    i_trig           => f02_btrig,
    o_resetting      => f02_resetting,
    o_pkt_valid      => f02_pkt_valid,
    o_pkt_discard_x  => f02_pkt_discard_x,
    o_pkt_discard_y  => f02_pkt_discard_y,
    --Input channel 0 (RXFIFO 0, FWFT)
    o_rxfifo_next0    => f02_in0_next,
    i_rxfifo_empty0   => f02_in0_empty,
    i_rxfifo_charisk0 => f02_in0_isk,
    i_rxfifo_data0    => f02_in0_data,
    --Input channel 1 (RXFIFO 1, FWFT)
    o_rxfifo_next1    => f02_in1_next,
    i_rxfifo_empty1   => f02_in1_empty,
    i_rxfifo_charisk1 => f02_in1_isk,
    i_rxfifo_data1    => f02_in1_data,
    --Output SFP channel 0 (TXFIFO 0) PING TRANSMISSION
    i_txfifo_full0    => f02_out0_full,
    o_txfifo_write0   => f02_out0_write,
    o_txfifo_charisk0 => f02_out0_isk,
    o_txfifo_data0    => f02_out0_data,
    --Output SFP channel 1 (TXFIFO 1) PING TRANSMISSION
    i_txfifo_full1    => f02_out1_full,
    o_txfifo_write1   => f02_out1_write,
    o_txfifo_charisk1 => f02_out1_isk,
    o_txfifo_data1    => f02_out1_data,
    --Output channel (FIFO interface, FWFT)
    i_output_next_x    => xr_in_next(0),
    o_output_valid_x   => xr_in_valid(0),
    o_output_charisk_x => xr_in_isk(0),
    o_output_data_x    => xr_in_data(0),
    i_output_next_y    => yr_in_next(0),
    o_output_valid_y   => yr_in_valid(0),
    o_output_charisk_y => yr_in_isk(0),
    o_output_data_y    => yr_in_data(0),
    --KW84, 08.08.2016
    o_statistics      => open
);

PING0_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => f02_out0_full,
    ALMOSTFULL  => open,
    WREN        => f02_out0_write,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => f02_out0_isk,
    DI          => f02_out0_data,
    --
    RDCLK       => clk,
    EMPTY       => ping0_fifo_empty,
    ALMOSTEMPTY => open,
    RDEN        => ping0_fifo_next,
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => ping0_fifo_isk,
    DO          => ping0_fifo_data
);

PING1_FIFO : FIFO36
generic map(
    DATA_WIDTH              => 36,
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => f02_out1_full,
    ALMOSTFULL  => open,
    WREN        => f02_out1_write,
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => f02_out1_isk,
    DI          => f02_out1_data,
    --
    RDCLK       => clk,
    EMPTY       => ping1_fifo_empty,
    ALMOSTEMPTY => open,
    RDEN        => ping1_fifo_next,
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => ping1_fifo_isk,
    DO          => ping1_fifo_data
);

DELAY_PING_P : process(clk, f02_btrig)
begin
    if rising_edge(f02_btrig) then
        ping0_dly_cnt <= 0;
        ping1_dly_cnt <= 0;
    elsif rising_edge(clk) then
        ping0_dly_cnt <= ping0_dly_cnt+1;
        ping1_dly_cnt <= ping1_dly_cnt+1;
    end if;
end process;

ping0_fifo_empty_d <= ping0_fifo_empty when ping0_dly_cnt > 10000 else '1';
ping1_fifo_empty_d <= ping1_fifo_empty when ping1_dly_cnt > 20000 else '1';

---------------------------------------------------------------------------------------
-- PACKET ROUTERS ---------------------------------------------------------------------
---------------------------------------------------------------------------------------
PACKET_ROUTER_X : ibfb_packet_router
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    N_INPUT_PORTS  => 3, --was 5 (changed in v2.00)
    N_OUTPUT_PORTS => 1 --was 2 (changed in v2.00)
    --ROUTING_TABLE => (X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", 
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF")
)
port map(
    i_clk     => clk,
    i_rst     => rst,
    i_err_rst => rst,
    i_out_en  => "1",
    i_routing_table => routing_table,
    --input (FIFO, FWFT)
    o_next    => xr_in_next,
    i_valid   => xr_in_valid,
    i_charisk => xr_in_isk,
    i_data    => xr_in_data,
    --output 
    i_next    => xr_out_next,
    o_valid   => xr_out_valid,
    o_err     => xr_out_err,
    o_charisk => xr_out_isk,
    o_data    => xr_out_data
);
xr_out_next(0) <= not xr_out_full;

PACKET_ROUTER_Y : ibfb_packet_router
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP,
    N_INPUT_PORTS  => 3, --was 5 (changed in v2.00)
    N_OUTPUT_PORTS => 1 --was 2 (changed in v2.00)
    --ROUTING_TABLE => (X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", 
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF",
    --                  X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF", X"FFFFFFFF")
)
port map(
    i_clk     => clk,
    i_rst     => rst,
    i_err_rst => rst,
    i_out_en  => "1",
    i_routing_table => routing_table,
    --input (FIFO, FWFT)
    o_next    => yr_in_next,
    i_valid   => yr_in_valid,
    i_charisk => yr_in_isk,
    i_data    => yr_in_data,
    --output 
    i_next    => yr_out_next,
    o_valid   => yr_out_valid,
    o_err     => yr_out_err,
    o_charisk => yr_out_isk,
    o_data    => yr_out_data
);
yr_out_next(0) <= not yr_out_full;

---------------------------------------------------------------------------------------
-- OUTPUT FIFOs -----------------------------------------------------------------------
---------------------------------------------------------------------------------------
OUTFIFO_X : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => xr_out_full,
    ALMOSTFULL  => open,
    WREN        => xr_out_valid(0),
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => xr_out_isk(0),
    DI          => xr_out_data(0),
    --
    RDCLK       => clk2,
    EMPTY       => ofifo_x_empty,
    ALMOSTEMPTY => open,
    RDEN        => ofifo_x_next,
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => ofifo_x_isk,
    DO          => ofifo_x_data
);
ofifo_x_valid <= not ofifo_x_empty;

OUTFIFO_Y : FIFO36
generic map(
    DATA_WIDTH              => 36,
    --ALMOST_FULL_OFFSET      : bit_vector := X"0080";
    --ALMOST_EMPTY_OFFSET     : bit_vector := X"0080";
    DO_REG                  => 1,
    EN_SYN                  => FALSE,
    FIRST_WORD_FALL_THROUGH => TRUE
)
port map(
    RST         => rst,
    --
    WRCLK       => clk,
    FULL        => yr_out_full,
    ALMOSTFULL  => open,
    WREN        => yr_out_valid(0),
    WRCOUNT     => open,
    WRERR       => open,
    DIP         => yr_out_isk(0),
    DI          => yr_out_data(0),
    --
    RDCLK       => clk2,
    EMPTY       => ofifo_y_empty,
    ALMOSTEMPTY => open,
    RDEN        => ofifo_y_next,
    RDCOUNT     => open,
    RDERR       => open,
    DOP         => ofifo_y_isk,
    DO          => ofifo_y_data
);
ofifo_y_valid <= not ofifo_y_empty;

---------------------------------------------------------------------------------------
-- PACKET RECEIVERS -------------------------------------------------------------------
---------------------------------------------------------------------------------------

X_PKT_RX : ibfb_packet_rx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP
)
port map(
    i_rst => rst,
    i_clk => clk2,
    --MGT FIFO interface
    o_next      => ofifo_x_next,
    i_valid     => ofifo_x_valid,
    i_charisk   => ofifo_x_isk,
    i_data      => ofifo_x_data,
    --user interface
    o_bad_data => xout_bad,
    o_eop      => xout_eop,
    o_crc_good => xout_good,
    o_rx_data  => xout_packet,
    --debug
    o_csp_clk   => open,
    o_csp_data  => open
 );
xout_error <= xout_bad and xout_eop;

Y_PKT_RX : ibfb_packet_rx
generic map(
    K_SOP => K_SOP,
    K_EOP => K_EOP
)
port map(
    i_rst => rst,
    i_clk => clk2,
    --MGT FIFO interface
    o_next      => ofifo_y_next,
    i_valid     => ofifo_y_valid,
    i_charisk   => ofifo_y_isk,
    i_data      => ofifo_y_data,
    --user interface
    o_bad_data => yout_bad,
    o_eop      => yout_eop,
    o_crc_good => yout_good,
    o_rx_data  => yout_packet,
    --debug
    o_csp_clk   => open,
    o_csp_data  => open
 );
yout_error <= yout_bad and yout_eop;

---------------------------------------------------------------------------------------
-- ASSERTIONS -------------------------------------------------------------------------
---------------------------------------------------------------------------------------
ASSERT_P : process(clk) 
begin
    if rising_edge(clk) then
        assert (pg0_out_full = '0') report "Filter FIFO full" severity error;
        assert (x0_out_full = '0') report "X0 FIFO full" severity error;
        assert (x1_out_full = '0') report "X1 FIFO full" severity error;
        assert (y0_out_full = '0') report "Y0 FIFO full" severity error;
        assert (y1_out_full = '0') report "Y1 FIFO full" severity error;
    end if;
end process;

ASSERT_P2 : process(clk2) 
begin
    if rising_edge(clk2) then
        assert not(xout_eop = '1' and xout_good = '0') report "XOUT CRC ERROR" severity error;
        assert (xout_error = '0') report "XOUT BAD DATA" severity error;
        assert not(yout_eop = '1' and yout_good = '0') report "YOUT CRC ERROR" severity error;
        assert (yout_error = '0') report "YOUT BAD DATA" severity error;
    end if;
end process;

---------------------------------------------------------------------------------------
-- STATISTICS -------------------------------------------------------------------------
---------------------------------------------------------------------------------------
FIFO_CNT_P : process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            fifo_cnt_f02  <= 0;
            fifo_cnt_x0   <= 0;
            fifo_cnt_x1   <= 0;
            fifo_cnt_y0   <= 0;
            fifo_cnt_y1   <= 0;
            fifo_wcnt_f02 <= 0;
            fifo_wcnt_x0  <= 0;
            fifo_wcnt_x1  <= 0;
            fifo_wcnt_y0  <= 0;
            fifo_wcnt_y1  <= 0;
            f02_in_cnt    <= 0;
            xr_in_cnt0    <= 0;
            xr_in_cnt1    <= 0;
            xr_in_cnt2    <= 0;
            yr_in_cnt0    <= 0;
            yr_in_cnt1    <= 0;
            yr_in_cnt2    <= 0;
            xr_out_cnt    <= 0;
            yr_out_cnt    <= 0;
            ofifo_x_wcnt   <= 0;
            ofifo_y_wcnt   <= 0;
        else
            --FIFO FILL COUNTERS ---------------------------------------------------------------
            --F02
            if (pg0_out_valid = '1' and gen0_fifo_next = '0' and pg0_out_full = '0') then
                   fifo_cnt_f02 <= fifo_cnt_f02+1;
            elsif (pg0_out_valid = '0' and gen0_fifo_next = '1' and gen0_fifo_empty = '0') then
                   fifo_cnt_f02 <= fifo_cnt_f02-1;
            end if;
            --X0
            if (x0_out_valid = '1' and xr_in_next(1) = '0' and x0_out_full = '0') then
                fifo_cnt_x0 <= fifo_cnt_x0+1;
            elsif (x0_out_valid = '0' and xr_in_next(1) = '1' and xr_in_empty(1) = '0') then
                fifo_cnt_x0 <= fifo_cnt_x0-1;
            end if;
            --X1
            if (x1_out_valid = '1' and xr_in_next(2) = '0' and x1_out_full = '0') then
                fifo_cnt_x1 <= fifo_cnt_x1+1;
            elsif (x1_out_valid = '0' and xr_in_next(2) = '1' and xr_in_empty(2) = '0') then
                fifo_cnt_x1 <= fifo_cnt_x1-1;
            end if;
            --Y0
            if (y0_out_valid = '1' and yr_in_next(1) = '0' and y0_out_full = '0') then
                fifo_cnt_y0 <= fifo_cnt_y0+1;
            elsif (y0_out_valid = '0' and yr_in_next(1) = '1' and yr_in_empty(1) = '0') then
                fifo_cnt_y0 <= fifo_cnt_y0-1;
            end if;
            --Y1
            if (y1_out_valid = '1' and yr_in_next(2) = '0' and y1_out_full = '0') then
                fifo_cnt_y1 <= fifo_cnt_y1+1;
            elsif (y1_out_valid = '0' and yr_in_next(2) = '1' and yr_in_empty(2) = '0') then
                fifo_cnt_y1 <= fifo_cnt_y1-1;
            end if;
            

            --FIFO WRITE COUNTERS ---------------------------------------------------------------
            if btrig = '1' then
                fifo_wcnt_f02 <= 0;
            elsif (pg0_out_valid = '1' and pg0_out_full = '0') then
                fifo_wcnt_f02 <= fifo_wcnt_f02+1;
            end if;
            if btrig = '1' then
                fifo_wcnt_x0 <= 0;
            elsif (x0_out_valid = '1' and x0_out_full = '0') then
                fifo_wcnt_x0 <= fifo_wcnt_x0+1;
            end if;
            if btrig = '1' then
                fifo_wcnt_x1 <= 0;
            elsif (x1_out_valid = '1' and x1_out_full = '0') then
                fifo_wcnt_x1 <= fifo_wcnt_x1+1;
            end if;
            if btrig = '1' then
                fifo_wcnt_y0 <= 0;
            elsif (y0_out_valid = '1' and y0_out_full = '0') then
                fifo_wcnt_y0 <= fifo_wcnt_y0+1;
            end if;
            if btrig = '1' then
                fifo_wcnt_y1 <= 0;
            elsif (y1_out_valid = '1' and y1_out_full = '0') then
                fifo_wcnt_y1 <= fifo_wcnt_y1+1;
            end if;

            --FILTER INPUT COUNTER ------------------------------------------------------------
            if btrig = '1' then
                f02_in_cnt <= 0;
            elsif (f02_in0_next = '1' and f02_in0_empty = '0') then
                   f02_in_cnt <= f02_in_cnt+1;
            end if;

            --ROUTER IN COUNTERS ---------------------------------------------------------------
            if btrig = '1' then
                xr_in_cnt0 <= 0;
            elsif (xr_in_next(0) = '1' and xr_in_valid(0) = '1') then
                xr_in_cnt0 <= xr_in_cnt0+1;
            end if;
            if btrig = '1' then
                xr_in_cnt1 <= 0;
            elsif (xr_in_next(1) = '1' and xr_in_valid(1) = '1') then
                xr_in_cnt1 <= xr_in_cnt1+1;
            end if;
            if btrig = '1' then
                xr_in_cnt2 <= 0;
            elsif (xr_in_next(2) = '1' and xr_in_valid(2) = '1') then
                xr_in_cnt2 <= xr_in_cnt2+1;
            end if;
            
            if btrig = '1' then
                yr_in_cnt0 <= 0;
            elsif (yr_in_next(0) = '1' and yr_in_valid(0) = '1') then
                yr_in_cnt0 <= yr_in_cnt0+1;
            end if;
            if btrig = '1' then
                yr_in_cnt1 <= 0;
            elsif (yr_in_next(1) = '1' and yr_in_valid(1) = '1') then
                yr_in_cnt1 <= yr_in_cnt1+1;
            end if;
            if btrig = '1' then
                yr_in_cnt2 <= 0;
            elsif (yr_in_next(2) = '1' and yr_in_valid(2) = '1') then
                yr_in_cnt2 <= yr_in_cnt2+1;
            end if;

            --ROUTER IN COUNTERS ---------------------------------------------------------------
            if btrig = '1' then
                xr_out_cnt <= 0;
            elsif (xr_out_valid(0) = '1') then
                xr_out_cnt <= xr_out_cnt+1;
            end if;
            if btrig = '1' then
                yr_out_cnt <= 0;
            elsif (yr_out_valid(0) = '1') then
                yr_out_cnt <= yr_out_cnt+1;
            end if;

            --OUTFIFOs COUNTERS --------------------------------------------------------------
            if btrig = '1' then
                ofifo_x_wcnt <= 0;
            elsif (xr_out_valid(0) = '1' and xr_out_full = '0') then
                ofifo_x_wcnt <= ofifo_x_wcnt+1;
            end if;
            if btrig = '1' then
                ofifo_y_wcnt <= 0;
            elsif (yr_out_valid(0) = '1' and yr_out_full = '0') then
                ofifo_y_wcnt <= ofifo_y_wcnt+1;
            end if;
            

        end if; --rst
    end if; --clk
end process;

BPM_CNT_P : process(clk2)
begin
    if rising_edge(clk2) then
        if rst = '1' or btrig = '1' then
            bpm1_xcnt <= 0;
            bpm2_xcnt <= 0;
            bpm3_xcnt <= 0;
            bpm4_xcnt <= 0;
            bpm5_xcnt <= 0;
            bpm6_xcnt <= 0;
            bpm7_xcnt <= 0;
            bpm8_xcnt <= 0;
            bpm9_xcnt <= 0;
            bpmA_xcnt <= 0;

            bpm1_ycnt <= 0;
            bpm2_ycnt <= 0;
            bpm3_ycnt <= 0;
            bpm4_ycnt <= 0;
            bpm5_ycnt <= 0;
            bpm6_ycnt <= 0;
            bpm7_ycnt <= 0;
            bpm8_ycnt <= 0;
            bpm9_ycnt <= 0;
            bpmA_ycnt <= 0;
        else
            --BPM COUNTERS
            if xout_eop = '1' then
                case xout_packet.bpm is
                    when X"01" =>
                        bpm1_xcnt <= bpm1_xcnt+1;
                    when X"02" =>
                        bpm2_xcnt <= bpm2_xcnt+1;
                    when X"03" =>
                        bpm3_xcnt <= bpm3_xcnt+1;
                    when X"04" =>
                        bpm4_xcnt <= bpm4_xcnt+1;
                    when X"05" =>
                        bpm5_xcnt <= bpm5_xcnt+1;
                    when X"06" =>
                        bpm6_xcnt <= bpm6_xcnt+1;
                    when X"07" =>
                        bpm7_xcnt <= bpm7_xcnt+1;
                    when X"08" =>
                        bpm8_xcnt <= bpm8_xcnt+1;
                    when X"09" =>
                        bpm9_xcnt <= bpm9_xcnt+1;
                    when X"0A" =>
                        bpmA_xcnt <= bpmA_xcnt+1;
                    when others=>
                        null;
                end case;
            end if;

            if yout_eop = '1' then
                case yout_packet.bpm is
                    when X"01" =>
                        bpm1_ycnt <= bpm1_ycnt+1;
                    when X"02" =>
                        bpm2_ycnt <= bpm2_ycnt+1;
                    when X"03" =>
                        bpm3_ycnt <= bpm3_ycnt+1;
                    when X"04" =>
                        bpm4_ycnt <= bpm4_ycnt+1;
                    when X"05" =>
                        bpm5_ycnt <= bpm5_ycnt+1;
                    when X"06" =>
                        bpm6_ycnt <= bpm6_ycnt+1;
                    when X"07" =>
                        bpm7_ycnt <= bpm7_ycnt+1;
                    when X"08" =>
                        bpm8_ycnt <= bpm8_ycnt+1;
                    when X"09" =>
                        bpm9_ycnt <= bpm9_ycnt+1;
                    when X"0A" =>
                        bpmA_ycnt <= bpmA_ycnt+1;
                    when others=>
                        null;
                end case;
            end if; --yout_eop
        end if; --rst
    end if; --clk
end process;

FIFO_CNT_P2 : process(clk2)
begin
    if rising_edge(clk2) then
        if rst = '1' then
            ofifo_x_rcnt   <= 0;
            ofifo_y_rcnt   <= 0;
        else
            --OUTFIFOs COUNTERS --------------------------------------------------------------
            if btrig = '1' then
                ofifo_x_rcnt <= 0;
            elsif (ofifo_x_next = '1' and ofifo_x_empty = '0') then
                ofifo_x_rcnt <= ofifo_x_rcnt+1;
            end if;
            if btrig = '1' then
                ofifo_y_rcnt <= 0;
            elsif (ofifo_y_next = '1' and ofifo_y_empty = '0') then
                ofifo_y_rcnt <= ofifo_y_rcnt+1;
            end if;
        end if;
    end if;
end process;

ofifo_x_cnt <= ofifo_x_wcnt-ofifo_x_rcnt;
ofifo_y_cnt <= ofifo_y_wcnt-ofifo_y_rcnt;

---------------------------------------------------------------------------------------
-- THROUGHPUT METERS ------------------------------------------------------------------
---------------------------------------------------------------------------------------

--DATA GENERATORS ---------------------------------------------------------------------
METER_DGEN_FILT : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => pg0_in_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_gen_filt,
    o_bps_max    => bps_gen_filt
);

METER_DGEN_X0 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => x0_in_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_gen_x0,
    o_bps_max    => bps_gen_x0
);

METER_DGEN_X1 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => x1_in_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_gen_x1,
    o_bps_max    => bps_gen_x1
);

METER_DGEN_Y0 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => y0_in_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_gen_y0,
    o_bps_max    => bps_gen_y0
);

METER_DGEN_Y1 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => y1_in_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_gen_y1,
    o_bps_max    => bps_gen_y1
);

--PACKET TRANSMITTERS ----------------------------------------------------------------
METER_PTX_FILT : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => pg0_out_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_pkt_filt,
    o_bps_max    => bps_pkt_filt
);

METER_PTX_X0 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => x0_out_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_pkt_x0,
    o_bps_max    => bps_pkt_x0
);

METER_PTX_X1 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => x1_out_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_pkt_x1,
    o_bps_max    => bps_pkt_x1
);

METER_PTX_Y0 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => y0_out_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_pkt_y0,
    o_bps_max    => bps_pkt_y0
);

METER_PTX_Y1 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => y1_out_valid,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_pkt_y1,
    o_bps_max    => bps_pkt_y1
);

--FILTER INPUT -------------------------------------------------------------
METER_FILT_IN : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => f02_in0_next,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_filt_in,
    o_bps_max    => bps_filt_in
);

--ROUTERS INPUTS -----------------------------------------------------------
METER_XR_IN0 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => xr_in_next(0),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_xr_in0,
    o_bps_max    => bps_xr_in0
);

METER_XR_IN1 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => xr_in_next(1),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_xr_in1,
    o_bps_max    => bps_xr_in1
);

METER_XR_IN2 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => xr_in_next(2),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_xr_in2,
    o_bps_max    => bps_xr_in2
);


METER_YR_IN0 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => yr_in_next(0),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_yr_in0,
    o_bps_max    => bps_yr_in0
);

METER_YR_IN1 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => yr_in_next(1),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_yr_in1,
    o_bps_max    => bps_yr_in1
);

METER_YR_IN2 : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => yr_in_next(2),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_yr_in2,
    o_bps_max    => bps_yr_in2
);

--ROUTERS OUTPUTS -----------------------------------------------------------
METER_XR_OUT : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => xr_out_valid(0),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_xr_out,
    o_bps_max    => bps_xr_out
);

METER_YR_OUT : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => yr_out_valid(0),
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_yr_out,
    o_bps_max    => bps_yr_out
);

--OUT FIFOs READ ------------------------------------------------------------
METER_OFIFO_X : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK2_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => ofifo_x_next,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_ofifo_x,
    o_bps_max    => bps_ofifo_x
);

METER_OFIFO_Y : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK2_FREQ,
    DATA_WIDTH_BITS => 32.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => ofifo_y_next,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_ofifo_y,
    o_bps_max    => bps_ofifo_y
);

--OUT PACKETS RECEIVERS -----------------------------------------------------
METER_OPKT_X : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK2_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => xout_eop,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_opkt_x,
    o_bps_max    => bps_opkt_x
);

METER_OPKT_Y : throughput_meter
generic map(
    CLK_FREQ_HZ     => CLK2_FREQ,
    DATA_WIDTH_BITS => 96.0
)
port map(
    i_clk => clk,
    i_rst => btrig,
    i_data_valid => yout_eop,
    o_bps        => open,
    o_bpc        => open,
    o_bpc_max    => bpc_opkt_y,
    o_bps_max    => bps_opkt_y
);

end architecture test; --of dual_router_tb
