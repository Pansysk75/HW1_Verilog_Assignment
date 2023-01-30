`timescale 1ns/1ps
`include "baudcontroller.v"

module baudcontroller_TB;
  
  
  
  reg global_clk, global_reset;
  
  wire result_clock_to_sample ; 
  BaudController  object_baud_controller( global_reset , global_clk , 3'b010 , result_clock_to_sample ) ;
  
  
  
  reg [31:0] i ; 
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
    global_clk = 0;
    global_reset = 0;
    
    
    // reset 
    #10 global_reset = 1;    
    #10 global_reset = 0;
    
    
    for (i = 0 ; i < 30 ; i=i+1) begin
      	// Wait for the pulses
      	@( posedge result_clock_to_sample ) ; 
    end
    
    @ (posedge global_clk) ;
    @ (posedge global_clk) ;
    @ (posedge global_clk) ;
    @ (posedge global_clk) ;
    @ (posedge global_clk) ;
    @ (posedge global_clk) ;
    
    $finish;
  end

  
  always #10 global_clk = ~global_clk;
  
  
  
  
  
  
endmodule

  
  
  
  
  
  
  
  
  
  
  
  
  