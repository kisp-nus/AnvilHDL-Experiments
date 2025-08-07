module axi_demux_wrapper(
input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  output logic[0:0] _slv_ep_aw_req_ack,
  input logic[0:0] _slv_ep_aw_req_valid,
  input logic[34:0] _slv_ep_aw_req_0,
  input logic[0:0] _slv_ep_aw_sel_0,
  output logic[0:0] _slv_ep_w_req_ack,
  input logic[0:0] _slv_ep_w_req_valid,
  input logic[35:0] _slv_ep_w_req_0,
  input logic[0:0] _slv_ep_b_resp_ack,
  output logic[0:0] _slv_ep_b_resp_valid,
  output logic[1:0] _slv_ep_b_resp_0,
  output logic[0:0] _slv_ep_ar_req_ack,
  input logic[0:0] _slv_ep_ar_req_valid,
  input logic[34:0] _slv_ep_ar_req_0,
  input logic[0:0] _slv_ep_ar_sel_0,
  input logic[0:0] _slv_ep_r_resp_ack,
  output logic[0:0] _slv_ep_r_resp_valid,
  output logic[33:0] _slv_ep_r_resp_0,
  output logic[0:0] _slv_ep_sel_ack,
  input logic[0:0] _slv_ep_sel_valid,
  input logic[0:0] _slv_ep_sel_0,
  input logic[0:0] _mst_ep_0_mst_aw_req_ack,
  output logic[0:0] _mst_ep_0_mst_aw_req_valid,
  output logic[34:0] _mst_ep_0_mst_aw_req_0,
  input logic[0:0] _mst_ep_0_mst_w_req_ack,
  output logic[0:0] _mst_ep_0_mst_w_req_valid,
  output logic[35:0] _mst_ep_0_mst_w_req_0,
  output logic[0:0] _mst_ep_0_mst_b_resp_ack,
  input logic[0:0] _mst_ep_0_mst_b_resp_valid,
  input logic[1:0] _mst_ep_0_mst_b_resp_0,
  input logic[0:0] _mst_ep_0_mst_ar_req_ack,
  output logic[0:0] _mst_ep_0_mst_ar_req_valid,
  output logic[34:0] _mst_ep_0_mst_ar_req_0,
  output logic[0:0] _mst_ep_0_mst_r_resp_ack,
  input logic[0:0] _mst_ep_0_mst_r_resp_valid,
  input logic[33:0] _mst_ep_0_mst_r_resp_0,
  input logic[0:0] _mst_ep_1_mst_aw_req_ack,
  output logic[0:0] _mst_ep_1_mst_aw_req_valid,
  output logic[34:0] _mst_ep_1_mst_aw_req_0,
  input logic[0:0] _mst_ep_1_mst_w_req_ack,
  output logic[0:0] _mst_ep_1_mst_w_req_valid,
  output logic[35:0] _mst_ep_1_mst_w_req_0,
  output logic[0:0] _mst_ep_1_mst_b_resp_ack,
  input logic[0:0] _mst_ep_1_mst_b_resp_valid,
  input logic[1:0] _mst_ep_1_mst_b_resp_0,
  input logic[0:0] _mst_ep_1_mst_ar_req_ack,
  output logic[0:0] _mst_ep_1_mst_ar_req_valid,
  output logic[34:0] _mst_ep_1_mst_ar_req_0,
  output logic[0:0] _mst_ep_1_mst_r_resp_ack,
  input logic[0:0] _mst_ep_1_mst_r_resp_valid,
  input logic[33:0] _mst_ep_1_mst_r_resp_0
);



  localparam int unsigned NoMstPorts     = 2;        // Number of master ports
  localparam int unsigned MaxTrans       = 8;        // Maximum transactions //Check
  localparam bit          FallThrough    = 1'b0;     // FIFO fall through mode
  localparam bit          SpillAw        = 1'b1;     // Spill register on AW
  localparam bit          SpillW         = 1'b1;     // Spill register on W
  localparam bit          SpillB         = 1'b1;     // Spill register on B
  localparam bit          SpillAr        = 1'b1;     // Spill register on AR
  localparam bit          SpillR         = 1'b1;     // Spill register on R
 

localparam int unsigned AxiAddrWidth   = 32;
localparam int unsigned AxiDataWidth   = 32;
localparam int unsigned AxiStrbWidth   = AxiDataWidth / 8;

typedef logic [AxiAddrWidth-1:0] addr_t;
typedef logic [AxiDataWidth-1:0] data_t;
typedef logic [AxiStrbWidth-1:0] strb_t;
typedef logic [$clog2(NoMstPorts)-1:0] select_t;

`AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
`AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
`AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
`AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
`AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
`AXI_LITE_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
`AXI_LITE_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)

//Slave Port Connectios

  axi_req_t  slv_req;
  axi_resp_t slv_resp;
  select_t   slv_aw_select;
  select_t   slv_ar_select;
  axi_req_t  [NoMstPorts-1:0] mst_reqs;
  axi_resp_t [NoMstPorts-1:0] mst_resps;

  assign slv_req = '{
    aw : _slv_ep_aw_req_0,
    aw_valid : _slv_ep_aw_req_valid,
    w : _slv_ep_w_req_0,
    w_valid : _slv_ep_w_req_valid,
    b_ready : _slv_ep_b_resp_ack,
    ar : _slv_ep_ar_req_0,
    ar_valid : _slv_ep_ar_req_valid,
    r_ready : _slv_ep_r_resp_ack
  };


  assign _slv_ep_aw_req_ack = slv_resp.aw_ready;
  assign _slv_ep_ar_req_ack = slv_resp.ar_ready;
  assign _slv_ep_w_req_ack = slv_resp.w_ready;
  assign _slv_ep_b_resp_valid = slv_resp.b_valid;
  assign _slv_ep_b_resp_0 = slv_resp.b;
  assign _slv_ep_r_resp_valid = slv_resp.r_valid;
  assign _slv_ep_r_resp_0 = slv_resp.r;


// Master port connections
  assign _mst_ep_0_mst_aw_req_0 = mst_reqs[0].aw;
  assign _mst_ep_0_mst_aw_req_valid = mst_reqs[0].aw_valid;
  assign _mst_ep_0_mst_w_req_0 = mst_reqs[0].w;
  assign _mst_ep_0_mst_w_req_valid = mst_reqs[0].w_valid;
  assign _mst_ep_0_mst_b_resp_ack = mst_reqs[0].b_ready;
  assign _mst_ep_0_mst_ar_req_0 = mst_reqs[0].ar;
  assign _mst_ep_0_mst_ar_req_valid = mst_reqs[0].ar_valid;
  assign _mst_ep_0_mst_r_resp_ack = mst_reqs[0].r_ready;



  assign _mst_ep_1_mst_aw_req_0 = mst_reqs[1].aw;
  assign _mst_ep_1_mst_aw_req_valid = mst_reqs[1].aw_valid;
  assign _mst_ep_1_mst_w_req_0 = mst_reqs[1].w;
  assign _mst_ep_1_mst_w_req_valid = mst_reqs[1].w_valid;
  assign _mst_ep_1_mst_b_resp_ack = mst_reqs[1].b_ready;
  assign _mst_ep_1_mst_ar_req_0 = mst_reqs[1].ar;
  assign _mst_ep_1_mst_ar_req_valid = mst_reqs[1].ar_valid;
  assign _mst_ep_1_mst_r_resp_ack = mst_reqs[1].r_ready;

  assign slv_aw_select = _slv_ep_aw_sel_0;
  assign slv_ar_select = _slv_ep_ar_sel_0;


assign mst_resps[0] = '{
  aw_ready : _mst_ep_0_mst_aw_req_ack,
  ar_ready : _mst_ep_0_mst_ar_req_ack,
  w_ready : _mst_ep_0_mst_w_req_ack,
  b_valid : _mst_ep_0_mst_b_resp_valid,
  b : _mst_ep_0_mst_b_resp_0,
  r_valid : _mst_ep_0_mst_r_resp_valid,
  r : _mst_ep_0_mst_r_resp_0
};

assign mst_resps[1] = '{
  aw_ready : _mst_ep_1_mst_aw_req_ack,
  ar_ready : _mst_ep_1_mst_ar_req_ack,
  w_ready : _mst_ep_1_mst_w_req_ack,
  b_valid : _mst_ep_1_mst_b_resp_valid,
  b : _mst_ep_1_mst_b_resp_0,
  r_valid : _mst_ep_1_mst_r_resp_valid,
  r : _mst_ep_1_mst_r_resp_0
};


axi_lite_demux #(
    .aw_chan_t   ( aw_chan_t   ),
    .w_chan_t    ( w_chan_t    ),
    .b_chan_t    ( b_chan_t    ),
    .ar_chan_t   ( ar_chan_t   ),
    .r_chan_t    ( r_chan_t    ),
    .axi_req_t   ( axi_req_t   ),
    .axi_resp_t  ( axi_resp_t  ),
    .NoMstPorts  ( NoMstPorts  ),
    .MaxTrans    ( MaxTrans    ),
    .FallThrough ( FallThrough ),
    .SpillAw     ( SpillAw     ),
    .SpillW      ( SpillW      ),
    .SpillB      ( SpillB      ),
    .SpillAr     ( SpillAr     ),
    .SpillR      ( SpillR      )
  ) i_dut (
    .clk_i            ( clk_i          ),
    .rst_ni           ( rst_ni         ),
    .test_i           (1'b0           ), // No test mode
    .slv_aw_select_i  ( slv_aw_select  ),
    .slv_ar_select_i  ( slv_ar_select  ),
    .slv_req_i( slv_req ),
    .slv_resp_o( slv_resp ),
    .mst_reqs_o( mst_reqs ),
    .mst_resps_i( mst_resps )
);
endmodule