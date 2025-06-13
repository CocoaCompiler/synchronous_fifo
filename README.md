# Synchronous FIFO

## Overview
A **FIFO (First-In, First-Out)** is a data buffer commonly used for communicating data between two systems operating at different data rates. Data written into the FIFO comes out in the same order it was entered: the first value written in is the first value read. 

In **Synchronous FIFOs**, both writing and reading are controlled by the same clock. 

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

* **Test 2** reads and writes to the FIFO at different rates over num_cycles clock cycles. It checks that the data is stored and read in the right order, even when operations overlap. This test also empties out the FIFO after num_cycles clock cycles and verifies the output and empty flag.
  
![image](https://github.com/user-attachments/assets/8782249d-c2fe-4225-ae5a-078920822a9f)

**Writing/Reading to FIFO at mixed rates**
![image](https://github.com/user-attachments/assets/566061e3-07f3-4ed1-8787-6a74d12f297d)

**Emptying FIFO and comparing output to model**
![image](https://github.com/user-attachments/assets/83891f76-0f88-4e8c-9d2b-3a1013b83a3f)

## Simulation Results
**Simulation results** for write_interval=2, read_interval=3, num_cycles=10.

**TCL Console**
The TCL console output shows the full simulation log, including all writes, reads, and value comparisons. Each assertion is checked in real time; any failure would halt the simulation. The final summary confirms the FIFO passed all test cases.
![image](https://github.com/user-attachments/assets/abf84ad2-e4e2-42ad-a389-fc26726a788d)

**Waveform**
![image](https://github.com/user-attachments/assets/9ca904e6-7e23-4aa1-8658-8caad3f23783)
The waveform illustrates FIFO operation at the signal level. It shows the clock and reset activity, how and when data is written or read, and how the FIFO’s full and empty flags respond.

## Areas of Improvement
### Data Mismatches with certain num_cycles
While the FIFO and testbench work reliably for some values of num_cycles, I observed that the testbench occasionally reports a mismatch like Expected X, got X+1 during the emptying phase. This points to an extra read being issued towards the end of the test.

In the future, I’d refine the emptying logic to ensure that each read enable matches a valid entry in the model, and that no extra reads are performed after the FIFO is empty. This will help prevent off-by-one mismatches and improve the reliability of the testbench.

Also the following improvements can be added: 
* Extend testbench coverage to additional edge cases (e.g. randomized read/write intervals)
* Parametrizing FIFO

**TCL Console output for num_cycles=5, write_interval=2, read_interval=3**

![image](https://github.com/user-attachments/assets/1625c518-720d-4821-bdd3-705c7076a274)

## How to Run 
1. Clone this repo or download fifo_synch.v and tb_fifo_synch.sv
2. Compile the files in your simulator (I used Vivado 2024.2).
3. Check the console output for test results and open the generated waveform file for signal analysis. 

## References
1. [Clock Domain Crossing – Paul Franzon (YouTube)](https://www.youtube.com/watch?v=a_RL56y8Fpo&t=812s)
2. *Digital Fundamentals*, Floyd, 10th Edition, Chapter 10: Memory and Storage
