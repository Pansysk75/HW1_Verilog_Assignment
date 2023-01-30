//`timescale 1ns/1ps


`ifndef COUNTER
`define COUNTER

module counter #(
  // number of bits in counter
  parameter BITS = 4,
  parameter STEP = 1)
  (
	input reset,
	input clk,
      
    output reg [BITS-1:0] counter_value
  );
  
  
   // Synchronous logic with asynchronous reset
   always @ (posedge clk or posedge reset)
    begin
      if(reset)
        begin
          counter_value <= 0;
        end
      else
        begin          
          counter_value <= counter_value + STEP;
        end
    end
  
endmodule


`endif //COUNTER