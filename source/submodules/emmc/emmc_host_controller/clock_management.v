//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : clock_management.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-11-15 15:27:25 
// Last Modified  : 2025-04-14 13:47:39
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module clock_management
(
//Globle Signals
input                           emmc_base_clk,//200MHz
input                           rstn_emmc_clk,
input                           emmc_base_clk_cal,//200MHz,The clock phase is dynamically adjusted by the cpu
input                           rstn_emmc_clk_cal,
//Sampling Clock Phase Dynamic Adjustment Signals
//--From RISC-V
input           [2:0]           cpu_shift,          
input                           cpu_shift_ena,
//--To FPGA PLL 
output  reg     [2:0]           pll_SHIFT,          
output  reg                     pll_SHIFT_ENA,
//Control Signals
input                           cpu_clk_out_en,
input           [15:0]          clk_div,
output  reg                     emmc_clk_en,
output  reg                     sample_en,
input           [15:0]          sample_cnt
);

//Parameter Define 
parameter                       ENA_MAX = 4'd4;

//Register Define
reg     [15:0]                  clk_div_r;
reg     [15:0]                  clk_div_cnt;
reg     [15:0]                  cal_clk_div_cnt;

reg                             cpu_clk_out_en_r;
reg                             cal_cpu_clk_out_en_r;
reg                             pll_SHIFT_ENA_r;
reg                             cal_pll_SHIFT_ENA_r;

reg     [3:0]                   ena_cnt;
reg                             cnt_vld;
reg                             cpu_shift_ena_r1;
reg                             cpu_shift_ena_r2;
reg                             cpu_shift_ena_posedge;

//Wire Define
wire    [15:0]                  clk_div_w;
wire                            clk_enable_posedge;
wire                            cal_clk_enable_posedge;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/
always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        clk_div_r <= 16'h0;
    else if(clk_div[15:1] == 0)
        clk_div_r <= 16'h0;
    else
        clk_div_r <= {clk_div[15:1],1'b0} - 1'b1;
end

assign clk_div_w = (clk_div[15:1] == 0) ? 16'h0 : ({clk_div[15:1],1'b0} - 1'b1);

/*----------------------- Tx Clock (Divider) Enable Region -----------------*/
always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        begin
            cpu_clk_out_en_r <= 1'b0;
            pll_SHIFT_ENA_r  <= 1'b0;
        end
    else 
        begin
            cpu_clk_out_en_r <= cpu_clk_out_en;
            pll_SHIFT_ENA_r  <= pll_SHIFT_ENA;
        end
end

always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        clk_div_cnt <= 16'h0;
    else if((cpu_clk_out_en_r == 1'b0) || (clk_div_cnt == clk_div_w) || (pll_SHIFT_ENA_r == 1'b1))
        clk_div_cnt <= 16'h0;
    else 
        clk_div_cnt <= clk_div_cnt + 1'b1;
end

always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        emmc_clk_en <= 1'h0;
    else if((clk_div_cnt == 0) && (pll_SHIFT_ENA_r == 1'b0)) 
        emmc_clk_en <= 1'h1;
    else
        emmc_clk_en <= 1'h0;
end

/*----------------------- Rx Clock (Divider) Enable Region -----------------*/
always @(posedge emmc_base_clk_cal or negedge rstn_emmc_clk_cal)
begin
    if(rstn_emmc_clk_cal == 1'b0)
        begin
            cal_cpu_clk_out_en_r <= 1'b0;
            cal_pll_SHIFT_ENA_r  <= 1'b0;
        end
    else 
        begin
            cal_cpu_clk_out_en_r <= cpu_clk_out_en;
            cal_pll_SHIFT_ENA_r  <= pll_SHIFT_ENA;
        end
end

always @(posedge emmc_base_clk_cal or negedge rstn_emmc_clk_cal)
begin
    if(rstn_emmc_clk_cal == 1'b0)
        cal_clk_div_cnt <= 16'h0;
    else if((cal_cpu_clk_out_en_r == 1'b0) || (cal_clk_div_cnt == clk_div_w) || (cal_pll_SHIFT_ENA_r == 1'b1))
        cal_clk_div_cnt <= 16'h0;
    else
        cal_clk_div_cnt <= cal_clk_div_cnt + 1'b1;
end

always @(posedge emmc_base_clk_cal or negedge rstn_emmc_clk_cal)
begin
    if(rstn_emmc_clk_cal == 1'b0)
        sample_en <= 1'h0;
    else if((cal_clk_div_cnt == sample_cnt) && (cal_pll_SHIFT_ENA_r == 1'b0))
        sample_en <= 1'h1;
    else 
        sample_en <= 1'b0;
end

/*----------- Rx Sampling Clock Phase Dynamic Adjustment Region ------------*/
always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        begin
            cpu_shift_ena_r1 <= 1'b0;
            cpu_shift_ena_r2 <= 1'b0;
        end
    else 
        begin
            cpu_shift_ena_r1 <= cpu_shift_ena;
            cpu_shift_ena_r2 <= cpu_shift_ena_r1;
        end
end

always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        cpu_shift_ena_posedge <= 1'b0;
    else if((cpu_shift_ena_r1 == 1'b1) && (cpu_shift_ena_r2 == 1'b0))
        cpu_shift_ena_posedge <= 1'b1;
    else
        cpu_shift_ena_posedge <= 1'b0;
end

always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        ena_cnt <= 4'd0;
    else if(ena_cnt == ENA_MAX-1)
        ena_cnt <= 4'd0;
    else if(cnt_vld == 1'b1)
        ena_cnt <= ena_cnt + 4'd1;
end

always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0) 
        cnt_vld <= 1'b0;
    else if(ena_cnt == ENA_MAX-1)
        cnt_vld <= 1'b0;
    else if(cpu_shift_ena_posedge == 1'b1)
        cnt_vld <= 1'b1;
end

always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        begin
            pll_SHIFT     <= 3'b0;
        end
    else 
        begin
            pll_SHIFT     <= cpu_shift;
        end
end
    
always @(posedge emmc_base_clk or negedge rstn_emmc_clk)
begin
    if(rstn_emmc_clk == 1'b0)
        pll_SHIFT_ENA <= 1'b0;
    else if((ena_cnt == ENA_MAX-1) && (cnt_vld == 1'b1))
        pll_SHIFT_ENA <= 1'b0;
    else if(cpu_shift_ena_posedge == 1'b1)
        pll_SHIFT_ENA <= 1'b1;
end

//Encryption end
endmodule
