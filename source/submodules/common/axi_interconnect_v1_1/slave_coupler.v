//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : slave_coupler.v
// Version        : 1.0 
// Date Created   : 2024-05-11 09:30:46 
// Last Modified  : 2025-02-20 11:09:56
// Abstract       : ---  
//  
//Copyright (c) 2020-2024 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.initial 
//***************************************************************/

`timescale 1ns / 1ns

module slave_coupler#(
    parameter                       AXI_AW           = 32,
    parameter                       AXI_DW           = 32,
    parameter                       S_AXI_CMD_REG_EN = 1
    
)
(

//Global Signals
input                           clk,
input                           rstn,
//
input                           rdcmd_only,
//Slave AXI4 Bus Interface
input                           s_axi_awvalid,
output  wire                    s_axi_awready,
input           [AXI_AW-1:0]    s_axi_awaddr,
input           [7:0]           s_axi_awlen,
input                           s_axi_wvalid,
output  wire                    s_axi_wready,
input           [AXI_DW-1:0]    s_axi_wdata,
input           [AXI_DW/8-1:0]  s_axi_wstrb,
input                           s_axi_wlast,
output  wire                    s_axi_bvalid,
input                           s_axi_bready,
output  wire    [1:0]           s_axi_bresp,
input                           s_axi_arvalid,
output  wire                    s_axi_arready,
input           [AXI_AW-1:0]    s_axi_araddr,
input           [7:0]           s_axi_arlen,
output  wire                    s_axi_rvalid,
input                           s_axi_rready,
output  wire    [AXI_DW-1:0]    s_axi_rdata,
output  wire                    s_axi_rlast,
output  wire    [1:0]           s_axi_rresp,

//Master Local Bus Interface
//--Master Local Bus Write/Read Address 
output  reg                     m_lb_arw,
output  wire                    m_lb_avalid,
input                           m_lb_aready,
output  wire    [AXI_AW-1:0]    m_lb_aaddr,
output  wire    [7:0]           m_lb_alen,

//--Master Local Bus Write Data 
output  wire                    m_lb_wvalid,
input                           m_lb_wready,
output  wire    [AXI_DW-1:0]    m_lb_wdata,
output  wire    [AXI_DW/8-1:0]  m_lb_wstrb,
output  wire                    m_lb_wlast,

//--Master Local Bus Bresp 
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

//Register Define
reg                             last_arw;

//Wire Define



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
d8k0h6bh286zSW8UJFl1EZX32rDSry6G4THkKbRcaLBF+oriVeuqhvFO/CovNtO5
U4hEQ5pyYdHIgnVwJAtNRgTjmnrFGaXsghW+rQOa6z1rwXeUmcm5z2ssaNvx33np
7X8paDw4H5IJnA6hRs0sstviolQj7naRy953BEEvh5A=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
fT5ECN549XxyI1yW74rDBCmcCptYKaY//gK5E1ywbbhLOFHERMJIQISCqAQ+T4sJ
AVjGlWDm2Q1O2POv2Q1kUZKInWdQz6tBEJQqeHAPwYwWA+5zwVqUlOX6xALcyRDb
6ysUQwemknl0u9509r6mI/T5DxQpEdmSlaCHRtSP7b1xGOMaXfi6ViOSnH5rvMNk
IFfuwYSYE64UE/nZkTRyA6MeC2OeHbcf0g964YIBPv68bnPXYqopISwdde9ZTQmj
u5xc2JrAFLepboU6vil5Aneu0Q6neWlgM4YmKiGLQUFPVllTBL5Y2lgpztJhS2Qa
eL3pgd2IRpBO7uGxvMY78A==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
nbG45gK0d+UGgFCCxGNqsLJhE0olo5/WAUcDuyAa/KFRqluIowAf9D8NBqmG7iWD
PnJLRyVrKGYY0fSQHmPdALXE/RPXFiQeqfVQZPSxoazAhmBl+u40/cZh0/M9zjKN
rSK3YzBD3ySIhmlMY2ij2MaPoEYY53oYkL7xk+aslH0=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
pHWEs+52dDDHsVF1rgrpnS9yGDKJf0l3trgX1ksrSTiO5GtsYEObivQSXqvzrN0C
ISqQ7Xh5WfBngOAS6uptBZxmVdP5ej2Y4qe8ilNcMb+yd3MH4y/BxPqjvp2ydj9r
8GDptRlygW9gREkuOQWNtfdMLO+NDYXYPIkXBU/s4LCFJdqlWrdFURKbTPAdfBFy
sF+cX1+QghtvWEB0UXIOFVHjNApMP5sFHYEr19c4zzCqSElwkoc5/kH/ZQCm77nH
+XzZbR/JT5Z7/Tf8R46a4qyNYPxyogomY5NBSqvXcWqpvbuT0lOlYEnAo1kXSx0P
ranD+VG70ZAQ8IJOSANffQ==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
m+S/DOwqz4fiqe2QCVZaR3uWZ/JKvdCsgO2A+BzgbR4JHhx6QZfdshxKY4JP/XrM
BQH6HvNCBOfKbbHgiyNCZ25Sz0SsE90pvfkEju1KzZ8SGTOxu/8dGYysMQuGYw0V
WOVMgRylT3h83AYVGcAhXFzeWxQoCep+NIK80gDkD+Pwd70WUvrjNsE0FCkJiojA
4W9E37bbx7u34gGDSTqpPj7JqPcl03OzKRFux1nhe81cbKGn7NvErDTRngsGieMZ
9tvZl0hr5CBblQB2XvutpxQ051rCNKhGfVC+ne+ZtE7kZDKkZrgECsjblhCXTOw1
PRoTnK9/F7+WOYwNzGBk4g==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=8464)
`pragma protect data_block
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
3K9yAETshznBDhoUMSmU6g==
`pragma protect end_protected
endmodule
