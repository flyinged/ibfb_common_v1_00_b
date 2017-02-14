library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use pkg_ibfb_fb_ctrl.all;

entity ibfb_fb_correction is
port(
    i_clk        : in  std_logic;
    i_pos_v      : in  std_logic;
    i_pos        : in  t_matrix_2x1_coeff; --m11,m12
    i_feedback_v : in  std_logic;
    i_feedback   : in  t_matrix_2x1_int16; --m11,m12
    i_transform  : in  t_matrix_2x2_coeff; --m11,m12,m21,m22
    i_out_ack    : in  std_logic;
    o_pos_v      : out std_logic;
    o_pos        : out t_matrix_2x1_coeff;
);
end entity ibfb_fb_correction;

architecture struct of ibfb_fb_correction is

signal out_valid : std_logic := '0';
signal fb_v, tfb_v, out_update : std_logic;
signal fb, tfb, tfb_r : t_matrix_2x1_coeff;

begin

--1. Convert feedback input from unsigned integer to single precision floating point
FB_INT_TO_SPFP_INST : matrix_2x1_int2single
port map(
    i_clk => i_clk,
    i_nd  => i_feedback_v,
    i_in  => i_feedback,
    o_rdy => fb_v,
    o_out => fb
);

--2. Apply transformation to feedback value
FB_TRANSFORM_INST : matrix_2x2_mult_single
  port  (
    i_clk     => i_clk,
    i_m_coeff => i_transform,
    i_nd      => fb_v,
    i_in      => fb,
    o_rdy     => tfb_v,
    o_out     => tfb
);

--3. Register transformed feedback (needed? is tfb stable during calculation?)
TFB_REG_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if tfb_v = '1' then
            tfb_r <= tfb;
        end if;
    end if;
end process;

--4. Apply feedback to input
ADD_TFB_INST : matrix_2x1_addsub_single
generic map(
    c_op => '0'  -- 0: add, 1: sub
);
port map(
    i_clk => i_clk,
    i_nd  => i_pos_v,
    i_a   => i_pos,
    i_b   => tfb_r,
    o_rdy => out_update,
    o_out => o_pos
);

OUT_ACK_P : process(i_clk)
begin
    if rising_edge(i_clk) then
        if out_update = '1' then
            out_valid <= '1';
        elsif i_out_ack = '1' then
            out_valid <= '0';
        end if;
    end if;
end process;

o_pos_v <= out_valid;



end architecture struct; --of ibfb_fb_correction

