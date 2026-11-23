import Lake
open Lake DSL

package «alhamid-wafq» where
  moreLeanArgs := #["-DwarningAsError=false"]

@[default_target]
lean_lib «GnosticAbjad» where
  -- Automatically picks up GnosticAbjad.lean and GnosticAbjad/EC_SBox.lean
