//////////////////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2026 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Top IP Module = master_coupler
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***************************************************************************************
// Vesion  : 1.00
// Time    : Mon Apr 13 09:49:50 2026
// ***************************************************************************************
`timescale 1ns / 1ns
 
module master_coupler#(
    parameter                       S_COUNT          = 3,
    parameter                       AXI_AW           = 32, 
    parameter                       AXI_DW           = 128, 
    parameter                       M_AXI_CMD_REG_EN = 0,
    parameter                       M_AXI_DAT_REG_EN = 1
)
(
//Global Signals
input                           clk,
input                           rstn,

//Slave Local Bus Interface
//--Slave Local Bus Write/Read Address 
input                           s_lb_arw,
input                           s_lb_avalid,
output  wire                    s_lb_aready,
input           [AXI_AW-1:0]    s_lb_aaddr,
input           [7:0]           s_lb_alen,
//--Slave Local Bus Write Data 
input                           s_lb_wvalid,
output  wire                    s_lb_wready,
input           [AXI_DW-1:0]    s_lb_wdata,
input           [AXI_DW/8-1:0]  s_lb_wstrb,
input                           s_lb_wlast,
output  wire                    s_lb_bvalid,
input                           s_lb_bready,
output  wire     [1:0]          s_lb_bresp,
//--Slave Local Bus Read Data
output  wire                    s_lb_rvalid,
input                           s_lb_rready,
output  wire    [AXI_DW-1:0]    s_lb_rdata,
output  wire                    s_lb_rlast,

//Master AXI4 Bus Interface
output  wire                    m_axi_awvalid,
input                           m_axi_awready,
output  wire    [AXI_AW-1:0]    m_axi_awaddr,
output  wire    [7:0]           m_axi_awlen,
output  wire    [7:0]           m_axi_awid,
output  wire    [2:0]           m_axi_awsize,
output  wire    [1:0]           m_axi_awburst,
output  wire    [1:0]           m_axi_awlock,
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
output  wire                    m_axi_arvalid,
input                           m_axi_arready,
output  wire    [AXI_AW-1:0]    m_axi_araddr,
output  wire    [7:0]           m_axi_arlen,
output  wire    [7:0]           m_axi_arid,
output  wire    [2:0]           m_axi_arsize,
output  wire    [1:0]           m_axi_arburst,
output  wire    [1:0]           m_axi_arlock,
output  wire    [3:0]           m_axi_arcache,
output  wire    [2:0]           m_axi_arprot,
input                           m_axi_rvalid,
output  wire                    m_axi_rready,
input           [AXI_DW-1:0]    m_axi_rdata,
input                           m_axi_rlast,
input           [1:0]           m_axi_rresp
);

//Parameter Define

//Register Define

//Wire Define
wire                            s_axi_awvalid;
wire                            s_axi_awready;
wire    [AXI_AW-1:0]            s_axi_awaddr;
wire    [7:0]                   s_axi_awlen;

wire                            s_axi_arvalid;
wire                            s_axi_arready;
wire    [AXI_AW-1:0]            s_axi_araddr;
wire    [7:0]                   s_axi_arlen;


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
dYZ6YmhTCosmtvg18aff68A9lR/ZIKRZl4Sh9SULpeYSGxYGKo445np1M0acyePj
HV/Eo0VOlO5DX6vJyTKEImQS33ZV5qkmkZW3BH9sKwH/4UIaWUBQOh5i/ROMEXks
TgVu+o4njLfSGv4+OECL6y9m6bEew7pKSUXilkjH85Q=
`pragma protect key_keyowner="Aldec"
`pragma protect key_method="rsa"
`pragma protect key_keyname="ALDEC15_001"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
Imz3hrp4ZBIN4AzH8LpmvCSaJGixvhbxSL1vxVvPU4FklkAf56bMGCAu+yYn7Thx
si+oaXpCAbm3NuwcOoiOTXOJNDePMlF2xiDKu6rjIWtqw3XVSTt/tmjb5gSkLjcL
+a0r7iVVqeM8GHhdUSMWesDX02nbtc5ysMVE+/GnHku3O6TqWpsx8/aAmfWmiOWi
6aBXTzdSUOykLxWJMaLrvoq86drwSV+GLxeYLEVdgs/7icK/M5yMCaorvLzeD6HG
Uc9DXIItx+giLeaJqHtrZyXhP3qZuGdu0LjjvBp9A1zE/pDVrFe5w6qWiuG5FcGt
5oHyi4nYTsb0ooyX4YNE9g==
`pragma protect key_keyowner="Synopsys"
`pragma protect key_method="rsa"
`pragma protect key_keyname="SNPS-VCS-RSA-2"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=128)
`pragma protect key_block
VrzySx323Vu7k0H1xvmAGOnGLVLKUqOoXWz8ipF5wLR2SnHlE3i4vwjaDV6NPkSK
Aa3M9orZYSdrSUppWa4mI/Jk262UBR7BdxMlLihlTDbQHaImiCRmjIUur+FIth1U
U7/3sMuqXS61JEl2FSl9NVYimCxcxnoM7kypMitn0qs=
`pragma protect key_keyowner="Cadence Design Systems."
`pragma protect key_method="rsa"
`pragma protect key_keyname="CDS_RSA_KEY_VER_1"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
HCNwLGNqPQt1awVpGra6pdVhaLm7dLYyVzFtDS88sS1n7m0YPnboA/jk1hSBoyVs
G1kIcTDzK19c34JhzeDKURlxFkJBM1MkIozUh3XKtY6GuFgN/2YhddIzhP9mkazo
A03wJUcr76n9j/ek5At8CRGuppKWrfZyyM92nHGZVz+x6elJEWD6eCheXD/mKmLd
Baj5TeFAMDODaGVfCKHTyLaq2JfemCihbYWf6pUX1E4LaVvTucggcIAvMv0iJDUt
fZtALkzpNnQ9FOFpDidkRIaoSoNyKMyWCTVY4An5oLLiijJJmt96SGFxXPpIfL+0
iDy2aWGxicfO3clmQIKzHA==
`pragma protect key_keyowner="Efinix Inc."
`pragma protect key_keyname="EFX_K01"
`pragma protect key_method="rsa"
`pragma protect encoding=(enctype="base64", line_length=64, bytes=256)
`pragma protect key_block
STq9HHpWzd/qeFjq60qUJQ3I2HBGnZ8QJ+rcA6eXs6xLe+7p6A8Cvf2TP5nYNRCu
KlXwkEYswSz5chaVq0Jo+ucqg9jEIipUd8BVH8uAY8Fu5CXGWL/NsIJjUZe0Gd+g
Uvq++ZN5fHJHPlZ73lLFHNLk+WUm0pWnXST36sUBm+UOmll1Na7+jVU2gkmn0m5y
Za9W2q6Ux/XQRRr4VL6FVjXeqrWvDI6wmTbBs2jCZ8XpbBdzBabXnsPtGgL8yeNt
FHnxRu9aFgTygGKOVu8Yo5jCwXHnsy1eKH1M0+KCubySdAO/pdwb86Ewr4covJsZ
UN51vw+vYbSBqdqCj53E2w==
`pragma protect encoding=(enctype="base64", line_length=64, bytes=15904)
`pragma protect data_block
+bvOUJHMdZ6PzU7uJAIyIFf72GEL9Vo5yRpP1EixowXU/sGrE/Ymi1Ffg4D9blkI
3qBaIbDtLahVHNiLMCg16n9LIvPaHEiiDC9j5O5e8Cd+dvmO8UpMAmAg/NNhzfoO
Jm60/nGj4lRf+V5wmlu/bIeC6b4alWCx89EG7ogKQLDby5YxpWQh+gZ5FZF2W+om
GBH8Ei5J1lB8mwJJr5er/kT7H4jmIjohrBqNrVcit9CPOXCuFnKQfejY2Jm+mkKn
pEIYPV5Y0djnY6OO0N8Hk6mEJSYQ0jpv0Ki5IyXdnlxbC0/Qnj23XYclnVo825CR
b62k4af09jtJTQZ2DeYNNmNFEkpKgAzyBRJoi2p6BArEMP8Scvg1EKKsTmD6mz8S
N7NdvbX5ATcGxXwBDfJqFtdmHcx1+XPMPTdx08zSKwMMW/4z/OKocsTxhgTvrM5z
HpuNZBEGnWjBejofjURKL+Ld8G9deuxDmBTGKi0aXC+EGRUMPpOLhI2Q8D3ZBp1c
l8LebTZTKdzNQWGyI64+CT3o98tzUgTowmgE0ZTE6pwHIja2ydKFttSPle6GwfrD
TI1LlyaUFmNTCWI+w+HWPiP2zESapfqsUU0izuFOFZFZwT/nQ3/w2uVXjWTFyTV6
gAii1AOorLApY8p2C0rY1V4S5tK/sqr2dty7kO2MWrFkHWqbFLqSZ3rFcR3yUwQI
2R0aIycZEob9lU7GmtNWSkM+hFGczH1ciuko9TjTVDFUJsoyGCPqD43cLUxEuGMq
f6VGLTbNuKhkbF7u5bIMBdoQeWQq/ajDXyDebHFKsKZrnCoj1XxbBdG6LAQoQyLC
iEphfbhflY3if08EQdehSN57vaJhuXnHkrXlTInYXKqCl5DiZvFTaQ0Bdap1av59
B999tWJOkqOD/BAeGD1S1swq36k5BA+mqe3OpAvsjLMZq3mvU8DUt+H9hmhX6dU1
DFXYjXNSyCSjVi/t39BphsJx5J14E0izQXc15+8tSSJsRazYyDBQZGo0I52l8dao
ETl9ikyzVV9jekTdqOlK1f7z6omNqDdGOnQF8fqLb9Mg7pUp9692ERTdv784fdoL
qeJttOchtkVXoW3J0G+ci7055TDfNivhrKYfHAwZDi98xhkstqHGGeN+P1mrZY0S
scvmN1H5JO1xgWRE0iNcj6G1/uMoWv54i0+HBxlB6i+xWcciFDMm5R5PzqRMXxTy
ZyD8/NyPCRy8CCkdr7IlKps8dfxh5b22fNhW+y7e9UzfqWMWb4+2wEqmcywBnnWx
LpTTPdx/dRxcC3m+xMbmXfKPqGhQidi2a5UIAP2ZUVhfyLwxXik7dh4eIzQxUL1m
e03BiTA+mil6aWtLVieVcrjPrCIN0NikRKRBCR+lyBAmOQDeoVBUWRDsR8AxRuwu
agvpCGBBDF+C072K8+YuZWSraS1qpwisn4/h+W+gBLDAGO2vIg71mD/hgBRUkNgu
M8b/LgIHMf5kYb00ena6MX86O8VezWkIdoXaZ++VlPOAS9lzHeGAXjIc1kMYx3wz
N3KNCHiJWZ9ri2wgOT3sozafQPJlIgzFu9W+LkuWdKyp7tLWLnGObhMjPuX+mANn
nkUx0WueHlcAFtw1r1uf/49/ud+NXcc0DG7a9fnc1H22UTkLdMrVj8zizYC+zKN9
D9BagDOyvcopw2bShi3w7AYYOpJEfXYXSLXFoHb4/uNDzDN2QM+eGezB4jrFW0Vq
zQQg98tcEygHWnaesTtIcx8ooOD/fRmVa9xoaMtrz82XLj7WVaqsFsVR/pk8ZTib
YMm49kbBKDtRYr91KA4rflLbPWyikjS/fiRfb4+DNPNJmS1BwlF0guaZ1B/R/8f0
4aj+usSoWta49C7KhaGzJLwldSNko7w6tVzDvTB2ltyUXVe5stSd/mLkyaAa444c
0AC0mqAMlk1pThjpVFhPy9UnA1QOyEP9KSXFSkNHUdgMi6PAA4Ms5toyMOQzMnnJ
TD7GND2E9KUDzXtBD748QX14CYeiF0EiggzZaHDAQgN28oC2v9rsVtyGhJ/sFOnb
yHPEHceQZh+NXm6X7a9euveEAPRctHyTlOsJJwKCp/Ht9Ht2QuBE57noZmWx/Jid
6blntiz/z99wK29BKBul4NfElDT4iEsJqTIgWWcf+JD/j/EiEgrLaCjxK2jebdkA
naxI0slczkLqmtg4jp1cn0bvT9nnnhYgRhlQoVufbVl+Oh/MkgXoQOdFv37+pdYm
gWkAVIFBhRqk5uLHshImgTLNrKVdyh3NRgteme3KeDQAqQtWpOe/i1Gg0n4o7CPh
IlXRBpuBEYKpDj7AJOx4JJFivl0c2NiitFnB56gtAheyTpFK/4KrSFOb4WvAtEIw
FIXcufaYtFYvYudwJPH0luccE8Y+BJY6j4H7eiJ0FUpyMumN4LsPXXEJu7v8peyP
K5/8T+VvrTlEnZrrr1DSIWxjq1LMKtvppmmAm6TK25AxXHuPFlhL+8U2RuqteNXo
qW6dlbJI+uX3ytB1888L4Ao74mTV3ntRd6hw5hcOo1gjBfglw8NLd+8y/qWoGAHf
UlpCGAQ5x5exgF/x5vR/S+tg6Y1hOillxUJsLA48/g+k2aVffqk2oFmZVmujvA3w
AGbA/5U2umAsAsownZUsXt6VTjkFM4yXmKx2Z7FXKuEe0mSOr8wm4+GzheYRUUmV
Vd2HR5jbzuYyx5uZ7bLsAwx3bYJN4IxBcCdmWvu05v67cG0njIwn6+dQPU/CNh3E
cMx7aCvG4f8cZ0Lx0nOWDyr/OJIFwWWV29WKn0uHpeJqn+pd3fqD/gfEGa5YAySG
Fnxr8UhGi6XlkbIVYshyvEvvzCL+FD4qIw82j6kaeaCrVap7FiHZP41JBlYtsMH3
tHjBgv089Hjh56SClU7MzBh33uHVrh+fS+NEVomzOKxtpD8L6eG5U8cJu00dRvtA
mjownveAI03H/FNwPXxeld+LJz4dmRLl/bWBvu616tRuwxSuvcrESJu5A6jhrhUV
YTb3zIbK/VKEi9Z4sp7DOI132JsccFBOouoQBIhbfDi3sMnrfMRtQZTj/S5FMghV
RO5GQE3USaVUdbwXpGaQ8B/wuiju4ZBdbLSGWnJ1iWEklVBUU1E0+tK9fgaMwJ5h
fR9er9KI7PCjJTWPr88TvDKBg4F+BeY0i/aUVZyzLFlBL5JzO5Twb0zp0h35kNAL
wnDoPU1nLLiymHZDOsE5g7rC+TaRPjCdKRLmBIzZTbt3AWxyuPS5IHuQrDmaVWnp
kxPhGvN2C9539yV3qqzP2MvQBf3us3PEPFqjMr7EkVIIZ4CLISkSfTgNv5S7XsqO
FvEqDs0VEjEWb/BCggjcHM6Rynm96Z8tVbJ9ZMh/9iadDusI1K19VT6BNGIHWVNS
kKNcOjSmgHdYRmQfQ9aao2LjcMaBM9qcnj+Kj85a8nr5b4n2Q7qEayN29TmQfRoH
4Ctgs//4uNW8MeGGtvGVD3nsGm3YY8JNPSYFPYRdXi5loWu384taLvDuvoRI3dVe
X/XsORbl/tOVC0PmnyNWZIWrMpvGsq6LcDyXnT3oQfqsg7whfJuk+1xv5HdRQ4yp
hmF1fK4uXhs+DE3KD51prkvTg7+dU05iXMHVGkeD+jVqdc/l5zLS8zOPbw51TjIo
B4loEAx3fJ2RRmGcxGFlrexiCu+4GNR9XXsNSI/DH3EnPUiZICinGQcFWXdmxFq7
a7UoI/fNgFVjEBRQMdfAa5wRmMnmStSISxx4GMPhCZ9E6qtpfuSbBo2hWunKSwGa
CEIU5mQbz+OqfGNaFAqnQyblUhnEvvNykMvKy4iy2P+PaaVzE2TwnUFcaninA5Dt
kcN/wDlWX+wpGEkJSsHodGZRI0L2OOKTEOeXaTCPtniVcO4L6+1kxTMZcGE9uYj7
uuctTT395rcV4r1wZnPhqyE437L5JK506O08JdvIzdTeH3GLt3iNxSoa4xglF0iA
jfY8KXc2C+ZG2/Fb5dZ53Qblb/Jpglb8++s8H8PD+uG+qote6cmrRYmUaJ4AUPpa
VC2iZvtw9GJxjCgGEmoQU90pnLWKMxGCCeOVnKtqQFWg54NTEyOGZP5AqUlVGubK
uwxBNs3snc9stOW34gQ4edfj/GCun1IfheG/NqnHKBT7Ok+5B6/rR0bGZU57iSnh
6hlU2d0RwMhrgctNlncXNAoFbhDvKqeMY++5wzBStlIl4qs+ZH5Ka9t8zTpymOhh
Mq7fh1fccXDgOg60taRCtmpr/lLav3ZUVC23UC1dArQp4tHTFOQIh8KdegUicbR+
pSq+KoCLJ4vpG8ikL7DDCaSHtaknjncfe5giEetbgLl3b610fkBFNaYEPyx4co2T
ROQM922imSQ+Xa0eazoCY4BYi4kBNUqmyeE6XCCpHK/0/J8S4o/4HQBz/gzlwx7J
qT6sLN1zFg3BLXevdWoJcPaLO1qzmwptSBD0k3CW5mhQeNWtQgqlBeabujtCnG7d
qb+mQls0mM9CFBvKxLRj/Q4jiHhLpVyepuz9spEAKYw1L3gjhmTW+cE67a3Ezd31
SlU1c2cdFEWwCD/SyMgy9NInPsWctBKk8dyj8bWkH+Ft7wdxJgO/CTtpupC/PJiu
ukG50MimMhuY+8fvZJrI82J3PFzH3OTvrvQznxZO6onbVyhkZTVNdL+UD2gVEc1p
xrwiJfSuMILNive0+jRkdAwhnvdGbMPQ0LoPMPrC8qkBePS/jaOziOFBvoo+tOj2
3UpiP6WIytpA6wRUj25OmhJLXuaLWO80w+c4xhTMZzgklavG+1unlsgC/t2GrSI5
Q96tgp81ZMzKuw1a/6zkTM5mZ6/JVG0N0X9a95DKP06uBWnv7vLnnLLPJ5977UYk
03sZcx7VKdZnx398nUO+pJv/C6ADYGo9ZO5B8K00cMyizD8hfOlG+euXShhx5qjx
SxjLeSkya7IkQeMwvJYAGVVyAZCJskgD0NX7t5SSsEXhx1VMBwGcV4zEMQ8/ItBG
HgJmuRSkdxSntSOu3TdFHfZY1mFAASGuOEeTrTWGS2tnpQLSIyf2YB1UySOr92VH
PkxiGfk5Yu0wRZDgQvgl0qFRagsA8HfTstMK3GSBKFCWucJ+qzJkUuWnnjmAGztv
XiuHUKON3umZ+P5kpChuwmvcJExH1Dh5jaeO5gxQJc3Ga76ZEgMiR+tDf1ZvIz+Q
rOUd4gNssqobEAxrwv0O0kYdpYA6jOBV30Gi49lfd7l0vhK83oMxINjTxvTpw8EC
GOyQZD/IIEFDCpLQOojKPQnPh0IMMd8qCv7we9DbTr1Ot/uMNnhXKrCYWRgMT+aN
io2j+vHDIt6k4AjgTKD5kE3zoQdGRb4dvYJc18/wNo84oRL/pudFWllTCIiLH8cd
aK1osYDva/2t5HDTtpJPgQ1bKmpMYu7/8y2p1tiuXCWrRlT7tQlVIDEyASBsWV6L
Mw2IVR1pcDQhYmjIddHrYxzl0V0IQ/f2zKQrOknyDmvNNw6ZCAEbqhniYgHmHqUG
RdcbADKGwsjPNN4Bcxy11rwcJzx0Pc8BpgXkJ5KU1jraIzGywd77HHQKfJ5r6Mld
S1/xuPuUqDOBQvonMbzjYBGpI5xp0WQlH+yY6nBdPI3ZCWIp/7z5c5l6vZloMc/+
wtp+4Rfvz7NnaW5JdizxG+RB/Bx8DmoJGVoih9tzfG53iX/4LnHnueCSi7xvRpOM
ElIMKYlSNUSWDJXuxoD2mLtDlvobGkh4nHGLbNkBOXl6KqAvUj/g08RZRPM8CsB0
/ubyoi3gF/p1+wh8cZLZyYsBkTD8FXON1VtWYOgBCIDVjV05pN5xSS1OZzSW4ILe
7Bgk5PTQaTu7zmo3FsbD5UFrbKsxODivaXVxd1yVBVaT3ejlp6otJ5saF9YZGuLF
mP7cYCudH7lFS4m4SC8ey4UdIOs+EeTaC4spmv9C8p0Dzuku28eLbMWRbGZXgAwR
R+Si7EBFbwI/yM8EQZijXfXr/akwL1lEcPj7ayYR5ubx+hIsOT7YVSdYWXVxb4ay
+ZJjACrOto/PXHDrmMEVqRupUazt9Ui0vBSfF91+CGF2bRqLAlY9pLVqmLYcp8ED
hrE7xQ8XyLrbKfG1Zz292fP6lYP5FFSj85Y72/Al3x+b83Z/G7JYmiwseQrgFoNX
oK/rN25I94lfICKtzV3g0EbPFIFvLC5sWE5tlw0nY5C9+4k/MJJHiM5y4mBfHXJ4
peuytKvMpAjRjdojtWMCZxF1pAbjSIfKtAhrtZlXNR8CMtCrm1IEHtyumSy5xHzG
hrBiccsMns41N6rS1AEW4M/nSW0kVqkjvVHm0vrslQcVeXeeVsSI6pKSrIclAHK1
zD2+JWbmBzG00Eiqt0S8eqg1uV2V8I7Uy/pjV0HtaP5bXqJrr9i6JYzsWurlnUpl
fMhAR3YrydaXbWa4rpxaQ60vTzPmcegWFCC5NR32g56kr2ohzKeUaBpZ4+LeM3EA
MKr12Q1VMY9b38VDRctbosK6sNU6tWrH0zfOKvw2Q76TS+U7Hkh/krkFWf/EAgBu
KbDo7ztZQzJZwO0JTOmQIeT+o+fQSNPJl51guSG1XY+mzROQTBAYM8ELJtuNx60S
lml0Lu96eWZo8hDqrHcax+pduFYHpLASW2ED+Cs8NFfbfPa/1B6iPHwI4ZQc0mSK
5pL400pDfgaiJ+fPiN2EMj7flSMMDhNTn6GDvLVFKxPpo/+X3PP7P55z3xq+4qQN
GmptB67dWBvTjmmmIOYilmhOw7S0gVV6WQFWomtPEds3hsc5YDOnaDGIQVdLcaZx
w+ec3T3sHujbloC71LQr/Ql1pdjuhi/rCdAbCt5VJePQxbGVlwkYs2+hXAkMtJpW
km4ZPnt+j52x6ys6yBCUeelvuQRMxdiwGd3X76u6ofWxb6O4cQVd8TP/CilxorVX
NsozE90pnPISNavtIT5CS1vbpBcQIj0iydROTZ1cb8RgpGejaUVWUpsZe/5g1kPh
Y189vlfdLka1eX5Yq4/R1tawvdaGxJa1CQXPc+3PbijRSJi38Ymcdixd/xT++oIF
1ERiWxMtV0sZ8Z0SeXGdueHJD+L3IphEeZ3lBffx3LOEWkunLRXd793SdcHojSeH
I9RT+jplEnbp4xaomzdkZYIoRdRrI/8WLWc9EzPIjP0c9eN/utEpq+XaUq6B2itB
AKHSnkFcZ99k++mBBfhfJV2Oq9fneE4oqJVZTTsjFYHPoZX7ykgneYG7OcaXh9HR
H1hpkgOV48Nlw8DK56GqN1dV7CE9boE99dMVc7oXtbZuYMaSxZ5LPGkAcKboQelA
ujVZxA0JXVCv4FijAOxMipgtRYt6a/y+u0m6izs69EOxiaNeYJL9f325PwAX6/Tw
sAy/m8BhXdRBo6cerkASp1EgMFfFoMCKLypRu78LbZru8akdAAw0ZuZ9Ib3TgzGa
5ZUBzGsl1frRLp0vYTmd4IEeP9OnMmCFPrTIYwxL1GENNF4svElbDlQkyM0LZhVa
BDa+lMUVYyOSJprBf/HJwqlBa3/b9yInidD4m76PlBa/ruia8yNtOExIH7i7yrX4
DciaS+XduDMIW4Cq1Q0miRQ2YbqIj4apT+4f1hkocnhf9eBnoeJnFdOoNrUdE8t7
czTnGsVy2yzJ3Etgd5OyRpHde93JNRVpCMhsCoEVJdOKkfIcU53VQtMAFys1MPUd
6nBvw5NX89fNnSyiW/nBhMSfaY91OtoWfPoi7muMQjoN74wiaH3w/Yqh4I8wufrv
bG0jXcTHTtevq7Vj1UpyPhGdblXMlnJGuDR9RAALhlfmUIi/+fSJwn9fR959Kw+S
AzVsYIcFabii+qwKuJgEWQe6JpGkmjuLpjz0/eBK3LPbHhSp1eUcmfqukrxHf+Rs
3jnJAwYFd070OU1zsAZgvFeIIwSblkfzF2rlmeROXNeEhtJrWy39jm8wZ8zU9DpA
Wt2H0ITC5HWHZJ8UBOKTgHg0+/9pQ7k1hkPxsUkTm3ZOkekAi+ghc4k9fAzT2M/7
VPNXt4+xour51P8CUGLoJ59CA9JTNVzgcqqnxUKmC2ldwp2neXytd1ps1JVrFhlQ
tyA0NFpzmfFVannF70MNOce/Oz1cPCr2PY4xy2IhZ1/IomHwrnDpAoQx7uVxP0rJ
mWgyJ5MLglBQXI1Lt9t1kTzAXNJjwYYcTfXsIuNlS4YmT3sdqTiUx4Q44sAuKAml
hBcBZv/FuoorHWqmHh3WmtLedXqtIf4mP6RDWoFSLWVjGquMA+djroBjtMxIDSJP
686ziemrGIDpUVzKI83EX8fh8x5TxTIpBA8Onaxg9in0OBdzlHq2Mk5f6uAzaObA
kkL2x/I6KAkhLXyOLLKZftLA+wCrhbcFP1T2elzUzpx+1KcIyuGUy6nbuNzS0+9W
nty13vFx3r8XICIv3kTHrElsaXUOXUmKE9qfn4FiW7CoruulhbmrmapspMVRY7mB
9eeJhrfs7kleAdqi89WGtfJVnBHUQ3BRy3R+9XT5sbXdZK/Qk1O6Mf+1boTrxlwT
C8TG9xGkRBH20hh3OW0GZ6xd+PZy6BI1pOnaIpqxO2LIMH6wJzFubGXXwztdZ7F5
llSO2yzoox/AEMTVsP0VSdfaMQYzCrugcB8y+ZMX9s/guKYBgBZNtS53FdwscwoM
kc4pmni1SdC9Wm8N9dQtNovAmmL5+U8XatrKMNFZuK3x2F2xMUrOenIGrN9Z3dxu
Rub5AAgyvxUVI2voMlxDy71el4IYtrIoprfFHlQAWL2/ljlVrA78egBiCEEFNsU3
rkYKW95uRupnPy7Wms16LQrdvFJcYuOcBwFRbvEp+o2TubXcE0ecYDOuQRUEpak0
KfBZS5tBn4vsCyinpFQWhwXRmRlN4KFLOKT8HTFXwbtXXYPK9M4jN3p8VEAsvWxv
liZQW1VXYqgVSfAs+FMBoym3cZ6T5A9bfJP+W1bjYCyLq+LzuvYmaWb7fsz7OViY
UlsT7LF2W1wiVn6xHMAKpHTpI8IK884+ZrlUdzm4e5a4VYrVSu0sNYLCMPb4weUo
YBOp/vIZxAzRmc5PuH0N2o8sLDSYax0+D4HwgztqaWu2i4hdJknpjtGVjx4630EF
kXXVfASNRwCmFbYghaNDruBPa5g5SzKY3h8xZgusOcJB8K9oxbUCdZMqXhIlhw/n
l/BNOQPqeG/G2MDoN188+OJd5AySLA8A7DsM/xYyxe03nYf+mSDJiivEDiYGS9I6
MXRzNsBtMWYqotFnKggogHUfcN7EuLy/hBMDx7pFQ+SDjcNaGVABJK5tsDsCmIcX
LaDiUqRMegxy2io7/4OERx6y27LduTnRO0t5BvtlZy5ozqomYCHFhyPl+rrL07Ul
sZHB69qFyYvF17XCBdhL9X0gii+S7ETK5fmc2qMSGKuQy9KvWcYbeuAWmfg0KmZW
xY9rbWMbKRjpjNATWYFkhIfeuEqXiNkKScDINsKa5xxVKUhFxD8XeXn4MFa+tQnI
AgZ3cwn1nkWn4sCMuXioyukNVXaNIhtFBpszdy86Nvz/FH7nK0KpbnmMJNI5GIwh
ZI5Y2v5CDvjJsBR26Fv833+fj/6WjCwh6WFG+iU+AWKPKeaH9XOfxpdYBoMUpKql
ZEj2IAV+KWhyOS0zwhgCO/XpKW/bBp1eZcFPKrV5QJbn6pWA88vVZeCl9HpHUwrH
TR7M5yGk2kQeHf+dVimw1xVOgqE+BVcQpBERuQmT8CoGN/1XY/9HjAT/7HOfu/29
FhawMRYF/hlhZQC16qkrCel90gnm7dYwejB2MenSEVN8laIrJOBxUjZsOVo4YzoO
eflqm2WokxbqL0fMO+jSLbL9rZKEJ2D6yYdCPwqwOlziPWgdmo19m20OS9SCflp/
I0lPYRqrB7hpccANs4mozY3UQK12agfaedLSxf9+kI638vTqQKwuA6Tym+dwszq9
CTN4oz6OBGS8ZXevLqo42ilM74Rw2wZ48ZpV4JgaUOUTeevtYl6A7Mdtuqj2dMaE
Le0O2OSc3vN5NGrKvlruA1Y8vMqjNDhaO+1BqlHfXhGkZl/B2WQYqx8RBfD5uhi/
VyrZr7YAbXQb9eBqBOAvljskR7nCd1KUXDJYUxGhsbGZAvRg7HLPtdN9rHtaJI0T
oWLe/2xeXOvNc9v9bmhuN/v8btMB520qRA2PfWQVe1gG5a2TRZYpc+L1Gk//6+j1
L8fetxD3ShYaAtny65DxUEZ+1V3yIm1wV69VInxOmC3wbuWQc5G7lOmvlvjpj9tU
H4sx6oXeIMa9He83y7fL1Y7+UlGR52W7zkw+lXuIMIPD9kacXJD33eDX8fsmV04L
dAcw+1SU1scKpTsGV9LeNkFxcIIcgxYiA/Cyj/QpJwq6WYr+KXDUcmOZsb07wA1b
fcoeAsJpiNciDlHRTOsLHqMdsrYNolZChk+Pzc92bQDjg7XOhDRHF7T+0AElr/54
sq4GfGa8u9yodCWjvfJtJEqsaHdHq7e4oROTtd9uC/41CW9nzEIHJNNCMqLAuhZZ
8hHWBes/Bu51DAd0nIcXsOYsjlZysr2PpVWNVb3qgVAIJ13nZz3m4ZtIb6SaaxVd
XiCusjfLbGHjiqna8vLZtB3tb7ol0XV5k20ArsWvoF28ZLwx6Ezo1rO+9jLYV5Ro
wImShp8YDBLEUif3Mu7vM+wD6Zcpx009oNiV6SEZb18Fl1v9S5OmnHMAz4CxBvGn
p7rK4SKcewu1oCP3uM31sX1hewp6Swy0dzVrjAkAZW9zK3LRkCBWOaKQUKKgB8Aw
L+xclGqlKHF5frEfQaLC99hZijyY5UXqH48hAuHMSIQJfP3HVYdxRE4YJV/Jj+5C
2MLbAt4cSpSuzRT2s0Z7+CDrXoWuyloxRnKFKuTb/kO1Oo1ytk67wt3CSrsIjL+z
DDTPWojiMZRIAWzkD0sxwmltbIDYRlaBC+YlDCrl6kk00B8bZ3O3VBCziosRC7Lj
CQYcGpJxGSKQFRJfgJABuDyYsLnDBm1IPSUH1jiqo5hsrtsJvJbPW0FRPg4tiah4
6k2Z9llsT96UCIdh5QPRs4E3rWJTO4LJ4WZvp9KY2yRnCRDxGdvonBM/I/8VcLZj
impINEW24o/NpBVvJMJMu/3QUJRdK+WzHv3EXMiNnJT2zq3NleDSKrs01gAmofSe
7drirU48XSj1XKnPs2+qqvr+lirinvNLSqIp+vjPCEl00Vsx45oRpCcOvOqWnP7E
Uch1VGvpZ2W/Z/qdebrsCaARcHgN2cWrlvj45UpO099oY1mWGJcTDHqMjZbKj+Bg
8D+2GroXuZ9xUuRLrW1GwiFC7pUCkWAHNeRh4Ak4Q3w/U5GJVGTWqdOdyfYIEWuX
qY54E+7A3QiOeXXfzpUoQXOUI6TmyL7embNBmB4bUvsGFzCL3deYPoGNhW/Ooc9/
27IZYxXF1Xp3ED7A5d9GJqjuwQbarXFgZfo58ly1UrHvjqL7z1cL6nXdlUEqXfMf
2YobOj6OB+pcmc7Br84QyHzDO2qVvz9YXW1R5laKBrONkidmJ1ONLTnamgKIFIVN
5uqUxFo3U1yMdBS3Irh6FH6lbC4VFRpKqddj8XPXTb1KXVkclT/HCfFXS9OCyH0y
6TQJ0GhnY9z6YQxRGEeTOrFNTste/R618n+CR0dOyUzG5O60tk41XK5BJHguMN8T
e+B3J/BwzMuFXGQ6bGLLsmO2MwlFdD7Jtx0zyYPtSLsdL+v5tNjL5GaxgLLUwcEO
DtcX4njg6KolW2/sZFSI7yK5+jDDljSQbhxhVXbdP2WUXIfO1yie9exq3O4nsMKd
6O4ZuiD7oLQutXsf7KUJkDjMX4J6xh/I9m4HvAPRC1V+HCVV9YdHBbblCItn1n3/
yTABraEavqcqt9nJC8Qf/ga455QUg5RLPG2HAWgheh/JQGouV+dJjvpFDgYDWUvN
ToouXnkDvMlR5sPO0JuaobAR4FkOHzCiS5fkmF5Vi8I/L4XjURNDuMPWZRi0IESB
LhLswm8eQ33oz/VvmxfkLpq7SMc6FFiIViqxmPB2K9dlE8DuvTSeqkGTJc4HSpm+
1U4BGCDxcXwD28UP2oQgC9Bcca4HWddip7b6+N/uE1GARkOn01M3lo/wXnqRAt/z
xvUSASvsO6wEhm/JePtGiVyU4+ZNas86Yf63JPMPvxjT3XfyqAvFHx/2XtuuHTgb
QX3k/jkvTafoPahkW3RAcULH5KXQQHeeyHuC+aquX8TitLMcawzU8mcfOjSNBWsH
v4hJk3zMT8Jtvh47HGn+5kcD0d4P6XqNEwPNNyg2RRRWiKMKhniNw0LiTTPHy+rP
rovyKdlmkwRMEDQU6X3vVJT/lHxjP7VDCsPFqjQSn8itZQT/buQL/CmGH3ZXzFDx
rSXAOdt3UTPXSKa55QuHsJJkqOqAjXHNOYE9KA4uyGzbg4oMdT1yXwjMkgN61E8y
C/QBtML9tTks1RIDcyM47cIFKrN5WGzm8b2VxLJRngY9YfSXWTMIsGyCYWV1mQJi
Yz0TdnsrJZdDtn6GYMLFgSZ+JtB+f5UcL1SM9k5Li7Ylf2y+v+NgKEi9tuFhOy0l
TnoTjRACYZ5xIo9xjvq5B3beJVt5b/k9UqSnfHwuIJIkdX4XaYLlwWfMz5JoXPFt
hJ1zFuACj15VEgBtNKyy1h3DPkOYou1QZuFnfO+GZvlBIz5rPsLZ4jFhxgy1Eqi+
ReVWHWcCnDLy0c+/+xGGcA2+x4t3gm1SRRKYcwuN6Ebewdqd9RICQYFRhfPW7J9N
IT9qbMSf6u2LoyA/1z9DdJYqsqe4LVR3UQu+G8nrfEGtbh8jkQjvJgJUSzFcGu4/
ByFYVRqBTEJUKAl6FwLwCEfMY8nU2w2OPt83HbaRIx8yBGv/QrgZq3V5IHCj6Vhu
P7OILmFzjT/wQN2Tj3SVcQThA6opp+dbo6gJbi5FoaAOj3KeChxgLyUDTJ+c0C95
0LuzjjMAxtX1rOglpLUANlFZ0pas5NRMcUBFVuS45q01QOBMDoHB/tdqCUp477ty
fmaW/v/pNnc6mmTvsNOU+Nl28DnDy0iFz2R5PP8sZVgleZ/7/prQr6Nic/5hf+1h
ZQQnLrPhfC8DwedKFt/ODKT/nIooA/mzQl5Jetzp3M/u1DdoszKGKsfupNDAD7A2
CSCXuTUMRo0+hqUbttnjOUhnCx2zhjvir8wLPOafQyD+0ZGLM7STPvR6iYuZ8fmZ
YNlr/VDYcE8fw5oXdLvwtbvTknvagoliwOkcYnrcFGLLwo04Cch6fDOHwis2xsDN
J+WCr6DcDql6alDoKmdynHpDYe2Zd1IeVHuvUilsfdUISSzIcITc1MnJLvBCVcB+
QV2+XgLeFreXJ++9ZS10ApmHe1UWcpNR6+I4y+tsGf433M9noS+Pr+IE4oizUZHn
xFE4JzOpZftjC0wtWYglH1ho0XTgGXhlzcs6F1lQNhbKU3JpIkXfcV3Uwgc3pTam
QtUryIzV5PX8SkPEPZH7KSOEQ4pApQkUSp3on93eaziShTZL1eplcvmOj5hTgKmc
fKkw99WeDEiQsBUnD65WBS4RrfYTYw581/tl480dQ4PBBC6sRJgdk2O70gYaVy5A
9OkNqTISua2Wj74R/jKjMl9FDemZJU4Nk4Sn+S9GYOZIKIJ8SyPfgYebuyE7c4NU
fz6k6/XLteexKCz4sZhXKoelNwXt6juw6bqPNBfSvAHJG5YW9AY0KDxnCnMqSlbx
OFbKfLmNex1x9U23LrDWKpMtEFxl6R62OAtCLxIjlA8sCbFoYyk4XGLLhAySrLrq
vex8n7qs8AVjUaA0+WG5UrN9XOIGNQxZuKMHsYjrIvYLSlxd+auZQ7t2hoeyQgaY
DJpY1VBnMeixc24Gu8NmxT6TxZFV7YIesvVvKh7OWFptS5L2MlO2Yy8pScAC814h
kGUKgsjKUPAHZ+4z232mR+JVZoYAVoLKWa7lgkw+IXo2SERJiBPoP5yXVAsfqox/
gbTXVcw0Gp3LE/Nmul8Cdm/9C3BChpqe3NxDOu4lyWHT5XxHzj0F+Vy1w5apKNeq
L5fczzcy9m949aC/IzLkkXCsMSSpoCJa7zhnvV6Ax1ISA3PUcf2QIJJDN1cmU4dw
AgWugWackZsP0Yyn+sRpkok8k/P0+0j+A84iq2aX01ywf6nGDTkNpumnmwkq2NAa
f7e+RyUJimfPTl2H4Xq3rDOa3gTwv+N7BX3ZF3DRJ8tPkM+oXJQQkgCFwjIP96Ot
3Vr8FrHvoujV+WawLPlTw/NjGmFHapKZWZpnTyvtxOtCO/03HHGTadqG1f+JfQ6d
IQJP2iG0rmA1jiWFiQgjIrKJEobhqQzuhOj6xJWb6jIwd4WU/sEq1kRgtjdFeWR1
4G5+1DmN0LEP2RWqVgBLNVUin+CNxnTKV9Ufj9dHjX5yblttFF5TyShxQ+4FZIwv
h1D+MzArUc5qx6kJhRJ9eCQlhrO4T2y2zFslZAsYk3Q8WqyBGcS+QqKK4fpmULxB
Bd50Q6GhTcS+qCS+mRe3NaOkd7wlrUql1B+e5mjYTVGG0VGxUgez4BKLUVPfLhUf
R0RML6t3gd46EfWL94VZd12mx2HRh03GorRk3cMhKqy3HfYS+2k7YMv5XzbQ2E9S
azzfLFPdPcR5DCso0k6L+Rdhan5S8+eDZomvMpjxC8yZtjPM9PXouSL1tFkzquEh
ZWZx69jP26heF3jDE/6O10nQInxAGHmb3hdmVjqVg9pnZefOahhlwHQqABbR78KA
SOifiv0Evh3nrT5UIG3X2eA6J92KtNUi5hadG51LUkQl9wO90cH46VwBqych0Hmf
b5fbLq2HNvLRdEPwZeMbvFyjmmaWehSuYN2zItqrlYvvrmjfsw3i6ZH6hMlAChjM
NzlYk/177JbXsWOCwK/RjL3X/corK9MYNZc+5zlLCHcVfjRsHctfsvPNLwK2dt6+
mb/BSrOXLvIzQCkzCPS5rJoVqQ0rznjuJC1EIbJaFRignDE1OfTiyz02KZ+rnU9v
UjDsNHs7aeWCglOrhev9UMwk0qONle25ECr0VWtoQkZORQHetIWSBNe8XBjrDVem
yWD4trFouex9WTvt5XNrIjQF7devztEWMgd+UhOpHeagdjBC1cIpwPQ9zOKg+DEL
PksmG4lTFBWOIUqrP8cxdM0SEnfvt1gIDPFJwQ0qHn3vrUIJ/9AR+8tVNPrE8oUT
5JOE1oUCNeh+UZUMCH4ei9blyJiquF7QQ1mqB+NPm7gilfh2GFvgJJb/PwFxn+b+
9zT7mk4Bd6kM88iAXLb0eGB+7UVl13l3NBDxYf6+dBEUp7YZHc+dmdVH16UH/9E7
72yDDcRV5YOvZheCJvmJ1L/TqNBLca1JAzzBslhJZOsE8MhnStmG4q2+lQLT06+z
5M6NFC6gWz29gyKvn7iMTqncOo0gCD+V0o06KsXhuErT7F4tda2yBbPZrUnfeGJ5
K0FohdudlZBGEisPEvJ3w4npe/9YE48VgjaoOMwBLIo8vGq0UEiEnooFDf3gPCm7
BrpwvWQ+LNDaVVJw1uHv2TSLWO7ZaNA5zeRi6mMa44jF1GqHHg/98Gdu9/CJ5yfQ
PX+ZWr38FiW89ILhPtgVyR3K6pURFjfGVC7R21ywa66/pNndqeqGeozxY3bLSJ3i
m9PwcSG0gQ7vUCH2sozetFoSCimiVlRVNik9CvQY1g9KvCl32ynp5tkpNJ3Eu0/9
13qChFycklacppbE+hOYwphv3XBIx+ttPwRCupS+0QdIfQ2NG9FzafXo2tmjCN8x
y6AfpYYIkR85+hWaKeOa1DMFVU03Vy1nd2cnG8aCLFl9tAS71EfkCZveL6OglVih
uagR/lhdeUjbWNvNbtlNUb2zHQKREr6JqrzwRLKeIzeG+QWYYW/9rdSRHYymCZIF
0oeLhqL8f3QtRzI/FrqmXm9EhRF1aTiqL4Q000R9pUG682r1pajarhcW6zPUthF9
SkSG72wYDhsQ1Fvz7k4m0tqzEfrrhZpFbfJ0jB+jdRyWgnHtxjmXlHaODj0GzvWP
mKwfE5sSQsIJS0aM9zf9CZXo7eDfMUcPbLdrJbdQWPs03HScBgQWeReuGccjfcwd
zN741kHb7iEz/tbQ6NrQ8WUwR5uak++URcqMGhlpvcQ/3eHk6rB5stAZoYndYuN9
cyb32tZosjkmM5ZbpXmB6wvslM+nNOyr7LhBL9IxZYYG/2ViElRymPbH5Fo2KdfJ
7138fC0ONDMa44B0sOuBHuUeCFAv7FsgVFhzI6WvcmuezR1IWQHjwomCJh4gT07a
saw8iR8IpbxcbAf30QC7iWpKhxZopzmVP7YgWKxWNYm5rJ5qyqMbxzLM+jbDivhw
84ihfCL1dy1hRm259j/7brAegSLmsFg/coN/KNXmiaQDAFTlyDCd6C5VpRI9u5VQ
L+l30TfrowRLlXcxeRuWhd3735eakfeoVfLwv3wjAf167X0DWYU/UC1P0GPPCZlQ
HhXlOTdo44TCb7N2YuoD0sqdgkSlW5eota2LANPm21p9Nqqgnz0D/PzG8AXhC0dL
4Aq7GIl7c4Mh37E0igZ7+bXVt9ZuB2nC0gv9zrnqd0lDQKZ5I71/DCnxDYkkGF6w
TczjVXSUtn/ttIj+/EL3Cau6L+m5T+VwKlLhTOit2vPx6aLDiYVVk4UuuphzfclB
l7fsckpB7uVNpNIB6M/jMHROr/oGpV5HKe6EvRb7A00VKgJq4O/bJSedVdonBBZQ
uToqf6pDrOoZy+GT9u5VWHXzjVcGAOKYF/oF3dYj9NuiXvWwwUs+tIZ4/IDS+K1a
ydUkEAy1OiGx+LAoaC0HnNXdqWT1GzoG9c8w1nGyFnBUDcuszHxRbuHnXeWNlOfl
0Fzvf88Rp7Iml9+N5X+qk2EhJjc7/UzaKiE25mB63zaYHZ38oal2+NNUYoKG94mb
vT8odWUrUu3tt42EEiL1WEdTUKjQwsM46bhqG+HScMyylE4uDI4KbutWMNPrg69w
bAxxiIXTFW+6NtF4Jn6PDQ9SNOioHVr4lIIcXFt1hd2cDHRpJXYVryFSLbJkWPVq
yYgmxAPjeF4iFDkrEa3R5GY1gFzG7wpb7ifvWk5/h2Z1nhMvndCGc9FE9dB8jbR2
nImMSP5o5ww2FPv/VUYLgggnQIxpMRcamRQHP1h2NqwcmA6+gVj5CFzu9bfzJqCm
BbwtOom7OZ28CmoxUVhi7jfZ7yneV0iJH9WSn6CwRcwC4A6npgAA3WxExUyN6Lxi
3d/VT87ElbaCnET2yfeG3dh0ObGMogD6RcB9Rx6yZWyfRow8kFe0fMPCvD4ISBql
EIqs9PDAfSzM/+6aB0RGnq/vutFDWAiu99cy8d77PCxF5YuUEwhBkPdpaHBjcTM0
T7qJ7G9P7sD4lPaFHaEWR44ibU7UbQQvUyoDDUI/wG2eZP68tpwdABpEWxDT2ZVN
t8pGXj3tQvbj+5eqAtYXiay8l4RDl5ajQogZdSo9GEd8/8Hf2ChLbcm0R4fJRzHC
QPGcrYpqSaKFinKHR+QY9Y5/nVF/umjj9KFehnazfCajG0vf4TFLvEEnRcc7Q8u7
vkb4GFjVLd7qAOtukzRpRyvPi4WJ9XS9c84Xg5Fyqnik57d9A22fjZNu5FLVeyOy
zTwV38kVpYfWyZd4OPBeLlhpSZ0/YArn048h8nuAkfC6tgPyR6ZmwU5+MeIEvBpS
Yo3N7ji1TmpVNydW7n+zbltfvuoEERU+i9aUDYC4NNZ8GRhqgeYbR5pCALYDTmKc
tltPISYdSwkRkbdSmKD2fUonNppA8JXq62ebtYmpU8ZoOpAevtbmt74bvd+NPFkk
zqI/k4iq0GWhEVizcfrr0i8u96J6Rg1VF4td7Gm23QL3W/06ZiXJWirouUmAtfzI
/zuoggCvquxRUO6jFZ5T0cRjkUn/Uu/7GkJC+y06WdvdsfGtUPvTT9x+pTTkZ4YB
zbujdHyesmnldWvToBPHHfv5doznmzh5smgrUgopZ9L+CCY5LWrAuru7rLdDuCpB
sJff33lsq27x0zxSQI02P2WZLqTx1hbVFAinRtJKX45oykFDOutjfxC+RpCEjfsk
h0L1ExjISBK1D9TfUW9cof8cVunKPWG4Wr31DctKvpE8BpDDgTUFpxqgJeUDUQ/N
o2XX2mzhEvuqroF1TBXAcUBoixpr3f0V6SXxz2+M8qSeFbCG+BGPgY4pAHOFoqDh
VfVCX2qbBIP8jc7fMBSvVQOml5CAfV8evssTku/ejHaJ0JxPArOwto2kYjwdqIpD
IJupk5OJF7A6wlfOBgGublYOYrgjX1voUe8YIq4Gz6qWAK8eAZDaYCLlVqq1Deqf
B1nWy2R1QECGcbLIvWQc5ZYKRmziojyiXdFLwMg4QR3bC5C/Fbvqq0kdl1zb4ggR
1/wkqBxVEvUZjVS++WNVcnEjp8GAOarwB8jSI6qluy7cP6/wnmOK397ybn/hrbV4
ED4NxShalh23yur7fbRR6YTzNYKxkotjMbPCcm4vewsiXUJkBN8I7k8KENh4dY1R
SzZM9uVRwlu+YqaUz/j0lJJGjRt2B5vLonRBsdpPORyGyTldZ8FfWpgbWw0YhX+k
Ps1nFBCOwuStlcbDgowBVx/xf45Ub2Y3bghiJJTZRhzQ4vtWrgOo5XfOEBIpBjqN
2xrsPf0Jzdo5NswUzM4ftApZgkzwHIVwUDP9KmxydzUJctDGFTiJsZ7QtYXLoKD7
p9FBxF36UwPsth4565gRkWbH2SKrWCPdDqb8P3VChgBcbBZk8MTCrrUpj4UWcIHP
onCGZP4kSRd2Bc9ZsJHbpqZwewWnMKQeOtlOzMQCsLqwUs1QapiCFTqNMJXN/c0z
rycrOkY1I0Gn1LBsil5iqYcedBu/5edeGeyanEu8B353JDagBqOdmYorW7AYzuH+
esniaLuM1QU//O0GMXjTQ9XNbXq/tzYaQJYQ1IsD8nNcdoI3awiJi4rAiIu3BskB
BSxXsogpfaglEQZDLvtwS37ayDv/H9RJ35/Ajgfm10pqenQfaNHzZuCKqmzv6vku
Esz6GXurTNyTExu+GiSb8h+VWGDUsPOHUmt7Sw/VD0dCuS/HsfctcR3PABYvz1JF
iU/B+HHIGDp6HZy1Sq2aqQCqkzHpTZ0A64uTsX1MN3odyiWrYIcYYTT5CQvz9btV
+dNdSHBPhzRquUp4ILkaQ8xeV+U1pb9g+DQixqqFORcaJJ8KIlxULf+m3USFDwmZ
Afr95dZ4OGGA6fDO4p1LbMSylH1LxCqbeuBk85WOtHzOo99oDluLGwrXw5dkkcWU
uLyjxJBQJQN8GZQGx9OtjEkM00og+9e5gBztXQGnyfj2BmX5QGkPbyJjcqWN19NP
k9hBrwzUY+Oyc2D+IkxEYNVHjy3bSxdEQriTIDJ51XxwTUuPMD2tZvZD/ZjHsb/i
YSju18TlKTzaqS37byy3bV1htVWptiHcMF0BTs8LATJzxnkhmbdakQgC+MgRJ8ck
8iGHf4cqrTnsWD8KK5PMOTUNuMhWjTd7yjVe1G019Zz7X2XVRn02OWYwZvGKp7zA
Ng9Y3TfERawsh60oFF21jknpSTM+CzfTJOWb9z/DIofOQlV6l8hGGaL93v0lhLfV
jBGCDQtZIl5jaXCpLsid2exKv8NIYTry1QWa2FAAVRF5Eg5wpvVvuOnhEnc83Drk
fBBid+mSgTxWxIWh5BBLqXd4vLaxjtMHrgIRsG5vX+vXnUuBJWUS9tNLrqWHXH1f
RyGiA4YX2rWimDZSwK6OS7dYMXKcd5hTbG8E5UQSoEN70g0/s5P9yzwEY8xBi96w
xD7xa2cg64NjlV0BLxguzYnpCQ/Fc96EjdPKt1hZdC1hGHR1PtRdtvrtD0P0xgEr
mNlQ39G5mYBX3w734JwivIzM9Ix8CZAAaIqsJbsj1c6sQ/94lTZgGB5CxLIKVrlI
VYCTcyM3qc9OnflWJy1TmvlZbqk2lKIt35Bzo6/lLqI8I35ehrj2btTnsU4fsn/w
JJf54onFm39U0iuildUk8yr+G2YiC7ANzx48BvNf+HZek4ZGKS/PPMMTg21mTwJt
cbxg8q8AiDdOIc7pJaW7C+0mA/njoQHXT7qY1+HTxG718vaOqcu4qlHKJwaeHbEI
AF26sBXRBB2kfysorEyHz6KUJeyoidbYpPT2F+J0kiTbPpeeZprPczxQtM9m6cqt
F9cYrw4lm0M8Mr2DWIqT5S8obODqMJUuiaZ8wKb9lGz+LlKj7YDfE2rDbV+tE64F
0F29XTZMqNSpXQwmAZIMIoBIIdmJBpLyNuRaoClRfJbk7qj7sPdpBttxYR+7ohkv
YMacvwtiKhHVV9Mx4jWvDWyrs/ZTVwe5SxUybd1d8eVvnbd1oxhIxtHw2mcYU2rO
bUo/PPcj83EYu2LWnAf0Qwrj2NSoBOVSTbg4qoV19Ow/DmMSvf7TSzynOD8OPXQv
FdSUCHFXZgxxa3ZVAKXsCuE2K8A0zqjfiJL474uikgeMnn8OzBUCCjbw0QypCSF9
FUFqa+Socx12glqsvCVXpohTzgkC+OZsxFwXt4TUHFiMzp5WS8bAVwhtdF4Dpv7T
uzSCukwBDnARaTRnYbzCvCnewFXg7YY1qhTVuUCbUvYYyOm+Gi/1q6olldCHPxNA
cSwW0boGM2MLWrRm7/0igwrWatmyrZI8UIF2daD3dINQLMxo9q9RyNlsENe/+A7N
hxJ5oNZtmOLX7Us6mELUXZP9ZX8i5H0SFuhY+7k6QhrPKyuJs6jyQtsU5UGs9L3r
Wodp7kOEnorTIA0u5Zi/AmSNaNEaNIwCT3akZsIfmBECAvQzVUFC+pdHDAUWC9Xp
VYShHRy5JnTlUSd9+ez7ddNcNjBZaqjGDlBzTCydNSrVJUcyxp58uy6I2FcmPFFJ
5mfiQKRZbYHmzk7jMH4DSNArM75C1zJ9JPyX+ztz8CJQaXeeKq785Sfo9KbIYnM8
SaBXLxbJVjII8YcmM8QcVn1ff7SC9m4iCnnnKpxcrDb3jDmhaRMLGR2/m5Sd+dYC
0tkmT1sE0GHYLgSmrNnX5V0WyM4AeXaZuojJ2UjBIIjJBTQxYKwliOKNjc4FRME5
ppK8iwfj4/v/Pff2AaHWvnHteEKL98k3rkoYfRL4iE4Nll7volvr5wX0dSrqP55y
hPgQ4dppglWYDpKBnv7ZDCThx5oZIaBvWoCmGY6K0sRDBXKG2BIwq5Y8d/vSjPce
WLqkFmB2AkCYgucpYAikzw==
`pragma protect end_protected
endmodule
