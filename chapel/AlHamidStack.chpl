module AlHamidStack {
  use CTypes;

  // C-ABI bindings to alhamid_kernel.zig
  extern proc alhamid_encrypt(key: c_ptrConst(uint(8)), pt: c_ptrConst(uint(8)), ct: c_ptr(uint(8))): void;
  extern proc alhamid_decrypt(key: c_ptrConst(uint(8)), ct: c_ptrConst(uint(8)), pt: c_ptr(uint(8))): void;
  extern proc alhamid_mac_tag(key: c_ptrConst(uint(8)), blocks: c_ptrConst(uint(8)), num_blocks: c_size_t, tag_out: c_ptr(uint(8))): void;
  extern proc abjad_tweak_sbox_fwd(x: uint(8), quadrant: uint(8), tweak: uint(8)): uint(8);
  extern proc abjad_tweak_sbox_inv(y: uint(8), quadrant: uint(8), tweak: uint(8)): uint(8);
  extern proc wafq_ec_scalar_mul(scalar: uint(8), px: uint(8), py: uint(8), p_inf: uint(8),
                                 ref rx: uint(8), ref ry: uint(8), ref r_inf: uint(8)): void;
  extern proc wafq_ec_on_curve(x: uint(8), y: uint(8), is_inf: uint(8)): uint(8);

  config const numBlocks: int = 16;
  config const tweakSeed: uint(8) = 36; // POLARITY_DELTA

  const QuadrantDomain = {0..3};
  const ByteDomain     = {0..255};
  const LaneDomain     = {0..15};
  const KeyDomain      = {0..7};

  proc main() {
    var key: [KeyDomain] uint(8) = [53, 93, 110, 146, 36, 49, 33, 7];

    // 1. Parallel S-Box Bijection Verification across all 4 DecoherenceQuadrants x 256 bytes
    var sboxOk: [QuadrantDomain] bool = true;
    forall q in QuadrantDomain {
      var localOk = true;
      for x in ByteDomain {
        const fwd = abjad_tweak_sbox_fwd(x:uint(8), q:uint(8), tweakSeed);
        const inv = abjad_tweak_sbox_inv(fwd, q:uint(8), tweakSeed);
        if inv != x:uint(8) then localOk = false;
      }
      sboxOk[q] = localOk;
    }
    assert(&& reduce sboxOk, "S-Box bijection failed across quadrants");

    // 2. Wafq Elliptic Curve Order-48 Verification on G_wafq = (7, 33) over F_53
    var rx, ry, r_inf: uint(8) = 0;
    assert(wafq_ec_on_curve(7, 33, 0) == 1, "G_wafq not on E(F_53)");
    wafq_ec_scalar_mul(48, 7, 33, 0, rx, ry, r_inf);
    assert(r_inf == 1, "48 * G_wafq != O (infinity)");

    // 3. Data-Parallel Block Encryption / Decryption Roundtrip across numBlocks
    const BlockRange = {0..<numBlocks};
    var plaintexts:  [BlockRange, LaneDomain] uint(8);
    var ciphertexts: [BlockRange, LaneDomain] uint(8);
    var recovered:   [BlockRange, LaneDomain] uint(8);

    forall b in BlockRange {
      for i in LaneDomain {
        plaintexts[b, i] = ((b * 17 + i * 53) % 256):uint(8);
      }
      var ptBuf, ctBuf, recBuf: [LaneDomain] uint(8);
      for i in LaneDomain do ptBuf[i] = plaintexts[b, i];

      alhamid_encrypt(c_ptrTo(key[0]), c_ptrTo(ptBuf[0]), c_ptrTo(ctBuf[0]));
      alhamid_decrypt(c_ptrTo(key[0]), c_ptrTo(ctBuf[0]), c_ptrTo(recBuf[0]));

      for i in LaneDomain {
        ciphertexts[b, i] = ctBuf[i];
        recovered[b, i]   = recBuf[i];
        assert(recovered[b, i] == plaintexts[b, i], "Roundtrip mismatch");
      }
    }
  }
}
