# AL-HAMID / WAFQ

**Gnostic / Arabic Esoteric Arithmetic Cryptographic Primitives**

Freestanding multi-language implementations of the Al-Ḥamīd–Wafq kernel:

- Custom-tweaked bijective Abjad S-Box (4 Decoherence Quadrants)
- 49-round Feistel–Wafq block cipher + sponge MAC over 16-lane state
- Elliptic curve arithmetic over $\mathbb{F}_{53}$: $y^2 = x^3 + 11x + 33$
- Formal Lean 4 specifications (zero `sorry`)
- Hardware bindings (VHDL-2008, Bluespec SystemVerilog, Chisel)

## License

**GNU Affero General Public License v3.0** (AGPLv3)

See [LICENSE](LICENSE).

## Repository Layout

```
zig/          Freestanding Zig kernel (C-ABI exported) — primary runtime
lean/         Lean 4 formal specs (EC_SBox + GnosticAbjad core)
vhdl/         VHDL-2008 RTL (wafq_ec_alu + abjad_tweak_sbox)
bsv/          Bluespec SystemVerilog (mkWafqECUnit + mkAbjadTweakSBox)
chisel/       Chisel 3/6 stack bindings (incomplete / WIP)
chapel/       Parallel Chapel verification harness (incomplete / WIP)
docs/         Design notes and extraction notes
```

## Key Constants (Axiom-Derived)

| Symbol              | Value | Meaning                          |
|---------------------|-------|----------------------------------|
| `AL_HAMID_VALUE`    | 53    | Prime field $\mathbb{F}_{53}$  |
| `AL_HAMID_FULL`     | 93    | Affine bias                      |
| `ALI_VALUE`         | 110   |                                  |
| `MASTER_AGGREGATE`  | 256   | $2^8$ ring                     |
| `JAMAL_VECTOR`      | 146   |                                  |
| `POLARITY_DELTA`    | 36    |                                  |
| `BIFURCATION_THRESHOLD` | 49 | Number of Feistel rounds     |
| `WAFQ_ALLAH_3×3`    | magic square constant-sum 33    |

Base point $G_{\mathrm{wafq}} = (7, 33)$ has order 48 on the curve.

## Build Notes

### Zig (recommended entry point)

```bash
zig build-lib -O ReleaseFast zig/alhamid_kernel.zig
# produces libalhamid_kernel.a with C-ABI exports:
#   alhamid_encrypt / alhamid_decrypt / alhamid_mac_tag
#   abjad_tweak_sbox_fwd / abjad_tweak_sbox_inv
#   wafq_ec_scalar_mul / wafq_ec_on_curve
```

### Lean 4

```bash
lake build   # once a lakefile is added
```

The two Lean files are self-contained (`Init` only) and contain exhaustive kernel-checked theorems for bijectivity, curve order, and Feistel invertibility.

### VHDL / BSV

Synthesizable RTL extracted from the Lean specification. Use with your preferred toolchain (Vivado, Yosys, BSC, etc.).

## Status

- **Zig + Lean + VHDL + BSV**: extracted and structured for production use.
- **Chapel / Chisel**: present but incomplete in the source dump (syntax truncated). Marked WIP.
- **Rust**: referenced as original “source of truth” in comments; no Rust sources were present in the supplied markdown. A `rust/` directory can be added when the port is available.

## Provenance

Extracted from a multi-language monolithic markdown dump  
(“AL-HAMID / WAFQ FREESTANDING ZIG KERNEL (C-ABI Exported)”).  
Source-of-truth claims point to GnosticAbjad Lean 4 axioms and a prior Rust runtime by Ahmad Ali Parr / SNAPKITTYWEST.

## Contributing

This repository is released under AGPLv3. Network use of modified versions requires providing Corresponding Source (see AGPL §13).

---

*Think below the abstraction. Verify above the assumption. Own the entire stack.*
