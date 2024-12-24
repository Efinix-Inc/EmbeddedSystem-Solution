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


module common_apb3 #(
   parameter   ADDR_WIDTH  = 16,
   parameter   DATA_WIDTH  = 32,
   parameter   SW_MODULE    = 1,       //SW_MODULE = 1-> Camera,  2-> Display, 3-> Hw_accel
   parameter   NUM_RD_REG   = 6,      // Number of Read Register
   parameter   NUM_WR_REG   = 5      // Number of Write Register


) (

   input   [DATA_WIDTH - 1 :0]         data_in  [0:NUM_RD_REG-1],
   output  reg [DATA_WIDTH - 1 :0]     data_out [0:NUM_WR_REG-1],


   input                   cross_clk,
   input                   clk,

   input                   resetn,
   input  [ADDR_WIDTH-1:0] PADDR,
   input                   PSEL,
   input                   PENABLE,
   output                  PREADY,
   input                   PWRITE,
   input  [DATA_WIDTH-1:0] PWDATA,
   output [DATA_WIDTH-1:0] PRDATA,
   output                  PSLVERROR
);

///////////////////////////////////////////////////////////////////////////////

localparam [1:0] IDLE   = 2'b00,
                 SETUP  = 2'b01,
                 ACCESS = 2'b10,
                 WAIT   = 2'b11;

reg [1:0]            busState, 
                     busNext;
reg [DATA_WIDTH-1:0] slaveReg [0:NUM_WR_REG-1];
reg [DATA_WIDTH-1:0] slaveRegOut;
reg                  slaveReady;
wire                 actWrite,
                     actRead,
                     Read_busy,
                     Write_busy,
                     Write_sync,
                     Complete;
integer              byteIndex;

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

// Handshake sync for write
common_pulse_sync sync_write (
   .pulse      (actWrite),
   .fastclk    (clk),
   .slowclk    (cross_clk),
   .rst        (!resetn),
   .busy       (Write_busy),
   .pulse_sync (Write_sync)
);

   assign actRead    = !PWRITE  & (busState == ACCESS);
   assign actWrite   = PWRITE  & (busState == ACCESS);
   assign PREADY     = (actRead | Write_sync) && (busState !== IDLE);
   assign PRDATA     = slaveRegOut;
   assign PSLVERROR  = (Write_busy && actWrite) || (Read_busy && actRead); 
 
/***************Register Write*****************/

   always@ (*)
   begin
      if(!resetn)
         for(byteIndex = 0; byteIndex < NUM_WR_REG; byteIndex = byteIndex + 1)
            slaveReg[byteIndex] <= {DATA_WIDTH{1'b0}};
      else begin
         for(byteIndex = 0; byteIndex < NUM_WR_REG; byteIndex = byteIndex + 1)
            if(Write_sync && PADDR[ADDR_WIDTH-1:0] == (byteIndex*4))
               slaveReg[byteIndex] <= PWDATA;
            else
               slaveReg[byteIndex] <= slaveReg[byteIndex];
      end
   end

integer k;
always @(*) begin
   for (k = 0; k < NUM_WR_REG; k = k + 1) begin
      data_out[k] = slaveReg[k];
   end
end


/***************Register Read*****************/


reg [DATA_WIDTH-1:0] data_in_ff1 [0:NUM_RD_REG-1];
reg [DATA_WIDTH-1:0] data_in_ff2 [0:NUM_RD_REG-1];
integer i;

// Double flops
   always@ (posedge clk or negedge resetn)
   begin
      if(!resetn) begin
         // Reset all elements in the array

         for (i=0;i<NUM_RD_REG; i = i+1) begin
         data_in_ff1[i] <= {DATA_WIDTH{1'b0}};
         data_in_ff2[i] <= {DATA_WIDTH{1'b0}};
         end
      end
      else begin
         for (i=0;i<NUM_RD_REG; i = i+1) begin
         data_in_ff1[i] <= data_in[i];
         data_in_ff2[i] <= data_in_ff1[i];
         end
      end
   end


   always@ (*)
   begin
      if(!resetn)
         slaveRegOut <= {DATA_WIDTH{1'b0}};
      else begin
         if (actRead) begin
               for (i = 0; i < NUM_RD_REG; i = i + 1) begin
                  if (PADDR[6:2] == (SW_MODULE == 1 ? (5'd5 + i) : SW_MODULE == 2 ?(5'd11 + i):(5'd15 + i))) begin
                     slaveRegOut <= data_in_ff2[i]; 
                  end
               end 
         end else begin
            slaveRegOut <= slaveRegOut;
      end
    end
   end
/*********************************************/   
endmodule


