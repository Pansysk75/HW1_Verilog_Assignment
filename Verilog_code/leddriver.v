`timescale 1ns / 1ps

`include "counter.v"
`include "clockdivider.v"
`include "decoder.v"

module FourDigitLEDdriver(
  input reset, clk, 
  input [3:0] char3, char2, char1, char0,
  output reg an3, an2, an1, an0, // our anodes
  output a, b, c, d, e, f, g	//	our signals to the display 
);

//		    a
//   	 ------
//    f |	   |  b
//	    |   g  |
//	  	 ------
//      |      |
//	  e |	   |  c
//	     ------ 
//			d

  
  // We use ClockDivider to create a clock at 1/16th of the original clk frequency
  // This is needed because the anode--char counter logic is at 1/16 of the global clock
  
  wire slow_clk;
  ClockDivider #(.RANK(4)) clock_divider (reset, clk, slow_clk);
  
  // Use a 4-bit counter to control the timings of anodes/chars
  wire [3:0] anode_count;
  counter #(.BITS(4), .STEP(-1)) anode_counter (reset, slow_clk, anode_count);
  

  reg [3:0] char_to_decode;
  LEDdecoder led_decoder(char_to_decode, {a,b,c,d,e,f,g});
  
  
  
/////////////////////////////////////////////////////////////////////		
//	Set char values to present them at the correct anode at a time //
/////////////////////////////////////////////////////////////////////	
   
    
  // This sets the input 2 cycles before
  always@(anode_count)
begin
  case(anode_count) 
      4'b0000 : char_to_decode = char3;	
      4'b1100 : char_to_decode = char2;
      4'b1000 : char_to_decode = char1;
      4'b0100 : char_to_decode = char0;
    endcase
end
  
  
  
  
//////////////////////////
//		Anodes Set		//
//////////////////////////
  always@(anode_count)
begin
  	case(anode_count)
        4'b1110 : {an3, an2, an1, an0} = 4'b0111;  	//an3
        4'b1010 : {an3, an2, an1, an0} = 4'b1011;	//an2
        4'b0110 : {an3, an2, an1, an0} = 4'b1101;	//an1
        4'b0010 : {an3, an2, an1, an0} = 4'b1110;	//an0
        default : {an3, an2, an1, an0} = 4'b1111;	//none
  	endcase
end


  
endmodule
