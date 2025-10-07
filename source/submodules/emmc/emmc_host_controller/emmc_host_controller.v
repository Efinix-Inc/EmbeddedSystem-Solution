//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : emmc_host_controller.v
// Version        : 1.0 
// Author         : Evan Chen 
// Email          : evan.chen@elitestek.com 
// Date Created   : 2024-11-12 16:52:25 
// Last Modified  : 2025-06-10 17:05:16
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module emmc_host_controller#(
    parameter                       ADMA_DATA_WIDTH   = 32,
    parameter                       BASE_CLK_FREQ     = 200,         // MHz, the frequency of emmc_base_clk
    parameter       [4:0]           SHIFT_SEL         = 5'h4,
    parameter                       FAMILY            = "TITANIUM",
    parameter                       RAM_STYLE         = "block_ram" 
)
(
//Global Signals
input                           emmc_rst,           //Global Reset
input                           emmc_base_clk,      //eMMC base clock
input                           emmc_base_clk_cal,  //eMMC rx data base sample clock,the clock phase is dynamically adjusted by the cpu
output  wire                    emmc_int,           //eMMC interrupt
//Sampling Clock Phase Dynamic Adjustment Signals
//--To FPGA PLL 
output  wire    [2:0]           pll_SHIFT,          
output  wire    [4:0]           pll_SHIFT_SEL,      
output  wire                    pll_SHIFT_ENA,
//AXI4-Lite Register Bus Interface
input                           s_axi_aclk,       //AXI Bus Clock.
input           [9:0]           s_axi_awaddr,     //Write Address. byte address.
input                           s_axi_awvalid,    //Write address valid.
output  wire                    s_axi_awready,    //Write address ready.
input           [31:0]          s_axi_wdata,      //Write data bus.
input            [3:0]          s_axi_wstrb,
input                           s_axi_wvalid,     //Write valid.
output  wire                    s_axi_wready,     //Write ready.
output  wire    [1:0]           s_axi_bresp,      //Write response.
output  wire                    s_axi_bvalid,     //Write response valid.
input                           s_axi_bready,     //Response ready.
input           [9:0]           s_axi_araddr,     //Read address. byte address.
input                           s_axi_arvalid,    //Read address valid.
output  wire                    s_axi_arready,    //Read address ready.
output  wire    [1:0]           s_axi_rresp,      //Read response.
output  wire    [31:0]          s_axi_rdata,      //Read data.
output  wire                    s_axi_rvalid,     //Read valid.
output  wire                    s_axi_rlast,      //Read last.
input                           s_axi_rready,     //Read ready.
//AXI4 Memory Bus Interface
input                           m_axi_clk,
//--Write Bus Interface
output  wire                    m_axi_awvalid,
output  wire    [31:0]          m_axi_awaddr,
output  wire    [7:0]           m_axi_awlen,
output  wire    [2:0]           m_axi_awsize,
output  wire    [1:0]           m_axi_awburst,
output  wire    [2:0]           m_axi_awprot,
output  wire    [1:0]           m_axi_awlock,
output  wire    [3:0]           m_axi_awcache,
input                           m_axi_awready,
output  wire    [ADMA_DATA_WIDTH-1:0]   m_axi_wdata,
output  wire    [ADMA_DATA_WIDTH/8-1:0] m_axi_wstrb,
output  wire                    m_axi_wlast,
output  wire                    m_axi_wvalid,
input                           m_axi_wready,
input           [1:0]           m_axi_bresp,
input                           m_axi_bvalid,
output  wire                    m_axi_bready,
//--Read Bus Interface
output  wire                    m_axi_arvalid,
output  wire    [31:0]          m_axi_araddr,
output  wire    [7:0]           m_axi_arlen,
output  wire    [2:0]           m_axi_arsize,
output  wire    [1:0]           m_axi_arburst,
output  wire    [2:0]           m_axi_arprot,
output  wire    [1:0]           m_axi_arlock,
output  wire    [3:0]           m_axi_arcache,
input                           m_axi_arready,
input                           m_axi_rvalid,
input           [ADMA_DATA_WIDTH-1:0] m_axi_rdata,
input                           m_axi_rlast,
input           [1:0]           m_axi_rresp,
output  wire                    m_axi_rready,
//eMMC Card Ports
output  wire                    emmc_clk_HI,
output  wire                    emmc_clk_LO,
input                           emmc_cmd_IN_HI,
input                           emmc_cmd_IN_LO,
output  wire                    emmc_cmd_OUT_HI,
output  wire                    emmc_cmd_OUT_LO,
output  wire                    emmc_cmd_OE,
input           [7:0]           emmc_dat_IN_HI,
input           [7:0]           emmc_dat_IN_LO,
output  wire    [7:0]           emmc_dat_OUT_HI,
output  wire    [7:0]           emmc_dat_OUT_LO,
output  wire                    emmc_dat_OE
);

//Parameter Define
localparam                      VERSION            = 32'h10;
localparam                      BUFFER_BLOCK_SIZE  = 512; 
parameter                       BUFFER_BLOCK_COUNT = 4;    // DATA_BUFFER_DEPTH/128;

//Register Define 

//Wire Define
//Clk Management
wire                            clk_enable;
wire                            emmc_clk_en;
wire                            sample_en;
//Cfg Space Registers
//--Base Configuration Registers Field
wire                            clk_out_en;
wire    [15:0]                  clk_out_div;
//--Sampling Clock Phase Dynamic Adjustment Registers Field
wire    [2:0]                   cpu_shift;         
wire                            cpu_shift_ena;
wire    [15:0]                  sample_cnt;
//--eMMC Host Control Registers Field
wire                            sw_reset_dat;
wire    [11:0]                  block_size;
wire    [15:0]                  block_count;
wire    [31:0]                  argument_1;
wire                            dma_enable;
wire    [1:0]                   auto_cmd_enable;
wire    [1:0]                   response_type_select;
wire                            data_transfer_direction_select;
wire                            command_crc_check_enable;
wire                            command_index_check_enable;
wire    [5:0]                   command_index;
wire    [1:0]                   data_transfer_width;
wire                            stop_at_block_gap_request;
wire                            continue_request;
wire    [63:0]                  adma_system_address;
//Buffer Ctr
wire                            rd_buf_rst;
wire                            wr_buf_rst;
wire                            non_dma_wr_vld;
wire    [31:0]                  non_dma_wr_data;
wire    [31:0]                  non_dma_rd_data;
wire                            non_dma_rd_vld;
wire                            non_dma_rd_eop;
wire                            non_dma_rd_rdy;
wire                            dma_wr_vld;
wire    [31:0]                  dma_wr_data;
wire                            dma_wr_rdy;
wire                            dma_rd_vld;
wire    [31:0]                  dma_rd_data;
wire                            dma_rd_rdy;
wire    [31:0]                  ff_tx_data;
wire                            ff_tx_vld;
wire                            ff_tx_rdy;
wire    [31:0]                  ff_rx_data;
wire                            ff_rx_vld;
wire                            ff_rx_eop;
wire                            ff_rx_err;
wire                            buffer_write_enable;
wire                            buffer_read_enable;
wire                            buf_wr_transfer_rdy;
wire                            buf_rd_transfer_rdy;
//eMMC Cmd Ctr
wire                            cmd_start;
wire                            cmd_busy;
wire    [119:0]                 resp;
wire                            resp_vld;
wire    [4:0]                   resp_err;
wire                            auto_cmd_en;//auto cmd12 or auto_cmd23
wire                            end_bit_of_cmd;
//eMMC Dat Ctr
wire                            wr_start;
wire                            rd_start;
wire                            dat_busy;
wire                            dat_crc_vld;
wire                            dat_crc_ok;
wire                            auto_cmd12_start;
wire                            wr_bk_transfer_done;
wire                            rd_bk_transfer_done;
wire                            stop_at_block_gap_done;
wire                            rd_pause;
wire                            emmc_cmd_i;
wire                            emmc_cmd_o;
wire                            emmc_cmd_oe;
wire    [7:0]                   emmc_dat_i_hi;
wire    [7:0]                   emmc_dat_i_lo;
wire    [7:0]                   emmc_dat_o_hi;
wire    [7:0]                   emmc_dat_o_lo;
wire                            emmc_dat_oe;
//rx cdc sync
wire                            emmc_rx_cmd_vld;
wire                            emmc_rx_cmd;
wire                            emmc_rx_dat_vld;
wire    [15:0]                  emmc_rx_dat;
wire                            fifo_rstn;
//DMA Engine
wire                            dma_wr_start;
wire                            dma_rd_start;
wire                            dma_rd_done;
//Clock Domain Cross
//--bistable_domain_cross
wire                            clk_out_en_emmc_clk;
wire    [15:0]                  clk_div_emmc_clk;
wire    [15:0]                  clk_div_emmc_clk_cal;
wire    [2:0]                   cpu_shift_emmc_clk;         
wire                            cpu_shift_ena_emmc_clk;
wire    [15:0]                  sample_cnt_emmc_clk_cal;
wire    [11:0]                  block_size_emmc_clk;
wire    [15:0]                  block_count_emmc_clk;
wire    [31:0]                  argument_1_emmc_clk;
wire                            dma_enable_emmc_clk;
wire    [1:0]                   auto_cmd_enable_emmc_clk;
wire    [1:0]                   response_type_select_emmc_clk;
wire                            data_transfer_direction_select_emmc_clk;
wire                            command_crc_check_enable_emmc_clk;
wire                            command_index_check_enable_emmc_clk;
wire                            data_present_select_emmc_clk;
wire    [5:0]                   command_index_emmc_clk;
wire    [1:0]                   data_transfer_width_emmc_clk;
wire                            stop_at_block_gap_request_emmc_clk;
wire                            continue_request_emmc_clk;
wire                            cmd_start_emmc_clk;
wire                            cmd_busy_mcu_clk;
wire                            wr_start_emmc_clk;
wire                            rd_start_emmc_clk;
wire                            dat_busy_mcu_clk;
wire                            dma_wr_start_dma_clk;
wire                            dma_rd_start_dma_clk;
wire    [31:0]                  adma_system_address_dma_clk;
wire                            stop_at_block_gap_request_dma_clk;
wire                            emmc_dat_OE_emmc_clk_cal;
//--pulse_and_data_domain_cross
wire                            resp_vld_mcu_clk;
wire    [119:0]                 resp_mcu_clk;
wire    [4:0]                   resp_err_mcu_clk;
wire                            auto_cmd_en_mcu_clk;
wire                            dat_crc_vld_mcu_clk;
wire                            dat_crc_ok_mcu_clk;
//--pulse_domain_cross
wire                            data_err_mcu_clk;
wire                            end_bit_of_cmd_mcu_clk;
wire                            wr_bk_transfer_done_mcu_clk;
wire                            rd_bk_transfer_done_mcu_clk;
wire                            stop_at_block_gap_done_mcu_clk;
wire                            dma_rd_done_mcu_clk;
//--adma interface
wire                            m1_axi_awvalid;
wire    [31:0]                  m1_axi_awaddr;
wire    [7:0]                   m1_axi_awlen;
wire    [2:0]                   m1_axi_awsize;
wire    [1:0]                   m1_axi_awburst;
wire    [2:0]                   m1_axi_awprot;
wire    [1:0]                   m1_axi_awlock;
wire    [3:0]                   m1_axi_awcache;
wire                            m1_axi_awready;
wire    [31:0]                  m1_axi_wdata;
wire    [3:0]                   m1_axi_wstrb;
wire                            m1_axi_wlast;
wire                            m1_axi_wvalid;
wire                            m1_axi_wready;
wire    [1:0]                   m1_axi_bresp;
wire                            m1_axi_bvalid;
wire                            m1_axi_bready;
wire                            m1_axi_arvalid;
wire    [31:0]                  m1_axi_araddr;
wire    [7:0]                   m1_axi_arlen;
wire    [2:0]                   m1_axi_arsize;
wire    [1:0]                   m1_axi_arburst;
wire    [2:0]                   m1_axi_arprot;
wire    [1:0]                   m1_axi_arlock;
wire    [3:0]                   m1_axi_arcache;
wire                            m1_axi_arready;
wire                            m1_axi_rvalid;
wire    [31:0]                  m1_axi_rdata;
wire                            m1_axi_rlast;
wire    [1:0]                   m1_axi_rresp;
wire                            m1_axi_rready;
//--asyn reset cross clock
wire                            emmc_rstn_s_axi_aclk;
wire                            emmc_rstn_m_axi_clk;
wire                            emmc_rstn_emmc_clk;
wire                            emmc_rstn_emmc_clk_cal;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/

/*-------------------------- Asyn Reset Cross Clock--------------------------------*/
asynreset_deal u_reset0 (.clk (s_axi_aclk        ), .rstn_i (~emmc_rst ), .rstn_o (emmc_rstn_s_axi_aclk   ));
asynreset_deal u_reset1 (.clk (m_axi_clk         ), .rstn_i (~emmc_rst ), .rstn_o (emmc_rstn_m_axi_clk    ));
asynreset_deal u_reset2 (.clk (emmc_base_clk     ), .rstn_i (~emmc_rst ), .rstn_o (emmc_rstn_emmc_clk     ));
asynreset_deal u_reset3 (.clk (emmc_base_clk_cal ), .rstn_i (~emmc_rst ), .rstn_o (emmc_rstn_emmc_clk_cal ));

/*--------------------------- Clock Region ---------------------------------*/

assign clk_enable = (clk_out_en_emmc_clk == 1'b1) && (rd_pause == 1'b0);

clock_management u_clock_management
(
//Global Signals
    .emmc_base_clk                      (emmc_base_clk                      ),
    .rstn_emmc_clk                      (emmc_rstn_emmc_clk                 ),
    .emmc_base_clk_cal                  (emmc_base_clk_cal                  ),
    .rstn_emmc_clk_cal                  (emmc_rstn_emmc_clk_cal             ),
//Sampling Clock Phase Dynamic Adjustment Signals
//--From RISC-V
    .cpu_shift                          (cpu_shift_emmc_clk                 ),
    .cpu_shift_ena                      (cpu_shift_ena_emmc_clk             ),
//--To FPGA PLL 
    .pll_SHIFT                          (pll_SHIFT                          ),
    .pll_SHIFT_ENA                      (pll_SHIFT_ENA                      ),
//Control Signals
    .cpu_clk_out_en                     (clk_out_en_emmc_clk                ),
    .clk_div                            (clk_div_emmc_clk                   ),
    .emmc_clk_en                        (emmc_clk_en                        ),
    .sample_cnt                         (sample_cnt_emmc_clk_cal            ),
    .sample_en                          (sample_en                          )
);

assign pll_SHIFT_SEL = SHIFT_SEL[4:0];

/*------------------ Configuration Management Region -----------------------*/
reg_axi4_lite#(
    .ADDR_WTH                           (10                                 ),
    .VERSION                            (VERSION                            ),
    .BASE_CLK_FREQ                      (BASE_CLK_FREQ                      ),
    .MAX_BLOCK_LEN                      (BUFFER_BLOCK_SIZE                  )
)
u_reg_axi4_lite
(
//Global Signals

//AXI4-Lite Interface
    .s_axi_aclk                         (s_axi_aclk                         ),
    .s_axi_aresetn                      (emmc_rstn_s_axi_aclk               ),
    .s_axi_awaddr                       (s_axi_awaddr                       ),
    .s_axi_awvalid                      (s_axi_awvalid                      ),
    .s_axi_awready                      (s_axi_awready                      ),
    .s_axi_wdata                        (s_axi_wdata                        ),
    .s_axi_wstrb                        (s_axi_wstrb                        ),
    .s_axi_wvalid                       (s_axi_wvalid                       ),
    .s_axi_wready                       (s_axi_wready                       ),
    .s_axi_bresp                        (s_axi_bresp                        ),
    .s_axi_bvalid                       (s_axi_bvalid                       ),
    .s_axi_bready                       (s_axi_bready                       ),
    .s_axi_araddr                       (s_axi_araddr                       ),
    .s_axi_arvalid                      (s_axi_arvalid                      ),
    .s_axi_arready                      (s_axi_arready                      ),
    .s_axi_rresp                        (s_axi_rresp                        ),
    .s_axi_rdata                        (s_axi_rdata                        ),
    .s_axi_rvalid                       (s_axi_rvalid                       ),
    .s_axi_rlast                        (s_axi_rlast                        ),
    .s_axi_rready                       (s_axi_rready                       ),
//Auxiliary Signals
    .emmc_int                           (emmc_int                           ),
//Cfg Space Registers
//--Base Configuration Registers Field
    .clk_out_en                         (clk_out_en                         ),
    .clk_out_div                        (clk_out_div                        ),
//--Sampling Clock Phase Dynamic Adjustment Registers Field
    .cpu_shift                          (cpu_shift                          ),
    .cpu_shift_ena                      (cpu_shift_ena                      ),
    .sample_cnt                         (sample_cnt                         ),
//--eMMC Host Control Registers Field
    .argument_2                         (                                   ),
    .block_size                         (block_size                         ),
    .block_count                        (block_count                        ),
    .argument_1                         (argument_1                         ),
    .dma_enable                         (dma_enable                         ),
    .auto_cmd_enable                    (auto_cmd_enable                    ),
    .response_type_select               (response_type_select               ),
    .data_transfer_direction_select     (data_transfer_direction_select     ),
    .command_crc_check_enable           (command_crc_check_enable           ),
    .command_index_check_enable         (command_index_check_enable         ),
    .data_present_select                (data_present_select                ),
    .command_type                       (                                   ),
    .command_index                      (command_index                      ),
    //debug start
    .dat_line_active                    (dat_line_active                    ),
    .write_transfer_active              (write_transfer_active              ),
    .read_transfer_active               (read_transfer_active               ),
    .command_complete                   (command_complete                   ),
    .transfer_complete                  (transfer_complete                  ),
    .block_gap_event                    (block_gap_event                    ),
    .buffer_write_ready                 (buffer_write_ready                 ),
    .buffer_read_ready                  (buffer_read_ready                  ),
    .card_insertion                     (card_insertion                     ),
    .card_removal                       (card_removal                       ),
    //debug end
    .data_transfer_width                (data_transfer_width                ),
    .data_ddr_mode                      (data_ddr_mode                      ),   
    .stop_at_block_gap_request          (stop_at_block_gap_request          ),
    .continue_request                   (continue_request                   ),
    .adma_system_address                (adma_system_address                ),
//Logic Signals
//--eMMC Host Control Registers Field
    .cmd_start                          (cmd_start                          ),
    .cmd_busy                           (cmd_busy_mcu_clk                   ),
    .wr_start                           (wr_start                           ),
    .rd_start                           (rd_start                           ),
    .dat_busy                           (dat_busy_mcu_clk                   ),
    .dma_wr_start                       (dma_wr_start                       ),
    .dma_rd_start                       (dma_rd_start                       ),
    .resp                               (resp_mcu_clk                       ),
    .resp_vld                           (resp_vld_mcu_clk                   ),
    .resp_err                           (resp_err_mcu_clk                   ),
    .data_err                           (data_err_mcu_clk                   ),
    .auto_cmd_en                        (auto_cmd_en_mcu_clk                ),
    .dat_crc_vld                        (dat_crc_vld_mcu_clk                ),
    .dat_crc_ok                         (dat_crc_ok_mcu_clk                 ),
    .buffer_write_enable                (buffer_write_enable                ),
    .buffer_read_enable                 (buffer_read_enable                 ),
    .wr_bk_transfer_done                (wr_bk_transfer_done_mcu_clk        ),
    .rd_bk_transfer_done                (rd_bk_transfer_done_mcu_clk        ),
    .stop_at_block_gap_done             (stop_at_block_gap_done_mcu_clk     ),
    .end_bit_of_cmd                     (end_bit_of_cmd_mcu_clk             ),
    .dma_rd_done                        (dma_rd_done_mcu_clk                ),
    .non_dma_wr_vld                     (non_dma_wr_vld                     ),
    .non_dma_wr_data                    (non_dma_wr_data                    ),
    .non_dma_rd_data                    (non_dma_rd_data                    ),
    .non_dma_rd_eop                     (non_dma_rd_eop                     ),
    .non_dma_rd_rdy                     (non_dma_rd_rdy                     ),
    .rd_buf_rst                         (rd_buf_rst                         ),
    .wr_buf_rst                         (wr_buf_rst                         ),
    .sw_reset_dat                       (sw_reset_dat                       )
);

/*-------------------------- DMA Engine Region -----------------------------*/
dma_engine u_dma_engine
(
//Global Signals
    .rstn                               (emmc_rstn_m_axi_clk                ),
//Cmd Control Signals
    .dma_start                          ({dma_rd_start_dma_clk,dma_wr_start_dma_clk}),
    .adma_system_address                (adma_system_address_dma_clk        ),
    .stop_at_block_gap_request          (stop_at_block_gap_request_dma_clk  ),
    .dma_wr_done                        (                                   ),
    .dma_rd_done                        (dma_rd_done                        ),
//Master AXI4 Bus Interface
    .m_axi_clk                          (m_axi_clk                          ),
//--Write Bus Interface
    .m_axi_awvalid                      (m1_axi_awvalid                     ),
    .m_axi_awaddr                       (m1_axi_awaddr                      ),
    .m_axi_awlen                        (m1_axi_awlen                       ),
    .m_axi_awsize                       (m1_axi_awsize                      ),
    .m_axi_awburst                      (m1_axi_awburst                     ),
    .m_axi_awprot                       (m1_axi_awprot                      ),
    .m_axi_awlock                       (m1_axi_awlock                      ),
    .m_axi_awcache                      (m1_axi_awcache                     ),
    .m_axi_awready                      (m1_axi_awready                     ),
    .m_axi_wdata                        (m1_axi_wdata                       ),
    .m_axi_wstrb                        (m1_axi_wstrb                       ),
    .m_axi_wlast                        (m1_axi_wlast                       ),
    .m_axi_wvalid                       (m1_axi_wvalid                      ),
    .m_axi_wready                       (m1_axi_wready                      ),
    .m_axi_bresp                        (m1_axi_bresp                       ),
    .m_axi_bvalid                       (m1_axi_bvalid                      ),
    .m_axi_bready                       (m1_axi_bready                      ),
//--Read Bus Interface
    .m_axi_arvalid                      (m1_axi_arvalid                     ),
    .m_axi_araddr                       (m1_axi_araddr                      ),
    .m_axi_arlen                        (m1_axi_arlen                       ),
    .m_axi_arsize                       (m1_axi_arsize                      ),
    .m_axi_arburst                      (m1_axi_arburst                     ),
    .m_axi_arprot                       (m1_axi_arprot                      ),
    .m_axi_arlock                       (m1_axi_arlock                      ),
    .m_axi_arcache                      (m1_axi_arcache                     ),
    .m_axi_arready                      (m1_axi_arready                     ),
    .m_axi_rvalid                       (m1_axi_rvalid                      ),
    .m_axi_rdata                        (m1_axi_rdata                       ),
    .m_axi_rlast                        (m1_axi_rlast                       ),
    .m_axi_rresp                        (m1_axi_rresp                       ),
    .m_axi_rready                       (m1_axi_rready                      ),
//Buffer Write Interface
    .dma_wr_vld                         (dma_wr_vld                         ),
    .dma_wr_data                        (dma_wr_data                        ),
    .dma_wr_rdy                         (dma_wr_rdy                         ),
//Buffer Read Interface
    .dma_rd_vld                         (dma_rd_vld                         ),
    .dma_rd_data                        (dma_rd_data                        ),
    .dma_rd_rdy                         (dma_rd_rdy                         )
);

/*----------------------- Buffer Control Region ----------------------------*/
buf_ctr#(
    .BUFFER_BLOCK_COUNT                 (BUFFER_BLOCK_COUNT                 ),
    .BUFFER_BLOCK_SIZE                  (BUFFER_BLOCK_SIZE                  ),
    .FAMILY                             (FAMILY                             ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
u_buf_ctr
(
//Global Signals
    .rstn                               (!emmc_rst                          ),
    .rd_buf_rst                         (rd_buf_rst                         ),
    .wr_buf_rst                         (wr_buf_rst                         ),
    .sw_reset_dat                       (sw_reset_dat                       ),
    .emmc_clk                           (emmc_base_clk                      ),
    .emmc_clk_en                        (emmc_clk_en                        ),
//Control Signals
    .bk_size_non_dma_clk                (block_size                         ),
    .bk_size_emmc_clk                   (block_size_emmc_clk                ),
    .dma_enable_emmc_clk                (dma_enable_emmc_clk                ),
    .dma_enable_non_dma_clk             (dma_enable                         ),
    .buffer_write_enable_non_dma_clk    (buffer_write_enable                ),
    .buffer_read_enable_non_dma_clk     (buffer_read_enable                 ),
    .buf_wr_transfer_rdy_emmc_clk       (buf_wr_transfer_rdy                ),
    .buf_rd_transfer_rdy_emmc_clk       (buf_rd_transfer_rdy                ),
//Non DMA Interface
    .non_dma_clk                        (s_axi_aclk                         ),
    .non_dma_wr_vld                     (non_dma_wr_vld                     ),
    .non_dma_wr_data                    (non_dma_wr_data                    ),
    .non_dma_rd_vld                     (non_dma_rd_vld                     ),
    .non_dma_rd_data                    (non_dma_rd_data                    ),
    .non_dma_rd_eop                     (non_dma_rd_eop                     ),
    .non_dma_rd_rdy                     (non_dma_rd_rdy                     ),
//DMA Interface
    .dma_clk                            (m_axi_clk                          ),
    .dma_wr_vld                         (dma_wr_vld                         ),
    .dma_wr_data                        (dma_wr_data                        ),
    .dma_wr_rdy                         (dma_wr_rdy                         ),
    .dma_rd_vld                         (dma_rd_vld                         ),
    .dma_rd_data                        (dma_rd_data                        ),
    .dma_rd_rdy                         (dma_rd_rdy                         ),
//Fifo Out Interface
    .ff_tx_data                         (ff_tx_data                         ),
    .ff_tx_vld                          (ff_tx_vld                          ),
    .ff_tx_rdy                          (ff_tx_rdy                          ),
//Fifo In Interface
    .ff_rx_data                         (ff_rx_data                         ),
    .ff_rx_vld                          (ff_rx_vld                          ),
    .ff_rx_eop                          (ff_rx_eop                          ),
    .ff_rx_err                          (ff_rx_err                          ),
    .ff_rx_rdy                          (                                   )
);

/*---------------------- eMMC Cmd Controller Region ------------------------*/
emmc_cmd_ctr u_emmc_cmd_ctr
(
//Global Signals
    .clk                                (emmc_base_clk                      ),
    .clk_en                             (emmc_clk_en                        ),
    .rstn                               (emmc_rstn_emmc_clk                 ),
//Control Signals
    .cmd_start                          (cmd_start_emmc_clk                 ),
    .cmd_busy                           (cmd_busy                           ),
    .cmd                                ({command_index_emmc_clk,argument_1_emmc_clk}),
    .cmd_resp_type                      (response_type_select_emmc_clk      ),
    .data_transfer_direction_select     (data_transfer_direction_select_emmc_clk),
    .cmd_crc_chk_en                     (command_crc_check_enable_emmc_clk  ),
    .cmd_index_chk_en                   (command_index_check_enable_emmc_clk),
    .data_present                       (data_present_select_emmc_clk       ),
    .resp                               (resp                               ),
    .resp_vld                           (resp_vld                           ),
    .resp_err                           (resp_err                           ),
    .auto_cmd_en                        (auto_cmd_en                        ),
    .auto_cmd12_start                   (auto_cmd12_start                   ),
    .end_bit_of_cmd                     (end_bit_of_cmd                     ),
//eMMC Interface
    .emmc_dat_i_vld                     (emmc_rx_dat_vld                    ),
    .emmc_dat_i                         (emmc_rx_dat[8]                     ),
    .emmc_cmd_i_vld                     (emmc_rx_cmd_vld                    ),
    .emmc_cmd_i                         (emmc_rx_cmd                        ),
    .emmc_cmd_o                         (emmc_cmd_o                         ),
    .emmc_cmd_oe                        (emmc_cmd_oe                        )
);

/*---------------------- eMMC Dat Controller Region ------------------------*/
emmc_dat_ctr u_emmc_dat_ctr
(
//Global Signals
    .clk                                (emmc_base_clk                      ),
    .clk_en                             (emmc_clk_en                        ),
    .rstn                               (emmc_rstn_emmc_clk                 ),
//Configuration Signals
    .data_transfer_width                (data_transfer_width_emmc_clk       ),
    .data_ddr_mode                      (data_ddr_mode_emmc_clk             ),   
//Control Signals
    .dat_start                          ({rd_start_emmc_clk,wr_start_emmc_clk}),
    .dat_busy                           (dat_busy                           ),
    .bk_size                            (block_size_emmc_clk                ),
    .bk_cnt                             (block_count_emmc_clk               ),
    .stop_at_block_gap_request          (stop_at_block_gap_request_emmc_clk ),
    .continue_request                   (continue_request_emmc_clk          ),
    .dat_crc_vld                        (dat_crc_vld                        ),
    .dat_crc_ok                         (dat_crc_ok                         ),
    .auto_cmd_enable                    (auto_cmd_enable_emmc_clk           ),
    .auto_cmd12_start                   (auto_cmd12_start                   ),
    .buf_wr_transfer_rdy                (buf_wr_transfer_rdy                ),
    .buf_rd_transfer_rdy                (buf_rd_transfer_rdy                ),
    .wr_bk_transfer_done                (wr_bk_transfer_done                ),
    .rd_bk_transfer_done                (rd_bk_transfer_done                ),
    .stop_at_block_gap_done             (stop_at_block_gap_done             ),
    .rd_pause                           (rd_pause                           ),
//Tx Fifo Interface
    .ff_tx_data                         (ff_tx_data                         ),
    .ff_tx_vld                          (ff_tx_vld                          ),
    .ff_tx_rdy                          (ff_tx_rdy                          ),
//Rx Fifo Interface
    .ff_rx_data                         (ff_rx_data                         ),
    .ff_rx_vld                          (ff_rx_vld                          ),
    .ff_rx_eop                          (ff_rx_eop                          ),
    .ff_rx_err                          (ff_rx_err                          ),
//eMMC Interface
    .emmc_dat_i_vld                     (emmc_rx_dat_vld                    ),
    .emmc_dat_i                         (emmc_rx_dat                        ),
    .emmc_dat_o                         ({emmc_dat_o_hi,emmc_dat_o_lo}      ),
    .emmc_dat_oe                        (emmc_dat_oe                        )
);

/*--------------------------- Tx Clock Align Region ------------------------*/
emmc_clk_adapt_ddio_clk u_emmc_clk_adapt_ddio_clk
(
//Global Signals
    .rstn                               (emmc_rstn_emmc_clk                 ),
    .clk                                (emmc_base_clk                      ),
//Control Signals
    .clk_enable                         (clk_enable                         ),
    .clk_div                            (clk_div_emmc_clk                   ),
    .clk_en                             (emmc_clk_en                        ),
    .data_ddr_mode                      (data_ddr_mode_emmc_clk             ),
//eMMC Clock Signals
    .emmc_clk_HI                        (emmc_clk_HI                        ),
    .emmc_clk_LO                        (emmc_clk_LO                        ),
//eMMC CMD Signals
    .emmc_cmd_o                         (emmc_cmd_o                         ),
    .emmc_cmd_oe                        (emmc_cmd_oe                        ),
    .emmc_cmd_OUT_HI                    (emmc_cmd_OUT_HI                    ),
    .emmc_cmd_OUT_LO                    (emmc_cmd_OUT_LO                    ),
    .emmc_cmd_OE                        (emmc_cmd_OE                        ),
//eMMC DAT Signals
    .emmc_dat_o_hi                      (emmc_dat_o_hi                      ),
    .emmc_dat_o_lo                      (emmc_dat_o_lo                      ),
    .emmc_dat_oe                        (emmc_dat_oe                        ),
    .emmc_dat_OUT_HI                    (emmc_dat_OUT_HI                    ),
    .emmc_dat_OUT_LO                    (emmc_dat_OUT_LO                    ),
    .emmc_dat_OE                        (emmc_dat_OE                        )
);

/*--------------------------- Rx Clock Align Region ------------------------*/
ddio_clk_adapt_emmc_clk u_ddio_clk_adapt_emmc_clk
(
    .rstn                               (emmc_rstn_emmc_clk_cal             ),
    .clk                                (emmc_base_clk_cal                  ),
//Control Signals
    .clk_enable                         (clk_enable                         ),
    .clk_div                            (clk_div_emmc_clk_cal               ),
    .sample_en                          (sample_en                          ),
//eMMC CMD Signals
    .emmc_cmd_IN_HI                     (emmc_cmd_IN_HI                     ),
    .emmc_cmd_IN_LO                     (emmc_cmd_IN_LO                     ),
    .emmc_cmd_i                         (emmc_cmd_i                         ),
    .emmc_cmd_OE                        (emmc_cmd_OE                        ),
//eMMC DAT Signals
    .emmc_dat_IN_HI                     (emmc_dat_IN_HI                     ),
    .emmc_dat_IN_LO                     (emmc_dat_IN_LO                     ),
    .emmc_dat_i_hi                      (emmc_dat_i_hi                      ),
    .emmc_dat_i_lo                      (emmc_dat_i_lo                      ),
    .emmc_dat_OE                        (emmc_dat_OE_emmc_clk_cal           )
);

/*------------------------ Rx CMD & Data CDC Region ------------------------*/

assign fifo_rstn = ~((emmc_rst == 1'b1) || (pll_SHIFT_ENA == 1'b1));

rx_cdc_sync #(
    .WTH                                (1                                  ),
    .DEPTH                              (512                                ),
    .FAMILY                             (FAMILY                             ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
cmd_rx_cdc_sync
(
    .rstn                               (fifo_rstn                          ),
    .s_clk                              (emmc_base_clk_cal                  ),
    .s_clk_en                           (sample_en                          ),
    .m_clk                              (emmc_base_clk                      ),
    .m_clk_en                           (emmc_clk_en                        ),
    .s_emmc_rx_dat                      (emmc_cmd_i                         ),
    .m_emmc_rx_vld                      (emmc_rx_cmd_vld                    ),
    .m_emmc_rx_dat                      (emmc_rx_cmd                        )
);

rx_cdc_sync #(
    .WTH                                (16                                 ),
    .DEPTH                              (512                                ),
    .FAMILY                             (FAMILY                             ),
    .RAM_STYLE                          (RAM_STYLE                          )
)
dat_rx_cdc_sync
(
    .rstn                               (fifo_rstn                          ),
    .s_clk                              (emmc_base_clk_cal                  ),
    .s_clk_en                           (sample_en                          ),
    .m_clk                              (emmc_base_clk                      ),
    .m_clk_en                           (emmc_clk_en                        ),
    .s_emmc_rx_dat                      ({emmc_dat_i_hi,emmc_dat_i_lo}      ),
    .m_emmc_rx_vld                      (emmc_rx_dat_vld                    ),
    .m_emmc_rx_dat                      (emmc_rx_dat                        )
);

/*-------------------------- Clock Domain Cross ----------------------------*/
//-----------------------------bistable_domain_cross
//--emmc_base_clk
bistable_domain_cross #(1) clk_out_en_cross                     (emmc_rstn_emmc_clk,emmc_base_clk,1'b1,clk_out_en,clk_out_en_emmc_clk);
bistable_domain_cross #(16) clk_div_cross1                      (emmc_rstn_emmc_clk,emmc_base_clk,1'b1,clk_out_div,clk_div_emmc_clk);
bistable_domain_cross #(3) cpu_shift_cross                      (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,cpu_shift,cpu_shift_emmc_clk);
bistable_domain_cross #(1) cpu_shift_ena_cross                  (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,cpu_shift_ena,cpu_shift_ena_emmc_clk);
bistable_domain_cross #(12) block_size_cross                    (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,block_size,block_size_emmc_clk);
bistable_domain_cross #(16) block_count_cross                   (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,block_count,block_count_emmc_clk);
bistable_domain_cross #(32) argument_1_cross                    (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,argument_1,argument_1_emmc_clk);
bistable_domain_cross #(1) dma_enable_cross                     (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,dma_enable,dma_enable_emmc_clk);
bistable_domain_cross #(2) auto_cmd_enable_cross                (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,auto_cmd_enable,auto_cmd_enable_emmc_clk);
bistable_domain_cross #(2) response_type_select_cross           (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,response_type_select,response_type_select_emmc_clk);
bistable_domain_cross #(1) data_transfer_direction_select_cross (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,data_transfer_direction_select,data_transfer_direction_select_emmc_clk);
bistable_domain_cross #(1) command_crc_check_enable_cross       (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,command_crc_check_enable,command_crc_check_enable_emmc_clk);
bistable_domain_cross #(1) command_index_check_enable_cross     (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,command_index_check_enable,command_index_check_enable_emmc_clk);
bistable_domain_cross #(1) data_present_select_cross            (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,data_present_select,data_present_select_emmc_clk);
bistable_domain_cross #(6) command_index_cross                  (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,command_index,command_index_emmc_clk);
bistable_domain_cross #(2) data_transfer_width_cross            (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,data_transfer_width,data_transfer_width_emmc_clk);
bistable_domain_cross #(1) data_ddr_mode_cross                  (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,data_ddr_mode,data_ddr_mode_emmc_clk);
bistable_domain_cross #(1) stop_at_block_gap_request_cross      (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,stop_at_block_gap_request,stop_at_block_gap_request_emmc_clk);
bistable_domain_cross #(1) continue_request_cross               (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,continue_request,continue_request_emmc_clk);
bistable_domain_cross #(1) cmd_start_cross                      (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,cmd_start,cmd_start_emmc_clk);
bistable_domain_cross #(1) wr_start_cross                       (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,wr_start,wr_start_emmc_clk);
bistable_domain_cross #(1) rd_start_cross                       (emmc_rstn_emmc_clk,emmc_base_clk,emmc_clk_en,rd_start,rd_start_emmc_clk);
//--emmc_base_clk_cal
bistable_domain_cross #(16) sample_cnt_cross                    (emmc_rstn_emmc_clk_cal,emmc_base_clk_cal,1'b1,sample_cnt,sample_cnt_emmc_clk_cal);
bistable_domain_cross #(16) clk_div_cross2                      (emmc_rstn_emmc_clk_cal,emmc_base_clk_cal,1'b1,clk_out_div,clk_div_emmc_clk_cal);
bistable_domain_cross #(1)  emmc_dat_OE_cross                   (emmc_rstn_emmc_clk_cal,emmc_base_clk_cal,1'b1,emmc_dat_OE,emmc_dat_OE_emmc_clk_cal);

//--s_axi_aclk
bistable_domain_cross #(1) cmd_busy_cross                       (emmc_rstn_s_axi_aclk,s_axi_aclk,1'b1,cmd_busy,cmd_busy_mcu_clk);
bistable_domain_cross #(1) dat_busy_cross                       (emmc_rstn_s_axi_aclk,s_axi_aclk,1'b1,dat_busy,dat_busy_mcu_clk);
//--m_axi_clk
bistable_domain_cross #(1) dma_wr_start_cross                   (emmc_rstn_m_axi_clk,m_axi_clk,1'b1,dma_wr_start,dma_wr_start_dma_clk);
bistable_domain_cross #(1) dma_rd_start_cross                   (emmc_rstn_m_axi_clk,m_axi_clk,1'b1,dma_rd_start,dma_rd_start_dma_clk);
bistable_domain_cross #(32) adma_system_address_cross           (emmc_rstn_m_axi_clk,m_axi_clk,1'b1,adma_system_address[31:0],adma_system_address_dma_clk);
bistable_domain_cross #(1) stop_at_block_gap_request_cross_2    (emmc_rstn_m_axi_clk,m_axi_clk,1'b1,stop_at_block_gap_request,stop_at_block_gap_request_dma_clk);

//-----------------------------pulse_and_data_domain_cross
pulse_and_data_domain_cross_sr #(126) resp_vld_cross  (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,resp_vld,{auto_cmd_en,resp_err,resp},resp_vld_mcu_clk,{auto_cmd_en_mcu_clk,resp_err_mcu_clk,resp_mcu_clk});
pulse_and_data_domain_cross_sr #(1) dat_crc_vld_cross (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,dat_crc_vld,{dat_crc_ok},dat_crc_vld_mcu_clk,{dat_crc_ok_mcu_clk});

//-----------------------------pulse_domain_cross
pulse_domain_cross_sr data_err_cross               (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,ff_rx_err,data_err_mcu_clk);
pulse_domain_cross_sr end_bit_of_cmd_cross         (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,end_bit_of_cmd,end_bit_of_cmd_mcu_clk);
pulse_domain_cross_sr wr_bk_transfer_done_cross    (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,wr_bk_transfer_done,wr_bk_transfer_done_mcu_clk);
pulse_domain_cross_sr rd_bk_transfer_done_cross    (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,rd_bk_transfer_done,rd_bk_transfer_done_mcu_clk);
pulse_domain_cross_sr stop_at_block_gap_done_cross (emmc_base_clk,emmc_rstn_emmc_clk,emmc_clk_en,s_axi_aclk,emmc_rstn_s_axi_aclk,stop_at_block_gap_done,stop_at_block_gap_done_mcu_clk);
pulse_domain_cross_sr dma_rd_done_cross            (m_axi_clk    ,emmc_rstn_m_axi_clk,1'b1      ,s_axi_aclk,emmc_rstn_s_axi_aclk,dma_rd_done,dma_rd_done_mcu_clk);

// ADMA data upsizer
assign m_reset = ~emmc_rstn_m_axi_clk;
generate
if(ADMA_DATA_WIDTH == 512 )
begin
Asic32To512UpsizerAxi4Upsizer axi4_upsizer_32to512
(
 .io_input_aw_valid         ( m1_axi_awvalid    ),
 .io_input_aw_ready         ( m1_axi_awready    ),
 .io_input_aw_payload_addr  ( m1_axi_awaddr     ),
 .io_input_aw_payload_id    ( 8'h0 ),
 .io_input_aw_payload_region( 4'h0 ),
 .io_input_aw_payload_len   ( m1_axi_awlen      ),
 .io_input_aw_payload_size  ( m1_axi_awsize     ),
 .io_input_aw_payload_burst ( m1_axi_awburst    ),
 .io_input_aw_payload_lock  ( m1_axi_awlock[0]  ),
 .io_input_aw_payload_cache ( m1_axi_awcache    ),
 .io_input_aw_payload_qos   ( 4'h0 ),
 .io_input_aw_payload_prot  ( m1_axi_awprot     ),
 .io_input_w_valid          ( m1_axi_wvalid     ),
 .io_input_w_ready          ( m1_axi_wready     ),
 .io_input_w_payload_data   ( m1_axi_wdata      ),
 .io_input_w_payload_strb   ( m1_axi_wstrb      ),
 .io_input_w_payload_last   ( m1_axi_wlast      ),
 .io_input_b_valid          ( m1_axi_bvalid     ),
 .io_input_b_ready          ( m1_axi_bready     ),
 .io_input_b_payload_id     (  ),
 .io_input_b_payload_resp   ( m1_axi_bresp      ),
 .io_input_ar_valid         ( m1_axi_arvalid    ),
 .io_input_ar_ready         ( m1_axi_arready    ),
 .io_input_ar_payload_addr  ( m1_axi_araddr     ),
 .io_input_ar_payload_id    ( 8'h0 ),
 .io_input_ar_payload_region( 4'h0 ),
 .io_input_ar_payload_len   ( m1_axi_arlen      ),
 .io_input_ar_payload_size  ( m1_axi_arsize     ),
 .io_input_ar_payload_burst ( m1_axi_arburst    ),
 .io_input_ar_payload_lock  ( m1_axi_arlock[0]  ),
 .io_input_ar_payload_cache ( m1_axi_arcache    ),
 .io_input_ar_payload_qos   ( 4'h0 ),
 .io_input_ar_payload_prot  ( m1_axi_arprot     ),
 .io_input_r_valid          ( m1_axi_rvalid     ),
 .io_input_r_ready          ( m1_axi_rready     ),
 .io_input_r_payload_data   ( m1_axi_rdata      ),
 .io_input_r_payload_id     (  ),
 .io_input_r_payload_resp   ( m1_axi_rresp      ),
 .io_input_r_payload_last   ( m1_axi_rlast      ),
 .io_output_aw_valid         ( m_axi_awvalid    ),
 .io_output_aw_ready         ( m_axi_awready    ),
 .io_output_aw_payload_addr  ( m_axi_awaddr     ),
 .io_output_aw_payload_id    (  ),
 .io_output_aw_payload_region(  ),
 .io_output_aw_payload_len   ( m_axi_awlen      ),
 .io_output_aw_payload_size  ( m_axi_awsize     ),
 .io_output_aw_payload_burst ( m_axi_awburst    ),
 .io_output_aw_payload_lock  ( m_axi_awlock     ),
 .io_output_aw_payload_cache ( m_axi_awcache    ),
 .io_output_aw_payload_qos   (  ),
 .io_output_aw_payload_prot  ( m_axi_awprot     ),
 .io_output_w_valid          ( m_axi_wvalid     ),
 .io_output_w_ready          ( m_axi_wready     ),
 .io_output_w_payload_data   ( m_axi_wdata      ),
 .io_output_w_payload_strb   ( m_axi_wstrb      ),
 .io_output_w_payload_last   ( m_axi_wlast      ),
 .io_output_b_valid          ( m_axi_bvalid     ),
 .io_output_b_ready          ( m_axi_bready     ),
 .io_output_b_payload_id     ( 8'h0 ),
 .io_output_b_payload_resp   ( m_axi_bresp      ),
 .io_output_ar_valid         ( m_axi_arvalid    ),
 .io_output_ar_ready         ( m_axi_arready    ),
 .io_output_ar_payload_addr  ( m_axi_araddr     ),
 .io_output_ar_payload_id    (  ),
 .io_output_ar_payload_region(  ),
 .io_output_ar_payload_len   ( m_axi_arlen      ),
 .io_output_ar_payload_size  ( m_axi_arsize     ),
 .io_output_ar_payload_burst ( m_axi_arburst    ),
 .io_output_ar_payload_lock  ( m_axi_arlock     ),
 .io_output_ar_payload_cache ( m_axi_arcache    ),
 .io_output_ar_payload_qos   (  ),
 .io_output_ar_payload_prot  ( m_axi_arprot     ),
 .io_output_r_valid          ( m_axi_rvalid     ),
 .io_output_r_ready          ( m_axi_rready     ),
 .io_output_r_payload_data   ( m_axi_rdata      ),
 .io_output_r_payload_id     ( 8'h0 ),
 .io_output_r_payload_resp   ( m_axi_rresp      ),
 .io_output_r_payload_last   ( m_axi_rlast      ),
 .clk                        ( m_axi_clk        ),
 .reset                      ( m_reset          )
); 
end
else if(ADMA_DATA_WIDTH == 256 )
begin
Asic32To256UpsizerAxi4Upsizer axi4_upsizer_32to256
(
 .io_input_aw_valid         ( m1_axi_awvalid    ),
 .io_input_aw_ready         ( m1_axi_awready    ),
 .io_input_aw_payload_addr  ( m1_axi_awaddr     ),
 .io_input_aw_payload_id    ( 8'h0 ),
 .io_input_aw_payload_region( 4'h0 ),
 .io_input_aw_payload_len   ( m1_axi_awlen      ),
 .io_input_aw_payload_size  ( m1_axi_awsize     ),
 .io_input_aw_payload_burst ( m1_axi_awburst    ),
 .io_input_aw_payload_lock  ( m1_axi_awlock[0]  ),
 .io_input_aw_payload_cache ( m1_axi_awcache    ),
 .io_input_aw_payload_qos   ( 4'h0 ),
 .io_input_aw_payload_prot  ( m1_axi_awprot     ),
 .io_input_w_valid          ( m1_axi_wvalid     ),
 .io_input_w_ready          ( m1_axi_wready     ),
 .io_input_w_payload_data   ( m1_axi_wdata      ),
 .io_input_w_payload_strb   ( m1_axi_wstrb      ),
 .io_input_w_payload_last   ( m1_axi_wlast      ),
 .io_input_b_valid          ( m1_axi_bvalid     ),
 .io_input_b_ready          ( m1_axi_bready     ),
 .io_input_b_payload_id     (  ),
 .io_input_b_payload_resp   ( m1_axi_bresp      ),
 .io_input_ar_valid         ( m1_axi_arvalid    ),
 .io_input_ar_ready         ( m1_axi_arready    ),
 .io_input_ar_payload_addr  ( m1_axi_araddr     ),
 .io_input_ar_payload_id    ( 8'h0 ),
 .io_input_ar_payload_region( 4'h0 ),
 .io_input_ar_payload_len   ( m1_axi_arlen      ),
 .io_input_ar_payload_size  ( m1_axi_arsize     ),
 .io_input_ar_payload_burst ( m1_axi_arburst    ),
 .io_input_ar_payload_lock  ( m1_axi_arlock[0]  ),
 .io_input_ar_payload_cache ( m1_axi_arcache    ),
 .io_input_ar_payload_qos   ( 4'h0 ),
 .io_input_ar_payload_prot  ( m1_axi_arprot     ),
 .io_input_r_valid          ( m1_axi_rvalid     ),
 .io_input_r_ready          ( m1_axi_rready     ),
 .io_input_r_payload_data   ( m1_axi_rdata      ),
 .io_input_r_payload_id     (  ),
 .io_input_r_payload_resp   ( m1_axi_rresp      ),
 .io_input_r_payload_last   ( m1_axi_rlast      ),
 .io_output_aw_valid         ( m_axi_awvalid    ),
 .io_output_aw_ready         ( m_axi_awready    ),
 .io_output_aw_payload_addr  ( m_axi_awaddr     ),
 .io_output_aw_payload_id    (  ),
 .io_output_aw_payload_region(  ),
 .io_output_aw_payload_len   ( m_axi_awlen      ),
 .io_output_aw_payload_size  ( m_axi_awsize     ),
 .io_output_aw_payload_burst ( m_axi_awburst    ),
 .io_output_aw_payload_lock  ( m_axi_awlock     ),
 .io_output_aw_payload_cache ( m_axi_awcache    ),
 .io_output_aw_payload_qos   (  ),
 .io_output_aw_payload_prot  ( m_axi_awprot     ),
 .io_output_w_valid          ( m_axi_wvalid     ),
 .io_output_w_ready          ( m_axi_wready     ),
 .io_output_w_payload_data   ( m_axi_wdata      ),
 .io_output_w_payload_strb   ( m_axi_wstrb      ),
 .io_output_w_payload_last   ( m_axi_wlast      ),
 .io_output_b_valid          ( m_axi_bvalid     ),
 .io_output_b_ready          ( m_axi_bready     ),
 .io_output_b_payload_id     ( 8'h0 ),
 .io_output_b_payload_resp   ( m_axi_bresp      ),
 .io_output_ar_valid         ( m_axi_arvalid    ),
 .io_output_ar_ready         ( m_axi_arready    ),
 .io_output_ar_payload_addr  ( m_axi_araddr     ),
 .io_output_ar_payload_id    (  ),
 .io_output_ar_payload_region(  ),
 .io_output_ar_payload_len   ( m_axi_arlen      ),
 .io_output_ar_payload_size  ( m_axi_arsize     ),
 .io_output_ar_payload_burst ( m_axi_arburst    ),
 .io_output_ar_payload_lock  ( m_axi_arlock     ),
 .io_output_ar_payload_cache ( m_axi_arcache    ),
 .io_output_ar_payload_qos   (  ),
 .io_output_ar_payload_prot  ( m_axi_arprot     ),
 .io_output_r_valid          ( m_axi_rvalid     ),
 .io_output_r_ready          ( m_axi_rready     ),
 .io_output_r_payload_data   ( m_axi_rdata      ),
 .io_output_r_payload_id     ( 8'h0 ),
 .io_output_r_payload_resp   ( m_axi_rresp      ),
 .io_output_r_payload_last   ( m_axi_rlast      ),
 .clk                        ( m_axi_clk        ),
 .reset                      ( m_reset          )
); 
end
else if(ADMA_DATA_WIDTH == 128 )
begin
Asic32To128UpsizerAxi4Upsizer axi4_upsizer_32to128
(
 .io_input_aw_valid         ( m1_axi_awvalid    ),
 .io_input_aw_ready         ( m1_axi_awready    ),
 .io_input_aw_payload_addr  ( m1_axi_awaddr     ),
 .io_input_aw_payload_id    ( 8'h0 ),
 .io_input_aw_payload_region( 4'h0 ),
 .io_input_aw_payload_len   ( m1_axi_awlen      ),
 .io_input_aw_payload_size  ( m1_axi_awsize     ),
 .io_input_aw_payload_burst ( m1_axi_awburst    ),
 .io_input_aw_payload_lock  ( m1_axi_awlock[0]  ),
 .io_input_aw_payload_cache ( m1_axi_awcache    ),
 .io_input_aw_payload_qos   ( 4'h0 ),
 .io_input_aw_payload_prot  ( m1_axi_awprot     ),
 .io_input_w_valid          ( m1_axi_wvalid     ),
 .io_input_w_ready          ( m1_axi_wready     ),
 .io_input_w_payload_data   ( m1_axi_wdata      ),
 .io_input_w_payload_strb   ( m1_axi_wstrb      ),
 .io_input_w_payload_last   ( m1_axi_wlast      ),
 .io_input_b_valid          ( m1_axi_bvalid     ),
 .io_input_b_ready          ( m1_axi_bready     ),
 .io_input_b_payload_id     (  ),
 .io_input_b_payload_resp   ( m1_axi_bresp      ),
 .io_input_ar_valid         ( m1_axi_arvalid    ),
 .io_input_ar_ready         ( m1_axi_arready    ),
 .io_input_ar_payload_addr  ( m1_axi_araddr     ),
 .io_input_ar_payload_id    ( 8'h0 ),
 .io_input_ar_payload_region( 4'h0 ),
 .io_input_ar_payload_len   ( m1_axi_arlen      ),
 .io_input_ar_payload_size  ( m1_axi_arsize     ),
 .io_input_ar_payload_burst ( m1_axi_arburst    ),
 .io_input_ar_payload_lock  ( m1_axi_arlock[0]  ),
 .io_input_ar_payload_cache ( m1_axi_arcache    ),
 .io_input_ar_payload_qos   ( 4'h0 ),
 .io_input_ar_payload_prot  ( m1_axi_arprot     ),
 .io_input_r_valid          ( m1_axi_rvalid     ),
 .io_input_r_ready          ( m1_axi_rready     ),
 .io_input_r_payload_data   ( m1_axi_rdata      ),
 .io_input_r_payload_id     (  ),
 .io_input_r_payload_resp   ( m1_axi_rresp      ),
 .io_input_r_payload_last   ( m1_axi_rlast      ),
 .io_output_aw_valid         ( m_axi_awvalid    ),
 .io_output_aw_ready         ( m_axi_awready    ),
 .io_output_aw_payload_addr  ( m_axi_awaddr     ),
 .io_output_aw_payload_id    (  ),
 .io_output_aw_payload_region(  ),
 .io_output_aw_payload_len   ( m_axi_awlen      ),
 .io_output_aw_payload_size  ( m_axi_awsize     ),
 .io_output_aw_payload_burst ( m_axi_awburst    ),
 .io_output_aw_payload_lock  ( m_axi_awlock     ),
 .io_output_aw_payload_cache ( m_axi_awcache    ),
 .io_output_aw_payload_qos   (  ),
 .io_output_aw_payload_prot  ( m_axi_awprot     ),
 .io_output_w_valid          ( m_axi_wvalid     ),
 .io_output_w_ready          ( m_axi_wready     ),
 .io_output_w_payload_data   ( m_axi_wdata      ),
 .io_output_w_payload_strb   ( m_axi_wstrb      ),
 .io_output_w_payload_last   ( m_axi_wlast      ),
 .io_output_b_valid          ( m_axi_bvalid     ),
 .io_output_b_ready          ( m_axi_bready     ),
 .io_output_b_payload_id     ( 8'h0 ),
 .io_output_b_payload_resp   ( m_axi_bresp      ),
 .io_output_ar_valid         ( m_axi_arvalid    ),
 .io_output_ar_ready         ( m_axi_arready    ),
 .io_output_ar_payload_addr  ( m_axi_araddr     ),
 .io_output_ar_payload_id    (  ),
 .io_output_ar_payload_region(  ),
 .io_output_ar_payload_len   ( m_axi_arlen      ),
 .io_output_ar_payload_size  ( m_axi_arsize     ),
 .io_output_ar_payload_burst ( m_axi_arburst    ),
 .io_output_ar_payload_lock  ( m_axi_arlock     ),
 .io_output_ar_payload_cache ( m_axi_arcache    ),
 .io_output_ar_payload_qos   (  ),
 .io_output_ar_payload_prot  ( m_axi_arprot     ),
 .io_output_r_valid          ( m_axi_rvalid     ),
 .io_output_r_ready          ( m_axi_rready     ),
 .io_output_r_payload_data   ( m_axi_rdata      ),
 .io_output_r_payload_id     ( 8'h0 ),
 .io_output_r_payload_resp   ( m_axi_rresp      ),
 .io_output_r_payload_last   ( m_axi_rlast      ),
 .clk                        ( m_axi_clk        ),
 .reset                      ( m_reset          )
); 
end
else if(ADMA_DATA_WIDTH == 64 )
begin
Asic32To64UpsizerAxi4Upsizer axi4_upsizer_32to64
(
 .io_input_aw_valid         ( m1_axi_awvalid    ),
 .io_input_aw_ready         ( m1_axi_awready    ),
 .io_input_aw_payload_addr  ( m1_axi_awaddr     ),
 .io_input_aw_payload_id    ( 8'h0 ),
 .io_input_aw_payload_region( 4'h0 ),
 .io_input_aw_payload_len   ( m1_axi_awlen      ),
 .io_input_aw_payload_size  ( m1_axi_awsize     ),
 .io_input_aw_payload_burst ( m1_axi_awburst    ),
 .io_input_aw_payload_lock  ( m1_axi_awlock[0]  ),
 .io_input_aw_payload_cache ( m1_axi_awcache    ),
 .io_input_aw_payload_qos   ( 4'h0 ),
 .io_input_aw_payload_prot  ( m1_axi_awprot     ),
 .io_input_w_valid          ( m1_axi_wvalid     ),
 .io_input_w_ready          ( m1_axi_wready     ),
 .io_input_w_payload_data   ( m1_axi_wdata      ),
 .io_input_w_payload_strb   ( m1_axi_wstrb      ),
 .io_input_w_payload_last   ( m1_axi_wlast      ),
 .io_input_b_valid          ( m1_axi_bvalid     ),
 .io_input_b_ready          ( m1_axi_bready     ),
 .io_input_b_payload_id     (  ),
 .io_input_b_payload_resp   ( m1_axi_bresp      ),
 .io_input_ar_valid         ( m1_axi_arvalid    ),
 .io_input_ar_ready         ( m1_axi_arready    ),
 .io_input_ar_payload_addr  ( m1_axi_araddr     ),
 .io_input_ar_payload_id    ( 8'h0 ),
 .io_input_ar_payload_region( 4'h0 ),
 .io_input_ar_payload_len   ( m1_axi_arlen      ),
 .io_input_ar_payload_size  ( m1_axi_arsize     ),
 .io_input_ar_payload_burst ( m1_axi_arburst    ),
 .io_input_ar_payload_lock  ( m1_axi_arlock[0]  ),
 .io_input_ar_payload_cache ( m1_axi_arcache    ),
 .io_input_ar_payload_qos   ( 4'h0 ),
 .io_input_ar_payload_prot  ( m1_axi_arprot     ),
 .io_input_r_valid          ( m1_axi_rvalid     ),
 .io_input_r_ready          ( m1_axi_rready     ),
 .io_input_r_payload_data   ( m1_axi_rdata      ),
 .io_input_r_payload_id     (  ),
 .io_input_r_payload_resp   ( m1_axi_rresp      ),
 .io_input_r_payload_last   ( m1_axi_rlast      ),
 .io_output_aw_valid         ( m_axi_awvalid    ),
 .io_output_aw_ready         ( m_axi_awready    ),
 .io_output_aw_payload_addr  ( m_axi_awaddr     ),
 .io_output_aw_payload_id    (  ),
 .io_output_aw_payload_region(  ),
 .io_output_aw_payload_len   ( m_axi_awlen      ),
 .io_output_aw_payload_size  ( m_axi_awsize     ),
 .io_output_aw_payload_burst ( m_axi_awburst    ),
 .io_output_aw_payload_lock  ( m_axi_awlock     ),
 .io_output_aw_payload_cache ( m_axi_awcache    ),
 .io_output_aw_payload_qos   (  ),
 .io_output_aw_payload_prot  ( m_axi_awprot     ),
 .io_output_w_valid          ( m_axi_wvalid     ),
 .io_output_w_ready          ( m_axi_wready     ),
 .io_output_w_payload_data   ( m_axi_wdata      ),
 .io_output_w_payload_strb   ( m_axi_wstrb      ),
 .io_output_w_payload_last   ( m_axi_wlast      ),
 .io_output_b_valid          ( m_axi_bvalid     ),
 .io_output_b_ready          ( m_axi_bready     ),
 .io_output_b_payload_id     ( 8'h0 ),
 .io_output_b_payload_resp   ( m_axi_bresp      ),
 .io_output_ar_valid         ( m_axi_arvalid    ),
 .io_output_ar_ready         ( m_axi_arready    ),
 .io_output_ar_payload_addr  ( m_axi_araddr     ),
 .io_output_ar_payload_id    (  ),
 .io_output_ar_payload_region(  ),
 .io_output_ar_payload_len   ( m_axi_arlen      ),
 .io_output_ar_payload_size  ( m_axi_arsize     ),
 .io_output_ar_payload_burst ( m_axi_arburst    ),
 .io_output_ar_payload_lock  ( m_axi_arlock     ),
 .io_output_ar_payload_cache ( m_axi_arcache    ),
 .io_output_ar_payload_qos   (  ),
 .io_output_ar_payload_prot  ( m_axi_arprot     ),
 .io_output_r_valid          ( m_axi_rvalid     ),
 .io_output_r_ready          ( m_axi_rready     ),
 .io_output_r_payload_data   ( m_axi_rdata      ),
 .io_output_r_payload_id     ( 8'h0 ),
 .io_output_r_payload_resp   ( m_axi_rresp      ),
 .io_output_r_payload_last   ( m_axi_rlast      ),
 .clk                        ( m_axi_clk        ),
 .reset                      ( m_reset          )
); 
end
else
begin
assign m_axi_awvalid    = m1_axi_awvalid;
assign m_axi_awaddr     = m1_axi_awaddr;
assign m_axi_awlen      = m1_axi_awlen;
assign m_axi_awsize     = m1_axi_awsize;
assign m_axi_awburst    = m1_axi_awburst;
assign m_axi_awprot     = m1_axi_awprot;
assign m_axi_awlock     = m1_axi_awlock;
assign m_axi_awcache    = m1_axi_awcache;
assign m1_axi_awready   = m_axi_awready;
assign m_axi_wdata      = m1_axi_wdata;
assign m_axi_wstrb      = m1_axi_wstrb;
assign m_axi_wlast      = m1_axi_wlast;
assign m_axi_wvalid     = m1_axi_wvalid;
assign m1_axi_wready    = m_axi_wready;
assign m1_axi_bresp     = m_axi_bresp;
assign m1_axi_bvalid    = m_axi_bvalid;
assign m_axi_bready     = m1_axi_bready;
assign m_axi_arvalid    = m1_axi_arvalid;
assign m_axi_araddr     = m1_axi_araddr;
assign m_axi_arlen      = m1_axi_arlen;
assign m_axi_arsize     = m1_axi_arsize;
assign m_axi_arburst    = m1_axi_arburst;
assign m_axi_arprot     = m1_axi_arprot;
assign m_axi_arlock     = m1_axi_arlock;
assign m_axi_arcache    = m1_axi_arcache;
assign m1_axi_arready   = m_axi_arready;
assign m1_axi_rvalid    = m_axi_rvalid;
assign m1_axi_rdata     = m_axi_rdata;
assign m1_axi_rlast     = m_axi_rlast;
assign m1_axi_rresp     = m_axi_rresp;
assign m_axi_rready     = m1_axi_rready;
end
endgenerate

//Encryption end
endmodule
