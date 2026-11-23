import Lake
open Lake DSL

package «alhamid-wafq» where
  moreLeanArgs := #["-DwarningAsError=false"]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib «GnosticAbjad» where
  -- Core zero-dependency formalization
  -- GnosticAbjad.lean + GnosticAbjad/EC_SBox.lean

lean_lib «EuclideanDivisionLock» where
  roots := #[`EuclideanDivisionLock]

lean_lib «JavaDivisionModulo» where
  -- Formalization of JVM / LiquidJava DivisionModuloLock
  roots := #[`JavaDivisionModulo]
