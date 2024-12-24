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

////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   top_soc.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Top module for unified hardware
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// 1.0 Initial rev
// ***********************************************************************

// To enable RiscV soft tap connection (for debugger).
//`define SOFTTAP // Regenerate EfxSapphireHpSoc_slb with jtag with gpio selection is required. 

`define TITANIUM_DEVICE 
`define ENABLE_SDHC         // Comment out this line to disable SDHC , Modify gAXIS_1to4_switch IP manually !!
`define ENABLE_EVSOC        // Comment out this line to disable EVSOC, Modify gAXIS_1to4_switch IP manually !!
`define ENABLE_ETHERNET     // Comment out this line to disable Ethernet, Modify gAXIS_1to4_switch IP manually !!
`define DISPLAY_1920x1080_60Hz    //Set "i_hdmi_clk_148p5MHz" clk to 148.5MHz if switch to this 1080p mode.
//`define DISPLAY_1280x720_60Hz   //Set "i_hdmi_clk_148p5MHz" clk to 74.25MHz if switch to this 720p mode.

`ifdef ENABLE_EVSOC
    `define ENABLE_EVSOC_CAMERA     // Comment out this line to disable the PiCAM camera portion of EVSOC
    `define ENABLE_EVSOC_DISPLAY    // Comment out this line to disable the HDMI display portion of EVSOC
    `define ENABLE_EVSOC_HW_ACCEL   // Comment out this line to disable the hardware accelerator for EVSOC
`endif 


module top_soc (

`ifdef SOFTTAP
//Soft JTAG 
output          io_jtag_tdi,
input           io_jtag_tdo,
output          io_jtag_tms,
input           pin_io_jtag_tdi,
output          pin_io_jtag_tdo,
input           pin_io_jtag_tms,
`else
//Hard JTAG
output          jtagCtrl_tdi,
input           jtagCtrl_tdo,
output          jtagCtrl_enable,
output          jtagCtrl_capture,
output          jtagCtrl_shift,
output          jtagCtrl_update,
output          jtagCtrl_reset,
input           ut_jtagCtrl_tdi,
output          ut_jtagCtrl_tdo,
input           ut_jtagCtrl_enable,
input           ut_jtagCtrl_capture,
input           ut_jtagCtrl_shift,
input           ut_jtagCtrl_update,
input           ut_jtagCtrl_reset,
`endif 

//Custom Instruction
input           io_cfuClk,
input           io_cfuReset,
input           cpu0_customInstruction_cmd_valid,
output          cpu0_customInstruction_cmd_ready,
input [9:0]     cpu0_customInstruction_function_id,
input [31:0]    cpu0_customInstruction_inputs_0,
input [31:0]    cpu0_customInstruction_inputs_1,
output          cpu0_customInstruction_rsp_valid,
input           cpu0_customInstruction_rsp_ready,
output [31:0]   cpu0_customInstruction_outputs_0,
input           cpu1_customInstruction_cmd_valid,
output          cpu1_customInstruction_cmd_ready,
input [9:0]     cpu1_customInstruction_function_id,
input [31:0]    cpu1_customInstruction_inputs_0,
input [31:0]    cpu1_customInstruction_inputs_1,
output          cpu1_customInstruction_rsp_valid,
input           cpu1_customInstruction_rsp_ready,
output [31:0]   cpu1_customInstruction_outputs_0,
input           cpu2_customInstruction_cmd_valid,
output          cpu2_customInstruction_cmd_ready,
input [9:0]     cpu2_customInstruction_function_id,
input [31:0]    cpu2_customInstruction_inputs_0,
input [31:0]    cpu2_customInstruction_inputs_1,
output          cpu2_customInstruction_rsp_valid,
input           cpu2_customInstruction_rsp_ready,
output [31:0]   cpu2_customInstruction_outputs_0,
input           cpu3_customInstruction_cmd_valid,
output          cpu3_customInstruction_cmd_ready,
input [9:0]     cpu3_customInstruction_function_id,
input [31:0]    cpu3_customInstruction_inputs_0,
input [31:0]    cpu3_customInstruction_inputs_1,
output          cpu3_customInstruction_rsp_valid,
input           cpu3_customInstruction_rsp_ready,
output [31:0]   cpu3_customInstruction_outputs_0,

//DDR Master Ports
output          io_ddrMasters_0_aw_valid,
input           io_ddrMasters_0_aw_ready,
output [31:0]   io_ddrMasters_0_aw_payload_addr,
output [3:0]    io_ddrMasters_0_aw_payload_id,
output [3:0]    io_ddrMasters_0_aw_payload_region,
output [7:0]    io_ddrMasters_0_aw_payload_len,
output [2:0]    io_ddrMasters_0_aw_payload_size,
output [1:0]    io_ddrMasters_0_aw_payload_burst,
output          io_ddrMasters_0_aw_payload_lock,
output [3:0]    io_ddrMasters_0_aw_payload_cache,
output [3:0]    io_ddrMasters_0_aw_payload_qos,
output [2:0]    io_ddrMasters_0_aw_payload_prot,
output          io_ddrMasters_0_aw_payload_allStrb,
output          io_ddrMasters_0_w_valid,
input           io_ddrMasters_0_w_ready,
output [127:0]  io_ddrMasters_0_w_payload_data,
output [15:0]   io_ddrMasters_0_w_payload_strb,
output          io_ddrMasters_0_w_payload_last,
input           io_ddrMasters_0_b_valid,
output          io_ddrMasters_0_b_ready,
input [3:0]     io_ddrMasters_0_b_payload_id,
input [1:0]     io_ddrMasters_0_b_payload_resp,
output          io_ddrMasters_0_ar_valid,
input           io_ddrMasters_0_ar_ready,
output [31:0]   io_ddrMasters_0_ar_payload_addr,
output [3:0]    io_ddrMasters_0_ar_payload_id,
output [3:0]    io_ddrMasters_0_ar_payload_region,
output [7:0]    io_ddrMasters_0_ar_payload_len,
output [2:0]    io_ddrMasters_0_ar_payload_size,
output [1:0]    io_ddrMasters_0_ar_payload_burst,
output          io_ddrMasters_0_ar_payload_lock,
output [3:0]    io_ddrMasters_0_ar_payload_cache,
output [3:0]    io_ddrMasters_0_ar_payload_qos,
output [2:0]    io_ddrMasters_0_ar_payload_prot,
input           io_ddrMasters_0_r_valid,
output          io_ddrMasters_0_r_ready,
input [127:0]   io_ddrMasters_0_r_payload_data,
input [3:0]     io_ddrMasters_0_r_payload_id,
input [1:0]     io_ddrMasters_0_r_payload_resp,
input           io_ddrMasters_0_r_payload_last,
input           io_ddrMasters_0_clk,
input           io_ddrMasters_0_reset,

//Interrupts
output          userInterruptA,
output          userInterruptB,
output          userInterruptC,
output          userInterruptD,
output          userInterruptE,
output          userInterruptF,
output          userInterruptH,
output          userInterruptG,
output          userInterruptI,
output          userInterruptJ,
output          userInterruptK,
output          userInterruptL,
output          userInterruptM,
output          userInterruptN,
output          userInterruptO,
output          userInterruptP,

//Peripherals
input [3:0]     system_gpio_0_io_read,
output [3:0]    system_gpio_0_io_write,
output [3:0]    system_gpio_0_io_writeEnable,
output          system_uart_0_io_txd,
input           system_uart_0_io_rxd,
output          system_spi_0_io_sclk_write,
output          system_spi_0_io_data_0_writeEnable,
input           system_spi_0_io_data_0_read,
output          system_spi_0_io_data_0_write,
output          system_spi_0_io_data_1_writeEnable,
input           system_spi_0_io_data_1_read,
output          system_spi_0_io_data_1_write,
output          system_spi_0_io_data_2_writeEnable,
input           system_spi_0_io_data_2_read,
output          system_spi_0_io_data_2_write,
output          system_spi_0_io_data_3_writeEnable,
input           system_spi_0_io_data_3_read,
output          system_spi_0_io_data_3_write,
output [3:0]    system_spi_0_io_ss,
output          system_i2c_1_io_sda_writeEnable,
output          system_i2c_1_io_sda_write,
input           system_i2c_1_io_sda_read,
output          system_i2c_1_io_scl_writeEnable,
output          system_i2c_1_io_scl_write,
input           system_i2c_1_io_scl_read,

//AXI Slave Ports
input [31:0]    axiA_awaddr,
input [7:0]     axiA_awlen,
input [2:0]     axiA_awsize,
input [1:0]     axiA_awburst,
input           axiA_awlock,
input [3:0]     axiA_awcache,
input [2:0]     axiA_awprot,
input [3:0]     axiA_awqos,
input [3:0]     axiA_awregion,
input           axiA_awvalid,
output          axiA_awready,
input [31:0]    axiA_wdata,
input [3:0]     axiA_wstrb,
input           axiA_wvalid,
input           axiA_wlast,
output          axiA_wready,
output [1:0]    axiA_bresp,
output          axiA_bvalid,
input           axiA_bready,
input [31:0]    axiA_araddr,
input [7:0]     axiA_arlen,
input [2:0]     axiA_arsize,
input [1:0]     axiA_arburst,
input           axiA_arlock,
input [3:0]     axiA_arcache,
input [2:0]     axiA_arprot,
input [3:0]     axiA_arqos,
input [3:0]     axiA_arregion,
input           axiA_arvalid,
output          axiA_arready,
output [31:0]   axiA_rdata,
output [1:0]    axiA_rresp,
output          axiA_rlast,
output          axiA_rvalid,
input           axiA_rready,
output          axiAInterrupt,

//DDR Configuration
input           cfg_done,
output          cfg_start,
output          cfg_sel,
output          cfg_reset,

//Clock & Reset
input           io_peripheralClk,
input           io_peripheralReset,
output          io_asyncReset,
input           io_gpio_sw_n, 
input           pll_peripheral_locked,
input           pll_system_locked,
input           pll_tse_locked,
input           pll_hdmi_locked, 
input           io_memoryClk, 
input           io_systemReset,

`ifdef ENABLE_SDHC
//  SDHC
input           sd_base_clk, 
output          sd_clk_hi,
output          sd_clk_lo,
input           sd_cmd_i,
output          sd_cmd_o,
output          sd_cmd_oe,
input  [3:0]    sd_dat_i,
output [3:0]    sd_dat_o,
output [3:0]    sd_dat_oe,
input           sd_cd_n, 
input           sd_wp,

`endif // ENABLE_SDHC

`ifdef ENABLE_ETHERNET
// TSEMAC
input           io_tseClk,
// MAC 
output [3:0]    rgmii_txd_HI,
output [3:0]    rgmii_txd_LO,
output          rgmii_tx_ctl_HI,
output          rgmii_tx_ctl_LO,
output          rgmii_txc_HI,
output          rgmii_txc_LO,
input  [3:0]    rgmii_rxd_HI,
input  [3:0]    rgmii_rxd_LO,
input           rgmii_rx_ctl_HI,
input           rgmii_rx_ctl_LO,
input           mux_clk,
output [1:0]    mux_clk_sw,
// PHY
output          phy_rst,
input           phy_mdi,
output          phy_mdo,
output          phy_mdo_en,
output          phy_mdc,
input           rgmii_rxc,      
input           rgmii_rxc_slow, 

`endif  //ENABLE_ETHERNET

`ifdef ENABLE_EVSOC_DISPLAY

//hdmi 
input         i_pixel_clk,
input         i_hdmi_clk_148p5MHz, 
input         i_sys_clk_25mhz,

// I2C Configuration for HDMI
input   i_hdmi_sda,
output  o_hdmi_sda_oe,
input   i_hdmi_scl,
output  o_hdmi_scl_oe,
        
// HDMI YUV Output
output          hdmi_yuv_de,
output  [15:0]  hdmi_yuv_data,
output          hdmi_yuv_vs_OE,     //for Ti375C529 Dev Kit which requires tristate IO for HS VS
output          hdmi_yuv_hs_OE,     //for Ti375C529 Dev Kit which requires tristate IO for HS VS

`endif // ENABLE_EVSOC_DISPLAY

`ifdef ENABLE_EVSOC_CAMERA
//cam
//MIPI RX - Camera
input               cam_ck_LP_P_IN,
input               cam_ck_LP_N_IN,
output   wire       cam_ck_HS_TERM,
output   wire       cam_ck_HS_ENA,
input               cam_ck_CLKOUT,

input      [7:0]    cam_d0_HS_IN,
input      [7:0]    cam_d0_HS_IN_1,
input      [7:0]    cam_d0_HS_IN_2,
input      [7:0]    cam_d0_HS_IN_3,
input               cam_d0_LP_P_IN,
input               cam_d0_LP_N_IN,
output   wire       cam_d0_HS_TERM,
output   wire       cam_d0_HS_ENA,
output   wire       cam_d0_RST,
output   wire       cam_d0_FIFO_RD,
input               cam_d0_FIFO_EMPTY,

input      [7:0]    cam_d1_HS_IN,
input      [7:0]    cam_d1_HS_IN_1,
input      [7:0]    cam_d1_HS_IN_2,
input      [7:0]    cam_d1_HS_IN_3,
input               cam_d1_LP_P_IN,
input               cam_d1_LP_N_IN,
output   wire       cam_d1_HS_TERM,
output   wire       cam_d1_HS_ENA,
output   wire       cam_d1_RST,
output   wire       cam_d1_FIFO_RD,
input               cam_d1_FIFO_EMPTY,

//CSI Camera interface
input   i_cam_sda,
output  o_cam_sda_oe,
input   i_cam_scl,
output  o_cam_scl_oe,
output  o_cam_scl,
output  o_cam_sda,
output  o_cam_rstn,
`else 
output   wire       cam_d0_RST,
output   wire       cam_d1_RST,
`endif  // ENABLE_EVSOC_CAMERA

//DDR AXI 0
output          ddr_inst1_ARSTN_0,
//DDR AXI 0 Read Address Channel
output [32:0]   ddr_inst1_ARADDR_0,     //Read address. It gives the address of the first transfer in a burst transaction.
output [1:0]    ddr_inst1_ARBURST_0,    //Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
output [5:0]    ddr_inst1_ARID_0,       //Address ID. This signal identifies the group of address signals.
output [7:0]    ddr_inst1_ARLEN_0,      //Burst length. This signal indicates the number of transfers in a burst.
input           ddr_inst1_ARREADY_0,    //Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
output  [2:0]   ddr_inst1_ARSIZE_0,     //Burst size. This signal indicates the size of each transfer in the burst.
output          ddr_inst1_ARVALID_0,    //Address valid. This signal indicates that the channel is signaling valid address and control information.
output          ddr_inst1_ARLOCK_0,     //Lock type. This signal provides additional information about the atomic characteristics of the transfer.
output          ddr_inst1_ARAPCMD_0,    //Read auto-precharge.
output          ddr_inst1_ARQOS_0,      //QoS indentifier for read transaction.

//DDR AXI 0 Wrtie Address Channel
output [32:0]   ddr_inst1_AWADDR_0,     //Write address. It gives the address of the first transfer in a burst transaction.
output [1:0]    ddr_inst1_AWBURST_0,    //Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
output [5:0]    ddr_inst1_AWID_0,       //Address ID. This signal identifies the group of address signals.
output [7:0]    ddr_inst1_AWLEN_0,      //Burst length. This signal indicates the number of transfers in a burst.
input           ddr_inst1_AWREADY_0,    //Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
output [2:0]    ddr_inst1_AWSIZE_0,     //Burst size. This signal indicates the size of each transfer in the burst.
output          ddr_inst1_AWVALID_0,    //Address valid. This signal indicates that the channel is signaling valid address and control information.
output          ddr_inst1_AWLOCK_0,     //Lock type. This signal provides additional information about the atomic characteristics of the transfer.
output          ddr_inst1_AWAPCMD_0,    //Write auto-precharge.
output          ddr_inst1_AWQOS_0,      //QoS indentifier for write transaction.
output [3:0]    ddr_inst1_AWCACHE_0,    //Memory type. This signal indicates how transactions are required to progress through a system.
output          ddr_inst1_AWALLSTRB_0,  //Write all strobes asserted.
output          ddr_inst1_AWCOBUF_0,    //Write coherent bufferable selection.

//DDR AXI 0 Write Response Channel
input  [5:0]    ddr_inst1_BID_0,        //Response ID tag. This signal is the ID tag of the write response.
output          ddr_inst1_BREADY_0,     //Response ready. This signal indicates that the master can accept a write response.
input  [1:0]    ddr_inst1_BRESP_0,      //Read response. This signal indicates the status of the read transfer.
input           ddr_inst1_BVALID_0,     //Write response valid. This signal indicates that the channel is signaling a valid write response.

//DDR AXI 0 Read Data Channel
input   [511:0] ddr_inst1_RDATA_0,       //Read data.
input   [5:0]   ddr_inst1_RID_0,         //Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
input           ddr_inst1_RLAST_0,       //Read last. This signal indicates the last transfer in a read burst.
output          ddr_inst1_RREADY_0,      //Read ready. This signal indicates that the master can accept the read data and response information.
input   [1:0]   ddr_inst1_RRESP_0,       //Read response. This signal indicates the status of the read transfer.
input           ddr_inst1_RVALID_0,      //Read valid. This signal indicates that the channel is signaling the required read data.

//DDR AXI 0 Write Data Channel Signals

output  [511:0]  ddr_inst1_WDATA_0,      //Write data. AXI4 port 0 is 256, port 1 is 128.
output  ddr_inst1_WLAST_0,                              //Write last. This signal indicates the last transfer in a write burst.
input   ddr_inst1_WREADY_0,                             //Write ready. This signal indicates that the slave can accept the write data.
output  [63:0] ddr_inst1_WSTRB_0,     //Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
output  ddr_inst1_WVALID_0                              //Write valid. This signal indicates that valid write data and strobes are available.


);

/************************************Local Parameters ***************************************/

// Device 
`ifdef TITANIUM_DEVICE
    localparam FAMILY  = "TITANIUM";
`else
    localparam FAMILY  = "TRION";
`endif 

//Display
`ifdef DISPLAY_1920x1080_60Hz
    //Resolution Parameter (Vesa Standard): 1080p (HDMI Clock 148.5 MHz )
    localparam  DISPLAY_MODE    = "1920x1080_60Hz" ;  // Display setting for LVDS  
`endif

`ifdef DISPLAY_1280x720_60Hz
    //Resolution Parameter (Vesa Standard): 720p (HDMI Clock 74.250 MHz)
    localparam  DISPLAY_MODE    = "1280x720_60Hz" ;  // Display setting for LVDS
`endif


// AXI Interconnect
localparam AXIS_DEV     = 4;
localparam AXIM_DEV     = 2;
localparam SLB          = 0;
// SDHC
localparam SDHC         = 1;
localparam MSDHC        = 0;
// TSEMAC
localparam TSE          = 2;
localparam MTSE         = 1;
// Hardware accel
localparam HW_ACCEL     = 3;

//Vision related paramter
localparam MIPI_FRAME_WIDTH     = 1920;  // Resolution of Camera input 
localparam MIPI_FRAME_HEIGHT    = 1080;  // Resolution of Camera input 
localparam APB3_ADDR_WIDTH      = 16;    // Vision APB3 CSR Address Width 
localparam APB3_DATA_WIDTH      = 32;    // Vision APB3 CSR Data Width
localparam HW_ACCEL_ADDR_WIDTH  = 32;    // Hardware Accelerator Address Width
localparam HW_ACCEL_DATA_WIDTH  = 32;     // Hardware Accelerator Data Width

/************************************Common Wire  ***************************************/

//APB Slave 0  (EVSOC) - HW Accelerator DMA
wire    [15:0]   vision_dma_apbSlave_0_PADDR;
wire    [0:0]    vision_dma_apbSlave_0_PSEL;
wire             vision_dma_apbSlave_0_PENABLE;
wire             vision_dma_apbSlave_0_PREADY;
wire             vision_dma_apbSlave_0_PWRITE;
wire    [31:0]   vision_dma_apbSlave_0_PWDATA;
wire    [31:0]   vision_dma_apbSlave_0_PRDATA;
wire             vision_dma_apbSlave_0_PSLVERROR;

//APB Slave 1  (EVSOC) - Cam & Display registers 
wire    [15:0]   vision_apbSlave_1_PADDR;
wire    [0:0]    vision_apbSlave_1_PSEL;
wire             vision_apbSlave_1_PENABLE;
wire             vision_apbSlave_1_PREADY;
wire             vision_apbSlave_1_PWRITE;
wire    [31:0]   vision_apbSlave_1_PWDATA;
wire    [31:0]   vision_apbSlave_1_PRDATA;
wire             vision_apbSlave_1_PSLVERROR;

//APB3 Slave 2 to TSE DMA Wires 
wire   [31:0]   tse_dma_apbSlave_2_PADDR    ;
wire            tse_dma_apbSlave_2_PSEL     ;
wire            tse_dma_apbSlave_2_PENABLE  ;
wire            tse_dma_apbSlave_2_PREADY   ;
wire            tse_dma_apbSlave_2_PWRITE   ;
wire   [31:0]   tse_dma_apbSlave_2_PWDATA   ;
wire   [31:0]   tse_dma_apbSlave_2_PRDATA   ;
wire            tse_dma_apbSlave_2_PSLVERROR;

// DMA
wire [7:0]      dma_arid;
wire [7:0]      dma_awid;
wire            dma_tx_rst;
wire            dma_rx_rst;
wire            dma_tx_descriptorUpdate;
wire [1:0]      dma_interrupts;

//Interrupts  
wire        userInterrupt_gpio0;
wire        userInterrupt_gpio1;
wire        userInterrupt_gpio2;
wire        userInterrupt_gpio3;
wire        userInterrupt_uart;
wire        userInterrupt_i2c0;
wire        userInterrupt_i2c1;
wire        userInterrupt_spi0;
wire        userInterrupt_spi1;
wire  [3:0] vision_dma_interrupts;
wire        vision_dma_ctrl_interrupt; 
wire        w_axiAInterrupt; 
wire        axi4Interrupt_or; 
wire        axiAInterrupt_slb; 
wire        i_arstn;  

 ////////////////////////////////////////////////////////////////////////////
 
//Reset 
assign o_cam_rstn       = ~io_asyncReset;
assign axiAInterrupt    = axi4Interrupt_or; 
assign axi4Interrupt_or = w_axiAInterrupt | axiAInterrupt_slb;
assign vision_dma_ctrl_interrupt    = | vision_dma_interrupts; // changed

//Interrupts
assign userInterruptA = vision_dma_ctrl_interrupt;  
assign userInterruptB = dma_interrupts[0]; 
assign userInterruptC = dma_interrupts[1]; 
assign userInterruptD = sd_int;  
assign userInterruptE = 1'b0; 
assign userInterruptF = 1'b0; 
assign userInterruptG = 1'b0; 
assign userInterruptH = 1'b0;  
assign userInterruptI = userInterrupt_uart;                     
assign userInterruptJ = userInterrupt_i2c0;
assign userInterruptK = userInterrupt_i2c1; 
assign userInterruptL = userInterrupt_spi0; 
assign userInterruptM = userInterrupt_spi1; 
assign userInterruptN = userInterrupt_gpio0;
assign userInterruptO = userInterrupt_gpio1;
assign userInterruptP = 1'b0;

//DDR
assign dma_arid = 8'hE0;
assign dma_awid = 8'hE1;
assign ddr_inst1_ARID_0 = {dma_arid[7:6], dma_arid[3:0]};
assign ddr_inst1_AWID_0 = {dma_awid[7:6], dma_awid[3:0]};
assign ddr_inst1_ARADDR_0[32] = 1'b0;
assign ddr_inst1_AWADDR_0[32] = 1'b0;
assign ddr_inst1_AWAPCMD_0    = 1'b0;
assign ddr_inst1_ARAPCMD_0    = 1'b0;
assign ddr_inst1_AWALLSTRB_0  = 1'b0;
assign ddr_inst1_AWCOBUF_0    = 1'b0;
assign ddr_inst1_ARSTN_0       = ~io_systemReset;

/********************************************* AXI Interconnect ********************************************/

//  Switch between sdhc and slb
wire [(AXIS_DEV*32)-1:0]    gAXIS_m_awaddr;
wire [(AXIS_DEV*8)-1:0]     gAXIS_m_awlen;
wire [(AXIS_DEV*3)-1:0]     gAXIS_m_awsize;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_awburst;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_awlock;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_awcache;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_awprot;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_awqos;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_awregion;
wire [AXIS_DEV-1:0]         gAXIS_m_awvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_awready;
wire [(AXIS_DEV*32)-1:0]    gAXIS_m_wdata;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_wstrb;
wire [AXIS_DEV-1:0]         gAXIS_m_wvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_wlast;
wire [AXIS_DEV-1:0]         gAXIS_m_wready;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_bresp;
wire [AXIS_DEV-1:0]         gAXIS_m_bvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_bready;
wire [(AXIS_DEV*32)-1:0]    gAXIS_m_araddr;
wire [(AXIS_DEV*8)-1:0]     gAXIS_m_arlen;
wire [(AXIS_DEV*3)-1:0]     gAXIS_m_arsize;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_arburst;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_arlock;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_arcache;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_arprot;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_arqos;
wire [(AXIS_DEV*4)-1:0]     gAXIS_m_arregion;
wire [AXIS_DEV-1:0]         gAXIS_m_arvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_arready;
wire [(AXIS_DEV*32)-1:0]    gAXIS_m_rdata;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_rresp;
wire [AXIS_DEV-1:0]         gAXIS_m_rlast;
wire [AXIS_DEV-1:0]         gAXIS_m_rvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_rready;

// Switch between sdhc and tsemac
wire [(AXIM_DEV*32)-1:0]    gAXIM_s_awaddr;
wire [(AXIM_DEV*8)-1:0]     gAXIM_s_awlen;
wire [(AXIM_DEV*3)-1:0]     gAXIM_s_awsize;
wire [(AXIM_DEV*2)-1:0]     gAXIM_s_awburst;
wire [(AXIM_DEV*2)-1:0]     gAXIM_s_awlock;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_awcache;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_awprot;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_awqos;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_awregion;
wire [AXIM_DEV-1:0]         gAXIM_s_awvalid;
wire [AXIM_DEV-1:0]         gAXIM_s_awready;
wire [(AXIM_DEV*128)-1:0]   gAXIM_s_wdata;
wire [(AXIM_DEV*16)-1:0]    gAXIM_s_wstrb;
wire [AXIM_DEV-1:0]         gAXIM_s_wvalid;
wire [AXIM_DEV-1:0]         gAXIM_s_wlast;
wire [AXIM_DEV-1:0]         gAXIM_s_wready;
wire [(AXIM_DEV*2)-1:0]     gAXIM_s_bresp;
wire [AXIM_DEV-1:0]         gAXIM_s_bvalid;
wire [AXIM_DEV-1:0]         gAXIM_s_bready;
wire [(AXIM_DEV*32)-1:0]    gAXIM_s_araddr;
wire [(AXIM_DEV*8)-1:0]     gAXIM_s_arlen;
wire [(AXIM_DEV*3)-1:0]     gAXIM_s_arsize;
wire [(AXIM_DEV*2)-1:0]     gAXIM_s_arburst;
wire [(AXIM_DEV*2)-1:0]     gAXIM_s_arlock;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_arcache;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_arprot;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_arqos;
wire [(AXIM_DEV*4)-1:0]     gAXIM_s_arregion;
wire [AXIM_DEV-1:0]         gAXIM_s_arvalid;
wire [AXIM_DEV-1:0]         gAXIM_s_arready;
wire [(AXIM_DEV*128)-1:0]   gAXIM_s_rdata;
wire [(AXIM_DEV*2)-1:0]     gAXIM_s_rresp;
wire [AXIM_DEV-1:0]         gAXIM_s_rlast;
wire [AXIM_DEV-1:0]         gAXIM_s_rvalid;
wire [AXIM_DEV-1:0]         gAXIM_s_rready;


/**************************************************
 *
 * AXI Interconnect Instantiation
 * To switch between SDHC, SLB, TSEMAC, Hw Accel
 * 
**************************************************/                    
gAXIS_1to4_switch u_AXIS_1to4_switch
(
    .rst_n              ( ~io_peripheralReset ),
    .clk                ( io_peripheralClk ),
    .m_axi_awvalid      ( gAXIS_m_awvalid ),
    .m_axi_awready      ( gAXIS_m_awready ),
    .m_axi_awid         ( ),
    .m_axi_awaddr       ( gAXIS_m_awaddr ),
    .m_axi_awburst      ( gAXIS_m_awburst ),
    .m_axi_awlen        ( gAXIS_m_awlen ),
    .m_axi_awsize       ( gAXIS_m_awsize ),
    .m_axi_awcache      ( gAXIS_m_awcache ),
    .m_axi_awqos        ( gAXIS_m_awqos ),
    .m_axi_awprot       ( gAXIS_m_awprot ),
    .m_axi_awuser       ( ),
    .m_axi_awlock       ( gAXIS_m_awlock ),
    .m_axi_awregion     ( gAXIS_m_awregion ),
    .m_axi_wvalid       ( gAXIS_m_wvalid ),
    .m_axi_wready       ( gAXIS_m_wready ),
    .m_axi_wdata        ( gAXIS_m_wdata ),
    .m_axi_wstrb        ( gAXIS_m_wstrb ),
    .m_axi_wlast        ( gAXIS_m_wlast ),
    .m_axi_wuser        ( ),
    .m_axi_bready       ( gAXIS_m_bready ),
    .m_axi_bvalid       ( gAXIS_m_bvalid ),
    .m_axi_bresp        ( gAXIS_m_bresp ),
    .m_axi_buser        ( {AXIS_DEV{3'h0}} ),
    .m_axi_bid          ( {AXIS_DEV{8'h0}} ),
    .m_axi_arvalid      ( gAXIS_m_arvalid ),
    .m_axi_arready      ( gAXIS_m_arready ),
    .m_axi_arid         ( ),
    .m_axi_araddr       ( gAXIS_m_araddr ),
    .m_axi_arburst      ( gAXIS_m_arburst ),
    .m_axi_arlen        ( gAXIS_m_arlen ),
    .m_axi_arsize       ( gAXIS_m_arsize ),
    .m_axi_arlock       ( gAXIS_m_arlock ),
    .m_axi_arprot       ( gAXIS_m_arprot ),
    .m_axi_arcache      ( gAXIS_m_arcache ),
    .m_axi_arqos        ( gAXIS_m_arqos ),
    .m_axi_aruser       ( ),
    .m_axi_arregion     ( gAXIS_m_arregion ),
    .m_axi_ruser        ( {AXIS_DEV{3'h0}}),
    .m_axi_rvalid       ( gAXIS_m_rvalid ),
    .m_axi_rready       ( gAXIS_m_rready ),
    .m_axi_rid          ( {AXIS_DEV{8'h0}}),
    .m_axi_rdata        ( gAXIS_m_rdata ),
    .m_axi_rresp        ( gAXIS_m_rresp ),
    .m_axi_rlast        ( gAXIS_m_rlast ),
    .s_axi_awvalid      ( axiA_awvalid ),
    .s_axi_awready      ( axiA_awready ),
    .s_axi_awaddr       ( {7'h00, axiA_awaddr[24:0]} ),
    .s_axi_awid         ( 8'h00 ),
    .s_axi_awburst      ( axiA_awburst ),
    .s_axi_awlen        ( axiA_awlen ),
    .s_axi_awsize       ( axiA_awsize ),
    .s_axi_awprot       ( {1'b0, axiA_awprot} ),
    .s_axi_awlock       ( {1'b0, axiA_awlock} ),
    .s_axi_awcache      ( axiA_awcache ),
    .s_axi_awqos        ( axiA_awqos ),
    .s_axi_awuser       ( 3'h0 ),
    .s_axi_wvalid       ( axiA_wvalid ),
    .s_axi_wready       ( axiA_wready ),
    .s_axi_wid          ( 8'h00 ),
    .s_axi_wdata        ( axiA_wdata ),
    .s_axi_wlast        ( axiA_wlast ),
    .s_axi_wstrb        ( axiA_wstrb ),
    .s_axi_wuser        ( 3'h0 ),
    .s_axi_bvalid       ( axiA_bvalid ),
    .s_axi_bready       ( axiA_bready ),
    .s_axi_bresp        ( axiA_bresp ),
    .s_axi_bid          ( ),
    .s_axi_buser        ( ),
    .s_axi_arvalid      ( axiA_arvalid ),
    .s_axi_arready      ( axiA_arready ),
    .s_axi_araddr       ( {7'h00, axiA_araddr[24:0]} ),
    .s_axi_arid         ( 8'h00 ),
    .s_axi_arburst      ( axiA_arburst ),
    .s_axi_arlen        ( axiA_arlen ),
    .s_axi_arsize       ( axiA_arsize ),
    .s_axi_arprot       ( { 1'b0, axiA_arprot} ),
    .s_axi_arlock       ( { 1'b0, axiA_arlock} ),
    .s_axi_arcache      ( axiA_arcache ),
    .s_axi_arqos        ( axiA_arqos ),
    .s_axi_aruser       ( 3'h0 ),
    .s_axi_rready       ( axiA_rready ),
    .s_axi_rvalid       ( axiA_rvalid ),
    .s_axi_rdata        ( axiA_rdata ),
    .s_axi_rresp        ( axiA_rresp ),
    .s_axi_rlast        ( axiA_rlast ),
    .s_axi_rid          ( ),
    .s_axi_ruser        ( )
);

/**************************************************
 *
 * AXI Interconnect Instantiation
 * To switch between access of SDHC and TSEMAC to ddrMaster of Soc 
 * 
**************************************************/ 
gAXIM_2to1_switch u_AXIM_2to1_switch
(
    .rst_n              ( ~io_ddrMasters_0_reset ),
    .clk                ( io_ddrMasters_0_clk ),
    .m_axi_awvalid      ( io_ddrMasters_0_aw_valid ),
    .m_axi_awready      ( io_ddrMasters_0_aw_ready ),
    .m_axi_awid         ( io_ddrMasters_0_aw_payload_id ),
    .m_axi_awaddr       ( io_ddrMasters_0_aw_payload_addr ),
    .m_axi_awburst      ( io_ddrMasters_0_aw_payload_burst ),
    .m_axi_awlen        ( io_ddrMasters_0_aw_payload_len ),
    .m_axi_awsize       ( io_ddrMasters_0_aw_payload_size ),
    .m_axi_awcache      ( io_ddrMasters_0_aw_payload_cache ),
    .m_axi_awqos        ( io_ddrMasters_0_aw_payload_qos ),
    .m_axi_awprot       ( io_ddrMasters_0_aw_payload_prot ),
    .m_axi_awuser       ( ),
    .m_axi_awlock       ( io_ddrMasters_0_aw_payload_lock ),
    .m_axi_awregion     ( io_ddrMasters_0_aw_payload_region ),
    .m_axi_wvalid       ( io_ddrMasters_0_w_valid ),
    .m_axi_wready       ( io_ddrMasters_0_w_ready ),
    .m_axi_wdata        ( io_ddrMasters_0_w_payload_data ),
    .m_axi_wstrb        ( io_ddrMasters_0_w_payload_strb ),
    .m_axi_wlast        ( io_ddrMasters_0_w_payload_last ),
    .m_axi_wuser        ( ),
    .m_axi_bready       ( io_ddrMasters_0_b_ready ),
    .m_axi_bvalid       ( io_ddrMasters_0_b_valid ),
    .m_axi_bresp        ( io_ddrMasters_0_b_payload_resp ),
    .m_axi_buser        ( 3'h0 ),
    .m_axi_bid          ( {4'h0, io_ddrMasters_0_b_payload_id} ),
    .m_axi_arvalid      ( io_ddrMasters_0_ar_valid ),
    .m_axi_arready      ( io_ddrMasters_0_ar_ready ),
    .m_axi_arid         ( io_ddrMasters_0_ar_payload_id ),
    .m_axi_araddr       ( io_ddrMasters_0_ar_payload_addr ),
    .m_axi_arburst      ( io_ddrMasters_0_ar_payload_burst ),
    .m_axi_arlen        ( io_ddrMasters_0_ar_payload_len ),
    .m_axi_arsize       ( io_ddrMasters_0_ar_payload_size ),
    .m_axi_arlock       ( io_ddrMasters_0_ar_payload_lock ),
    .m_axi_arprot       ( io_ddrMasters_0_ar_payload_prot ),
    .m_axi_arcache      ( io_ddrMasters_0_ar_payload_cache ),
    .m_axi_arqos        ( io_ddrMasters_0_ar_payload_qos ),
    .m_axi_aruser       ( ),
    .m_axi_arregion     ( io_ddrMasters_0_ar_payload_region ),
    .m_axi_ruser        ( 3'h0),
    .m_axi_rvalid       ( io_ddrMasters_0_r_valid ),
    .m_axi_rready       ( io_ddrMasters_0_r_ready ),
    .m_axi_rid          ( 8'h0 ),
    .m_axi_rdata        ( io_ddrMasters_0_r_payload_data ),
    .m_axi_rresp        ( io_ddrMasters_0_r_payload_resp ),
    .m_axi_rlast        ( io_ddrMasters_0_r_payload_last ),
    .s_axi_awvalid      ( gAXIM_s_awvalid ),
    .s_axi_awready      ( gAXIM_s_awready ),
    .s_axi_awaddr       ( gAXIM_s_awaddr ),
    .s_axi_awid         ( {AXIM_DEV{8'h00}} ),
    .s_axi_awburst      ( gAXIM_s_awburst ),
    .s_axi_awlen        ( gAXIM_s_awlen ),
    .s_axi_awsize       ( gAXIM_s_awsize ),
    .s_axi_awprot       ( gAXIM_s_awprot ),
    .s_axi_awlock       ( gAXIM_s_awlock ),
    .s_axi_awcache      ( gAXIM_s_awcache ),
    .s_axi_awqos        ( gAXIM_s_awqos ),
    .s_axi_awuser       ( {AXIM_DEV{3'h0}} ),
    .s_axi_wvalid       ( gAXIM_s_wvalid ),
    .s_axi_wready       ( gAXIM_s_wready ),
    .s_axi_wid          ( {AXIM_DEV{8'h00}} ),
    .s_axi_wdata        ( gAXIM_s_wdata ),
    .s_axi_wlast        ( gAXIM_s_wlast ),
    .s_axi_wstrb        ( gAXIM_s_wstrb ),
    .s_axi_wuser        ( {AXIM_DEV{3'h0}} ),
    .s_axi_bvalid       ( gAXIM_s_bvalid ),
    .s_axi_bready       ( gAXIM_s_bready ),
    .s_axi_bresp        ( gAXIM_s_bresp ),
    .s_axi_bid          ( ),
    .s_axi_buser        ( ),
    .s_axi_arvalid      ( gAXIM_s_arvalid ),
    .s_axi_arready      ( gAXIM_s_arready ),
    .s_axi_araddr       ( gAXIM_s_araddr ),
    .s_axi_arid         ( {AXIM_DEV{8'h00}} ),
    .s_axi_arburst      ( gAXIM_s_arburst ),
    .s_axi_arlen        ( gAXIM_s_arlen ),
    .s_axi_arsize       ( gAXIM_s_arsize ),
    .s_axi_arprot       ( gAXIM_s_axiA_arprot ),
    .s_axi_arlock       ( gAXIM_s_axiA_arlock ),
    .s_axi_arcache      ( gAXIM_s_arcache ),
    .s_axi_arqos        ( gAXIM_s_arqos ),
    .s_axi_aruser       ( {AXIM_DEV{3'h0}} ),
    .s_axi_rready       ( gAXIM_s_rready ),
    .s_axi_rvalid       ( gAXIM_s_rvalid ),
    .s_axi_rdata        ( gAXIM_s_rdata ),
    .s_axi_rresp        ( gAXIM_s_rresp ),
    .s_axi_rlast        ( gAXIM_s_rlast ),
    .s_axi_rid          ( ),
    .s_axi_ruser        ( )
);

/****************************************** SD Related Modules Instantiation *****************************************/

`ifdef ENABLE_SDHC

// SDHC
wire            sd_rst;
wire            sd_int;
wire            sd_dat_oe_i;

assign sd_rst                       = io_peripheralReset;
assign gAXIS_m_rlast[SDHC*1 +: 1]   = 1'b1;
assign sd_dat_oe                    = {4{sd_dat_oe_i}};

/**************************************************
 *
 * SDHC Instantiation
 * 
**************************************************/ 
gSDHC u_gSDHC
(
    .sd_rst             ( sd_rst ),
    .sd_base_clk        ( sd_base_clk ),
    .sd_int             ( sd_int ),
    .sd_cd_n            ( sd_cd_n ),
    .sd_wp              ( sd_wp ),
    .s_axi_aclk         ( io_peripheralClk ),
    .s_axi_awaddr       ( gAXIS_m_awaddr[SDHC*32 +: 32] ),
    .s_axi_awready      ( gAXIS_m_awready[SDHC*1 +: 1] ),
    .s_axi_awvalid      ( gAXIS_m_awvalid[SDHC*1 +: 1] ),
    .s_axi_wstrb        ( gAXIS_m_wstrb[SDHC*4 +: 4]),
    .s_axi_wdata        ( gAXIS_m_wdata[SDHC*32 +: 32] ),
    .s_axi_wready       ( gAXIS_m_wready[SDHC*1 +: 1] ),
    .s_axi_wvalid       ( gAXIS_m_wvalid[SDHC*1 +: 1] ),
    .s_axi_bresp        ( gAXIS_m_bresp[SDHC*2 +: 2] ),
    .s_axi_bvalid       ( gAXIS_m_bvalid[SDHC*1 +: 1] ),
    .s_axi_araddr       ( gAXIS_m_araddr[SDHC*32 +: 32] ),
    .s_axi_bready       ( gAXIS_m_bready[SDHC*1 +: 1] ),
    .s_axi_arready      ( gAXIS_m_arready[SDHC*1 +: 1] ),
    .s_axi_arvalid      ( gAXIS_m_arvalid[SDHC*1 +: 1] ),
    .s_axi_rresp        ( gAXIS_m_rresp[SDHC*2 +: 2] ),
    .s_axi_rdata        ( gAXIS_m_rdata[SDHC*32 +: 32]),
    .s_axi_rvalid       ( gAXIS_m_rvalid[SDHC*1 +: 1] ),
    .s_axi_rready       ( gAXIS_m_rready[SDHC*1 +: 1] ),
    .m_axi_clk          ( io_ddrMasters_0_clk ),
    .m_axi_awaddr       ( gAXIM_s_awaddr[MSDHC*32 +: 32] ),
    .m_axi_awvalid      ( gAXIM_s_awvalid[MSDHC*1 +: 1] ),
    .m_axi_awlen        ( gAXIM_s_awlen[MSDHC*8 +: 8] ),
    .m_axi_awready      ( gAXIM_s_awready[MSDHC*1 +: 1] ),
    .m_axi_awburst      ( gAXIM_s_awburst[MSDHC*2 +: 2] ),
    .m_axi_awsize       ( gAXIM_s_awsize[MSDHC*3 +: 3] ),
    .m_axi_awcache      ( gAXIM_s_awcache[MSDHC*4 +: 4] ),
    .m_axi_awlock       ( gAXIM_s_awlock[MSDHC*2 +: 2] ),
    .m_axi_awprot       ( gAXIM_s_awprot[MSDHC*4 +: 4] ),
    .m_axi_wdata        ( gAXIM_s_wdata[MSDHC*128 +: 128] ),
    .m_axi_wstrb        ( gAXIM_s_wstrb[MSDHC*16 +: 16] ),
    .m_axi_wlast        ( gAXIM_s_wlast[MSDHC*1 +: 1] ),
    .m_axi_wvalid       ( gAXIM_s_wvalid[MSDHC*1 +: 1] ),
    .m_axi_wready       ( gAXIM_s_wready[MSDHC*1 +:1] ),
    .m_axi_bresp        ( gAXIM_s_bresp[MSDHC*2 +: 2] ),
    .m_axi_bvalid       ( gAXIM_s_bvalid[MSDHC*1 +: 1] ),
    .m_axi_bready       ( gAXIM_s_bready[MSDHC*1 +: 1] ),
    .m_axi_arvalid      ( gAXIM_s_arvalid[MSDHC*1 +: 1] ),
    .m_axi_araddr       ( gAXIM_s_araddr[MSDHC*32 +: 32] ),
    .m_axi_arlen        ( gAXIM_s_arlen[MSDHC*8 +: 8] ),
    .m_axi_arsize       ( gAXIM_s_arsize[MSDHC*3 +: 3] ),
    .m_axi_arburst      ( gAXIM_s_arburst[MSDHC*2 +: 2] ),
    .m_axi_arprot       ( gAXIM_s_arprot[MSDHC*4 +: 4] ),
    .m_axi_arlock       ( gAXIM_s_arlock[MSDHC*2 +: 2] ),
    .m_axi_arcache      ( gAXIM_s_arcache[MSDHC*4 +: 4] ),
    .m_axi_arready      ( gAXIM_s_arready[MHSDC*1 +: 1] ),
    .m_axi_rvalid       ( gAXIM_s_rvalid[MSDHC*1 +: 1] ),
    .m_axi_rdata        ( gAXIM_s_rdata[MSDHC*128 +: 128] ),
    .m_axi_rlast        ( gAXIM_s_rlast[MSDHC*1 +: 1] ),
    .m_axi_rresp        ( gAXIM_s_rresp[MSDHC*2 +: 2] ),
    .m_axi_rready       ( gAXIM_s_rready[MSDHC*1 +: 1] ),
    .sd_clk_hi          ( sd_clk_hi ),
    .sd_clk_lo          ( sd_clk_lo ),
    .sd_cmd_i           ( sd_cmd_i ),
    .sd_cmd_o           ( sd_cmd_o ),
    .sd_cmd_oe          ( sd_cmd_oe ),
    .sd_dat_i           ( sd_dat_i ),
    .sd_dat_o           ( sd_dat_o ),
    .sd_dat_oe          ( sd_dat_oe_i )
);

`endif // ENABLE_SDHC

/********************************************* TSEMAC ********************************************/
`ifdef ENABLE_ETHERNET

// TSE
wire            tse_pll_ok;       
wire            phy_sw_rst;   
wire            mac_ext_rst;
wire [2:0]      eth_speed;
wire            s_eth_tx_tvalid;
wire            s_eth_tx_tready;
wire [7:0]      s_eth_tx_tdata;
wire [0:0]      s_eth_tx_tkeep;
wire [3:0]      s_eth_tx_tdest;
wire            s_eth_tx_tlast;
wire            m_eth_rx_tvalid;
wire            m_eth_rx_tready;
wire [7:0]      m_eth_rx_tdata;
wire [0:0]      m_eth_rx_tkeep;
wire [3:0]      m_eth_rx_tdest;
wire            m_eth_rx_tlast;

assign m_eth_rx_tdest  = 4'h0;
assign phy_rst         = phy_sw_rst;
assign tse_pll_ok      = pll_tse_locked & pll_peripheral_locked;

// if 1000mbps, output 125mhz                  
// default as 100mbps/10mbps, output 25mhz/12.5mhz 
assign mux_clk_sw      = (eth_speed == 3'b100) ? 2'b10 : 2'b11; 


tseCore  #(
    .FAMILY                 (FAMILY)
)u_tseCore(
    .io_peripheralClk        ( io_peripheralClk ),
    .io_peripheralReset      ( io_peripheralReset ),
    .io_tseClk               ( io_tseClk ),
    .pll_locked              ( tse_pll_ok ),
    .phy_sw_rst              ( phy_sw_rst ),
    .mac_ext_rst             ( mac_ext_rst ),
    .dma_rx_rst              ( dma_rx_rst ),
    .dma_tx_rst              ( dma_tx_rst ),
    .dma_tx_descriptorUpdate ( dma_tx_descriptorUpdate ),
    .dma_interrupts          ( dma_interrupts ),
    .eth_speed               ( eth_speed ),
    .rgmii_txd_HI            ( rgmii_txd_HI ),
    .rgmii_txd_LO            ( rgmii_txd_LO ),
    .rgmii_tx_ctl_HI         ( rgmii_tx_ctl_HI ),
    .rgmii_tx_ctl_LO         ( rgmii_tx_ctl_LO ),
    .rgmii_txc_HI            ( rgmii_txc_HI ),
    .rgmii_txc_LO            ( rgmii_txc_LO ),
    .rgmii_rxd_HI            ( rgmii_rxd_HI ),
    .rgmii_rxd_LO            ( rgmii_rxd_LO ),
    .rgmii_rx_ctl_HI         ( rgmii_rx_ctl_HI ),
    .rgmii_rx_ctl_LO         ( rgmii_rx_ctl_LO ),
    .rgmii_rxc               ( mux_clk ), 
    .phy_mdi                 ( phy_mdi ),
    .phy_mdo                 ( phy_mdo ),
    .phy_mdo_en              ( phy_mdo_en ),
    .phy_mdc                 ( phy_mdc ), 
    .s_axi_awaddr            ( gAXIS_m_awaddr[TSE*32 +: 32] ),   
    .s_axi_awvalid           ( gAXIS_m_awvalid[TSE*1 +: 1] ),  
    .s_axi_awready           ( gAXIS_m_awready[TSE*1 +: 1] ),  
    .s_axi_wdata             ( gAXIS_m_wdata[TSE*32 +: 32] ),    
    .s_axi_wstrb             ( gAXIS_m_wstrb[TSE*4 +: 4] ),
    .s_axi_wlast             ( gAXIS_m_wlast[TSE*1 +: 1] ),
    .s_axi_wvalid            ( gAXIS_m_wvalid[TSE*1 +: 1] ),   
    .s_axi_wready            ( gAXIS_m_wready[TSE*1 +: 1] ),   
    .s_axi_bresp             ( gAXIS_m_bresp[TSE*2 +: 2] ),    
    .s_axi_bvalid            ( gAXIS_m_bvalid[TSE*1 +: 1] ),   
    .s_axi_bready            ( gAXIS_m_bready[TSE*1 +: 1] ),   
    .s_axi_araddr            ( gAXIS_m_araddr[TSE*32 +: 32] ),   
    .s_axi_arvalid           ( gAXIS_m_arvalid[TSE*1 +: 1] ),  
    .s_axi_arready           ( gAXIS_m_arready[TSE*1 +: 1] ),  
    .s_axi_rresp             ( gAXIS_m_rresp[TSE*2 +: 2] ),    
    .s_axi_rdata             ( gAXIS_m_rdata[TSE*32 +: 32] ),    
    .s_axi_rlast             ( gAXIS_m_rlast[TSE*1 +: 1] ),
    .s_axi_rvalid            ( gAXIS_m_rvalid[TSE*1 +: 1] ),   
    .s_axi_rready            ( gAXIS_m_rready[TSE*1 +: 1] ),
    .s_eth_tx_tvalid         ( s_eth_tx_tvalid ),
    .s_eth_tx_tready         ( s_eth_tx_tready ),
    .s_eth_tx_tdata          ( s_eth_tx_tdata  ),
    .s_eth_tx_tkeep          ( s_eth_tx_tkeep  ),
    .s_eth_tx_tdest          ( s_eth_tx_tdest  ),
    .s_eth_tx_tlast          ( s_eth_tx_tlast  ),
    .m_eth_rx_tvalid         ( m_eth_rx_tvalid ),
    .m_eth_rx_tready         ( m_eth_rx_tready ),
    .m_eth_rx_tdata          ( m_eth_rx_tdata  ),
    .m_eth_rx_tstrb          ( m_eth_rx_tstrb  ),
    .m_eth_rx_tlast          ( m_eth_rx_tlast  )
);

/**************************************************
 *
 * DMA Instantiation
 * To pass data to/from TSEMAC with DDR 
 * 
**************************************************/ 
gDMA u_gDMA (
    .clk                     ( io_ddrMasters_0_clk ),
    .reset                   ( io_ddrMasters_0_reset ),
    .ctrl_clk                ( io_peripheralClk      ),
    .ctrl_reset              ( io_peripheralReset    ),
    .ctrl_PADDR              ( tse_dma_apbSlave_2_PADDR    ),
    .ctrl_PREADY             ( tse_dma_apbSlave_2_PREADY   ),
    .ctrl_PENABLE            ( tse_dma_apbSlave_2_PENABLE  ),
    .ctrl_PSEL               ( tse_dma_apbSlave_2_PSEL     ),
    .ctrl_PWRITE             ( tse_dma_apbSlave_2_PWRITE   ),
    .ctrl_PWDATA             ( tse_dma_apbSlave_2_PWDATA   ),
    .ctrl_PRDATA             ( tse_dma_apbSlave_2_PRDATA   ),
    .ctrl_PSLVERROR          ( tse_dma_apbSlave_2_PSLVERROR),
    .ctrl_interrupts         ( dma_interrupts ),
    .read_arvalid            ( gAXIM_s_arvalid[MTSE*1 +: 1] ),
    .read_araddr             ( gAXIM_s_araddr[MTSE*32 +: 32] ),
    .read_arready            ( gAXIM_s_arready[MTSE*1 +: 1] ),
    .read_arregion           ( gAXIM_s_arregion[MTSE*4 +: 4] ),
    .read_arlen              ( gAXIM_s_arlen[MTSE*8 +: 8] ),
    .read_arsize             ( gAXIM_s_arsize[MTSE*3 +: 3] ),
    .read_arburst            ( gAXIM_s_arburst[MTSE*2 +: 2] ),
    .read_arlock             ( gAXIM_s_arlock[MTSE*2 +: 2] ),
    .read_arcache            ( gAXIM_s_arcache[MTSE*4 +: 4] ),
    .read_arqos              ( gAXIM_s_arqos[MTSE*4 +: 4] ),
    .read_arprot             ( gAXIM_s_arprot[MTSE*4 +: 4] ),
    .read_rready             ( gAXIM_s_rready[MTSE*1 +: 1] ),
    .read_rvalid             ( gAXIM_s_rvalid[MTSE*1 +: 1] ),
    .read_rdata              ( gAXIM_s_rdata[MTSE*128 +: 128] ),
    .read_rlast              ( gAXIM_s_rlast[MTSE*1 +: 1] ),
    .read_rresp              ( gAXIM_s_rresp[MTSE*2 +: 2] ),
    .write_awvalid           ( gAXIM_s_awvalid[MTSE*1 +: 1] ),
    .write_awready           ( gAXIM_s_awready[MTSE*1 +: 1] ),
    .write_awaddr            ( gAXIM_s_awaddr[MTSE*32 +: 32] ),
    .write_awregion          ( gAXIM_s_awregion[MTSE*4 +: 4] ),
    .write_awlen             ( gAXIM_s_awlen[MTSE*8 +: 8] ),
    .write_awsize            ( gAXIM_s_awsize[MTSE*3 +: 3] ),
    .write_awburst           ( gAXIM_s_awburst[MTSE*2 +: 2] ),
    .write_awlock            ( gAXIM_s_awlock[MTSE*2 +: 2] ),
    .write_awcache           ( gAXIM_s_awcache[MTSE*4 +: 4] ),
    .write_awqos             ( gAXIM_s_awqos[MTSE*4 +: 4] ),
    .write_awprot            ( gAXIM_s_awprot[MTSE*4 +: 4] ),
    .write_wvalid            ( gAXIM_s_wvalid[MTSE*1 +: 1] ),
    .write_wready            ( gAXIM_s_wready[MTSE*1 +: 1] ),
    .write_wdata             ( gAXIM_s_wdata[MTSE*128 +: 128] ),
    .write_wstrb             ( gAXIM_s_wstrb[MTSE*16 +: 16] ),
    .write_wlast             ( gAXIM_s_wlast[MTSE*1 +: 1] ),
    .write_bvalid            ( gAXIM_s_bvalid[MTSE*1 +: 1] ),
    .write_bready            ( gAXIM_s_bready[MTSE*1 +: 1] ),
    .write_bresp             ( gAXIM_s_bresp[MTSE*2 +: 2] ),
    .dat1_o_clk              ( io_tseClk ),
    .dat1_o_reset            ( mac_ext_rst | dma_tx_rst),
    .dat1_o_tvalid           ( s_eth_tx_tvalid ),
    .dat1_o_tready           ( s_eth_tx_tready ),
    .dat1_o_tdata            ( s_eth_tx_tdata ),
    .dat1_o_tkeep            ( s_eth_tx_tkeep ),
    .dat1_o_tdest            ( s_eth_tx_tdest ),
    .dat1_o_tlast            ( s_eth_tx_tlast ),
    .dat0_i_clk              ( mux_clk ),
    .dat0_i_reset            ( mac_ext_rst | dma_rx_rst ),
    .dat0_i_tvalid           ( m_eth_rx_tvalid ),
    .dat0_i_tready           ( m_eth_rx_tready ),
    .dat0_i_tdata            ( m_eth_rx_tdata ),
    .dat0_i_tkeep            ( 1'b1),
    .dat0_i_tdest            ( m_eth_rx_tdest ),
    .dat0_i_tlast            ( m_eth_rx_tlast ),
    .io_1_descriptorUpdate   (  ),
    .io_0_descriptorUpdate   (dma_tx_descriptorUpdate)
  
);

`endif // ENABLE_ETHERNET

/*********************************************Edge Vision Soc  ****************************************************/

`ifdef ENABLE_EVSOC

// Camera (DMA)
wire         cam_dma_wready;
wire         cam_dma_wvalid;
wire         cam_dma_wlast;
wire [63:0]  cam_dma_wdata;

// Display Module (DMA)
wire           display_dma_rready;
wire           display_dma_rvalid;
wire [63:0]    display_dma_rdata;
wire [7:0]     display_dma_rkeep;

// Hardware accelerator (DMA)
wire            hw_accel_dma_rready;
wire            hw_accel_dma_rvalid;
wire [3:0]      hw_accel_dma_rkeep;
wire [31:0]     hw_accel_dma_rdata;
wire            hw_accel_dma_wready;
wire            hw_accel_dma_wvalid;
wire            hw_accel_dma_wlast;
wire [31:0]     hw_accel_dma_wdata;

`ifdef ENABLE_EVSOC_DISPLAY

//EVSOC (CAM & DISPLAY)
assign hdmi_yuv_vs_OE = !hdmi_yuv_vs;
assign hdmi_yuv_hs_OE = !hdmi_yuv_hs;

`endif //ENABLE_EVSOC_DISPLAY


/**************************************************
 *
 * Vision Wrapper 
 * Camera, Display and Hw Accel Related Module
 * 
**************************************************/ 

efx_isg_vision_wrapper  #(
    .FAMILY                 ( FAMILY              ),
    .DISPLAY_MODE           ( DISPLAY_MODE        ),
    .MIPI_FRAME_WIDTH       ( MIPI_FRAME_WIDTH    ),
    .MIPI_FRAME_HEIGHT      ( MIPI_FRAME_HEIGHT   ),
    .HW_ACCEL_ADDR_WIDTH    ( HW_ACCEL_ADDR_WIDTH ), 
    .HW_ACCEL_DATA_WIDTH    ( HW_ACCEL_DATA_WIDTH ),
    .APB3_ADDR_WIDTH        ( APB3_ADDR_WIDTH     ),
    .APB3_DATA_WIDTH        ( APB3_DATA_WIDTH     ) 
) u_evsoc (
    // Clock
    .i_pixel_clk           ( i_pixel_clk         ),
    .io_peripheralClk      ( io_peripheralClk    ),
    .io_peripheralReset    ( io_peripheralReset  ),
    .i_hdmi_clk_148p5MHz   ( i_hdmi_clk_148p5MHz ),
    .i_sys_clk_25mhz       ( i_sys_clk_25mhz     ),
    .i_arstn               ( i_arstn             ),

    // PLL Locked
    .pll_system_locked     ( pll_system_locked     ), 
    .pll_hdmi_locked       ( pll_hdmi_locked       ),
    .pll_peripheral_locked ( pll_peripheral_locked ),

    // MIPI RX - Camera
    .cam_ck_LP_P_IN       ( cam_ck_LP_P_IN  ), 
    .cam_ck_LP_N_IN       ( cam_ck_LP_N_IN  ), 
    .cam_ck_HS_TERM       ( cam_ck_HS_TERM  ), 
    .cam_ck_HS_ENA        ( cam_ck_HS_ENA   ), 
    .cam_ck_CLKOUT        ( cam_ck_CLKOUT   ), 
    .cam_d0_HS_IN         ( cam_d0_HS_IN    ), 
    .cam_d0_HS_IN_1       ( cam_d0_HS_IN_1  ), 
    .cam_d0_HS_IN_2       ( cam_d0_HS_IN_2  ), 
    .cam_d0_HS_IN_3       ( cam_d0_HS_IN_3  ), 
    .cam_d0_LP_P_IN       ( cam_d0_LP_P_IN  ), 
    .cam_d0_LP_N_IN       ( cam_d0_LP_N_IN  ), 
    .cam_d0_HS_TERM       ( cam_d0_HS_TERM  ), 
    .cam_d0_HS_ENA        ( cam_d0_HS_ENA   ), 
    .cam_d0_RST           ( cam_d0_RST      ), 
    .cam_d0_FIFO_RD       ( cam_d0_FIFO_RD  ), 
    .cam_d0_FIFO_EMPTY    ( cam_d0_FIFO_EMPTY ), 
    .cam_d1_HS_IN         ( cam_d1_HS_IN   ), 
    .cam_d1_HS_IN_1       ( cam_d1_HS_IN_1 ), 
    .cam_d1_HS_IN_2       ( cam_d1_HS_IN_2 ), 
    .cam_d1_HS_IN_3       ( cam_d1_HS_IN_3 ), 
    .cam_d1_LP_P_IN       ( cam_d1_LP_P_IN ), 
    .cam_d1_LP_N_IN       ( cam_d1_LP_N_IN ), 
    .cam_d1_HS_TERM       ( cam_d1_HS_TERM ), 
    .cam_d1_HS_ENA        ( cam_d1_HS_ENA  ), 
    .cam_d1_RST           ( cam_d1_RST     ), 
    .cam_d1_FIFO_RD       ( cam_d1_FIFO_RD ), 
    .cam_d1_FIFO_EMPTY    ( cam_d1_FIFO_EMPTY ),

    // Camera (DMA)
    .cam_dma_wready     ( cam_dma_wready  ), 
    .cam_dma_wvalid     ( cam_dma_wvalid  ), 
    .cam_dma_wlast      ( cam_dma_wlast   ), 
    .cam_dma_wdata      ( cam_dma_wdata   ), 

    // I2C Configuration for HDMI
    .i2c_sda_i          ( i_hdmi_sda ), 
    .i2c_scl_i          ( i_hdmi_scl ), 
    .i2c_sda_oe         ( o_hdmi_sda_oe ), 
    .i2c_scl_oe         ( o_hdmi_scl_oe ), 

    // HDMI YUV Output
    .hdmi_yuv_vs    ( hdmi_yuv_vs ), 
    .hdmi_yuv_hs    ( hdmi_yuv_hs ), 
    .hdmi_yuv_de    ( hdmi_yuv_de ), 
    .hdmi_yuv_data  ( hdmi_yuv_data ),    

    // HDMI Display (DMA)
    .display_dma_rdata  ( display_dma_rdata ), 
    .display_dma_rvalid ( display_dma_rvalid ), 
    .display_dma_rkeep  ( display_dma_rkeep ), 
    .display_dma_rready ( display_dma_rready ),

    // Hardware Accelerator (DMA)
    .hw_accel_dma_rready ( hw_accel_dma_rready ),
    .hw_accel_dma_rvalid ( hw_accel_dma_rvalid ),
    .hw_accel_dma_rdata  ( hw_accel_dma_rdata  ),
    .hw_accel_dma_rkeep  ( hw_accel_dma_rkeep  ),
    .hw_accel_dma_wready ( hw_accel_dma_wready ),
    .hw_accel_dma_wvalid ( hw_accel_dma_wvalid ),
    .hw_accel_dma_wlast  ( hw_accel_dma_wlast  ),
    .hw_accel_dma_wdata  ( hw_accel_dma_wdata  ),

    // Hardware Accelerator
    .axi_interrupt ( w_axiAInterrupt ),
    .axi_awid      ( 'd0 ),
    .axi_awaddr    ( gAXIS_m_awaddr  [HW_ACCEL*32 +: 32] ),
    .axi_awlen     ( gAXIS_m_awlen   [HW_ACCEL*8 +: 8]   ),
    .axi_awsize    ( gAXIS_m_awsize  [HW_ACCEL*3 +: 3]   ),
    .axi_awburst   ( gAXIS_m_awburst [HW_ACCEL*2 +: 2]   ),
    .axi_awlock    ( gAXIS_m_awlock  [HW_ACCEL*2 +: 2]   ),
    .axi_awcache   ( gAXIS_m_awcache [HW_ACCEL*4 +: 4]   ),
    .axi_awprot    ( gAXIS_m_awprot  [HW_ACCEL*3 +: 3]   ),
    .axi_awqos     ( gAXIS_m_awqos   [HW_ACCEL*4 +: 4]   ),
    .axi_awregion  ( gAXIS_m_awregion[HW_ACCEL*4 +: 4]   ),
    .axi_awvalid   ( gAXIS_m_awvalid [HW_ACCEL*1 +: 1]   ),
    .axi_awready   ( gAXIS_m_awready [HW_ACCEL*1 +: 1]   ),
    .axi_wdata     ( gAXIS_m_wdata   [HW_ACCEL*32 +: 32] ),
    .axi_wstrb     ( gAXIS_m_wstrb   [HW_ACCEL*4 +: 4]   ),
    .axi_wlast     ( gAXIS_m_wlast   [HW_ACCEL*1 +: 1]   ),
    .axi_wvalid    ( gAXIS_m_wvalid  [HW_ACCEL*1 +: 1]   ),
    .axi_wready    ( gAXIS_m_wready  [HW_ACCEL*1 +: 1]   ),
    .axi_bid       (), 
    .axi_bresp     ( gAXIS_m_bresp   [HW_ACCEL*2 +: 2]   ),
    .axi_bvalid    ( gAXIS_m_bvalid  [HW_ACCEL*1 +: 1]   ),
    .axi_bready    ( gAXIS_m_bready  [HW_ACCEL*1 +: 1]   ),
    .axi_arid      ( 'd0), 
    .axi_araddr    ( gAXIS_m_araddr  [HW_ACCEL*32 +: 32] ),
    .axi_arlen     ( gAXIS_m_arlen   [HW_ACCEL*8 +: 8]   ),
    .axi_arsize    ( gAXIS_m_arsize  [HW_ACCEL*3 +: 3]   ),
    .axi_arburst   ( gAXIS_m_arburst [HW_ACCEL*2 +: 2]   ),
    .axi_arlock    ( gAXIS_m_arlock  [HW_ACCEL*2 +: 2]   ),
    .axi_arcache   ( gAXIS_m_arcache [HW_ACCEL*4 +: 4]   ),
    .axi_arprot    ( gAXIS_m_arprot  [HW_ACCEL*3 +: 3]   ),
    .axi_arqos     ( gAXIS_m_arqos   [HW_ACCEL*4 +: 4]   ),
    .axi_arregion  ( gAXIS_m_arregion[HW_ACCEL*4 +: 4]   ),
    .axi_arvalid   ( gAXIS_m_arvalid [HW_ACCEL*1 +: 1]   ),
    .axi_arready   ( gAXIS_m_arready [HW_ACCEL*1 +: 1]   ),
    .axi_rid       (),
    .axi_rdata     ( gAXIS_m_rdata   [HW_ACCEL*32 +: 32] ),
    .axi_rresp     ( gAXIS_m_rresp   [HW_ACCEL*2 +: 2]   ),
    .axi_rlast     ( gAXIS_m_rlast   [HW_ACCEL*1 +: 1]   ),
    .axi_rvalid    ( gAXIS_m_rvalid  [HW_ACCEL*1 +: 1]   ),
    .axi_rready    ( gAXIS_m_rready  [HW_ACCEL*1 +: 1]   ), 

    //Control Register APB3
    .vision_PADDR         ( vision_apbSlave_1_PADDR     ),
    .vision_PSEL          ( vision_apbSlave_1_PSEL      ),
    .vision_PENABLE       ( vision_apbSlave_1_PENABLE   ),
    .vision_PREADY        ( vision_apbSlave_1_PREADY    ),
    .vision_PWRITE        ( vision_apbSlave_1_PWRITE    ),
    .vision_PWDATA        ( vision_apbSlave_1_PWDATA    ),
    .vision_PRDATA        ( vision_apbSlave_1_PRDATA    ),
    .vision_PSLVERROR     ( vision_apbSlave_1_PSLVERROR ),
    .mode_selector        ( system_gpio_0_io_read[0]    )         
);

/**************************************************
 *
 * DMA Instantiation
 * To pass data to/from cam and display with DDR 
 * 
**************************************************/ 
gDMA_vision u_dma_vision(
    .clk                ( io_memoryClk ),
    .reset              ( io_systemReset ), 
    .ctrl_clk           ( io_peripheralClk ),
    .ctrl_reset         ( io_peripheralReset ),

//APB Slave
    .ctrl_PADDR         ( vision_dma_apbSlave_0_PADDR     ),
    .ctrl_PSEL          ( vision_dma_apbSlave_0_PSEL      ),
    .ctrl_PENABLE       ( vision_dma_apbSlave_0_PENABLE   ),
    .ctrl_PREADY        ( vision_dma_apbSlave_0_PREADY    ),
    .ctrl_PWRITE        ( vision_dma_apbSlave_0_PWRITE    ),
    .ctrl_PWDATA        ( vision_dma_apbSlave_0_PWDATA    ),
    .ctrl_PRDATA        ( vision_dma_apbSlave_0_PRDATA    ),
    .ctrl_PSLVERROR     ( vision_dma_apbSlave_0_PSLVERROR ),
    .ctrl_interrupts    ( vision_dma_interrupts           ),
    
    //DMA AXI memory Interface 
    .read_arvalid       ( ddr_inst1_ARVALID_0 ),
    .read_araddr        ( ddr_inst1_ARADDR_0[31:0] ),
    .read_arready       ( ddr_inst1_ARREADY_0 ),
    .read_arregion      (  ),
    .read_arlen         ( ddr_inst1_ARLEN_0 ),
    .read_arsize        ( ddr_inst1_ARSIZE_0 ),
    .read_arburst       ( ddr_inst1_ARBURST_0 ),
    .read_arlock        ( ddr_inst1_ARLOCK_0 ),
    .read_arcache       (  ),
    .read_arqos         ( ddr_inst1_ARQOS_0 ),
    .read_arprot        (  ),
    
    .read_rready        (ddr_inst1_RREADY_0 ),
    .read_rvalid        (ddr_inst1_RVALID_0 ),
    .read_rdata         (ddr_inst1_RDATA_0 ),
    .read_rlast         (ddr_inst1_RLAST_0 ),
    .read_rresp         (ddr_inst1_RRESP_0 ),
     
    .write_awvalid      ( ddr_inst1_AWVALID_0 ),
    .write_awready      ( ddr_inst1_AWREADY_0 ),
    .write_awaddr       ( ddr_inst1_AWADDR_0[31:0] ),
    .write_awregion     (  ),
    .write_awlen        ( ddr_inst1_AWLEN_0 ),
    .write_awsize       ( ddr_inst1_AWSIZE_0 ),
    .write_awburst      ( ddr_inst1_AWBURST_0 ),
    .write_awlock       ( ddr_inst1_AWLOCK_0 ),
    .write_awcache      ( ddr_inst1_AWCACHE_0 ),
    .write_awqos        ( ddr_inst1_AWQOS_0 ),
    .write_awprot       (  ),
    
    .write_wvalid       ( ddr_inst1_WVALID_0 ),
    .write_wready       ( ddr_inst1_WREADY_0 ),
    .write_wdata        ( ddr_inst1_WDATA_0 ),
    .write_wstrb        ( ddr_inst1_WSTRB_0 ),
    .write_wlast        ( ddr_inst1_WLAST_0 ),
    
    .write_bvalid       ( ddr_inst1_BVALID_0 ),
    .write_bready       ( ddr_inst1_BREADY_0 ),
    .write_bresp        ( ddr_inst1_BRESP_0 ),

    //64bits Camera Video Stream In
    .dat0_i_clk         ( i_pixel_clk ),
    .dat0_i_reset       ( ~i_arstn ),
    .dat0_i_tvalid      ( cam_dma_wvalid ),
    .dat0_i_tready      ( cam_dma_wready ),
    .dat0_i_tdata       ( cam_dma_wdata ),
    .dat0_i_tkeep       ( {8{cam_dma_wvalid}} ),
    .dat0_i_tdest       ( 4'd0 ),
    .dat0_i_tlast       ( cam_dma_wlast ),
    
     //64-bit dma channel (MM2S - from external memory)
    .dat1_o_clk         ( i_hdmi_clk_148p5MHz ),
    .dat1_o_reset       ( ~i_arstn ),
    .dat1_o_tvalid      ( display_dma_rvalid ),
    .dat1_o_tready      ( display_dma_rready ),
    .dat1_o_tdata       ( display_dma_rdata ),
    .dat1_o_tkeep       ( display_dma_rkeep ),
    .dat1_o_tdest       (  ),
    .dat1_o_tlast       (  ),

   //32-bit dma channel (S2MM - to DDR)
   .dat2_i_clk          ( io_peripheralClk ),
   .dat2_i_reset        ( io_peripheralReset ),
   .dat2_i_tvalid       ( hw_accel_dma_wvalid ),
   .dat2_i_tready       ( hw_accel_dma_wready ),
   .dat2_i_tdata        ( hw_accel_dma_wdata ),
   .dat2_i_tkeep        ( {4{hw_accel_dma_wvalid}} ),
   .dat2_i_tdest        ( 4'd0 ),
   .dat2_i_tlast        ( hw_accel_dma_wlast ),
   
   //32-bit dma channel (MM2S - from DDR)
   .dat3_o_clk          ( io_peripheralClk ),
   .dat3_o_reset        ( io_peripheralReset ),
   .dat3_o_tvalid       ( hw_accel_dma_rvalid ),
   .dat3_o_tready       ( hw_accel_dma_rready ),
   .dat3_o_tdata        ( hw_accel_dma_rdata ),
   .dat3_o_tkeep        ( hw_accel_dma_rkeep ),
   .dat3_o_tdest        ( ),
   .dat3_o_tlast        ( )
   
);

`endif // ENABLE_EVSOC



/*********************************************Miscellaneous Module  ****************************************************/

custom_instruction_tea cpu0_custom_instruction_tea_inst(
    .clk                ( io_cfuClk ),
    .reset              ( io_cfuReset ),
    .cmd_valid          ( cpu0_customInstruction_cmd_valid ),
    .cmd_ready          ( cpu0_customInstruction_cmd_ready ),
    .cmd_function_id    ( cpu0_customInstruction_function_id ),
    .cmd_inputs_0       ( cpu0_customInstruction_inputs_0 ),
    .cmd_inputs_1       ( cpu0_customInstruction_inputs_1 ),
    .rsp_valid          ( cpu0_customInstruction_rsp_valid ),
    .rsp_ready          ( cpu0_customInstruction_rsp_ready ),
    .rsp_outputs_0      ( cpu0_customInstruction_outputs_0 )
);

custom_instruction_tea cpu1_custom_instruction_tea_inst(
    .clk                ( io_cfuClk ),
    .reset              ( io_cfuReset ),
    .cmd_valid          ( cpu1_customInstruction_cmd_valid ),
    .cmd_ready          ( cpu1_customInstruction_cmd_ready ),
    .cmd_function_id    ( cpu1_customInstruction_function_id ),
    .cmd_inputs_0       ( cpu1_customInstruction_inputs_0 ),
    .cmd_inputs_1       ( cpu1_customInstruction_inputs_1 ),
    .rsp_valid          ( cpu1_customInstruction_rsp_valid ),
    .rsp_ready          ( cpu1_customInstruction_rsp_ready ),
    .rsp_outputs_0      ( cpu1_customInstruction_outputs_0 )
);

custom_instruction_tea cpu2_custom_instruction_tea_inst(
    .clk                ( io_cfuClk ),
    .reset              ( io_cfuReset ),
    .cmd_valid          ( cpu2_customInstruction_cmd_valid ),
    .cmd_ready          ( cpu2_customInstruction_cmd_ready ),
    .cmd_function_id    ( cpu2_customInstruction_function_id ),
    .cmd_inputs_0       ( cpu2_customInstruction_inputs_0 ),
    .cmd_inputs_1       ( cpu2_customInstruction_inputs_1 ),
    .rsp_valid          ( cpu2_customInstruction_rsp_valid ),
    .rsp_ready          ( cpu2_customInstruction_rsp_ready ),
    .rsp_outputs_0      ( cpu2_customInstruction_outputs_0 ) 
);

custom_instruction_tea cpu3_custom_instruction_tea_inst(
    .clk                ( io_cfuClk ),
    .reset              ( io_cfuReset ),
    .cmd_valid          ( cpu3_customInstruction_cmd_valid ),
    .cmd_ready          ( cpu3_customInstruction_cmd_ready ),
    .cmd_function_id    ( cpu3_customInstruction_function_id ),
    .cmd_inputs_0       ( cpu3_customInstruction_inputs_0 ),
    .cmd_inputs_1       ( cpu3_customInstruction_inputs_1 ),
    .rsp_valid          ( cpu3_customInstruction_rsp_valid ),
    .rsp_ready          ( cpu3_customInstruction_rsp_ready ),
    .rsp_outputs_0      ( cpu3_customInstruction_outputs_0 )
);

/*********************************************Soft Logic Block ****************************************************/

//axi4 bridge to various I/O
EfxSapphireHpSoc_slb u_top_peripherals(
    .io_apbSlave_0_PADDR                    ( vision_dma_apbSlave_0_PADDR ),
    .io_apbSlave_0_PSEL                     ( vision_dma_apbSlave_0_PSEL ),
    .io_apbSlave_0_PENABLE                  ( vision_dma_apbSlave_0_PENABLE ),
    .io_apbSlave_0_PREADY                   ( vision_dma_apbSlave_0_PREADY ),
    .io_apbSlave_0_PWRITE                   ( vision_dma_apbSlave_0_PWRITE ),
    .io_apbSlave_0_PWDATA                   ( vision_dma_apbSlave_0_PWDATA ),
    .io_apbSlave_0_PRDATA                   ( vision_dma_apbSlave_0_PRDATA ),
    .io_apbSlave_0_PSLVERROR                ( vision_dma_apbSlave_0_PSLVERROR ),
    
    // APB3 ( EV SOC )
    .io_apbSlave_1_PADDR                    ( vision_apbSlave_1_PADDR ),
    .io_apbSlave_1_PSEL                     ( vision_apbSlave_1_PSEL ),
    .io_apbSlave_1_PENABLE                  ( vision_apbSlave_1_PENABLE ),
    .io_apbSlave_1_PREADY                   ( vision_apbSlave_1_PREADY ),
    .io_apbSlave_1_PWRITE                   ( vision_apbSlave_1_PWRITE ),
    .io_apbSlave_1_PWDATA                   ( vision_apbSlave_1_PWDATA ),
    .io_apbSlave_1_PRDATA                   ( vision_apbSlave_1_PRDATA ),
    .io_apbSlave_1_PSLVERROR                ( vision_apbSlave_1_PSLVERROR ),

    .io_apbSlave_2_PADDR                    ( tse_dma_apbSlave_2_PADDR    ),
    .io_apbSlave_2_PSEL                     ( tse_dma_apbSlave_2_PSEL     ),
    .io_apbSlave_2_PENABLE                  ( tse_dma_apbSlave_2_PENABLE  ),
    .io_apbSlave_2_PREADY                   ( tse_dma_apbSlave_2_PREADY   ),
    .io_apbSlave_2_PWRITE                   ( tse_dma_apbSlave_2_PWRITE   ),
    .io_apbSlave_2_PWDATA                   ( tse_dma_apbSlave_2_PWDATA   ),
    .io_apbSlave_2_PRDATA                   ( tse_dma_apbSlave_2_PRDATA   ),
    .io_apbSlave_2_PSLVERROR                ( tse_dma_apbSlave_2_PSLVERROR),

    .system_spi_0_io_sclk_write             ( system_spi_0_io_sclk_write ),
    .system_spi_0_io_data_0_writeEnable     ( system_spi_0_io_data_0_writeEnable ),
    .system_spi_0_io_data_0_read            ( system_spi_0_io_data_0_read ),
    .system_spi_0_io_data_0_write           ( system_spi_0_io_data_0_write ),
    .system_spi_0_io_data_1_writeEnable     ( system_spi_0_io_data_1_writeEnable ),
    .system_spi_0_io_data_1_read            ( system_spi_0_io_data_1_read ),
    .system_spi_0_io_data_1_write           ( system_spi_0_io_data_1_write ),
    .system_spi_0_io_data_2_writeEnable     ( system_spi_0_io_data_2_writeEnable ),
    .system_spi_0_io_data_2_read            ( system_spi_0_io_data_2_read ),
    .system_spi_0_io_data_2_write           ( system_spi_0_io_data_2_write ),
    .system_spi_0_io_data_3_writeEnable     ( system_spi_0_io_data_3_writeEnable ),
    .system_spi_0_io_data_3_read            ( system_spi_0_io_data_3_read ),
    .system_spi_0_io_data_3_write           ( system_spi_0_io_data_3_write ),
    .system_spi_0_io_ss                     ( system_spi_0_io_ss ),
    .system_uart_0_io_txd                   ( system_uart_0_io_txd ),
    .system_uart_0_io_rxd                   ( system_uart_0_io_rxd ),

    .system_i2c_0_io_sda_writeEnable        ( o_cam_sda_oe ),
    .system_i2c_0_io_sda_write              ( o_cam_sda ),
    .system_i2c_0_io_sda_read               ( i_cam_sda ),
    .system_i2c_0_io_scl_writeEnable        ( o_cam_scl_oe ),
    .system_i2c_0_io_scl_write              ( o_cam_scl ),
    .system_i2c_0_io_scl_read               ( i_cam_scl ),
    
    .system_i2c_1_io_sda_writeEnable        ( system_i2c_1_io_sda_writeEnable ),
    .system_i2c_1_io_sda_write              ( system_i2c_1_io_sda_write ),
    .system_i2c_1_io_sda_read               ( system_i2c_1_io_sda_read ),
    .system_i2c_1_io_scl_writeEnable        ( system_i2c_1_io_scl_writeEnable ),
    .system_i2c_1_io_scl_write              ( system_i2c_1_io_scl_write ),
    .system_i2c_1_io_scl_read               ( system_i2c_1_io_scl_read ),
    
`ifdef SOFTTAP
    .io_jtag_tdi                            ( io_jtag_tdi ),
    .io_jtag_tms                            ( io_jtag_tms ),
    .io_jtag_tdo                            ( io_jtag_tdo ),
    .pin_io_jtag_tdi                        ( pin_io_jtag_tdi ),
    .pin_io_jtag_tms                        ( pin_io_jtag_tms ),
    .pin_io_jtag_tdo                        ( pin_io_jtag_tdo ),
`else 
    .jtagCtrl_tdi                           ( jtagCtrl_tdi ),
    .jtagCtrl_tdo                           ( jtagCtrl_tdo ),
    .jtagCtrl_enable                        ( jtagCtrl_enable ),
    .jtagCtrl_capture                       ( jtagCtrl_capture ),
    .jtagCtrl_shift                         ( jtagCtrl_shift ),
    .jtagCtrl_update                        ( jtagCtrl_update ),
    .jtagCtrl_reset                         ( jtagCtrl_reset ),
    .ut_jtagCtrl_tdi                        ( ut_jtagCtrl_tdi ),
    .ut_jtagCtrl_tdo                        ( ut_jtagCtrl_tdo ),
    .ut_jtagCtrl_enable                     ( ut_jtagCtrl_enable ),
    .ut_jtagCtrl_capture                    ( ut_jtagCtrl_capture ),
    .ut_jtagCtrl_shift                      ( ut_jtagCtrl_shift ),
    .ut_jtagCtrl_update                     ( ut_jtagCtrl_update ),
    .ut_jtagCtrl_reset                      ( ut_jtagCtrl_reset ),
`endif 
    .system_gpio_0_io_read                  ( system_gpio_0_io_read ),
    .system_gpio_0_io_write                 ( system_gpio_0_io_write ),
    .system_gpio_0_io_writeEnable           ( system_gpio_0_io_writeEnable ),
    .userInterruptA                         ( userInterrupt_uart ),
    .userInterruptB                         ( userInterrupt_spi0 ),
    .userInterruptC                         ( userInterrupt_spi1 ),
    .userInterruptD                         ( userInterrupt_i2c0 ),
    .userInterruptE                         ( userInterrupt_i2c1 ),
    .userInterruptF                         ( userInterrupt_gpio0 ),
    .userInterruptG                         ( userInterrupt_gpio1 ),
    .axiA_awvalid                           ( gAXIS_m_awvalid[SLB*1 +: 1] ),
    .axiA_awready                           ( gAXIS_m_awready[SLB*1 +: 1] ),
    .axiA_awaddr                            ( gAXIS_m_awaddr[SLB*32 +: 32] ),
    .axiA_awlen                             ( gAXIS_m_awlen[SLB*8 +: 8] ),
    .axiA_awburst                           ( gAXIS_m_awburst[SLB*2 +: 2] ),
    .axiA_awsize                            ( gAXIS_m_awsize[SLB*3 +: 3] ),
    .axiA_awcache                           ( gAXIS_m_awcache[SLB*4 +: 4] ),
    .axiA_awprot                            ( gAXIS_m_awprot[SLB*3 +: 3] ),
    .axiA_wvalid                            ( gAXIS_m_wvalid[SLB*1 +: 1] ),
    .axiA_wready                            ( gAXIS_m_wready[SLB*1 +: 1] ),
    .axiA_wdata                             ( gAXIS_m_wdata[SLB*32 +: 32] ),
    .axiA_wstrb                             ( gAXIS_m_wstrb[SLB*4 +: 4] ),
    .axiA_wlast                             ( gAXIS_m_wlast[SLB*1 +: 1] ),
    .axiA_bvalid                            ( gAXIS_m_bvalid[SLB*1 +: 1] ),
    .axiA_bready                            ( gAXIS_m_bready[SLB*1 +: 1] ),
    .axiA_bresp                             ( gAXIS_m_bresp[SLB*2 +: 2] ),
    .axiA_arvalid                           ( gAXIS_m_arvalid[SLB*1 +: 1] ),
    .axiA_arready                           ( gAXIS_m_arready[SLB*1 +: 1] ),
    .axiA_araddr                            ( gAXIS_m_araddr[SLB*32 +: 32] ),
    .axiA_arlen                             ( gAXIS_m_arlen[SLB*8 +: 8] ),
    .axiA_arburst                           ( gAXIS_m_arburst[SLB*2 +: 2]),
    .axiA_arsize                            ( gAXIS_m_arsize[SLB*3 +: 3] ),
    .axiA_arcache                           ( gAXIS_m_arcache[SLB*4 +: 4] ),
    .axiA_arprot                            ( gAXIS_m_arprot[SLB*3 +: 3] ),
    .axiA_rvalid                            ( gAXIS_m_rvalid[SLB*1 +: 1] ),
    .axiA_rready                            ( gAXIS_m_rready[SLB*1 +: 1] ),
    .axiA_rdata                             ( gAXIS_m_rdata[SLB*32 +: 32] ),
    .axiA_rresp                             ( gAXIS_m_rresp[SLB*2 +: 2] ),
    .axiA_rlast                             ( gAXIS_m_rlast[SLB*1 +: 1] ),
    .axiAInterrupt                          ( axiAInterrupt_slb ),
    .cfg_done                               ( cfg_done ),
    .cfg_start                              ( cfg_start ),
    .cfg_sel                                ( cfg_sel ),
    .cfg_reset                              ( cfg_reset ),
    .io_peripheralClk                       ( io_peripheralClk ),
    .io_peripheralReset                     ( io_peripheralReset ),
    .io_asyncReset                          ( io_asyncReset ),
    .io_gpio_sw_n                           ( io_gpio_sw_n ), 
    .pll_peripheral_locked                  ( pll_peripheral_locked ),
    .pll_system_locked                      ( pll_system_locked )
);

endmodule
