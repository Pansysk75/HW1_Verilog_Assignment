`timescale 1ns/1ps

`include "UART_transmitter.v"
`include "UART_receiver.v"

module Test_error_Receiver_TB;
  
  
  
  reg global_clk, global_reset;
  
  reg [7:0] data_to_send ; 
  reg [2:0] baud_select =  3'b111 ; 
  reg write = 0 ; 
  
  wire data_out_of_transm ; 
  wire transm_busy ; 
  
  wire [7:0] data_received ;
  wire Receive_FERROR ;
  wire Receive_PERROR ;
  wire Receive_VALID ;
  
  
  UART_transmitter object_transmitter( global_reset , global_clk , data_to_send , baud_select , 1 , write , data_out_of_transm, transm_busy);
  
  
  
  UART_receiver object_receiver ( global_reset , global_clk ,baud_select , 1, ~ data_out_of_transm , data_received , Receive_FERROR,  Receive_PERROR,Receive_VALID ) ;
  
  
  
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    
    global_clk = 0;
    global_reset = 0;
    
    
    // reset 
    @( posedge global_clk ) global_reset = 1;    
    @( negedge global_clk ) global_reset = 0;
    @( posedge global_clk ) global_reset = 1;    
    @( negedge global_clk ) global_reset = 0;
    
    
    @( posedge global_clk ) ;
    @( posedge global_clk ) ;  
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Set Data to Send 1 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data_to_send = 8'hFA;
    // Wait 2 clock cycles to write 
    
    @( posedge global_clk ) ;
    @( posedge global_clk ) ;  
    write = 1 ; 
    // Keep write high as long as the clock is high (half a period clock)
    @( negedge global_clk ) ; 
    write = 0 ; 
    
    
    // Wait the data to be transmitted before trying to send the next
     @( negedge transm_busy ) ; 
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Set Data to Send 2 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data_to_send = 8'h07;
    // Wait 2 clock cycles to write 
    
    @( posedge global_clk ) ;
    @( posedge global_clk ) ;  
    write = 1 ; 
    // Keep write high as long as the clock is high (half a period clock)
    @( negedge global_clk ) ; 
    write = 0 ; 
    
    
    // Wait the data to be transmitted before trying to send the next
     @( negedge transm_busy ) ; 
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Set Data to Send 3 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data_to_send = 8'hc4;
    // Wait 2 clock cycles to write 
    
    @( posedge global_clk ) ;
    @( posedge global_clk ) ;  
    write = 1 ; 
    // Keep write high as long as the clock is high (half a period clock)
    @( negedge global_clk ) ; 
    write = 0 ; 
    
    
    // Wait the data to be transmitted before trying to send the next
     @( negedge transm_busy ) ; 
    
    
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Set Data to Send 4 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    data_to_send = 8'hFF;
    // Wait 2 clock cycles to write 
    
    @( posedge global_clk ) ;
    @( posedge global_clk ) ;  
    write = 1 ; 
    // Keep write high as long as the clock is high (half a period clock)
    @( negedge global_clk ) ; 
    write = 0 ; 
    
    
    
    
    
    
    // Wait the data to be transmitted before ending the simulation 
     @( negedge transm_busy ) ; 
    
    
    $finish;
  end

  
  always #10 global_clk = ~global_clk;
  
  
  
  
  
  
  
  
endmodule


