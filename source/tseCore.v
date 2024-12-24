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
//        / /  ..    /   tseCore.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Core module controlling the TSEMAC
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// 1.0 Initial rev
// ***********************************************************************


`timescale 1 ns / 1 ns

module tseCore #(
    parameter ADDR_WIDTH = 10,
    parameter FAMILY     = "TITANIUM"
) (
    input                       io_peripheralClk,
    input                       io_peripheralReset,
    input                       io_tseClk,
    input                       pll_locked,
    output                      phy_sw_rst,
    output                      mac_ext_rst,
    output                      dma_rx_rst,
    output                      dma_tx_rst,
    input                       dma_tx_descriptorUpdate,
    output [1:0]                dma_interrupts,
    output  [2:0]               eth_speed,

    // MAC RGMII Interface
    output  [3:0]               rgmii_txd_HI,
    output  [3:0]               rgmii_txd_LO,
    output                      rgmii_tx_ctl_HI,
    output                      rgmii_tx_ctl_LO,
    output                      rgmii_txc_HI,
    output                      rgmii_txc_LO,
    input   [3:0]               rgmii_rxd_HI,
    input   [3:0]               rgmii_rxd_LO,
    input                       rgmii_rx_ctl_HI,
    input                       rgmii_rx_ctl_LO,
    input                       rgmii_rxc,
    // PHY MDIO Interface
    input                       phy_mdi,
    output                      phy_mdo,
    output                      phy_mdo_en,
    output                      phy_mdc,
    // AXI CSR
    input   [31:0]              s_axi_awaddr,   
    input                       s_axi_awvalid,  
    output                      s_axi_awready,  
    input   [31:0]              s_axi_wdata,  
    input   [3:0]               s_axi_wstrb,  
    output                      s_axi_wlast,
    input                       s_axi_wvalid,   
    output                      s_axi_wready,   
    output  [1:0]               s_axi_bresp,    
    output                      s_axi_bvalid,   
    input                       s_axi_bready,   
    input   [31:0]              s_axi_araddr,   
    input                       s_axi_arvalid,  
    output                      s_axi_arready,  
    output  [1:0]               s_axi_rresp,    
    output  [31:0]              s_axi_rdata,    
    output                      s_axi_rlast,
    output                      s_axi_rvalid,   
    input                       s_axi_rready,
    // MAC Stream
    input                       s_eth_tx_tvalid,
    output                      s_eth_tx_tready,
    input    [7:0]              s_eth_tx_tdata,
    input    [0:0]              s_eth_tx_tkeep,
    input    [3:0]              s_eth_tx_tdest,
    input                       s_eth_tx_tlast,
    output                      m_eth_rx_tvalid,
    input                       m_eth_rx_tready,
    output    [7:0]             m_eth_rx_tdata,
    output    [0:0]             m_eth_rx_tstrb,
    output                      m_eth_rx_tlast
);
////////////////////////////////////////////////////////////////////////////////////////////
localparam TSE_DEV  = 2;
localparam MAC      = 0;
localparam CMN      = 1;

//  Switch between MAC and CMN
wire [(TSE_DEV*32)-1:0]    gTSE_m_awaddr;
wire [(TSE_DEV*8)-1:0]	   gTSE_m_awlen;
wire [(TSE_DEV*3)-1:0]	   gTSE_m_awsize;
wire [(TSE_DEV*2)-1:0]     gTSE_m_awburst;
wire [(TSE_DEV*2)-1:0]     gTSE_m_awlock;
wire [TSE_DEV-1:0]         gTSE_m_awvalid;
wire [TSE_DEV-1:0]         gTSE_m_awready;
wire [(TSE_DEV*32)-1:0]    gTSE_m_wdata;
wire [(TSE_DEV*4)-1:0]     gTSE_m_wstrb;
wire [TSE_DEV-1:0]         gTSE_m_wvalid;
wire [TSE_DEV-1:0]         gTSE_m_wlast;
wire [TSE_DEV-1:0]         gTSE_m_wready;
wire [(TSE_DEV*2)-1:0]     gTSE_m_bresp;
wire [TSE_DEV-1:0]         gTSE_m_bvalid;
wire [TSE_DEV-1:0]         gTSE_m_bready;
wire [(TSE_DEV*32)-1:0]    gTSE_m_araddr;
wire [(TSE_DEV*8)-1:0]	   gTSE_m_arlen;
wire [(TSE_DEV*3)-1:0]	   gTSE_m_arsize;
wire [(TSE_DEV*2)-1:0]	   gTSE_m_arburst;
wire [(TSE_DEV*2)-1:0]     gTSE_m_arlock;
wire [TSE_DEV-1:0]         gTSE_m_arvalid;
wire [TSE_DEV-1:0]         gTSE_m_arready;
wire [(TSE_DEV*32)-1:0]    gTSE_m_rdata;
wire [(TSE_DEV*2)-1:0]     gTSE_m_rresp;
wire [TSE_DEV-1:0]         gTSE_m_rlast;
wire [TSE_DEV-1:0]         gTSE_m_rvalid;
wire [TSE_DEV-1:0]         gTSE_m_rready;

// clock reset
wire                       mac_sw_rst;
wire                       proto_reset;
wire                       mac_ext_srst;
wire                       rx_axis_clk;
wire                       tx_axis_clk;

// Stream control
wire                       m_eth_tx_tvalid;
wire                       m_eth_tx_tready;
wire    [7:0]              m_eth_tx_tdata;
wire    [3:0]              m_eth_tx_tdest;
wire                       m_eth_tx_tlast;
wire                       s_eth_rx_tvalid;
wire                       s_eth_rx_tready;
wire    [7:0]              s_eth_rx_tdata;
wire    [0:0]              s_eth_rx_tkeep;
wire    [3:0]              s_eth_rx_tdest;
wire                       s_eth_rx_tlast;

////////////////////////////////////////////////////////////////////////////////////////////
assign mac_ext_rst  = ~pll_locked;
assign rx_axis_clk  = io_tseClk;
assign tx_axis_clk  = io_tseClk;

reset_ctrl #(
    .NUM_RST        (2),
    .CYCLE          (2),
    .IN_RST_ACTIVE  (2'b11),
    .OUT_RST_ACTIVE (2'b11)
) inst_reset_ctrl (
    .i_arst ({mac_sw_rst, mac_ext_rst}),
    .i_clk  ({2{io_tseClk}}),
    .o_srst ({proto_reset, mac_ext_srst})
);

gTSE_1to2_switch u_gTSE_1to2_switch
(
    .rst_n          ( ~io_peripheralReset ),
    .clk            ( io_peripheralClk ),
    .s_axi_awvalid  ( s_axi_awvalid ),
    .s_axi_awready  ( s_axi_awready ),
    .s_axi_awaddr   ( {16'd0, s_axi_awaddr[15:0]} ),
    .s_axi_awlock   ( 2'b00 ),
    .s_axi_wready   ( s_axi_wready ),
    .s_axi_wvalid   ( s_axi_wvalid ),
    .s_axi_wstrb    ( s_axi_wstrb ),
    .s_axi_wdata    ( s_axi_wdata ),
    .s_axi_wlast    ( s_axi_wlast ),
    .s_axi_wid      ( 8'h00 ),
    .s_axi_bvalid   ( s_axi_bvalid ),
    .s_axi_bready   ( s_axi_bready ),
    .s_axi_bid      (  ),
    .s_axi_bresp    ( s_axi_bresp ),
    .s_axi_arvalid  ( s_axi_arvalid ),
    .s_axi_arready  ( s_axi_arready ),
    .s_axi_araddr   ( {16'd0, s_axi_araddr[15:0]} ),
    .s_axi_arlock   ( 2'b00 ),
    .s_axi_rvalid   ( s_axi_rvalid ),
    .s_axi_rready   ( s_axi_rready ),
    .s_axi_rid      (  ),
    .s_axi_rdata    ( s_axi_rdata ),
    .s_axi_rlast    (  ),
    .s_axi_rresp    ( s_axi_rresp ),
    .m_axi_awvalid  ( gTSE_m_awvalid ),
    .m_axi_awready  ( gTSE_m_awready ),
    .m_axi_awaddr   ( gTSE_m_awaddr ),
    .m_axi_awlock   (  ),
    .m_axi_wvalid   ( gTSE_m_wvalid ),
    .m_axi_wready   ( gTSE_m_wready ),
    .m_axi_wlast    ( gTSE_m_wlast ),
    .m_axi_wstrb    ( gTSE_m_wstrb ),
    .m_axi_wdata    ( gTSE_m_wdata ),
    .m_axi_bvalid   ( gTSE_m_bvalid ),
    .m_axi_bready   ( gTSE_m_bready ),
    .m_axi_bresp    ( gTSE_m_bresp ),
    .m_axi_bid      ( {TSE_DEV{8'h00}} ),
    .m_axi_arvalid  ( gTSE_m_arvalid ),
    .m_axi_araddr   ( gTSE_m_araddr ),
    .m_axi_arlock   (  ),
    .m_axi_arready  ( gTSE_m_arready ),
    .m_axi_rvalid   ( gTSE_m_rvalid ),
    .m_axi_rready   ( gTSE_m_rready ),
    .m_axi_rid      ( {TSE_DEV{8'h00}} ),
    .m_axi_rdata    ( gTSE_m_rdata ),
    .m_axi_rlast    ( gTSE_m_rlast ),
    .m_axi_rresp    ( gTSE_m_rresp )
);
assign s_axi_rlast  = 1'b1;
assign gTSE_m_wlast = 2'b11;
assign gTSE_m_rlast = 2'b11;

gTSE_streamControl #(
    .ADDR_WIDTH     (ADDR_WIDTH),
    .FAMILY         (FAMILY)
) u_gTSE_streamControl (
    .s_axi_aclk             ( io_peripheralClk ),
    .s_axi_aresetn          ( ~io_peripheralReset ),
    .s_axi_awaddr           ( gTSE_m_awaddr[CMN*32 +: ADDR_WIDTH] ),
    .s_axi_awvalid          ( gTSE_m_awvalid[CMN*1 +: 1] ),
    .s_axi_awready          ( gTSE_m_awready[CMN*1 +: 1] ),
    .s_axi_wdata            ( gTSE_m_wdata[CMN*32 +: 32] ),
    .s_axi_wvalid           ( gTSE_m_wvalid[CMN*1 +: 1] ),
    .s_axi_wready           ( gTSE_m_wready[CMN*1 +: 1] ),
    .s_axi_bvalid           ( gTSE_m_bvalid[CMN*1 +: 1] ),
    .s_axi_bready           ( gTSE_m_bready[CMN*1 +: 1 ]),
    .s_axi_bresp            ( gTSE_m_bresp[CMN*2 +: 2] ),
    .s_axi_araddr           ( gTSE_m_araddr[CMN*32 +: ADDR_WIDTH] ),
    .s_axi_arvalid          ( gTSE_m_arvalid[CMN*1 +: 1] ),
    .s_axi_arready          ( gTSE_m_arready[CMN*1 +: 1] ),
    .s_axi_rdata            ( gTSE_m_rdata[CMN*32 +: 32] ),
    .s_axi_rvalid           ( gTSE_m_rvalid[CMN*1 +: 1] ),
    .s_axi_rready           ( gTSE_m_rready[CMN*1 +: 1] ),
    .s_axi_rresp            ( gTSE_m_rresp[CMN*2 +: 2] ),
    .mac_ext_rst            ( mac_ext_rst || mac_sw_rst ),
    .s_eth_tx_clk           ( tx_axis_clk ),
    .s_eth_tx_tvalid        ( s_eth_tx_tvalid ),
    .s_eth_tx_tready        ( s_eth_tx_tready ),
    .s_eth_tx_tdata         ( s_eth_tx_tdata ),
    .s_eth_tx_tkeep         ( s_eth_tx_tkeep ),
    .s_eth_tx_tdest         ( s_eth_tx_tdest ),
    .s_eth_tx_tlast         ( s_eth_tx_tlast ),
    .m_eth_tx_tvalid        ( m_eth_tx_tvalid ),
    .m_eth_tx_tready        ( m_eth_tx_tready ),
    .m_eth_tx_tdata         ( m_eth_tx_tdata ),
    .m_eth_tx_tdest         ( m_eth_tx_tdest ),
    .m_eth_tx_tlast         ( m_eth_tx_tlast ),
    .mac_sw_rst             ( mac_sw_rst ),
    .phy_sw_rst             ( phy_sw_rst ),
    .dma_rx_rst             ( dma_rx_rst ),
    .dma_tx_rst             ( dma_tx_rst ),
    .error                  ( ),
    .dma_descriptor_update  (dma_tx_descriptorUpdate)
);

gTSE u_gTSE (
    .mac_reset              ( mac_ext_srst ),
    .proto_reset            ( mac_ext_srst || proto_reset ),
    .tx_mac_aclk            ( io_tseClk ),
    .rx_mac_aclk            (),
    .eth_speed              ( eth_speed  ),
    // MAC RX
    .rx_axis_clk            ( rgmii_rxc ),
    .rx_axis_mac_tdata      ( s_eth_rx_tdata ),
    .rx_axis_mac_tvalid     ( s_eth_rx_tvalid ),
    .rx_axis_mac_tstrb      ( s_eth_rx_tstrb ),
    .rx_axis_mac_tlast      ( s_eth_rx_tlast ),
    .rx_axis_mac_tuser      (  ),
    .rx_axis_mac_tready     ( s_eth_rx_tready ),
    // MAC TX
    .tx_axis_clk            ( tx_axis_clk ),
    .tx_axis_mac_tdata      ( m_eth_tx_tdata ),
    .tx_axis_mac_tvalid     ( m_eth_tx_tvalid ),
    .tx_axis_mac_tstrb      ( 1'b1 ),
    .tx_axis_mac_tlast      ( m_eth_tx_tlast ),
    .tx_axis_mac_tuser      ( 1'b0 ),
    .tx_axis_mac_tready     ( m_eth_tx_tready ),
    // AXI CSR
    .s_axi_aclk             ( io_peripheralClk ),
    .s_axi_awaddr           ( gTSE_m_awaddr[MAC*32 +: ADDR_WIDTH] ),
    .s_axi_awvalid          ( gTSE_m_awvalid[MAC*1 +:1 ] ),
    .s_axi_awready          ( gTSE_m_awready[MAC*1 +: 1] ),
    .s_axi_wdata            ( gTSE_m_wdata[MAC*32 +: 32] ),
    .s_axi_wvalid           ( gTSE_m_wvalid[MAC*1 +: 1] ),
    .s_axi_wready           ( gTSE_m_wready[MAC*1 +: 1] ),
    .s_axi_bresp            ( gTSE_m_bresp[MAC*2 +: 2] ),
    .s_axi_bvalid           ( gTSE_m_bvalid[MAC*1 +: 1] ),
    .s_axi_bready           ( gTSE_m_bready[MAC*1 +: 1] ),
    .s_axi_araddr           ( gTSE_m_araddr[MAC*32 +: ADDR_WIDTH] ),
    .s_axi_arvalid          ( gTSE_m_arvalid[MAC*1 +: 1] ),
    .s_axi_arready          ( gTSE_m_arready[MAC*1 +: 1] ),
    .s_axi_rresp            ( gTSE_m_rresp[MAC*2 +: 2] ),
    .s_axi_rdata            ( gTSE_m_rdata[MAC*32 +: 32] ),
    .s_axi_rvalid           ( gTSE_m_rvalid[MAC*1 +: 1] ),
    .s_axi_rready           ( gTSE_m_rready[MAC*1 +: 1] ),
    // RGMII
    .rgmii_txd_HI           ( rgmii_txd_HI ),
    .rgmii_txd_LO           ( rgmii_txd_LO ),
    .rgmii_tx_ctl_HI        ( rgmii_tx_ctl_HI ),
    .rgmii_tx_ctl_LO        ( rgmii_tx_ctl_LO ),
    .rgmii_txc_HI           ( rgmii_txc_HI ),
    .rgmii_txc_LO           ( rgmii_txc_LO ),
    .rgmii_rxd_HI           ( rgmii_rxd_HI ),
    .rgmii_rxd_LO           ( rgmii_rxd_LO ),
    .rgmii_rx_ctl_HI        ( rgmii_rx_ctl_HI ),
    .rgmii_rx_ctl_LO        ( rgmii_rx_ctl_LO ),
    .rgmii_rxc              ( rgmii_rxc ),
    // MDIO
    .Mdo                    ( phy_mdo ),
    .MdoEn                  ( phy_mdo_en ),
    .Mdi                    ( phy_mdi ),
    .Mdc                    ( phy_mdc )
);

assign m_eth_rx_tvalid  = s_eth_rx_tvalid;
assign m_eth_rx_tdata   = s_eth_rx_tdata;
assign m_eth_rx_tkeep   = 1'b1;
assign m_eth_rx_tlast   = s_eth_rx_tlast;
assign s_eth_rx_tready  = m_eth_rx_tready;

endmodule

module gTSE_streamControl#(
    parameter   ADDR_WIDTH = 10,
    parameter   NUM_REG    = 5,
    parameter   NUM_FRAME  = 10,
    parameter   MAC_RX_CLK_FREQ = 100,
    parameter   COALESCE_US = 4000   ,
    parameter   FAMILY      = "TITANIUM"
)
(

input                           s_axi_aclk,     //AXI Bus Clock.
input                           s_axi_aresetn,  //AXI Reset. Active-Low.
input        [ADDR_WIDTH-1:0]   s_axi_awaddr,   //Write Address. byte address.
input                           s_axi_awvalid,  //Write address valid.
output  reg                     s_axi_awready,  //Write address ready.
input        [31:0]             s_axi_wdata,    //Write data bus.
input                           s_axi_wvalid,   //Write valid.
output  reg                     s_axi_wready,   //Write ready.
output  wire [1:0]              s_axi_bresp,    //Write response.
output  reg                     s_axi_bvalid,   //Write response valid.
input                           s_axi_bready,   //Response ready.
input        [ADDR_WIDTH-1:0]   s_axi_araddr,   //Read address. byte address.
input                           s_axi_arvalid,  //Read address valid.
output  reg                     s_axi_arready,  //Read address ready.
output  wire [1:0]              s_axi_rresp,    //Read response.
output  reg  [31:0]             s_axi_rdata,    //Read data.
output  reg                     s_axi_rvalid,   //Read valid.
input                           s_axi_rready,   //Read ready.
input                           s_eth_tx_clk,
input                           s_eth_tx_tvalid,
output                          s_eth_tx_tready,
input    [7:0]                  s_eth_tx_tdata,
input    [0:0]                  s_eth_tx_tkeep,
input    [3:0]                  s_eth_tx_tdest,
input                           s_eth_tx_tlast,
output                          m_eth_tx_tvalid,
input                           m_eth_tx_tready,
output    [7:0]                 m_eth_tx_tdata,
output    [3:0]                 m_eth_tx_tdest,
output                          m_eth_tx_tlast,
input                           mac_ext_rst,
output  reg                     mac_sw_rst,    
output  reg                     phy_sw_rst,
output  reg                     dma_rx_rst,
output  reg                     dma_tx_rst,
output  reg                     error,
input                           dma_descriptor_update

);
// Parameter Define 
localparam DATA_DEPTH       = NUM_FRAME*1540;
localparam SIZE_DEPTH       = NUM_FRAME*5;
localparam DATA_DEPTH_WID   = $clog2(DATA_DEPTH);
localparam SIZE_DEPTH_WID   = $clog2(SIZE_DEPTH);
localparam COALESCE_CNT     = (COALESCE_US * MAC_RX_CLK_FREQ);
// Register Define
// Cfg Space Registers

// Other Registers
reg     [ADDR_WIDTH-3:0]   loc_waddr;
reg                        loc_waddr_vld;
reg     [31:0]             loc_wdata;
reg                        loc_wdata_vld;
reg     [ADDR_WIDTH-3:0]   loc_raddr;
reg                        loc_raddr_vld;
// Wire Define
wire                       loc_wrdy;
wire                       loc_rrdy;
wire                       w_eth_mac_rst;
wire [9:0]                 w_trans_rdcnt;
wire                       w_trans_rst_busy;
wire                       w_trans_full;
wire                       w_trans_empty;
wire [12:0]                w_txdata_rd_datacount;
wire                       w_tx_full;
wire                       w_tx_empty;
wire                       w_eth_tx_tlast;
wire                       w_eth_tx_tkeep;
wire [3:0]                 w_eth_tx_tdest;
wire [7:0]                 w_eth_tx_tdata;
reg                        r_eth_tx_tlast;
reg  [3:0]                 r_eth_tx_tdest;
reg  [7:0]                 r_eth_tx_tdata;
reg                        r_eth_tx_tvalid;
wire                       w_rd_en;
reg  [15:0]                write_cnt;
wire [15:0]                write_cnt_rd;
wire [15:0]                write_cnt_next;
reg  [15:0]                read_cnt;
reg  [1:0]                 rd_state;
reg  [1:0]                 next_rd_state;

/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/
//axi4-lite interface
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_waddr <= {ADDR_WIDTH-2{1'b0}};
	else if((s_axi_awvalid == 1'b1) && (s_axi_awready == 1'b1))
		loc_waddr <= s_axi_awaddr[2+:ADDR_WIDTH-2];
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_waddr_vld <= 1'b0;
	else if((s_axi_awvalid == 1'b1) && (s_axi_awready == 1'b1))
		loc_waddr_vld <= 1'b1;
    else if((loc_waddr_vld == 1'b1) && (loc_wdata_vld == 1'b1) && (loc_wrdy == 1'b1))
        loc_waddr_vld <= 1'b0;
end

assign loc_wrdy = 1'b1;

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_awready <= 1'b0;
    else if((s_axi_awvalid == 1'b1) && (s_axi_awready == 1'b1))
        s_axi_awready <= 1'b0;
	else if(loc_waddr_vld == 1'b0)
		s_axi_awready <= 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_wdata <= 32'h0;
	else if((s_axi_wvalid == 1'b1) && (s_axi_wready == 1'b1))
		loc_wdata <= s_axi_wdata;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_wdata_vld <= 1'b0;
	else if((s_axi_wvalid == 1'b1) && (s_axi_wready == 1'b1))
		loc_wdata_vld <= 1'b1;
    else if((loc_waddr_vld == 1'b1) && (loc_wdata_vld == 1'b1) && (loc_wrdy == 1'b1))
        loc_wdata_vld <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_wready <= 1'b0;
    else if((s_axi_wvalid == 1'b1) && (s_axi_wready == 1'b1))
        s_axi_wready <= 1'b0;
	else if(loc_wdata_vld == 1'b0)
		s_axi_wready <= 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_bvalid <= 1'b0;
	else if((loc_waddr_vld == 1'b1) && (loc_wdata_vld == 1'b1) && (loc_wrdy == 1'b1))
		s_axi_bvalid <= 1'b1;
    else if(s_axi_bready == 1'b1)
        s_axi_bvalid <= 1'b0;
end

assign s_axi_bresp = 2'h0;


always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_raddr <= {ADDR_WIDTH-2{1'b0}};
	else if((s_axi_arvalid == 1'b1) && (s_axi_arready == 1'b1))
		loc_raddr <= s_axi_araddr[2+:ADDR_WIDTH-2];
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_raddr_vld <= 1'b0;
	else if((s_axi_arvalid == 1'b1) && (s_axi_arready == 1'b1))
		loc_raddr_vld <= 1'b1;
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1))
        loc_raddr_vld <= 1'b0;
end

assign loc_rrdy = 1'b1;

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_arready <= 1'b0;
    else if((s_axi_arvalid == 1'b1) && (s_axi_arready == 1'b1))
        s_axi_arready <= 1'b0;
	else if(loc_raddr_vld == 1'b0)
		s_axi_arready <= 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_rdata <= 32'h0;
	else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1))
        begin
            case(loc_raddr)
            //Base Configuration Registers Field
            'h080:s_axi_rdata <= {31'd0, mac_sw_rst};
            'h081:s_axi_rdata <= {31'd0, phy_sw_rst};
            'h082:s_axi_rdata <= {31'd0, dma_rx_rst};
            'h083:s_axi_rdata <= {31'd0, dma_tx_rst};
            default:s_axi_rdata <= 32'hEEEE_1111;
            endcase
        end
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_rvalid <= 1'b0;
	else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1))
        s_axi_rvalid <= 1'b1;
    else if(s_axi_rready == 1'b1)
        s_axi_rvalid <= 1'b0;
end

assign s_axi_rresp = 2'h0;

/*----------------------------------------------------------------------------------*\
    Register Space -- Base Configuration Registers Field
\*----------------------------------------------------------------------------------*/

//loc_addr = 0x000; axi_addr = 0x000; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            mac_sw_rst <= 1'b0;
        end
	else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h080))
        begin
            mac_sw_rst <= loc_wdata[0];
        end
end

//loc_addr = 0x001; axi_addr = 0x004; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            phy_sw_rst <= 1'b0;
        end
	else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h081))
        begin
            phy_sw_rst <= loc_wdata[0];
        end
end

//loc_addr = 0x002; axi_addr = 0x008; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            dma_rx_rst <= 1'b0;
        end
	else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h082))
        begin
            dma_rx_rst <= loc_wdata[0];
        end
end


//loc_addr = 0x003; axi_addr = 0x00C; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            dma_tx_rst <= 1'b0;
        end
	else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h083))
        begin
            dma_tx_rst <= loc_wdata[0];
        end
end


/*----------------------------------------------------------------------------------*\
    Register Space -- The End
\*----------------------------------------------------------------------------------*/
reset #(
    .IN_RST_ACTIVE  ("HIGH"),
    .OUT_RST_ACTIVE ("HIGH"),
    .CYCLE          (2)
) inst_reset (
    .i_arst (mac_ext_rst),
    .i_clk  (s_eth_tx_clk),
    .o_srst (w_eth_mac_rst)

);

assign w_rd_en          = (next_rd_state == 1);
assign write_cnt_next   = (s_eth_tx_tkeep ? write_cnt + 1 : write_cnt);
assign s_eth_tx_tready  = !w_tx_full;
assign m_eth_tx_tvalid  = rd_state != 0;
assign m_eth_tx_tdata   = w_eth_tx_tdata;
assign m_eth_tx_tdest   = w_eth_tx_tdest;
assign m_eth_tx_tlast   = r_eth_tx_tlast;

always @(posedge s_eth_tx_clk or posedge w_eth_mac_rst) 
begin
    if (w_eth_mac_rst) 
    begin
        write_cnt <= 16'd0;
    end 
    else begin
        if (s_eth_tx_tvalid && s_eth_tx_tready) 
        begin
            if (s_eth_tx_tlast) 
            begin
                write_cnt <= 16'd0;
            end 
            else if (s_eth_tx_tkeep) 
            begin
                write_cnt <= write_cnt + 1'b1;
            end
        end
    end
end

always @(*) 
begin
    case (rd_state)
    2'b00: 
    begin
        if (!w_trans_empty) 
        begin
            next_rd_state = 2'b01;
        end else 
        begin
            next_rd_state = 2'b00;
        end
    end
    2'b01: 
    begin
        if (!m_eth_tx_tready) 
        begin
            next_rd_state = 2'b10;
        end else if (m_eth_tx_tlast) 
        begin
            next_rd_state = 2'b00;
        end else 
        begin
            next_rd_state = 2'b01;
        end
    end
    2'b10: 
    begin
        if (m_eth_tx_tvalid && m_eth_tx_tready) 
        begin
            if (m_eth_tx_tlast)
                next_rd_state = 2'b00;
            else
                next_rd_state = 2'b01;
        end else 
        begin
            next_rd_state = 2'b10;
        end
    end
    default: 
    begin
        next_rd_state = 2'b00;
    end
    endcase
end

always @(posedge s_eth_tx_clk or posedge w_eth_mac_rst) 
begin
    if (w_eth_mac_rst) 
    begin
        rd_state        = 2'b00;
        read_cnt        = 16'd0;
        r_eth_tx_tlast  <= 1'b0;
    end 
    else 
    begin
        rd_state <= next_rd_state;
        if (next_rd_state == 2'b00) 
        begin
            read_cnt       <= 16'd0;
            r_eth_tx_tlast <= 1'b0;
        end 
        else 
        begin
            if (w_rd_en) 
            begin
                read_cnt <= read_cnt + 1'b1;
                if ((read_cnt + 1'b1) == write_cnt_rd) 
                begin
                    r_eth_tx_tlast <= 1'b1;
                end
            end
        end
    end
end



common_efx_fifo_wrapper #(
   .FAMILY (FAMILY),       
   .SYNC_CLK (0),
   .SYNC_STAGE (2),
   .DATA_WIDTH (13),
   .MODE ("STANDARD"),
   .OUTPUT_REG (0),
   .PROG_FULL_ASSERT (510),
   .PROGRAMMABLE_FULL ("NONE"),
   .PROG_FULL_NEGATE (510),
   .PROGRAMMABLE_EMPTY ("NONE"),
   .PROG_EMPTY_ASSERT (2),
   .PROG_EMPTY_NEGATE (3),
   .OPTIONAL_FLAGS (0),
   .PIPELINE_REG (1),
   .DEPTH (4096),
   .ASYM_WIDTH_RATIO (4),
   .BYPASS_RESET_SYNC (0),
   .ENDIANESS (0),
   .RAM_STYLE ("block_ram"),
   .OVERFLOW_PROTECT (0),
   .UNDERFLOW_PROTECT (0)

   )u_standard_tx_fifo_trans (
    .a_rst_i        (w_eth_mac_rst),
    .wr_clk_i       (s_eth_tx_clk),
    .wr_en_i        (s_eth_tx_tvalid && s_eth_tx_tready && s_eth_tx_tkeep),
    .wdata          ({s_eth_tx_tkeep,s_eth_tx_tdest, s_eth_tx_tdata}),
    .rd_clk_i       (s_eth_tx_clk),
    .rd_en_i        (w_rd_en),
    .rdata          ({w_eth_tx_tkeep, w_eth_tx_tdest, w_eth_tx_tdata}),
    .full_o         (w_tx_full),
    .empty_o        (w_tx_empty),
    .wr_datacount_o (),
    .rd_datacount_o (w_txdata_rd_datacount),
    .rst_busy       (w_tx_size_busy)
);

common_efx_fifo_wrapper  #(
   .FAMILY (FAMILY),       
   .SYNC_CLK (0),
   .SYNC_STAGE (2),
   .DATA_WIDTH (16),
   .MODE ("FWFT"),
   .OUTPUT_REG (0),
   .PROG_FULL_ASSERT (510),
   .PROGRAMMABLE_FULL ("NONE"),
   .PROG_FULL_NEGATE (510),
   .PROGRAMMABLE_EMPTY ("NONE"),
   .PROG_EMPTY_ASSERT (2),
   .PROG_EMPTY_NEGATE (3),
   .OPTIONAL_FLAGS (0),
   .PIPELINE_REG (1),
   .DEPTH (512),
   .ASYM_WIDTH_RATIO (4),
   .BYPASS_RESET_SYNC (0),
   .ENDIANESS (0),
   .RAM_STYLE ("block_ram"),
   .OVERFLOW_PROTECT (0),
   .UNDERFLOW_PROTECT (0)

   )  u_fwft_tx_fifo_data (
    .a_rst_i        (w_eth_mac_rst),
    .wr_clk_i       (s_eth_tx_clk),
    .wr_en_i        (s_eth_tx_tvalid && s_eth_tx_tready && s_eth_tx_tlast),
    .wdata          (write_cnt_next),
    .rd_clk_i       (s_eth_tx_clk),
    .rd_en_i        (m_eth_tx_tvalid && m_eth_tx_tready && m_eth_tx_tlast),
    .rdata          (write_cnt_rd),
    .full_o         (w_trans_full),
    .empty_o        (w_trans_empty),
    .wr_datacount_o (),
    .rd_datacount_o (w_trans_rdcnt),
    .rst_busy       (w_trans_rst_busy)
);

always @(posedge s_eth_tx_clk or posedge w_eth_mac_rst) 
begin
    if (w_eth_mac_rst) 
    begin
        error <= 1'b0;
    end else 
    begin
        if ((w_trans_full && s_eth_tx_tvalid && s_eth_tx_tready && s_eth_tx_tlast ) || w_trans_rst_busy || (w_trans_empty && w_rd_en))
            error <= 1'b1;
    end
end

endmodule

////////////////////////////////////////////////////////////////////////////////////////////
module reset
#(
	parameter	IN_RST_ACTIVE	= "LOW",
	parameter	OUT_RST_ACTIVE	= "HIGH",
	parameter	CYCLE			= 1
)
(
	input	i_arst,
	input	i_clk,

	output	o_srst
);

(* async_reg = "true" *) reg [CYCLE-1:0]r_srst_1P;

genvar i;
generate
	if (IN_RST_ACTIVE == "LOW")
	begin
		if (OUT_RST_ACTIVE == "LOW")
		begin
			always@(negedge i_arst or posedge i_clk)
			begin
				if (~i_arst)
					r_srst_1P[0]	<= 1'b0;
				else
					r_srst_1P[0]	<= 1'b1;
			end

			for (i=0; i<CYCLE-1; i=i+1)
			begin
				always@(negedge i_arst or posedge i_clk)
				begin
					if (~i_arst)
						r_srst_1P[i+1]	<= 1'b0;
					else
						r_srst_1P[i+1]	<= r_srst_1P[i];
				end
			end
		end
		else
		begin
			always@(negedge i_arst or posedge i_clk)
			begin
				if (~i_arst)
					r_srst_1P[0]	<= 1'b1;
				else
					r_srst_1P[0]	<= 1'b0;
			end

			for (i=0; i<CYCLE-1; i=i+1)
			begin
				always@(negedge i_arst or posedge i_clk)
				begin
					if (~i_arst)
						r_srst_1P[i+1]	<= 1'b1;
					else
						r_srst_1P[i+1]	<= r_srst_1P[i];
				end
			end
		end
	end
	else
	begin
		if (OUT_RST_ACTIVE == "LOW")
		begin
			always@(posedge i_arst or posedge i_clk)
			begin
				if (i_arst)
					r_srst_1P[0]	<= 1'b0;
				else
					r_srst_1P[0]	<= 1'b1;
			end

			for (i=0; i<CYCLE-1; i=i+1)
			begin
				always@(posedge i_arst or posedge i_clk)
				begin
					if (i_arst)
						r_srst_1P[i+1]	<= 1'b0;
					else
						r_srst_1P[i+1]	<= r_srst_1P[i];
				end
			end
		end
		else
		begin
			always@(posedge i_arst or posedge i_clk)
			begin
				if (i_arst)
					r_srst_1P[0]	<= 1'b1;
				else
					r_srst_1P[0]	<= 1'b0;
			end

			for (i=0; i<CYCLE-1; i=i+1)
			begin
				always@(posedge i_arst or posedge i_clk)
				begin
					if (i_arst)
						r_srst_1P[i+1]	<= 1'b1;
					else
						r_srst_1P[i+1]	<= r_srst_1P[i];
				end
			end
		end
	end
endgenerate

assign	o_srst	= r_srst_1P[CYCLE-1];

endmodule

module reset_ctrl
#(
    parameter   NUM_RST         = 1,
    parameter   CYCLE           = 1,
    parameter   IN_RST_ACTIVE   = 1'b1,
    parameter   OUT_RST_ACTIVE  = 1'b1
)
(
    input   [NUM_RST-1:0]   i_arst,
    input   [NUM_RST-1:0]   i_clk,
    output  [NUM_RST-1:0]   o_srst
);

genvar i;
generate
    for (i=0; i<NUM_RST; i=i+1)
    begin
        if (IN_RST_ACTIVE & (1'b1 << i))
        begin
            if (OUT_RST_ACTIVE & (1'b1 << i))
            begin
                reset
                #(
                    .IN_RST_ACTIVE  ("HIGH"),
                    .OUT_RST_ACTIVE ("HIGH"),
                    .CYCLE          (CYCLE)
                )
                inst_sysclk_rstn
                (
                    .i_arst (i_arst[i]),
                    .i_clk  (i_clk[i]),
                    .o_srst (o_srst[i])
                );
            end
            else
            begin
                reset
                #(
                    .IN_RST_ACTIVE  ("HIGH"),
                    .OUT_RST_ACTIVE ("LOW"),
                    .CYCLE          (CYCLE)
                )
                inst_sysclk_rstn
                (
                    .i_arst (i_arst[i]),
                    .i_clk  (i_clk[i]),
                    .o_srst (o_srst[i])
                );
            end
        end
        else
        begin
            if (OUT_RST_ACTIVE & (1'b1 << i))
            begin
                reset
                #(
                    .IN_RST_ACTIVE  ("LOW"),
                    .OUT_RST_ACTIVE ("HIGH"),
                    .CYCLE          (CYCLE)
                )
                inst_sysclk_rstn
                (
                    .i_arst (i_arst[i]),
                    .i_clk  (i_clk[i]),
                    .o_srst (o_srst[i])
                );
            end
            else
            begin
                reset
                #(
                    .IN_RST_ACTIVE  ("LOW"),
                    .OUT_RST_ACTIVE ("LOW"),
                    .CYCLE          (CYCLE)
                )
                inst_sysclk_rstn
                (
                    .i_arst (i_arst[i]),
                    .i_clk  (i_clk[i]),
                    .o_srst (o_srst[i])
                );
            end
        end
    end
endgenerate

endmodule
////////////////////////////////////////////////////////////////////////////////////////////

