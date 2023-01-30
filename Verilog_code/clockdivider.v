
module ClockDivider
  #(parameter RANK = 1) //How many times the freq of the input clock will be divided by 2
  (input reset, input clk_in, output clk_out);
  
  reg [RANK:0] counter_value;
  assign clk_out = counter_value[RANK]; // The output clk is the msb of the counter
  
  always @ (posedge clk_in)
    begin
      if(reset) counter_value <= 0;
      else counter_value <= counter_value + 1;
    end
endmodule

