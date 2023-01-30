
`ifndef BAUDCONTROLLER
`define BAUDCONTROLLER

module BaudController(
    input reset, clk,
    input [2:0] baud_select,
    output reg sample_ENABLE
	);
  
  /*
  The baud_select signal is used to select transmission rate.
  In practice, that means setting an appropriate switching frequency
  for the sample_ENABLE signal
  
  
  
  		s=16										s*T2					T1
  baud_select 	- 	Baud rate(bits/sec):	-	Clock cycles	-	Sample cycles (s=16)
  000				300							166667				10417
  001				1200						41667				2604
  010				4800						10417				651
  011				9600						5208				326
  100				19200						2604				163
  101				38400						1302				81
  110				57600						868					54
  111				115200						434					27
  	
    
  */
  
  
  
  
  // Set max_count depending on baud_select
  reg [13:0] max_count;
  always @ (baud_select)
    begin
      case(baud_select)
      3'b000: max_count = 10417;
      3'b001: max_count = 2604;
      3'b010: max_count = 651;
      3'b011: max_count = 326;
      3'b100: max_count = 163;
      3'b101: max_count = 81;
      3'b110: max_count = 54;
      3'b111: max_count = 27;
//       3'b111: max_count = 7; 	// TO be able to show the results in the time limit
        default max_count = 13'bXXXXXXXXXXXXX ; 
      endcase
    end
  
  
  
  
  // count up to max_count and then reset the counter and make a pulse for sampling
  reg [13:0] sample_counter ; 
  
  always @ (posedge clk or posedge reset) 
    begin
      if (reset) begin 
        sample_counter = 0;
        sample_ENABLE = 0;
      end
      else if ( sample_counter == max_count-1 ) begin
        sample_counter = 0 ; 
      	sample_ENABLE = 1 ; 
    	end
  		else begin
          
      		sample_ENABLE = 0 ; 
          sample_counter = sample_counter + 1 ; 
  		end
      
    end
  
  
  

endmodule


`endif //BAUDCONTROLLER