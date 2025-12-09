import os
import sys

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(ROOT_DIR, "src")
SCRIPTS_DIR = os.path.join(ROOT_DIR, "scripts")
sys.path.insert(0, SCRIPTS_DIR)



# Tests to Run

#  1. FIFO
#  2. Spill Register
#  3. Stream FIFO
#  4. AXI Lite MUX ROUTER
#  5. AXI Lite DEMUX ROUTER
#  6. Filament Benchmarks
#  7. CVA6 Benchmarks

COMMON_CELLS = os.path.join(SRC_DIR, "common_cells")
OUT_DIR = os.path.join(ROOT_DIR, "out")

if not os.path.exists(OUT_DIR):
    os.makedirs(OUT_DIR)
else :
    os.system(f"rm -rf {OUT_DIR}/*")


def print_log(msg):
    print(f"[INFO] {msg}")


def fifo_benchmarks():
    print_log("Running FIFO Benchmarks...")
    os.chdir(COMMON_CELLS)
    os.system("make clean > /dev/null 2>&1")
    os.system(f"make run MODULE_NAME=fifo_top > {OUT_DIR}/fifo_benchmarks.log 2>&1")
    print_log("FIFO Benchmarks Completed! Check logs in out/fifo_benchmarks.log\n")


def get_input(msg):
    # wait for enter or any key press
    input("[Input] " + msg + " Press Enter to continue...")

def print_line():
    print("==================================================================================\n")

    
if __name__ == "__main__":

    print_log("Interactive Script for Running Artefacts\n")

    print_line()
    get_input("Starting FIFO Benchmarks: ")
    fifo_benchmarks()
    print_line()

    print_log("All Benchmarks Completed!")








