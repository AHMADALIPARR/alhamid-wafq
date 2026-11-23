//! AL-HAMID / WAFQ FREESTANDING ZIG KERNEL (C-ABI Exported)
//! Source of Truth: Gnostic/Arabic Esoteric Arithmetic Rust + Lean 4 Specs

pub const AL_HAMID_VALUE: u32 = 53;
pub const AL_HAMID_FULL_VALUE: u32 = 93;
pub const ALI_VALUE: u32 = 110;
pub const MASTER_AGGREGATE: u32 = 256;
pub const MATRIX_DIMENSION: usize = 16;
pub const JAMAL_VECTOR: u32 = 146;
pub const JALAL_VECTOR: u32 = 110;
pub const POLARITY_DELTA: u32 = 36;
pub const BIFURCATION_ORDER: u32 = 7;
pub const BIFURCATION_THRESHOLD: usize = 49;
pub const INV_53_MOD_256: u32 = 29;
pub const EC_A: u32 = 11;
pub const EC_B: u32 = 33;

pub const WAFQ_ALLAH_3X3: [3][3]u8 = .{
    .{ 8, 1, 24 },
    .{ 15, 11, 7 },
    .{ 10, 21, 2 },
};

pub const INV53_LUT: [53]u8 = .{
    0,  1,  27, 18, 40, 32, 9,  38, 20, 6,
    16, 29, 31, 49, 19, 46, 10, 25, 3,  14,
    8,  48, 41, 30, 42, 17, 51, 2,  36, 11,
    23, 12, 5,  45, 39, 50, 28, 43, 7,  34,
    4,  22, 24, 37, 47, 33, 15, 44, 21, 13,
    35, 26, 52,
};

pub const DecoherenceQuadrant = enum(u2) {
    Q1_EnochianLTR = 0,
    Q2_LatinLTR = 1,
    Q3_HebrewRTL = 2,
    Q4_ArabicRTL = 3,

    pub inline fn fromStep(step: usize) DecoherenceQuadrant {
        return @enumFromInt((step / 12) % 4);
    }

    pub inline fn bias(self: DecoherenceQuadrant) u8 {
        return switch (self) {
            .Q1_EnochianLTR => 53,
            .Q2_LatinLTR => 146,
            .Q3_HebrewRTL => 110,
            .Q4_ArabicRTL => 36,
        };
    }
};

pub inline fn digitRoot(n: u32) u8 {
    if (n == 0) return 0;
    const r = n % 9;
    return if (r == 0) 9 else @intCast(r);
}

inline fn rotl8(x: u8, r: u3) u8 {
    return (x << r) | (x >> @intCast(8 - @as(u4, r)));
}

inline fn rotr8(x: u8, r: u3) u8 {
    return (x >> r) | (x << @intCast(8 - @as(u4, r)));
}

// =============================================================================
// 1. CUSTOM-TWEAKED BIJECTIVE ABJAD S-BOX
// =============================================================================

inline fn nibbleF1(hi: u4) u4 {
    const h: u32 = hi;
    const w: u32 = WAFQ_ALLAH_3X3[h % 3][(h / 3) % 3];
    return @intCast((w + h * BIFURCATION_ORDER) % 16);
}

inline fn nibbleF2(lo: u4) u4 {
    const dr: u32 = digitRoot(@as(u32, lo) + 1);
    return @intCast((dr * 5 + 3) % 16);
}

pub export fn abjad_tweak_sbox_fwd(x: u8, quadrant: u8, tweak: u8) callconv(.c) u8 {
    const q: DecoherenceQuadrant = @enumFromInt(quadrant & 3);
    const hi: u4 = @intCast(x >> 4);
    const lo: u4 = @intCast(x & 0x0F);
    const lo1: u4 = lo +% nibbleF1(hi);
    const hi2: u4 = hi +% nibbleF2(lo1);
    const nf: u32 = (@as(u32, hi2) << 4) | @as(u32, lo1);
    const aff: u8 = @intCast((nf * AL_HAMID_VALUE + AL_HAMID_FULL_VALUE) % MASTER_AGGREGATE);
    return rotl8(aff, 3) ^ tweak ^ q.bias();
}

pub export fn abjad_tweak_sbox_inv(y: u8, quadrant: u8, tweak: u8) callconv(.c) u8 {
    const q: DecoherenceQuadrant = @enumFromInt(quadrant & 3);
    const unxor: u8 = y ^ tweak ^ q.bias();
    const unrot: u32 = rotr8(unxor, 3);
    const unaff: u8 = @intCast(((unrot + MASTER_AGGREGATE - AL_HAMID_FULL_VALUE) * INV_53_MOD_256) % MASTER_AGGREGATE);
    const hi2: u4 = @intCast(unaff >> 4);
    const lo1: u4 = @intCast(unaff & 0x0F);
    const hi: u4 = hi2 -% nibbleF2(lo1);
    const lo: u4 = lo1 -% nibbleF1(hi);
    return (@as(u8, hi) << 4) | @as(u8, lo);
}

// =============================================================================
// 2. AL-HAMID-256 49-ROUND FEISTEL-WAFQ CIPHER & SPONGE MAC
// =============================================================================

inline fn roundConst(t: usize, k: usize) u8 {
    const q = DecoherenceQuadrant.fromStep(t);
    const pillar_val: u32 = q.bias();
    const wafq_val: u32 = WAFQ_ALLAH_3X3[t % 3][k % 3];
    return @intCast((pillar_val + wafq_val * POLARITY_DELTA + @as(u32, @intCast(t)) * AL_HAMID_VALUE + @as(u32, @intCast(k)) * ALI_VALUE) % MASTER_AGGREGATE);
}

inline fn feistelF(t: usize, x: u8, k: usize) u8 {
    const rc: u32 = roundConst(t, k);
    const dr: u32 = digitRoot(@as(u32, x) + 1);
    const mixed: u32 = (@as(u32, x) * AL_HAMID_VALUE + rc) ^ (dr * POLARITY_DELTA);
    return @intCast(mixed % MASTER_AGGREGATE);
}

pub export fn alhamid_encrypt(key: [*]const u8, pt: [*]const u8, ct: [*]u8) callconv(.c) void {
    var state: [16]u8 = undefined;
    for (0..16) |i| state[i] = pt[i];

    for (0..BIFURCATION_THRESHOLD) |t| {
        var next_feistel: [16]u8 = state;
        for (0..8) |k| {
            const even = 2 * k;
            const odd = even + 1;
            next_feistel[even] = state[even] +% feistelF(t, state[odd], k) +% key[k];
        }
        var permuted: [16]u8 = undefined;
        for (0..16) |i| {
            const dst = (i * 5 + 3) % 16;
            permuted[dst] = next_feistel[i];
        }
        state = permuted;
    }

    for (0..16) |i| ct[i] = state[i];
}

pub export fn alhamid_decrypt(key: [*]const u8, ct: [*]const u8, pt: [*]u8) callconv(.c) void {
    var state: [16]u8 = undefined;
    for (0..16) |i| state[i] = ct[i];

    var t_rev: usize = BIFURCATION_THRESHOLD;
    while (t_rev > 0) {
        t_rev -= 1;
        var unpermuted: [16]u8 = undefined;
        for (0..16) |i| {
            const src = (i * 5 + 3) % 16;
            unpermuted[i] = state[src];
        }
        for (0..8) |k| {
            const even = 2 * k;
            const odd = even + 1;
            unpermuted[even] = unpermuted[even] -% (feistelF(t_rev, unpermuted[odd], k) +% key[k]);
        }
        state = unpermuted;
    }

    for (0..16) |i| pt[i] = state[i];
}

pub export fn alhamid_mac_tag(key: [*]const u8, blocks: [*]const u8, num_blocks: usize, tag_out: [*]u8) callconv(.c) void {
    var state: [16]u8 = .{0} ** 16;
    var tmp: [16]u8 = undefined;
    for (0..num_blocks) |b| {
        const offset = b * 16;
        for (0..16) |i| tmp[i] = state[i] ^ blocks[offset + i];
        alhamid_encrypt(key, &tmp, &state);
    }
    for (0..4) |j| tag_out[j] = state[j];
}

// =============================================================================
// 3. WAFQ ELLIPTIC CURVE ARITHMETIC OVER F_53: y^2 = x^3 + 11x + 33 (mod 53)
// =============================================================================

pub const ECPoint = struct {
    is_inf: bool,
    x: u8,
    y: u8,
};

inline fn fp53Add(a: u8, b: u8) u8 {
    return @intCast((@as(u32, a) + @as(u32, b)) % AL_HAMID_VALUE);
}

inline fn fp53Sub(a: u8, b: u8) u8 {
    return @intCast((@as(u32, a) + AL_HAMID_VALUE - (@as(u32, b) % AL_HAMID_VALUE)) % AL_HAMID_VALUE);
}

inline fn fp53Mul(a: u8, b: u8) u8 {
    return @intCast((@as(u32, a) * @as(u32, b)) % AL_HAMID_VALUE);
}

pub fn ecDouble(p: ECPoint) ECPoint {
    if (p.is_inf or p.y == 0) return .{ .is_inf = true, .x = 0, .y = 0 };
    const num = fp53Add(fp53Mul(3, fp53Mul(p.x, p.x)), EC_A);
    const den = fp53Mul(2, p.y);
    const lam = fp53Mul(num, INV53_LUT[den]);
    const x3 = fp53Sub(fp53Mul(lam, lam), fp53Mul(2, p.x));
    const y3 = fp53Sub(fp53Mul(lam, fp53Sub(p.x, x3)), p.y);
    return .{ .is_inf = false, .x = x3, .y = y3 };
}

pub fn ecAdd(p: ECPoint, q: ECPoint) ECPoint {
    if (p.is_inf) return q;
    if (q.is_inf) return p;
    if (p.x == q.x) {
        return if (p.y == q.y) ecDouble(p) else .{ .is_inf = true, .x = 0, .y = 0 };
    }
    const lam = fp53Mul(fp53Sub(q.y, p.y), INV53_LUT[fp53Sub(q.x, p.x)]);
    const x3 = fp53Sub(fp53Sub(fp53Mul(lam, lam), p.x), q.x);
    const y3 = fp53Sub(fp53Mul(lam, fp53Sub(p.x, x3)), p.y);
    return .{ .is_inf = false, .x = x3, .y = y3 };
}

pub export fn wafq_ec_scalar_mul(scalar: u8, px: u8, py: u8, p_inf: u8, rx: *u8, ry: *u8, r_inf: *u8) callconv(.c) void {
    var acc: ECPoint = .{ .is_inf = true, .x = 0, .y = 0 };
    var cur: ECPoint = .{ .is_inf = (p_inf != 0), .x = px % 53, .y = py % 53 };
    var k: u8 = scalar;
    while (k > 0) : (k >>= 1) {
        if ((k & 1) != 0) acc = ecAdd(acc, cur);
        cur = ecDouble(cur);
    }
    rx.* = acc.x;
    ry.* = acc.y;
    r_inf.* = if (acc.is_inf) 1 else 0;
}

pub export fn wafq_ec_on_curve(x: u8, y: u8, is_inf: u8) callconv(.c) u8 {
    if (is_inf != 0) return 1;
    const xm = x % 53;
    const ym = y % 53;
    const lhs = fp53Mul(ym, ym);
    const rhs = fp53Add(fp53Add(fp53Mul(fp53Mul(xm, xm), xm), fp53Mul(EC_A, xm)), EC_B);
    return if (lhs == rhs) 1 else 0;
}

// Compile-time axiom verification
comptime {
    if ((AL_HAMID_VALUE * INV_53_MOD_256) % MASTER_AGGREGATE != 1) @compileError("53 inverse invariant failed");
    if (wafq_ec_on_curve(7, 33, 0) != 1) @compileError("G_wafq (7, 33) not on curve");
    var x: usize = 0;
    while (x < 256) : (x += 1) {
        const xb: u8 = @intCast(x);
        if (abjad_tweak_sbox_inv(abjad_tweak_sbox_fwd(xb, 0, 36), 0, 36) != xb) {
            @compileError("TweakSBox bijection failed");
        }
    }
}
