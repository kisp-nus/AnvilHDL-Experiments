# Additional Experiments for Anvil


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