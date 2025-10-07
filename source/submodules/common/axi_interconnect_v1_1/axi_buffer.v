//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : axi_buffer.v
// Version        : 1.0 
// Date Created   : 2025-02-18 16:16:05 
// Last Modified  : 2025-02-27 11:19:56
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1ns / 1ns

module axi_buffer#(
    parameter                       AXI_AW              = 32,         // AXI address width
    parameter                       AXI_DW              = 32,         // AXI data width
    parameter                       FAMILY              = "TITANIUM", // FPGA family
    parameter                       CMD_FIFO_DEPTH      = 16,         // Command FIFO depth
    parameter                       CMD_FIFO_RAM_STYLE  = "block",    // Command FIFO RAM style
    parameter                       DATA_FIFO_DEPTH     = 256,        // Data FIFO depth, minimum 256
    parameter                       DATA_FIFO_RAM_STYLE = "block"     // Data FIFO RAM style
)
(

//Global Signals
input                           clk,
input                           rstn,
//Slave AXI4 Bus Interface
input                           s_axi_awvalid,
output  reg                     s_axi_awready,
input           [AXI_AW-1:0]    s_axi_awaddr,
input           [7:0]           s_axi_awlen,
input                           s_axi_wvalid,
output  reg                     s_axi_wready,
input           [AXI_DW-1:0]    s_axi_wdata,
input           [AXI_DW/8-1:0]  s_axi_wstrb,
input                           s_axi_wlast,
output  wire                    s_axi_bvalid,
input                           s_axi_bready,
output  wire    [1:0]           s_axi_bresp,
input                           s_axi_arvalid,
output  reg                     s_axi_arready,
input           [AXI_AW-1:0]    s_axi_araddr,
input           [7:0]           s_axi_arlen,
output  reg                     s_axi_rvalid,
input                           s_axi_rready,
output  reg     [AXI_DW-1:0]    s_axi_rdata,
output  reg                     s_axi_rlast,
output  wire    [1:0]           s_axi_rresp,
//Master AXI4 Bus Interface
//--Master AXI4 Write
output  reg                     m_axi_awvalid,
input                           m_axi_awready,
output  reg     [AXI_AW-1:0]    m_axi_awaddr,
output  reg     [7:0]           m_axi_awlen,
output  reg                     m_axi_wvalid,
input                           m_axi_wready,
output  reg     [AXI_DW-1:0]    m_axi_wdata,
output  reg     [AXI_DW/8-1:0]  m_axi_wstrb,
output  reg                     m_axi_wlast,
input                           m_axi_bvalid,
output  wire                    m_axi_bready,
input           [1:0]           m_axi_bresp,
//--Master AXI4 Read
output  reg                     m_axi_arvalid,
input                           m_axi_arready,
output  reg     [AXI_AW-1:0]    m_axi_araddr,
output  reg     [7:0]           m_axi_arlen,
input                           m_axi_rvalid,
output  reg                     m_axi_rready,
input           [AXI_DW-1:0]    m_axi_rdata,
input                           m_axi_rlast,
input           [1:0]           m_axi_rresp                         
);

//Parameter Define
localparam                      DATA_FIFO_DEPTH_WTH = $clog2(DATA_FIFO_DEPTH);
localparam                      AXI_SW              = AXI_DW/8;

//Register Define

//Wire Define
//--u1: Write CMD FIFO
wire                            u1_wen;
wire    [AXI_AW+8-1:0]          u1_wdata;
wire                            u1_almfull;
wire                            u1_ren;
wire    [AXI_AW+8-1:0]          u1_rdata;
wire                            u1_empty;
wire                            u1_rst_busy;
//--u2: Write DATA FIFO
wire                            u2_wen;
wire    [1+AXI_SW+AXI_DW-1:0]   u2_wdata;
wire    [DATA_FIFO_DEPTH_WTH:0] u2_wr_datacnt;
wire                            u2_almfull;
wire                            u2_ren;
wire    [1+AXI_SW+AXI_DW-1:0]   u2_rdata;
wire                            u2_empty;
wire                            u2_rst_busy;
wire    [8:0]                   cur_datacnt;
wire                            cur_data_wait;
//--u4: Read CMD FIFO
wire                            u4_wen;
wire    [AXI_AW+8-1:0]          u4_wdata;
wire                            u4_almfull;
wire                            u4_ren;
wire    [AXI_AW+8-1:0]          u4_rdata;
wire                            u4_empty;
wire                            u4_rst_busy;
//--u5: Read DATA FIFO
wire                            u5_wen;
wire    [1+AXI_DW-1:0]          u5_wdata;
wire    [DATA_FIFO_DEPTH_WTH:0] u5_wr_datacnt;
wire                            u5_almfull;
wire                            u5_ren;
wire    [1+AXI_DW-1:0]          u5_rdata;
wire                            u5_empty;
wire                            u5_rst_busy;


`pragma protect begin_protected
`pragma protect version=1
`pragma protect encrypt_agent="ipecrypt"
`pragma protect encrypt_agent_info="http://ipencrypter.com Version: 20.0.8"
`pragma protect author="author-a"
`pragma protect author_info="author-a-details"
`pragma protect data_method="aes256-cbc"

`pragma protect key_keyowner="Mentor Graphics Corporation"
`pragma protect key_keyname="MGC-VERIF-SIM-RSA-1"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
WCIl5r0maA7CcpOm46vE/6tPLMid/VGfcQpnGFLbFDluQam6s/C4+WLjtAJ0XMkI
AKp1Q/CX89F2B6xYz5sJic+o15Htad0vbJMZss6rOvCNIClJxJelK7emU/yEJ8Sv
5AB0cRFvaWPpdSLIA2SB2qZFwBmN2czeHXL//JGyXxc=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
YtIuzCPTIoKiawjSBslO7kfHnupIv7NZDtioDTibje5/kyKXJVbmORUkZWiaXULJ
fmqAby8leeALrAOuCCnH6x7oacDLv29Y6j4VjH5jfIWK4ZIMqrJuktL62AmFrsvl
S8BEXlcG4VeCwgwrQCnKFuOmcHRHFZ9cWmnAJeq57MRH9BX0tPFEBsLTayKvI82f
Gp6FY74S3TIudeDfwHrTEMcPpx0boSzkhvN14tW43KfoKOfmEBSd5KKOYX7GQehW
iczYszWo4b9ClkjQYygPDcNkrmq9BeEswDgfewsLWDPbHhdRsSdRVWWCKstMOhyF
xHtDRFNDrXMEPx1gIgkegg==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
tralG5czPBSPs/H/XLTpjgiy9lvX8fDWQJZe6Yx4l2CHUFY3P+wJuSzqJv5XEYyZ
ORy4Z7fyycMxJ6F/LhuJ+2YV+vzQDUOeR3ITPX2pHweB6+Zy5EPRywzKirpIUW/g
jQq0E7N8XytHJVYzOZgLJQ0ZwTo+PD7dph75Kth9wSc=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
M/utK0sIbIF3OeH2PnGPr+U3rzOhWqRGUNKna6QtnYaIx0hVRuiakC3iiPZYL+WB
sXJjpL3I7VrLnXNoGFTbaRduO2v8cIHZz3Rarg0G5QxPkM9zYNuKeqrHHZrrzTO3
1o5ZgaF5AGbJRXJyRsBV46an49zM/k983ZQ3YNP416A/tCYSqd7T6kQjMRD1aahL
viiS5O+dqhv3A1DLYzBnaIQNngdvDEDA/mdu35V82zH12QH92Dtmy2xVhT6kZx/+
nHUmQ2/tu0fJSP5V9kMHwV4wSOIpAR+dhY25fdNLmdlY4AozPx/hwQMkWqz8Qy1g
DYZVazyi0XtpqsECaxGAdA==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
G9xiL0obDJCiMEICE5SvKcgnpCcz+gNi62JsocskeMxxizQNawkUiu3F4gExIZuU
ijDgRNug39VBn3E3BkdX0ZcK6/AHPhBUy39IklYnJhAtpjScjEwIvJxNBEc2kUMb
viss0oJTz3IR90qIer2Q+C3D6+YUbDYOMRTTjya6+Sd2fszL2WD/4485ZBkW2JU2
fdqfxDPck/Yc4LmukXzrofNTwGq51RyTpv2u0Vgx26x2hDGJOWYc3fOEgq89dkTa
JwEGTwjL9jVaPzkX8X0AhWA+5bZnm/SfyAPtGw6Iq6euzbfcpTvVRkwbGAWeVDMt
wOMWcKSiTEKxuhivXXko6g==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=17568)
`pragma protect data_block
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
`pragma protect end_protected
endmodule
