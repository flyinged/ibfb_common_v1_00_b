------------------------------------------------------------------------------
--                       Paul Scherrer Institute (PSI)
------------------------------------------------------------------------------
-- Unit    : dac16hl_if.vhd
-- Author  : Waldemar Koprek, Section Diagnostic
-- Version : $Revision: 1.1 $
------------------------------------------------------------------------------
-- Copyright© PSI, Section Diagnostic
------------------------------------------------------------------------------
-- Comment : This is a package for programming spi_base chips in various 
--           configuration
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_ibfb_timing is 
  
  type typ_pulse_gen_in is record
    slv_delay   						 : unsigned(27 downto 0);
    slv_period   						 : unsigned(15 downto 0);
    slv_high     						 : unsigned(15 downto 0);
    slv_pulse_num						 : unsigned(11 downto 0);
  end record typ_pulse_gen_in;
  
  type t_cpu_timing_rd is record
    ext_trg_missing               : std_logic;
    read_ready                    : std_logic;
  end record t_cpu_timing_rd;

  type t_cpu_timing_wr is record
    global_trg_ena                : std_logic;
    trg_mode                      : std_logic;
 	trg_source    		          : std_logic_vector(2 downto 0);
    b_delay                       : std_logic_vector(27 downto  0);    
    b_number                      : std_logic_vector(15 downto  0);    
    b_space                       : std_logic_vector(15 downto  0);    
    trg_rate                      : std_logic_vector( 2 downto  0);    -- 0x2C -- unsigned char
    trg_once                      : std_logic;                         -- 0x00 -- unsigned int
  end record t_cpu_timing_wr;
  
  type t_timing is record
    sl_global_pulse_trg           : std_logic;
    sl_global_bunch_trg           : std_logic;
    sl_global_pulse               : std_logic;
  end record t_timing;
  
  component tim_pulse_gen
  port (
    i_clk             : in  std_logic;
    i_params          : in  typ_pulse_gen_in;
    i_trg             : in  std_logic;
    o_active          : out std_logic;
    o_pulse           : out std_logic
    );
  end component tim_pulse_gen;

  component ibfb_timing
  port (
    i_dac_clk                   : in  std_logic;
    -- Sampling interface
    i_cpu_clk                   : in  std_logic;
    i_cpu_fsm_wr                : in  t_cpu_timing_wr;
    o_cpu_fsm_rd                : out t_cpu_timing_rd;
    -- BPM interface
    i_ext_trg                   : in  std_logic;
    o_ibfb_timing               : out t_timing;
    o_led_pulse                 : out std_logic;
    -- debug
    o_csp_clk                   : out std_logic;
    o_csp_data                  : out std_logic_vector(63 downto 0)
  );
  end component ibfb_timing;

  component pulse_clock_domain_cross
  port (
    -- adc clk domain
    i_clk_in           : in  std_logic;
    i_pulse_in         : in  std_logic;
    -- usr clk domain
    i_clk_out          : in  std_logic;
    o_pulse_out        : out std_logic
    );
  end component pulse_clock_domain_cross;
  
  component timing_clock_domain_cross
  port (
    -- adc clk domain
    i_clk_in           : in  std_logic;
    i_timing_in        : in  t_timing;
    -- usr clk domain
    i_clk_out          : in  std_logic;
    o_timing_out       : out t_timing
    );
  end component timing_clock_domain_cross;
  
  
end package pkg_ibfb_timing;

---------------------------------------------------------------------------
-- END PACKAGED DEFINITION ------------------------------------------------
---------------------------------------------------------------------------

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Pulse generator
------------------------------------------------------------------------------
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.pkg_ibfb_timing.all;

entity tim_pulse_gen is 
  port (
    i_clk             : in  std_logic;
    i_params          : in  typ_pulse_gen_in;
    i_trg             : in  std_logic;
    o_active          : out std_logic;
    o_pulse           : out std_logic
    );
end tim_pulse_gen;

architecture behavioral of tim_pulse_gen is

  type typ_pulse_fsm is (
    idle,
    train_delay,
    pulse_gen_high,
    pulse_gen_low
  );

  signal r_fsm            : typ_pulse_fsm := idle;
  signal slv_delay_cnt    : unsigned(27 downto 0) := (others => '0');
  signal slv_period_cnt   : unsigned(15 downto 0) := (others => '0');
  signal slv_pulse_cnt    : unsigned(11 downto 0) := (others => '0');
  
  
  signal sl_period_ok     : std_logic := '0';
  signal sl_high_ok       : std_logic := '0';
  signal sl_pulses_ok     : std_logic := '0';
  signal sl_diff_ok       : std_logic := '0';
  
  signal sl_period_end    : std_logic := '0';
  signal slv_valid_cond   : std_logic_vector(4 downto 0);
  
begin

  --params check
  prc_param_check : process ( i_clk )
  begin
    if rising_edge( i_clk ) then
      sl_period_ok <= or_reduce(std_logic_vector(i_params.slv_period(15 downto 1))); -- >=2
      sl_high_ok   <= or_reduce(std_logic_vector(i_params.slv_high));                -- >=1
      sl_pulses_ok <= or_reduce(std_logic_vector(i_params.slv_pulse_num));           -- >=1
      if i_params.slv_period > i_params.slv_high then
        sl_diff_ok  <= '1';
      else
        sl_diff_ok  <= '0';
      end if;
    end if;
  end process ;
  
  slv_valid_cond <= i_trg & sl_period_ok & sl_high_ok & sl_pulses_ok & sl_diff_ok;

  -- trigger delay
  prc_delay_cnt : process ( i_clk )
  begin
    if rising_edge( i_clk ) then
      if r_fsm = train_delay then
        slv_delay_cnt <= slv_delay_cnt + 1;
      else
        slv_delay_cnt <= (others => '0');
      end if;
    end if;
  end process ;  

  prc_period_cnt : process ( i_clk )
  begin
    if rising_edge( i_clk ) then
      if (r_fsm = pulse_gen_high) or (r_fsm = pulse_gen_low) then
        slv_period_cnt  <= slv_period_cnt + X"1";
      end if;
      if (sl_period_end = '1') or (r_fsm = train_delay) then
        slv_period_cnt  <= "0000000000000001";
      end if;
    end if;
  end process ;  
  
  sl_period_end <= '1' when slv_period_cnt = i_params.slv_period else '0';
  
  prc_fsm : process ( i_clk )
  begin
    if rising_edge( i_clk ) then
      case r_fsm is
        when idle =>
          if and_reduce(slv_valid_cond) = '1' then
            r_fsm <= train_delay;
          end if;
          slv_pulse_cnt <= (others => '0');
        when train_delay => 
          if slv_delay_cnt = i_params.slv_delay then
            r_fsm <= pulse_gen_high;
          end if;
        when pulse_gen_high =>
          if slv_period_cnt = i_params.slv_high then
            slv_pulse_cnt   <= slv_pulse_cnt + X"1";
            r_fsm           <= pulse_gen_low;
          end if;
        when pulse_gen_low =>
          if sl_period_end = '1' then
            if slv_pulse_cnt = i_params.slv_pulse_num then
              r_fsm <= idle;
            else
              r_fsm <= pulse_gen_high;
            end if;
          end if;
      end case;
    end if;
  end process ;
  
  o_pulse   <= '1' when r_fsm = pulse_gen_high else '0';
  o_active  <= '0' when r_fsm = idle else '1';
  
end behavioral;

------------------------------------------------------------------------------
-- Pulse clock domain crossing
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.pkg_ibfb_timing.all;

entity pulse_clock_domain_cross is 
  port (
    -- adc clk domain
    i_clk_in           : in  std_logic;
    i_pulse_in         : in  std_logic;
    -- usr clk domain
    i_clk_out          : in  std_logic;
    o_pulse_out        : out std_logic
    );
end pulse_clock_domain_cross;

architecture behavioral of pulse_clock_domain_cross is

  signal slv_pulse_stretch : std_logic_vector(5  downto 0)  := (others => '0');

begin

  prc_pulse_stretching : process ( i_clk_in )
    variable vslv_pulse_ris      : std_logic_vector(1 downto 0);
  begin
    if rising_edge(i_clk_in) then
      if vslv_pulse_ris = "01" then -- rising edge of the pulse
        slv_pulse_stretch <= (others => '1');
      else
        slv_pulse_stretch <= slv_pulse_stretch(slv_pulse_stretch'left-1 downto 0) & '0'; 
      end if;
      vslv_pulse_ris  := vslv_pulse_ris(0) & i_pulse_in;      
    end if;
  end process ;
  
  prc_pulse_generation : process ( i_clk_out )
    variable vslv_stretch_ris      : std_logic_vector(1 downto 0);
  begin
    if rising_edge( i_clk_out ) then
      if vslv_stretch_ris = "01"  then --end of sampling window
        o_pulse_out <= '1';
      else
        o_pulse_out <= '0';
      end if;
      vslv_stretch_ris  := vslv_stretch_ris(0) & slv_pulse_stretch(slv_pulse_stretch'left);
    end if;
  end process ;
   
end behavioral;


------------------------------------------------------------------------------
-- timing clock domain crossing
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.pkg_ibfb_timing.all;

entity timing_clock_domain_cross is 
  port (
    -- adc clk domain
    i_clk_in           : in  std_logic;
    i_timing_in        : in  t_timing;
    -- usr clk domain
    i_clk_out          : in  std_logic;
    o_timing_out       : out t_timing
    );
end timing_clock_domain_cross;

architecture behavioral of timing_clock_domain_cross is

begin

  ins_clock_domain_cross_pulse_trg: pulse_clock_domain_cross
  port map (
    -- adc clk domain
    i_clk_in           => i_clk_in,
    i_pulse_in         => i_timing_in.sl_global_pulse_trg,
    -- usr clk domain  
    i_clk_out          => i_clk_out,
    o_pulse_out        => o_timing_out.sl_global_pulse_trg
    );

  ins_clock_domain_cross_pulse_bunch: pulse_clock_domain_cross
  port map (
    -- adc clk domain
    i_clk_in           => i_clk_in,
    i_pulse_in         => i_timing_in.sl_global_bunch_trg,
    -- usr clk domain  
    i_clk_out          => i_clk_out,
    o_pulse_out        => o_timing_out.sl_global_bunch_trg
    );

  prc_global_pulse : process ( i_clk_out )
  begin
    if rising_edge(i_clk_out) then
      o_timing_out.sl_global_pulse <= i_timing_in.sl_global_pulse;
    end if;
  end process ;
   
end behavioral;


------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- IBFB Timing
------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library work;
use work.pkg_ibfb_timing.all;

entity ibfb_timing is
   port    (
      i_dac_clk                   : in  std_logic;
      -- Sampling interface
      i_cpu_clk                   : in  std_logic;
      i_cpu_fsm_wr                : in  t_cpu_timing_wr;
      o_cpu_fsm_rd                : out t_cpu_timing_rd;
      -- BPM interface
      i_ext_trg                   : in  std_logic;
      o_ibfb_timing               : out t_timing;
      o_led_pulse                 : out std_logic;
      -- debug
      o_csp_clk                   : out std_logic;
      o_csp_data                  : out std_logic_vector(63 downto 0)
   );
end ibfb_timing;

architecture behavioral of ibfb_timing is

  -- trigger system
  signal slv_atrg_cnt                 : unsigned(27 downto 0);
  signal slv_atrg_max                 : unsigned(27 downto 0);
  signal slv_atrg                     : std_logic_vector(5 downto 0) := (others => '0');
  signal slv_atrg_prev                : std_logic_vector(5 downto 0) := (others => '0');
  signal sl_trg_auto                  : std_logic := '0';
  signal sl_trg_external              : std_logic := '0';
 	signal slv_ext_trg_cnt     		      : unsigned(27 downto 0);
 	signal slv_trg_source    		        : unsigned(2 downto 0);
  signal sl_global_pulse_mux          : std_logic := '0';
  signal sl_global_pulse_trg          : std_logic := '0';
  signal sl_global_trg_ena            : std_logic := '0';
  signal sl_trg_mode                  : std_logic := '0';
  signal sl_once                      : std_logic := '0';
  signal sl_pulse                     : std_logic := '0';
  signal sl_global_pulse              : std_logic := '0';
  signal sl_global_bunch_trg          : std_logic := '0';
  signal r_bucket_params              : typ_pulse_gen_in;
  signal slv_pulse_cnt                : unsigned(8 downto 0) := (others => '0');
  signal slv_trg_led                  : std_logic_vector(9 downto 0) := (others => '0');
  signal slv_trg                      : std_logic_vector(1 downto 0) := (others => '0');
  signal slv_led_pulse                : unsigned(21 downto 0);

begin

  ---------------------------------------------------------------------------
  -- CSP
  ---------------------------------------------------------------------------
  o_csp_clk                 <= i_dac_clk;
  o_csp_data(0)             <= sl_global_trg_ena;
  o_csp_data(1)             <= sl_trg_mode;
  o_csp_data(2)             <= sl_trg_auto;
  o_csp_data(3)             <= sl_trg_external;
  o_csp_data(4)             <= sl_global_pulse_mux;
  o_csp_data(5)             <= sl_once;
  o_csp_data(6)             <= sl_global_pulse_trg;
  o_csp_data(7)             <= sl_global_pulse;
  o_csp_data(10 downto  8)  <= std_logic_vector(slv_trg_source);
  o_csp_data(13 downto 11)  <= i_cpu_fsm_wr.trg_rate;
  o_csp_data(14)            <= sl_global_bunch_trg;
  o_csp_data(15)            <= slv_trg_led(9);
  o_csp_data(43 downto 32)  <= std_logic_vector(r_bucket_params.slv_pulse_num);
  o_csp_data(63 downto 48)  <= std_logic_vector(r_bucket_params.slv_period);

  ---------------------------------------------------------------------------
  -- clock domain crossing of the control parameters
  ---------------------------------------------------------------------------

  prc_params_capture : process ( i_dac_clk )
  begin
    if rising_edge( i_dac_clk ) then     
      sl_global_trg_ena                   <= i_cpu_fsm_wr.global_trg_ena;
      sl_trg_mode      	                  <= i_cpu_fsm_wr.trg_mode;
      slv_trg_source                      <= unsigned(i_cpu_fsm_wr.trg_source);
      r_bucket_params.slv_delay   	      <= unsigned(i_cpu_fsm_wr.b_delay);
      r_bucket_params.slv_period          <= unsigned(i_cpu_fsm_wr.b_space);
      r_bucket_params.slv_pulse_num       <= unsigned(i_cpu_fsm_wr.b_number(11 downto 0));
      r_bucket_params.slv_high            <= X"0001";
    end if;
  end process ;

  ---------------------------------------------------------------------------
  -- AUTO TRIGGER SOURCE
  ---------------------------------------------------------------------------

  slv_atrg_max <= X"EE6B280" when i_cpu_fsm_wr.trg_rate = "001" else --   2 s
                  X"7735940" when i_cpu_fsm_wr.trg_rate = "010" else --   1 s
                  X"3B9ACA0" when i_cpu_fsm_wr.trg_rate = "011" else -- 0.5 s
                  X"17D7840" when i_cpu_fsm_wr.trg_rate = "100" else -- 0.2 s
                  X"0BEBC20" when i_cpu_fsm_wr.trg_rate = "101" else -- 0.1 s
                  X"0BEBC20";
  
  prc_auto_trigger: process(i_cpu_clk)
  begin
    if rising_edge( i_cpu_clk ) then
      slv_atrg_cnt    <= slv_atrg_cnt + X"1";
      if slv_atrg_cnt = slv_atrg_max then
        slv_atrg      <= (others => '1');
        slv_atrg_cnt  <= (others => '0');
      else
        slv_atrg       <= slv_atrg(slv_atrg'left-1 downto 0) & '0';
      end if;
    end if;
  end process;
  
  prc_auto_trigger_hclk : process ( i_dac_clk )
  begin
    if rising_edge( i_dac_clk ) then
      if slv_atrg_prev(5 downto 4) = "01" then --rising edge
        sl_trg_auto  <= '1';
      else
        sl_trg_auto  <= '0';
      end if;
      slv_atrg_prev  <= slv_atrg_prev(4 downto 0) & slv_atrg(slv_atrg'left);
    end if;
  end process ;

  ---------------------------------------------------------------------------
  -- External Trigger
  ---------------------------------------------------------------------------

  -- edge detection
  prc_ext_trg_rising_edge : process ( i_dac_clk )
   variable vslv_prev      : std_logic_vector(1 downto 0);
  begin
    if rising_edge( i_dac_clk ) then
      if vslv_prev = "01" then
       sl_trg_external  <= '1';
      else
       sl_trg_external  <= '0';
      end if;
      vslv_prev := vslv_prev(0) & i_ext_trg;
    end if;
  end process ;

  -- missing external trigger detection
  prc_ext_trg_present : process ( i_cpu_clk )
   variable vslv_prev      : std_logic_vector(1 downto 0);
  begin
    if rising_edge( i_cpu_clk ) then
      if vslv_prev = "01" then
       slv_ext_trg_cnt	<= (others => '1');
      else
      	if slv_ext_trg_cnt(slv_ext_trg_cnt'left) = '1' then
        	slv_ext_trg_cnt	<= slv_ext_trg_cnt - X"1";
        end if;
      end if;
      vslv_prev := vslv_prev(0) & i_ext_trg;
    end if;
  end process ;

  o_cpu_fsm_rd.ext_trg_missing	<= not slv_ext_trg_cnt(slv_ext_trg_cnt'left);

  ---------------------------------------------------------------------------
  -- GLOBAL SIGNALS GENERATION
  ---------------------------------------------------------------------------
  
  -- trigger source mux
  prc_trg_source : process ( i_dac_clk )
  begin
    if rising_edge( i_dac_clk ) then
      case slv_trg_source is
        when "000" =>                     -- trigger external 
          sl_global_pulse_mux  <= sl_trg_external;
        when others =>                    -- trigger auto
          sl_global_pulse_mux  <= sl_trg_auto;
      end case;
	  end if;
  end process ;
  
  -- trigger once gate
  prc_trg_mode : process ( i_dac_clk )
    variable vslv_prev        : std_logic_vector(1 downto 0);
  begin
    if rising_edge( i_dac_clk ) then
      if sl_trg_mode = '0' then -- continuous
        sl_global_pulse_trg   <= sl_global_pulse_mux;
      else                      -- trigger once
        if sl_once = '1' then
          sl_global_pulse_trg <= sl_global_pulse_mux;
          if sl_global_pulse_mux = '1' then
            sl_once           <= '0';
          end if;
        else
          sl_global_pulse_trg <= '0';
        end if;
      end if;
      if vslv_prev = "01" then
        sl_once               <= '1';
      end if;
      vslv_prev               := vslv_prev(0) & i_cpu_fsm_wr.trg_once;  
      
      o_ibfb_timing.sl_global_pulse_trg <= sl_global_pulse_trg and sl_global_trg_ena ;
      o_ibfb_timing.sl_global_bunch_trg <= sl_global_bunch_trg and sl_global_trg_ena ;
      o_ibfb_timing.sl_global_pulse     <= sl_global_pulse     and sl_global_trg_ena ;
    end if;
  end process ;

  ---------------------------------------------------------------------------
  -- Bucket trigger generation
  ---------------------------------------------------------------------------    
  ins_bunch_pulse_gen:  tim_pulse_gen 
    port map (
      i_clk             => i_dac_clk,
      i_params          => r_bucket_params,
      i_trg             => sl_global_pulse_trg,
      o_active          => sl_pulse,
      o_pulse           => sl_global_bunch_trg
    );

  -- extention of the pulse duration in order to record the last bunch
  prc_extend_pulse : process ( i_dac_clk )
  begin
    if rising_edge(i_dac_clk) then
      if sl_pulse = '1' then
        slv_pulse_cnt <= (others => '1');
      else
        if slv_pulse_cnt(slv_pulse_cnt'left) = '1' then
          slv_pulse_cnt <= slv_pulse_cnt - X"1";
        end if;
      end if;
    end if;
  end process ;
  
  sl_global_pulse  <= sl_pulse or slv_pulse_cnt(slv_pulse_cnt'left);
  
  ---------------------------------------------------------------------------
  -- CPU INTERFACE
  ---------------------------------------------------------------------------
  prc_cpu_if : process ( i_cpu_clk )
  begin
    if rising_edge( i_cpu_clk ) then
      if i_cpu_fsm_wr.global_trg_ena = '1' then
        o_cpu_fsm_rd.read_ready  <= not sl_global_pulse;      
      end if;
    end if;
  end process ;
  
  ---------------------------------------------------------------------------
  -- LED PULSE
  ---------------------------------------------------------------------------
  prc_trg_led : process ( i_dac_clk )
  begin
    if rising_edge( i_dac_clk ) then
      slv_trg_led <= slv_trg_led(8 downto 0) & '0';
      if sl_global_pulse_trg = '1' and i_cpu_fsm_wr.global_trg_ena = '1' then
        slv_trg_led <= (others => '1');
      end if;
    end if;
  end process ;
  
  prc_trg_pulse : process ( i_cpu_clk )
  begin
    if rising_edge( i_cpu_clk ) then
      slv_trg <= slv_trg(0) & slv_trg_led(9);
      if slv_trg = "01" then
        slv_led_pulse <= (others => '0');
      end if;
      if slv_led_pulse(slv_led_pulse'left) = '0' then
        slv_led_pulse <= slv_led_pulse + X"1";
      end if;
    end if;
  end process ;
  
  o_led_pulse <= not slv_led_pulse(slv_led_pulse'left);
  
end behavioral;
