library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity throughput_meter is
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
    o_bps        : out real --bits per second
);
end entity throughput_meter;

architecture behav of throughput_meter is

signal clock_cycle_cnt, data_cnt, bps, bpc, bps_max, bpc_max : real;

begin

MAIN : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            clock_cycle_cnt <= 0.0;
            data_cnt <= 0.0;
        else
            clock_cycle_cnt <= clock_cycle_cnt + 1.0; --free running clock cycle counter
            if i_data_valid = '1' then 
                data_cnt <= data_cnt + 1.0; --data word counter
            end if;
        end if;
    end if;
end process;

MAX_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if i_rst = '1' then
            bpc_max <= 0.0;
            bps_max <= 0.0;
        else
            if bpc > bpc_max then
                bpc_max <= bpc;
            end if;
            if bps > bps_max then
                bps_max <= bps;
            end if;
        end if;
    end if;
end process;

bpc <= (DATA_WIDTH_BITS*data_cnt)/clock_cycle_cnt when clock_cycle_cnt > 0.0 else
         0.0;
bps <= (CLK_FREQ_HZ*DATA_WIDTH_BITS*data_cnt)/clock_cycle_cnt when clock_cycle_cnt > 0.0 else
         0.0;

o_bpc <= bpc;
o_bps <= bps;

o_bps_max <= bps_max;
o_bpc_max <= bpc_max;

end architecture behav;
