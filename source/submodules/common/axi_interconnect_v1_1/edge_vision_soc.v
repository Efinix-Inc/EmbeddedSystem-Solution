///////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024 github-efx
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////

// To enable RiscV soft tap connection (for debugger).
//`define SOFT_TAP 1

module edge_vision_soc #(
    parameter MIPI_FRAME_WIDTH   = 1920, // Camera input resolution
    parameter MIPI_FRAME_HEIGHT  = 1080, // Camera input resolution
    parameter FRAME_WIDTH        = 1920, // Output display frame resolution
    parameter FRAME_HEIGHT       = 1080, // Output display frame resolution
    parameter INPUT_IMAGE_WIDTH  = 1920, // Input image size for pre-processing
    parameter INPUT_IMAGE_HEIGHT = 1080, // Input image size for pre-processing
    parameter SCALE_FACTOR       = 5,   // Reduce the input image size by this factor before pre-processing
    parameter AXI_0_DATA_WIDTH   = 512   // AXI Width 0 connected to DMA
)	   
(
`ifndef SOFT_TAP        
output		                    jtagCtrl_tdi    ,
input		                    jtagCtrl_tdo    ,
output		                    jtagCtrl_enable ,
output		                    jtagCtrl_capture,
output		                    jtagCtrl_shift  ,
output		                    jtagCtrl_update ,
output		                    jtagCtrl_reset  ,
input		                    ut_jtagCtrl_tdi    ,
output		                    ut_jtagCtrl_tdo    ,
input		                    ut_jtagCtrl_enable ,
input		                    ut_jtagCtrl_capture,
input		                    ut_jtagCtrl_shift  ,
input		                    ut_jtagCtrl_update ,
input		                    ut_jtagCtrl_reset  ,
`else               
output                          io_jtag_tdi,
input                           io_jtag_tdo,
output                          io_jtag_tms,
input                           pin_io_jtag_tdi,
output                          pin_io_jtag_tdo,
input                           pin_io_jtag_tms,
`endif              

//Temporary fix to slb overwriting clock names 
output                          io_peripheralClk, 
output                          io_ddrMasters_0_clk,


//AXI Master 0 Read Data Channel
input		                    io_ddrMasters_0_r_valid           ,
output		                    io_ddrMasters_0_r_ready           ,
input [127:0]                   io_ddrMasters_0_r_payload_data    ,
input [3:0]                     io_ddrMasters_0_r_payload_id      ,
input [1:0]                     io_ddrMasters_0_r_payload_resp    ,
input		                    io_ddrMasters_0_r_payload_last    ,

//AXI Master 0 Write Data Channel
output		                    io_ddrMasters_0_w_valid           ,
input		                    io_ddrMasters_0_w_ready           ,
output [127:0]                  io_ddrMasters_0_w_payload_data    ,
output [15:0]                   io_ddrMasters_0_w_payload_strb    ,
output		                    io_ddrMasters_0_w_payload_last    ,

//AXI Master 0 Response Channel
input		                    io_ddrMasters_0_b_valid           ,
output		                    io_ddrMasters_0_b_ready           ,
input [3:0]                     io_ddrMasters_0_b_payload_id      ,
input [1:0]                     io_ddrMasters_0_b_payload_resp    ,

//AXI Master 0 Read Address Channel
output		                    io_ddrMasters_0_ar_valid          ,
input		                    io_ddrMasters_0_ar_ready          ,
output [31:0]                   io_ddrMasters_0_ar_payload_addr   ,
output [3:0]                    io_ddrMasters_0_ar_payload_id     ,
output [3:0]                    io_ddrMasters_0_ar_payload_region ,
output [7:0]                    io_ddrMasters_0_ar_payload_len    ,
output [2:0]                    io_ddrMasters_0_ar_payload_size   ,
output [1:0]                    io_ddrMasters_0_ar_payload_burst  ,
output		                    io_ddrMasters_0_ar_payload_lock   ,
output [3:0]                    io_ddrMasters_0_ar_payload_cache  ,
output [3:0]                    io_ddrMasters_0_ar_payload_qos    ,
output [2:0]                    io_ddrMasters_0_ar_payload_prot   ,

//AXI Master 0 Write Address Channel
output		                    io_ddrMasters_0_aw_valid          ,
input		                    io_ddrMasters_0_aw_ready          ,
output [31:0]                   io_ddrMasters_0_aw_payload_addr   ,
output [3:0]                    io_ddrMasters_0_aw_payload_id     ,
output [3:0]                    io_ddrMasters_0_aw_payload_region ,
output [7:0]                    io_ddrMasters_0_aw_payload_len    ,
output [2:0]                    io_ddrMasters_0_aw_payload_size   ,
output [1:0]                    io_ddrMasters_0_aw_payload_burst  ,
output		                    io_ddrMasters_0_aw_payload_lock   ,
output [3:0]                    io_ddrMasters_0_aw_payload_cache  ,
output [3:0]                    io_ddrMasters_0_aw_payload_qos    ,
output [2:0]                    io_ddrMasters_0_aw_payload_prot   ,
output		                    io_ddrMasters_0_aw_payload_allStrb,


output		                    system_spi_0_io_sclk_write        ,
output		                    system_spi_0_io_data_0_writeEnable,
input		                    system_spi_0_io_data_0_read       ,
output		                    system_spi_0_io_data_0_write      ,
output		                    system_spi_0_io_data_1_writeEnable,
input		                    system_spi_0_io_data_1_read       ,
output		                    system_spi_0_io_data_1_write      ,
output		                    system_spi_0_io_data_2_writeEnable,
input		                    system_spi_0_io_data_2_read       ,
output		                    system_spi_0_io_data_2_write      ,
output		                    system_spi_0_io_data_3_writeEnable,
input		                    system_spi_0_io_data_3_read       ,
output		                    system_spi_0_io_data_3_write      ,
output [3:0]                    system_spi_0_io_ss                ,

output		                    system_uart_0_io_txd,
input		                    system_uart_0_io_rxd,

input [31:0]                    axiA_awaddr  ,
input [7:0]	                    axiA_awlen   ,
input [2:0]	                    axiA_awsize  ,
input [1:0]	                    axiA_awburst ,
input		                    axiA_awlock  ,
input [3:0]	                    axiA_awcache ,
input [2:0]	                    axiA_awprot  ,
input [3:0]	                    axiA_awqos   ,
input [3:0]	                    axiA_awregion,
input		                    axiA_awvalid ,
output		                    axiA_awready ,
input [31:0]                    axiA_wdata   ,
input [3:0]                     axiA_wstrb   ,
input		                    axiA_wvalid  ,
input		                    axiA_wlast   ,
output		                    axiA_wready  ,
output [1:0]                    axiA_bresp   ,
output		                    axiA_bvalid  ,
input		                    axiA_bready  ,
input [31:0]                    axiA_araddr  ,
input [7:0]	                    axiA_arlen   ,
input [2:0]	                    axiA_arsize  ,
input [1:0]	                    axiA_arburst ,
input		                    axiA_arlock  ,
input [3:0]	                    axiA_arcache ,
input [2:0]	                    axiA_arprot  ,
input [3:0]	                    axiA_arqos   ,
input [3:0]	                    axiA_arregion,
input		                    axiA_arvalid ,
output		                    axiA_arready ,
output [31:0]                   axiA_rdata   ,
output [1:0]                    axiA_rresp   ,
output		                    axiA_rlast   ,
output		                    axiA_rvalid  ,
input		                    axiA_rready  ,
output                          axiAInterrupt,

input                           cfg_done ,
output                          cfg_start,
output                          cfg_sel  ,
output                          cfg_reset,

//Up to 8 Interrupts. userInterruptH is connected to eCNN
output		                    userInterruptA,
output		                    userInterruptB,
output		                    userInterruptC,
output		                    userInterruptD,
output		                    userInterruptE,
output		                    userInterruptF,
output		                    userInterruptG,
output		                    userInterruptH,

//MIPI RX - Camera      
input    wire                   cam_ck_LP_P_IN,
input    wire                   cam_ck_LP_N_IN,
output   wire                   cam_ck_HS_TERM,
output   wire                   cam_ck_HS_ENA,
input    wire                   cam_ck_CLKOUT,

input    wire  [7:0]            cam_d0_HS_IN     ,
input    wire  [7:0]            cam_d0_HS_IN_1   ,
input    wire  [7:0]            cam_d0_HS_IN_2   ,
input    wire  [7:0]            cam_d0_HS_IN_3   ,
input    wire                   cam_d0_LP_P_IN   ,
input    wire                   cam_d0_LP_N_IN   ,
output   wire                   cam_d0_HS_TERM   ,
output   wire                   cam_d0_HS_ENA    ,
output   wire                   cam_d0_RST       ,
output   wire                   cam_d0_FIFO_RD   ,
input    wire                   cam_d0_FIFO_EMPTY,

input    wire  [7:0]            cam_d1_HS_IN     ,
input    wire  [7:0]            cam_d1_HS_IN_1   ,
input    wire  [7:0]            cam_d1_HS_IN_2   ,
input    wire  [7:0]            cam_d1_HS_IN_3   ,
input    wire                   cam_d1_LP_P_IN   ,
input    wire                   cam_d1_LP_N_IN   ,
output   wire                   cam_d1_HS_TERM   ,
output   wire                   cam_d1_HS_ENA    ,
output   wire                   cam_d1_RST       ,
output   wire                   cam_d1_FIFO_RD   ,
input    wire                   cam_d1_FIFO_EMPTY,

//CSI Camera interface      
input                           io_fpga_scl_IN  ,
output	                        io_fpga_scl_OUT ,
output                          io_fpga_scl_oe  ,
input                           io_fpga_sda_IN  ,
output	                        io_fpga_sda_OUT ,
output                          io_fpga_sda_oe  ,


input                           i_cam_sda   ,
output	                        o_cam_sda   ,
output                          o_cam_sda_oe,
input                           i_cam_scl   ,
output                          o_cam_scl_oe,
output	                        o_cam_scl   ,
output                          o_cam_rstn  ,

// I2C Configuration for HDMI
input                           i_hdmi_sda   ,
output                          o_hdmi_sda_oe,
input                           i_hdmi_scl   ,
output                          o_hdmi_scl_oe,


input                           hdmi_yuv_hs_IN ,
output                          hdmi_yuv_vs_OE ,
input                           hdmi_yuv_vs_IN ,
output                          hdmi_yuv_hs_OE ,
output                          hdmi_yuv_vs_OUT,
output                          hdmi_yuv_hs_OUT,

output                          hdmi_yuv_de  ,
output  [15:0]                  hdmi_yuv_data,

//Moved hdmi pll to soc_pll_mem_clk
input                           pll_osc_LOCKED ,
output                          pll_osc_RSTN   ,

input                           i_sys_clk          ,
input                           io_memoryClk       ,
input                           i_pixel_clk        ,
input                           i_hdmi_clk_148p5MHz,
input                           i_sys_clk_25mhz    ,

//3 Clocks Input for eCNN
input                           prp_clk     ,
input                           prp_clk_2x  ,
input                           prp_clk_2x_n,

input                           io_peripheralReset,
input                           io_systemReset    ,
output                          io_asyncReset     ,
output  reg                     sysClk_reset_ok   ,
output  reg                     periClk_reset_ok  ,
input                           io_gpio_sw_n      ,

//Make sure all interface clocks are locked
input                           pll_hdmi_locked   ,
input                           pll_system_locked ,
input                           pll_prp_locked    ,


//DDR AXI 0
output                          soc_ddr_inst1_ARSTN_0    ,

//DDR AXI 0 Read Data Channel
input   [AXI_0_DATA_WIDTH-1:0]  soc_ddr_inst1_RDATA_0    ,  //Read data.
input   [5:0]                   soc_ddr_inst1_RID_0      ,  //Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
input                           soc_ddr_inst1_RLAST_0    ,  //Read last. This signal indicates the last transfer in a read burst.
output                          soc_ddr_inst1_RREADY_0   ,  //Read ready. This signal indicates that the master can accept the read data and response information.
input   [1:0]                   soc_ddr_inst1_RRESP_0    ,  //Read response. This signal indicates the status of the read transfer.
input                           soc_ddr_inst1_RVALID_0   ,  //Read valid. This signal indicates that the channel is signaling the required read data.

//DDR AXI 0 Write Data Channel 
output  [AXI_0_DATA_WIDTH-1:0]  soc_ddr_inst1_WDATA_0    ,  //Write data. AXI4 port 0 is 256, port 1 is 128.
output                          soc_ddr_inst1_WLAST_0    ,  //Write last. This signal indicates the last transfer in a write burst.
input                           soc_ddr_inst1_WREADY_0   ,  //Write ready. This signal indicates that the slave can accept the write data.
output  [AXI_0_DATA_WIDTH/8-1:0]soc_ddr_inst1_WSTRB_0    ,  //Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
output                          soc_ddr_inst1_WVALID_0   ,  //Write valid. This signal indicates that valid write data and strobes are available.
   
   
//DDR AXI 0 Wrtie Response Channel
input   [5:0]                   soc_ddr_inst1_BID_0      ,  //Response ID tag. This signal is the ID tag of the write response.
output                          soc_ddr_inst1_BREADY_0   ,  //Response ready. This signal indicates that the master can accept a write response.
input   [1:0]                   soc_ddr_inst1_BRESP_0    ,  //Read response. This signal indicates the status of the read transfer.
input                           soc_ddr_inst1_BVALID_0   ,  //Write response valid. This signal indicates that the channel is signaling a valid write response.

//DDR AXI 0 Read Address Channel
output  [32:0]                  soc_ddr_inst1_ARADDR_0   ,  //Read address. It gives the address of the first transfer in a burst transaction.
output  [1:0]                   soc_ddr_inst1_ARBURST_0  ,  //Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
output  [5:0]                   soc_ddr_inst1_ARID_0     ,  //Address ID. This signal identifies the group of address signals.
output  [7:0]                   soc_ddr_inst1_ARLEN_0    ,  //Burst length. This signal indicates the number of transfers in a burst.
input                           soc_ddr_inst1_ARREADY_0  ,  //Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
output  [2:0]                   soc_ddr_inst1_ARSIZE_0   ,  //Burst size. This signal indicates the size of each transfer in the burst.
output                          soc_ddr_inst1_ARVALID_0  ,  //Address valid. This signal indicates that the channel is signaling valid address and control information.
output                          soc_ddr_inst1_ARLOCK_0   ,  //Lock type. This signal provides additional information about the atomic characteristics of the transfer.
output                          soc_ddr_inst1_ARAPCMD_0  ,  //Read auto-precharge.
output                          soc_ddr_inst1_ARQOS_0    ,  //QoS indentifier for read transaction.

//DDR AXI 0 Write Address Channel
output  [32:0]                  soc_ddr_inst1_AWADDR_0   ,  //Write address. It gives the address of the first transfer in a burst transaction.
output  [1:0]                   soc_ddr_inst1_AWBURST_0  ,  //Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
output  [5:0]                   soc_ddr_inst1_AWID_0     ,  //Address ID. This signal identifies the group of address signals.
output  [7:0]                   soc_ddr_inst1_AWLEN_0    ,  //Burst length. This signal indicates the number of transfers in a burst.
input                           soc_ddr_inst1_AWREADY_0  ,  //Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
output  [2:0]                   soc_ddr_inst1_AWSIZE_0   ,  //Burst size. This signal indicates the size of each transfer in the burst.
output                          soc_ddr_inst1_AWVALID_0  ,  //Address valid. This signal indicates that the channel is signaling valid address and control information.
output                          soc_ddr_inst1_AWLOCK_0   ,  //Lock type. This signal provides additional information about the atomic characteristics of the transfer.
output                          soc_ddr_inst1_AWAPCMD_0  ,  //Write auto-precharge.
output                          soc_ddr_inst1_AWQOS_0    ,  //QoS indentifier for write transaction.
output  [3:0]                   soc_ddr_inst1_AWCACHE_0  ,  //Memory type. This signal indicates how transactions are required to progress through a system.
output                          soc_ddr_inst1_AWALLSTRB_0,  //Write all strobes asserted.
output                          soc_ddr_inst1_AWCOBUF_0     //Write coherent bufferable selection.
);

////////////////////////
// Variable Declaration
////////////////////////
localparam  PERI_FREQ       = 250;

localparam  VIDEO_MAX_HRES  = 11'd1920;
localparam  VIDEO_HSP       = 8'd44   ;
localparam  VIDEO_HBP       = 8'd148  ;
localparam  VIDEO_HFP       = 8'd88   ;

localparam  VIDEO_MAX_VRES  = 11'd1080;
localparam  VIDEO_VSP       = 6'd5    ;
localparam  VIDEO_VBP       = 6'd36   ;
localparam  VIDEO_VFP       = 6'd4    ;

// CSI Controller
localparam CSI_RX_PIXEL_DATAWIDTH     = CAM_PIXEL_RX_MEM_DATAWIDTH;
localparam CSI_RX_PIXEL_PER_CLK       = 4;
localparam CSI_RX_TOTAL_DATAWIDTH     = CSI_RX_PIXEL_DATAWIDTH * CSI_RX_PIXEL_PER_CLK;
localparam CSI_RX_NUM_DATA_LANE       = 2;
localparam CSI_RX_DATA_WIDTH_LANE     = 16;
localparam CAM_PIXEL_RX_DATAWIDTH     = 10;   //RAW10, RAW12
localparam CAM_PIXEL_RX_MEM_DATAWIDTH = 8;

//APB0 (DMA)
wire [15:0] io_apbSlave_0_PADDR    ;
wire        io_apbSlave_0_PSEL     ;
wire        io_apbSlave_0_PENABLE  ;
wire        io_apbSlave_0_PREADY   ;
wire        io_apbSlave_0_PWRITE   ;
wire [31:0] io_apbSlave_0_PWDATA   ;
wire [31:0] io_apbSlave_0_PRDATA   ;
wire        io_apbSlave_0_PSLVERROR;

//APB1
wire [19:0] io_apbSlave_1_PADDR    ;
wire        io_apbSlave_1_PSEL     ;
wire        io_apbSlave_1_PENABLE  ;
wire        io_apbSlave_1_PREADY   ;
wire        io_apbSlave_1_PWRITE   ;
wire [31:0] io_apbSlave_1_PWDATA   ;
wire [31:0] io_apbSlave_1_PRDATA   ;
wire        io_apbSlave_1_PSLVERROR;

//APB2 (eCNN)
wire [15:0] io_apbSlave_2_PADDR    ;
wire        io_apbSlave_2_PSEL     ;
wire        io_apbSlave_2_PENABLE  ;
wire        io_apbSlave_2_PREADY   ;
wire        io_apbSlave_2_PWRITE   ;
wire [31:0] io_apbSlave_2_PWDATA   ;
wire [31:0] io_apbSlave_2_PRDATA   ;
wire        io_apbSlave_2_PSLVERROR;

//APB3 (eCNN2)
wire [15:0] io_apbSlave_3_PADDR    ;
wire        io_apbSlave_3_PSEL     ;
wire        io_apbSlave_3_PENABLE  ;
wire        io_apbSlave_3_PREADY   ;
wire        io_apbSlave_3_PWRITE   ;
wire [31:0] io_apbSlave_3_PWDATA   ;
wire [31:0] io_apbSlave_3_PRDATA   ;
wire        io_apbSlave_3_PSLVERROR;

//APB4 (eCNN3)
wire [15:0] io_apbSlave_4_PADDR    ;
wire        io_apbSlave_4_PSEL     ;
wire        io_apbSlave_4_PENABLE  ;
wire        io_apbSlave_4_PREADY   ;
wire        io_apbSlave_4_PWRITE   ;
wire [31:0] io_apbSlave_4_PWDATA   ;
wire [31:0] io_apbSlave_4_PRDATA   ;
wire        io_apbSlave_4_PSLVERROR;


wire        cnn_calc_start;
wire        cnn_calc_end;
wire        cnn2_calc_start;
wire        cnn2_calc_end;
wire        cnn3_calc_start;
wire        cnn3_calc_end;

wire [5:0]  dma_interrupts;	
wire        w_hdmi_clk    ;

assign pll_osc_RSTN     =   1'b1;
assign w_hdmi_clk = i_hdmi_clk_148p5MHz; // HDMI Clock 148.5 MHz


//////////////////
//Configure AXI0//
//////////////////
assign soc_ddr_inst1_ARSTN_0 = ~io_systemReset;
wire [7:0] dma_arid;
wire [7:0] dma_awid;

assign dma_arid = 8'hE0;
assign dma_awid = 8'hE1;

assign soc_ddr_inst1_ARID_0 = {dma_arid[7:6], dma_arid[3:0]};
assign soc_ddr_inst1_AWID_0 = {dma_awid[7:6], dma_awid[3:0]};

assign soc_ddr_inst1_ARADDR_0[32] = 1'b0;
assign soc_ddr_inst1_AWADDR_0[32] = 1'b0;

assign soc_ddr_inst1_AWAPCMD_0 =   1'b0;
assign soc_ddr_inst1_ARAPCMD_0 =   1'b0;
assign soc_ddr_inst1_AWALLSTRB_0 = 1'b0;
assign soc_ddr_inst1_AWCOBUF_0   = 1'b0;

assign  io_peripheralClk     = prp_clk; 
assign  io_ddrMasters_0_clk  = prp_clk; 

////////////////
//Reset Related
//////////////////
wire io_asyncResetn_evsoc;
wire mipi_rstn;
wire i_arstn  ;

assign io_asyncResetn_evsoc   = ~io_asyncReset & pll_osc_LOCKED & pll_hdmi_locked;
assign i_arstn                = (io_asyncResetn_evsoc & (!mipi_rstn));
assign o_cam_rstn             = i_arstn;
 
// Reset synchronizers
wire soc_prp_reset_out;     
common_reset #(
    .IN_RST_ACTIVE("HIGH"),
    .OUT_RST_ACTIVE("LOW"),
    .CYCLE(1)
) u_common_reset_prp_reset (
    .i_arst (io_peripheralReset),
	.i_clk  (prp_clk),
	.o_srst (soc_prp_reset_out)
);    


wire [31:0]                             debug_cam_display_fifo_status;
wire                                    debug_display_dma_fifo_underflow;
wire                                    debug_display_dma_fifo_overflow;
wire                                    wRstDebugReg;
wire [31:0]                             debug_display_dma_fifo_rcount; 
wire [31:0]                             debug_display_dma_fifo_wcount;

wire [2:0]	                            w_hdmi_i2c_state;
wire		                            w_hdmi_confdone;

wire                                    hdmi_yuv_vs;
wire                                    hdmi_yuv_hs;

assign                                  hdmi_yuv_vs_OE = !hdmi_yuv_vs;
assign                                  hdmi_yuv_hs_OE = !hdmi_yuv_hs;

assign                                  hdmi_yuv_vs_OUT = 0;
assign                                  hdmi_yuv_hs_OUT = 0;


wire                                    w_rx_out_de;
wire                                    w_rx_out_vs;
wire                                    w_rx_out_hs;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0]   w_rx_out_data_00;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0]   w_rx_out_data_01;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0]   w_rx_out_data_10;
wire [CAM_PIXEL_RX_MEM_DATAWIDTH-1:0]   w_rx_out_data_11;
wire [5:0]                              rx_out_dt;

////////////////////////////////////////////////////////////////
// MIPI RX - Camera
wire  [7:0]                             w_cam_d0_HS_IN;
wire  [7:0]                             w_cam_d1_HS_IN;
reg                                     w_cam_confdone;
wire                                    w_cam_ck_HS_ENA_0;
wire                                    w_cam_ck_HS_TERM_0;
wire  [1:0]                             w_cam_d_HS_ENA_0;

wire  [5:0]                             w_mipi_rx_dt;
wire                                    w_mipi_rx_vs;
wire                                    w_mipi_rx_hs;
wire                                    w_mipi_rx_de;
wire  [63:0]                            w_mipi_rx_data;

reg   [10:0]                            r_rx_x_mipi;
reg   [10:0]                            r_rx_y_mipi;
reg                                     r_rx_hs;
reg                                     r_rx_vs;  


(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_P_IN_0_1P;
(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_N_IN_0_1P;
(* async_reg = "true" *)reg   [15:0]   r_mipi_rx_data_HS_IN_0_1P;
(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_P_IN_0_2P;
(* async_reg = "true" *)reg   [1:0]    r_mipi_rx_data_LP_N_IN_0_2P;
(* async_reg = "true" *)reg   [15:0]   r_mipi_rx_data_HS_IN_0_2P;

////////////////////////////////////////////////////////////////
// MIPI CSI RX Channel - Camera

always@(negedge i_arstn or posedge cam_ck_CLKOUT)
begin
   if (~i_arstn)
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

assign   w_cam_d0_HS_IN    = {cam_d0_HS_IN_3, cam_d0_HS_IN_2, cam_d0_HS_IN_1, cam_d0_HS_IN};
assign   w_cam_d1_HS_IN    = {cam_d1_HS_IN_3, cam_d1_HS_IN_2, cam_d1_HS_IN_1, cam_d1_HS_IN};

assign   cam_ck_HS_TERM  = w_cam_ck_HS_ENA_0;
assign   cam_ck_HS_ENA   = w_cam_ck_HS_ENA_0;
assign   cam_d0_HS_TERM  = w_cam_d_HS_ENA_0[0];
assign   cam_d1_HS_TERM  = w_cam_d_HS_ENA_0[1];
assign   cam_d0_HS_ENA   = w_cam_d_HS_ENA_0[0];
assign   cam_d1_HS_ENA   = w_cam_d_HS_ENA_0[1];
assign   cam_d0_RST      = ~i_arstn;
assign   cam_d1_RST      = ~i_arstn;             


//DMA signals for eCNN pre-processing
localparam Dma2DataWidth = 64;
localparam Dma2KeepWidth = Dma2DataWidth / 8;

wire                     m_axis_dma2_TVALID;
wire                     m_axis_dma2_TREADY;
wire [Dma2DataWidth-1:0] m_axis_dma2_TDATA ;
wire [Dma2KeepWidth-1:0] m_axis_dma2_TKEEP ;
wire                     m_axis_dma2_TLAST ;
wire [              3:0] m_axis_dma2_TDEST ;

wire                     m_axis_dmafix_TVALID;
wire                     m_axis_dmafix_TREADY;
wire [Dma2DataWidth-1:0] m_axis_dmafix_TDATA ;
wire [Dma2KeepWidth-1:0] m_axis_dmafix_TKEEP ;
wire                     m_axis_dmafix_TLAST ;
wire [              3:0] m_axis_dmafix_TDEST ;

assign m_axis_dmafix_TVALID  = (&m_axis_dma2_TKEEP) & m_axis_dma2_TVALID;
assign m_axis_dma2_TREADY    = m_axis_dmafix_TREADY;
assign m_axis_dmafix_TDATA   = m_axis_dma2_TDATA;
assign m_axis_dmafix_TKEEP   = (&m_axis_dma2_TKEEP) ? {Dma2KeepWidth{1'b1}} : {Dma2KeepWidth{1'b0}};
assign m_axis_dmafix_TLAST   = m_axis_dma2_TLAST;
assign m_axis_dmafix_TDEST   = m_axis_dma2_TDEST;


localparam AxisDataWidth = 32;
localparam AxisKeepWidth = AxisDataWidth / 8;

wire                     m_axis_dmahalf_TVALID;
wire                     m_axis_dmahalf_TREADY;
wire [AxisDataWidth-1:0] m_axis_dmahalf_TDATA ;
wire [AxisKeepWidth-1:0] m_axis_dmahalf_TKEEP ;
wire                     m_axis_dmahalf_TLAST ;
wire [              3:0] m_axis_dmahalf_TDEST ;

wire                     m_axis_mscale_r_TVALID;
wire                     m_axis_mscale_r_TREADY;
wire [AxisDataWidth-1:0] m_axis_mscale_r_TDATA ;
wire [AxisKeepWidth-1:0] m_axis_mscale_r_TKEEP ;
wire                     m_axis_mscale_r_TLAST ;
wire [              3:0] m_axis_mscale_r_TDEST ;

wire                     m_axis_mscale_g_TVALID;
wire                     m_axis_mscale_g_TREADY;
wire [AxisDataWidth-1:0] m_axis_mscale_g_TDATA ;
wire [AxisKeepWidth-1:0] m_axis_mscale_g_TKEEP ;
wire                     m_axis_mscale_g_TLAST ;
wire [              3:0] m_axis_mscale_g_TDEST ;

wire                     m_axis_mscale_b_TVALID;
wire                     m_axis_mscale_b_TREADY;
wire [AxisDataWidth-1:0] m_axis_mscale_b_TDATA ;
wire [AxisKeepWidth-1:0] m_axis_mscale_b_TKEEP ;
wire                     m_axis_mscale_b_TLAST ;
wire [              3:0] m_axis_mscale_b_TDEST ;

/////////////////////
//AXI CNN SIGNAL
/////////////////////
localparam CnnIdWidth = 3;
localparam CnnDataWidth = 128;
localparam CnnStrbWidth = CnnDataWidth / 8;

/* CNN AXI master */
wire [  CnnIdWidth-1:0] axi_cnn_AWID   ;
wire [  CnnIdWidth-1:0] axi_cnn_ARID   ;
wire [            31:0] axi_cnn_AWADDR ;
wire [            31:0] axi_cnn_ARADDR ;
wire [             7:0] axi_cnn_AWLEN  ;
wire [             7:0] axi_cnn_ARLEN  ;
wire [             2:0] axi_cnn_AWSIZE ;
wire [             2:0] axi_cnn_ARSIZE ;
wire [             1:0] axi_cnn_AWBURST;
wire [             1:0] axi_cnn_ARBURST;
wire                    axi_cnn_AWLOCK ;
wire                    axi_cnn_ARLOCK ;
wire [             3:0] axi_cnn_AWCACHE;
wire [             3:0] axi_cnn_ARCACHE;
wire [             2:0] axi_cnn_AWPROT ;
wire [             2:0] axi_cnn_ARPROT ;
wire [             3:0] axi_cnn_AWQOS   , axi_cnn_ARQOS   ;
wire [             3:0] axi_cnn_AWREGION, axi_cnn_ARREGION;

wire [  CnnIdWidth-1:0] axi_cnn_BID  ;
wire [  CnnIdWidth-1:0] axi_cnn_RID  ;
wire [CnnDataWidth-1:0] axi_cnn_WDATA;
wire [CnnDataWidth-1:0] axi_cnn_RDATA;
wire [CnnStrbWidth-1:0] axi_cnn_WSTRB;
wire [             1:0] axi_cnn_BRESP;
wire [             1:0] axi_cnn_RRESP;
wire                    axi_cnn_WLAST;
wire                    axi_cnn_RLAST;
wire axi_cnn_AWVALID, axi_cnn_ARVALID, axi_cnn_WVALID, axi_cnn_BVALID, axi_cnn_RVALID;
wire axi_cnn_AWREADY, axi_cnn_ARREADY, axi_cnn_WREADY, axi_cnn_BREADY, axi_cnn_RREADY;


wire [  CnnIdWidth-1:0] axi_cnn2_AWID   ;
wire [  CnnIdWidth-1:0] axi_cnn2_ARID   ;
wire [            31:0] axi_cnn2_AWADDR ;
wire [            31:0] axi_cnn2_ARADDR ;
wire [             7:0] axi_cnn2_AWLEN  ;
wire [             7:0] axi_cnn2_ARLEN  ;
wire [             2:0] axi_cnn2_AWSIZE ;
wire [             2:0] axi_cnn2_ARSIZE ;
wire [             1:0] axi_cnn2_AWBURST;
wire [             1:0] axi_cnn2_ARBURST;
wire                    axi_cnn2_AWLOCK ;
wire                    axi_cnn2_ARLOCK ;
wire [             3:0] axi_cnn2_AWCACHE;
wire [             3:0] axi_cnn2_ARCACHE;
wire [             2:0] axi_cnn2_AWPROT ;
wire [             2:0] axi_cnn2_ARPROT ;
wire [             3:0] axi_cnn2_AWQOS   , axi_cnn2_ARQOS   ;
wire [             3:0] axi_cnn2_AWREGION, axi_cnn2_ARREGION;

wire [  CnnIdWidth-1:0] axi_cnn2_BID  ;
wire [  CnnIdWidth-1:0] axi_cnn2_RID  ;
wire [CnnDataWidth-1:0] axi_cnn2_WDATA;
wire [CnnDataWidth-1:0] axi_cnn2_RDATA;
wire [CnnStrbWidth-1:0] axi_cnn2_WSTRB;
wire [             1:0] axi_cnn2_BRESP;
wire [             1:0] axi_cnn2_RRESP;
wire                    axi_cnn2_WLAST;
wire                    axi_cnn2_RLAST;
wire axi_cnn2_AWVALID, axi_cnn2_ARVALID, axi_cnn2_WVALID, axi_cnn2_BVALID, axi_cnn2_RVALID;
wire axi_cnn2_AWREADY, axi_cnn2_ARREADY, axi_cnn2_WREADY, axi_cnn2_BREADY, axi_cnn2_RREADY;


wire [  CnnIdWidth-1:0] axi_cnn3_AWID   ;
wire [  CnnIdWidth-1:0] axi_cnn3_ARID   ;
wire [            31:0] axi_cnn3_AWADDR ;
wire [            31:0] axi_cnn3_ARADDR ;
wire [             7:0] axi_cnn3_AWLEN  ;
wire [             7:0] axi_cnn3_ARLEN  ;
wire [             2:0] axi_cnn3_AWSIZE ;
wire [             2:0] axi_cnn3_ARSIZE ;
wire [             1:0] axi_cnn3_AWBURST;
wire [             1:0] axi_cnn3_ARBURST;
wire                    axi_cnn3_AWLOCK ;
wire                    axi_cnn3_ARLOCK ;
wire [             3:0] axi_cnn3_AWCACHE;
wire [             3:0] axi_cnn3_ARCACHE;
wire [             2:0] axi_cnn3_AWPROT ;
wire [             2:0] axi_cnn3_ARPROT ;
wire [             3:0] axi_cnn3_AWQOS   , axi_cnn3_ARQOS   ;
wire [             3:0] axi_cnn3_AWREGION, axi_cnn3_ARREGION;

wire [  CnnIdWidth-1:0] axi_cnn3_BID  ;
wire [  CnnIdWidth-1:0] axi_cnn3_RID  ;
wire [CnnDataWidth-1:0] axi_cnn3_WDATA;
wire [CnnDataWidth-1:0] axi_cnn3_RDATA;
wire [CnnStrbWidth-1:0] axi_cnn3_WSTRB;
wire [             1:0] axi_cnn3_BRESP;
wire [             1:0] axi_cnn3_RRESP;
wire                    axi_cnn3_WLAST;
wire                    axi_cnn3_RLAST;
wire axi_cnn3_AWVALID, axi_cnn3_ARVALID, axi_cnn3_WVALID, axi_cnn3_BVALID, axi_cnn3_RVALID;
wire axi_cnn3_AWREADY, axi_cnn3_ARREADY, axi_cnn3_WREADY, axi_cnn3_BREADY, axi_cnn3_RREADY;


//////////////////////////////////////
//AXI INTERCONNECT SIGNAL
//////////////////////////////////////
localparam CNNCount = 3;

wire [CNNCount-1:0]               axi_inter_m_awvalid;
wire [CNNCount-1:0]               axi_inter_m_awready;
wire [32*CNNCount-1:0]            axi_inter_m_awaddr ;
wire [8*CNNCount-1:0 ]            axi_inter_m_awlen  ;
wire [CNNCount-1:0]               axi_inter_m_arvalid;
wire [CNNCount-1:0]               axi_inter_m_arready;
wire [32*CNNCount-1:0]            axi_inter_m_araddr ;
wire [8*CNNCount-1:0 ]            axi_inter_m_arlen  ;

wire [CNNCount-1:0]               axi_inter_m_bvalid;
wire [CNNCount-1:0]               axi_inter_m_bready;
wire [2*CNNCount-1:0 ]            axi_inter_m_bresp ;
wire [CNNCount-1:0]               axi_inter_m_wvalid;
wire [CNNCount-1:0]               axi_inter_m_wready;
wire [CnnDataWidth*CNNCount-1:0]  axi_inter_m_wdata ;
wire [CnnStrbWidth*CNNCount-1:0]  axi_inter_m_wstrb ;
wire [CNNCount-1:0]               axi_inter_m_wlast ;
wire [CNNCount-1:0]               axi_inter_m_rvalid;
wire [CNNCount-1:0]               axi_inter_m_rready;
wire [CnnDataWidth*CNNCount-1:0]  axi_inter_m_rdata ;
wire [2*CNNCount-1:0 ]            axi_inter_m_rresp ;
wire [CNNCount-1:0]               axi_inter_m_rlast ;


// Camera Input Prepocessing
wire [63:0]     w_mapped_raw_data;

csi2_rx_cam #(
) u_csi2_rx_cam (
   .reset_n             (i_arstn      ),
   .clk                 (i_pixel_clk  ),
   .reset_byte_HS_n     (i_arstn      ),
   .clk_byte_HS         (cam_ck_CLKOUT),
   .reset_pixel_n       (i_arstn      ),
   .clk_pixel           (i_pixel_clk  ),
   
   .Rx_LP_CLK_P         (cam_ck_LP_P_IN    ),
   .Rx_LP_CLK_N         (cam_ck_LP_N_IN    ),
   .Rx_HS_enable_C      (w_cam_ck_HS_ENA_0 ),
   .LVDS_termen_C       (w_cam_ck_HS_TERM_0),

   .Rx_LP_D_P           (r_mipi_rx_data_LP_P_IN_0_2P    ),
   .Rx_LP_D_N           (r_mipi_rx_data_LP_N_IN_0_2P    ),
   .Rx_HS_D_0           (r_mipi_rx_data_HS_IN_0_2P[7:0] ),
   .Rx_HS_D_1           (r_mipi_rx_data_HS_IN_0_2P[15:8]),
   .Rx_HS_D_2           (),
   .Rx_HS_D_3           (),
   .Rx_HS_D_4           (),
   .Rx_HS_D_5           (),
   .Rx_HS_D_6           (),
   .Rx_HS_D_7           (),
   .Rx_HS_enable_D      (w_cam_d_HS_ENA_0),
   .LVDS_termen_D       (),
   .fifo_rd_enable      ({cam_d1_FIFO_RD,    cam_d0_FIFO_RD}),
   .fifo_rd_empty       ({cam_d1_FIFO_EMPTY, cam_d0_FIFO_EMPTY}),
   .DLY_enable_D        (),
   .DLY_inc_D           (),
   .u_dly_enable_D      (),
   .u_dly_inc_D         (),
   
   .axi_clk             (1'b0),
   .axi_reset_n         (1'b0),
   .axi_awaddr          (6'b0),
   .axi_awvalid         (1'b0),
   .axi_awready         (),
   .axi_wdata           (32'b0),
   .axi_wvalid          (1'b0),
   .axi_wready          (),
   
   .axi_bvalid          (),
   .axi_bready          (1'b0),
   .axi_araddr          (6'b0),
   .axi_arvalid         (1'b0),
   .axi_arready         (),
   .axi_rdata           (),
   .axi_rvalid          (),
   .axi_rready          (1'b0),
   
   .hsync_vc0           (w_rx_out_hs),
   .hsync_vc1           (),
   .hsync_vc2           (),
   .hsync_vc3           (),
   .hsync_vc4           (),
   .hsync_vc5           (),
   .hsync_vc6           (),
   .hsync_vc7           (),
   .hsync_vc8           (),
   .hsync_vc9           (),
   .hsync_vc10          (),
   .hsync_vc11          (),
   .hsync_vc12          (),
   .hsync_vc13          (),
   .hsync_vc14          (),
   .hsync_vc15          (),
   .vsync_vc0           (w_rx_out_vs),
   .vsync_vc1           (),
   .vsync_vc2           (),
   .vsync_vc3           (),
   .vsync_vc4           (),
   .vsync_vc5           (),
   .vsync_vc6           (),
   .vsync_vc7           (),
   .vsync_vc8           (),
   .vsync_vc9           (),
   .vsync_vc10          (),
   .vsync_vc11          (),
   .vsync_vc12          (),
   .vsync_vc13          (),
   .vsync_vc14          (),
   .vsync_vc15          (),
   .vc                  (),
   .vcx                 (),
   .word_count          (),
   .shortpkt_data_field (),
   .datatype            (rx_out_dt),
   .pixel_per_clk       (),
   .pixel_data          (w_mapped_raw_data),
   .pixel_data_valid    (w_rx_out_de      ),
   .irq                 ()
);

wire            cam_dma_wready   ;
wire            cam_dma_wvalid   ;
wire            cam_dma_wlast    ;
wire [63:0]     cam_dma_wdata    ;

wire            stream_wr_en_ch0  ;
wire [48-1:0]   stream_wr_data_ch0;
wire            stream_wr_en_ch1  ;
wire [48-1:0]   stream_wr_data_ch1;

// Picam Debug register to APB status registers.
wire            debug_cam_dma_fifo_overflow ;
wire            debug_cam_dma_fifo_underflow;
wire [31:0]     debug_cam_dma_fifo_rcount   ;
wire [31:0]     debug_cam_dma_fifo_wcount   ;
wire [31:0]     debug_cam_dma_status        ;

wire            debug_cam_pixel_remap_fifo_underflow;
wire            debug_cam_pixel_remap_fifo_overflow ;

//cam_picam & hdmi
wire [15:0]     rgb_control;
wire            trigger_capture_frame;
wire            continuous_capture_frame;
wire            rgb_gray;
wire            cam_dma_init_done;
wire [31:0]     frames_per_second;
wire [31:0]     set_offset_display_rgb;
wire            hw_accel_dma_init_done;

wire            hw_accel_dma_init_done_ch0;
wire            hw_accel_dma_init_done_ch1;

cam_picam # (
    .MIPI_FRAME_WIDTH                       (MIPI_FRAME_WIDTH),             //Input frame resolution from MIPI
    .MIPI_FRAME_HEIGHT                      (MIPI_FRAME_HEIGHT),            //Input frame resolution from MIPI
    .FRAME_WIDTH                            (FRAME_WIDTH),                  //Output frame resolution to external memory
    .FRAME_HEIGHT                           (FRAME_HEIGHT),                 //Output frame resolution to external memory
    .DMA_TRANSFER_LENGTH                    ((FRAME_WIDTH*FRAME_HEIGHT)/2), //2PPC
    .MIPI_PCLK_CLK_RATE                     (32'd100_000_000)               // as mipi_pclk is 100MHz
) u_cam (
    .mipi_pclk                              (i_pixel_clk      ),
    .rst_n                                  (i_arstn          ),
    .mipi_cam_data                          (w_mapped_raw_data),
    .mipi_cam_valid                         (w_rx_out_de      ),
    .mipi_cam_vs                            (w_rx_out_vs      ),
    .mipi_cam_hs                            (w_rx_out_hs      ),
    .mipi_cam_type                          (rx_out_dt)       ,
    
    .stream_wr_en_ch0                       (stream_wr_en_ch0  ),
    .stream_wr_data_ch0                     (stream_wr_data_ch0),
    .stream_wr_en_ch1                       (stream_wr_en_ch1  ),
    .stream_wr_data_ch1                     (stream_wr_data_ch1), 

    .cam_dma_wready                         (cam_dma_wready),
    .cam_dma_wvalid                         (cam_dma_wvalid),
    .cam_dma_wlast                          (cam_dma_wlast ),
    .cam_dma_wdata                          (cam_dma_wdata ),

    .rgb_control                            (rgb_control),
    .trigger_capture_frame                  (trigger_capture_frame),
    .continuous_capture_frame               (continuous_capture_frame),
    .rgb_gray                               (rgb_gray),
    .cam_dma_init_done                      (cam_dma_init_done),
    .frames_per_second                      (frames_per_second),
    .debug_cam_pixel_remap_fifo_overflow    (debug_cam_pixel_remap_fifo_overflow ),
    .debug_cam_pixel_remap_fifo_underflow   (debug_cam_pixel_remap_fifo_underflow),
    .debug_cam_dma_fifo_overflow            (debug_cam_dma_fifo_overflow         ),
    .debug_cam_dma_fifo_underflow           (debug_cam_dma_fifo_underflow        ),
    .debug_cam_dma_fifo_rcount              (debug_cam_dma_fifo_rcount           ),
    .debug_cam_dma_fifo_wcount              (debug_cam_dma_fifo_wcount           ),
    .debug_cam_dma_status                   (debug_cam_dma_status                )
);


/////////////
// Camera I2C
/////////////
/* I2C initialization for ADV7511 */
display_hdmi_adv7511_config #(
    .INITIAL_CODE   ("source/display/hdmi/display_hdmi_adv7511_reg.mem")
) inst_adv7511_config (
    .i_arst         (~i_arstn),
    .i_sysclk       (i_sys_clk_25mhz),
    .i_pll_locked   (pll_system_locked),
    .o_state        (),
    .o_confdone     (w_hdmi_confdone),
    
    .i_sda          (i_hdmi_sda   ),
    .o_sda_oe       (o_hdmi_sda_oe),
    .i_scl          (i_hdmi_scl   ),
    .o_scl_oe       (o_hdmi_scl_oe),
    .o_rstn         ()
);


// Display Hdmi                 
wire [63:0]      display_dma_rdata;
wire             display_dma_rvalid;
wire [7:0]       display_dma_rkeep;
wire             display_dma_rready;

// Diplay post process from DMA to HDMI Port
display_hdmi_yuv #(
    .FRAME_WIDTH     (FRAME_WIDTH ),
    .FRAME_HEIGHT    (FRAME_HEIGHT),

    .VIDEO_MAX_HRES  (VIDEO_MAX_HRES),
    .VIDEO_HSP       (VIDEO_HSP     ),
    .VIDEO_HBP       (VIDEO_HBP     ),
    .VIDEO_HFP       (VIDEO_HFP     ),

    .VIDEO_MAX_VRES  (VIDEO_MAX_VRES),
    .VIDEO_VSP       (VIDEO_VSP     ),
    .VIDEO_VBP       (VIDEO_VBP     ),
    .VIDEO_VFP       (VIDEO_VFP     )
    
) inst_display_hdmi_yuv(
    .iHdmiClk                           (w_hdmi_clk),
    .iRst_n                             (i_arstn),
    
    // control offset display to red or green 
    .set_offset_display_rgb             (set_offset_display_rgb),
    
    //DMA RGB Input
    .ivDisplayDmaRdData                 (display_dma_rdata ),
    .iDisplayDmaRdValid                 (display_dma_rvalid),
    .iv7DisplayDmaRdKeep                (8'hFF),
    .oDisplayDmaRdReady                 (display_dma_rready),
    
    // Status.
    .iRstDebugReg                       (1'b0),
    .oDebugDisplayDmaFifoUnderflow      (debug_display_dma_fifo_underflow),
    .oDebugDisplayDmaFifoOverflow       (debug_display_dma_fifo_overflow ),
    .ov32DebugDisplayDmaFifoRCount      (debug_display_dma_fifo_rcount   ), 
    .ov32DebugDisplayDmaFifoWCount      (debug_display_dma_fifo_wcount   ),

    // Output to HDMI
    .oHdmiYuvVs                         (hdmi_yuv_vs ),
    .oHdmiYuvHs                         (hdmi_yuv_hs ),
    .oHdmiYuvDe                         (hdmi_yuv_de ),
    .ov16HdmiYuvData                    (hdmi_yuv_data)
);


// Display Hdmi
wire             bbox_dma_tvalid;
wire             bbox_dma_tready;
wire [63:0]      bbox_dma_tdata;
wire [7:0]       bbox_dma_tkeep;
wire [3:0]       bbox_dma_tdest;
wire             bbox_dma_tlast;

// Annotator u_annotator (
//    .clock             (w_hdmi_clk),
//    .reset             (~i_arstn),
   
//    .s_axis_in_tvalid   (bbox_dma_tvalid),
//    .s_axis_in_tlast    (bbox_dma_tlast),
//    .s_axis_in_tdata    (bbox_dma_tdata),
//    .s_axis_in_tready   (bbox_dma_tready),
   
//    .m_axis_out_tvalid  (display_dma_rvalid),
//    .m_axis_out_tdata   (display_dma_rdata),
//    .m_axis_out_tready  (display_dma_rready)
// );

display_annotator #(
   .FRAME_WIDTH  (FRAME_WIDTH),
   .FRAME_HEIGHT (FRAME_HEIGHT),
   .MAX_BBOX     (16)
) u_display_annotator (
   .clk        (w_hdmi_clk),
   .rst        (~i_arstn),
   
   .in_valid   (bbox_dma_tvalid),
   .in_last    (bbox_dma_tlast ),
   .in_data    (bbox_dma_tdata ),
   .in_ready   (bbox_dma_tready),
   
   .out_valid  (display_dma_rvalid),
   .out_data   (display_dma_rdata ),
   .out_ready  (display_dma_rready)
);




/*****************/
/*DMA            */
/*****************/
dma u_dma(
    .clk                (io_memoryClk),
    .reset              (io_systemReset),
    
    .ctrl_clk           (prp_clk),
    .ctrl_reset         (!soc_prp_reset_out),

    //APB Slave
    .ctrl_PADDR         (io_apbSlave_0_PADDR         ),
    .ctrl_PSEL          (io_apbSlave_0_PSEL          ),
    .ctrl_PENABLE       (io_apbSlave_0_PENABLE       ),
    .ctrl_PREADY        (io_apbSlave_0_PREADY        ),
    .ctrl_PWRITE        (io_apbSlave_0_PWRITE        ),
    .ctrl_PWDATA        (io_apbSlave_0_PWDATA        ),
    .ctrl_PRDATA        (io_apbSlave_0_PRDATA        ),
    .ctrl_PSLVERROR     (io_apbSlave_0_PSLVERROR     ),
    .ctrl_interrupts    (dma_interrupts              ),

    //DMA AXI memory Interface 
    .read_arvalid       (soc_ddr_inst1_ARVALID_0     ),
    .read_araddr        (soc_ddr_inst1_ARADDR_0[31:0]),
    .read_arready       (soc_ddr_inst1_ARREADY_0     ),
    .read_arregion      (),
    .read_arlen         (soc_ddr_inst1_ARLEN_0       ),
    .read_arsize        (soc_ddr_inst1_ARSIZE_0      ),
    .read_arburst       (soc_ddr_inst1_ARBURST_0     ),
    .read_arlock        (soc_ddr_inst1_ARLOCK_0      ),
    .read_arcache       ( ),
    .read_arqos         (soc_ddr_inst1_ARQOS_0       ),
    .read_arprot        ( ),
    
    .read_rready        (soc_ddr_inst1_RREADY_0      ),
    .read_rvalid        (soc_ddr_inst1_RVALID_0      ),
    .read_rdata         (soc_ddr_inst1_RDATA_0       ),
    .read_rlast         (soc_ddr_inst1_RLAST_0       ),
    .read_rresp         (soc_ddr_inst1_RRESP_0       ),
    
    .write_awvalid      (soc_ddr_inst1_AWVALID_0     ),
    .write_awready      (soc_ddr_inst1_AWREADY_0     ),
    .write_awaddr       (soc_ddr_inst1_AWADDR_0[31:0]),
    .write_awregion     (),
    .write_awlen        (soc_ddr_inst1_AWLEN_0       ),
    .write_awsize       (soc_ddr_inst1_AWSIZE_0      ),
    .write_awburst      (soc_ddr_inst1_AWBURST_0     ),
    .write_awlock       (soc_ddr_inst1_AWLOCK_0      ),
    .write_awcache      (soc_ddr_inst1_AWCACHE_0     ),
    .write_awqos        (soc_ddr_inst1_AWQOS_0       ),
    .write_awprot       (),
    
    .write_wvalid       (soc_ddr_inst1_WVALID_0      ),
    .write_wready       (soc_ddr_inst1_WREADY_0      ),
    .write_wdata        (soc_ddr_inst1_WDATA_0       ),
    .write_wstrb        (soc_ddr_inst1_WSTRB_0       ),
    .write_wlast        (soc_ddr_inst1_WLAST_0       ),
    
    .write_bvalid       (soc_ddr_inst1_BVALID_0      ),
    .write_bready       (soc_ddr_inst1_BREADY_0      ),
    .write_bresp        (soc_ddr_inst1_BRESP_0       ),

	
    //64bits Camera Video Stream In
    .dat0_i_clk         (i_pixel_clk        ),
    .dat0_i_reset       (~i_arstn           ),
    .dat0_i_tvalid      (cam_dma_wvalid     ),
    .dat0_i_tready      (cam_dma_wready     ),
    .dat0_i_tdata       (cam_dma_wdata      ),
    .dat0_i_tkeep       ({8{cam_dma_wvalid}}),
    .dat0_i_tdest       (4'd0),
    .dat0_i_tlast       (cam_dma_wlast      ),
	
     //64-bit dma channel (MM2S - from external memory)
    .dat1_o_clk         (w_hdmi_clk     ),
    .dat1_o_reset       (~i_arstn       ),
    .dat1_o_tvalid      (bbox_dma_tvalid),
    .dat1_o_tready      (bbox_dma_tready),
    .dat1_o_tdata       (bbox_dma_tdata ),
    .dat1_o_tkeep       (bbox_dma_tkeep ),
    .dat1_o_tdest       (bbox_dma_tdest ),
    .dat1_o_tlast       (bbox_dma_tlast ),
    
    //Raw ecnn input data for pre-processing
    .dat2_o_clk         (prp_clk),
    .dat2_o_reset       (!soc_prp_reset_out    ),
    .dat2_o_tvalid      (m_axis_dma2_TVALID    ),
    .dat2_o_tready      (m_axis_dma2_TREADY    ),
    .dat2_o_tdata       (m_axis_dma2_TDATA     ),
    .dat2_o_tkeep       (m_axis_dma2_TKEEP     ),
    .dat2_o_tlast       (m_axis_dma2_TLAST     ),
    .dat2_o_tdest       (m_axis_dma2_TDEST     ),

    .dat3_i_clk         (prp_clk),
    .dat3_i_reset       (!soc_prp_reset_out    ),
    .dat3_i_tvalid      (m_axis_mscale_r_TVALID),
    .dat3_i_tready      (m_axis_mscale_r_TREADY),
    .dat3_i_tdata       (m_axis_mscale_r_TDATA ),
    .dat3_i_tkeep       (m_axis_mscale_r_TKEEP ),
    .dat3_i_tlast       (m_axis_mscale_r_TLAST ),
    .dat3_i_tdest       (m_axis_mscale_r_TDEST ),

    .dat4_i_clk         (prp_clk),
    .dat4_i_reset       (!soc_prp_reset_out    ),
    .dat4_i_tvalid      (m_axis_mscale_g_TVALID),
    .dat4_i_tready      (m_axis_mscale_g_TREADY),
    .dat4_i_tdata       (m_axis_mscale_g_TDATA ),
    .dat4_i_tkeep       (m_axis_mscale_g_TKEEP ),
    .dat4_i_tlast       (m_axis_mscale_g_TLAST ),
    .dat4_i_tdest       (m_axis_mscale_g_TDEST ),
        
    .dat5_i_clk         (prp_clk),
    .dat5_i_reset       (!soc_prp_reset_out    ),
    .dat5_i_tvalid      (m_axis_mscale_b_TVALID),
    .dat5_i_tready      (m_axis_mscale_b_TREADY),
    .dat5_i_tdata       (m_axis_mscale_b_TDATA ),
    .dat5_i_tkeep       (m_axis_mscale_b_TKEEP ),
    .dat5_i_tlast       (m_axis_mscale_b_TLAST ),
    .dat5_i_tdest       (m_axis_mscale_b_TDEST )
);

assign userInterruptE = |dma_interrupts;


//Streaming in 64-bit instead of 32-bit doubles the pre-processing speed 
//Requires a bridge to convert 64-bit to 32-bit for pre-processing
//Pre-processing with 32-bits gives more accurate output

axis_width_64to32 #(
    .STREAM_WIDTH_IN (Dma2DataWidth),
    .STREAM_WIDTH_OUT(AxisDataWidth)
) axis_width_64to32_dma1_inst (
    .ACLK_in          (prp_clk),
    .ACLK_out         (prp_clk_2x),
    .ARESETn          (soc_prp_reset_out),
    .s_axis_in_TVALID (m_axis_dmafix_TVALID ),
    .s_axis_in_TREADY (m_axis_dmafix_TREADY ),
    .s_axis_in_TDATA  (m_axis_dmafix_TDATA  ),
    .s_axis_in_TKEEP  (m_axis_dmafix_TKEEP  ),
    .s_axis_in_TLAST  (m_axis_dmafix_TLAST  ),
    .s_axis_in_TDEST  (m_axis_dmafix_TDEST  ),
    .m_axis_out_TVALID(m_axis_dmahalf_TVALID),
    .m_axis_out_TREADY(m_axis_dmahalf_TREADY),
    .m_axis_out_TDATA (m_axis_dmahalf_TDATA ),
    .m_axis_out_TKEEP (m_axis_dmahalf_TKEEP ),
    .m_axis_out_TLAST (m_axis_dmahalf_TLAST ),
    .m_axis_out_TDEST (m_axis_dmahalf_TDEST )
);

multi_scaler #(
      .STREAM_WIDTH(32),
      .SCALE_FACTOR(SCALE_FACTOR),
      .INPUT_IMAGE_WIDTH(INPUT_IMAGE_WIDTH),
      .INPUT_IMAGE_HEIGHT(INPUT_IMAGE_HEIGHT)
  ) multi_scaler_inst (
      .ACLK            (prp_clk),
      .ACLK_2x         (prp_clk_2x),
      .ARESETn         (soc_prp_reset_out),
      .s_axis_in_TVALID(m_axis_dmahalf_TVALID),
      .s_axis_in_TREADY(m_axis_dmahalf_TREADY),
      .s_axis_in_TDATA (m_axis_dmahalf_TDATA ),
      .s_axis_in_TKEEP (m_axis_dmahalf_TKEEP ),
      .s_axis_in_TLAST (m_axis_dmahalf_TLAST ),
      .s_axis_in_TDEST (m_axis_dmahalf_TDEST ),
      .m_axis_r_TVALID (m_axis_mscale_r_TVALID),
      .m_axis_r_TREADY (m_axis_mscale_r_TREADY),
      .m_axis_r_TDATA  (m_axis_mscale_r_TDATA ),
      .m_axis_r_TKEEP  (m_axis_mscale_r_TKEEP ),
      .m_axis_r_TLAST  (m_axis_mscale_r_TLAST ),
      .m_axis_r_TDEST  (m_axis_mscale_r_TDEST ),
      .m_axis_g_TVALID (m_axis_mscale_g_TVALID),
      .m_axis_g_TREADY (m_axis_mscale_g_TREADY),
      .m_axis_g_TDATA  (m_axis_mscale_g_TDATA ),
      .m_axis_g_TKEEP  (m_axis_mscale_g_TKEEP ),
      .m_axis_g_TLAST  (m_axis_mscale_g_TLAST ),
      .m_axis_g_TDEST  (m_axis_mscale_g_TDEST ),
      .m_axis_b_TVALID (m_axis_mscale_b_TVALID),
      .m_axis_b_TREADY (m_axis_mscale_b_TREADY),
      .m_axis_b_TDATA  (m_axis_mscale_b_TDATA ),
      .m_axis_b_TKEEP  (m_axis_mscale_b_TKEEP ),
      .m_axis_b_TLAST  (m_axis_mscale_b_TLAST ),
      .m_axis_b_TDEST  (m_axis_mscale_b_TDEST )
  );
											   

reg  [31:0]     sysClk_cnt;
reg  [31:0]     periClk_cnt;

/*                                                                                  */
/* Check aliveness of system and peripheral reset                                   */
/*                                                                                  */
always@(posedge prp_clk or posedge !soc_prp_reset_out)
begin  
    if(!soc_prp_reset_out)
    begin
        periClk_cnt <= 'd0;
        periClk_reset_ok <= 1'b0;        
    end
    else
    begin
        if(periClk_cnt == (PERI_FREQ*1000000)-1)
        begin
            periClk_cnt <= 'd0;
            periClk_reset_ok <= ~periClk_reset_ok;            
        end
        else
        begin
            periClk_cnt <= periClk_cnt + 1'b1;
            periClk_reset_ok <= periClk_reset_ok;                        
        end
    end
end

always@(posedge i_sys_clk_25mhz or posedge io_systemReset)
begin  
    if(io_systemReset)
    begin
        sysClk_cnt <= 'd0;
        sysClk_reset_ok <= 1'b0;        
    end
    else
    begin
        if(sysClk_cnt == (PERI_FREQ*1000000)-1)
        begin
            sysClk_cnt <= 'd0;
            sysClk_reset_ok <= ~sysClk_reset_ok;            
        end
        else
        begin
            sysClk_cnt <= sysClk_cnt + 1'b1;
            sysClk_reset_ok <= sysClk_reset_ok;                        
        end
    end
end

 
////////////////////////
//AXI MASTER <-> eCNN/// 
////////////////////////
// assign io_ddrMasters_0_aw_payload_id     = {1'b1, axi_cnn_AWID}          ;
// assign io_ddrMasters_0_aw_payload_addr   = axi_cnn_AWADDR                ;
// assign io_ddrMasters_0_aw_payload_len    = axi_cnn_AWLEN                 ;
// assign io_ddrMasters_0_aw_payload_size   = axi_cnn_AWSIZE                ;
// assign io_ddrMasters_0_aw_payload_burst  = axi_cnn_AWBURST               ;
// assign io_ddrMasters_0_aw_payload_lock   = axi_cnn_AWLOCK                ;
// assign io_ddrMasters_0_aw_payload_cache  = axi_cnn_AWCACHE               ;
// assign io_ddrMasters_0_aw_payload_prot   = axi_cnn_AWPROT                ;
// assign io_ddrMasters_0_aw_payload_qos    = axi_cnn_AWQOS                 ;
// assign io_ddrMasters_0_aw_payload_region = axi_cnn_AWREGION              ;
// assign io_ddrMasters_0_aw_valid          = axi_cnn_AWVALID               ;
// assign axi_cnn_AWREADY                   = io_ddrMasters_0_aw_ready      ;
// assign io_ddrMasters_0_w_payload_data    = axi_cnn_WDATA                 ;
// assign io_ddrMasters_0_w_payload_strb    = axi_cnn_WSTRB                 ;
// assign io_ddrMasters_0_w_payload_last    = axi_cnn_WLAST                 ;
// assign io_ddrMasters_0_w_valid           = axi_cnn_WVALID                ;
// assign axi_cnn_WREADY                    = io_ddrMasters_0_w_ready       ;
// assign axi_cnn_BID[CnnIdWidth-1:0]       = io_ddrMasters_0_b_payload_id  ;
// assign axi_cnn_BRESP                     = io_ddrMasters_0_b_payload_resp;
// assign axi_cnn_BVALID                    = io_ddrMasters_0_b_valid       ;
// assign io_ddrMasters_0_b_ready           = axi_cnn_BREADY                ;
// assign io_ddrMasters_0_ar_payload_id     = {1'b1, axi_cnn_ARID}          ;
// assign io_ddrMasters_0_ar_payload_addr   = axi_cnn_ARADDR                ;
// assign io_ddrMasters_0_ar_payload_len    = axi_cnn_ARLEN                 ;
// assign io_ddrMasters_0_ar_payload_size   = axi_cnn_ARSIZE                ;
// assign io_ddrMasters_0_ar_payload_burst  = axi_cnn_ARBURST               ;
// assign io_ddrMasters_0_ar_payload_lock   = axi_cnn_ARLOCK                ;
// assign io_ddrMasters_0_ar_payload_cache  = axi_cnn_ARCACHE               ;
// assign io_ddrMasters_0_ar_payload_prot   = axi_cnn_ARPROT                ;
// assign io_ddrMasters_0_ar_payload_qos    = axi_cnn_ARQOS                 ;
// assign io_ddrMasters_0_ar_payload_region = axi_cnn_ARREGION              ;
// assign io_ddrMasters_0_ar_valid          = axi_cnn_ARVALID               ;
// assign axi_cnn_ARREADY                   = io_ddrMasters_0_ar_ready      ;
// assign axi_cnn_RID[CnnIdWidth-1:0]       = io_ddrMasters_0_r_payload_id  ;
// assign axi_cnn_RDATA                     = io_ddrMasters_0_r_payload_data;
// assign axi_cnn_RRESP                     = io_ddrMasters_0_r_payload_resp;
// assign axi_cnn_RLAST                     = io_ddrMasters_0_r_payload_last;
// assign axi_cnn_RVALID                    = io_ddrMasters_0_r_valid       ;
// assign io_ddrMasters_0_r_ready           = axi_cnn_RREADY                ;






// wire [7:0] interconnet_s_bid;
// wire [7:0] interconnet_s_rid;


// efx_axi_interconnect u_efx_axi_interconnect(
//     .clk    ( prp_clk ),
//     .rst_n  ( soc_prp_reset_out ),
//     //SLAVE AXI
//     //AW
//     .s_axi_awvalid  ( {axi_cnn_AWVALID            , axi_cnn2_AWVALID             }),
//     .s_axi_awaddr   ( {axi_cnn_AWADDR             , axi_cnn2_AWADDR              }),
//     .s_axi_awlock   ( {axi_cnn_AWLOCK             , axi_cnn2_AWLOCK              }),
//     .s_axi_awready  ( {axi_cnn_AWREADY            , axi_cnn2_AWREADY             }),
//     .s_axi_awprot   ( {axi_cnn_AWPROT             , axi_cnn2_AWPROT              }),
//     .s_axi_awcache  ( {axi_cnn_AWCACHE            , axi_cnn2_AWCACHE             }),
//     .s_axi_awqos    ( {axi_cnn_AWQOS              , axi_cnn2_AWQOS               }),
//     .s_axi_awuser   ( {axi_cnn_AWUSER             , axi_cnn2_AWUSER              }),
//     // .s_axi_awid     ( 8'd0 ),
//     .s_axi_awid     ( {{1'b1,axi_cnn_AWID}        , {1'b0,axi_cnn2_AWID}         }),
//     .s_axi_awburst  ( {axi_cnn_AWBURST            , axi_cnn2_AWBURST             }),
//     .s_axi_awlen    ( {axi_cnn_AWLEN              , axi_cnn2_AWLEN               }),
//     .s_axi_awsize   ( {axi_cnn_AWSIZE             , axi_cnn2_AWSIZE              }),
//     //AR
//     .s_axi_arvalid  ( {axi_cnn_ARVALID            , axi_cnn2_ARVALID             }),
//     .s_axi_araddr   ( {axi_cnn_ARADDR             , axi_cnn2_ARADDR              }),
//     .s_axi_arlock   ( {axi_cnn_ARLOCK             , axi_cnn2_ARLOCK              }),
//     .s_axi_arready  ( {axi_cnn_ARREADY            , axi_cnn2_ARREADY             }),
//     .s_axi_arqos    ( {axi_cnn_ARQOS              , axi_cnn2_ARQOS               }),
//     .s_axi_arcache  ( {axi_cnn_ARCACHE            , axi_cnn2_ARCACHE             }),
//     .s_axi_arsize   ( {axi_cnn_ARSIZE             , axi_cnn2_ARSIZE              }),
//     // .s_axi_arid     ( 8'd0 ),
//     .s_axi_arid     ( {{1'b1,axi_cnn_ARID}        , {1'b0,axi_cnn2_ARID}         }),
//     .s_axi_arlen    ( {axi_cnn_ARLEN              , axi_cnn2_ARLEN               }),
//     .s_axi_arburst  ( {axi_cnn_ARBURST            , axi_cnn2_ARBURST             }),
//     .s_axi_arprot   ( {axi_cnn_ARPROT             , axi_cnn2_ARPROT              }),
//     .s_axi_aruser   ( {axi_cnn_ARUSER             , axi_cnn2_ARUSER              }),
//     //RESPONSE
//     .s_axi_bready   ( {axi_cnn_BREADY             , axi_cnn2_BREADY              }),
//     .s_axi_bresp    ( {axi_cnn_BRESP              , axi_cnn2_BRESP               }),
//     .s_axi_bid      ( interconnet_s_bid ),
//     // .s_axi_bid      ( {axi_cnn_BID[CnnIdWidth-1:0], axi_cnn2_BID[CnnIdWidth-1:0] }),
//     .s_axi_bvalid   ( {axi_cnn_BVALID             , axi_cnn2_BVALID              }),
//     .s_axi_buser    ( {axi_cnn_BUSER              , axi_cnn2_BUSER               }),
//     //W
//     .s_axi_wvalid   ( {axi_cnn_WVALID             , axi_cnn2_WVALID              }),
//     .s_axi_wlast    ( {axi_cnn_WLAST              , axi_cnn2_WLAST               }),
//     .s_axi_wid      ( {axi_cnn_WID                , axi_cnn2_WID                 }),
//     .s_axi_wdata    ( {axi_cnn_WDATA              , axi_cnn2_WDATA               }),
//     .s_axi_wstrb    ( {axi_cnn_WSTRB              , axi_cnn2_WSTRB               }),
//     .s_axi_wready   ( {axi_cnn_WREADY             , axi_cnn2_WREADY              }),
//     .s_axi_wuser    ( {axi_cnn_WUSER              , axi_cnn2_WUSER               } ),
//     //R
//     .s_axi_rid      ( interconnet_s_rid ),
//     // .s_axi_rid      ( {axi_cnn_RID[CnnIdWidth-1:0], axi_cnn2_RID[CnnIdWidth-1:0] }),
//     .s_axi_rready   ( {axi_cnn_RREADY             , axi_cnn2_RREADY              }),
//     .s_axi_rdata    ( {axi_cnn_RDATA              , axi_cnn2_RDATA               }),
//     .s_axi_rresp    ( {axi_cnn_RRESP              , axi_cnn2_RRESP               }),
//     .s_axi_rvalid   ( {axi_cnn_RVALID             , axi_cnn2_RVALID              }),
//     .s_axi_rlast    ( {axi_cnn_RLAST              , axi_cnn2_RLAST               }),
//     .s_axi_ruser    ( {axi_cnn_RUSER              , axi_cnn2_RUSER               }),
    
//     //AW
//     .m_axi_awvalid  ( io_ddrMasters_0_aw_valid           ),
//     .m_axi_awaddr   ( io_ddrMasters_0_aw_payload_addr    ),
//     .m_axi_awlock   ( io_ddrMasters_0_aw_payload_lock    ),
//     .m_axi_awready  ( io_ddrMasters_0_aw_ready           ),
//     .m_axi_awprot   ( io_ddrMasters_0_aw_payload_prot    ),
//     // .m_axi_awid     (       ),
//     .m_axi_awid     ( io_ddrMasters_0_aw_payload_id      ),
//     .m_axi_awburst  ( io_ddrMasters_0_aw_payload_burst   ),
//     .m_axi_awlen    ( io_ddrMasters_0_aw_payload_len     ),
//     .m_axi_awsize   ( io_ddrMasters_0_aw_payload_size    ),
//     .m_axi_awcache  ( io_ddrMasters_0_aw_payload_cache   ),
//     .m_axi_awqos    ( io_ddrMasters_0_aw_payload_qos     ),
//     .m_axi_awuser   ( axi_inter_m_awuser ),
//     .m_axi_awregion ( io_ddrMasters_0_aw_payload_region  ),
//     //AR   
//     .m_axi_arvalid  ( io_ddrMasters_0_ar_valid           ),
//     .m_axi_araddr   ( io_ddrMasters_0_ar_payload_addr    ),
//     .m_axi_arlock   ( io_ddrMasters_0_ar_payload_lock    ),
//     .m_axi_arready  ( io_ddrMasters_0_ar_ready           ),
//     .m_axi_arprot   ( io_ddrMasters_0_ar_payload_prot    ),
//     .m_axi_arburst  ( io_ddrMasters_0_ar_payload_burst   ),
//     .m_axi_arlen    ( io_ddrMasters_0_ar_payload_len     ),
//     .m_axi_arsize   ( io_ddrMasters_0_ar_payload_size    ),
//     .m_axi_arcache  ( io_ddrMasters_0_ar_payload_cache   ),
//     .m_axi_arqos    ( io_ddrMasters_0_ar_payload_qos     ),
//     .m_axi_aruser   ( axi_inter_m_aruser ),
//     .m_axi_arregion ( io_ddrMasters_0_ar_payload_region  ),
//     // .m_axi_arid     (       ),  
//     .m_axi_arid     ( io_ddrMasters_0_ar_payload_id      ),  
//     //RESPONSE 
//     .m_axi_bready   ( io_ddrMasters_0_b_ready            ),
//     .m_axi_bresp    ( io_ddrMasters_0_b_payload_resp     ),  
//     .m_axi_bid      ( io_ddrMasters_0_b_payload_id       ),
//     .m_axi_bvalid   ( io_ddrMasters_0_b_valid            ),
//     .m_axi_buser    ( axi_inter_m_buser ),
//     //W
//     .m_axi_wvalid   ( io_ddrMasters_0_w_valid            ),
//     .m_axi_wlast    ( io_ddrMasters_0_w_payload_last     ),
//     .m_axi_wdata    ( io_ddrMasters_0_w_payload_data     ),
//     .m_axi_wstrb    ( io_ddrMasters_0_w_payload_strb     ),
//     .m_axi_wready   ( io_ddrMasters_0_w_ready            ),
//     .m_axi_wuser    ( axi_inter_m_wuser ),
//     //R
//     .m_axi_rready   ( io_ddrMasters_0_r_ready            ),
//     .m_axi_rid      ( io_ddrMasters_0_r_payload_id       ),
//     .m_axi_rdata    ( io_ddrMasters_0_r_payload_data     ),
//     .m_axi_rresp    ( io_ddrMasters_0_r_payload_resp     ),
//     .m_axi_rvalid   ( io_ddrMasters_0_r_valid            ),
//     .m_axi_rlast    ( io_ddrMasters_0_r_payload_last     ),
//     .m_axi_ruser    ( axi_inter_m_ruser )
// );

// assign axi_cnn_BID = interconnet_s_bid[6:4];
// assign axi_cnn_RID = interconnet_s_rid[6:4];
// assign axi_cnn2_BID = interconnet_s_bid[2:0];
// assign axi_cnn2_RID = interconnet_s_rid[2:0];





// assign debug_cam_display_fifo_status = {
//     // axi_inter_m_rid,
//     1'b0, axi_cnn_RID, 1'b0, axi_cnn_BID,

//     io_ddrMasters_0_ar_payload_id, io_ddrMasters_0_aw_payload_id, 
//      io_ddrMasters_0_r_payload_id, io_ddrMasters_0_b_payload_id,
//     1'b1, axi_cnn_ARID, 1'b0, axi_cnn2_ARID
// };

// // assign debug_dma_hw_accel_in_fifo_wcount = {
// //     axi_cnn_AWCACHE, axi_cnn2_AWCACHE,
// //     1'b0, axi_cnn_AWSIZE, 1'b0, axi_cnn2_AWSIZE, 
// //     1'b0, axi_cnn_AWPROT, 1'b0, axi_cnn2_AWPROT,
// //     2'b0, axi_cnn_AWBURST, 3'b0, io_ddrMasters_0_aw_payload_lock
// // };


// assign debug_dma_hw_accel_out_fifo_rcount = {
//     // axi_cnn_ARCACHE, axi_cnn2_ARCACHE,
//     // 1'b0, axi_cnn_ARSIZE, 1'b0, axi_cnn2_ARSIZE, 
//     // 1'b0, axi_cnn_ARPROT, 1'b0, axi_cnn2_ARPROT,
//     io_ddrMasters_0_aw_payload_len, 

//     io_ddrMasters_0_aw_payload_cache, 
//     io_ddrMasters_0_aw_payload_burst, 1'b0, io_ddrMasters_0_aw_payload_lock, 
//     io_ddrMasters_0_r_payload_id, io_ddrMasters_0_b_payload_id,
//     1'b0, io_ddrMasters_0_aw_payload_size, 1'b0, io_ddrMasters_0_aw_payload_prot
// };


// axi4_id_seq #(
//     .AXI_DATA_WIDTH     (CnnDataWidth),
//     .AXI_ADDR_WIDTH     (32          ),
//     .AXI_ID_WIDTH       (CnnIdWidth  ),
//     .S_COUNT            (2           )
// ) u_axi4_id_seq (

//     .axi_clk             ( prp_clk              ),
//     .axi_rstn            ( soc_prp_reset_out    ),

//     .s_axi_awaddr        ( axi_inter_m_awaddr   ),
//     .s_axi_awid          ( axi_inter_m_awid     ),
//     .s_axi_awlen         ( axi_inter_m_awlen    ),
//     .s_axi_awsize        ( axi_inter_m_awsize   ),
//     .s_axi_awvalid       ( axi_inter_m_awvalid  ),
//     .s_axi_awready       ( axi_inter_m_awready  ),

//     .s_axi_araddr        ( axi_inter_m_araddr   ),
//     .s_axi_arid          ( axi_inter_m_arid     ),
//     .s_axi_arlen         ( axi_inter_m_arlen    ),
//     .s_axi_arsize        ( axi_inter_m_arsize   ),
//     .s_axi_arvalid       ( axi_inter_m_arvalid  ),
//     .s_axi_arready       ( axi_inter_m_arready  ),

//     .s_axi_bresp         ( axi_inter_m_bresp    ),
//     .s_axi_bid           ( axi_inter_m_bid      ),
//     .s_axi_bvalid        ( axi_inter_m_bvalid   ),
//     .s_axi_bready        ( axi_inter_m_bready   ),

//     .s_axi_wdata         ( axi_inter_m_wdata    ),
//     .s_axi_wlast         ( axi_inter_m_wlast    ),
//     .s_axi_wvalid        ( axi_inter_m_wvalid   ),
//     .s_axi_wready        ( axi_inter_m_wready   ),
//     .s_axi_wstrb         ( axi_inter_m_wstrb    ),

//     .s_axi_rid           ( axi_inter_m_rid      ),
//     .s_axi_rdata         ( axi_inter_m_rdata    ),
//     .s_axi_rresp         ( axi_inter_m_rresp    ),
//     .s_axi_rlast         ( axi_inter_m_rlast    ),
//     .s_axi_rvalid        ( axi_inter_m_rvalid   ),
//     .s_axi_rready        ( axi_inter_m_rready   ),

//     //AW
//     .m_axi_awaddr        ( io_ddrMasters_0_aw_payload_addr    ),
//     .m_axi_awid          ( io_ddrMasters_0_aw_payload_id      ),
//     .m_axi_awlen         ( io_ddrMasters_0_aw_payload_len     ),
//     .m_axi_awsize        ( io_ddrMasters_0_aw_payload_size    ),
//     .m_axi_awvalid       ( io_ddrMasters_0_aw_valid           ),
//     .m_axi_awready       ( io_ddrMasters_0_aw_ready           ),
//     //AR   
//     .m_axi_araddr        ( io_ddrMasters_0_ar_payload_addr    ),
//     .m_axi_arid          ( io_ddrMasters_0_ar_payload_id      ),  
//     .m_axi_arlen         ( io_ddrMasters_0_ar_payload_len     ),
//     .m_axi_arsize        ( io_ddrMasters_0_ar_payload_size    ),
//     .m_axi_arvalid       ( io_ddrMasters_0_ar_valid           ),
//     .m_axi_arready       ( io_ddrMasters_0_ar_ready           ),
//     //RESPONSE 
//     .m_axi_bid           ( io_ddrMasters_0_b_payload_id       ),
//     .m_axi_bresp         ( io_ddrMasters_0_b_payload_resp     ),  
//     .m_axi_bready        ( io_ddrMasters_0_b_ready            ),
//     .m_axi_bvalid        ( io_ddrMasters_0_b_valid            ),
//     //W
//     .m_axi_wdata         ( io_ddrMasters_0_w_payload_data     ),
//     .m_axi_wlast         ( io_ddrMasters_0_w_payload_last     ),
//     .m_axi_wstrb         ( io_ddrMasters_0_w_payload_strb     ),
//     .m_axi_wvalid        ( io_ddrMasters_0_w_valid            ),
//     .m_axi_wready        ( io_ddrMasters_0_w_ready            ),
//     //R
//     .m_axi_rid           ( io_ddrMasters_0_r_payload_id       ),
//     .m_axi_rdata         ( io_ddrMasters_0_r_payload_data     ),
//     .m_axi_rresp         ( io_ddrMasters_0_r_payload_resp     ),
//     .m_axi_rlast         ( io_ddrMasters_0_r_payload_last     ),
//     .m_axi_rvalid        ( io_ddrMasters_0_r_valid            ),
//     .m_axi_rready        ( io_ddrMasters_0_r_ready            )
// );


// axi_interconnect_beta #(
//     .S_COUNT              (2),
//     .SLAVE_ASYN_ARRAY     ({2{1'b0}}),
//     .S_AXI_DW_ARRAY       ({2{CnnDataWidth}}),
//     .CB_DW                (CnnDataWidth),
//     .M_AXI_DW             (CnnDataWidth),
//     .ARB_MODE             (1),
//     .FAMILY               ("TITANIUM"),
//     .RD_QUEUE_FIFO_RAM_STYLE ("block_ram"),
//     .RD_QUEUE_FIFO_DEPTH  (512)
// ) inst_axi_nto1 (

//     .s_axi_clk      ( {prp_clk                    , prp_clk                      }),
//     .s_axi_rstn     ( {soc_prp_reset_out          , soc_prp_reset_out            }),
//     //AW
//     .s_axi_awvalid  ( {axi_cnn_AWVALID            , axi_cnn2_AWVALID             }),
//     .s_axi_awaddr   ( {axi_cnn_AWADDR             , axi_cnn2_AWADDR              }),
//     .s_axi_awready  ( {axi_cnn_AWREADY            , axi_cnn2_AWREADY             }),
//     .s_axi_awlen    ( {axi_cnn_AWLEN              , axi_cnn2_AWLEN               }),
//     //AR
//     .s_axi_arvalid  ( {axi_cnn_ARVALID            , axi_cnn2_ARVALID             }),
//     .s_axi_araddr   ( {axi_cnn_ARADDR             , axi_cnn2_ARADDR              }),
//     .s_axi_arready  ( {axi_cnn_ARREADY            , axi_cnn2_ARREADY             }),
//     .s_axi_arlen    ( {axi_cnn_ARLEN              , axi_cnn2_ARLEN               }),
//     //RESPONSE
//     .s_axi_bready   ( {axi_cnn_BREADY             , axi_cnn2_BREADY              }),
//     .s_axi_bresp    ( {axi_cnn_BRESP              , axi_cnn2_BRESP               }),
//     .s_axi_bvalid   ( {axi_cnn_BVALID             , axi_cnn2_BVALID              }),
//     //W
//     .s_axi_wvalid   ( {axi_cnn_WVALID             , axi_cnn2_WVALID              }),
//     .s_axi_wlast    ( {axi_cnn_WLAST              , axi_cnn2_WLAST               }),
//     .s_axi_wdata    ( {axi_cnn_WDATA              , axi_cnn2_WDATA               }),
//     .s_axi_wstrb    ( {axi_cnn_WSTRB              , axi_cnn2_WSTRB               }),
//     .s_axi_wready   ( {axi_cnn_WREADY             , axi_cnn2_WREADY              }),
//     //R
//     .s_axi_rready   ( {axi_cnn_RREADY             , axi_cnn2_RREADY              }),
//     .s_axi_rdata    ( {axi_cnn_RDATA              , axi_cnn2_RDATA               }),
//     .s_axi_rresp    ( {axi_cnn_RRESP              , axi_cnn2_RRESP               }),
//     .s_axi_rvalid   ( {axi_cnn_RVALID             , axi_cnn2_RVALID              }),
//     .s_axi_rlast    ( {axi_cnn_RLAST              , axi_cnn2_RLAST               }),
    

//     .m_axi_clk      ( prp_clk                            ),
//     .m_axi_rstn     ( soc_prp_reset_out                  ),
//     //AW
//     .m_axi_awaddr   ( axi_inter_m_awaddr                 ),
//     // .m_axi_awid     ( axi_inter_m_awid                   ),
//     .m_axi_awlen    ( axi_inter_m_awlen                  ),
//     .m_axi_awsize   ( axi_inter_m_awsize                 ),
//     .m_axi_awvalid  ( axi_inter_m_awvalid                ),
//     .m_axi_awready  ( axi_inter_m_awready                ),
//     .m_axi_awlock   ( io_ddrMasters_0_aw_payload_lock    ),
//     .m_axi_awprot   ( io_ddrMasters_0_aw_payload_prot    ),
//     .m_axi_awburst  ( io_ddrMasters_0_aw_payload_burst   ),
//     .m_axi_awcache  ( io_ddrMasters_0_aw_payload_cache   ),
//     // .m_axi_awqos    ( io_ddrMasters_0_aw_payload_qos     ),
//     // .m_axi_awregion ( io_ddrMasters_0_aw_payload_region  ),
//     //AR   
//     .m_axi_araddr   ( axi_inter_m_araddr                 ),
//     // .m_axi_arid     ( axi_inter_m_arid                   ),  
//     .m_axi_arlen    ( axi_inter_m_arlen                  ),
//     .m_axi_arsize   ( axi_inter_m_arsize                 ),
//     .m_axi_arvalid  ( axi_inter_m_arvalid                ),
//     .m_axi_arready  ( axi_inter_m_arready                ),
//     .m_axi_arlock   ( io_ddrMasters_0_ar_payload_lock    ),
//     .m_axi_arprot   ( io_ddrMasters_0_ar_payload_prot    ),
//     .m_axi_arburst  ( io_ddrMasters_0_ar_payload_burst   ),
//     .m_axi_arcache  ( io_ddrMasters_0_ar_payload_cache   ),
//     // .m_axi_arqos    ( io_ddrMasters_0_ar_payload_qos     ),
//     // .m_axi_arregion ( io_ddrMasters_0_ar_payload_region  ),
//     //RESPONSE 
//     .m_axi_bready   ( axi_inter_m_bready                 ),
//     .m_axi_bresp    ( axi_inter_m_bresp                  ),  
//     .m_axi_bvalid   ( axi_inter_m_bvalid                 ),
//     // .m_axi_bid      ( axi_inter_m_bid                    ),
//     //W
//     .m_axi_wvalid   ( axi_inter_m_wvalid                 ),
//     .m_axi_wready   ( axi_inter_m_wready                 ),
//     .m_axi_wlast    ( axi_inter_m_wlast                  ),
//     .m_axi_wdata    ( axi_inter_m_wdata                  ),
//     .m_axi_wstrb    ( axi_inter_m_wstrb                  ),
//     //R
//     .m_axi_rready   ( axi_inter_m_rready                 ),
//     .m_axi_rvalid   ( axi_inter_m_rvalid                 ),
//     .m_axi_rdata    ( axi_inter_m_rdata                  ),
//     .m_axi_rresp    ( axi_inter_m_rresp                  ),
//     // .m_axi_rid      ( axi_inter_m_rid                    ),
//     .m_axi_rlast    ( axi_inter_m_rlast                  )
// );



axi_interconnect #(
    .S_COUNT                 (CNNCount),
    .AXI_DW                  (CnnDataWidth),
    .AXI_AW                  (32),
    .FAMILY                  ("TITANIUM"),
    .RD_QUEUE_FIFO_RAM_STYLE ("block_ram"),
    .S_AXI_CMD_REG_EN        (1),
    .S_BUFFER_EN             ({CNNCount{1'b1}}),
    .RD_QUEUE_FIFO_DEPTH     (512)

// axi_interconnect_beta #(
//     .S_COUNT              (CNNCount),
//     .SLAVE_ASYN_ARRAY     ({CNNCount{1'b0}}),
//     .S_AXI_DW_ARRAY       ({CNNCount{CnnDataWidth}}),
//     .CB_DW                (CnnDataWidth),
//     .M_AXI_DW             (CnnDataWidth),
//     .ARB_MODE             (1),
//     .FAMILY               ("TITANIUM"),
//     .RD_QUEUE_FIFO_RAM_STYLE ("block_ram"),
//     .RD_QUEUE_FIFO_DEPTH  (512)
) inst_axi_nto1 (

    .clk      ( prp_clk                           ),
    .rstn     ( soc_prp_reset_out                 ),
    // .s_axi_clk      ( {CNNCount{prp_clk          }} ),
    // .s_axi_rstn     ( {CNNCount{soc_prp_reset_out}} ),
    // .m_axi_clk      ( prp_clk                            ),
    // .m_axi_rstn     ( soc_prp_reset_out                  ),

    //AW
    .s_axi_awvalid  ( axi_inter_m_awvalid ),
    .s_axi_awaddr   ( axi_inter_m_awaddr  ),
    .s_axi_awready  ( axi_inter_m_awready ),
    .s_axi_awlen    ( axi_inter_m_awlen   ),
    //AR
    .s_axi_arvalid  ( axi_inter_m_arvalid ),
    .s_axi_araddr   ( axi_inter_m_araddr  ),
    .s_axi_arready  ( axi_inter_m_arready ),
    .s_axi_arlen    ( axi_inter_m_arlen   ),
    //RESPONSE
    .s_axi_bready   ( axi_inter_m_bready  ),
    .s_axi_bresp    ( axi_inter_m_bresp   ),
    .s_axi_bvalid   ( axi_inter_m_bvalid  ),
    //W
    .s_axi_wvalid   ( axi_inter_m_wvalid  ),
    .s_axi_wlast    ( axi_inter_m_wlast   ),
    .s_axi_wdata    ( axi_inter_m_wdata   ),
    .s_axi_wstrb    ( axi_inter_m_wstrb   ),
    .s_axi_wready   ( axi_inter_m_wready  ),
    //R
    .s_axi_rready   ( axi_inter_m_rready  ),
    .s_axi_rdata    ( axi_inter_m_rdata   ),
    .s_axi_rresp    ( axi_inter_m_rresp   ),
    .s_axi_rvalid   ( axi_inter_m_rvalid  ),
    .s_axi_rlast    ( axi_inter_m_rlast   ),
    

    //AW
    .m_axi_awaddr   ( io_ddrMasters_0_aw_payload_addr    ),
    .m_axi_awid     ( io_ddrMasters_0_aw_payload_id      ),
    .m_axi_awlen    ( io_ddrMasters_0_aw_payload_len     ),
    .m_axi_awsize   ( io_ddrMasters_0_aw_payload_size    ),
    .m_axi_awvalid  ( io_ddrMasters_0_aw_valid           ),
    .m_axi_awready  ( io_ddrMasters_0_aw_ready           ),
    .m_axi_awlock   ( io_ddrMasters_0_aw_payload_lock    ),
    .m_axi_awprot   ( io_ddrMasters_0_aw_payload_prot    ),
    .m_axi_awburst  ( io_ddrMasters_0_aw_payload_burst   ),
    .m_axi_awcache  ( io_ddrMasters_0_aw_payload_cache   ),
    // .m_axi_awqos    ( io_ddrMasters_0_aw_payload_qos     ),
    // .m_axi_awregion ( io_ddrMasters_0_aw_payload_region  ),
    //AR   
    .m_axi_araddr   ( io_ddrMasters_0_ar_payload_addr    ),
    .m_axi_arid     ( io_ddrMasters_0_ar_payload_id      ),  
    .m_axi_arlen    ( io_ddrMasters_0_ar_payload_len     ),
    .m_axi_arsize   ( io_ddrMasters_0_ar_payload_size    ),
    .m_axi_arvalid  ( io_ddrMasters_0_ar_valid           ),
    .m_axi_arready  ( io_ddrMasters_0_ar_ready           ),
    .m_axi_arlock   ( io_ddrMasters_0_ar_payload_lock    ),
    .m_axi_arprot   ( io_ddrMasters_0_ar_payload_prot    ),
    .m_axi_arburst  ( io_ddrMasters_0_ar_payload_burst   ),
    .m_axi_arcache  ( io_ddrMasters_0_ar_payload_cache   ),
    // .m_axi_arqos    ( io_ddrMasters_0_ar_payload_qos     ),
    // .m_axi_arregion ( io_ddrMasters_0_ar_payload_region  ),
    //RESPONSE 
    .m_axi_bready   ( io_ddrMasters_0_b_ready            ),
    .m_axi_bresp    ( io_ddrMasters_0_b_payload_resp     ),  
    .m_axi_bvalid   ( io_ddrMasters_0_b_valid            ),
    //W
    .m_axi_wvalid   ( io_ddrMasters_0_w_valid            ),
    .m_axi_wready   ( io_ddrMasters_0_w_ready            ),
    .m_axi_wlast    ( io_ddrMasters_0_w_payload_last     ),
    .m_axi_wdata    ( io_ddrMasters_0_w_payload_data     ),
    .m_axi_wstrb    ( io_ddrMasters_0_w_payload_strb     ),
    //R
    .m_axi_rready   ( io_ddrMasters_0_r_ready            ),
    .m_axi_rvalid   ( io_ddrMasters_0_r_valid            ),
    .m_axi_rdata    ( io_ddrMasters_0_r_payload_data     ),
    .m_axi_rresp    ( io_ddrMasters_0_r_payload_resp     ),
    .m_axi_rlast    ( io_ddrMasters_0_r_payload_last     )
);

axi4_id_seq #(
    .AXI_DATA_WIDTH     (CnnDataWidth),
    .AXI_ADDR_WIDTH     (32          ),
    .AXI_ID_WIDTH       (CnnIdWidth  ),
    .S_COUNT            (CNNCount    )
) u_axi4_id_seq (
    .axi_clk             ( prp_clk              ),
    .axi_rstn            ( soc_prp_reset_out    ),

    .s_axi_awaddr        ( {axi_cnn_AWADDR  , axi_cnn2_AWADDR  , axi_cnn3_AWADDR  } ),
    .s_axi_awid          ( {axi_cnn_AWID    , axi_cnn2_AWID    , axi_cnn3_AWID    } ),
    .s_axi_awlen         ( {axi_cnn_AWLEN   , axi_cnn2_AWLEN   , axi_cnn3_AWLEN   } ),
    .s_axi_awvalid       ( {axi_cnn_AWVALID , axi_cnn2_AWVALID , axi_cnn3_AWVALID } ),
    .s_axi_awready       ( {axi_cnn_AWREADY , axi_cnn2_AWREADY , axi_cnn3_AWREADY } ),
    .s_axi_araddr        ( {axi_cnn_ARADDR  , axi_cnn2_ARADDR  , axi_cnn3_ARADDR  } ),
    .s_axi_arid          ( {axi_cnn_ARID    , axi_cnn2_ARID    , axi_cnn3_ARID    } ),
    .s_axi_arlen         ( {axi_cnn_ARLEN   , axi_cnn2_ARLEN   , axi_cnn3_ARLEN   } ),
    .s_axi_arvalid       ( {axi_cnn_ARVALID , axi_cnn2_ARVALID , axi_cnn3_ARVALID } ),
    .s_axi_arready       ( {axi_cnn_ARREADY , axi_cnn2_ARREADY , axi_cnn3_ARREADY } ),
    .s_axi_bresp         ( {axi_cnn_BRESP   , axi_cnn2_BRESP   , axi_cnn3_BRESP   } ),
    .s_axi_bid           ( {axi_cnn_BID     , axi_cnn2_BID     , axi_cnn3_BID     } ),
    .s_axi_bvalid        ( {axi_cnn_BVALID  , axi_cnn2_BVALID  , axi_cnn3_BVALID  } ),
    .s_axi_bready        ( {axi_cnn_BREADY  , axi_cnn2_BREADY  , axi_cnn3_BREADY  } ),
    .s_axi_wdata         ( {axi_cnn_WDATA   , axi_cnn2_WDATA   , axi_cnn3_WDATA   } ),
    .s_axi_wlast         ( {axi_cnn_WLAST   , axi_cnn2_WLAST   , axi_cnn3_WLAST   } ),
    .s_axi_wvalid        ( {axi_cnn_WVALID  , axi_cnn2_WVALID  , axi_cnn3_WVALID  } ),
    .s_axi_wready        ( {axi_cnn_WREADY  , axi_cnn2_WREADY  , axi_cnn3_WREADY  } ),
    .s_axi_wstrb         ( {axi_cnn_WSTRB   , axi_cnn2_WSTRB   , axi_cnn3_WSTRB   } ),
    .s_axi_rid           ( {axi_cnn_RID     , axi_cnn2_RID     , axi_cnn3_RID     } ),
    .s_axi_rdata         ( {axi_cnn_RDATA   , axi_cnn2_RDATA   , axi_cnn3_RDATA   } ),
    .s_axi_rresp         ( {axi_cnn_RRESP   , axi_cnn2_RRESP   , axi_cnn3_RRESP   } ),
    .s_axi_rlast         ( {axi_cnn_RLAST   , axi_cnn2_RLAST   , axi_cnn3_RLAST   } ),
    .s_axi_rvalid        ( {axi_cnn_RVALID  , axi_cnn2_RVALID  , axi_cnn3_RVALID  } ),
    .s_axi_rready        ( {axi_cnn_RREADY  , axi_cnn2_RREADY  , axi_cnn3_RREADY  } ),

    .m_axi_awaddr        ( axi_inter_m_awaddr    ),
    .m_axi_awlen         ( axi_inter_m_awlen     ),
    .m_axi_awvalid       ( axi_inter_m_awvalid   ),
    .m_axi_awready       ( axi_inter_m_awready   ), 
    .m_axi_araddr        ( axi_inter_m_araddr    ),
    .m_axi_arlen         ( axi_inter_m_arlen     ),
    .m_axi_arvalid       ( axi_inter_m_arvalid   ),
    .m_axi_arready       ( axi_inter_m_arready   ), 
    .m_axi_bresp         ( axi_inter_m_bresp     ),  
    .m_axi_bready        ( axi_inter_m_bready    ),
    .m_axi_bvalid        ( axi_inter_m_bvalid    ),
    .m_axi_wdata         ( axi_inter_m_wdata     ),
    .m_axi_wlast         ( axi_inter_m_wlast     ),
    .m_axi_wstrb         ( axi_inter_m_wstrb     ),
    .m_axi_wvalid        ( axi_inter_m_wvalid    ),
    .m_axi_wready        ( axi_inter_m_wready    ),
    .m_axi_rdata         ( axi_inter_m_rdata     ),
    .m_axi_rresp         ( axi_inter_m_rresp     ),
    .m_axi_rlast         ( axi_inter_m_rlast     ),
    .m_axi_rvalid        ( axi_inter_m_rvalid    ),
    .m_axi_rready        ( axi_inter_m_rready    )
);


// axi4_id_seq_ori #(
//     .AXI_DATA_WIDTH     (CnnDataWidth),
//     .AXI_ADDR_WIDTH     (32          ),
//     .AXI_ID_WIDTH       (CnnIdWidth  )
// ) u_axi4_id_seq_0 (
//     .axi_clk             ( prp_clk              ),
//     .axi_rstn            ( soc_prp_reset_out    ),

//     .s_axi_awaddr        ( axi_cnn_AWADDR  ),
//     .s_axi_awid          ( axi_cnn_AWID    ),
//     .s_axi_awlen         ( axi_cnn_AWLEN   ),
//     .s_axi_awvalid       ( axi_cnn_AWVALID ),
//     .s_axi_awready       ( axi_cnn_AWREADY ),
//     .s_axi_araddr        ( axi_cnn_ARADDR  ),
//     .s_axi_arid          ( axi_cnn_ARID    ),
//     .s_axi_arlen         ( axi_cnn_ARLEN   ),
//     .s_axi_arvalid       ( axi_cnn_ARVALID ),
//     .s_axi_arready       ( axi_cnn_ARREADY ),
//     .s_axi_bresp         ( axi_cnn_BRESP   ),
//     .s_axi_bid           ( axi_cnn_BID     ),
//     .s_axi_bvalid        ( axi_cnn_BVALID  ),
//     .s_axi_bready        ( axi_cnn_BREADY  ),
//     .s_axi_wdata         ( axi_cnn_WDATA   ),
//     .s_axi_wlast         ( axi_cnn_WLAST   ),
//     .s_axi_wvalid        ( axi_cnn_WVALID  ),
//     .s_axi_wready        ( axi_cnn_WREADY  ),
//     .s_axi_wstrb         ( axi_cnn_WSTRB   ),
//     .s_axi_rid           ( axi_cnn_RID     ),
//     .s_axi_rdata         ( axi_cnn_RDATA   ),
//     .s_axi_rresp         ( axi_cnn_RRESP   ),
//     .s_axi_rlast         ( axi_cnn_RLAST   ),
//     .s_axi_rvalid        ( axi_cnn_RVALID  ),
//     .s_axi_rready        ( axi_cnn_RREADY  ),

//     .m_axi_awaddr        ( axi_inter_m_awaddr   [31:0] ),
//     .m_axi_awlen         ( axi_inter_m_awlen    [7:0] ),
//     .m_axi_awvalid       ( axi_inter_m_awvalid  [0] ),
//     .m_axi_awready       ( axi_inter_m_awready  [0] ), 
//     .m_axi_araddr        ( axi_inter_m_araddr   [31:0] ),
//     .m_axi_arlen         ( axi_inter_m_arlen    [7:0] ),
//     .m_axi_arvalid       ( axi_inter_m_arvalid  [0] ),
//     .m_axi_arready       ( axi_inter_m_arready  [0] ), 
//     .m_axi_bresp         ( axi_inter_m_bresp    [1:0] ),  
//     .m_axi_bready        ( axi_inter_m_bready   [0] ),
//     .m_axi_bvalid        ( axi_inter_m_bvalid   [0] ),
//     .m_axi_wdata         ( axi_inter_m_wdata    [CnnDataWidth-1:0] ),
//     .m_axi_wlast         ( axi_inter_m_wlast    [0] ),
//     .m_axi_wstrb         ( axi_inter_m_wstrb    [CnnStrbWidth-1:0] ),
//     .m_axi_wvalid        ( axi_inter_m_wvalid   [0] ),
//     .m_axi_wready        ( axi_inter_m_wready   [0] ),
//     .m_axi_rdata         ( axi_inter_m_rdata    [CnnDataWidth-1:0] ),
//     .m_axi_rresp         ( axi_inter_m_rresp    [1:0] ),
//     .m_axi_rlast         ( axi_inter_m_rlast    [0] ),
//     .m_axi_rvalid        ( axi_inter_m_rvalid   [0] ),
//     .m_axi_rready        ( axi_inter_m_rready   [0] )
// );


// axi4_id_seq_ori #(
//     .AXI_DATA_WIDTH     (CnnDataWidth),
//     .AXI_ADDR_WIDTH     (32          ),
//     .AXI_ID_WIDTH       (CnnIdWidth  )
// ) u_axi4_id_seq_1 (
//     .axi_clk             ( prp_clk              ),
//     .axi_rstn            ( soc_prp_reset_out    ),

//     .s_axi_awaddr        ( axi_cnn2_AWADDR  ),
//     .s_axi_awid          ( axi_cnn2_AWID    ),
//     .s_axi_awlen         ( axi_cnn2_AWLEN   ),
//     .s_axi_awvalid       ( axi_cnn2_AWVALID ),
//     .s_axi_awready       ( axi_cnn2_AWREADY ),
//     .s_axi_araddr        ( axi_cnn2_ARADDR  ),
//     .s_axi_arid          ( axi_cnn2_ARID    ),
//     .s_axi_arlen         ( axi_cnn2_ARLEN   ),
//     .s_axi_arvalid       ( axi_cnn2_ARVALID ),
//     .s_axi_arready       ( axi_cnn2_ARREADY ),
//     .s_axi_bresp         ( axi_cnn2_BRESP   ),
//     .s_axi_bid           ( axi_cnn2_BID     ),
//     .s_axi_bvalid        ( axi_cnn2_BVALID  ),
//     .s_axi_bready        ( axi_cnn2_BREADY  ),
//     .s_axi_wdata         ( axi_cnn2_WDATA   ),
//     .s_axi_wlast         ( axi_cnn2_WLAST   ),
//     .s_axi_wvalid        ( axi_cnn2_WVALID  ),
//     .s_axi_wready        ( axi_cnn2_WREADY  ),
//     .s_axi_wstrb         ( axi_cnn2_WSTRB   ),
//     .s_axi_rid           ( axi_cnn2_RID     ),
//     .s_axi_rdata         ( axi_cnn2_RDATA   ),
//     .s_axi_rresp         ( axi_cnn2_RRESP   ),
//     .s_axi_rlast         ( axi_cnn2_RLAST   ),
//     .s_axi_rvalid        ( axi_cnn2_RVALID  ),
//     .s_axi_rready        ( axi_cnn2_RREADY  ),

//     .m_axi_awaddr        ( axi_inter_m_awaddr   [63:32] ),
//     .m_axi_awlen         ( axi_inter_m_awlen    [15:8] ),
//     .m_axi_awvalid       ( axi_inter_m_awvalid  [1] ),
//     .m_axi_awready       ( axi_inter_m_awready  [1] ), 
//     .m_axi_araddr        ( axi_inter_m_araddr   [63:32] ),
//     .m_axi_arlen         ( axi_inter_m_arlen    [15:8] ),
//     .m_axi_arvalid       ( axi_inter_m_arvalid  [1] ),
//     .m_axi_arready       ( axi_inter_m_arready  [1] ), 
//     .m_axi_bresp         ( axi_inter_m_bresp    [3:2] ),  
//     .m_axi_bready        ( axi_inter_m_bready   [1] ),
//     .m_axi_bvalid        ( axi_inter_m_bvalid   [1] ),
//     .m_axi_wdata         ( axi_inter_m_wdata    [CnnDataWidth*2-1:CnnDataWidth] ),
//     .m_axi_wlast         ( axi_inter_m_wlast    [1] ),
//     .m_axi_wstrb         ( axi_inter_m_wstrb    [CnnStrbWidth*2-1:CnnStrbWidth] ),
//     .m_axi_wvalid        ( axi_inter_m_wvalid   [1] ),
//     .m_axi_wready        ( axi_inter_m_wready   [1] ),
//     .m_axi_rdata         ( axi_inter_m_rdata    [CnnDataWidth*2-1:CnnDataWidth] ),
//     .m_axi_rresp         ( axi_inter_m_rresp    [3:2] ),
//     .m_axi_rlast         ( axi_inter_m_rlast    [1] ),
//     .m_axi_rvalid        ( axi_inter_m_rvalid   [1] ),
//     .m_axi_rready        ( axi_inter_m_rready   [1] )
// );


////////////////////////
  /* DepEye CNN IP */
////////////////////////
core_cnn_postmap cnn_inst (
    .clk     (prp_clk          ),
    .clk_2x  (prp_clk_2x       ),
    .clk_2x_n(prp_clk_2x_n     ),
    // .clk_4x_n(prp_clk_4x_n     ), //Not part of config
    .rstn    (soc_prp_reset_out),

    .flag_calc_start(cnn_calc_start),
    .flag_calc_end  (cnn_calc_end  ),

    .s_apb_paddr    (io_apbSlave_2_PADDR[11:0]),
    .s_apb_psel     (io_apbSlave_2_PSEL       ),
    .s_apb_penable  (io_apbSlave_2_PENABLE    ),
    .s_apb_pwrite   (io_apbSlave_2_PWRITE     ),
    .s_apb_pwdata   (io_apbSlave_2_PWDATA     ),
    .s_apb_pready   (io_apbSlave_2_PREADY     ),
    .s_apb_prdata   (io_apbSlave_2_PRDATA     ),
    .s_apb_pslverror(io_apbSlave_2_PSLVERROR  ),

    .m_axi_awid     (axi_cnn_AWID   ),
    .m_axi_awaddr   (axi_cnn_AWADDR ),
    .m_axi_awlen    (axi_cnn_AWLEN  ),
    .m_axi_awsize   (axi_cnn_AWSIZE ),
    .m_axi_awburst  (axi_cnn_AWBURST),  // .m_axi_awlock (m_axi_cnn_AWLOCK),
    .m_axi_awcache  (axi_cnn_AWCACHE),
    .m_axi_awprot   (axi_cnn_AWPROT ),  // .m_axi_awqos  (m_axi_cnn_AWQOS),
    .m_axi_awvalid  (axi_cnn_AWVALID),
    .m_axi_awready  (axi_cnn_AWREADY),
    .m_axi_wdata    (axi_cnn_WDATA  ),
    .m_axi_wstrb    (axi_cnn_WSTRB  ),
    .m_axi_wlast    (axi_cnn_WLAST  ),
    .m_axi_wvalid   (axi_cnn_WVALID ),
    .m_axi_wready   (axi_cnn_WREADY ),   
    .m_axi_bid      (axi_cnn_BID    ),
    .m_axi_bresp    (axi_cnn_BRESP  ),
    .m_axi_bvalid   (axi_cnn_BVALID ),
    .m_axi_bready   (axi_cnn_BREADY ),  
    .m_axi_arid     (axi_cnn_ARID   ),
    .m_axi_araddr   (axi_cnn_ARADDR ),
    .m_axi_arlen    (axi_cnn_ARLEN  ),
    .m_axi_arsize   (axi_cnn_ARSIZE ),
    .m_axi_arburst  (axi_cnn_ARBURST),  // .m_axi_arlock (m_axi_cnn_ARLOCK),
    .m_axi_arcache  (axi_cnn_ARCACHE),
    .m_axi_arprot   (axi_cnn_ARPROT ),  // .m_axi_arqos  (m_axi_cnn_ARQOS),
    .m_axi_arvalid  (axi_cnn_ARVALID),
    .m_axi_arready  (axi_cnn_ARREADY),
    .m_axi_rid      (axi_cnn_RID    ),
    .m_axi_rdata    (axi_cnn_RDATA  ),
    .m_axi_rresp    (axi_cnn_RRESP  ),
    .m_axi_rlast    (axi_cnn_RLAST  ),
    .m_axi_rvalid   (axi_cnn_RVALID ),
    .m_axi_rready   (axi_cnn_RREADY )
);

assign userInterruptH = cnn_calc_end;


core_cnn_postmap cnn_inst2 (
    .clk     (prp_clk          ),
    .clk_2x  (prp_clk_2x       ),
    .clk_2x_n(prp_clk_2x_n     ),
    // .clk_4x_n(prp_clk_4x_n     ), //Not part of config
    .rstn    (soc_prp_reset_out),

    .flag_calc_start(cnn2_calc_start),
    .flag_calc_end  (cnn2_calc_end  ),

    .s_apb_paddr    (io_apbSlave_3_PADDR[11:0]),
    .s_apb_psel     (io_apbSlave_3_PSEL       ),
    .s_apb_penable  (io_apbSlave_3_PENABLE    ),
    .s_apb_pwrite   (io_apbSlave_3_PWRITE     ),
    .s_apb_pwdata   (io_apbSlave_3_PWDATA     ),
    .s_apb_pready   (io_apbSlave_3_PREADY     ),
    .s_apb_prdata   (io_apbSlave_3_PRDATA     ),
    .s_apb_pslverror(io_apbSlave_3_PSLVERROR  ),

    .m_axi_awid     (axi_cnn2_AWID   ),
    .m_axi_awaddr   (axi_cnn2_AWADDR ),
    .m_axi_awlen    (axi_cnn2_AWLEN  ),
    .m_axi_awsize   (axi_cnn2_AWSIZE ),
    .m_axi_awburst  (axi_cnn2_AWBURST),  // .m_axi_awlock (m_axi_cnn2_AWLOCK),
    .m_axi_awcache  (axi_cnn2_AWCACHE),
    .m_axi_awprot   (axi_cnn2_AWPROT ),  // .m_axi_awqos  (m_axi_cnn2_AWQOS),
    .m_axi_awvalid  (axi_cnn2_AWVALID),
    .m_axi_awready  (axi_cnn2_AWREADY),
    .m_axi_wdata    (axi_cnn2_WDATA  ),
    .m_axi_wstrb    (axi_cnn2_WSTRB  ),
    .m_axi_wlast    (axi_cnn2_WLAST  ),
    .m_axi_wvalid   (axi_cnn2_WVALID ),
    .m_axi_wready   (axi_cnn2_WREADY ),   
    .m_axi_bid      (axi_cnn2_BID    ),
    .m_axi_bresp    (axi_cnn2_BRESP  ),
    .m_axi_bvalid   (axi_cnn2_BVALID ),
    .m_axi_bready   (axi_cnn2_BREADY ),  
    .m_axi_arid     (axi_cnn2_ARID   ),
    .m_axi_araddr   (axi_cnn2_ARADDR ),
    .m_axi_arlen    (axi_cnn2_ARLEN  ),
    .m_axi_arsize   (axi_cnn2_ARSIZE ),
    .m_axi_arburst  (axi_cnn2_ARBURST),  // .m_axi_arlock (m_axi_cnn2_ARLOCK),
    .m_axi_arcache  (axi_cnn2_ARCACHE),
    .m_axi_arprot   (axi_cnn2_ARPROT ),  // .m_axi_arqos  (m_axi_cnn2_ARQOS),
    .m_axi_arvalid  (axi_cnn2_ARVALID),
    .m_axi_arready  (axi_cnn2_ARREADY),
    .m_axi_rid      (axi_cnn2_RID    ),
    .m_axi_rdata    (axi_cnn2_RDATA  ),
    .m_axi_rresp    (axi_cnn2_RRESP  ),
    .m_axi_rlast    (axi_cnn2_RLAST  ),
    .m_axi_rvalid   (axi_cnn2_RVALID ),
    .m_axi_rready   (axi_cnn2_RREADY )
);

assign userInterruptG = cnn2_calc_end;


core_cnn_postmap_m cnn_inst3 (
    .clk     (prp_clk          ),
    .clk_2x  (prp_clk_2x       ),
    .clk_2x_n(prp_clk_2x_n     ),
    // .clk_4x_n(prp_clk_4x_n     ), //Not part of config
    .rstn    (soc_prp_reset_out),

    .flag_calc_start(cnn3_calc_start),
    .flag_calc_end  (cnn3_calc_end  ),

    .s_apb_paddr    (io_apbSlave_4_PADDR[11:0]),
    .s_apb_psel     (io_apbSlave_4_PSEL       ),
    .s_apb_penable  (io_apbSlave_4_PENABLE    ),
    .s_apb_pwrite   (io_apbSlave_4_PWRITE     ),
    .s_apb_pwdata   (io_apbSlave_4_PWDATA     ),
    .s_apb_pready   (io_apbSlave_4_PREADY     ),
    .s_apb_prdata   (io_apbSlave_4_PRDATA     ),
    .s_apb_pslverror(io_apbSlave_4_PSLVERROR  ),

    .m_axi_awid     (axi_cnn3_AWID   ),
    .m_axi_awaddr   (axi_cnn3_AWADDR ),
    .m_axi_awlen    (axi_cnn3_AWLEN  ),
    .m_axi_awsize   (axi_cnn3_AWSIZE ),
    .m_axi_awburst  (axi_cnn3_AWBURST),  // .m_axi_awlock (m_axi_cnn3_AWLOCK),
    .m_axi_awcache  (axi_cnn3_AWCACHE),
    .m_axi_awprot   (axi_cnn3_AWPROT ),  // .m_axi_awqos  (m_axi_cnn3_AWQOS),
    .m_axi_awvalid  (axi_cnn3_AWVALID),
    .m_axi_awready  (axi_cnn3_AWREADY),
    .m_axi_wdata    (axi_cnn3_WDATA  ),
    .m_axi_wstrb    (axi_cnn3_WSTRB  ),
    .m_axi_wlast    (axi_cnn3_WLAST  ),
    .m_axi_wvalid   (axi_cnn3_WVALID ),
    .m_axi_wready   (axi_cnn3_WREADY ),   
    .m_axi_bid      (axi_cnn3_BID    ),
    .m_axi_bresp    (axi_cnn3_BRESP  ),
    .m_axi_bvalid   (axi_cnn3_BVALID ),
    .m_axi_bready   (axi_cnn3_BREADY ),  
    .m_axi_arid     (axi_cnn3_ARID   ),
    .m_axi_araddr   (axi_cnn3_ARADDR ),
    .m_axi_arlen    (axi_cnn3_ARLEN  ),
    .m_axi_arsize   (axi_cnn3_ARSIZE ),
    .m_axi_arburst  (axi_cnn3_ARBURST),  // .m_axi_arlock (m_axi_cnn3_ARLOCK),
    .m_axi_arcache  (axi_cnn3_ARCACHE),
    .m_axi_arprot   (axi_cnn3_ARPROT ),  // .m_axi_arqos  (m_axi_cnn3_ARQOS),
    .m_axi_arvalid  (axi_cnn3_ARVALID),
    .m_axi_arready  (axi_cnn3_ARREADY),
    .m_axi_rid      (axi_cnn3_RID    ),
    .m_axi_rdata    (axi_cnn3_RDATA  ),
    .m_axi_rresp    (axi_cnn3_RRESP  ),
    .m_axi_rlast    (axi_cnn3_RLAST  ),
    .m_axi_rvalid   (axi_cnn3_RVALID ),
    .m_axi_rready   (axi_cnn3_RREADY )
);

assign userInterruptF = cnn3_calc_end;

////////////////////
// SLB CONNECTION //
////////////////////
EfxSapphireHpSoc_slb u_top_peripherals(
    .system_i2c_0_io_sda_writeEnable   (o_cam_sda_oe),
    .system_i2c_0_io_sda_write         (o_cam_sda   ),
    .system_i2c_0_io_sda_read          (i_cam_sda   ),
    .system_i2c_0_io_scl_writeEnable   (o_cam_scl_oe),
    .system_i2c_0_io_scl_write         (o_cam_scl   ),
    .system_i2c_0_io_scl_read          (i_cam_scl   ),

    .system_i2c_1_io_sda_writeEnable   (io_fpga_sda_oe ),
    .system_i2c_1_io_sda_write         (io_fpga_sda_OUT),
    .system_i2c_1_io_sda_read          (io_fpga_sda_IN ),
    .system_i2c_1_io_scl_writeEnable   (io_fpga_scl_oe ),
    .system_i2c_1_io_scl_write         (io_fpga_scl_OUT),
    .system_i2c_1_io_scl_read          (io_fpga_scl_IN ),
    
    .system_spi_0_io_sclk_write        (system_spi_0_io_sclk_write        ),
    .system_spi_0_io_data_0_writeEnable(system_spi_0_io_data_0_writeEnable),
    .system_spi_0_io_data_0_read       (system_spi_0_io_data_0_read       ),
    .system_spi_0_io_data_0_write      (system_spi_0_io_data_0_write      ),
    .system_spi_0_io_data_1_writeEnable(system_spi_0_io_data_1_writeEnable),
    .system_spi_0_io_data_1_read       (system_spi_0_io_data_1_read       ),
    .system_spi_0_io_data_1_write      (system_spi_0_io_data_1_write      ),
    .system_spi_0_io_data_2_writeEnable(system_spi_0_io_data_2_writeEnable),
    .system_spi_0_io_data_2_read       (system_spi_0_io_data_2_read       ),
    .system_spi_0_io_data_2_write      (system_spi_0_io_data_2_write      ),
    .system_spi_0_io_data_3_writeEnable(system_spi_0_io_data_3_writeEnable),
    .system_spi_0_io_data_3_read       (system_spi_0_io_data_3_read       ),
    .system_spi_0_io_data_3_write      (system_spi_0_io_data_3_write      ),
    .system_spi_0_io_ss                (system_spi_0_io_ss                ),
    
     //DMA
    .io_apbSlave_0_PADDR    (io_apbSlave_0_PADDR    ),
    .io_apbSlave_0_PSEL     (io_apbSlave_0_PSEL     ),
    .io_apbSlave_0_PENABLE  (io_apbSlave_0_PENABLE  ),
    .io_apbSlave_0_PREADY   (io_apbSlave_0_PREADY   ),
    .io_apbSlave_0_PWRITE   (io_apbSlave_0_PWRITE   ),
    .io_apbSlave_0_PWDATA   (io_apbSlave_0_PWDATA   ),
    .io_apbSlave_0_PRDATA   (io_apbSlave_0_PRDATA   ),
    .io_apbSlave_0_PSLVERROR(io_apbSlave_0_PSLVERROR),
     //common_apb3
    .io_apbSlave_1_PADDR    (io_apbSlave_1_PADDR    ),
    .io_apbSlave_1_PSEL     (io_apbSlave_1_PSEL     ),
    .io_apbSlave_1_PENABLE  (io_apbSlave_1_PENABLE  ),
    .io_apbSlave_1_PREADY   (io_apbSlave_1_PREADY   ),
    .io_apbSlave_1_PWRITE   (io_apbSlave_1_PWRITE   ),
    .io_apbSlave_1_PWDATA   (io_apbSlave_1_PWDATA   ),
    .io_apbSlave_1_PRDATA   (io_apbSlave_1_PRDATA   ),
    .io_apbSlave_1_PSLVERROR(io_apbSlave_1_PSLVERROR),
     //eCNN
    .io_apbSlave_2_PADDR    (io_apbSlave_2_PADDR    ),
    .io_apbSlave_2_PSEL     (io_apbSlave_2_PSEL     ),
    .io_apbSlave_2_PENABLE  (io_apbSlave_2_PENABLE  ),
    .io_apbSlave_2_PREADY   (io_apbSlave_2_PREADY   ),
    .io_apbSlave_2_PWRITE   (io_apbSlave_2_PWRITE   ),
    .io_apbSlave_2_PWDATA   (io_apbSlave_2_PWDATA   ),
    .io_apbSlave_2_PRDATA   (io_apbSlave_2_PRDATA   ),
    .io_apbSlave_2_PSLVERROR(io_apbSlave_2_PSLVERROR),
     //eCNN 2
    .io_apbSlave_3_PADDR    (io_apbSlave_3_PADDR    ),
    .io_apbSlave_3_PSEL     (io_apbSlave_3_PSEL     ),
    .io_apbSlave_3_PENABLE  (io_apbSlave_3_PENABLE  ),
    .io_apbSlave_3_PREADY   (io_apbSlave_3_PREADY   ),
    .io_apbSlave_3_PWRITE   (io_apbSlave_3_PWRITE   ),
    .io_apbSlave_3_PWDATA   (io_apbSlave_3_PWDATA   ),
    .io_apbSlave_3_PRDATA   (io_apbSlave_3_PRDATA   ),
    .io_apbSlave_3_PSLVERROR(io_apbSlave_3_PSLVERROR),
     //eCNN 3
    .io_apbSlave_4_PADDR    (io_apbSlave_4_PADDR    ),
    .io_apbSlave_4_PSEL     (io_apbSlave_4_PSEL     ),
    .io_apbSlave_4_PENABLE  (io_apbSlave_4_PENABLE  ),
    .io_apbSlave_4_PREADY   (io_apbSlave_4_PREADY   ),
    .io_apbSlave_4_PWRITE   (io_apbSlave_4_PWRITE   ),
    .io_apbSlave_4_PWDATA   (io_apbSlave_4_PWDATA   ),
    .io_apbSlave_4_PRDATA   (io_apbSlave_4_PRDATA   ),
    .io_apbSlave_4_PSLVERROR(io_apbSlave_4_PSLVERROR),
    
    .userInterruptA         (userInterruptA),
    .userInterruptB         (userInterruptB),
    .userInterruptC         (userInterruptC),
    
    `ifndef SOFT_TAP
    .jtagCtrl_tdi       (jtagCtrl_tdi       ),
    .jtagCtrl_tdo       (jtagCtrl_tdo       ),
    .jtagCtrl_enable    (jtagCtrl_enable    ),
    .jtagCtrl_capture   (jtagCtrl_capture   ),
    .jtagCtrl_shift     (jtagCtrl_shift     ),
    .jtagCtrl_update    (jtagCtrl_update    ),
    .jtagCtrl_reset     (jtagCtrl_reset     ),
    .ut_jtagCtrl_tdi    (ut_jtagCtrl_tdi    ),
    .ut_jtagCtrl_tdo    (ut_jtagCtrl_tdo    ),
    .ut_jtagCtrl_enable (ut_jtagCtrl_enable ),
    .ut_jtagCtrl_capture(ut_jtagCtrl_capture),
    .ut_jtagCtrl_shift  (ut_jtagCtrl_shift  ),
    .ut_jtagCtrl_update (ut_jtagCtrl_update ),
    .ut_jtagCtrl_reset  (ut_jtagCtrl_reset  ),
    `else
    .io_jtag_tdi(io_jtag_tdi),
    .io_jtag_tdo(io_jtag_tdo),
    .io_jtag_tms(io_jtag_tms),
    .pin_io_jtag_tdi(pin_io_jtag_tdi),
    .pin_io_jtag_tdo(pin_io_jtag_tdo),
    .pin_io_jtag_tms(pin_io_jtag_tms),
    `endif
    
    .system_uart_0_io_txd (system_uart_0_io_txd),
    .system_uart_0_io_rxd (system_uart_0_io_rxd),
    
    .axiA_awvalid  (axiA_awvalid ),
    .axiA_awready  (axiA_awready ),
    .axiA_awaddr   (axiA_awaddr  ),
    .axiA_awlen    (axiA_awlen   ),
    .axiA_awsize   (axiA_awsize  ),
    .axiA_awcache  (axiA_awcache ),
    .axiA_awprot   (axiA_awprot  ),
    .axiA_wvalid   (axiA_wvalid  ),
    .axiA_wready   (axiA_wready  ),
    .axiA_wdata    (axiA_wdata   ),
    .axiA_wstrb    (axiA_wstrb   ),
    .axiA_wlast    (axiA_wlast   ),
    .axiA_bvalid   (axiA_bvalid  ),
    .axiA_bready   (axiA_bready  ),
    .axiA_bresp    (axiA_bresp   ),
    .axiA_arvalid  (axiA_arvalid ),
    .axiA_arready  (axiA_arready ),
    .axiA_araddr   (axiA_araddr  ),
    .axiA_arlen    (axiA_arlen   ),
    .axiA_arsize   (axiA_arsize  ),
    .axiA_arcache  (axiA_arcache ),
    .axiA_arprot   (axiA_arprot  ),
    .axiA_rvalid   (axiA_rvalid  ),
    .axiA_rready   (axiA_rready  ),
    .axiA_rdata    (axiA_rdata   ),
    .axiA_rresp    (axiA_rresp   ),
    .axiA_rlast    (axiA_rlast   ),
    .axiAInterrupt (axiAInterrupt),
    
    .cfg_done  (cfg_done ),
    .cfg_start (cfg_start),
    .cfg_sel   (cfg_sel  ),
    .cfg_reset (cfg_reset),
    
    .io_peripheralClk      (prp_clk           ),
    .io_peripheralReset    (!soc_prp_reset_out),
    .io_asyncReset         (io_asyncReset     ),
    .io_gpio_sw_n          (io_gpio_sw_n      ), 
    .pll_peripheral_locked (pll_prp_locked),
    .pll_system_locked     (pll_system_locked)
);


wire  [31:0]     debug_dma_hw_accel_in_fifo_wcount    ;
wire  [31:0]     debug_dma_hw_accel_out_fifo_rcount   ;

// For control and status register
common_apb3 #(
   .ADDR_WIDTH                              (16),
   .DATA_WIDTH                              (32),
   .NUM_REG                                 (7)
) u_apb3_cam_display (
    .clk                                    (prp_clk),
    .resetn                                 (soc_prp_reset_out),
    
    // Output Control
    .mipi_rstn                              (mipi_rstn                 ),
    .rgb_control                            (rgb_control               ),
    .trigger_capture_frame                  (trigger_capture_frame     ),
    .continuous_capture_frame               (continuous_capture_frame  ),
    .rgb_gray                               (rgb_gray                  ),
    .cam_dma_init_done                      (cam_dma_init_done         ),
    .hw_accel_dma_init_done                 (hw_accel_dma_init_done    ),    
    .hw_accel_dma_init_done_ch0             (hw_accel_dma_init_done_ch0),
    .hw_accel_dma_init_done_ch1             (hw_accel_dma_init_done_ch1),
    
    .frames_per_second                      (frames_per_second     ),
    .set_offset_display_rgb                 (set_offset_display_rgb),

    // Input Info Data
    .debug_fifo_status                      (debug_cam_display_fifo_status     ),
    .debug_cam_dma_fifo_rcount              (debug_cam_dma_fifo_rcount         ),
    .debug_cam_dma_fifo_wcount              (debug_cam_dma_fifo_wcount         ),
    .debug_display_dma_fifo_rcount          (debug_display_dma_fifo_rcount     ),
    .debug_display_dma_fifo_wcount          (debug_display_dma_fifo_wcount     ),
    .debug_dma_hw_accel_in_fifo_wcount      (debug_dma_hw_accel_in_fifo_wcount ),
    .debug_dma_hw_accel_out_fifo_rcount     (debug_dma_hw_accel_out_fifo_rcount),
    .debug_cam_dma_status                   (debug_cam_dma_status              ),

    // Apb 3 interface
    .PADDR                                  (io_apbSlave_1_PADDR    ),
    .PSEL                                   (io_apbSlave_1_PSEL     ),
    .PENABLE                                (io_apbSlave_1_PENABLE  ),
    .PREADY                                 (io_apbSlave_1_PREADY   ),
    .PWRITE                                 (io_apbSlave_1_PWRITE   ),
    .PWDATA                                 (io_apbSlave_1_PWDATA   ),
    .PRDATA                                 (io_apbSlave_1_PRDATA   ),
    .PSLVERROR                              (io_apbSlave_1_PSLVERROR)
);



assign debug_cam_display_fifo_status= {22'd0,  
                                               debug_cam_pixel_remap_fifo_underflow, debug_cam_pixel_remap_fifo_overflow  ,
                                               debug_cam_dma_fifo_underflow        , debug_cam_dma_fifo_overflow          , 
                                               debug_display_dma_fifo_underflow    , debug_display_dma_fifo_overflow      };
                                               
                                               
endmodule
