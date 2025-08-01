

// Wrapper for AES key expansion module
aes_pkg::sp2v_e en,out_valid,out_ack;
  assign out_ack =  _ep_le_req_valid && (out_valid == aes_pkg::SP2V_HIGH) ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
  assign en = _ep_le_init_valid ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
  
  // Simulate req_ack as always high for this simple test
  assign _ep_le_req_ack = 1'b1;

  // Convert 256-bit key to 8x32 format for OpenTitan
  logic [7:0][31:0] key_input [1];
  logic [7:0][31:0] key_output [1];
  
  // Pack the key correctly
  always_comb begin
    for (int i = 0; i < 8; i++) begin
      key_input[0][i] = _ep_le_req_0[9 + i*32 +: 32];
    end
  end
  
  // Pack output key
  always_comb begin
    for (int i = 0; i < 8; i++) begin
      _ep_le_res_0[i*32 +: 32] = key_output[0][i];
    end
    _ep_le_res_0[256] = 1'b0; // err_o
  end

   aes_key_expand #(
    .AES192Enable (0),
    .SecMasking   (0),
    .SecSBoxImpl  (aes_pkg::SBoxImplLut)
   ) dut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .cfg_valid_i (1'b1),
    .op_i (aes_pkg::ciph_op_e'(_ep_le_init_0[4:3])),
    .en_i (en),
    .prd_we_i (1'b0),
    .out_req_o (out_valid),
    .out_ack_i (out_ack),
    .clear_i (_ep_le_init_0[0]),
    .round_i (_ep_le_req_0[5+:4]),
    .key_len_i(aes_pkg::AES_128),
    .key_i(key_input),
    .prd_i(32'h0),
    .key_o(key_output),
    .err_o ()
);
    



