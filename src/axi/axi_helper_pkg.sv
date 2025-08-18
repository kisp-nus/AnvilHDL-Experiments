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


module axi_lite_mux_wrapper(
  input logic[0:0] clk_i,
  input logic[0:0] rst_ni,
  output logic[0:0] _slv_ep_0_aw_req_ack,
  input logic[0:0] _slv_ep_0_aw_req_valid,
  input logic[34:0] _slv_ep_0_aw_req_0,
  output logic[0:0] _slv_ep_0_w_req_ack,
  input logic[0:0] _slv_ep_0_w_req_valid,
  input logic[35:0] _slv_ep_0_w_req_0,
  input logic[0:0] _slv_ep_0_b_resp_ack,
  output logic[0:0] _slv_ep_0_b_resp_valid,
  output logic[1:0] _slv_ep_0_b_resp_0,
  output logic[0:0] _slv_ep_0_ar_req_ack,
  input logic[0:0] _slv_ep_0_ar_req_valid,
  input logic[34:0] _slv_ep_0_ar_req_0,
  input logic[0:0] _slv_ep_0_r_resp_ack,
  output logic[0:0] _slv_ep_0_r_resp_valid,
  output logic[33:0] _slv_ep_0_r_resp_0,
  output logic[0:0] _slv_ep_1_aw_req_ack,
  input logic[0:0] _slv_ep_1_aw_req_valid,
  input logic[34:0] _slv_ep_1_aw_req_0,
  output logic[0:0] _slv_ep_1_w_req_ack,
  input logic[0:0] _slv_ep_1_w_req_valid,
  input logic[35:0] _slv_ep_1_w_req_0,
  input logic[0:0] _slv_ep_1_b_resp_ack,
  output logic[0:0] _slv_ep_1_b_resp_valid,
  output logic[1:0] _slv_ep_1_b_resp_0,
  output logic[0:0] _slv_ep_1_ar_req_ack,
  input logic[0:0] _slv_ep_1_ar_req_valid,
  input logic[34:0] _slv_ep_1_ar_req_0,
  input logic[0:0] _slv_ep_1_r_resp_ack,
  output logic[0:0] _slv_ep_1_r_resp_valid,
  output logic[33:0] _slv_ep_1_r_resp_0,
  output logic[0:0] _slv_ep_2_aw_req_ack,
  input logic[0:0] _slv_ep_2_aw_req_valid,
  input logic[34:0] _slv_ep_2_aw_req_0,
  output logic[0:0] _slv_ep_2_w_req_ack,
  input logic[0:0] _slv_ep_2_w_req_valid,
  input logic[35:0] _slv_ep_2_w_req_0,
  input logic[0:0] _slv_ep_2_b_resp_ack,
  output logic[0:0] _slv_ep_2_b_resp_valid,
  output logic[1:0] _slv_ep_2_b_resp_0,
  output logic[0:0] _slv_ep_2_ar_req_ack,
  input logic[0:0] _slv_ep_2_ar_req_valid,
  input logic[34:0] _slv_ep_2_ar_req_0,
  input logic[0:0] _slv_ep_2_r_resp_ack,
  output logic[0:0] _slv_ep_2_r_resp_valid,
  output logic[33:0] _slv_ep_2_r_resp_0,
  output logic[0:0] _slv_ep_3_aw_req_ack,
  input logic[0:0] _slv_ep_3_aw_req_valid,
  input logic[34:0] _slv_ep_3_aw_req_0,
  output logic[0:0] _slv_ep_3_w_req_ack,
  input logic[0:0] _slv_ep_3_w_req_valid,
  input logic[35:0] _slv_ep_3_w_req_0,
  input logic[0:0] _slv_ep_3_b_resp_ack,
  output logic[0:0] _slv_ep_3_b_resp_valid,
  output logic[1:0] _slv_ep_3_b_resp_0,
  output logic[0:0] _slv_ep_3_ar_req_ack,
  input logic[0:0] _slv_ep_3_ar_req_valid,
  input logic[34:0] _slv_ep_3_ar_req_0,
  input logic[0:0] _slv_ep_3_r_resp_ack,
  output logic[0:0] _slv_ep_3_r_resp_valid,
  output logic[33:0] _slv_ep_3_r_resp_0,
  output logic[0:0] _slv_ep_4_aw_req_ack,
  input logic[0:0] _slv_ep_4_aw_req_valid,
  input logic[34:0] _slv_ep_4_aw_req_0,
  output logic[0:0] _slv_ep_4_w_req_ack,
  input logic[0:0] _slv_ep_4_w_req_valid,
  input logic[35:0] _slv_ep_4_w_req_0,
  input logic[0:0] _slv_ep_4_b_resp_ack,
  output logic[0:0] _slv_ep_4_b_resp_valid,
  output logic[1:0] _slv_ep_4_b_resp_0,
  output logic[0:0] _slv_ep_4_ar_req_ack,
  input logic[0:0] _slv_ep_4_ar_req_valid,
  input logic[34:0] _slv_ep_4_ar_req_0,
  input logic[0:0] _slv_ep_4_r_resp_ack,
  output logic[0:0] _slv_ep_4_r_resp_valid,
  output logic[33:0] _slv_ep_4_r_resp_0,
  output logic[0:0] _slv_ep_5_aw_req_ack,
  input logic[0:0] _slv_ep_5_aw_req_valid,
  input logic[34:0] _slv_ep_5_aw_req_0,
  output logic[0:0] _slv_ep_5_w_req_ack,
  input logic[0:0] _slv_ep_5_w_req_valid,
  input logic[35:0] _slv_ep_5_w_req_0,
  input logic[0:0] _slv_ep_5_b_resp_ack,
  output logic[0:0] _slv_ep_5_b_resp_valid,
  output logic[1:0] _slv_ep_5_b_resp_0,
  output logic[0:0] _slv_ep_5_ar_req_ack,
  input logic[0:0] _slv_ep_5_ar_req_valid,
  input logic[34:0] _slv_ep_5_ar_req_0,
  input logic[0:0] _slv_ep_5_r_resp_ack,
  output logic[0:0] _slv_ep_5_r_resp_valid,
  output logic[33:0] _slv_ep_5_r_resp_0,
  output logic[0:0] _slv_ep_6_aw_req_ack,
  input logic[0:0] _slv_ep_6_aw_req_valid,
  input logic[34:0] _slv_ep_6_aw_req_0,
  output logic[0:0] _slv_ep_6_w_req_ack,
  input logic[0:0] _slv_ep_6_w_req_valid,
  input logic[35:0] _slv_ep_6_w_req_0,
  input logic[0:0] _slv_ep_6_b_resp_ack,
  output logic[0:0] _slv_ep_6_b_resp_valid,
  output logic[1:0] _slv_ep_6_b_resp_0,
  output logic[0:0] _slv_ep_6_ar_req_ack,
  input logic[0:0] _slv_ep_6_ar_req_valid,
  input logic[34:0] _slv_ep_6_ar_req_0,
  input logic[0:0] _slv_ep_6_r_resp_ack,
  output logic[0:0] _slv_ep_6_r_resp_valid,
  output logic[33:0] _slv_ep_6_r_resp_0,
  output logic[0:0] _slv_ep_7_aw_req_ack,
  input logic[0:0] _slv_ep_7_aw_req_valid,
  input logic[34:0] _slv_ep_7_aw_req_0,
  output logic[0:0] _slv_ep_7_w_req_ack,
  input logic[0:0] _slv_ep_7_w_req_valid,
  input logic[35:0] _slv_ep_7_w_req_0,
  input logic[0:0] _slv_ep_7_b_resp_ack,
  output logic[0:0] _slv_ep_7_b_resp_valid,
  output logic[1:0] _slv_ep_7_b_resp_0,
  output logic[0:0] _slv_ep_7_ar_req_ack,
  input logic[0:0] _slv_ep_7_ar_req_valid,
  input logic[34:0] _slv_ep_7_ar_req_0,
  input logic[0:0] _slv_ep_7_r_resp_ack,
  output logic[0:0] _slv_ep_7_r_resp_valid,
  output logic[33:0] _slv_ep_7_r_resp_0,
  input logic[0:0] _mst_ep_mst_aw_req_ack,
  output logic[0:0] _mst_ep_mst_aw_req_valid,
  output logic[34:0] _mst_ep_mst_aw_req_0,
  input logic[0:0] _mst_ep_mst_w_req_ack,
  output logic[0:0] _mst_ep_mst_w_req_valid,
  output logic[35:0] _mst_ep_mst_w_req_0,
  output logic[0:0] _mst_ep_mst_b_resp_ack,
  input logic[0:0] _mst_ep_mst_b_resp_valid,
  input logic[1:0] _mst_ep_mst_b_resp_0,
  input logic[0:0] _mst_ep_mst_ar_req_ack,
  output logic[0:0] _mst_ep_mst_ar_req_valid,
  output logic[34:0] _mst_ep_mst_ar_req_0,
  output logic[0:0] _mst_ep_mst_r_resp_ack,
  input logic[0:0] _mst_ep_mst_r_resp_valid,
  input logic[33:0] _mst_ep_mst_r_resp_0
);

  localparam int unsigned NoSlvPorts     = 8;        // Number of slave ports
  localparam int unsigned MaxTrans       = 8;        // Maximum transactions
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

`AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
`AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
`AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
`AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
`AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
`AXI_LITE_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
`AXI_LITE_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)

// Slave Port Connections
  axi_req_t  [NoSlvPorts-1:0] slv_reqs;
  axi_resp_t [NoSlvPorts-1:0] slv_resps;
  axi_req_t  mst_req;
  axi_resp_t mst_resp;

  // Slave port 0 connections
  assign slv_reqs[0] = '{
    aw : _slv_ep_0_aw_req_0,
    aw_valid : _slv_ep_0_aw_req_valid,
    w : _slv_ep_0_w_req_0,
    w_valid : _slv_ep_0_w_req_valid,
    b_ready : _slv_ep_0_b_resp_ack,
    ar : _slv_ep_0_ar_req_0,
    ar_valid : _slv_ep_0_ar_req_valid,
    r_ready : _slv_ep_0_r_resp_ack
  };

  assign _slv_ep_0_aw_req_ack = slv_resps[0].aw_ready;
  assign _slv_ep_0_ar_req_ack = slv_resps[0].ar_ready;
  assign _slv_ep_0_w_req_ack = slv_resps[0].w_ready;
  assign _slv_ep_0_b_resp_valid = slv_resps[0].b_valid;
  assign _slv_ep_0_b_resp_0 = slv_resps[0].b;
  assign _slv_ep_0_r_resp_valid = slv_resps[0].r_valid;
  assign _slv_ep_0_r_resp_0 = slv_resps[0].r;

  // Slave port 1 connections
  assign slv_reqs[1] = '{
    aw : _slv_ep_1_aw_req_0,
    aw_valid : _slv_ep_1_aw_req_valid,
    w : _slv_ep_1_w_req_0,
    w_valid : _slv_ep_1_w_req_valid,
    b_ready : _slv_ep_1_b_resp_ack,
    ar : _slv_ep_1_ar_req_0,
    ar_valid : _slv_ep_1_ar_req_valid,
    r_ready : _slv_ep_1_r_resp_ack
  };

  assign _slv_ep_1_aw_req_ack = slv_resps[1].aw_ready;
  assign _slv_ep_1_ar_req_ack = slv_resps[1].ar_ready;
  assign _slv_ep_1_w_req_ack = slv_resps[1].w_ready;
  assign _slv_ep_1_b_resp_valid = slv_resps[1].b_valid;
  assign _slv_ep_1_b_resp_0 = slv_resps[1].b;
  assign _slv_ep_1_r_resp_valid = slv_resps[1].r_valid;
  assign _slv_ep_1_r_resp_0 = slv_resps[1].r;

  // Slave port 2 connections
  assign slv_reqs[2] = '{
    aw : _slv_ep_2_aw_req_0,
    aw_valid : _slv_ep_2_aw_req_valid,
    w : _slv_ep_2_w_req_0,
    w_valid : _slv_ep_2_w_req_valid,
    b_ready : _slv_ep_2_b_resp_ack,
    ar : _slv_ep_2_ar_req_0,
    ar_valid : _slv_ep_2_ar_req_valid,
    r_ready : _slv_ep_2_r_resp_ack
  };

  assign _slv_ep_2_aw_req_ack = slv_resps[2].aw_ready;
  assign _slv_ep_2_ar_req_ack = slv_resps[2].ar_ready;
  assign _slv_ep_2_w_req_ack = slv_resps[2].w_ready;
  assign _slv_ep_2_b_resp_valid = slv_resps[2].b_valid;
  assign _slv_ep_2_b_resp_0 = slv_resps[2].b;
  assign _slv_ep_2_r_resp_valid = slv_resps[2].r_valid;
  assign _slv_ep_2_r_resp_0 = slv_resps[2].r;

  // Slave port 3 connections
  assign slv_reqs[3] = '{
    aw : _slv_ep_3_aw_req_0,
    aw_valid : _slv_ep_3_aw_req_valid,
    w : _slv_ep_3_w_req_0,
    w_valid : _slv_ep_3_w_req_valid,
    b_ready : _slv_ep_3_b_resp_ack,
    ar : _slv_ep_3_ar_req_0,
    ar_valid : _slv_ep_3_ar_req_valid,
    r_ready : _slv_ep_3_r_resp_ack
  };

  assign _slv_ep_3_aw_req_ack = slv_resps[3].aw_ready;
  assign _slv_ep_3_ar_req_ack = slv_resps[3].ar_ready;
  assign _slv_ep_3_w_req_ack = slv_resps[3].w_ready;
  assign _slv_ep_3_b_resp_valid = slv_resps[3].b_valid;
  assign _slv_ep_3_b_resp_0 = slv_resps[3].b;
  assign _slv_ep_3_r_resp_valid = slv_resps[3].r_valid;
  assign _slv_ep_3_r_resp_0 = slv_resps[3].r;

  // Slave port 4 connections
  assign slv_reqs[4] = '{
    aw : _slv_ep_4_aw_req_0,
    aw_valid : _slv_ep_4_aw_req_valid,
    w : _slv_ep_4_w_req_0,
    w_valid : _slv_ep_4_w_req_valid,
    b_ready : _slv_ep_4_b_resp_ack,
    ar : _slv_ep_4_ar_req_0,
    ar_valid : _slv_ep_4_ar_req_valid,
    r_ready : _slv_ep_4_r_resp_ack
  };

  assign _slv_ep_4_aw_req_ack = slv_resps[4].aw_ready;
  assign _slv_ep_4_ar_req_ack = slv_resps[4].ar_ready;
  assign _slv_ep_4_w_req_ack = slv_resps[4].w_ready;
  assign _slv_ep_4_b_resp_valid = slv_resps[4].b_valid;
  assign _slv_ep_4_b_resp_0 = slv_resps[4].b;
  assign _slv_ep_4_r_resp_valid = slv_resps[4].r_valid;
  assign _slv_ep_4_r_resp_0 = slv_resps[4].r;

  // Slave port 5 connections
  assign slv_reqs[5] = '{
    aw : _slv_ep_5_aw_req_0,
    aw_valid : _slv_ep_5_aw_req_valid,
    w : _slv_ep_5_w_req_0,
    w_valid : _slv_ep_5_w_req_valid,
    b_ready : _slv_ep_5_b_resp_ack,
    ar : _slv_ep_5_ar_req_0,
    ar_valid : _slv_ep_5_ar_req_valid,
    r_ready : _slv_ep_5_r_resp_ack
  };

  assign _slv_ep_5_aw_req_ack = slv_resps[5].aw_ready;
  assign _slv_ep_5_ar_req_ack = slv_resps[5].ar_ready;
  assign _slv_ep_5_w_req_ack = slv_resps[5].w_ready;
  assign _slv_ep_5_b_resp_valid = slv_resps[5].b_valid;
  assign _slv_ep_5_b_resp_0 = slv_resps[5].b;
  assign _slv_ep_5_r_resp_valid = slv_resps[5].r_valid;
  assign _slv_ep_5_r_resp_0 = slv_resps[5].r;

  // Slave port 6 connections
  assign slv_reqs[6] = '{
    aw : _slv_ep_6_aw_req_0,
    aw_valid : _slv_ep_6_aw_req_valid,
    w : _slv_ep_6_w_req_0,
    w_valid : _slv_ep_6_w_req_valid,
    b_ready : _slv_ep_6_b_resp_ack,
    ar : _slv_ep_6_ar_req_0,
    ar_valid : _slv_ep_6_ar_req_valid,
    r_ready : _slv_ep_6_r_resp_ack
  };

  assign _slv_ep_6_aw_req_ack = slv_resps[6].aw_ready;
  assign _slv_ep_6_ar_req_ack = slv_resps[6].ar_ready;
  assign _slv_ep_6_w_req_ack = slv_resps[6].w_ready;
  assign _slv_ep_6_b_resp_valid = slv_resps[6].b_valid;
  assign _slv_ep_6_b_resp_0 = slv_resps[6].b;
  assign _slv_ep_6_r_resp_valid = slv_resps[6].r_valid;
  assign _slv_ep_6_r_resp_0 = slv_resps[6].r;

  // Slave port 7 connections
  assign slv_reqs[7] = '{
    aw : _slv_ep_7_aw_req_0,
    aw_valid : _slv_ep_7_aw_req_valid,
    w : _slv_ep_7_w_req_0,
    w_valid : _slv_ep_7_w_req_valid,
    b_ready : _slv_ep_7_b_resp_ack,
    ar : _slv_ep_7_ar_req_0,
    ar_valid : _slv_ep_7_ar_req_valid,
    r_ready : _slv_ep_7_r_resp_ack
  };

  assign _slv_ep_7_aw_req_ack = slv_resps[7].aw_ready;
  assign _slv_ep_7_ar_req_ack = slv_resps[7].ar_ready;
  assign _slv_ep_7_w_req_ack = slv_resps[7].w_ready;
  assign _slv_ep_7_b_resp_valid = slv_resps[7].b_valid;
  assign _slv_ep_7_b_resp_0 = slv_resps[7].b;
  assign _slv_ep_7_r_resp_valid = slv_resps[7].r_valid;
  assign _slv_ep_7_r_resp_0 = slv_resps[7].r;

  // Master port connections
  assign _mst_ep_mst_aw_req_0 = mst_req.aw;
  assign _mst_ep_mst_aw_req_valid = mst_req.aw_valid;
  assign _mst_ep_mst_w_req_0 = mst_req.w;
  assign _mst_ep_mst_w_req_valid = mst_req.w_valid;
  assign _mst_ep_mst_b_resp_ack = mst_req.b_ready;
  assign _mst_ep_mst_ar_req_0 = mst_req.ar;
  assign _mst_ep_mst_ar_req_valid = mst_req.ar_valid;
  assign _mst_ep_mst_r_resp_ack = mst_req.r_ready;

  assign mst_resp = '{
    aw_ready : _mst_ep_mst_aw_req_ack,
    ar_ready : _mst_ep_mst_ar_req_ack,
    w_ready : _mst_ep_mst_w_req_ack,
    b_valid : _mst_ep_mst_b_resp_valid,
    b : _mst_ep_mst_b_resp_0,
    r_valid : _mst_ep_mst_r_resp_valid,
    r : _mst_ep_mst_r_resp_0
  };

axi_lite_mux #(
    .aw_chan_t   ( aw_chan_t   ),
    .w_chan_t    ( w_chan_t    ),
    .b_chan_t    ( b_chan_t    ),
    .ar_chan_t   ( ar_chan_t   ),
    .r_chan_t    ( r_chan_t    ),
    .axi_req_t   ( axi_req_t   ),
    .axi_resp_t  ( axi_resp_t  ),
    .NoSlvPorts  ( NoSlvPorts  ),
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
    .slv_reqs_i       ( slv_reqs       ),
    .slv_resps_o      ( slv_resps      ),
    .mst_req_o        ( mst_req        ),
    .mst_resp_i       ( mst_resp       )
);
endmodule