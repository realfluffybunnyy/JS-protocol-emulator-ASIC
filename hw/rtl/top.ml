open Hardcaml
open Signal

module I = struct
  type 'a t =
    { clk : 'a
    ; rst_n : 'a
    ; ena : 'a
    ; ui_in : 'a [@bits 8]
    ; uio_in : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

module O = struct
  type 'a t =
    { uo_out : 'a [@bits 8]
    ; uio_out : 'a [@bits 8]
    ; uio_oe : 'a [@bits 8]
    }
  [@@deriving hardcaml]
end

let name = "tt_um_protocol_emulator"

let create (i : _ I.t) : _ O.t =
  { uo_out = i.ui_in +: i.uio_in; uio_out = zero 8; uio_oe = zero 8 }
;;

let circuit () =
  let module C = Circuit.With_interface (I) (O) in
  C.create_exn ~name create
;;
