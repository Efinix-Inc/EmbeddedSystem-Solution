///////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 github-efx
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///////////////////////////////////////////////////////////////////////////////////

module common_apb3_wrapper #(
    parameter   ADDR_WIDTH  = 16,
    parameter   DATA_WIDTH  = 32,
    parameter   NUM_REG     = 3
)(
    //Clock & Reset
    input                    resetn,
    input  [DATA_WIDTH-1:0]  data_in  [0:NUM_REG-1],
    input                    ready_in [0:NUM_REG-1],

    //APB3 Standard Signal
    input  [ADDR_WIDTH-1:0]  PADDR,
    output                   PREADY,
    output [DATA_WIDTH-1:0]  PRDATA,
    input                    PWRITE


);

///////////////////////////////////////////////////////////////////////////////

reg [DATA_WIDTH-1:0]   PRDATA_CAM,
                        PRDATA_DISPLAY,
                        PRDATA_HW_ACCEL;
reg     PREADY_CAM,
        PREADY_DISPLAY,
        PREADY_HW_ACCEL;

localparam CAM_BASE      = 5'd5;
localparam DISPLAY_BASE  = 5'd11;
localparam HW_ACCEL_BASE = 5'd15;

always@(*)
begin
    if (!resetn) begin
    PRDATA_CAM      <= {DATA_WIDTH{1'b0}};
    PRDATA_DISPLAY  <= {DATA_WIDTH{1'b0}};
    PRDATA_HW_ACCEL <= {DATA_WIDTH{1'b0}};
    PREADY_CAM      <= 1'b0;
    PREADY_DISPLAY  <= 1'b0;
    PREADY_HW_ACCEL <= 1'b0;
    end
    else begin
    PRDATA_CAM      <=  data_in[0];
    PRDATA_DISPLAY  <=  data_in[1];
    PRDATA_HW_ACCEL <=  data_in[2];
    PREADY_CAM      <= ready_in[0];
    PREADY_DISPLAY  <= ready_in[1];
    PREADY_HW_ACCEL <= ready_in[2];    
    end
end



assign PRDATA = (PADDR[6:2] >= HW_ACCEL_BASE) ? PRDATA_HW_ACCEL :
                (PADDR[6:2] >= DISPLAY_BASE)  ? PRDATA_DISPLAY :
                PRDATA_CAM;

assign PREADY = PWRITE ? PREADY_CAM :(PADDR[6:2] >= HW_ACCEL_BASE) ? PREADY_HW_ACCEL :
                (PADDR[6:2] >= DISPLAY_BASE)  ? PREADY_DISPLAY :
                PREADY_CAM;



/*********************************************/   
endmodule