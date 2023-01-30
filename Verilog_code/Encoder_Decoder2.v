

module Encoder_Decoder2(
  input [7:0] data_to_encode_or_decode ,
  output [7:0] encoded_or_decoded_data
	);
  
  
  
  // Second option to encode/decode
  
  assign 	encoded_or_decoded_data[0] = 	~ data_to_encode_or_decode[7];
  assign 	encoded_or_decoded_data[1] = 	~ data_to_encode_or_decode[6];
  assign 	encoded_or_decoded_data[2] = 	~ data_to_encode_or_decode[5];
  assign 	encoded_or_decoded_data[3] = 	~ data_to_encode_or_decode[4];
  assign 	encoded_or_decoded_data[4] = 	~ data_to_encode_or_decode[3];
  assign 	encoded_or_decoded_data[5] = 	~ data_to_encode_or_decode[2];
  assign 	encoded_or_decoded_data[6] = 	~ data_to_encode_or_decode[1];
  assign 	encoded_or_decoded_data[7] = 	~ data_to_encode_or_decode[0];
  
                        
endmodule