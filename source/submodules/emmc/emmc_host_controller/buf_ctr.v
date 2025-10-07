//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : buf_ctr.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-12-12 16:22:10 
// Last Modified  : 2024-12-12 16:52:01
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module buf_ctr#(
    parameter                       BUFFER_BLOCK_COUNT = 4,
    parameter                       BUFFER_BLOCK_SIZE  = 512,
    parameter                       FAMILY             = "TITANIUM",
    parameter                       RAM_STYLE          = "block_ram" 
)
(
//Global Signals
input                           rstn,
input                           rd_buf_rst,
input                           wr_buf_rst,
input                           emmc_clk,
input                           emmc_clk_en,
//Control Signals
input           [11:0]          bk_size_non_dma_clk,
input           [11:0]          bk_size_emmc_clk,
input                           dma_enable_emmc_clk,
input                           dma_enable_non_dma_clk,
output  wire                    buffer_write_enable_non_dma_clk,
output  wire                    buffer_read_enable_non_dma_clk,
output  wire                    buf_wr_transfer_rdy_emmc_clk,
output  wire                    buf_rd_transfer_rdy_emmc_clk,
//Non DMA Interface
input                           non_dma_clk,
input                           non_dma_wr_vld,
input           [31:0]          non_dma_wr_data,
output  wire                    non_dma_rd_vld,
output  wire    [31:0]          non_dma_rd_data,
output  wire                    non_dma_rd_eop,
input                           non_dma_rd_rdy,
//DMA Interface
input                           dma_clk,
input                           dma_wr_vld,
input           [31:0]          dma_wr_data,
output  wire                    dma_wr_rdy,
output  wire                    dma_rd_vld,
output  wire    [31:0]          dma_rd_data,
input                           dma_rd_rdy,
//Fifo Out Interface
output  wire    [31:0]          ff_tx_data,
output  wire                    ff_tx_vld,
input                           ff_tx_rdy,
//Fifo In Interface
input                           ff_rx_vld,
input           [31:0]          ff_rx_data,
input                           ff_rx_eop,
input                           ff_rx_err,
output  wire                    ff_rx_rdy,
input                           sw_reset_dat
//Status and  Error Signals
);
//Parameter Define 

//Register Define

//Wire Define
wire                            wr_buf_rstn;
wire                            rd_buf_rstn;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/
assign wr_buf_rstn = rstn && (wr_buf_rst == 1'b0);
assign rd_buf_rstn = rstn && (rd_buf_rst == 1'b0);

wr_buf_ctr#(
    .BUFFER_BLOCK_COUNT                 (BUFFER_BLOCK_COUNT                 ),
    .BUFFER_BLOCK_SIZE                  (BUFFER_BLOCK_SIZE                  ),
    .FAMILY                             (FAMILY                             ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u_wr_buf_ctr
(
//Global Signals
    .rstn                               (wr_buf_rstn                        ),
    .emmc_clk                           (emmc_clk                           ),
    .emmc_clk_en                        (emmc_clk_en                        ),
//Control Signals
    .bk_size_non_dma_clk                (bk_size_non_dma_clk                ),
    .bk_size_emmc_clk                   (bk_size_emmc_clk                   ),
    .dma_enable_emmc_clk                (dma_enable_emmc_clk                ),
    .buf_wr_transfer_rdy_emmc_clk       (buf_wr_transfer_rdy_emmc_clk       ),
    .buffer_write_enable_non_dma_clk    (buffer_write_enable_non_dma_clk    ),
//Non DMA Interface
    .non_dma_clk                        (non_dma_clk                        ),
    .non_dma_wr_vld                     (non_dma_wr_vld                     ),
    .non_dma_wr_data                    (non_dma_wr_data                    ),
//DMA Interface
    .dma_clk                            (dma_clk                            ),
    .dma_wr_vld                         (dma_wr_vld                         ),
    .dma_wr_data                        (dma_wr_data                        ),
    .dma_wr_rdy                         (dma_wr_rdy                         ),
//Fifo Out Interface
    .ff_tx_vld                          (ff_tx_vld                          ),
    .ff_tx_data                         ({ff_tx_data[7:0],ff_tx_data[15:8],ff_tx_data[23:16],ff_tx_data[31:24]}),
    .ff_tx_rdy                          (ff_tx_rdy                          ),
    .sw_reset_dat                       (sw_reset_dat                       )
//Status and  Error Signals
);

rd_buf_ctr#(
    .BUFFER_BLOCK_COUNT                 (BUFFER_BLOCK_COUNT                 ),
    .BUFFER_BLOCK_SIZE                  (BUFFER_BLOCK_SIZE                  ),
    .FAMILY                             (FAMILY                             ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u_rd_buf_ctr
(
//Global Signals
    .rstn                               (rd_buf_rstn                        ),
    .emmc_clk                           (emmc_clk                           ),
    .emmc_clk_en                        (emmc_clk_en                        ),
//Control Signals
    .bk_size_non_dma_clk                (bk_size_non_dma_clk                ),
    .bk_size_emmc_clk                   (bk_size_emmc_clk                   ),
    .dma_enable_emmc_clk                (dma_enable_emmc_clk                ),
    .dma_enable_non_dma_clk             (dma_enable_non_dma_clk             ),
    .buf_rd_transfer_rdy_emmc_clk       (buf_rd_transfer_rdy_emmc_clk       ),
    .buffer_read_enable_non_dma_clk     (buffer_read_enable_non_dma_clk     ),
//Non DMA Interface
    .non_dma_clk                        (non_dma_clk                        ),
    .non_dma_rd_vld                     (non_dma_rd_vld                     ),
    .non_dma_rd_data                    (non_dma_rd_data                    ),
    .non_dma_rd_eop                     (non_dma_rd_eop                     ),
    .non_dma_rd_rdy                     (non_dma_rd_rdy                     ),
//DMA Interface
    .dma_clk                            (dma_clk                            ),
    .dma_rd_vld                         (dma_rd_vld                         ),
    .dma_rd_data                        (dma_rd_data                        ),
    .dma_rd_rdy                         (dma_rd_rdy                         ),
//Fifo In Interface
    .ff_rx_vld                          (ff_rx_vld                          ),
    .ff_rx_data                         ({ff_rx_data[7:0], ff_rx_data[15:8], ff_rx_data[23:16], ff_rx_data[31:24]}),
    .ff_rx_eop                          (ff_rx_eop                          ),
    .ff_rx_err                          (ff_rx_err                          ),
    .ff_rx_rdy                          (ff_rx_rdy                          ),
    .sw_reset_dat                       (sw_reset_dat                       )
//Status and  Error Signals
);

//Encryption end
endmodule
