//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : system_reg_sdio
// Version        : 1.0 
// Date Created   : 2025-03-06 14:14:09 
// Last Modified  : 2026-02-25 14:09:39
// Abstract       : ---  
//  
//Copyright (c) 2020-2026 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`define IP_MODULE_NAME(name) name
`timescale 1 ns / 1 ps

//Encryption begin
`pragma protect begin_protected
`pragma protect version=1
`pragma protect encrypt_agent="ipecrypt"
`pragma protect encrypt_agent_info="http://ipencrypter.com Version: 20.0.8"
`pragma protect author="author-a"
`pragma protect author_info="author-a-details"

`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
UHdbkE4YcdqOnrc5qI9LdtkG8AOTHx+pQREaB+U24czuUxBUi77VPaxIMOxpLwKS
vFrgdthPAJ6BynbaDxrLfJrRnpxEjqLQeysn+6qjRprRnitMTosUbb7hEUUD1A1v
6HoA6SpO9s5QCfLqjrVfdAwguSZrorBntnrUP9V79JgENPLSBx8DY+dOt4PtOPqS
NnDz//71/kFUj6sCeO4OvCkh+WrXYsQbcBD2oYD5A/rX4wDD+BJsyzkYI1s/AXM0
AUNfvVA6zyA9weSYHUO6NEXy+VmLwCUT0CKWjdA7ryVg/A/xr9Of6jh7yqf7A2Ua
FWE2dYzLnCj7j+sM2NHy/w==
`pragma protect key_keyowner="Mentor Graphics Corporation"
`pragma protect key_keyname="MGC-VERIF-SIM-RSA-1"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
esTV9bkqjGlLG3Sw10gVECioPhTA7B2kqm0o80++Ng9TfmnrPKPHEXqxPtZ0DWoQ
Gd49bamuAKECxNxbRA7XSew2aAQhwEST5Kdg08sHmrfPcJn2Dgbk/26AUCW8iTeV
ncnYHiC+qhyx1WtLFjAhpJ5l4I77fmmcFAk0t214PdE=
`pragma protect data_method="aes256-cbc"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=7568)
`pragma protect data_block
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
`pragma protect end_protected

`undef IP_MODULE_NAME

