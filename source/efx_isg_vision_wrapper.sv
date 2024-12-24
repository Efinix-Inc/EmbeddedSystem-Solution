
module efx_isg_vision_wrapper#(

    parameter FAMILY                 = "TITANIUM",
    parameter DISPLAY_MODE           = "1920x1080_60Hz", // Display Mode
    parameter MIPI_FRAME_WIDTH       = 1920,          // Resolution of Camera input 
    parameter MIPI_FRAME_HEIGHT      = 1080,          // Resolution of Camera input 
    parameter APB3_ADDR_WIDTH        = 16,            // APB3 CSR Address Width 
    parameter APB3_DATA_WIDTH        = 32,            // APB3 CSR Data Width
    parameter HW_ACCEL_ADDR_WIDTH    = 32,            // Hardware Accelerator Address Width
    parameter HW_ACCEL_DATA_WIDTH    = 32,            // Hardware Accelerator Data Width
    parameter CSI_RX_DATA_WIDTH_LANE = 16             // CSI RX Data Width Lane
    
    )(

    // Clock 
    input           i_pixel_clk,
    input           io_peripheralClk,
    input           io_peripheralReset, 
    input           i_hdmi_clk_148p5MHz, 
    input           i_sys_clk_25mhz,
    output wire     i_arstn,

    // PLL Locked
    input           pll_system_locked,
    input           pll_peripheral_locked,
    input           pll_hdmi_locked,

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
   output                              mipi_dphy_rx_inst1_RST0_N,              // Active Low Reset for MIPI Control 

    // Camera (DMA)
    input               cam_dma_wready,
    output              cam_dma_wvalid,
    output              cam_dma_wlast,
    output [63:0]       cam_dma_wdata,

    // I2C Configuration for HDMI
    input           i2c_sda_i ,
    input           i2c_scl_i ,
    output          i2c_sda_oe,
    output          i2c_scl_oe,

    // HDMI YUV Output
    output          hdmi_yuv_de,
    output  [15:0]  hdmi_yuv_data,
    output          hdmi_yuv_vs,     //for Ti375C529 Dev Kit which requires tristate IO for HS VS
    output          hdmi_yuv_hs,     //for Ti375C529 Dev Kit which requires tristate IO for HS VS

    // HDMI Display (DMA)
    input [63:0]    display_dma_rdata,
    input           display_dma_rvalid,
    input [7:0]     display_dma_rkeep,
    output          display_dma_rready,

    //Hardware accelerator (DMA)
    output          hw_accel_dma_rready,
    input           hw_accel_dma_rvalid,
    input [3:0]     hw_accel_dma_rkeep,
    input [31:0]    hw_accel_dma_rdata,
    input           hw_accel_dma_wready,
    output          hw_accel_dma_wvalid,
    output          hw_accel_dma_wlast,
    output [31:0]   hw_accel_dma_wdata,

    //Hardware accelerator
    output                               axi_interrupt,
    //AW
    input [7:0]                          axi_awid,
    input [HW_ACCEL_ADDR_WIDTH-1:0]      axi_awaddr,
    input [7:0]                          axi_awlen,
    input [2:0]                          axi_awsize,
    input [1:0]                          axi_awburst,
    input                                axi_awlock,
    input [3:0]                          axi_awcache,
    input [2:0]                          axi_awprot,
    input [3:0]                          axi_awqos,
    input [3:0]                          axi_awregion,
    input                                axi_awvalid,
    output                               axi_awready,
    //W
    input [HW_ACCEL_ADDR_WIDTH-1:0]     axi_wdata,
    input [(HW_ACCEL_ADDR_WIDTH/8)-1:0] axi_wstrb,
    input                               axi_wlast,
    input                               axi_wvalid,
    output                              axi_wready,
    //B
    output [7:0]                        axi_bid,
    output [1:0]                        axi_bresp,
    output                              axi_bvalid,
    input                               axi_bready,
    //AR
    input [7:0]                         axi_arid,
    input [HW_ACCEL_ADDR_WIDTH-1:0]     axi_araddr,
    input [7:0]                         axi_arlen,
    input [2:0]                         axi_arsize,
    input [1:0]                         axi_arburst,
    input                               axi_arlock,
    input [3:0]                         axi_arcache,
    input [2:0]                         axi_arprot,
    input [3:0]                         axi_arqos,
    input [3:0]                         axi_arregion,
    input                               axi_arvalid,
    output                              axi_arready,
    //R
    output [7:0]                        axi_rid,
    output [HW_ACCEL_ADDR_WIDTH-1:0]    axi_rdata,
    output [1:0]                        axi_rresp,
    output                              axi_rlast,
    output                              axi_rvalid,
    input                               axi_rready,

    //Control Status Register : APB3 Standard Signal
    input  [APB3_ADDR_WIDTH-1:0]        vision_PADDR,
    input                               vision_PSEL,
    input                               vision_PENABLE,
    output                              vision_PREADY,
    input                               vision_PWRITE,
    input  [APB3_DATA_WIDTH-1:0]        vision_PWDATA,
    output [APB3_DATA_WIDTH-1:0]        vision_PRDATA,
    output                              vision_PSLVERROR,
    input                               mode_selector


);
//////////////////////////////////////////////////////

wire    [APB3_DATA_WIDTH-1:0] PRDATA_CAM, PRDATA_DISPLAY, PRDATA_HW_ACCEL;
wire    PREADY_CAM, PREADY_DISPLAY, PREADY_HW_ACCEL ;

//reset 

wire    mipi_rstn; 
wire    io_asyncResetn_evsoc;

//////////////////////////////////////////////////////

assign io_asyncResetn_evsoc     =  pll_system_locked & pll_peripheral_locked & pll_hdmi_locked;
assign i_arstn                  = (io_asyncResetn_evsoc & (!mipi_rstn)) ;


/**************************************************
 *
 * Camera Wrapper 
 * Mipi Rx, Picam, common Apb3 Related Module
 * 
**************************************************/ 
`ifdef ENABLE_EVSOC_CAMERA

efx_isg_mipi_csi_cam_wrapper #(
    .FAMILY             ( FAMILY            ),
    .DISPLAY_MODE       ( DISPLAY_MODE      ),
    .MIPI_FRAME_WIDTH   ( MIPI_FRAME_WIDTH  ),
    .MIPI_FRAME_HEIGHT  ( MIPI_FRAME_HEIGHT ),
    .APB3_ADDR_WIDTH    ( APB3_ADDR_WIDTH   ),
    .APB3_DATA_WIDTH    ( APB3_DATA_WIDTH   )

    ) mipi_csi_cam_inst (
    .rstn                 ( i_arstn          ), 
    .mipi_rstn            ( mipi_rstn        ),
    .i_pixel_clk          ( i_pixel_clk      ),
    .io_peripheralClk     ( io_peripheralClk ),
    .io_peripheralReset   ( io_peripheralReset ),
    .cam_dma_wready       ( cam_dma_wready  ), 
    .cam_dma_wvalid       ( cam_dma_wvalid  ), 
    .cam_dma_wlast        ( cam_dma_wlast   ), 
    .cam_dma_wdata        ( cam_dma_wdata   ), 
    // MIPI RX - Camera
    .mipi_dphy_rx_inst1_WORD_CLKOUT_HS          (mipi_dphy_rx_inst1_WORD_CLKOUT_HS),
    .mipi_dphy_rx_inst1_FORCE_RX_MODE           (mipi_dphy_rx_inst1_FORCE_RX_MODE),
    .mipi_dphy_rx_inst1_ERR_CONTENTION_LP0      (mipi_dphy_rx_inst1_ERR_CONTENTION_LP0),
    .mipi_dphy_rx_inst1_ERR_CONTENTION_LP1      (mipi_dphy_rx_inst1_ERR_CONTENTION_LP1),
    .mipi_dphy_rx_inst1_ERR_CONTROL_LAN0        (mipi_dphy_rx_inst1_ERR_CONTROL_LAN0),
    .mipi_dphy_rx_inst1_ERR_CONTROL_LAN1        (mipi_dphy_rx_inst1_ERR_CONTROL_LAN1),
    .mipi_dphy_rx_inst1_ERR_ESC_LAN0            (mipi_dphy_rx_inst1_ERR_ESC_LAN0),
    .mipi_dphy_rx_inst1_ERR_ESC_LAN1            (mipi_dphy_rx_inst1_ERR_ESC_LAN1),
    .mipi_dphy_rx_inst1_ERR_SOT_HS_LAN0         (mipi_dphy_rx_inst1_ERR_SOT_HS_LAN0),
    .mipi_dphy_rx_inst1_ERR_SOT_HS_LAN1         (mipi_dphy_rx_inst1_ERR_SOT_HS_LAN1),
    .mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN0    (mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN0),
    .mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN1    (mipi_dphy_rx_inst1_ERR_SOT_SYNC_HS_LAN1),
    .mipi_dphy_rx_inst1_LP_CLK                  (mipi_dphy_rx_inst1_LP_CLK),
    .mipi_dphy_rx_inst1_RX_ACTIVE_HS_LAN0       (mipi_dphy_rx_inst1_RX_ACTIVE_HS_LAN0),
    .mipi_dphy_rx_inst1_RX_ACTIVE_HS_LAN1       (mipi_dphy_rx_inst1_RX_ACTIVE_HS_LAN1),
    .mipi_dphy_rx_inst1_RX_CLK_ACTIVE_HS        (mipi_dphy_rx_inst1_RX_CLK_ACTIVE_HS),
    .mipi_dphy_rx_inst1_ESC_LAN0_CLK            (mipi_dphy_rx_inst1_ESC_LAN0_CLK),
    .mipi_dphy_rx_inst1_ESC_LAN1_CLK            (mipi_dphy_rx_inst1_ESC_LAN1_CLK),
    .mipi_dphy_rx_inst1_RX_DATA_ESC             (mipi_dphy_rx_inst1_RX_DATA_ESC),
    .mipi_dphy_rx_inst1_RX_DATA_HS_LAN0         (mipi_dphy_rx_inst1_RX_DATA_HS_LAN0),
    .mipi_dphy_rx_inst1_RX_DATA_HS_LAN1         (mipi_dphy_rx_inst1_RX_DATA_HS_LAN1),
    .mipi_dphy_rx_inst1_RX_LPDT_ESC             (mipi_dphy_rx_inst1_RX_LPDT_ESC),
    .mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN0     (mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN0),
    .mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN1     (mipi_dphy_rx_inst1_RX_SKEW_CAL_HS_LAN1),
    .mipi_dphy_rx_inst1_RX_SYNC_HS_LAN0         (mipi_dphy_rx_inst1_RX_SYNC_HS_LAN0),
    .mipi_dphy_rx_inst1_RX_SYNC_HS_LAN1         (mipi_dphy_rx_inst1_RX_SYNC_HS_LAN1),
    .mipi_dphy_rx_inst1_RX_TRIGGER_ESC          (mipi_dphy_rx_inst1_RX_TRIGGER_ESC),
    .mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_CLK_NOT  (mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_CLK_NOT),
    .mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN0 (mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN0),
    .mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN1 (mipi_dphy_rx_inst1_RX_ULPS_ACTIVE_NOT_LAN1),
    .mipi_dphy_rx_inst1_RX_ULPS_CLK_NOT         (mipi_dphy_rx_inst1_RX_ULPS_CLK_NOT),
    .mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN0        (mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN0),
    .mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN1        (mipi_dphy_rx_inst1_RX_ULPS_ESC_LAN1),
    .mipi_dphy_rx_inst1_RX_VALID_ESC            (mipi_dphy_rx_inst1_RX_VALID_ESC),
    .mipi_dphy_rx_inst1_RX_VALID_HS_LAN0        (mipi_dphy_rx_inst1_RX_VALID_HS_LAN0),
    .mipi_dphy_rx_inst1_RX_VALID_HS_LAN1        (mipi_dphy_rx_inst1_RX_VALID_HS_LAN1),
    .mipi_dphy_rx_inst1_STOPSTATE_CLK           (mipi_dphy_rx_inst1_STOPSTATE_CLK),
    .mipi_dphy_rx_inst1_STOPSTATE_LAN0          (mipi_dphy_rx_inst1_STOPSTATE_LAN0),
    .mipi_dphy_rx_inst1_STOPSTATE_LAN1          (mipi_dphy_rx_inst1_STOPSTATE_LAN1  ),
    .mipi_dphy_rx_inst1_RESET_N                 (mipi_dphy_rx_inst1_RESET_N),
    .mipi_dphy_rx_inst1_RST0_N                  (mipi_dphy_rx_inst1_RST0_N ),
    // Common APB3 Control Register
    .PADDR                ( vision_PADDR         ),
    .PSEL                 ( vision_PSEL          ),
    .PENABLE              ( vision_PENABLE       ),
    .PREADY               ( PREADY_CAM    ),
    .PRDATA               ( PRDATA_CAM    ),
    .PWRITE               ( vision_PWRITE        ),
    .PWDATA               ( vision_PWDATA        ),
    .PSLVERROR            (  )      
); 
`else 

    assign cam_d0_RST = 1'b1; 
    assign cam_d1_RST = 1'b1; 

`endif  // ENABLE_EVSOC_CAMERA


/**************************************************
 *
 * Display Wrapper 
 * HDMI, common Apb3 Related Module
 * 
**************************************************/ 
`ifdef ENABLE_EVSOC_DISPLAY

efx_isg_hdmi_display_wrapper #(
    .FAMILY             ( FAMILY           ),
    .DISPLAY_MODE       ( DISPLAY_MODE     ),
    .APB3_ADDR_WIDTH    ( APB3_ADDR_WIDTH  ),
    .APB3_DATA_WIDTH    ( APB3_DATA_WIDTH  )

    )displayTopInst (
    .rstn                   ( i_arstn             ), 
    .sys_clk                ( i_sys_clk_25mhz     ), 
    .hdmi_clk               ( i_hdmi_clk_148p5MHz ), 
    .io_peripheralClk       ( io_peripheralClk    ),
    .io_peripheralReset     ( io_peripheralReset  ),
    .pll_locked             ( pll_system_locked   ), 
    .i2c_sda_i              ( i2c_sda_i           ),
    .i2c_scl_i              ( i2c_scl_i           ),
    .i2c_sda_oe             ( i2c_sda_oe          ), 
    .i2c_scl_oe             ( i2c_scl_oe          ), 
    
    .display_dma_rdata  ( display_dma_rdata  ), 
    .display_dma_rvalid ( display_dma_rvalid ), 
    .display_dma_rkeep  ( display_dma_rkeep  ), 
    .display_dma_rready ( display_dma_rready ), 
    
    .hdmi_yuv_vs    ( hdmi_yuv_vs   ), 
    .hdmi_yuv_hs    ( hdmi_yuv_hs   ), 
    .hdmi_yuv_de    ( hdmi_yuv_de     ), 
    .hdmi_yuv_data  ( hdmi_yuv_data   ),
    // Common APB3 Control Register
    .PADDR                ( vision_PADDR         ),
    .PSEL                 ( vision_PSEL          ),
    .PENABLE              ( vision_PENABLE       ),
    .PREADY               ( PREADY_DISPLAY    ),
    .PRDATA               ( PRDATA_DISPLAY    ),
    .PWRITE               ( 1'b0  ),
    .PWDATA               (  ),
    .PSLVERROR            (  )  
); 


`endif // ENABLE_EVSOC_DISPLAY



/**************************************************
 *
 * common_apb3 Instantiation
 * For control and status register for Cam and displays
 * 
**************************************************/ 

common_apb3_wrapper #(
    .ADDR_WIDTH   (APB3_ADDR_WIDTH),
    .DATA_WIDTH   (APB3_DATA_WIDTH)
) u_apb3_wrapper (
    .resetn     ( ~io_peripheralReset ),
    // Apb 3 interface
    .data_in    ({PRDATA_CAM,PRDATA_DISPLAY,PRDATA_HW_ACCEL}),
    .ready_in   ({PREADY_CAM,PREADY_DISPLAY,PREADY_HW_ACCEL}),
    .PADDR      ( vision_PADDR ),
    .PREADY     ( vision_PREADY ),
    .PRDATA     ( vision_PRDATA )
);


/**************************************************
 *
 * Hardware Accelerator Wrapper
 * Hw Accel, common Apb3 Related Module
 * 
**************************************************/ 
`ifdef ENABLE_EVSOC_HW_ACCEL

efx_isg_hw_accel_wrapper #(
    .FAMILY            ( FAMILY              ),
    .DISPLAY_MODE      ( DISPLAY_MODE        ),
    .AXI_ADDR_WIDTH    ( HW_ACCEL_ADDR_WIDTH ), 
    .AXI_DATA_WIDTH    ( HW_ACCEL_DATA_WIDTH ),
    .APB3_ADDR_WIDTH   ( APB3_ADDR_WIDTH     ),
    .APB3_DATA_WIDTH   ( APB3_DATA_WIDTH     )

    )hwAccelTopInst (
    .clk            ( io_peripheralClk    ), 
    .rstn           ( ~io_peripheralReset ), 
    .mode_selector  ( mode_selector),
    .axi_slave_clk  ( io_peripheralClk    ), 
    .axi_slave_rstn ( ~io_peripheralReset ),
    .axi_interrupt ( axi_interrupt ),
    .axi_awid      ( 'd0 ),
    .axi_awaddr    ( axi_awaddr   ),
    .axi_awlen     ( axi_awlen    ),
    .axi_awsize    ( axi_awsize   ),
    .axi_awburst   ( axi_awburst  ),
    .axi_awlock    ( axi_awlock   ),
    .axi_awcache   ( axi_awcache  ),
    .axi_awprot    ( axi_awprot   ),
    .axi_awqos     ( axi_awqos    ),
    .axi_awregion  ( axi_awregion ),
    .axi_awvalid   ( axi_awvalid  ),
    .axi_awready   ( axi_awready  ),
    .axi_wdata     ( axi_wdata    ),
    .axi_wstrb     ( axi_wstrb    ),
    .axi_wlast     ( axi_wlast    ),
    .axi_wvalid    ( axi_wvalid   ),
    .axi_wready    ( axi_wready   ),
    .axi_bid       (  ),
    .axi_bresp     ( axi_bresp    ),
    .axi_bvalid    ( axi_bvalid   ),
    .axi_bready    ( axi_bready   ),
    .axi_arid      ( 'd0 ),
    .axi_araddr    ( axi_araddr   ),
    .axi_arlen     ( axi_arlen    ),
    .axi_arsize    ( axi_arsize   ),
    .axi_arburst   ( axi_arburst  ),
    .axi_arlock    ( axi_arlock   ),
    .axi_arcache   ( axi_arcache  ),
    .axi_arprot    ( axi_arprot   ),
    .axi_arqos     ( axi_arqos    ),
    .axi_arregion  ( axi_arregion ),
    .axi_arvalid   ( axi_arvalid  ),
    .axi_arready   ( axi_arready  ),
    .axi_rid       (  ),
    .axi_rdata     ( axi_rdata  ),
    .axi_rresp     ( axi_rresp  ),
    .axi_rlast     ( axi_rlast  ),
    .axi_rvalid    ( axi_rvalid ),
    .axi_rready    ( axi_rready ),
    .dma_rready    ( hw_accel_dma_rready ),
    .dma_rvalid    ( hw_accel_dma_rvalid ),
    .dma_rdata     ( hw_accel_dma_rdata ),
    .dma_rkeep     ( hw_accel_dma_rkeep ),
    .dma_wready    ( hw_accel_dma_wready ),
    .dma_wvalid    ( hw_accel_dma_wvalid ),
    .dma_wlast     ( hw_accel_dma_wlast ),
    .dma_wdata     ( hw_accel_dma_wdata ),
    // Common APB3 Control Register
    .PADDR         ( vision_PADDR   ),
    .PSEL          ( vision_PSEL    ),
    .PENABLE       ( vision_PENABLE ),
    .PREADY        ( PREADY_HW_ACCEL    ),
    .PRDATA        ( PRDATA_HW_ACCEL    ),
    .PWRITE        ( 1'b0  ),
    .PWDATA        (  ),
    .PSLVERROR     (  )  
); 
`endif // ENABLE_EVSOC_HW_ACCEL

endmodule
