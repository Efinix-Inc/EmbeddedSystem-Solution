//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : rd_buf_ctr.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-12-12 16:30:52 
// Last Modified  : 2025-06-10 16:02:06
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module rd_buf_ctr#(
    parameter                       BUFFER_BLOCK_COUNT = 32,
    parameter                       BUFFER_BLOCK_SIZE  = 512,
    parameter                       FAMILY             = "TITANIUM",
    parameter                       RAM_STYLE          = "block_ram" 
)
(
//Global Signals
input                           rstn,
input                           emmc_clk,
input                           emmc_clk_en,
//Control Signals
input           [11:0]          bk_size_non_dma_clk,
input           [11:0]          bk_size_emmc_clk,
input                           dma_enable_emmc_clk,
input                           dma_enable_non_dma_clk,
output  reg                     buf_rd_transfer_rdy_emmc_clk,
output  reg                     buffer_read_enable_non_dma_clk,
//Non DMA Interface
input                           non_dma_clk,
output  reg                     non_dma_rd_vld,
output  reg     [31:0]          non_dma_rd_data,
output  reg                     non_dma_rd_eop,
input                           non_dma_rd_rdy,
//DMA Interface
input                           dma_clk,
output  reg                     dma_rd_vld,
output  reg     [31:0]          dma_rd_data,
input                           dma_rd_rdy,
//Fifo In Interface
input                           ff_rx_vld,
input           [31:0]          ff_rx_data,
input                           ff_rx_eop,
input                           ff_rx_err,
output  reg                     ff_rx_rdy,
input                           sw_reset_dat
//Status and  Error Signals
);
//Parameter Define
localparam                      FIFO_DTH   = BUFFER_BLOCK_COUNT*(BUFFER_BLOCK_SIZE/4);
localparam                      FIFO_DTH_W = $clog2(FIFO_DTH);

//Register Define
reg     [31:0]                  u2_data;
reg                             u2_wrreq;
reg     [31:0]                  u3_data;
reg                             u3_wrreq;
reg     [9:0]                   buf_wptr;
reg     [9:0]                   buf_rptr;
reg     [7:0]                   buf_bk_cnt;
reg     [9:0]                   non_dma_rptr;
reg     [7:0]                   non_dma_bk_cnt;

//Wire Define
wire    [31:0]                  u1_data;
wire                            u1_wrreq;
wire                            u1_rdreq;
wire    [31:0]                  u1_q;
wire                            u1_empty;
wire                            u1_almfull;
wire                            u2_rdreq;
wire    [31:0]                  u2_q;
wire                            u2_empty;
wire                            u2_almfull;
wire    [3:0]                   u2_wrcnt;
wire                            non_dma_u1_rdreq;
wire                            u3_rdreq;
wire    [31:0]                  u3_q;
wire                            u3_empty;
wire                            u3_almfull;
wire    [3:0]                   u3_wrcnt;
wire                            dma_u1_rdreq;
wire                            buf_wbk_en;
wire                            buf_rbk_en;
wire                            buf_wbk_en_non_dma_clk;
wire                            buf_rbk_en_non_dma_clk;
wire                            rstn_emmc_clk;
wire                            rstn_non_dma_clk;
wire                            rstn_dma_clk;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/
//--asyn reset cross clock
asynreset_deal u_reset0 (.clk (emmc_clk    ), .rstn_i (rstn ), .rstn_o (rstn_emmc_clk    ));
asynreset_deal u_reset1 (.clk (non_dma_clk ), .rstn_i (rstn ), .rstn_o (rstn_non_dma_clk ));
asynreset_deal u_reset2 (.clk (dma_clk     ), .rstn_i (rstn ), .rstn_o (rstn_dma_clk     ));

/*---------------------------- SYNC FIFO Region ----------------------------*/
common_efx_fifo_wrapper#(
    .SYNC_CLK                           (1                                  ),
    .SYNC_STAGE                         (2                                  ),
    .DATA_WIDTH                         (32                                 ),
    .MODE                               ("FWFT"                             ),
    .OUTPUT_REG                         (0                                  ),
    .PROG_FULL_ASSERT                   (                                   ),
    .PROGRAMMABLE_FULL                  ("NONE"                             ),
    .PROG_FULL_NEGATE                   (                                   ),
    .PROGRAMMABLE_EMPTY                 ("NONE"                             ),
    .PROG_EMPTY_ASSERT                  (0                                  ),
    .PROG_EMPTY_NEGATE                  (0                                  ),
    .OPTIONAL_FLAGS                     (1                                  ),
    .PIPELINE_REG                       (1                                  ),
    .DEPTH                              (FIFO_DTH                           ),
    .FAMILY                             (FAMILY                             ),
    .ASYM_WIDTH_RATIO                   (4                                  ),
    .BYPASS_RESET_SYNC                  (0                                  ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u1_sync_fifo
(
    .almost_full_o                      (u1_almfull                         ),
    .full_o                             (                                   ),
    .overflow_o                         (                                   ),
    .wr_ack_o                           (                                   ),
    .empty_o                            (u1_empty                           ),
    .almost_empty_o                     (                                   ),
    .underflow_o                        (                                   ),
    .rd_valid_o                         (                                   ),
    .rdata                              (u1_q                               ),
    .clk_i                              (emmc_clk                           ),
    .wr_clk_i                           (1'b0                               ),
    .rd_clk_i                           (1'b0                               ),
    .wr_en_i                            (u1_wrreq                           ),
    .rd_en_i                            (u1_rdreq                           ),
    .wdata                              (u1_data                            ),
    .wr_datacount_o                     (                                   ),
    .rst_busy                           (                                   ),
    .rd_datacount_o                     (                                   ),
    .a_rst_i                            (!rstn                              ),
    .a_wr_rst_i                         (1'b0                               ),
    .a_rd_rst_i                         (1'b0                               )
);

assign u1_data = ff_rx_data;
assign u1_wrreq = (ff_rx_vld == 1'b1) && (emmc_clk_en == 1'b1);
assign u1_rdreq = (dma_u1_rdreq == 1'b1) || (non_dma_u1_rdreq == 1'b1);

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        ff_rx_rdy <= 1'b0;
    else if(emmc_clk_en == 1'b0)
        ff_rx_rdy <= ff_rx_rdy;
    else if(u1_almfull == 1'b1)
        ff_rx_rdy <= 1'b0;
    else
        ff_rx_rdy <= 1'b1;
end

/*------------------------- Non DMA FIFO Region ----------------------------*/
common_efx_fifo_wrapper#(
    .SYNC_CLK                           (0                                  ),
    .SYNC_STAGE                         (2                                  ),
    .DATA_WIDTH                         (32                                 ),
    .MODE                               ("FWFT"                             ),
    .OUTPUT_REG                         (0                                  ),
    .PROG_FULL_ASSERT                   (                                   ),
    .PROGRAMMABLE_FULL                  ("NONE"                             ),
    .PROG_FULL_NEGATE                   (                                   ),
    .PROGRAMMABLE_EMPTY                 ("NONE"                             ),
    .PROG_EMPTY_ASSERT                  (0                                  ),
    .PROG_EMPTY_NEGATE                  (0                                  ),
    .OPTIONAL_FLAGS                     (1                                  ),
    .PIPELINE_REG                       (1                                  ),
    .DEPTH                              (8                                  ),
    .FAMILY                             (FAMILY                             ),
    .ASYM_WIDTH_RATIO                   (4                                  ),
    .BYPASS_RESET_SYNC                  (0                                  ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u2_non_dma_fifo
(
    .almost_full_o                      (                                   ),
    .full_o                             (                                   ),
    .overflow_o                         (                                   ), 
    .wr_ack_o                           (                                   ),
    .empty_o                            (u2_empty                           ),
    .almost_empty_o                     (                                   ),
    .underflow_o                        (                                   ),
    .rd_valid_o                         (                                   ),
    .rdata                              (u2_q                               ),
    .clk_i                              (1'b0                               ),
    .wr_clk_i                           (emmc_clk                           ),
    .rd_clk_i                           (non_dma_clk                        ),
    .wr_en_i                            (u2_wrreq                           ),
    .rd_en_i                            (u2_rdreq                           ),
    .wdata                              (u2_data                            ),
    .wr_datacount_o                     (u2_wrcnt                           ),
    .rst_busy                           (                                   ),
    .rd_datacount_o                     (                                   ),
    .a_rst_i                            (!rstn                              ),
    .a_wr_rst_i                         (1'b0                               ),
    .a_rd_rst_i                         (1'b0                               )
);

assign u2_rdreq = (u2_empty == 1'b0) && ((non_dma_rd_vld == 1'b0) || (non_dma_rd_rdy == 1'b1));
assign u2_almfull = (u2_wrcnt >= 5);
assign non_dma_u1_rdreq = (dma_enable_emmc_clk == 1'b0) && (u2_almfull == 1'b0) && (u1_empty == 1'b0);

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        u2_data <= 32'h0;
    else if(non_dma_u1_rdreq == 1'b1)
        u2_data <= u1_q;
    else
        u2_data <= 32'h0;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        u2_wrreq <= 1'b0;
    else if(non_dma_u1_rdreq == 1'b1)
        u2_wrreq <= 1'b1;
    else
        u2_wrreq <= 1'b0;
end

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        non_dma_rd_vld <= 1'b0;
    else if(u2_rdreq == 1'b1)
        non_dma_rd_vld <= 1'b1;
    else if(non_dma_rd_rdy == 1'b1)
        non_dma_rd_vld <= 1'b0;
end

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        non_dma_rd_data <= 32'h0;
    else if(u2_rdreq == 1'b1)
        non_dma_rd_data <= u2_q;
end

/*----------------------------- DMA FIFO Region ----------------------------*/
common_efx_fifo_wrapper#(
    .SYNC_CLK                           (0                                  ),
    .SYNC_STAGE                         (2                                  ),
    .DATA_WIDTH                         (32                                 ),
    .MODE                               ("FWFT"                             ),
    .OUTPUT_REG                         (0                                  ),
    .PROG_FULL_ASSERT                   (                                   ),
    .PROGRAMMABLE_FULL                  ("NONE"                             ),
    .PROG_FULL_NEGATE                   (                                   ),
    .PROGRAMMABLE_EMPTY                 ("NONE"                             ),
    .PROG_EMPTY_ASSERT                  (0                                  ),
    .PROG_EMPTY_NEGATE                  (0                                  ),
    .OPTIONAL_FLAGS                     (1                                  ),
    .PIPELINE_REG                       (1                                  ),
    .DEPTH                              (8                                  ),
    .FAMILY                             (FAMILY                             ),
    .ASYM_WIDTH_RATIO                   (4                                  ),
    .BYPASS_RESET_SYNC                  (0                                  ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u3_dma_fifo
(
    .almost_full_o                      (                                   ),
    .full_o                             (                                   ),
    .overflow_o                         (                                   ),
    .wr_ack_o                           (                                   ),
    .empty_o                            (u3_empty                           ),
    .almost_empty_o                     (                                   ),
    .underflow_o                        (                                   ),
    .rd_valid_o                         (                                   ),
    .rdata                              (u3_q                               ),
    .clk_i                              (1'b0                               ),
    .wr_clk_i                           (emmc_clk                           ),
    .rd_clk_i                           (dma_clk                            ),
    .wr_en_i                            (u3_wrreq                           ),
    .rd_en_i                            (u3_rdreq                           ),
    .wdata                              (u3_data                            ),
    .wr_datacount_o                     (u3_wrcnt                           ),
    .rst_busy                           (                                   ),
    .rd_datacount_o                     (                                   ),
    .a_rst_i                            (!rstn                              ),
    .a_wr_rst_i                         (1'b0                               ),
    .a_rd_rst_i                         (1'b0                               )
);

pulse_domain_cross_sr u1_wrreq_cross(emmc_clk,rstn_emmc_clk,1'b1,non_dma_clk,rstn_non_dma_clk,buf_wbk_en,buf_wbk_en_non_dma_clk);
assign u3_rdreq = (u3_empty == 1'b0) && ((dma_rd_vld == 1'b0) || (dma_rd_rdy == 1'b1));
assign u3_almfull = (u3_wrcnt >= 5);
assign dma_u1_rdreq = (dma_enable_emmc_clk == 1'b1) && (u3_almfull == 1'b0) && (u1_empty == 1'b0);

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        u3_data <= 32'h0;
    else if(dma_u1_rdreq == 1'b1)
        u3_data <= u1_q;
    else
        u3_data <= 32'h0;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        u3_wrreq <= 1'b0;
    else if(dma_u1_rdreq == 1'b1)
        u3_wrreq <= 1'b1;
    else
        u3_wrreq <= 1'b0;
end

always @(posedge dma_clk or negedge rstn_dma_clk)
begin
    if(rstn_dma_clk == 1'b0)
        dma_rd_vld <= 1'b0;
    else if(u3_rdreq == 1'b1)
        dma_rd_vld <= 1'b1;
    else if(dma_rd_rdy == 1'b1)
        dma_rd_vld <= 1'b0;
end

always @(posedge dma_clk or negedge rstn_dma_clk)
begin
    if(rstn_dma_clk == 1'b0)
        dma_rd_data <= 32'h0;
    else if(u3_rdreq == 1'b1)
        dma_rd_data <= u3_q;
end

/*------------------------- Buffer Transfer Region -------------------------*/
assign buf_wbk_en = (u1_wrreq == 1'b1) && (buf_wptr == bk_size_emmc_clk[11:2]-1);
assign buf_rbk_en = (u1_rdreq == 1'b1) && (buf_rptr == bk_size_emmc_clk[11:2]-1);

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_wptr <= 10'h0;
    else if(buf_wbk_en == 1'b1)
        buf_wptr <= 10'h0;
    else if(u1_wrreq == 1'b1)
        buf_wptr <= buf_wptr + 1'b1;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_rptr <= 10'h0;
    else if(buf_rbk_en == 1'b1)
        buf_rptr <= 10'h0;
    else if(u1_rdreq == 1'b1)
        buf_rptr <= buf_rptr + 1'b1;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_bk_cnt <= 8'h0;
    else if((buf_wbk_en == 1'b1) && (buf_rbk_en == 1'b1))
        buf_bk_cnt <= buf_bk_cnt;
    else if(buf_wbk_en == 1'b1)
        buf_bk_cnt <= buf_bk_cnt + 1'b1;
    else if(buf_rbk_en == 1'b1)
        buf_bk_cnt <= buf_bk_cnt - 1'b1;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_rd_transfer_rdy_emmc_clk <= 1'h1;
    // else if(buf_bk_cnt < BUFFER_BLOCK_COUNT)
    else if(buf_bk_cnt < BUFFER_BLOCK_COUNT-1)
        buf_rd_transfer_rdy_emmc_clk <= 1'b1;
    else
        buf_rd_transfer_rdy_emmc_clk <= 1'h0;
end

/*----------------------- Non DMA Data Transfer Region ---------------------*/
assign buf_rbk_en_non_dma_clk = (non_dma_rd_vld == 1'b1) && (non_dma_rd_rdy == 1'b1) && (non_dma_rptr == bk_size_non_dma_clk[11:2]-1);

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        non_dma_rptr <= 10'h0;
    else if((non_dma_rd_vld == 1'b1) && (non_dma_rd_rdy == 1'b1) && (non_dma_rptr == bk_size_non_dma_clk[11:2]-1))
        non_dma_rptr <= 10'h0;
    else if((non_dma_rd_vld == 1'b1) && (non_dma_rd_rdy == 1'b1))
        non_dma_rptr <= non_dma_rptr + 1'b1;
end

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        non_dma_bk_cnt <= 8'h0;
    else if((dma_enable_non_dma_clk == 1'b0) && (buf_wbk_en_non_dma_clk == 1'b1) && (buf_rbk_en_non_dma_clk == 1'b1))
        non_dma_bk_cnt <= non_dma_bk_cnt;
    else if((dma_enable_non_dma_clk == 1'b0) && (buf_wbk_en_non_dma_clk == 1'b1))
        non_dma_bk_cnt <= non_dma_bk_cnt + 1'b1;
    else if(buf_rbk_en_non_dma_clk == 1'b1)
        non_dma_bk_cnt <= non_dma_bk_cnt - 1'b1;
end

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        non_dma_rd_eop <= 1'b0;
    else if(buf_rbk_en_non_dma_clk == 1'b1)
        non_dma_rd_eop <= 1'b1;
    else
        non_dma_rd_eop <= 1'b0;
end

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        buffer_read_enable_non_dma_clk <= 1'h0;
    else if(non_dma_bk_cnt == 0)
        buffer_read_enable_non_dma_clk <= 1'h0;
    else if (sw_reset_dat == 1'b1)
        buffer_read_enable_non_dma_clk <= 1'b0;
    else
        buffer_read_enable_non_dma_clk <= 1'b1;
end

//Encryption end
endmodule
