
`timescale 1 ns / 1 ns

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

//MIPI DPHY RX0: CSI RX Interface
   input                               mipi_dphy_rx_inst1_WORD_CLKOUT_HS,
   output                              mipi_dphy_rx_inst1_FORCE_RX_MODE,
   input                               mipi_dphy_rx_inst1_ERR_CONTENTION_LP0,
   input                               mipi_dphy_rx_inst1_ERR_CONTENTION_LP1,
   input                               mipi_dphy_rx_inst1_ERR_CONTROL_LAN0,
   input                               mipi_dphy_rx_inst1_ERR_CONTROL_LAN1,
   input                               mipi_dphy_rx_inst1_ERR_ESC_LAN0,
   input                               mipi_dphy_rx_inst1_ERR_ESC_LAN1,
   input                               mipi_dphy_rx_inst1_ERR_SOT_HS_LAN0,
   input                               mipi_dphy_rx_inst1_ERR_SOT_HS_LAN1,
   input                               mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN0,
   input                               mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN1,
   input                               mipi_dphy_rx_inst1_LP_CLK,
   input                               mipi_dphy_rx_inst1_RX_ACTIVE_HS_LAN0,
   input                               mipi_dphy_rx_inst1_RX_ACTIVE_HS_LAN1,
   input                               mipi_dphy_rx_inst1_RX_CLK_ACTIVE_HS,
   input                               mipi_dphy_rx_inst1_ESC_LAN0_CLK,
   input                               mipi_dphy_rx_inst1_ESC_LAN1_CLK,
   input [7:0]                         mipi_dphy_rx_inst1_RX_DATA_ESC,
   input [CSI_RX_DATA_WIDTH_LANE-1:0]  mipi_dphy_rx_inst1_RX_DATA_HS_LAN0,
   input [CSI_RX_DATA_WIDTH_LANE-1:0]  mipi_dphy_rx_inst1_RX_DATA_HS_LAN1,
   input                               mipi_dphy_rx_inst1_RX_LPDT_ESC,
   input                               mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN0,
   input                               mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN1,
   input                               mipi_dphy_rx_inst1_RX_SYNC_HS_LAN0,
   input                               mipi_dphy_rx_inst1_RX_SYNC_HS_LAN1,
   input [3:0]                         mipi_dphy_rx_inst1_RX_TRIGGER_ESC,
   input                               mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_CLK_NOT,
   input                               mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN0,
   input                               mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN1,
   input                               mipi_dphy_rx_inst1_RX_ULPS_CLK_NOT,
   input                               mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN0,
   input                               mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN1,
   input                               mipi_dphy_rx_inst1_RX_VALID_ESC,
   input                               mipi_dphy_rx_inst1_RX_VALID_HS_LAN0,
   input                               mipi_dphy_rx_inst1_RX_VALID_HS_LAN1,
   input                               mipi_dphy_rx_inst1_STOPSTATE_CLK,
   input                               mipi_dphy_rx_inst1_STOPSTATE_LAN0,
   input                               mipi_dphy_rx_inst1_STOPSTATE_LAN1,
   output                              mipi_dphy_rx_inst1_RESET_N,             // Active Low Reset for MIPI Control 
   output                              mipi_dphy_rx_inst1_RST0_N               // Active Low Reset for MIPI Control 
);
///////////////////////////////////////////////////////////////////

// Resolution of Display
localparam FRAME_WIDTH  = (DISPLAY_MODE == "1920x1080_60Hz")? 1920 :
                         (DISPLAY_MODE == "1280x720_60Hz") ? 1280 :
                                                             640  ;

localparam FRAME_HEIGHT = (DISPLAY_MODE == "1920x1080_60Hz") ? 1080:
                         (DISPLAY_MODE == "1280x720_60Hz")  ? 720 :
                                                              480 ; 

// CSI controllers output interface port 
localparam  CSI_RX_NUM_DATA_LANE        = 2;
localparam  CSI_RX_DATA_WIDTH_LANE      = 16;
localparam  CAM_PIXEL_RX_DATAWIDTH      = 10;   //RAW10, RAW12
localparam  CAM_PIXEL_RX_MEM_DATAWIDTH  = 8;
localparam  CSI_RX_PIXEL_PER_CLK        = 4;
localparam  CSI_RX_PIXEL_DATAWIDTH      = CAM_PIXEL_RX_MEM_DATAWIDTH;
localparam  CSI_RX_TOTAL_DATAWIDTH      = CSI_RX_PIXEL_DATAWIDTH * CSI_RX_PIXEL_PER_CLK;

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

// Wire for MIPI RX <=> PiCam
//wire         w_rx_valid;
//wire         w_rx_vs;
//wire         w_rx_hs;
//wire [1:0]   w_rx_vc;
//wire [3:0]   w_rx_count;
//wire [5:0]   w_rx_type;
//wire [17:0]  w_rx_error;
wire [63:0]  w_rx_data;
wire         w_rx_out_de;
wire         w_rx_out_vs;
wire         w_rx_out_hs;
wire [5:0]   rx_out_dt;

wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0] w_rx_out_data_00;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0] w_rx_out_data_01;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0] w_rx_out_data_10;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0] w_rx_out_data_11;   


/**************************************************
 *
 * cam_csi_rx_controllers Instantiation
 * 
**************************************************/ 
cam_csi_rx_controllers #(
    .NUM_CHANNEL            ( 1                          ),
    .NUM_RX_PER_CHANNEL     ( CSI_RX_NUM_DATA_LANE       ),
    .DATAWIDTH_PER_CHANNEL  ( CSI_RX_DATA_WIDTH_LANE     ),
    .PIXEL_RX_DATAWIDTH     ( CAM_PIXEL_RX_DATAWIDTH     ),  // RAW10, RAW12
    .PIXEL_OUT_DATAWIDTH    ( CAM_PIXEL_RX_MEM_DATAWIDTH )   // DATAWIDTH will be store to Memory
) inst_csi_rx_controllersn(

    .rstn                   ( rstn                    ),
    .clk                    ( i_pixel_clk             ),
    .clk_pixel              ( i_pixel_clk             ),

    // DPHY interface port
    .clk_byte_HS            ( mipi_dphy_rx_inst1_WORD_CLKOUT_HS   ),
    .reset_byte_HS_n        ( mipi_dphy_rx_inst1_RST0_N           ),
    .resetb_rx              ( mipi_dphy_rx_inst1_RESET_N          ),
    .RxDataHS0              ( mipi_dphy_rx_inst1_RX_DATA_HS_LAN0  ),  // full 16 bit
    .RxDataHS1              ( mipi_dphy_rx_inst1_RX_DATA_HS_LAN1  ),
    .RxValidHS0             ( mipi_dphy_rx_inst1_RX_VALID_HS_LAN0 ),
    .RxValidHS1             ( mipi_dphy_rx_inst1_RX_VALID_HS_LAN1 ),

    .RxSyncHS               ( {mipi_dphy_rx_inst1_RX_SYNC_HS_LAN1,mipi_dphy_rx_inst1_RX_SYNC_HS_LAN0                 }),
    .RxUlpsClkNot           ( {mipi_dphy_rx_inst1_RX_ULPS_CLK_NOT                                                    }),
    .RxUlpsActiveClkNot     ( {mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_CLK_NOT                                             }),
    .RxErrEsc               ( {mipi_dphy_rx_inst1_ERR_ESC_LAN1,mipi_dphy_rx_inst1_ERR_ESC_LAN0                       }),
    .RxErrControl           ( {mipi_dphy_rx_inst1_ERR_CONTROL_LAN1,mipi_dphy_rx_inst1_ERR_CONTROL_LAN0               }),
    .RxErrSotSyncHS         ( {mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN1,mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN0       }),
    .RxUlpsEsc              ( {mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN1,mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN0               }),
    .RxUlpsActiveNot        ( {mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN1,mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN0 }),
    .RxSkewCalHS            ( {mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN1,mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN0         }),
    .RxStopState            ( {mipi_dphy_rx_inst1_STOPSTATE_LAN1,mipi_dphy_rx_inst1_STOPSTATE_LAN0                   }),

    // CSI controller ouptut interface port
    .rx_out_de              ( w_rx_out_de      ),
    .rx_out_vs              ( w_rx_out_vs      ),
    .rx_out_hs              ( w_rx_out_hs      ),
    .rx_out_data_00         ( w_rx_out_data_00 ),
    .rx_out_data_01         ( w_rx_out_data_01 ),
    .rx_out_data_10         ( w_rx_out_data_10 ),
    .rx_out_data_11         ( w_rx_out_data_11 ),
    .rx_out_dt              ( rx_out_dt        )
);

// Assignment for Picam data
//assign  w_rx_valid      = w_rx_out_de;
//assign  w_rx_vs         = w_rx_out_vs;
//assign  w_rx_hs         = w_rx_out_hs;
//assign  w_rx_type       = rx_out_dt;
assign  w_rx_data       = {24'h0, w_rx_out_data_11[7:0], 2'b0, w_rx_out_data_10[7:0], 2'b0, w_rx_out_data_01[7:0], 2'b0, w_rx_out_data_00[7:0], 2'b0};                                        



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
   .mipi_pclk                              ( i_pixel_clk       ),
   .rst_n                                  ( rstn              ),
   .mipi_cam_data                          ( w_rx_data         ),
   .mipi_cam_valid                         ( w_rx_out_de        ),
   .mipi_cam_vs                            ( w_rx_out_vs           ),
   .mipi_cam_hs                            ( w_rx_out_hs           ),
   .mipi_cam_type                          ( rx_out_dt         ),

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



