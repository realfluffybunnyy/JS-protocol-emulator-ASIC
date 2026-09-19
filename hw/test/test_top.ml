open Hardcaml
open Protocol_emulator
module Sim = Cyclesim.With_interface (Top.I) (Top.O)

let%expect_test "uo_out is ui_in + uio_in" =
  let sim = Sim.create Top.create in
  let i = Cyclesim.inputs sim in
  let o = Cyclesim.outputs sim in
  List.iter
    (fun (a, b) ->
       i.ui_in := Bits.of_int ~width:8 a;
       i.uio_in := Bits.of_int ~width:8 b;
       Cyclesim.cycle sim;
       Stdio.printf "%d + %d = %d\n" a b (Bits.to_int !(o.uo_out)))
    [ 20, 30; 200, 100 ];
  [%expect
    {|
    20 + 30 = 50
    200 + 100 = 44
    |}]
;;
