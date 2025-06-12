# Synchronous FIFO

## Overview
A **FIFO (First-In, First-Out) ** is a data buffer commonly used for communicating data between two systems operating at different data rates. Data written into the FIFO comes out in the same order it was entered: the first value written in is the first value read. 

In **Synchronous FIFOs**, both writing and writing are controlled by the same clock. 

![image](https://github.com/user-attachments/assets/e2267c8c-57be-4a32-94c1-56136e83b4e2)

## Synch FIFO Module (fifo_synch.v)
**Inputs**
* **clk**:       Clock
* **rst**:       Synchronous reset
* **wr_en**:     Write enable
* **din[7:0]**:  Data input
* **rd_en**:     Read enable

**Outputs**
* **dout[7:0]**: Data output
* **isfull**   : FIFO full flag
* **isempty**  : FIFO empty flag

The FIFO is built as circular buffer using an internal memory array with write (wrptr) and read (rdptr) pointers. Data is written on each positive clock edge when wr_en is high and the FIFO is not full. Data is read out when rd_en is high and the FIFO is not empty. The full and empty flags are updated by comparing the write and read pointers:
* The FIFO is **empty** when both pointers are equal (no data available to read).
* The FIFO is **full** when incrementing the write pointer by one would make it equal to the read pointer (no more data can be written until space is freed). 
All pointers and flags are reset when rst is enabled. 
![image](https://github.com/user-attachments/assets/01145a72-cacf-4c93-9102-c643542e8926)

## Synch FIFO Testbench (tb_fifo_synch.sv)
The SystemVerilog testbench verifies FIFO functionality using two main tests:
* **Test 1**: Fills the FIFO to capacity and then empties it, checking that the empty flag is set correctly.
![image](https://github.com/user-attachments/assets/dea366a5-c6d6-4834-b5a6-41de8ecc1e18)

* **Test 2**: Performs mixed-rate read and write operations. A reference queue models expected output, and each FIFO read is compared against it using assertions. This test ensures all data is read out in the correct order and the FIFO is empty at the end.
  
![image](https://github.com/user-attachments/assets/fd74e9fb-e034-4574-89c7-d2efd6697c88)

**Writing/Reading to FIFO at mixed rates**
![image](https://github.com/user-attachments/assets/566061e3-07f3-4ed1-8787-6a74d12f297d)

**Emptying FIFO and comparing output to model**
![image](https://github.com/user-attachments/assets/d9a60d73-d6b9-4607-a5f2-bdfb9d444f4d)

## Simulation 
**Simulation results** for write_interval=2, read_interval=3, num_cycles=5. 


  

