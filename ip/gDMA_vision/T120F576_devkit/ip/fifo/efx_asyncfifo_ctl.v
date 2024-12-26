/////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2020 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   efx_asyncfifo_ctl.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Asynchronous FIFO status controller
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// *******************************
// Revisions:
// 1.0 Initial rev
// 2.3 Introduce wr_adr_change & rd_adr_change for PIPELINE_REG en
//     rd_adr_int added DEPTH != 2**ADDR_WIDTH logic
//
// *******************************

`resetall
`timescale 1ns/1ps

module efx_asyncfifo_ctl
#(
  parameter SYNC_CLK		= 0,
  parameter WR_DEPTH		= 1025,
  parameter RD_DEPTH		= 1025,
  parameter WADDR_WIDTH		= depth2width(WR_DEPTH),
  parameter RADDR_WIDTH		= depth2width(RD_DEPTH),
  parameter ASYM_WIDTH		= 0,
  parameter MODE		= "STANDARD",
  parameter PIPELINE_REG	= 1,
  parameter OPTIONAL_FLAGS	= 1,
  parameter PROGRAMMABLE_FULL	= "NONE",
  parameter PROG_FULL_ASSERT	= 1024,
  parameter PROG_FULL_NEGATE	= 1025,
  parameter PROGRAMMABLE_EMPTY	= "NONE",
  parameter PROG_EMPTY_ASSERT	= 1,
  parameter PROG_EMPTY_NEGATE	= 0
)
(// output
 output wire 		       wr_almost_full_o,
 output wire 		       wr_prog_full_o,
 output wire 		       wr_full_o,
 output reg 		       overflow_o,
 output wire [WADDR_WIDTH-1:0]  wr_adr_o,
 output reg 		       wr_ack_o,
 output wire 		       wr_ram,
 output wire [WADDR_WIDTH-1:0] wr_datacount_o,
 output wire 		       rd_empty_o,
 output wire 		       rd_almost_empty_o,
 output wire 		       rd_prog_empty_o,
 output reg 		       underflow_o,
 output wire [RADDR_WIDTH-1:0]  rd_adr_o,
 output reg 		       rd_valid_o,
 output wire 		       rd_ram,
 output wire [RADDR_WIDTH-1:0] rd_datacount_o,
 // input    
 input 			       wr_clk_i,
 input 			       wr_en_i,
 input 			       rd_clk_i,
 input 			       rd_en_i,
 input 			       a_rst_i);
//--------------------------------------------------------------------
// Local Function
function integer depth2width;
input [31:0] depth;
// Description:
//   Converts a depth value into a Width.  For instance a depth of
//        a=depth2width(64);
//   sets "a" to 6. 
//
//   One way to use this is to convert a depth to a width value on a
//   register.  For instance:
//        reg [depth2width(MEM_WIDTH)-1:0] a;
//
begin : fnDepth2Width
  if (depth > 1) begin
     depth = depth - 1;
     for (depth2width=0; depth>0; depth2width = depth2width + 1)
       depth = depth>>1;
  end
  else
    depth2width = 0;
end
endfunction 


//--------------------------------------------------------------------
function integer width2depth;
input [31:0] width;
// Description:
//   Converts a width value into a depth.  For instance a width of
//        a=width2depth(6);
//   sets "a" to 64. 
//
//   One way to use this is to convert a width to a depth value on a
//   register.  For instance:
//        reg [WORD_WIDTH-1:0] a [width2depth(ADR_WIDTH)-1];
//
begin : fnWidth2Depth
  width2depth = width**2;
end
endfunction 

//--------------------------------------------------------------------
function integer divCeil;
input [31:0] dividend;
input [31:0] divisor;
// Description:
//   Divides dividend by divisor.  In dividing the values the max value 
//   is obtained.
//        a=divCeil(6,4);
//   sets "a" to 2. 
//
begin : fnDivCeil
  divCeil = (dividend-(dividend%divisor)) / divisor;
  divCeil = (dividend%divisor) > 0 ? divCeil + 1 : divCeil;
end
endfunction 

//--------------------------------------------------------------------
function integer divFloor;
input [31:0] dividend;
input [31:0] divisor;
// Description:
//   Divides dividend by divisor.  In dividing the values the max value 
//   is obtained.
//        a=divFloor(6,4);
//   sets "a" to 1. 
//
begin : fnDivFloor
  divFloor = (dividend-(dividend%divisor)) / divisor;
end
endfunction

//--------------------------------------------------------------------

//--------------------------------------------------------------------
// Masked Signals
   wire 	      wr_empty_o, wr_almost_empty_o, wr_prog_empty_o, wr_half_full_o;
   wire 	      rd_almost_full_o, rd_prog_full_o, rd_full_o, rd_half_full_o;
//--------------------------------------------------------------------
// Local Parameters
   localparam WMAX_ADDR = (WR_DEPTH-1);
   localparam RMAX_ADDR = (RD_DEPTH-1);
   localparam WR_SYNC=2;
   localparam RD_SYNC=2;
   
   localparam WADDR_WIDTH_M = WADDR_WIDTH+1;
   localparam RADDR_WIDTH_M = RADDR_WIDTH+1;
   
//--------------------------------------------------------------------
// Local Signals
   wire [RADDR_WIDTH_M-1:0] rd_adr_int;       //Internal read address
   wire 		  rd_empty_int;
   reg 			  rd_first = 1'b0;
   wire [WADDR_WIDTH_M-1:0] wr_adr_gray, wr_adr_gray_sync, wr_adr_sync;
   wire [RADDR_WIDTH_M-1:0] rd_adr_gray, rd_adr_gray_sync, rd_adr_sync;
   reg  [WADDR_WIDTH_M-1:0] wr_adr_nxt;
   reg  [RADDR_WIDTH_M-1:0] rd_adr_nxt;
   
   assign wr_adr_o = wr_adr_nxt[WADDR_WIDTH-1:0];
   assign rd_adr_o = rd_adr_nxt[RADDR_WIDTH-1:0];
   // reg  [WADDR_WIDTH-1:0] wr_adr_sync_reg; //Pipelined Sync Addr if enabled
   // reg  [RADDR_WIDTH-1:0] rd_adr_sync_reg; //Pipelined Sync Addr if enabled

//--------------------------------------------------------------------
// Writing and Reading is allowed only for valid operations. That
// is you can not write more into a full FIFO nor can you read
// an empty FIFO.
// Logic for writing and reading ram, wr_ram & rd_ram
   assign wr_ram = (wr_en_i & ~wr_full_o);

generate
   if (MODE == "STANDARD") begin
      assign rd_empty_o = rd_empty_int;
      assign rd_ram = (rd_en_i  & ~rd_empty_o);

      assign rd_adr_int = rd_adr_nxt;
   end
   else /* (MODE == "FWFT") */ begin : rd_fwft_compensate
      assign rd_empty_o = rd_first ? 1'b1 : rd_empty_int;

      //Can't read when datacount = 1
      //Auto read at next clock cycle if empty for first write
      assign rd_ram = (rd_en_i & ~rd_empty_o & (rd_datacount_o != 1)) |
     		      (rd_first & ~rd_empty_int);

      always @(posedge rd_clk_i)
	if (rd_empty_int)
	  rd_first <= 1'b1;
	else if (rd_first)
	  rd_first <= 1'b0;
	else if (rd_datacount_o == {{RADDR_WIDTH-1{1'b0}}, 1'b1} && rd_en_i)
	  rd_first <= 1'b1;

      //rd_adr in FWFT will auto-increment for the first word, hence need to
      // compensate that extra word lost.
      reg datacount_minus;	//Word compensation for FWFT
      //if (RD_DEPTH == 2**RADDR_WIDTH)    // DEPTH is always multiply of 2
	assign rd_adr_int = rd_adr_nxt - datacount_minus;
    //  else
	//assign rd_adr_int = (datacount_minus && (rd_adr_o == {RADDR_WIDTH{1'b0}})) ?
	//		    RMAX_ADDR : rd_adr_o - datacount_minus;

      always @(posedge rd_clk_i, posedge a_rst_i) begin
	 if (a_rst_i) begin
	    datacount_minus <= 1'b0;
	 end
	 else if (rd_first && ~rd_empty_int) begin
	    datacount_minus  <= 1'b1;
	 end
	 else if (rd_datacount_o == {{RADDR_WIDTH-1{1'b0}},1'b1} && rd_en_i) begin
	    datacount_minus <= 1'b0;
	 end
      end
   end
endgenerate
   
//--------------------------------------------------------------------
// Write Address Counter and optional wr_ack_o Signal
generate
   if (OPTIONAL_FLAGS == 1)
     always @(posedge wr_clk_i, posedge a_rst_i)
       if (a_rst_i)
	 wr_ack_o <= 1'b0;
       else
	 wr_ack_o <= wr_ram;
endgenerate

always @(posedge wr_clk_i, posedge a_rst_i)
  begin
     if(a_rst_i)
       wr_adr_nxt <= {WADDR_WIDTH_M{1'b0}};
     else
       if (wr_ram)
	 //if(wr_adr_o==WMAX_ADDR)    // DEPTH is always multiply of 2
     //      wr_adr_o <= {WADDR_WIDTH{1'b0}};
	 //else
           wr_adr_nxt <= wr_adr_nxt + 1'b1;
  end

// Convert Write address to Gray to sync with Read Domain
bin2gray
  #(.WIDTH(WADDR_WIDTH_M))
  u_wr_adr_gray(.gray_o(wr_adr_gray),.bin_i(wr_adr_nxt),.clk_i(wr_clk_i));
// sync to rd_clk_i
pipe_reg
  #(.DEPTH(RD_SYNC),.WIDTH(WADDR_WIDTH_M))
  u_wr_adr_graysync(.d_o(wr_adr_gray_sync),.d_i(wr_adr_gray),.clk_i(rd_clk_i));
// convert back to binary
gray2bin
  #(.WIDTH(WADDR_WIDTH_M))
  u_wr_adr_sync(.bin_o(wr_adr_sync),.gray_i(wr_adr_gray_sync));
//Introduced to reduce logic required for FWFT rd_datacount_o

wire wr_adr_change;
generate
    if (PIPELINE_REG == 1) begin : wr_adr_change_gen
        reg [WADDR_WIDTH_M-1:0] wr_adr_gray_reg;
        always @(posedge rd_clk_i)
          wr_adr_gray_reg <= wr_adr_gray;

        if (RD_SYNC >= 1) begin
            reg wr_adr_change_reg;
            always @(posedge rd_clk_i)
              wr_adr_change_reg <= (wr_adr_gray != wr_adr_gray_reg);

            if (RD_SYNC > 1)
                pipe_reg
                    #(.DEPTH(RD_SYNC-1),.WIDTH(1))
                    u_wr_adr_graysync(.d_o(wr_adr_change),.d_i(wr_adr_change_reg),.clk_i(rd_clk_i));
            else
                assign wr_adr_change = wr_adr_change_reg;
        end
        else
            assign wr_adr_change = (wr_adr_gray != wr_adr_gray_reg);
    end
endgenerate

// generate
//    if (PIPELINE_REG == 0) begin
//       always @(*)
// 	wr_adr_sync_reg = wr_adr_sync;
//    end
//    else /* (PIPELINE_REG == 1) */ begin
//       always @(posedge rd_clk_i)
// 	  wr_adr_sync_reg <= wr_adr_sync;
//    end
// endgenerate

//--------------------------------------------------------------------
// Read Address Counter and rd_valid_o Signal
generate
   if (OPTIONAL_FLAGS == 1)
     if (MODE == "STANDARD") begin
	always @(posedge rd_clk_i, posedge a_rst_i)
	  if (a_rst_i) begin
	     rd_valid_o <= 1'b0;
	  end
	  else begin
	     rd_valid_o <= rd_ram;
	  end
     end
     else /* (MODE == "FWFT") */  begin
	always @(*)
	  rd_valid_o = ~rd_empty_o;
     end
endgenerate

   always @(posedge rd_clk_i, posedge a_rst_i)
     if (a_rst_i) begin
	rd_adr_nxt <= {RADDR_WIDTH_M{1'b0}};
     end
     else begin
	if (rd_ram)
	  //if(rd_adr_o==RMAX_ADDR)          // DEPTH is always multiply of 2
	  //  rd_adr_o <= {RADDR_WIDTH{1'b0}};
	  //else
	    rd_adr_nxt <= rd_adr_nxt + 1'b1;
     end
   
// Convert Read address to Gray to sync with Write Domain
bin2gray
  #(.WIDTH(RADDR_WIDTH_M))
  u_rd_adr_gray(.gray_o(rd_adr_gray),.bin_i(rd_adr_int),.clk_i(rd_clk_i));
// sync to wr_clk_i
pipe_reg
  #(.DEPTH(WR_SYNC),.WIDTH(RADDR_WIDTH_M))
  u_rd_adr_graysync(.d_o(rd_adr_gray_sync),.d_i(rd_adr_gray),.clk_i(wr_clk_i));
// convert back to binary
gray2bin
  #(.WIDTH(RADDR_WIDTH_M))
  u_rd_adr_sync(.bin_o(rd_adr_sync),.gray_i(rd_adr_gray_sync));

wire rd_adr_change;
generate
    if (PIPELINE_REG == 1) begin : rd_adr_change_gen
        reg [RADDR_WIDTH_M-1:0] rd_adr_gray_reg;
        always @(posedge wr_clk_i)
          rd_adr_gray_reg <= rd_adr_gray;

        if (WR_SYNC >= 1) begin
            reg rd_adr_change_reg;
            always @(posedge wr_clk_i)
              rd_adr_change_reg <= (rd_adr_gray != rd_adr_gray_reg);

            if (WR_SYNC > 1)
                pipe_reg
                    #(.DEPTH(WR_SYNC-1),.WIDTH(1))
                    u_rd_adr_graysync(.d_o(rd_adr_change),.d_i(rd_adr_change_reg),.clk_i(wr_clk_i));
            else
                assign rd_adr_change = rd_adr_change_reg;
        end
        else
            assign rd_adr_change = (rd_adr_gray != rd_adr_gray_reg);
    end
endgenerate

// generate
//    if (PIPELINE_REG == 0) begin
//       always @(*)
// 	rd_adr_sync_reg = rd_adr_sync;
//    end
//    else /* (PIPELINE_REG == 1) */ begin
//       always @(posedge wr_clk_i)
// 	  rd_adr_sync_reg <= rd_adr_sync;
//    end
// endgenerate

//--------------------------------------------------------------------
// Compute Wr & Rd Flags
   efx_fifo_ctl_sm #(//Parameter
		     .SYNC_CLK		 (SYNC_CLK),
		     .DEPTH		 (WR_DEPTH),
		     .ADDR_WIDTH	 (WADDR_WIDTH),
		     .MODE		 (MODE),
		     .OPTIONAL_FLAGS	 (OPTIONAL_FLAGS),
		     .PROGRAMMABLE_FULL	 (PROGRAMMABLE_FULL),
		     .PROG_FULL_ASSERT	 (PROG_FULL_ASSERT),
		     .PROG_FULL_NEGATE	 (PROG_FULL_NEGATE),
		     .PROGRAMMABLE_EMPTY (PROGRAMMABLE_EMPTY), 
		     .PROG_EMPTY_ASSERT	 (PROG_EMPTY_ASSERT),
		     .PROG_EMPTY_NEGATE	 (PROG_EMPTY_NEGATE),
		     .PIPELINE_REG	 (PIPELINE_REG),
		     .DOMAIN		 ("WRITE"))
   u_wrflags(
	     // Outputs
	     .empty_o		(wr_empty_o),
	     .almost_empty_o(wr_almost_empty_o),
	     .prog_empty_o	(wr_prog_empty_o),
	     .half_full_o	(wr_half_full_o),
	     .almost_full_o	(wr_almost_full_o),
	     .prog_full_o	(wr_prog_full_o),
	     .full_o		(wr_full_o),
	     .datacount_o	(wr_datacount_o),
	     // Inputs
	     .wr_adr_i		(wr_adr_nxt[WADDR_WIDTH-1:0]),
	     .wr_adr_i_msb  (wr_adr_nxt[WADDR_WIDTH]),
	     .rd_adr_i		(rd_adr_sync[RADDR_WIDTH-1:0]),
	     .rd_adr_i_msb  (rd_adr_sync[RADDR_WIDTH]),	     
	     .clk_i         (wr_clk_i),
	     .a_rst_i		(a_rst_i),
	     .wr_ram		(wr_ram),
	     .rd_ram		(rd_adr_change),
	     .rd_en_i		(1'b0));

   efx_fifo_ctl_sm #(//Parameter
		     .SYNC_CLK		 (SYNC_CLK),
		     .DEPTH		 (RD_DEPTH),
		     .ADDR_WIDTH	 (RADDR_WIDTH),
		     .MODE		 (MODE),
		     .OPTIONAL_FLAGS	 (OPTIONAL_FLAGS),
		     .PROGRAMMABLE_FULL	 (PROGRAMMABLE_FULL),
		     .PROG_FULL_ASSERT	 (PROG_FULL_ASSERT),
		     .PROG_FULL_NEGATE	 (PROG_FULL_NEGATE),
		     .PROGRAMMABLE_EMPTY (PROGRAMMABLE_EMPTY), 
		     .PROG_EMPTY_ASSERT	 (PROG_EMPTY_ASSERT),
		     .PROG_EMPTY_NEGATE	 (PROG_EMPTY_NEGATE),
		     .PIPELINE_REG	 (PIPELINE_REG),
		     .DOMAIN		 ("READ"))
   u_rdflags(
	     // Outputs
	     .empty_o		(rd_empty_int),
	     .almost_empty_o(rd_almost_empty_o),
	     .prog_empty_o	(rd_prog_empty_o),
	     .half_full_o	(rd_half_full_o),
	     .almost_full_o	(rd_almost_full_o),
	     .prog_full_o	(rd_prog_full_o),
	     .full_o		(rd_full_o),
	     .datacount_o	(rd_datacount_o),
	     // Inputs
	     .wr_adr_i		(wr_adr_sync[WADDR_WIDTH-1:0]),
	     .wr_adr_i_msb  (wr_adr_sync[WADDR_WIDTH]),
	     .rd_adr_i		(rd_adr_int[RADDR_WIDTH-1:0]),
	     .rd_adr_i_msb  (rd_adr_int[RADDR_WIDTH]),	 
	     .clk_i         (rd_clk_i),
	     .a_rst_i		(a_rst_i),
	     .wr_ram		(wr_adr_change),
	     .rd_ram		(rd_ram && ~rd_first),
	     .rd_en_i		(rd_en_i));

//Optional error signals
generate
   if (OPTIONAL_FLAGS == 1) begin
      always @(posedge wr_clk_i) begin
	 overflow_o <= wr_full_o & wr_en_i;
      end
      always @(posedge rd_clk_i) begin
	 underflow_o <= rd_empty_o & rd_en_i;
      end
   end
endgenerate

endmodule

////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2020 Efinix Inc. All rights reserved.              
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
////////////////////////////////////////////////////////////////////////////////
