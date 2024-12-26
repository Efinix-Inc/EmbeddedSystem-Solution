/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2021 Efinix Inc. All rights reserved.
//
// Description:
// Example top file for DMA example design
//
// Language:  Verilog 2001
//
// ------------------------------------------------------------------------------
// REVISION:
//  $Snapshot: $
//  $Id:$
//
// History:
// 1.0 Initial Release. 
/////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module top (
	//PLL
  	output	      		my_pll_rstn,
  	input			my_pll_locked,
  	output	      		my_ddr_pll_rstn,
  	input			my_ddr_pll_locked,
	//SOC
  	input               	io_systemClk,
  	input               	io_asyncReset,
  	input               	io_memoryClk,
  	output              	system_uart_0_io_txd,
  	input               	system_uart_0_io_rxd,
  	output              	io_ddrA_arw_valid,
  	input               	io_ddrA_arw_ready,
  	output     [31:0]   	io_ddrA_arw_payload_addr,
  	output     [7:0]    	io_ddrA_arw_payload_id,
  	output     [7:0]    	io_ddrA_arw_payload_len,
  	output     [2:0]    	io_ddrA_arw_payload_size,
  	output     [1:0]    	io_ddrA_arw_payload_burst,
  	output     [1:0]    	io_ddrA_arw_payload_lock,
  	output              	io_ddrA_arw_payload_write,
  	output     [7:0]    	io_ddrA_w_payload_id,
  	output              	io_ddrA_w_valid,
  	input               	io_ddrA_w_ready,
  	output     [127:0]  	io_ddrA_w_payload_data,
  	output     [15:0]   	io_ddrA_w_payload_strb,
  	output              	io_ddrA_w_payload_last,
  	input               	io_ddrA_b_valid,
  	output              	io_ddrA_b_ready,
  	input      [7:0]    	io_ddrA_b_payload_id,
  	input               	io_ddrA_r_valid,
  	output              	io_ddrA_r_ready,
  	input      [127:0]  	io_ddrA_r_payload_data,
  	input      [7:0]    	io_ddrA_r_payload_id,
  	input      [1:0]    	io_ddrA_r_payload_resp,
  	input               	io_ddrA_r_payload_last,
  	output         		system_spi_0_io_sclk_write,
  	output              	system_spi_0_io_data_0_writeEnable,
  	input          		system_spi_0_io_data_0_read,
  	output         		system_spi_0_io_data_0_write,
  	output              	system_spi_0_io_data_1_writeEnable,
  	input          		system_spi_0_io_data_1_read,
  	output         		system_spi_0_io_data_1_write,
  	output         		system_spi_0_io_ss,
	input               	jtag_inst1_TCK,
  	input               	jtag_inst1_TDI,
  	output              	jtag_inst1_TDO,
  	input               	jtag_inst1_SEL,
  	input               	jtag_inst1_CAPTURE,
  	input               	jtag_inst1_SHIFT,
  	input               	jtag_inst1_UPDATE,
  	input               	jtag_inst1_RESET
);
/////////////////////////////////////////////////////////////////////////////
//Local Parameter 
localparam NI = 1;
//Reset and PLL
wire 		mcuReset;
wire		io_systemReset;
wire		io_ddrMasterReset;
wire   [1:0]    io_ddrA_b_payload_resp;
(* keep , syn_keep *) wire 	  io_memoryReset /* synthesis syn_keep = 1 */;				
(* keep , syn_keep *) wire [3:0]  io_ddrA_arw_payload_qos /* synthesis syn_keep = 1 */;
(* keep , syn_keep *) wire [2:0]  io_ddrA_arw_payload_prot /* synthesis syn_keep = 1 */;
(* keep , syn_keep *) wire [3:0]  io_ddrA_arw_payload_cache /* synthesis syn_keep = 1 */;
(* keep , syn_keep *) wire [3:0]  io_ddrA_arw_payload_region /* synthesis syn_keep = 1 */;

//APB DMA 0  
wire   [13:0]   io_apbSlave_0_PADDR;
wire          	io_apbSlave_0_PSEL;
wire            io_apbSlave_0_PENABLE;
wire            io_apbSlave_0_PREADY;
wire            io_apbSlave_0_PWRITE;
wire   [31:0]   io_apbSlave_0_PWDATA;
wire   [31:0]   io_apbSlave_0_PRDATA;
wire            io_apbSlave_0_PSLVERROR;
wire 		tester_i_tvalid;	
wire  		tester_i_tready;	
wire   [31:0]	tester_i_tdata;
wire   [3:0]	tester_i_tkeep;	
wire   [3:0]	tester_i_tdest;	
wire      	tester_i_tlast;	
wire 		tester_o_tvalid;	
wire      	tester_o_tready;
wire   [31:0]	tester_o_tdata;	
wire   [3:0]	tester_o_tkeep;	
wire   [3:0]	tester_o_tdest;	
wire 		tester_o_tlast;	
wire            read_arvalid;
wire            read_arready;
wire   [31:0]   read_araddr;
wire   [3:0]    read_arregion;
wire   [7:0]    read_arlen;
wire   [2:0]    read_arsize;
wire   [1:0]    read_arburst;
wire   [0:0]    read_arlock;
wire   [3:0]    read_arcache;
wire   [3:0]    read_arqos;
wire   [2:0]    read_arprot;
wire            read_rvalid;
wire            read_rready;
wire   [63:0]   read_rdata;
wire   [1:0]    read_rresp;
wire            read_rlast;
wire            write_awvalid;
wire            write_awready;
wire   [31:0]   write_awaddr;
wire   [3:0]    write_awregion;
wire   [7:0]    write_awlen;
wire   [2:0]    write_awsize;
wire   [1:0]    write_awburst;
wire   [0:0]    write_awlock;
wire   [3:0]    write_awcache;
wire   [3:0]    write_awqos;
wire   [2:0]    write_awprot;
wire            write_wvalid;
wire            write_wready;
wire   [63:0]   write_wdata;
wire   [7:0]    write_wstrb;
wire            write_wlast;
wire            write_bvalid;
wire            write_bready;
wire   [1:0]    write_bresp;

/////////////////////////////////////////////////////////////////////////////
//Reset and PLL
assign mcuReset 		= ~( io_asyncReset & my_pll_locked & my_ddr_pll_locked );
assign my_pll_rstn 		= 1'b1;
assign my_ddr_pll_rstn 		= 1'b1;
assign io_ddrA_b_payload_resp 	= 2'b00;
/////////////////////////////////////////////////////////////////////////////

dma_loopback_tester #(
	.ID(4'h0),
	.DW(32),
	.FD(2048),
	.FB(4)

) tester (
	.tester_clk		(io_systemClk),
	.tester_resetn		(~io_systemReset),
 	.tester_i_tvalid	(tester_i_tvalid),	
 	.tester_i_tready	(tester_i_tready),	
 	.tester_i_tdata		(tester_i_tdata ),	
 	.tester_i_tkeep		(tester_i_tkeep	),	
 	.tester_i_tdest		(tester_i_tdest	),	
 	.tester_i_tlast		(tester_i_tlast	),	
 	.tester_o_tvalid	(tester_o_tvalid),	
 	.tester_o_tready	(tester_o_tready),
 	.tester_o_tdata		(tester_o_tdata	),	
 	.tester_o_tkeep		(tester_o_tkeep	),	
 	.tester_o_tdest		(tester_o_tdest	),	
 	.tester_o_tlast		(tester_o_tlast	)	
);

dma_exp_0 dma(
    .clk			(io_memoryClk		),
    .reset			(io_memoryReset		),
    .ctrl_PADDR			(io_apbSlave_0_PADDR	),
    .ctrl_PREADY		(io_apbSlave_0_PREADY	),     
    .ctrl_PENABLE		(io_apbSlave_0_PENABLE	),      
    .ctrl_PSEL			(io_apbSlave_0_PSEL	),   
    .ctrl_PWRITE		(io_apbSlave_0_PWRITE	),    
    .ctrl_PWDATA		(io_apbSlave_0_PWDATA	),    
    .ctrl_PRDATA		(io_apbSlave_0_PRDATA	),    
    .ctrl_PSLVERROR		(io_apbSlave_0_PSLVERRPR),    
    .ctrl_interrupts            (			),
    .read_arvalid		(read_arvalid		),
    .read_araddr		(read_araddr		),
    .read_arready		(read_arready		),
    .read_arregion		(read_arregion		),
    .read_arlen			(read_arlen		),
    .read_arsize		(read_arsize		),
    .read_arburst		(read_arburst		),
    .read_arlock		(read_arlock		),
    .read_arcache		(read_arcache		),
    .read_arqos			(read_arqos		),
    .read_arprot		(read_arprot		),
    .read_rready		(read_rready		),
    .read_rvalid		(read_rvalid		),
    .read_rdata			(read_rdata		),
    .read_rlast			(read_rlast		),
    .write_awvalid		(write_awvalid		),
    .write_awready		(write_awready		),
    .write_awaddr		(write_awaddr		),
    .write_awregion		(write_awregion		),
    .write_awlen		(write_awlen		),
    .write_awsize		(write_awsize		),
    .write_awburst		(write_awburst		),
    .write_awlock		(write_awlock		),
    .write_awcache		(write_awcache		),
    .write_awqos		(write_awqos		),
    .write_awprot		(write_awprot		),
    .write_wvalid		(write_wvalid		),
    .write_wready		(write_wready		),
    .write_wdata		(write_wdata		),
    .write_wstrb		(write_wstrb		),
    .write_wlast		(write_wlast		),
    .write_bvalid		(write_bvalid		),
    .write_bready		(write_bready		),
    .write_bresp		(write_bresp		),
    .dat0_o_tvalid		(tester_i_tvalid	),
    .dat0_o_tready		(tester_i_tready	),
    .dat0_o_tdata		(tester_i_tdata		),
    .dat0_o_tkeep		(tester_i_tkeep		),
    .dat0_o_tdest		(tester_i_tdest		),
    .dat0_o_tlast		(tester_i_tlast		),
    .dat1_i_clk			(io_systemClk		),
    .dat1_i_reset		(io_systemReset		),
    .dat0_o_clk			(io_systemClk		),
    .dat0_o_reset		(io_systemReset		),
    .dat1_i_tvalid		(tester_o_tvalid	),
    .dat1_i_tready		(tester_o_tready	),
    .dat1_i_tdata		(tester_o_tdata		),
    .dat1_i_tkeep		(tester_o_tkeep		),
    .dat1_i_tdest		(tester_o_tdest		),
    .dat1_i_tlast		(tester_o_tlast		),
    .read_rresp			(read_rresp		)
);
/////////////////////////////////////////////////////////////////////////////

soc_dma_exp_0 soc_inst
(
  .io_systemClk				(io_systemClk),
  .io_asyncReset			(mcuReset),
  .io_memoryClk				(io_memoryClk),
  .io_memoryReset			(io_memoryReset), 		
  .system_uart_0_io_txd			(system_uart_0_io_txd),
  .system_uart_0_io_rxd			(system_uart_0_io_rxd),
  .io_apbSlave_0_PADDR			(io_apbSlave_0_PADDR),
  .io_apbSlave_0_PSEL			(io_apbSlave_0_PSEL),
  .io_apbSlave_0_PENABLE		(io_apbSlave_0_PENABLE),
  .io_apbSlave_0_PREADY			(io_apbSlave_0_PREADY),
  .io_apbSlave_0_PWRITE			(io_apbSlave_0_PWRITE),
  .io_apbSlave_0_PWDATA			(io_apbSlave_0_PWDATA),
  .io_apbSlave_0_PRDATA			(io_apbSlave_0_PRDATA),
  .io_apbSlave_0_PSLVERROR		(io_apbSlave_0_PSLVERROR),
  .io_systemReset			(io_systemReset),		
  .io_ddrA_arw_valid			(io_ddrA_arw_valid),
  .io_ddrA_arw_ready			(io_ddrA_arw_ready),
  .io_ddrA_arw_payload_addr		(io_ddrA_arw_payload_addr),
  .io_ddrA_arw_payload_id		(io_ddrA_arw_payload_id),
  .io_ddrA_arw_payload_region		(io_ddrA_arw_payload_region),
  .io_ddrA_arw_payload_len		(io_ddrA_arw_payload_len),
  .io_ddrA_arw_payload_size		(io_ddrA_arw_payload_size),
  .io_ddrA_arw_payload_burst		(io_ddrA_arw_payload_burst),
  .io_ddrA_arw_payload_lock		(io_ddrA_arw_payload_lock),
  .io_ddrA_arw_payload_cache		(io_ddrA_arw_payload_cache),
  .io_ddrA_arw_payload_qos		(io_ddrA_arw_payload_qos),
  .io_ddrA_arw_payload_prot		(io_ddrA_arw_payload_prot),
  .io_ddrA_arw_payload_write		(io_ddrA_arw_payload_write),
  .io_ddrA_w_valid			(io_ddrA_w_valid),
  .io_ddrA_w_ready			(io_ddrA_w_ready),
  .io_ddrA_w_payload_data		(io_ddrA_w_payload_data),
  .io_ddrA_w_payload_strb		(io_ddrA_w_payload_strb),
  .io_ddrA_w_payload_last		(io_ddrA_w_payload_last),
  .io_ddrA_b_valid			(io_ddrA_b_valid),
  .io_ddrA_b_ready			(io_ddrA_b_ready),
  .io_ddrA_b_payload_id			(io_ddrA_b_payload_id),
  .io_ddrA_b_payload_resp		(io_ddrA_b_payload_resp),
  .io_ddrA_r_valid			(io_ddrA_r_valid),
  .io_ddrA_r_ready			(io_ddrA_r_ready),
  .io_ddrA_r_payload_data		(io_ddrA_r_payload_data),
  .io_ddrA_r_payload_id			(io_ddrA_r_payload_id),
  .io_ddrA_r_payload_resp		(io_ddrA_r_payload_resp),
  .io_ddrA_r_payload_last		(io_ddrA_r_payload_last),
  .io_ddrA_w_payload_id			(io_ddrA_w_payload_id),
  .io_ddrMasters_0_aw_valid		(write_awvalid),
  .io_ddrMasters_0_aw_ready		(write_awready),		
  .io_ddrMasters_0_aw_payload_addr	(write_awaddr),
  .io_ddrMasters_0_aw_payload_id	('hE0),
  .io_ddrMasters_0_aw_payload_region	(write_awregion	),
  .io_ddrMasters_0_aw_payload_len	(write_awlen	),
  .io_ddrMasters_0_aw_payload_size	(write_awsize	),
  .io_ddrMasters_0_aw_payload_burst	(write_awburst	),
  .io_ddrMasters_0_aw_payload_lock	(write_awlock	),
  .io_ddrMasters_0_aw_payload_cache	(write_awcache	),
  .io_ddrMasters_0_aw_payload_qos	(write_awqos	),
  .io_ddrMasters_0_aw_payload_prot	(write_awprot	),
  .io_ddrMasters_0_w_valid		(write_wvalid	),
  .io_ddrMasters_0_w_ready		(write_wready	),
  .io_ddrMasters_0_w_payload_data	(write_wdata	),
  .io_ddrMasters_0_w_payload_strb	(write_wstrb	),
  .io_ddrMasters_0_w_payload_last	(write_wlast	),
  .io_ddrMasters_0_b_valid		(write_bvalid	),
  .io_ddrMasters_0_b_ready		(write_bready	),
  .io_ddrMasters_0_b_payload_id		(),
  .io_ddrMasters_0_b_payload_resp	(write_bresp	),
  .io_ddrMasters_0_ar_valid		(read_arvalid	),
  .io_ddrMasters_0_ar_ready		(read_arready	),
  .io_ddrMasters_0_ar_payload_addr	(read_araddr	),
  .io_ddrMasters_0_ar_payload_id	('hE1		),
  .io_ddrMasters_0_ar_payload_region	(read_arregion	),
  .io_ddrMasters_0_ar_payload_len	(read_arlen	),
  .io_ddrMasters_0_ar_payload_size	(read_arsize	),
  .io_ddrMasters_0_ar_payload_burst	(read_arburst	),
  .io_ddrMasters_0_ar_payload_lock	(read_arlock	),
  .io_ddrMasters_0_ar_payload_cache	(read_arcache	),
  .io_ddrMasters_0_ar_payload_qos	(read_arqos	),
  .io_ddrMasters_0_ar_payload_prot	(read_arprot	),
  .io_ddrMasters_0_r_valid		(read_rvalid	),
  .io_ddrMasters_0_r_ready		(read_rready	),
  .io_ddrMasters_0_r_payload_data	(read_rdata	),
  .io_ddrMasters_0_r_payload_id		(),
  .io_ddrMasters_0_r_payload_resp	(read_rresp	),
  .io_ddrMasters_0_r_payload_last	(read_rlast	),
  .io_ddrMasters_0_clk			(io_memoryClk	),
  .io_ddrMasters_0_reset		(io_ddrMasterReset),
  .system_spi_0_io_sclk_write		(system_spi_0_io_sclk_write),
  .system_spi_0_io_data_0_writeEnable	(system_spi_0_io_data_0_writeEnable),
  .system_spi_0_io_data_0_read		(system_spi_0_io_data_0_read),
  .system_spi_0_io_data_0_write		(system_spi_0_io_data_0_write),
  .system_spi_0_io_data_1_writeEnable	(system_spi_0_io_data_1_writeEnable),
  .system_spi_0_io_data_1_read		(system_spi_0_io_data_1_read),
  .system_spi_0_io_data_1_write		(system_spi_0_io_data_1_write),
  .system_spi_0_io_data_2_writeEnable	(),
  .system_spi_0_io_data_2_read		(),
  .system_spi_0_io_data_2_write		(),
  .system_spi_0_io_data_3_writeEnable	(),
  .system_spi_0_io_data_3_read		(),
  .system_spi_0_io_data_3_write		(),
  .system_spi_0_io_ss			(system_spi_0_io_ss),
  .jtagCtrl_tck				(jtag_inst1_TCK),
  .jtagCtrl_tdi				(jtag_inst1_TDI),
  .jtagCtrl_tdo				(jtag_inst1_TDO),
  .jtagCtrl_enable			(jtag_inst1_SEL),
  .jtagCtrl_capture			(jtag_inst1_CAPTURE),
  .jtagCtrl_shift			(jtag_inst1_SHIFT),
  .jtagCtrl_update			(jtag_inst1_UPDATE),
  .jtagCtrl_reset			(jtag_inst1_RESET)
);

endmodule

//////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2021 Efinix Inc. All rights reserved.
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
