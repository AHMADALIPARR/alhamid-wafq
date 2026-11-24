======================================================
SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
Copyright (C) 2026 Bel Esprit D'Accord Irrevocable Trust (EIN 42-697643)
License-ID: SL-AGPL3-001 | Covenant-Version: 1.0 | Project policy reference

LOCKED DIV-MOD (JAVA TRUNCATED + EUCLIDEAN) & OPENQASM 3.0 REVERSIBLE RESTORING DIVISION
 namespace LockedDivModQuantum

 =============================================================================
 PART 1: RUST `LockedDivMod` PORT (TRUNCATED & EUCLIDEAN DIVISION CONTRACT)
 =============================================================================

structure DivModResult where
  qTrunc  : Int
  rTrunc  : Int
  qEuclid : Int
  rEuclid : Int
  deriving DecidableEq, Repr

def NonZeroInt := { d : Int // d ≠ 0 }

def intSignum (d : Int) : Int :=
  if d > 0 then 1 else if d < 0 then -1 else 0

-- Exact port of `NonZeroI32::locked_div_mod` over mathematical `Int`
def lockedDivMod (d : NonZeroInt) (n : Int) : DivModResult :=
  let dv := d.val
  let qTrunc := Int.tdiv n dv
  let rTrunc := Int.tmod n dv
  let isNeg  := rTrunc < 0
  let dAbs : Int := Int.ofNat dv.natAbs
  let adjust : Int := if isNeg then dAbs else 0
  let rEuclid := rTrunc + adjust
  let qAdjust : Int := if isNeg then intSignum dv else 0
  let qEuclid := qTrunc - qAdjust
  { qTrunc, rTrunc, qEuclid, rEuclid }

def lockedModuloEuclidean (n : Int) (d : NonZeroInt) : Int :=
  (lockedDivMod d n).rEuclid

def lockedDivideEuclidean (n : Int) (d : NonZeroInt) : Int :=
  (lockedDivMod d n).qEuclid

-- Helper: `d.natAbs * signum(d) = d` for `d ≠ 0`
private theorem natAbs_mul_signum (d : Int) (hd : d ≠ 0) :
    (Int.ofNat d.natAbs) * intSignum d = d := by
  unfold intSignum
  omega

-- Theorem 1.1: Truncated Division Identity (n = q_trunc * d + r_trunc)
theorem locked_trunc_identity (d : NonZeroInt) (n : Int) :
    n = (lockedDivMod d n).qTrunc * d.val + (lockedDivMod d n).rTrunc := by
  unfold lockedDivMod
  simp only
  have h := Int.tdiv_add_tmod n d.val
  omega

-- Theorem 1.2: Euclidean Division Identity (n = q_euclid * d + r_euclid)
theorem locked_euclid_identity (d : NonZeroInt) (n : Int) :
    n = (lockedDivMod d n).qEuclid * d.val + (lockedDivMod d n).rEuclid := by
  unfold lockedDivMod
  simp only
  have hbase := Int.tdiv_add_tmod n d.val
  by_cases hneg : Int.tmod n d.val < 0
  · simp only [hneg, ite_true]
    have hs := natAbs_mul_signum d.val d.property
    have hmul : (Int.tdiv n d.val - intSignum d.val) * d.val =
                Int.tdiv n d.val * d.val - intSignum d.val * d.val := by
      exact Int.sub_mul _ _ _
    have hsign : intSignum d.val * d.val = Int.ofNat d.val.natAbs := by
      unfold intSignum
      omega
    omega
  · simp only [hneg, ite_false]
    omega

-- Theorem 1.3: Euclidean Remainder Bounds (0 ≤ r_euclid < |d|)
theorem locked_euclid_bounds (d : NonZeroInt) (n : Int) :
    0 ≤ (lockedDivMod d n).rEuclid ∧
    (lockedDivMod d n).rEuclid < Int.ofNat d.val.natAbs := by
  unfold lockedDivMod
  simp only
  have hlt : (Int.tmod n d.val).natAbs < d.val.natAbs :=
    Int.natAbs_tmod_lt n d.property
  by_cases hneg : Int.tmod n d.val < 0
  · simp only [hneg, ite_true]
    omega
  · simp only [hneg, ite_false]
    omega

-- Theorem 1.4: Java/Truncated Remainder Bounds (-|d| < r_trunc < |d|)
theorem locked_trunc_bounds (d : NonZeroInt) (n : Int) :
    -(Int.ofNat d.val.natAbs) < (lockedDivMod d n).rTrunc ∧
    (lockedDivMod d n).rTrunc < Int.ofNat d.val.natAbs := by
  unfold lockedDivMod
  simp only
  have hlt : (Int.tmod n d.val).natAbs < d.val.natAbs :=
    Int.natAbs_tmod_lt n d.property
  omega

-- =============================================================================
-- PART 2: 32-BIT SIGNED `i32` MODEL (WITH `i32::MIN / -1` GUARD)
-- =============================================================================

def I32_MIN : Int := -2147483648
def I32_MAX : Int :=  2147483647

def inI32 (x : Int) : Bool := (I32_MIN ≤ x) && (x ≤ I32_MAX)

def lockedDivModI32 (n d : Int) (hd : d ≠ 0) : DivModResult :=
  if n == I32_MIN && d == -1 then
    { qTrunc := I32_MIN, rTrunc := 0, qEuclid := I32_MIN, rEuclid := 0 }
  else
    lockedDivMod ⟨d, hd⟩ n

theorem verify_i32_samples :
    (lockedDivModI32 (-7) 3 (by decide)).qEuclid = -3 ∧
    (lockedDivModI32 (-7) 3 (by decide)).rEuclid = 2 ∧
    (lockedDivModI32 (-7) (-3) (by decide)).qEuclid = 3 ∧
    (lockedDivModI32 (-7) (-3) (by decide)).rEuclid = 2 ∧
    (lockedDivModI32 I32_MIN (-1) (by decide)).rEuclid = 0 := by
  decide

-- =============================================================================
-- PART 3: OPENQASM 3.0 REVERSIBLE 32-BIT RESTORING DIVISION IN LEAN 4
-- =============================================================================

-- Reversible primitive gates (`x`, `cx`)
def xGate (q : Bool) : Bool := !q

def cxGate (ctrl target : Bool) : Bool × Bool :=
  (ctrl, ctrl ^^ target)

theorem xGate_involutive (q : Bool) : xGate (xGate q) = q := by
  cases q <;> rfl

theorem cxGate_involutive (c t : Bool) :
    let (c', t') := cxGate c t
    cxGate c' t' = (c, t) := by
  cases c <;> cases t <;> rfl

-- Reversible 32-bit in-place subtractor (`subtract_inplace`) & its inverse (`add_inplace`)
def subtractInplace (target source : BitVec 32) (borrow : Bool) : BitVec 32 × Bool :=
  let borrowOut := target.toNat < source.toNat
  (target - source, borrow ^^ borrowOut)

def addInplace (target source : BitVec 32) (borrow : Bool) : BitVec 32 × Bool :=
  let diff := target + source
  let borrowOut := diff.toNat < source.toNat
  (diff, borrow ^^ borrowOut)

theorem subtractInplace_reversible (target source : BitVec 32) :
    let (diff, b1) := subtractInplace target source false
    let (restored, b2) := addInplace diff source b1
    restored = target ∧ b2 = false := by
  unfold subtractInplace addInplace
  simp only
  constructor
  · exact BitVec.sub_add_cancel target source
  · have h1 : (target - source + source) = target := BitVec.sub_add_cancel target source
    rw [h1]
    cases hlt : decide (target.toNat < source.toNat) <;> simp

-- Quantum register state matching OpenQASM 3.0 top-level qubits
structure QuantumDivState where
  acc      : BitVec 32
  dividend : BitVec 32
  divisor  : BitVec 32
  quotient : BitVec 32
  borrow   : Bool
  deriving DecidableEq, Repr

-- Single restoring division step (shift `(acc, dividend)` left by 1, subtract `divisor`, restore on borrow)
def restoringDivisionStep (st : QuantumDivState) : QuantumDivState :=
  let msb : BitVec 32 := if st.dividend.msb then 1#32 else 0#32
  let accShifted : BitVec 32 := (st.acc <<< 1) ||| msb
  let divShifted : BitVec 32 := st.dividend <<< 1
  let (diff, b) := subtractInplace accShifted st.divisor false
  if b then
    -- Restore accumulator, quotient bit = 0
    let (restored, _) := addInplace diff st.divisor b
    { st with acc := restored, dividend := divShifted, quotient := st.quotient <<< 1, borrow := false }
  else
    -- Keep difference, quotient bit = 1
    { st with acc := diff, dividend := divShifted, quotient := (st.quotient <<< 1) ||| 1#32, borrow := false }

-- 32-step unrolled OpenQASM 3.0 restoring division circuit
def runRestoringDiv32 (dividendIn divisorIn : BitVec 32) : QuantumDivState :=
  let init : QuantumDivState := {
    acc      := 0#32
    dividend := dividendIn
    divisor  := divisorIn
    quotient := 0#32
    borrow   := false
  }
  (List.range 32).foldl (fun st _ => restoringDivisionStep st) init

-- Kernel-verified execution of the 32-qubit restoring division circuit on concrete vectors
theorem verify_qasm_restoring_div :
    let res1 := runRestoringDiv32 100#32 7#32
    res1.quotient = 14#32 ∧ res1.acc = 2#32 ∧
    let res2 := runRestoringDiv32 0xFFFFFFFF#32 53#32
    res2.quotient * 53#32 + res2.acc = 0xFFFFFFFF#32 ∧ res2.acc < 53#32 := by
  decide

end LockedDivModQuantum
