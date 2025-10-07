//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : ddio_clk_adapt_emmc_clk.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-11-07 17:14:02 
// Last Modified  : 2024-12-12 16:59:56
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1ns / 1ps
 
module ddio_clk_adapt_emmc_clk
(
//Global Signals
input                           rstn,
input                           clk,
//Control Signals
input                           sample_en,
input           [15:0]          clk_div,
input                           clk_enable,
//emmc CMD Signals
input                           emmc_cmd_IN_HI,
input                           emmc_cmd_IN_LO,
output  reg                     emmc_cmd_i,
input                           emmc_cmd_OE,
//emmc DAT Signals
input           [7:0]           emmc_dat_IN_HI,
input           [7:0]           emmc_dat_IN_LO,
output  reg     [7:0]           emmc_dat_i_hi,
output  reg     [7:0]           emmc_dat_i_lo,
input                           emmc_dat_OE
);

//Parameter Define
 
//Register Define
reg     [15:0]                  clk_div_cnt;
reg     [15:0]                  clk_div_r;
reg     [7:0]                   emmc_dat_i_hi_r;
reg     [7:0]                   emmc_dat_i_lo_r;
//Wire Define

//Encryption begin 
/*----------------------------------------------------------------------------------*\
                                The main code
\*----------------------------------------------------------------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        clk_div_r <= 16'h0;
    else if(clk_div[15:1] == 0)
        clk_div_r <= 16'h0;
    else
        clk_div_r <= {clk_div[15:1],1'b0} - 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        clk_div_cnt <= 16'h0;
    else if((clk_div_cnt == clk_div_r) || (sample_en == 1'b1))
        clk_div_cnt <= 16'h0;
    else
        clk_div_cnt <= clk_div_cnt + 1'b1;
end

/*-------------------------------- CMD Region ------------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0) 
        emmc_cmd_i <=1'b1;
    else if((sample_en == 1'b1) && (emmc_cmd_OE == 1'b0))
        emmc_cmd_i <= emmc_cmd_IN_HI;
end

/*------------------------------- Data Region ------------------------------*/
always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) 
        emmc_dat_i_hi_r <= {8{1'b1}};
    else if((sample_en == 1'b1) && (emmc_dat_OE == 1'b0))
        emmc_dat_i_hi_r <= emmc_dat_IN_HI;
end

always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) 
        emmc_dat_i_lo_r <= {8{1'b1}};
    else if((clk_div_r != 0) && (clk_div_cnt ==  (clk_div_r>>1)) && (emmc_dat_OE == 1'b0))//div >= 2
        emmc_dat_i_lo_r <= emmc_dat_IN_HI;
end

always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) 
        emmc_dat_i_hi <= {8{1'b1}};
    else if((sample_en == 1'b1) && (emmc_dat_OE == 1'b0))
        emmc_dat_i_hi <= emmc_dat_i_hi_r;
end

always @(posedge clk or negedge rstn) begin
    if(rstn == 1'b0) 
        emmc_dat_i_lo <= {8{1'b1}};
    else if((clk_div_r == 0) && (sample_en == 1'b1) && (emmc_dat_OE == 1'b0))//div == 0/1
        emmc_dat_i_lo <= emmc_dat_IN_LO;
    else if((sample_en == 1'b1) && (emmc_dat_OE == 1'b0))
        emmc_dat_i_lo <= emmc_dat_i_lo_r;
end

//Encryption end
endmodule