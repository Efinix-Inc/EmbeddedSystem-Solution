module axi4_id_seq #(
parameter               AXI_DATA_WIDTH    = 256 ,
parameter               AXI_ADDR_WIDTH    = 64 ,
parameter               AXI_ID_WIDTH      = 8  ,
parameter               S_COUNT           = 2

)(
input           axi_clk,
input           axi_rstn,

//-----------------------------------------------------
//Master AXI4 interface 
output  wire    [AXI_ADDR_WIDTH * S_COUNT - 1:0]        m_axi_awaddr,
output  wire    [8 * S_COUNT - 1:0]                     m_axi_awlen,
output  wire    [S_COUNT - 1:0]                         m_axi_awvalid,
input           [S_COUNT - 1:0]                         m_axi_awready,

output  wire    [AXI_DATA_WIDTH * S_COUNT - 1:0]        m_axi_wdata,
output  wire    [(AXI_DATA_WIDTH * S_COUNT / 8) - 1:0]  m_axi_wstrb,
output  wire    [S_COUNT - 1:0]                         m_axi_wlast,
output  wire    [S_COUNT - 1:0]                         m_axi_wvalid,
input           [S_COUNT - 1:0]                         m_axi_wready,

input           [2 * S_COUNT - 1:0]                     m_axi_bresp,
input           [S_COUNT - 1:0]                         m_axi_bvalid,
output  wire    [S_COUNT - 1:0]                         m_axi_bready,

output  wire    [AXI_ADDR_WIDTH * S_COUNT - 1:0]        m_axi_araddr,
output  wire    [8 * S_COUNT - 1:0]                     m_axi_arlen,
output  wire    [S_COUNT - 1:0]                         m_axi_arvalid,
input           [S_COUNT - 1:0]                         m_axi_arready,

input           [AXI_DATA_WIDTH * S_COUNT - 1:0]        m_axi_rdata,
input           [2 * S_COUNT - 1:0]                     m_axi_rresp,
input           [S_COUNT - 1:0]                         m_axi_rlast,
input           [S_COUNT - 1:0]                         m_axi_rvalid,
output  wire    [S_COUNT - 1:0]                         m_axi_rready, 

//-----------------------------------------------------
//slave AXI4 interface
input           [AXI_ID_WIDTH * S_COUNT - 1:0]          s_axi_awid,
input           [S_COUNT - 1:0]                         s_axi_awvalid,
input           [AXI_ADDR_WIDTH * S_COUNT - 1:0]        s_axi_awaddr,
input           [8 * S_COUNT - 1:0]                     s_axi_awlen,
output  wire    [S_COUNT - 1:0]                         s_axi_awready,

input           [S_COUNT - 1:0]                         s_axi_wvalid,   
input           [AXI_DATA_WIDTH * S_COUNT - 1:0]        s_axi_wdata,
input           [(AXI_DATA_WIDTH * S_COUNT / 8) - 1:0]  s_axi_wstrb,
input           [S_COUNT - 1:0]                         s_axi_wlast,
output  wire    [S_COUNT - 1:0]                         s_axi_wready,

output  wire    [AXI_ID_WIDTH*S_COUNT - 1:0]            s_axi_bid,
output  wire    [8 * S_COUNT - 1:0]                     s_axi_bresp,
output  wire    [S_COUNT - 1:0]                         s_axi_bvalid,
input           [S_COUNT - 1:0]                         s_axi_bready,

input           [AXI_ID_WIDTH * S_COUNT - 1:0]          s_axi_arid,
input           [S_COUNT - 1:0]                         s_axi_arvalid,
input           [AXI_ADDR_WIDTH * S_COUNT - 1:0]        s_axi_araddr,
input           [8 * S_COUNT - 1:0]                     s_axi_arlen,
output  wire    [S_COUNT - 1:0]                         s_axi_arready,

output  wire    [AXI_ID_WIDTH * S_COUNT - 1:0]          s_axi_rid,
output  wire    [S_COUNT - 1:0]                         s_axi_rvalid,
output  wire    [AXI_DATA_WIDTH * S_COUNT - 1:0]        s_axi_rdata,
output  wire    [S_COUNT - 1:0]                         s_axi_rlast,
output  wire    [8 * S_COUNT - 1:0]                     s_axi_rresp,
input           [S_COUNT - 1:0]                         s_axi_rready 

);
//parameter 

//register

//wire
wire    [S_COUNT - 1:0]                                 awfifo_full;
wire    [S_COUNT - 1:0]                                 awfifo_empty;
wire    [S_COUNT - 1:0]                                 awfifo_wen;
wire    [S_COUNT - 1:0]                                 awfifo_ren;

wire    [S_COUNT - 1:0]                                 arfifo_full;
wire    [S_COUNT - 1:0]                                 arfifo_empty;
wire    [S_COUNT - 1:0]                                 arfifo_wen;
wire    [S_COUNT - 1:0]                                 arfifo_ren;


assign s_axi_awready  = m_axi_awready;
assign m_axi_awvalid  = s_axi_awvalid;
assign m_axi_awaddr   = s_axi_awaddr;
assign m_axi_awlen    = s_axi_awlen;


assign s_axi_wready   = m_axi_wready;
assign m_axi_wvalid   = s_axi_wvalid;
assign m_axi_wdata    = s_axi_wdata;
assign m_axi_wstrb    = s_axi_wstrb;
assign m_axi_wlast    = s_axi_wlast;

assign s_axi_bvalid   = m_axi_bvalid;
assign s_axi_bresp    = m_axi_bresp;


assign s_axi_arready  = m_axi_arready;
assign m_axi_arvalid  = s_axi_arvalid;
assign m_axi_araddr   = s_axi_araddr;
assign m_axi_arlen    = s_axi_arlen;


assign m_axi_rready   = s_axi_rready;
assign s_axi_rvalid   = m_axi_rvalid;
assign s_axi_rdata    = m_axi_rdata;
assign s_axi_rresp    = m_axi_rresp;
assign s_axi_rlast    = m_axi_rlast;

genvar i;

generate
for(i = 0 ; i < S_COUNT; i = i + 1) begin: FIFO_ID_U

    //**************************AWID***************************************************
    assign awfifo_wen[i]   = s_axi_awvalid[i] & s_axi_awready[i];
    assign m_axi_bready[i] = s_axi_bready[i] & !awfifo_empty[i];
    assign awfifo_ren[i]   = s_axi_bready[i] & !awfifo_empty[i] & m_axi_bvalid[i];


    common_efx_fifo_wrapper#(
        .FAMILY             ("TITANIUM"  ),
        .SYNC_CLK           (0           ),
        .SYNC_STAGE         (2           ),
        .DATA_WIDTH         (AXI_ID_WIDTH),
        .MODE               ("FWFT"      ),
        .OUTPUT_REG         (0           ),
        .PROG_FULL_ASSERT   (            ),
        .PROGRAMMABLE_FULL  ("NONE"      ),
        .PROG_FULL_NEGATE   (            ),
        .PROGRAMMABLE_EMPTY ("NONE"      ),
        .PROG_EMPTY_ASSERT  (0           ),
        .PROG_EMPTY_NEGATE  (0           ),
        .OPTIONAL_FLAGS     (1           ),
        .PIPELINE_REG       (1           ),
        .DEPTH              (256         ),
        .ASYM_WIDTH_RATIO   (4           ),
        .BYPASS_RESET_SYNC  (0           ) 
    )
    awid_fifo
    (
        .full_o             (awfifo_full[i]                             ),
        .empty_o            (awfifo_empty[i]                            ),
        .rdata              (s_axi_bid[i*AXI_ID_WIDTH +: AXI_ID_WIDTH]  ),
        .wdata              (s_axi_awid[i*AXI_ID_WIDTH +: AXI_ID_WIDTH] ),
        .clk_i              (axi_clk                                    ),
        .wr_clk_i           (axi_clk                                    ),
        .rd_clk_i           (axi_clk                                    ),
        .wr_en_i            (awfifo_wen[i]                              ),
        .rd_en_i            (awfifo_ren[i]                              ),
        .a_rst_i            (!axi_rstn                                  )
    ); 

    //**************************ARID***************************************************

    assign arfifo_wen[i] = s_axi_arready[i] & s_axi_arvalid[i];
    assign arfifo_ren[i] = m_axi_rvalid[i] & m_axi_rready[i] & m_axi_rlast[i];


    common_efx_fifo_wrapper#(
        .FAMILY             ("TITANIUM"  ),
        .SYNC_CLK           (0           ),
        .SYNC_STAGE         (2           ),
        .DATA_WIDTH         (AXI_ID_WIDTH),
        .MODE               ("FWFT"      ),
        .OUTPUT_REG         (0           ),
        .PROG_FULL_ASSERT   (            ),
        .PROGRAMMABLE_FULL  ("NONE"      ),
        .PROG_FULL_NEGATE   (            ),
        .PROGRAMMABLE_EMPTY ("NONE"      ),
        .PROG_EMPTY_ASSERT  (0           ),
        .PROG_EMPTY_NEGATE  (0           ),
        .OPTIONAL_FLAGS     (1           ),
        .PIPELINE_REG       (1           ),
        .DEPTH              (256         ),
        .ASYM_WIDTH_RATIO   (4           ),
        .BYPASS_RESET_SYNC  (0           ) 
    )
    arid_fifo
    (
        .full_o             (arfifo_full[i]                             ),
        .empty_o            (arfifo_empty[i]                            ),
        .rdata              (s_axi_rid[i*AXI_ID_WIDTH +: AXI_ID_WIDTH]  ),
        .wdata              (s_axi_arid[i*AXI_ID_WIDTH +: AXI_ID_WIDTH] ),
        .clk_i              (axi_clk                                    ),
        .wr_clk_i           (axi_clk                                    ),
        .rd_clk_i           (axi_clk                                    ),
        .wr_en_i            (arfifo_wen[i]                              ),
        .rd_en_i            (arfifo_ren[i]                              ),
        .a_rst_i            (!axi_rstn                                  )
    ); 

end endgenerate


endmodule