`timescale 1ns/1ps

`include "Encoder_Decoder1.v"
`include "Encoder_Decoder2.v"
`include "Encoder_Decoder3.v"

module Encoder_Decoder_TB;
  
  
   
  reg [7:0] i ; 
  
  reg  [7:0] original_input ;
  wire [7:0] final_output ;
  
  wire [7:0] encoder_input1,encoder_input2,encoder_input3 ;
  wire [7:0] encoder_output1,encoder_output2,encoder_output3;  
  wire [7:0] decoder_input1,decoder_input2,decoder_input3;  
  wire [7:0] decoder_output1,decoder_output2,decoder_output3;
  
  
  assign encoder_input1 = original_input  ; 
  assign encoder_input2 = encoder_output1 ;
  assign encoder_input3 = encoder_output2 ; 
  
  assign decoder_input3 = encoder_output3 ;
  assign decoder_input2 = decoder_output3 ; 
  assign decoder_input1 = decoder_output2 ;   
  assign final_output 	= decoder_output1 ;
  
  Encoder_Decoder1 object_encoder1(encoder_input1, encoder_output1 ) ;
  Encoder_Decoder2 object_encoder2(encoder_input2, encoder_output2 ) ;
  Encoder_Decoder3 object_encoder3(encoder_input3, encoder_output3 ) ;
  
  
  Encoder_Decoder3 object_decoder3(decoder_input3, decoder_output3 ) ;
  Encoder_Decoder2 object_decoder2(decoder_input2, decoder_output2 ) ;
  Encoder_Decoder1 object_decoder1(decoder_input1, decoder_output1 ) ;
  
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
   
    for (i = 0 ; i < 16*4-1 ; i=i+1) begin
    	#10  original_input = i ;
    
    end
    
    $finish;
    
  end

  
  
  
endmodule