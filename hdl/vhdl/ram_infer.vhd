--
-- Single port RAM, read first mode
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_infer is
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
end entity ram_infer;

architecture syn of ram_infer is

type ram_type is array (0 to (2**ADDR_W)-1) of std_logic_vector (DATA_W-1 downto 0);

signal RAM : ram_type;
signal read_adda : unsigned(ADDR_W-1 downto 0);
signal read_addb : unsigned(ADDR_W-1 downto 0);

begin

process (clk)
begin
    if rising_edge(clk) then
        if (en = '1') then
            if (we = '1') then
                RAM(to_integer(unsigned(addr))) <= di;
            end if;
            do <= RAM(to_integer(unsigned(addr)));
        end if;
    end if;
end process;

end architecture syn;

--
-- Dual port RAM (A port RW, B port RO, read first mode)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_infer_dual is
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
end entity ram_infer_dual;

architecture syn of ram_infer_dual is

type ram_type is array (0 to (2**ADDR_W)-1) of std_logic_vector (DATA_W-1 downto 0);

signal RAM : ram_type;
--shared variable RAM : ram_type;

begin

PORT_A_P : process (clka)
begin
    if rising_edge(clka) then
        if (ena = '1') then
            if (wea = '1') then
                RAM(to_integer(unsigned(addra))) <= dia;
            end if;
            doa <= RAM(to_integer(unsigned(addra)));
        end if;
    end if;
end process;

PORT_B_P : process (clkb)
begin
    if rising_edge(clkb) then
        if (enb = '1') then
            dob <= RAM(to_integer(unsigned(addrb)));
        end if;
    end if;
end process;

end architecture syn;
