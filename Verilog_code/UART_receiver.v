`include "counter.v"
`include "baudcontroller.v"
  
module UART_receiver(
 	input reset, clk, 			// Those are for the baude controller as input  
    input [2:0] baud_select, 	// Select baud rate   
	input Rx_EN,				// Enable the chip  
  	input Rx_D,					// Serial data in 
    
  	output reg [7:0] Rx_DATA,  	// Data to send/transmit  
    output reg Rx_FERROR,		// Framing Error 
    output reg Rx_PERROR,		// Parity Error
    output reg Rx_VALID			// Rx_DATA is Valid 
  );
   
  
  
  
  
  wire result_clock_to_sample ; 		// Count 16 of those then change the output
  
  BaudController  transmitter_baud_controller( reset , clk , baud_select , result_clock_to_sample ) ;
  	
  	// The states
	parameter 	s_idle 		= 4'b0000,
                s_bit_begin = 4'b0001, 
                s_bit_0		= 4'b0010,
                s_bit_1		= 4'b0011,
                s_bit_2		= 4'b0100,
                s_bit_3		= 4'b0101,
                s_bit_4		= 4'b0110,
                s_bit_5		= 4'b0111,
                s_bit_6		= 4'b1000,
                s_bit_7		= 4'b1001,
                s_bit_par	= 4'b1010,
                s_bit_stop	= 4'b1011;
  
  
  parameter 	sample_number_1			= 4'h0,
                sample_number_2			= 4'h1,
                sample_number_3			= 4'h2,
                sample_number_4			= 4'h3,
                sample_number_5			= 4'h4,
                sample_number_6			= 4'h5,
                sample_number_7			= 4'h6,
                sample_number_8			= 4'h7,
                sample_number_9			= 4'h8,
                sample_number_10		= 4'h9,
                sample_number_11		= 4'ha,
                sample_number_12		= 4'hb,
                sample_number_13		= 4'hc,
                sample_number_14		= 4'hd,
                sample_number_15		= 4'he,
                sample_number_16		= 4'hf;
  
  
  reg [3:0] current_state_bit ;
  reg [3:0] next_state_bit ;
  
  reg [3:0] current_state_sample_id ; 
  reg [3:0] next_state_sample_id ;
  
  
  // Do the state change
  always@( posedge result_clock_to_sample or posedge reset)
    begin: STATE_MEMORY
      if(reset) begin
        current_state_bit 		<= s_idle ; 
        current_state_sample_id <= sample_number_1 ;
        Rx_FERROR = 0 ; 
        Rx_PERROR = 0 ;    
        Rx_VALID  = 0 ; 
      end
      else	if (  Rx_EN ) begin       
        current_state_bit 		<= next_state_bit ; 
        current_state_sample_id <= next_state_sample_id ;                
      end
    end
  
  
  
  // Leave idle state immediately when input goes low
  always @ ( negedge Rx_D)
    begin : START_RECEIVER_LOGIC
      	
      if ( current_state_bit == s_idle ) begin
        	//$display("Negedge Rx_D so start receiving");
        	current_state_bit 		<= s_bit_begin ; 
        	current_state_sample_id	<= sample_number_1;
      end
    end
  
  
  // Find the next state 
  always @ ( current_state_bit or current_state_sample_id )
    begin : NEXT_STATE_LOGIC
      
        // We start from s_idle and sample_number_1

      	if (  current_state_bit == s_idle ) begin 
            next_state_bit 			<= s_idle; 
            next_state_sample_id 	<= sample_number_1;
        end
        else if ( current_state_bit == s_bit_stop & current_state_sample_id == sample_number_16) begin
            next_state_bit 			<= s_idle ; 
            next_state_sample_id 	<= sample_number_1;
        end
        else if ( current_state_sample_id == sample_number_16 ) begin
 			next_state_bit 			<= current_state_bit + 1 ; 
            next_state_sample_id 	<= sample_number_1;
        end
      	else begin
 			next_state_bit 			<= current_state_bit ; 
            next_state_sample_id 	<= current_state_sample_id + 1 ;          
        end
      
      
      
    end
    
  
  
  
  
  
  
    
  reg [15:0] samples ; 
  reg [3:0] sum_of_some_samples ;
  reg pairity_found ; 
  
  reg condition1 ,condition2 ,condition3,conditions_together ; 
  reg [14:1] values_of_samples,values_of_samples_reverced ; 	
  
  always @ ( current_state_sample_id or current_state_bit ) 
    begin
      if ( Rx_EN ) begin    
        
        
        
        if ( current_state_bit != s_idle ) begin
          // If not idle take a sample 
          if ( current_state_bit == s_bit_begin) begin
            	Rx_VALID = 0 ; 
                if ( current_state_sample_id == sample_number_1) begin
                  	//$display(" Reset the FERROR kai PERROR");
                    Rx_FERROR = 0 ;
                    Rx_PERROR = 0 ;
                end
          end
            
          samples[current_state_sample_id] = Rx_D ; 
          
          
          if ( current_state_sample_id == 15 ) begin
            	
            	// Check that all the 14 samples in the middle are the same 
                condition1 = samples[14:1] == 0 ;
                condition2 = samples[14:1] == 14'h3fff ;
            	conditions_together = ~(condition1 |condition2) ;
				// If there was an error before or there is one now
                Rx_FERROR = Rx_FERROR |  conditions_together  ;  
				
            	// Sum of the sumples (to check for the majority)
                sum_of_some_samples =  samples[1] + samples[2] + samples[3] + samples[4] + samples[5] + samples[6] + samples[7] + samples[8] + samples[9] + 										samples[10] + samples[11] + samples[12] + samples[13] + samples[14] ; 

            
            	// If the state is reading a data bit (not the start pairity or the stop bit)
                if( current_state_bit - 2 >= 0 & current_state_bit - 2 <= 7) begin
                  	// If most of them are high assume 1 was send
                    if ( sum_of_some_samples >= 7 ) begin
                      Rx_DATA[current_state_bit - 2] =  1  ; 
                    end
                  	// If most of them are low assume 0 was send
                    else begin              
                      Rx_DATA[current_state_bit - 2] =  0  ; 
                    end
                end
            
            	// If it is the pairity bit check it is correct
            	if ( current_state_bit == s_bit_par) begin
                  	// calculate the parity of the data received 
                  	pairity_found = Rx_DATA[0] ^ Rx_DATA[1] ^ Rx_DATA[2] ^ Rx_DATA[3] ^ Rx_DATA[4] ^ Rx_DATA[5] ^ Rx_DATA[6] ^ Rx_DATA[7] ;
                    // Assume if the received pairity bit was a 0 or an 1
                    // Then check if the pairity bit received is differend than the calcuated
                  	Rx_PERROR = pairity_found != (sum_of_some_samples >= 7) ;
                end
            
            	// If it is the stop bit 
                if ( current_state_bit == s_bit_stop ) begin 
                  
                  	// If most of them are low assume 0 was send for the stop bit
                  	// Thus there is a frame error
                  	if (sum_of_some_samples < 7) begin
                      	Rx_FERROR = 1 ;
                    end
                  	
                  	// If no error occured then the data are valid
                  	Rx_VALID = ~ ( Rx_PERROR | Rx_FERROR )  ;
                  
                end
          end // End : if ( current_state_sample_id == 15 ) begin
          
            
            
            
        end  	// End : if ( current_state_bit != s_idle ) begin
      end 		// End : if  ( Rx_EN ) begin
    end			// End : always block begin
  
    

  
endmodule


// Extra stuff to copy paste for tests


  
//  sum_of_some_samples =  samples[1] + samples[2] + samples[3] + samples[4] + samples[5] + samples[6] + samples[7] + samples[8] + samples[9] + samples[10] + samples[11] + samples[12] + samples[13] + samples[14] ; 
  
  
//   Rx_DATA[0] ^ Rx_DATA[1] ^ Rx_DATA[2] ^ Rx_DATA[3] ^ Rx_DATA[4] ^ Rx_DATA[5] ^ Rx_DATA[6] ^ Rx_DATA[7] ;
  
//   samples[0] +
//   samples[1] +
//   samples[2] +
//   samples[3] +
//   samples[4] +
//   samples[5] +
//   samples[6] +
//   samples[7] +
//   samples[8] +
//   samples[9] +
//   samples[10] +
//   samples[11] +
//   samples[12] +
//   samples[13] +
//   samples[14] +
//   samples[15] +
  












