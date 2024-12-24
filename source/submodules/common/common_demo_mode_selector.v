module common_demo_mode_selector (
    input switch, 
    input clk, 
    input rstn, 
    output reg [1:0] demo_mode 
);
 
wire debounced_switch;
 
common_debouncer u_common_debouncer (
   .switch  (switch), 
   .clk     (clk),
   .rst_n   (rstn),
   .q       (debounced_switch)
);
always @(posedge clk) begin
    if (~rstn) begin
        demo_mode <= 2'b11; 
    end else begin
        if(debounced_switch) begin
            demo_mode <= demo_mode + 2'b1;
        end else begin
            demo_mode <= demo_mode;
        end
    end
end
endmodule //demo_mode_selector