////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   
//       / / .'     /    
//    __/ /.'      /     
//   __   \       /      
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// 1.0 Initial rev
//
// ***********************************************************************
`timescale 1 ns / 1 ps
module dma_ctr
(
//Globle Signals
input                           clk,
input                           rstn,
//Control Signals
input           [1:0]           dma_start,//[0]:write; [1]:read;
input           [31:0]          adma_system_address,
input                           stop_at_block_gap_request,
output  reg                     dma_wr_done,
output  reg                     dma_rd_done,
//DMA Write Data Interface
//--User Slave Read Bus Interface
output  reg                     s_arvalid,
output  reg     [31:0]          s_araddr,
output  reg     [15:0]          s_arlen,//Total_Byte_Length = s_arlen[15:0] + 1.
input                           s_arready,
input           [31:0]          s_rdata,
input                           s_rvalid,
output  wire                    s_rready,
//--Buffer Write Interface
output  wire                    dma_wr_vld,
output  wire    [31:0]          dma_wr_data,
input                           dma_wr_rdy,
//DMA Read Data Interface
//--User Slave Write Bus Interface
output  reg                     s_awvalid,
output  reg     [31:0]          s_awaddr,
output  reg     [15:0]          s_awlen,
input                           s_awready,
output  wire    [31:0]          s_wdata,
output  wire                    s_wvalid,
input                           s_wready,
//--Buffer Read Interface
input                           dma_rd_vld,
input           [31:0]          dma_rd_data,
output  wire                    dma_rd_rdy
//Status and  Error Signals
);
// Parameter Define 
parameter State_stop    = 2'd0;
parameter State_fds     = 2'd1;
parameter State_cadr    = 2'd2;
parameter State_tfr     = 2'd3;

localparam AXSIZE = 32/8;

// Register Define
reg     [1:0]                   cur_state;
reg     [1:0]                   next_state;
reg     [1:0]                   fds_cnt;
reg                             ds_table_ptr_en;
reg     [63:0]                  ds_table_r;
reg                             tfr_rw;//0b:write transfer; 1b:read transfer;
reg     [15:0]                  tfr_length;
reg     [15:0]                  tfr_byte_cnt_rd;
reg     [15:0]                  tfr_byte_cnt_wr;
reg                             tfr_complete;

// Wire Define

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/


/*----------------------- FSM Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        cur_state <= State_stop;
    else
        cur_state <= next_state;
end

always @(*)
begin
    case(cur_state)
    State_stop :
        if((dma_start == 2'b01) || (dma_start == 2'b10))
            next_state = State_fds;
        else
            next_state = State_stop;

    State_fds :
        if((fds_cnt == 'd3) && (ds_table_r[0] == 1'b0))
            next_state = State_stop;
        else if(fds_cnt == 'd3)
            next_state = State_cadr;
        else
            next_state = State_fds;

    State_cadr :
        if(ds_table_r[5:4] == 2'b10)
            next_state = State_tfr;
        else if(ds_table_r[1] == 1'b1)
            next_state = State_stop;
        else
            next_state = State_fds;
    
    State_tfr :
        if((tfr_complete == 1'b1) && (ds_table_r[1] == 1'b0) && (stop_at_block_gap_request == 1'b0))
            next_state = State_fds;
        else if(tfr_complete == 1'b1)
            next_state = State_stop;
        else
            next_state = State_tfr;

    default :
        next_state = State_stop;
    endcase
end

/*----------------------- Fetch Descriptor Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        fds_cnt <= 2'h0;
    else if(cur_state != State_fds)
        fds_cnt <= 2'h0;
    else if((fds_cnt == 'd0) || ((s_rvalid == 1'b1) && (s_rready == 1'b1)))
        fds_cnt <= fds_cnt + 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ds_table_ptr_en <= 1'b0;
    else if(cur_state == State_stop)
        ds_table_ptr_en <= 1'b1;
    else
        ds_table_ptr_en <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ds_table_r <= 64'h0;
    else if((cur_state == State_fds) && (fds_cnt == 2'd1) && (s_rvalid == 1'b1) && (s_rready == 1'b1))
        ds_table_r[31:0] <= s_rdata;
    else if((cur_state == State_fds) && (fds_cnt == 2'd2) && (s_rvalid == 1'b1) && (s_rready == 1'b1))
        ds_table_r[63:32] <= s_rdata;
    else if((cur_state == State_cadr) && (ds_table_r[1] == 1'b0) && (ds_table_r[5:4] == 2'b11))
        ds_table_r[63:32] <= ds_table_r[63:32];
    else if(cur_state == State_cadr)
        ds_table_r[63:32] <= s_araddr + 2*AXSIZE;
end

/*----------------------- Transfer Data Region ----------------------------*/
//0b:write transfer; 1b:read transfer;
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_rw <= 1'b0;
    else if((cur_state == State_stop) && (dma_start == 2'b01))
        tfr_rw <= 1'b0;
    else if((cur_state == State_stop) && (dma_start == 2'b10))
        tfr_rw <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_length <= 16'h0;
    else if(ds_table_r[31:16] == 0)
        tfr_length <= 65532;
    else if(ds_table_r[31:16] < AXSIZE)
        tfr_length <= 0;
    else
        tfr_length <= ds_table_r[31:16] - AXSIZE;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_byte_cnt_rd <= 16'h0;
    else if(cur_state != State_tfr)
        tfr_byte_cnt_rd <= 16'h0;
    else if((cur_state == State_tfr) && 
            ((tfr_rw == 1'b0) && (s_rvalid == 1'b1) && (s_rready == 1'b1)))
        tfr_byte_cnt_rd <= tfr_byte_cnt_rd + AXSIZE;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_byte_cnt_wr <= 16'h0;
    else if(tfr_complete)
    begin
        if( (tfr_rw == 1'b1) && (s_wvalid == 1'b1) && (s_wready == 1'b1) )
            tfr_byte_cnt_wr <= AXSIZE;
        else
            tfr_byte_cnt_wr <= 16'h0;
    end
    else if( (tfr_rw == 1'b1) && (s_wvalid == 1'b1) && (s_wready == 1'b1) )
        tfr_byte_cnt_wr <= tfr_byte_cnt_wr + AXSIZE;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_complete <= 1'b0;
    else if((cur_state == State_tfr) && ( (tfr_byte_cnt_rd == tfr_length) || (tfr_byte_cnt_wr == tfr_length) ) &&
             (((tfr_rw == 1'b0) && (s_rvalid == 1'b1) && (s_rready == 1'b1)) ||
              ((tfr_rw == 1'b1) && (s_wvalid == 1'b1) && (s_wready == 1'b1))))
        tfr_complete <= 1'b1;
    else
        tfr_complete <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dma_wr_done <= 1'b0;
    else if((tfr_rw == 1'b0) && (cur_state == State_tfr) && (tfr_complete == 1'b1) &&
              ((ds_table_r[1] == 1'b1) || (stop_at_block_gap_request == 1'b1)))
        dma_wr_done <= 1'b1;
    else
        dma_wr_done <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dma_rd_done <= 1'b0;
    else if((tfr_rw == 1'b1) && (cur_state == State_tfr) && (tfr_complete == 1'b1) &&
              ((ds_table_r[1] == 1'b1) || (stop_at_block_gap_request == 1'b1)))
        dma_rd_done <= 1'b1;
    else
        dma_rd_done <= 1'b0;
end

/*----------------------- DMA Write Data Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_arvalid <= 1'b0;
    else if(((cur_state == State_fds) && (fds_cnt == 2'd0)) ||
            ((cur_state == State_cadr) && (ds_table_r[5:4] == 2'b10) && (tfr_rw == 1'b0)))
        s_arvalid <= 1'b1;
    else if(s_arready == 1'b1)
        s_arvalid <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_araddr <= 32'h0;
    else if((cur_state == State_fds) && (fds_cnt == 2'd0) && (ds_table_ptr_en == 1'b1))
        s_araddr <= adma_system_address;
    else if(((cur_state == State_fds) && (fds_cnt == 2'd0)) ||
            ((cur_state == State_cadr) && (ds_table_r[5:4] == 2'b10) && (tfr_rw == 1'b0)))
        s_araddr <= ds_table_r[63:32];
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_arlen <= 16'd0;
    else if((cur_state == State_fds) && (fds_cnt == 2'd0))
        s_arlen <= 16'd7;
    else if((cur_state == State_cadr) && (ds_table_r[5:4] == 2'b10) && (tfr_rw == 1'b0))
        s_arlen <= ds_table_r[31:16] - 1'b1;
end

assign s_rready = (cur_state == State_tfr) ? dma_wr_rdy : 1'b1;
assign dma_wr_vld = (cur_state == State_tfr) ? s_rvalid : 1'b0;
assign dma_wr_data = s_rdata;

/*----------------------- DMA Read Data Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_awvalid <= 1'b0;
    else if((cur_state == State_cadr) && (ds_table_r[5:4] == 2'b10) && (tfr_rw == 1'b1))
        s_awvalid <= 1'b1;
    else if(s_awready == 1'b1)
        s_awvalid <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_awaddr <= 32'h0;
    else if((cur_state == State_cadr) && (ds_table_r[5:4] == 2'b10) && (tfr_rw == 1'b1))
        s_awaddr <= ds_table_r[63:32];
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_awlen <= 16'd0;
    else if((cur_state == State_cadr) && (ds_table_r[5:4] == 2'b10) && (tfr_rw == 1'b1))
        s_awlen <= ds_table_r[31:16] - 1'b1;
end

assign s_wdata = dma_rd_data;
assign s_wvalid = dma_rd_vld;
assign dma_rd_rdy =s_wready ;
//assign dma_rd_rdy = (cur_state == State_tfr) ? s_wready : 1'b0;

//Encryption end
endmodule
////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.              
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
