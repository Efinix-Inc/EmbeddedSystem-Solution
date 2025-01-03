////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   tb_soc.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Testbench for SapphireSoC + DMA simulation
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// ***********************************************************************
`timescale 1ns / 1ps
//`define SKIP_TEST

module tb_soc ();

localparam  MHZ     = 100;
localparam  MMHZ    = 100;
localparam  PMHZ    = 50;
localparam  AXIMHZ  = 75;
localparam  MEMWIDTH=128;
localparam  MEMDEPTH=$clog2(67108864/128);

/////////////////////////////////////////////////////////////////////////////
//clock and reset
wire            buttonReset;
wire	        io_systemClk; 
wire            io_memoryClk;
wire            io_peripheralClk;
wire            io_ddrMasters_0_clk;
wire            sys_pll_locked;
wire            peri_pll_locked;
wire            mem_pll_locked;
reg	        	rst			            = 1'b1;
//spi
wire 	        system_spi_0_io_ss;
wire 	        system_spi_0_io_sclk_write;
wire 	        system_spi_0_io_data_0;
wire 	        system_spi_0_io_data_1;
//uart
wire	        system_uart_0_io_txd;
reg             system_uart_0_io_rxd	= 1'b1;
//gpio
wire  [3:0]     system_gpio_0_io;
//axi memory
wire			io_ddrA_arw_valid;
wire			io_ddrA_arw_ready;
wire  [31:0]	io_ddrA_arw_payload_addr;
wire  [7:0]		io_ddrA_arw_payload_id;
wire  [7:0]		io_ddrA_arw_payload_len;
wire  [2:0]		io_ddrA_arw_payload_size;
wire  [1:0]		io_ddrA_arw_payload_burst;
wire  [1:0]		io_ddrA_arw_payload_lock;
wire			io_ddrA_arw_payload_write;
wire  [7:0]		io_ddrA_w_payload_id;
wire			io_ddrA_w_valid;
wire			io_ddrA_w_ready;
wire  [127:0]	io_ddrA_w_payload_data;
wire  [15:0]	io_ddrA_w_payload_strb;
wire			io_ddrA_w_payload_last;
wire			io_ddrA_b_valid;
wire			io_ddrA_b_ready;
wire  [7:0]		io_ddrA_b_payload_id;
wire			io_ddrA_r_valid;
wire			io_ddrA_r_ready;
wire  [127:0]	io_ddrA_r_payload_data;
wire  [7:0]		io_ddrA_r_payload_id;
wire  [1:0]		io_ddrA_r_payload_resp;
wire			io_ddrA_r_payload_last;



/////////////////////////////////////////////////////////////////////////////
//system reset
initial begin
     rst = 1;
     #2000; 
     rst = 0;
end

//system clock
clock_gen #(
        .FREQ_CLK_MHZ(MHZ)
) clock_gen_0_inst (
        .rst            (1'b0),
        .clk_out0      	(io_systemClk),
        .locked         (sys_pll_locked)
);
//memory clock
clock_gen #(
        .FREQ_CLK_MHZ(MMHZ)
) clock_gen_1_inst (
        .rst            (1'b0),
        .clk_out0      	(io_memoryClk),
        .locked         (mem_pll_locked)
);

//peripheral clock
clock_gen #(
        .FREQ_CLK_MHZ(PMHZ)
) clock_gen_2_inst (
        .rst            (1'b0),
        .clk_out0      	(io_peripheralClk),
        .locked         (peri_pll_locked)
);

//axim clock
clock_gen #(
        .FREQ_CLK_MHZ(AXIMHZ)
) clock_gen_3_inst (
        .rst            (1'b0),
        .clk_out0      	(io_ddrMasters_0_clk),
        .locked         ()
);

assign buttonReset = 1'b0;
//////////////////////////////////////////////////////////////////////////////
initial begin
    $display("start dma tests ..");
    $display("proceed to memory-to-memory transfer test");
end

initial begin
    @(system_gpio_0_io === 4'hD);
    $error("data check fail!");
    $finish;
end
initial begin
    @(system_gpio_0_io === 4'hF);
    $error("system crash!");
    $finish;
end
initial begin
    @(system_gpio_0_io === 4'h1);
    $display("dma (32b) memory-to-memory transfer test pass!");
    $display("proceed to custom sg linked-list test");
end
initial begin
    @(system_gpio_0_io === 4'h2);
    $display("dma (32b) custom sg linked-list transfer test pass!");
    $display("proceed to normal sg linked-list test");
end
initial begin
    @(system_gpio_0_io === 4'h3);
    $display("dma (32b) normal sg linked-list transfer test pass!");
    $display("proceed to direct mode test");
end
initial begin
    @(system_gpio_0_io === 4'h4);
    $display("dma (32b) direct mode transfer test pass!");
    $display("proceed to (8b) direct mode test");
end
initial begin
    @(system_gpio_0_io === 4'h5);
    $display("dma (8b) direct mode transfer test pass!");
    $display("TEST PASS!");
    $finish;
end


//////////////////////////////////////////////////////////////////////////////

top_soc_wrapper dut_wrapper(
.system_gpio_0_io           (system_gpio_0_io),
.system_uart_0_io_txd       (system_uart_0_io_txd),
.system_uart_0_io_rxd       (system_uart_0_io_rxd),
.system_spi_0_io_data_0     (system_spi_0_io_data_0),
.system_spi_0_io_data_1     (system_spi_0_io_data_1),
.system_spi_0_io_sclk_write (system_spi_0_io_sclk_write),
.system_spi_0_io_ss         (system_spi_0_io_ss),
.io_ddrA_arw_valid          (io_ddrA_arw_valid),
.io_ddrA_arw_ready          (io_ddrA_arw_ready),
.io_ddrA_arw_payload_addr   (io_ddrA_arw_payload_addr),
.io_ddrA_arw_payload_id     (io_ddrA_arw_payload_id),
.io_ddrA_arw_payload_len    (io_ddrA_arw_payload_len),
.io_ddrA_arw_payload_size   (io_ddrA_arw_payload_size),
.io_ddrA_arw_payload_burst  (io_ddrA_arw_payload_burst),
.io_ddrA_arw_payload_lock   (io_ddrA_arw_payload_lock),
.io_ddrA_arw_payload_write  (io_ddrA_arw_payload_write),
.io_ddrA_w_payload_id       (io_ddrA_w_payload_id),
.io_ddrA_w_valid            (io_ddrA_w_valid),
.io_ddrA_w_ready            (io_ddrA_w_ready),
.io_ddrA_w_payload_data     (io_ddrA_w_payload_data),
.io_ddrA_w_payload_strb     (io_ddrA_w_payload_strb),
.io_ddrA_w_payload_last     (io_ddrA_w_payload_last),
.io_ddrA_b_valid            (io_ddrA_b_valid),
.io_ddrA_b_ready            (io_ddrA_b_ready),
.io_ddrA_b_payload_id       (io_ddrA_b_payload_id),
.io_ddrA_r_valid            (io_ddrA_r_valid),
.io_ddrA_r_ready            (io_ddrA_r_ready),
.io_ddrA_r_payload_data     (io_ddrA_r_payload_data),
.io_ddrA_r_payload_id       (io_ddrA_r_payload_id),
.io_ddrA_r_payload_resp     (io_ddrA_r_payload_resp),
.io_ddrA_r_payload_last     (io_ddrA_r_payload_last),
.buttonReset                (~buttonReset),
.sys_pll_locked             (sys_pll_locked),
.peri_pll_locked            (peri_pll_locked),
.ddr_pll_locked             (mem_pll_locked),
.io_systemClk               (io_systemClk),
.io_memoryClk               (io_memoryClk),
.io_peripheralClk           (io_peripheralClk),
.io_ddrMasters_0_clk        (io_ddrMasters_0_clk)
);

ext_mem_controller #(
.WIDTH(MEMWIDTH),
.DEPTH(MEMDEPTH)
) ext_mem_ctrl_inst (
.io_memoryClk   (io_memoryClk),
.resetn         (mem_pll_locked),
.aid_0          (io_ddrA_arw_payload_id),
.aaddr_0        (io_ddrA_arw_payload_addr),
.alen_0         (io_ddrA_arw_payload_len),
.asize_0        (io_ddrA_arw_payload_size),
.aburst_0       (io_ddrA_arw_payload_burst),
.alock_0        (io_ddrA_arw_payload_lock),
.avalid_0       (io_ddrA_arw_valid),
.aready_0       (io_ddrA_arw_ready),
.atype_0        (io_ddrA_arw_payload_write),
.wid_0          (io_ddrA_w_payload_id),
.wdata_0        (io_ddrA_w_payload_data),
.wstrb_0        (io_ddrA_w_payload_strb),
.wlast_0        (io_ddrA_w_payload_last),
.wvalid_0       (io_ddrA_w_valid),
.wready_0       (io_ddrA_w_ready),
.rid_0          (io_ddrA_r_payload_id),
.rdata_0        (io_ddrA_r_payload_data),
.rlast_0        (io_ddrA_r_payload_last),
.rvalid_0       (io_ddrA_r_valid),
.rready_0       (io_ddrA_r_ready),
.rresp_0        (io_ddrA_r_payload_resp),
.bid_0          (io_ddrA_b_payload_id),
.bvalid_0       (io_ddrA_b_valid),
.bready_0       (io_ddrA_b_ready));

/*
W25Q32JVxxIM spi_flash(
    .CSn    (system_spi_0_io_ss),
    .CLK    (system_spi_0_io_sclk_write),
    .RESETn (systemClk_locked),
    .DIO    (system_spi_0_io_data_0),
    .WPn    (),
    .HOLDn  (),
    .DO     (system_spi_0_io_data_1)
);
*/

endmodule

//////////////////////////////////////////////////////////////////////////////

module top_soc_wrapper(
output [0:0]    system_spi_0_io_ss,
output		system_spi_0_io_sclk_write,
inout		system_spi_0_io_data_0,
inout		system_spi_0_io_data_1,
output		system_uart_0_io_txd,
input		system_uart_0_io_rxd,
output		io_ddrA_arw_valid,
input		io_ddrA_arw_ready,
output [31:0]   io_ddrA_arw_payload_addr,
output [7:0]    io_ddrA_arw_payload_id,
output [7:0]    io_ddrA_arw_payload_len,
output [2:0]    io_ddrA_arw_payload_size,
output [1:0]    io_ddrA_arw_payload_burst,
output [1:0]    io_ddrA_arw_payload_lock,
output	        io_ddrA_arw_payload_write,
output [7:0]    io_ddrA_w_payload_id,
output		io_ddrA_w_valid,
input		io_ddrA_w_ready,
output [127:0]  io_ddrA_w_payload_data,
output [15:0]   io_ddrA_w_payload_strb,
output		io_ddrA_w_payload_last,
input		io_ddrA_b_valid,
output		io_ddrA_b_ready,
input [7:0]     io_ddrA_b_payload_id,
input	        io_ddrA_r_valid,
output	        io_ddrA_r_ready,
input [127:0]   io_ddrA_r_payload_data,
input [7:0]     io_ddrA_r_payload_id,
input [1:0]     io_ddrA_r_payload_resp,
input	        io_ddrA_r_payload_last,
inout [3:0]     system_gpio_0_io,
input           sys_pll_locked,
input           peri_pll_locked,
input           ddr_pll_locked,
input           buttonReset,
input           io_systemClk,
input           io_memoryClk,
input           io_ddrMasters_0_clk,
input           io_peripheralClk
);
//////////////////////////////////////////////////////////////////////////////
wire  [3:0]	system_gpio_0_io_read;
wire  [3:0]	system_gpio_0_io_write;
wire  [3:0]	system_gpio_0_io_writeEnable;
wire  [0:0]	spi_0_io_ss;
wire		spi_0_io_data_0_writeEnable;
wire		system_spi_0_io_data_0_read;
wire		spi_0_io_data_0_write;
wire		spi_0_io_data_1_writeEnable;
wire		system_spi_0_io_data_1_read;
wire		spi_0_io_data_1_write;
wire		spi_0_io_sclk_write;



io_sim  #(.WIDTH(4),.REG(0)) gpio0_io_data ( 
.clk(io_peripheralClk),
.out_pad(system_gpio_0_io_write),
.out_oe(system_gpio_0_io_writeEnable),
.in_pad(system_gpio_0_io_read),
.io(system_gpio_0_io));

io_sim  #(.WIDTH(1+1),.REG(1)) spi0_io_aux (
.clk(io_peripheralClk),
.out_pad({spi_0_io_sclk_write,spi_0_io_ss}),
.out_oe({1+1{1'b1}}),
.in_pad(),
.io({system_spi_0_io_sclk_write,system_spi_0_io_ss}));

io_sim  #(.WIDTH(2),.REG(1)) spi0_io_data ( 
.clk(io_peripheralClk),
.out_pad({spi_0_io_data_0_write,spi_0_io_data_1_write}),
.out_oe({spi_0_io_data_0_writeEnable,spi_0_io_data_1_writeEnable}),
.in_pad({system_spi_0_io_data_0_read,system_spi_0_io_data_1_read}),
.io({system_spi_0_io_data_0,system_spi_0_io_data_1}));

//////////////////////////////////////////////////////////////////////////////
top dut (
.io_ddrA_arw_valid                      (io_ddrA_arw_valid),
.io_ddrA_arw_ready                      (io_ddrA_arw_ready),
.io_ddrA_arw_payload_addr               (io_ddrA_arw_payload_addr),
.io_ddrA_arw_payload_id                 (io_ddrA_arw_payload_id),
.io_ddrA_arw_payload_len                (io_ddrA_arw_payload_len),
.io_ddrA_arw_payload_size               (io_ddrA_arw_payload_size),
.io_ddrA_arw_payload_burst              (io_ddrA_arw_payload_burst),
.io_ddrA_arw_payload_lock               (io_ddrA_arw_payload_lock),
.io_ddrA_arw_payload_write              (io_ddrA_arw_payload_write),
.io_ddrA_w_payload_id                   (io_ddrA_w_payload_id),
.io_ddrA_w_valid                        (io_ddrA_w_valid),
.io_ddrA_w_ready                        (io_ddrA_w_ready),
.io_ddrA_w_payload_data                 (io_ddrA_w_payload_data),
.io_ddrA_w_payload_strb                 (io_ddrA_w_payload_strb),
.io_ddrA_w_payload_last                 (io_ddrA_w_payload_last),
.io_ddrA_b_valid                        (io_ddrA_b_valid),
.io_ddrA_b_ready                        (io_ddrA_b_ready),
.io_ddrA_b_payload_id                   (io_ddrA_b_payload_id),
.io_ddrA_r_valid                        (io_ddrA_r_valid),
.io_ddrA_r_ready                        (io_ddrA_r_ready),
.io_ddrA_r_payload_data                 (io_ddrA_r_payload_data),
.io_ddrA_r_payload_id                   (io_ddrA_r_payload_id),
.io_ddrA_r_payload_resp                 (io_ddrA_r_payload_resp),
.io_ddrA_r_payload_last                 (io_ddrA_r_payload_last),
.system_gpio_0_io_read                  (system_gpio_0_io_read),
.system_gpio_0_io_write                 (system_gpio_0_io_write),
.system_gpio_0_io_writeEnable           (system_gpio_0_io_writeEnable),
.system_uart_0_io_txd                   (system_uart_0_io_txd),
.system_uart_0_io_rxd                   (system_uart_0_io_rxd),
.system_spi_0_io_sclk_write             (spi_0_io_sclk_write),
.system_spi_0_io_data_0_writeEnable     (spi_0_io_data_0_writeEnable),
.system_spi_0_io_data_0_read            (system_spi_0_io_data_0_read),
.system_spi_0_io_data_0_write           (spi_0_io_data_0_write),
.system_spi_0_io_data_1_writeEnable     (spi_0_io_data_1_writeEnable),
.system_spi_0_io_data_1_read            (system_spi_0_io_data_1_read),
.system_spi_0_io_data_1_write           (spi_0_io_data_1_write),
.system_spi_0_io_ss                     (spi_0_io_ss),

//clock and reset
.buttonReset                            (buttonReset),
.sys_pll_locked                         (sys_pll_locked),
.peri_pll_locked                        (peri_pll_locked),
.ddr_pll_locked                         (ddr_pll_locked),
.io_systemClk                           (io_systemClk),
.io_memoryClk                           (io_memoryClk),
.io_peripheralClk                       (io_peripheralClk),
.io_ddrMasters_0_clk                    (io_ddrMasters_0_clk)
);

endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2024 Efinix Inc. All rights reserved.
//
// This   document  contains  proprietary information  which   is
// protected by  copyright. All rights  are reserved.  This notice
// refers to original work by Efinix, Inc. which may be derivitive
// of other work distributed under license of the authors.  In the
// case of derivative work, nothing in this notice overrides the
// original author's license agreement.  Where applicable, the 
// original license agreement is included in it's original 
// unmodified form immediately below this header.
//
// WARRANTY DISCLAIMER.  
//     THE  DESIGN, CODE, OR INFORMATION ARE PROVIDED “AS IS” AND 
//     EFINIX MAKES NO WARRANTIES, EXPRESS OR IMPLIED WITH 
//     RESPECT THERETO, AND EXPRESSLY DISCLAIMS ANY IMPLIED WARRANTIES, 
//     INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF 
//     MERCHANTABILITY, NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR 
//     PURPOSE.  SOME STATES DO NOT ALLOW EXCLUSIONS OF AN IMPLIED 
//     WARRANTY, SO THIS DISCLAIMER MAY NOT APPLY TO LICENSEE.
//
// LIMITATION OF LIABILITY.  
//     NOTWITHSTANDING ANYTHING TO THE CONTRARY, EXCEPT FOR BODILY 
//     INJURY, EFINIX SHALL NOT BE LIABLE WITH RESPECT TO ANY SUBJECT 
//     MATTER OF THIS AGREEMENT UNDER TORT, CONTRACT, STRICT LIABILITY 
//     OR ANY OTHER LEGAL OR EQUITABLE THEORY (I) FOR ANY INDIRECT, 
//     SPECIAL, INCIDENTAL, EXEMPLARY OR CONSEQUENTIAL DAMAGES OF ANY 
//     CHARACTER INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF 
//     GOODWILL, DATA OR PROFIT, WORK STOPPAGE, OR COMPUTER FAILURE OR 
//     MALFUNCTION, OR IN ANY EVENT (II) FOR ANY AMOUNT IN EXCESS, IN 
//     THE AGGREGATE, OF THE FEE PAID BY LICENSEE TO EFINIX HEREUNDER 
//     (OR, IF THE FEE HAS BEEN WAIVED, $100), EVEN IF EFINIX SHALL HAVE 
//     BEEN INFORMED OF THE POSSIBILITY OF SUCH DAMAGES.  SOME STATES DO 
//     NOT ALLOW THE EXCLUSION OR LIMITATION OF INCIDENTAL OR 
//     CONSEQUENTIAL DAMAGES, SO THIS LIMITATION AND EXCLUSION MAY NOT 
//     APPLY TO LICENSEE.
//
/////////////////////////////////////////////////////////////////////////////

