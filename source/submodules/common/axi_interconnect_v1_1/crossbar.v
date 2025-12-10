//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : crossbar.v
// Version        : 1.0 
// Date Created   : 2024-01-08 15:57:49 
// Last Modified  : 2024-05-20 15:30:02
// Abstract       : ---  
//  
//Copyright (c) 2020-2024 Elitestek,Inc. All Rights Reserved.
//  
//***************************************************************/
//Modification History 
//1.initial 
//***************************************************************/

`timescale 1ns / 1ns
 
module crossbar#(
    parameter                       AXI_AW                  = 32, 
    parameter                       AXI_DW                  = 64, 
    parameter                       S_COUNT                 = 3, 
    parameter                       FAMILY                  = "TRION",
    parameter                       RD_QUEUE_FIFO_RAM_STYLE = "block_ram", 
    parameter                       RD_QUEUE_FIFO_DEPTH     = 512
)
(
                                
//Global Signals 
input                           clk,
input                           rstn,

//
output  reg                     rdcmd_only,
//Slave Local Bus Interface
//--Slave Local Bus Write/Read Address 
input           [S_COUNT*1-1:0] s_lb_arw,
input           [S_COUNT*1-1:0] s_lb_avalid,
output  wire    [S_COUNT*1-1:0] s_lb_aready,
input           [S_COUNT*AXI_AW-1:0]
                                s_lb_aaddr,
input           [S_COUNT*8-1:0] s_lb_alen,
//--Slave Local Bus Write Data 
input           [S_COUNT*1-1:0] s_lb_wvalid,
output  wire    [S_COUNT*1-1:0] s_lb_wready,
input           [S_COUNT*AXI_DW-1:0]     
                                s_lb_wdata,
input           [S_COUNT*AXI_DW/8-1:0]     
                                s_lb_wstrb,
input           [S_COUNT*1-1:0] s_lb_wlast,
//--Slave Local Bus Write Resp 
output  wire    [S_COUNT*1-1:0] s_lb_bvalid,
input           [S_COUNT*1-1:0] s_lb_bready,
output  wire    [S_COUNT*2-1:0] s_lb_bresp,
//--Slave Local Bus Read Data
output  wire    [S_COUNT*1-1:0] s_lb_rvalid,
input           [S_COUNT*1-1:0] s_lb_rready,
output  wire    [S_COUNT*AXI_DW-1:0]     
                                s_lb_rdata,
output  wire    [S_COUNT*1-1:0] s_lb_rlast,

//Master Local Bus Interface
//--Master Local Bus Write/Read Address 
output  reg                     m_lb_arw,
output  reg                     m_lb_avalid,
input                           m_lb_aready,
output  reg     [AXI_AW-1:0]    m_lb_aaddr,
output  reg     [7:0]           m_lb_alen,
//--Master Local Bus Write Data 
output  reg                     m_lb_wvalid,
input                           m_lb_wready,
output  reg     [AXI_DW-1:0]    m_lb_wdata,
output  reg     [AXI_DW/8-1:0]  m_lb_wstrb,
output  reg                     m_lb_wlast,
input                           m_lb_bvalid,
output  wire                    m_lb_bready,
input           [1:0]           m_lb_bresp,
//--Master Local Bus Read Data
input                           m_lb_rvalid,
output  wire                    m_lb_rready,
input           [AXI_DW-1:0]    m_lb_rdata,
input                           m_lb_rlast


);

//Parameter Define
localparam                      S_COUNT_WTH                = (S_COUNT > 1) ? $clog2(S_COUNT) : 1; 
localparam                      BRESP_QUEUE_FIFO_RAM_STYLE = RD_QUEUE_FIFO_RAM_STYLE;
localparam                      BRESP_QUEUE_FIFO_DEPTH     = RD_QUEUE_FIFO_DEPTH;

//Register Define
reg     [S_COUNT-1:0]           ch_req;
reg     [S_COUNT_WTH:0]         grant_num_r;
reg                             grant_ready;

//Wire Define
wire    [S_COUNT-1:0]           grant;
wire    [S_COUNT_WTH-1:0]       grant_num;
wire                            grant_valid;
//--read queue fifo
wire                            u1_wen;
wire    [S_COUNT_WTH-1:0]       u1_wdata;
wire                            u1_almfull;
wire                            u1_ren;
wire    [S_COUNT_WTH-1:0]       u1_rdata;
wire                            u1_empty;
wire    [S_COUNT_WTH-1:0]       rd_num;

//--b resp queue fifo
wire                            u2_wen;
wire    [S_COUNT_WTH-1:0]       u2_wdata;
wire                            u2_almfull;
wire                            u2_ren;
wire    [S_COUNT_WTH-1:0]       u2_rdata;
wire                            u2_empty;

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
ki6+0YlBI16E1CqS5DEXuNyhlacHLoxDK3U1vEPRxSdYB3mpQA7Lhy4rU8OXbsRk
O4Sa7zdBbu7fDHJtlBrwr9Exb8G7f9gbycOnpj/C6W7F2BKz8rTHTSwxGNC+UA00
Ya3wkOXf3m4GmS3iAixr0R7B48nBlmfe/N99a5achT8=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
SxZ4zQScOxdhx0+1SNohhDlaygVlam9UjUi8PNSSRCBfZlKjaDRTj9hcfRrljGDJ
Is2CLDXtsnVElRoo4LKmgEFGB0ioUtQf10uOZ5FQG0AhMl2vH/ZluOrVjo26f1B9
nZSGjaATe+aN+deeD8VXbUD12AylqmxAOmGyGUddQa+duPfr1mmweoqCf/w4eNDH
Gi+mB9N58cxLFk4xXcevlAiusDuagVzMFDTuhJOqwdduq+RomSv92spB5JbnKlje
MPZX43wmWoW/B+s2nLoAhDSOrpaKraWA348bZQW+CjUWyCpEko4wXGSRIEWO7Dd1
smVPSWq4yZAxBK2zn6HxdQ==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
mMWlhbz/57hSNxrWvTGtAsjtGdDUvcUoWZOfA6khJA+s/nVKeGJiKfXCEd6Uocjs
MEBlHnHo4GKXzbjh8F6mio1bUvOucOQCyW+FyWM/RRbFUlvKpp41i4WdgS0EfN/g
91iDhbMvwYtHW5tNMbfBB5Qj0RYFuWJZGupW/7w4qDw=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
BYx7KpWRaKBiDq3VFS2ZVTVhkmpLZIuDwrKdWhm8bvbJQTLJz1rIeRzibJ9QIDXo
ORviiV6sTdPS8zK04fMBMT3+rz3DHpn36EoBnoYIdBj2dyokFdXXNq26Mum65Zur
PHqcgdJ73eVPMWlr4kaM+U1wVx+F0U1bpJBE1acAwroR/bQVJ2rpiyaMXiUMgYBi
oOV2WtohhU4HPX49l0oUpGDDPyS/g0EdpVzouLrYjrn39Cncf7TTzz6GaZW6Yj0M
S6Sr+No/7geATrw0s0TT9sUXNwYYvAMrtsJEo4NREQuo4Mdnb9/sj0zQBP6BSMlY
8P1qBRei27uTDawtyyW2QA==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
B//9MUR/LWD4bhy6zEPk6AVsonLFHAIhsOLbDT5tMFdpOvCUVsTsUMJ8bC5lVURG
gFjimkltnFSWxqScOM+bS589yZsVT7eV8qDtjzT46YQge1pmAP2kla0f2uYLYxVT
IG0F4m99P+vl42jEbTEztrUDJ5wTjBbYF0LoDogWLDqRIGRw0zIdmosHtTu6oxae
irm+QTEnRda/RRmURq+IJwz0UNhkLiYnh+vV3CZ7vX6hqm2hnsdICNvC9Vciqumz
O/HtDPj982DXVhb0/PcHi6zhteAd8ycyjyubg8axehvIRfEqNwekEKSCAoPyrOBI
ivjcfk+W6+CH679H7EgngQ==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=10960)
`pragma protect data_block
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
/6fKTVzJCgdlKhAqnk+aFA==
`pragma protect end_protected
endmodule
