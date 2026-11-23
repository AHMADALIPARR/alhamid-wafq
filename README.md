<div align="center">

```
 ▄▄▄       ██▓        ██░ ██  ▄▄▄       ███▄ ▄███▓ ██▓▓█████▄ 
▒████▄    ▓██▒       ▓██░ ██▒▒████▄    ▓██▒▀█▀ ██▒▓██▒▒██▀ ██▌
▒██  ▀█▄  ▒██░       ▒██▀▀██░▒██  ▀█▄  ▓██    ▓██░▒██▒░██   █▌
░██▄▄▄▄██ ▒██░       ░▓█ ░██ ░██▄▄▄▄██ ▒██    ▒██ ░██░░▓█▄   ▌
 ▓█   ▓██▒░██████▒   ░▓█▒░██▓ ▓█   ▓██▒▒██▒   ░██▒░██░░▒████▓ 
 ▒▒   ▓▒█░░ ▒░▓  ░    ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒░   ░  ░░▓   ▒▒▓  ▒ 
  ▒   ▒▒ ░░ ░ ▒  ░    ▒ ░▒░ ░  ▒   ▒▒ ░░  ░      ░ ▒ ░ ░ ▒  ▒ 
  ░   ▒     ░ ░       ░  ░░ ░  ░   ▒   ░      ░    ▒ ░ ░ ░  ░ 
      ░  ░    ░  ░    ░  ░  ░      ░  ░       ░    ░     ░    
                                                       ░      
```

```
 ██╗    ██╗ █████╗ ███████╗ ██████╗ 
 ██║    ██║██╔══██╗██╔════╝██╔═══██╗
 ██║ █╗ ██║███████║█████╗  ██║   ██║
 ██║███╗██║██╔══██║██╔══╝  ██║▄▄ ██║
 ╚███╔███╔╝██║  ██║██║     ╚██████╔╝
  ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝      ╚══▀▀═╝ 
```

### GNOSTIC / ARABIC ESOTERIC ARITHMETIC  ·  FREESTANDING CRYPTO KERNEL

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-d4a24c?style=for-the-badge&labelColor=0e100e)](LICENSE)
[![Lean 4](https://img.shields.io/badge/Lean%204-v4.14.0-blue?style=for-the-badge&labelColor=0e100e)](lean/)
[![Zig](https://img.shields.io/badge/Zig-C--ABI-black?style=for-the-badge&labelColor=0e100e)](zig/)
[![LiquidJava](https://img.shields.io/badge/LiquidJava-Spec-green?style=for-the-badge&labelColor=0e100e)](liquidjava/)
[![Status](https://img.shields.io/badge/STATUS-KERNEL%20ONLINE-00ff9f?style=for-the-badge&labelColor=0e100e)](https://github.com/AHMADALIPARR/alhamid-wafq)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│  0x35 AL_HAMID   │  0x5D FULL   │  0x6E ALI   │  0x92 JAMAL  │  0x24 DELTA  │
│  0x31 BIFURCATE  │  0x100 AGG   │  F_53 EC    │  16 LANES    │  49 ROUNDS   │
└──────────────────────────────────────────────────────────────────────────────┘
```

</div>

---

## 1. SYSTEM MATRIX

| Layer                    | Path                          | Language / Tool          | Role                                              | Status      |
|--------------------------|-------------------------------|--------------------------|---------------------------------------------------|-------------|
| Runtime Kernel           | `zig/`                        | Zig (C-ABI)              | Encrypt, decrypt, MAC, S-Box, EC scalar mul       | ONLINE      |
| Formal Core              | `lean/GnosticAbjad*`          | Lean 4 (Init only)       | Abjad axioms, Feistel, sponge, EC, bijective S-Box| VERIFIED    |
| Euclidean Division Lock  | `lean/EuclideanDivisionLock`  | Lean 4 + Mathlib         | Unique (q,r) Euclidean division                   | VERIFIED    |
| JVM Division Lock        | `lean/JavaDivisionModulo`     | Lean 4 + Mathlib         | Formalization of LiquidJava / JVM div-mod         | VERIFIED    |
| LiquidJava Spec          | `liquidjava/`                 | Java + LiquidJava        | Locked division & modulo pair (source of truth)   | ONLINE      |
| RTL – EC + S-Box         | `vhdl/`                       | VHDL-2008                | `wafq_ec_alu` + `abjad_tweak_sbox`                | SYNTH-READY |
| RTL – Bluespec           | `bsv/`                        | Bluespec SystemVerilog   | `mkWafqECUnit` + `mkAbjadTweakSBox`               | SYNTH-READY |
| HW Stack                 | `chisel/`                     | Chisel 3/6               | DecoupledIO top + blackboxes                      | WIP         |
| Parallel Harness         | `chapel/`                     | Chapel                   | Multi-lane verification harness                   | WIP         |

---

## 2. CORE CONSTANTS (AXIOM TABLE)

| Symbol                     | Value (dec / hex) | Role                                              |
|----------------------------|-------------------|---------------------------------------------------|
| `AL_HAMID_VALUE`           | 53 / 0x35         | Prime field modulus F_53                          |
| `AL_HAMID_FULL_VALUE`      | 93 / 0x5D         | Affine whitening constant                         |
| `ALI_VALUE`                | 110 / 0x6E        | Round / key-schedule constant                     |
| `JAMAL_VECTOR`             | 146 / 0x92        | Expansion (Jamāl) polarity vector                 |
| `JALAL_VECTOR`             | 110 / 0x6E        | Contraction (Jalāl) polarity vector               |
| `POLARITY_DELTA`           | 36 / 0x24         | Jamāl − Jalāl                                     |
| `BIFURCATION_ORDER`        | 7 / 0x07          | Digit-root order                                  |
| `BIFURCATION_THRESHOLD`    | 49 / 0x31         | Number of Feistel rounds (7²)                     |
| `MASTER_AGGREGATE`         | 256 / 0x100       | Byte ring Z/256Z                                  |
| `MATRIX_DIMENSION`         | 16 / 0x10         | State lanes                                       |
| `INV_53_MOD_256`           | 29 / 0x1D         | Multiplicative inverse of 53 mod 256              |
| `EC_A` / `EC_B`            | 11 / 33           | Curve coefficients y² = x³ + 11x + 33 (mod 53)    |

```
WAFQ_ALLAH_3x3  (magic constant sum = 33)
┌────┬────┬────┐
│  8 │  1 │ 24 │
├────┼────┼────┤
│ 15 │ 11 │  7 │
├────┼────┼────┤
│ 10 │ 21 │  2 │
└────┴────┴────┘
```

Base point G_wafq = (7, 33)  ·  Order 48  ·  48 · G_wafq = O (infinity)

---

## 3. ARCHITECTURE

```
                    ┌──────────────────────────────────────┐
                    │         AL-HAMID-256 KERNEL          │
                    │  16-lane state · 49 Feistel rounds   │
                    └──────────────────┬───────────────────┘
                                       │
          ┌────────────────────────────┼────────────────────────────┐
          │                            │                            │
          ▼                            ▼                            ▼
   ┌─────────────┐            ┌─────────────────┐          ┌────────────────┐
   │  Tweak S-Box │            │  Feistel F + RC │          │  Wafq EC F_53  │
   │  4 Quadrants │            │  digitRoot mix  │          │  y²=x³+11x+33  │
   │  bijective   │            │  affine perm    │          │  scalar mul    │
   └─────────────┘            └─────────────────┘          └────────────────┘
          │                            │                            │
          └────────────────────────────┼────────────────────────────┘
                                       ▼
                    ┌──────────────────────────────────────┐
                    │     SPONGE MAC  ·  4-byte TAG        │
                    └──────────────────────────────────────┘
```

### Decoherence Quadrants

| Quadrant              | Bias | Polarity | Direction |
|-----------------------|------|----------|-----------|
| Q1_EnochianLTR        | 53   | Jamāl    | LTR       |
| Q2_LatinLTR           | 146  | Jamāl    | LTR       |
| Q3_HebrewRTL          | 110  | Jalāl    | RTL       |
| Q4_ArabicRTL          | 36   | Jalāl    | RTL       |

---

## 4. ZIG KERNEL (`zig/alhamid_kernel.zig`)

Freestanding C-ABI exported kernel.

```bash
zig build-lib -O ReleaseFast zig/alhamid_kernel.zig
```

| Exported Symbol              | Signature (conceptual)                          | Purpose                        |
|------------------------------|-------------------------------------------------|--------------------------------|
| `alhamid_encrypt`            | (key[8], pt[16], ct[16])                        | 49-round block encrypt         |
| `alhamid_decrypt`            | (key[8], ct[16], pt[16])                        | 49-round block decrypt         |
| `alhamid_mac_tag`            | (key, blocks, n, tag[4])                        | Sponge MAC → 4-byte tag        |
| `abjad_tweak_sbox_fwd`       | (x, quadrant, tweak) → u8                       | Forward tweaked S-Box          |
| `abjad_tweak_sbox_inv`       | (y, quadrant, tweak) → u8                       | Inverse tweaked S-Box          |
| `wafq_ec_scalar_mul`         | (scalar, px, py, p_inf → rx, ry, r_inf)         | EC scalar multiplication       |
| `wafq_ec_on_curve`           | (x, y, is_inf) → bool                           | Point-on-curve predicate       |

Compile-time checks inside the kernel:
- 53 * 29 ≡ 1 (mod 256)
- G_wafq = (7,33) lies on the curve
- S-Box is bijective for every input under fixed tweak

---

## 5. LEAN 4 FORMALIZATION (`lean/`)

### 5.1 Core Package — GnosticAbjad (zero external dependencies)

```bash
cd lean
lake build GnosticAbjad
```

| Module                       | Content                                                                 |
|------------------------------|-------------------------------------------------------------------------|
| `GnosticAbjad`               | 28-letter Abjad matrix, polarity partition, magic squares, Feistel-Wafq cipher, sponge MAC, state machine dichotomy |
| `GnosticAbjad.EC_SBox`       | F_53 arithmetic, curve y² = x³ + 11x + 33, bijective tweaked S-Box, exhaustive bijectivity theorems |

Key theorems (kernel-checked, no `sorry`):

```
theorem axiom_abjad_bounds
theorem axiom_abjad_injective
theorem axiom_polarity_partition          -- 7 Jamāl : 21 Jalāl
theorem axiom_digitRoot_range
theorem axiom_al_hamid_bifurcation        -- 53 → 106 → 7 → 49
theorem axiom_allah_equilibrium
theorem axiom_wafq_allah_valid            -- 3×3 magic square
theorem axiom_quadrant_periodicity
theorem axiom_quadrant_polarity_flip
theorem axiom_master_matrix_invariants
theorem axiom_sethian_dichotomy
theorem feistel_roundtrip
theorem permute_roundtrip
theorem round_roundtrip
theorem cipher_correctness                -- 49-round invertibility
theorem axiom_fp53_inv_valid
theorem axiom_wafq_ec_nonsingular
theorem axiom_base_points_on_curve
theorem axiom_wafq_ec_order_divides_48
theorem axiom_tweakSBox_bijective_q1
theorem axiom_tweakSBox_sample_bijective
theorem witness_non_trivial_permutation
theorem witness_key_sensitivity
```

### 5.2 EuclideanDivisionLock (Mathlib)

```bash
lake build EuclideanDivisionLock
```

```
theorem euclidean_division_lock
  (a b : Int) (hb : b ≠ 0) :
  ∃! (q r : Int), a = b * q + r ∧ 0 ≤ r ∧ r < Int.natAbs b
```

Also provides `java_mod_adjust` and a (partial) bridge theorem to Euclidean remainder.

### 5.3 JavaDivisionModulo (Mathlib) — mirrors LiquidJava

```bash
lake build JavaDivisionModulo
```

| Definition / Theorem              | Meaning (matches LiquidJava)                          |
|-----------------------------------|-------------------------------------------------------|
| `lockedDivide`                    | JVM toward-zero division                              |
| `lockedModuloJava`                | JVM remainder (sign follows dividend)                 |
| `lockedModuloEuclidean`           | Non-negative Euclidean remainder                      |
| `java_div_mod_rebuild`            | n = (n/d)*d + (n%d)                                   |
| `java_mod_natAbs_lt`              | |n % d| < |d|                                         |
| `java_mod_sign_nonneg`            | n ≥ 0 → n%d ≥ 0                                       |
| `java_mod_sign_nonpos`            | n ≤ 0 → n%d ≤ 0                                       |
| `euclidean_mod_nonneg`            | 0 ≤ Euclidean remainder                               |
| `euclidean_mod_lt`                | Euclidean remainder < |d|                             |
| `euclidean_mod_rebuild`           | ∃ q. n = d*q + Euclidean remainder                    |
| `java_adjust_eq_euclidean`        | Euclidean = Java remainder adjusted when negative     |

---

## 6. LIQUIDJAVA SPECIFICATION (`liquidjava/`)

Source-level specification that the Lean `JavaDivisionModulo` formalizes.

```java
// liquidjava/DivisionModuloLock.java

lockedDivide(n, d)          // toward-zero quotient
lockedModuloJava(n, d)      // sign-of-dividend remainder
lockedModuloEuclidean(n, d) // always non-negative remainder
```

Key LiquidJava contracts:

- `@requires nonZero(d)`
- `@ensures n == lockedDivide(n,d) * d + res`
- `@ensures res > -abs(d) && res < abs(d)`
- `@ensures (n >= 0) ==> (res >= 0)`
- `@ensures (n <= 0) ==> (res <= 0)`
- Euclidean variant: `0 <= res && res < abs(d)`

---

## 7. HARDWARE

### VHDL-2008 (`vhdl/wafq_ec_and_sbox.vhd`)

- Package `wafq_ec_pkg` — constants, INV53_LUT, digit_root, quadrant_bias
- Entity `wafq_ec_alu` — point double / add over F_53
- Entity `abjad_tweak_sbox` — combinational forward/inverse S-Box

### Bluespec (`bsv/WafqECSBox.bsv`)

- `mkWafqECUnit` — scalar multiplier (binary method)
- `mkAbjadTweakSBox` — pure combinational transform

### Chisel (`chisel/AlHamidStack.scala`) — WIP

DecoupledIO stack that binds the VHDL/BSV blackboxes. Source was truncated in the original dump; structure is present.

### Chapel (`chapel/AlHamidStack.chpl`) — WIP

Parallel verification harness calling the Zig C-ABI. Also truncated in the original dump.

---

## 8. BUILD QUICK REFERENCE

```bash
# Zig runtime
zig build-lib -O ReleaseFast zig/alhamid_kernel.zig

# Lean core (no Mathlib)
cd lean && lake build GnosticAbjad

# Lean + Mathlib targets
cd lean && lake build EuclideanDivisionLock
cd lean && lake build JavaDivisionModulo

# LiquidJava (requires LiquidJava toolchain)
# javac / liquidjava checker on liquidjava/DivisionModuloLock.java
```

Toolchain pin: `lean/lean-toolchain` → `leanprover/lean4:v4.14.0`

---

## 9. STATUS MATRIX

```
 COMPONENT                  │ STATE
────────────────────────────┼────────────────
 Zig Kernel                 │ ██████████  ONLINE
 Lean GnosticAbjad          │ ██████████  VERIFIED
 Lean EC_SBox               │ ██████████  VERIFIED
 Lean EuclideanDivisionLock │ ██████████  VERIFIED
 Lean JavaDivisionModulo    │ ██████████  VERIFIED
 LiquidJava Spec            │ ██████████  ONLINE
 VHDL RTL                   │ ████████░░  SYNTH-READY
 Bluespec                   │ ████████░░  SYNTH-READY
 Chisel Stack               │ ████░░░░░░  WIP / TRUNCATED
 Chapel Harness             │ ████░░░░░░  WIP / TRUNCATED
 Rust Port                  │ ░░░░░░░░░░  PENDING
```

---

## 10. LICENSE

**GNU Affero General Public License v3.0**

Network use of modified versions requires providing Corresponding Source (AGPL §13).

```
Copyright (C) 2026  Ahmad Ali Parr / SNAPKITTYWEST
```

---

<div align="center">

```
═══════════════════════════════════════════════════════════════
  THINK BELOW THE ABSTRACTION
  VERIFY ABOVE THE ASSUMPTION
  OWN THE ENTIRE STACK
═══════════════════════════════════════════════════════════════
```

`0x35 · 0x5D · 0x6E · 0x24 · 0x31`

</div>
