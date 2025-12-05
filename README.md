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


### 