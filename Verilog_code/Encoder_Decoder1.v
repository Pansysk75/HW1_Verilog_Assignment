

module Encoder_Decoder1(
  input [7:0] data_to_encode_or_decode ,
  output [7:0] encoded_or_decoded_data
	);
  
  
  // First option to encode/decode
  
  assign encoded_or_decoded_data = ~ data_to_encode_or_decode ; 
  
                        
endmodule



//	//  Another way to make the same thing 
//   genvar i;
//   generate
//     for(i = 7; i>=0; i=i-1) begin
//       assign encoded_or_decoded_data[7-i] = ~ data_to_encode_or_decode[i];
//     end
//   endgenerate
  


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// All the encode-decode option in the 3 files  

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~ First option ~~~~~~~~~~~~~~~~~~~~~~~~~~
  
//   assign encoded_or_decoded_data = ~ data_to_encode_or_decode ; 
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Second option ~~~~~~~~~~~~~~~~~~~~~~~~~~
  
//   assign 	encoded_or_decoded_data[0] = 	~ data_to_encode_or_decode[7];
//   assign 	encoded_or_decoded_data[1] = 	~ data_to_encode_or_decode[6];
//   assign 	encoded_or_decoded_data[2] = 	~ data_to_encode_or_decode[5];
//   assign 	encoded_or_decoded_data[3] = 	~ data_to_encode_or_decode[4];
//   assign 	encoded_or_decoded_data[4] = 	~ data_to_encode_or_decode[3];
//   assign 	encoded_or_decoded_data[5] = 	~ data_to_encode_or_decode[2];
//   assign 	encoded_or_decoded_data[6] = 	~ data_to_encode_or_decode[1];
//   assign 	encoded_or_decoded_data[7] = 	~ data_to_encode_or_decode[0];
  
  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Third  option ~~~~~~~~~~~~~~~~~~~~~~~~~~
  
//   // Flip the first 4
//   assign 	encoded_or_decoded_data[0] = 	~ data_to_encode_or_decode[3];
//   assign 	encoded_or_decoded_data[1] = 	~ data_to_encode_or_decode[2];
//   assign 	encoded_or_decoded_data[2] = 	~ data_to_encode_or_decode[1];
//   assign 	encoded_or_decoded_data[3] = 	~ data_to_encode_or_decode[0];
  
  
//   // Flip the last 4
//   assign 	encoded_or_decoded_data[4] = 	~ data_to_encode_or_decode[7];
//   assign 	encoded_or_decoded_data[5] = 	~ data_to_encode_or_decode[6];
//   assign 	encoded_or_decoded_data[6] = 	~ data_to_encode_or_decode[5];
//   assign 	encoded_or_decoded_data[7] = 	~ data_to_encode_or_decode[4];
  
          
    

  
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Back-up statements ~~~~~~~~~~~~~~~~~~~~~~~~~~
    
//   encoded_or_decoded_data[0] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[1] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[2] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[3] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[4] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[5] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[6] = 	data_to_encode_or_decode[
//   encoded_or_decoded_data[7] = 	data_to_encode_or_decode[
  