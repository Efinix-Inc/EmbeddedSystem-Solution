////////////////////////////////////////////////////////////////////////////
//           _____       
//          / _______    Copyright (C) 2013-2023 Efinix Inc. All rights reserved.
//         / /       \   
//        / /  ..    /   design_modules.v
//       / / .'     /    
//    __/ /.'      /     Description:
//   __   \       /      Modules for SapphireSoC example design
//  /_/ /\ \_____/ /     
// ____/  \_______/      
//
// ***********************************************************************
// Revisions:
// 1.0 Initial rev
// 1.1 Added Custom ALU
// 1.2 Fixed AXI4 slave read first issue
// 1.3 Added axi full-duplex to half-duplex converter
// 1.4 Support cache invalidation
// ***********************************************************************
`timescale 1ns/1ps

module apb3_slave #(
    // user parameter starts here
    //
    parameter   ADDR_WIDTH  = 16,
    parameter   DATA_WIDTH  = 32,
    parameter   NUM_REG     = 7
) (
    // user logic starts here
    input                    clk,
    input                    resetn,
    output                   start,
    output  [DATA_WIDTH-1:0] iaddr,
    output  [7:0]            ilen,
    output  [DATA_WIDTH-1:0] idata,
    input   [1:0]            status,
    input   [ADDR_WIDTH-1:0] PADDR,
    input                    PSEL,
    input                    PENABLE,
    output                   PREADY,
    input                    PWRITE,
    input   [DATA_WIDTH-1:0] PWDATA,
    output  [DATA_WIDTH-1:0] PRDATA,
    output                   PSLVERROR

);


///////////////////////////////////////////////////////////////////////////////

localparam [1:0]    IDLE   = 2'b00,
                    SETUP  = 2'b01,
                    ACCESS = 2'b10;

integer              byteIndex;
reg [DATA_WIDTH-1:0] slaveReg [0:NUM_REG-1];
reg [DATA_WIDTH-1:0] slaveRegOut;
reg [1:0]            busState, 
                     busNext;
reg                  slaveReady;
wire                 actWrite,
                     actRead;
reg [31:0]           lfsr;
wire                 lfsr_stop;


///////////////////////////////////////////////////////////////////////////////

    always@(posedge clk or negedge resetn)
    begin
        if(!resetn) 
            busState <= IDLE; 
        else
            busState <= busNext; 
    end

    always@(*)
    begin
        busNext = busState;

        case(busState)
            IDLE:
            begin
                if(PSEL && !PENABLE)
                    busNext = SETUP;
                else
                    busNext = IDLE;
            end
            SETUP:
            begin
                if(PSEL && PENABLE)
                    busNext = ACCESS;
                else
                    busNext = IDLE;
            end
            ACCESS:
            begin
                if(PREADY)
                    busNext = IDLE;
                else
                    busNext = ACCESS;
            end
            default:
            begin
                busNext = IDLE;
            end
        endcase
    end


    assign actWrite = PWRITE  & (busState == ACCESS);
    assign actRead  = !PWRITE & (busState == ACCESS);
    assign PSLVERROR = 1'b0; 
    assign PRDATA = slaveRegOut;
    assign PREADY = slaveReady & & (busState !== IDLE);

    always@ (posedge clk)
    begin
        slaveReady <= actWrite | actRead;
    end

    always@ (posedge clk or negedge resetn)
    begin
        if(!resetn)
            for(byteIndex = 0; byteIndex < NUM_REG; byteIndex = byteIndex + 1)
            slaveReg[byteIndex] <= {DATA_WIDTH{1'b0}};
        else 
        begin
            if(actWrite) 
            begin
                for(byteIndex = 0; byteIndex < NUM_REG; byteIndex = byteIndex + 1)
                if (PADDR[5:0] == (byteIndex*4))
                    slaveReg[byteIndex] <= PWDATA;
            end
            else
            begin
                slaveReg[0] <= lfsr;
                slaveReg[1] <= slaveReg[1];      
                slaveReg[2] <= {30'd0, status};                         
                for(byteIndex = 3; byteIndex < NUM_REG; byteIndex = byteIndex + 1)
                slaveReg[byteIndex] <= slaveReg[byteIndex];
            end
        end
    end

    always@ (posedge clk or negedge resetn)
    begin
        if(!resetn)
            slaveRegOut <= {DATA_WIDTH{1'b0}};
        else begin
            if(actRead)
                slaveRegOut <= slaveReg[PADDR[7:2]];
            else
                slaveRegOut <= slaveRegOut;
                
        end

    end

    assign lfsr_stop    = slaveReg[1][0];
    assign start        = slaveReg[3][0];
    assign ilen         = slaveReg[3][15:8];
    assign idata        = slaveReg[4];
    assign iaddr        = slaveReg[5];
//custom logics

    always@(posedge clk or negedge resetn)
    begin 
        if (!resetn)
            lfsr <= 'd1;
        else
        begin
            if(!lfsr_stop)
            begin
                lfsr[31] <= lfsr[0];
                lfsr[30] <= lfsr[31];
                lfsr[29] <= lfsr[30];
                lfsr[28] <= lfsr[29];
                lfsr[27] <= lfsr[28];
                lfsr[26] <= lfsr[27];
                lfsr[25] <= lfsr[26];
                lfsr[24] <= lfsr[25];
                lfsr[23] <= lfsr[24];
                lfsr[22] <= lfsr[23];
                lfsr[21] <= lfsr[22];
                lfsr[20] <= lfsr[21];
                lfsr[19] <= lfsr[20];
                lfsr[18] <= lfsr[19];
                lfsr[17] <= lfsr[18];
                lfsr[16] <= lfsr[17];
                lfsr[15] <= lfsr[16];
                lfsr[14] <= lfsr[15];
                lfsr[13] <= lfsr[14];
                lfsr[12] <= lfsr[13];
                lfsr[11] <= lfsr[12];
                lfsr[10] <= lfsr[11];
                lfsr[9 ] <= lfsr[10];
                lfsr[8 ] <= lfsr[9 ];
                lfsr[7 ] <= lfsr[8 ];
                lfsr[6 ] <= lfsr[7 ];
                lfsr[5 ] <= lfsr[6 ];
                lfsr[4 ] <= lfsr[5 ];
                lfsr[3 ] <= lfsr[4 ] ^ lfsr[0];
                lfsr[2 ] <= lfsr[3 ];
                lfsr[1 ] <= lfsr[2 ];
                lfsr[0 ] <= lfsr[1 ] ^ lfsr[0];
            end
            else
            begin
                lfsr <= lfsr;
            end
        end
    end

endmodule

// ***********************************************************************

module axi4_slave #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    //custom logic starts here
    output                  axi_interrupt,
    //
    input                   axi_aclk,
    input                   axi_resetn,
    //AW
    input [7:0]             axi_awid,
    input [ADDR_WIDTH-1:0]  axi_awaddr,
    input [7:0]             axi_awlen,
    input [2:0]             axi_awsize,
    input [1:0]             axi_awburst,
    input                   axi_awlock,
    input [3:0]             axi_awcache,
    input [2:0]             axi_awprot,
    input [3:0]             axi_awqos,
    input [3:0]             axi_awregion,
    input                   axi_awvalid,
    output                  axi_awready,
    //W
    input [DATA_WIDTH-1:0]  axi_wdata,
    input [(DATA_WIDTH/8)-1:0] 
                            axi_wstrb,
    input                   axi_wlast,
    input                   axi_wvalid,
    output                  axi_wready,
    //B
    output [7:0]            axi_bid,
    output [1:0]            axi_bresp,
    output                  axi_bvalid,
    input                   axi_bready,
    //AR
    input [7:0]             axi_arid,
    input [ADDR_WIDTH-1:0]  axi_araddr,
    input [7:0]             axi_arlen,
    input [2:0]             axi_arsize,
    input [1:0]             axi_arburst,
    input                   axi_arlock,
    input [3:0]             axi_arcache,
    input [2:0]             axi_arprot,
    input [3:0]             axi_arqos,
    input [3:0]             axi_arregion,
    input                   axi_arvalid,
    output                  axi_arready,
    //R
    output [7:0]            axi_rid,
    output [DATA_WIDTH-1:0] axi_rdata,
    output [1:0]            axi_rresp,
    output                  axi_rlast,
    output                  axi_rvalid,
    input                   axi_rready  
);

///////////////////////////////////////////////////////////////////////////////
localparam      RAM_SIZE = 2048;
localparam      RAMW     = $clog2(RAM_SIZE);

localparam [2:0]    IDLE    = 3'h0,
                    PRE_WR  = 3'h1,
                    WR      = 3'h2,
                    WR_RESP = 3'h3,
                    PRE_RD  = 3'h4,
                    RD      = 3'h5;
        
reg [2:0]       busState,
                busNext;
wire            busReady,
                busPreWrite,
                busWrite,
                busWriteResp,
                busPreRead,
                busRead;
wire            awWrap,
                arWrap;
reg  [7:0]      awidReg;
reg  [ADDR_WIDTH-1:0]   
                awaddrReg;
reg  [7:0]      awlenReg;
reg  [2:0]      awsizeReg;
reg  [1:0]      awburstReg,
                awlockReg;
reg  [3:0]      awcacheReg;
reg  [2:0]      awprotReg;
reg  [3:0]      awqosReg;
reg  [3:0]      awregionReg;

reg  [7:0]      aridReg;
reg  [ADDR_WIDTH-1:0]   
                araddrReg;
reg  [7:0]      arlenReg;
reg  [2:0]      arsizeReg;
reg  [1:0]      arburstReg,
                arlockReg;
reg  [3:0]      arcacheReg;
reg  [2:0]      arprotReg;
reg  [3:0]      arqosReg;
reg  [3:0]      arregionReg;

reg  [31:0]     awaddr_base;
wire [31:0]     awWrapSize;
reg  [7:0]      decodeAwsize;

wire [31:0]     araddr_wrap;
reg  [7:0]      decodeArsize;

reg  [31:0]     araddr_base;
wire [31:0]     arWrapSize;
reg  [7:0]      ridReg;
reg  [1:0]      rrespReg;
reg  [1:0]      rlastReg;

wire            pWr_done;
wire            pRd_done;
wire            awaddr_ext;
wire            araddr_ext;
wire [(DATA_WIDTH/8)-1:0] 
                rlast;
wire [(DATA_WIDTH/8)-1:0] 
                rvalid;
//custom logic
wire [9:0]      wdata  [0:3];
wire            wEnable[0:3];
wire [9:0]      rdata  [0:3];
wire [31:0]     data_o;
wire            rEnable;
reg             r_axi_interrupt;

///////////////////////////////////////////////////////////////////////////////


    always@ (posedge axi_aclk or negedge axi_resetn)
    begin
        if(!axi_resetn)
            busState <= IDLE;
        else
            busState <= busNext;

    end

    always@ (*)
    begin
        busNext = busState;

        case(busState)
        IDLE:
        begin
            if(axi_awvalid)
                busNext = PRE_WR;
            else if(axi_arvalid)
                busNext = PRE_RD;
            else
                busNext = IDLE;
        end
        PRE_WR:
        begin
            if(pWr_done)
                busNext = WR;
            else
                busNext = PRE_WR;
        end
        WR:
        begin
            if(axi_wlast)
                busNext = WR_RESP;
            else
                busNext = WR;
        end
        WR_RESP:
        begin
            if(axi_bready)
                busNext = IDLE;
            else
                busNext = WR_RESP;
        end
        PRE_RD:
        begin
            if(pRd_done)
                busNext = RD;
            else
                busNext = PRE_RD;
        end
        RD:
        begin
            if(axi_rlast && axi_rready)
                busNext = IDLE;
            else
                busNext = RD;
        end
        default:
            busNext = IDLE;
        endcase
    end

    assign busReady     = (busState == IDLE);
    assign busPreWrite  = (busState == PRE_WR);
    assign busWrite     = (busState == WR);
    assign busWriteResp = (busState == WR_RESP);
    assign busPreRead   = (busState == PRE_RD);
    assign busRead      = (busState == RD);

    //PRE_WRITE
    assign pWr_done = (awburstReg == 2'b10)? awaddr_ext : 1'b1;
    //AW Control

    assign axi_awready  = busReady;

    //Wrap Control
        always@ (posedge axi_aclk or negedge axi_resetn)
        begin
        if (!axi_resetn)
            awaddr_base <= 'h0;
        else begin
            if(busReady)
                awaddr_base <= 'h0;
            else if(busPreWrite && !awaddr_ext)
                awaddr_base <= awaddr_base + awWrapSize;
            else
                awaddr_base <= awaddr_base;
        end
    end

    assign awaddr_ext   = busPreWrite ? (awaddr_base[RAMW:0] > awaddrReg[RAMW:0]) : 1'b0;
    assign awWrap       = busWrite && (axi_awburst == 2'b10) ? (awaddrReg[RAMW:0] == awaddr_base - 4)     : 1'b0;
    assign awWrapSize   = (DATA_WIDTH/8) * awlenReg;

    //AW Info 
        always@ (posedge axi_aclk)
    begin
        if(axi_awvalid) begin
            awidReg     <= axi_awid;
            awlenReg    <= axi_awlen + 1'b1;
            awsizeReg   <= axi_awsize;
            awburstReg  <= axi_awburst;
            awlockReg   <= axi_awlock;
            awcacheReg  <= axi_awcache;
            awprotReg   <= axi_awprot;
            awqosReg    <= axi_awqos;
            awregionReg <= axi_awregion;
        end
        else begin
            awidReg     <= awidReg;
            awlenReg    <= awlenReg;
            awsizeReg   <= awsizeReg;
            awburstReg  <= awburstReg;
            awlockReg   <= awlockReg;
            awcacheReg  <= awcacheReg;
            awprotReg   <= awprotReg;
            awqosReg    <= awqosReg;
            awregionReg <= awregionReg;
        end
    end

    always@ (awsizeReg)
    begin
        case(awsizeReg)
        3'h0:decodeAwsize    <= 8'd1;
        3'h1:decodeAwsize    <= 8'd2;
        3'h2:decodeAwsize    <= 8'd4;
        3'h3:decodeAwsize    <= 8'd8;
        3'h4:decodeAwsize    <= 8'd16;
        3'h5:decodeAwsize    <= 8'd32;
        3'h6:decodeAwsize    <= 8'd64;
        3'h7:decodeAwsize    <= 8'd128;
        default:decodeAwsize <= 8'd1;
        endcase
    end

    always@ (posedge axi_aclk)
    begin
        if(axi_awvalid)
            awaddrReg   <= axi_awaddr;
        else if (busWrite) begin
            case(awburstReg)
            2'b00://fixed burst
            awaddrReg <= awaddrReg;
            2'b01://incremental burst
            awaddrReg <= awaddrReg + decodeAwsize;
            2'b10://wrap burst
            begin
                if(awWrap)
                    awaddrReg <= awaddrReg - awWrapSize;
                else
                    awaddrReg <= awaddrReg + decodeAwsize;
            end
            default:
            awaddrReg <= awaddrReg;
            endcase
        end
    end
    //W operation
        assign axi_wready = busWrite;

    //B Response
    assign axi_bid    = awidReg;
    assign axi_bresp  = 2'b00;
    assign axi_bvalid = busWriteResp;

   //PRE_READ
   assign pRd_done = (arburstReg == 2'b10)? araddr_ext : 1'b1;

   //AR Control
    assign axi_arready = busReady;

   //Wrap Control
        always@ (posedge axi_aclk or negedge axi_resetn)
        begin
        if (!axi_resetn)
            araddr_base <= 'h0;
        else begin
            if(busReady)
                araddr_base <= 'h0;
            else if(busPreRead && !araddr_ext)
                araddr_base <= araddr_base + arWrapSize;
            else
                araddr_base <= araddr_base;
        end
    end

    assign araddr_ext   = busPreRead ? (araddr_base[RAMW:0] > araddrReg[RAMW:0]) : 1'b0;
    assign arWrap       = (busRead && axi_arburst == 2'b10)   ? (araddrReg[RAMW:0] == araddr_base - 4)     : 1'b0;
    assign arWrapSize   = (DATA_WIDTH/8) * arlenReg;

    //AR Info 
        always@ (posedge axi_aclk)
    begin
        if(axi_arvalid) begin
            aridReg     <= axi_arid;
            arlenReg    <= axi_arlen + 1'b1;
            arsizeReg   <= axi_arsize;
            arburstReg  <= axi_arburst;
            arlockReg   <= axi_arlock;
            arcacheReg  <= axi_arcache;
            arprotReg   <= axi_arprot;
            arqosReg    <= axi_arqos;
            arregionReg <= axi_arregion;
        end
        else begin
            aridReg     <= aridReg;
            arlenReg    <= arlenReg;
            arsizeReg   <= arsizeReg;
            arburstReg  <= arburstReg;
            arlockReg   <= arlockReg;
            arcacheReg  <= arcacheReg;
            arprotReg   <= arprotReg;
            arqosReg    <= arqosReg;
            arregionReg <= arregionReg;
        end
    end

    always@ (arsizeReg)
    begin
        case(arsizeReg)
        3'h0:decodeArsize    <= 8'd1;
        3'h1:decodeArsize    <= 8'd2;
        3'h2:decodeArsize    <= 8'd4;
        3'h3:decodeArsize    <= 8'd8;
        3'h4:decodeArsize    <= 8'd16;
        3'h5:decodeArsize    <= 8'd32;
        3'h6:decodeArsize    <= 8'd64;
        3'h7:decodeArsize    <= 8'd128;
        default:decodeArsize <= 8'd1;
        endcase
    end

    always@ (posedge axi_aclk)
    begin
        if(axi_arvalid)
            araddrReg   <= axi_araddr;
        else if (rEnable && axi_rready) begin
            case(arburstReg)
            2'b00://fixed burst
            araddrReg <= araddrReg;
            2'b01://incremental burst
            araddrReg <= araddrReg + decodeArsize;
            2'b10://wrap burst
            begin
                if(arWrap)
                    araddrReg <= araddrReg - arWrapSize;
                else
                    araddrReg <= araddrReg + decodeArsize;
            end
            default:
            araddrReg <= araddrReg;
            endcase
        end
    end

    // R Operation
    assign axi_rdata  = data_o;
 
    // R Response
    assign axi_rvalid = busRead? |rvalid : 1'b0 ;
    assign axi_rlast  = busRead? |rlast : 1'b0 ;
        
    assign axi_rresp = 2'b00;
    assign axi_rid   = aridReg;

    //custom logic starts here
    assign axi_interrupt = r_axi_interrupt; 
    assign rEnable = (axi_arburst == 2'b10)? busRead : busPreRead;
    
    always@ (posedge axi_aclk)
    begin
        if (!axi_resetn)
        begin
            r_axi_interrupt <= 1'b0;
        end
        else
        begin
            if((axi_wvalid) && (axi_wdata == 16'hABCD)) 
                r_axi_interrupt <= 1'b1;
            else                        
                r_axi_interrupt <= 1'b0;    
        end     
    end
    
    genvar i;
    generate
        for(i=0;i < (DATA_WIDTH/8); i = i + 1) begin
    
        assign rvalid[i] = (arlenReg != 'h1)? rdata[i][8] : 1'b1;
        assign rlast[i] = (arlenReg != 'h1)? rdata[i][9] : 1'b1;
        assign wdata[i] = {axi_wlast, axi_wvalid, axi_wdata[(i*8+7) -: 8]} ;
        assign data_o[(i*8+7) -: 8] = rdata[i];
        assign wEnable[i] = axi_wready & axi_wvalid & axi_wstrb[i];

        ext_mem #(
            .DATA_WIDTH (10),
            .ADDR_WIDTH (RAMW-2),
            .OUTPUT_REG ("TRUE")
                         
        ) user_ram (
            .wdata  (wdata[i]),
            .waddr  (awaddrReg[RAMW-1:2]), 
            .raddr  (araddrReg[RAMW-1:2]),
            .we     (wEnable[i]), 
            .wclk   (axi_aclk), 
            .re     (rEnable), 
            .rclk   (axi_aclk),
            .rdata  (rdata[i])
        );
        end
    endgenerate

endmodule

// ***********************************************************************

module memory_checker #(
    parameter WIDTH       = 32,
    parameter ALEN        = 23,
    parameter START_ADDR  = 32'h00000000,
    parameter STOP_ADDR   = 32'h00100000,
    parameter ADDR_OFFSET = (ALEN + 1)*(WIDTH/8)
) (
input                       axi_clk,
input                       rstn,
input                       start,
output      [7:0]           aid,
output reg  [31:0]          aaddr,
output reg  [7:0]           alen,
output reg  [2:0]           asize,
output reg  [1:0]           aburst,
output reg  [1:0]           alock,
output reg                  avalid,
input                       aready,
output reg                  atype,

output      [7:0]           wid,
output reg  [WIDTH-1:0]     wdata,
output      [WIDTH/8-1:0]   wstrb,
output reg                  wlast,
output reg                  wvalid,
input                       wready,

input       [3:0]           rid,
input       [WIDTH-1:0]     rdata,
input                       rlast,
input                       rvalid,
output reg                  rready,
input       [1:0]           rresp,

input       [7:0]           bid,
input                       bvalid,
output reg                  bready,
output                      pass, 
// Dcache clearing
input                       apb3_clk,
input                       start2,
input       [31:0]          iaddr,                    
input       [31:0]          idata,
input       [7:0]           ilen,
output      [1:0]           status


);

///////////////////////////////////////////////////////////////////////////////
localparam  ASIZE = (WIDTH == 512)? 6 :
                    (WIDTH == 256)? 5 :
                    (WIDTH == 128)? 4 :
                    (WIDTH == 64)?  3 : 2;

//Main states
localparam  COMPARE_WIDTH = WIDTH;
localparam  IDLE            = 4'b0000, 
            WRITE_ADDR      = 4'b0001,
            PRE_WRITE       = 4'b0010,
            WRITE           = 4'b0011,
            POST_WRITE      = 4'b0100,
            READ_ADDR       = 4'b0101,
            PRE_READ        = 4'b0110,
            READ_COMPARE    = 4'b0111,
            POST_READ       = 4'b1000,
            DONE            = 4'b1001,
            IDLE2           = 4'b1010, 
            WRITE_ADDR2     = 4'b1011,
            PRE_WRITE2      = 4'b1100,
            WRITE2          = 4'b1101,
            POST_WRITE2     = 4'b1110;

//reg [3:0] states, nstates;
reg             fail;
reg             done;
reg [3:0]       states;
reg [3:0]       nstates;
reg             bvalid_done;
reg [1:0]       start_sync;
reg [8:0]       write_cnt, read_cnt;
reg [WIDTH-1:0] rdata_store;
reg             wburst_done, 
                rburst_done, 
                write_done, 
                read_done;
reg [8:0]       wcnt;

///////////////////////////////////////////////////////////////////////////////
    assign aid   = 8'h00;
    assign wstrb = {WIDTH/8{1'b1}};
    assign wid   = 8'h00;
    assign pass  = done & ~fail;
    
///////////////////////////////////////////////////////////////////////////////
// sync clock domain
///////////////////////////////////////////////////////////////////////////////
reg         start_s1;
reg  [1:0]  start_d1;
wire        start_w1,start_w2;
reg [31:0]  iaddr_s1;                    
reg [31:0]  idata_s1;
reg [7:0]   ilen_s1;
reg [1:0]   status_d1, status_d2;
reg         busy; 

always@(posedge apb3_clk)
begin
    start_s1    <= start2;
    status_d1   <= {busy, pass}; 
    status_d2   <= status_d1;
end

assign status   = status_d2;
assign start_w1 = start2 & ~start_s1;

pulse_synchronizer syncStart
(
    .clk_i(apb3_clk),
    .pulse_i(start_w1),
    .clk_o(axi_clk),
    .pulse_o(start_w2)
);

always@(posedge axi_clk)
begin
    start_d1 <= {start_d1[0], start_w2};
end

always@(posedge axi_clk)
begin
    if(start_w2)
    begin   
        iaddr_s1 <= iaddr;
        idata_s1 <= idata;
        ilen_s1 <= ilen;
    end
end 


    always @(posedge axi_clk or negedge rstn) 
    begin
        if (!rstn) begin
            start_sync <= 2'b00;
        end else begin
            start_sync[0] <= start;
            start_sync[1] <= start_sync[0];
        end
    end
    
    always @(posedge axi_clk or negedge rstn) 
    begin
        if (!rstn) begin
            states <= IDLE;
        end else begin
            states <= nstates;
        end
    end
    
    always @(states or start_sync[1] or write_cnt or rburst_done or write_done or read_done or bvalid_done or aready or start_d1) 
    begin
        case(states) 
        IDLE       : 
        if (start_sync[1])          
            nstates = WRITE_ADDR;
        else                    
            nstates = IDLE;
        WRITE_ADDR : 
        if (aready)             
            nstates = PRE_WRITE;
        else                    
            nstates = WRITE_ADDR;
        PRE_WRITE  :    
        nstates = WRITE;
        WRITE      : 
        if (write_cnt == 9'd0)          
            nstates = POST_WRITE;
        else                    
            nstates = WRITE;
        POST_WRITE : 
        if (write_done & bvalid_done)       
            nstates = READ_ADDR;
        else if (bvalid_done)           
            nstates = WRITE_ADDR;
        else                    
            nstates = POST_WRITE;
        READ_ADDR  : 
        if (aready)                 
            nstates = PRE_READ;
        else                    
            nstates = READ_ADDR;
        PRE_READ   :                        
        nstates = READ_COMPARE;
        READ_COMPARE  : 
        if (rburst_done)            
            nstates = POST_READ;
        else                    
            nstates = READ_COMPARE;
        POST_READ  :    
        if (read_done)              
            nstates = DONE;
        else                    
            nstates = READ_ADDR;
        DONE       :                        
        nstates = IDLE2;
        
    // New states to cater for specific write
        IDLE2   : // Wait for input from APB3 
        begin
        if(start_d1[1])
            nstates = WRITE_ADDR2;
        else
            nstates = IDLE2;
        end
        WRITE_ADDR2 : 
        if (aready)             
            nstates = PRE_WRITE2;
        else                    
            nstates = WRITE_ADDR2;
        PRE_WRITE2  :   
        nstates = WRITE2;
        WRITE2      : 
        if (write_cnt == 9'd0)          
            nstates = POST_WRITE2;
        else                    
            nstates = WRITE2;
        POST_WRITE2 : 
        if (write_done & bvalid_done)       
            nstates = IDLE2;
        else if (bvalid_done)           
            nstates = WRITE_ADDR2;
        else                    
            nstates = POST_WRITE2;
            
        default :
        nstates = IDLE;
        endcase
    end
    
    always @(posedge axi_clk or negedge rstn) 
    begin
        if (!rstn) begin
            aaddr       <= START_ADDR;
            avalid      <= 1'b0;
            atype       <= 1'b0;
            aburst      <= 2'b00;
            asize       <= 3'b000;
            alen        <= 8'd0;
            alock       <= 2'b00;
            wvalid      <= 1'b0;
            write_cnt   <= ALEN + 1;
            write_done  <= 1'b0;
            wdata       <= {WIDTH{1'b0}};
            wburst_done <= 1'b0;
            wlast       <= 1'b0;
            bready      <= 1'b0;
            fail        <= 1'b0;
            done        <= 1'b0;
            rready      <= 1'b0;
            bvalid_done <= 1'b0;
            busy        <= 1'b1; 
        end 
        else 
        begin
            if (states == IDLE) 
            begin
                aaddr       <= START_ADDR;
                avalid      <= 1'b0;
                atype       <= 1'b0;
                aburst      <= 2'b00;
                asize       <= 3'b000;
                alen        <= 8'd0;
                alock       <= 2'b00;
                wvalid      <= 1'b0;
                write_cnt   <= ALEN + 1;
                wdata       <= {WIDTH{1'b0}};
                wburst_done <= 1'b0;
                wlast       <= 1'b0;
                bready      <= 1'b0;
                rready      <= 1'b0;
                bvalid_done <= 1'b0;
                fail        <= 1'b0;
                done        <= 1'b0;
                busy        <= 1'b1; 
            end
            if (states == WRITE_ADDR) 
            begin
                avalid      <= 1'b1;
                atype       <= 1'b1;
                asize       <= ASIZE;
                alen        <= ALEN;
                aburst      <= 2'b01;
                alock       <= 2'b00;
                wvalid      <= 1'b0;
                write_cnt   <= ALEN + 1;
                wburst_done <= 1'b0;
                bvalid_done <= 1'b0;
                bready      <= 1'b0;
                rready      <= 1'b0;
                done        <= 1'b0;
                fail        <= 1'b0;
                busy        <= 1'b1; 
            end
            if (states == PRE_WRITE) 
            begin
                avalid      <= 1'b0;
                atype       <= 1'b0;
                wvalid      <= 1'b1;
                wdata       <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~write_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{write_cnt[7:0]}}};
                bready      <= 1'b1;
                write_cnt   <= write_cnt - 9'd1;
                busy        <= 1'b1; 
                if(alen == 'd0)
                begin
                    wlast <= 1'b1;
                end
            end
            if (states == WRITE) 
            begin
                busy        <= 1'b1; 
                if (wready == 1'b1) 
                begin
                    wdata   <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~write_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{write_cnt[7:0]}}};
                    if (write_cnt == 9'd0) 
                    begin
                        wburst_done <= 1'b1;
                        wlast       <= 1'b0;
                        wvalid      <= 1'b0;
                        if (aaddr >= STOP_ADDR) 
                        begin
                            write_done <= 1'b1;
                        end else 
                        begin
                            write_done <= 1'b0;
                        end
                    end if (write_cnt == 9'd1) 
                    begin
                        wlast     <= 1'b1;
                        write_cnt <= write_cnt - 9'd1;
                    end 
                    else 
                    begin
                        write_cnt <= write_cnt - 9'd1;
                    end
                end
            end
            if (states == POST_WRITE) 
            begin
                busy        <= 1'b1; 
                if (write_done) 
                begin
                        aaddr <= START_ADDR;
                end 
                else 
                begin
                    if (bvalid) begin
                        aaddr <= aaddr + ADDR_OFFSET;
                    end
                end
                if (wready == 1'b1) 
                begin
                    wlast   <= 1'b0;    
                    wvalid  <= 1'b0;    
                end
                if (bvalid) 
                begin
                    bvalid_done <= 1'b1;
                    bready      <= 1'b0;
                end
            end
            if (states == READ_ADDR) 
            begin
                busy     <= 1'b1; 
                avalid   <= 1'b1;
                read_cnt <= ALEN + 1;
                    
            end
            if (states == PRE_READ) 
            begin
                busy        <= 1'b1; 
                avalid      <= 1'b0;
                rburst_done <= 1'b0;
                rdata_store <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~read_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{read_cnt[7:0]}}};
                read_cnt    <= read_cnt - 1'b1;
            end
            if (states == READ_COMPARE) 
            begin
                busy   <= 1'b1; 
                rready <= 1'b1;
                if (read_cnt != 9'd0) 
                begin
                    if (rvalid == 1'b1) 
                    begin
                        rdata_store <= {{WIDTH/32{~aaddr[7:0]}},{WIDTH/32{~read_cnt[7:0]}},{WIDTH/32{aaddr[7:0]}},{WIDTH/32{read_cnt[7:0]}}};
                        read_cnt <= read_cnt - 1'b1;
                        if (rdata[COMPARE_WIDTH-1:0] != rdata_store[COMPARE_WIDTH-1:0]) 
                            fail <= 1'b1;
                        else 
                            fail <= 1'b0;
                    end
        
                end
            end
            if (read_cnt == 9'd0) 
            begin
                if (rvalid == 1'b1) 
                begin
                    if (rdata[COMPARE_WIDTH-1:0] != rdata_store[COMPARE_WIDTH-1:0]) 
                    begin
                        fail <= 1'b1;
                    end 
                    else 
                    begin
                        fail <= 1'b0;
                    end
                    if (aaddr >= STOP_ADDR) 
                    begin
                        read_done <= 1'b1;
                    end 
                    else 
                    begin
                        read_done <= 1'b0;
                    end
                    rburst_done <= 1'b1;
                end
            end
            if (states == POST_READ) 
            begin
                busy    <= 1'b1; 
                aaddr   <= aaddr + ADDR_OFFSET;
                rready  <= 1'b1;
            end
            if (states == DONE)
            begin
                busy <= 1'b1; 
                done <= 1'b1;
            end

            if (states == IDLE2) 
            begin
                aaddr       <= iaddr_s1;
                avalid      <= 1'b0;
                atype       <= 1'b0;
                aburst      <= 2'b00;
                asize       <= 3'b000;
                alen        <= 8'd0;
                alock       <= 2'b00;
                wvalid      <= 1'b0;
                write_cnt   <= ilen_s1 + 1;
                wdata       <= {WIDTH{1'b0}};
                wburst_done <= 1'b0;
                wlast       <= 1'b0;
                bready      <= 1'b0;
                rready      <= 1'b0;
                bvalid_done <= 1'b0;
                fail        <= 1'b0;
                done        <= 1'b1;
                busy        <= 1'b0; 
            end
            if (states == WRITE_ADDR2) 
            begin
                avalid      <= 1'b1;
                atype       <= 1'b1;
                asize       <= ASIZE;
                alen        <= ilen_s1;
                aburst      <= 2'b01;
                alock       <= 2'b00;
                wvalid      <= 1'b0;
                write_cnt   <= ilen_s1 + 1;
                wburst_done <= 1'b0;
                bvalid_done <= 1'b0;
                bready      <= 1'b0;
                rready      <= 1'b0;
                done        <= 1'b1;
                fail        <= 1'b0;
                busy        <= 1'b1; 
            end
            if (states == PRE_WRITE2) 
            begin
                avalid      <= 1'b0;
                atype       <= 1'b0;
                wvalid      <= 1'b1;
                wdata       <= idata_s1;
                bready      <= 1'b1;
                write_cnt   <= write_cnt - 9'd1;
                busy        <= 1'b1; 
                if(alen == 'd0)
                begin
                    wlast <= 1'b1;
                end
            end
            if (states == WRITE2) 
            begin
                busy        <= 1'b1; 
                if (wready == 1'b1) 
                begin
                    wdata   <= wdata + 'h1;
                    if (write_cnt == 9'd0) 
                    begin
                        wburst_done <= 1'b1;
                        wlast       <= 1'b0;
                        wvalid      <= 1'b0;
                        write_done  <= 1'b1;
                    end if (write_cnt == 9'd1) 
                    begin
                        wlast     <= 1'b1;
                        write_cnt <= write_cnt - 9'd1;
                    end 
                    else 
                    begin
                        write_cnt <= write_cnt - 9'd1;
                    end
                end
            end
            if (states == POST_WRITE2) 
            begin
                busy        <= 1'b1; 
                if (write_done) 
                begin
                        aaddr <= iaddr_s1;
                end 
                else 
                begin
                    if (bvalid) begin
                        aaddr <= iaddr_s1 + ((ilen_s1 + 1)*(WIDTH/8));
                    end
                end
                if (wready == 1'b1) 
                begin
                    wlast   <= 1'b0;    
                    wvalid  <= 1'b0;    
                end
                if (bvalid) 
                begin
                    bvalid_done <= 1'b1;
                    bready      <= 1'b0;
                end
            end
            
        end
    end
    
    
endmodule

// ***********************************************************************
module timer_start #(
    parameter MHZ    = 50,
    parameter SECOND = 3,
    parameter PULSE  = 0
) (
    input       clk,
    input       rst_n,
    output      start
); 

reg [35:0]  delay_cnt;
wire        second_tick;
reg [4:0]   second_cnt;
reg [3:0]   pulse_reg;
wire        start_reg;

///////////////////////////////////////////////////////////////////////////////

`ifndef EFX_SIM
localparam tick_cnt = (MHZ * 1000000) >> 1;
`else
localparam tick_cnt = MHZ * 200;
`endif

    always@(posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        delay_cnt <= 'd0;
    else
    begin
        if(delay_cnt == tick_cnt || start_reg == 1'b1)
            delay_cnt <= 'd0;
        else
            delay_cnt <= delay_cnt + 1'b1;
    end
    end

    assign second_tick = ((delay_cnt) == (tick_cnt - 1)); 

    always@(posedge clk or negedge rst_n)
    begin
    if(!rst_n)
        second_cnt <= 'd0;
    else
    begin
        if(second_tick)
            second_cnt <= second_cnt + 1'b1;
        else
            second_cnt <= second_cnt;
    end
    end

    assign start_reg = (second_cnt == SECOND);
    
    always@(posedge clk)
    begin
        pulse_reg <= {pulse_reg[2:0],start_reg};
    end

generate
if(PULSE == 1)
    assign start = ~pulse_reg[3] & start_reg;
else
    assign start = start_reg;
endgenerate

endmodule

// ***********************************************************************
module ext_mem #(
    parameter DATA_WIDTH    = 8,
    parameter ADDR_WIDTH    = 9,
    parameter OUTPUT_REG    = "TRUE",
    parameter RAM_INIT_FILE = ""
) (
    input [DATA_WIDTH-1:0]  wdata,
    input [ADDR_WIDTH-1:0]  waddr, 
    input [ADDR_WIDTH-1:0]  raddr,
    input                   we, 
    input                   wclk, 
    input                   re, 
    input                   rclk,
    output [DATA_WIDTH-1:0] rdata
);

/////////////////////////////////////////////////////////////////////////////

    localparam MEMORY_DEPTH = 2**ADDR_WIDTH;
    localparam MAX_DATA = (1<<ADDR_WIDTH)-1;

    reg [DATA_WIDTH-1:0]ram [MEMORY_DEPTH-1:0];
    wire [DATA_WIDTH-1:0] r_rdata_1P;
    reg [DATA_WIDTH-1:0] r_rdata_2P = 'h0;

/////////////////////////////////////////////////////////////////////////////
    initial
    begin
        if (RAM_INIT_FILE != "")
        begin
            $readmemh(RAM_INIT_FILE, ram);
        end
    end

    always @ (posedge wclk)
        if (we)
        ram[waddr] <= wdata;

    assign r_rdata_1P = re? ram[raddr] : 'hZ;

    always @ (posedge rclk)
    begin
        if (re)
        r_rdata_2P <= r_rdata_1P;
    end

    generate
        if (OUTPUT_REG == "TRUE")
            assign  rdata = r_rdata_2P;
        else
            assign  rdata = r_rdata_1P;
    endgenerate

endmodule

// ***********************************************************************
module custom_instruction_tea (
    input             clk,
    input             reset,
    input             cmd_valid,
    output            cmd_ready,
    input  [9:0]      cmd_function_id,
    input  [31:0]     cmd_inputs_0,
    input  [31:0]     cmd_inputs_1,
    output reg        rsp_valid,
    input             rsp_ready,
    output [31:0]     rsp_outputs_0
);

/////////////////////////////////////////////////////////////////////////////

    reg  [31:0]     raw_data0;
    reg  [31:0]     raw_data1;          
    reg             raw_valid;
    reg             raw_valid_upper;
    reg  [1:0]      valid_upper_r1;
    wire [63:0]     enc_out;
    wire            enc_valid;
    wire            enc_valid_upper;
    reg             enc_busy;
/////////////////////////////////////////////////////////////////////////////

    always@(posedge clk or posedge reset) 
    begin
        if(reset) 
        begin
            raw_data0       <= 32'd0;
            raw_data1       <= 32'd0;
            raw_valid       <= 1'b0;    
            raw_valid_upper <= raw_valid_upper;
        end 
        else 
        begin
            if (cmd_ready & cmd_valid) 
            begin
                case (cmd_function_id[1:0])
                2'd0:
                begin
                    raw_data0       <= cmd_inputs_0;
                    raw_data1       <= cmd_inputs_1;
                    raw_valid       <= 1'b1;
                    raw_valid_upper <= 1'b0;
                    
                end
                2'd1:
                begin
                    raw_data0       <= raw_data0;
                    raw_data1       <= raw_data1;
                    raw_valid       <= 1'b0;
                    raw_valid_upper <= 1'b1;
                end
                default:
                begin
                    raw_data0       <= raw_data0;
                    raw_data1       <= raw_data1;
                    raw_valid       <= 1'b0;
                    raw_valid_upper <= raw_valid_upper;
                end
                endcase 
            end
            else
            begin   
                raw_data0       <= raw_data0;
                raw_data1       <= raw_data1;
                raw_valid       <= 1'b0;
                raw_valid_upper <= raw_valid_upper;
            end
        end
    end

    always@(posedge clk or posedge reset)
    begin
        if(reset)
            enc_busy <= 1'b0;
        else
        begin
            if(rsp_valid && rsp_ready)
                enc_busy <= 1'b0;
            else if(cmd_valid)
                begin
                    case (cmd_function_id[1:0])
                    2'd0,2'd1:
                    enc_busy    <= 1'b1;
                    default:
                    enc_busy    <= 1'b0;
                    endcase
                end
            else
                enc_busy <= enc_busy;
        end
    end

    always@(posedge clk)
    begin
        valid_upper_r1 <= {valid_upper_r1[0], raw_valid_upper};
    end

    assign enc_valid_upper = valid_upper_r1[0] & ~valid_upper_r1[1];

    always@(posedge clk or posedge reset)
    begin
        if(reset)
            rsp_valid <= 1'b0;
        else
        begin
            if(enc_valid | enc_valid_upper)
                rsp_valid <= 1'b1;
            else if(rsp_ready)            
                rsp_valid <= 1'b0;
            else
                rsp_valid <= rsp_valid;
        end
    end
                

    assign rsp_outputs_0 = raw_valid_upper ? enc_out[63:32]:enc_out[31:0];
    assign cmd_ready     = !enc_busy;

    tiny_encrytion #(
    .ITER(1024)
    ) tea (
        .clk        (clk),
        .reset      (reset),
        .raw0       (raw_data0),
        .raw1       (raw_data1),
        .rawEn      (raw_valid),
        .busy       (),
        .enc_out    (enc_out),
        .enc_valid  (enc_valid)
    );

endmodule

/////////////////////////////////////////////////////////////////////////////
module tiny_encrytion #(
    parameter ITER = 1024
) (
    clk,
    reset,
    raw0,
    raw1,
    rawEn,
    busy,
    enc_out,
    enc_valid
    
);

input               clk;
input               reset;
input [31:0]        raw0;
input [31:0]        raw1;
input               rawEn;
output              busy;
output reg [63:0]   enc_out;
output              enc_valid; 


/////////////////////////////////////////////////////////////////////////////
localparam deltaConstant = 32'h9E3779B9;
localparam enckey0       = 32'h01234567;
localparam enckey1       = 32'h89abcdef;
localparam enckey2       = 32'h13579248;
localparam enckey3       = 32'h248a0135;
localparam CW            = $clog2(ITER);

reg [31:0]  raw_r0,
            raw_r1;

reg [CW-1:0] iteration_cnt;
reg [2:0]    iteration_start;
wire         iteration_stop;
reg          iteration_act;
reg [1:0]    data_tick;
reg          data_tick_r1;
reg [31:0]   delta_r1;

wire [31:0]  cal0_top;
wire [31:0]  cal0_mid;
wire [31:0]  cal0_bot;
wire [31:0]  cal0;

wire [31:0]  cal1_top;
wire [31:0]  cal1_mid;
wire [31:0]  cal1_bot;
wire [31:0]  cal1;

/////////////////////////////////////////////////////////////////////////////
always@(posedge clk)
begin
    if(data_tick[0])
        enc_out <= {raw_r1, raw_r0};
    else
        enc_out <= enc_out;
end

assign busy = iteration_act;
assign enc_valid = data_tick[1];

always@(posedge clk)
begin
        iteration_start <= {iteration_start[1:0], rawEn};
        data_tick <= {data_tick[0], iteration_stop};
end

assign iteration_stop = (iteration_cnt == {CW{1'b1}});

always@(posedge clk or posedge reset)
begin
    if(reset)
        iteration_act <= 'b0;
    else
    begin
        if(iteration_start[2])
            iteration_act <= 1'b1;
        else if(iteration_stop)
            iteration_act <= 1'b0;
        else
            iteration_act <= iteration_act;
    end
end

always@(posedge clk or posedge reset)
begin
    if(reset)
        iteration_cnt <= 'd0;
    else
    begin
        if(iteration_act)
            iteration_cnt <= iteration_cnt + 1'b1;
        else
            iteration_cnt <= 'd0;
    end
end

always@(posedge clk)
begin
    if(iteration_start[1] && !iteration_act)
    begin
        raw_r0 <= raw0;
        raw_r1 <= raw1;
        delta_r1 <= deltaConstant;
    end
    else
    if(iteration_act)
    begin
        raw_r0      <= cal1 + raw_r0;
        raw_r1      <= cal0 + raw_r1;
        delta_r1    <= delta_r1 + deltaConstant;
    end 
    else
    begin
        raw_r0      <= raw_r0;
        raw_r1      <= raw_r1;
        delta_r1    <= delta_r1;

    end
end


assign cal0_top     = ((raw_r0 + cal1) << 4) + enckey2;
assign cal0_mid     = (raw_r0 + cal1) + delta_r1;
assign cal0_bot     = ((raw_r0 + cal1) >> 5) + enckey3;
assign cal0         = cal0_top ^ cal0_mid ^ cal0_bot;
assign cal1_top     = (raw_r1 << 4) + enckey0;
assign cal1_mid     = raw_r1 + delta_r1;
assign cal1_bot     = (raw_r1 >> 5) + enckey1;
assign cal1         = cal1_top ^ cal1_mid ^ cal1_bot;

endmodule
/////////////////////////////////////////////////////////////////////////////
module fd_to_hd_wrapper (
input                       clk,
input                       reset,
output  wire                io_ddrA_arw_valid,
input                       io_ddrA_arw_ready,
output  wire    [31:0]      io_ddrA_arw_payload_addr,
output  wire    [7:0]       io_ddrA_arw_payload_id,
output  wire    [7:0]       io_ddrA_arw_payload_len,
output  wire    [2:0]       io_ddrA_arw_payload_size,
output  wire    [1:0]       io_ddrA_arw_payload_burst,
output  wire    [1:0]       io_ddrA_arw_payload_lock,
output  wire                io_ddrA_arw_payload_write,

input                       io_ddrA_aw_valid,
output  wire                io_ddrA_aw_ready,
input           [31:0]      io_ddrA_aw_payload_addr,
input           [7:0]       io_ddrA_aw_payload_id,
input           [7:0]       io_ddrA_aw_payload_len,
input           [2:0]       io_ddrA_aw_payload_size,
input           [1:0]       io_ddrA_aw_payload_burst,
input           [1:0]       io_ddrA_aw_payload_lock,

input                       io_ddrA_ar_valid,
output  wire                io_ddrA_ar_ready,
input           [31:0]      io_ddrA_ar_payload_addr,
input           [7:0]       io_ddrA_ar_payload_id,
input           [7:0]       io_ddrA_ar_payload_len,
input           [2:0]       io_ddrA_ar_payload_size,
input           [1:0]       io_ddrA_ar_payload_burst,
input           [1:0]       io_ddrA_ar_payload_lock
);
/////////////////////////////////////////////////////////////////////////////
localparam [1:0]    IDLE    = 2'h0,
                    WRITE   = 2'h1,
                    READ    = 2'h2;

reg [1:0]           st_cur,
                    st_next; 

wire                op_write,
                    op_read;
/////////////////////////////////////////////////////////////////////////////
    always@(posedge clk or posedge reset)
    begin
    if(reset)
        st_cur <= IDLE;
    else
        st_cur <= st_next;
    end

    always@*
    begin
        st_next = st_cur;
        case(st_cur)
        IDLE:
        begin
            if(io_ddrA_aw_valid)
                st_next = WRITE;
            else if (io_ddrA_ar_valid)
                st_next = READ;
            else
                st_next = IDLE;
        end
        WRITE:
        begin
            if(io_ddrA_aw_ready)
                st_next = IDLE;
            else
                st_next = WRITE;
        end
        READ:
        begin
            if(io_ddrA_ar_ready)
                st_next = IDLE;
            else
                st_next = READ;
        end
        default: st_next = IDLE;
        endcase
    end
        
assign op_write = (st_cur == WRITE);
assign op_read = (st_cur == READ);

assign io_ddrA_arw_valid         = op_write ? io_ddrA_aw_valid : op_read ? io_ddrA_ar_valid : 1'b0; 
assign io_ddrA_arw_payload_addr  = op_write ? io_ddrA_aw_payload_addr    : io_ddrA_ar_payload_addr;  
assign io_ddrA_arw_payload_id    = op_write ? io_ddrA_aw_payload_id      : io_ddrA_ar_payload_id;    
assign io_ddrA_arw_payload_len   = op_write ? io_ddrA_aw_payload_len     : io_ddrA_ar_payload_len;   
assign io_ddrA_arw_payload_size  = op_write ? io_ddrA_aw_payload_size    : io_ddrA_ar_payload_size;  
assign io_ddrA_arw_payload_burst = op_write ? io_ddrA_aw_payload_burst   : io_ddrA_ar_payload_burst; 
assign io_ddrA_arw_payload_lock  = op_write ? io_ddrA_aw_payload_lock    : io_ddrA_ar_payload_lock;  
assign io_ddrA_arw_payload_write = op_write;

assign io_ddrA_aw_ready = op_write ? io_ddrA_arw_ready : 1'b0;
assign io_ddrA_ar_ready = op_read ? io_ddrA_arw_ready : 1'b0;

endmodule

// ***********************************************************************

module reset_synchronizer #(
    parameter NUM_STAGE  = 10,
    parameter ACTIVE_LOW = 1
)(
    input reset_in,
    output reset_out,
    input clk
);
    
    reg [NUM_STAGE-1 : 0] data;
    
    generate if(ACTIVE_LOW == 1)
        always @(posedge clk or negedge reset_in) begin
            if(~reset_in) begin
                data <= {NUM_STAGE{1'b0}};
            end else begin
                data <= {1'b1, data[NUM_STAGE-1:1]};
            end 
        end
    else
        always @(posedge clk or posedge reset_in) begin
            if(reset_in) begin
                data <= {NUM_STAGE{1'b1}};
            end else begin
                data <= {1'b0, data[NUM_STAGE-1:1]};
            end
        end
    endgenerate

    assign reset_out = data[0];

endmodule

/////////////////////////////////////////////////////////////////////////////

module pulse_synchronizer
(
    clk_i,
    pulse_i,
    clk_o,
    pulse_o
);

input   clk_i;
input   pulse_i;
input   clk_o;
output  pulse_o;


/////////////////////////////////////////////////////////////////////////////
reg         sync_pulse = 1'b0;
reg [2:0]   sync_reg   = 3'd0; 

/////////////////////////////////////////////////////////////////////////////
always@ (posedge clk_i)
begin
    if(pulse_i)
        sync_pulse <= ~sync_pulse;
    else
        sync_pulse <= sync_pulse;
end

/////////////////////////////////////////////////////////////////////////////
always@ (posedge clk_o)
begin
    sync_reg[2] <= sync_pulse;
    sync_reg[1] <= sync_reg[2];
    sync_reg[0] <= sync_reg[1];
end

assign pulse_o = sync_reg[0] ^ sync_reg[1];

endmodule



/////////////////////////////////////////////////////////////////////////////
// 128-to-512 bit AXI upsizer
/////////////////////////////////////////////////////////////////////////////

module Asic128To512UpsizerAxi4Upsizer (
  input               io_input_aw_valid,
  output              io_input_aw_ready,
  input      [31:0]   io_input_aw_payload_addr,
  input      [7:0]    io_input_aw_payload_id,
  input      [3:0]    io_input_aw_payload_region,
  input      [7:0]    io_input_aw_payload_len,
  input      [2:0]    io_input_aw_payload_size,
  input      [1:0]    io_input_aw_payload_burst,
  input      [0:0]    io_input_aw_payload_lock,
  input      [3:0]    io_input_aw_payload_cache,
  input      [3:0]    io_input_aw_payload_qos,
  input      [2:0]    io_input_aw_payload_prot,
  input               io_input_w_valid,
  output              io_input_w_ready,
  input      [127:0]  io_input_w_payload_data,
  input      [15:0]   io_input_w_payload_strb,
  input               io_input_w_payload_last,
  output              io_input_b_valid,
  input               io_input_b_ready,
  output     [7:0]    io_input_b_payload_id,
  output     [1:0]    io_input_b_payload_resp,
  input               io_input_ar_valid,
  output              io_input_ar_ready,
  input      [31:0]   io_input_ar_payload_addr,
  input      [7:0]    io_input_ar_payload_id,
  input      [3:0]    io_input_ar_payload_region,
  input      [7:0]    io_input_ar_payload_len,
  input      [2:0]    io_input_ar_payload_size,
  input      [1:0]    io_input_ar_payload_burst,
  input      [0:0]    io_input_ar_payload_lock,
  input      [3:0]    io_input_ar_payload_cache,
  input      [3:0]    io_input_ar_payload_qos,
  input      [2:0]    io_input_ar_payload_prot,
  output              io_input_r_valid,
  input               io_input_r_ready,
  output     [127:0]  io_input_r_payload_data,
  output     [7:0]    io_input_r_payload_id,
  output     [1:0]    io_input_r_payload_resp,
  output              io_input_r_payload_last,
  output              io_output_aw_valid,
  input               io_output_aw_ready,
  output     [31:0]   io_output_aw_payload_addr,
  output     [7:0]    io_output_aw_payload_id,
  output     [3:0]    io_output_aw_payload_region,
  output     [7:0]    io_output_aw_payload_len,
  output     [2:0]    io_output_aw_payload_size,
  output     [1:0]    io_output_aw_payload_burst,
  output     [0:0]    io_output_aw_payload_lock,
  output     [3:0]    io_output_aw_payload_cache,
  output     [3:0]    io_output_aw_payload_qos,
  output     [2:0]    io_output_aw_payload_prot,
  output              io_output_w_valid,
  input               io_output_w_ready,
  output     [511:0]  io_output_w_payload_data,
  output     [63:0]   io_output_w_payload_strb,
  output              io_output_w_payload_last,
  input               io_output_b_valid,
  output              io_output_b_ready,
  input      [7:0]    io_output_b_payload_id,
  input      [1:0]    io_output_b_payload_resp,
  output              io_output_ar_valid,
  input               io_output_ar_ready,
  output     [31:0]   io_output_ar_payload_addr,
  output     [7:0]    io_output_ar_payload_id,
  output     [3:0]    io_output_ar_payload_region,
  output     [7:0]    io_output_ar_payload_len,
  output     [2:0]    io_output_ar_payload_size,
  output     [1:0]    io_output_ar_payload_burst,
  output     [0:0]    io_output_ar_payload_lock,
  output     [3:0]    io_output_ar_payload_cache,
  output     [3:0]    io_output_ar_payload_qos,
  output     [2:0]    io_output_ar_payload_prot,
  input               io_output_r_valid,
  output              io_output_r_ready,
  input      [511:0]  io_output_r_payload_data,
  input      [7:0]    io_output_r_payload_id,
  input      [1:0]    io_output_r_payload_resp,
  input               io_output_r_payload_last,
  input               clk,
  input               reset
);

  wire                readOnly_io_input_ar_ready;
  wire                readOnly_io_input_r_valid;
  wire       [127:0]  readOnly_io_input_r_payload_data;
  wire       [7:0]    readOnly_io_input_r_payload_id;
  wire       [1:0]    readOnly_io_input_r_payload_resp;
  wire                readOnly_io_input_r_payload_last;
  wire                readOnly_io_output_ar_valid;
  wire       [31:0]   readOnly_io_output_ar_payload_addr;
  wire       [7:0]    readOnly_io_output_ar_payload_id;
  wire       [3:0]    readOnly_io_output_ar_payload_region;
  wire       [7:0]    readOnly_io_output_ar_payload_len;
  wire       [2:0]    readOnly_io_output_ar_payload_size;
  wire       [1:0]    readOnly_io_output_ar_payload_burst;
  wire       [0:0]    readOnly_io_output_ar_payload_lock;
  wire       [3:0]    readOnly_io_output_ar_payload_cache;
  wire       [3:0]    readOnly_io_output_ar_payload_qos;
  wire       [2:0]    readOnly_io_output_ar_payload_prot;
  wire                readOnly_io_output_r_ready;
  wire                writeOnly_io_input_aw_ready;
  wire                writeOnly_io_input_w_ready;
  wire                writeOnly_io_input_b_valid;
  wire       [7:0]    writeOnly_io_input_b_payload_id;
  wire       [1:0]    writeOnly_io_input_b_payload_resp;
  wire                writeOnly_io_output_aw_valid;
  wire       [31:0]   writeOnly_io_output_aw_payload_addr;
  wire       [7:0]    writeOnly_io_output_aw_payload_id;
  wire       [3:0]    writeOnly_io_output_aw_payload_region;
  wire       [7:0]    writeOnly_io_output_aw_payload_len;
  wire       [2:0]    writeOnly_io_output_aw_payload_size;
  wire       [1:0]    writeOnly_io_output_aw_payload_burst;
  wire       [0:0]    writeOnly_io_output_aw_payload_lock;
  wire       [3:0]    writeOnly_io_output_aw_payload_cache;
  wire       [3:0]    writeOnly_io_output_aw_payload_qos;
  wire       [2:0]    writeOnly_io_output_aw_payload_prot;
  wire                writeOnly_io_output_w_valid;
  wire       [511:0]  writeOnly_io_output_w_payload_data;
  wire       [63:0]   writeOnly_io_output_w_payload_strb;
  wire                writeOnly_io_output_w_payload_last;
  wire                writeOnly_io_output_b_ready;

  Asic128To512UpsizerAxi4ReadOnlyUpsizer readOnly (
    .io_input_ar_valid           (io_input_ar_valid                        ), //i
    .io_input_ar_ready           (readOnly_io_input_ar_ready               ), //o
    .io_input_ar_payload_addr    (io_input_ar_payload_addr[31:0]           ), //i
    .io_input_ar_payload_id      (io_input_ar_payload_id[7:0]              ), //i
    .io_input_ar_payload_region  (io_input_ar_payload_region[3:0]          ), //i
    .io_input_ar_payload_len     (io_input_ar_payload_len[7:0]             ), //i
    .io_input_ar_payload_size    (io_input_ar_payload_size[2:0]            ), //i
    .io_input_ar_payload_burst   (io_input_ar_payload_burst[1:0]           ), //i
    .io_input_ar_payload_lock    (io_input_ar_payload_lock                 ), //i
    .io_input_ar_payload_cache   (io_input_ar_payload_cache[3:0]           ), //i
    .io_input_ar_payload_qos     (io_input_ar_payload_qos[3:0]             ), //i
    .io_input_ar_payload_prot    (io_input_ar_payload_prot[2:0]            ), //i
    .io_input_r_valid            (readOnly_io_input_r_valid                ), //o
    .io_input_r_ready            (io_input_r_ready                         ), //i
    .io_input_r_payload_data     (readOnly_io_input_r_payload_data[127:0]  ), //o
    .io_input_r_payload_id       (readOnly_io_input_r_payload_id[7:0]      ), //o
    .io_input_r_payload_resp     (readOnly_io_input_r_payload_resp[1:0]    ), //o
    .io_input_r_payload_last     (readOnly_io_input_r_payload_last         ), //o
    .io_output_ar_valid          (readOnly_io_output_ar_valid              ), //o
    .io_output_ar_ready          (io_output_ar_ready                       ), //i
    .io_output_ar_payload_addr   (readOnly_io_output_ar_payload_addr[31:0] ), //o
    .io_output_ar_payload_id     (readOnly_io_output_ar_payload_id[7:0]    ), //o
    .io_output_ar_payload_region (readOnly_io_output_ar_payload_region[3:0]), //o
    .io_output_ar_payload_len    (readOnly_io_output_ar_payload_len[7:0]   ), //o
    .io_output_ar_payload_size   (readOnly_io_output_ar_payload_size[2:0]  ), //o
    .io_output_ar_payload_burst  (readOnly_io_output_ar_payload_burst[1:0] ), //o
    .io_output_ar_payload_lock   (readOnly_io_output_ar_payload_lock       ), //o
    .io_output_ar_payload_cache  (readOnly_io_output_ar_payload_cache[3:0] ), //o
    .io_output_ar_payload_qos    (readOnly_io_output_ar_payload_qos[3:0]   ), //o
    .io_output_ar_payload_prot   (readOnly_io_output_ar_payload_prot[2:0]  ), //o
    .io_output_r_valid           (io_output_r_valid                        ), //i
    .io_output_r_ready           (readOnly_io_output_r_ready               ), //o
    .io_output_r_payload_data    (io_output_r_payload_data[511:0]          ), //i
    .io_output_r_payload_id      (io_output_r_payload_id[7:0]              ), //i
    .io_output_r_payload_resp    (io_output_r_payload_resp[1:0]            ), //i
    .io_output_r_payload_last    (io_output_r_payload_last                 ), //i
    .clk                         (clk                                      ), //i
    .reset                       (reset                                    )  //i
  );
  Asic128To512UpsizerAxi4WriteOnlyUpsizer writeOnly (
    .io_input_aw_valid           (io_input_aw_valid                         ), //i
    .io_input_aw_ready           (writeOnly_io_input_aw_ready               ), //o
    .io_input_aw_payload_addr    (io_input_aw_payload_addr[31:0]            ), //i
    .io_input_aw_payload_id      (io_input_aw_payload_id[7:0]               ), //i
    .io_input_aw_payload_region  (io_input_aw_payload_region[3:0]           ), //i
    .io_input_aw_payload_len     (io_input_aw_payload_len[7:0]              ), //i
    .io_input_aw_payload_size    (io_input_aw_payload_size[2:0]             ), //i
    .io_input_aw_payload_burst   (io_input_aw_payload_burst[1:0]            ), //i
    .io_input_aw_payload_lock    (io_input_aw_payload_lock                  ), //i
    .io_input_aw_payload_cache   (io_input_aw_payload_cache[3:0]            ), //i
    .io_input_aw_payload_qos     (io_input_aw_payload_qos[3:0]              ), //i
    .io_input_aw_payload_prot    (io_input_aw_payload_prot[2:0]             ), //i
    .io_input_w_valid            (io_input_w_valid                          ), //i
    .io_input_w_ready            (writeOnly_io_input_w_ready                ), //o
    .io_input_w_payload_data     (io_input_w_payload_data[127:0]            ), //i
    .io_input_w_payload_strb     (io_input_w_payload_strb[15:0]             ), //i
    .io_input_w_payload_last     (io_input_w_payload_last                   ), //i
    .io_input_b_valid            (writeOnly_io_input_b_valid                ), //o
    .io_input_b_ready            (io_input_b_ready                          ), //i
    .io_input_b_payload_id       (writeOnly_io_input_b_payload_id[7:0]      ), //o
    .io_input_b_payload_resp     (writeOnly_io_input_b_payload_resp[1:0]    ), //o
    .io_output_aw_valid          (writeOnly_io_output_aw_valid              ), //o
    .io_output_aw_ready          (io_output_aw_ready                        ), //i
    .io_output_aw_payload_addr   (writeOnly_io_output_aw_payload_addr[31:0] ), //o
    .io_output_aw_payload_id     (writeOnly_io_output_aw_payload_id[7:0]    ), //o
    .io_output_aw_payload_region (writeOnly_io_output_aw_payload_region[3:0]), //o
    .io_output_aw_payload_len    (writeOnly_io_output_aw_payload_len[7:0]   ), //o
    .io_output_aw_payload_size   (writeOnly_io_output_aw_payload_size[2:0]  ), //o
    .io_output_aw_payload_burst  (writeOnly_io_output_aw_payload_burst[1:0] ), //o
    .io_output_aw_payload_lock   (writeOnly_io_output_aw_payload_lock       ), //o
    .io_output_aw_payload_cache  (writeOnly_io_output_aw_payload_cache[3:0] ), //o
    .io_output_aw_payload_qos    (writeOnly_io_output_aw_payload_qos[3:0]   ), //o
    .io_output_aw_payload_prot   (writeOnly_io_output_aw_payload_prot[2:0]  ), //o
    .io_output_w_valid           (writeOnly_io_output_w_valid               ), //o
    .io_output_w_ready           (io_output_w_ready                         ), //i
    .io_output_w_payload_data    (writeOnly_io_output_w_payload_data[511:0] ), //o
    .io_output_w_payload_strb    (writeOnly_io_output_w_payload_strb[63:0]  ), //o
    .io_output_w_payload_last    (writeOnly_io_output_w_payload_last        ), //o
    .io_output_b_valid           (io_output_b_valid                         ), //i
    .io_output_b_ready           (writeOnly_io_output_b_ready               ), //o
    .io_output_b_payload_id      (io_output_b_payload_id[7:0]               ), //i
    .io_output_b_payload_resp    (io_output_b_payload_resp[1:0]             ), //i
    .clk                         (clk                                       ), //i
    .reset                       (reset                                     )  //i
  );
  assign io_input_ar_ready = readOnly_io_input_ar_ready;
  assign io_input_r_valid = readOnly_io_input_r_valid;
  assign io_input_r_payload_data = readOnly_io_input_r_payload_data;
  assign io_input_r_payload_id = readOnly_io_input_r_payload_id;
  assign io_input_r_payload_resp = readOnly_io_input_r_payload_resp;
  assign io_input_r_payload_last = readOnly_io_input_r_payload_last;
  assign io_input_aw_ready = writeOnly_io_input_aw_ready;
  assign io_input_w_ready = writeOnly_io_input_w_ready;
  assign io_input_b_valid = writeOnly_io_input_b_valid;
  assign io_input_b_payload_id = writeOnly_io_input_b_payload_id;
  assign io_input_b_payload_resp = writeOnly_io_input_b_payload_resp;
  assign io_output_ar_valid = readOnly_io_output_ar_valid;
  assign io_output_ar_payload_addr = readOnly_io_output_ar_payload_addr;
  assign io_output_ar_payload_id = readOnly_io_output_ar_payload_id;
  assign io_output_ar_payload_region = readOnly_io_output_ar_payload_region;
  assign io_output_ar_payload_len = readOnly_io_output_ar_payload_len;
  assign io_output_ar_payload_size = readOnly_io_output_ar_payload_size;
  assign io_output_ar_payload_burst = readOnly_io_output_ar_payload_burst;
  assign io_output_ar_payload_lock = readOnly_io_output_ar_payload_lock;
  assign io_output_ar_payload_cache = readOnly_io_output_ar_payload_cache;
  assign io_output_ar_payload_qos = readOnly_io_output_ar_payload_qos;
  assign io_output_ar_payload_prot = readOnly_io_output_ar_payload_prot;
  assign io_output_r_ready = readOnly_io_output_r_ready;
  assign io_output_aw_valid = writeOnly_io_output_aw_valid;
  assign io_output_aw_payload_addr = writeOnly_io_output_aw_payload_addr;
  assign io_output_aw_payload_id = writeOnly_io_output_aw_payload_id;
  assign io_output_aw_payload_region = writeOnly_io_output_aw_payload_region;
  assign io_output_aw_payload_len = writeOnly_io_output_aw_payload_len;
  assign io_output_aw_payload_size = writeOnly_io_output_aw_payload_size;
  assign io_output_aw_payload_burst = writeOnly_io_output_aw_payload_burst;
  assign io_output_aw_payload_lock = writeOnly_io_output_aw_payload_lock;
  assign io_output_aw_payload_cache = writeOnly_io_output_aw_payload_cache;
  assign io_output_aw_payload_qos = writeOnly_io_output_aw_payload_qos;
  assign io_output_aw_payload_prot = writeOnly_io_output_aw_payload_prot;
  assign io_output_w_valid = writeOnly_io_output_w_valid;
  assign io_output_w_payload_data = writeOnly_io_output_w_payload_data;
  assign io_output_w_payload_strb = writeOnly_io_output_w_payload_strb;
  assign io_output_w_payload_last = writeOnly_io_output_w_payload_last;
  assign io_output_b_ready = writeOnly_io_output_b_ready;

endmodule

module Asic128To512UpsizerAxi4WriteOnlyUpsizer (
  input               io_input_aw_valid,
  output reg          io_input_aw_ready,
  input      [31:0]   io_input_aw_payload_addr,
  input      [7:0]    io_input_aw_payload_id,
  input      [3:0]    io_input_aw_payload_region,
  input      [7:0]    io_input_aw_payload_len,
  input      [2:0]    io_input_aw_payload_size,
  input      [1:0]    io_input_aw_payload_burst,
  input      [0:0]    io_input_aw_payload_lock,
  input      [3:0]    io_input_aw_payload_cache,
  input      [3:0]    io_input_aw_payload_qos,
  input      [2:0]    io_input_aw_payload_prot,
  input               io_input_w_valid,
  output              io_input_w_ready,
  input      [127:0]  io_input_w_payload_data,
  input      [15:0]   io_input_w_payload_strb,
  input               io_input_w_payload_last,
  output              io_input_b_valid,
  input               io_input_b_ready,
  output     [7:0]    io_input_b_payload_id,
  output     [1:0]    io_input_b_payload_resp,
  output              io_output_aw_valid,
  input               io_output_aw_ready,
  output     [31:0]   io_output_aw_payload_addr,
  output     [7:0]    io_output_aw_payload_id,
  output     [3:0]    io_output_aw_payload_region,
  output reg [7:0]    io_output_aw_payload_len,
  output reg [2:0]    io_output_aw_payload_size,
  output     [1:0]    io_output_aw_payload_burst,
  output     [0:0]    io_output_aw_payload_lock,
  output     [3:0]    io_output_aw_payload_cache,
  output     [3:0]    io_output_aw_payload_qos,
  output     [2:0]    io_output_aw_payload_prot,
  output              io_output_w_valid,
  input               io_output_w_ready,
  output     [511:0]  io_output_w_payload_data,
  output     [63:0]   io_output_w_payload_strb,
  output              io_output_w_payload_last,
  input               io_output_b_valid,
  output              io_output_b_ready,
  input      [7:0]    io_output_b_payload_id,
  input      [1:0]    io_output_b_payload_resp,
  input               clk,
  input               reset
);

  wire       [14:0]   _zz_cmdLogic_byteCount;
  wire       [12:0]   _zz_cmdLogic_incrLen;
  wire       [12:0]   _zz_cmdLogic_incrLen_1;
  wire       [5:0]    _zz_cmdLogic_incrLen_2;
  wire       [6:0]    _zz_dataLogic_byteCounterNext;
  wire       [7:0]    _zz_dataLogic_byteCounterNext_1;
  reg        [63:0]   _zz_dataLogic_byteActivity;
  wire                cmdLogic_outputFork_valid;
  wire                cmdLogic_outputFork_ready;
  wire       [31:0]   cmdLogic_outputFork_payload_addr;
  wire       [7:0]    cmdLogic_outputFork_payload_id;
  wire       [3:0]    cmdLogic_outputFork_payload_region;
  wire       [7:0]    cmdLogic_outputFork_payload_len;
  wire       [2:0]    cmdLogic_outputFork_payload_size;
  wire       [1:0]    cmdLogic_outputFork_payload_burst;
  wire       [0:0]    cmdLogic_outputFork_payload_lock;
  wire       [3:0]    cmdLogic_outputFork_payload_cache;
  wire       [3:0]    cmdLogic_outputFork_payload_qos;
  wire       [2:0]    cmdLogic_outputFork_payload_prot;
  wire                cmdLogic_dataFork_valid;
  wire                cmdLogic_dataFork_ready;
  wire       [31:0]   cmdLogic_dataFork_payload_addr;
  wire       [7:0]    cmdLogic_dataFork_payload_id;
  wire       [3:0]    cmdLogic_dataFork_payload_region;
  wire       [7:0]    cmdLogic_dataFork_payload_len;
  wire       [2:0]    cmdLogic_dataFork_payload_size;
  wire       [1:0]    cmdLogic_dataFork_payload_burst;
  wire       [0:0]    cmdLogic_dataFork_payload_lock;
  wire       [3:0]    cmdLogic_dataFork_payload_cache;
  wire       [3:0]    cmdLogic_dataFork_payload_qos;
  wire       [2:0]    cmdLogic_dataFork_payload_prot;
  reg                 io_input_aw_fork2_logic_linkEnable_0;
  reg                 io_input_aw_fork2_logic_linkEnable_1;
  wire                when_Stream_l993;
  wire                when_Stream_l993_1;
  wire                cmdLogic_outputFork_fire;
  wire                cmdLogic_dataFork_fire;
  wire       [11:0]   cmdLogic_byteCount;
  wire       [6:0]    cmdLogic_incrLen;
  wire                when_Axi4Upsizer_l21;
  wire                when_Axi4Upsizer_l24;
  reg        [5:0]    dataLogic_byteCounter;
  reg        [2:0]    dataLogic_size;
  reg                 dataLogic_outputValid;
  reg                 dataLogic_outputLast;
  reg                 dataLogic_busy;
  reg                 dataLogic_incrementByteCounter;
  reg                 dataLogic_alwaysFire;
  wire       [6:0]    dataLogic_byteCounterNext;
  reg        [511:0]  dataLogic_dataBuffer;
  reg        [63:0]   dataLogic_maskBuffer;
  wire       [63:0]   dataLogic_byteActivity;
  wire                io_output_w_fire;
  wire                io_output_w_isStall;
  wire                io_input_w_fire;
  wire                when_Axi4Upsizer_l59;
  wire                when_Axi4Upsizer_l59_1;
  wire                when_Axi4Upsizer_l59_2;
  wire                when_Axi4Upsizer_l59_3;
  wire                when_Axi4Upsizer_l59_4;
  wire                when_Axi4Upsizer_l59_5;
  wire                when_Axi4Upsizer_l59_6;
  wire                when_Axi4Upsizer_l59_7;
  wire                when_Axi4Upsizer_l59_8;
  wire                when_Axi4Upsizer_l59_9;
  wire                when_Axi4Upsizer_l59_10;
  wire                when_Axi4Upsizer_l59_11;
  wire                when_Axi4Upsizer_l59_12;
  wire                when_Axi4Upsizer_l59_13;
  wire                when_Axi4Upsizer_l59_14;
  wire                when_Axi4Upsizer_l59_15;
  wire                when_Axi4Upsizer_l59_16;
  wire                when_Axi4Upsizer_l59_17;
  wire                when_Axi4Upsizer_l59_18;
  wire                when_Axi4Upsizer_l59_19;
  wire                when_Axi4Upsizer_l59_20;
  wire                when_Axi4Upsizer_l59_21;
  wire                when_Axi4Upsizer_l59_22;
  wire                when_Axi4Upsizer_l59_23;
  wire                when_Axi4Upsizer_l59_24;
  wire                when_Axi4Upsizer_l59_25;
  wire                when_Axi4Upsizer_l59_26;
  wire                when_Axi4Upsizer_l59_27;
  wire                when_Axi4Upsizer_l59_28;
  wire                when_Axi4Upsizer_l59_29;
  wire                when_Axi4Upsizer_l59_30;
  wire                when_Axi4Upsizer_l59_31;
  wire                when_Axi4Upsizer_l59_32;
  wire                when_Axi4Upsizer_l59_33;
  wire                when_Axi4Upsizer_l59_34;
  wire                when_Axi4Upsizer_l59_35;
  wire                when_Axi4Upsizer_l59_36;
  wire                when_Axi4Upsizer_l59_37;
  wire                when_Axi4Upsizer_l59_38;
  wire                when_Axi4Upsizer_l59_39;
  wire                when_Axi4Upsizer_l59_40;
  wire                when_Axi4Upsizer_l59_41;
  wire                when_Axi4Upsizer_l59_42;
  wire                when_Axi4Upsizer_l59_43;
  wire                when_Axi4Upsizer_l59_44;
  wire                when_Axi4Upsizer_l59_45;
  wire                when_Axi4Upsizer_l59_46;
  wire                when_Axi4Upsizer_l59_47;
  wire                when_Axi4Upsizer_l59_48;
  wire                when_Axi4Upsizer_l59_49;
  wire                when_Axi4Upsizer_l59_50;
  wire                when_Axi4Upsizer_l59_51;
  wire                when_Axi4Upsizer_l59_52;
  wire                when_Axi4Upsizer_l59_53;
  wire                when_Axi4Upsizer_l59_54;
  wire                when_Axi4Upsizer_l59_55;
  wire                when_Axi4Upsizer_l59_56;
  wire                when_Axi4Upsizer_l59_57;
  wire                when_Axi4Upsizer_l59_58;
  wire                when_Axi4Upsizer_l59_59;
  wire                when_Axi4Upsizer_l59_60;
  wire                when_Axi4Upsizer_l59_61;
  wire                when_Axi4Upsizer_l59_62;
  wire                when_Axi4Upsizer_l59_63;
  wire                cmdLogic_dataFork_fire_1;
  wire                when_Axi4Upsizer_l68;
  wire                when_Axi4Upsizer_l68_1;
  wire                when_Axi4Upsizer_l68_2;
  wire                when_Axi4Upsizer_l68_3;
  wire                when_Axi4Upsizer_l68_4;
  wire                when_Axi4Upsizer_l68_5;

  assign _zz_cmdLogic_byteCount = ({7'd0,io_input_aw_payload_len} <<< io_input_aw_payload_size);
  assign _zz_cmdLogic_incrLen = ({1'b0,cmdLogic_byteCount} + _zz_cmdLogic_incrLen_1);
  assign _zz_cmdLogic_incrLen_2 = io_input_aw_payload_addr[5 : 0];
  assign _zz_cmdLogic_incrLen_1 = {7'd0, _zz_cmdLogic_incrLen_2};
  assign _zz_dataLogic_byteCounterNext_1 = ({7'd0,1'b1} <<< dataLogic_size);
  assign _zz_dataLogic_byteCounterNext = _zz_dataLogic_byteCounterNext_1[6:0];
  always @(*) begin
    case(dataLogic_size)
      3'b000 : _zz_dataLogic_byteActivity = 64'h0000000000000001;
      3'b001 : _zz_dataLogic_byteActivity = 64'h0000000000000003;
      3'b010 : _zz_dataLogic_byteActivity = 64'h000000000000000f;
      3'b011 : _zz_dataLogic_byteActivity = 64'h00000000000000ff;
      3'b100 : _zz_dataLogic_byteActivity = 64'h000000000000ffff;
      default : _zz_dataLogic_byteActivity = 64'h00000000ffffffff;
    endcase
  end

  always @(*) begin
    io_input_aw_ready = 1'b1;
    if(when_Stream_l993) begin
      io_input_aw_ready = 1'b0;
    end
    if(when_Stream_l993_1) begin
      io_input_aw_ready = 1'b0;
    end
  end

  assign when_Stream_l993 = ((! cmdLogic_outputFork_ready) && io_input_aw_fork2_logic_linkEnable_0);
  assign when_Stream_l993_1 = ((! cmdLogic_dataFork_ready) && io_input_aw_fork2_logic_linkEnable_1);
  assign cmdLogic_outputFork_valid = (io_input_aw_valid && io_input_aw_fork2_logic_linkEnable_0);
  assign cmdLogic_outputFork_payload_addr = io_input_aw_payload_addr;
  assign cmdLogic_outputFork_payload_id = io_input_aw_payload_id;
  assign cmdLogic_outputFork_payload_region = io_input_aw_payload_region;
  assign cmdLogic_outputFork_payload_len = io_input_aw_payload_len;
  assign cmdLogic_outputFork_payload_size = io_input_aw_payload_size;
  assign cmdLogic_outputFork_payload_burst = io_input_aw_payload_burst;
  assign cmdLogic_outputFork_payload_lock = io_input_aw_payload_lock;
  assign cmdLogic_outputFork_payload_cache = io_input_aw_payload_cache;
  assign cmdLogic_outputFork_payload_qos = io_input_aw_payload_qos;
  assign cmdLogic_outputFork_payload_prot = io_input_aw_payload_prot;
  assign cmdLogic_outputFork_fire = (cmdLogic_outputFork_valid && cmdLogic_outputFork_ready);
  assign cmdLogic_dataFork_valid = (io_input_aw_valid && io_input_aw_fork2_logic_linkEnable_1);
  assign cmdLogic_dataFork_payload_addr = io_input_aw_payload_addr;
  assign cmdLogic_dataFork_payload_id = io_input_aw_payload_id;
  assign cmdLogic_dataFork_payload_region = io_input_aw_payload_region;
  assign cmdLogic_dataFork_payload_len = io_input_aw_payload_len;
  assign cmdLogic_dataFork_payload_size = io_input_aw_payload_size;
  assign cmdLogic_dataFork_payload_burst = io_input_aw_payload_burst;
  assign cmdLogic_dataFork_payload_lock = io_input_aw_payload_lock;
  assign cmdLogic_dataFork_payload_cache = io_input_aw_payload_cache;
  assign cmdLogic_dataFork_payload_qos = io_input_aw_payload_qos;
  assign cmdLogic_dataFork_payload_prot = io_input_aw_payload_prot;
  assign cmdLogic_dataFork_fire = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign io_output_aw_valid = cmdLogic_outputFork_valid;
  assign cmdLogic_outputFork_ready = io_output_aw_ready;
  assign io_output_aw_payload_addr = cmdLogic_outputFork_payload_addr;
  assign io_output_aw_payload_id = cmdLogic_outputFork_payload_id;
  assign io_output_aw_payload_region = cmdLogic_outputFork_payload_region;
  always @(*) begin
    io_output_aw_payload_len = cmdLogic_outputFork_payload_len;
    if(when_Axi4Upsizer_l21) begin
      io_output_aw_payload_len = {1'd0, cmdLogic_incrLen};
    end
  end

  always @(*) begin
    io_output_aw_payload_size = cmdLogic_outputFork_payload_size;
    if(when_Axi4Upsizer_l21) begin
      io_output_aw_payload_size = 3'b110;
      if(when_Axi4Upsizer_l24) begin
        io_output_aw_payload_size = io_input_aw_payload_size;
      end
    end
  end

  assign io_output_aw_payload_burst = cmdLogic_outputFork_payload_burst;
  assign io_output_aw_payload_lock = cmdLogic_outputFork_payload_lock;
  assign io_output_aw_payload_cache = cmdLogic_outputFork_payload_cache;
  assign io_output_aw_payload_qos = cmdLogic_outputFork_payload_qos;
  assign io_output_aw_payload_prot = cmdLogic_outputFork_payload_prot;
  assign cmdLogic_byteCount = _zz_cmdLogic_byteCount[11:0];
  assign cmdLogic_incrLen = _zz_cmdLogic_incrLen[12 : 6];
  assign when_Axi4Upsizer_l21 = (io_output_aw_payload_burst == 2'b01);
  assign when_Axi4Upsizer_l24 = (io_input_aw_payload_len == 8'h00);
  assign dataLogic_byteCounterNext = ({1'b0,dataLogic_byteCounter} + _zz_dataLogic_byteCounterNext);
  assign dataLogic_byteActivity = (_zz_dataLogic_byteActivity <<< dataLogic_byteCounter);
  assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
  assign io_output_w_valid = dataLogic_outputValid;
  assign io_output_w_isStall = (io_output_w_valid && (! io_output_w_ready));
  assign io_input_w_ready = (dataLogic_busy && (! io_output_w_isStall));
  assign io_output_w_payload_data = dataLogic_dataBuffer;
  assign io_output_w_payload_strb = dataLogic_maskBuffer;
  assign io_output_w_payload_last = dataLogic_outputLast;
  assign io_input_w_fire = (io_input_w_valid && io_input_w_ready);
  assign when_Axi4Upsizer_l59 = dataLogic_byteActivity[0];
  assign when_Axi4Upsizer_l59_1 = dataLogic_byteActivity[1];
  assign when_Axi4Upsizer_l59_2 = dataLogic_byteActivity[2];
  assign when_Axi4Upsizer_l59_3 = dataLogic_byteActivity[3];
  assign when_Axi4Upsizer_l59_4 = dataLogic_byteActivity[4];
  assign when_Axi4Upsizer_l59_5 = dataLogic_byteActivity[5];
  assign when_Axi4Upsizer_l59_6 = dataLogic_byteActivity[6];
  assign when_Axi4Upsizer_l59_7 = dataLogic_byteActivity[7];
  assign when_Axi4Upsizer_l59_8 = dataLogic_byteActivity[8];
  assign when_Axi4Upsizer_l59_9 = dataLogic_byteActivity[9];
  assign when_Axi4Upsizer_l59_10 = dataLogic_byteActivity[10];
  assign when_Axi4Upsizer_l59_11 = dataLogic_byteActivity[11];
  assign when_Axi4Upsizer_l59_12 = dataLogic_byteActivity[12];
  assign when_Axi4Upsizer_l59_13 = dataLogic_byteActivity[13];
  assign when_Axi4Upsizer_l59_14 = dataLogic_byteActivity[14];
  assign when_Axi4Upsizer_l59_15 = dataLogic_byteActivity[15];
  assign when_Axi4Upsizer_l59_16 = dataLogic_byteActivity[16];
  assign when_Axi4Upsizer_l59_17 = dataLogic_byteActivity[17];
  assign when_Axi4Upsizer_l59_18 = dataLogic_byteActivity[18];
  assign when_Axi4Upsizer_l59_19 = dataLogic_byteActivity[19];
  assign when_Axi4Upsizer_l59_20 = dataLogic_byteActivity[20];
  assign when_Axi4Upsizer_l59_21 = dataLogic_byteActivity[21];
  assign when_Axi4Upsizer_l59_22 = dataLogic_byteActivity[22];
  assign when_Axi4Upsizer_l59_23 = dataLogic_byteActivity[23];
  assign when_Axi4Upsizer_l59_24 = dataLogic_byteActivity[24];
  assign when_Axi4Upsizer_l59_25 = dataLogic_byteActivity[25];
  assign when_Axi4Upsizer_l59_26 = dataLogic_byteActivity[26];
  assign when_Axi4Upsizer_l59_27 = dataLogic_byteActivity[27];
  assign when_Axi4Upsizer_l59_28 = dataLogic_byteActivity[28];
  assign when_Axi4Upsizer_l59_29 = dataLogic_byteActivity[29];
  assign when_Axi4Upsizer_l59_30 = dataLogic_byteActivity[30];
  assign when_Axi4Upsizer_l59_31 = dataLogic_byteActivity[31];
  assign when_Axi4Upsizer_l59_32 = dataLogic_byteActivity[32];
  assign when_Axi4Upsizer_l59_33 = dataLogic_byteActivity[33];
  assign when_Axi4Upsizer_l59_34 = dataLogic_byteActivity[34];
  assign when_Axi4Upsizer_l59_35 = dataLogic_byteActivity[35];
  assign when_Axi4Upsizer_l59_36 = dataLogic_byteActivity[36];
  assign when_Axi4Upsizer_l59_37 = dataLogic_byteActivity[37];
  assign when_Axi4Upsizer_l59_38 = dataLogic_byteActivity[38];
  assign when_Axi4Upsizer_l59_39 = dataLogic_byteActivity[39];
  assign when_Axi4Upsizer_l59_40 = dataLogic_byteActivity[40];
  assign when_Axi4Upsizer_l59_41 = dataLogic_byteActivity[41];
  assign when_Axi4Upsizer_l59_42 = dataLogic_byteActivity[42];
  assign when_Axi4Upsizer_l59_43 = dataLogic_byteActivity[43];
  assign when_Axi4Upsizer_l59_44 = dataLogic_byteActivity[44];
  assign when_Axi4Upsizer_l59_45 = dataLogic_byteActivity[45];
  assign when_Axi4Upsizer_l59_46 = dataLogic_byteActivity[46];
  assign when_Axi4Upsizer_l59_47 = dataLogic_byteActivity[47];
  assign when_Axi4Upsizer_l59_48 = dataLogic_byteActivity[48];
  assign when_Axi4Upsizer_l59_49 = dataLogic_byteActivity[49];
  assign when_Axi4Upsizer_l59_50 = dataLogic_byteActivity[50];
  assign when_Axi4Upsizer_l59_51 = dataLogic_byteActivity[51];
  assign when_Axi4Upsizer_l59_52 = dataLogic_byteActivity[52];
  assign when_Axi4Upsizer_l59_53 = dataLogic_byteActivity[53];
  assign when_Axi4Upsizer_l59_54 = dataLogic_byteActivity[54];
  assign when_Axi4Upsizer_l59_55 = dataLogic_byteActivity[55];
  assign when_Axi4Upsizer_l59_56 = dataLogic_byteActivity[56];
  assign when_Axi4Upsizer_l59_57 = dataLogic_byteActivity[57];
  assign when_Axi4Upsizer_l59_58 = dataLogic_byteActivity[58];
  assign when_Axi4Upsizer_l59_59 = dataLogic_byteActivity[59];
  assign when_Axi4Upsizer_l59_60 = dataLogic_byteActivity[60];
  assign when_Axi4Upsizer_l59_61 = dataLogic_byteActivity[61];
  assign when_Axi4Upsizer_l59_62 = dataLogic_byteActivity[62];
  assign when_Axi4Upsizer_l59_63 = dataLogic_byteActivity[63];
  assign cmdLogic_dataFork_fire_1 = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign when_Axi4Upsizer_l68 = (3'b000 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_1 = (3'b001 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_2 = (3'b010 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_3 = (3'b011 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_4 = (3'b100 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_5 = (3'b101 < cmdLogic_dataFork_payload_size);
  assign cmdLogic_dataFork_ready = (! dataLogic_busy);
  assign io_input_b_valid = io_output_b_valid;
  assign io_output_b_ready = io_input_b_ready;
  assign io_input_b_payload_id = io_output_b_payload_id;
  assign io_input_b_payload_resp = io_output_b_payload_resp;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_aw_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_aw_fork2_logic_linkEnable_1 <= 1'b1;
      dataLogic_outputValid <= 1'b0;
      dataLogic_busy <= 1'b0;
      dataLogic_maskBuffer <= 64'h0000000000000000;
    end else begin
      if(cmdLogic_outputFork_fire) begin
        io_input_aw_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdLogic_dataFork_fire) begin
        io_input_aw_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_aw_ready) begin
        io_input_aw_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_aw_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(io_output_w_ready) begin
        dataLogic_outputValid <= 1'b0;
      end
      if(io_output_w_fire) begin
        dataLogic_maskBuffer <= 64'h0000000000000000;
      end
      if(io_input_w_fire) begin
        dataLogic_outputValid <= ((dataLogic_byteCounterNext[6] || io_input_w_payload_last) || dataLogic_alwaysFire);
        if(io_input_w_payload_last) begin
          dataLogic_busy <= 1'b0;
        end
        if(when_Axi4Upsizer_l59) begin
          dataLogic_maskBuffer[0] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_1) begin
          dataLogic_maskBuffer[1] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_2) begin
          dataLogic_maskBuffer[2] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_3) begin
          dataLogic_maskBuffer[3] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_4) begin
          dataLogic_maskBuffer[4] <= io_input_w_payload_strb[4];
        end
        if(when_Axi4Upsizer_l59_5) begin
          dataLogic_maskBuffer[5] <= io_input_w_payload_strb[5];
        end
        if(when_Axi4Upsizer_l59_6) begin
          dataLogic_maskBuffer[6] <= io_input_w_payload_strb[6];
        end
        if(when_Axi4Upsizer_l59_7) begin
          dataLogic_maskBuffer[7] <= io_input_w_payload_strb[7];
        end
        if(when_Axi4Upsizer_l59_8) begin
          dataLogic_maskBuffer[8] <= io_input_w_payload_strb[8];
        end
        if(when_Axi4Upsizer_l59_9) begin
          dataLogic_maskBuffer[9] <= io_input_w_payload_strb[9];
        end
        if(when_Axi4Upsizer_l59_10) begin
          dataLogic_maskBuffer[10] <= io_input_w_payload_strb[10];
        end
        if(when_Axi4Upsizer_l59_11) begin
          dataLogic_maskBuffer[11] <= io_input_w_payload_strb[11];
        end
        if(when_Axi4Upsizer_l59_12) begin
          dataLogic_maskBuffer[12] <= io_input_w_payload_strb[12];
        end
        if(when_Axi4Upsizer_l59_13) begin
          dataLogic_maskBuffer[13] <= io_input_w_payload_strb[13];
        end
        if(when_Axi4Upsizer_l59_14) begin
          dataLogic_maskBuffer[14] <= io_input_w_payload_strb[14];
        end
        if(when_Axi4Upsizer_l59_15) begin
          dataLogic_maskBuffer[15] <= io_input_w_payload_strb[15];
        end
        if(when_Axi4Upsizer_l59_16) begin
          dataLogic_maskBuffer[16] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_17) begin
          dataLogic_maskBuffer[17] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_18) begin
          dataLogic_maskBuffer[18] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_19) begin
          dataLogic_maskBuffer[19] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_20) begin
          dataLogic_maskBuffer[20] <= io_input_w_payload_strb[4];
        end
        if(when_Axi4Upsizer_l59_21) begin
          dataLogic_maskBuffer[21] <= io_input_w_payload_strb[5];
        end
        if(when_Axi4Upsizer_l59_22) begin
          dataLogic_maskBuffer[22] <= io_input_w_payload_strb[6];
        end
        if(when_Axi4Upsizer_l59_23) begin
          dataLogic_maskBuffer[23] <= io_input_w_payload_strb[7];
        end
        if(when_Axi4Upsizer_l59_24) begin
          dataLogic_maskBuffer[24] <= io_input_w_payload_strb[8];
        end
        if(when_Axi4Upsizer_l59_25) begin
          dataLogic_maskBuffer[25] <= io_input_w_payload_strb[9];
        end
        if(when_Axi4Upsizer_l59_26) begin
          dataLogic_maskBuffer[26] <= io_input_w_payload_strb[10];
        end
        if(when_Axi4Upsizer_l59_27) begin
          dataLogic_maskBuffer[27] <= io_input_w_payload_strb[11];
        end
        if(when_Axi4Upsizer_l59_28) begin
          dataLogic_maskBuffer[28] <= io_input_w_payload_strb[12];
        end
        if(when_Axi4Upsizer_l59_29) begin
          dataLogic_maskBuffer[29] <= io_input_w_payload_strb[13];
        end
        if(when_Axi4Upsizer_l59_30) begin
          dataLogic_maskBuffer[30] <= io_input_w_payload_strb[14];
        end
        if(when_Axi4Upsizer_l59_31) begin
          dataLogic_maskBuffer[31] <= io_input_w_payload_strb[15];
        end
        if(when_Axi4Upsizer_l59_32) begin
          dataLogic_maskBuffer[32] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_33) begin
          dataLogic_maskBuffer[33] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_34) begin
          dataLogic_maskBuffer[34] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_35) begin
          dataLogic_maskBuffer[35] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_36) begin
          dataLogic_maskBuffer[36] <= io_input_w_payload_strb[4];
        end
        if(when_Axi4Upsizer_l59_37) begin
          dataLogic_maskBuffer[37] <= io_input_w_payload_strb[5];
        end
        if(when_Axi4Upsizer_l59_38) begin
          dataLogic_maskBuffer[38] <= io_input_w_payload_strb[6];
        end
        if(when_Axi4Upsizer_l59_39) begin
          dataLogic_maskBuffer[39] <= io_input_w_payload_strb[7];
        end
        if(when_Axi4Upsizer_l59_40) begin
          dataLogic_maskBuffer[40] <= io_input_w_payload_strb[8];
        end
        if(when_Axi4Upsizer_l59_41) begin
          dataLogic_maskBuffer[41] <= io_input_w_payload_strb[9];
        end
        if(when_Axi4Upsizer_l59_42) begin
          dataLogic_maskBuffer[42] <= io_input_w_payload_strb[10];
        end
        if(when_Axi4Upsizer_l59_43) begin
          dataLogic_maskBuffer[43] <= io_input_w_payload_strb[11];
        end
        if(when_Axi4Upsizer_l59_44) begin
          dataLogic_maskBuffer[44] <= io_input_w_payload_strb[12];
        end
        if(when_Axi4Upsizer_l59_45) begin
          dataLogic_maskBuffer[45] <= io_input_w_payload_strb[13];
        end
        if(when_Axi4Upsizer_l59_46) begin
          dataLogic_maskBuffer[46] <= io_input_w_payload_strb[14];
        end
        if(when_Axi4Upsizer_l59_47) begin
          dataLogic_maskBuffer[47] <= io_input_w_payload_strb[15];
        end
        if(when_Axi4Upsizer_l59_48) begin
          dataLogic_maskBuffer[48] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_49) begin
          dataLogic_maskBuffer[49] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_50) begin
          dataLogic_maskBuffer[50] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_51) begin
          dataLogic_maskBuffer[51] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_52) begin
          dataLogic_maskBuffer[52] <= io_input_w_payload_strb[4];
        end
        if(when_Axi4Upsizer_l59_53) begin
          dataLogic_maskBuffer[53] <= io_input_w_payload_strb[5];
        end
        if(when_Axi4Upsizer_l59_54) begin
          dataLogic_maskBuffer[54] <= io_input_w_payload_strb[6];
        end
        if(when_Axi4Upsizer_l59_55) begin
          dataLogic_maskBuffer[55] <= io_input_w_payload_strb[7];
        end
        if(when_Axi4Upsizer_l59_56) begin
          dataLogic_maskBuffer[56] <= io_input_w_payload_strb[8];
        end
        if(when_Axi4Upsizer_l59_57) begin
          dataLogic_maskBuffer[57] <= io_input_w_payload_strb[9];
        end
        if(when_Axi4Upsizer_l59_58) begin
          dataLogic_maskBuffer[58] <= io_input_w_payload_strb[10];
        end
        if(when_Axi4Upsizer_l59_59) begin
          dataLogic_maskBuffer[59] <= io_input_w_payload_strb[11];
        end
        if(when_Axi4Upsizer_l59_60) begin
          dataLogic_maskBuffer[60] <= io_input_w_payload_strb[12];
        end
        if(when_Axi4Upsizer_l59_61) begin
          dataLogic_maskBuffer[61] <= io_input_w_payload_strb[13];
        end
        if(when_Axi4Upsizer_l59_62) begin
          dataLogic_maskBuffer[62] <= io_input_w_payload_strb[14];
        end
        if(when_Axi4Upsizer_l59_63) begin
          dataLogic_maskBuffer[63] <= io_input_w_payload_strb[15];
        end
      end
      if(cmdLogic_dataFork_fire_1) begin
        dataLogic_busy <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_w_fire) begin
      if(dataLogic_incrementByteCounter) begin
        dataLogic_byteCounter <= dataLogic_byteCounterNext[5:0];
      end
      dataLogic_outputLast <= io_input_w_payload_last;
      if(when_Axi4Upsizer_l59) begin
        dataLogic_dataBuffer[7 : 0] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_1) begin
        dataLogic_dataBuffer[15 : 8] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_2) begin
        dataLogic_dataBuffer[23 : 16] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_3) begin
        dataLogic_dataBuffer[31 : 24] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_4) begin
        dataLogic_dataBuffer[39 : 32] <= io_input_w_payload_data[39 : 32];
      end
      if(when_Axi4Upsizer_l59_5) begin
        dataLogic_dataBuffer[47 : 40] <= io_input_w_payload_data[47 : 40];
      end
      if(when_Axi4Upsizer_l59_6) begin
        dataLogic_dataBuffer[55 : 48] <= io_input_w_payload_data[55 : 48];
      end
      if(when_Axi4Upsizer_l59_7) begin
        dataLogic_dataBuffer[63 : 56] <= io_input_w_payload_data[63 : 56];
      end
      if(when_Axi4Upsizer_l59_8) begin
        dataLogic_dataBuffer[71 : 64] <= io_input_w_payload_data[71 : 64];
      end
      if(when_Axi4Upsizer_l59_9) begin
        dataLogic_dataBuffer[79 : 72] <= io_input_w_payload_data[79 : 72];
      end
      if(when_Axi4Upsizer_l59_10) begin
        dataLogic_dataBuffer[87 : 80] <= io_input_w_payload_data[87 : 80];
      end
      if(when_Axi4Upsizer_l59_11) begin
        dataLogic_dataBuffer[95 : 88] <= io_input_w_payload_data[95 : 88];
      end
      if(when_Axi4Upsizer_l59_12) begin
        dataLogic_dataBuffer[103 : 96] <= io_input_w_payload_data[103 : 96];
      end
      if(when_Axi4Upsizer_l59_13) begin
        dataLogic_dataBuffer[111 : 104] <= io_input_w_payload_data[111 : 104];
      end
      if(when_Axi4Upsizer_l59_14) begin
        dataLogic_dataBuffer[119 : 112] <= io_input_w_payload_data[119 : 112];
      end
      if(when_Axi4Upsizer_l59_15) begin
        dataLogic_dataBuffer[127 : 120] <= io_input_w_payload_data[127 : 120];
      end
      if(when_Axi4Upsizer_l59_16) begin
        dataLogic_dataBuffer[135 : 128] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_17) begin
        dataLogic_dataBuffer[143 : 136] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_18) begin
        dataLogic_dataBuffer[151 : 144] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_19) begin
        dataLogic_dataBuffer[159 : 152] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_20) begin
        dataLogic_dataBuffer[167 : 160] <= io_input_w_payload_data[39 : 32];
      end
      if(when_Axi4Upsizer_l59_21) begin
        dataLogic_dataBuffer[175 : 168] <= io_input_w_payload_data[47 : 40];
      end
      if(when_Axi4Upsizer_l59_22) begin
        dataLogic_dataBuffer[183 : 176] <= io_input_w_payload_data[55 : 48];
      end
      if(when_Axi4Upsizer_l59_23) begin
        dataLogic_dataBuffer[191 : 184] <= io_input_w_payload_data[63 : 56];
      end
      if(when_Axi4Upsizer_l59_24) begin
        dataLogic_dataBuffer[199 : 192] <= io_input_w_payload_data[71 : 64];
      end
      if(when_Axi4Upsizer_l59_25) begin
        dataLogic_dataBuffer[207 : 200] <= io_input_w_payload_data[79 : 72];
      end
      if(when_Axi4Upsizer_l59_26) begin
        dataLogic_dataBuffer[215 : 208] <= io_input_w_payload_data[87 : 80];
      end
      if(when_Axi4Upsizer_l59_27) begin
        dataLogic_dataBuffer[223 : 216] <= io_input_w_payload_data[95 : 88];
      end
      if(when_Axi4Upsizer_l59_28) begin
        dataLogic_dataBuffer[231 : 224] <= io_input_w_payload_data[103 : 96];
      end
      if(when_Axi4Upsizer_l59_29) begin
        dataLogic_dataBuffer[239 : 232] <= io_input_w_payload_data[111 : 104];
      end
      if(when_Axi4Upsizer_l59_30) begin
        dataLogic_dataBuffer[247 : 240] <= io_input_w_payload_data[119 : 112];
      end
      if(when_Axi4Upsizer_l59_31) begin
        dataLogic_dataBuffer[255 : 248] <= io_input_w_payload_data[127 : 120];
      end
      if(when_Axi4Upsizer_l59_32) begin
        dataLogic_dataBuffer[263 : 256] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_33) begin
        dataLogic_dataBuffer[271 : 264] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_34) begin
        dataLogic_dataBuffer[279 : 272] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_35) begin
        dataLogic_dataBuffer[287 : 280] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_36) begin
        dataLogic_dataBuffer[295 : 288] <= io_input_w_payload_data[39 : 32];
      end
      if(when_Axi4Upsizer_l59_37) begin
        dataLogic_dataBuffer[303 : 296] <= io_input_w_payload_data[47 : 40];
      end
      if(when_Axi4Upsizer_l59_38) begin
        dataLogic_dataBuffer[311 : 304] <= io_input_w_payload_data[55 : 48];
      end
      if(when_Axi4Upsizer_l59_39) begin
        dataLogic_dataBuffer[319 : 312] <= io_input_w_payload_data[63 : 56];
      end
      if(when_Axi4Upsizer_l59_40) begin
        dataLogic_dataBuffer[327 : 320] <= io_input_w_payload_data[71 : 64];
      end
      if(when_Axi4Upsizer_l59_41) begin
        dataLogic_dataBuffer[335 : 328] <= io_input_w_payload_data[79 : 72];
      end
      if(when_Axi4Upsizer_l59_42) begin
        dataLogic_dataBuffer[343 : 336] <= io_input_w_payload_data[87 : 80];
      end
      if(when_Axi4Upsizer_l59_43) begin
        dataLogic_dataBuffer[351 : 344] <= io_input_w_payload_data[95 : 88];
      end
      if(when_Axi4Upsizer_l59_44) begin
        dataLogic_dataBuffer[359 : 352] <= io_input_w_payload_data[103 : 96];
      end
      if(when_Axi4Upsizer_l59_45) begin
        dataLogic_dataBuffer[367 : 360] <= io_input_w_payload_data[111 : 104];
      end
      if(when_Axi4Upsizer_l59_46) begin
        dataLogic_dataBuffer[375 : 368] <= io_input_w_payload_data[119 : 112];
      end
      if(when_Axi4Upsizer_l59_47) begin
        dataLogic_dataBuffer[383 : 376] <= io_input_w_payload_data[127 : 120];
      end
      if(when_Axi4Upsizer_l59_48) begin
        dataLogic_dataBuffer[391 : 384] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_49) begin
        dataLogic_dataBuffer[399 : 392] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_50) begin
        dataLogic_dataBuffer[407 : 400] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_51) begin
        dataLogic_dataBuffer[415 : 408] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_52) begin
        dataLogic_dataBuffer[423 : 416] <= io_input_w_payload_data[39 : 32];
      end
      if(when_Axi4Upsizer_l59_53) begin
        dataLogic_dataBuffer[431 : 424] <= io_input_w_payload_data[47 : 40];
      end
      if(when_Axi4Upsizer_l59_54) begin
        dataLogic_dataBuffer[439 : 432] <= io_input_w_payload_data[55 : 48];
      end
      if(when_Axi4Upsizer_l59_55) begin
        dataLogic_dataBuffer[447 : 440] <= io_input_w_payload_data[63 : 56];
      end
      if(when_Axi4Upsizer_l59_56) begin
        dataLogic_dataBuffer[455 : 448] <= io_input_w_payload_data[71 : 64];
      end
      if(when_Axi4Upsizer_l59_57) begin
        dataLogic_dataBuffer[463 : 456] <= io_input_w_payload_data[79 : 72];
      end
      if(when_Axi4Upsizer_l59_58) begin
        dataLogic_dataBuffer[471 : 464] <= io_input_w_payload_data[87 : 80];
      end
      if(when_Axi4Upsizer_l59_59) begin
        dataLogic_dataBuffer[479 : 472] <= io_input_w_payload_data[95 : 88];
      end
      if(when_Axi4Upsizer_l59_60) begin
        dataLogic_dataBuffer[487 : 480] <= io_input_w_payload_data[103 : 96];
      end
      if(when_Axi4Upsizer_l59_61) begin
        dataLogic_dataBuffer[495 : 488] <= io_input_w_payload_data[111 : 104];
      end
      if(when_Axi4Upsizer_l59_62) begin
        dataLogic_dataBuffer[503 : 496] <= io_input_w_payload_data[119 : 112];
      end
      if(when_Axi4Upsizer_l59_63) begin
        dataLogic_dataBuffer[511 : 504] <= io_input_w_payload_data[127 : 120];
      end
    end
    if(cmdLogic_dataFork_fire_1) begin
      dataLogic_byteCounter <= cmdLogic_dataFork_payload_addr[5:0];
      if(when_Axi4Upsizer_l68) begin
        dataLogic_byteCounter[0] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_1) begin
        dataLogic_byteCounter[1] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_2) begin
        dataLogic_byteCounter[2] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_3) begin
        dataLogic_byteCounter[3] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_4) begin
        dataLogic_byteCounter[4] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_5) begin
        dataLogic_byteCounter[5] <= 1'b0;
      end
      dataLogic_size <= cmdLogic_dataFork_payload_size;
      dataLogic_alwaysFire <= (! (cmdLogic_dataFork_payload_burst == 2'b01));
      dataLogic_incrementByteCounter <= (! (cmdLogic_dataFork_payload_burst == 2'b00));
    end
  end


endmodule

module Asic128To512UpsizerAxi4ReadOnlyUpsizer (
  input               io_input_ar_valid,
  output reg          io_input_ar_ready,
  input      [31:0]   io_input_ar_payload_addr,
  input      [7:0]    io_input_ar_payload_id,
  input      [3:0]    io_input_ar_payload_region,
  input      [7:0]    io_input_ar_payload_len,
  input      [2:0]    io_input_ar_payload_size,
  input      [1:0]    io_input_ar_payload_burst,
  input      [0:0]    io_input_ar_payload_lock,
  input      [3:0]    io_input_ar_payload_cache,
  input      [3:0]    io_input_ar_payload_qos,
  input      [2:0]    io_input_ar_payload_prot,
  output              io_input_r_valid,
  input               io_input_r_ready,
  output     [127:0]  io_input_r_payload_data,
  output     [7:0]    io_input_r_payload_id,
  output     [1:0]    io_input_r_payload_resp,
  output              io_input_r_payload_last,
  output              io_output_ar_valid,
  input               io_output_ar_ready,
  output     [31:0]   io_output_ar_payload_addr,
  output     [7:0]    io_output_ar_payload_id,
  output     [3:0]    io_output_ar_payload_region,
  output     [7:0]    io_output_ar_payload_len,
  output reg [2:0]    io_output_ar_payload_size,
  output     [1:0]    io_output_ar_payload_burst,
  output     [0:0]    io_output_ar_payload_lock,
  output     [3:0]    io_output_ar_payload_cache,
  output     [3:0]    io_output_ar_payload_qos,
  output     [2:0]    io_output_ar_payload_prot,
  input               io_output_r_valid,
  output              io_output_r_ready,
  input      [511:0]  io_output_r_payload_data,
  input      [7:0]    io_output_r_payload_id,
  input      [1:0]    io_output_r_payload_resp,
  input               io_output_r_payload_last,
  input               clk,
  input               reset
);

  wire                dataLogic_cmdPush_fifo_io_pop_ready;
  wire                dataLogic_cmdPush_fifo_io_push_ready;
  wire                dataLogic_cmdPush_fifo_io_pop_valid;
  wire       [5:0]    dataLogic_cmdPush_fifo_io_pop_payload_startAt;
  wire       [5:0]    dataLogic_cmdPush_fifo_io_pop_payload_endAt;
  wire       [2:0]    dataLogic_cmdPush_fifo_io_pop_payload_size;
  wire       [7:0]    dataLogic_cmdPush_fifo_io_pop_payload_id;
  wire       [4:0]    dataLogic_cmdPush_fifo_io_occupancy;
  wire       [4:0]    dataLogic_cmdPush_fifo_io_availability;
  wire       [14:0]   _zz_cmdLogic_byteCount;
  wire       [12:0]   _zz_cmdLogic_incrLen;
  wire       [12:0]   _zz_cmdLogic_incrLen_1;
  wire       [5:0]    _zz_cmdLogic_incrLen_2;
  wire       [31:0]   _zz_dataLogic_cmdPush_payload_endAt;
  wire       [31:0]   _zz_dataLogic_cmdPush_payload_endAt_1;
  wire       [14:0]   _zz_dataLogic_cmdPush_payload_endAt_2;
  wire       [6:0]    _zz_dataLogic_byteCounterNext;
  wire       [7:0]    _zz_dataLogic_byteCounterNext_1;
  reg        [127:0]  _zz_io_input_r_payload_data;
  wire       [1:0]    _zz_io_input_r_payload_data_1;
  wire                cmdLogic_outputFork_valid;
  wire                cmdLogic_outputFork_ready;
  wire       [31:0]   cmdLogic_outputFork_payload_addr;
  wire       [7:0]    cmdLogic_outputFork_payload_id;
  wire       [3:0]    cmdLogic_outputFork_payload_region;
  wire       [7:0]    cmdLogic_outputFork_payload_len;
  wire       [2:0]    cmdLogic_outputFork_payload_size;
  wire       [1:0]    cmdLogic_outputFork_payload_burst;
  wire       [0:0]    cmdLogic_outputFork_payload_lock;
  wire       [3:0]    cmdLogic_outputFork_payload_cache;
  wire       [3:0]    cmdLogic_outputFork_payload_qos;
  wire       [2:0]    cmdLogic_outputFork_payload_prot;
  wire                cmdLogic_dataFork_valid;
  wire                cmdLogic_dataFork_ready;
  wire       [31:0]   cmdLogic_dataFork_payload_addr;
  wire       [7:0]    cmdLogic_dataFork_payload_id;
  wire       [3:0]    cmdLogic_dataFork_payload_region;
  wire       [7:0]    cmdLogic_dataFork_payload_len;
  wire       [2:0]    cmdLogic_dataFork_payload_size;
  wire       [1:0]    cmdLogic_dataFork_payload_burst;
  wire       [0:0]    cmdLogic_dataFork_payload_lock;
  wire       [3:0]    cmdLogic_dataFork_payload_cache;
  wire       [3:0]    cmdLogic_dataFork_payload_qos;
  wire       [2:0]    cmdLogic_dataFork_payload_prot;
  reg                 io_input_ar_fork2_logic_linkEnable_0;
  reg                 io_input_ar_fork2_logic_linkEnable_1;
  wire                when_Stream_l993;
  wire                when_Stream_l993_1;
  wire                cmdLogic_outputFork_fire;
  wire                cmdLogic_dataFork_fire;
  wire       [11:0]   cmdLogic_byteCount;
  wire       [6:0]    cmdLogic_incrLen;
  wire                when_Axi4Upsizer_l108;
  wire                dataLogic_cmdPush_valid;
  wire                dataLogic_cmdPush_ready;
  wire       [5:0]    dataLogic_cmdPush_payload_startAt;
  wire       [5:0]    dataLogic_cmdPush_payload_endAt;
  wire       [2:0]    dataLogic_cmdPush_payload_size;
  wire       [7:0]    dataLogic_cmdPush_payload_id;
  reg        [2:0]    dataLogic_size;
  reg                 dataLogic_busy;
  reg        [7:0]    dataLogic_id;
  reg        [5:0]    dataLogic_byteCounter;
  reg        [5:0]    dataLogic_byteCounterLast;
  wire       [6:0]    dataLogic_byteCounterNext;
  wire                readOnly_dataLogic_cmdPush_fifo_io_pop_fire;
  wire                io_input_r_fire;

  assign _zz_cmdLogic_byteCount = ({7'd0,io_input_ar_payload_len} <<< io_input_ar_payload_size);
  assign _zz_cmdLogic_incrLen = ({1'b0,cmdLogic_byteCount} + _zz_cmdLogic_incrLen_1);
  assign _zz_cmdLogic_incrLen_2 = io_input_ar_payload_addr[5 : 0];
  assign _zz_cmdLogic_incrLen_1 = {7'd0, _zz_cmdLogic_incrLen_2};
  assign _zz_dataLogic_cmdPush_payload_endAt = (cmdLogic_dataFork_payload_addr + _zz_dataLogic_cmdPush_payload_endAt_1);
  assign _zz_dataLogic_cmdPush_payload_endAt_2 = ({7'd0,cmdLogic_dataFork_payload_len} <<< cmdLogic_dataFork_payload_size);
  assign _zz_dataLogic_cmdPush_payload_endAt_1 = {17'd0, _zz_dataLogic_cmdPush_payload_endAt_2};
  assign _zz_dataLogic_byteCounterNext_1 = ({7'd0,1'b1} <<< dataLogic_size);
  assign _zz_dataLogic_byteCounterNext = _zz_dataLogic_byteCounterNext_1[6:0];
  assign _zz_io_input_r_payload_data_1 = (dataLogic_byteCounter >>> 3'd4);
  Asic128To512UpsizerStreamFifo dataLogic_cmdPush_fifo (
    .io_push_valid           (dataLogic_cmdPush_valid                           ), //i
    .io_push_ready           (dataLogic_cmdPush_fifo_io_push_ready              ), //o
    .io_push_payload_startAt (dataLogic_cmdPush_payload_startAt[5:0]            ), //i
    .io_push_payload_endAt   (dataLogic_cmdPush_payload_endAt[5:0]              ), //i
    .io_push_payload_size    (dataLogic_cmdPush_payload_size[2:0]               ), //i
    .io_push_payload_id      (dataLogic_cmdPush_payload_id[7:0]                 ), //i
    .io_pop_valid            (dataLogic_cmdPush_fifo_io_pop_valid               ), //o
    .io_pop_ready            (dataLogic_cmdPush_fifo_io_pop_ready               ), //i
    .io_pop_payload_startAt  (dataLogic_cmdPush_fifo_io_pop_payload_startAt[5:0]), //o
    .io_pop_payload_endAt    (dataLogic_cmdPush_fifo_io_pop_payload_endAt[5:0]  ), //o
    .io_pop_payload_size     (dataLogic_cmdPush_fifo_io_pop_payload_size[2:0]   ), //o
    .io_pop_payload_id       (dataLogic_cmdPush_fifo_io_pop_payload_id[7:0]     ), //o
    .io_flush                (1'b0                                              ), //i
    .io_occupancy            (dataLogic_cmdPush_fifo_io_occupancy[4:0]          ), //o
    .io_availability         (dataLogic_cmdPush_fifo_io_availability[4:0]       ), //o
    .clk                     (clk                                               ), //i
    .reset                   (reset                                             )  //i
  );
  always @(*) begin
    case(_zz_io_input_r_payload_data_1)
      2'b00 : _zz_io_input_r_payload_data = io_output_r_payload_data[127 : 0];
      2'b01 : _zz_io_input_r_payload_data = io_output_r_payload_data[255 : 128];
      2'b10 : _zz_io_input_r_payload_data = io_output_r_payload_data[383 : 256];
      default : _zz_io_input_r_payload_data = io_output_r_payload_data[511 : 384];
    endcase
  end

  always @(*) begin
    io_input_ar_ready = 1'b1;
    if(when_Stream_l993) begin
      io_input_ar_ready = 1'b0;
    end
    if(when_Stream_l993_1) begin
      io_input_ar_ready = 1'b0;
    end
  end

  assign when_Stream_l993 = ((! cmdLogic_outputFork_ready) && io_input_ar_fork2_logic_linkEnable_0);
  assign when_Stream_l993_1 = ((! cmdLogic_dataFork_ready) && io_input_ar_fork2_logic_linkEnable_1);
  assign cmdLogic_outputFork_valid = (io_input_ar_valid && io_input_ar_fork2_logic_linkEnable_0);
  assign cmdLogic_outputFork_payload_addr = io_input_ar_payload_addr;
  assign cmdLogic_outputFork_payload_id = io_input_ar_payload_id;
  assign cmdLogic_outputFork_payload_region = io_input_ar_payload_region;
  assign cmdLogic_outputFork_payload_len = io_input_ar_payload_len;
  assign cmdLogic_outputFork_payload_size = io_input_ar_payload_size;
  assign cmdLogic_outputFork_payload_burst = io_input_ar_payload_burst;
  assign cmdLogic_outputFork_payload_lock = io_input_ar_payload_lock;
  assign cmdLogic_outputFork_payload_cache = io_input_ar_payload_cache;
  assign cmdLogic_outputFork_payload_qos = io_input_ar_payload_qos;
  assign cmdLogic_outputFork_payload_prot = io_input_ar_payload_prot;
  assign cmdLogic_outputFork_fire = (cmdLogic_outputFork_valid && cmdLogic_outputFork_ready);
  assign cmdLogic_dataFork_valid = (io_input_ar_valid && io_input_ar_fork2_logic_linkEnable_1);
  assign cmdLogic_dataFork_payload_addr = io_input_ar_payload_addr;
  assign cmdLogic_dataFork_payload_id = io_input_ar_payload_id;
  assign cmdLogic_dataFork_payload_region = io_input_ar_payload_region;
  assign cmdLogic_dataFork_payload_len = io_input_ar_payload_len;
  assign cmdLogic_dataFork_payload_size = io_input_ar_payload_size;
  assign cmdLogic_dataFork_payload_burst = io_input_ar_payload_burst;
  assign cmdLogic_dataFork_payload_lock = io_input_ar_payload_lock;
  assign cmdLogic_dataFork_payload_cache = io_input_ar_payload_cache;
  assign cmdLogic_dataFork_payload_qos = io_input_ar_payload_qos;
  assign cmdLogic_dataFork_payload_prot = io_input_ar_payload_prot;
  assign cmdLogic_dataFork_fire = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign io_output_ar_valid = cmdLogic_outputFork_valid;
  assign cmdLogic_outputFork_ready = io_output_ar_ready;
  assign io_output_ar_payload_addr = cmdLogic_outputFork_payload_addr;
  assign io_output_ar_payload_region = cmdLogic_outputFork_payload_region;
  assign io_output_ar_payload_burst = cmdLogic_outputFork_payload_burst;
  assign io_output_ar_payload_lock = cmdLogic_outputFork_payload_lock;
  assign io_output_ar_payload_cache = cmdLogic_outputFork_payload_cache;
  assign io_output_ar_payload_qos = cmdLogic_outputFork_payload_qos;
  assign io_output_ar_payload_prot = cmdLogic_outputFork_payload_prot;
  assign cmdLogic_byteCount = _zz_cmdLogic_byteCount[11:0];
  assign cmdLogic_incrLen = _zz_cmdLogic_incrLen[12 : 6];
  always @(*) begin
    io_output_ar_payload_size = 3'b110;
    if(when_Axi4Upsizer_l108) begin
      io_output_ar_payload_size = io_input_ar_payload_size;
    end
  end

  assign io_output_ar_payload_len = {1'd0, cmdLogic_incrLen};
  assign io_output_ar_payload_id = 8'h00;
  assign when_Axi4Upsizer_l108 = (io_input_ar_payload_len == 8'h00);
  assign dataLogic_cmdPush_valid = cmdLogic_dataFork_valid;
  assign cmdLogic_dataFork_ready = dataLogic_cmdPush_ready;
  assign dataLogic_cmdPush_payload_startAt = cmdLogic_dataFork_payload_addr[5:0];
  assign dataLogic_cmdPush_payload_endAt = _zz_dataLogic_cmdPush_payload_endAt[5:0];
  assign dataLogic_cmdPush_payload_size = cmdLogic_dataFork_payload_size;
  assign dataLogic_cmdPush_payload_id = cmdLogic_dataFork_payload_id;
  assign dataLogic_cmdPush_ready = dataLogic_cmdPush_fifo_io_push_ready;
  assign dataLogic_byteCounterNext = ({1'b0,dataLogic_byteCounter} + _zz_dataLogic_byteCounterNext);
  assign readOnly_dataLogic_cmdPush_fifo_io_pop_fire = (dataLogic_cmdPush_fifo_io_pop_valid && dataLogic_cmdPush_fifo_io_pop_ready);
  assign dataLogic_cmdPush_fifo_io_pop_ready = (! dataLogic_busy);
  assign io_input_r_fire = (io_input_r_valid && io_input_r_ready);
  assign io_input_r_valid = (io_output_r_valid && dataLogic_busy);
  assign io_input_r_payload_last = (io_output_r_payload_last && (dataLogic_byteCounter == dataLogic_byteCounterLast));
  assign io_input_r_payload_resp = io_output_r_payload_resp;
  assign io_input_r_payload_data = _zz_io_input_r_payload_data;
  assign io_input_r_payload_id = dataLogic_id;
  assign io_output_r_ready = ((dataLogic_busy && io_input_r_ready) && (io_input_r_payload_last || dataLogic_byteCounterNext[6]));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_ar_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_ar_fork2_logic_linkEnable_1 <= 1'b1;
      dataLogic_busy <= 1'b0;
    end else begin
      if(cmdLogic_outputFork_fire) begin
        io_input_ar_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdLogic_dataFork_fire) begin
        io_input_ar_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_ar_ready) begin
        io_input_ar_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_ar_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(readOnly_dataLogic_cmdPush_fifo_io_pop_fire) begin
        dataLogic_busy <= 1'b1;
      end
      if(io_input_r_fire) begin
        if(io_input_r_payload_last) begin
          dataLogic_busy <= 1'b0;
        end
      end
    end
  end

  always @(posedge clk) begin
    if(readOnly_dataLogic_cmdPush_fifo_io_pop_fire) begin
      dataLogic_byteCounter <= dataLogic_cmdPush_fifo_io_pop_payload_startAt;
      dataLogic_byteCounterLast <= dataLogic_cmdPush_fifo_io_pop_payload_endAt;
      dataLogic_size <= dataLogic_cmdPush_fifo_io_pop_payload_size;
      dataLogic_id <= dataLogic_cmdPush_fifo_io_pop_payload_id;
    end
    if(io_input_r_fire) begin
      dataLogic_byteCounter <= dataLogic_byteCounterNext[5:0];
    end
  end


endmodule

module Asic128To512UpsizerStreamFifo (
  input               io_push_valid,
  output              io_push_ready,
  input      [5:0]    io_push_payload_startAt,
  input      [5:0]    io_push_payload_endAt,
  input      [2:0]    io_push_payload_size,
  input      [7:0]    io_push_payload_id,
  output              io_pop_valid,
  input               io_pop_ready,
  output     [5:0]    io_pop_payload_startAt,
  output     [5:0]    io_pop_payload_endAt,
  output     [2:0]    io_pop_payload_size,
  output     [7:0]    io_pop_payload_id,
  input               io_flush,
  output     [4:0]    io_occupancy,
  output     [4:0]    io_availability,
  input               clk,
  input               reset
);

  reg        [22:0]   _zz_logic_ram_port0;
  wire       [3:0]    _zz_logic_pushPtr_valueNext;
  wire       [0:0]    _zz_logic_pushPtr_valueNext_1;
  wire       [3:0]    _zz_logic_popPtr_valueNext;
  wire       [0:0]    _zz_logic_popPtr_valueNext_1;
  wire                _zz__zz_logic_ram_port0;
  wire                _zz__zz_io_pop_payload_startAt;
  wire       [22:0]   _zz__zz_logic_ram_port1;
  wire       [3:0]    _zz_io_availability;
  reg                 _zz_1;
  reg                 logic_pushPtr_willIncrement;
  reg                 logic_pushPtr_willClear;
  reg        [3:0]    logic_pushPtr_valueNext;
  reg        [3:0]    logic_pushPtr_value;
  wire                logic_pushPtr_willOverflowIfInc;
  wire                logic_pushPtr_willOverflow;
  reg                 logic_popPtr_willIncrement;
  reg                 logic_popPtr_willClear;
  reg        [3:0]    logic_popPtr_valueNext;
  reg        [3:0]    logic_popPtr_value;
  wire                logic_popPtr_willOverflowIfInc;
  wire                logic_popPtr_willOverflow;
  wire                logic_ptrMatch;
  reg                 logic_risingOccupancy;
  wire                logic_pushing;
  wire                logic_popping;
  wire                logic_empty;
  wire                logic_full;
  reg                 _zz_io_pop_valid;
  wire       [22:0]   _zz_io_pop_payload_startAt;
  wire                when_Stream_l1123;
  wire       [3:0]    logic_ptrDif;
  reg [22:0] logic_ram [0:15];

  assign _zz_logic_pushPtr_valueNext_1 = logic_pushPtr_willIncrement;
  assign _zz_logic_pushPtr_valueNext = {3'd0, _zz_logic_pushPtr_valueNext_1};
  assign _zz_logic_popPtr_valueNext_1 = logic_popPtr_willIncrement;
  assign _zz_logic_popPtr_valueNext = {3'd0, _zz_logic_popPtr_valueNext_1};
  assign _zz_io_availability = (logic_popPtr_value - logic_pushPtr_value);
  assign _zz__zz_io_pop_payload_startAt = 1'b1;
  assign _zz__zz_logic_ram_port1 = {io_push_payload_id,{io_push_payload_size,{io_push_payload_endAt,io_push_payload_startAt}}};
  always @(posedge clk) begin
    if(_zz__zz_io_pop_payload_startAt) begin
      _zz_logic_ram_port0 <= logic_ram[logic_popPtr_valueNext];
    end
  end

  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_pushPtr_value] <= _zz__zz_logic_ram_port1;
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_pushing) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willIncrement = 1'b0;
    if(logic_pushing) begin
      logic_pushPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_pushPtr_willClear = 1'b1;
    end
  end

  assign logic_pushPtr_willOverflowIfInc = (logic_pushPtr_value == 4'b1111);
  assign logic_pushPtr_willOverflow = (logic_pushPtr_willOverflowIfInc && logic_pushPtr_willIncrement);
  always @(*) begin
    logic_pushPtr_valueNext = (logic_pushPtr_value + _zz_logic_pushPtr_valueNext);
    if(logic_pushPtr_willClear) begin
      logic_pushPtr_valueNext = 4'b0000;
    end
  end

  always @(*) begin
    logic_popPtr_willIncrement = 1'b0;
    if(logic_popping) begin
      logic_popPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_popPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_popPtr_willClear = 1'b1;
    end
  end

  assign logic_popPtr_willOverflowIfInc = (logic_popPtr_value == 4'b1111);
  assign logic_popPtr_willOverflow = (logic_popPtr_willOverflowIfInc && logic_popPtr_willIncrement);
  always @(*) begin
    logic_popPtr_valueNext = (logic_popPtr_value + _zz_logic_popPtr_valueNext);
    if(logic_popPtr_willClear) begin
      logic_popPtr_valueNext = 4'b0000;
    end
  end

  assign logic_ptrMatch = (logic_pushPtr_value == logic_popPtr_value);
  assign logic_pushing = (io_push_valid && io_push_ready);
  assign logic_popping = (io_pop_valid && io_pop_ready);
  assign logic_empty = (logic_ptrMatch && (! logic_risingOccupancy));
  assign logic_full = (logic_ptrMatch && logic_risingOccupancy);
  assign io_push_ready = (! logic_full);
  assign io_pop_valid = ((! logic_empty) && (! (_zz_io_pop_valid && (! logic_full))));
  assign _zz_io_pop_payload_startAt = _zz_logic_ram_port0;
  assign io_pop_payload_startAt = _zz_io_pop_payload_startAt[5 : 0];
  assign io_pop_payload_endAt = _zz_io_pop_payload_startAt[11 : 6];
  assign io_pop_payload_size = _zz_io_pop_payload_startAt[14 : 12];
  assign io_pop_payload_id = _zz_io_pop_payload_startAt[22 : 15];
  assign when_Stream_l1123 = (logic_pushing != logic_popping);
  assign logic_ptrDif = (logic_pushPtr_value - logic_popPtr_value);
  assign io_occupancy = {(logic_risingOccupancy && logic_ptrMatch),logic_ptrDif};
  assign io_availability = {((! logic_risingOccupancy) && logic_ptrMatch),_zz_io_availability};
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      logic_pushPtr_value <= 4'b0000;
      logic_popPtr_value <= 4'b0000;
      logic_risingOccupancy <= 1'b0;
      _zz_io_pop_valid <= 1'b0;
    end else begin
      logic_pushPtr_value <= logic_pushPtr_valueNext;
      logic_popPtr_value <= logic_popPtr_valueNext;
      _zz_io_pop_valid <= (logic_popPtr_valueNext == logic_pushPtr_value);
      if(when_Stream_l1123) begin
        logic_risingOccupancy <= logic_pushing;
      end
      if(io_flush) begin
        logic_risingOccupancy <= 1'b0;
      end
    end
  end


endmodule


/////////////////////////////////////////////////////////////////////////////
// 256-to-512 bit AXI upsizer
/////////////////////////////////////////////////////////////////////////////
module Asic256To512UpsizerAxi4Upsizer (
  input               io_input_aw_valid,
  output              io_input_aw_ready,
  input      [31:0]   io_input_aw_payload_addr,
  input      [7:0]    io_input_aw_payload_id,
  input      [3:0]    io_input_aw_payload_region,
  input      [7:0]    io_input_aw_payload_len,
  input      [2:0]    io_input_aw_payload_size,
  input      [1:0]    io_input_aw_payload_burst,
  input      [0:0]    io_input_aw_payload_lock,
  input      [3:0]    io_input_aw_payload_cache,
  input      [3:0]    io_input_aw_payload_qos,
  input      [2:0]    io_input_aw_payload_prot,
  input               io_input_w_valid,
  output              io_input_w_ready,
  input      [255:0]  io_input_w_payload_data,
  input      [31:0]   io_input_w_payload_strb,
  input               io_input_w_payload_last,
  output              io_input_b_valid,
  input               io_input_b_ready,
  output     [7:0]    io_input_b_payload_id,
  output     [1:0]    io_input_b_payload_resp,
  input               io_input_ar_valid,
  output              io_input_ar_ready,
  input      [31:0]   io_input_ar_payload_addr,
  input      [7:0]    io_input_ar_payload_id,
  input      [3:0]    io_input_ar_payload_region,
  input      [7:0]    io_input_ar_payload_len,
  input      [2:0]    io_input_ar_payload_size,
  input      [1:0]    io_input_ar_payload_burst,
  input      [0:0]    io_input_ar_payload_lock,
  input      [3:0]    io_input_ar_payload_cache,
  input      [3:0]    io_input_ar_payload_qos,
  input      [2:0]    io_input_ar_payload_prot,
  output              io_input_r_valid,
  input               io_input_r_ready,
  output     [255:0]  io_input_r_payload_data,
  output     [7:0]    io_input_r_payload_id,
  output     [1:0]    io_input_r_payload_resp,
  output              io_input_r_payload_last,
  output              io_output_aw_valid,
  input               io_output_aw_ready,
  output     [31:0]   io_output_aw_payload_addr,
  output     [7:0]    io_output_aw_payload_id,
  output     [3:0]    io_output_aw_payload_region,
  output     [7:0]    io_output_aw_payload_len,
  output     [2:0]    io_output_aw_payload_size,
  output     [1:0]    io_output_aw_payload_burst,
  output     [0:0]    io_output_aw_payload_lock,
  output     [3:0]    io_output_aw_payload_cache,
  output     [3:0]    io_output_aw_payload_qos,
  output     [2:0]    io_output_aw_payload_prot,
  output              io_output_w_valid,
  input               io_output_w_ready,
  output     [511:0]  io_output_w_payload_data,
  output     [63:0]   io_output_w_payload_strb,
  output              io_output_w_payload_last,
  input               io_output_b_valid,
  output              io_output_b_ready,
  input      [7:0]    io_output_b_payload_id,
  input      [1:0]    io_output_b_payload_resp,
  output              io_output_ar_valid,
  input               io_output_ar_ready,
  output     [31:0]   io_output_ar_payload_addr,
  output     [7:0]    io_output_ar_payload_id,
  output     [3:0]    io_output_ar_payload_region,
  output     [7:0]    io_output_ar_payload_len,
  output     [2:0]    io_output_ar_payload_size,
  output     [1:0]    io_output_ar_payload_burst,
  output     [0:0]    io_output_ar_payload_lock,
  output     [3:0]    io_output_ar_payload_cache,
  output     [3:0]    io_output_ar_payload_qos,
  output     [2:0]    io_output_ar_payload_prot,
  input               io_output_r_valid,
  output              io_output_r_ready,
  input      [511:0]  io_output_r_payload_data,
  input      [7:0]    io_output_r_payload_id,
  input      [1:0]    io_output_r_payload_resp,
  input               io_output_r_payload_last,
  input               clk,
  input               reset
);

  wire                readOnly_io_input_ar_ready;
  wire                readOnly_io_input_r_valid;
  wire       [255:0]  readOnly_io_input_r_payload_data;
  wire       [7:0]    readOnly_io_input_r_payload_id;
  wire       [1:0]    readOnly_io_input_r_payload_resp;
  wire                readOnly_io_input_r_payload_last;
  wire                readOnly_io_output_ar_valid;
  wire       [31:0]   readOnly_io_output_ar_payload_addr;
  wire       [7:0]    readOnly_io_output_ar_payload_id;
  wire       [3:0]    readOnly_io_output_ar_payload_region;
  wire       [7:0]    readOnly_io_output_ar_payload_len;
  wire       [2:0]    readOnly_io_output_ar_payload_size;
  wire       [1:0]    readOnly_io_output_ar_payload_burst;
  wire       [0:0]    readOnly_io_output_ar_payload_lock;
  wire       [3:0]    readOnly_io_output_ar_payload_cache;
  wire       [3:0]    readOnly_io_output_ar_payload_qos;
  wire       [2:0]    readOnly_io_output_ar_payload_prot;
  wire                readOnly_io_output_r_ready;
  wire                writeOnly_io_input_aw_ready;
  wire                writeOnly_io_input_w_ready;
  wire                writeOnly_io_input_b_valid;
  wire       [7:0]    writeOnly_io_input_b_payload_id;
  wire       [1:0]    writeOnly_io_input_b_payload_resp;
  wire                writeOnly_io_output_aw_valid;
  wire       [31:0]   writeOnly_io_output_aw_payload_addr;
  wire       [7:0]    writeOnly_io_output_aw_payload_id;
  wire       [3:0]    writeOnly_io_output_aw_payload_region;
  wire       [7:0]    writeOnly_io_output_aw_payload_len;
  wire       [2:0]    writeOnly_io_output_aw_payload_size;
  wire       [1:0]    writeOnly_io_output_aw_payload_burst;
  wire       [0:0]    writeOnly_io_output_aw_payload_lock;
  wire       [3:0]    writeOnly_io_output_aw_payload_cache;
  wire       [3:0]    writeOnly_io_output_aw_payload_qos;
  wire       [2:0]    writeOnly_io_output_aw_payload_prot;
  wire                writeOnly_io_output_w_valid;
  wire       [511:0]  writeOnly_io_output_w_payload_data;
  wire       [63:0]   writeOnly_io_output_w_payload_strb;
  wire                writeOnly_io_output_w_payload_last;
  wire                writeOnly_io_output_b_ready;

  Asic256To512UpsizerAxi4ReadOnlyUpsizer readOnly (
    .io_input_ar_valid           (io_input_ar_valid                        ), //i
    .io_input_ar_ready           (readOnly_io_input_ar_ready               ), //o
    .io_input_ar_payload_addr    (io_input_ar_payload_addr[31:0]           ), //i
    .io_input_ar_payload_id      (io_input_ar_payload_id[7:0]              ), //i
    .io_input_ar_payload_region  (io_input_ar_payload_region[3:0]          ), //i
    .io_input_ar_payload_len     (io_input_ar_payload_len[7:0]             ), //i
    .io_input_ar_payload_size    (io_input_ar_payload_size[2:0]            ), //i
    .io_input_ar_payload_burst   (io_input_ar_payload_burst[1:0]           ), //i
    .io_input_ar_payload_lock    (io_input_ar_payload_lock                 ), //i
    .io_input_ar_payload_cache   (io_input_ar_payload_cache[3:0]           ), //i
    .io_input_ar_payload_qos     (io_input_ar_payload_qos[3:0]             ), //i
    .io_input_ar_payload_prot    (io_input_ar_payload_prot[2:0]            ), //i
    .io_input_r_valid            (readOnly_io_input_r_valid                ), //o
    .io_input_r_ready            (io_input_r_ready                         ), //i
    .io_input_r_payload_data     (readOnly_io_input_r_payload_data[255:0]  ), //o
    .io_input_r_payload_id       (readOnly_io_input_r_payload_id[7:0]      ), //o
    .io_input_r_payload_resp     (readOnly_io_input_r_payload_resp[1:0]    ), //o
    .io_input_r_payload_last     (readOnly_io_input_r_payload_last         ), //o
    .io_output_ar_valid          (readOnly_io_output_ar_valid              ), //o
    .io_output_ar_ready          (io_output_ar_ready                       ), //i
    .io_output_ar_payload_addr   (readOnly_io_output_ar_payload_addr[31:0] ), //o
    .io_output_ar_payload_id     (readOnly_io_output_ar_payload_id[7:0]    ), //o
    .io_output_ar_payload_region (readOnly_io_output_ar_payload_region[3:0]), //o
    .io_output_ar_payload_len    (readOnly_io_output_ar_payload_len[7:0]   ), //o
    .io_output_ar_payload_size   (readOnly_io_output_ar_payload_size[2:0]  ), //o
    .io_output_ar_payload_burst  (readOnly_io_output_ar_payload_burst[1:0] ), //o
    .io_output_ar_payload_lock   (readOnly_io_output_ar_payload_lock       ), //o
    .io_output_ar_payload_cache  (readOnly_io_output_ar_payload_cache[3:0] ), //o
    .io_output_ar_payload_qos    (readOnly_io_output_ar_payload_qos[3:0]   ), //o
    .io_output_ar_payload_prot   (readOnly_io_output_ar_payload_prot[2:0]  ), //o
    .io_output_r_valid           (io_output_r_valid                        ), //i
    .io_output_r_ready           (readOnly_io_output_r_ready               ), //o
    .io_output_r_payload_data    (io_output_r_payload_data[511:0]          ), //i
    .io_output_r_payload_id      (io_output_r_payload_id[7:0]              ), //i
    .io_output_r_payload_resp    (io_output_r_payload_resp[1:0]            ), //i
    .io_output_r_payload_last    (io_output_r_payload_last                 ), //i
    .clk                         (clk                                      ), //i
    .reset                       (reset                                    )  //i
  );
  Asic256To512UpsizerAxi4WriteOnlyUpsizer writeOnly (
    .io_input_aw_valid           (io_input_aw_valid                         ), //i
    .io_input_aw_ready           (writeOnly_io_input_aw_ready               ), //o
    .io_input_aw_payload_addr    (io_input_aw_payload_addr[31:0]            ), //i
    .io_input_aw_payload_id      (io_input_aw_payload_id[7:0]               ), //i
    .io_input_aw_payload_region  (io_input_aw_payload_region[3:0]           ), //i
    .io_input_aw_payload_len     (io_input_aw_payload_len[7:0]              ), //i
    .io_input_aw_payload_size    (io_input_aw_payload_size[2:0]             ), //i
    .io_input_aw_payload_burst   (io_input_aw_payload_burst[1:0]            ), //i
    .io_input_aw_payload_lock    (io_input_aw_payload_lock                  ), //i
    .io_input_aw_payload_cache   (io_input_aw_payload_cache[3:0]            ), //i
    .io_input_aw_payload_qos     (io_input_aw_payload_qos[3:0]              ), //i
    .io_input_aw_payload_prot    (io_input_aw_payload_prot[2:0]             ), //i
    .io_input_w_valid            (io_input_w_valid                          ), //i
    .io_input_w_ready            (writeOnly_io_input_w_ready                ), //o
    .io_input_w_payload_data     (io_input_w_payload_data[255:0]            ), //i
    .io_input_w_payload_strb     (io_input_w_payload_strb[31:0]             ), //i
    .io_input_w_payload_last     (io_input_w_payload_last                   ), //i
    .io_input_b_valid            (writeOnly_io_input_b_valid                ), //o
    .io_input_b_ready            (io_input_b_ready                          ), //i
    .io_input_b_payload_id       (writeOnly_io_input_b_payload_id[7:0]      ), //o
    .io_input_b_payload_resp     (writeOnly_io_input_b_payload_resp[1:0]    ), //o
    .io_output_aw_valid          (writeOnly_io_output_aw_valid              ), //o
    .io_output_aw_ready          (io_output_aw_ready                        ), //i
    .io_output_aw_payload_addr   (writeOnly_io_output_aw_payload_addr[31:0] ), //o
    .io_output_aw_payload_id     (writeOnly_io_output_aw_payload_id[7:0]    ), //o
    .io_output_aw_payload_region (writeOnly_io_output_aw_payload_region[3:0]), //o
    .io_output_aw_payload_len    (writeOnly_io_output_aw_payload_len[7:0]   ), //o
    .io_output_aw_payload_size   (writeOnly_io_output_aw_payload_size[2:0]  ), //o
    .io_output_aw_payload_burst  (writeOnly_io_output_aw_payload_burst[1:0] ), //o
    .io_output_aw_payload_lock   (writeOnly_io_output_aw_payload_lock       ), //o
    .io_output_aw_payload_cache  (writeOnly_io_output_aw_payload_cache[3:0] ), //o
    .io_output_aw_payload_qos    (writeOnly_io_output_aw_payload_qos[3:0]   ), //o
    .io_output_aw_payload_prot   (writeOnly_io_output_aw_payload_prot[2:0]  ), //o
    .io_output_w_valid           (writeOnly_io_output_w_valid               ), //o
    .io_output_w_ready           (io_output_w_ready                         ), //i
    .io_output_w_payload_data    (writeOnly_io_output_w_payload_data[511:0] ), //o
    .io_output_w_payload_strb    (writeOnly_io_output_w_payload_strb[63:0]  ), //o
    .io_output_w_payload_last    (writeOnly_io_output_w_payload_last        ), //o
    .io_output_b_valid           (io_output_b_valid                         ), //i
    .io_output_b_ready           (writeOnly_io_output_b_ready               ), //o
    .io_output_b_payload_id      (io_output_b_payload_id[7:0]               ), //i
    .io_output_b_payload_resp    (io_output_b_payload_resp[1:0]             ), //i
    .clk                         (clk                                       ), //i
    .reset                       (reset                                     )  //i
  );
  assign io_input_ar_ready = readOnly_io_input_ar_ready;
  assign io_input_r_valid = readOnly_io_input_r_valid;
  assign io_input_r_payload_data = readOnly_io_input_r_payload_data;
  assign io_input_r_payload_id = readOnly_io_input_r_payload_id;
  assign io_input_r_payload_resp = readOnly_io_input_r_payload_resp;
  assign io_input_r_payload_last = readOnly_io_input_r_payload_last;
  assign io_input_aw_ready = writeOnly_io_input_aw_ready;
  assign io_input_w_ready = writeOnly_io_input_w_ready;
  assign io_input_b_valid = writeOnly_io_input_b_valid;
  assign io_input_b_payload_id = writeOnly_io_input_b_payload_id;
  assign io_input_b_payload_resp = writeOnly_io_input_b_payload_resp;
  assign io_output_ar_valid = readOnly_io_output_ar_valid;
  assign io_output_ar_payload_addr = readOnly_io_output_ar_payload_addr;
  assign io_output_ar_payload_id = readOnly_io_output_ar_payload_id;
  assign io_output_ar_payload_region = readOnly_io_output_ar_payload_region;
  assign io_output_ar_payload_len = readOnly_io_output_ar_payload_len;
  assign io_output_ar_payload_size = readOnly_io_output_ar_payload_size;
  assign io_output_ar_payload_burst = readOnly_io_output_ar_payload_burst;
  assign io_output_ar_payload_lock = readOnly_io_output_ar_payload_lock;
  assign io_output_ar_payload_cache = readOnly_io_output_ar_payload_cache;
  assign io_output_ar_payload_qos = readOnly_io_output_ar_payload_qos;
  assign io_output_ar_payload_prot = readOnly_io_output_ar_payload_prot;
  assign io_output_r_ready = readOnly_io_output_r_ready;
  assign io_output_aw_valid = writeOnly_io_output_aw_valid;
  assign io_output_aw_payload_addr = writeOnly_io_output_aw_payload_addr;
  assign io_output_aw_payload_id = writeOnly_io_output_aw_payload_id;
  assign io_output_aw_payload_region = writeOnly_io_output_aw_payload_region;
  assign io_output_aw_payload_len = writeOnly_io_output_aw_payload_len;
  assign io_output_aw_payload_size = writeOnly_io_output_aw_payload_size;
  assign io_output_aw_payload_burst = writeOnly_io_output_aw_payload_burst;
  assign io_output_aw_payload_lock = writeOnly_io_output_aw_payload_lock;
  assign io_output_aw_payload_cache = writeOnly_io_output_aw_payload_cache;
  assign io_output_aw_payload_qos = writeOnly_io_output_aw_payload_qos;
  assign io_output_aw_payload_prot = writeOnly_io_output_aw_payload_prot;
  assign io_output_w_valid = writeOnly_io_output_w_valid;
  assign io_output_w_payload_data = writeOnly_io_output_w_payload_data;
  assign io_output_w_payload_strb = writeOnly_io_output_w_payload_strb;
  assign io_output_w_payload_last = writeOnly_io_output_w_payload_last;
  assign io_output_b_ready = writeOnly_io_output_b_ready;

endmodule

module Asic256To512UpsizerAxi4WriteOnlyUpsizer (
  input               io_input_aw_valid,
  output reg          io_input_aw_ready,
  input      [31:0]   io_input_aw_payload_addr,
  input      [7:0]    io_input_aw_payload_id,
  input      [3:0]    io_input_aw_payload_region,
  input      [7:0]    io_input_aw_payload_len,
  input      [2:0]    io_input_aw_payload_size,
  input      [1:0]    io_input_aw_payload_burst,
  input      [0:0]    io_input_aw_payload_lock,
  input      [3:0]    io_input_aw_payload_cache,
  input      [3:0]    io_input_aw_payload_qos,
  input      [2:0]    io_input_aw_payload_prot,
  input               io_input_w_valid,
  output              io_input_w_ready,
  input      [255:0]  io_input_w_payload_data,
  input      [31:0]   io_input_w_payload_strb,
  input               io_input_w_payload_last,
  output              io_input_b_valid,
  input               io_input_b_ready,
  output     [7:0]    io_input_b_payload_id,
  output     [1:0]    io_input_b_payload_resp,
  output              io_output_aw_valid,
  input               io_output_aw_ready,
  output     [31:0]   io_output_aw_payload_addr,
  output     [7:0]    io_output_aw_payload_id,
  output     [3:0]    io_output_aw_payload_region,
  output reg [7:0]    io_output_aw_payload_len,
  output reg [2:0]    io_output_aw_payload_size,
  output     [1:0]    io_output_aw_payload_burst,
  output     [0:0]    io_output_aw_payload_lock,
  output     [3:0]    io_output_aw_payload_cache,
  output     [3:0]    io_output_aw_payload_qos,
  output     [2:0]    io_output_aw_payload_prot,
  output              io_output_w_valid,
  input               io_output_w_ready,
  output     [511:0]  io_output_w_payload_data,
  output     [63:0]   io_output_w_payload_strb,
  output              io_output_w_payload_last,
  input               io_output_b_valid,
  output              io_output_b_ready,
  input      [7:0]    io_output_b_payload_id,
  input      [1:0]    io_output_b_payload_resp,
  input               clk,
  input               reset
);

  wire       [14:0]   _zz_cmdLogic_byteCount;
  wire       [13:0]   _zz_cmdLogic_incrLen;
  wire       [13:0]   _zz_cmdLogic_incrLen_1;
  wire       [5:0]    _zz_cmdLogic_incrLen_2;
  wire       [6:0]    _zz_dataLogic_byteCounterNext;
  wire       [7:0]    _zz_dataLogic_byteCounterNext_1;
  reg        [63:0]   _zz_dataLogic_byteActivity;
  wire                cmdLogic_outputFork_valid;
  wire                cmdLogic_outputFork_ready;
  wire       [31:0]   cmdLogic_outputFork_payload_addr;
  wire       [7:0]    cmdLogic_outputFork_payload_id;
  wire       [3:0]    cmdLogic_outputFork_payload_region;
  wire       [7:0]    cmdLogic_outputFork_payload_len;
  wire       [2:0]    cmdLogic_outputFork_payload_size;
  wire       [1:0]    cmdLogic_outputFork_payload_burst;
  wire       [0:0]    cmdLogic_outputFork_payload_lock;
  wire       [3:0]    cmdLogic_outputFork_payload_cache;
  wire       [3:0]    cmdLogic_outputFork_payload_qos;
  wire       [2:0]    cmdLogic_outputFork_payload_prot;
  wire                cmdLogic_dataFork_valid;
  wire                cmdLogic_dataFork_ready;
  wire       [31:0]   cmdLogic_dataFork_payload_addr;
  wire       [7:0]    cmdLogic_dataFork_payload_id;
  wire       [3:0]    cmdLogic_dataFork_payload_region;
  wire       [7:0]    cmdLogic_dataFork_payload_len;
  wire       [2:0]    cmdLogic_dataFork_payload_size;
  wire       [1:0]    cmdLogic_dataFork_payload_burst;
  wire       [0:0]    cmdLogic_dataFork_payload_lock;
  wire       [3:0]    cmdLogic_dataFork_payload_cache;
  wire       [3:0]    cmdLogic_dataFork_payload_qos;
  wire       [2:0]    cmdLogic_dataFork_payload_prot;
  reg                 io_input_aw_fork2_logic_linkEnable_0;
  reg                 io_input_aw_fork2_logic_linkEnable_1;
  wire                when_Stream_l993;
  wire                when_Stream_l993_1;
  wire                cmdLogic_outputFork_fire;
  wire                cmdLogic_dataFork_fire;
  wire       [12:0]   cmdLogic_byteCount;
  wire       [7:0]    cmdLogic_incrLen;
  wire                when_Axi4Upsizer_l21;
  wire                when_Axi4Upsizer_l24;
  reg        [5:0]    dataLogic_byteCounter;
  reg        [2:0]    dataLogic_size;
  reg                 dataLogic_outputValid;
  reg                 dataLogic_outputLast;
  reg                 dataLogic_busy;
  reg                 dataLogic_incrementByteCounter;
  reg                 dataLogic_alwaysFire;
  wire       [6:0]    dataLogic_byteCounterNext;
  reg        [511:0]  dataLogic_dataBuffer;
  reg        [63:0]   dataLogic_maskBuffer;
  wire       [63:0]   dataLogic_byteActivity;
  wire                io_output_w_fire;
  wire                io_output_w_isStall;
  wire                io_input_w_fire;
  wire                when_Axi4Upsizer_l59;
  wire                when_Axi4Upsizer_l59_1;
  wire                when_Axi4Upsizer_l59_2;
  wire                when_Axi4Upsizer_l59_3;
  wire                when_Axi4Upsizer_l59_4;
  wire                when_Axi4Upsizer_l59_5;
  wire                when_Axi4Upsizer_l59_6;
  wire                when_Axi4Upsizer_l59_7;
  wire                when_Axi4Upsizer_l59_8;
  wire                when_Axi4Upsizer_l59_9;
  wire                when_Axi4Upsizer_l59_10;
  wire                when_Axi4Upsizer_l59_11;
  wire                when_Axi4Upsizer_l59_12;
  wire                when_Axi4Upsizer_l59_13;
  wire                when_Axi4Upsizer_l59_14;
  wire                when_Axi4Upsizer_l59_15;
  wire                when_Axi4Upsizer_l59_16;
  wire                when_Axi4Upsizer_l59_17;
  wire                when_Axi4Upsizer_l59_18;
  wire                when_Axi4Upsizer_l59_19;
  wire                when_Axi4Upsizer_l59_20;
  wire                when_Axi4Upsizer_l59_21;
  wire                when_Axi4Upsizer_l59_22;
  wire                when_Axi4Upsizer_l59_23;
  wire                when_Axi4Upsizer_l59_24;
  wire                when_Axi4Upsizer_l59_25;
  wire                when_Axi4Upsizer_l59_26;
  wire                when_Axi4Upsizer_l59_27;
  wire                when_Axi4Upsizer_l59_28;
  wire                when_Axi4Upsizer_l59_29;
  wire                when_Axi4Upsizer_l59_30;
  wire                when_Axi4Upsizer_l59_31;
  wire                when_Axi4Upsizer_l59_32;
  wire                when_Axi4Upsizer_l59_33;
  wire                when_Axi4Upsizer_l59_34;
  wire                when_Axi4Upsizer_l59_35;
  wire                when_Axi4Upsizer_l59_36;
  wire                when_Axi4Upsizer_l59_37;
  wire                when_Axi4Upsizer_l59_38;
  wire                when_Axi4Upsizer_l59_39;
  wire                when_Axi4Upsizer_l59_40;
  wire                when_Axi4Upsizer_l59_41;
  wire                when_Axi4Upsizer_l59_42;
  wire                when_Axi4Upsizer_l59_43;
  wire                when_Axi4Upsizer_l59_44;
  wire                when_Axi4Upsizer_l59_45;
  wire                when_Axi4Upsizer_l59_46;
  wire                when_Axi4Upsizer_l59_47;
  wire                when_Axi4Upsizer_l59_48;
  wire                when_Axi4Upsizer_l59_49;
  wire                when_Axi4Upsizer_l59_50;
  wire                when_Axi4Upsizer_l59_51;
  wire                when_Axi4Upsizer_l59_52;
  wire                when_Axi4Upsizer_l59_53;
  wire                when_Axi4Upsizer_l59_54;
  wire                when_Axi4Upsizer_l59_55;
  wire                when_Axi4Upsizer_l59_56;
  wire                when_Axi4Upsizer_l59_57;
  wire                when_Axi4Upsizer_l59_58;
  wire                when_Axi4Upsizer_l59_59;
  wire                when_Axi4Upsizer_l59_60;
  wire                when_Axi4Upsizer_l59_61;
  wire                when_Axi4Upsizer_l59_62;
  wire                when_Axi4Upsizer_l59_63;
  wire                cmdLogic_dataFork_fire_1;
  wire                when_Axi4Upsizer_l68;
  wire                when_Axi4Upsizer_l68_1;
  wire                when_Axi4Upsizer_l68_2;
  wire                when_Axi4Upsizer_l68_3;
  wire                when_Axi4Upsizer_l68_4;
  wire                when_Axi4Upsizer_l68_5;

  assign _zz_cmdLogic_byteCount = ({7'd0,io_input_aw_payload_len} <<< io_input_aw_payload_size);
  assign _zz_cmdLogic_incrLen = ({1'b0,cmdLogic_byteCount} + _zz_cmdLogic_incrLen_1);
  assign _zz_cmdLogic_incrLen_2 = io_input_aw_payload_addr[5 : 0];
  assign _zz_cmdLogic_incrLen_1 = {8'd0, _zz_cmdLogic_incrLen_2};
  assign _zz_dataLogic_byteCounterNext_1 = ({7'd0,1'b1} <<< dataLogic_size);
  assign _zz_dataLogic_byteCounterNext = _zz_dataLogic_byteCounterNext_1[6:0];
  always @(*) begin
    case(dataLogic_size)
      3'b000 : _zz_dataLogic_byteActivity = 64'h0000000000000001;
      3'b001 : _zz_dataLogic_byteActivity = 64'h0000000000000003;
      3'b010 : _zz_dataLogic_byteActivity = 64'h000000000000000f;
      3'b011 : _zz_dataLogic_byteActivity = 64'h00000000000000ff;
      3'b100 : _zz_dataLogic_byteActivity = 64'h000000000000ffff;
      default : _zz_dataLogic_byteActivity = 64'h00000000ffffffff;
    endcase
  end

  always @(*) begin
    io_input_aw_ready = 1'b1;
    if(when_Stream_l993) begin
      io_input_aw_ready = 1'b0;
    end
    if(when_Stream_l993_1) begin
      io_input_aw_ready = 1'b0;
    end
  end

  assign when_Stream_l993 = ((! cmdLogic_outputFork_ready) && io_input_aw_fork2_logic_linkEnable_0);
  assign when_Stream_l993_1 = ((! cmdLogic_dataFork_ready) && io_input_aw_fork2_logic_linkEnable_1);
  assign cmdLogic_outputFork_valid = (io_input_aw_valid && io_input_aw_fork2_logic_linkEnable_0);
  assign cmdLogic_outputFork_payload_addr = io_input_aw_payload_addr;
  assign cmdLogic_outputFork_payload_id = io_input_aw_payload_id;
  assign cmdLogic_outputFork_payload_region = io_input_aw_payload_region;
  assign cmdLogic_outputFork_payload_len = io_input_aw_payload_len;
  assign cmdLogic_outputFork_payload_size = io_input_aw_payload_size;
  assign cmdLogic_outputFork_payload_burst = io_input_aw_payload_burst;
  assign cmdLogic_outputFork_payload_lock = io_input_aw_payload_lock;
  assign cmdLogic_outputFork_payload_cache = io_input_aw_payload_cache;
  assign cmdLogic_outputFork_payload_qos = io_input_aw_payload_qos;
  assign cmdLogic_outputFork_payload_prot = io_input_aw_payload_prot;
  assign cmdLogic_outputFork_fire = (cmdLogic_outputFork_valid && cmdLogic_outputFork_ready);
  assign cmdLogic_dataFork_valid = (io_input_aw_valid && io_input_aw_fork2_logic_linkEnable_1);
  assign cmdLogic_dataFork_payload_addr = io_input_aw_payload_addr;
  assign cmdLogic_dataFork_payload_id = io_input_aw_payload_id;
  assign cmdLogic_dataFork_payload_region = io_input_aw_payload_region;
  assign cmdLogic_dataFork_payload_len = io_input_aw_payload_len;
  assign cmdLogic_dataFork_payload_size = io_input_aw_payload_size;
  assign cmdLogic_dataFork_payload_burst = io_input_aw_payload_burst;
  assign cmdLogic_dataFork_payload_lock = io_input_aw_payload_lock;
  assign cmdLogic_dataFork_payload_cache = io_input_aw_payload_cache;
  assign cmdLogic_dataFork_payload_qos = io_input_aw_payload_qos;
  assign cmdLogic_dataFork_payload_prot = io_input_aw_payload_prot;
  assign cmdLogic_dataFork_fire = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign io_output_aw_valid = cmdLogic_outputFork_valid;
  assign cmdLogic_outputFork_ready = io_output_aw_ready;
  assign io_output_aw_payload_addr = cmdLogic_outputFork_payload_addr;
  assign io_output_aw_payload_id = cmdLogic_outputFork_payload_id;
  assign io_output_aw_payload_region = cmdLogic_outputFork_payload_region;
  always @(*) begin
    io_output_aw_payload_len = cmdLogic_outputFork_payload_len;
    if(when_Axi4Upsizer_l21) begin
      io_output_aw_payload_len = cmdLogic_incrLen;
    end
  end

  always @(*) begin
    io_output_aw_payload_size = cmdLogic_outputFork_payload_size;
    if(when_Axi4Upsizer_l21) begin
      io_output_aw_payload_size = 3'b110;
      if(when_Axi4Upsizer_l24) begin
        io_output_aw_payload_size = io_input_aw_payload_size;
      end
    end
  end

  assign io_output_aw_payload_burst = cmdLogic_outputFork_payload_burst;
  assign io_output_aw_payload_lock = cmdLogic_outputFork_payload_lock;
  assign io_output_aw_payload_cache = cmdLogic_outputFork_payload_cache;
  assign io_output_aw_payload_qos = cmdLogic_outputFork_payload_qos;
  assign io_output_aw_payload_prot = cmdLogic_outputFork_payload_prot;
  assign cmdLogic_byteCount = _zz_cmdLogic_byteCount[12:0];
  assign cmdLogic_incrLen = _zz_cmdLogic_incrLen[13 : 6];
  assign when_Axi4Upsizer_l21 = (io_output_aw_payload_burst == 2'b01);
  assign when_Axi4Upsizer_l24 = (io_input_aw_payload_len == 8'h00);
  assign dataLogic_byteCounterNext = ({1'b0,dataLogic_byteCounter} + _zz_dataLogic_byteCounterNext);
  assign dataLogic_byteActivity = (_zz_dataLogic_byteActivity <<< dataLogic_byteCounter);
  assign io_output_w_fire = (io_output_w_valid && io_output_w_ready);
  assign io_output_w_valid = dataLogic_outputValid;
  assign io_output_w_isStall = (io_output_w_valid && (! io_output_w_ready));
  assign io_input_w_ready = (dataLogic_busy && (! io_output_w_isStall));
  assign io_output_w_payload_data = dataLogic_dataBuffer;
  assign io_output_w_payload_strb = dataLogic_maskBuffer;
  assign io_output_w_payload_last = dataLogic_outputLast;
  assign io_input_w_fire = (io_input_w_valid && io_input_w_ready);
  assign when_Axi4Upsizer_l59 = dataLogic_byteActivity[0];
  assign when_Axi4Upsizer_l59_1 = dataLogic_byteActivity[1];
  assign when_Axi4Upsizer_l59_2 = dataLogic_byteActivity[2];
  assign when_Axi4Upsizer_l59_3 = dataLogic_byteActivity[3];
  assign when_Axi4Upsizer_l59_4 = dataLogic_byteActivity[4];
  assign when_Axi4Upsizer_l59_5 = dataLogic_byteActivity[5];
  assign when_Axi4Upsizer_l59_6 = dataLogic_byteActivity[6];
  assign when_Axi4Upsizer_l59_7 = dataLogic_byteActivity[7];
  assign when_Axi4Upsizer_l59_8 = dataLogic_byteActivity[8];
  assign when_Axi4Upsizer_l59_9 = dataLogic_byteActivity[9];
  assign when_Axi4Upsizer_l59_10 = dataLogic_byteActivity[10];
  assign when_Axi4Upsizer_l59_11 = dataLogic_byteActivity[11];
  assign when_Axi4Upsizer_l59_12 = dataLogic_byteActivity[12];
  assign when_Axi4Upsizer_l59_13 = dataLogic_byteActivity[13];
  assign when_Axi4Upsizer_l59_14 = dataLogic_byteActivity[14];
  assign when_Axi4Upsizer_l59_15 = dataLogic_byteActivity[15];
  assign when_Axi4Upsizer_l59_16 = dataLogic_byteActivity[16];
  assign when_Axi4Upsizer_l59_17 = dataLogic_byteActivity[17];
  assign when_Axi4Upsizer_l59_18 = dataLogic_byteActivity[18];
  assign when_Axi4Upsizer_l59_19 = dataLogic_byteActivity[19];
  assign when_Axi4Upsizer_l59_20 = dataLogic_byteActivity[20];
  assign when_Axi4Upsizer_l59_21 = dataLogic_byteActivity[21];
  assign when_Axi4Upsizer_l59_22 = dataLogic_byteActivity[22];
  assign when_Axi4Upsizer_l59_23 = dataLogic_byteActivity[23];
  assign when_Axi4Upsizer_l59_24 = dataLogic_byteActivity[24];
  assign when_Axi4Upsizer_l59_25 = dataLogic_byteActivity[25];
  assign when_Axi4Upsizer_l59_26 = dataLogic_byteActivity[26];
  assign when_Axi4Upsizer_l59_27 = dataLogic_byteActivity[27];
  assign when_Axi4Upsizer_l59_28 = dataLogic_byteActivity[28];
  assign when_Axi4Upsizer_l59_29 = dataLogic_byteActivity[29];
  assign when_Axi4Upsizer_l59_30 = dataLogic_byteActivity[30];
  assign when_Axi4Upsizer_l59_31 = dataLogic_byteActivity[31];
  assign when_Axi4Upsizer_l59_32 = dataLogic_byteActivity[32];
  assign when_Axi4Upsizer_l59_33 = dataLogic_byteActivity[33];
  assign when_Axi4Upsizer_l59_34 = dataLogic_byteActivity[34];
  assign when_Axi4Upsizer_l59_35 = dataLogic_byteActivity[35];
  assign when_Axi4Upsizer_l59_36 = dataLogic_byteActivity[36];
  assign when_Axi4Upsizer_l59_37 = dataLogic_byteActivity[37];
  assign when_Axi4Upsizer_l59_38 = dataLogic_byteActivity[38];
  assign when_Axi4Upsizer_l59_39 = dataLogic_byteActivity[39];
  assign when_Axi4Upsizer_l59_40 = dataLogic_byteActivity[40];
  assign when_Axi4Upsizer_l59_41 = dataLogic_byteActivity[41];
  assign when_Axi4Upsizer_l59_42 = dataLogic_byteActivity[42];
  assign when_Axi4Upsizer_l59_43 = dataLogic_byteActivity[43];
  assign when_Axi4Upsizer_l59_44 = dataLogic_byteActivity[44];
  assign when_Axi4Upsizer_l59_45 = dataLogic_byteActivity[45];
  assign when_Axi4Upsizer_l59_46 = dataLogic_byteActivity[46];
  assign when_Axi4Upsizer_l59_47 = dataLogic_byteActivity[47];
  assign when_Axi4Upsizer_l59_48 = dataLogic_byteActivity[48];
  assign when_Axi4Upsizer_l59_49 = dataLogic_byteActivity[49];
  assign when_Axi4Upsizer_l59_50 = dataLogic_byteActivity[50];
  assign when_Axi4Upsizer_l59_51 = dataLogic_byteActivity[51];
  assign when_Axi4Upsizer_l59_52 = dataLogic_byteActivity[52];
  assign when_Axi4Upsizer_l59_53 = dataLogic_byteActivity[53];
  assign when_Axi4Upsizer_l59_54 = dataLogic_byteActivity[54];
  assign when_Axi4Upsizer_l59_55 = dataLogic_byteActivity[55];
  assign when_Axi4Upsizer_l59_56 = dataLogic_byteActivity[56];
  assign when_Axi4Upsizer_l59_57 = dataLogic_byteActivity[57];
  assign when_Axi4Upsizer_l59_58 = dataLogic_byteActivity[58];
  assign when_Axi4Upsizer_l59_59 = dataLogic_byteActivity[59];
  assign when_Axi4Upsizer_l59_60 = dataLogic_byteActivity[60];
  assign when_Axi4Upsizer_l59_61 = dataLogic_byteActivity[61];
  assign when_Axi4Upsizer_l59_62 = dataLogic_byteActivity[62];
  assign when_Axi4Upsizer_l59_63 = dataLogic_byteActivity[63];
  assign cmdLogic_dataFork_fire_1 = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign when_Axi4Upsizer_l68 = (3'b000 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_1 = (3'b001 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_2 = (3'b010 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_3 = (3'b011 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_4 = (3'b100 < cmdLogic_dataFork_payload_size);
  assign when_Axi4Upsizer_l68_5 = (3'b101 < cmdLogic_dataFork_payload_size);
  assign cmdLogic_dataFork_ready = (! dataLogic_busy);
  assign io_input_b_valid = io_output_b_valid;
  assign io_output_b_ready = io_input_b_ready;
  assign io_input_b_payload_id = io_output_b_payload_id;
  assign io_input_b_payload_resp = io_output_b_payload_resp;
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_aw_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_aw_fork2_logic_linkEnable_1 <= 1'b1;
      dataLogic_outputValid <= 1'b0;
      dataLogic_busy <= 1'b0;
      dataLogic_maskBuffer <= 64'h0000000000000000;
    end else begin
      if(cmdLogic_outputFork_fire) begin
        io_input_aw_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdLogic_dataFork_fire) begin
        io_input_aw_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_aw_ready) begin
        io_input_aw_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_aw_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(io_output_w_ready) begin
        dataLogic_outputValid <= 1'b0;
      end
      if(io_output_w_fire) begin
        dataLogic_maskBuffer <= 64'h0000000000000000;
      end
      if(io_input_w_fire) begin
        dataLogic_outputValid <= ((dataLogic_byteCounterNext[6] || io_input_w_payload_last) || dataLogic_alwaysFire);
        if(io_input_w_payload_last) begin
          dataLogic_busy <= 1'b0;
        end
        if(when_Axi4Upsizer_l59) begin
          dataLogic_maskBuffer[0] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_1) begin
          dataLogic_maskBuffer[1] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_2) begin
          dataLogic_maskBuffer[2] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_3) begin
          dataLogic_maskBuffer[3] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_4) begin
          dataLogic_maskBuffer[4] <= io_input_w_payload_strb[4];
        end
        if(when_Axi4Upsizer_l59_5) begin
          dataLogic_maskBuffer[5] <= io_input_w_payload_strb[5];
        end
        if(when_Axi4Upsizer_l59_6) begin
          dataLogic_maskBuffer[6] <= io_input_w_payload_strb[6];
        end
        if(when_Axi4Upsizer_l59_7) begin
          dataLogic_maskBuffer[7] <= io_input_w_payload_strb[7];
        end
        if(when_Axi4Upsizer_l59_8) begin
          dataLogic_maskBuffer[8] <= io_input_w_payload_strb[8];
        end
        if(when_Axi4Upsizer_l59_9) begin
          dataLogic_maskBuffer[9] <= io_input_w_payload_strb[9];
        end
        if(when_Axi4Upsizer_l59_10) begin
          dataLogic_maskBuffer[10] <= io_input_w_payload_strb[10];
        end
        if(when_Axi4Upsizer_l59_11) begin
          dataLogic_maskBuffer[11] <= io_input_w_payload_strb[11];
        end
        if(when_Axi4Upsizer_l59_12) begin
          dataLogic_maskBuffer[12] <= io_input_w_payload_strb[12];
        end
        if(when_Axi4Upsizer_l59_13) begin
          dataLogic_maskBuffer[13] <= io_input_w_payload_strb[13];
        end
        if(when_Axi4Upsizer_l59_14) begin
          dataLogic_maskBuffer[14] <= io_input_w_payload_strb[14];
        end
        if(when_Axi4Upsizer_l59_15) begin
          dataLogic_maskBuffer[15] <= io_input_w_payload_strb[15];
        end
        if(when_Axi4Upsizer_l59_16) begin
          dataLogic_maskBuffer[16] <= io_input_w_payload_strb[16];
        end
        if(when_Axi4Upsizer_l59_17) begin
          dataLogic_maskBuffer[17] <= io_input_w_payload_strb[17];
        end
        if(when_Axi4Upsizer_l59_18) begin
          dataLogic_maskBuffer[18] <= io_input_w_payload_strb[18];
        end
        if(when_Axi4Upsizer_l59_19) begin
          dataLogic_maskBuffer[19] <= io_input_w_payload_strb[19];
        end
        if(when_Axi4Upsizer_l59_20) begin
          dataLogic_maskBuffer[20] <= io_input_w_payload_strb[20];
        end
        if(when_Axi4Upsizer_l59_21) begin
          dataLogic_maskBuffer[21] <= io_input_w_payload_strb[21];
        end
        if(when_Axi4Upsizer_l59_22) begin
          dataLogic_maskBuffer[22] <= io_input_w_payload_strb[22];
        end
        if(when_Axi4Upsizer_l59_23) begin
          dataLogic_maskBuffer[23] <= io_input_w_payload_strb[23];
        end
        if(when_Axi4Upsizer_l59_24) begin
          dataLogic_maskBuffer[24] <= io_input_w_payload_strb[24];
        end
        if(when_Axi4Upsizer_l59_25) begin
          dataLogic_maskBuffer[25] <= io_input_w_payload_strb[25];
        end
        if(when_Axi4Upsizer_l59_26) begin
          dataLogic_maskBuffer[26] <= io_input_w_payload_strb[26];
        end
        if(when_Axi4Upsizer_l59_27) begin
          dataLogic_maskBuffer[27] <= io_input_w_payload_strb[27];
        end
        if(when_Axi4Upsizer_l59_28) begin
          dataLogic_maskBuffer[28] <= io_input_w_payload_strb[28];
        end
        if(when_Axi4Upsizer_l59_29) begin
          dataLogic_maskBuffer[29] <= io_input_w_payload_strb[29];
        end
        if(when_Axi4Upsizer_l59_30) begin
          dataLogic_maskBuffer[30] <= io_input_w_payload_strb[30];
        end
        if(when_Axi4Upsizer_l59_31) begin
          dataLogic_maskBuffer[31] <= io_input_w_payload_strb[31];
        end
        if(when_Axi4Upsizer_l59_32) begin
          dataLogic_maskBuffer[32] <= io_input_w_payload_strb[0];
        end
        if(when_Axi4Upsizer_l59_33) begin
          dataLogic_maskBuffer[33] <= io_input_w_payload_strb[1];
        end
        if(when_Axi4Upsizer_l59_34) begin
          dataLogic_maskBuffer[34] <= io_input_w_payload_strb[2];
        end
        if(when_Axi4Upsizer_l59_35) begin
          dataLogic_maskBuffer[35] <= io_input_w_payload_strb[3];
        end
        if(when_Axi4Upsizer_l59_36) begin
          dataLogic_maskBuffer[36] <= io_input_w_payload_strb[4];
        end
        if(when_Axi4Upsizer_l59_37) begin
          dataLogic_maskBuffer[37] <= io_input_w_payload_strb[5];
        end
        if(when_Axi4Upsizer_l59_38) begin
          dataLogic_maskBuffer[38] <= io_input_w_payload_strb[6];
        end
        if(when_Axi4Upsizer_l59_39) begin
          dataLogic_maskBuffer[39] <= io_input_w_payload_strb[7];
        end
        if(when_Axi4Upsizer_l59_40) begin
          dataLogic_maskBuffer[40] <= io_input_w_payload_strb[8];
        end
        if(when_Axi4Upsizer_l59_41) begin
          dataLogic_maskBuffer[41] <= io_input_w_payload_strb[9];
        end
        if(when_Axi4Upsizer_l59_42) begin
          dataLogic_maskBuffer[42] <= io_input_w_payload_strb[10];
        end
        if(when_Axi4Upsizer_l59_43) begin
          dataLogic_maskBuffer[43] <= io_input_w_payload_strb[11];
        end
        if(when_Axi4Upsizer_l59_44) begin
          dataLogic_maskBuffer[44] <= io_input_w_payload_strb[12];
        end
        if(when_Axi4Upsizer_l59_45) begin
          dataLogic_maskBuffer[45] <= io_input_w_payload_strb[13];
        end
        if(when_Axi4Upsizer_l59_46) begin
          dataLogic_maskBuffer[46] <= io_input_w_payload_strb[14];
        end
        if(when_Axi4Upsizer_l59_47) begin
          dataLogic_maskBuffer[47] <= io_input_w_payload_strb[15];
        end
        if(when_Axi4Upsizer_l59_48) begin
          dataLogic_maskBuffer[48] <= io_input_w_payload_strb[16];
        end
        if(when_Axi4Upsizer_l59_49) begin
          dataLogic_maskBuffer[49] <= io_input_w_payload_strb[17];
        end
        if(when_Axi4Upsizer_l59_50) begin
          dataLogic_maskBuffer[50] <= io_input_w_payload_strb[18];
        end
        if(when_Axi4Upsizer_l59_51) begin
          dataLogic_maskBuffer[51] <= io_input_w_payload_strb[19];
        end
        if(when_Axi4Upsizer_l59_52) begin
          dataLogic_maskBuffer[52] <= io_input_w_payload_strb[20];
        end
        if(when_Axi4Upsizer_l59_53) begin
          dataLogic_maskBuffer[53] <= io_input_w_payload_strb[21];
        end
        if(when_Axi4Upsizer_l59_54) begin
          dataLogic_maskBuffer[54] <= io_input_w_payload_strb[22];
        end
        if(when_Axi4Upsizer_l59_55) begin
          dataLogic_maskBuffer[55] <= io_input_w_payload_strb[23];
        end
        if(when_Axi4Upsizer_l59_56) begin
          dataLogic_maskBuffer[56] <= io_input_w_payload_strb[24];
        end
        if(when_Axi4Upsizer_l59_57) begin
          dataLogic_maskBuffer[57] <= io_input_w_payload_strb[25];
        end
        if(when_Axi4Upsizer_l59_58) begin
          dataLogic_maskBuffer[58] <= io_input_w_payload_strb[26];
        end
        if(when_Axi4Upsizer_l59_59) begin
          dataLogic_maskBuffer[59] <= io_input_w_payload_strb[27];
        end
        if(when_Axi4Upsizer_l59_60) begin
          dataLogic_maskBuffer[60] <= io_input_w_payload_strb[28];
        end
        if(when_Axi4Upsizer_l59_61) begin
          dataLogic_maskBuffer[61] <= io_input_w_payload_strb[29];
        end
        if(when_Axi4Upsizer_l59_62) begin
          dataLogic_maskBuffer[62] <= io_input_w_payload_strb[30];
        end
        if(when_Axi4Upsizer_l59_63) begin
          dataLogic_maskBuffer[63] <= io_input_w_payload_strb[31];
        end
      end
      if(cmdLogic_dataFork_fire_1) begin
        dataLogic_busy <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if(io_input_w_fire) begin
      if(dataLogic_incrementByteCounter) begin
        dataLogic_byteCounter <= dataLogic_byteCounterNext[5:0];
      end
      dataLogic_outputLast <= io_input_w_payload_last;
      if(when_Axi4Upsizer_l59) begin
        dataLogic_dataBuffer[7 : 0] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_1) begin
        dataLogic_dataBuffer[15 : 8] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_2) begin
        dataLogic_dataBuffer[23 : 16] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_3) begin
        dataLogic_dataBuffer[31 : 24] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_4) begin
        dataLogic_dataBuffer[39 : 32] <= io_input_w_payload_data[39 : 32];
      end
      if(when_Axi4Upsizer_l59_5) begin
        dataLogic_dataBuffer[47 : 40] <= io_input_w_payload_data[47 : 40];
      end
      if(when_Axi4Upsizer_l59_6) begin
        dataLogic_dataBuffer[55 : 48] <= io_input_w_payload_data[55 : 48];
      end
      if(when_Axi4Upsizer_l59_7) begin
        dataLogic_dataBuffer[63 : 56] <= io_input_w_payload_data[63 : 56];
      end
      if(when_Axi4Upsizer_l59_8) begin
        dataLogic_dataBuffer[71 : 64] <= io_input_w_payload_data[71 : 64];
      end
      if(when_Axi4Upsizer_l59_9) begin
        dataLogic_dataBuffer[79 : 72] <= io_input_w_payload_data[79 : 72];
      end
      if(when_Axi4Upsizer_l59_10) begin
        dataLogic_dataBuffer[87 : 80] <= io_input_w_payload_data[87 : 80];
      end
      if(when_Axi4Upsizer_l59_11) begin
        dataLogic_dataBuffer[95 : 88] <= io_input_w_payload_data[95 : 88];
      end
      if(when_Axi4Upsizer_l59_12) begin
        dataLogic_dataBuffer[103 : 96] <= io_input_w_payload_data[103 : 96];
      end
      if(when_Axi4Upsizer_l59_13) begin
        dataLogic_dataBuffer[111 : 104] <= io_input_w_payload_data[111 : 104];
      end
      if(when_Axi4Upsizer_l59_14) begin
        dataLogic_dataBuffer[119 : 112] <= io_input_w_payload_data[119 : 112];
      end
      if(when_Axi4Upsizer_l59_15) begin
        dataLogic_dataBuffer[127 : 120] <= io_input_w_payload_data[127 : 120];
      end
      if(when_Axi4Upsizer_l59_16) begin
        dataLogic_dataBuffer[135 : 128] <= io_input_w_payload_data[135 : 128];
      end
      if(when_Axi4Upsizer_l59_17) begin
        dataLogic_dataBuffer[143 : 136] <= io_input_w_payload_data[143 : 136];
      end
      if(when_Axi4Upsizer_l59_18) begin
        dataLogic_dataBuffer[151 : 144] <= io_input_w_payload_data[151 : 144];
      end
      if(when_Axi4Upsizer_l59_19) begin
        dataLogic_dataBuffer[159 : 152] <= io_input_w_payload_data[159 : 152];
      end
      if(when_Axi4Upsizer_l59_20) begin
        dataLogic_dataBuffer[167 : 160] <= io_input_w_payload_data[167 : 160];
      end
      if(when_Axi4Upsizer_l59_21) begin
        dataLogic_dataBuffer[175 : 168] <= io_input_w_payload_data[175 : 168];
      end
      if(when_Axi4Upsizer_l59_22) begin
        dataLogic_dataBuffer[183 : 176] <= io_input_w_payload_data[183 : 176];
      end
      if(when_Axi4Upsizer_l59_23) begin
        dataLogic_dataBuffer[191 : 184] <= io_input_w_payload_data[191 : 184];
      end
      if(when_Axi4Upsizer_l59_24) begin
        dataLogic_dataBuffer[199 : 192] <= io_input_w_payload_data[199 : 192];
      end
      if(when_Axi4Upsizer_l59_25) begin
        dataLogic_dataBuffer[207 : 200] <= io_input_w_payload_data[207 : 200];
      end
      if(when_Axi4Upsizer_l59_26) begin
        dataLogic_dataBuffer[215 : 208] <= io_input_w_payload_data[215 : 208];
      end
      if(when_Axi4Upsizer_l59_27) begin
        dataLogic_dataBuffer[223 : 216] <= io_input_w_payload_data[223 : 216];
      end
      if(when_Axi4Upsizer_l59_28) begin
        dataLogic_dataBuffer[231 : 224] <= io_input_w_payload_data[231 : 224];
      end
      if(when_Axi4Upsizer_l59_29) begin
        dataLogic_dataBuffer[239 : 232] <= io_input_w_payload_data[239 : 232];
      end
      if(when_Axi4Upsizer_l59_30) begin
        dataLogic_dataBuffer[247 : 240] <= io_input_w_payload_data[247 : 240];
      end
      if(when_Axi4Upsizer_l59_31) begin
        dataLogic_dataBuffer[255 : 248] <= io_input_w_payload_data[255 : 248];
      end
      if(when_Axi4Upsizer_l59_32) begin
        dataLogic_dataBuffer[263 : 256] <= io_input_w_payload_data[7 : 0];
      end
      if(when_Axi4Upsizer_l59_33) begin
        dataLogic_dataBuffer[271 : 264] <= io_input_w_payload_data[15 : 8];
      end
      if(when_Axi4Upsizer_l59_34) begin
        dataLogic_dataBuffer[279 : 272] <= io_input_w_payload_data[23 : 16];
      end
      if(when_Axi4Upsizer_l59_35) begin
        dataLogic_dataBuffer[287 : 280] <= io_input_w_payload_data[31 : 24];
      end
      if(when_Axi4Upsizer_l59_36) begin
        dataLogic_dataBuffer[295 : 288] <= io_input_w_payload_data[39 : 32];
      end
      if(when_Axi4Upsizer_l59_37) begin
        dataLogic_dataBuffer[303 : 296] <= io_input_w_payload_data[47 : 40];
      end
      if(when_Axi4Upsizer_l59_38) begin
        dataLogic_dataBuffer[311 : 304] <= io_input_w_payload_data[55 : 48];
      end
      if(when_Axi4Upsizer_l59_39) begin
        dataLogic_dataBuffer[319 : 312] <= io_input_w_payload_data[63 : 56];
      end
      if(when_Axi4Upsizer_l59_40) begin
        dataLogic_dataBuffer[327 : 320] <= io_input_w_payload_data[71 : 64];
      end
      if(when_Axi4Upsizer_l59_41) begin
        dataLogic_dataBuffer[335 : 328] <= io_input_w_payload_data[79 : 72];
      end
      if(when_Axi4Upsizer_l59_42) begin
        dataLogic_dataBuffer[343 : 336] <= io_input_w_payload_data[87 : 80];
      end
      if(when_Axi4Upsizer_l59_43) begin
        dataLogic_dataBuffer[351 : 344] <= io_input_w_payload_data[95 : 88];
      end
      if(when_Axi4Upsizer_l59_44) begin
        dataLogic_dataBuffer[359 : 352] <= io_input_w_payload_data[103 : 96];
      end
      if(when_Axi4Upsizer_l59_45) begin
        dataLogic_dataBuffer[367 : 360] <= io_input_w_payload_data[111 : 104];
      end
      if(when_Axi4Upsizer_l59_46) begin
        dataLogic_dataBuffer[375 : 368] <= io_input_w_payload_data[119 : 112];
      end
      if(when_Axi4Upsizer_l59_47) begin
        dataLogic_dataBuffer[383 : 376] <= io_input_w_payload_data[127 : 120];
      end
      if(when_Axi4Upsizer_l59_48) begin
        dataLogic_dataBuffer[391 : 384] <= io_input_w_payload_data[135 : 128];
      end
      if(when_Axi4Upsizer_l59_49) begin
        dataLogic_dataBuffer[399 : 392] <= io_input_w_payload_data[143 : 136];
      end
      if(when_Axi4Upsizer_l59_50) begin
        dataLogic_dataBuffer[407 : 400] <= io_input_w_payload_data[151 : 144];
      end
      if(when_Axi4Upsizer_l59_51) begin
        dataLogic_dataBuffer[415 : 408] <= io_input_w_payload_data[159 : 152];
      end
      if(when_Axi4Upsizer_l59_52) begin
        dataLogic_dataBuffer[423 : 416] <= io_input_w_payload_data[167 : 160];
      end
      if(when_Axi4Upsizer_l59_53) begin
        dataLogic_dataBuffer[431 : 424] <= io_input_w_payload_data[175 : 168];
      end
      if(when_Axi4Upsizer_l59_54) begin
        dataLogic_dataBuffer[439 : 432] <= io_input_w_payload_data[183 : 176];
      end
      if(when_Axi4Upsizer_l59_55) begin
        dataLogic_dataBuffer[447 : 440] <= io_input_w_payload_data[191 : 184];
      end
      if(when_Axi4Upsizer_l59_56) begin
        dataLogic_dataBuffer[455 : 448] <= io_input_w_payload_data[199 : 192];
      end
      if(when_Axi4Upsizer_l59_57) begin
        dataLogic_dataBuffer[463 : 456] <= io_input_w_payload_data[207 : 200];
      end
      if(when_Axi4Upsizer_l59_58) begin
        dataLogic_dataBuffer[471 : 464] <= io_input_w_payload_data[215 : 208];
      end
      if(when_Axi4Upsizer_l59_59) begin
        dataLogic_dataBuffer[479 : 472] <= io_input_w_payload_data[223 : 216];
      end
      if(when_Axi4Upsizer_l59_60) begin
        dataLogic_dataBuffer[487 : 480] <= io_input_w_payload_data[231 : 224];
      end
      if(when_Axi4Upsizer_l59_61) begin
        dataLogic_dataBuffer[495 : 488] <= io_input_w_payload_data[239 : 232];
      end
      if(when_Axi4Upsizer_l59_62) begin
        dataLogic_dataBuffer[503 : 496] <= io_input_w_payload_data[247 : 240];
      end
      if(when_Axi4Upsizer_l59_63) begin
        dataLogic_dataBuffer[511 : 504] <= io_input_w_payload_data[255 : 248];
      end
    end
    if(cmdLogic_dataFork_fire_1) begin
      dataLogic_byteCounter <= cmdLogic_dataFork_payload_addr[5:0];
      if(when_Axi4Upsizer_l68) begin
        dataLogic_byteCounter[0] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_1) begin
        dataLogic_byteCounter[1] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_2) begin
        dataLogic_byteCounter[2] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_3) begin
        dataLogic_byteCounter[3] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_4) begin
        dataLogic_byteCounter[4] <= 1'b0;
      end
      if(when_Axi4Upsizer_l68_5) begin
        dataLogic_byteCounter[5] <= 1'b0;
      end
      dataLogic_size <= cmdLogic_dataFork_payload_size;
      dataLogic_alwaysFire <= (! (cmdLogic_dataFork_payload_burst == 2'b01));
      dataLogic_incrementByteCounter <= (! (cmdLogic_dataFork_payload_burst == 2'b00));
    end
  end


endmodule

module Asic256To512UpsizerAxi4ReadOnlyUpsizer (
  input               io_input_ar_valid,
  output reg          io_input_ar_ready,
  input      [31:0]   io_input_ar_payload_addr,
  input      [7:0]    io_input_ar_payload_id,
  input      [3:0]    io_input_ar_payload_region,
  input      [7:0]    io_input_ar_payload_len,
  input      [2:0]    io_input_ar_payload_size,
  input      [1:0]    io_input_ar_payload_burst,
  input      [0:0]    io_input_ar_payload_lock,
  input      [3:0]    io_input_ar_payload_cache,
  input      [3:0]    io_input_ar_payload_qos,
  input      [2:0]    io_input_ar_payload_prot,
  output              io_input_r_valid,
  input               io_input_r_ready,
  output     [255:0]  io_input_r_payload_data,
  output     [7:0]    io_input_r_payload_id,
  output     [1:0]    io_input_r_payload_resp,
  output              io_input_r_payload_last,
  output              io_output_ar_valid,
  input               io_output_ar_ready,
  output     [31:0]   io_output_ar_payload_addr,
  output     [7:0]    io_output_ar_payload_id,
  output     [3:0]    io_output_ar_payload_region,
  output     [7:0]    io_output_ar_payload_len,
  output reg [2:0]    io_output_ar_payload_size,
  output     [1:0]    io_output_ar_payload_burst,
  output     [0:0]    io_output_ar_payload_lock,
  output     [3:0]    io_output_ar_payload_cache,
  output     [3:0]    io_output_ar_payload_qos,
  output     [2:0]    io_output_ar_payload_prot,
  input               io_output_r_valid,
  output              io_output_r_ready,
  input      [511:0]  io_output_r_payload_data,
  input      [7:0]    io_output_r_payload_id,
  input      [1:0]    io_output_r_payload_resp,
  input               io_output_r_payload_last,
  input               clk,
  input               reset
);

  wire                dataLogic_cmdPush_fifo_io_pop_ready;
  wire                dataLogic_cmdPush_fifo_io_push_ready;
  wire                dataLogic_cmdPush_fifo_io_pop_valid;
  wire       [5:0]    dataLogic_cmdPush_fifo_io_pop_payload_startAt;
  wire       [5:0]    dataLogic_cmdPush_fifo_io_pop_payload_endAt;
  wire       [2:0]    dataLogic_cmdPush_fifo_io_pop_payload_size;
  wire       [7:0]    dataLogic_cmdPush_fifo_io_pop_payload_id;
  wire       [4:0]    dataLogic_cmdPush_fifo_io_occupancy;
  wire       [4:0]    dataLogic_cmdPush_fifo_io_availability;
  wire       [14:0]   _zz_cmdLogic_byteCount;
  wire       [13:0]   _zz_cmdLogic_incrLen;
  wire       [13:0]   _zz_cmdLogic_incrLen_1;
  wire       [5:0]    _zz_cmdLogic_incrLen_2;
  wire       [31:0]   _zz_dataLogic_cmdPush_payload_endAt;
  wire       [31:0]   _zz_dataLogic_cmdPush_payload_endAt_1;
  wire       [14:0]   _zz_dataLogic_cmdPush_payload_endAt_2;
  wire       [6:0]    _zz_dataLogic_byteCounterNext;
  wire       [7:0]    _zz_dataLogic_byteCounterNext_1;
  reg        [255:0]  _zz_io_input_r_payload_data;
  wire       [0:0]    _zz_io_input_r_payload_data_1;
  wire                cmdLogic_outputFork_valid;
  wire                cmdLogic_outputFork_ready;
  wire       [31:0]   cmdLogic_outputFork_payload_addr;
  wire       [7:0]    cmdLogic_outputFork_payload_id;
  wire       [3:0]    cmdLogic_outputFork_payload_region;
  wire       [7:0]    cmdLogic_outputFork_payload_len;
  wire       [2:0]    cmdLogic_outputFork_payload_size;
  wire       [1:0]    cmdLogic_outputFork_payload_burst;
  wire       [0:0]    cmdLogic_outputFork_payload_lock;
  wire       [3:0]    cmdLogic_outputFork_payload_cache;
  wire       [3:0]    cmdLogic_outputFork_payload_qos;
  wire       [2:0]    cmdLogic_outputFork_payload_prot;
  wire                cmdLogic_dataFork_valid;
  wire                cmdLogic_dataFork_ready;
  wire       [31:0]   cmdLogic_dataFork_payload_addr;
  wire       [7:0]    cmdLogic_dataFork_payload_id;
  wire       [3:0]    cmdLogic_dataFork_payload_region;
  wire       [7:0]    cmdLogic_dataFork_payload_len;
  wire       [2:0]    cmdLogic_dataFork_payload_size;
  wire       [1:0]    cmdLogic_dataFork_payload_burst;
  wire       [0:0]    cmdLogic_dataFork_payload_lock;
  wire       [3:0]    cmdLogic_dataFork_payload_cache;
  wire       [3:0]    cmdLogic_dataFork_payload_qos;
  wire       [2:0]    cmdLogic_dataFork_payload_prot;
  reg                 io_input_ar_fork2_logic_linkEnable_0;
  reg                 io_input_ar_fork2_logic_linkEnable_1;
  wire                when_Stream_l993;
  wire                when_Stream_l993_1;
  wire                cmdLogic_outputFork_fire;
  wire                cmdLogic_dataFork_fire;
  wire       [12:0]   cmdLogic_byteCount;
  wire       [7:0]    cmdLogic_incrLen;
  wire                when_Axi4Upsizer_l108;
  wire                dataLogic_cmdPush_valid;
  wire                dataLogic_cmdPush_ready;
  wire       [5:0]    dataLogic_cmdPush_payload_startAt;
  wire       [5:0]    dataLogic_cmdPush_payload_endAt;
  wire       [2:0]    dataLogic_cmdPush_payload_size;
  wire       [7:0]    dataLogic_cmdPush_payload_id;
  reg        [2:0]    dataLogic_size;
  reg                 dataLogic_busy;
  reg        [7:0]    dataLogic_id;
  reg        [5:0]    dataLogic_byteCounter;
  reg        [5:0]    dataLogic_byteCounterLast;
  wire       [6:0]    dataLogic_byteCounterNext;
  wire                readOnly_dataLogic_cmdPush_fifo_io_pop_fire;
  wire                io_input_r_fire;

  assign _zz_cmdLogic_byteCount = ({7'd0,io_input_ar_payload_len} <<< io_input_ar_payload_size);
  assign _zz_cmdLogic_incrLen = ({1'b0,cmdLogic_byteCount} + _zz_cmdLogic_incrLen_1);
  assign _zz_cmdLogic_incrLen_2 = io_input_ar_payload_addr[5 : 0];
  assign _zz_cmdLogic_incrLen_1 = {8'd0, _zz_cmdLogic_incrLen_2};
  assign _zz_dataLogic_cmdPush_payload_endAt = (cmdLogic_dataFork_payload_addr + _zz_dataLogic_cmdPush_payload_endAt_1);
  assign _zz_dataLogic_cmdPush_payload_endAt_2 = ({7'd0,cmdLogic_dataFork_payload_len} <<< cmdLogic_dataFork_payload_size);
  assign _zz_dataLogic_cmdPush_payload_endAt_1 = {17'd0, _zz_dataLogic_cmdPush_payload_endAt_2};
  assign _zz_dataLogic_byteCounterNext_1 = ({7'd0,1'b1} <<< dataLogic_size);
  assign _zz_dataLogic_byteCounterNext = _zz_dataLogic_byteCounterNext_1[6:0];
  assign _zz_io_input_r_payload_data_1 = (dataLogic_byteCounter >>> 3'd5);
  Asic256To512UpsizerStreamFifo dataLogic_cmdPush_fifo (
    .io_push_valid           (dataLogic_cmdPush_valid                           ), //i
    .io_push_ready           (dataLogic_cmdPush_fifo_io_push_ready              ), //o
    .io_push_payload_startAt (dataLogic_cmdPush_payload_startAt[5:0]            ), //i
    .io_push_payload_endAt   (dataLogic_cmdPush_payload_endAt[5:0]              ), //i
    .io_push_payload_size    (dataLogic_cmdPush_payload_size[2:0]               ), //i
    .io_push_payload_id      (dataLogic_cmdPush_payload_id[7:0]                 ), //i
    .io_pop_valid            (dataLogic_cmdPush_fifo_io_pop_valid               ), //o
    .io_pop_ready            (dataLogic_cmdPush_fifo_io_pop_ready               ), //i
    .io_pop_payload_startAt  (dataLogic_cmdPush_fifo_io_pop_payload_startAt[5:0]), //o
    .io_pop_payload_endAt    (dataLogic_cmdPush_fifo_io_pop_payload_endAt[5:0]  ), //o
    .io_pop_payload_size     (dataLogic_cmdPush_fifo_io_pop_payload_size[2:0]   ), //o
    .io_pop_payload_id       (dataLogic_cmdPush_fifo_io_pop_payload_id[7:0]     ), //o
    .io_flush                (1'b0                                              ), //i
    .io_occupancy            (dataLogic_cmdPush_fifo_io_occupancy[4:0]          ), //o
    .io_availability         (dataLogic_cmdPush_fifo_io_availability[4:0]       ), //o
    .clk                     (clk                                               ), //i
    .reset                   (reset                                             )  //i
  );
  always @(*) begin
    case(_zz_io_input_r_payload_data_1)
      1'b0 : _zz_io_input_r_payload_data = io_output_r_payload_data[255 : 0];
      default : _zz_io_input_r_payload_data = io_output_r_payload_data[511 : 256];
    endcase
  end

  always @(*) begin
    io_input_ar_ready = 1'b1;
    if(when_Stream_l993) begin
      io_input_ar_ready = 1'b0;
    end
    if(when_Stream_l993_1) begin
      io_input_ar_ready = 1'b0;
    end
  end

  assign when_Stream_l993 = ((! cmdLogic_outputFork_ready) && io_input_ar_fork2_logic_linkEnable_0);
  assign when_Stream_l993_1 = ((! cmdLogic_dataFork_ready) && io_input_ar_fork2_logic_linkEnable_1);
  assign cmdLogic_outputFork_valid = (io_input_ar_valid && io_input_ar_fork2_logic_linkEnable_0);
  assign cmdLogic_outputFork_payload_addr = io_input_ar_payload_addr;
  assign cmdLogic_outputFork_payload_id = io_input_ar_payload_id;
  assign cmdLogic_outputFork_payload_region = io_input_ar_payload_region;
  assign cmdLogic_outputFork_payload_len = io_input_ar_payload_len;
  assign cmdLogic_outputFork_payload_size = io_input_ar_payload_size;
  assign cmdLogic_outputFork_payload_burst = io_input_ar_payload_burst;
  assign cmdLogic_outputFork_payload_lock = io_input_ar_payload_lock;
  assign cmdLogic_outputFork_payload_cache = io_input_ar_payload_cache;
  assign cmdLogic_outputFork_payload_qos = io_input_ar_payload_qos;
  assign cmdLogic_outputFork_payload_prot = io_input_ar_payload_prot;
  assign cmdLogic_outputFork_fire = (cmdLogic_outputFork_valid && cmdLogic_outputFork_ready);
  assign cmdLogic_dataFork_valid = (io_input_ar_valid && io_input_ar_fork2_logic_linkEnable_1);
  assign cmdLogic_dataFork_payload_addr = io_input_ar_payload_addr;
  assign cmdLogic_dataFork_payload_id = io_input_ar_payload_id;
  assign cmdLogic_dataFork_payload_region = io_input_ar_payload_region;
  assign cmdLogic_dataFork_payload_len = io_input_ar_payload_len;
  assign cmdLogic_dataFork_payload_size = io_input_ar_payload_size;
  assign cmdLogic_dataFork_payload_burst = io_input_ar_payload_burst;
  assign cmdLogic_dataFork_payload_lock = io_input_ar_payload_lock;
  assign cmdLogic_dataFork_payload_cache = io_input_ar_payload_cache;
  assign cmdLogic_dataFork_payload_qos = io_input_ar_payload_qos;
  assign cmdLogic_dataFork_payload_prot = io_input_ar_payload_prot;
  assign cmdLogic_dataFork_fire = (cmdLogic_dataFork_valid && cmdLogic_dataFork_ready);
  assign io_output_ar_valid = cmdLogic_outputFork_valid;
  assign cmdLogic_outputFork_ready = io_output_ar_ready;
  assign io_output_ar_payload_addr = cmdLogic_outputFork_payload_addr;
  assign io_output_ar_payload_region = cmdLogic_outputFork_payload_region;
  assign io_output_ar_payload_burst = cmdLogic_outputFork_payload_burst;
  assign io_output_ar_payload_lock = cmdLogic_outputFork_payload_lock;
  assign io_output_ar_payload_cache = cmdLogic_outputFork_payload_cache;
  assign io_output_ar_payload_qos = cmdLogic_outputFork_payload_qos;
  assign io_output_ar_payload_prot = cmdLogic_outputFork_payload_prot;
  assign cmdLogic_byteCount = _zz_cmdLogic_byteCount[12:0];
  assign cmdLogic_incrLen = _zz_cmdLogic_incrLen[13 : 6];
  always @(*) begin
    io_output_ar_payload_size = 3'b110;
    if(when_Axi4Upsizer_l108) begin
      io_output_ar_payload_size = io_input_ar_payload_size;
    end
  end

  assign io_output_ar_payload_len = cmdLogic_incrLen;
  assign io_output_ar_payload_id = 8'h00;
  assign when_Axi4Upsizer_l108 = (io_input_ar_payload_len == 8'h00);
  assign dataLogic_cmdPush_valid = cmdLogic_dataFork_valid;
  assign cmdLogic_dataFork_ready = dataLogic_cmdPush_ready;
  assign dataLogic_cmdPush_payload_startAt = cmdLogic_dataFork_payload_addr[5:0];
  assign dataLogic_cmdPush_payload_endAt = _zz_dataLogic_cmdPush_payload_endAt[5:0];
  assign dataLogic_cmdPush_payload_size = cmdLogic_dataFork_payload_size;
  assign dataLogic_cmdPush_payload_id = cmdLogic_dataFork_payload_id;
  assign dataLogic_cmdPush_ready = dataLogic_cmdPush_fifo_io_push_ready;
  assign dataLogic_byteCounterNext = ({1'b0,dataLogic_byteCounter} + _zz_dataLogic_byteCounterNext);
  assign readOnly_dataLogic_cmdPush_fifo_io_pop_fire = (dataLogic_cmdPush_fifo_io_pop_valid && dataLogic_cmdPush_fifo_io_pop_ready);
  assign dataLogic_cmdPush_fifo_io_pop_ready = (! dataLogic_busy);
  assign io_input_r_fire = (io_input_r_valid && io_input_r_ready);
  assign io_input_r_valid = (io_output_r_valid && dataLogic_busy);
  assign io_input_r_payload_last = (io_output_r_payload_last && (dataLogic_byteCounter == dataLogic_byteCounterLast));
  assign io_input_r_payload_resp = io_output_r_payload_resp;
  assign io_input_r_payload_data = _zz_io_input_r_payload_data;
  assign io_input_r_payload_id = dataLogic_id;
  assign io_output_r_ready = ((dataLogic_busy && io_input_r_ready) && (io_input_r_payload_last || dataLogic_byteCounterNext[6]));
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      io_input_ar_fork2_logic_linkEnable_0 <= 1'b1;
      io_input_ar_fork2_logic_linkEnable_1 <= 1'b1;
      dataLogic_busy <= 1'b0;
    end else begin
      if(cmdLogic_outputFork_fire) begin
        io_input_ar_fork2_logic_linkEnable_0 <= 1'b0;
      end
      if(cmdLogic_dataFork_fire) begin
        io_input_ar_fork2_logic_linkEnable_1 <= 1'b0;
      end
      if(io_input_ar_ready) begin
        io_input_ar_fork2_logic_linkEnable_0 <= 1'b1;
        io_input_ar_fork2_logic_linkEnable_1 <= 1'b1;
      end
      if(readOnly_dataLogic_cmdPush_fifo_io_pop_fire) begin
        dataLogic_busy <= 1'b1;
      end
      if(io_input_r_fire) begin
        if(io_input_r_payload_last) begin
          dataLogic_busy <= 1'b0;
        end
      end
    end
  end

  always @(posedge clk) begin
    if(readOnly_dataLogic_cmdPush_fifo_io_pop_fire) begin
      dataLogic_byteCounter <= dataLogic_cmdPush_fifo_io_pop_payload_startAt;
      dataLogic_byteCounterLast <= dataLogic_cmdPush_fifo_io_pop_payload_endAt;
      dataLogic_size <= dataLogic_cmdPush_fifo_io_pop_payload_size;
      dataLogic_id <= dataLogic_cmdPush_fifo_io_pop_payload_id;
    end
    if(io_input_r_fire) begin
      dataLogic_byteCounter <= dataLogic_byteCounterNext[5:0];
    end
  end


endmodule

module Asic256To512UpsizerStreamFifo (
  input               io_push_valid,
  output              io_push_ready,
  input      [5:0]    io_push_payload_startAt,
  input      [5:0]    io_push_payload_endAt,
  input      [2:0]    io_push_payload_size,
  input      [7:0]    io_push_payload_id,
  output              io_pop_valid,
  input               io_pop_ready,
  output     [5:0]    io_pop_payload_startAt,
  output     [5:0]    io_pop_payload_endAt,
  output     [2:0]    io_pop_payload_size,
  output     [7:0]    io_pop_payload_id,
  input               io_flush,
  output     [4:0]    io_occupancy,
  output     [4:0]    io_availability,
  input               clk,
  input               reset
);

  reg        [22:0]   _zz_logic_ram_port0;
  wire       [3:0]    _zz_logic_pushPtr_valueNext;
  wire       [0:0]    _zz_logic_pushPtr_valueNext_1;
  wire       [3:0]    _zz_logic_popPtr_valueNext;
  wire       [0:0]    _zz_logic_popPtr_valueNext_1;
  wire                _zz__zz_logic_ram_port0;
  wire                _zz__zz_io_pop_payload_startAt;
  wire       [22:0]   _zz__zz_logic_ram_port1;
  wire       [3:0]    _zz_io_availability;
  reg                 _zz_1;
  reg                 logic_pushPtr_willIncrement;
  reg                 logic_pushPtr_willClear;
  reg        [3:0]    logic_pushPtr_valueNext;
  reg        [3:0]    logic_pushPtr_value;
  wire                logic_pushPtr_willOverflowIfInc;
  wire                logic_pushPtr_willOverflow;
  reg                 logic_popPtr_willIncrement;
  reg                 logic_popPtr_willClear;
  reg        [3:0]    logic_popPtr_valueNext;
  reg        [3:0]    logic_popPtr_value;
  wire                logic_popPtr_willOverflowIfInc;
  wire                logic_popPtr_willOverflow;
  wire                logic_ptrMatch;
  reg                 logic_risingOccupancy;
  wire                logic_pushing;
  wire                logic_popping;
  wire                logic_empty;
  wire                logic_full;
  reg                 _zz_io_pop_valid;
  wire       [22:0]   _zz_io_pop_payload_startAt;
  wire                when_Stream_l1123;
  wire       [3:0]    logic_ptrDif;
  reg [22:0] logic_ram [0:15];

  assign _zz_logic_pushPtr_valueNext_1 = logic_pushPtr_willIncrement;
  assign _zz_logic_pushPtr_valueNext = {3'd0, _zz_logic_pushPtr_valueNext_1};
  assign _zz_logic_popPtr_valueNext_1 = logic_popPtr_willIncrement;
  assign _zz_logic_popPtr_valueNext = {3'd0, _zz_logic_popPtr_valueNext_1};
  assign _zz_io_availability = (logic_popPtr_value - logic_pushPtr_value);
  assign _zz__zz_io_pop_payload_startAt = 1'b1;
  assign _zz__zz_logic_ram_port1 = {io_push_payload_id,{io_push_payload_size,{io_push_payload_endAt,io_push_payload_startAt}}};
  always @(posedge clk) begin
    if(_zz__zz_io_pop_payload_startAt) begin
      _zz_logic_ram_port0 <= logic_ram[logic_popPtr_valueNext];
    end
  end

  always @(posedge clk) begin
    if(_zz_1) begin
      logic_ram[logic_pushPtr_value] <= _zz__zz_logic_ram_port1;
    end
  end

  always @(*) begin
    _zz_1 = 1'b0;
    if(logic_pushing) begin
      _zz_1 = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willIncrement = 1'b0;
    if(logic_pushing) begin
      logic_pushPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_pushPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_pushPtr_willClear = 1'b1;
    end
  end

  assign logic_pushPtr_willOverflowIfInc = (logic_pushPtr_value == 4'b1111);
  assign logic_pushPtr_willOverflow = (logic_pushPtr_willOverflowIfInc && logic_pushPtr_willIncrement);
  always @(*) begin
    logic_pushPtr_valueNext = (logic_pushPtr_value + _zz_logic_pushPtr_valueNext);
    if(logic_pushPtr_willClear) begin
      logic_pushPtr_valueNext = 4'b0000;
    end
  end

  always @(*) begin
    logic_popPtr_willIncrement = 1'b0;
    if(logic_popping) begin
      logic_popPtr_willIncrement = 1'b1;
    end
  end

  always @(*) begin
    logic_popPtr_willClear = 1'b0;
    if(io_flush) begin
      logic_popPtr_willClear = 1'b1;
    end
  end

  assign logic_popPtr_willOverflowIfInc = (logic_popPtr_value == 4'b1111);
  assign logic_popPtr_willOverflow = (logic_popPtr_willOverflowIfInc && logic_popPtr_willIncrement);
  always @(*) begin
    logic_popPtr_valueNext = (logic_popPtr_value + _zz_logic_popPtr_valueNext);
    if(logic_popPtr_willClear) begin
      logic_popPtr_valueNext = 4'b0000;
    end
  end

  assign logic_ptrMatch = (logic_pushPtr_value == logic_popPtr_value);
  assign logic_pushing = (io_push_valid && io_push_ready);
  assign logic_popping = (io_pop_valid && io_pop_ready);
  assign logic_empty = (logic_ptrMatch && (! logic_risingOccupancy));
  assign logic_full = (logic_ptrMatch && logic_risingOccupancy);
  assign io_push_ready = (! logic_full);
  assign io_pop_valid = ((! logic_empty) && (! (_zz_io_pop_valid && (! logic_full))));
  assign _zz_io_pop_payload_startAt = _zz_logic_ram_port0;
  assign io_pop_payload_startAt = _zz_io_pop_payload_startAt[5 : 0];
  assign io_pop_payload_endAt = _zz_io_pop_payload_startAt[11 : 6];
  assign io_pop_payload_size = _zz_io_pop_payload_startAt[14 : 12];
  assign io_pop_payload_id = _zz_io_pop_payload_startAt[22 : 15];
  assign when_Stream_l1123 = (logic_pushing != logic_popping);
  assign logic_ptrDif = (logic_pushPtr_value - logic_popPtr_value);
  assign io_occupancy = {(logic_risingOccupancy && logic_ptrMatch),logic_ptrDif};
  assign io_availability = {((! logic_risingOccupancy) && logic_ptrMatch),_zz_io_availability};
  always @(posedge clk or posedge reset) begin
    if(reset) begin
      logic_pushPtr_value <= 4'b0000;
      logic_popPtr_value <= 4'b0000;
      logic_risingOccupancy <= 1'b0;
      _zz_io_pop_valid <= 1'b0;
    end else begin
      logic_pushPtr_value <= logic_pushPtr_valueNext;
      logic_popPtr_value <= logic_popPtr_valueNext;
      _zz_io_pop_valid <= (logic_popPtr_valueNext == logic_pushPtr_value);
      if(when_Stream_l1123) begin
        logic_risingOccupancy <= logic_pushing;
      end
      if(io_flush) begin
        logic_risingOccupancy <= 1'b0;
      end
    end
  end


endmodule

