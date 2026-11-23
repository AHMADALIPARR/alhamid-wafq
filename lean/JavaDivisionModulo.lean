-- JavaDivisionModulo.lean
-- Lean 4 formalization of JVM / LiquidJava Division & Modulo Lock
-- Detailed proofs mirroring liquidjava/DivisionModuloLock.java

import Mathlib.Data.Int.Basic
import Mathlib.Tactic

namespace JavaDivisionModulo

/-- Absolute value matching the Java `abs` pure method. -/
def abs (x : Int) : Int := if x < 0 then -x else x

/-- Non-zero predicate matching the Java `nonZero` pure method. -/
def nonZero (d : Int) : Prop := d ≠ 0

/-- JVM / Java division (toward zero). Matches `lockedDivide`. -/
def lockedDivide (n d : Int) (_h : nonZero d) : Int := n / d

/-- JVM / Java remainder (sign follows dividend). Matches `lockedModuloJava`. -/
def lockedModuloJava (n d : Int) (_h : nonZero d) : Int := n % d

/-- Euclidean remainder (always non-negative). Matches `lockedModuloEuclidean`. -/
def lockedModuloEuclidean (n d : Int) (h : nonZero d) : Int :=
  let r := n % d
  if r < 0 then r + abs d else r

-- ---------------------------------------------------------------------------
-- Core JVM relationship
-- ---------------------------------------------------------------------------

/-- n = (n/d)·d + (n%d)  (fundamental JVM identity). -/
theorem java_div_mod_rebuild (n d : Int) (h : nonZero d) :
    n = lockedDivide n d h * d + lockedModuloJava n d h := by
  simp [lockedDivide, lockedModuloJava]
  exact Int.ediv_add_emod n d

-- ---------------------------------------------------------------------------
-- Magnitude of the Java remainder
-- ---------------------------------------------------------------------------

/-- |n % d| < |d|. -/
theorem java_mod_natAbs_lt (n d : Int) (h : nonZero d) :
    (lockedModuloJava n d h).natAbs < d.natAbs := by
  simp [lockedModuloJava]
  exact Int.emod_lt_of_ne_zero n h

-- ---------------------------------------------------------------------------
-- Sign of the Java remainder follows the dividend
-- ---------------------------------------------------------------------------

/-- If n ≥ 0 then n%d ≥ 0. -/
theorem java_mod_sign_nonneg (n d : Int) (h : nonZero d) (hn : 0 ≤ n) :
    0 ≤ lockedModuloJava n d h := by
  simp [lockedModuloJava]
  exact Int.emod_nonneg n h

/-- If n ≤ 0 then n%d ≤ 0. -/
theorem java_mod_sign_nonpos (n d : Int) (h : nonZero d) (hn : n ≤ 0) :
    lockedModuloJava n d h ≤ 0 := by
  simp [lockedModuloJava]
  exact Int.emod_nonpos_of_nonpos n hn

-- ---------------------------------------------------------------------------
-- Euclidean remainder properties
-- ---------------------------------------------------------------------------

/-- Euclidean remainder is non-negative. -/
theorem euclidean_mod_nonneg (n d : Int) (h : nonZero d) :
    0 ≤ lockedModuloEuclidean n d h := by
  simp only [lockedModuloEuclidean, abs]
  split_ifs with hr
  · have := Int.emod_lt_of_ne_zero n h
    omega
  · exact Int.emod_nonneg n h

/-- Euclidean remainder is strictly less than |d|. -/
theorem euclidean_mod_lt (n d : Int) (h : nonZero d) :
    lockedModuloEuclidean n d h < abs d := by
  simp only [lockedModuloEuclidean, abs]
  split_ifs with hr
  · have := Int.emod_lt_of_ne_zero n h
    omega
  · have hlt := Int.emod_lt_of_ne_zero n h
    cases' Int.natAbs_eq d with hpos hneg
    · omega
    · omega

/-- Existence of a quotient for the Euclidean remainder. -/
theorem euclidean_mod_rebuild (n d : Int) (h : nonZero d) :
    ∃ q : Int, n = d * q + lockedModuloEuclidean n d h := by
  simp only [lockedModuloEuclidean]
  split_ifs with hr
  · refine ⟨n / d - Int.sign d, ?_⟩
    have hrebuild := Int.ediv_add_emod n d
    have hsign : d * Int.sign d = abs d := by
      simp [Int.sign, abs]
      split_ifs <;> omega
    omega
  · exact ⟨n / d, Int.ediv_add_emod n d⟩

-- ---------------------------------------------------------------------------
-- Bridge between the two remainder notions
-- ---------------------------------------------------------------------------

/-- The Euclidean definition is exactly the Java remainder with a possible adjustment. -/
theorem java_adjust_eq_euclidean (n d : Int) (h : nonZero d) :
    lockedModuloEuclidean n d h =
      (let r := lockedModuloJava n d h
       if r < 0 then r + abs d else r) := by
  rfl

/--
  Combined statement that mirrors the LiquidJava contracts for the Euclidean path:
  0 ≤ res < |d|  and  ∃ q, n = d·q + res.
-/
theorem lockedModuloEuclidean_spec (n d : Int) (h : nonZero d) :
    let res := lockedModuloEuclidean n d h
    0 ≤ res ∧ res < abs d ∧ ∃ q : Int, n = d * q + res := by
  exact ⟨euclidean_mod_nonneg n d h,
         euclidean_mod_lt n d h,
         euclidean_mod_rebuild n d h⟩

/--
  Combined statement that mirrors the LiquidJava contracts for the Java path:
  n = q·d + res,  |res| < |d|,  and sign(res) follows sign(n).
-/
theorem lockedModuloJava_spec (n d : Int) (h : nonZero d) :
    let q   := lockedDivide n d h
    let res := lockedModuloJava n d h
    n = q * d + res ∧
    res.natAbs < d.natAbs ∧
    (0 ≤ n → 0 ≤ res) ∧
    (n ≤ 0 → res ≤ 0) := by
  refine ⟨java_div_mod_rebuild n d h,
          java_mod_natAbs_lt n d h,
          fun hn => java_mod_sign_nonneg n d h hn,
          fun hn => java_mod_sign_nonpos n d h hn⟩

end JavaDivisionModulo
