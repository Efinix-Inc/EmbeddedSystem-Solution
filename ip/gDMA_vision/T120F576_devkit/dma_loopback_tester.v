`timescale 1ns/1ps

module dma_loopback_tester #(
	parameter ID = 4'h0,
	parameter DW = 32,
	parameter FD = 2048,
	parameter FB = 4

) (
	tester_clk,
	tester_resetn,
 	tester_i_tvalid,	
 	tester_i_tready,	
 	tester_i_tdata,	
 	tester_i_tkeep,	
 	tester_i_tdest,	
 	tester_i_tlast,	
 	tester_o_tvalid,	
 	tester_o_tready,
 	tester_o_tdata,	
 	tester_o_tkeep,	
 	tester_o_tdest,	
 	tester_o_tlast	
);

/////////////////////////////////////////////////////////////////////////////

	input 			tester_clk;
	input 			tester_resetn;
 	input 			tester_i_tvalid;	
 	output reg		tester_i_tready;	
 	input [DW-1:0]		tester_i_tdata;	
 	input [(DW/8)-1:0]	tester_i_tkeep;	
 	input [3:0]		tester_i_tdest;	
 	input			tester_i_tlast;	
 	output			tester_o_tvalid;	
 	input			tester_o_tready;
 	output [DW-1:0]		tester_o_tdata;	
 	output [(DW/8)-1:0]	tester_o_tkeep;	
 	output reg [3:0]	tester_o_tdest;	
 	output			tester_o_tlast;

/////////////////////////////////////////////////////////////////////////////
localparam WRCNT = 10;//$clog2(FD/FB);

wire 			f_almfull [0:FB-1];
wire			Orf_almfull;
wire			f_valid[0:FB-1];
wire [(DW/FB)+1:0] 	f_data [0:FB-1];
wire [(DW/FB)+1:0]      fo_data [0:FB-1];
wire [WRCNT-1:0]	wrcnt [0:FB-1];
wire			f_empty[0:FB-1];
wire			Andf_empty;
wire			rd_en;
reg			rd_triggerred;

always@(posedge tester_clk)
begin
	 tester_o_tdest <= ID;
end

always@(posedge tester_clk or negedge tester_resetn)
begin
	if(!tester_resetn)
		tester_i_tready <= 1'b0;
	else begin
		if(Orf_almfull)
			tester_i_tready <= 1'b0;
		else
			tester_i_tready <= 1'b1;
	end
end

always@(posedge tester_clk or negedge tester_resetn)
begin
	if(!tester_resetn)
		rd_triggerred <= 1'b0;
	else
	begin
		if(wrcnt[0] > 'd16)
			rd_triggerred <= 1'b1;
		else if (tester_o_tlast && tester_o_tready)
			rd_triggerred <= 1'b0;
		else
			rd_triggerred <= rd_triggerred;
	end
end

assign rd_en = (rd_triggerred & tester_o_tready );

assign tester_o_tlast 	= fo_data[0][9] ;
assign Orf_almfull	= f_almfull[0];
assign Andf_empty	= f_empty[0];
assign tester_o_tvalid 	= rd_triggerred;
/////////////////////////////////////////////////////////////////////////////
genvar i;
generate
for(i = 0 ; i < FB ; i = i + 1) begin

assign f_data[i] = {tester_i_tlast, tester_i_tkeep[i], tester_i_tdata[(i*8+7) -: 8]};

assign tester_o_tdata[(i*8+7) -: 8] 	= fo_data[i][7:0]; 
assign tester_o_tkeep[i] 		= fo_data[i][8];

efx_fifo_wrapper fifo_u1
(
//Output
    .almost_full_o              (f_almfull[i]               ),
    .prog_full_o                (                           ),
    .full_o                     (                           ),
    .overflow_o                 (                           ),
    .wr_ack_o                   (                           ),
    .datacount_o                (wrcnt[i]                   ),
    .empty_o                    (f_empty[i]                 ),
    .almost_empty_o             (                           ),
    .prog_empty_o               (                           ),
    .underflow_o                (                           ),
    .rd_valid_o                 (f_valid[i]                 ),
    .rdata                      (fo_data[i]                 ),
    .rst_busy                   (                           ),
//Input
    .clk_i                      (tester_clk                 ),
    .wr_en_i                    (tester_i_tvalid && tester_i_tready),
    .rd_en_i                    (rd_en                 	    ),
    .a_rst_i                    (!tester_resetn             ),
    .wdata                      (f_data[i]                  )
);
end
endgenerate

endmodule
