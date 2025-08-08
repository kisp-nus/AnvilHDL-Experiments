#!/bin/bash


if [ -z "$1" ]; then
    echo "Usage: $0 <TESTBENCH_NAME> [TIMEOUT]"
    echo "Example: $0 axi_lite_demux_tb 10000"
    exit 1
fi

TESTBENCH_NAME=$1
TIMEOUT=${2:-10000}

TESTBENCH_PATH_FILE=$(realpath "$TESTBENCH_NAME.sv")
echo "Testbench path file: $TESTBENCH_PATH_FILE"

cat > demux.flist << EOF
+incdir+/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/include
+incdir+/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/include
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cb_filter_pkg.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cc_onehot.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_reset_ctrlr_pkg.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cf_math_pkg.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/clk_int_div.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/credit_counter.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/delta_counter.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/ecc_pkg.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/edge_propagator_tx.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/exp_backoff.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/fifo_v3.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/gray_to_binary.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/isochronous_4phase_handshake.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/isochronous_spill_register.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lfsr.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lfsr_16bit.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lfsr_8bit.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/lossy_valid_to_stream.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/mv_filter.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/onehot_to_bin.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/plru_tree.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/passthrough_stream_fifo.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/popcount.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/rr_arb_tree.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/rstgen_bypass.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/serial_deglitch.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/shift_reg.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/shift_reg_gated.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/spill_register.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/spill_register_flushable.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_demux.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_filter.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_fork.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_intf.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_join_dynamic.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_mux.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/stream_throttle.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/sub_per_hash.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/sync.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/sync_wedge.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/unread.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/read.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/addr_decode_dync.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_2phase.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/cdc_4phase.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/clk_int_div_static.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/addr_decode.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/addr_decode_napot.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/.bender/git/checkouts/common_cells-3e2fcccecd7aee7b/src/multiaddr_decode.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/src/axi_pkg.sv
/home/adi4kisp/Desktop/Workspace/Anvil-Experiments/axi/src/axi_lite_demux.sv
${TESTBENCH_PATH_FILE}
EOF


ROOT=$(realpath "./")


cat > "$ROOT/sim_main.cpp" << EOF
#include <memory>
#include <iostream>
#include <verilated.h>
#include "V${TESTBENCH_NAME}.h"

double sc_time_stamp() { return 0; }

int main(int argc, char** argv) {
    unsigned timeout = ${TIMEOUT};
    if (argc > 1) {
        timeout = std::atoi(argv[1]);
    }

    std::cout << "Starting ${TESTBENCH_NAME} simulation (timeout: " << timeout << " cycles)" << std::endl;

    Verilated::mkdir("logs");
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    contextp->debug(0);
    contextp->randReset(2);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    const std::unique_ptr<V${TESTBENCH_NAME}> top{new V${TESTBENCH_NAME}{contextp.get(), "TOP"}};

    top->clk_i = 0;
    top->rst_ni = 0;

    unsigned time_cnt = 0;

    while (!contextp->gotFinish() && time_cnt < timeout) {
        contextp->timeInc(1);
        top->clk_i = !top->clk_i;

        if (!top->clk_i) {
            if (contextp->time() > 1 && contextp->time() < 10) {
                top->rst_ni = 0;  // Assert reset
            } else {
                top->rst_ni = 1;  // Deassert reset
            }
        }

        top->eval();
        ++time_cnt;
        
        if (time_cnt % 1000 == 0 && time_cnt > 0) {
            std::cout << "Progress: " << time_cnt << "/" << timeout << " cycles" << std::endl;
        }
    }

    top->final();
    
    if (contextp->gotFinish()) {
        std::cout << "Simulation completed with \\\\$finish at cycle " << time_cnt << std::endl;
    } else {
        std::cout << "Simulation reached timeout at cycle " << time_cnt << std::endl;
    }
    
    contextp->statsPrintSummary();
    return 0;
}
EOF

# Set up Verilator flags properly
VERILATOR_FLAGS=(
    -Wno-fatal
    --cc
    --exe
    --build
    --timing
    --top
    "$TESTBENCH_NAME"
    -j
    4
    -Wall
    -Wno-PINCONNECTEMPTY
    -Wno-ASSIGNDLY
    -Wno-DECLFILENAME
    -Wno-UNUSED
    -Wno-UNDRIVEN
    -Wno-UNOPTFLAT
    -Wno-WIDTHCONCAT
    -Wno-WIDTHEXPAND
    -Wno-VARHIDDEN
    -Wno-EOFNEWLINE
    -Wno-GENUNNAMED
    -Wno-SYNCASYNCNET
    -Wwarn-UNSUPPORTED
    -Wno-LITENDIAN
    -Wno-UNPACKED
    -Wno-STMTDLY
    -I"$ROOT/include"
)

# Check if required files exist
if [ ! -f "axi_pkg.sv" ]; then
    echo "Error: axi_pkg.sv not found in current directory"
    exit 1
fi

if [ ! -f "axi_lite_demux.sv" ]; then
    echo "Error: axi_lite_demux.sv not found in current directory"
    exit 1
fi

# Run Verilator
echo "Running Verilator with testbench: $TESTBENCH_NAME"
echo "Timeout set to: $TIMEOUT cycles"

# Check if testbench file exists
if [ ! -f "${TESTBENCH_NAME}.sv" ]; then
    echo "Error: ${TESTBENCH_NAME}.sv not found in current directory"
    exit 1
fi

verilator -f demux.flist "${VERILATOR_FLAGS[@]}" -top "$TESTBENCH_NAME" "$ROOT/sim_main.cpp"




if [ $? -eq 0 ]; then
    echo "Compilation successful. Running simulation..."
    ./obj_dir/V${TESTBENCH_NAME} $TIMEOUT
else
    echo "Compilation failed!"
    exit 1
fi
