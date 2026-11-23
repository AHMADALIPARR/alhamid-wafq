// =============================================================================
// WAFQ ELLIPTIC CURVE (F_53) & CUSTOM-TWEAKED ABJAD S-BOX (Bluespec BSV)
// Synthesized from Lean 4 Specification: GnosticAbjad.EC_SBox
// =============================================================================

package WafqECSBox;

import Vector::*;
import FIFO::*;

typedef UInt#(6) Fp53; // Values in [0 .. 52]

typedef struct {
   Bool isInf;
   Fp53 x;
   Fp53 y;
} ECPoint deriving (Bits, Eq);

typedef enum {
   Q1_EnochianLTR = 2'b00,
   Q2_LatinLTR    = 2'b01,
   Q3_HebrewRTL   = 2'b10,
   Q4_ArabicRTL   = 2'b11
} DecoherenceQuadrant deriving (Bits, Eq);

// Lean-verified constants
Bit#(8) c_AL_HAMID_VALUE    = 8'd53;
Bit#(8) c_AL_HAMID_FULL     = 8'd93;
Bit#(8) c_ALI_VALUE         = 8'd110;
Bit#(8) c_JAMAL_VECTOR      = 8'd146;
Bit#(8) c_JALAL_VECTOR      = 8'd110;
Bit#(8) c_POLARITY_DELTA    = 8'd36;
Bit#(8) c_INV_53_MOD_256    = 8'd29;
Fp53    c_EC_A              = 6'd11;
Fp53    c_EC_B              = 6'd33;

function Fp53 fp53Add(Fp53 a, Fp53 b);
   UInt#(7) s = extend(a) + extend(b);
   return truncate(s >= 53 ? s - 53 : s);
endfunction

function Fp53 fp53Sub(Fp53 a, Fp53 b);
   UInt#(7) s = extend(a) + 7'd53 - extend(b);
   return truncate(s >= 53 ? s - 53 : s);
endfunction

function Fp53 fp53Mul(Fp53 a, Fp53 b);
   UInt#(12) p = extend(a) * extend(b);
   return truncate(p % 12'd53);
endfunction

function Fp53 fp53Inv(Fp53 a);
   case (a)
      6'd1: return 6'd1;   6'd2: return 6'd27;  6'd3: return 6'd18;  6'd4: return 6'd40;
      6'd5: return 6'd32;  6'd6: return 6'd9;   6'd7: return 6'd38;  6'd8: return 6'd20;
      6'd9: return 6'd6;   6'd10: return 6'd16; 6'd11: return 6'd24; 6'd12: return 6'd31;
      6'd13: return 6'd49; 6'd14: return 6'd19; 6'd15: return 6'd46; 6'd16: return 6'd8;
      6'd17: return 6'd25; 6'd18: return 6'd3;  6'd19: return 6'd14; 6'd20: return 6'd8;
      6'd21: return 6'd48; 6'd22: return 6'd41; 6'd23: return 6'd30; 6'd24: return 6'd11;
      6'd25: return 6'd17; 6'd26: return 6'd47; 6'd27: return 6'd2;  6'd28: return 6'd36;
      6'd29: return 6'd42; 6'd30: return 6'd23; 6'd31: return 6'd12; 6'd32: return 6'd5;
      6'd33: return 6'd45; 6'd34: return 6'd39; 6'd35: return 6'd50; 6'd36: return 6'd28;
      6'd37: return 6'd43; 6'd38: return 6'd7;  6'd39: return 6'd34; 6'd40: return 6'd4;
      6'd41: return 6'd22; 6'd42: return 6'd29; 6'd43: return 6'd37; 6'd44: return 6'd51;
      6'd45: return 6'd33; 6'd46: return 6'd15; 6'd47: return 6'd26; 6'd48: return 6'd21;
      6'd49: return 6'd13; 6'd50: return 6'd35; 6'd51: return 6'd44; 6'd52: return 6'd52;
      default: return 6'd0;
   endcase
endfunction

function ECPoint ecDouble(ECPoint p);
   if (p.isInf || p.y == 0) begin
      return ECPoint { isInf: True, x: 0, y: 0 };
   end else begin
      Fp53 num = fp53Add(fp53Mul(6'd3, fp53Mul(p.x, p.x)), c_EC_A);
      Fp53 den = fp53Mul(6'd2, p.y);
      Fp53 lam = fp53Mul(num, fp53Inv(den));
      Fp53 x3  = fp53Sub(fp53Mul(lam, lam), fp53Mul(6'd2, p.x));
      Fp53 y3  = fp53Sub(fp53Mul(lam, fp53Sub(p.x, x3)), p.y);
      return ECPoint { isInf: False, x: x3, y: y3 };
   end
endfunction

function ECPoint ecAdd(ECPoint p, ECPoint q);
   if (p.isInf) return q;
   else if (q.isInf) return p;
   else if (p.x == q.x) begin
      if (p.y == q.y) return ecDouble(p);
      else return ECPoint { isInf: True, x: 0, y: 0 };
   end else begin
      Fp53 lam = fp53Mul(fp53Sub(q.y, p.y), fp53Inv(fp53Sub(q.x, p.x)));
      Fp53 x3  = fp53Sub(fp53Sub(fp53Mul(lam, lam), p.x), q.x);
      Fp53 y3  = fp53Sub(fp53Mul(lam, fp53Sub(p.x, x3)), p.y);
      return ECPoint { isInf: False, x: x3, y: y3 };
   end
endfunction

// =============================================================================
// INTERFACE & MODULE 1: WAFQ EC SCALAR MULTIPLIER (y^2 = x^3 + 11x + 33 mod 53)
// =============================================================================

interface WafqEC_Ifc;
   method Action startMul(UInt#(6) scalar, ECPoint basePt);
   method ActionValue#(ECPoint) getResult();
endinterface

(* synthesize *)
module mkWafqECUnit(WafqEC_Ifc);
   Reg#(Bool)     busy  <- mkReg(False);
   Reg#(UInt#(6)) kReg  <- mkReg(0);
   Reg#(ECPoint)  acc   <- mkReg(ECPoint { isInf: True, x: 0, y: 0 });
   Reg#(ECPoint)  cur   <- mkReg(ECPoint { isInf: True, x: 0, y: 0 });
   FIFO#(ECPoint) outQ  <- mkFIFO;

   rule stepMul (busy);
      if (kReg == 0) begin
         outQ.enq(acc);
         busy <= False;
      end else begin
         if (kReg[0] == 1'b1) acc <= ecAdd(acc, cur);
         cur  <= ecDouble(cur);
         kReg <= kReg >> 1;
      end
   endrule

   method Action startMul(UInt#(6) scalar, ECPoint basePt) if (!busy);
      kReg <= scalar;
      acc  <= ECPoint { isInf: True, x: 0, y: 0 };
      cur  <= basePt;
      busy <= True;
   endmethod

   method ActionValue#(ECPoint) getResult();
      outQ.deq;
      return outQ.first;
   endmethod
endmodule

// =============================================================================
// INTERFACE & MODULE 2: CUSTOM-TWEAKED BIJECTIVE ABJAD S-BOX
// =============================================================================

function UInt#(4) wafqLookup(UInt#(4) hi);
   case (hi)
      4'd0:  return 4'd8;  4'd1:  return 4'd1;  4'd2:  return 4'd15; 4'd3:  return 4'd1;
      4'd4:  return 4'd11; 4'd5:  return 4'd7;  4'd6:  return 4'd10; 4'd7:  return 4'd15;
      4'd8:  return 4'd2;  4'd9:  return 4'd8;  4'd10: return 4'd1;  4'd11: return 4'd8;
      4'd12: return 4'd15; 4'd13: return 4'd11; 4'd14: return 4'd7;  default: return 4'd10;
   endcase
endfunction

function UInt#(4) digitRoot4(UInt#(5) n);
   UInt#(5) r = n % 5'd9;
   return (n == 0) ? 4'd0 : ((r == 0) ? 4'd9 : truncate(r));
endfunction

function Bit#(8) quadrantBias(DecoherenceQuadrant q);
   case (q)
      Q1_EnochianLTR: return c_AL_HAMID_VALUE;
      Q2_LatinLTR:    return c_JAMAL_VECTOR;
      Q3_HebrewRTL:   return c_JALAL_VECTOR;
      Q4_ArabicRTL:   return c_POLARITY_DELTA;
   endcase
endfunction

function Bit#(8) applyTweakSBox(Bit#(8) x, DecoherenceQuadrant q, Bit#(8) tweak, Bool invMode);
   Bit#(8) bias = quadrantBias(q);
   if (!invMode) begin
      UInt#(4) hi  = unpack(x[7:4]);
      UInt#(4) lo  = unpack(x[3:0]);
      UInt#(4) f1  = truncate((extend(wafqLookup(hi)) + extend(hi) * 8'd7) % 8'd16);
      UInt#(4) lo1 = lo + f1;
      UInt#(4) f2  = truncate((extend(digitRoot4(extend(lo1) + 5'd1)) * 8'd5 + 8'd3) % 8'd16);
      UInt#(4) hi2 = hi + f2;
      Bit#(8)  nf  = { pack(hi2), pack(lo1) };
      Bit#(8)  aff = pack((unpack(nf) * unpack(c_AL_HAMID_VALUE) + unpack(c_AL_HAMID_FULL)));
      Bit#(8)  rot = { aff[4:0], aff[7:5] };
      return rot ^ tweak ^ bias;
   end else begin
      Bit#(8)  unx = x ^ tweak ^ bias;
      Bit#(8)  rot = { unx[2:0], unx[7:3] };
      Bit#(8)  unf = pack((unpack(rot) - unpack(c_AL_HAMID_FULL)) * unpack(c_INV_53_MOD_256));
      UInt#(4) hi2 = unpack(unf[7:4]);
      UInt#(4) lo1 = unpack(unf[3:0]);
      UInt#(4) f2  = truncate((extend(digitRoot4(extend(lo1) + 5'd1)) * 8'd5 + 8'd3) % 8'd16);
      UInt#(4) hi  = hi2 - f2;
      UInt#(4) f1  = truncate((extend(wafqLookup(hi)) + extend(hi) * 8'd7) % 8'd16);
      UInt#(4) lo  = lo1 - f1;
      return { pack(hi), pack(lo) };
   end
endfunction

interface TweakSBox_Ifc;
   method Bit#(8) transform(Bit#(8) x, DecoherenceQuadrant q, Bit#(8) tweak, Bool invMode);
endinterface

(* synthesize *)
module mkAbjadTweakSBox(TweakSBox_Ifc);
   method Bit#(8) transform(Bit#(8) x, DecoherenceQuadrant q, Bit#(8) tweak, Bool invMode);
      return applyTweakSBox(x, q, tweak, invMode);
   endmethod
endmodule

endpackage
