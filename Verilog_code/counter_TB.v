
`timescale 1ns/1ps

`include "counter.v"

module counter_TB;
  
  reg global_clk, global_reset;
  
  
  wire [3:0] test_counter ;
  
  counter #(.COUNTER_WIDTH(4) , .STEP(1)) my_counter (
      .clk (global_clk),       
      .reset (global_reset), 
      .counter_value (test_counter)
   );
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
    global_clk = 0;
    global_reset = 0;
    
    // reset 
    #10 global_reset = 1;    
    #10 global_reset = 0;
    
    #1000 $finish;
  end

  always #10 global_clk = ~global_clk;

endmodule