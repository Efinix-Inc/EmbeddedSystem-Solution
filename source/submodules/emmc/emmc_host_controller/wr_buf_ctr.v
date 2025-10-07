//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : wr_buf_ctr.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-12-12 16:25:32 
// Last Modified  : 2025-06-10 15:40:23
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module wr_buf_ctr#(
    parameter                       BUFFER_BLOCK_COUNT = 32,//must be greater than or equal to 2
    parameter                       BUFFER_BLOCK_SIZE  = 512,
    parameter                       FAMILY             = "TITANIUM",
    parameter                       RAM_STYLE          = "block_ram" 
)
(
//Globle Signals
input                           rstn,
input                           emmc_clk,
input                           emmc_clk_en,
//Control Signals
input           [11:0]          bk_size_non_dma_clk,
input           [11:0]          bk_size_emmc_clk,
input                           dma_enable_emmc_clk,
output  reg                     buf_wr_transfer_rdy_emmc_clk,
output  reg                     buffer_write_enable_non_dma_clk,
//Non DMA Interface
input                           non_dma_clk,
input                           non_dma_wr_vld,
input           [31:0]          non_dma_wr_data,
//DMA Interface
input                           dma_clk,
input                           dma_wr_vld,
input           [31:0]          dma_wr_data,
output  reg                     dma_wr_rdy,
//Fifo Out Interface
output  wire                    ff_tx_vld,
output  wire    [31:0]          ff_tx_data,
input                           ff_tx_rdy,
input                           sw_reset_dat
//Status and  Error Signals
);
//Parameter Define 
localparam                      BLOCK_DTH   = (BUFFER_BLOCK_SIZE/4);
localparam                      BLOCK_DTH_W = $clog2(BLOCK_DTH);
localparam                      FIFO_DTH    = BUFFER_BLOCK_COUNT*BLOCK_DTH;
localparam                      FIFO_DTH_W  = $clog2(FIFO_DTH);

//Register Define
reg     [31:0]                  u1_data;
reg                             u1_wrreq;
reg     [9:0]                   buf_wptr;
reg     [9:0]                   buf_rptr;
reg     [7:0]                   buf_bk_cnt;

//Wire Define
wire                            u1_almfull;
wire                            u1_rdreq;
wire    [31:0]                  u1_q;
wire                            u1_empty;
wire    [FIFO_DTH_W:0]          u1_wrcnt;
wire    [31:0]                  u2_data;
wire                            u2_wrreq;
wire                            u2_rdreq;
wire    [31:0]                  u2_q;
wire                            u2_empty;
// wire    [BLOCK_DTH_W-1:0]       u2_wrcnt;
wire    [BLOCK_DTH_W:0]         u2_wrcnt;
wire    [31:0]                  u3_data;
wire                            u3_wrreq;
wire                            u3_rdreq;
wire    [31:0]                  u3_q;
wire                            u3_empty;
wire                            u3_almfull;
wire    [3:0]                   u3_wrcnt;
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
    .wr_datacount_o                     (u1_wrcnt                           ),
    .rst_busy                           (                                   ),
    .rd_datacount_o                     (                                   ),
    .a_rst_i                            (!rstn                              ),
    .a_wr_rst_i                         (1'b0                               ),
    .a_rd_rst_i                         (1'b0                               )
);

assign u1_rdreq = (u1_empty == 1'b0) && (ff_tx_rdy == 1'b1) && (emmc_clk_en == 1'b1);
assign ff_tx_data = u1_q;
assign ff_tx_vld = (u1_empty == 1'b0);

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        u1_data <= 32'h0;
    else if(u2_rdreq == 1'b1)
        u1_data <= u2_q;
    else if(u3_rdreq == 1'b1)
        u1_data <= u3_q;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        u1_wrreq <= 1'b0;
    else if((u2_rdreq == 1'b1) || (u3_rdreq == 1'b1))
        u1_wrreq <= 1'b1;
    else
        u1_wrreq <= 1'b0;
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
    .DEPTH                              (BLOCK_DTH                          ),
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
    .wr_clk_i                           (non_dma_clk                        ),
    .rd_clk_i                           (emmc_clk                           ),
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

assign u2_data = non_dma_wr_data;
assign u2_wrreq = non_dma_wr_vld;
assign u2_rdreq = (u1_almfull == 1'b0) && (u2_empty == 1'b0);

always @(posedge non_dma_clk or negedge rstn_non_dma_clk)
begin
    if(rstn_non_dma_clk == 1'b0)
        buffer_write_enable_non_dma_clk <= 1'h0;
    else if(u2_wrcnt == 0)
        buffer_write_enable_non_dma_clk <= 1'h1;
    else if(sw_reset_dat == 1'b1)
        buffer_write_enable_non_dma_clk <= 1'b0;
    else
        buffer_write_enable_non_dma_clk <= 1'b0;
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
    .wr_clk_i                           (dma_clk                            ),
    .rd_clk_i                           (emmc_clk                           ),
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

assign u3_data = dma_wr_data;
assign u3_wrreq = (dma_wr_vld == 1'b1) && (dma_wr_rdy == 1'b1);
assign u3_rdreq = (u1_almfull == 1'b0) && (u3_empty == 1'b0);
assign u3_almfull = (u3_wrcnt >= 4'd5);

always @(posedge dma_clk or negedge rstn_dma_clk)
begin
    if(rstn_dma_clk == 1'b0)
        dma_wr_rdy <= 1'h0;
    else if(u3_almfull == 1'b1)
        dma_wr_rdy <= 1'h0;
    else
        dma_wr_rdy <= 1'b1;
end

/*----------------------- Buffer Transfer Region ---------------------------*/
always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_wptr <= 10'h0;
    else if((u1_wrreq == 1'b1) && (buf_wptr == bk_size_emmc_clk[11:2]-1))
        buf_wptr <= 10'h0;
    else if(u1_wrreq == 1'b1)
        buf_wptr <= buf_wptr + 1'b1;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_rptr <= 10'h0;
    else if((u1_rdreq == 1'b1) && (buf_rptr == bk_size_emmc_clk[11:2]-1))
        buf_rptr <= 10'h0;
    else if(u1_rdreq == 1'b1)
        buf_rptr <= buf_rptr + 1'b1;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_bk_cnt <= 8'h0;
    else if(((u1_wrreq == 1'b1) && (buf_wptr == bk_size_emmc_clk[11:2]-1)) && 
            ((u1_rdreq == 1'b1) && (buf_rptr == bk_size_emmc_clk[11:2]-1)))
        buf_bk_cnt <= buf_bk_cnt;
    else if((u1_wrreq == 1'b1) && (buf_wptr == bk_size_emmc_clk[11:2]-1))
        buf_bk_cnt <= buf_bk_cnt + 1'b1;
    else if((u1_rdreq == 1'b1) && (buf_rptr == bk_size_emmc_clk[11:2]-1))
        buf_bk_cnt <= buf_bk_cnt - 1'b1;
end

always @(posedge emmc_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        buf_wr_transfer_rdy_emmc_clk <= 1'h0;
    else if(buf_bk_cnt == 0)
        buf_wr_transfer_rdy_emmc_clk <= 1'b0;
    else
        buf_wr_transfer_rdy_emmc_clk <= 1'h1;
end

//Encryption end
endmodule
