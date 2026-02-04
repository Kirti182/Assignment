# Single-Stage Pipeline Register

## Problem Statement
Implement a single-stage pipeline register in SystemVerilog using a standard valid/ready handshake that:
- Accepts data when `in_valid` and `in_ready` are asserted
- Presents stored data on output with `out_valid`
- Correctly handles backpressure without data loss or duplication
- Is fully synthesizable and resets to a clean empty state

## Solution

### Design (`pipeline_register.sv`)
A parameterized pipeline register with:
- **Input Interface:** `in_valid`, `in_ready`, `in_data[DATA_WIDTH-1:0]`
- **Output Interface:** `out_valid`, `out_ready`, `out_data[DATA_WIDTH-1:0]`
- **Control:** `clk`, `rst_n` (active-low asynchronous reset)

**Key Logic:**
- `in_ready = !valid_reg || out_ready` - Ready when empty or being consumed
- Data transfers on valid/ready handshake (both signals high)
- Internal register holds data during backpressure
- Single-cycle pipeline latency

### Verification (`tb_pipeline_register.sv`)
Testbench validates:
1. Basic data transfer
2. Backpressure handling (no data loss)
3. No data duplication
4. Reset functionality

All tests pass successfully.
