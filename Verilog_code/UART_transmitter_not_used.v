
`include "baudcontroller.v"

`include "counter.v"
  

// Tests that we did not use. It kinda works but it hasn't been thorough tested as the other more like FSM transmitter

module UART_transmitter(
 	input reset, clk, 			// Those are for the baude controller as input
    input [7:0] Tx_DATA,  		// Data to send/transmit
    input [2:0] baud_select, 	// Select baud rate 
    input Tx_EN,				// Enable the chip
    input Tx_WR,				// High when data are ready in the input
    output reg Tx_D,			// Serial data transmission main output
    output reg Tx_BUSY			// Is the transmitter busy (to know not to change the input etc)
  );
    
  
  
  wire result_clock_to_sample ; 		// Count 16 of those then change the output
  wire [3:0] number_of_sampeling_cycles; // This counts the 16 of the above
  reg reset_counter = 0 ; 
  
  BaudController  transmitter_baud_controller( reset , clk , baud_select , result_clock_to_sample ) ;
  
  counter counter_to_send (reset_counter|reset , result_clock_to_sample , number_of_sampeling_cycles ) ;
  
  
  // Stores the data when we write to the transmitter (and then sends them 
  reg [7:0] stored_data_to_send	; 
  reg [10:0] bits_11_to_send ;
  
  // Reset
  always @ ( posedge reset)
    begin
      	Tx_BUSY = 0 ; 
        if ( Tx_EN == 1 ) begin
          Tx_D 	= 1 ;  	// So the default value, when we start to send it will go low for the start bit
          stored_data_to_send = 8'h00 ;
        end else begin
          Tx_D 	= 0 ;	// If the chip is not enabled then set it to zero 
    	end
    end
  
  
  // Write data to the transmiter 
  always @ ( posedge Tx_WR ) 
    begin
      if ( Tx_EN == 1 ) begin
      	stored_data_to_send = Tx_DATA ;
        
        bits_11_to_send[0] = 0 ; 
        bits_11_to_send[8:1] = stored_data_to_send ;

        // The pairity bit 
        bits_11_to_send[9] =    (stored_data_to_send[0] ^  stored_data_to_send[1] ^  stored_data_to_send[2] ^  stored_data_to_send[3] ^  stored_data_to_send[4] ^  stored_data_to_send[5] ^  stored_data_to_send[6] ^  stored_data_to_send[7 ] );
        bits_11_to_send[10] = 1 ; 
        
        
        Tx_BUSY = 1 ; 
      end
    end
  
  
  
  reg start_sending ;
  // Start sending singal
  always @ ( posedge Tx_BUSY ) 
    begin
		if ( Tx_EN == 1 ) begin
        	start_sending = 1 ;
          	reset_counter = 1 ; // How many cycles of the 16 have passed make them zero 
          	reset_bit_send = 1 ; // bit to send id
            change_send_bit = 0  ; 
            reset_counter = 0 ; // How many cycles of the 16 have passed make them zero 
            reset_bit_send = 0 ; // bit to send id
        end else begin
        	start_sending = 0 ;
      		reset_counter = 0 ;
          	reset_bit_send = 0 ; 
    	end
    end
  
  
  	reg reset_bit_send;
  wire [3:0] bit_to_send ; 
  reg change_send_bit ; 
  counter counter_bit_that_is_send (reset_bit_send|reset , change_send_bit , bit_to_send ) ;
  
  // Reset the above counter when we are at 11 bits
  always @ ( bit_to_send , change_send_bit ) 
    begin
      	if (bit_to_send == 11 ) begin
        	reset_bit_send = 1 ;
      	end else begin
        	reset_bit_send = 0 ;
    	end
    end
  
  
  // Do the sending
  always @ ( posedge result_clock_to_sample ) 
    begin
      if (start_sending == 1) begin
       	
         
        
        if ( number_of_sampeling_cycles == 15)
          begin
            // change symbol beeing send 
            change_send_bit = 1 ;
          end
        else begin
          	change_send_bit = 0 ; 
        end
        
        Tx_D = bits_11_to_send[bit_to_send] ;
        
      end
      
    end
  
  
  
  

  
  
  
endmodule