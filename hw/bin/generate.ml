open Hardcaml

let () = Rtl.print Verilog (Protocol_emulator.Top.circuit ())
