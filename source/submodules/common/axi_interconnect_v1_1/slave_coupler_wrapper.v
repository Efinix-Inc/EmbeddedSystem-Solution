//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : slave_coupler_wrapper.v
// Version        : 1.0 
// Date Created   : 2025-02-18 17:45:54 
// Last Modified  : 2025-02-20 10:03:06
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1ns / 1ns

module slave_coupler_wrapper#(
    parameter                       AXI_AW           = 32,
    parameter                       AXI_DW           = 512,
    parameter                       S_AXI_CMD_REG_EN = 1,
    parameter                       S_BUFFER_EN      = 1
    
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
output  wire                    m_lb_arw,
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

//Wire Define
wire                            m_axi_awvalid;
wire                            m_axi_awready;
wire    [AXI_AW-1:0]            m_axi_awaddr;
wire    [7:0]                   m_axi_awlen;
wire                            m_axi_wvalid;
wire                            m_axi_wready;
wire    [AXI_DW-1:0]            m_axi_wdata;
wire    [AXI_DW/8-1:0]          m_axi_wstrb;
wire                            m_axi_wlast;
wire                            m_axi_bvalid;
wire                            m_axi_bready;
wire    [1:0]                   m_axi_bresp;
wire                            m_axi_arvalid;
wire                            m_axi_arready;
wire    [AXI_AW-1:0]            m_axi_araddr;
wire    [7:0]                   m_axi_arlen;
wire    [2:0]                   m_axi_arsize;
wire                            m_axi_rvalid;
wire                            m_axi_rready;
wire    [AXI_DW-1:0]            m_axi_rdata;
wire                            m_axi_rlast;
wire    [1:0]                   m_axi_rresp;


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
CM+J+uP5KOXxLbQ5odpuxVDBRHtez522jR5F+EqO0kUIBLUkqW/f/f2JsdcPenfj
/2mUeVE6Vkzq+NQoEyLFEpDsW5XTxnlOLyzF7PCm6+XJoSmUpc5sbwPO60sHgje7
j3gLtNgyQGCHGBrAy/wcpdnOgd5lWyVdUAtyB4Wwa0g=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
p3KWpbu/kHRPOCM7BBmxinUYVXXRZcfRwgsQd4Wsl/fq/WL9LTPlQO44Ek4PVsmc
5XpEwHWWxto3ggAhAJ7BkHt2eXjIcZz9SMm2Si7Xjt4Qzc5KgwU0V1DzhYDNcoTX
Gu4CfQ4j303cYq0HMEMmhmZTnazk6AZHAAy+4y4p2Qv2egqm+qobHENRj4VZeGXM
qnjK6qu0dOuf73JvGlZKJQgf/cMe2kX9Eg1hoHxHdJg7W3Hq3yvRZiy/xJAQQsA+
CUu+UIiSRMLwZY7YB4ZM7qIP0pZ4EJUb7lEH3O24kIbSW34cHXHbhspDnlH74PXS
6YWepXb+QI/l1agIRbsIZQ==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
S0LwJxrKpogptkPyiC8isA/5lK5qPOP6bBGiOGketWlhLZffAfEYjGcFXeuutrRH
U9E459LP8orLh/7IgYukx8zsWCkZJWYJlQ7Ah2ddRGWGfstIxhqqEt3FmKB7QkrX
FOQbtF6wohCA4vmTIYsAHWAlzM6x3DjPo3ua0esK6U0=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
hxmk8Cncb0f6X03g9q18NMKAuwgZpi9BQtFnlJ6xm7Pkqn9Uw5pB85a+e4mQjiV0
kuu8ChXfHwYJhaJUEwhk1+ec8qCptU3SHQ6ptDLL7TF2sbwMph0V3BjLyei9H8Ts
Mn+7Qtlu66WKPWHrFMkgrpqcrXbjy1wRikK047X19onIP1+HtdjKWBu2YfM67xKo
8wjyaahBwcfWhn+xSalrlFDPVPHenkEH6ak4XLxxZXwPzFaj0FTyLM00FPe+kCyg
bx1ARXL9KI4dwiNGOrCuaUgtpmlFT4PaTJG5uQaG6dXyg6rMhraNbnEhHcHRfKVY
Rsl0b29lYcwelJZ+XmTUUA==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
YBMs3ElTYG9FIWeii/khLr55PatsyW072XkiQq2lrWPCGcIMkDUfu3yYmcBmMpIV
ALuXQBpmo7Vbu5dXYjVcHGuscpLdKm3AyOgnzlIFNW/oaKb9OHlKgxYqYssDi2cZ
QI7LC2x+T7/vV7PbSNazrhuKFuz18o7OxprIt542+uRVTM34uCke+wYFHvOgPhGU
6+Ok8lGn8B7AFOYzVZKO5Y2Up1rms87BIF1ODz04uGLwIGi6bPX/s038AsCl+OfF
ipNGLKgqz1b9AYZSXSZZRrTLkyiIiti2v7mOogXiv3tDWoik8G2df3EQRpCXVEth
ZLmTJEeAJNd+tpS+kjqv0w==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=11056)
`pragma protect data_block
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
DmB3F4JvT1tNtuU05ahbAQ==
`pragma protect end_protected
endmodule
