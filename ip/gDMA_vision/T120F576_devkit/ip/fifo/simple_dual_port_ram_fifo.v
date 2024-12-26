/////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2020 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   simple_dual_port_ram_fifo.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Modified Efinix Single RAM Block
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// *******************************
// Revisions:
// 1.0 Initial rev
// 2.0 Sync FWFT infer READ_UNKNOWN RAM and Support Asymmetrical Width
//
// *******************************

module simple_dual_port_ram_fifo
  #(
    parameter SYNC_CLK		= 1,
    parameter WR_DEPTH		= 512,
    parameter RD_DEPTH		= 512,
    parameter WDATA_WIDTH	= 8,
    parameter RDATA_WIDTH	= 8,
    parameter WADDR_WIDTH	= 9,
    parameter RADDR_WIDTH	= 9,
    parameter OUTPUT_REG	= 1,
    parameter ASYM_WIDTH	= 0,
    parameter MODE		= "STANDARD"
    )
   (
    input [(WDATA_WIDTH-1):0]  wdata,
    input [(WADDR_WIDTH-1):0]  waddr,
    input [(RADDR_WIDTH-1):0]  raddr,
    input 		       we, re, clk, wclk, rclk,
    output [(RDATA_WIDTH-1):0] rdata
    );

   //Depth and data width is inversely proportional
   localparam MEM_DEPTH = (WR_DEPTH > RD_DEPTH) ? WR_DEPTH : RD_DEPTH;
   localparam MEM_DATA_WIDTH = (WDATA_WIDTH > RDATA_WIDTH) ? RDATA_WIDTH : WDATA_WIDTH;

   reg [MEM_DATA_WIDTH-1:0]        ram[MEM_DEPTH-1:0];

   reg [RDATA_WIDTH-1:0]       r_rdata_1P;

generate
   if (ASYM_WIDTH == 0) begin
      if (SYNC_CLK == 1) begin
	 always @ (posedge clk) begin
	    if (we)
	      ram[waddr] <= wdata;
	    if (re)
	      r_rdata_1P <= ram[raddr];
	 end
      end
      else /* (SYNC_CLK == 0) */ begin
	 always @ (posedge wclk)
	   if (we)
	     ram[waddr] <= wdata;

	 always @ (posedge rclk) begin
	    if (re)
	      r_rdata_1P <= ram[raddr];
	 end
      end
   end
   else /* (ASYM_WIDTH == 1) */ begin //Sync FIFO only
      if (WDATA_WIDTH == RDATA_WIDTH*2) begin
	 always @ (posedge clk) begin : wrwidth_gt_rdwidth
	    integer i;
	    reg     lsbaddr;
	    for (i=0; i<2; i=i+1) begin // : write1
	       lsbaddr = i;
	       if (we) begin
	   	  //ram[{waddr,lsbaddr}] <= wdata[((i+1)*WDATA_WIDTH/2)-1 -: WDATA_WIDTH/2]; //Little Endian
	   	  ram[{waddr,lsbaddr}] <= wdata[(WDATA_WIDTH/(i+1))-1 -: WDATA_WIDTH/2]; //Big Endian
	       end
	    end
	    if (re)
	      r_rdata_1P <= ram[raddr];
	 end
      end
      else if (WDATA_WIDTH == RDATA_WIDTH/2) begin
	 always @ (posedge clk) begin : wrwidth_lt_rdwidth
	    integer i;
	    reg     lsbaddr;
	    if (we)
	      ram[waddr] <= wdata;
	    for (i=0; i<2; i=i+1) begin
	       lsbaddr = i;
	       if (re) begin
		  //r_rdata_1P[((i+1)*RDATA_WIDTH/2)-1 -: RDATA_WIDTH/2] <= ram[{raddr,lsbaddr}]; //Little Endian
		  r_rdata_1P[(RDATA_WIDTH/(i+1))-1 -: RDATA_WIDTH/2] <= ram[{raddr,lsbaddr}]; //Big Endian
	       end
	    end
	 end
      end
   end
endgenerate

generate
   if (OUTPUT_REG == 1) begin
      reg [RDATA_WIDTH-1:0] r_rdata_2P;
      if (SYNC_CLK == 1)
	always @(posedge clk)
	  r_rdata_2P <= r_rdata_1P;
      else /* (SYNC_CLK == 0) */
	always @(posedge rclk)
	  r_rdata_2P <= r_rdata_1P;
      assign rdata = r_rdata_2P;
   end
   else /* (OUTPUT_REG == 0) */
     assign rdata = r_rdata_1P;
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
