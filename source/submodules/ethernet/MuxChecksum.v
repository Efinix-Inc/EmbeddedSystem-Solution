module MuxChecksum #(
    parameter DATA_WIDTH =8
)(
    //S0: Use original, S1: Use checksum data
    input wire mux_sw,

    // From original Data
    input wire                      og_tvalid,
    input wire                      og_tlast,
    input wire [DATA_WIDTH-1 :0]    og_tdata,

    // Checksum Data
    input wire                      cks_tvalid,
    input wire                      cks_tlast,
    input wire [DATA_WIDTH-1 :0]    cks_tdata,

    // To next stage (selected output)
    output wire                  mux_tvalid,
    output wire                  mux_tlast,
    output wire [DATA_WIDTH-1:0] mux_tdata


);

    // Select between original and checksum output
    assign mux_tvalid = (mux_sw == 1'b0) ? og_tvalid : cks_tvalid;
    assign mux_tlast  = (mux_sw == 1'b0) ? og_tlast  : cks_tlast;
    assign mux_tdata  = (mux_sw == 1'b0) ? og_tdata  : cks_tdata;


endmodule