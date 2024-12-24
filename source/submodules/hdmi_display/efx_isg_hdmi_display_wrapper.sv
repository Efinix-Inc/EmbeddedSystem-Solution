
module efx_isg_hdmi_display_wrapper #(
    parameter FAMILY            = "TITANIUM" ,
    parameter DISPLAY_MODE      = "1280x720_60Hz",
    parameter APB3_DATA_WIDTH   = 32,
    parameter APB3_ADDR_WIDTH   = 16
) (
    input                       rstn,
    input                       sys_clk, 
    input                       hdmi_clk,
    input                       io_peripheralClk,
    input                       io_peripheralReset,
    input                       pll_locked,  
    input                       i2c_sda_i, 
    input                       i2c_scl_i, 
    output                      i2c_sda_oe, 
    output                      i2c_scl_oe,

    //APB3 Standard Signal
    input  [APB3_ADDR_WIDTH-1:0] PADDR,
    input                        PSEL,
    input                        PENABLE,
    output                       PREADY,
    input                        PWRITE,
    input  [APB3_DATA_WIDTH-1:0] PWDATA,
    output [APB3_DATA_WIDTH-1:0] PRDATA,
    output                       PSLVERROR, 
    
    input [63:0]                display_dma_rdata, 
    input                       display_dma_rvalid, 
    input [7:0]                 display_dma_rkeep, 
    output                      display_dma_rready, 
    
    output                      hdmi_yuv_vs,
    output                      hdmi_yuv_hs,
    output                      hdmi_yuv_de,
    output [15:0]               hdmi_yuv_data

);

//Resolution Parameter (Vesa Standard): 
// * 1080p (HDMI Clock 148.5 MHz )
// * 720p (HDMI Clock 74.250 MHz)
// * 480p (HDMI Clock 25.250 MHz)

localparam FRAME_WIDTH  = (DISPLAY_MODE == "1920x1080_60Hz")? 12'd1920 :
                         (DISPLAY_MODE == "1280x720_60Hz") ? 12'd1280 :
                                                             12'd640  ;

localparam FRAME_HEIGHT = (DISPLAY_MODE == "1920x1080_60Hz") ? 12'd1080:
                         (DISPLAY_MODE == "1280x720_60Hz")  ? 12'd720 :
                                                              12'd480 ;  

localparam VIDEO_MAX_HRES  = (DISPLAY_MODE == "1920x1080_60Hz")? 11'd1920:
                            (DISPLAY_MODE == "1280x720_60Hz") ? 11'd1280:
                                                                11'd640 ;

localparam VIDEO_HSP  = (DISPLAY_MODE == "1920x1080_60Hz")? 8'd44:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 8'd40:
                                                           8'd96;

localparam VIDEO_HBP  = (DISPLAY_MODE == "1920x1080_60Hz")? 8'd148:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 8'd220:
                                                           8'd40;

localparam VIDEO_HFP  = (DISPLAY_MODE == "1920x1080_60Hz")? 8'd88:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 8'd110:
                                                           8'd8;

localparam VIDEO_MAX_VRES  = (DISPLAY_MODE == "1920x1080_60Hz")? 11'd1080:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 11'd720:
                                                           11'd480;

localparam VIDEO_VSP  = (DISPLAY_MODE == "1920x1080_60Hz")? 6'd5:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 6'd5:
                                                           6'd2;

localparam VIDEO_VBP  = (DISPLAY_MODE == "1920x1080_60Hz")? 6'd36:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 6'd20:
                                                           6'd25;


localparam VIDEO_VFP  = (DISPLAY_MODE == "1920x1080_60Hz")? 6'd4:
                       (DISPLAY_MODE == "1280x720_60Hz") ? 6'd5:
                                                           6'd2;


/**************************************************
 *
 * display_hdmi_adv7511_config Instantiation
 * 
**************************************************/ 
display_hdmi_config #(
    .FAMILY         ( FAMILY            )                 
) u_display_config (
    .i_arst         ( !rstn ),
    .i_sysclk       ( sys_clk ),
    .i_pll_locked   ( pll_locked ),
    .o_state        ( ),
    .o_confdone     ( ),
    
    .i_sda          ( i2c_sda_i ),
    .o_sda_oe       ( i2c_sda_oe ),
    .i_scl          ( i2c_scl_i ),
    .o_scl_oe       ( i2c_scl_oe ),
    .o_rstn         ( )
);


/**************************************************
 *
 * display_hdmi_yuv Instantiation
 * Diplay post process from DMA to HDMI Port
 * 
**************************************************/ 
display_hdmi_yuv #(
    .FRAME_WIDTH     (FRAME_WIDTH),
    .FRAME_HEIGHT    (FRAME_HEIGHT),

    .VIDEO_MAX_HRES  (VIDEO_MAX_HRES),
    .VIDEO_HSP       (VIDEO_HSP),
    .VIDEO_HBP       (VIDEO_HBP),
    .VIDEO_HFP       (VIDEO_HFP),

    .VIDEO_MAX_VRES  (VIDEO_MAX_VRES),
    .VIDEO_VSP       (VIDEO_VSP),
    .VIDEO_VBP       (VIDEO_VBP),
    .VIDEO_VFP       (VIDEO_VFP)
) inst_display_hdmi_yuv(
    .iHdmiClk                           ( hdmi_clk ),
    .iRst_n                             ( rstn ),
    
    //DMA RGB Input
    .ivDisplayDmaRdData                 ( display_dma_rdata ),
    .iDisplayDmaRdValid                 ( display_dma_rvalid ),
    .iv7DisplayDmaRdKeep                ( display_dma_rkeep ),
    .oDisplayDmaRdReady                 ( display_dma_rready ),
    
    // Status.
    .iRstDebugReg                       ( 1'b0 ),
    .oDebugDisplayDMAFifoStatus         ( debug_display_dma_fifo_status ), 
    .ov32DebugDisplayDmaFifoRCount      ( debug_display_dma_fifo_rcount ), 
    .ov32DebugDisplayDmaFifoWCount      ( debug_display_dma_fifo_wcount ),

    // Output to HDMI
    .oHdmiYuvVs                         ( hdmi_yuv_vs ),
    .oHdmiYuvHs                         ( hdmi_yuv_hs ),
    .oHdmiYuvDe                         ( hdmi_yuv_de ),
    .ov16HdmiYuvData                    ( hdmi_yuv_data )
);

//Debug Display Signal
wire [31:0]               debug_display_dma_fifo_rcount;
wire [31:0]               debug_display_dma_fifo_wcount;
wire [31:0]               debug_display_dma_fifo_status;


// APB3 control for Display related Signal
common_apb3 #(
   .ADDR_WIDTH   (16),
   .DATA_WIDTH   (32),
   .SW_MODULE    (2 ),
   .NUM_RD_REG   (4 )
) u_apb3_display (
    .clk                               ( io_peripheralClk    ),
    .cross_clk                         ( hdmi_clk            ),
    .resetn                            ( ~io_peripheralReset ),
    
    .data_out   /* Output Control  */  (),
    .data_in   /* Input Info Data  */  ({32'hBBCD_5678, debug_display_dma_fifo_status, debug_display_dma_fifo_rcount, debug_display_dma_fifo_wcount}),
   
    // Apb 3 interface
    .PADDR                             ( PADDR          ),
    .PSEL                              ( PSEL           ),
    .PENABLE                           ( PENABLE        ),
    .PREADY                            ( PREADY ),
    .PRDATA                            ( PRDATA ),
    .PWRITE                            ( 1'b0   ),
    .PWDATA                            (        ),
    .PSLVERROR                         (        )
);


endmodule

