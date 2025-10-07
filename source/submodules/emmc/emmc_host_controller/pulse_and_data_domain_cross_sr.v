//***************************************************************/
//   ______   _   _   _                  _            _
//  |  ____| | | (_) | |                | |          | |
//  | |__    | |  _  | |_    ___   ___  | |_    ___  | | __
//  |  __|   | | | | | __|  / _ \ / __| | __|  / _ \ | |/ /
//  | |____  | | | | | |_  |  __/ \__ \ | |_  |  __/ |   <
//  |______| |_| |_|  \__|  \___| |___/  \__|  \___| |_|\_\
//  
// Module Name    : pulse_and_data_domain_cross_sr
// Version        : 1.0 
// Author         : Bill Chen 
// Email          : bill.chen@elitestek.com 
// Date Created   : 2025-06-11 16:47:22
// Last Modified  : 2025-06-11 16:53:09
// Abstract       : ---  
//  
//Copyright (c) 2020-2025 Elitestek,Inc. All Rights Reserved. 
//  
//***************************************************************/
//Modification History 
//1.0 initial 
//***************************************************************/
`timescale 1 ns / 1 ps
module pulse_and_data_domain_cross_sr#(
    parameter                       DWTH = 1
)
(
input                           in_clk,
input                           in_rstn,
input                           in_clk_en,
input                           out_clk,
input                           out_rstn,
input                           in_pulse,
input           [DWTH-1:0]      in_data,
output  reg                     out_pulse,
output  reg     [DWTH-1:0]      out_data
);

// Parameter Define 

// Register Define 
reg                             in_pulse_turn;
reg     [DWTH-1:0]              in_data_d1;
reg     [2:0]                   out_pulse_sr;
reg     [DWTH-1:0]              out_data_d1;
reg     [DWTH-1:0]              out_data_d2;

// Wire Define 

//Encryption begin
/*----------------------------------------------------------------------------------*\
                                 The main code
\*----------------------------------------------------------------------------------*/
always @(posedge in_clk or negedge in_rstn)
begin
    if(in_rstn == 1'b0)
        in_pulse_turn <= 1'b0;
    else if(in_clk_en == 1'b0)
        in_pulse_turn <= in_pulse_turn;
    else if(in_pulse == 1'b1)
        in_pulse_turn <= ~in_pulse_turn;
end

always @(posedge in_clk or negedge in_rstn)
begin
    if(in_rstn == 1'b0)
        in_data_d1 <= {DWTH{1'b0}};
    else if(in_clk_en == 1'b0)
        in_data_d1 <= in_data_d1;
    else    
        in_data_d1 <= in_data;
end

always @(posedge out_clk or negedge out_rstn)
begin
    if(out_rstn == 1'b0)
        out_pulse_sr <= 3'h0;
    else
        out_pulse_sr <= {out_pulse_sr[1:0],in_pulse_turn};
end

always @(posedge out_clk or negedge out_rstn)
begin
    if(out_rstn == 1'b0)
        out_pulse <= 1'b0;
    else if(out_pulse_sr[2] ^ out_pulse_sr[1])
        out_pulse <= 1'b1;
    else
        out_pulse <= 1'b0;
end

always @(posedge out_clk or negedge out_rstn)
begin
    if(out_rstn == 1'b0)
        begin
            out_data_d1 <= {DWTH{1'b0}};
            out_data_d2 <= {DWTH{1'b0}};
            out_data <= {DWTH{1'b0}};
        end
    else
        begin
            out_data_d1 <= in_data_d1;
            out_data_d2 <= out_data_d1;
            out_data <= out_data_d2;
        end
end

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
