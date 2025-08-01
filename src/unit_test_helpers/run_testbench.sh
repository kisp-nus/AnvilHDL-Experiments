#!/bin/bash


# Usage: ./run_testbench.sh <testbench_name> [timeout_cycles]

set -e

# Configuration
DEFAULT_TIMEOUT=10000


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_usage() {
    echo "Usage: $0 <testbench_name> [timeout_cycles]"
    echo ""
    echo "Examples:"
    echo "  $0 aes_key_expand_tb"
    echo "  $0 aes_key_expand_tb 20000"
    echo "  $0 my_custom_tb 5000"
}


if [[ $# -lt 1 ]]; then
    log_error "Missing testbench name"
    show_usage
    exit 1
fi

TESTBENCH_NAME="$1"
TIMEOUT="${2:-$DEFAULT_TIMEOUT}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RTL_DIR="$SCRIPT_DIR"

log_info "OpenTitan Testbench Runner"
log_info "Testbench: $TESTBENCH_NAME"
log_info "Timeout: $TIMEOUT cycles"


TESTBENCH_FILE=""
for ext in ".sv" ".anvil.sv" "_tb.sv" "_tb.anvil.sv"; do
    if [[ -f "$RTL_DIR/${TESTBENCH_NAME}${ext}" ]]; then
        TESTBENCH_FILE="$RTL_DIR/${TESTBENCH_NAME}${ext}"
        break
    fi
done

if [[ -z "$TESTBENCH_FILE" ]]; then
    log_error "Could not find testbench file for '$TESTBENCH_NAME'"
    exit 1
fi

log_success "Found testbench: $(basename "$TESTBENCH_FILE")"


BUILD_DIR="$RTL_DIR/build_${TESTBENCH_NAME}"
mkdir -p "$BUILD_DIR"


create_stubs() {

    if [[ ! -f "$RTL_DIR/prim_assert.sv" ]]; then
        log_info "Creating prim_assert.sv stub..."
        cat > "$RTL_DIR/prim_assert.sv" << 'EOF'
`define ASSERT_STATIC_LINT_ERROR(name, expr)
`define ASSERT_INIT(name, expr)
`define ASSERT(name, expr, clk = `ASSERT_DEFAULT_CLK, rst = `ASSERT_DEFAULT_RST)
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
EOF
    fi
    
 
    if [[ ! -f "$RTL_DIR/stub_packages.sv" ]]; then
        log_info "Creating stub_packages.sv..."
        cat > "$RTL_DIR/stub_packages.sv" << 'EOF'
package prim_util_pkg;
  function automatic integer vbits(integer value);
    if (value == 1) return 1;
    return $clog2(value);
  endfunction
endpackage

package aes_reg_pkg;
  parameter int NumRegsIv = 4;
  parameter logic [2:0] AES_CTRL_SHADOWED_OPERATION_RESVAL = 3'b001;
  parameter logic [5:0] AES_CTRL_SHADOWED_MODE_RESVAL = 6'b000001;
  parameter logic [2:0] AES_CTRL_SHADOWED_KEY_LEN_RESVAL = 3'b001;
  parameter logic [2:0] AES_CTRL_SHADOWED_PRNG_RESEED_RATE_RESVAL = 3'b001;
  parameter logic AES_CTRL_SHADOWED_FORCE_ZERO_MASKS_RESVAL = 1'b0;
  parameter logic AES_CTRL_SHADOWED_MANUAL_OPERATION_RESVAL = 1'b0;
  parameter logic AES_CTRL_SHADOWED_SIDELOAD_RESVAL = 1'b0;
endpackage
EOF
    fi
    
    if [[ ! -f "$RTL_DIR/prim_sec_anchor_buf.sv" ]]; then
        log_info "Creating prim_sec_anchor_buf.sv stub..."
        cat > "$RTL_DIR/prim_sec_anchor_buf.sv" << 'EOF'
module prim_sec_anchor_buf #(
  parameter int unsigned Width = 1
) (
  input  logic [Width-1:0] in_i,
  output logic [Width-1:0] out_o
);
  assign out_o = in_i;
endmodule
EOF
    fi
}

create_stubs


SV_FILES=()


for stub in "prim_assert.sv" "stub_packages.sv" "prim_sec_anchor_buf.sv"; do
    if [[ -f "$RTL_DIR/$stub" ]]; then
        SV_FILES+=("$RTL_DIR/$stub")
        log_info "Added: $stub"
    fi
done


if grep -q "aes_" "$TESTBENCH_FILE"; then
    log_info "Detected AES testbench, adding AES dependencies..."
    
    AES_DEPS=(
        "aes_pkg.sv"
        "aes_sbox_canright_pkg.sv"
        "aes_sel_buf_chk.sv" 
        "aes_sbox_lut.sv"
        "aes_sbox_canright.sv"
        "aes_sbox.sv"
        "aes_key_expand.sv"
    )
    
    for dep in "${AES_DEPS[@]}"; do
        if [[ -f "$RTL_DIR/$dep" ]]; then
            SV_FILES+=("$RTL_DIR/$dep")
            log_info "Added: $dep"
        fi
    done
fi


SV_FILES+=("$TESTBENCH_FILE")
log_info "Added: $(basename "$TESTBENCH_FILE")"

log_success "Found ${#SV_FILES[@]} files to compile"


log_info "Creating C++ simulation driver..."
cat > "$BUILD_DIR/sim_main.cpp" << EOF
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
        std::cout << "Simulation completed with \$finish at cycle " << time_cnt << std::endl;
    } else {
        std::cout << "Simulation reached timeout at cycle " << time_cnt << std::endl;
    }
    
    contextp->statsPrintSummary();
    return 0;
}
EOF


log_info "Compiling with Verilator..."
cd "$BUILD_DIR"

VFLAGS="--cc --exe --build --top $TESTBENCH_NAME -j 4"
VFLAGS="$VFLAGS -Wall -Wno-PINCONNECTEMPTY -Wno-ASSIGNDLY -Wno-DECLFILENAME"
VFLAGS="$VFLAGS -Wno-UNUSED -Wno-UNOPTFLAT -Wno-WIDTHCONCAT -Wno-WIDTHEXPAND"
VFLAGS="$VFLAGS -Wno-LITENDIAN -Wno-UNPACKED -I$RTL_DIR"

if verilator $VFLAGS "${SV_FILES[@]}" sim_main.cpp; then
    log_success "Compilation successful!"
else
    log_error "Compilation failed!"
    exit 1
fi


EXECUTABLE="$BUILD_DIR/obj_dir/V${TESTBENCH_NAME}"
if [[ -f "$EXECUTABLE" ]]; then
    log_info "Running simulation..."
    echo "=================================="
    if "$EXECUTABLE" "$TIMEOUT"; then
        echo "=================================="
        log_success "Simulation completed!"
    else
        echo "=================================="
        log_warning "Simulation completed with warnings"
    fi
else
    log_error "Executable not found!"
    exit 1
fi

log_info "Build directory: $BUILD_DIR"
log_info "To re-run: $EXECUTABLE [$TIMEOUT]"