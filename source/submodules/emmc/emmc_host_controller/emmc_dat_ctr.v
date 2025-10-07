//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : emmc_dat_ctr.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-11-15 15:05:14 
// Last Modified  : 2024-12-30 14:18:39
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module emmc_dat_ctr
(
//Global Signals
input                           clk,
input                           clk_en,
input                           rstn,
//Configuration Signals
input           [1:0]           data_transfer_width,//[10]:8-line mode; [01]:4-line mode; [00]:1-line mode
input                           data_ddr_mode,//[0]:sdr mode [1]:ddr mode     
//Control Signals
input           [15:0]          bk_cnt,
input           [1:0]           dat_start,//[01]:write; [10]:read;
output  reg                     dat_busy,
input           [11:0]          bk_size,//Byte units.
input                           stop_at_block_gap_request,
input                           continue_request,
output  reg                     dat_crc_vld,
output  reg                     dat_crc_ok,
input           [1:0]           auto_cmd_enable,//00b:Auto CMD Disable; 01b:Auto CMD12 Enable; 10b:Auto CMD23 Enable
output  reg                     auto_cmd12_start,
input                           buf_wr_transfer_rdy,
input                           buf_rd_transfer_rdy,
output  reg                     wr_bk_transfer_done,
output  reg                     rd_bk_transfer_done,
output  reg                     stop_at_block_gap_done,
output  reg                     rd_pause,
//Tx Fifo Interface
input           [31:0]          ff_tx_data,
input                           ff_tx_vld,
output  reg                     ff_tx_rdy,
//Rx Fifo Interface
output  reg     [31:0]          ff_rx_data,
output  reg                     ff_rx_vld,
output  reg                     ff_rx_eop,
output  reg                     ff_rx_err,
//eMMC Interface
input                           emmc_dat_i_vld,
input           [15:0]          emmc_dat_i,
output  reg     [15:0]          emmc_dat_o,
output  reg                     emmc_dat_oe
//Status and  Error Signals
);

// Parameter Define 
parameter                       State_idle       = 3'd0;
parameter                       State_wr_wait    = 3'd1;
parameter                       State_wr_dat     = 3'd2;
parameter                       State_wr_resp    = 3'd3;
parameter                       State_wr_busy    = 3'd4;
parameter                       State_rd_wait    = 3'd5;
parameter                       State_rd_pre_dat = 3'd6;
parameter                       State_rd_dat     = 3'd7;

//Register Define
reg     [2:0]                   cur_state;
reg     [2:0]                   next_state;
reg     [14:0]                  bk_size_num;
reg     [15:0]                  bk_cnt_r;
reg     [14:0]                  dat_cnt;
reg     [31:0]                  dat_sr;
reg     [15:0]                  crc_dat;
reg     [15:0]                  emmc_dat_r;
reg     [1:0]                   resp_cnt;
reg     [2:0]                   resp_sr;
reg     [16*16-1:0]             crc_sr;
reg                             crc_rst;
reg                             crc_en;
reg     [15:0]                  emmc_dat_i_r;
reg     [15:0]                  rd_dat_crc_ok;
reg                             stop_at_block_gap_r;

//Wire Define
wire    [16*16-1:0]             crc_result;
wire                            crc_enable;
wire                            emmc_dat_no_busy_cycle;

genvar i;
/*----------------------------------------------------------------------------------*\
                                 The debug code
\*----------------------------------------------------------------------------------*/

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/

/*-------------------------------- FSM Region ------------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        cur_state <= State_idle;
    else if(clk_en == 1'b0)
        cur_state <= cur_state;
    else
        cur_state <= next_state;
end

always @(*)
begin
    case(cur_state)
    State_idle :
        if((dat_start == 2'b01) && (bk_cnt != 0))
            next_state = State_wr_wait;
        else if((dat_start == 2'b10) && (bk_cnt != 0))
            next_state = State_rd_wait;
        else
            next_state = State_idle;

    State_wr_wait :
        if(bk_cnt_r == 16'h0)
            next_state = State_idle;
        else if(buf_wr_transfer_rdy == 1'b1)
            next_state = State_wr_dat;
        else
            next_state = State_wr_wait;

    State_wr_dat :
        if((dat_cnt >= bk_size_num + 15'd23) && (emmc_dat_i_r[8] == 1'b0))
            next_state = State_wr_resp;
        else
            next_state = State_wr_dat;

    State_wr_resp :
        if(resp_cnt == 2'h3)
            next_state = State_wr_busy;
        else
            next_state = State_wr_resp;

    State_wr_busy :
        if((emmc_dat_i_r[8] == 1'b1) && (stop_at_block_gap_r == 1'b1))
            next_state = State_idle;
        else if(emmc_dat_i_r[8] == 1'b1)
            next_state = State_wr_wait;
        else
            next_state = State_wr_busy;

    State_rd_wait :
        if(bk_cnt_r == 16'h0)
            next_state = State_idle;
        else
            next_state = State_rd_pre_dat;

    State_rd_pre_dat :
        if(emmc_dat_i_r[8] == 1'b0)
            next_state = State_rd_dat;
        else
            next_state = State_rd_pre_dat;

    State_rd_dat :
        if((dat_cnt >= bk_size_num + 15'd20) && (stop_at_block_gap_r == 1'b1))
            next_state = State_idle;
        else if(dat_cnt >= bk_size_num + 15'd20)
            next_state = State_rd_wait;
        else
            next_state = State_rd_dat;

    default :
        next_state = State_idle;
    endcase
end

/*--------------------------- Common Logic Region --------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dat_busy <= 1'b0;
    else if(clk_en == 1'b0)
        dat_busy <= dat_busy;
    else if(cur_state == State_idle)
        dat_busy <= 1'b0;
    else
        dat_busy <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        bk_size_num <= 15'h0;
    else if(clk_en == 1'b0)
        bk_size_num <= bk_size_num;
    else if((data_transfer_width == 2'b10) && (data_ddr_mode == 1'b1) && (cur_state == State_idle))//8-line ddr mode
        bk_size_num <= {3'h0,bk_size>>1};
    else if((data_transfer_width == 2'b10) && (data_ddr_mode == 1'b0) && (cur_state == State_idle))//8-line sdr mode
        bk_size_num <= {3'h0,bk_size};
    else if((data_transfer_width == 2'b01) && (data_ddr_mode == 1'b1) && (cur_state == State_idle))//4-line ddr mode
        bk_size_num <= {3'h0,bk_size};
    else if((data_transfer_width == 2'b01) && (data_ddr_mode == 1'b0) && (cur_state == State_idle))//4-line sdr mode
        bk_size_num <= {2'h0,bk_size,1'h0};
    else if((data_transfer_width == 2'b00) && (data_ddr_mode == 1'b0) && (cur_state == State_idle))//1-line sdr mode
        bk_size_num <= {bk_size,3'h0};
end

// Number of blocks. when ck_en is 1,if the CRC check passes each time, the current block transmission is complete. The number of blocks decreases by 1
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        bk_cnt_r <= 16'h0;
    else if(clk_en == 1'b0)
        bk_cnt_r <= bk_cnt_r;
    else if((cur_state == State_idle) && ((dat_start == 2'b01) || (dat_start == 2'b10)))
        bk_cnt_r <= bk_cnt;
    else if(dat_crc_vld == 1'b1)
        bk_cnt_r <= bk_cnt_r - 1'b1;
end

// Data transfer count register, when ck_en is 1, increments by 1 per cycle in the State_wr_dat or State_rd_dat states.
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dat_cnt <= 15'h0;
    else if(clk_en == 1'b0)
        dat_cnt <= dat_cnt;
    else if((cur_state == State_wr_dat) || ((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1)))
        dat_cnt <= dat_cnt + 1'b1;
    else
        dat_cnt <= 15'h0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ff_tx_rdy <= 1'b0;
    else if(clk_en == 1'b0)
        ff_tx_rdy <= ff_tx_rdy;
    else if((cur_state == State_wr_dat)  && (dat_cnt < bk_size_num) && (
                ((data_transfer_width == 2'b10) && (data_ddr_mode == 1'b1) && (dat_cnt[0]   == 1'd0)) ||   //8-line ddr mode
                ((data_transfer_width == 2'b10) && (data_ddr_mode == 1'b0) && (dat_cnt[1:0] == 2'd0)) ||   //8-line sdr mode
                ((data_transfer_width == 2'b01) && (data_ddr_mode == 1'b1) && (dat_cnt[1:0] == 2'd0)) ||   //4-line ddr mode
                ((data_transfer_width == 2'b01) && (data_ddr_mode == 1'b0) && (dat_cnt[2:0] == 3'd0)) ||   //4-line sdr mode
                ((data_transfer_width == 2'b00) && (data_ddr_mode == 1'b0) && (dat_cnt[4:0] == 5'd0))      //1-line sdr mode
           ))
        ff_tx_rdy <= 1'b1;
    else
        ff_tx_rdy <= 1'h0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dat_sr <= 32'h0;
    else if(clk_en == 1'b0)
        dat_sr <= dat_sr;
    else if((cur_state == State_wr_dat) && (dat_cnt == 15'd0))
        dat_sr <= 32'h0;
    else if((cur_state == State_wr_dat) && (ff_tx_rdy == 1'b1) && (data_ddr_mode == 1'b1) && (data_transfer_width == 2'b01))
        dat_sr <= {ff_tx_data[31:28],ff_tx_data[23:20],ff_tx_data[27:24],ff_tx_data[19:16],ff_tx_data[15:12],ff_tx_data[7:4],ff_tx_data[11:8],ff_tx_data[3:0]};
    else if((cur_state == State_wr_dat) && (ff_tx_rdy == 1'b1))
        dat_sr <= ff_tx_data;
    else if((cur_state == State_wr_dat) && (data_ddr_mode == 1'b1) && (data_transfer_width == 2'b10))//8-line ddr mode
        dat_sr <= {dat_sr[15:0],16'b0};
    else if((cur_state == State_wr_dat) && (data_ddr_mode == 1'b0) && (data_transfer_width == 2'b10))//8-line sdr mode
        dat_sr <= {dat_sr[23:0],8'b0};
    else if((cur_state == State_wr_dat) && (data_ddr_mode == 1'b1) && (data_transfer_width == 2'b01))//4-line ddr mode
        dat_sr <= {dat_sr[23:0],8'b0};
    else if((cur_state == State_wr_dat) && (data_ddr_mode == 1'b0) && (data_transfer_width == 2'b01))//4-line sdr mode
        dat_sr <= {dat_sr[27:0],4'b0};
    else if((cur_state == State_wr_dat) && (data_ddr_mode == 1'b0) && (data_transfer_width == 2'b00))//1-line sdr mode
        dat_sr <= {dat_sr[30:0],1'b0};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_cnt <= 2'h0;
    else if(clk_en == 1'b0)
        resp_cnt <= resp_cnt;
    else if((cur_state == State_wr_resp) && (emmc_dat_i_vld == 1'b1))
        resp_cnt <= resp_cnt + 1'b1;
    else
        resp_cnt <= 2'h0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_sr <= 3'h0;
    else if(clk_en == 1'b0)
        resp_sr <= resp_sr;
    else if((cur_state == State_wr_resp) && (emmc_dat_i_vld == 1'b1) && (resp_cnt <= 2'h2))
        resp_sr <= {resp_sr[1:0],emmc_dat_i_r[8]};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dat_crc_vld <= 1'b0;
    else if(clk_en == 1'b0)
        dat_crc_vld <= dat_crc_vld;
    else if(((cur_state == State_wr_resp) && (resp_cnt == 2'h3)) ||
                ((cur_state == State_rd_dat) && (dat_cnt == bk_size_num + 15'd17)))
        dat_crc_vld <= 1'b1;
    else
        dat_crc_vld <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        dat_crc_ok <= 1'b0;
    else if(clk_en == 1'b0)
        dat_crc_ok <= dat_crc_ok;
    else if(
            ((cur_state == State_wr_resp) && (resp_cnt == 2'h3) && (resp_sr[2:0] == 3'b010)) ||
            ((data_ddr_mode == 1'b1) && (data_transfer_width == 2'b10) && (rd_dat_crc_ok[15:0] == {16{1'b1}})) ||                     //8-line mode,ddr
            ((data_ddr_mode == 1'b0) && (data_transfer_width == 2'b10) && (rd_dat_crc_ok[15:8] == {8{1'b1}})) ||                      //8-line mode,sdr
            ((data_ddr_mode == 1'b1) && (data_transfer_width == 2'b01) && ({rd_dat_crc_ok[12:8],rd_dat_crc_ok[3:0]} == {8{1'b1}})) || //4-line mode,ddr
            ((data_ddr_mode == 1'b0) && (data_transfer_width == 2'b01) && (rd_dat_crc_ok[12:8] == {4{1'b1}})) ||                      //4-line mode,sdr
            ((data_transfer_width == 2'b00) && (rd_dat_crc_ok[8] == 1'b1))                                                            //1-line mode,only sdr
           )
        dat_crc_ok <= 1'b1;
    else
        dat_crc_ok <= 1'b0;
end

generate
for(i=0; i<16; i=i+1)
begin : rd_dat_crc
    always @(posedge clk or negedge rstn)
    begin
        if(rstn == 1'b0)
            rd_dat_crc_ok[i] <= 1'b0;
        else if(clk_en == 1'b0)
            rd_dat_crc_ok[i] <= rd_dat_crc_ok[i];
        else if((cur_state == State_rd_dat) && (dat_cnt == bk_size_num + 15'd16) && 
                        (crc_sr[i*16 +: 16] == crc_result[i*16 +: 16]))
            rd_dat_crc_ok[i] <= 1'b1;
        else
            rd_dat_crc_ok[i] <= 1'b0;
    end
end
endgenerate

assign emmc_dat_no_busy_cycle = dat_crc_vld;

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        auto_cmd12_start <= 1'b0;
    else if(clk_en == 1'b0)
        auto_cmd12_start <= auto_cmd12_start;
`ifndef SIM_MODE
    else if((auto_cmd_enable == 2'h1) && 
            (((cur_state == State_rd_dat) && (dat_cnt == bk_size_num +15'd15 -15'd49 -15'd3 -15'd5) && ((bk_cnt_r == 16'h1) || (stop_at_block_gap_r == 1'b1))) || //15,crc cycle  49,cmd cycle, 3,auto_cmd12_start to cmd begin, 5,ddio to emmc_dat_ctr
             ((cur_state == State_wr_busy) && (emmc_dat_i_vld == 1'b1) && (emmc_dat_i_r[8] == 1'b1) && ((bk_cnt_r == 16'h0) || ((bk_cnt_r == 16'h1) && (emmc_dat_no_busy_cycle == 1'b1)) || (stop_at_block_gap_r == 1'b1)))))
        auto_cmd12_start <= 1'b1;
`else
    else if((auto_cmd_enable == 2'h1) && ((cur_state == State_wr_dat) || (cur_state == State_rd_dat)) &&
            (dat_cnt == bk_size_num-15'd24) && ((bk_cnt_r == 16'h1) || (stop_at_block_gap_r == 1'b1)))
        auto_cmd12_start <= 1'b1;
`endif
    else
        auto_cmd12_start <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        wr_bk_transfer_done <= 1'b0;
    else if(clk_en == 1'b0)
        wr_bk_transfer_done <= wr_bk_transfer_done;
    `ifndef SIM_MODE 
    else if((cur_state == State_wr_busy) && (emmc_dat_i_vld == 1'b1) && (emmc_dat_i_r[8] == 1'b1))
    `else
    else if((cur_state == State_wr_busy) )
    `endif
        wr_bk_transfer_done <= 1'b1;
    else
        wr_bk_transfer_done <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        rd_bk_transfer_done <= 1'b0;
    else if(clk_en == 1'b0)
        rd_bk_transfer_done <= rd_bk_transfer_done;
    else if((cur_state == State_rd_dat) && (dat_cnt >= bk_size_num + 15'd20))
        rd_bk_transfer_done <= 1'b1;
    else
        rd_bk_transfer_done <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        stop_at_block_gap_r <= 1'b0;
    else if(clk_en == 1'b0)
        stop_at_block_gap_r <= stop_at_block_gap_r;
`ifndef SIM_MODE
    else if((stop_at_block_gap_request == 1'b1) && 
            (((cur_state == State_rd_dat) && (dat_cnt < bk_size_num-15'd24)) ||
            ((cur_state == State_wr_busy) && (emmc_dat_i_vld == 1'b1) && (emmc_dat_i_r[8] == 1'b0))))
        stop_at_block_gap_r <= 1'b1;
`else
    else if((stop_at_block_gap_request == 1'b1) && 
            (((cur_state == State_rd_dat) && (dat_cnt < bk_size_num-15'd24)) ||
            ((cur_state == State_wr_dat) && (dat_cnt < bk_size_num-15'd24))))
        stop_at_block_gap_r <= 1'b1;
`endif
    else if(stop_at_block_gap_done == 1'b1)
        stop_at_block_gap_r <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        stop_at_block_gap_done <= 1'b0;
    else if(clk_en == 1'b0)
        stop_at_block_gap_done <= stop_at_block_gap_done;
    else if((stop_at_block_gap_r == 1'b1) && 
            (((cur_state == State_rd_dat) && (dat_cnt >= bk_size_num + 15'd20)) ||
             ((cur_state == State_wr_busy) && (emmc_dat_i_vld == 1'b1) && (emmc_dat_i_r[8] == 1'b1))))
        stop_at_block_gap_done <= 1'b1;
    else
        stop_at_block_gap_done <= 1'b0;
end

assign buf_bk_almfull = ~buf_rd_transfer_rdy;

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        rd_pause <= 1'b0;
    else if(clk_en == 1'b0)
        rd_pause <= rd_pause;
    // else if((buf_bk_almfull == 1'b1) && (cur_state == State_rd_dat) && (bk_cnt_r >= 16'h2) && (dat_cnt == bk_size_num + 15'd15 - 15'd1 - 15'd1 - 15'd3))//15'd9: the delay from ddio to this module 
    else if((buf_bk_almfull == 1'b1) && (cur_state == State_rd_dat) && (bk_cnt_r >= 16'h2) && (dat_cnt == bk_size_num + 15'd16 - 15'd2 - 15'd6 - 15'd1 + 15'd2) && (stop_at_block_gap_request == 1'b0))//: input delay: ddio align  2 emmc cycle, cdc fifo 6~7 base(200m) cycle,this module reg 1 emmc cycle ; output delay: rd_pause to emmc clk stop 2 emmc cycle
        rd_pause <= 1'b1;
    else if(buf_bk_almfull == 1'b0)
        rd_pause <= 1'b0;
end

/*--------------------------------- CRC Region -----------------------------*/
assign crc_enable = crc_en & clk_en;
generate
for(i=0; i<16; i=i+1)
begin : emmc_crc
    emmc_crc_16 u_emmc_crc_16(
        .BITVAL                             (crc_dat[i]                         ),
        .ENABLE                             (crc_enable                         ),
        .BITSTRB                            (clk                                ),
        .CLEAR                              (crc_rst                            ),
        .CRC                                (crc_result[i*16 +: 16]             )
    );
    always @(posedge clk or negedge rstn)
    begin
        if(rstn == 1'b0)
            crc_sr[i*16 +: 16] <= 16'h0;
        else if(clk_en == 1'b0)
            crc_sr[i*16 +: 16] <= crc_sr[i*16 +: 16];
        else if((cur_state == State_wr_dat) && (dat_cnt == bk_size_num + 15'd3))
            crc_sr[i*16 +: 16] <= crc_result[i*16 +: 16];
        else if(cur_state == State_wr_dat)
            crc_sr[i*16 +: 16] <= {crc_sr[i*16 +: 15],1'b0};
        else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt >= bk_size_num) && (dat_cnt <= bk_size_num + 15'd15))
            crc_sr[i*16 +: 16] <= {crc_sr[i*16 +: 15],emmc_dat_i_r[i]};
    end

     always @(posedge clk or negedge rstn)
    begin
        if(rstn == 1'b0)
            crc_dat[i] <= 1'b0;
        else if(clk_en == 1'b0)
            crc_dat[i] <= crc_dat[i];
        else if((cur_state == State_wr_dat) && (dat_cnt >= 15'd2))
            crc_dat[i] <= dat_sr[i+16];
        else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1))
            crc_dat[i] <= emmc_dat_i_r[i];
        else
            crc_dat[i] <= 1'b0;
    end
end
endgenerate

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        crc_rst <= 1'b1;
    else if(clk_en == 1'b0)
        crc_rst <= crc_rst;
    else if((cur_state == State_wr_dat) || (cur_state == State_rd_dat))
        crc_rst <= 1'b0;
    else
        crc_rst <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        crc_en <= 1'b0;
    else if(clk_en == 1'b0)
        crc_en <= crc_en;
    else if(((cur_state == State_wr_dat) && (dat_cnt >= 15'd2) && (dat_cnt <= bk_size_num + 15'd1)) ||
                ((cur_state == State_rd_dat) && (dat_cnt < bk_size_num)))
        crc_en <= 1'b1;
    else
        crc_en <= 1'b0;
end

/*------------------------- eMMC Data Output Region ------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_dat_r <= {16{1'b1}};
    else if(clk_en == 1'b0)
        emmc_dat_r <= emmc_dat_r;
    else if(data_transfer_width == 2'b10)//8-line mode
        begin
            if(data_ddr_mode == 1'b0)
                begin
                    emmc_dat_r[15:8] <= crc_dat[15:8];
                    emmc_dat_r[7:0]  <= crc_dat[15:8];
                end
            else 
                begin
                    emmc_dat_r[15:8] <= crc_dat[15:8];
                    emmc_dat_r[7:0]  <= crc_dat[7:0];
                end
        end
    else if(data_transfer_width == 2'b01)//4-line mode
        begin
            if(data_ddr_mode == 1'b0)
                begin
                    emmc_dat_r[15:8] <= {{4{1'b1}},crc_dat[15:12]};
                    emmc_dat_r[7:0]  <= {{4{1'b1}},crc_dat[15:12]};
                end
            else
                begin
                    emmc_dat_r[15:8] <= {{4{1'b1}},crc_dat[15:12]};
                    emmc_dat_r[7:0]  <= {{4{1'b1}},crc_dat[11:8]};
                end
        end
    else if(data_transfer_width == 2'b00)//1-line mode
        begin
            if(data_ddr_mode == 1'b0)
                begin
                    emmc_dat_r[15:8] <= {{7{1'b1}},crc_dat[15]};
                    emmc_dat_r[7:0]  <= {{7{1'b1}},crc_dat[15]};
                end
        end
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_dat_o <= {16{1'b1}};
    else if(clk_en == 1'b0)
        emmc_dat_o <= emmc_dat_o;
    else if((cur_state == State_wr_dat) && (dat_cnt >= 15'd3) && (dat_cnt <= bk_size_num + 15'd3))
        begin
            if(data_transfer_width == 2'b10)//8-line mode
                begin
                    if(data_ddr_mode == 1'b0)//sdr mode
                        begin
                            emmc_dat_o[15:8] <= emmc_dat_r[7:0];
                            emmc_dat_o[7:0]  <= emmc_dat_r[7:0];
                        end
                    else//ddr mode
                        begin
                            emmc_dat_o[15:8] <= emmc_dat_r[15:8];
                            emmc_dat_o[7:0]  <= emmc_dat_r[7:0];
                        end
                end
            else if(data_transfer_width == 2'b01)//4-line mode
                begin
                    if(data_ddr_mode == 1'b0)//sdr mode
                        begin
                            emmc_dat_o[15:8] <= {{4{1'b1}},emmc_dat_r[3:0]};
                            emmc_dat_o[7:0]  <= {{4{1'b1}},emmc_dat_r[3:0]};
                        end
                    else//ddr mode
                        begin
                            emmc_dat_o[15:8] <= {{4{1'b1}},emmc_dat_r[11:8]};
                            emmc_dat_o[7:0]  <= {{4{1'b1}},emmc_dat_r[3:0]};
                        end
                end
            else if(data_transfer_width == 2'b00)//1-line mode
                begin
                    if(data_ddr_mode == 1'b0)//sdr mode
                        begin
                            emmc_dat_o[15:8] <= {{7{1'b1}},emmc_dat_r[8]};
                            emmc_dat_o[7:0] <= {{7{1'b1}},emmc_dat_r[0]};
                        end
                end
        end
    else if((cur_state == State_wr_dat) && (dat_cnt >= bk_size_num + 15'd4) && (dat_cnt <= bk_size_num + 15'd19))
        begin
            if(data_transfer_width == 2'b10)//8-line mode
                begin
                    if(data_ddr_mode == 1'b0)//sdr mode
                        begin
                            emmc_dat_o[15:8] <= {crc_sr[255],crc_sr[239],crc_sr[223],crc_sr[207],crc_sr[191],crc_sr[175],crc_sr[159],crc_sr[143]};
                            emmc_dat_o[7:0]  <= {crc_sr[255],crc_sr[239],crc_sr[223],crc_sr[207],crc_sr[191],crc_sr[175],crc_sr[159],crc_sr[143]};
                        end
                    else
                        begin
                            emmc_dat_o[15:8] <= {crc_sr[255],crc_sr[239],crc_sr[223],crc_sr[207],crc_sr[191],crc_sr[175],crc_sr[159],crc_sr[143]};
                            emmc_dat_o[7:0]  <= {crc_sr[127],crc_sr[111],crc_sr[95],crc_sr[79],crc_sr[63],crc_sr[47],crc_sr[31],crc_sr[15]};
                        end
                end
            else if(data_transfer_width == 2'b01)//4-line mode
                begin
                    if(data_ddr_mode == 1'b0)
                        begin
                            emmc_dat_o[15:8] <= {{4{1'b1}},crc_sr[255],crc_sr[239],crc_sr[223],crc_sr[207]};
                            emmc_dat_o[7:0]  <= {{4{1'b1}},crc_sr[255],crc_sr[239],crc_sr[223],crc_sr[207]};
                        end
                    else
                        begin
                            emmc_dat_o[15:8] <= {{4{1'b1}},crc_sr[255],crc_sr[239],crc_sr[223],crc_sr[207]};
                            emmc_dat_o[7:0]  <= {{4{1'b1}},crc_sr[191],crc_sr[175],crc_sr[159],crc_sr[143]};
                        end
                end
            else if(data_transfer_width == 2'b00)//1-line mode
                begin
                    if(data_ddr_mode == 1'b0)
                        begin
                            emmc_dat_o[15:8] <= {{7{1'b1}},crc_sr[255]};
                            emmc_dat_o[7:0]  <= {{7{1'b1}},crc_sr[255]};
                        end
                end
        end
    else
        emmc_dat_o <= {16{1'b1}};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_dat_oe <= 1'b0;
    else if(clk_en == 1'b0)
        emmc_dat_oe <= emmc_dat_oe;
    else if((cur_state == State_wr_dat) && (dat_cnt >= 15'd3) && (dat_cnt <= bk_size_num + 15'd20))
        emmc_dat_oe <= 1'b1;
    else
        emmc_dat_oe <= 1'b0;
end

/*----------------------- eMMC Data Input Region ---------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_dat_i_r <= 16'h0;
    else if((emmc_dat_i_vld == 1'b1) && (clk_en == 1'b1))
        emmc_dat_i_r <= emmc_dat_i;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ff_rx_data <= 32'h0;
    else if(clk_en == 1'b0)
        ff_rx_data <= ff_rx_data;
    else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt < bk_size_num) && (data_ddr_mode == 1'b1) && (data_transfer_width == 2'b10))//8-line ddr mode
        ff_rx_data <= {ff_rx_data[15:0],emmc_dat_i_r};
    else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt < bk_size_num) && (data_ddr_mode == 1'b0) && (data_transfer_width == 2'b10))//8-line sdr mode
        ff_rx_data <= {ff_rx_data[23:0],emmc_dat_i_r[15:8]};
    else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt < bk_size_num) && (data_ddr_mode == 1'b1) && (data_transfer_width == 2'b01) && (dat_cnt[1:0] == 2'b11))//4-line ddr mode
        ff_rx_data <= {ff_rx_data[23:20],ff_rx_data[15:12],ff_rx_data[19:16],ff_rx_data[11:8],ff_rx_data[7:4],emmc_dat_i_r[11:8],ff_rx_data[3:0],emmc_dat_i_r[3:0]};
    else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt < bk_size_num) && (data_ddr_mode == 1'b1) && (data_transfer_width == 2'b01))//4-line ddr mode
        ff_rx_data <= {ff_rx_data[23:0],{emmc_dat_i_r[11:8],emmc_dat_i_r[3:0]}};
    else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt < bk_size_num) && (data_ddr_mode == 1'b0) && (data_transfer_width == 2'b01))//4-line sdr mode
        ff_rx_data <= {ff_rx_data[27:0],emmc_dat_i_r[11:8]};
    else if((cur_state == State_rd_dat) && (emmc_dat_i_vld == 1'b1) && (dat_cnt < bk_size_num) && (data_ddr_mode == 1'b0) && (data_transfer_width == 2'b00))//1-line sdr mode
        ff_rx_data <= {ff_rx_data[30:0],emmc_dat_i_r[8]};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ff_rx_vld <= 1'b0;
    else if(clk_en == 1'b0)
        ff_rx_vld <= ff_rx_vld;
    else if((cur_state == State_rd_dat) && ((dat_crc_vld == 1'b1) || ((dat_cnt < bk_size_num - 1'b1) && (
                    ((data_transfer_width == 2'b10) && (data_ddr_mode == 1'b1) && (dat_cnt[0]   == {1{1'b1}})) ||   //8-line ddr mode
                    ((data_transfer_width == 2'b10) && (data_ddr_mode == 1'b0) && (dat_cnt[1:0] == {2{1'b1}})) ||   //8-line sdr mode
                    ((data_transfer_width == 2'b01) && (data_ddr_mode == 1'b1) && (dat_cnt[1:0] == {2{1'b1}})) ||   //4-line ddr mode
                    ((data_transfer_width == 2'b01) && (data_ddr_mode == 1'b0) && (dat_cnt[2:0] == {3{1'b1}})) ||   //4-line sdr mode
                    ((data_transfer_width == 2'b00) && (data_ddr_mode == 1'b0) && (dat_cnt[4:0] == {5{1'b1}}))      //1-line sdr mode
                    ))   
            ))
        ff_rx_vld <= 1'b1;
    else
        ff_rx_vld <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ff_rx_eop <= 1'b0;
    else if(clk_en == 1'b0)
        ff_rx_eop <= ff_rx_eop;
    else if((cur_state == State_rd_dat) && (dat_crc_vld == 1'b1))
        ff_rx_eop <= 1'b1;
    else
        ff_rx_eop <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        ff_rx_err <= 1'b0;
    else if(clk_en == 1'b0)
        ff_rx_err <= ff_rx_err;
    else if((cur_state == State_rd_dat) && (dat_crc_vld == 1'b1) && (dat_crc_ok == 1'b0))
        ff_rx_err <= 1'b1;
    else
        ff_rx_err <= 1'b0;
end

//Encryption end
endmodule

