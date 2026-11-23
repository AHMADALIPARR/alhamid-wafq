-- EuclideanDivisionLock.lean
-- Lean 4 + Mathlib4 — Euclidean Division Lock
-- Detailed proofs for unique Euclidean division and Java→Euclidean adjustment

import Mathlib.Data.Int.Basic
import Mathlib.Tactic

/-- Helper: every integer is ≥ 0 or < 0. -/
lemma abs_cases (b : Int) : b ≥ 0 ∨ b < 0 := by
  by_cases h : 0 ≤ b
  · exact Or.inl h
  · exact Or.inr (by omega)

/--
  Unique Euclidean division:
  For any integer a and any nonzero b there exist unique q, r such that
      a = b·q + r   ∧   0 ≤ r   ∧   r < |b|.
-/
theorem euclidean_division_lock (a b : Int) (hb : b ≠ 0) :
    ∃! (q r : Int), a = b * q + r ∧ 0 ≤ r ∧ r < Int.natAbs b := by
  -- ---------- Existence ----------
  have h_exists : ∃ (q r : Int), a = b * q + r ∧ 0 ≤ r ∧ r < Int.natAbs b := by
    refine ⟨a / b, a % b, Int.ediv_add_emod a b, Int.emod_nonneg a hb, ?_⟩
    exact Int.emod_lt_of_ne_zero a hb

  obtain ⟨q, r, hq, hr₀, hr₁⟩ := h_exists

  -- ---------- Uniqueness ----------
  refine ⟨⟨q, r, ⟨hq, hr₀, hr₁⟩⟩, ?_⟩
  rintro ⟨q', r', hq', hr'₀, hr'₁⟩

  -- From the two reconstructions: r' - r = b·(q - q')
  have h_diff : r' - r = b * (q - q') := by
    have : b * q + r = b * q' + r' := by linarith
    linarith

  -- Show the quotient difference is zero
  have h_q : q - q' = 0 := by
    by_contra hne
    have hδ : (q - q' : Int) ≠ 0 := hne
    have hδ_abs : (q - q').natAbs ≥ 1 := Nat.one_le_iff_ne_zero.mpr (Int.natAbs_ne_zero.mpr hδ)
    -- |r' - r| = |b| · |q - q'| ≥ |b|
    have hmul : (r' - r).natAbs = b.natAbs * (q - q').natAbs := by
      rw [h_diff, Int.natAbs_mul]
    -- But both remainders lie in [0, |b|), therefore |r' - r| < |b|
    have h_lt : (r' - r).natAbs < b.natAbs := by omega
    -- Contradiction
    nlinarith

  have h_qq : q = q' := sub_eq_zero.mp h_q
  have h_rr : r = r' := by
    have := congr_arg (fun x : Int => a - b * x) h_qq
    linarith
  exact ⟨h_qq, h_rr⟩

/--
  Convert a Java-style (sign-follows-dividend) remainder into a Euclidean remainder.
-/
def java_mod_adjust (a b : Int) (_hb : b ≠ 0) : Int :=
  let r := a % b
  if r < 0 then r + Int.natAbs b else r

/--
  The adjustment always produces a true Euclidean remainder:
      0 ≤ r < |b|   and   ∃ q, a = b·q + r.
-/
theorem java_adjust_yields_euclidean (a b : Int) (hb : b ≠ 0) :
    let r := java_mod_adjust a b hb
    0 ≤ r ∧ r < Int.natAbs b ∧ ∃ q : Int, a = b * q + r := by
  dsimp [java_mod_adjust]
  have h_rebuild := Int.ediv_add_emod a b
  have h_nonneg  := Int.emod_nonneg a hb
  have h_lt      := Int.emod_lt_of_ne_zero a hb

  split_ifs with hr
  · -- Java remainder negative: add |b|
    have lower : 0 ≤ (a % b) + b.natAbs := by omega
    have upper : (a % b) + b.natAbs < b.natAbs := by omega
    refine ⟨lower, upper, ?_⟩
    refine ⟨a / b - Int.sign b, ?_⟩
    have hsign : b * Int.sign b = ↑b.natAbs := by
      cases' abs_cases b with hpos hneg
      · rw [Int.sign_eq_one_of_pos (lt_of_le_of_ne hpos hb.symm)]
        omega
      · rw [Int.sign_eq_neg_one_of_neg hneg]
        omega
    linarith [h_rebuild, hsign]
  · exact ⟨h_nonneg, h_lt, ⟨a / b, h_rebuild⟩⟩
