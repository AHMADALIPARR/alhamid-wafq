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

### `GNOSTIC / ARABIC ESOTERIC ARITHMETIC  ·  FREESTANDING CRYPTO KERNEL`

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-d4a24c?style=for-the-badge&labelColor=0e100e)](LICENSE)
[![Lean 4](https://img.shields.io/badge/Lean%204-v4.14.0-blue?style=for-the-badge&labelColor=0e100e)](lean/)
[![Zig](https://img.shields.io/badge/Zig-C--ABI-black?style=for-the-badge&labelColor=0e100e)](zig/)
[![Status](https://img.shields.io/badge/STATUS-KERNEL%20ONLINE-00ff9f?style=for-the-badge&labelColor=0e100e)](https://github.com/AHMADALIPARR/alhamid-wafq)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  0x35  ·  AL_HAMID_VALUE     │  0x5D  ·  AL_HAMID_FULL     │  0x6E  ·  ALI  │
│  0x92  ·  JAMAL_VECTOR       │  0x6E  ·  JALAL_VECTOR      │  0x24  ·  Δ    │
│  0x31  ·  BIFURCATION (49)   │  0x100 ·  MASTER_AGGREGATE  │  F₅₃  ·  EC   │
└─────────────────────────────────────────────────────────────────────────────┘
```

</div>

---

## ▸ SYSTEM MATRIX

| Layer              | Language / Toolchain      | Role                                      | Status     |
|--------------------|---------------------------|-------------------------------------------|------------|
| **Runtime Kernel** | Zig (C-ABI)               | Encrypt / Decrypt / MAC / S-Box / EC      | `ONLINE`   |
| **Formal Spec**    | Lean 4 (Lake)             | Zero-`sorry` axioms + invertibility proofs| `VERIFIED` |
| **RTL – EC**       | VHDL-2008                 | `wafq_ec_alu` over F₅₃                    | `SYNTH`    |
| **RTL – S-Box**    | VHDL-2008 + Bluespec      | Bijective Abjad Tweak S-Box               | `SYNTH`    |
| **HW Stack**       | Chisel 3/6                | DecoupledIO top + blackboxes              | `WIP`      |
| **Parallel Harness**| Chapel                   | Multi-lane verification                   | `WIP`      |

---

## ▸ CORE CONSTANTS  ·  AXIOM TABLE

| Symbol                     | Hex / Dec | Mathematical Role                          |
|----------------------------|-----------|--------------------------------------------|
| `AL_HAMID_VALUE`           | `0x35` / 53 | Prime field modulus F₅₃                   |
| `AL_HAMID_FULL_VALUE`      | `0x5D` / 93 | Affine whitening constant                  |
| `ALI_VALUE`                | `0x6E` / 110| Round / key schedule constant              |
| `JAMAL_VECTOR`             | `0x92` / 146| Expansion polarity vector                  |
| `JALAL_VECTOR`             | `0x6E` / 110| Contraction polarity vector                |
| `POLARITY_DELTA`           | `0x24` / 36 | Jamāl − Jalāl                              |
| `BIFURCATION_ORDER`        | `0x07` / 7  | Digit-root order                           |
| `BIFURCATION_THRESHOLD`    | `0x31` / 49 | Feistel rounds (7²)                        |
| `MASTER_AGGREGATE`         | `0x100`/ 256| Byte ring ℤ/256ℤ                           |
| `MATRIX_DIMENSION`         | `0x10` / 16 | State lanes                                |
| `INV_53_MOD_256`           | `0x1D` / 29 | 53⁻¹ (mod 256)                             |
| `EC_A` / `EC_B`            | 11 / 33     | Curve y² = x³ + 11x + 33 (mod 53)          |

```
WAFQ_ALLAH_3×3  (constant sum = 33)
┌────┬────┬────┐
│  8 │  1 │ 24 │
├────┼────┼────┤
│ 15 │ 11 │  7 │
├────┼────┼────┤
│ 10 │ 21 │  2 │
└────┴────┴────┘
```

**Base point** `G_wafq = (7, 33)` · **Order** 48 · **Infinity** after 48·G

---

## ▸ ARCHITECTURE

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
   │  Tweak S-Box │            │  Feistel F + RC │          │  Wafq EC F₅₃   │
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
| `Q1_EnochianLTR`      | 53   | Jamāl    | LTR       |
| `Q2_LatinLTR`         | 146  | Jamāl    | LTR       |
| `Q3_HebrewRTL`        | 110  | Jalāl    | RTL       |
| `Q4_ArabicRTL`        | 36   | Jalāl    | RTL       |

---

## ▸ BUILD

### Zig Kernel (primary runtime)

```bash
zig build-lib -O ReleaseFast zig/alhamid_kernel.zig
```

Exported C-ABI surface:

| Symbol                      | Purpose                          |
|-----------------------------|----------------------------------|
| `alhamid_encrypt`           | 16-byte block encrypt            |
| `alhamid_decrypt`           | 16-byte block decrypt            |
| `alhamid_mac_tag`           | Sponge MAC → 4-byte tag          |
| `abjad_tweak_sbox_fwd`      | Forward tweaked S-Box            |
| `abjad_tweak_sbox_inv`      | Inverse tweaked S-Box            |
| `wafq_ec_scalar_mul`        | EC scalar multiplication         |
| `wafq_ec_on_curve`          | Point-on-curve check             |

### Lean 4 Formalization

```bash
cd lean
lake build
```

| Module                    | Content                                      |
|---------------------------|----------------------------------------------|
| `GnosticAbjad`            | Abjad matrix, polarity, Feistel, sponge MAC  |
| `GnosticAbjad.EC_SBox`    | F₅₃ curve + bijective S-Box theorems         |

Toolchain: `leanprover/lean4:v4.14.0` · Zero external dependencies · All proofs kernel-checked.

### Hardware

```text
vhdl/wafq_ec_and_sbox.vhd     →  wafq_ec_alu + abjad_tweak_sbox
bsv/WafqECSBox.bsv            →  mkWafqECUnit + mkAbjadTweakSBox
chisel/AlHamidStack.scala     →  DecoupledIO top (WIP)
```

---

## ▸ STATUS MATRIX

```
 COMPONENT          │ STATE
────────────────────┼──────────────
 Zig Kernel         │ ██████████  ONLINE
 Lean Specs         │ ██████████  VERIFIED
 VHDL RTL           │ ████████░░  SYNTH-READY
 Bluespec           │ ████████░░  SYNTH-READY
 Chisel Stack       │ ████░░░░░░  WIP / TRUNCATED
 Chapel Harness     │ ████░░░░░░  WIP / TRUNCATED
 Rust Port          │ ░░░░░░░░░░  PENDING
```

---

## ▸ LICENSE

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
