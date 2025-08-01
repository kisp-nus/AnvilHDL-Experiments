

// Wrapper for AES key expansion module

module aes_sub_bytes_wrapper(
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  input logic[129:0] _ep_req_0,
  output logic[127:0] _ep_res_0
);
aes_pkg::sp2v_e out_valid, out_ack;
assign out_ack = out_valid == aes_pkg::SP2V_HIGH ? aes_pkg::SP2V_HIGH : aes_pkg::SP2V_LOW;
aes_sub_bytes #(
  .SecSBoxImpl(aes_pkg::SBoxImplLut)
) dut (
  .clk_i,
  .rst_ni,
  .en_i(aes_pkg::SP2V_HIGH),
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