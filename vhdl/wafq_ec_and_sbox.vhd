--------------------------------------------------------------------------------
-- WAFQ ELLIPTIC CURVE (F_53) & CUSTOM-TWEAKED ABJAD S-BOX (VHDL-2008)
-- Synthesized from Lean 4 Specification: GnosticAbjad.EC_SBox
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package wafq_ec_pkg is
  constant C_P_PRIME         : integer := 53;  -- AL_HAMID_VALUE
  constant C_AL_HAMID_FULL   : integer := 93;  -- AL_HAMID_FULL_VALUE
  constant C_ALI_VALUE       : integer := 110; -- ALI_VALUE
  constant C_JAMAL_VEC       : integer := 146; -- JAMAL_VECTOR
  constant C_JALAL_VEC       : integer := 110; -- JALAL_VECTOR
  constant C_POLARITY_DELTA  : integer := 36;  -- POLARITY_DELTA
  constant C_BIFURCATION_ORD : integer := 7;   -- BIFURCATION_ORDER
  constant C_EC_A            : integer := 11;  -- WAFQ_ALLAH_3X3[1][1]
  constant C_EC_B            : integer := 33;  -- WAFQ_ALLAH_3X3.constantSum
  constant C_INV_53_MOD_256  : integer := 29;  -- 53 * 29 = 1 mod 256

  type t_wafq_3x3 is array (0 to 2, 0 to 2) of integer range 0 to 31;
  constant C_WAFQ_3X3 : t_wafq_3x3 := (
    (8,  1,  24),
    (15, 11, 7),
    (10, 21, 2)
  );

  -- Precomputed multiplicative inverse LUT in F_53: a^(-1) mod 53
  type t_inv53_lut is array (0 to 52) of integer range 0 to 52;
  constant C_INV53_LUT : t_inv53_lut := (
     0,  1, 27, 18, 40, 32,  9, 38, 20,  6,
    16, 24, 31, 49, 19, 46,  8, 25,  3, 14,
     8, 48, 41, 30, 11, 17, 47,  2, 36, 42,
    23, 12,  5, 45, 39, 50, 28, 43,  7, 34,
     4, 22, 29, 37, 51, 33, 15, 26, 21, 13,
    35, 44, 52
  );

  function fp53_add(a, b : integer) return integer;
  function fp53_sub(a, b : integer) return integer;
  function fp53_mul(a, b : integer) return integer;
  function digit_root_8(n : integer) return integer;
  function quadrant_bias(q : std_logic_vector(1 downto 0)) return unsigned;
end package wafq_ec_pkg;

package body wafq_ec_pkg is
  function fp53_add(a, b : integer) return integer is
  begin
    return (a + b) mod 53;
  end function;

  function fp53_sub(a, b : integer) return integer is
  begin
    return (a + 53 - (b mod 53)) mod 53;
  end function;

  function fp53_mul(a, b : integer) return integer is
  begin
    return (a * b) mod 53;
  end function;

  function digit_root_8(n : integer) return integer is
    variable r : integer;
  begin
    if n = 0 then
      return 0;
    else
      r := n mod 9;
      if r = 0 then
        return 9;
      else
        return r;
      end if;
    end if;
  end function;

  function quadrant_bias(q : std_logic_vector(1 downto 0)) return unsigned is
  begin
    case q is
      when "00"   => return to_unsigned(C_P_PRIME, 8);        -- 53
      when "01"   => return to_unsigned(C_JAMAL_VEC, 8);      -- 146
      when "10"   => return to_unsigned(C_JALAL_VEC, 8);      -- 110
      when others => return to_unsigned(C_POLARITY_DELTA, 8); -- 36
    end case;
  end function;
end package body wafq_ec_pkg;

--------------------------------------------------------------------------------
-- ENTITY 1: WAFQ ELLIPTIC CURVE ALU (y^2 = x^3 + 11x + 33 mod 53)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wafq_ec_pkg.all;

entity wafq_ec_alu is
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    start    : in  std_logic;
    op_dbl   : in  std_logic; -- '1' = ecDouble(P), '0' = ecAdd(P, Q)
    p_inf    : in  std_logic;
    px       : in  unsigned(5 downto 0);
    py       : in  unsigned(5 downto 0);
    q_inf    : in  std_logic;
    qx       : in  unsigned(5 downto 0);
    qy       : in  unsigned(5 downto 0);
    r_inf    : out std_logic;
    rx       : out unsigned(5 downto 0);
    ry       : out unsigned(5 downto 0);
    done     : out std_logic
  );
end entity wafq_ec_alu;

architecture rtl of wafq_ec_alu is
begin
  process(clk, rst_n)
    variable x1, y1, x2, y2 : integer range 0 to 52;
    variable num, den, lam  : integer range 0 to 52;
    variable x3, y3         : integer range 0 to 52;
    variable do_dbl         : boolean;
  begin
    if rst_n = '0' then
      r_inf <= '1';
      rx    <= (others => '0');
      ry    <= (others => '0');
      done  <= '0';
    elsif rising_edge(clk) then
      done <= '0';
      if start = '1' then
        done <= '1';
        x1 := to_integer(px) mod 53;
        y1 := to_integer(py) mod 53;
        x2 := to_integer(qx) mod 53;
        y2 := to_integer(qy) mod 53;

        if op_dbl = '1' then
          if p_inf = '1' or y1 = 0 then
            r_inf <= '1';
            rx    <= (others => '0');
            ry    <= (others => '0');
          else
            num := fp53_add(fp53_mul(3, fp53_mul(x1, x1)), C_EC_A);
            den := fp53_mul(2, y1);
            lam := fp53_mul(num, C_INV53_LUT(den));
            x3  := fp53_sub(fp53_mul(lam, lam), fp53_mul(2, x1));
            y3  := fp53_sub(fp53_mul(lam, fp53_sub(x1, x3)), y1);
            r_inf <= '0';
            rx    <= to_unsigned(x3, 6);
            ry    <= to_unsigned(y3, 6);
          end if;
        else
          if p_inf = '1' then
            r_inf <= q_inf;
            rx    <= to_unsigned(x2, 6);
            ry    <= to_unsigned(y2, 6);
          elsif q_inf = '1' then
            r_inf <= p_inf;
            rx    <= to_unsigned(x1, 6);
            ry    <= to_unsigned(y1, 6);
          elsif x1 = x2 then
            if y1 = y2 then
              if y1 = 0 then
                r_inf <= '1';
                rx    <= (others => '0');
                ry    <= (others => '0');
              else
                num := fp53_add(fp53_mul(3, fp53_mul(x1, x1)), C_EC_A);
                den := fp53_mul(2, y1);
                lam := fp53_mul(num, C_INV53_LUT(den));
                x3  := fp53_sub(fp53_mul(lam, lam), fp53_mul(2, x1));
                y3  := fp53_sub(fp53_mul(lam, fp53_sub(x1, x3)), y1);
                r_inf <= '0';
                rx    <= to_unsigned(x3, 6);
                ry    <= to_unsigned(y3, 6);
              end if;
            else
              r_inf <= '1';
              rx    <= (others => '0');
              ry    <= (others => '0');
            end if;
          else
            lam := fp53_mul(fp53_sub(y2, y1), C_INV53_LUT(fp53_sub(x2, x1)));
            x3  := fp53_sub(fp53_sub(fp53_mul(lam, lam), x1), x2);
            y3  := fp53_sub(fp53_mul(lam, fp53_sub(x1, x3)), y1);
            r_inf <= '0';
            rx    <= to_unsigned(x3, 6);
            ry    <= to_unsigned(y3, 6);
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture rtl;

--------------------------------------------------------------------------------
-- ENTITY 2: CUSTOM-TWEAKED BIJECTIVE ABJAD S-BOX (FWD / INV)
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wafq_ec_pkg.all;

entity abjad_tweak_sbox is
  port (
    x_in     : in  unsigned(7 downto 0);
    quadrant : in  std_logic_vector(1 downto 0);
    tweak    : in  unsigned(7 downto 0);
    inv_mode : in  std_logic; -- '0' = forward, '1' = inverse
    y_out    : out unsigned(7 downto 0)
  );
end entity abjad_tweak_sbox;

architecture comb of abjad_tweak_sbox is
begin
  process(x_in, quadrant, tweak, inv_mode)
    variable v_hi, v_lo, v_lo1, v_hi2 : integer range 0 to 15;
    variable v_nf, v_aff, v_unaff     : integer range 0 to 255;
    variable v_rot, v_unxor           : unsigned(7 downto 0);
    variable v_bias                   : unsigned(7 downto 0);
    variable v_f1, v_f2               : integer range 0 to 15;
  begin
    v_bias := quadrant_bias(quadrant);
    if inv_mode = '0' then
      v_hi  := to_integer(x_in(7 downto 4));
      v_lo  := to_integer(x_in(3 downto 0));
      v_f1  := (C_WAFQ_3X3(v_hi mod 3, (v_hi / 3) mod 3) + v_hi * C_BIFURCATION_ORD) mod 16;
      v_lo1 := (v_lo + v_f1) mod 16;
      v_f2  := (digit_root_8(v_lo1 + 1) * 5 + 3) mod 16;
      v_hi2 := (v_hi + v_f2) mod 16;
      v_nf  := v_hi2 * 16 + v_lo1;
      v_aff := (v_nf * C_P_PRIME + C_AL_HAMID_FULL) mod 256;
      v_rot := rotate_left(to_unsigned(v_aff, 8), 3);
      y_out <= v_rot xor tweak xor v_bias;
    else
      v_unxor := x_in xor tweak xor v_bias;
      v_rot   := rotate_right(v_unxor, 3);
      v_unaff := ((to_integer(v_rot) + 256 - C_AL_HAMID_FULL) * C_INV_53_MOD_256) mod 256;
      v_hi2   := v_unaff / 16;
      v_lo1   := v_unaff mod 16;
      v_f2    := (digit_root_8(v_lo1 + 1) * 5 + 3) mod 16;
      v_hi    := (v_hi2 + 16 - v_f2) mod 16;
      v_f1    := (C_WAFQ_3X3(v_hi mod 3, (v_hi / 3) mod 3) + v_hi * C_BIFURCATION_ORD) mod 16;
      v_lo    := (v_lo1 + 16 - v_f1) mod 16;
      y_out   <= to_unsigned(v_hi * 16 + v_lo, 8);
    end if;
  end process;
end architecture comb;
