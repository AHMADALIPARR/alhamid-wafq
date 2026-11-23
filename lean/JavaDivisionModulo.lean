-- JavaDivisionModulo.lean
-- Lean 4 formalization of JVM / LiquidJava Division & Modulo Lock
-- Mirrors: liquidjava/DivisionModuloLock.java

import Mathlib.Data.Int.Basic
import Mathlib.Tactic

namespace JavaDivisionModulo

/-- Absolute value helper matching the Java `abs` pure method. -/
def abs (x : Int) : Int := if x < 0 then -x else x

/-- Non-zero predicate matching the Java `nonZero` pure method. -/
def nonZero (d : Int) : Prop := d ≠ 0

/--
  JVM / Java division (toward zero).
  Matches `lockedDivide` in LiquidJava.
-/
def lockedDivide (n d : Int) (_h : nonZero d) : Int := n / d

/--
  JVM / Java remainder (sign follows dividend).
  Matches `lockedModuloJava` in LiquidJava.
-/
def lockedModuloJava (n d : Int) (_h : nonZero d) : Int := n % d

/--
  Euclidean remainder (always non-negative).
  Matches `lockedModuloEuclidean` in LiquidJava.
-/
def lockedModuloEuclidean (n d : Int) (h : nonZero d) : Int :=
  let r := n % d
  if r < 0 then r + abs d else r

-- ---------------------------------------------------------------------------
-- Core JVM relationship: n = (n/d)*d + (n%d)
-- ---------------------------------------------------------------------------

theorem java_div_mod_rebuild (n d : Int) (h : nonZero d) :
    n = lockedDivide n d h * d + lockedModuloJava n d h := by
  simp [lockedDivide, lockedModuloJava]
  exact Int.ediv_add_emod n d

-- ---------------------------------------------------------------------------
-- Remainder magnitude bound (Java semantics)
-- ---------------------------------------------------------------------------

theorem java_mod_natAbs_lt (n d : Int) (h : nonZero d) :
    (lockedModuloJava n d h).natAbs < d.natAbs := by
  simp [lockedModuloJava]
  exact Int.emod_lt_of_ne_zero n h

-- ---------------------------------------------------------------------------
-- Sign of Java remainder follows the dividend
-- ---------------------------------------------------------------------------

theorem java_mod_sign_nonneg (n d : Int) (h : nonZero d) (hn : 0 ≤ n) :
    0 ≤ lockedModuloJava n d h := by
  simp [lockedModuloJava]
  exact Int.emod_nonneg n h

theorem java_mod_sign_nonpos (n d : Int) (h : nonZero d) (hn : n ≤ 0) :
    lockedModuloJava n d h ≤ 0 := by
  simp [lockedModuloJava]
  exact Int.emod_nonpos_of_nonpos n hn

-- ---------------------------------------------------------------------------
-- Euclidean remainder is always in [0, |d|)
-- ---------------------------------------------------------------------------

theorem euclidean_mod_nonneg (n d : Int) (h : nonZero d) :
    0 ≤ lockedModuloEuclidean n d h := by
  simp only [lockedModuloEuclidean, abs]
  split_ifs with hr
  · -- r < 0, so r + |d| ≥ 0
    have hmod := Int.emod_lt_of_ne_zero n h
    have hnn := Int.emod_nonneg n h
    omega
  · exact Int.emod_nonneg n h

theorem euclidean_mod_lt (n d : Int) (h : nonZero d) :
    lockedModuloEuclidean n d h < abs d := by
  simp only [lockedModuloEuclidean, abs]
  split_ifs with hr
  · have hmod := Int.emod_lt_of_ne_zero n h
    omega
  · have := Int.emod_lt_of_ne_zero n h
    cases' Int.natAbs_eq d with hpos hneg
    · omega
    · omega

theorem euclidean_mod_rebuild (n d : Int) (h : nonZero d) :
    ∃ q : Int, n = d * q + lockedModuloEuclidean n d h := by
  simp only [lockedModuloEuclidean]
  split_ifs with hr
  · -- negative Java remainder → adjust by +|d| and correct quotient
    use n / d - Int.sign d
    have hrebuild := Int.ediv_add_emod n d
    -- Goal: n = d * (n/d - sign d) + (n%d + |d|)
    have hsign : d * Int.sign d = abs d := by
      simp [Int.sign, abs]
      split_ifs <;> omega
    omega
  · use n / d
    exact Int.ediv_add_emod n d

-- ---------------------------------------------------------------------------
-- Bridge: the Euclidean definition is exactly the Java remainder adjusted
-- ---------------------------------------------------------------------------

theorem java_adjust_eq_euclidean (n d : Int) (h : nonZero d) :
    lockedModuloEuclidean n d h =
      (let r := lockedModuloJava n d h
       if r < 0 then r + abs d else r) := by
  rfl

end JavaDivisionModulo
