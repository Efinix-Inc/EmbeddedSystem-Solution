//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : reg_axi4_lite.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-12-12 11:35:24 
// Last Modified  : 2025-04-14 13:46:23
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps
module reg_axi4_lite#(
    parameter                       ADDR_WTH = 10,
    parameter                       VERSION = 32'h10,
    parameter                       BASE_CLK_FREQ = 200,
    parameter                       MAX_BLOCK_LEN = 512
)
(
//Global Signals

//AXI4-Lite Interface
input                           s_axi_aclk,   //AXI Bus Clock.
input                           s_axi_aresetn,//AXI Reset. Active-Low.
input           [ADDR_WTH-1:0]  s_axi_awaddr, //Write Address. byte address.
input                           s_axi_awvalid,//Write address valid.
output  reg                     s_axi_awready,//Write address ready.
input           [31:0]          s_axi_wdata,  //Write data bus.
input           [3:0]           s_axi_wstrb,
input                           s_axi_wvalid, //Write valid.
output  reg                     s_axi_wready, //Write ready.
output  wire    [1:0]           s_axi_bresp,  //Write response.
output  reg                     s_axi_bvalid, //Write response valid.
input                           s_axi_bready, //Response ready.
input           [ADDR_WTH-1:0]  s_axi_araddr, //Read address. byte address.
input                           s_axi_arvalid,//Read address valid.
output  reg                     s_axi_arready,//Read address ready.
output  wire    [1:0]           s_axi_rresp,  //Read response.
output  reg     [31:0]          s_axi_rdata,  //Read data.
output  reg                     s_axi_rvalid, //Read valid.
output  wire                    s_axi_rlast,  //Read last.
input                           s_axi_rready, //Read ready.
//Auxiliary Signals
output  reg                     emmc_int,
//Cfg Space Registers
//--Base Configuration Registers Field
output  reg                     clk_out_en,
output  reg     [15:0]          clk_out_div,

//--Sampling Clock Phase Dynamic Adjustment Registers Field
output  reg     [2:0]           cpu_shift,               
output  reg                     cpu_shift_ena,
output  reg     [15:0]          sample_cnt,

//--eMMC Host Control Registers Field
output  reg     [31:0]          argument_2,//unused
output  reg     [11:0]          block_size,
output  reg     [2:0]           sdma_buff_boundary,//unused
output  reg     [15:0]          block_count,
output  reg     [31:0]          argument_1,
output  reg                     dma_enable,
output  reg                     block_count_enable,//intnal
output  reg     [1:0]           auto_cmd_enable,
output  reg                     data_transfer_direction_select,//intnal
output  reg                     multi_or_single_block_select,//unused
output  reg     [1:0]           response_type_select,
output  reg                     command_crc_check_enable,
output  reg                     command_index_check_enable,
output  reg                     data_present_select,
output  reg     [1:0]           command_type,//unused
output  reg     [5:0]           command_index,
output  reg     [127:0]         response,//intnal
output  reg                     command_inhibit_cmd,//unused
output  reg                     command_inhibit_dat,//unused
output  reg                     dat_line_active,//intnal
output  reg                     retuning_request,//unused
output  reg                     write_transfer_active,//intnal
output  reg                     read_transfer_active,//intnal
output  reg                     led_control,//unused
output  reg     [1:0]           data_transfer_width,//[10]:8-line mode; [01]:4-line mode; [00]:1-line mode
output  reg                     data_ddr_mode,//[0]:sdr mode [1]:ddr mode     
output  reg                     stop_at_block_gap_request,
output  reg                     continue_request,
output  reg                     read_wait_control,//unused
output  reg                     interrupt_at_block_gap,//unused
output  reg                     command_complete,//intnal
output  reg                     transfer_complete,//intnal
output  reg                     block_gap_event,//intnal
output  reg                     buffer_write_ready,//intnal
output  reg                     buffer_read_ready,//intnal
output  reg                     card_insertion,//intnal
output  reg                     card_removal,//intnal
output  reg                     command_timeout_error,//intnal
output  reg                     command_crc_error,//intnal
output  reg                     command_end_bit_error,//intnal
output  reg                     command_index_error,//intnal
output  reg                     data_crc_error,//intnal
output  reg     [31:0]          interrupt_status_enable,//intnal
output  reg     [31:0]          interrupt_signal_enable,//intnal
output  reg     [63:0]          adma_system_address,
//Logic Signals
//--eMMC Host Control Registers Field
output  reg                     cmd_start,
input                           cmd_busy,
output  reg                     wr_start,
output  reg                     rd_start,
input                           dat_busy,
output  reg                     dma_wr_start,
output  reg                     dma_rd_start,
input           [119:0]         resp,
input                           resp_vld,
input           [4:0]           resp_err,
input                           data_err,
input                           auto_cmd_en,
input                           dat_crc_vld,
input                           dat_crc_ok,
input                           buffer_write_enable,
input                           buffer_read_enable,
input                           wr_bk_transfer_done,
input                           rd_bk_transfer_done,
input                           stop_at_block_gap_done,
input                           end_bit_of_cmd,
input                           dma_rd_done,
output  reg                     non_dma_wr_vld,
output  reg     [31:0]          non_dma_wr_data,
input           [31:0]          non_dma_rd_data,
input                           non_dma_rd_eop,
output  reg                     non_dma_rd_rdy,
output  reg                     rd_buf_rst,
output  reg                     wr_buf_rst,
output  reg                     sw_reset_dat
);
//Parameter Define 

//Register Define
//Cfg Space Registers
//--eMMC Host Control Registers Field
//Other Registers
reg     [ADDR_WTH-3:0]          loc_waddr;
reg                             loc_waddr_vld;
reg     [31:0]                  loc_wdata;
reg                             loc_wdata_vld;
reg     [3:0]                   loc_wstrb;
reg     [ADDR_WTH-3:0]          loc_raddr;
reg                             loc_raddr_vld;
reg                             transaction_suspend;
reg     [127:0]                 save_reg;
reg     [15:0]                  transfer_count;
reg     [31:0]                  argument_1_r;
reg     [31:0]                  buffer_data_port;
reg                             sw_reset_cmd;
reg                             sw_reset_all;
reg                             hw_reset_emmc_dev;

//Wire Define
//--Readable Status Signals
wire                            loc_wrdy;
wire                            loc_rrdy;
wire    [15:0]                  block_size_registers;
wire    [15:0]                  transfer_mode;
wire    [15:0]                  command;
wire    [31:0]                  present_state;
wire    [7:0]                   host_control_1;
wire    [7:0]                   power_control;
wire    [7:0]                   block_gap_control;
wire    [7:0]                   wakeup_control;
wire    [15:0]                  normal_Interrupt_status;
wire    [15:0]                  error_Interrupt_status;
wire    [31:0]                  cmd_transfer;
wire    [31:0]                  cur_cmd_transfer;
//--Edge Pulse
wire                            buffer_write_enable_posedge;
wire                            buffer_read_enable_posedge;
wire                            dat_line_active_posedge;
wire                            continue_request_posedge;
wire                            read_transfer_active_negedge;
wire                            write_transfer_active_negedge;
wire                            dat_line_active_negedge;
wire                            transfer_complete_negedge;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/
//axi4-lite interface
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_waddr <= {ADDR_WTH-2{1'b0}};
    else if((s_axi_awvalid == 1'b1) && (s_axi_awready == 1'b1))
        loc_waddr <= s_axi_awaddr[2+:ADDR_WTH-2];
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_waddr_vld <= 1'b0;
    else if((s_axi_awvalid == 1'b1) && (s_axi_awready == 1'b1))
        loc_waddr_vld <= 1'b1;
    else if((loc_waddr_vld == 1'b1) && (loc_wdata_vld == 1'b1) && (loc_wrdy == 1'b1))
        loc_waddr_vld <= 1'b0;
end

assign loc_wrdy = 1'b1;

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_awready <= 1'b0;
    else if((s_axi_awvalid == 1'b1) && (s_axi_awready == 1'b1))
        s_axi_awready <= 1'b0;
    else if(loc_waddr_vld == 1'b0)
        s_axi_awready <= 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            loc_wdata <= 32'h0;
            loc_wstrb <= 4'h0;
        end
    else if((s_axi_wvalid == 1'b1) && (s_axi_wready == 1'b1)) 
        begin
            loc_wdata <= s_axi_wdata;
            loc_wstrb <= s_axi_wstrb;
        end
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_wdata_vld <= 1'b0;
    else if((s_axi_wvalid == 1'b1) && (s_axi_wready == 1'b1))
        loc_wdata_vld <= 1'b1;
    else if((loc_waddr_vld == 1'b1) && (loc_wdata_vld == 1'b1) && (loc_wrdy == 1'b1))
        loc_wdata_vld <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_wready <= 1'b0;
    else if((s_axi_wvalid == 1'b1) && (s_axi_wready == 1'b1))
        s_axi_wready <= 1'b0;
    else if(loc_wdata_vld == 1'b0)
        s_axi_wready <= 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_bvalid <= 1'b0;
    else if((loc_waddr_vld == 1'b1) && (loc_wdata_vld == 1'b1) && (loc_wrdy == 1'b1))
        s_axi_bvalid <= 1'b1;
    else if(s_axi_bready == 1'b1)
        s_axi_bvalid <= 1'b0;
end

assign s_axi_bresp = 2'h0;

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_raddr <= {ADDR_WTH-2{1'b0}};
    else if((s_axi_arvalid == 1'b1) && (s_axi_arready == 1'b1))
        loc_raddr <= s_axi_araddr[2+:ADDR_WTH-2];
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        loc_raddr_vld <= 1'b0;
    else if((s_axi_arvalid == 1'b1) && (s_axi_arready == 1'b1))
        loc_raddr_vld <= 1'b1;
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1))
        loc_raddr_vld <= 1'b0;
end

assign loc_rrdy = 1'b1;

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_arready <= 1'b0;
    else if((s_axi_arvalid == 1'b1) && (s_axi_arready == 1'b1))
        s_axi_arready <= 1'b0;
    else if(loc_raddr_vld == 1'b0)
        s_axi_arready <= 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_rdata <= 32'h0;
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1))
        begin
            case(loc_raddr)
            //Base Configuration Registers Field
            'h000 : s_axi_rdata <= VERSION;
            'h001 : s_axi_rdata <= {15'h0,clk_out_en,clk_out_div};
            'h002 : s_axi_rdata <= {30'h0,dat_busy,cmd_busy};
            'h003 : s_axi_rdata <= {sample_cnt,7'h0,cpu_shift,5'h0,cpu_shift_ena};
            //eMMC Host Control Registers Field
            'h040 : s_axi_rdata <= argument_2;
            'h041 : s_axi_rdata <= {block_count,block_size_registers};
            'h042 : s_axi_rdata <= argument_1;
            'h043 : s_axi_rdata <= {command,transfer_mode};
            'h044 : s_axi_rdata <= response[31:0];
            'h045 : s_axi_rdata <= response[63:32];
            'h046 : s_axi_rdata <= response[95:64];
            'h047 : s_axi_rdata <= response[127:96];
            'h048 : s_axi_rdata <= buffer_data_port;
            'h049 : s_axi_rdata <= present_state;
            'h04a : s_axi_rdata <= {wakeup_control,block_gap_control,power_control,host_control_1};
            'h04b : s_axi_rdata <= {4'b0,hw_reset_emmc_dev,sw_reset_dat,sw_reset_cmd,sw_reset_all,24'h0};
            'h04c : s_axi_rdata <= {error_Interrupt_status,normal_Interrupt_status};
            'h04d : s_axi_rdata <= interrupt_status_enable;
            'h04e : s_axi_rdata <= interrupt_signal_enable;
            'h050 : s_axi_rdata <= {MAX_BLOCK_LEN[15:0],6'h0,BASE_CLK_FREQ[9:0]};
            'h056 : s_axi_rdata <= adma_system_address[31:0];
            'h057 : s_axi_rdata <= adma_system_address[63:32];
            default:s_axi_rdata <= 32'h0;
            endcase
        end
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        s_axi_rvalid <= 1'b0;
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1))
        s_axi_rvalid <= 1'b1;
    else if(s_axi_rready == 1'b1)
        s_axi_rvalid <= 1'b0;
end

assign s_axi_rlast = s_axi_rvalid;
assign s_axi_rresp = 2'h0;

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        emmc_int <= 1'b0;
    else
        emmc_int <= ( ((command_complete == 1'b1) && (interrupt_signal_enable[0] == 1'b1)) ||
                    ((transfer_complete == 1'b1) && (interrupt_signal_enable[1] == 1'b1)) ||
                    ((block_gap_event == 1'b1) && (interrupt_signal_enable[2] == 1'b1)) ||
                    ((buffer_write_ready == 1'b1) && (interrupt_signal_enable[4] == 1'b1)) ||
                    ((buffer_read_ready == 1'b1) && (interrupt_signal_enable[5] == 1'b1)) ||
                    ((card_insertion == 1'b1) && (interrupt_signal_enable[6] == 1'b1)) ||
                    ((card_removal == 1'b1) && (interrupt_signal_enable[7] == 1'b1)) ||
                    ((command_timeout_error == 1'b1) && (interrupt_signal_enable[16] == 1'b1)) ||
                    ((command_crc_error == 1'b1) && (interrupt_signal_enable[17] == 1'b1)) ||
                    ((command_end_bit_error == 1'b1) && (interrupt_signal_enable[18] == 1'b1)) ||
                    ((command_index_error == 1'b1) && (interrupt_signal_enable[19] == 1'b1)) ||
                    ((data_crc_error == 1'b1) && (interrupt_signal_enable[21] == 1'b1)) ); 
end

/*----------------------------------------------------------------------------------*\
    Register Space -- Base Configuration Registers Field
\*----------------------------------------------------------------------------------*/
//loc_addr = 0x01; axi_addr = 0x004; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            clk_out_en <= 1'b0;
            clk_out_div[15:0] <= 16'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h001))
        begin
            clk_out_en <= loc_wdata[16];
            clk_out_div[15:0] <= loc_wdata[15:0];
        end
end

/*----------------------------------------------------------------------------------*\
    Register Space -- eMMC Host Control Registers Field
\*----------------------------------------------------------------------------------*/
//loc_addr = 0x03; axi_addr = 0x00C; RW;
// Sampling clock phase dynamic adjustment
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            sample_cnt    <= 16'b0;
            cpu_shift     <= 3'b0;
            cpu_shift_ena <= 1'b0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h003))
        begin
            sample_cnt    <= loc_wdata[31:16];
            cpu_shift     <= loc_wdata[8:6];
            cpu_shift_ena <= loc_wdata[0];
        end
end

//loc_addr = 0x40; axi_addr = 0x100; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            argument_2[31:0] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h040))
        begin
            argument_2[31:0] <= loc_wdata[31:0];
        end
    else if((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1))
        begin
            argument_2[31:0] <= save_reg[0*32 +: 32];
        end
end

//loc_addr = 0x041; axi_addr = 0x104; RW;
//Block Size & Block Count
assign block_size_registers = {1'h0,sdma_buff_boundary[2:0],block_size[11:0]};

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            block_size[11:0] <= 12'h0;
            sdma_buff_boundary[2:0] <= 3'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h041))
        begin
            if (loc_wstrb[0] == 1'b1)
                block_size[7:0] <= loc_wdata[7:0];
            if (loc_wstrb[1] == 1'b1)
                begin
                    block_size[11:8] <= loc_wdata[11:8];
                    sdma_buff_boundary[2:0] <= loc_wdata[14:12];
                end
        end
    else if((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1))
        begin
            block_size[11:0] <= save_reg[1*32 +: 12];
            sdma_buff_boundary[2:0] <= save_reg[1*32+12 +: 3];
        end
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        block_count[15:0] <= 16'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h041))
        begin
            if (loc_wstrb[2] == 1'b1)
                block_count[7:0] <= loc_wdata[23:16];
            if (loc_wstrb[3] == 1'b1)
                block_count[15:8] <= loc_wdata[31:24];
        end
    else if((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1))
        block_count[15:0] <= save_reg[1*32+16 +: 16];
    else if(((wr_bk_transfer_done == 1'b1) || (rd_bk_transfer_done == 1'b1)) && (block_count != 0))
        block_count[15:0] <= block_count[15:0] - 1'b1;
end

//loc_addr = 0x042; axi_addr = 0x108; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            argument_1[31:0] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h042))
        begin
            argument_1[31:0] <= loc_wdata[31:0];
        end
    else if((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1))
        begin
            argument_1[31:0] <= save_reg[2*32 +: 32];
        end
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            argument_1_r[31:0] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h042))
        begin
            argument_1_r[31:0] <= loc_wdata[31:0];
        end
    else if(((wr_bk_transfer_done == 1'b1) || (rd_bk_transfer_done == 1'b1)) && (block_count != 0))
        begin
            // argument_1_r[31:0] <= argument_1_r[31:0] + block_size[11:0];//in Byte
            argument_1_r[31:0] <= argument_1_r[31:0] + 1'b1;//in Sector
        end
end

//loc_addr = 0x043; axi_addr = 0x10c; RW;
//Transfer Mode & Command
assign transfer_mode = {10'h0,multi_or_single_block_select,data_transfer_direction_select,auto_cmd_enable,block_count_enable,dma_enable};
assign command = {2'h0,command_index[5:0],command_type[1:0],data_present_select,command_index_check_enable,command_crc_check_enable,1'h0,response_type_select[1:0]};

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            dma_enable <= 1'h0;
            block_count_enable <= 1'h0;
            auto_cmd_enable <= 2'h0;
            data_transfer_direction_select <= 1'h0;
            multi_or_single_block_select <= 1'h0;
            response_type_select[1:0] <= 2'h0;
            command_crc_check_enable <= 1'h0;
            command_index_check_enable <= 1'h0;
            data_present_select <= 1'h0;
            command_type[1:0] <= 2'h0;
            command_index[5:0] <= 6'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h043))
        begin
            if (loc_wstrb[0]) 
                begin
                    dma_enable <= loc_wdata[0];
                    block_count_enable <= loc_wdata[1];
                    auto_cmd_enable[1:0] <= loc_wdata[3:2];
                    data_transfer_direction_select <= loc_wdata[4];
                    multi_or_single_block_select <= loc_wdata[5];
                end
            if (loc_wstrb[2]) 
                begin
                    response_type_select[1:0] <= loc_wdata[17:16];
                    command_crc_check_enable <= loc_wdata[19];
                    command_index_check_enable <= loc_wdata[20];
                    data_present_select <= loc_wdata[21];
                    command_type[1:0] <= loc_wdata[23:22];
                end
            if (loc_wstrb[3])
                begin
                    command_index[5:0] <= loc_wdata[29:24];
                end
        end
    else if((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1))
        begin
            dma_enable <= save_reg[3*32 +: 1];
            block_count_enable <= save_reg[3*32+1 +: 1];
            auto_cmd_enable[1:0] <= save_reg[3*32+2 +: 2];
            data_transfer_direction_select <= save_reg[3*32+4 +: 1];
            multi_or_single_block_select <= save_reg[3*32+5 +: 1];
            response_type_select[1:0] <= save_reg[3*32+16 +: 2];
            command_crc_check_enable <= save_reg[3*32+19 +: 1];
            command_index_check_enable <= save_reg[3*32+20 +: 1];
            data_present_select <= save_reg[3*32+21 +: 1];
            command_type[1:0] <= save_reg[3*32+22 +: 2];
            command_index[5:0] <= save_reg[3*32+24 +: 6];
        end
end

//loc_addr = 0x044; axi_addr = 0x110; ROC;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            response[31:0] <= 32'h0;
        end
    else if(resp_vld == 1'b1)
        begin
            response[31:0] <= resp[31:0];
        end
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1) && (loc_raddr == 'h044))
        begin
            response[31:0] <= 32'h0;
        end
end

//loc_addr = 0x045; axi_addr = 0x114; ROC;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            response[63:32] <= 32'h0;
        end
    else if(resp_vld == 1'b1)
        begin
            response[63:32] <= resp[63:32];
        end
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1) && (loc_raddr == 'h045))
        begin
            response[63:32] <= 32'h0;
        end
end

//loc_addr = 0x046; axi_addr = 0x118; ROC;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            response[95:64] <= 32'h0;
        end
    else if(resp_vld == 1'b1)
        begin
            response[95:64] <= resp[95:64];
        end
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1) && (loc_raddr == 'h046))
        begin
            response[95:64] <= 32'h0;
        end
end

//loc_addr = 0x047; axi_addr = 0x11c; ROC;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            response[127:96] <= 32'h0;
        end
    else if(resp_vld == 1'b1)
        begin
            response[127:96] <= {8'h0,resp[119:96]};
        end
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1) && (loc_raddr == 'h047))
        begin
            response[127:96] <= 32'h0;
        end
end

//loc_addr = 0x048; axi_addr = 0x120; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if (s_axi_aresetn == 1'b0)
        buffer_data_port <= 32'b0;
    else if(sw_reset_dat == 1'b1)
        buffer_data_port <= 32'b0;
    else
        buffer_data_port <= non_dma_rd_data;
end

//loc_addr = 0x049; axi_addr = 0x124; RO/ROC;
//Present State
assign present_state = {20'h0,buffer_read_enable,buffer_write_enable,read_transfer_active,write_transfer_active,4'h0,retuning_request,dat_line_active,command_inhibit_dat,command_inhibit_cmd};

//[0] - Command Inhibit(CMD)
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_inhibit_cmd <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (s_axi_bready == 1'b1) && (loc_waddr == 'h043))
        command_inhibit_cmd <= 1'h1;
    else if(resp_vld == 1'b1)
        command_inhibit_cmd <= 1'h0;
    else if((sw_reset_cmd == 1'b1) || (sw_reset_all == 1'b1))
        command_inhibit_cmd <= 1'h0;
end

//[1] - Command Inhibit(DAT)
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_inhibit_dat <= 1'h0;
    else if((dat_line_active == 1'b1) || (read_transfer_active == 1'b1))
        command_inhibit_dat <= 1'h1;
    else if((sw_reset_dat == 1'b1) || (sw_reset_all == 1'b1))
        command_inhibit_dat <= 1'h0;
    else
        command_inhibit_dat <= 1'h0;
end

//[2] - DAT Line Active
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        dat_line_active <= 1'h0;
    else if((end_bit_of_cmd == 1'b1) ||
            ((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1)))
        dat_line_active <= 1'h1;
    else if(((block_count == 16'h1) && ((wr_bk_transfer_done == 1'b1) || (rd_bk_transfer_done == 1'b1))) ||
            ((data_transfer_direction_select == 1'b1) && (dma_rd_done == 1'b1)) ||
            (stop_at_block_gap_done == 1'b1))
        dat_line_active <= 1'h0;
    else if(sw_reset_dat == 1'b1)
        dat_line_active <= 1'b0;
end

//[3] - Re-Tuning Request
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        retuning_request <= 1'h0;
end

//[8] - Write Transfer Active
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        write_transfer_active <= 1'h0;
    else if(((data_transfer_direction_select == 1'b0) && (end_bit_of_cmd == 1'b1)) ||
            ((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1) && (save_reg[3*32+4 +: 1] == 1'b0)))
        write_transfer_active <= 1'h1;
    else if(((data_transfer_direction_select == 1'b0) && (dat_crc_vld == 1'b1) && (transfer_count == 16'h1)) || 
            (stop_at_block_gap_done == 1'b1))
        write_transfer_active <= 1'h0;
    else if(sw_reset_dat == 1'b1)
        write_transfer_active <= 1'h0;
end

//[9] - Read Transfer Active
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        read_transfer_active <= 1'h0;
    else if(((data_transfer_direction_select == 1'b1) && (end_bit_of_cmd == 1'b1)) ||
            ((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1) && (save_reg[3*32+4 +: 1] == 1'b1)))
        read_transfer_active <= 1'h1;
    else if(((non_dma_rd_eop == 1'b1) && (transfer_count == 16'h1)) ||
            ((data_transfer_direction_select == 1'b1) && (dma_rd_done == 1'b1)) ||
            (stop_at_block_gap_done == 1'b1))
        read_transfer_active <= 1'h0;
    else if(sw_reset_dat == 1'b1)
        read_transfer_active <= 1'h0;
end

//loc_addr = 0x04a; axi_addr = 0x128; RW;
//Host Control 1 & Power Control & Block Gap Control & Wakeup Control
assign host_control_1 = {4'h0,data_ddr_mode,data_transfer_width,led_control};
assign power_control = 8'h0;
assign block_gap_control = {4'h0,interrupt_at_block_gap,read_wait_control,continue_request,stop_at_block_gap_request};
assign wakeup_control = 8'h0;

//[0] - LED Control
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        led_control <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a))
        led_control <= loc_wdata[0];
end

//[2:1] - Data Transfer Width [00]:1 line  [01]:4 line [10]:8 line 
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        data_transfer_width <= 2'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a))
        data_transfer_width <= loc_wdata[2:1];
end

//[3] - Data Sample Mode [0]:sdr [1]:ddr 
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        data_ddr_mode <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a))
        data_ddr_mode <= loc_wdata[3];
end

//[16] - Stop At Block Gap Request
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        stop_at_block_gap_request <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a) && (loc_wstrb[2] == 1'b1))
        stop_at_block_gap_request <= loc_wdata[16];
    else if(transfer_complete_negedge == 1'b1)
        stop_at_block_gap_request <= 1'h0;
    else if(sw_reset_dat == 1'b1)
        stop_at_block_gap_request <= 1'h0;
end

//[17] - Continue Request
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        continue_request <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a) && (stop_at_block_gap_request == 1'b0) && (loc_wstrb[2] == 1'b1))
        continue_request <= loc_wdata[17];
    else if(dat_line_active_posedge == 1'b1)
        continue_request <= 1'h0;
    else if(sw_reset_dat == 1'b1)
        continue_request <= 1'b0;
end

//[18] - Read Wait Control
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        read_wait_control <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a) && (loc_wstrb[2] == 1'b1))
        read_wait_control <= loc_wdata[18];
end

//[19] - Interrupt At Block Gap
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        interrupt_at_block_gap <= 1'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04a) && (loc_wstrb[2] == 1'b1))
        interrupt_at_block_gap <= loc_wdata[19];
end

//loc_addr = 0x04b; axi_addr = 0x12c; RW;
//software reset register

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            hw_reset_emmc_dev <= 1'b0;
            sw_reset_all      <= 1'b0;
            sw_reset_cmd      <= 1'b0;
            sw_reset_dat      <= 1'b0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04b) && (loc_wstrb[3] == 1'b1))
        begin
            hw_reset_emmc_dev <= loc_wdata[27];
            sw_reset_dat      <= loc_wdata[26];
            sw_reset_cmd      <= loc_wdata[25];
            sw_reset_all      <= loc_wdata[24];
        end
    else if(hw_reset_emmc_dev == 1'b1)
        hw_reset_emmc_dev <= 1'b0;
    else if(sw_reset_all == 1'b1)
        sw_reset_all <= 1'b0;
    else if(sw_reset_cmd == 1'b1)
        sw_reset_cmd <= 1'b0;
    else if(sw_reset_dat == 1'b1)
        sw_reset_dat <= 1'b0;
end

//loc_addr = 0x04c; axi_addr = 0x130; RW1C;
//Normal Interrupt Status & Error Interrupt Status
assign normal_Interrupt_status = {8'h0,card_removal,card_insertion,buffer_read_ready,buffer_write_ready,1'b0,block_gap_event,transfer_complete,command_complete};
assign error_Interrupt_status = {10'h0,data_crc_error,1'b0,command_index_error,command_end_bit_error,command_crc_error,command_timeout_error};

//[0] - Command Complete
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_complete <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[0] == 1'b1) && (loc_wstrb[0] == 1'b1)) ||
                (interrupt_status_enable[0] == 1'b0))
        command_complete <= 1'h0;
    else if((resp_vld == 1'b1) && (auto_cmd_en == 1'b0))
        command_complete <= 1'h1;
    else if (sw_reset_cmd == 1'b1)
        command_complete <= 1'b0;
end

//[1] - Transfer Complete
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        transfer_complete <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[1] == 1'b1) && (loc_wstrb[0] == 1'b1)) ||
                (interrupt_status_enable[1] == 1'b0))
        transfer_complete <= 1'h0;
    else if(((data_transfer_direction_select == 1'b0) && (dat_line_active_negedge == 1'b1)) ||
            ((data_transfer_direction_select == 1'b1) && (read_transfer_active_negedge == 1'b1)))
        transfer_complete <= 1'h1;
    else if(sw_reset_dat == 1'b1)
        transfer_complete <= 1'b0;
end

//[2] - Block Gap Event
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        block_gap_event <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[2] == 1'b1) && (loc_wstrb[0] == 1'b1)) ||
                (interrupt_status_enable[2] == 1'b0))
        block_gap_event <= 1'h0;
    else if((stop_at_block_gap_request == 1'b1) && 
            (((data_transfer_direction_select == 1'b1) && (dat_line_active_negedge == 1'b1)) || 
             ((data_transfer_direction_select == 1'b0) && (write_transfer_active_negedge == 1'b1))))
        block_gap_event <= 1'h1;
    else if(sw_reset_dat == 1'b1)
        block_gap_event <= 1'b0;
end

//[4] - Buffer Write Ready
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        buffer_write_ready <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[4] == 1'b1) && (loc_wstrb[0] == 1'b1)) ||
                (interrupt_status_enable[4] == 1'b0))
        buffer_write_ready <= 1'h0;
    else if(buffer_write_enable_posedge == 1'b1)
        buffer_write_ready <= 1'h1;
    else if(sw_reset_dat == 1'b1)
        buffer_write_ready <= 1'b0;
end

//[5] - Buffer Read Ready
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        buffer_read_ready <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[5] == 1'b1) && (loc_wstrb[0] == 1'b1)) ||
                (interrupt_status_enable[5] == 1'b0))
        buffer_read_ready <= 1'h0;
    else if(buffer_read_enable_posedge == 1'b1)
        buffer_read_ready <= 1'h1;
    else if(sw_reset_dat == 1'b1)
        buffer_read_ready <= 1'b0;
end

//[16] - Command Timeout Error
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_timeout_error <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[16] == 1'b1) && (loc_wstrb[2] == 1'b1)) ||
                (interrupt_status_enable[16] == 1'b0))
        command_timeout_error <= 1'h0;
    else if((resp_vld == 1'b1) && (resp_err[0] == 1'b1))
        command_timeout_error <= 1'h1;
end

//[17] - Command CRC Error
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_crc_error <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[17] == 1'b1) && (loc_wstrb[2] == 1'b1)) ||
                (interrupt_status_enable[17] == 1'b0))
        command_crc_error <= 1'h0;
    else if((resp_vld == 1'b1) && (resp_err[3] == 1'b1))
        command_crc_error <= 1'h1;
end

//[18] - Command End Bit Error
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_end_bit_error <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[18] == 1'b1) && (loc_wstrb[2] == 1'b1)) ||
                (interrupt_status_enable[18] == 1'b0))
        command_end_bit_error <= 1'h0;
    else if((resp_vld == 1'b1) && (resp_err[4] == 1'b1))
        command_end_bit_error <= 1'h1;
end

//[19] - Command Index Error
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        command_index_error <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[19] == 1'b1) && (loc_wstrb[2] == 1'b1)) ||
                (interrupt_status_enable[19] == 1'b0))
        command_index_error <= 1'h0;
    else if((resp_vld == 1'b1) && (resp_err[2] == 1'b1))
        command_index_error <= 1'h1;
end

//[21] - Data CRC Error
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        data_crc_error <= 1'h0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04c) && (loc_wdata[21] == 1'b1) && (loc_wstrb[2] == 1'b1)) ||
                (interrupt_status_enable[21] == 1'b0))
        data_crc_error <= 1'h0;
    else if(data_err == 1'b1)
        data_crc_error <= 1'h1;
end

//loc_addr = 0x04d; axi_addr = 0x134; RW;
//Normal Interrupt Status Enable & Error Interrupt Status Enable
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            interrupt_status_enable[31:0] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04d))
        begin
            interrupt_status_enable[31:0] <= loc_wdata[31:0];
        end
end

//loc_addr = 0x04e; axi_addr = 0x138; RW;
//Normal Interrupt Signal Enable & Error Interrupt Signal Enable
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            interrupt_signal_enable[31:0] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h04e))
        begin
            interrupt_signal_enable[31:0] <= loc_wdata[31:0];
        end
end

//loc_addr = 0x056; axi_addr = 0x158; RW;
//ADMA System Address [31:0]
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            adma_system_address[31:0] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h056))
        begin
            adma_system_address[31:0] <= loc_wdata[31:0];
        end
end

//loc_addr = 0x057; axi_addr = 0x15c; RW;
//ADMA System Address [63:32]
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        begin
            adma_system_address[63:32] <= 32'h0;
        end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h057))
        begin
            adma_system_address[63:32] <= loc_wdata[31:0];
        end
end

/*---------------------- eMMC Host Control Logic Region --------------------*/
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        transfer_count[15:0] <= 16'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h041) && (loc_wstrb[2] == 1'b1 | loc_wstrb[3] == 1'b1))
        transfer_count[15:0] <= loc_wdata[31:16];
    else if((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1))
        transfer_count[15:0] <= save_reg[1*32+16 +: 16];
    else if(stop_at_block_gap_request == 1'b1)
        transfer_count[15:0] <= 16'h0;
    else if((((data_transfer_direction_select == 1'b0) && (dat_crc_vld == 1'b1)) ||
             (non_dma_rd_eop == 1'b1)) && (transfer_count != 0))
        transfer_count[15:0] <= transfer_count[15:0] - 1'b1;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        transaction_suspend <= 1'b0;
    else if(stop_at_block_gap_done == 1'b1)
        transaction_suspend <= 1'b1;
    else if(continue_request_posedge == 1'b1)
        transaction_suspend <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        save_reg <= 128'h0;
    else if((stop_at_block_gap_request == 1'b1) && (transfer_complete == 1'b1))
        save_reg <= {{command,transfer_mode},argument_1_r,{block_count,block_size_registers},argument_2};
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        cmd_start <= 1'b0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h043) && (loc_wstrb[2] | loc_wstrb[3])) ||
            ((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1)))
        cmd_start <= 1'b1;
    else if(cmd_busy == 1'b1)
        cmd_start <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        wr_start <= 1'b0;
    else if((data_transfer_direction_select == 1'b0) && (end_bit_of_cmd == 1'b1))
        wr_start <= 1'b1;
    else if(dat_busy == 1'b1)
        wr_start <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        rd_start <= 1'b0;
    else if((data_transfer_direction_select == 1'b1) && (end_bit_of_cmd == 1'b1))
        rd_start <= 1'b1;
    else if(dat_busy == 1'b1)
        rd_start <= 1'b0;
end

assign cur_cmd_transfer[7:0] = (s_axi_bvalid == 1'b1 && loc_waddr == 'h043)? ((loc_wstrb[0] == 1'b1)? loc_wdata[7:0]: cmd_transfer[7:0]): cmd_transfer[7:0];
assign cur_cmd_transfer[15:8] = (s_axi_bvalid == 1'b1 && loc_waddr == 'h043)? ((loc_wstrb[1] == 1'b1)? loc_wdata[15:8]: cmd_transfer[15:8]): cmd_transfer[15:8];
assign cur_cmd_transfer[23:16] = (s_axi_bvalid == 1'b1 && loc_waddr == 'h043)? ((loc_wstrb[2] == 1'b1)? loc_wdata[23:16]: cmd_transfer[23:16]): cmd_transfer[23:16];
assign cur_cmd_transfer[31:24] = (s_axi_bvalid == 1'b1 && loc_waddr == 'h043)? ((loc_wstrb[3] == 1'b1)? loc_wdata[31:24]: cmd_transfer[31:24]): cmd_transfer[31:24];
assign cmd_transfer = {command, transfer_mode};

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        dma_wr_start <= 1'b0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h043) && (loc_wstrb[2] | loc_wstrb[3]) && (cur_cmd_transfer[0] == 1'b1) && (cur_cmd_transfer[4] == 1'b0) && (cur_cmd_transfer[21] == 1'b1)) ||
            ((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1) && (save_reg[3*32 +: 1] == 1'b1) && (save_reg[3*32+4 +: 1] == 1'b0) && (save_reg[3*32+21 +: 1] == 1'b1)))
        dma_wr_start <= 1'b1;
    else
        dma_wr_start <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        dma_rd_start <= 1'b0;
    else if(((s_axi_bvalid == 1'b1) && (loc_waddr == 'h043) && (loc_wstrb[2] | loc_wstrb[3]) && (cur_cmd_transfer[0] == 1'b1) && (cur_cmd_transfer[4] == 1'b1) && (cur_cmd_transfer[21] == 1'b1)) ||
            ((continue_request_posedge == 1'b1) && (transaction_suspend == 1'b1) && (save_reg[3*32 +: 1] == 1'b1) && (save_reg[3*32+4 +: 1] == 1'b1) && (save_reg[3*32+21 +: 1] == 1'b1)))
        dma_rd_start <= 1'b1;
    else
        dma_rd_start <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        non_dma_wr_vld <= 1'b0;
    else if((s_axi_bvalid == 1'b1) && (s_axi_bready == 1'b1) && (loc_waddr == 'h048))
        non_dma_wr_vld <= 1'b1;
    else
        non_dma_wr_vld <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        non_dma_wr_data <= 32'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h048))
        non_dma_wr_data <= loc_wdata[31:0];
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        non_dma_rd_rdy <= 1'b0;
    else if((loc_raddr_vld == 1'b1) && (loc_rrdy == 1'b1) && (loc_raddr == 'h048))
        non_dma_rd_rdy <= 1'b1;
    else
        non_dma_rd_rdy <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        rd_buf_rst <= 1'b0;
    else if((cmd_start == 1'b1) && (data_present_select == 1'b1) && (data_transfer_direction_select == 1'b1))
        rd_buf_rst <= 1'b1;
    else
        rd_buf_rst <= 1'b0;
end

always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        wr_buf_rst <= 1'b0;
    else if(write_transfer_active_negedge == 1'b1)
        wr_buf_rst <= 1'b1;
    else
        wr_buf_rst <= 1'b0;
end

//Rising Edge Pulse
posedge_domain_cross buffer_write_enable_posedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,buffer_write_enable,buffer_write_enable_posedge);
posedge_domain_cross buffer_read_enable_posedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,buffer_read_enable,buffer_read_enable_posedge);
posedge_domain_cross dat_line_active_posedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,dat_line_active,dat_line_active_posedge);
posedge_domain_cross continue_request_posedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,continue_request,continue_request_posedge);

//Falling Edge Pulse
negedge_domain_cross read_transfer_active_negedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,read_transfer_active,read_transfer_active_negedge);
negedge_domain_cross write_transfer_active_negedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,write_transfer_active,write_transfer_active_negedge);
negedge_domain_cross dat_line_active_negedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,dat_line_active,dat_line_active_negedge);
negedge_domain_cross transfer_complete_negedge_cross(s_axi_aresetn,s_axi_aclk,1'b1,transfer_complete,transfer_complete_negedge);

//Encryption end
endmodule

