//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : emmc_clk_adapt_ddio_clk.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-11-07 17:14:02 
// Last Modified  : 2025-02-17 09:28:23
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1ns / 1ps
 
module emmc_clk_adapt_ddio_clk
(
//Global Signals
input                           rstn,
input                           clk,
//Control Signals
input                           clk_en,
input           [15:0]          clk_div,
input                           clk_enable,
input                           data_ddr_mode,
//eMMC Clock Signals
output  reg                     emmc_clk_HI,
output  reg                     emmc_clk_LO,
//eMMC CMD Signals
input                           emmc_cmd_o,
input                           emmc_cmd_oe,
output  reg                     emmc_cmd_OUT_HI,
output  reg                     emmc_cmd_OUT_LO,
output  reg                     emmc_cmd_OE,
//eMMC DAT Signals
input           [7:0]           emmc_dat_o_hi,
input           [7:0]           emmc_dat_o_lo,
input                           emmc_dat_oe,
output  reg     [7:0]           emmc_dat_OUT_HI,
output  reg     [7:0]           emmc_dat_OUT_LO,
output  reg                     emmc_dat_OE

);

//Parameter Define
 
//Register Define
reg     [15:0]                  clk_div_cnt;
reg     [15:0]                  clk_div_r;
reg                             emmc_clk_hi_r;
reg                             emmc_clk_lo_r;
reg                             emmc_cmd_oe_r1;
reg                             emmc_cmd_oe_r2;
reg                             emmc_dat_oe_r1;
reg                             emmc_dat_oe_r2;

//Wire Define
wire    [15:0]                  clk_div_w;

//Encryption begin 
/*----------------------------------------------------------------------------------*\
                                The main code
\*----------------------------------------------------------------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        clk_div_r <= 16'h0;
    else if(clk_enable == 1'b1)
        clk_div_r <= clk_div_w;
end

assign clk_div_w = (clk_div[15:1] == 0) ? 16'h0 : ({clk_div[15:1],1'b0} - 1'b1);

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        clk_div_cnt <= 16'h0;
    else if((clk_div_cnt == clk_div_w) || (clk_en == 1'b1))
		clk_div_cnt <= 16'h0;
    else
        clk_div_cnt <= clk_div_cnt + 1'b1;
end

/*------------------------------- Clock Region -----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        begin
            emmc_clk_hi_r <= 1'b0;
            emmc_clk_lo_r <= 1'b0;
        end
    else if((clk_enable == 1'b0) && (clk_div_cnt == (clk_div_r>>1)))
        begin
            emmc_clk_hi_r <= 1'b0;
            emmc_clk_lo_r <= 1'b0;
        end
    else if((clk_enable == 1'b1) && (clk_div_w == 0))
        begin
            emmc_clk_hi_r <= 1'b1;
            emmc_clk_lo_r <= 1'b0;
        end
    else if((clk_enable == 1'b1) && (clk_en == 1'b1)) 
        begin
            emmc_clk_hi_r <= 1'b1;
            emmc_clk_lo_r <= 1'b1;
        end
    else if((clk_enable == 1'b1) && (clk_en == 1'b0) && (clk_div_cnt == (clk_div_w>>1)))
        begin
            emmc_clk_hi_r <= 1'b0;
            emmc_clk_lo_r <= 1'b0;
        end
end 

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        begin
            emmc_clk_HI <= 1'b0;
            emmc_clk_LO <= 1'b0;
        end
    else 
        begin
            emmc_clk_HI <= emmc_clk_hi_r;
            emmc_clk_LO <= emmc_clk_lo_r;
        end
end

/*-------------------------------- CMD Region ------------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0) 
        begin
            emmc_cmd_OUT_HI <= 1'b0;
            emmc_cmd_OUT_LO <= 1'b0;
        end
    else 
        begin
            emmc_cmd_OUT_HI <= emmc_cmd_o;
            emmc_cmd_OUT_LO <= emmc_cmd_o;
        end
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_cmd_OE <= 1'b0;
    else if(emmc_cmd_oe == 1'b1)
        emmc_cmd_OE <= emmc_cmd_oe;
    else 
        emmc_cmd_OE <= emmc_cmd_oe_r2;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        begin
            emmc_cmd_oe_r1 <= 1'b0;
            emmc_cmd_oe_r2 <= 1'b0;
        end
    else if(clk_en == 1'b1)
        begin
            emmc_cmd_oe_r1 <= emmc_cmd_oe;
            emmc_cmd_oe_r2 <= emmc_cmd_oe_r1;
        end
end

/*------------------------------- Data Region ------------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0) 
        begin
            emmc_dat_OUT_HI <= 8'b0;
            emmc_dat_OUT_LO <= 8'b0;
        end
    else if((data_ddr_mode == 1'b0) || (clk_div_w == 1'b0))
        begin
            emmc_dat_OUT_HI <= emmc_dat_o_hi;
            emmc_dat_OUT_LO <= emmc_dat_o_lo;
        end
    else if((data_ddr_mode == 1'b1) && (clk_div_cnt == 0))
        begin
            emmc_dat_OUT_HI <= emmc_dat_o_hi;
            emmc_dat_OUT_LO <= emmc_dat_o_hi;
        end
    else if((data_ddr_mode == 1'b1) && (clk_div_cnt == ({clk_div[15:1],1'b0} >> 1)))
        begin
            emmc_dat_OUT_HI <= emmc_dat_o_lo;
            emmc_dat_OUT_LO <= emmc_dat_o_lo;
        end
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_dat_OE <= 1'b0;
    else if(emmc_dat_oe == 1'b1)
        emmc_dat_OE <= emmc_dat_oe;
    else
        emmc_dat_OE <= emmc_dat_oe_r2;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        begin
            emmc_dat_oe_r1 <= 1'b0;
            emmc_dat_oe_r2 <= 1'b0;
        end
    else if(clk_en == 1'b1)
        begin
            emmc_dat_oe_r1 <= emmc_dat_oe;
            emmc_dat_oe_r2 <= emmc_dat_oe_r1;
        end
end

//Encryption end
endmodule