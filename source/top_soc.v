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

`timescale 1ns / 1ps
// To enable RiscV soft tap connection (for debugger).
//`define SOFTTAP 

// Uncomment the following line to disable IP 
`define TITANIUM_DEVICE   
`define ENABLE_SDHC              // Comment out this line to disable SDHC , Modify gAXIS_1to3_switch IP manually !!           
`define ENABLE_EVSOC             // Comment out this line to disable EVSOC , Modify gAXIS_1to3_switch IP manually !!
`define ENABLE_ETHERNET          // Comment out this line to disable EVSOC , Modify gAXIS_1to3_switch IP manually !!
`define ENABLE_AXI_INTERCONNECT  // Comment out this line to disable AXI-INTERCONNECT (Hardware Accelerator <=> SDHC <=> TSEMAC)
`define DISPLAY_1280x720_60Hz    // Default Set to 720p
  
`ifdef ENABLE_EVSOC
    `define ENABLE_EVSOC_CAMERA     // Comment out this line to disable the PiCAM camera portion of EVSOC
    `define ENABLE_EVSOC_DISPLAY    // Comment out this line to disable the HDMI display portion of EVSOC
    `define ENABLE_EVSOC_HW_ACCEL   // Comment out this line to disable the hardware accelerator for EVSOC
`endif 



module top_soc (

//Clock
    input       io_systemClk,                           // Clock for Soc
    input		io_peripheralClk,                       // Clock for Peripheral
    input		io_memoryClk,                           // Clock for DMA
    input       mipi_pclk,                              // Clock For Mipi PiCam V2
    input       hdmi_clk,                               // Clock for I2C Init HDMI module with 480p
    input       io_tseClk,                              // Clock for TSEMAC -> 125MHz
    input       hdmi_yuv_clk,                           // Clock for init HDMI-YUV(25.25MHz)
    output      mipi_dphy_rx_inst1_RESET_N,             // Active Low Reset for MIPI Control 
    output      mipi_dphy_rx_inst1_RST0_N,              // Active Low Reset for MIPI Control 

//PLL
    input       i_master_rstn,                          // Active Low Reset for SoC
    output      systemClk_rstn,                         // Active Low Reset for SoC PLL
    input       systemClk_locked,                       // SOC PLL Locked
  	output	    my_ddr_pll_rstn,                        // Active Low Reset for DDR PLL
  	input		my_ddr_pll_locked,                      // DDR PLL Locked
    output      mipi_pll_rstn,                          // Active Low Reset for MIPI PLL
    input       mipi_pll_locked,                        // MIPI PLL Locked
    output      tse_pll_rstn,                           // Active Low Reset for TSE PLL

// Titanium DDR Config Controller
    output		cfg_start,                              // Start the DDR configuration controller.
    output		cfg_reset,                              // Active-high DDR configuration controller reset.
    output		cfg_sel,                                // To select whether to use internal DDR configuration controller or user register ports for configuration:
                                                        // 0: Use internal configuration controller.
                                                        // 1: Use register configuration ports (cfg_rst, cfg_start, cfg_done will be disabled).
    input		cfg_done,                               // Indicates the controller configuration is done
    output		cfg_ok,
    output		DDR_AXI0_resetn,                        // Active low Reset signal for DDR AXI 0
    output		DDR_AXI1_resetn,                        // Active low Reset signal for DDR AXI 1

// Titanium DDR-AXI_0 is directly connected to Sapphire Soc
    output			    io_ddrA_ar_valid,               // Address valid. This signal indicates that the channel is signaling valid address and control information.
    input			    io_ddrA_ar_ready,               // Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    output [32:0]       io_ddrA_ar_payload_addr,        // Read address. It gives the address of the first transfer in a burst transaction.
    output [5:0]        io_ddrA_ar_payload_id,          // Address ID. This signal identifies the group of address signals.
    output [7:0]        io_ddrA_ar_payload_len,         // Burst length. This signal indicates the number of transfers in a burst.
    output [2:0]        io_ddrA_ar_payload_size,        // Burst size. This signal indicates the size of each transfer in the burst.
    output [1:0]        io_ddrA_ar_payload_burst,       // Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
    output		    	io_ddrA_ar_payload_lock,        // Lock type. This signal provides additional information about the atomic characteristics of the transfer.
    output		    	io_ddrA_ar_apcmd,               // Read auto-precharge.
    output		    	io_ddrA_ar_payload_qos,         // QoS indentifier for read transaction.
    output			    io_ddrA_aw_valid,               // Address valid. This signal indicates that the channel is signaling valid address and control information.
    input			    io_ddrA_aw_ready,               // Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    output [32:0]       io_ddrA_aw_payload_addr,        // Write address. It gives the address of the first transfer in a burst transaction.
    output [5:0]        io_ddrA_aw_payload_id,          // Address ID. This signal identifies the group of address signals.
    output [7:0]        io_ddrA_aw_payload_len,         // Burst length. This signal indicates the number of transfers in a burst.
    output [2:0]        io_ddrA_aw_payload_size,        // Burst size. This signal indicates the size of each transfer in the burst.
    output [1:0]        io_ddrA_aw_payload_burst,       // Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
    output			    io_ddrA_aw_payload_lock,        // Lock type. This signal provides additional information about the atomic characteristics of the transfer.
    output [3:0]        io_ddrA_aw_payload_cache,       // Memory type. This signal indicates how transactions are required to progress through a system.
    output		    	io_ddrA_aw_payload_qos,         // QoS indentifier for write transaction.
    output		    	io_ddrA_aw_payload_allstrb,     // Write all strobes asserted.
    output		    	io_ddrA_aw_apcmd,               // Write auto-precharge.
    output		    	io_ddrA_awcobuf,                // Write coherent bufferable selection.  
    output [512-1:0]    io_ddrA_w_payload_data,         // Write data. AXI4 port 0 is 256, port 1 is 128.
    output [64-1:0]     io_ddrA_w_payload_strb,         // Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    input [1:0]         io_ddrA_b_payload_resp,         // Read response. This signal indicates the status of the read transfer.
    input [5:0]         io_ddrA_b_payload_id,           // Response ID tag. This signal is the ID tag of the write response.
    input [512-1:0]     io_ddrA_r_payload_data,         // Read data.
    input [5:0]         io_ddrA_r_payload_id,           // Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
    input [1:0]         io_ddrA_r_payload_resp,         // Read response. This signal indicates the status of the read transfer.

// Titanium DDR-AXI_1 is directly connected to DMA
    output			    io_ddrB_ar_valid,               // Address valid. This signal indicates that the channel is signaling valid address and control information.
    input			    io_ddrB_ar_ready,               // Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    output [32:0]       io_ddrB_ar_payload_addr,        // Read address. It gives the address of the first transfer in a burst transaction.
    output [5:0]        io_ddrB_ar_payload_id,          // Address ID. This signal identifies the group of address signals.
    output [7:0]        io_ddrB_ar_payload_len,         // Burst length. This signal indicates the number of transfers in a burst.
    output [2:0]        io_ddrB_ar_payload_size,        // Burst size. This signal indicates the size of each transfer in the burst.
    output [1:0]        io_ddrB_ar_payload_burst,       // Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
    output		    	io_ddrB_ar_payload_lock,        // Lock type. This signal provides additional information about the atomic characteristics of the transfer.
    output		    	io_ddrB_ar_apcmd,               // Read auto-precharge.
    output		    	io_ddrB_ar_payload_qos,         // QoS indentifier for read transaction.
    output			    io_ddrB_aw_valid,               // Address valid. This signal indicates that the channel is signaling valid address and control information.
    input			    io_ddrB_aw_ready,               // Address ready. This signal indicates that the slave is ready to accept an address and associated control signals.
    output [32:0]       io_ddrB_aw_payload_addr,        // Write address. It gives the address of the first transfer in a burst transaction.
    output [5:0]        io_ddrB_aw_payload_id,          // Address ID. This signal identifies the group of address signals.
    output [7:0]        io_ddrB_aw_payload_len,         // Burst length. This signal indicates the number of transfers in a burst.
    output [2:0]        io_ddrB_aw_payload_size,        // Burst size. This signal indicates the size of each transfer in the burst.
    output [1:0]        io_ddrB_aw_payload_burst,       // Burst type. The burst type and the size determine how the address for each transfer within the burst is calculated.
    output			    io_ddrB_aw_payload_lock,        // Lock type. This signal provides additional information about the atomic characteristics of the transfer.
    output [3:0]        io_ddrB_aw_payload_cache,       // Memory type. This signal indicates how transactions are required to progress through a system.
    output		    	io_ddrB_aw_payload_qos,         // QoS indentifier for write transaction.
    output		    	io_ddrB_aw_payload_allstrb,     // Write all strobes asserted.
    output		    	io_ddrB_aw_apcmd,               // Write auto-precharge.
    output		    	io_ddrB_awcobuf,                // Write coherent bufferable selection.  
    output [512-1:0]    io_ddrB_w_payload_data,         // Write data. AXI4 port 0 is 256, port 1 is 128.
    output [64-1:0]     io_ddrB_w_payload_strb,         // Write strobes. This signal indicates which byte lanes hold valid data. There is one write strobe bit for each eight bits of the write data bus.
    input [1:0]         io_ddrB_b_payload_resp,         // Read response. This signal indicates the status of the read transfer.
    input [5:0]         io_ddrB_b_payload_id,           // Response ID tag. This signal is the ID tag of the write response.
    input [512-1:0]     io_ddrB_r_payload_data,         // Read data.
    input [5:0]         io_ddrB_r_payload_id,           // Read ID tag. This signal is the identification tag for the read data group of signals generated by the slave.
    input [1:0]         io_ddrB_r_payload_resp,         // Read response. This signal indicates the status of the read transfer.
    
    //Common Signal for DDR -> Sapphire Soc
    input			    io_ddrA_b_valid,                // Write response valid. This signal indicates that the channel is signaling a valid write response.
    output			    io_ddrA_b_ready,                // Response ready. This signal indicates that the master can accept a write response.   
    output			    io_ddrA_w_valid,                // Write valid. This signal indicates that valid write data and strobes are available.
    input			    io_ddrA_w_ready,                // Write ready. This signal indicates that the slave can accept the write data.
    output			    io_ddrA_w_payload_last,         // Write last. This signal indicates the last transfer in a write burst.
    input			    io_ddrA_r_valid,                // Read valid. This signal indicates that the channel is signaling the required read data.
    output			    io_ddrA_r_ready,                // Read ready. This signal indicates that the master can accept the read data and response information.    
    input			    io_ddrA_r_payload_last,         // Read lasts. This signal indicates the last transfer in a read burst.
   
    //Common Signal for DDR -> DMA
    input			    io_ddrB_b_valid,                // Write response valid. This signal indicates that the channel is signaling a valid write response.
    output			    io_ddrB_b_ready,                // Response ready. This signal indicates that the master can accept a write response.   
    output			    io_ddrB_w_valid,                // Write valid. This signal indicates that valid write data and strobes are available.
    input			    io_ddrB_w_ready,                // Write ready. This signal indicates that the slave can accept the write data.
    output			    io_ddrB_w_payload_last,         // Write last. This signal indicates the last transfer in a write burst.
    input			    io_ddrB_r_valid,                // Read valid. This signal indicates that the channel is signaling the required read data.
    output			    io_ddrB_r_ready,                // Read ready. This signal indicates that the master can accept the read data and response information.    
    input			    io_ddrB_r_payload_last,         // Read lasts. This signal indicates the last transfer in a read burst.
   
//SPI_0
    output		        system_spi_0_io_sclk_write,
    output		        system_spi_0_io_data_0_writeEnable,
    input		        system_spi_0_io_data_0_read,
    output		        system_spi_0_io_data_0_write,
    output		        system_spi_0_io_data_1_writeEnable,
    input		        system_spi_0_io_data_1_read,
    output		        system_spi_0_io_data_1_write,
    output		        system_spi_0_io_ss,

//GPIO
    input [3:0]         system_gpio_0_io_read,
    output [3:0]        system_gpio_0_io_write,
    output [3:0]        system_gpio_0_io_writeEnable,

//JTAG   
    input		        jtag_inst1_TCK,
    input		        jtag_inst1_TDI,
    output		        jtag_inst1_TDO,
    input		        jtag_inst1_SEL,
    input		        jtag_inst1_CAPTURE,
    input		        jtag_inst1_SHIFT,
    input		        jtag_inst1_UPDATE,
    input		        jtag_inst1_RESET,
    
`ifdef ENABLE_SDHC
//  SDHC
    output              sd_clk_hi,
    output              sd_clk_lo,
    input               sd_cmd_i,
    output              sd_cmd_o,
    output              sd_cmd_oe,
    input  [3:0]        sd_dat_i,
    output [3:0]        sd_dat_o,
    output [3:0]        sd_dat_oe,
`endif

`ifdef ENABLE_EVSOC_CAMERA
// Common Evsoc Camera interface
   input               i_cam_sda,
   output              o_cam_sda_oe,
   input               i_cam_scl,
   output              o_cam_scl_oe,
   output              o_cam_rstn,            //Active Low Reset for Picam

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


`endif // ENABLE_EVSOC_CAMERA

`ifdef ENABLE_EVSOC_DISPLAY
// Common Evsoc I2C Configuration for HDMI
    output                               hdmi_sda_writeEnable,
    input                                hdmi_sda_read,
    output                               hdmi_scl_writeEnable,
    input                                hdmi_scl_read,

    //  HDMI YUV Output
    output                               hdmi_yuv_vs,
    output                               hdmi_yuv_hs,
    output                               hdmi_yuv_de,
    output  [15:0]                       hdmi_yuv_data,

`endif // ENABLE_EVSOC_DISPLAY


`ifdef ENABLE_ETHERNET

// TSE
    input                   mux_clk,
    output          [1:0]   mux_clk_sw,  
    output  wire    [3:0]   rgmii_txd_HI,
    output  wire    [3:0]   rgmii_txd_LO,
    output  wire            rgmii_txc_HI,
    output  wire            rgmii_txc_LO,
    input           [3:0]   rgmii_rxd_HI,
    input           [3:0]   rgmii_rxd_LO,
    output  wire            rgmii_tx_ctl_HI,
    output  wire            rgmii_tx_ctl_LO,
    input                   rgmii_rx_ctl_HI,
    input                   rgmii_rx_ctl_LO,

//TEMAC PHY Ctr Interface
    output  wire            o_phy_rstn,

//TEMAC PHY MDIO Interface
    input                   phy_mdi,
    output  wire            phy_mdo,
    output  wire            phy_mdo_en,
    output  wire            phy_mdc,
    output  wire            phy_active,

`endif


`ifdef SOFTTAP
    input                   softtap_jtag_tms,
    input                   softtap_jtag_tdi,
    output                  softtap_jtag_tdo,
    input                   softtap_jtag_tck,
`endif
// I2C Sensor
    input                   i_sensor_sda,
    output                  o_sensor_sda,
    output                  o_sensor_sda_oe,
    input                   i_sensor_scl,
    output                  o_sensor_scl,
    output                  o_sensor_scl_oe,
//UART_0
    output		            system_uart_0_io_txd,
    input		            system_uart_0_io_rxd
);

/************************************Local Parameters ***************************************/

/////////////////////////////////////////////////////////////////////////////
//Localparams
//////////////////

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


//Vision related paramter
localparam MIPI_FRAME_WIDTH       = 1920;  // Resolution of Camera input 
localparam MIPI_FRAME_HEIGHT      = 1080;  // Resolution of Camera input 
localparam APB3_ADDR_WIDTH        = 16;    // Vision APB3 CSR Address Width 
localparam APB3_DATA_WIDTH        = 32;    // Vision APB3 CSR Data Width
localparam HW_ACCEL_ADDR_WIDTH    = 32;    // Hardware Accelerator Address Width
localparam HW_ACCEL_DATA_WIDTH    = 32;     // Hardware Accelerator Data Width
localparam CSI_RX_DATA_WIDTH_LANE = 16;

//SD
localparam SD_AXI_DW   = 32;            // Data Width
localparam SD_AXI_AW   = 32;            // Address Width
localparam SD_AXI_SW   = SD_AXI_DW/8;   // Write Strobes Width



//AXI Interconnect
localparam HW_ACCEL     = 0; 
localparam SDHC         = 1;
localparam TSE          = 2;
localparam AXIS_DEV     = 3;

// DMA - TSEMAC
localparam AXIS_DW = 64;

/************************************Common Wire  ***************************************/

//////////////////
//Wires & Registers
//////////////////

// Reset and PLL
wire 		reset;
wire		io_systemReset;
wire 	    io_memoryReset;				
wire        io_peripheralReset;
wire        w_system_watchdog_hardPanic;
wire        pll_locked;

// Custom Instruction 
wire            cpu0_customInstruction_cmd_valid;
wire		    cpu0_customInstruction_cmd_ready;
wire [9:0]      cpu0_customInstruction_function_id;
wire [31:0]     cpu0_customInstruction_inputs_0;
wire [31:0]     cpu0_customInstruction_inputs_1;
wire		    cpu0_customInstruction_rsp_valid;
wire		    cpu0_customInstruction_rsp_ready;
wire [31:0]     cpu0_customInstruction_outputs_0;

wire            cpu1_customInstruction_cmd_valid;
wire		    cpu1_customInstruction_cmd_ready;
wire [9:0]      cpu1_customInstruction_function_id;
wire [31:0]     cpu1_customInstruction_inputs_0;
wire [31:0]     cpu1_customInstruction_inputs_1;
wire		    cpu1_customInstruction_rsp_valid;
wire		    cpu1_customInstruction_rsp_ready;
wire [31:0]     cpu1_customInstruction_outputs_0;

// APB Slave 0  (DMA)
wire    [15:0]  vision_dma_apbSlave_0_PADDR;
wire    [0:0]   vision_dma_apbSlave_0_PSEL;
wire            vision_dma_apbSlave_0_PENABLE;
wire            vision_dma_apbSlave_0_PREADY;
wire            vision_dma_apbSlave_0_PWRITE;
wire    [31:0]  vision_dma_apbSlave_0_PWDATA;
wire    [31:0]  vision_dma_apbSlave_0_PRDATA;
wire            vision_dma_apbSlave_0_PSLVERROR;
wire            vision_dma_ctrl_interrupt;

// APB 3 Slave 1 -  Control and Status Register (EVSOC)
wire    [15:0]  vision_apbSlave_1_PADDR;
wire    [0:0]   vision_apbSlave_1_PSEL;
wire            vision_apbSlave_1_PENABLE;
wire            vision_apbSlave_1_PREADY;
wire            vision_apbSlave_1_PWRITE;
wire    [31:0]  vision_apbSlave_1_PWDATA;
wire    [31:0]  vision_apbSlave_1_PRDATA;
wire            vision_apbSlave_1_PSLVERROR;

//APB3 Slave 2 to TSE DMA Wires 
wire   [15:0]   tse_dma_apbSlave_2_PADDR    ;
wire            tse_dma_apbSlave_2_PSEL     ;
wire            tse_dma_apbSlave_2_PENABLE  ;
wire            tse_dma_apbSlave_2_PREADY   ;
wire            tse_dma_apbSlave_2_PWRITE   ;
wire   [31:0]   tse_dma_apbSlave_2_PWDATA   ;
wire   [31:0]   tse_dma_apbSlave_2_PRDATA   ;
wire            tse_dma_apbSlave_2_PSLVERROR;

//Initialize reset signal
assign systemClk_rstn 	= 1'b1;
assign my_ddr_pll_rstn  = 1'b1;
assign tse_pll_rstn     = 1'b1;
assign mipi_pll_rstn    = 1'b1; 
assign lvds_pll_rstn    = 1'b1;
assign hdmi_pll_rstn    = 1'b1;


//Assignment for pll and reset
assign pll_locked = w_master_rstn & systemClk_locked & my_ddr_pll_locked & mipi_pll_locked & cfg_ok;
assign reset      = ~pll_locked | w_system_watchdog_hardPanic;

assign  o_sensor_sda_oe    = !o_sensor_sda;
assign  o_sensor_scl_oe    = !o_sensor_scl;

/*********************************************LPDDR4 Configuration (Titanium)******************************************/

////////////////////////////////////
// DDR Configuration for Titanium 
////////////////////////////////////

//ddr4 config
localparam [1:0]    IDLE        = 2'b00,
                    CFG_START   = 2'b01,
                    CFG_DONE    = 2'b11;

//ddr4 configuration related wires 
reg  [1:0]   cfg_st, cfg_next;
reg  [7:0]   cfg_count;
wire [7:0]   dma_arid;
wire [7:0]   dma_awid;

//Configure for DDR -> SOC                   
assign io_ddrA_ar_apcmd             = 1'b0;
assign io_ddrA_aw_payload_allstrb   = 1'b0;
assign io_ddrA_aw_apcmd             = 1'b0;
assign io_ddrA_awcobuf              = 1'b0;
assign io_ddrA_ar_payload_addr      = { 1'b0, io_ddr_ar_payload_addr_u[31:0] };
assign io_ddrA_aw_payload_addr      = { 1'b0, io_ddr_aw_payload_addr_u[31:0] };
assign io_ddrA_ar_payload_id        = { io_ddr_ar_payload_id_u[7:6], io_ddr_ar_payload_id_u[3:0]    };
assign io_ddrA_aw_payload_id        = { io_ddr_aw_payload_id_u[7:6], io_ddr_aw_payload_id_u[3:0]    };
assign io_ddr_b_payload_id_i        = { io_ddrA_b_payload_id[5:4], 2'b00, io_ddrA_b_payload_id[3:0] };
assign io_ddr_r_payload_id_i        = { io_ddrA_r_payload_id[5:4], 2'b00, io_ddrA_r_payload_id[3:0] };


//Configure for DDR -> DMA
assign dma_arid = 8'hE0;
assign dma_awid = 8'hE1;
assign io_ddrB_aw_apcmd           = 1'b0;
assign io_ddrB_ar_apcmd           = 1'b0;
assign io_ddrB_aw_payload_allstrb = 1'b0;
assign io_ddrB_awcobuf            = 1'b0;
assign io_ddrB_ar_payload_addr    = { 1'b0, io_ddr_ar_payload_addr_u[63:32] };
assign io_ddrB_aw_payload_addr    = { 1'b0, io_ddr_aw_payload_addr_u[63:32] };
assign io_ddrB_ar_payload_id      = { dma_arid[7:6], dma_arid[3:0]          };
assign io_ddrB_aw_payload_id      = { dma_awid[7:6], dma_awid[3:0]          };

//Assignment for pll and reset
assign DDR_AXI0_resetn  = cfg_ok;
assign DDR_AXI1_resetn  = cfg_ok;

// Configure DDR
assign cfg_start    = ( cfg_st != IDLE     );
assign cfg_ok       = ( cfg_st == CFG_DONE );
assign cfg_reset    = ( cfg_st == IDLE     );
assign cfg_sel      = 1'b0;

always@(posedge io_systemClk or negedge w_master_rstn)
begin
    if(!w_master_rstn)
        cfg_st <= IDLE;
    else
        cfg_st <= cfg_next;
end

always@(*)
begin
    cfg_next = cfg_st;
    case(cfg_st)
    IDLE:
    begin
        if(cfg_count == 'hff)
            cfg_next = CFG_START;
        else
            cfg_next = IDLE;
    end
    CFG_START:
    begin
        if(cfg_done)
            cfg_next = CFG_DONE;
        else
            cfg_next = CFG_START;
    end
    CFG_DONE:
        cfg_next = CFG_DONE;
    default:
        cfg_next = IDLE;
    endcase
end


always@(posedge io_systemClk)
begin
    if(cfg_st == IDLE)
        cfg_count <= cfg_count + 1'b1;
    else
        cfg_count <= 'h0;
end

/*******************************************DDR Upsizer AXI0 & AXI1 (Titanium) **************************************/

////////////////////////////////////
//  AXI DDR Upsizer 128-bit to 512-bit 
//  (Only applicable for Ti180 design, Ti180 Hardened DDR Controller supports only 512-bit)
////////////////////////////////////


//These signals are for DDR-UPSIZER (128/256-> 512)
localparam UPSIZER_SOC   = 0; // This param is for 128->512 Upsizer
localparam UPSIZER_DMA   = 1; // This param is for 256->512 Upsizer
localparam UPSIZER       = 2; // Two upsizer is required

wire      [UPSIZER-1:0]             io_ddr_aw_valid_u;
wire      [UPSIZER-1:0]             io_ddr_aw_ready_u;
wire      [(UPSIZER*32)-1:0]        io_ddr_aw_payload_addr_u;
wire      [(UPSIZER*8)-1:0]         io_ddr_aw_payload_id_u;
wire      [(UPSIZER*4)-1:0]         io_ddr_aw_payload_region_u;
wire      [(UPSIZER*8)-1:0]         io_ddr_aw_payload_len_u;
wire      [(UPSIZER*3)-1:0]         io_ddr_aw_payload_size_u;
wire      [(UPSIZER*2)-1:0]         io_ddr_aw_payload_burst_u;
wire      [UPSIZER-1:0]             io_ddr_aw_payload_lock_u;
wire      [(UPSIZER*4)-1:0]         io_ddr_aw_payload_cache_u;
wire      [(UPSIZER*4)-1:0]         io_ddr_aw_payload_qos_u;
wire      [(UPSIZER*3)-1:0]         io_ddr_aw_payload_prot_u;
wire      [UPSIZER-1:0]             io_ddr_w_valid_u;
wire      [UPSIZER-1:0]             io_ddr_w_ready_u;
wire      [(UPSIZER*256)-1:0]       io_ddr_w_payload_data_u;
wire      [(UPSIZER*32)-1:0]        io_ddr_w_payload_strb_u;
wire      [UPSIZER-1:0]             io_ddr_w_payload_last_u;
wire      [UPSIZER-1:0]             io_ddr_b_valid_u;
wire      [UPSIZER-1:0]             io_ddr_b_ready_u;
wire      [(UPSIZER*8)-1:0]         io_ddr_b_payload_id_u;
wire      [(UPSIZER*2)-1:0]         io_ddr_b_payload_resp_u;
wire      [UPSIZER-1:0]             io_ddr_ar_valid_u;
wire      [UPSIZER-1:0]             io_ddr_ar_ready_u;
wire      [(UPSIZER*32)-1:0]        io_ddr_ar_payload_addr_u;
wire      [(UPSIZER*8)-1:0]         io_ddr_ar_payload_id_u;
wire      [(UPSIZER*4)-1:0]         io_ddr_ar_payload_region_u;
wire      [(UPSIZER*8)-1:0]         io_ddr_ar_payload_len_u;
wire      [(UPSIZER*3)-1:0]         io_ddr_ar_payload_size_u;
wire      [(UPSIZER*2)-1:0]         io_ddr_ar_payload_burst_u;
wire      [UPSIZER-1:0]             io_ddr_ar_payload_lock_u;
wire      [(UPSIZER*4)-1:0]         io_ddr_ar_payload_cache_u;
wire      [(UPSIZER*4)-1:0]         io_ddr_ar_payload_qos_u;
wire      [(UPSIZER*3)-1:0]         io_ddr_ar_payload_prot_u;
wire      [UPSIZER-1:0]             io_ddr_r_valid_u;
wire      [UPSIZER-1:0]             io_ddr_r_ready_u;
wire      [(UPSIZER*256)-1:0]       io_ddr_r_payload_data_u;
wire      [(UPSIZER*8)-1:0]         io_ddr_r_payload_id_u;
wire      [(UPSIZER*2)-1:0]         io_ddr_r_payload_resp_u;
wire      [UPSIZER-1:0]             io_ddr_r_payload_last_u;

//DDR4 signal size switch wires
wire      [(UPSIZER*32)-1:0]        io_ddr_ar_payload_addr_i;
wire      [(UPSIZER*32)-1:0]        io_ddr_aw_payload_addr_i;
wire      [7:0]                     io_ddr_ar_payload_id_i;
wire      [7:0]                     io_ddr_aw_payload_id_i;
wire      [7:0]                     io_ddr_b_payload_id_i;
wire      [7:0]                     io_ddr_r_payload_id_i;

Asic128To512UpsizerAxi4Upsizer upsizer_SOC( //Upsizer SOC -> DDR

    //128 DW bit SoC
    .io_input_aw_valid              ( io_ddr_aw_valid_u         [UPSIZER_SOC*1+:1]     ),     
    .io_input_aw_ready              ( io_ddr_aw_ready_u         [UPSIZER_SOC*1+:1]     ),     
    .io_input_aw_payload_len        ( io_ddr_aw_payload_len_u   [UPSIZER_SOC*8+:8]     ),     
    .io_input_aw_payload_size       ( io_ddr_aw_payload_size_u  [UPSIZER_SOC*3+:3]     ),    
    .io_input_aw_payload_burst      ( io_ddr_aw_payload_burst_u [UPSIZER_SOC*2+:2]     ),   
    .io_input_aw_payload_lock       ( io_ddr_aw_payload_lock_u  [UPSIZER_SOC*1+:1]     ),    
    .io_input_aw_payload_qos        ( io_ddr_aw_payload_qos_u   [UPSIZER_SOC*4+:4]     ),     
    .io_input_aw_payload_cache      ( io_ddr_aw_payload_cache_u [UPSIZER_SOC*4+:4]     ), 
    .io_input_ar_valid              ( io_ddr_ar_valid_u         [UPSIZER_SOC*1+:1]     ),     
    .io_input_ar_ready              ( io_ddr_ar_ready_u         [UPSIZER_SOC*1+:1]     ),     
    .io_input_ar_payload_len        ( io_ddr_ar_payload_len_u   [UPSIZER_SOC*8+:8]     ),     
    .io_input_ar_payload_size       ( io_ddr_ar_payload_size_u  [UPSIZER_SOC*3+:3]     ),   
    .io_input_ar_payload_burst      ( io_ddr_ar_payload_burst_u [UPSIZER_SOC*2+:2]     ),   
    .io_input_ar_payload_lock       ( io_ddr_ar_payload_lock_u  [UPSIZER_SOC*1+:1]     ),   
    .io_input_ar_payload_qos        ( io_ddr_ar_payload_qos_u   [UPSIZER_SOC*4+:4]     ),     
    .io_input_w_valid               ( io_ddr_w_valid_u          [UPSIZER_SOC*1+:1]     ),
    .io_input_w_ready               ( io_ddr_w_ready_u          [UPSIZER_SOC*1+:1]     ),
    .io_input_w_payload_data        ( io_ddr_w_payload_data_u   [UPSIZER_SOC*256+:256] ),
    .io_input_w_payload_strb        ( io_ddr_w_payload_strb_u   [UPSIZER_SOC*32+:32]   ),
    .io_input_w_payload_last        ( io_ddr_w_payload_last_u   [UPSIZER_SOC*1+:1]     ),
    .io_input_b_valid               ( io_ddr_b_valid_u          [UPSIZER_SOC*1+:1]     ),
    .io_input_b_ready               ( io_ddr_b_ready_u          [UPSIZER_SOC*1+:1]     ),
    .io_input_b_payload_resp        ( io_ddr_b_payload_resp_u   [UPSIZER_SOC*2+:2]     ),
    .io_input_r_valid               ( io_ddr_r_valid_u          [UPSIZER_SOC*1+:1]     ),
    .io_input_r_ready               ( io_ddr_r_ready_u          [UPSIZER_SOC*1+:1]     ),
    .io_input_r_payload_data        ( io_ddr_r_payload_data_u   [UPSIZER_SOC*256+:256] ),
    .io_input_r_payload_resp        ( io_ddr_r_payload_resp_u   [UPSIZER_SOC*2+:2]     ),
    .io_input_r_payload_last        ( io_ddr_r_payload_last_u   [UPSIZER_SOC*1+:1]     ),
    .io_input_ar_payload_addr       ( io_ddr_ar_payload_addr_i  [UPSIZER_SOC*32+:32]   ),
    .io_input_aw_payload_addr       ( io_ddr_aw_payload_addr_i  [UPSIZER_SOC*32+:32]   ),
    .io_input_ar_payload_id         ( io_ddr_ar_payload_id_i                           ), //output to soc
    .io_input_aw_payload_id         ( io_ddr_aw_payload_id_i                           ), //output to soc
    .io_input_b_payload_id          ( io_ddr_b_payload_id_u     [UPSIZER_SOC*8+:8]     ), //output to Soc as well
    .io_input_r_payload_id          ( io_ddr_r_payload_id_u     [UPSIZER_SOC*8+:8]     ), //output to Soc as well
    .io_input_aw_payload_prot       (   ),
    .io_input_aw_payload_region     (   ), 
    .io_input_ar_payload_prot       (   ),
    .io_input_ar_payload_cache      (   ),
    .io_input_ar_payload_region     (   ),  
    //512 DW bit DDR
    .io_output_aw_payload_prot      (   ),
    .io_output_aw_payload_region    (   ),
    .io_output_ar_payload_prot      (   ),
    .io_output_ar_payload_cache     (   ),
    .io_output_ar_payload_region    (   ),
    .io_output_ar_payload_addr      ( io_ddr_ar_payload_addr_u  [UPSIZER_SOC*32+:32]  ),
    .io_output_aw_payload_addr      ( io_ddr_aw_payload_addr_u  [UPSIZER_SOC*32+:32]  ),
    .io_output_ar_payload_id        ( io_ddr_ar_payload_id_u    [UPSIZER_SOC*8+:8]     ),
    .io_output_aw_payload_id        ( io_ddr_aw_payload_id_u    [UPSIZER_SOC*8+:8]     ),
    .io_output_aw_valid             ( io_ddrA_aw_valid         ),
    .io_output_aw_ready             ( io_ddrA_aw_ready         ),
    .io_output_aw_payload_len       ( io_ddrA_aw_payload_len   ),
    .io_output_aw_payload_size      ( io_ddrA_aw_payload_size  ),
    .io_output_aw_payload_burst     ( io_ddrA_aw_payload_burst ),
    .io_output_aw_payload_lock      ( io_ddrA_aw_payload_lock  ),
    .io_output_aw_payload_qos       ( io_ddrA_aw_payload_qos   ),
    .io_output_aw_payload_cache     ( io_ddrA_aw_payload_cache ),
    .io_output_ar_valid             ( io_ddrA_ar_valid         ),
    .io_output_ar_ready             ( io_ddrA_ar_ready         ),
    .io_output_ar_payload_len       ( io_ddrA_ar_payload_len   ),
    .io_output_ar_payload_size      ( io_ddrA_ar_payload_size  ),
    .io_output_ar_payload_burst     ( io_ddrA_ar_payload_burst ),
    .io_output_ar_payload_lock      ( io_ddrA_ar_payload_lock  ),
    .io_output_ar_payload_qos       ( io_ddrA_ar_payload_qos   ),
    .io_output_w_valid              ( io_ddrA_w_valid          ),   
    .io_output_w_ready              ( io_ddrA_w_ready          ),
    .io_output_w_payload_data       ( io_ddrA_w_payload_data   ),
    .io_output_w_payload_strb       ( io_ddrA_w_payload_strb   ),
    .io_output_w_payload_last       ( io_ddrA_w_payload_last   ),
    .io_output_b_valid              ( io_ddrA_b_valid          ),
    .io_output_b_ready              ( io_ddrA_b_ready          ),
    .io_output_b_payload_resp       ( io_ddrA_b_payload_resp   ),
    .io_output_r_valid              ( io_ddrA_r_valid          ),
    .io_output_r_ready              ( io_ddrA_r_ready          ),
    .io_output_r_payload_data       ( io_ddrA_r_payload_data   ),
    .io_output_r_payload_resp       ( io_ddrA_r_payload_resp   ),
    .io_output_r_payload_last       ( io_ddrA_r_payload_last   ),
    .io_output_b_payload_id         ( io_ddr_b_payload_id_i    ),
    .io_output_r_payload_id         ( io_ddr_r_payload_id_i    ),
    .clk                            ( io_memoryClk             ),
    .reset                          ( io_memoryReset           )
);

//Upsizer DMA -> DDR
Asic256To512UpsizerAxi4Upsizer upsizer_DMA(
    // 256 DW bit DMA
    .io_input_aw_valid              ( io_ddr_aw_valid_u         [UPSIZER_DMA*1+:1]     ),     
    .io_input_aw_ready              ( io_ddr_aw_ready_u         [UPSIZER_DMA*1+:1]     ),     
    .io_input_aw_payload_len        ( io_ddr_aw_payload_len_u   [UPSIZER_DMA*8+:8]     ),     
    .io_input_aw_payload_size       ( io_ddr_aw_payload_size_u  [UPSIZER_DMA*3+:3]     ),    
    .io_input_aw_payload_burst      ( io_ddr_aw_payload_burst_u [UPSIZER_DMA*2+:2]     ),   
    .io_input_aw_payload_lock       ( io_ddr_aw_payload_lock_u  [UPSIZER_DMA*1+:1]     ),    
    .io_input_aw_payload_qos        ( io_ddr_aw_payload_qos_u   [UPSIZER_DMA*4+:4]     ),     
    .io_input_aw_payload_cache      ( io_ddr_aw_payload_cache_u [UPSIZER_DMA*4+:4]     ), 
    .io_input_ar_valid              ( io_ddr_ar_valid_u         [UPSIZER_DMA*1+:1]     ),     
    .io_input_ar_ready              ( io_ddr_ar_ready_u         [UPSIZER_DMA*1+:1]     ),     
    .io_input_ar_payload_len        ( io_ddr_ar_payload_len_u   [UPSIZER_DMA*8+:8]     ),     
    .io_input_ar_payload_size       ( io_ddr_ar_payload_size_u  [UPSIZER_DMA*3+:3]     ),   
    .io_input_ar_payload_burst      ( io_ddr_ar_payload_burst_u [UPSIZER_DMA*2+:2]     ),   
    .io_input_ar_payload_lock       ( io_ddr_ar_payload_lock_u  [UPSIZER_DMA*1+:1]     ),   
    .io_input_ar_payload_qos        ( io_ddr_ar_payload_qos_u   [UPSIZER_DMA*4+:4]     ),     
    .io_input_w_valid               ( io_ddr_w_valid_u          [UPSIZER_DMA*1+:1]     ),
    .io_input_w_ready               ( io_ddr_w_ready_u          [UPSIZER_DMA*1+:1]     ),
    .io_input_w_payload_data        ( io_ddr_w_payload_data_u   [UPSIZER_DMA*256+:256] ),
    .io_input_w_payload_strb        ( io_ddr_w_payload_strb_u   [UPSIZER_DMA*32+:32]   ),
    .io_input_w_payload_last        ( io_ddr_w_payload_last_u   [UPSIZER_DMA*1+:1]     ),
    .io_input_b_valid               ( io_ddr_b_valid_u          [UPSIZER_DMA*1+:1]     ),
    .io_input_b_ready               ( io_ddr_b_ready_u          [UPSIZER_DMA*1+:1]     ),
    .io_input_b_payload_resp        ( io_ddr_b_payload_resp_u   [UPSIZER_DMA*2+:2]     ),
    .io_input_r_valid               ( io_ddr_r_valid_u          [UPSIZER_DMA*1+:1]     ),
    .io_input_r_ready               ( io_ddr_r_ready_u          [UPSIZER_DMA*1+:1]     ),
    .io_input_r_payload_data        ( io_ddr_r_payload_data_u   [UPSIZER_DMA*256+:256] ),
    .io_input_r_payload_resp        ( io_ddr_r_payload_resp_u   [UPSIZER_DMA*2+:2]     ),
    .io_input_r_payload_last        ( io_ddr_r_payload_last_u   [UPSIZER_DMA*1+:1]     ),
    .io_input_ar_payload_addr       ( io_ddr_ar_payload_addr_i  [UPSIZER_DMA*32+:32]   ),
    .io_input_aw_payload_addr       ( io_ddr_aw_payload_addr_i  [UPSIZER_DMA*32+:32]   ),
    .io_input_ar_payload_id         (   ), // Only for Soc
    .io_input_aw_payload_id         (   ), // Only for Soc
    .io_input_b_payload_id          (   ), // Only for Soc
    .io_input_r_payload_id          (   ), // Only for Soc
    .io_input_aw_payload_prot       (   ),
    .io_input_aw_payload_region     (   ), 
    .io_input_ar_payload_prot       (   ),
    .io_input_ar_payload_cache      (   ),
    .io_input_ar_payload_region     (   ),  
    //512 DW bit DDR
    .io_output_aw_payload_prot      (   ),
    .io_output_aw_payload_region    (   ),
    .io_output_ar_payload_prot      (   ),
    .io_output_ar_payload_cache     (   ),
    .io_output_ar_payload_region    (   ),
    .io_output_ar_payload_id        (   ), // Only for Soc
    .io_output_aw_payload_id        (   ), // Only for Soc
    .io_output_b_payload_id         (   ), // Only for Soc
    .io_output_r_payload_id         (   ), // Only for Soc
    .io_output_ar_payload_addr      ( io_ddr_ar_payload_addr_u[UPSIZER_DMA*32+:32]    ), //output to DDR
    .io_output_aw_payload_addr      ( io_ddr_aw_payload_addr_u[UPSIZER_DMA*32+:32]    ), //output to DDR
    .io_output_aw_valid             ( io_ddrB_aw_valid         ),
    .io_output_aw_ready             ( io_ddrB_aw_ready         ),
    .io_output_aw_payload_len       ( io_ddrB_aw_payload_len   ),
    .io_output_aw_payload_size      ( io_ddrB_aw_payload_size  ),
    .io_output_aw_payload_burst     ( io_ddrB_aw_payload_burst ),
    .io_output_aw_payload_lock      ( io_ddrB_aw_payload_lock  ),
    .io_output_aw_payload_qos       ( io_ddrB_aw_payload_qos   ),
    .io_output_aw_payload_cache     ( io_ddrB_aw_payload_cache ),
    .io_output_ar_valid             ( io_ddrB_ar_valid         ),
    .io_output_ar_ready             ( io_ddrB_ar_ready         ),
    .io_output_ar_payload_len       ( io_ddrB_ar_payload_len   ),
    .io_output_ar_payload_size      ( io_ddrB_ar_payload_size  ),
    .io_output_ar_payload_burst     ( io_ddrB_ar_payload_burst ),
    .io_output_ar_payload_lock      ( io_ddrB_ar_payload_lock  ),
    .io_output_ar_payload_qos       ( io_ddrB_ar_payload_qos   ),
    .io_output_w_valid              ( io_ddrB_w_valid          ),   
    .io_output_w_ready              ( io_ddrB_w_ready          ),
    .io_output_w_payload_data       ( io_ddrB_w_payload_data   ),
    .io_output_w_payload_strb       ( io_ddrB_w_payload_strb   ),
    .io_output_w_payload_last       ( io_ddrB_w_payload_last   ),
    .io_output_b_valid              ( io_ddrB_b_valid          ),
    .io_output_b_ready              ( io_ddrB_b_ready          ),
    .io_output_b_payload_resp       ( io_ddrB_b_payload_resp   ),
    .io_output_r_valid              ( io_ddrB_r_valid          ),
    .io_output_r_ready              ( io_ddrB_r_ready          ),
    .io_output_r_payload_data       ( io_ddrB_r_payload_data   ),
    .io_output_r_payload_resp       ( io_ddrB_r_payload_resp   ),
    .io_output_r_payload_last       ( io_ddrB_r_payload_last   ),
    .clk                            ( io_memoryClk             ),
    .reset                          ( io_memoryReset           )
);

/********************************************* AXI Interconnect ********************************************/

`ifdef ENABLE_AXI_INTERCONNECT
// HW_ACCEL: 0
// SDHC    : 1
// AXI Interconnect for SDHC & EVSOC HW ACCEL
wire [(AXIS_DEV*8)-1:0]     gAXIS_m_awid;
wire [(AXIS_DEV*8)-1:0]     gAXIS_m_arid;
wire [(AXIS_DEV*8)-1:0]     gAXIS_m_bid;
wire [(AXIS_DEV*8)-1:0]     gAXIS_m_rid;
wire [(AXIS_DEV*32)-1:0]    gAXIS_m_awaddr;
wire [(AXIS_DEV*8)-1:0]	    gAXIS_m_awlen;
wire [(AXIS_DEV*3)-1:0]	    gAXIS_m_awsize;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_awburst;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_awlock;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_awcache;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_awprot;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_awqos;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_awregion;
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
wire [(AXIS_DEV*8)-1:0]	    gAXIS_m_arlen;
wire [(AXIS_DEV*3)-1:0]	    gAXIS_m_arsize;
wire [(AXIS_DEV*2)-1:0]	    gAXIS_m_arburst;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_arlock;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_arcache;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_arprot;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_arqos;
wire [(AXIS_DEV*4)-1:0]	    gAXIS_m_arregion;
wire [AXIS_DEV-1:0]         gAXIS_m_arvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_arready;
wire [(AXIS_DEV*32)-1:0]    gAXIS_m_rdata;
wire [(AXIS_DEV*2)-1:0]     gAXIS_m_rresp;
wire [AXIS_DEV-1:0]         gAXIS_m_rlast;
wire [AXIS_DEV-1:0]         gAXIS_m_rvalid;
wire [AXIS_DEV-1:0]         gAXIS_m_rready;

// AXI-Interconnect <=> SoC
wire                w_axiA_awready ;
wire  [7:0]         w_axiA_awlen   ;
wire  [2:0]         w_axiA_awsize  ;
wire                w_axiA_awlock  ;
wire  [3:0]         w_axiA_awqos   ;
wire  [2:0]         w_axiA_awprot  ;
wire  [3:0]         w_axiA_awcache ;
wire  [1:0]         w_axiA_awburst ;
wire  [31:0]        w_axiA_awaddr  ;
wire  [7:0]         w_axiA_awid    ;
wire  [3:0]         w_axiA_awregion;
wire                w_axiA_awvalid ;
wire  [1:0]         w_axiA_arburst ;
wire  [3:0]         w_axiA_arcache ;
wire  [2:0]         w_axiA_arsize  ;
wire  [3:0]         w_axiA_arregion;
wire                w_axiA_arready ;
wire  [3:0]         w_axiA_arqos   ;
wire  [2:0]         w_axiA_arprot  ;
wire                w_axiA_arlock  ;
wire  [7:0]         w_axiA_arlen   ;
wire  [7:0]         w_axiA_arid    ;
wire                w_axiA_arvalid ;
wire  [31:0]        w_axiA_araddr  ;
wire                w_axiA_rlast   ;
wire                w_axiA_rvalid  ;
wire                w_axiA_rready  ;
wire   [31:0]       w_axiA_rdata   ;
wire   [7:0]        w_axiA_rid     ;
wire   [1:0]        w_axiA_rresp   ;
wire                w_axiA_wvalid  ;
wire                w_axiA_wready  ;
wire   [31:0]       w_axiA_wdata   ;
wire   [3:0]        w_axiA_wstrb   ;
wire                w_axiA_wlast   ;
wire                w_axiA_bvalid  ;
wire                w_axiA_bready  ;
wire   [7:0]        w_axiA_bid     ;
wire   [1:0]        w_axiA_bresp   ;
wire                w_axiAInterrupt;

// AXI-Interconnect <=> SDHC
assign gAXIS_m_rid[SDHC*8+:8]       = 8'h0;
assign gAXIS_m_bid[SDHC*8+:8]       = 8'h0;
assign gAXIS_m_rlast[SDHC*1 +: 1]   = 1'b1;

//AXI4_slave of soc (Slave) <=> SDHC, EVSOC HW ACCEL, TSE
gAXIS_1to3_switch u_AXIS_1to3_switch
(
    //from SDHC, EVSOC HW ACCEL
    .rst_n              ( ~io_peripheralReset ),
    .clk                ( io_peripheralClk    ),
    .m_axi_awvalid      ( gAXIS_m_awvalid     ),
    .m_axi_awready      ( gAXIS_m_awready     ),
    .m_axi_awid         ( gAXIS_m_awid        ), 
    .m_axi_awaddr       ( gAXIS_m_awaddr      ),
    .m_axi_awburst      ( gAXIS_m_awburst     ),
    .m_axi_awlen        ( gAXIS_m_awlen       ),
    .m_axi_awsize       ( gAXIS_m_awsize      ),
    .m_axi_awcache      ( gAXIS_m_awcache     ),
    .m_axi_awqos        ( gAXIS_m_awqos       ),
    .m_axi_awprot       ( gAXIS_m_awprot      ),
    .m_axi_awuser       (  ),
    .m_axi_awlock       ( gAXIS_m_awlock      ),
    .m_axi_awregion     ( gAXIS_m_awregion    ),
    .m_axi_wvalid       ( gAXIS_m_wvalid      ),
    .m_axi_wready       ( gAXIS_m_wready      ),
    .m_axi_wdata        ( gAXIS_m_wdata       ),
    .m_axi_wstrb        ( gAXIS_m_wstrb       ),
    .m_axi_wlast        ( gAXIS_m_wlast       ),
    .m_axi_wuser        (  ),
    .m_axi_bready       ( gAXIS_m_bready      ),
    .m_axi_bvalid       ( gAXIS_m_bvalid      ),
    .m_axi_bresp        ( gAXIS_m_bresp       ),
    .m_axi_buser        ( {AXIS_DEV{3'h0}}    ),
    .m_axi_bid          ( gAXIS_m_bid         ),
    .m_axi_arvalid      ( gAXIS_m_arvalid     ),
    .m_axi_arready      ( gAXIS_m_arready     ),
    .m_axi_arid         ( gAXIS_m_arid        ),
    .m_axi_araddr       ( gAXIS_m_araddr      ),
    .m_axi_arburst      ( gAXIS_m_arburst     ),
    .m_axi_arlen        ( gAXIS_m_arlen       ),
    .m_axi_arsize       ( gAXIS_m_arsize      ),
    .m_axi_arlock       ( gAXIS_m_arlock      ),
    .m_axi_arprot       ( gAXIS_m_arprot      ),
    .m_axi_arcache      ( gAXIS_m_arcache     ),
    .m_axi_arqos        ( gAXIS_m_arqos       ),
    .m_axi_aruser       (  ),
    .m_axi_arregion     ( gAXIS_m_arregion    ),
    .m_axi_ruser        ( {AXIS_DEV{3'h0}}    ),
    .m_axi_rvalid       ( gAXIS_m_rvalid      ),
    .m_axi_rready       ( gAXIS_m_rready      ),
    .m_axi_rid          ( gAXIS_m_rid         ),
    .m_axi_rdata        ( gAXIS_m_rdata       ),
    .m_axi_rresp        ( gAXIS_m_rresp       ),
    .m_axi_rlast        ( gAXIS_m_rlast       ),

    //from SoC
    .s_axi_awvalid      ( w_axiA_awvalid               ),
    .s_axi_awready      ( w_axiA_awready               ),
    .s_axi_awaddr       ( {8'h00, w_axiA_awaddr[23:0]} ),
    .s_axi_awid         ( w_axiA_awid                  ),
    .s_axi_awburst      ( w_axiA_awburst               ),
    .s_axi_awlen        ( w_axiA_awlen                 ),
    .s_axi_awsize       ( w_axiA_awsize                ),
    .s_axi_awprot       ( {1'b0, w_axiA_awprot}        ),
    .s_axi_awlock       ( {1'b0, w_axiA_awlock}        ),
    .s_axi_awcache      ( w_axiA_awcache               ),
    .s_axi_awqos        ( w_axiA_awqos                 ),
    .s_axi_awuser       ( 3'h0                         ),
    .s_axi_wvalid       ( w_axiA_wvalid                ),
    .s_axi_wready       ( w_axiA_wready                ),
    .s_axi_wid          ( 8'h00                        ),
    .s_axi_wdata        ( w_axiA_wdata                 ),
    .s_axi_wlast        ( w_axiA_wlast                 ),
    .s_axi_wstrb        ( w_axiA_wstrb                 ),
    .s_axi_wuser        ( 3'h0                         ),
    .s_axi_bvalid       ( w_axiA_bvalid                ),
    .s_axi_bready       ( w_axiA_bready                ),
    .s_axi_bresp        ( w_axiA_bresp                 ),
    .s_axi_bid          ( w_axiA_bid                   ),
    .s_axi_buser        (  ),
    .s_axi_ruser        (  ),
    .s_axi_arvalid      ( w_axiA_arvalid               ),
    .s_axi_arready      ( w_axiA_arready               ),
    .s_axi_araddr       ( {8'h00, w_axiA_araddr[23:0]} ),
    .s_axi_arid         ( w_axiA_arid                  ),
    .s_axi_arburst      ( w_axiA_arburst               ),
    .s_axi_arlen        ( w_axiA_arlen                 ),
    .s_axi_arsize       ( w_axiA_arsize                ),
    .s_axi_arprot       ( { 1'b0, w_axiA_arprot}       ),
    .s_axi_arlock       ( { 1'b0, w_axiA_arlock}       ),
    .s_axi_arcache      ( w_axiA_arcache               ),
    .s_axi_arqos        ( w_axiA_arqos                 ),
    .s_axi_aruser       ( 3'h0                         ),
    .s_axi_rready       ( w_axiA_rready                ),
    .s_axi_rvalid       ( w_axiA_rvalid                ),
    .s_axi_rdata        ( w_axiA_rdata                 ),
    .s_axi_rresp        ( w_axiA_rresp                 ),
    .s_axi_rlast        ( w_axiA_rlast                 ),
    .s_axi_rid          ( w_axiA_rid                   )

);
`endif

/****************************************** SD Related Modules Instantiation *****************************************/

`ifdef ENABLE_SDHC

//--AXI4 Interface
wire    [7:0]               sd_m_axi_awid;
wire    [SD_AXI_AW-1:0]     sd_m_axi_awaddr;
wire    [7:0]               sd_m_axi_awlen;
wire    [2:0]               sd_m_axi_awsize;
wire    [1:0]               sd_m_axi_awburst;
wire                        sd_m_axi_awlock;
wire    [3:0]               sd_m_axi_awcache;
wire    [2:0]               sd_m_axi_awprot;
wire                        sd_m_axi_awvalid;
wire                        sd_m_axi_awready;
wire    [SD_AXI_DW-1:0]     sd_m_axi_wdata;
wire    [SD_AXI_SW-1:0]     sd_m_axi_wstrb;
wire                        sd_m_axi_wlast;
wire                        sd_m_axi_wvalid;
wire                        sd_m_axi_wready;
wire    [7:0]               sd_m_axi_bid;
wire    [1:0]               sd_m_axi_bresp;
wire                        sd_m_axi_bvalid;
wire                        sd_m_axi_bready;
wire    [7:0]               sd_m_axi_arid;
wire    [SD_AXI_AW-1:0]     sd_m_axi_araddr;
wire    [7:0]               sd_m_axi_arlen;
wire    [2:0]               sd_m_axi_arsize;
wire    [1:0]               sd_m_axi_arburst;
wire                        sd_m_axi_arlock;
wire    [3:0]               sd_m_axi_arcache;
wire    [2:0]               sd_m_axi_arprot;
wire                        sd_m_axi_arvalid;
wire                        sd_m_axi_arready;
wire    [7:0]               sd_m_axi_rid;
wire    [SD_AXI_DW-1:0]     sd_m_axi_rdata;
wire    [1:0]               sd_m_axi_rresp;
wire                        sd_m_axi_rlast;
wire                        sd_m_axi_rvalid;
wire                        sd_m_axi_rready;

// SD Related wires
wire                        sd_int;
wire                        sd_dat_oe_w;
wire                        sd_cd_n; 
wire                        sd_wp; 

assign sd_cd_n          = 1'b0;
assign sd_wp            = 1'b1;
assign sd_dat_oe        = {4{sd_dat_oe_w}};

gSDHC u_sdhc
(
//Globle Signals
    .sd_rst                             ( io_systemReset   ),
    .sd_base_clk                        ( io_peripheralClk ),
    .sd_int                             ( sd_int           ),
    .sd_wp                              ( sd_wp            ),
    .sd_cd_n                            ( sd_cd_n          ),
//AXI4-Lite Register Interface
    .s_axi_aclk                         ( io_peripheralClk               ),
    .s_axi_awaddr                       ( gAXIS_m_awaddr [SDHC*32 +: 32] ),
    .s_axi_awready                      ( gAXIS_m_awready[SDHC*1 +: 1]   ),
    .s_axi_awvalid                      ( gAXIS_m_awvalid[SDHC*1 +: 1]   ),
    .s_axi_wstrb                        ( gAXIS_m_wstrb  [SDHC*4 +: 4]   ),
    .s_axi_wdata                        ( gAXIS_m_wdata  [SDHC*32 +: 32] ),
    .s_axi_wready                       ( gAXIS_m_wready [SDHC*1 +: 1]   ),
    .s_axi_wvalid                       ( gAXIS_m_wvalid [SDHC*1 +: 1]   ),
    .s_axi_bresp                        ( gAXIS_m_bresp  [SDHC*2 +: 2]   ),
    .s_axi_bvalid                       ( gAXIS_m_bvalid [SDHC*1 +: 1]   ),
    .s_axi_araddr                       ( gAXIS_m_araddr [SDHC*32 +: 32] ),
    .s_axi_bready                       ( gAXIS_m_bready [SDHC*1 +: 1]   ),
    .s_axi_arready                      ( gAXIS_m_arready[SDHC*1 +: 1]   ),
    .s_axi_arvalid                      ( gAXIS_m_arvalid[SDHC*1 +: 1]   ),
    .s_axi_rresp                        ( gAXIS_m_rresp  [SDHC*2 +: 2]   ),
    .s_axi_rdata                        ( gAXIS_m_rdata  [SDHC*32 +: 32] ),
    .s_axi_rvalid                       ( gAXIS_m_rvalid [SDHC*1 +: 1]   ),
    .s_axi_rready                       ( gAXIS_m_rready [SDHC*1 +: 1]   ),
//AXI4 Memory Bus Interface
    .m_axi_clk                          ( io_peripheralClk ),
//--Write Bus Interface
    .m_axi_awvalid                      ( sd_m_axi_awvalid ),
    .m_axi_awaddr                       ( sd_m_axi_awaddr [0*SD_AXI_AW +: 1*SD_AXI_AW] ), 
    .m_axi_wstrb                        ( sd_m_axi_wstrb  [0*SD_AXI_SW +: 1*SD_AXI_SW] ),
    .m_axi_awlen                        ( sd_m_axi_awlen  [0*8      +: 1*8]            ),
    .m_axi_awsize                       ( sd_m_axi_awsize [0*3      +: 1*3]            ),
    .m_axi_awburst                      ( sd_m_axi_awburst[0*2      +: 1*2]            ),
    .m_axi_awprot                       ( sd_m_axi_awprot [0*3      +: 1*3]            ),
    .m_axi_awlock                       ( sd_m_axi_awlock                              ),
    .m_axi_awcache                      ( sd_m_axi_awcache[0*4      +: 1*4]            ),
    .m_axi_awready                      ( sd_m_axi_awready                             ),
    .m_axi_wdata                        ( sd_m_axi_wdata  [0*SD_AXI_DW +: 1*SD_AXI_DW] ), 
    .m_axi_wlast                        ( sd_m_axi_wlast                               ),
    .m_axi_wvalid                       ( sd_m_axi_wvalid                              ),
    .m_axi_wready                       ( sd_m_axi_wready                              ),
    .m_axi_bresp                        ( sd_m_axi_bresp  [0*2      +: 1*2]            ),
    .m_axi_bvalid                       ( sd_m_axi_bvalid                              ),
    .m_axi_bready                       ( sd_m_axi_bready                              ),
//--Read Bus Interface
    .m_axi_arvalid                      ( sd_m_axi_arvalid                             ),
    .m_axi_araddr                       ( sd_m_axi_araddr [0*SD_AXI_AW +: 1*SD_AXI_AW] ), 
    .m_axi_arlen                        ( sd_m_axi_arlen  [0*8      +: 1*8]            ),
    .m_axi_arsize                       ( sd_m_axi_arsize [0*3      +: 1*3]            ),
    .m_axi_arburst                      ( sd_m_axi_arburst[0*2      +: 1*2]            ),
    .m_axi_arprot                       ( sd_m_axi_arprot [0*3      +: 1*3]            ),
    .m_axi_arlock                       ( sd_m_axi_arlock                              ),
    .m_axi_arcache                      ( sd_m_axi_arcache[0*4      +: 1*4]            ),
    .m_axi_arready                      ( sd_m_axi_arready                             ),
    .m_axi_rvalid                       ( sd_m_axi_rvalid                              ),
    .m_axi_rdata                        ( sd_m_axi_rdata  [0*SD_AXI_DW +: 1*SD_AXI_DW] ), 
    .m_axi_rlast                        ( sd_m_axi_rlast                               ),
    .m_axi_rresp                        ( sd_m_axi_rresp  [0*2      +: 1*2]            ),
    .m_axi_rready                       ( sd_m_axi_rready                              ),
//SD Interface
    .sd_clk_hi                          ( sd_clk_hi   ),
    .sd_clk_lo                          ( sd_clk_lo   ),
    .sd_cmd_i                           ( sd_cmd_i    ),
    .sd_cmd_o                           ( sd_cmd_o    ),
    .sd_cmd_oe                          ( sd_cmd_oe   ),
    .sd_dat_i                           ( sd_dat_i    ),
    .sd_dat_o                           ( sd_dat_o    ),
    .sd_dat_oe                          ( sd_dat_oe_w )
);
`endif

/********************************************* TSEMAC ********************************************/

`ifdef ENABLE_ETHERNET

//AXI4 Master to DMA Wires
wire                    tse_dmaaxi_read_arvalid;
wire                    tse_dmaaxi_read_arready;
wire    [31:0]          tse_dmaaxi_read_araddr;
wire    [3:0]           tse_dmaaxi_read_arregion;
wire    [7:0]           tse_dmaaxi_read_arlen;
wire    [2:0]           tse_dmaaxi_read_arsize;
wire    [1:0]           tse_dmaaxi_read_arburst;
wire    [0:0]           tse_dmaaxi_read_arlock;
wire    [3:0]           tse_dmaaxi_read_arcache;
wire    [3:0]           tse_dmaaxi_read_arqos;
wire    [2:0]           tse_dmaaxi_read_arprot;
wire                    tse_dmaaxi_read_rvalid;
wire                    tse_dmaaxi_read_rready;
wire    [AXIS_DW-1:0]   tse_dmaaxi_read_rdata;
wire    [1:0]           tse_dmaaxi_read_rresp;
wire                    tse_dmaaxi_read_rlast;
wire                    tse_dmaaxi_write_awvalid;
wire                    tse_dmaaxi_write_awready;
wire    [31:0]          tse_dmaaxi_write_awaddr;
wire    [3:0]           tse_dmaaxi_write_awregion;
wire    [7:0]           tse_dmaaxi_write_awlen;
wire    [2:0]           tse_dmaaxi_write_awsize;
wire    [1:0]           tse_dmaaxi_write_awburst;
wire    [0:0]           tse_dmaaxi_write_awlock;
wire    [3:0]           tse_dmaaxi_write_awcache;
wire    [3:0]           tse_dmaaxi_write_awqos;
wire    [2:0]           tse_dmaaxi_write_awprot;
wire                    tse_dmaaxi_write_wvalid;
wire                    tse_dmaaxi_write_wready;
wire    [AXIS_DW-1:0]   tse_dmaaxi_write_wdata;
wire    [AXIS_DW/8-1:0] tse_dmaaxi_write_wstrb;
wire                    tse_dmaaxi_write_wlast;
wire                    tse_dmaaxi_write_bvalid;
wire                    tse_dmaaxi_write_bready;
wire    [1:0]           tse_dmaaxi_write_bresp;

// TSE MAC Stream
wire                    s_eth_tx_tvalid;
wire                    s_eth_tx_tready;
wire    [7:0]           s_eth_tx_tdata;
wire    [0:0]           s_eth_tx_tkeep;
wire    [3:0]           s_eth_tx_tdest;
wire                    s_eth_tx_tlast;

wire                    m_eth_rx_tvalid;
wire                    m_eth_rx_tready;
wire    [7:0]           m_eth_rx_tdata;
wire    [3:0]           m_eth_rx_tdest;
wire                    m_eth_rx_tlast;

wire                    mac_ext_rst;
wire                    dma_rx_rst;
wire                    dma_tx_rst;

//TSE related wires
wire    [1:0]           tse_dma_interrupts;
wire                    rx_dma_descriptorUpdate;
wire                    io_ddrMasters_0_reset;
wire    [2:0]           tse_eth_speed;
wire                    phy_sw_rst;
wire                    rgmii_rxc;

assign rgmii_rxc  = mux_clk;
assign o_phy_rstn = phy_sw_rst;
assign mux_clk_sw = tse_eth_speed[2] ? 2 : 3;    //select clock 2 when speed == 1000Mbps


tseCore #(
    .FAMILY(FAMILY)
    )u_core (
    .io_peripheralClk        ( io_peripheralClk   ),
    .io_peripheralReset      ( io_peripheralReset ),
    .io_tseClk               ( io_tseClk   ),
    .pll_locked              ( pll_locked  ),
    .phy_sw_rst              ( phy_sw_rst  ),
    .mac_ext_rst             ( mac_ext_rst ),
    .dma_rx_rst              ( dma_rx_rst  ),
    .dma_tx_rst              ( dma_tx_rst  ),
    .dma_tx_descriptorUpdate ( rx_dma_descriptorUpdate ),

    .rgmii_txd_HI       ( rgmii_txd_HI    ),
    .rgmii_txd_LO       ( rgmii_txd_LO    ),
    .rgmii_tx_ctl_HI    ( rgmii_tx_ctl_HI ),
    .rgmii_tx_ctl_LO    ( rgmii_tx_ctl_LO ),
    .rgmii_rx_ctl_HI    ( rgmii_rx_ctl_HI ),
    .rgmii_rx_ctl_LO    ( rgmii_rx_ctl_LO ),
    .rgmii_rxc          ( rgmii_rxc       ),
    .rgmii_txc_HI       ( rgmii_txc_HI ),
    .rgmii_txc_LO       ( rgmii_txc_LO ),
    .rgmii_rxd_HI       ( rgmii_rxd_HI ),
    .rgmii_rxd_LO       ( rgmii_rxd_LO ),

    // TSEMAC PHY MDIO Interface
    .phy_mdi            ( phy_mdi    ),
    .phy_mdo            ( phy_mdo    ),
    .phy_mdo_en         ( phy_mdo_en ),
    .phy_mdc            ( phy_mdc    ),
    // Mac Interface
    .s_axi_awaddr            ( gAXIS_m_awaddr [TSE*32 +: 32] ),   
    .s_axi_awvalid           ( gAXIS_m_awvalid[TSE*1 +: 1]   ),  
    .s_axi_awready           ( gAXIS_m_awready[TSE*1 +: 1]   ),  
    .s_axi_wdata             ( gAXIS_m_wdata  [TSE*32 +: 32] ),    
    .s_axi_wstrb             ( gAXIS_m_wstrb  [TSE*4 +: 4]   ),
    .s_axi_wlast             ( gAXIS_m_wlast  [TSE*1 +: 1]   ),
    .s_axi_wvalid            ( gAXIS_m_wvalid [TSE*1 +: 1]   ),   
    .s_axi_wready            ( gAXIS_m_wready [TSE*1 +: 1]   ),   
    .s_axi_bresp             ( gAXIS_m_bresp  [TSE*2 +: 2]   ),    
    .s_axi_bvalid            ( gAXIS_m_bvalid [TSE*1 +: 1]   ),   
    .s_axi_bready            ( gAXIS_m_bready [TSE*1 +: 1]   ),   
    .s_axi_araddr            ( gAXIS_m_araddr [TSE*32 +: 32] ),   
    .s_axi_arvalid           ( gAXIS_m_arvalid[TSE*1 +: 1]   ),  
    .s_axi_arready           ( gAXIS_m_arready[TSE*1 +: 1]   ),  
    .s_axi_rresp             ( gAXIS_m_rresp  [TSE*2 +: 2]   ),    
    .s_axi_rdata             ( gAXIS_m_rdata  [TSE*32 +: 32] ),    
    .s_axi_rlast             ( gAXIS_m_rlast  [TSE*1 +: 1]   ),
    .s_axi_rvalid            ( gAXIS_m_rvalid [TSE*1 +: 1]   ),   
    .s_axi_rready            ( gAXIS_m_rready [TSE*1 +: 1]   ),
    // Mac Stream
    .s_eth_tx_tvalid         ( s_eth_tx_tvalid ),
    .s_eth_tx_tready         ( s_eth_tx_tready ),
    .s_eth_tx_tdata          ( s_eth_tx_tdata  ),
    .s_eth_tx_tkeep          ( s_eth_tx_tkeep  ),
    .s_eth_tx_tdest          ( s_eth_tx_tdest  ),
    .s_eth_tx_tlast          ( s_eth_tx_tlast  ),
    .m_eth_rx_tvalid         ( m_eth_rx_tvalid ),
    .m_eth_rx_tready         ( m_eth_rx_tready ),
    .m_eth_rx_tdata          ( m_eth_rx_tdata  ),
    .m_eth_rx_tlast          ( m_eth_rx_tlast  )
);

/**************************************************
 *
 * DMA Instantiation
 * To pass data to/from TSEMAC with Soc's ddrMaster 
 * 
**************************************************/ 
gDMA u_dma (
    .clk                  ( io_memoryClk          ),
    .reset                ( io_ddrMasters_0_reset ),
    .ctrl_clk             ( io_peripheralClk      ),
    .ctrl_reset           ( io_systemReset        ),

    .ctrl_PADDR           ( tse_dma_apbSlave_2_PADDR     ),
    .ctrl_PREADY          ( tse_dma_apbSlave_2_PREADY    ),
    .ctrl_PENABLE         ( tse_dma_apbSlave_2_PENABLE   ),
    .ctrl_PSEL            ( tse_dma_apbSlave_2_PSEL      ),
    .ctrl_PWRITE          ( tse_dma_apbSlave_2_PWRITE    ),
    .ctrl_PWDATA          ( tse_dma_apbSlave_2_PWDATA    ),
    .ctrl_PRDATA          ( tse_dma_apbSlave_2_PRDATA    ),
    .ctrl_PSLVERROR       ( tse_dma_apbSlave_2_PSLVERROR ),
    .ctrl_interrupts      ( tse_dma_interrupts             ),

    .read_arvalid         ( tse_dmaaxi_read_arvalid   ),
    .read_araddr          ( tse_dmaaxi_read_araddr    ),
    .read_arready         ( tse_dmaaxi_read_arready   ),
    .read_arregion        ( tse_dmaaxi_read_arregion  ),
    .read_arlen           ( tse_dmaaxi_read_arlen     ),
    .read_arsize          ( tse_dmaaxi_read_arsize    ),
    .read_arburst         ( tse_dmaaxi_read_arburst   ),
    .read_arlock          ( tse_dmaaxi_read_arlock    ),
    .read_arcache         ( tse_dmaaxi_read_arcache   ),
    .read_arqos           ( tse_dmaaxi_read_arqos     ),
    .read_arprot          ( tse_dmaaxi_read_arprot    ),
    .read_rready          ( tse_dmaaxi_read_rready    ),
    .read_rvalid          ( tse_dmaaxi_read_rvalid    ),
    .read_rdata           ( tse_dmaaxi_read_rdata     ),
    .read_rlast           ( tse_dmaaxi_read_rlast     ),
    .read_rresp           ( tse_dmaaxi_read_rresp     ),
    .write_awvalid        ( tse_dmaaxi_write_awvalid  ),
    .write_awready        ( tse_dmaaxi_write_awready  ),
    .write_awaddr         ( tse_dmaaxi_write_awaddr   ),
    .write_awregion       ( tse_dmaaxi_write_awregion ),
    .write_awlen          ( tse_dmaaxi_write_awlen    ),
    .write_awsize         ( tse_dmaaxi_write_awsize   ),
    .write_awburst        ( tse_dmaaxi_write_awburst  ),
    .write_awlock         ( tse_dmaaxi_write_awlock   ),
    .write_awcache        ( tse_dmaaxi_write_awcache  ),
    .write_awqos          ( tse_dmaaxi_write_awqos    ),
    .write_awprot         ( tse_dmaaxi_write_awprot   ),
    .write_wvalid         ( tse_dmaaxi_write_wvalid   ),
    .write_wready         ( tse_dmaaxi_write_wready   ),
    .write_wdata          ( tse_dmaaxi_write_wdata    ),
    .write_wstrb          ( tse_dmaaxi_write_wstrb    ),
    .write_wlast          ( tse_dmaaxi_write_wlast    ),
    .write_bvalid         ( tse_dmaaxi_write_bvalid   ),
    .write_bready         ( tse_dmaaxi_write_bready   ),
    .write_bresp          ( tse_dmaaxi_write_bresp    ),

    .io_1_descriptorUpdate(),
    .dat1_o_clk           ( io_tseClk                ),
    .dat1_o_reset         ( mac_ext_rst | dma_tx_rst ),
    .dat1_o_tvalid        ( s_eth_tx_tvalid ),
    .dat1_o_tready        ( s_eth_tx_tready ),
    .dat1_o_tdata         ( s_eth_tx_tdata  ),
    .dat1_o_tkeep         ( s_eth_tx_tkeep  ),
    .dat1_o_tdest         ( s_eth_tx_tdest  ),
    .dat1_o_tlast         ( s_eth_tx_tlast  ),

    .io_0_descriptorUpdate( rx_dma_descriptorUpdate  ),
    .dat0_i_clk           ( rgmii_rxc                ),
    .dat0_i_reset         ( mac_ext_rst | dma_rx_rst ),
    .dat0_i_tvalid        ( m_eth_rx_tvalid          ),
    .dat0_i_tready        ( m_eth_rx_tready          ),
    .dat0_i_tdata         ( m_eth_rx_tdata           ),
    .dat0_i_tkeep         ( 1'b1                     ),
    .dat0_i_tdest         ( 4'h0                     ),
    .dat0_i_tlast         ( m_eth_rx_tlast           )
);

`endif // ENABLE_ETHERNET

/*********************************************Edge Vision Soc  ****************************************************/

`ifdef ENABLE_EVSOC

// Reset Wire for EVSOC
wire         i_arstn;
wire         mipi_rstn;

// I2C_0 -> Camera
wire         o_cam_sda;
wire         o_cam_scl;

//  Wire for Picam V2 module to DMA
wire         cam_dma_wready;
wire         cam_dma_wvalid;
wire         cam_dma_wlast;
wire [63:0]  cam_dma_wdata;

// Wire for Display Module to DMA
wire        display_dma_rready;
wire        display_dma_rvalid;
wire [63:0] display_dma_rdata;
wire [7:0]  display_dma_rkeep;

// Wire for Hardware Accelerator to DMA
wire            hw_accel_dma_rready;
wire            hw_accel_dma_rvalid;
wire [3:0]      hw_accel_dma_rkeep;
wire [31:0]     hw_accel_dma_rdata;
wire            hw_accel_dma_wready;
wire            hw_accel_dma_wvalid;
wire            hw_accel_dma_wlast;
wire [31:0]     hw_accel_dma_wdata;

// For demo mode selection and dma vision interrupt
wire  [3:0]   vision_dma_interrupts;

// Assignment for reset (EVSOC)
assign  o_cam_rstn      = i_arstn;
assign  o_cam_sda_oe    = !o_cam_sda;
assign  o_cam_scl_oe    = !o_cam_scl;

// Assignment for DMA vision Interrupt
assign  vision_dma_ctrl_interrupt = | vision_dma_interrupts;


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
    .i_pixel_clk           ( mipi_pclk           ),
    .io_peripheralClk      ( io_peripheralClk    ),
    .io_peripheralReset    ( io_peripheralReset  ),
    .i_hdmi_clk_148p5MHz   ( hdmi_yuv_clk ),
    .i_sys_clk_25mhz       ( hdmi_clk     ),
    .i_arstn               ( i_arstn      ),

    // PLL Locked
    .pll_system_locked     ( systemClk_locked     ), 
    .pll_hdmi_locked       ( mipi_pll_locked      ),
    .pll_peripheral_locked ( pll_locked ),

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

    // Camera (DMA)
    .cam_dma_wready     ( cam_dma_wready  ), 
    .cam_dma_wvalid     ( cam_dma_wvalid  ), 
    .cam_dma_wlast      ( cam_dma_wlast   ), 
    .cam_dma_wdata      ( cam_dma_wdata   ), 

    // I2C Configuration for HDMI
    .i2c_sda_i          ( hdmi_sda_read ), 
    .i2c_scl_i          ( hdmi_scl_read ), 
    .i2c_sda_oe         ( hdmi_sda_writeEnable ), 
    .i2c_scl_oe         ( hdmi_scl_writeEnable ), 

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
    .axi_interrupt ( w_axiAInterrupt                  ),
    .axi_awid      ( gAXIS_m_awid    [HW_ACCEL*8 +: 8]   ), 
    .axi_awaddr    ( gAXIS_m_awaddr  [HW_ACCEL*32 +: 32] ),
    .axi_awlen     ( gAXIS_m_awlen   [HW_ACCEL*8 +: 8]   ),
    .axi_awsize    ( gAXIS_m_awsize  [HW_ACCEL*3 +: 3]   ),
    .axi_awburst   ( gAXIS_m_awburst [HW_ACCEL*2 +: 2]   ),
    .axi_awlock    ( gAXIS_m_awlock  [HW_ACCEL*1 +: 1]   ),
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
    .axi_bid       ( gAXIS_m_bid     [HW_ACCEL*8 +: 8]   ), 
    .axi_bresp     ( gAXIS_m_bresp   [HW_ACCEL*2 +: 2]   ),
    .axi_bvalid    ( gAXIS_m_bvalid  [HW_ACCEL*1 +: 1]   ),
    .axi_bready    ( gAXIS_m_bready  [HW_ACCEL*1 +: 1]   ),
    .axi_arid      ( gAXIS_m_arid    [HW_ACCEL*8 +: 8]   ), 
    .axi_araddr    ( gAXIS_m_araddr  [HW_ACCEL*32 +: 32] ),
    .axi_arlen     ( gAXIS_m_arlen   [HW_ACCEL*8 +: 8]   ),
    .axi_arsize    ( gAXIS_m_arsize  [HW_ACCEL*3 +: 3]   ),
    .axi_arburst   ( gAXIS_m_arburst [HW_ACCEL*2 +: 2]   ),
    .axi_arlock    ( gAXIS_m_arlock  [HW_ACCEL*1 +: 1]   ),
    .axi_arcache   ( gAXIS_m_arcache [HW_ACCEL*4 +: 4]   ),
    .axi_arprot    ( gAXIS_m_arprot  [HW_ACCEL*3 +: 3]   ),
    .axi_arqos     ( gAXIS_m_arqos   [HW_ACCEL*4 +: 4]   ),
    .axi_arregion  ( gAXIS_m_arregion[HW_ACCEL*4 +: 4]   ),
    .axi_arvalid   ( gAXIS_m_arvalid [HW_ACCEL*1 +: 1]   ),
    .axi_arready   ( gAXIS_m_arready [HW_ACCEL*1 +: 1]   ),
    .axi_rid       ( gAXIS_m_rid     [HW_ACCEL*8 +: 8]   ),
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
    .mode_selector        ( system_gpio_0_io_read[0]  )          
);



/**************************************************
 *
 * DMA Instantiation
 * To pass data to/from cam and display with DDR 
 * 
**************************************************/ 
gDMA_vision u_dma_vision (
    .clk                ( io_memoryClk       ),
    .reset              ( io_memoryReset     ),   
    .ctrl_clk           ( io_peripheralClk   ),
    .ctrl_reset         ( io_peripheralReset ),

    //DMA AXI memory Interface with Upsizer
    .read_arvalid       ( io_ddr_ar_valid_u         [UPSIZER_DMA*1+:1]   ),
    .read_arready       ( io_ddr_ar_ready_u         [UPSIZER_DMA*1+:1]   ),
    .read_araddr        ( io_ddr_ar_payload_addr_i  [UPSIZER_DMA*32+:32] ), //output from DMA
    .read_arlen         ( io_ddr_ar_payload_len_u   [UPSIZER_DMA*8+:8]   ),
    .read_arsize        ( io_ddr_ar_payload_size_u  [UPSIZER_DMA*3+:3]   ),
    .read_arburst       ( io_ddr_ar_payload_burst_u [UPSIZER_DMA*2+:2]   ),
    .read_arlock        ( io_ddr_ar_payload_lock_u  [UPSIZER_DMA*1+:1]   ),
    .read_arqos         ( io_ddr_ar_payload_qos_u   [UPSIZER_DMA*4+:4]   ),
    .read_arregion      (  ),
    .read_arcache       (  ),
    .read_arprot        (  ),
    .write_awregion     (  ),
    .write_awprot       (  ),
    .read_rready        ( io_ddr_r_ready_u          [UPSIZER_DMA*1+:1]     ),
    .read_rvalid        ( io_ddr_r_valid_u          [UPSIZER_DMA*1+:1]     ),
    .read_rdata         ( io_ddr_r_payload_data_u   [UPSIZER_DMA*256+:256] ),
    .read_rlast         ( io_ddr_r_payload_last_u   [UPSIZER_DMA*1+:1]     ),
    .read_rresp         ( io_ddr_r_payload_resp_u   [UPSIZER_DMA*2+:2]     ),    
    .write_awvalid      ( io_ddr_aw_valid_u         [UPSIZER_DMA*1+:1]     ),
    .write_awready      ( io_ddr_aw_ready_u         [UPSIZER_DMA*1+:1]     ),
    .write_awaddr       ( io_ddr_aw_payload_addr_i  [UPSIZER_DMA*32+:32]   ),
    .write_awlen        ( io_ddr_aw_payload_len_u   [UPSIZER_DMA*8+:8]     ),
    .write_awsize       ( io_ddr_aw_payload_size_u  [UPSIZER_DMA*3+:3]     ),
    .write_awburst      ( io_ddr_aw_payload_burst_u [UPSIZER_DMA*2+:2]     ),
    .write_awlock       ( io_ddr_aw_payload_lock_u  [UPSIZER_DMA*1+:1]     ), //only 1 bit in DDR
    .write_awcache      ( io_ddr_aw_payload_cache_u [UPSIZER_DMA*4+:4]     ),
    .write_awqos        ( io_ddr_aw_payload_qos_u   [UPSIZER_DMA*4+:4]     ), //only 1 bit in DDR
    .write_wvalid       ( io_ddr_w_valid_u          [UPSIZER_DMA*1+:1]     ),
    .write_wready       ( io_ddr_w_ready_u          [UPSIZER_DMA*1+:1]     ),
    .write_wdata        ( io_ddr_w_payload_data_u   [UPSIZER_DMA*256+:256] ),
    .write_wstrb        ( io_ddr_w_payload_strb_u   [UPSIZER_DMA*32+:32]   ),
    .write_wlast        ( io_ddr_w_payload_last_u   [UPSIZER_DMA*1+:1]     ),
    .write_bvalid       ( io_ddr_b_valid_u          [UPSIZER_DMA*1+:1]     ),
    .write_bready       ( io_ddr_b_ready_u          [UPSIZER_DMA*1+:1]     ),
    .write_bresp        ( io_ddr_b_payload_resp_u   [UPSIZER_DMA*2+:2]     ),

    //64-bit Camera Video Stream In
    .dat0_i_clk         ( mipi_pclk           ),
    .dat0_i_reset       ( ~i_arstn            ),    
    .dat0_i_tvalid      ( cam_dma_wvalid      ),
    .dat0_i_tready      ( cam_dma_wready      ),
    .dat0_i_tdata       ( cam_dma_wdata       ),
    .dat0_i_tkeep       ( {8{cam_dma_wvalid}} ),
    .dat0_i_tdest       ( 4'd0                ),
    .dat0_i_tlast       ( cam_dma_wlast       ),

    //64-bit dma channel (MM2S - from external memory)
    .dat1_o_clk         ( hdmi_yuv_clk        ),
    .dat1_o_reset       ( ~i_arstn            ),
    .dat1_o_tvalid      ( display_dma_rvalid  ),
    .dat1_o_tready      ( display_dma_rready  ),
    .dat1_o_tdata       ( display_dma_rdata   ),
    .dat1_o_tkeep       ( display_dma_rkeep   ),
    .dat1_o_tdest       (  ),
    .dat1_o_tlast       (  ),
    
    //32-bit dma channel (S2MM - to DDR)
   .dat2_i_clk          ( io_peripheralClk             ),
   .dat2_i_reset        ( io_peripheralReset           ),
   .dat2_i_tvalid       ( hw_accel_dma_wvalid      ),
   .dat2_i_tready       ( hw_accel_dma_wready      ),
   .dat2_i_tdata        ( hw_accel_dma_wdata       ),
   .dat2_i_tkeep        ( {4{hw_accel_dma_wvalid}} ),
   .dat2_i_tdest        ( 4'd0                     ),
   .dat2_i_tlast        ( hw_accel_dma_wlast       ),

   //32-bit dma channel (MM2S - from DDR)
   .dat3_o_clk          ( io_peripheralClk             ), 
   .dat3_o_reset        ( io_peripheralReset           ),
   .dat3_o_tvalid       ( hw_accel_dma_rvalid      ),
   .dat3_o_tready       ( hw_accel_dma_rready      ),
   .dat3_o_tdata        ( hw_accel_dma_rdata       ),
   .dat3_o_tkeep        ( hw_accel_dma_rkeep       ),
   .dat3_o_tdest        ( ),
   .dat3_o_tlast        ( ),

    //APB Slave
   .ctrl_PADDR         ( vision_dma_apbSlave_0_PADDR[13:0] ),
   .ctrl_PSEL          ( vision_dma_apbSlave_0_PSEL        ),
   .ctrl_PENABLE       ( vision_dma_apbSlave_0_PENABLE     ),
   .ctrl_PREADY        ( vision_dma_apbSlave_0_PREADY      ),
   .ctrl_PWRITE        ( vision_dma_apbSlave_0_PWRITE      ),
   .ctrl_PWDATA        ( vision_dma_apbSlave_0_PWDATA      ),
   .ctrl_PRDATA        ( vision_dma_apbSlave_0_PRDATA      ),
   .ctrl_PSLVERROR     ( vision_dma_apbSlave_0_PSLVERROR   ),
   .ctrl_interrupts    ( vision_dma_interrupts             )
   
);

`endif // ENABLE_EVSOC


////////////////////////////////Miscellaneous Module////////////////////////////////////

//////////////////
//  Asynchronous reset synchronizer
//////////////////
wire w_master_rstn;

reset_synchronizer rstn_master_sync
(
 .reset_in  ( i_master_rstn ),
 .reset_out ( w_master_rstn ),
 .clk       ( io_systemClk  ) 
);

custom_instruction_tea cpu0_custom_instruction_tea_inst(
.clk             ( io_systemClk                       ),
.reset           ( io_systemReset                     ),
.cmd_valid       ( cpu0_customInstruction_cmd_valid   ),
.cmd_ready       ( cpu0_customInstruction_cmd_ready   ),
.cmd_function_id ( cpu0_customInstruction_function_id ),
.cmd_inputs_0    ( cpu0_customInstruction_inputs_0    ),
.cmd_inputs_1    ( cpu0_customInstruction_inputs_1    ),
.rsp_valid       ( cpu0_customInstruction_rsp_valid   ),
.rsp_ready       ( cpu0_customInstruction_rsp_ready   ),
.rsp_outputs_0   ( cpu0_customInstruction_outputs_0   ));

custom_instruction_tea cpu1_custom_instruction_tea_inst(
.clk             ( io_systemClk                       ),
.reset           ( io_systemReset                     ),
.cmd_valid       ( cpu1_customInstruction_cmd_valid   ),
.cmd_ready       ( cpu1_customInstruction_cmd_ready   ),
.cmd_function_id ( cpu1_customInstruction_function_id ),
.cmd_inputs_0    ( cpu1_customInstruction_inputs_0    ),
.cmd_inputs_1    ( cpu1_customInstruction_inputs_1    ),
.rsp_valid       ( cpu1_customInstruction_rsp_valid   ),
.rsp_ready       ( cpu1_customInstruction_rsp_ready   ),
.rsp_outputs_0   ( cpu1_customInstruction_outputs_0   ));


/********************************************* Sapphire Soc ********************************************/

EfxSapphireSoc soc_inst
(
//Clock
    .io_memoryClk                       ( io_memoryClk             ),
    .io_memoryReset                     ( io_memoryReset           ),
    .io_systemClk                       ( io_systemClk             ),
    .io_asyncReset                      ( reset                    ),
    .io_systemReset                     ( io_systemReset           ),
    .io_peripheralClk                   ( io_peripheralClk         ),
    .io_peripheralReset                 ( io_peripheralReset       ),
    .system_watchdog_hardPanic          ( w_system_watchdog_hardPanic        ),
    .cpu0_customInstruction_cmd_valid   ( cpu0_customInstruction_cmd_valid   ),
    .cpu0_customInstruction_cmd_ready   ( cpu0_customInstruction_cmd_ready   ),
    .cpu0_customInstruction_function_id ( cpu0_customInstruction_function_id ),
    .cpu0_customInstruction_inputs_0    ( cpu0_customInstruction_inputs_0    ),
    .cpu0_customInstruction_inputs_1    ( cpu0_customInstruction_inputs_1    ),
    .cpu0_customInstruction_rsp_valid   ( cpu0_customInstruction_rsp_valid   ),
    .cpu0_customInstruction_rsp_ready   ( cpu0_customInstruction_rsp_ready   ),
    .cpu0_customInstruction_outputs_0   ( cpu0_customInstruction_outputs_0   ),

    .cpu1_customInstruction_cmd_valid   ( cpu1_customInstruction_cmd_valid   ),
    .cpu1_customInstruction_cmd_ready   ( cpu1_customInstruction_cmd_ready   ),
    .cpu1_customInstruction_function_id ( cpu1_customInstruction_function_id ),
    .cpu1_customInstruction_inputs_0    ( cpu1_customInstruction_inputs_0    ),
    .cpu1_customInstruction_inputs_1    ( cpu1_customInstruction_inputs_1    ),
    .cpu1_customInstruction_rsp_valid   ( cpu1_customInstruction_rsp_valid   ),
    .cpu1_customInstruction_rsp_ready   ( cpu1_customInstruction_rsp_ready   ),
    .cpu1_customInstruction_outputs_0   ( cpu1_customInstruction_outputs_0   ),

`ifdef ENABLE_EVSOC
    //I2C_0
    .system_i2c_0_io_sda_write          ( o_cam_sda ),
    .system_i2c_0_io_sda_read           ( i_cam_sda ),
    .system_i2c_0_io_scl_write          ( o_cam_scl ),
    .system_i2c_0_io_scl_read           ( i_cam_scl ),

    // APB 3 Slave 0 - Control DMA
    .io_apbSlave_0_PADDR                ( vision_dma_apbSlave_0_PADDR     ),
    .io_apbSlave_0_PSEL                 ( vision_dma_apbSlave_0_PSEL      ),
    .io_apbSlave_0_PENABLE              ( vision_dma_apbSlave_0_PENABLE   ),
    .io_apbSlave_0_PREADY               ( vision_dma_apbSlave_0_PREADY    ),
    .io_apbSlave_0_PWRITE               ( vision_dma_apbSlave_0_PWRITE    ),
    .io_apbSlave_0_PWDATA               ( vision_dma_apbSlave_0_PWDATA    ),
    .io_apbSlave_0_PRDATA               ( vision_dma_apbSlave_0_PRDATA    ),
    .io_apbSlave_0_PSLVERROR            ( vision_dma_apbSlave_0_PSLVERROR ),
    
    // APB 3 Slave 1 -  Control and Status Register (EVSOC)
    .io_apbSlave_1_PADDR                ( vision_apbSlave_1_PADDR     ),
    .io_apbSlave_1_PSEL                 ( vision_apbSlave_1_PSEL      ),
    .io_apbSlave_1_PENABLE              ( vision_apbSlave_1_PENABLE   ),
    .io_apbSlave_1_PREADY               ( vision_apbSlave_1_PREADY    ),
    .io_apbSlave_1_PWRITE               ( vision_apbSlave_1_PWRITE    ),
    .io_apbSlave_1_PWDATA               ( vision_apbSlave_1_PWDATA    ),
    .io_apbSlave_1_PRDATA               ( vision_apbSlave_1_PRDATA    ),
    .io_apbSlave_1_PSLVERROR            ( vision_apbSlave_1_PSLVERROR ),

    .userInterruptA                     ( vision_dma_ctrl_interrupt ),

`endif
//UART 
    .system_uart_0_io_txd               ( system_uart_0_io_txd) ,
    .system_uart_0_io_rxd               ( system_uart_0_io_rxd) ,
 //DDR - AXI4 Channel 0 
    .io_ddrA_aw_valid                   ( io_ddr_aw_valid_u         [UPSIZER_SOC*1+:1] ),
    .io_ddrA_aw_ready                   ( io_ddr_aw_ready_u         [UPSIZER_SOC*1+:1] ),
    .io_ddrA_aw_payload_len             ( io_ddr_aw_payload_len_u   [UPSIZER_SOC*8+:8] ),
    .io_ddrA_aw_payload_size            ( io_ddr_aw_payload_size_u  [UPSIZER_SOC*3+:3] ),
    .io_ddrA_aw_payload_burst           ( io_ddr_aw_payload_burst_u [UPSIZER_SOC*2+:2] ),
    .io_ddrA_aw_payload_lock            ( io_ddr_aw_payload_lock_u  [UPSIZER_SOC*1+:1] ),
    .io_ddrA_aw_payload_qos             ( io_ddr_aw_payload_qos_u   [UPSIZER_SOC*4+:4] ),
    .io_ddrA_aw_payload_cache           ( io_ddr_aw_payload_cache_u [UPSIZER_SOC*4+:4] ),
    .io_ddrA_aw_payload_prot            (  ),
    .io_ddrA_aw_payload_region          (  ),
    .io_ddrA_ar_payload_cache           (  ),
    .io_ddrA_ar_payload_region          (  ),
    .io_ddrA_ar_payload_prot            (  ),
    .io_ddrA_ar_valid                   ( io_ddr_ar_valid_u         [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_ar_ready                   ( io_ddr_ar_ready_u         [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_ar_payload_len             ( io_ddr_ar_payload_len_u   [UPSIZER_SOC*8+:8]     ),
    .io_ddrA_ar_payload_size            ( io_ddr_ar_payload_size_u  [UPSIZER_SOC*3+:3]     ),
    .io_ddrA_ar_payload_burst           ( io_ddr_ar_payload_burst_u [UPSIZER_SOC*2+:2]     ),
    .io_ddrA_ar_payload_lock            ( io_ddr_ar_payload_lock_u  [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_ar_payload_qos             ( io_ddr_ar_payload_qos_u   [UPSIZER_SOC*4+:4]     ),
    .io_ddrA_w_valid                    ( io_ddr_w_valid_u          [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_w_ready                    ( io_ddr_w_ready_u          [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_w_payload_data             ( io_ddr_w_payload_data_u   [UPSIZER_SOC*256+:256] ),
    .io_ddrA_w_payload_strb             ( io_ddr_w_payload_strb_u   [UPSIZER_SOC*32+:32]   ),
    .io_ddrA_w_payload_last             ( io_ddr_w_payload_last_u   [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_b_valid                    ( io_ddr_b_valid_u          [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_b_ready                    ( io_ddr_b_ready_u          [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_b_payload_resp             ( io_ddr_b_payload_resp_u   [UPSIZER_SOC*2+:2]     ),
    .io_ddrA_r_valid                    ( io_ddr_r_valid_u          [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_r_ready                    ( io_ddr_r_ready_u          [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_r_payload_data             ( io_ddr_r_payload_data_u   [UPSIZER_SOC*256+:256] ),
    .io_ddrA_r_payload_resp             ( io_ddr_r_payload_resp_u   [UPSIZER_SOC*2+:2]     ),
    .io_ddrA_r_payload_last             ( io_ddr_r_payload_last_u   [UPSIZER_SOC*1+:1]     ),
    .io_ddrA_ar_payload_addr            ( io_ddr_ar_payload_addr_i  [UPSIZER_SOC*32+:32]   ),
    .io_ddrA_aw_payload_addr            ( io_ddr_aw_payload_addr_i  [UPSIZER_SOC*32+:32]   ),
    .io_ddrA_ar_payload_id              ( io_ddr_ar_payload_id_i                           ),
    .io_ddrA_aw_payload_id              ( io_ddr_aw_payload_id_i                           ),
    .io_ddrA_b_payload_id               ( io_ddr_b_payload_id_u     [UPSIZER_SOC*8+:8]     ),
    .io_ddrA_r_payload_id               ( io_ddr_r_payload_id_u     [UPSIZER_SOC*8+:8]     ),  

`ifdef ENABLE_ETHERNET

//APB3_2 - Connecting to TSE DMA Control
    .io_apbSlave_2_PADDR               ( tse_dma_apbSlave_2_PADDR     ),
    .io_apbSlave_2_PSEL                ( tse_dma_apbSlave_2_PSEL      ),
    .io_apbSlave_2_PENABLE             ( tse_dma_apbSlave_2_PENABLE   ),
    .io_apbSlave_2_PREADY              ( tse_dma_apbSlave_2_PREADY    ),
    .io_apbSlave_2_PWRITE              ( tse_dma_apbSlave_2_PWRITE    ),
    .io_apbSlave_2_PWDATA              ( tse_dma_apbSlave_2_PWDATA    ),
    .io_apbSlave_2_PRDATA              ( tse_dma_apbSlave_2_PRDATA    ),
    .io_apbSlave_2_PSLVERROR           ( tse_dma_apbSlave_2_PSLVERROR ),
//User Interrupts
    .userInterruptB                    ( tse_dma_interrupts[0] ),                
    .userInterruptC                    ( tse_dma_interrupts[1] ),
//AXI 4 Master_0 - Connecting to TSE DMA 
    .io_ddrMasters_0_aw_valid          ( tse_dmaaxi_write_awvalid  ),
    .io_ddrMasters_0_aw_ready          ( tse_dmaaxi_write_awready  ),
    .io_ddrMasters_0_aw_payload_addr   ( tse_dmaaxi_write_awaddr   ),
    .io_ddrMasters_0_aw_payload_id     ( 4'd8),
    .io_ddrMasters_0_aw_payload_region ( tse_dmaaxi_write_awregion ),
    .io_ddrMasters_0_aw_payload_len    ( tse_dmaaxi_write_awlen    ),
    .io_ddrMasters_0_aw_payload_size   ( tse_dmaaxi_write_awsize   ),
    .io_ddrMasters_0_aw_payload_burst  ( tse_dmaaxi_write_awburst  ),
    .io_ddrMasters_0_aw_payload_lock   ( tse_dmaaxi_write_awlock   ),
    .io_ddrMasters_0_aw_payload_cache  ( tse_dmaaxi_write_awcache  ),
    .io_ddrMasters_0_aw_payload_qos    ( tse_dmaaxi_write_awqos    ),
    .io_ddrMasters_0_aw_payload_prot   ( tse_dmaaxi_write_awprot   ),
    .io_ddrMasters_0_w_valid           ( tse_dmaaxi_write_wvalid   ),
    .io_ddrMasters_0_w_ready           ( tse_dmaaxi_write_wready   ),
    .io_ddrMasters_0_w_payload_data    ( tse_dmaaxi_write_wdata    ),
    .io_ddrMasters_0_w_payload_strb    ( tse_dmaaxi_write_wstrb    ),
    .io_ddrMasters_0_w_payload_last    ( tse_dmaaxi_write_wlast    ),
    .io_ddrMasters_0_b_valid           ( tse_dmaaxi_write_bvalid   ),
    .io_ddrMasters_0_b_ready           ( tse_dmaaxi_write_bready   ),
    .io_ddrMasters_0_b_payload_id      (  ),
    .io_ddrMasters_0_b_payload_resp    ( tse_dmaaxi_write_bresp    ),
    .io_ddrMasters_0_ar_valid          ( tse_dmaaxi_read_arvalid   ),
    .io_ddrMasters_0_ar_ready          ( tse_dmaaxi_read_arready   ),
    .io_ddrMasters_0_ar_payload_addr   ( tse_dmaaxi_read_araddr    ),
    .io_ddrMasters_0_ar_payload_id     ( 4'd7),
    .io_ddrMasters_0_ar_payload_region ( tse_dmaaxi_read_arregion  ),
    .io_ddrMasters_0_ar_payload_len    ( tse_dmaaxi_read_arlen     ),
    .io_ddrMasters_0_ar_payload_size   ( tse_dmaaxi_read_arsize    ),
    .io_ddrMasters_0_ar_payload_burst  ( tse_dmaaxi_read_arburst   ),
    .io_ddrMasters_0_ar_payload_lock   ( tse_dmaaxi_read_arlock    ),
    .io_ddrMasters_0_ar_payload_cache  ( tse_dmaaxi_read_arcache   ),
    .io_ddrMasters_0_ar_payload_qos    ( tse_dmaaxi_read_arqos     ),
    .io_ddrMasters_0_ar_payload_prot   ( tse_dmaaxi_read_arprot    ),
    .io_ddrMasters_0_r_valid           ( tse_dmaaxi_read_rvalid    ),
    .io_ddrMasters_0_r_ready           ( tse_dmaaxi_read_rready    ),
    .io_ddrMasters_0_r_payload_data    ( tse_dmaaxi_read_rdata     ),
    .io_ddrMasters_0_r_payload_id      (  ),
    .io_ddrMasters_0_r_payload_resp    ( tse_dmaaxi_read_rresp     ),
    .io_ddrMasters_0_r_payload_last    ( tse_dmaaxi_read_rlast     ),
    .io_ddrMasters_0_clk               ( io_memoryClk              ),
    .io_ddrMasters_0_reset             ( io_ddrMasters_0_reset     ), 
`else
    .io_ddrMasters_0_clk               ( io_memoryClk              ),
`endif


`ifdef ENABLE_SDHC
    .userInterruptD                     ( sd_int                 ),
    .io_ddrMasters_1_aw_valid           ( sd_m_axi_awvalid       ),
    .io_ddrMasters_1_aw_ready           ( sd_m_axi_awready       ),
    .io_ddrMasters_1_aw_payload_lock    ( sd_m_axi_awlock        ),
    .io_ddrMasters_1_aw_payload_addr    ( sd_m_axi_awaddr  [0*SD_AXI_AW +: 1*SD_AXI_AW] ),
    .io_ddrMasters_1_aw_payload_len     ( sd_m_axi_awlen   [0*8      +: 1*8]            ),
    .io_ddrMasters_1_aw_payload_size    ( sd_m_axi_awsize  [0*3      +: 1*3]            ),
    .io_ddrMasters_1_aw_payload_burst   ( sd_m_axi_awburst [0*2      +: 1*2]            ),
    .io_ddrMasters_1_aw_payload_cache   ( sd_m_axi_awcache [0*4      +: 1*4]            ),
    .io_ddrMasters_1_w_payload_data     ( sd_m_axi_wdata   [0*SD_AXI_DW +: 1*SD_AXI_DW] ),
    .io_ddrMasters_1_w_payload_strb     ( sd_m_axi_wstrb   [0*SD_AXI_SW +: 1*SD_AXI_SW] ),
    .io_ddrMasters_1_ar_payload_addr    ( sd_m_axi_araddr  [0*SD_AXI_AW +: 1*SD_AXI_AW] ),
    .io_ddrMasters_1_r_payload_data     ( sd_m_axi_rdata   [0*SD_AXI_DW +: 1*SD_AXI_DW] ),
    .io_ddrMasters_1_ar_payload_len     ( sd_m_axi_arlen   [0*8      +: 1*8]),
    .io_ddrMasters_1_ar_payload_size    ( sd_m_axi_arsize  [0*3      +: 1*3]),
    .io_ddrMasters_1_ar_payload_burst   ( sd_m_axi_arburst [0*2      +: 1*2]),
    .io_ddrMasters_1_ar_payload_cache   ( sd_m_axi_arcache [0*4      +: 1*4]),
    .io_ddrMasters_1_r_payload_resp     ( sd_m_axi_rresp   [0*2      +: 1*2]),
    .io_ddrMasters_1_b_payload_resp     ( sd_m_axi_bresp   [0*2      +: 1*2]),
    .io_ddrMasters_1_aw_payload_id      ( 'hE0 ),
    .io_ddrMasters_1_ar_payload_id      ( 'hE1 ),
    .io_ddrMasters_1_b_payload_id       (  ),
    .io_ddrMasters_1_r_payload_id       (  ),
    .io_ddrMasters_1_ar_payload_region  (  ),
    .io_ddrMasters_1_ar_payload_qos     (  ),
    .io_ddrMasters_1_ar_payload_prot    (  ),
    .io_ddrMasters_1_aw_payload_region  (  ),
    .io_ddrMasters_1_aw_payload_qos     (  ),
    .io_ddrMasters_1_aw_payload_prot    (  ),
    .io_ddrMasters_1_w_valid            ( sd_m_axi_wvalid  ),
    .io_ddrMasters_1_w_ready            ( sd_m_axi_wready  ),
    .io_ddrMasters_1_w_payload_last     ( sd_m_axi_wlast   ),
    .io_ddrMasters_1_b_valid            ( sd_m_axi_bvalid  ),
    .io_ddrMasters_1_b_ready            ( sd_m_axi_bready  ),
    .io_ddrMasters_1_ar_valid           ( sd_m_axi_arvalid ),
    .io_ddrMasters_1_ar_ready           ( sd_m_axi_arready ),
    .io_ddrMasters_1_ar_payload_lock    ( sd_m_axi_arlock  ),
    .io_ddrMasters_1_r_valid            ( sd_m_axi_rvalid  ),
    .io_ddrMasters_1_r_ready            ( sd_m_axi_rready  ),
    .io_ddrMasters_1_r_payload_last     ( sd_m_axi_rlast   ),
    .io_ddrMasters_1_clk                ( io_peripheralClk ),
    .io_ddrMasters_1_reset              (  ),
`else
    .io_ddrMasters_1_clk                ( io_peripheralClk ),
    .io_ddrMasters_1_reset              (  ),
`endif
    //AXI4 Slave Write Address Channel
    .axiA_awready                       ( w_axiA_awready   ),   
    .axiA_awlen                         ( w_axiA_awlen     ),      
    .axiA_awsize                        ( w_axiA_awsize    ),      
    .axiA_awlock                        ( w_axiA_awlock    ),      
    .axiA_awqos                         ( w_axiA_awqos     ),      
    .axiA_awprot                        ( w_axiA_awprot    ),      
    .axiA_awcache                       ( w_axiA_awcache   ),      
    .axiA_awburst                       ( w_axiA_awburst   ),
    .axiA_awaddr                        ( w_axiA_awaddr    ),   
    .axiA_awid                          ( w_axiA_awid      ),   
    .axiA_awregion                      ( w_axiA_awregion  ),
    .axiA_awvalid                       ( w_axiA_awvalid   ),  
    .axiA_arburst                       ( w_axiA_arburst   ),
    .axiA_arcache                       ( w_axiA_arcache   ),
    .axiA_arsize                        ( w_axiA_arsize    ),
    .axiA_arregion                      ( w_axiA_arregion  ),
    .axiA_arready                       ( w_axiA_arready   ),  
    .axiA_arqos                         ( w_axiA_arqos     ),
    .axiA_arprot                        ( w_axiA_arprot    ),
    .axiA_arlock                        ( w_axiA_arlock    ),
    .axiA_arlen                         ( w_axiA_arlen     ),
    .axiA_arid                          ( w_axiA_arid      ),   
    .axiA_arvalid                       ( w_axiA_arvalid   ),  
    .axiA_araddr                        ( w_axiA_araddr    ),   
    .axiA_rlast                         ( w_axiA_rlast     ),
    .axiA_rvalid                        ( w_axiA_rvalid    ),     
    .axiA_rready                        ( w_axiA_rready    ),     
    .axiA_rdata                         ( w_axiA_rdata     ),     
    .axiA_rid                           ( w_axiA_rid       ),     
    .axiA_rresp                         ( w_axiA_rresp     ),     
    .axiA_wvalid                        ( w_axiA_wvalid    ),     
    .axiA_wready                        ( w_axiA_wready    ),     
    .axiA_wdata                         ( w_axiA_wdata     ),     
    .axiA_wstrb                         ( w_axiA_wstrb     ),     
    .axiA_wlast                         ( w_axiA_wlast     ),
    .axiA_bvalid                        ( w_axiA_bvalid    ),     
    .axiA_bready                        ( w_axiA_bready    ),     
    .axiA_bid                           ( w_axiA_bid       ),     
    .axiA_bresp                         ( w_axiA_bresp     ),     
    .axiAInterrupt                      ( w_axiAInterrupt  ),

//GPIO_0 - Connecting to 1 switch and 3 LEDs
    .system_gpio_0_io_read              ( system_gpio_0_io_read        ),
    .system_gpio_0_io_write             ( system_gpio_0_io_write       ),
    .system_gpio_0_io_writeEnable       ( system_gpio_0_io_writeEnable ),

//I2C_1 - Connecting to sensor
    .system_i2c_1_io_sda_write          ( o_sensor_sda ),
    .system_i2c_1_io_sda_read           ( i_sensor_sda ),
    .system_i2c_1_io_scl_write          ( o_sensor_scl ),
    .system_i2c_1_io_scl_read           ( i_sensor_scl ),

//SPI_0 - Connecting to SPI Flash to load application from flash to DDR 
    .system_spi_0_io_sclk_write         ( system_spi_0_io_sclk_write         ),
    .system_spi_0_io_data_0_writeEnable ( system_spi_0_io_data_0_writeEnable ),
    .system_spi_0_io_data_0_read        ( system_spi_0_io_data_0_read        ),
    .system_spi_0_io_data_0_write       ( system_spi_0_io_data_0_write       ),
    .system_spi_0_io_data_1_writeEnable ( system_spi_0_io_data_1_writeEnable ),
    .system_spi_0_io_data_1_read        ( system_spi_0_io_data_1_read        ),
    .system_spi_0_io_data_1_write       ( system_spi_0_io_data_1_write       ),
    .system_spi_0_io_ss                 ( system_spi_0_io_ss                 ),
    .system_spi_0_io_data_2_writeEnable ( ),
    .system_spi_0_io_data_2_read        ( ),
    .system_spi_0_io_data_2_write       ( ),
    .system_spi_0_io_data_3_writeEnable ( ),
    .system_spi_0_io_data_3_read        ( ),
    .system_spi_0_io_data_3_write       ( ),


`ifdef SOFTTAP
    .io_jtag_tck                        ( softtap_jtag_tck   ),
    .io_jtag_tdi                        ( softtap_jtag_tdi   ),
    .io_jtag_tdo                        ( softtap_jtag_tdo   ),
    .io_jtag_tms                        ( softtap_jtag_tms   )

`else //Hard Tap 
    .jtagCtrl_tck                       ( jtag_inst1_TCK     ),
    .jtagCtrl_tdi                       ( jtag_inst1_TDI     ),
    .jtagCtrl_tdo                       ( jtag_inst1_TDO     ),
    .jtagCtrl_enable                    ( jtag_inst1_SEL     ),
    .jtagCtrl_capture                   ( jtag_inst1_CAPTURE ),
    .jtagCtrl_shift                     ( jtag_inst1_SHIFT   ),
    .jtagCtrl_update                    ( jtag_inst1_UPDATE  ),
    .jtagCtrl_reset                     ( jtag_inst1_RESET   )
`endif 

);

/*********************************************End of Module ********************************************/

endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2023 Efinix Inc. All rights reserved.
//
// This   document  contains  proprietary information  which   is
// protected by  copyright. All rights  are reserved.  This notice
// refers to original work by Efinix, Inc. which may be derivitive
// of other work distributed under license of the authors.  In the
// case of derivative work, nothing in this notice overrides the
// original author's license agreement.  Where applicable, the 
// original license agreement is included in it's original 
// unmodified form immediately below this header.
//
// WARRANTY DISCLAIMER.  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED ?AS IS? AND 
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH 
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES, 
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF 
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR 
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED 
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.
//
// LIMITATION OF LIABILITY.  
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY 
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT 
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY 
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT, 
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY 
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR 
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN 
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER 
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR 
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT 
//     APPLY TO LICENSEE.
//
/////////////////////////////////////////////////////////////////////////////
