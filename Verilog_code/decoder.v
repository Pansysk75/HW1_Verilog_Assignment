module LEDdecoder(
  input [3:0] char, // input 4-bit coded character
  output reg [6:0] LED // output 7-bit (a, b, c, d, e, f, g) signal                
);
  
	always@(char)
	begin
			
   		case(char)
			4'h0:LED = 7'b0000001;	// 0
			4'h1:LED = 7'b1001111;	// 1
          	4'h2:LED = 7'b1101101;	// 2
            4'h3:LED = 7'b1111001;	// 3
          	4'h4:LED = 7'b0110011;	// 4
          	4'h5:LED = 7'b1011011;	// 5
          	4'h6:LED = 7'b1011111;	// 6
          	4'h7:LED = 7'b1110010;	// 7
          	4'h8:LED = 7'b1111111;	// 8
          	4'h9:LED = 7'b1111011;	// 9
            4'ha:LED = 7'b0000001;	// -
          	// none ^_^
          	4'hc:LED = 7'b1111111;	// " "
            4'hf:LED = 7'b1000111;	// F
          
          	default:LED = 7'b0110000;   // E (error case)
			
		endcase
	end

endmodule