# I2C Master Protocol Controller

**Author:** Shaurya Mudgal

This repository contains the hardware RTL design for an I2C (Inter-Integrated Circuit) Master Protocol Controller. It is designed to manage synchronous two-wire serial communication between multiple electronic components on a shared bus.

## 📌 Project Overview

The core objective of this project is to accurately manage the complex step-by-step sequencing required by the I2C protocol. The controller translates parallel data into formatted serial transactions, handling both read and write operations.

Key architectural features include:
1. **13-State FSM:** A comprehensive Finite State Machine controlling the exact sequencing of START conditions, addressing, read/write bits, data payload transmission, acknowledgment polling, and STOP conditions.
2. **Bi-directional SDA Management:** Safely drives the shared `sda` data line using open-drain logic (`1'bz`) to allow both the master and simulated slaves to communicate without bus contention.
3. **SCL Clock Generation:** Includes a dedicated clock divider module to scale the high-speed system clock down to standard I2C operational frequencies.
4. **Error Handling:** Features an `ack_err` detection signal to monitor NACK (Not Acknowledge) responses from slave devices during addressing and data phases.

## 🗂️ File Structure

The repository is partitioned into the core RTL design modules and the simulation verification environment.

### 1. Hardware (RTL) - Verilog
*   `top_i2c.v`: The top-level integration module that instantiates and routes signals between the FSM and the clock divider.
*   `i2c_fsm.v`: The core control logic housing the 13-state machine, bit counters, and shift registers for serial data exchange.
*   `i2c_clk_divider.v`: The hardware timer responsible for generating the synchronized `i2c_tick` used to drive the FSM transitions.

### 2. Verification Environment - Verilog
*   `tb_i2c.v`: The behavioral testbench utilizing Verilog `pullup()` primitives to accurately model the physical I2C bus. It drives the master through a complete write transaction and validates the generation of START/STOP conditions and data shifting.

## 🚀 Project Status & Milestones

**Hardware Design & Integration (Completed)**
*   Engineered the I2C master protocol controller in standard Verilog HDL.
*   Built the core control logic using a highly structured 13-state FSM to ensure error-free data exchange.
*   Successfully implemented the tri-state logic necessary for handling two-wire communication.

**Simulation & Verification (Completed)**
*   Developed a dedicated testbench to simulate bus transactions.
*   Executed behavioral simulations in Xilinx Vivado.
*   Verified the accurate generation of serial timing, data alignment, and completion flags across a full simulated transfer.

## 🛠️ Tools and Technologies

*   **Hardware Description Language:** Verilog
*   **Simulation & Synthesis:** Xilinx Vivado (Behavioral Simulation)
