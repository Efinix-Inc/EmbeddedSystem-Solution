`timescale 1ns/1ps 

module common_pulse_sync(

    input pulse,
    input fastclk,  //200MHz
    input slowclk,  //100MHz
    input rst,      //async_reset
    output busy,
    output pulse_sync


);
wire d1;

wire qA1,qA2,qA3;
wire qB1,qB2,qB3;

assign d1 = pulse ? 1'b1: qB3 ? 1'b0 : qA1;
assign pulse_sync = qA2 & !qA3;

dff2 uA1 (.d(d1), .clk(fastclk), .q(qA1), .rst(rst));
dff2 uB1 (.d(qA1), .clk(slowclk), .q(qB1), .rst(rst));
dff2 uB2 (.d(qB1), .clk(slowclk), .q(qB2), .rst(rst));
dff2 uB3 (.d(qB2), .clk(slowclk), .q(qB3), .rst(rst));
dff2 uA2 (.d(qB2), .clk(fastclk), .q(qA2), .rst(rst));
dff2 uA3 (.d(qA2), .clk(fastclk), .q(qA3), .rst(rst));

assign busy = qA3 | qA1;



endmodule

// Simple Module dflipflop
module dff2(

    input d,
    input clk,
    input rst,
    output reg q

);

always @ ( posedge clk, posedge rst)
begin 
    if (rst)
        q <=0;
    else
        q <=d;
end

endmodule