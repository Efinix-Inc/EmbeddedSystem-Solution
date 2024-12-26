
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
    
    // LVDS Video output
    output [6:0]        lvds_1a_DATA,
    output [6:0]        lvds_1b_DATA,
    output [6:0]        lvds_1c_DATA,
    output [6:0]        lvds_1d_DATA,
    output [6:0]        lvds_2a_DATA,
    output [6:0]        lvds_2b_DATA,
    output [6:0]        lvds_2c_DATA,
    output [6:0]        lvds_2d_DATA,
    output [6:0]        lvds_clk

);

/**************************************************
 *
 * display_hdmi_config Instantiation
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
 * display_lvds Instantiation
 * Diplay post process from DMA to HDMI Port
 * 
**************************************************/ 
display_lvds # (
   .DISPLAY_MODE                     ( DISPLAY_MODE       ) 
) u_display (
   .lvds_slowclk                     ( hdmi_clk           ),
   .rst_n                            ( rstn               ),
   .display_dma_rdata                ( display_dma_rdata  ),
   .display_dma_rvalid               ( display_dma_rvalid ),
   .display_dma_rready               ( display_dma_rready ),
   .display_dma_rkeep                ( display_dma_rkeep  ),
   .lvds_1a_DATA                     ( lvds_1a_DATA       ),
   .lvds_1b_DATA                     ( lvds_1b_DATA       ),
   .lvds_1c_DATA                     ( lvds_1c_DATA       ),
   .lvds_1d_DATA                     ( lvds_1d_DATA       ),
   .lvds_2a_DATA                     ( lvds_2a_DATA       ),
   .lvds_2b_DATA                     ( lvds_2b_DATA       ),
   .lvds_2c_DATA                     ( lvds_2c_DATA       ),
   .lvds_2d_DATA                     ( lvds_2d_DATA       ),
   .lvds_clk                         ( lvds_clk           ),
   //Debug Signal
   .debug_display_dma_fifo_status    ( debug_display_dma_fifo_status ),
   .debug_display_dma_fifo_rcount    ( debug_display_dma_fifo_rcount ),
   .debug_display_dma_fifo_wcount    ( debug_display_dma_fifo_wcount )
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

