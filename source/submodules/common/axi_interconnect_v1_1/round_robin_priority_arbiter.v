//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : round_robin_priority_arbiter.v
// Version        : 1.0 
// Date Created   : 2024-01-06 11:35:19 
// Last Modified  : 2025-02-24 14:48:29
// Abstract       : ---  
//  
//Copyright (c) 2020-2024 Elitestek,Inc. All Rights Reserved.
//  
//***************************************************************/
//Modification History 
//1.initial 
//***************************************************************/
 
`timescale 1ns / 1ns
 
module round_robin_priority_arbiter#(
    parameter                       REQ_NUM = 3, 
    localparam                      REQ_NUM_WTH = (REQ_NUM > 1) ? $clog2(REQ_NUM) : 1 
)
(
input                           clk,
input                           rstn,

input           [REQ_NUM-1:0]   ch_req,

input                           grant_ready,
output  wire                    grant_valid,
output  reg     [REQ_NUM_WTH-1:0] 
                                grant_num
);
//Parameter Define
 
//Register Define
reg     [REQ_NUM-1:0]           last_state;
reg     [REQ_NUM-1:0]           one_hot_mem [REQ_NUM-1:0];
reg     [REQ_NUM_WTH-1:0]       grant_num_next;
reg                             grant_req;
reg     [REQ_NUM-1:0]           grant_r;
//Wire Define
wire    [2*REQ_NUM-1:0]         grant_ext;
wire    [REQ_NUM-1:0]           grant;


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
jRaUyEDtBZbGwD3PFSFF9D6Vz9sDy3S6BUJ6fbUTJPhz+RgtD7A9hUkux+f9wPzZ
R1MeLbEaPkYtWzsFxLAlrZpFuy+gkyHIqOFyMwj7lO2sOq/oeCbRAVr7mnDNNgS/
BU178IN+4K/36LA+TCwFZlrmtdc9XZgyyPtaOU3PIsE=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
O/hh6SXFU4lLm5W2dyU6UqZW36twW9gEds2S+W0/yjne7lAZDE+O+SXKGvNAFXF+
jgyxBvXCNrlaYYakwUDr4hqSVXOlLsjF+Jeg2o7NMl3YzH7KSoQ2Ej0M+iq5TzX+
slFm5WoA1vRQmDyGuBSyVw+MdLiZ33QD62283PjfyLBTL8vd9XBTtcSKiC8Uj9L2
xQwIadudn3AxCdkLY7tCnmomXRI+r0sMO70vwQbyTGHB97egLZ2WwS7QlY9TV2mS
iizLTaepfgiU8Imr5A8DRBHBZxPfQln016uSmw6rYoHVfZVX08o3MCLGUMLtv6Ej
lnrvwHB0S/fgDgTmr9FVVw==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
UrIcJ27gaTX/yPPWXZTSDXattPgOGTCP/sxFHOdIhvkJwfrETNAUQgrDWNyNldx/
rrZs4651hKGM3uIt8osBw/he9jfoDPiqexrTcNXwkApZZc3RecC7X3L/dkJZsgZr
bXptZhz/zfEQYQKZ98rn5dRy/LkYTKudVrVC//G3BNs=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
P6Vhs++vM8ynexD1YGgqvov37mCz1IxYhsz7sExbGxwmhp9KortDx6lM+kbNu+JU
0vb6jp0hcb1JJs31+9Xv3BIhjPUkZ50s0hrp2nWbuJPByvRpmbuz8I4gl2kBjKXw
+pGp8BUxghRopOFITF4H33NfalUN/o0aErny6LpTnuVWHAZPcggQT4r/tbqErAoV
ZtPbyOOavH8JPv4oVIqYNDOPqjbgrIIoUHxSLDE95alKkiwORD7drAX7sWUXA01a
UYMditLREqsf6oYfM/4UaQTgXByn/jYi1b1rO3e2reBAuufmLq9agU7xJIP/7lZE
NuwXuA4/fbxyRfVV+nv22w==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
RegAYwNFP80Ydn/pUDCTqR4ojIJsMLEyGle03BdIu9TvalmFQfU63J/B26TwNfAJ
OPk0uR2tw9EOu2bk0Fckx2zI3nSAR0m/IsRvshpAJmA4rVNwJ6rvyZ592wfIubjx
H9Gj2h2iG9rOrhaT3aQyIkNf9Mf5fWeA6SVDws3xqdRxizkSNIQ64C3cZa3/3xRg
GHnuzXFiSAaaOnidLuaNCdbN0t4Sln3anEzkO1mbATx5hKRpJRFFARh5ZSbOd2A6
Rkb5NhiHaj/Y0+J1/07YZUXJjQNzTA4zz57e6uJObvpCP91121ZH1i5jy4p7wcCv
CJlftLMHrOtrE+nfwdAQoQ==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=2000)
`pragma protect data_block
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
`pragma protect end_protected
endmodule
