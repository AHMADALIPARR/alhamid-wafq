# AL-HAMID / WAFQ — Lean 4 Formalization

Zero-`sorry` formalization of the Gnostic/Arabic esoteric arithmetic primitives
and the Al-Ḥamīd–Wafq cryptographic constructions.

## Build

```bash
cd lean
lake build
```

Requires Lean 4 (see `lean-toolchain`).

## Modules

- `GnosticAbjad` — core Abjad axioms, polarity, magic squares, Feistel-Wafq cipher, sponge MAC
- `GnosticAbjad.EC_SBox` — elliptic curve over F_53 + custom-tweaked bijective S-box

Both modules use only Lean 4 core (`Init`); no external math libraries required.
