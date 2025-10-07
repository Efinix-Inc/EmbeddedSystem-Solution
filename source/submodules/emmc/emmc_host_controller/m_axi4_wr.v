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
module m_axi4_wr#(
    parameter                       AXI_DW = 32,
    parameter                       AXI_AW = 32
)
(
//Globle Signals
input                           rstn,
input                           clk,
//Master AXI4 Write Bus Interface
output  reg                     m_axi_awvalid,
output  reg     [AXI_AW-1:0]    m_axi_awaddr,
output  reg     [7:0]           m_axi_awlen,
output  wire    [2:0]           m_axi_awsize,
output  wire    [1:0]           m_axi_awburst,
output  wire    [2:0]           m_axi_awprot,
output  wire    [1:0]           m_axi_awlock,
output  wire    [3:0]           m_axi_awcache,
input                           m_axi_awready,
output  reg     [AXI_DW-1:0]    m_axi_wdata,
output  wire    [AXI_DW/8-1:0]  m_axi_wstrb,
output  reg                     m_axi_wlast,
output  reg                     m_axi_wvalid,
input                           m_axi_wready,
input           [1:0]           m_axi_bresp,
input                           m_axi_bvalid,
output  reg                     m_axi_bready,
//User Slave Write Bus Interface
input                           s_awvalid,
input           [AXI_AW-1:0]    s_awaddr,
input           [15:0]          s_awlen,//Total_Byte_Length = s_awlen[15:0] + 1.
output  reg                     s_awready,
input           [AXI_DW-1:0]    s_wdata,
input                           s_wvalid,
output  reg                     s_wready
);
// Parameter Define 
localparam AXLEN = 32;
localparam AXSIZE = AXI_DW/8;
localparam AXSIZE_WTH = clogb2(AXSIZE);

// Register Define
reg                             tfr_valid;
reg     [15-AXSIZE_WTH:0]       tfr_axlen;
reg     [7:0]                   burst_cnt;

// Wire Define
wire    [16+AXI_AW-1:0]         u1_data;
wire                            u1_wrreq;
wire                            u1_rdreq;
wire    [16+AXI_AW-1:0]         u1_q;
wire                            u1_empty;
wire                            u1_almfull;
wire    [AXI_DW-1:0]            u2_data;
wire                            u2_wrreq;
wire                            u2_rdreq;
wire    [AXI_DW-1:0]            u2_q;
wire                            u2_empty;
wire                            u2_almfull;
//
reg                write_busy;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/

/*----------------------- Fixed Singals Region ----------------------------*/
assign m_axi_awsize = AXSIZE_WTH;
assign m_axi_awburst = 2'b01;
assign m_axi_awprot = 3'b010;
assign m_axi_awlock = 2'b00;
assign m_axi_awcache = 4'b0011;
assign m_axi_wstrb = {AXI_DW/8{1'b1}};

/*----------------------- Write Address Channel FIFO Region ----------------------------*/
sfifo_d3_wx #(
    .WTH                        (16+AXI_AW                  )
)
u1
(
    .clk                        (clk                        ),
    .rstn                       (rstn                       ),
    .data                       (u1_data                    ),
    .wrreq                      (u1_wrreq                   ),
    .rdreq                      (u1_rdreq                   ),
    .q                          (u1_q                       ),
    .usedw                      (                           ),
    .full                       (                           ),
    .empty                      (u1_empty                   ),
    .almost_full                (u1_almfull                 ),
    .almost_empty               (                           )
);

assign u1_wrreq = (s_awvalid == 1'b1) && (s_awready == 1'b1);
assign u1_data = {s_awlen,s_awaddr};
assign u1_rdreq = (u1_empty == 1'b0) && (tfr_valid == 1'b0);
/*----------------------- Write Data Channel FIFO Region ----------------------------*/
sfifo_d3_wx #(
    .WTH                        (AXI_DW                     )
)
u2
(
    .clk                        (clk                        ),
    .rstn                       (rstn                       ),
    .data                       (u2_data                    ),
    .wrreq                      (u2_wrreq                   ),
    .rdreq                      (u2_rdreq                   ),
    .q                          (u2_q                       ),
    .usedw                      (                           ),
    .full                       (                           ),
    .empty                      (u2_empty                   ),
    .almost_full                (u2_almfull                 ),
    .almost_empty               (                           )
);

assign u2_wrreq = (s_wvalid == 1'b1) && (s_wready == 1'b1);
assign u2_data = s_wdata;
assign u2_rdreq = (u2_empty == 1'b0) && ((m_axi_wvalid == 1'b0) || (m_axi_wready == 1'b1)) &&
                    //((u1_rdreq == 1'b1) || (tfr_valid == 1'b1));
                    (tfr_valid == 1'b1 && !write_busy);


always@ (posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        write_busy <= 1'b0;
    else if (m_axi_wlast && m_axi_wvalid && m_axi_wready)
        write_busy <= 1'b1;
    else if (m_axi_awvalid && m_axi_awready)
        write_busy <= 1'b0;
end
/*----------------------- Common Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_valid <= 1'b0;
    else if(u1_rdreq == 1'b1)
        tfr_valid <= 1'b1;
    else if((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1) && (tfr_axlen < AXLEN))
        tfr_valid <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        tfr_axlen <= {16-AXSIZE_WTH{1'b0}};
    else if(u1_rdreq == 1'b1)
        tfr_axlen <= u1_q[AXI_AW+AXSIZE_WTH +: 16-AXSIZE_WTH];
    else if((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1) && (tfr_axlen < AXLEN))
        tfr_axlen <= {16-AXSIZE_WTH{1'b0}};
    else if((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1))
        tfr_axlen <= tfr_axlen - AXLEN;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        burst_cnt <= 8'h0;
    else if((u2_rdreq == 1'b1) && (burst_cnt == m_axi_awlen))
        burst_cnt <= 8'h0;
    else if(u2_rdreq == 1'b1)
        burst_cnt <= burst_cnt + 1'b1;
end

/*----------------------- Master AXI4 Write Bus Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_awvalid <= 1'b0;
    else if((u1_rdreq == 1'b1) || 
           ((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1) && (tfr_axlen >= AXLEN)))
        m_axi_awvalid <= 1'b1;
    else if(m_axi_awready == 1'b1)
        m_axi_awvalid <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_awaddr <= {AXI_AW{1'h0}};
    else if(u1_rdreq == 1'b1)
        m_axi_awaddr <= u1_q[0 +: AXI_AW];
    else if((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1))
        m_axi_awaddr <= m_axi_awaddr + AXLEN*AXSIZE;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_awlen <= 8'h0;
    else if((u1_rdreq == 1'b1) && (u1_q[AXI_AW+AXSIZE_WTH +: 16-AXSIZE_WTH] < AXLEN))
        m_axi_awlen <= u1_q[AXI_AW+AXSIZE_WTH +: 8];
    else if((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1) && (tfr_axlen < AXLEN))
        m_axi_awlen <= tfr_axlen[7 : 0];
    else if((u1_rdreq == 1'b1) || ((m_axi_bvalid == 1'b1) && (m_axi_bready == 1'b1)))
        m_axi_awlen <= AXLEN - 1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_wvalid <= 1'b0;
    else if(u2_rdreq == 1'b1)
        m_axi_wvalid <= 1'b1;
    else if(m_axi_wready == 1'b1)
        m_axi_wvalid <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_wdata <= {AXI_DW{1'b1}};
    else if(u2_rdreq == 1'b1)
        m_axi_wdata <= u2_q;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_wlast <= 1'b0;
    else if((u2_rdreq == 1'b1) && (burst_cnt == m_axi_awlen))
        m_axi_wlast <= 1'b1;
    else if(m_axi_wready == 1'b1)
        m_axi_wlast <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        m_axi_bready <= 1'b0;
    else if((m_axi_awvalid == 1'b1) && (m_axi_awready == 1'b1))
        m_axi_bready <= 1'b1;
    else if(m_axi_bvalid == 1'b1)
        m_axi_bready <= 1'b0;
end

/*----------------------- User Slave Read Bus Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_awready <= 1'b0;
    else if(u1_almfull == 1'b1)
        s_awready <= 1'b0;
    else
        s_awready <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        s_wready <= 1'b0;
    else if(u2_almfull == 1'b1)
        s_wready <= 1'b0;
    else
        s_wready <= 1'b1;
end

/*----------------------------------------------------------------------------------*\
                                 The function code
\*----------------------------------------------------------------------------------*/
function integer clogb2;
input [31:0] value;
begin
value = value - 1;
for (clogb2 = 0; value > 0; clogb2 = clogb2 + 1)
value = value >> 1;
end
endfunction

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
