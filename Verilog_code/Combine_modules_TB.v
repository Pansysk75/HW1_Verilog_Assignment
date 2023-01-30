`timescale 1ns/1ps



`include "Encoder_Decoder1.v"
`include "Encoder_Decoder2.v"
`include "Encoder_Decoder3.v"

`include "UART_transmitter.v"
`include "UART_receiver.v"


`include "leddriver.v"


module Combine_modules_TB;
  
  
  reg global_clk, global_reset;
  
  parameter Times_to_send = 4  - 1 ; 
  reg [31:0] i ; 
  // 16 bits for the display, and Times_to_send for 
  reg [15:0] all_data_to_send[Times_to_send:0] ; 
  
  reg [15:0] current_data_to_send;
  
  
  reg [2:0] baud_select 		=  3'b111 ; 
  reg [2:0] trans_baud_select 	=  3'b111 ; 
  reg [2:0] receive_baud_select =  3'b111 ; 
  
  
  
  reg trans_EN = 1 ;
  reg receive_EN = 1 ;
  
  
  reg [7:0] current_Byte_to_send ; 
  
  // trans stuff (By syskakis) 
  reg trans_write = 0 ; 
  wire [7:0] trans_data_in ; 
  wire trans_data_out ;   
  wire trans_busy ; 
  
  // recevive stuff 
  reg receive_data_in ; 
  wire [7:0] receive_data ;
  wire receive_FERROR ;
  wire receive_PERROR ;
  wire receive_VALID ;
  
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~ Start Encoder-Decoder Stuff ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  // Main encoder I/O
  reg  [7:0]  input_encoder ;
  wire [7:0] output_encoder ;
  
  // Main decoder I/O
  reg  [7:0]  input_decoder ;
  wire [7:0] output_decoder ;
  
  // Encoders
  wire [7:0]  encoder_input1,   encoder_input2,   encoder_input3 ;
  wire [7:0] encoder_output1,  encoder_output2,  encoder_output3 ;  
  
  // Decoders
  wire [7:0]  decoder_input1,   decoder_input2,   decoder_input3 ;  
  wire [7:0] decoder_output1,  decoder_output2,  decoder_output3 ;
  
  
  assign encoder_input1 = input_encoder   ; // Main input to encode
  assign encoder_input2 = encoder_output1 ;
  assign encoder_input3 = encoder_output2 ; 
  assign output_encoder = encoder_output3 ;	// Main output of encode
  
  assign decoder_input3 = input_decoder   ; // Main input to decode
  assign decoder_input2 = decoder_output3 ; 
  assign decoder_input1 = decoder_output2 ;   
  assign output_decoder	= decoder_output1 ;	// Main output of decode
  
  Encoder_Decoder1 object_encoder1(encoder_input1, encoder_output1 ) ;
  Encoder_Decoder2 object_encoder2(encoder_input2, encoder_output2 ) ;
  Encoder_Decoder3 object_encoder3(encoder_input3, encoder_output3 ) ;
  
  
  Encoder_Decoder3 object_decoder3(decoder_input3, decoder_output3 ) ;
  Encoder_Decoder2 object_decoder2(decoder_input2, decoder_output2 ) ;
  Encoder_Decoder1 object_decoder1(decoder_input1, decoder_output1 ) ;
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~ End Encoder-Decoder Stuff ~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  
  
  // Transmitter
  UART_transmitter object_transmitter( global_reset , global_clk , trans_data_in , trans_baud_select , trans_EN , trans_write , trans_data_out, trans_busy);
  
  // Receiver
  UART_receiver object_receiver ( global_reset , global_clk ,receive_baud_select , receive_EN , receive_data_in , receive_data , receive_FERROR,  receive_PERROR, receive_VALID ) ;
  
  
  
  always @( trans_data_out ) begin 
    	receive_data_in = trans_data_out ; // For wrong receiving (to test the errors) use a "~" infrond of the trans_data_out
  end
  
  
  always @( receive_data ) begin 
    	input_decoder = receive_data ; 
  end
  
  
  // Set input to transmitter the output of the encoder
  assign trans_data_in = output_encoder ; 
  
  
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ LED Driver ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  reg [3:0] digit0, digit1, digit2, digit3;
  wire an3, an2, an1, an0;
  wire a,b,c,d,e,f,g;
  
  FourDigitLEDdriver object_driver_TB(global_reset, global_clk,
                               digit3, digit2, digit1, digit0,
                               an3, an2, an1, an0,
                               a,b,c,d,e,f,g
                              );
  
  
  
  reg MSB ;
  
  reg [15:0] current_data_to_display ; 
  
  reg Error_in_MSB ; 
  reg has_there_been_an_Error ; 
  
  always @( posedge global_reset ) begin
    	MSB = 1 ;
        digit3 = 4'hc ; 
    	digit2 = 4'hc ; 
        digit1 = 4'hc ; 
    	digit0 = 4'hc ; 
    	current_data_to_display = 16'hcccc;
    	Error_in_MSB = 0 ; 
    	has_there_been_an_Error = 0 ; 
  end
  
  
  // Reset the error for the next frame
  always @( negedge receive_FERROR or negedge receive_PERROR) begin     	
      	has_there_been_an_Error = 0 ; 
  end
  
           
  always @( posedge receive_VALID or posedge receive_FERROR or posedge receive_PERROR ) begin
    	
    if ( receive_VALID ) begin
      	has_there_been_an_Error = 0 ; // This is redundant 
      
      	if ( MSB == 1 ) begin
          	// Store the MSB
          	current_data_to_display[15:8] = output_decoder ;  
          	Error_in_MSB = 0 ; 
        end 
      	else begin
            if ( Error_in_MSB == 0 )  begin 
                // Store the LSB
                current_data_to_display[7:0]  = output_decoder ;  
            end
            else begin
                // Store FF in the LSB as well
                current_data_to_display[7:0]  = 8'hFF ;
            end
            
            
          	// Send the data to the display 
          	{digit3,digit2,digit1,digit0} = current_data_to_display ;
		end
      
      	// Change MSB
      	MSB = ~ MSB ; 
    end
    
    
    // Check if there already has been an error
    else if ( has_there_been_an_Error == 0 ) begin
      	has_there_been_an_Error = 1 ; 
      	
      	
      
      	// Copy pasta from above 
      	if ( MSB == 1 ) begin
          	// Store FF in the MSB
          	current_data_to_display[15:8] = 8'hFF ;  
           	Error_in_MSB = 1 ; 
        end 
      	else begin
          	// Store FF in the LSB and overwrite the MSB with FF 
            current_data_to_display  = 16'hFFFF ;  
          
          	// Send the data to the display 
          	{digit3,digit2,digit1,digit0} = current_data_to_display ;
		end
      
      	// Change MSB
      	MSB = ~ MSB ; 
      
    end
    
    
  end
   
  
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    //$dumpvars;
    $dumpvars(2, Combine_modules_TB);
    //$dumplimit(1*2**10*2**10*2**10);
    
    global_clk = 0;
    global_reset = 0;
    
    // Initialize the data (since they can not be dynamic) 
    all_data_to_send[0]= 16'hab12 ;
    all_data_to_send[1]= 16'h3b56 ;
    all_data_to_send[2]= 16'ha574 ;
    all_data_to_send[3]= 16'h0b89 ;
    
    
    // reset 
    @( posedge global_clk ) global_reset = 1;    
    @( negedge global_clk ) global_reset = 0;
    // reset
    @( posedge global_clk ) global_reset = 1;    
    @( negedge global_clk ) global_reset = 0;
    
   
    
    
    for (i = 0 ; i <= Times_to_send ; i=i+1) begin
      
//       	if ( i == 1 ) begin
// 			$dumpon;
//         end
//       	else begin
//         	$dumpoff;
//       	end
    	
     	@( posedge global_clk )  ;
      	// Set the data that the 'sensor' wants to send
      	current_data_to_send = all_data_to_send[i] ;
      
      
      	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Set Byte to Send ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      	// Send the 8 MSB first
      	current_Byte_to_send = current_data_to_send[15:8] ;
      
      	// Give the MSB (an3 an2) Byte to the encoder 
      	input_encoder = current_Byte_to_send ;
      
      	
      		
      	// write 
      	@( posedge global_clk ) trans_write = 1 ;       	
      	@( negedge global_clk ) trans_write = 0 ; 
      
      	// Wait for them to be sent => Busy low
      	@( negedge trans_busy );
      
      	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Set Byte to Send ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      	
      	// Send the 8 LSB first
      	current_Byte_to_send = current_data_to_send[7:0] ;      
      
      
      	// Give the LSB (an1 an0) Byte to the encoder 
      	input_encoder = current_Byte_to_send ;
      
      
      	// write 
      	@( posedge global_clk ) trans_write = 1 ;       	
      	@( negedge global_clk ) trans_write = 0 ; 
      
      	// Wait for them to be sent => Busy low
      	@( negedge trans_busy );
    
    end
    
    
    
    @( posedge global_clk );
    @( posedge global_clk );
    
    
    $finish;
    
  end

  
  
  always #10 global_clk = ~global_clk;
  
  
  
  
  
  
  
  
endmodule
