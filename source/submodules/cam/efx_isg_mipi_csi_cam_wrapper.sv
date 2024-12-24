
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
     
   //MIPI RX - Camera
    input               cam_ck_LP_P_IN,
    input               cam_ck_LP_N_IN,
    output              cam_ck_HS_TERM,
    output              cam_ck_HS_ENA,
    input               cam_ck_CLKOUT,

    input      [7:0]    cam_d0_HS_IN,
    input      [7:0]    cam_d0_HS_IN_1,
    input      [7:0]    cam_d0_HS_IN_2,
    input      [7:0]    cam_d0_HS_IN_3,
    input               cam_d0_LP_P_IN,
    input               cam_d0_LP_N_IN,
    output              cam_d0_HS_TERM,
    output              cam_d0_HS_ENA,
    output              cam_d0_RST,
    output              cam_d0_FIFO_RD,
    input               cam_d0_FIFO_EMPTY,

    input      [7:0]    cam_d1_HS_IN,
    input      [7:0]    cam_d1_HS_IN_1,
    input      [7:0]    cam_d1_HS_IN_2,
    input      [7:0]    cam_d1_HS_IN_3,
    input               cam_d1_LP_P_IN,
    input               cam_d1_LP_N_IN,
    output              cam_d1_HS_TERM,
    output              cam_d1_HS_ENA,
    output              cam_d1_RST,
    output              cam_d1_FIFO_RD,
    input               cam_d1_FIFO_EMPTY
);

// Resolution of Display
localparam FRAME_WIDTH  = (DISPLAY_MODE == "1920x1080_60Hz")? 1920 :
                         (DISPLAY_MODE == "1280x720_60Hz") ? 1280 :
                                                             640  ;

localparam FRAME_HEIGHT = (DISPLAY_MODE == "1920x1080_60Hz") ? 1080:
                         (DISPLAY_MODE == "1280x720_60Hz")  ? 720 :
                                                              480 ; 

// MIPI RX - Camera
wire  [7:0]             w_cam_d0_HS_IN;
wire  [7:0]             w_cam_d1_HS_IN;
reg                     w_cam_confdone;
wire                    w_cam_ck_HS_ENA_0;
wire                    w_cam_ck_HS_TERM_0;
wire  [1:0]             w_cam_d_HS_ENA_0;

(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_P_IN_0_1P;
(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_N_IN_0_1P;
(* async_reg = "true" *)reg   [15:0]   r_mipi_rx_data_HS_IN_0_1P;
(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_P_IN_0_2P;
(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_N_IN_0_2P;
(* async_reg = "true" *)reg   [15:0]   r_mipi_rx_data_HS_IN_0_2P;

wire [63:0]     w_mapped_raw_data;
wire            w_rx_out_de;
wire            w_rx_out_vs;
wire            w_rx_out_hs;
wire [5:0]      rx_out_dt;



always@(negedge rstn or posedge cam_ck_CLKOUT)
begin
   if (~rstn)
   begin
      r_mipi_rx_data_LP_P_IN_0_1P   <= 2'b0;
      r_mipi_rx_data_LP_N_IN_0_1P   <= 2'b0;
      r_mipi_rx_data_HS_IN_0_1P     <= {16{1'b0}};
      
      r_mipi_rx_data_LP_P_IN_0_2P   <= 2'b0;
      r_mipi_rx_data_LP_N_IN_0_2P   <= 2'b0;
      r_mipi_rx_data_HS_IN_0_2P     <= {16{1'b0}};
   end
   else
   begin
      r_mipi_rx_data_LP_P_IN_0_1P   <= {cam_d1_LP_P_IN, cam_d0_LP_P_IN}; 
      r_mipi_rx_data_LP_N_IN_0_1P   <= {cam_d1_LP_N_IN, cam_d0_LP_N_IN};
      r_mipi_rx_data_HS_IN_0_1P     <= {w_cam_d1_HS_IN[7:0], w_cam_d0_HS_IN[7:0]};
               
      r_mipi_rx_data_LP_P_IN_0_2P   <= r_mipi_rx_data_LP_P_IN_0_1P;
      r_mipi_rx_data_LP_N_IN_0_2P   <= r_mipi_rx_data_LP_N_IN_0_1P;
      r_mipi_rx_data_HS_IN_0_2P     <= r_mipi_rx_data_HS_IN_0_1P;
   end
end

assign   w_cam_d0_HS_IN    = cam_d0_HS_IN; 
assign   w_cam_d1_HS_IN    = cam_d1_HS_IN; 

assign   cam_ck_HS_TERM  = w_cam_ck_HS_ENA_0;
assign   cam_ck_HS_ENA   = w_cam_ck_HS_ENA_0;
assign   cam_d0_HS_TERM  = w_cam_d_HS_ENA_0[0];
assign   cam_d1_HS_TERM  = w_cam_d_HS_ENA_0[1];
assign   cam_d0_HS_ENA   = w_cam_d_HS_ENA_0[0];
assign   cam_d1_HS_ENA   = w_cam_d_HS_ENA_0[1];
assign   cam_d0_RST      = ~rstn;
assign   cam_d1_RST      = ~rstn;             


/**************************************************
 *
 * csi2_mipi_rx Instantiation
 * 
**************************************************/ 
csi2_mipi_rx #(
) u_csi2_rx_cam (
   .reset_n             ( rstn ),
   .clk                 ( i_pixel_clk ),
   .reset_byte_HS_n     ( rstn ),
   .clk_byte_HS         ( cam_ck_CLKOUT ),
   .reset_pixel_n       ( rstn ),
   .clk_pixel           ( i_pixel_clk ),
   
   .Rx_LP_CLK_P         ( cam_ck_LP_P_IN ),
   .Rx_LP_CLK_N         ( cam_ck_LP_N_IN ),
   .Rx_HS_enable_C      ( w_cam_ck_HS_ENA_0 ),
   .LVDS_termen_C       ( w_cam_ck_HS_TERM_0 ),
 
   .Rx_LP_D_P           ( r_mipi_rx_data_LP_P_IN_0_2P ),
   .Rx_LP_D_N           ( r_mipi_rx_data_LP_N_IN_0_2P ),
   .Rx_HS_D_0           ( r_mipi_rx_data_HS_IN_0_2P[7:0] ),
   .Rx_HS_D_1           ( r_mipi_rx_data_HS_IN_0_2P[15:8] ),
   .Rx_HS_D_2           (  ),
   .Rx_HS_D_3           (  ),
   .Rx_HS_D_4           (  ),
   .Rx_HS_D_5           (  ),
   .Rx_HS_D_6           (  ),
   .Rx_HS_D_7           (  ),
   .Rx_HS_enable_D      ( w_cam_d_HS_ENA_0 ),
   .LVDS_termen_D       (  ),
   .fifo_rd_enable      ( {cam_d1_FIFO_RD,    cam_d0_FIFO_RD} ),
   .fifo_rd_empty       ( {cam_d1_FIFO_EMPTY, cam_d0_FIFO_EMPTY} ),
   .DLY_enable_D        (  ),
   .DLY_inc_D           (  ),
   .u_dly_enable_D      (  ),
   .u_dly_inc_D         (  ),
   
   .axi_clk             ( 1'b0 ),
   .axi_reset_n         ( 1'b0 ),
   .axi_awaddr          ( 6'b0 ),
   .axi_awvalid         ( 1'b0 ),
   .axi_awready         (  ),
   .axi_wdata           ( 32'b0 ),
   .axi_wvalid          ( 1'b0 ),
   .axi_wready          (  ),
    
   .axi_bvalid          (  ),
   .axi_bready          ( 1'b0 ),
   .axi_araddr          ( 6'b0 ),
   .axi_arvalid         ( 1'b0 ),
   .axi_arready         (  ),
   .axi_rdata           (  ),
   .axi_rvalid          (  ),
   .axi_rready          ( 1'b0 ),
   
   .hsync_vc0           ( w_rx_out_hs ),
   .hsync_vc1           (  ),
   .hsync_vc2           (  ),
   .hsync_vc3           (  ),
   .hsync_vc4           (  ),
   .hsync_vc5           (  ),
   .hsync_vc6           (  ),
   .hsync_vc7           (  ),
   .hsync_vc8           (  ),
   .hsync_vc9           (  ),
   .hsync_vc10          (  ),
   .hsync_vc11          (  ),
   .hsync_vc12          (  ),
   .hsync_vc13          (  ),
   .hsync_vc14          (  ),
   .hsync_vc15          (  ),
   .vsync_vc0           ( w_rx_out_vs ),
   .vsync_vc1           (  ),
   .vsync_vc2           (  ),
   .vsync_vc3           (  ),
   .vsync_vc4           (  ),
   .vsync_vc5           (  ),
   .vsync_vc6           (  ),
   .vsync_vc7           (  ),
   .vsync_vc8           (  ),
   .vsync_vc9           (  ),
   .vsync_vc10          (  ),
   .vsync_vc11          (  ),
   .vsync_vc12          (  ),
   .vsync_vc13          (  ),
   .vsync_vc14          (  ),
   .vsync_vc15          (  ),
   .vc                  (  ),
   .vcx                 (  ),
   .word_count          (  ),
   .shortpkt_data_field (  ),
   .datatype            ( rx_out_dt ),
   .pixel_per_clk       (  ),
   .pixel_data          ( w_mapped_raw_data ),
   .pixel_data_valid    ( w_rx_out_de ),
   .irq                 (  )
 );

/**************************************************
 *
 * cam_picam_v2 Instantiation
 * 
**************************************************/ 



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

cam_picam_v2 # (
   .FAMILY                                 ( FAMILY           ),
   .MIPI_FRAME_WIDTH                       ( MIPI_FRAME_WIDTH ),             //Input frame resolution from MIPI
   .MIPI_FRAME_HEIGHT                      ( MIPI_FRAME_HEIGHT ),            //Input frame resolution from MIPI
   .FRAME_WIDTH                            ( FRAME_WIDTH ),                  //Output frame resolution to external memory
   .FRAME_HEIGHT                           ( FRAME_HEIGHT ),                 //Output frame resolution to external memory
   .DMA_TRANSFER_LENGTH                    ( (FRAME_WIDTH*FRAME_HEIGHT )/2 ), //2PPC
   .MIPI_PCLK_CLK_RATE                     ( 32'd100_000_000 )               // as mipi_pclk is 100MHz
 ) u_cam (
    .mipi_pclk                              ( i_pixel_clk ),
    .rst_n                                  ( rstn ),
    .mipi_cam_data                          ( w_mapped_raw_data ),
    .mipi_cam_valid                         ( w_rx_out_de ),
    .mipi_cam_vs                            ( w_rx_out_vs ),
    .mipi_cam_hs                            ( w_rx_out_hs ),
    .mipi_cam_type                          ( rx_out_dt ),

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


