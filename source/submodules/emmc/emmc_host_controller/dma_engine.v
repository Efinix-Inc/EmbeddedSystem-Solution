////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2025 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   
//       / / .'     /    
//    __/ /.'      /     
//   __   \       /      
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// 1.0 Initial rev
//
// ***********************************************************************
`timescale 1 ns / 1 ps
module dma_engine
(
//Globle Signals
input                           rstn,
//Control Signals
input           [1:0]           dma_start,//[0]:write; [1]:read;
input           [31:0]          adma_system_address,
input                           stop_at_block_gap_request,
output  wire                    dma_wr_done,
output  wire                    dma_rd_done,
//Master AXI4 Bus Interface
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
output  wire    [31:0]          m_axi_wdata,
output  wire    [3:0]           m_axi_wstrb,
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
input           [31:0]          m_axi_rdata,
input                           m_axi_rlast,
input           [1:0]           m_axi_rresp,
output  wire                    m_axi_rready,
//Buffer Write Interface
output  wire                    dma_wr_vld,
output  wire    [31:0]          dma_wr_data,
input                           dma_wr_rdy,
//Buffer Read Interface
input                           dma_rd_vld,
input           [31:0]          dma_rd_data,
output  wire                    dma_rd_rdy
);
// Parameter Define 

// Register Define

// Wire Define
wire                            s_arvalid;
wire    [31:0]                  s_araddr;
wire    [15:0]                  s_arlen;
wire                            s_arready;
wire    [31:0]                  s_rdata;
wire                            s_rvalid;
wire                            s_rready;
wire                            s_awvalid;
wire    [31:0]                  s_awaddr;
wire    [15:0]                  s_awlen;
wire                            s_awready;
wire    [31:0]                  s_wdata;
wire                            s_wvalid;
wire                            s_wready;

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/

/*----------------------- DMA Control Region ----------------------------*/
//pragma_end
dma_ctr u_dma_ctr
(
//Globle Signals
    .clk                                (m_axi_clk                          ),
    .rstn                               (rstn                               ),
//Control Signals
    .dma_start                          (dma_start                          ),
    .adma_system_address                (adma_system_address                ),
    .stop_at_block_gap_request          (stop_at_block_gap_request          ),
    .dma_wr_done                        (dma_wr_done                        ),
    .dma_rd_done                        (dma_rd_done                        ),
//DMA Write Data Interface
//--User Slave Read Bus Interface
    .s_arvalid                          (s_arvalid                          ),
    .s_araddr                           (s_araddr                           ),
    .s_arlen                            (s_arlen                            ),
    .s_arready                          (s_arready                          ),
    .s_rdata                            (s_rdata                            ),
    .s_rvalid                           (s_rvalid                           ),
    .s_rready                           (s_rready                           ),
//--Buffer Write Interface
    .dma_wr_vld                         (dma_wr_vld                         ),
    .dma_wr_data                        (dma_wr_data                        ),
    .dma_wr_rdy                         (dma_wr_rdy                         ),
//DMA Read Data Interface
//--User Slave Write Bus Interface
    .s_awvalid                          (s_awvalid                          ),
    .s_awaddr                           (s_awaddr                           ),
    .s_awlen                            (s_awlen                            ),
    .s_awready                          (s_awready                          ),
    .s_wdata                            (s_wdata                            ),
    .s_wvalid                           (s_wvalid                           ),
    .s_wready                           (s_wready                           ),
//--Buffer Rea Interface
    .dma_rd_vld                         (dma_rd_vld                         ),
    .dma_rd_data                        (dma_rd_data                        ),
    .dma_rd_rdy                         (dma_rd_rdy                         )
);

/*----------------------- Master AXI4 Write Region ----------------------------*/
m_axi4_wr#(
    .AXI_DW                             (32                                ),
    .AXI_AW                             (32                                 )
)
u_m_axi4_wr
(
//Globle Signals
    .rstn                               (rstn                               ),
    .clk                                (m_axi_clk                          ),
//Master AXI4 Write Bus Interface
    .m_axi_awvalid                      (m_axi_awvalid                      ),
    .m_axi_awaddr                       (m_axi_awaddr                       ),
    .m_axi_awlen                        (m_axi_awlen                        ),
    .m_axi_awsize                       (m_axi_awsize                       ),
    .m_axi_awburst                      (m_axi_awburst                      ),
    .m_axi_awprot                       (m_axi_awprot                       ),
    .m_axi_awlock                       (m_axi_awlock                       ),
    .m_axi_awcache                      (m_axi_awcache                      ),
    .m_axi_awready                      (m_axi_awready                      ),
    .m_axi_wdata                        (m_axi_wdata                        ),
    .m_axi_wstrb                        (m_axi_wstrb                        ),
    .m_axi_wlast                        (m_axi_wlast                        ),
    .m_axi_wvalid                       (m_axi_wvalid                       ),
    .m_axi_wready                       (m_axi_wready                       ),
    .m_axi_bresp                        (m_axi_bresp                        ),
    .m_axi_bvalid                       (m_axi_bvalid                       ),
    .m_axi_bready                       (m_axi_bready                       ),
//User Slave Write Bus Interface
    .s_awvalid                          (s_awvalid                          ),
    .s_awaddr                           (s_awaddr                           ),
    .s_awlen                            (s_awlen                            ),
    .s_awready                          (s_awready                          ),
    .s_wdata                            (s_wdata                            ),
    .s_wvalid                           (s_wvalid                           ),
    .s_wready                           (s_wready                           )
);

/*----------------------- Master AXI4 Read Region ----------------------------*/
m_axi4_rd#(
    .AXI_DW                             (32                                ),
    .AXI_AW                             (32                                 )
)
u_m_axi4_rd
(
//Globle Signals
    .rstn                               (rstn                               ),
    .clk                                (m_axi_clk                          ),
//Master AXI4 Read Bus Interface
    .m_axi_arvalid                      (m_axi_arvalid                      ),
    .m_axi_araddr                       (m_axi_araddr                       ),
    .m_axi_arlen                        (m_axi_arlen                        ),
    .m_axi_arsize                       (m_axi_arsize                       ),
    .m_axi_arburst                      (m_axi_arburst                      ),
    .m_axi_arprot                       (m_axi_arprot                       ),
    .m_axi_arlock                       (m_axi_arlock                       ),
    .m_axi_arcache                      (m_axi_arcache                      ),
    .m_axi_arready                      (m_axi_arready                      ),
    .m_axi_rvalid                       (m_axi_rvalid                       ),
    .m_axi_rdata                        (m_axi_rdata                        ),
    .m_axi_rlast                        (m_axi_rlast                        ),
    .m_axi_rresp                        (m_axi_rresp                        ),
    .m_axi_rready                       (m_axi_rready                       ),
//User Slave Read Bus Interface
    .s_arvalid                          (s_arvalid                          ),
    .s_araddr                           (s_araddr                           ),
    .s_arlen                            (s_arlen                            ),
    .s_arready                          (s_arready                          ),
    .s_rdata                            (s_rdata                            ),
    .s_rvalid                           (s_rvalid                           ),
    .s_rready                           (s_rready                           )
);

//Encryption end
endmodule
////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2013-2025 Efinix Inc. All rights reserved.              
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
////////////////////////////////////////////////////////////////////////////////
