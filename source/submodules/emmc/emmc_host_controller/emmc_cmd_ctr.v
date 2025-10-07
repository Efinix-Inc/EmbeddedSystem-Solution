//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : emmc_cmd_ctr.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-12-12 14:33:21 
// Last Modified  : 2024-12-13 13:50:41
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module emmc_cmd_ctr
(
//Global Signals
input                           clk,
input                           clk_en,
input                           rstn,
//Control Signals
input                           cmd_start,
output  reg                     cmd_busy,
input           [37:0]          cmd,//[37:32]=command index; [31:0]=argument;
input           [1:0]           cmd_resp_type,//00b:No Response; 01b:Response Length 136; 10b: Response Length 48; 11b: Response Length 48 check Busy after response;
input                           data_transfer_direction_select,
input                           cmd_crc_chk_en,
input                           cmd_index_chk_en,
input                           data_present,
output  reg     [119:0]         resp,
output  reg                     resp_vld,
output  reg     [4:0]           resp_err,
output  reg                     auto_cmd_en,
input                           auto_cmd12_start,
output  reg                     end_bit_of_cmd,
//eMMC Interface
input                           emmc_dat_i_vld,
input                           emmc_dat_i,
input                           emmc_cmd_i_vld,
input                           emmc_cmd_i,
output  reg                     emmc_cmd_o,
output  reg                     emmc_cmd_oe
//Status and  Error Signals

);
//Parameter Define 
parameter                       State_idle     = 3'd0;
parameter                       State_cmd      = 3'd1;
parameter                       State_RespWait = 3'd2;
parameter                       State_resp     = 3'd3;
parameter                       State_busy     = 3'd4;
parameter                       State_end      = 3'd5;

//Register Define
reg     [2:0]                   cur_state;
reg     [2:0]                   next_state;
reg     [7:0]                   bit_cnt;
reg     [39:0]                  cmd_sr;
reg     [1:0]                   cmd_resp_type_r;
reg                             cmd_crc_chk_en_r;
reg                             cmd_index_chk_en_r;
reg                             data_present_r;
reg                             crc_rst;
reg                             crc_bit;
reg                             crc_bit_en;
reg     [6:0]                   crc_sr;
reg                             emmc_busy;
reg                             emmc_cmd_i_r;
reg     [5:0]                   cmd_index;
reg     [5:0]                   resp_index;
reg     [7:0]                   timeout_cnt;
reg                             emmc_cmd_r;

//Wire Define
wire    [6:0]                   crc_result;
wire                            crc_enable;

/*----------------------------------------------------------------------------------*\
                                 The debug code
\*----------------------------------------------------------------------------------*/

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/

/*------------------------------- FSM Region -------------------------------*/
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
        if((cmd_start == 1'b1) || (auto_cmd12_start == 1'b1))
            next_state = State_cmd;
        else
            next_state = State_idle;

    State_cmd :
        if((bit_cnt >= 8'd49) && (cmd_resp_type_r != 2'h0))
            next_state = State_RespWait;
        else if(bit_cnt >= 8'd49)
            next_state = State_end;
        else
            next_state = State_cmd;

    State_RespWait :
        if(timeout_cnt >= 8'd64)
            next_state = State_end;
        else if((emmc_cmd_i_r == 1'b0) && (emmc_cmd_oe == 1'b0))
            next_state = State_resp;
        else
            next_state = State_RespWait;
    
    State_resp :
        if(((cmd_resp_type_r == 2'b10) && (bit_cnt == 8'd46)) ||
           ((cmd_resp_type_r == 2'b01) && (bit_cnt == 8'd134)))
            next_state = State_end;
        else if((cmd_resp_type_r == 2'b11) && (bit_cnt == 8'd46))
            `ifndef SIM_MODE 
            next_state = State_busy;
            `else
            next_state = State_end;
            `endif
        else
            next_state = State_resp;

    State_busy :
        if(emmc_busy == 1'b0)
            next_state = State_end;
        else
            next_state = State_busy;

    State_end : 
        next_state = State_idle;

    default :
        next_state = State_idle;
    endcase
end

/*---------------------------- Bit Counter Region --------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        bit_cnt <= 8'h0;
    else if(clk_en == 1'b0)
        bit_cnt <= bit_cnt;
    else if((cur_state == State_cmd) || ((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)))
        bit_cnt <= bit_cnt + 1'b1;
    else
        bit_cnt <= 8'h0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        cmd_sr <= 40'h0;
    else if(clk_en == 1'b0)
        cmd_sr <= cmd_sr;
    else if((cur_state == State_idle) && (cmd_start == 1'b1))
        cmd_sr <= {2'b01,cmd};
    else if((cur_state == State_idle) && (auto_cmd12_start == 1'b1))
        cmd_sr <= {2'b01,{6'd12,32'h0}};
    else if(cur_state == State_cmd)
        cmd_sr <= {cmd_sr[38:0],1'b0};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        begin
            cmd_resp_type_r <= 2'h0;
            cmd_crc_chk_en_r <= 1'h0;
            cmd_index_chk_en_r <= 1'h0;
            data_present_r <= 1'h0;
        end
    else if(clk_en == 1'b0)
        begin
            cmd_resp_type_r <= cmd_resp_type_r;
            cmd_crc_chk_en_r <= cmd_crc_chk_en_r;
            cmd_index_chk_en_r <= cmd_index_chk_en_r;
            data_present_r <= data_present_r;
        end
    else if((cur_state == State_idle) && (cmd_start == 1'b1))
        begin
            cmd_resp_type_r <= cmd_resp_type;
            cmd_crc_chk_en_r <= cmd_crc_chk_en;
            cmd_index_chk_en_r <= cmd_index_chk_en;
            data_present_r <= data_present;
        end
    else if((cur_state == State_idle) && (auto_cmd12_start == 1'b1) && (data_transfer_direction_select == 1'b0))
        begin
            cmd_resp_type_r <= 2'b11;
            cmd_crc_chk_en_r <= 1'b1;
            cmd_index_chk_en_r <= 1'b1;
            data_present_r <= 1'h0;
        end
    else if((cur_state == State_idle) && (auto_cmd12_start == 1'b1) && (data_transfer_direction_select == 1'b1))
        begin
            cmd_resp_type_r <= 2'b10;
            cmd_crc_chk_en_r <= 1'b1;
            cmd_index_chk_en_r <= 1'b1;
            data_present_r <= 1'h0;
        end
end

/*-------------------------------- CRC Region ------------------------------*/
assign crc_enable = crc_bit_en & clk_en;
emmc_crc_7 u_emmc_crc_7(
    .BITVAL                             (crc_bit                            ),
    .ENABLE                             (crc_enable                         ),
    .BITSTRB                            (clk                                ),
    .CLEAR                              (crc_rst                            ),
    .CRC                                (crc_result                         )
);

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        crc_rst <= 1'b1;
    else if(clk_en == 1'b0)
        crc_rst <= crc_rst;
    else if((cur_state == State_cmd) || ((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)))
        crc_rst <= 1'b0;
    else
        crc_rst <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        begin
            crc_bit <= 1'b0;
            crc_bit_en <= 1'b0;
        end
    else if(clk_en == 1'b0)
        begin
            crc_bit <= crc_bit;
            crc_bit_en <= crc_bit_en;
        end
    else if((cur_state == State_cmd) && (bit_cnt < 8'd40))
        begin
            crc_bit <= cmd_sr[39];
            crc_bit_en <= 1'b1;
        end
    else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && ((((cmd_resp_type_r == 2'b10)||(cmd_resp_type_r == 2'b11)) && (bit_cnt <= 8'd38)) ||
                    ((cmd_resp_type_r == 2'b01) && (bit_cnt >= 8'd7) && (bit_cnt <= 8'd126))))
        begin
            crc_bit <= emmc_cmd_i_r;
            crc_bit_en <= 1'b1;
        end
    else
        begin
            crc_bit <= 1'b0;
            crc_bit_en <= 1'b0;
        end
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        crc_sr <= 7'h0;
    else if(clk_en == 1'b0)
        crc_sr <= crc_sr;
    else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && ((((cmd_resp_type_r == 2'b10)||(cmd_resp_type_r == 2'b11)) && (bit_cnt >= 8'd39) && (bit_cnt <= 8'd45)) ||
                ((cmd_resp_type_r == 2'b01) && (bit_cnt >= 8'd127) && (bit_cnt <= 8'd133))))
        crc_sr <= {crc_sr[5:0],emmc_cmd_i_r};
    else if((cur_state == State_cmd) && (bit_cnt == 8'd41))
        crc_sr <= crc_result;
    else if(cur_state == State_cmd)
        crc_sr <= {crc_sr[5:0],1'b0};
end

/*------------------------- eMMC Command Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_cmd_r <= 1'b1;
    else if(clk_en == 1'b0)
        emmc_cmd_r <= emmc_cmd_r;
    else
        emmc_cmd_r <= crc_bit;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_cmd_o <= 1'b1;
    else if(clk_en == 1'b0)
        emmc_cmd_o <= emmc_cmd_o;
    else if((cur_state == State_cmd) && (bit_cnt >= 8'd2) && (bit_cnt <= 8'd41))
        emmc_cmd_o <= emmc_cmd_r;
    else if((cur_state == State_cmd) && (bit_cnt >= 8'd42) && (bit_cnt <= 8'd48))
        emmc_cmd_o <= crc_sr[6];
    else
        emmc_cmd_o <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_cmd_oe <= 1'b0;
    else if(clk_en == 1'b0)
        emmc_cmd_oe <= emmc_cmd_oe;
    else if((cur_state == State_cmd) && (bit_cnt >= 8'd1) && (bit_cnt <= 8'd49))
        emmc_cmd_oe <= 1'b1;
    else
        emmc_cmd_oe <= 1'b0;
end

/*------------------------ eMMC Response Region ----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_busy <= 1'b0;
    else if((emmc_dat_i_vld == 1'b1) && (clk_en == 1'b1))
        emmc_busy <= ~emmc_dat_i;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        emmc_cmd_i_r <= 1'b0;
    else if((emmc_cmd_i_vld == 1'b1) && (clk_en == 1'b1))
        emmc_cmd_i_r <= emmc_cmd_i;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        cmd_index <= 6'h0;
    else if(clk_en == 1'b0)
        cmd_index <= cmd_index;
    else if((cur_state == State_idle) && (cmd_start == 1'b1))
        cmd_index <= cmd[37:32];
    else if((cur_state == State_idle) && (auto_cmd12_start == 1'b1))
        cmd_index <= 6'd12;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_index <= 6'h0;
    else if(clk_en == 1'b0)
        resp_index <= resp_index;
    else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && (bit_cnt >= 8'd1) && (bit_cnt <= 8'd6))
        resp_index <= {resp_index[4:0],emmc_cmd_i_r};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp <= 120'h0;
    else if(clk_en == 1'b0)
        resp <= resp;
    else if(cur_state == State_idle)
        resp <= 120'h0;
    else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && 
             ((((cmd_resp_type_r == 2'b10)||(cmd_resp_type_r == 2'b11)) && (bit_cnt >= 8'd7) && (bit_cnt <= 8'd38)) ||
                  ((cmd_resp_type_r == 2'b01) && (bit_cnt >= 8'd7) && (bit_cnt <= 8'd126))))
        resp <= {resp[118:0],emmc_cmd_i_r};
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_vld <= 1'b0;
    else if(clk_en == 1'b0)
        resp_vld <= resp_vld;
    else if(cur_state == State_end)
        resp_vld <= 1'b1;
    else
        resp_vld <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        auto_cmd_en <= 1'b0;
    else if(clk_en == 1'b0)
        auto_cmd_en <= auto_cmd_en;
    else if((cur_state == State_idle) && (auto_cmd12_start == 1'b1))
        auto_cmd_en <= 1'b1;
    else if(resp_vld == 1'b1)
        auto_cmd_en <= 1'b0;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        timeout_cnt <= 8'h0;
    else if(clk_en == 1'b0)
        timeout_cnt <= timeout_cnt;
    else if(cur_state == State_RespWait)
        timeout_cnt <= timeout_cnt + 1'b1;
    else
        timeout_cnt <= 8'h0;
end

//resp_timeout_err
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_err[0] <= 1'b0;
    else if(clk_en == 1'b0)
        resp_err[0] <= resp_err[0];
    else if(cur_state == State_idle)
        resp_err[0] <= 1'b0;
    else if((cur_state == State_RespWait) && (timeout_cnt >= 8'd64))
        resp_err[0] <= 1'b1;
end

//resp_trs_bit_err
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_err[1] <= 1'b0;
    else if(clk_en == 1'b0)
        resp_err[1] <= resp_err[1];
    else if(cur_state == State_idle)
        resp_err[1] <= 1'b0;
    else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && (bit_cnt == 8'd0) && (emmc_cmd_i_r == 1'b1))
        resp_err[1] <= 1'b1;
end

//resp_cmd_index_err
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_err[2] <= 1'b0;
    else if(clk_en == 1'b0)
        resp_err[2] <= resp_err[2];
    else if((cur_state == State_idle) || (cmd_index_chk_en_r == 1'b0))
        resp_err[2] <= 1'b0;
    else if((cur_state == State_resp) && (bit_cnt == 8'd7) && (resp_index != cmd_index))
    // else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && (bit_cnt == 8'd7) && (resp_index != cmd_index))
        resp_err[2] <= 1'b1;
end

//resp_crc_err
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_err[3] <= 1'b0;
    else if(clk_en == 1'b0)
        resp_err[3] <= resp_err[3];
    else if((cur_state == State_idle) || (cmd_crc_chk_en_r == 1'b0))
        resp_err[3] <= 1'b0;
    else if((cur_state == State_resp) && (crc_sr != crc_result) && 
              ((((cmd_resp_type_r == 2'b10)||(cmd_resp_type_r == 2'b11)) && (bit_cnt == 8'd46)) || 
                 ((cmd_resp_type_r == 2'b01) && (bit_cnt == 8'd134))))
        resp_err[3] <= 1'b1;
end

//resp_end_bit_err
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        resp_err[4] <= 1'b0;
    else if(clk_en == 1'b0)
        resp_err[4] <= resp_err[4];
    else if(cur_state == State_idle)
        resp_err[4] <= 1'b0;
    else if(((cur_state == State_resp) && (emmc_cmd_i_vld == 1'b1)) && (emmc_cmd_i_r == 1'b0) && 
              ((((cmd_resp_type_r == 2'b10)||(cmd_resp_type_r == 2'b11)) && (bit_cnt == 8'd46)) || 
                 ((cmd_resp_type_r == 2'b01) && (bit_cnt == 8'd134))))
        resp_err[4] <= 1'b1;
end

/*------------------------------ Common Region -----------------------------*/
always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        cmd_busy <= 1'b0;
    else if(clk_en == 1'b0)
        cmd_busy <= cmd_busy;
    else if(cur_state == State_idle)
        cmd_busy <= 1'b0;
    else
        cmd_busy <= 1'b1;
end

always @(posedge clk or negedge rstn)
begin
    if(rstn == 1'b0)
        end_bit_of_cmd <= 1'b0;
    else if(clk_en == 1'b0)
        end_bit_of_cmd <= end_bit_of_cmd;
    else if((cur_state == State_cmd) && (bit_cnt == 8'd49) && (data_present_r == 1'b1)) 
        end_bit_of_cmd <= 1'b1;
    else
        end_bit_of_cmd <= 1'b0;
end

//Encryption end
endmodule
