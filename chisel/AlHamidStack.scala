// =============================================================================
// AL-HAMID / WAFQ CHISEL HARDWARE BINDINGS & TOP-LEVEL STACK (Chisel 3 / 6)
// Binds VHDL (`wafq_ec_alu`, `abjad_tweak_sbox`) & BSV (`mkWafqECUnit`,
// `mkAbjadTweakSBox`) RTL into a unified Chisel DecoupledIO Stack.
// =============================================================================

package gnostic.abjad

import chisel3._
import chisel3.util._

// -----------------------------------------------------------------------------
// 1. AXIOM CONSTANTS
// -----------------------------------------------------------------------------
object AlHamidConstants {
  val AL_HAMID_VALUE        = 53.U(8.W)
  val AL_HAMID_FULL_VALUE   = 93.U(8.W)
  val ALI_VALUE             = 110.U(8.W)
  val JAMAL_VECTOR          = 146.U(8.W)
  val JALAL_VECTOR          = 110.U(8.W)
  val POLARITY_DELTA        = 36.U(8.W)
  val BIFURCATION_THRESHOLD = 49
}

// -----------------------------------------------------------------------------
// 2. CHISEL BLACKBOX BINDING -> VHDL `wafq_ec_alu`
// -----------------------------------------------------------------------------
class WafqECAluBlackBox extends BlackBox with HasBlackBoxResource {
  override def desiredName = "wafq_ec_alu"

  val io = IO(new Bundle {
    val clk    = Input(Clock())
    val rst_n  = Input(Bool())
    val start  = Input(Bool())
    val op_dbl = Input(Bool())
    val p_inf  = Input(Bool())
    val px     = Input(UInt(6.W))
    val py     = Input(UInt(6.W))
    val q_inf  = Input(Bool())
    val qx     = Input(UInt(6.W))
    val qy     = Input(UInt(6.W))
    val r_inf  = Output(Bool())
    val rx     = Output(UInt(6.W))
    val ry     = Output(UInt(6.W))
    val done   = Output(Bool())
  })
}

// -----------------------------------------------------------------------------
// 3. CHISEL BLACKBOX BINDING -> BSV `mkWafqECUnit` (Scalar Multiplier)
// -----------------------------------------------------------------------------
class BsvWafqECUnitBlackBox extends BlackBox {
  override def desiredName = "mkWafqECUnit"

  val io = IO(new Bundle {
    val CLK               = Input(Clock())
    val RST_N             = Input(Bool())
    val startMul_scalar   = Input(UInt(6.W))
    val startMul_basePt   = Input(UInt(13.W)) // {isInf(1), x(6), y(6)}
    val EN_startMul       = Input(Bool())
    val RDY_startMul      = Output(Bool())
    val EN_getResult      = Input(Bool())
    val getResult         = Output(UInt(13.W))
    val RDY_getResult     = Output(Bool())
  })
}

// -----------------------------------------------------------------------------
// 4. CHISEL BLACKBOX BINDING -> VHDL `abjad_tweak_sbox`
// -----------------------------------------------------------------------------
class AbjadTweakSBoxBlackBox extends BlackBox {
  override def desiredName = "abjad_tweak_sbox"

  val io = IO(new Bundle {
    val x_in     = Input(UInt(8.W))
    val quadrant = Input(UInt(2.W))
    val tweak    = Input(UInt(8.W))
    val inv_mode = Input(Bool())
    val y_out    = Output(UInt(8.W))
  })
}

// -----------------------------------------------------------------------------
// 5. NATIVE CHISEL 49-ROUND AL-HAMID-256 + WAFQ EC + TWEAK S-BOX STACK TOP
// -----------------------------------------------------------------------------
class StackReq extends Bundle {
  val key      = Vec(8, UInt(8.W))
  val block    = Vec(16, UInt(8.W))
  val tweak    = UInt(8.W)
  val invMode  = Bool()
  val ecScalar = UInt(6.W)
}

class StackResp extends Bundle {
  val outBlock = Vec(16, UInt(8.W))
  val ecPointX = UInt(6.W)
  val ecPointY = UInt(6.W)
  val ecIsInf  = Bool()
}

class AlHamidStackTop extends Module {
  val io = IO(new Bundle {
    val req  = Flipped(Decoupled(new StackReq))
    val resp = Decoupled(new StackResp)
  })

  val sbox   = Module(new AbjadTweakSBoxBlackBox)
  val ecUnit = Module(new BsvWafqECUnitBlackBox)

  // Connect BSV EC Unit clock/reset (active-low RST_N)
  ecUnit.io.CLK   := clock
  ecUnit.io.RST_N := !reset.asBool

  val sIdle :: sEncrypt :: sWaitEC :: sDone :: Nil = Enum(4)
  val stateReg  = RegInit(sIdle)
  val roundReg  = RegInit(0.U(6.W))
  val lanesReg  = Reg(Vec(16, UInt(8.W)))
  val keyReg    = Reg(Vec(8, UInt(8.W)))
  val tweakReg  = RegInit(0.U(8.W))
  val invReg    = RegInit(false.B)
  val ecResReg  = RegInit(0.U(13.W))

  // Quadrant selection from roundReg: (t / 12) % 4
  val quadrant = (roundReg / 12.U)(1, 0)

  // S-Box lane 0 pre/post whitening datapath
  sbox.io.x_in     := lanesReg(0)
  sbox.io.quadrant := quadrant
  sbox.io.tweak    := tweakReg
  sbox.io.inv_mode := invReg

  // Default BSV EC Unit handshake
  ecUnit.io.startMul_scalar := 0.U
  ecUnit.io.startMul_basePt := Cat(0.U(1.W), 7.U(6.W), 33.U(6.W)) // G_wafq = (7, 33)
  ecUnit.io.EN_startMul     := false.B
  ecUnit.io.EN_getResult    := false.B

  io.req.ready  := (stateReg === sIdle) && ecUnit.io.RDY_startMul
  io.resp.valid := (stateReg === sDone)
  io.resp.bits.outBlock := lanesReg
  io.resp.bits.ecIsInf  := ecResReg(12)
  io.resp.bits.ecPointX := ecResReg(11, 6)
  io.resp.bits.ecPointY := ecResReg(5, 0)

  switch(stateReg) {
    is(sIdle) {
      when(io.req.fire) {
        lanesReg := io.req.bits.block
        keyReg   := io.req.bits.key
        tweakReg := io.req.bits.tweak
        invReg   := io.req.bits.invMode
        roundReg := 0.U
        ecUnit.io.startMul_scalar := io.req.bits.ecScalar
        ecUnit.io.EN_startMul     := true.B
        stateReg := sEncrypt
      }
    }
    is(sEncrypt) {
      // 8-pair Feistel + affine lane permutation (i*5 + 3) mod 16
      val nextFeistel = Wire(Vec(16, UInt(8.W)))
      nextFeistel := lanesReg
      for (k <- 0 until 8) {
        val even = 2 * k
        val odd  = even + 1
        val mix  = (lanesReg(odd) * AlHamidConstants.AL_HAMID_VALUE + tweakReg)(7, 0) ^
                   ((quadrant * AlHamidConstants.POLARITY_DELTA)(7, 0))
        nextFeistel(even) := lanesReg(even) + mix + keyReg(k)
      }
      val permuted = Wire(Vec(16, UInt(8.W)))
      for (i <- 0 until 16) {
        permuted((i * 5 + 3) % 16) := nextFeistel(i)
      }
      lanesReg := permuted

      when(roundReg === (AlHamidConstants.BIFURCATION_THRESHOLD - 1).U) {
        stateReg := sWaitEC
      }.otherwise {
        roundReg := roundReg + 1.U
      }
    }
    is(sWaitEC) {
      when(ecUnit.io.RDY_getResult) {
        ecUnit.io.EN_getResult := true.B
        ecResReg := ecUnit.io.getResult
        lanesReg(0) := sbox.io.y_out // Apply final custom-tweaked S-box whitening
        stateReg := sDone
      }
    }
    is(sDone) {
      when(io.resp.fire) 

stateReg := sIdle
      }
    }
  }
}
