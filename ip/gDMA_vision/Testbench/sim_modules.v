////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2023 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   sim_modules.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Modules for SapphireSoC simulation
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// 1.0 Initial rev
//
// ***********************************************************************
`timescale 10ps/1ps

module clock_gen
#(
parameter FREQ_CLK_MHZ = 166
)
(
input    rst            ,
output reg clk_out0     ,
output reg clk_out45    ,
output reg clk_out90    ,
output reg clk_out135   ,
output reg locked
);

localparam CYCLE    = 100000/FREQ_CLK_MHZ;
localparam PHASE45  = CYCLE/8;
localparam PHASE90  = CYCLE/4;
localparam PHASE135 = (CYCLE/8)*3;


always @ ( * ) begin
      if (rst)
      locked <= 1'b0;
      else
      #(10*CYCLE)
      locked <= 1'b1;
end

// clock 0
initial begin
   clk_out0 = 1'b0;
   wait(locked)
    #(100*CYCLE)
   forever #(CYCLE/2) clk_out0 = ~clk_out0;
end

initial begin
   clk_out45 = 1'b0;
   wait(locked)
   #(100*CYCLE)
   #PHASE45
   forever #(CYCLE/2) clk_out45 = ~clk_out45;
end

initial begin
   clk_out90 = 1'b0;
   wait(locked)
   #(100*CYCLE)
   #PHASE90
   forever #(CYCLE/2) clk_out90 = ~clk_out90;
end

initial begin
   clk_out135 = 1'b0;
   wait(locked)
   #(100*CYCLE)
   #PHASE135
   forever #(CYCLE/2) clk_out135 = ~clk_out135;
end

endmodule

// ***********************************************************************

module io_sim #(
    parameter   WIDTH   = 8,
    parameter   REG     = 0
) (
    input               clk,
    input  [WIDTH-1:0]  out_pad,
    input  [WIDTH-1:0]  out_oe,
    output [WIDTH-1:0]  in_pad,
    inout  [WIDTH-1:0]  io
);

reg [WIDTH-1:0] out_oe_reg;
reg [WIDTH-1:0] out_pad_reg;
reg [WIDTH-1:0] in_pad_reg;

genvar i;
generate
if(REG == 1)
begin

    for(i=0; i < WIDTH; i=i+1)
    begin
        always@(posedge clk)
        begin
            out_pad_reg[i] <= out_pad[i];
            out_oe_reg[i] <= out_oe[i];
            in_pad_reg[i] <= io[i];
        end

        assign io[i]= out_oe_reg[i] ? out_pad_reg[i] : 'bZ;
        assign in_pad[i] = in_pad_reg[i];
    end
end
else
begin
    for(i=0; i < WIDTH; i=i+1)
    begin
        assign io[i]=out_oe[i] ? out_pad[i] : 'bZ;
        assign in_pad[i] = io[i];
    end
end
endgenerate

endmodule

// ***********************************************************************
module ext_mem_controller #(
    parameter WIDTH = 128,
    parameter DEPTH = 19
) (
	input		        io_memoryClk,
	input		        resetn,
	input [7:0]         aid_0,
	input [31:0] 	    aaddr_0,
	input [7:0] 	    alen_0,
	input [2:0] 	    asize_0,
	input [1:0] 	    aburst_0,
	input [1:0] 	    alock_0,
	input 		        avalid_0,
	output reg	        aready_0,
	input		        atype_0,
	input [7:0] 	    wid_0,
	input [WIDTH-1:0] 	wdata_0,
	input [WIDTH/8-1:0] wstrb_0,
	input 		        wlast_0,
	input 		        wvalid_0,
	output reg 	        wready_0,
	output [7:0] 	    rid_0,
	output [WIDTH-1:0] 	rdata_0,
	output reg 	        rlast_0,
	output reg 	        rvalid_0,
	input 		        rready_0,
	output reg [1:0]    rresp_0,
	output reg [7:0]    bid_0,
	output reg 	        bvalid_0,
	input 		        bready_0

);
/////////////////////////////////////////////////////////////////////////////
localparam	s_idle	 = 2'b00;
localparam	s_write	 = 2'b01;
localparam	s_resp	 = 2'b10;
localparam	s_read	 = 2'b11;
localparam  ADDR_LSB = (WIDTH == 1024)? 7 :
                       (WIDTH == 512)?  6 :
                       (WIDTH == 256)?  5 :
                       (WIDTH == 128)?  4 :
                       (WIDTH == 64 )?  3 : 2; 

reg   [1:0]  	    r_ram0_state_1P;
reg   [7:0]  	    r_aid_0_1P;
reg   [DEPTH-1:0]	r_aaddr_0_1P;
reg   [7:0]  	    r_alen_0_1P;
wire  [WIDTH-1:0]	wdata;
reg   [WIDTH-1:0]	wdata_r = 'd0;
wire                wenable;
/////////////////////////////////////////////////////////////////////////////

always@(negedge resetn or posedge io_memoryClk)
begin
	if (~resetn)
	begin
		r_ram0_state_1P	<= s_idle;
		r_aid_0_1P	    <= {8{1'b0}};
		r_aaddr_0_1P	<= {DEPTH{1'b0}};
		r_alen_0_1P	    <= {8{1'b0}};
		rlast_0		    <= 1'b0;
		rvalid_0	    <= 1'b0;
		aready_0	    <= 1'b0;
		wready_0	    <= 1'b0;
		bid_0		    <= {8{1'b0}};
		bvalid_0	    <= 1'b0;
		rresp_0		    <= 2'b00;
	end else
	begin
		aready_0	<= 1'b0;
		rresp_0		<= 2'b00;
		
		case (r_ram0_state_1P)
			s_idle:
			begin
				if (avalid_0)
				begin
					if (atype_0)
					begin
						r_ram0_state_1P	<= s_write;
						wready_0	    <= 1'b1;
					end
					else
					begin
						r_ram0_state_1P	<= s_read;
					end
					
					r_aid_0_1P		<= aid_0;
					r_aaddr_0_1P	<= aaddr_0[DEPTH+ADDR_LSB:ADDR_LSB];
					r_alen_0_1P		<= alen_0;
					aready_0		<= 1'b1;
				end
			end
			
			s_write:
			begin
				if (wvalid_0)
				begin
					r_aaddr_0_1P	<= r_aaddr_0_1P+1'b1;
					r_alen_0_1P		<= r_alen_0_1P-1'b1;
					
					if (r_alen_0_1P == {8{1'b0}})
					begin
						r_ram0_state_1P	<= s_resp;
						wready_0	    <= 1'b0;
						bid_0		    <= r_aid_0_1P;
						bvalid_0	    <= 1'b1;
					end
				end
			end

			s_resp:
			begin
				if (bready_0)
				begin
					r_ram0_state_1P	<= s_idle;
					bvalid_0		<= 1'b0;
				end
			end
			
			s_read:
			begin
				rvalid_0			<= 1'b1;
				
				if (r_alen_0_1P == 8'b0)
					rlast_0			<= 1'b1;
				
				if (rvalid_0 && rready_0)
				begin
					r_aaddr_0_1P	<= r_aaddr_0_1P+1'b1;
					r_alen_0_1P		<= r_alen_0_1P-1'b1;
					
					if (r_alen_0_1P == 8'b1)
						rlast_0		<= 1'b1;
					
					if (r_alen_0_1P == {8{1'b0}})
					begin
						rvalid_0	    <= 1'b0;
						rlast_0		    <= 1'b0;
						r_ram0_state_1P	<= s_idle;
					end
				end
			end
			
			default:
			begin
				r_ram0_state_1P	<= s_idle;
				r_aid_0_1P		<= {8{1'b0}};
				r_aaddr_0_1P	<= {DEPTH{1'b0}};
				r_alen_0_1P		<= {8{1'b0}};
				rlast_0			<= 1'b0;
				rvalid_0		<= 1'b0;
				wready_0		<= 1'b0;
				bid_0			<= {8{1'b0}};
				bvalid_0		<= 1'b0;
			end
		endcase
	end
end

assign	rid_0	= r_aid_0_1P;
assign  wenable = (wvalid_0 && r_ram0_state_1P == s_write);

genvar i;
generate
for(i=0; i < WIDTH/8; i = i + 1) 
begin
	assign wdata[(i*8+7) -: 8] =  (wdata_0[(i*8+7) -: 8] & {8{wstrb_0[i]}});
	always@(*)
    begin
		wdata_r[(i*8+7) -: 8] <= {8{wstrb_0[i]}} ? wdata[(i*8+7) -: 8] : 
                                    rdata_0[(i*8+7) -: 8];
    end
end
endgenerate

ext_mem_sim #(
	.DATA_WIDTH (WIDTH),
	.ADDR_WIDTH (DEPTH),
	.RAM_INIT_FILE("MEM.TXT"),
	.OUTPUT_REG ("FALSE")
				 
) ext_mem_sim_inst (
	.wdata 	(wdata_r),
	.waddr	(r_aaddr_0_1P), 
	.raddr	(r_aaddr_0_1P),
	.we	    (wenable), 
	.wclk	(io_memoryClk), 
	.re	    (rvalid_0|wready_0), 
	.rclk	(io_memoryClk),
	.rdata	(rdata_0)
);
endmodule

// ***********************************************************************
module ext_mem_sim #(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 9,
    parameter OUTPUT_REG    = "TRUE",
    parameter RAM_INIT_FILE = ""
) (
    input [DATA_WIDTH-1:0]  wdata,
    input [ADDR_WIDTH-1:0]  waddr, 
    input [ADDR_WIDTH-1:0]  raddr,
    input                   we, 
    input                   wclk, 
    input                   re, 
    input                   rclk,
    output [DATA_WIDTH-1:0] rdata
);

/////////////////////////////////////////////////////////////////////////////

    localparam MEMORY_DEPTH = 2**ADDR_WIDTH;
    localparam MAX_DATA = (1<<ADDR_WIDTH)-1;

    reg [DATA_WIDTH-1:0]ram [MEMORY_DEPTH-1:0];
    wire [DATA_WIDTH-1:0] r_rdata_1P;
    reg [DATA_WIDTH-1:0] r_rdata_2P;

/////////////////////////////////////////////////////////////////////////////
    integer i;
    
    initial
    begin
        if (RAM_INIT_FILE != "")
        begin
            $readmemh(RAM_INIT_FILE, ram);
        end
    end

    always @ (posedge wclk)
        if (we)
        ram[waddr] <= wdata;

    assign r_rdata_1P = re? ram[raddr] : 'hZ;

    always @ (posedge rclk)
    begin
        if (re)
        r_rdata_2P <= r_rdata_1P;
    end

    generate
        if (OUTPUT_REG == "TRUE")
            assign  rdata = r_rdata_2P;
        else
            assign  rdata = r_rdata_1P;
    endgenerate

endmodule


//////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.
//
// This   document  contains  proprietary information  which   is
// protected by  copyright. All rights  are reserved.  This notice
// refers to original work by Efinix, Inc. which may be derivitive
// of other work distributed under license of the authors.  In the
// case of derivative work, nothing in this notice overrides the
// original author's license agreement.  Where applicable, the 
// original license agreement is included in it's original 
// unmodified form immediately below this header.
//
// WARRANTY DISCLAIMER.  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND 
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH 
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES, 
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF 
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR 
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED 
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.
//
// LIMITATION OF LIABILITY.  
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY 
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT 
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY 
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT, 
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY 
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR 
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN 
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER 
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR 
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT 
//     APPLY TO LICENSEE.
//
/////////////////////////////////////////////////////////////////////////////

