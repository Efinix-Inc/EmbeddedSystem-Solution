//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : rx_cdc_sync.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-11-07 10:39:53 
// Last Modified  : 2024-12-12 17:07:55
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/
 
`timescale 1ns / 1ps
 
module rx_cdc_sync#(
    parameter                       WTH       = 1,
    parameter                       DEPTH     = 512,  
    parameter                       FAMILY    = "TITANIUM", 
    parameter                       RAM_STYLE = "block_ram"
)
(
input                           rstn,
input                           s_clk,
input                           s_clk_en,
input                           m_clk,
input                           m_clk_en,
input           [WTH-1:0]       s_emmc_rx_dat,
output  reg                     m_emmc_rx_vld,
output  reg     [WTH-1:0]       m_emmc_rx_dat
);

//Parameter Define

//Register Define
 
//Wire Define
wire                            u1_wen;
wire    [WTH-1:0]               u1_wdata;
wire                            u1_almfull;
wire                            u1_ren;
wire    [WTH-1:0]               u1_rdata;
wire                            u1_empty;
wire                            u1_rst_busy;
wire                            rstn_m_clk;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                The main code
\*----------------------------------------------------------------------------------*/
//Asyn reset cross time
asynreset_deal u_mreset (.clk (m_clk ), .rstn_i (rstn ), .rstn_o (rstn_m_clk ));

 //Asynchronous FIFO
common_efx_fifo_wrapper#(
    .SYNC_CLK                           (0                                  ),
    .SYNC_STAGE                         (2                                  ),
    .DATA_WIDTH                         (WTH                                ),
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
    .DEPTH                              (DEPTH                              ),
    .FAMILY                             (FAMILY                             ),
    .ASYM_WIDTH_RATIO                   (4                                  ),
    .BYPASS_RESET_SYNC                  (0                                  ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u1_async_fifo
(
    .almost_full_o                      (u1_almfull                         ),
    .full_o                             (                                   ),
    .overflow_o                         (                                   ),
    .wr_ack_o                           (                                   ),
    .empty_o                            (u1_empty                           ),
    .almost_empty_o                     (                                   ),
    .underflow_o                        (                                   ),
    .rd_valid_o                         (                                   ),
    .rdata                              (u1_rdata                           ),
    .clk_i                              (1'b0                               ),
    .wr_clk_i                           (s_clk                              ),
    .rd_clk_i                           (m_clk                              ),
    .wr_en_i                            (u1_wen                             ),
    .rd_en_i                            (u1_ren                             ),
    .wdata                              (u1_wdata                           ),
    .wr_datacount_o                     (                                   ),
    .rst_busy                           (u1_rst_busy                        ),
    .rd_datacount_o                     (                                   ),
    .a_rst_i                            (!rstn                              ),
    .a_wr_rst_i                         (1'b0                               ),
    .a_rd_rst_i                         (1'b0                               )
);

assign u1_wen   = (u1_rst_busy == 1'b0) && (s_clk_en == 1'b1);
assign u1_wdata = s_emmc_rx_dat;
assign u1_ren   = (u1_empty == 1'b0) && (m_clk_en == 1'b1);

always @(posedge m_clk or negedge rstn_m_clk)
begin
    if(rstn_m_clk == 1'b0)
        m_emmc_rx_vld <= 1'b0;
    else if(u1_ren == 1'b1) 
        m_emmc_rx_vld <= 1'b1;
    else if(m_clk_en == 1'b1) 
        m_emmc_rx_vld <= 1'b0;
end

always @(posedge m_clk or negedge rstn_m_clk)
begin
    if(rstn_m_clk == 1'b0)
        m_emmc_rx_dat <= {WTH{1'b0}};
    else if(u1_ren == 1'b1)
        m_emmc_rx_dat <= u1_rdata;
end
 
//Encryption end
endmodule
