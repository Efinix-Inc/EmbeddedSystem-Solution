
module efx_isg_hw_accel_wrapper #(
    parameter FAMILY            = "TITANIUM" ,
    parameter DISPLAY_MODE      = "1920x1080_60Hz",
    parameter AXI_ADDR_WIDTH    = 32, 
    parameter AXI_DATA_WIDTH    = 32, 
    parameter APB3_DATA_WIDTH   = 32,
    parameter APB3_ADDR_WIDTH   = 16
) (
   input                        clk, 
   input                        rstn, 
   input                        mode_selector,
    //APB3 Standard Signal
    input  [APB3_ADDR_WIDTH-1:0] PADDR,
    input                        PSEL,
    input                        PENABLE,
    output                       PREADY,
    input                        PWRITE,
    input  [APB3_DATA_WIDTH-1:0] PWDATA,
    output [APB3_DATA_WIDTH-1:0] PRDATA,
    output                       PSLVERROR, 

   input                        axi_slave_clk, 
   input                        axi_slave_rstn,
   output                       axi_interrupt,
   //AW
   input [7:0]                  axi_awid,
   input [AXI_ADDR_WIDTH-1:0]   axi_awaddr,
   input [7:0]                  axi_awlen,
   input [2:0]                  axi_awsize,
   input [1:0]                  axi_awburst,
   input                        axi_awlock,
   input [3:0]                  axi_awcache,
   input [2:0]                  axi_awprot,
   input [3:0]                  axi_awqos,
   input [3:0]                  axi_awregion,
   input                        axi_awvalid,
   output                       axi_awready,
   //W
   input [AXI_DATA_WIDTH-1:0]   axi_wdata,
   input [(AXI_DATA_WIDTH/8)-1:0] axi_wstrb,
   input                        axi_wlast,
   input                        axi_wvalid,
   output                       axi_wready,
   //B
   output [7:0]                 axi_bid,
   output [1:0]                 axi_bresp,
   output                       axi_bvalid,
   input                        axi_bready,
   //AR
   input [7:0]                  axi_arid,
   input [AXI_ADDR_WIDTH-1:0]   axi_araddr,
   input [7:0]                  axi_arlen,
   input [2:0]                  axi_arsize,
   input [1:0]                  axi_arburst,
   input                        axi_arlock,
   input [3:0]                  axi_arcache,
   input [2:0]                  axi_arprot,
   input [3:0]                  axi_arqos,
   input [3:0]                  axi_arregion,
   input                        axi_arvalid,
   output                       axi_arready,
   //R
   output [7:0]                 axi_rid,
   output [AXI_DATA_WIDTH-1:0]  axi_rdata,
   output [1:0]                 axi_rresp,
   output                       axi_rlast,
   output                       axi_rvalid,
   input                        axi_rready,
   
   output                           dma_rready,
   input                            dma_rvalid,
   input   [(AXI_DATA_WIDTH/8)-1:0]  dma_rkeep,
   input   [AXI_DATA_WIDTH-1:0]     dma_rdata,
   input                            dma_wready,
   output                           dma_wvalid,
   output                           dma_wlast,
   output  [AXI_DATA_WIDTH-1:0]     dma_wdata
); 

// Resolution of Display
localparam FRAME_WIDTH  = (DISPLAY_MODE == "1920x1080_60Hz")? 1920 :
                         (DISPLAY_MODE == "1280x720_60Hz")  ? 1280 :
                                                              640  ;

localparam FRAME_HEIGHT = (DISPLAY_MODE == "1920x1080_60Hz") ? 1080:
                         (DISPLAY_MODE == "1280x720_60Hz")   ? 720 :
                                                               480 ;

wire            hw_accel_axi_we;
wire [31:0]     hw_accel_axi_waddr;
wire [31:0]     hw_accel_axi_wdata;
wire            hw_accel_axi_re;
wire [31:0]     hw_accel_axi_raddr;
wire [31:0]     hw_accel_axi_rdata;
wire            hw_accel_axi_rvalid;
wire [31:0]     debug_hw_accel_dma_fifo_status;    
wire [31:0]     debug_hw_accel_in_fifo_wcount;
wire [31:0]     debug_hw_accel_out_fifo_rcount;
wire [1:0]      select_demo_mode;

//For demo2 
common_demo_mode_selector u_demo_mode_selector (
    .switch     ( mode_selector), 
    .clk        ( clk ), 
    .rstn       ( rstn ), 
    .demo_mode  ( select_demo_mode )
);

// APB3 control for Hardware Accelerator related Signal
common_apb3 #(
   .ADDR_WIDTH   (16),
   .DATA_WIDTH   (32),
   .SW_MODULE    (3 ),
   .NUM_RD_REG   (5 )
) u_apb3_hw_accel (
    .clk                               ( clk           ),
    .cross_clk                         ( axi_slave_clk ),
    .resetn                            ( rstn          ),
    
    .data_out   /* Output Control  */  (),
    .data_in   /* Input Info Data  */  ({32'hCBCD_5678, debug_hw_accel_dma_fifo_status, debug_hw_accel_out_fifo_rcount, debug_hw_accel_in_fifo_wcount, {30'd0, select_demo_mode}}),
    
    // Apb 3 interface
    .PADDR                             ( PADDR   ),
    .PSEL                              ( PSEL    ),
    .PENABLE                           ( PENABLE ),
    .PREADY                            ( PREADY  ),
    .PRDATA                            ( PRDATA  ),
    .PWRITE                            ( 1'b0    ),
    .PWDATA                            (         ),
    .PSLVERROR                         (         )
);

hw_accel_axi4 #(
    .ADDR_WIDTH     ( AXI_ADDR_WIDTH ),
    .DATA_WIDTH     ( AXI_DATA_WIDTH )
) u_hw_accel_axi4 (
    .axi_interrupt ( axi_interrupt ),
    .axi_aclk      ( axi_slave_clk ),
    .axi_resetn    ( axi_slave_rstn ),
    
    .axi_awid      (  axi_awid  ),
    .axi_awaddr    ( axi_awaddr ),
    .axi_awlen     ( axi_awlen  ),
    .axi_awsize    ( axi_awsize ),
    .axi_awburst   ( axi_awburst ),
    .axi_awlock    ( axi_awlock ),
    .axi_awcache   ( axi_awcache ),
    .axi_awprot    ( axi_awprot ),
    .axi_awqos     ( axi_awqos ),
    .axi_awregion  ( axi_awregion ),
    .axi_awvalid   ( axi_awvalid ),
    .axi_awready   ( axi_awready ),
    .axi_wdata     ( axi_wdata ),
    .axi_wstrb     ( axi_wstrb ),
    .axi_wlast     ( axi_wlast ),
    .axi_wvalid    ( axi_wvalid ),
    .axi_wready    ( axi_wready ),
    .axi_bid       ( axi_bid  ),
    .axi_bresp     ( axi_bresp ),
    .axi_bvalid    ( axi_bvalid ),
    .axi_bready    ( axi_bready ),
    .axi_arid      ( axi_arid ),
    .axi_araddr    ( axi_araddr ),
    .axi_arlen     ( axi_arlen ),
    .axi_arsize    ( axi_arsize ),
    .axi_arburst   ( axi_arburst ),
    .axi_arlock    ( axi_arlock ),
    .axi_arcache   ( axi_arcache ),
    .axi_arprot    ( axi_arprot ),
    .axi_arqos     ( axi_arqos ),
    .axi_arregion  ( axi_arregion ),
    .axi_arvalid   ( axi_arvalid ),
    .axi_arready   ( axi_arready ),
    .axi_rid       ( axi_rid  ),
    .axi_rdata     ( axi_rdata ),
    .axi_rresp     ( axi_rresp ),
    .axi_rlast     ( axi_rlast ),
    .axi_rvalid    ( axi_rvalid ),
    .axi_rready    ( axi_rready ),
    
    .usr_we        ( hw_accel_axi_we ),
    .usr_waddr     ( hw_accel_axi_waddr ),
    .usr_wdata     ( hw_accel_axi_wdata ),
    .usr_re        ( hw_accel_axi_re ),
    .usr_raddr     ( hw_accel_axi_raddr ),
    .usr_rdata     ( hw_accel_axi_rdata ),
    .usr_rvalid    ( hw_accel_axi_rvalid )
);

hw_accel_wrapper #( 
    .AXI_ADDR_WIDTH      ( AXI_ADDR_WIDTH ),
    .DATA_WIDTH          ( AXI_DATA_WIDTH ),
    .FRAME_WIDTH         ( FRAME_WIDTH ),
    .FRAME_HEIGHT        ( FRAME_HEIGHT ),
    .DMA_TRANSFER_LENGTH ( FRAME_WIDTH*FRAME_HEIGHT ), //S2MM DMA transfer
    .FAMILY              ( FAMILY)
) u_hw_accel_wrapper ( 

    .debug_hw_accel_fifo_status (debug_hw_accel_dma_fifo_status ),     
    .debug_dma_in_fifo_wcount   (debug_hw_accel_in_fifo_wcount  ), 
    .debug_dma_out_fifo_rcount  (debug_hw_accel_out_fifo_rcount ),

    .clk                   ( clk ),
    .rst                   ( ~rstn ),
    
    .axi_slave_clk         ( axi_slave_clk ),
    .axi_slave_rst         ( ~axi_slave_rstn ),
   
    .axi_slave_we          ( hw_accel_axi_we ),
    .axi_slave_waddr       ( hw_accel_axi_waddr ),
    .axi_slave_wdata       ( hw_accel_axi_wdata ),
    .axi_slave_re          ( hw_accel_axi_re ),
    .axi_slave_raddr       ( hw_accel_axi_raddr ),
    .axi_slave_rdata       ( hw_accel_axi_rdata ),
    .axi_slave_rvalid      ( hw_accel_axi_rvalid ),
    
    .dma_rready            ( dma_rready ),
    .dma_rvalid            ( dma_rvalid ),
    .dma_rdata             ( dma_rdata ),
    .dma_rkeep             ( dma_rkeep ),
    
    .dma_wready            ( dma_wready ),
    .dma_wvalid            ( dma_wvalid ),
    .dma_wlast             ( dma_wlast ),
    .dma_wdata             ( dma_wdata )
);

endmodule 

