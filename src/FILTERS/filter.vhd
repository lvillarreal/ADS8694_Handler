-- -------------------------------------------------------------
--
-- Module: filter
-- Generated by MATLAB(R) 9.1 and the Filter Design HDL Coder 3.1.
-- Generated on: 2020-06-20 18:44:34
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Code Generation Options:
--
-- TargetLanguage: VHDL
-- TestBenchStimulus: step ramp chirp 

-- Filter Specifications:
--
-- Sample Rate     : N/A (normalized frequency)
-- Response        : Lowpass
-- Specification   : Fp,Fst,Ap,Ast
-- Stopband Edge   : 0.01
-- Stopband Atten. : 40 dB
-- Passband Edge   : 0.003
-- Passband Ripple : 1 dB
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- HDL Implementation    : Fully parallel
-- Folding Factor        : 1
-- -------------------------------------------------------------
-- Filter Settings:
--
-- Discrete-Time IIR Filter (real)
-- -------------------------------
-- Filter Structure    : Direct-Form II, Second-Order Sections
-- Number of Sections  : 3
-- Stable              : Yes
-- Linear Phase        : No
-- Arithmetic          : fixed
-- Numerator           : s32,29 -> [-4 4)
-- Denominator         : s32,30 -> [-2 2)
-- Scale Values        : s32,38 -> [-7.812500e-03 7.812500e-03)
-- Input               : s19,14 -> [-16 16)
-- Section Input       : s60,41 -> [-262144 262144)
-- Section Output      : s60,35 -> [-16777216 16777216)
-- Output              : s19,14 -> [-16 16)
-- State               : s50,30 -> [-524288 524288)
-- Numerator Prod      : s82,59 -> [-4194304 4194304)
-- Denominator Prod    : s82,60 -> [-2097152 2097152)
-- Numerator Accum     : s84,59 -> [-16777216 16777216)
-- Denominator Accum   : s84,60 -> [-8388608 8388608)
-- Round Mode          : convergent
-- Overflow Mode       : saturate
-- -------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;

ENTITY filter IS
   PORT( clk                             :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         filter_in                       :   IN    std_logic_vector(18 DOWNTO 0); -- sfix19_En14
         filter_out                      :   OUT   std_logic_vector(18 DOWNTO 0)  -- sfix19_En14
         );

END filter;


----------------------------------------------------------------
--Module Architecture: filter
----------------------------------------------------------------
ARCHITECTURE rtl OF filter IS
  -- Local Functions
  -- Type Definitions
  TYPE delay_pipeline_type IS ARRAY (NATURAL range <>) OF signed(49 DOWNTO 0); -- sfix50_En30
  -- Constants
  CONSTANT scaleconst1                    : signed(31 DOWNTO 0) := to_signed(10709456, 32); -- sfix32_En38
  CONSTANT coeff_b1_section1              : signed(31 DOWNTO 0) := to_signed(536870912, 32); -- sfix32_En29
  CONSTANT coeff_b2_section1              : signed(31 DOWNTO 0) := to_signed(1073741824, 32); -- sfix32_En29
  CONSTANT coeff_b3_section1              : signed(31 DOWNTO 0) := to_signed(536870912, 32); -- sfix32_En29
  CONSTANT coeff_a2_section1              : signed(31 DOWNTO 0) := to_signed(-2139048134, 32); -- sfix32_En30
  CONSTANT coeff_a3_section1              : signed(31 DOWNTO 0) := to_signed(1065473645, 32); -- sfix32_En30
  CONSTANT scaleconst2                    : signed(31 DOWNTO 0) := to_signed(10643152, 32); -- sfix32_En38
  CONSTANT coeff_b1_section2              : signed(31 DOWNTO 0) := to_signed(536870912, 32); -- sfix32_En29
  CONSTANT coeff_b2_section2              : signed(31 DOWNTO 0) := to_signed(1073741824, 32); -- sfix32_En29
  CONSTANT coeff_b3_section2              : signed(31 DOWNTO 0) := to_signed(536870912, 32); -- sfix32_En29
  CONSTANT coeff_a2_section2              : signed(31 DOWNTO 0) := to_signed(-2125804992, 32); -- sfix32_En30
  CONSTANT coeff_a3_section2              : signed(31 DOWNTO 0) := to_signed(1052229467, 32); -- sfix32_En30
  CONSTANT scaleconst3                    : signed(31 DOWNTO 0) := to_signed(1708410155, 32); -- sfix32_En38
  CONSTANT coeff_b1_section3              : signed(31 DOWNTO 0) := to_signed(536870912, 32); -- sfix32_En29
  CONSTANT coeff_b2_section3              : signed(31 DOWNTO 0) := to_signed(536870912, 32); -- sfix32_En29
  CONSTANT coeff_b3_section3              : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En29
  CONSTANT coeff_a2_section3              : signed(31 DOWNTO 0) := to_signed(-1060394870, 32); -- sfix32_En30
  CONSTANT coeff_a3_section3              : signed(31 DOWNTO 0) := to_signed(0, 32); -- sfix32_En30
  -- Signals
  SIGNAL input_register                   : signed(18 DOWNTO 0); -- sfix19_En14
  SIGNAL scale1                           : signed(91 DOWNTO 0); -- sfix92_En73
  SIGNAL mul_temp                         : signed(50 DOWNTO 0); -- sfix51_En52
  SIGNAL scaletypeconvert1                : signed(59 DOWNTO 0); -- sfix60_En41
  -- Section 1 Signals 
  SIGNAL a1sum1                           : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL a2sum1                           : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL b1sum1                           : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL b2sum1                           : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL typeconvert1                     : signed(49 DOWNTO 0); -- sfix50_En30
  SIGNAL delay_section1                   : delay_pipeline_type(0 TO 1); -- sfix50_En30
  SIGNAL inputconv1                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL a2mul1                           : signed(81 DOWNTO 0); -- sfix82_En60
  SIGNAL a3mul1                           : signed(81 DOWNTO 0); -- sfix82_En60
  SIGNAL b1mul1                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL b2mul1                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL b3mul1                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL sub_cast                         : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_cast_1                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_temp                         : signed(84 DOWNTO 0); -- sfix85_En60
  SIGNAL sub_cast_2                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_cast_3                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_temp_1                       : signed(84 DOWNTO 0); -- sfix85_En60
  SIGNAL b1multypeconvert1                : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast                         : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_1                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_temp                         : signed(84 DOWNTO 0); -- sfix85_En59
  SIGNAL add_cast_2                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_3                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_temp_1                       : signed(84 DOWNTO 0); -- sfix85_En59
  SIGNAL section_result1                  : signed(59 DOWNTO 0); -- sfix60_En35
  SIGNAL scale2                           : signed(91 DOWNTO 0); -- sfix92_En73
  SIGNAL scaletypeconvert2                : signed(59 DOWNTO 0); -- sfix60_En41
  -- Section 2 Signals 
  SIGNAL a1sum2                           : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL a2sum2                           : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL b1sum2                           : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL b2sum2                           : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL typeconvert2                     : signed(49 DOWNTO 0); -- sfix50_En30
  SIGNAL delay_section2                   : delay_pipeline_type(0 TO 1); -- sfix50_En30
  SIGNAL inputconv2                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL a2mul2                           : signed(81 DOWNTO 0); -- sfix82_En60
  SIGNAL a3mul2                           : signed(81 DOWNTO 0); -- sfix82_En60
  SIGNAL b1mul2                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL b2mul2                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL b3mul2                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL sub_cast_4                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_cast_5                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_temp_2                       : signed(84 DOWNTO 0); -- sfix85_En60
  SIGNAL sub_cast_6                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_cast_7                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_temp_3                       : signed(84 DOWNTO 0); -- sfix85_En60
  SIGNAL b1multypeconvert2                : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_4                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_5                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_temp_2                       : signed(84 DOWNTO 0); -- sfix85_En59
  SIGNAL add_cast_6                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_7                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_temp_3                       : signed(84 DOWNTO 0); -- sfix85_En59
  SIGNAL section_result2                  : signed(59 DOWNTO 0); -- sfix60_En35
  SIGNAL scale3                           : signed(91 DOWNTO 0); -- sfix92_En73
  SIGNAL scaletypeconvert3                : signed(59 DOWNTO 0); -- sfix60_En41
  --   -- Section 3 Signals 
  SIGNAL a1sum3                           : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL b1sum3                           : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL a1sumtypeconvert3                : signed(49 DOWNTO 0); -- sfix50_En30
  SIGNAL delay_section3                   : signed(49 DOWNTO 0); -- sfix50_En30
  SIGNAL inputconv3                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL a2mul3                           : signed(81 DOWNTO 0); -- sfix82_En60
  SIGNAL b1mul3                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL b2mul3                           : signed(81 DOWNTO 0); -- sfix82_En59
  SIGNAL sub_cast_8                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_cast_9                       : signed(83 DOWNTO 0); -- sfix84_En60
  SIGNAL sub_temp_4                       : signed(84 DOWNTO 0); -- sfix85_En60
  SIGNAL b1multypeconvert3                : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_8                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_cast_9                       : signed(83 DOWNTO 0); -- sfix84_En59
  SIGNAL add_temp_4                       : signed(84 DOWNTO 0); -- sfix85_En59
  SIGNAL output_typeconvert               : signed(18 DOWNTO 0); -- sfix19_En14
  SIGNAL output_register                  : signed(18 DOWNTO 0); -- sfix19_En14


BEGIN

  -- Block Statements
  input_reg_process : PROCESS (clk, reset, clk_enable)
  BEGIN
    IF reset = '1' THEN
      input_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        input_register <= signed(filter_in);
      END IF;
    END IF; 
  END PROCESS input_reg_process;

  mul_temp <= input_register * scaleconst1;
  scale1 <= resize(mul_temp & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 92);

  scaletypeconvert1 <= (59 => '0', OTHERS => '1') WHEN scale1(91) = '0' AND scale1(90 DOWNTO 31) = "111111111111111111111111111111111111111111111111111111111111"
      ELSE resize(shift_right(scale1(91 DOWNTO 0) + ( "0" & (scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32) & NOT scale1(32))), 32), 60);

  --   ------------------ Section 1 ------------------

  typeconvert1 <= (49 => '0', OTHERS => '1') WHEN (a1sum1(83) = '0' AND a1sum1(82 DOWNTO 79) /= "0000") OR (a1sum1(83) = '0' AND a1sum1(79 DOWNTO 30) = "01111111111111111111111111111111111111111111111111") -- special case0
      ELSE (49 => '1', OTHERS => '0') WHEN a1sum1(83) = '1' AND a1sum1(82 DOWNTO 79) /= "1111"
      ELSE (resize(shift_right(a1sum1(79 DOWNTO 0) + ( "0" & (a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30) & NOT a1sum1(30))), 30), 50));

  delay_process_section1 : PROCESS (clk, reset, clk_enable)
  BEGIN
    IF reset = '1' THEN
      delay_section1 <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        delay_section1(1) <= delay_section1(0);
        delay_section1(0) <= typeconvert1;
      END IF;
    END IF;
  END PROCESS delay_process_section1;

  inputconv1 <= resize(scaletypeconvert1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 84);

  a2mul1 <= delay_section1(0) * coeff_a2_section1;

  a3mul1 <= delay_section1(1) * coeff_a3_section1;

  b1mul1 <= resize(typeconvert1 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  b2mul1 <= resize(delay_section1(0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  b3mul1 <= resize(delay_section1(1) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  sub_cast <= inputconv1;
  sub_cast_1 <= resize(a2mul1, 84);
  sub_temp <= resize(sub_cast, 85) - resize(sub_cast_1, 85);
  a2sum1 <= (83 => '0', OTHERS => '1') WHEN (sub_temp(84) = '0' AND sub_temp(83) /= '0') OR (sub_temp(84) = '0' AND sub_temp(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN sub_temp(84) = '1' AND sub_temp(83) /= '1'
      ELSE (sub_temp(83 DOWNTO 0));

  sub_cast_2 <= a2sum1;
  sub_cast_3 <= resize(a3mul1, 84);
  sub_temp_1 <= resize(sub_cast_2, 85) - resize(sub_cast_3, 85);
  a1sum1 <= (83 => '0', OTHERS => '1') WHEN (sub_temp_1(84) = '0' AND sub_temp_1(83) /= '0') OR (sub_temp_1(84) = '0' AND sub_temp_1(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN sub_temp_1(84) = '1' AND sub_temp_1(83) /= '1'
      ELSE (sub_temp_1(83 DOWNTO 0));

  b1multypeconvert1 <= resize(b1mul1, 84);

  add_cast <= b1multypeconvert1;
  add_cast_1 <= resize(b2mul1, 84);
  add_temp <= resize(add_cast, 85) + resize(add_cast_1, 85);
  b2sum1 <= (83 => '0', OTHERS => '1') WHEN (add_temp(84) = '0' AND add_temp(83) /= '0') OR (add_temp(84) = '0' AND add_temp(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN add_temp(84) = '1' AND add_temp(83) /= '1'
      ELSE (add_temp(83 DOWNTO 0));

  add_cast_2 <= b2sum1;
  add_cast_3 <= resize(b3mul1, 84);
  add_temp_1 <= resize(add_cast_2, 85) + resize(add_cast_3, 85);
  b1sum1 <= (83 => '0', OTHERS => '1') WHEN (add_temp_1(84) = '0' AND add_temp_1(83) /= '0') OR (add_temp_1(84) = '0' AND add_temp_1(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN add_temp_1(84) = '1' AND add_temp_1(83) /= '1'
      ELSE (add_temp_1(83 DOWNTO 0));

  section_result1 <= (59 => '0', OTHERS => '1') WHEN b1sum1(83) = '0' AND b1sum1(82 DOWNTO 23) = "111111111111111111111111111111111111111111111111111111111111"
      ELSE resize(shift_right(b1sum1(83 DOWNTO 0) + ( "0" & (b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24) & NOT b1sum1(24))), 24), 60);

  scale2 <= section_result1 * scaleconst2;

  scaletypeconvert2 <= (59 => '0', OTHERS => '1') WHEN scale2(91) = '0' AND scale2(90 DOWNTO 31) = "111111111111111111111111111111111111111111111111111111111111"
      ELSE resize(shift_right(scale2(91 DOWNTO 0) + ( "0" & (scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32) & NOT scale2(32))), 32), 60);

  --   ------------------ Section 2 ------------------

  typeconvert2 <= (49 => '0', OTHERS => '1') WHEN (a1sum2(83) = '0' AND a1sum2(82 DOWNTO 79) /= "0000") OR (a1sum2(83) = '0' AND a1sum2(79 DOWNTO 30) = "01111111111111111111111111111111111111111111111111") -- special case0
      ELSE (49 => '1', OTHERS => '0') WHEN a1sum2(83) = '1' AND a1sum2(82 DOWNTO 79) /= "1111"
      ELSE (resize(shift_right(a1sum2(79 DOWNTO 0) + ( "0" & (a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30) & NOT a1sum2(30))), 30), 50));

  delay_process_section2 : PROCESS (clk, reset,clk_enable)
  BEGIN
    IF reset = '1' THEN
      delay_section2 <= (OTHERS => (OTHERS => '0'));
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        delay_section2(1) <= delay_section2(0);
        delay_section2(0) <= typeconvert2;
      END IF;
    END IF;
  END PROCESS delay_process_section2;

  inputconv2 <= resize(scaletypeconvert2 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 84);

  a2mul2 <= delay_section2(0) * coeff_a2_section2;

  a3mul2 <= delay_section2(1) * coeff_a3_section2;

  b1mul2 <= resize(typeconvert2 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  b2mul2 <= resize(delay_section2(0) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  b3mul2 <= resize(delay_section2(1) & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  sub_cast_4 <= inputconv2;
  sub_cast_5 <= resize(a2mul2, 84);
  sub_temp_2 <= resize(sub_cast_4, 85) - resize(sub_cast_5, 85);
  a2sum2 <= (83 => '0', OTHERS => '1') WHEN (sub_temp_2(84) = '0' AND sub_temp_2(83) /= '0') OR (sub_temp_2(84) = '0' AND sub_temp_2(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN sub_temp_2(84) = '1' AND sub_temp_2(83) /= '1'
      ELSE (sub_temp_2(83 DOWNTO 0));

  sub_cast_6 <= a2sum2;
  sub_cast_7 <= resize(a3mul2, 84);
  sub_temp_3 <= resize(sub_cast_6, 85) - resize(sub_cast_7, 85);
  a1sum2 <= (83 => '0', OTHERS => '1') WHEN (sub_temp_3(84) = '0' AND sub_temp_3(83) /= '0') OR (sub_temp_3(84) = '0' AND sub_temp_3(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN sub_temp_3(84) = '1' AND sub_temp_3(83) /= '1'
      ELSE (sub_temp_3(83 DOWNTO 0));

  b1multypeconvert2 <= resize(b1mul2, 84);

  add_cast_4 <= b1multypeconvert2;
  add_cast_5 <= resize(b2mul2, 84);
  add_temp_2 <= resize(add_cast_4, 85) + resize(add_cast_5, 85);
  b2sum2 <= (83 => '0', OTHERS => '1') WHEN (add_temp_2(84) = '0' AND add_temp_2(83) /= '0') OR (add_temp_2(84) = '0' AND add_temp_2(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN add_temp_2(84) = '1' AND add_temp_2(83) /= '1'
      ELSE (add_temp_2(83 DOWNTO 0));

  add_cast_6 <= b2sum2;
  add_cast_7 <= resize(b3mul2, 84);
  add_temp_3 <= resize(add_cast_6, 85) + resize(add_cast_7, 85);
  b1sum2 <= (83 => '0', OTHERS => '1') WHEN (add_temp_3(84) = '0' AND add_temp_3(83) /= '0') OR (add_temp_3(84) = '0' AND add_temp_3(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN add_temp_3(84) = '1' AND add_temp_3(83) /= '1'
      ELSE (add_temp_3(83 DOWNTO 0));

  section_result2 <= (59 => '0', OTHERS => '1') WHEN b1sum2(83) = '0' AND b1sum2(82 DOWNTO 23) = "111111111111111111111111111111111111111111111111111111111111"
      ELSE resize(shift_right(b1sum2(83 DOWNTO 0) + ( "0" & (b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24) & NOT b1sum2(24))), 24), 60);

  scale3 <= section_result2 * scaleconst3;

  scaletypeconvert3 <= (59 => '0', OTHERS => '1') WHEN scale3(91) = '0' AND scale3(90 DOWNTO 31) = "111111111111111111111111111111111111111111111111111111111111"
      ELSE resize(shift_right(scale3(91 DOWNTO 0) + ( "0" & (scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32) & NOT scale3(32))), 32), 60);

  --   ------------------ Section 3 (First Order) ------------------

  a1sumtypeconvert3 <= (49 => '0', OTHERS => '1') WHEN (a1sum3(83) = '0' AND a1sum3(82 DOWNTO 79) /= "0000") OR (a1sum3(83) = '0' AND a1sum3(79 DOWNTO 30) = "01111111111111111111111111111111111111111111111111") -- special case0
      ELSE (49 => '1', OTHERS => '0') WHEN a1sum3(83) = '1' AND a1sum3(82 DOWNTO 79) /= "1111"
      ELSE (resize(shift_right(a1sum3(79 DOWNTO 0) + ( "0" & (a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30) & NOT a1sum3(30))), 30), 50));

  delay_process_section3 : PROCESS (clk, reset,clk_enable)
  BEGIN
    IF reset = '1' THEN
      delay_section3 <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        delay_section3 <= a1sumtypeconvert3;
      END IF;
    END IF; 
  END PROCESS delay_process_section3;

  inputconv3 <= resize(scaletypeconvert3 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 84);

  a2mul3 <= delay_section3 * coeff_a2_section3;

  b1mul3 <= resize(a1sumtypeconvert3 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  b2mul3 <= resize(delay_section3 & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0', 82);

  sub_cast_8 <= inputconv3;
  sub_cast_9 <= resize(a2mul3, 84);
  sub_temp_4 <= resize(sub_cast_8, 85) - resize(sub_cast_9, 85);
  a1sum3 <= (83 => '0', OTHERS => '1') WHEN (sub_temp_4(84) = '0' AND sub_temp_4(83) /= '0') OR (sub_temp_4(84) = '0' AND sub_temp_4(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN sub_temp_4(84) = '1' AND sub_temp_4(83) /= '1'
      ELSE (sub_temp_4(83 DOWNTO 0));

  b1multypeconvert3 <= resize(b1mul3, 84);

  add_cast_8 <= b1multypeconvert3;
  add_cast_9 <= resize(b2mul3, 84);
  add_temp_4 <= resize(add_cast_8, 85) + resize(add_cast_9, 85);
  b1sum3 <= (83 => '0', OTHERS => '1') WHEN (add_temp_4(84) = '0' AND add_temp_4(83) /= '0') OR (add_temp_4(84) = '0' AND add_temp_4(83 DOWNTO 0) = "011111111111111111111111111111111111111111111111111111111111111111111111111111111111") -- special case0
      ELSE (83 => '1', OTHERS => '0') WHEN add_temp_4(84) = '1' AND add_temp_4(83) /= '1'
      ELSE (add_temp_4(83 DOWNTO 0));

  output_typeconvert <= (18 => '0', OTHERS => '1') WHEN (b1sum3(83) = '0' AND b1sum3(82 DOWNTO 63) /= "00000000000000000000") OR (b1sum3(83) = '0' AND b1sum3(63 DOWNTO 45) = "0111111111111111111") -- special case0
      ELSE (18 => '1', OTHERS => '0') WHEN b1sum3(83) = '1' AND b1sum3(82 DOWNTO 63) /= "11111111111111111111"
      ELSE (resize(shift_right(b1sum3(63 DOWNTO 0) + ( "0" & (b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45) & NOT b1sum3(45))), 45), 19));

  Output_Register_process : PROCESS (clk, reset,clk_enable)
  BEGIN
    IF reset = '1' THEN
      output_register <= (OTHERS => '0');
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        output_register <= output_typeconvert;
      END IF;
    END IF; 
  END PROCESS Output_Register_process;

  -- Assignment Statements
		filter_out <= std_logic_vector(output_register);
END rtl;
