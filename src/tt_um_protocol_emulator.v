module tt_um_protocol_emulator (
    uio_in,
    ui_in,
    clk,
    ena,
    rst_n,
    uo_out,
    uio_out,
    uio_oe
);

    input [7:0] uio_in;
    input [7:0] ui_in;
    input clk;
    input ena;
    input rst_n;
    output [7:0] uo_out;
    output [7:0] uio_out;
    output [7:0] uio_oe;

    wire [7:0] _8;
    wire [7:0] _4;
    wire [7:0] _6;
    wire [7:0] _10;
    assign _8 = 8'b00000000;
    assign _4 = uio_in;
    assign _6 = ui_in;
    assign _10 = _6 + _4;
    assign uo_out = _10;
    assign uio_out = _8;
    assign uio_oe = _8;

endmodule
