

// Wrapper for AES key expansion module

module aes_sub_bytes_wrapper(
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  input logic[129:0] _ep_req_0,
  input logic[0:0] _ep_req_valid,
  output logic[127:0] _ep_res_0
);
aes_pkg::sp2v_e out_valid, out_ack,en;
assign out_ack = out_valid == aes_pkg::SP2V_HIGH ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
assign en = _ep_req_valid ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;

aes_sub_bytes #(
  .SecSBoxImpl(aes_pkg::SBoxImplLut)
) dut (
  .clk_i,
  .rst_ni,
  .en_i(en),
  .out_req_o(out_valid),
  .out_ack_i(out_ack),
  .op_i(_ep_req_0[0+:2]),
  .data_i(_ep_req_0[2+:128]),
  .mask_i('0),
  .prd_i(0),
  .data_o(_ep_res_0),
  .mask_o(),
  .err_o()
);

endmodule 
module aes_key_expand_wrapper (
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  input logic[0:0] _ep_init_valid,
  input logic[4:0] _ep_init_0,
  output logic[0:0] _ep_req_ack,
  input logic[0:0] _ep_req_valid,
  input logic[264:0] _ep_req_0,
  output logic[256:0] _ep_res_0
);

          aes_pkg::sp2v_e en,out_valid,out_ack;
          assign out_ack =  _ep_req_valid && (out_valid == aes_pkg::SP2V_HIGH) ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
          assign en = _ep_req_valid ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
          
          // Simulate req_ack as always high for this simple test
          assign _ep_req_ack = 1'b1;

          // Convert 256-bit key to 8x32 format for OpenTitan
          logic [7:0][31:0] key_input [1];
          logic [7:0][31:0] key_output [1];
          
          // Pack the key correctly
          always_comb begin
            for (int i = 0; i < 8; i++) begin
              key_input[0][i] = _ep_req_0[9 + i*32 +: 32];
            end
          end
          
          // Pack output key
          always_comb begin
            for (int i = 0; i < 8; i++) begin
              _ep_res_0[((i*32)+1) +: 32] = key_output[0][i];
            end
            _ep_res_0[0] = 1'b0; // err_o
          end

          aes_key_expand #(
            .AES192Enable (0),
            .SecMasking   (0),
            .SecSBoxImpl  (aes_pkg::SBoxImplLut)
          ) dut (
            .clk_i(clk_i),
            .rst_ni(rst_ni),
            .cfg_valid_i (1'b1),
            .op_i (aes_pkg::ciph_op_e'(_ep_init_0[4:3])),
            .en_i (en),
            .prd_we_i (1'b0),
            .out_req_o (out_valid),
            .out_ack_i (out_ack),
            .clear_i (_ep_init_valid),
            .round_i (_ep_req_0[5+:4]),
            .key_len_i(aes_pkg::AES_128),
            .key_i(key_input),
            .prd_i(32'h0),
            .key_o(key_output),
            .err_o ()
        );

endmodule



module aes_shift_rows_wrapper(
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  input logic[129:0] _ep_req_0,
  output logic[127:0] _ep_res_0
);
aes_pkg::sp2v_e out_valid, out_ack;
assign out_ack = out_valid == aes_pkg::SP2V_HIGH ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
aes_shift_rows dut (
  .op_i(_ep_req_0[0+:2]),
  .data_i(_ep_req_0[2+:128]),
  .data_o(_ep_res_0)
);

endmodule


module aes_mix_columns_wrapper(
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  input logic[129:0] _ep_req_0,
  output logic[127:0] _ep_res_0
);
aes_pkg::sp2v_e out_valid, out_ack;
assign out_ack = out_valid == aes_pkg::SP2V_HIGH ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
aes_mix_columns dut(
  .op_i(_ep_req_0[0+:2]),
  .data_i(_ep_req_0[2+:128]),
  .data_o(_ep_res_0)
);

endmodule


module aes_cipher_core_wrapper (
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  output logic[0:0] _ep_dec_key_gen_req_ack,
  input logic[0:0] _ep_dec_key_gen_req_valid,
  input logic[0:0] _ep_dec_key_gen_req_0,
  input logic[255:0] _ep_key_pack_0,
  input logic[2:0] _ep_key_len_i_0,
  output logic[0:0] _ep_crypt_ack,
  input logic[0:0] _ep_crypt_valid,
  input logic[127:0] _ep_crypt_0,
  input logic[2:0] _ep_ctrl_0,
  input logic[0:0] _ep_res_ack,
  output logic[0:0] _ep_res_valid,
  output logic[133:0] _ep_res_0,
  input logic[0:0] _entr_ep_req_ack,
  output logic[0:0] _entr_ep_req_valid,
  output logic[0:0] _entr_ep_req_0,
  input logic[127:0] _entr_ep_res_0
);




  aes_pkg::sp2v_e                       in_valid_i;
 aes_pkg::sp2v_e                       in_ready_o;
assign in_valid_i = (_ep_crypt_valid | _ep_dec_key_gen_req_valid)&(in_ready_o == aes_pkg::SP2V_HIGH) ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
assign _ep_crypt_ack = in_ready_o == aes_pkg::SP2V_HIGH && _ep_crypt_valid == 1'd1 ? 1'b1 : 1'b0;
assign _ep_dec_key_gen_req_ack = in_ready_o == aes_pkg::SP2V_HIGH && _ep_dec_key_gen_req_valid == 1'd1 ? 1'b1 : 1'b0;

   


   
  
  
 aes_pkg::sp2v_e                       out_valid_o;
   aes_pkg::sp2v_e                       out_ready_i;

  assign out_ready_i = (out_valid_o == aes_pkg::SP2V_HIGH && _ep_res_ack == 1'd1) ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
  assign _ep_res_valid = (out_valid_o == aes_pkg::SP2V_HIGH) ? 1'b1 : 1'b0;

   


  // Control and sync signals
   
   aes_pkg::ciph_op_e                    op_i;
   assign op_i = aes_pkg::ciph_op_e'(_ep_ctrl_0[0+:2]);

    aes_pkg::sp2v_e                       crypt_i;
    assign crypt_i = (_ep_crypt_valid) ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;

   aes_pkg::sp2v_e                       crypt_o;
   assign _ep_res_0[3+:3] = crypt_o;
  


   
    aes_pkg::sp2v_e                       dec_key_gen_i;
    assign dec_key_gen_i = (_ep_dec_key_gen_req_valid) ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;

   aes_pkg::sp2v_e                       dec_key_gen_o;
   assign _ep_res_0[0+:3] = dec_key_gen_o;
  

    
   
  
 
  logic                        data_out_clear_i; // Re-use the cipher core muxes.

 logic                        data_out_clear_o;
  logic                        alert_fatal_i;

 logic                        alert_o;
logic        [3:0][3:0][7:0] state_init_i [1];

    assign state_init_i[0] = _ep_crypt_0;

   logic            [7:0][31:0] key_init_i [1];
  assign key_init_i[0] = _ep_key_pack_0[0+:256];

  logic        [3:0][3:0][7:0] state_o [1];
  assign _ep_res_0[6+:128] = state_o[0];

  

aes_cipher_core #(
  .AES192Enable(0),
  .CiphOpFwdOnly(0),
  .SecMasking(0),
  .SecSBoxImpl(aes_pkg::SBoxImplLut),
  .SecAllowForcingMasks(0),
  .SecSkipPRNGReseeding(0),
  .EntropyWidth(128)
) dut_core (
  .clk_i,
  .rst_ni,
  .cfg_valid_i(1'b1), // Always valid for this wrapper
  .in_valid_i(in_valid_i),
  .in_ready_o(in_ready_o),
  .out_valid_o(out_valid_o),
  .out_ready_i(out_ready_i),
  .op_i(op_i),
  .key_len_i(aes_pkg::key_len_e'(_ep_key_len_i_0)),
  .crypt_i(crypt_i),
  .crypt_o(crypt_o),
  .dec_key_gen_i(dec_key_gen_i),
  .dec_key_gen_o(dec_key_gen_o),

  .prng_reseed_i('0),
  .prng_reseed_o(),
  .key_clear_i('0),
  .key_clear_o(),
  .data_out_clear_i('0),
  .data_out_clear_o(),
  .alert_fatal_i('0),
  .alert_o(),
  .prd_clearing_state_i('{default: '0}),
  .prd_clearing_key_i('{default: '0}),
  .force_masks_i(1'b0), // Not used in this wrapper
  .data_in_mask_o(), // Not used in this wrapper
  .entropy_req_o(), // Not used in this wrapper
  .entropy_ack_i(),
  .entropy_i(128'h0), // Not used in this wrapper
  .state_init_i(state_init_i),
  .key_init_i(key_init_i),
  .state_o(state_o)
);




endmodule