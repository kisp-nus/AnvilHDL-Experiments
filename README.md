# Experiments for Anvil Evaluation


## Common Cells


### FIFO : a First In First Out Buffer

The files are located in `common_cells/`
- `fifo_wrapper.sv` : Baseline FIFO from common cells IP
- `fifo.anvil` : Anvil implementation of FIFO
- `fifo_top.anvil` : Top level Anvil file to instantiate and test both FIFOs

The test does the following:

1. Pushes data into FIFO
2. Trys to Overflow the FIFO
3. Pops data from FIFO
4. Trys to Underflow the FIFO

It does this for both the common cells FIFO and the Anvil FIFO and prints the results to the console.


### Spill Register

The files are located in `common_cells/`
- `spill_reg.sv` : Baseline Spill Register from common cells IP
- `spill_reg.anvil` : Anvil implementation of Spill Register
- `spill_reg_top.anvil` : Top level Anvil file to instantiate and test both Spill Registers

There are following test patterns implemented:
1. Send data to Spill Register
2. Receive data from Spill Register
3. Test for Overflow condition
4. Test for Underflow condition

The test does this for both the common cells Spill Register and the Anvil Spill Register and prints the results to the console

### Stream FIFO
The files are located in `common_cells/`

- `passthrough_stream_fifo.anvil` : Anvil implementation of Stream FIFO
- `stream_fifo.anvil` : Anvil implementation of Stream FIFO
- `stream_fifo_top.anvil` : Top level Anvil file to instantiate and test the Stream FIFO


The test does the following:
1. Pushes data into FIFO
2. Trys to check FIFO stream read : same cycle read and write when full
3. Pops data from FIFO

It prints the results to the console for both the common cells stream buffer and the Anvil stream buffer.

### AXI Lite Mux /AXI Lite Demux Router

The files are located in `axi/`
- `axi_lite_mux.anvil` : Anvil implementation of AXI Lite Mux
- `axi_lite_mux_top.anvil` : Top level Anvil file to instantiate and test the AXI Lite Mux
- `axi-demux.anvil` : Anvil implementation of AXI Demux Router
- `axi_router_top.anvil` : Top level Anvil file to instantiate and test the

The axi files are in `axi/` directory. we provide scripts in `unit_test_helpers/run_axi_veri.sh` to run the AXI Lite Mux tests for SV baseline from pulp platforms IP. 


The way to run the tests is 

```bash 
cd src/
python3 create_testbench.py <tb_name> <wrapper_name>
cd ..
cp unit_test_helpers/run_axi_veri.sh  ./src/axi/
cd ./src/axi/
bash run_axi_veri.sh
```
testbench_name is `axi_lite_mux_top` and wrapper_name is `axi_lite_mux` for AXI Lite Mux tests.

Similarly for AXI Demux tests tb_name is `axi_router_top` and wrapper_name is `axi_demux`

## AES Cipher Core

The files are located in `src/aes/`
- `aes_cipher_core.anvil` : Anvil implementation of AES Cipher Core
- `aes_helper_pkg.sv` : SystemVerilog wrapper for AES Cipher Core

The testbench can be created by running the following command from `src/` directory:

```bash
python3 create_testbench.py aes_cipher_core_tb aes_cipher_core --cleanup
```

This will create the testbench file `aes_cipher_core_tb.sv` in the `aes/hw/ip/rtl/` directory.

One can copy `run_testbench.sh` from `unit_test_helpers/` to `aes/hw/ip/rtl/` directory to run the testbench.


```
bash run_testbench.sh aes_cipher_core_tb
```

The testbench tests the AES cipher core for encryption and decryption test for `AES-128 and AES-256` and prints the results to the console.

Same results with cycle accurate designs can be replicated for SV baseline from OpenTitan IP.

## Filament ALU and SA Experiments

The files are located in `src/filament/` The file has two directory : one with src Anvil and src SV files. The sv files contains the generated SV code from Anvil and Filament backend wrapped around the testbenches.


So src files are in `src/filament/src_files/` directory.
- `Alu.anvil` : Anvil implementation of ALU
- `Alu_tb.anvil` : Testbench for ALU
- `SA.anvil` : Anvil implementation of Simple Accelerator
- `SA_tb.anvil` : Testbench for Simple Accelerator


The sv files are in `src/filament/sv_files/` directory.
- `AluAnvil.sv` : Generated testbench SV code for ALU from Anvil
- `SAanvil.sv` : Generated testbench SV code for Simple Accelerator from Anvil
- `AluFil.sv` : Filament alu implementation wrapped around the same testbench as Anvil
- `SAfil.sv` : Filament SA implementation wrapped around the same testbench as Anvil


To run the tests , go to sv directory and run the following commands:

```bash
cd src/filament/sv_files/
make run all
```

This runs the testbenches for both Anvil and Filament implementations and prints the results to the console.