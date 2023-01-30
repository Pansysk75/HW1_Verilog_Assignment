`include "counter.v"
`include "baudcontroller.v"

// The trasmitter that is used in this project

module UART_transmitter(
 	input reset, clk, 			// Those are for the baude controller as input
    input [7:0] Tx_DATA,  		// Data to send/transmit
    input [2:0] baud_select, 	// Select baud rate 
    input Tx_EN,				// Enable the chip
    input Tx_WR,				// High when data are ready in the input
    output reg Tx_D,			// Serial data transmission main output
    output reg Tx_BUSY			// Is the transmitter busy (to know not to change the input etc)
  );
   
  
   // Stores the data when we write to the transmitter (and then sends them 
  reg [7:0] stored_data_to_send	; 
  
  wire result_clock_to_sample ; // Count 16 of those then change the output
  BaudController  transmitter_baud_controller( reset , clk , baud_select , result_clock_to_sample ) ;
    
  wire [3:0] tick_count; // We change state every 16 ticks
  counter #(.BITS(4)) tick_counter (reset, result_clock_to_sample, tick_count);
  
  // Set the stored data
  always@(posedge reset or posedge Tx_WR) 
    begin
      if (reset) stored_data_to_send = 0 ;
      else if( Tx_BUSY == 0) stored_data_to_send = Tx_DATA;
      
  	end
  
 
  
  // !!! Implement FSM !!!
  
  reg [3:0] current_state, next_state;
  parameter s_idle 		= 4'b0000,
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
  
  
  always@(tick_count or posedge reset)
    begin: STATE_MEMORY
      if(reset) begin
        current_state <= s_idle;
      end
      else	if (tick_count == 15 & Tx_EN) begin
        current_state <= next_state;
      end
    end
  
  // This is part of the NEXT_STATE_LOGIC
  always @( posedge Tx_WR)
    begin
      if ( current_state == s_idle ) begin
        next_state = current_state + 1;
      end
      
    end
  
  
  always@(current_state )
    begin: NEXT_STATE_LOGIC
      case(current_state)
        s_idle: current_state = current_state ;
        s_bit_stop: next_state = s_idle;
        default: next_state = current_state + 1;
      endcase
    end
  

  always@(current_state)
    begin: OUTPUT_LOGIC
      Tx_BUSY = ~(current_state == s_idle);
      case(current_state)
        s_idle: 		Tx_D = 1;
        s_bit_begin:	Tx_D = 0;
        s_bit_0:		Tx_D = stored_data_to_send[0];
        s_bit_1:		Tx_D = stored_data_to_send[1];
        s_bit_2:		Tx_D = stored_data_to_send[2];
        s_bit_3:		Tx_D = stored_data_to_send[3];
        s_bit_4:		Tx_D = stored_data_to_send[4];
        s_bit_5:		Tx_D = stored_data_to_send[5];
        s_bit_6:		Tx_D = stored_data_to_send[6];
        s_bit_7:		Tx_D = stored_data_to_send[7];
        s_bit_par:		Tx_D = 	stored_data_to_send[0] ^ stored_data_to_send[1] ^ stored_data_to_send[2] ^ stored_data_to_send[3] ^ stored_data_to_send[4] ^ stored_data_to_send[5] ^ stored_data_to_send[6] ^ stored_data_to_send[7];
        s_bit_stop:		Tx_D = 1;
      endcase
    end
  

  
  
  
endmodule