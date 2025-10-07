//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : axi_interconnect.v
// Version        : 1.1 
// Date Created   : 2024-01-09 15:55:29 
// Last Modified  : 2025-02-28 15:04:52
// Abstract       : ---  
//  
//Copyright (c) 2020-2024 Elitestek,Inc. All Rights Reserved.
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//1.1 Add enable switch,configure whether to open the data buffer for each channel on the S side;
//    Add enable switch,configure whether to open reg output on M side.
//***************************************************************/

`timescale 1ns / 1ns

module axi_interconnect_v1_1#(
    parameter                       S_COUNT                 = 3,          // Number of slave interfaces
    parameter                       S_BUFFER_EN             = 3'b000,     // Buffer enable for each slave channel (bit width must match S_COUNT)
    parameter                       AXI_AW                  = 32,         // Address width for AXI
    parameter                       AXI_DW                  = 64,         // Data width for AXI
    parameter                       FAMILY                  = "TITANIUM", // FPGA family
    parameter                       RD_QUEUE_FIFO_RAM_STYLE = "block_ram",// RAM style for read queue FIFO
    parameter                       RD_QUEUE_FIFO_DEPTH     = 512,        // Depth of read queue FIFO
    parameter                       S_AXI_CMD_REG_EN        = 0,          // Enable command register for slave AXI
    parameter                       M_AXI_REG_EN            = 1           // Enable register for master AXI (must be set to 1 for LPDDR4 hardcore controller)
)
(
//Global Signals
input                           clk,
input                           rstn,

//Slave AXI4 Bus Interface
input           [S_COUNT*1-1:0] s_axi_awvalid,
output  wire    [S_COUNT*1-1:0] s_axi_awready,
input           [S_COUNT*AXI_AW-1:0]
                                s_axi_awaddr,
input           [S_COUNT*8-1:0] s_axi_awlen,
input           [S_COUNT*1-1:0] s_axi_wvalid,
output  wire    [S_COUNT*1-1:0] s_axi_wready,

input           [S_COUNT*AXI_DW-1:0] 
                                s_axi_wdata,
input           [S_COUNT*AXI_DW/8-1:0] 
                                s_axi_wstrb,
input           [S_COUNT*1-1:0] s_axi_wlast,
output  wire    [S_COUNT*1-1:0] s_axi_bvalid,
input           [S_COUNT*1-1:0] s_axi_bready,
output  wire    [S_COUNT*2-1:0] s_axi_bresp,

input           [S_COUNT*1-1:0] s_axi_arvalid,
output  wire    [S_COUNT*1-1:0] s_axi_arready,
input           [S_COUNT*AXI_AW-1:0]
                                s_axi_araddr,
input           [S_COUNT*8-1:0] s_axi_arlen,
output  wire    [S_COUNT*1-1:0] s_axi_rvalid,
input           [S_COUNT*1-1:0] s_axi_rready,
output          [S_COUNT*AXI_DW-1:0] 
                                s_axi_rdata,
output  wire    [S_COUNT*1-1:0] s_axi_rlast,
output  wire    [S_COUNT*2-1:0] s_axi_rresp,


//Master AXI4 Bus Interface
//--Master AXI4 Write
output  wire                    m_axi_awvalid,
input                           m_axi_awready,
output  wire    [AXI_AW-1:0]    m_axi_awaddr,
output  wire    [7:0]           m_axi_awlen,
output  wire    [7:0]           m_axi_awid,
output  wire    [2:0]           m_axi_awsize,
output  wire    [1:0]           m_axi_awburst,
output  wire    [0:0]           m_axi_awlock,
output  wire    [3:0]           m_axi_awcache,
output  wire    [2:0]           m_axi_awprot,

output  wire                    m_axi_wvalid,
input                           m_axi_wready,
output  wire    [AXI_DW-1:0]    m_axi_wdata,
output  wire    [AXI_DW/8-1:0]  m_axi_wstrb,
output  wire                    m_axi_wlast,
input                           m_axi_bvalid,
output  wire                    m_axi_bready,
input           [1:0]           m_axi_bresp,
//--Master AXI4 Read
output  wire                    m_axi_arvalid,
input                           m_axi_arready,
output  wire    [AXI_AW-1:0]    m_axi_araddr,
output  wire    [7:0]           m_axi_arlen,
output  wire    [7:0]           m_axi_arid,
output  wire    [2:0]           m_axi_arsize,
output  wire    [1:0]           m_axi_arburst,
output  wire    [0:0]           m_axi_arlock,
output  wire    [3:0]           m_axi_arcache,
output  wire    [2:0]           m_axi_arprot,
input                           m_axi_rvalid,
output  wire                    m_axi_rready,
input           [AXI_DW-1:0]    m_axi_rdata,
input                           m_axi_rlast,
input           [1:0]           m_axi_rresp

);

//Parameter Define
localparam                      S_COUNT_WTH = (S_COUNT > 1) ? $clog2(S_COUNT) : 1;  

//Register Define
 
//Wire Define
wire    [S_COUNT*1-1:0]         s_lb_arw;
wire    [S_COUNT*1-1:0]         s_lb_avalid;
wire    [S_COUNT*1-1:0]         s_lb_aready;
wire    [S_COUNT*AXI_AW-1:0]    s_lb_aaddr;
wire    [S_COUNT*8-1:0]         s_lb_alen;
wire    [S_COUNT*1-1:0]         s_lb_wvalid;
wire    [S_COUNT*1-1:0]         s_lb_wready;
wire    [S_COUNT*AXI_DW-1:0]    s_lb_wdata;
wire    [S_COUNT*AXI_DW/8-1:0]  s_lb_wstrb;
wire    [S_COUNT*1-1:0]         s_lb_wlast;
wire    [S_COUNT*1-1:0]         s_lb_bvalid;
wire    [S_COUNT*1-1:0]         s_lb_bready;
wire    [S_COUNT*2-1:0]         s_lb_bresp;
wire    [S_COUNT*1-1:0]         s_lb_rvalid;
wire    [S_COUNT*1-1:0]         s_lb_rready;
wire    [S_COUNT*AXI_DW-1:0]    s_lb_rdata;
wire    [S_COUNT*1-1:0]         s_lb_rlast;

wire                            m_lb_arw;
wire                            m_lb_avalid;
wire                            m_lb_aready;
wire    [AXI_AW-1:0]            m_lb_aaddr;
wire    [7:0]                   m_lb_alen;
wire                            m_lb_wvalid;
wire                            m_lb_wready;
wire    [AXI_DW-1:0]            m_lb_wdata;
wire    [AXI_DW/8-1:0]          m_lb_wstrb;
wire                            m_lb_wlast;
wire                            m_lb_bvalid;
wire                            m_lb_bready;
wire    [1:0]                   m_lb_bresp;
wire                            m_lb_rvalid;
wire                            m_lb_rready;
wire    [AXI_DW-1:0]            m_lb_rdata;
wire                            m_lb_rlast;

wire                            rdcmd_only;


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
frLBBIYU4VVh/buycJIoQ3GUjfUIXGZ1FRDCpH9uEHkUyv99twt4qrFc6ZQN0m5c
h/fXep8dZyP/zySWubLiE8gTZmjLXkRvV64B/DKqkxk4C7TGV+TGTmvMstJOpND6
LqUN3Ukd1NvkPUkfa5hSTXlnkTYrdM+fUR+9av+PJXg=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
l00svD1zmz8SxuG3D8Kl36JicHP4LRROsuVQHMdRFaL6PtIO9MBmtVWbGhd33VyC
t/PDZ1LI12KyT+kwVuKO9E0irsQiozQv9QLOT6T64hvYAW8saUOqXNqVxyEHgsFh
Go/gSlMgxoRwOR5COL4FjPFEsz/rMFW/7QHVepi6/fv+T4nXGFzUBCQdM9ITgzfH
PYpme7K+VSRTh70+DmPWFfFlLuGUniB+49nsZut9YB/yvGnR7pLclAvWQTikuOnM
LCjm+3i6p1MazjjKuA7DmWe/EF9L5BiCyjc1WJxyOVUA/ylTFuBg89tsd92tOsO2
DQtAG0CYwPNMfeG18lbt2Q==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
Lm9idSJypK/5UMgFtgKZJMbQo4pbrnSrdGtkvleOGenUZ8VAvC3wwwEk2M1Qaqm0
Pen+6Bq9bHPo9p+C0uASohB8xjZnlQqzMFvtt+sytPOo9eTt4Uj0wndst9mRJWtX
n2oF7RpcfQidmGGv/Seki1yFu2+7V9knhsg+mNivi1w=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
JBe582qnCjdA5vJTAG+O20hJoCwuzko12VpfjvvJGy+BU2lo7TNe8fHudcqjOVFx
yKGC2qWVJp52GXXDiA80ZZ2WVxZvICgHRwRj2oG7HPCaJkJ+L5p3UpRMpkMhI53f
4K/vdD1lxUYgih5Gdf9ITeVmCf5M9GHq0fbl8Yih/k12GbdbuJALQK+prXH/nkrG
WaYKsWsONY64bA95P4wldyDPmm+azGfTrbu7OZoOmqeo4koGPnyGOGnqz/sUR4Z0
rO/4f9SJCcOhUkzvMt4mLZfh00yi6y1H7j3FGPYdJqRBiaLOk45i2hcjevREV5eR
p8Q8mKfkZNot8/LJFOM7IA==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
EBTlb/Z7f3JfTwpj04aPuVEicqLPUKSw0vjH88Wf5UA2oxI+WwGHD70f8+/C4c+q
LwjCMxP3/lgLxDPmUHzLJ7h170KTgEROlVsURYeiUAzmH4Ko/EO3ZqjtcttFeJSH
w9yaKbGC+0dNsa7xrJFlnbvZBZqkB6ziLJhtJaDurI1TAxMlQgq6yXWCMAxQltoa
0uLYlimXz3EFE60bCN4ge9VKOQj4uoLKlrJ7/cP9dreuljw6jWnc6tuy5IrjcLVO
6N2QhyzTHf1CthWDZTYCJfNdIpwlKk4EusZ192Ubywhf1CNl8bL4WV7G7GaFtHlx
kj2ZANXE8/zmpzBGRHNvlA==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=11904)
`pragma protect data_block
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
`pragma protect end_protected
endmodule
