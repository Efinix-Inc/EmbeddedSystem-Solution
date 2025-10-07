//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : asynreset_deal.v
// Version        : 1.0 
// Author         : Bill Chen 
// Email          : bill.chen@elitestek.com 
// Date Created   : 2025-06-10 11:08:21 
// Last Modified  : 2025-06-10 11:15:34 
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/

`timescale 1 ns / 1 ps

module asynreset_deal
(
    input     clk       ,
    input     rstn_i    ,
    output    rstn_o
);

reg    rstn_syn1;
reg    rstn_syn2;

//Encryption begin

always @(posedge clk or negedge rstn_i)
begin
    if(rstn_i == 1'b0)
    begin
        rstn_syn1 <= 1'b0;
        rstn_syn2 <= 1'b0;
    end
    else
    begin
        rstn_syn1 <= 1'b1;
        rstn_syn2 <= rstn_syn1;
    end  
end

assign rstn_o = rstn_syn2;

//Encryption end
endmodule

