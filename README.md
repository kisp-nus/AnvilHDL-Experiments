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

### AXI Lite Mux

The files are located in `axi/`
- `axi_lite_mux.anvil` : Anvil implementation of AXI Lite Mux
- `axi_lite_mux_top.anvil` : Top level Anvil file to instantiate and test the AXI Lite Mux

The axi files are in `axi/` directory. we provide scripts in `unit_test_helpers/run_axi_veri.sh` to run the AXI Lite Mux tests for SV baseline from pulp platforms IP. 


The way to run the tests is 

```bash 
cp unit_test_helpers/run_axi_veri.sh  ./src/axi/
cd ./src/axi/
bash run_axi_veri.sh
```

