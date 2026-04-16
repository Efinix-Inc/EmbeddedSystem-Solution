//////////////////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Top IP Module = axi4_id_seq
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***************************************************************************************
// Vesion  : 1.00
// Time    : Mon Apr 13 09:49:50 2026
// ***************************************************************************************

`timescale 1 ns / 1 ns
module sfifo_d3_wx#(
    parameter                       WTH = 16
)
(
input                           clk,
input                           rstn,
input           [WTH-1:0]       data,
input                           wrreq,
input                           rdreq,
output  wire    [WTH-1:0]       q,
output  wire    [1:0]           usedw,
output  wire                    full,
output  wire                    empty,
output  wire                    almost_full,
output  wire                    almost_empty
);
// Parameter Define 

// Register Define 
reg     [3*WTH-1:0]             sr_dout;
reg     [1:0]                   sr_cnt;

// Wire Define


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
PbFIzL/QubPvHr33MbGpvrsejaQZZwz+DxIr4Dg0NS6pwyTHxjBAcSHP5VbryTEb
P4Ktec/U+htAuaL9jSQQp+Jt6MbHvZkHU9UjQIsHE4MaJG4RbrAkFR1currvfDOT
zV5fhZHIv13OX3+7oUANGcd8jvgg+tbBIeD8a/2aiu8=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
0swnbP6O13WljjCzLnPEpnkVdFqrhambV6YLoLDSWOhJzzUZSiAkDesTrLwnVJF1
wsGvthPzxp+tT32QqZGwidTrN3FaOqkompgoah8I4kFFlYF8RkMofmGrGr9CznRI
vxHtXO5KESlNdalTKMuJBY/O59k4gCmhkxOAPJu056EbaPpUzKSdK2GDlJynXDMe
a2f2+kLfr5BlLyBBPhnDu5m/yhosn6W/4E9crEZE6DqRuRW/BPKIsIlT+tKjWgil
ZRmbrd4VeL5Q8yCm0iLCRvhRo8R0E383FyX0c/l3T4WJ58cYHCm9MD33x76zz8BM
i9eBKoMWIOjmnXk9zLnWKQ==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
m//v0WGpkL1rKvdRHHtNp/r5epbWgSHslRbLpq0aso/N0xZcdsXFYG+n4VB4z0v4
Vd5kLuogA1b11Fu1wfCmRQgm2S0pG28/hV4awEDlR4CUu6YtB0aJ1pXGeJsh/thF
Z3qrGKlOtQ+8lTXXeT/iFfc4CX5MArIt8WgEU16mRWo=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
HV5wKne0VKqjdCjbaGl32L1Cw6g36pU6WXwP+u3ncXGcd+ceszRYp0lPYzed0Fas
bJZWlom9cH5/KKXK+zJdIU4Yzoj++n031mfNAmvWmwZHBIa4BfM6szPCrzKSUfx+
EmkQD3A3ccYv58zC1KeoMbrPRIi+FrbKsu9UyT1bBgRbASH7Z3XY/0ZBOKKKhOD+
OUlfPr98+2Z4LErSFrWZv4dnJ2JPQqR1GCZcdpPfR4u8dw8VIZT5au/s2F83fQyj
u+wvr8PX/nzlPXQBG+wZHwqSu6gRezUTO75TMlwwanF1hakX+VZucjGBLxy6f7Bm
RK+Jb4b1PPpEhob/ogePrA==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
YNR9qIKubvFtLcvT8FtDNh56gu2nIgcCml6kILc+qbVbZ2g/JC/GckfAp9Uq9IlA
bkP1yg7RK/NNWAJ0SkFUf3TKyLeSbqKae+dUSBemRYJW57UES/eci0H0WYIrebdG
6V4dibg7pDbaroYT1IO85DgvO8RWCX66tKs1quVdumlSvxeKOlrsq2KUj7A+wjIw
/nJH+wI/7r0elNGFrIgKFCs8WLxYPLaX3uMO3i2pXpMMsZGY+JAmZxOuQRqi93Wh
xWUBZgpFUBAeE4em4U5oXa8OK2FFxXl6hvCCAmNmQ3XUC3/2EMw5WLa6Rtf0VaVB
232dnwTM5XFA4MOo5EVoFA==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=2384)
`pragma protect data_block
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
`pragma protect end_protected
endmodule
