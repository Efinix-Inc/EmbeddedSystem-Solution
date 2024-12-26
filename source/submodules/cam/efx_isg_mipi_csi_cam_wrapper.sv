
`timescale 1 ns / 1 ns
`include "mipi_parameter.vh"

module efx_isg_mipi_csi_cam_wrapper #(
   parameter FAMILY            = "TITANIUM",
   parameter DISPLAY_MODE      = "1280x720_60Hz",
   parameter MIPI_FRAME_WIDTH  = 1920,  // camera input Width
   parameter MIPI_FRAME_HEIGHT = 1080,  // camera input Height  
   parameter APB3_DATA_WIDTH   = 32,
   parameter APB3_ADDR_WIDTH   = 16

) (
   input   rstn, 
   output  mipi_rstn,
   input   i_pixel_clk, 
   input   io_peripheralClk,
   input   io_peripheralReset,

   //DMA
   input          cam_dma_wready,
   output         cam_dma_wvalid,
   output         cam_dma_wlast,
   output  [63:0] cam_dma_wdata,

   //APB3 Standard Signal
   input  [APB3_ADDR_WIDTH-1:0]  PADDR,
   input                         PSEL,
   input                         PENABLE,
   output                        PREADY,
   input                         PWRITE,
   input  [APB3_DATA_WIDTH-1:0]  PWDATA,
   output [APB3_DATA_WIDTH-1:0]  PRDATA,
   output                        PSLVERROR,

   //MIPI Control
   output [3:0]        mipi_inst1_VC_ENA,
   output [1:0]        mipi_inst1_LANES,
   output              mipi_inst1_CLEAR,
   output              mipi_inst1_DPHY_RSTN,    // Active Low Reset for MIPI Control (DPHY)
   output              mipi_inst1_RSTN,         // Active Low Reset for MIPI Control (CSI-2)
   //MIPI Video input
   input [3:0]         mipi_inst1_HSYNC,
   input [3:0]         mipi_inst1_VSYNC,
   input [3:0]         mipi_inst1_CNT,
   input               mipi_inst1_VALID,
   input [5:0]         mipi_inst1_TYPE,
   input [63:0]        mipi_inst1_DATA,
   input [1:0]         mipi_inst1_VC,
   input [17:0]        mipi_inst1_ERR
);
///////////////////////////////////////////////////////////////////

// Resolution of Display
localparam FRAME_WIDTH  = (DISPLAY_MODE == "1920x1080_60Hz")? 1920 :
                         (DISPLAY_MODE == "1280x720_60Hz") ? 1280 :
                                                             640  ;

localparam FRAME_HEIGHT = (DISPLAY_MODE == "1920x1080_60Hz") ? 1080:
                         (DISPLAY_MODE == "1280x720_60Hz")  ? 720 :
                                                              480 ; 


///////////////////////////////////////////////////////////////////

//RISC-V slave control & Debug
wire   [15:0]                 rgb_control;
wire                          trigger_capture_frame;
wire                          continuous_capture_frame;
wire                          rgb_gray;
wire                          cam_dma_init_done;
wire [APB3_DATA_WIDTH-1:0]    w_data_out [0:4];

//Debug Cam Signal
wire [31:0]                   frames_per_second;
wire [31:0]                   debug_cam_dma_fifo_rcount;
wire [31:0]                   debug_cam_dma_fifo_wcount;
wire [31:0]                   debug_cam_dma_fifo_status; 


// MIPI Rx settings for Trion device
assign mipi_inst1_DPHY_RSTN         = 1'b1;
assign mipi_inst1_RSTN              = 1'b1;
assign mipi_inst1_VC_ENA[`MIPI_VC0] = 1'b1;
assign mipi_inst1_VC_ENA[`MIPI_VC1] = 1'b0;
assign mipi_inst1_VC_ENA[`MIPI_VC2] = 1'b0;
assign mipi_inst1_VC_ENA[`MIPI_VC3] = 1'b0;
assign mipi_inst1_CLEAR             = 1'b0;
assign mipi_inst1_LANES             = 2'b01;



/**************************************************
 *
 * cam_picam_v2 Instantiation
 * 
**************************************************/ 
cam_picam_v2 # (
   .FAMILY                                 ( FAMILY           ),
   .MIPI_FRAME_WIDTH                       ( MIPI_FRAME_WIDTH ),             //Input frame resolution from MIPI
   .MIPI_FRAME_HEIGHT                      ( MIPI_FRAME_HEIGHT ),            //Input frame resolution from MIPI
   .FRAME_WIDTH                            ( FRAME_WIDTH ),                  //Output frame resolution to external memory
   .FRAME_HEIGHT                           ( FRAME_HEIGHT ),                 //Output frame resolution to external memory
   .DMA_TRANSFER_LENGTH                    ( (FRAME_WIDTH*FRAME_HEIGHT )/2 ), //2PPC
   .MIPI_PCLK_CLK_RATE                     ( 32'd100_000_000 )               // as mipi_pclk is 100MHz
 ) u_cam (
   .mipi_cam_error                         ( mipi_inst1_ERR      ),
   .mipi_cam_vc                            ( mipi_inst1_VC       ),
   .mipi_cam_count                         ( mipi_inst1_CNT      ),
   .mipi_pclk                              ( i_pixel_clk         ),
   .rst_n                                  ( rstn                ),
   .mipi_cam_data                          ( mipi_inst1_DATA     ),
   .mipi_cam_valid                         ( mipi_inst1_VALID    ),
   .mipi_cam_vs                            ( mipi_inst1_VSYNC[0] ),
   .mipi_cam_hs                            ( mipi_inst1_HSYNC[0] ),
   .mipi_cam_type                          ( mipi_inst1_TYPE     ),

   .cam_dma_wready                         ( cam_dma_wready ),
   .cam_dma_wvalid                         ( cam_dma_wvalid ),
   .cam_dma_wlast                          ( cam_dma_wlast ),
   .cam_dma_wdata                          ( cam_dma_wdata ),

   .rgb_control                            ( rgb_control ),
   .trigger_capture_frame                  ( trigger_capture_frame ),
   .continuous_capture_frame               ( continuous_capture_frame ),
   .rgb_gray                               ( rgb_gray ),
   .cam_dma_init_done                      ( cam_dma_init_done ),
   .frames_per_second                      ( frames_per_second ),
   .debug_cam_dma_fifo_rcount              ( debug_cam_dma_fifo_rcount ),
   .debug_cam_dma_fifo_wcount              ( debug_cam_dma_fifo_wcount ),
   .debug_cam_dma_fifo_status              ( debug_cam_dma_fifo_status )
);


// APB3 control for Camera related Signal
common_apb3 #(
   .ADDR_WIDTH   (APB3_ADDR_WIDTH),
   .DATA_WIDTH   (APB3_DATA_WIDTH),
   .SW_MODULE    (1 ),
   .NUM_WR_REG   (5 ),
   .NUM_RD_REG   (5 )
) u_apb3_cam (
    .clk                               ( io_peripheralClk   ),
    .cross_clk                         ( i_pixel_clk        ),
    .resetn                            ( ~io_peripheralReset ),
    .data_out                          ( w_data_out ),
    .data_in   /* Input Info Data  */  ({32'hABCD_5678, debug_cam_dma_fifo_status, debug_cam_dma_fifo_rcount, debug_cam_dma_fifo_wcount, frames_per_second}),
  
    // Apb 3 interface
    .PADDR                             ( PADDR         ),
    .PSEL                              ( PSEL          ),
    .PENABLE                           ( PENABLE       ),
    .PREADY                            ( PREADY        ),
    .PRDATA                            ( PRDATA        ),
    .PWRITE                            ( PWRITE        ),
    .PWDATA                            ( PWDATA        ),
    .PSLVERROR                         ( PSLVERROR     )
);


// Output Control Signals
assign rgb_control              = w_data_out[0][15:0];
assign mipi_rstn                = w_data_out[1][0];
assign trigger_capture_frame    = w_data_out[2][0];
assign continuous_capture_frame = w_data_out[2][1];
assign rgb_gray                 = w_data_out[3][0];
assign cam_dma_init_done        = w_data_out[4][0];


endmodule



