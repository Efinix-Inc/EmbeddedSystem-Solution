//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : system_reg.v
// Version        : 1.0 
// Author         : Bill Chen 
// Email          : bill.chen@elitestek.com 
// Date Created   : 2025-3-6 14:14:09 
// Last Modified  : 2025-3-24 14:40:32
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps
module system_reg#(
    parameter                       ADDR_WTH = 10,
    parameter                       SYS_DATE = 32'h20250306
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

output                          emmc_dev_rst_o,
output                          emmc_ip_rst_o

);

//Parameter Define 

//Register Define
reg     [ADDR_WTH-3:0]          loc_waddr;
reg                             loc_waddr_vld;
reg     [31:0]                  loc_wdata;
reg                             loc_wdata_vld;
reg     [3:0]                   loc_wstrb;
reg     [ADDR_WTH-3:0]          loc_raddr;
reg                             loc_raddr_vld;
reg     [31:0]                  test_reg;
reg                             emmc_dev_reset = 1'b0;
reg                             emmc_ip_reset  = 1'b0;

//Wire Define
wire                            loc_wrdy;
wire                            loc_rrdy;

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
            'h000  : s_axi_rdata <= SYS_DATE;
            'h001  : s_axi_rdata <= test_reg;
            'h002  : s_axi_rdata <= {30'h0,emmc_dev_reset,emmc_ip_reset};
            default: s_axi_rdata <= 32'h0;
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

/*----------------------------------------------------------------------------------*\
    Register Space -- Base Configuration Registers Field
\*----------------------------------------------------------------------------------*/

//loc_addr = 0x01; axi_addr = 0x004; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
        test_reg <= 32'h0;
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h001))
        test_reg <= loc_wdata;   
end

//loc_addr = 0x02; axi_addr = 0x008; RW;
always @(posedge s_axi_aclk or negedge s_axi_aresetn)
begin
    if(s_axi_aresetn == 1'b0)
    begin
        emmc_dev_reset <= 1'b0;
        emmc_ip_reset  <= 1'b0;
    end
    else if((s_axi_bvalid == 1'b1) && (loc_waddr == 'h002))
    begin
        emmc_dev_reset <= loc_wdata[1];
        emmc_ip_reset  <= loc_wdata[0];
    end   
end

assign emmc_dev_rst_o = emmc_dev_reset;
assign emmc_ip_rst_o  = emmc_ip_reset;

//Encryption end
endmodule

