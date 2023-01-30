`timescale 1ns/1ps



`include "leddriver.v"

module leddriver_TB;
  
  reg global_clk, global_reset;
  
    integer i;
  
  reg [3:0] digit0, digit1, digit2, digit3;
  wire an3, an2, an1, an0;
  wire a,b,c,d,e,f,g;
  
  FourDigitLEDdriver object_driver_TB(global_reset, global_clk,
                               digit3, digit2, digit1, digit0,
                               an3, an2, an1, an0,
                               a,b,c,d,e,f,g
                              );
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
    global_clk = 0;
    global_reset = 0;
    
      
    // reset 
    #10 global_reset = 1;    
    #10 global_reset = 0;
    
    
    
    
    // Display: ‘-194’
    digit0 = 4'h4;
    digit1 = 4'h9;
    digit2 = 4'h1;
    digit3 = 4'ha;
    
    #40000
    
    // Display: ‘  10’
    digit0 = 4'h0;
    digit1 = 4'h1;
    digit2 = 4'hc;
    digit3 = 4'hc;
    
    #40000
    
    // Display: ‘- 32’
    digit0 = 4'h2;
    digit1 = 4'h3;
    digit2 = 4'hc;
    digit3 = 4'ha;
    
    #40000
    
    // Display: ‘FFFF’
    digit0 = 4'hf;
    digit1 = 4'hf;
    digit2 = 4'hf;
    digit3 = 4'hf;
    
    #40000
    
  
    
    $finish;
  end

  always #10 global_clk = ~global_clk;
  
endmodule