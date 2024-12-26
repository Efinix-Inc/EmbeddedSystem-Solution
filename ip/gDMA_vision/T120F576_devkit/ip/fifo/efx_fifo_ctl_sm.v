/////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2020 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   efx_fifo_ctl_sm.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      FIFO status flags state machine.  The state machine
//  /_/ /\ \_____/ /     generates the FIFO status based on read/write
// ____/  \_______/      address inputs.
//
// *******************************
// Revisions:
// 1.0 Initial rev
// 2.3 Datacount applies register mode
//
// *******************************

`resetall
`timescale 1ns/1ps

module efx_fifo_ctl_sm
#(parameter SYNC_CLK		= 1,
  parameter DEPTH		= 1025,
  parameter ADDR_WIDTH		= depth2width(DEPTH),
  parameter MODE		= "STANDARD",
  parameter OPTIONAL_FLAGS	= 1,
  parameter PROGRAMMABLE_FULL	= "NONE",
  parameter PROG_FULL_ASSERT	= 1024,
  parameter PROG_FULL_NEGATE	= 1025,
  parameter PROGRAMMABLE_EMPTY	= "NONE",
  parameter PROG_EMPTY_ASSERT	= 1,
  parameter PROG_EMPTY_NEGATE	= 0,
  parameter PIPELINE_REG	= 1,
  parameter DOMAIN		= "WRITE")
(// output
 output reg 		      empty_o,
 output wire 		      almost_empty_o,
 output wire 		      prog_empty_o,
 output reg 		      half_full_o,
 output reg 		      full_o,
 output wire 		      almost_full_o,
 output wire 		      prog_full_o,
 output wire [ADDR_WIDTH-1:0] datacount_o,
 // input
 input [ADDR_WIDTH-1:0]       wr_adr_i,
 input [ADDR_WIDTH-1:0]       rd_adr_i,
 input                        wr_adr_i_msb,
 input                        rd_adr_i_msb,
 input 			      clk_i,
 input 			      a_rst_i,
 input 			      wr_ram,
 input 			      rd_ram,
 input 			      rd_en_i);
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

// //--------------------------------------------------------------------
// Local Parameters
   localparam [ADDR_WIDTH-1:0] MAX_ADDR   = DEPTH-1;
   localparam HALF_DEPTH = DEPTH>>1;
   localparam EMPTY_ST   = 0; // State: empty
   localparam LT_HF_ST   = 1; // State: less than Half Full
   localparam GTE_HF_ST  = 2; // State: greater than or equal half full
   localparam FULL_ST    = 3; // State: full
   localparam [ADDR_WIDTH-1:0] FULL_COUNT = 0;
					 //(MODE=="STANDARD") ? 0 : 1;
   //FWFT will have one extra word
   //At this point we don't care the extra word introduced and it'll have
   // the same max datacount_o as Standard Mode, due to the complexity of
   // the state machine and flags if included. It'll be nice to have so as
   // to utilize the maximum Depth till wr_adr=rd_adr, however it's not an
   // important feature to be included at the moment.
   localparam MAXSPEED_DIV = ADDR_WIDTH;
   localparam CALC_WIDTH = (ADDR_WIDTH > depth2width(MAXSPEED_DIV)) ? depth2width(MAXSPEED_DIV) : ADDR_WIDTH;

//--------------------------------------------------------------------
// Local Signals
   reg [ADDR_WIDTH-1:0]      datacount_up;
   wire [ADDR_WIDTH-1:0]      datacount_dn;
   reg [1:0] 		 curr_st, next_st;

//--------------------------------------------------------------------
// Compute Word Count.  Word count is the number of words in the
// FIFO. Note that a depth with a power of 2 produces less logic

//    wire [ADDR_WIDTH-1:0] datacount_up_ideal;
// generate
//    if (SYNC_CLK == 1 || PIPELINE_REG == 0)
//      assign datacount_up_ideal = wr_adr_i - rd_adr_i;
//    else if (SYNC_CLK == 0 && PIPELINE_REG == 1) begin
//       reg [ADDR_WIDTH-1:0] wr_adr_reg;
//       reg [ADDR_WIDTH-1:0] rd_adr_reg;
//       assign datacount_up_ideal = wr_adr_reg - rd_adr_reg;
//       if (DOMAIN == "WRITE") begin
// 	 always @(*) wr_adr_reg = wr_adr_i;
// 	 always @(posedge clk_i)
// 	   rd_adr_reg <= rd_adr_i;
//       end
//       else if (DOMAIN == "READ") begin
// 	 always @(*) rd_adr_reg = rd_adr_i;
// 	 always @(posedge clk_i)
// 	   wr_adr_reg <= wr_adr_i;
//       end
//   end
// endgenerate
//    wire 		 compare_ideal;
//    assign compare_ideal = datacount_up_ideal != datacount_up;

   reg 	count_one;
   wire read_last;
generate
   if (MODE == "FWFT" && (SYNC_CLK == 1 || DOMAIN != "WRITE")) begin
      assign read_last = count_one && rd_en_i;
      always @(posedge clk_i) begin
      	 count_one <= (datacount_up == {{ADDR_WIDTH-2{1'b0}},2'b10} && ~wr_ram && rd_ram) ||
      		      (datacount_up == {{ADDR_WIDTH-1{1'b0}},1'b1} && ~wr_ram && ~read_last);// || (empty_o && wr_ram);
      end
   end
endgenerate

generate
   if (SYNC_CLK == 1) begin
      always @(posedge clk_i, posedge a_rst_i) begin
      	 if (a_rst_i)
      	   datacount_up <= {ADDR_WIDTH{1'b0}};
      	 else if (wr_ram) begin
      	    datacount_up <= datacount_up + 1'b1;
      	    if (rd_ram || (read_last && (MODE == "FWFT")))
      	      datacount_up <= datacount_up;
      	    else if (DEPTH != 2**ADDR_WIDTH)
      	      if (datacount_up == MAX_ADDR)
      		datacount_up <= {ADDR_WIDTH{1'b0}};
      	 end
      	 else if (rd_ram) begin
      	    datacount_up <= datacount_up - 1'b1;
      	    if (DEPTH != 2**ADDR_WIDTH)
      	      if (full_o)
      		datacount_up <= MAX_ADDR;
      	 end
      	 //This only applies to FWFT, Standard won't go into this
      	 // since when datacount=1 and rd_en_i, rd_ram will be high
      	 else if (MODE == "FWFT")
           if (read_last)
             datacount_up <= {ADDR_WIDTH{1'b0}};
      end
   end
   else if (SYNC_CLK == 0) begin
      if (PIPELINE_REG == 0)
	always @(*) datacount_up = wr_adr_i - rd_adr_i;
      else if (PIPELINE_REG == 1) begin
	 if (DOMAIN == "WRITE") begin
	    wire [ADDR_WIDTH-1:0] datacount_logic;
	    assign datacount_logic = (wr_adr_i - rd_adr_i) + wr_ram;

	    always @(posedge clk_i, posedge a_rst_i) begin
	       if (a_rst_i) begin
	    	  datacount_up <= {ADDR_WIDTH{1'b0}};
	       end
	       else begin
		  //.if (DEPTH == 2**ADDR_WIDTH)    // DEPTH is always multiply of 2
	    	    datacount_up <= datacount_logic;
	    //  else begin
		//    datacount_up <= (wr_adr_i >= rd_adr_i) ?
		//	     datacount_logic :
		//	     datacount_logic - ({ADDR_WIDTH{1'b1}} - MAX_ADDR);
	    //     if ((datacount_up == MAX_ADDR) && wr_ram && ~rd_ram)
	    //       datacount_up <= {ADDR_WIDTH{1'b0}};
		// end
	       end
	    end

	    // reg [ADDR_WIDTH-1:0] datacount_up_test;
	    // wire 		 compare;
	    // assign compare = datacount_up_test != datacount_up;

	    // reg [ADDR_WIDTH-1:0] rd_adr_reg; //ALT
            // wire [CALC_WIDTH:0]  rd_adr_diff; //ALT
            // assign rd_adr_diff = {1'b1,rd_adr_i[CALC_WIDTH-1:0]} - rd_adr_reg[CALC_WIDTH-1:0]; //ALT

	    // always @(posedge clk_i, posedge a_rst_i) begin
	    //    if (a_rst_i) begin
	    // 	  datacount_up_test <= {ADDR_WIDTH{1'b0}};
	    // 	  rd_adr_reg <= {ADDR_WIDTH{1'b0}}; //ALT
	    //    end
	    //    else begin
	    // 	  rd_adr_reg <= rd_adr_i; //ALT
	    // 	  datacount_up_test <= datacount_up_test + wr_ram - rd_adr_diff[CALC_WIDTH-1:0]; //ALT
	    // 	  //datacount_up_test <= (wr_adr_i - rd_adr_i) + wr_ram;
	    // 	  if (DEPTH != 2**ADDR_WIDTH)
	    // 	    if ((datacount_up_test == MAX_ADDR) && wr_ram && ~rd_ram)
	    // 	      datacount_up_test <= {ADDR_WIDTH{1'b0}};
	    // 	    else if (full_o && rd_ram) //ALT
	    // 	      datacount_up_test <= MAX_ADDR - rd_adr_diff[CALC_WIDTH-1:0] + 1'b1; //ALT
	    //    end
	    // end
	 end
	 else if (DOMAIN == "READ") begin
	    wire [ADDR_WIDTH-1:0] datacount_logic;
	    assign datacount_logic = (wr_adr_i - rd_adr_i) - (rd_ram || (read_last && (MODE == "FWFT")));

	    always @(posedge clk_i, posedge a_rst_i) begin
	       if (a_rst_i) begin
	    	  datacount_up <= {ADDR_WIDTH{1'b0}};
	       end
	       else begin
		  //if (DEPTH == 2**ADDR_WIDTH)            // DEPTH is always multiply of 2
	    	    datacount_up <= datacount_logic;
	    //	  else begin
		//     datacount_up <= (wr_adr_i >= rd_adr_i) ?
		//		     datacount_logic :
		//		     datacount_logic - ({ADDR_WIDTH{1'b1}} - MAX_ADDR);
		//     if (full_o && rd_ram)
	    //	       datacount_up <= MAX_ADDR;
		//  end
	       end
	    end
	 end
      end
   end
endgenerate

generate
   if (SYNC_CLK == 0 && PIPELINE_REG == 0) begin
      assign datacount_dn = (wr_adr_i - rd_adr_i) - ({ADDR_WIDTH{1'b1}} - MAX_ADDR);
      assign datacount_o = rd_adr_i > wr_adr_i ? datacount_dn : datacount_up;
   end
   else
     assign datacount_o = datacount_up;
endgenerate

//--------------------------------------------------------------------
// Next State: Depends on Current State and datacount_o
always @(*) begin
   next_st = curr_st;
   empty_o = 0;
   half_full_o = 0;
   full_o = 0;
   
   case(curr_st)
     EMPTY_ST : begin
	empty_o = 1;
	if(datacount_o != {ADDR_WIDTH{1'b0}}) //Logic for >0 is not efficient
	//if(datacount_o > 0)
	  begin
	     empty_o = 0;
	     next_st = LT_HF_ST;
	  end
     end
     LT_HF_ST : begin
	if(datacount_o[ADDR_WIDTH-1] == 1'b1) //>=HALF_DEPTH
          next_st = GTE_HF_ST;
	else if(datacount_o == 0) begin
	   empty_o = 1;
           next_st = EMPTY_ST;
	end
     end
     GTE_HF_ST : begin
	half_full_o = 1;
	if(datacount_o == FULL_COUNT) begin
        if (SYNC_CLK) begin
            full_o  = 1;
            next_st = FULL_ST;
        end
        else begin
            if (wr_adr_i_msb != rd_adr_i_msb) begin  //It is full when the MSB of the pointers are different, but remaining bits are equal.
                full_o  = 1;
                next_st = FULL_ST;
            end
            else begin    
                full_o  = 0;
                next_st = EMPTY_ST;
            end
        end
	end
	else if(datacount_o[ADDR_WIDTH-1] == 1'b0) //<HALF_DEPTH
          next_st = LT_HF_ST;
     end
     FULL_ST : begin
	half_full_o = 1;
	full_o = 1;
	if(datacount_o != FULL_COUNT) begin
	   full_o  = 0;
	   next_st = GTE_HF_ST;
	end
     end
     default : begin
	next_st = EMPTY_ST;
     end
   endcase
end

//--------------------------------------------------------------------
// Current State
always @(posedge clk_i, posedge a_rst_i) begin
  if(a_rst_i)
    curr_st <= EMPTY_ST;
  else
    curr_st <= next_st;
end

//--------------------------------------------------------------------
// Compute Optional Custom Flags
generate
   if (OPTIONAL_FLAGS == 1) begin
      assign almost_empty_o = (next_st==FULL_ST) ? 1'b0 :
			      (next_st==EMPTY_ST) ? 1'b1 : (datacount_o<=1);
      assign almost_full_o  = (next_st==EMPTY_ST) ? 1'b0 :
			      (((DEPTH-datacount_o)<=1) || next_st==FULL_ST);
   end
endgenerate

// Add a flop to the combinatorial output feedback to solve
//  racing issue
generate
   if (PROGRAMMABLE_FULL != "NONE") begin
      reg prog_full_latch;
      always @(posedge clk_i)
	prog_full_latch <= prog_full_o;
      if (PROGRAMMABLE_FULL == "STATIC_SINGLE")
	assign prog_full_o = (next_st==EMPTY_ST) ? 1'b0 :
                             (next_st==FULL_ST)  ? 1'b1 :
                             (prog_full_latch == 1'b0) ? (datacount_o>=PROG_FULL_ASSERT) :
                             (datacount_o>=PROG_FULL_ASSERT);
      else if (PROGRAMMABLE_FULL == "STATIC_DUAL")
	assign prog_full_o = (next_st==EMPTY_ST) ? 1'b0 :
                             (next_st==FULL_ST)  ? 1'b1 :
                             (prog_full_latch == 1'b0) ? (datacount_o>=PROG_FULL_ASSERT) :
                             (datacount_o>=PROG_FULL_NEGATE);
   end
endgenerate

generate
   if (PROGRAMMABLE_EMPTY != "NONE") begin
      reg prog_empty_latch;
      always @(posedge clk_i)
	prog_empty_latch <= prog_empty_o;
      if (PROGRAMMABLE_EMPTY == "STATIC_SINGLE")
	assign prog_empty_o = (next_st==FULL_ST)  ? 1'b0 :
                              (next_st==EMPTY_ST) ? 1'b1 :
                              (prog_empty_latch == 1'b0) ? (datacount_o<=PROG_EMPTY_ASSERT) :
                              (datacount_o<=PROG_EMPTY_ASSERT);
      else if (PROGRAMMABLE_EMPTY == "STATIC_DUAL")
	assign prog_empty_o = (next_st==FULL_ST)  ? 1'b0 :
                              (next_st==EMPTY_ST) ? 1'b1 :
                              (prog_empty_latch == 1'b0) ? (datacount_o<=PROG_EMPTY_ASSERT) :
                              (datacount_o<=PROG_EMPTY_NEGATE);
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
