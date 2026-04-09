
# Entity: async_fifo 
- **File**: Async_FIFO.v

## Diagram
![Diagram](async_fifo.svg "Diagram")
## Generics

| Generic name | Type | Value | Description |
| ------------ | ---- | ----- | ----------- |
| DATA_WIDTH   |      | 8     |             |
| DEPTH        |      | 16    |             |

## Ports

| Port name | Direction | Type                  | Description |
| --------- | --------- | --------------------- | ----------- |
| wclk      | input     | wire                  |             |
| rclk      |           |                       |             |
| wrst_n    |           |                       |             |
| rrst_n    |           |                       |             |
| w_en      | input     | wire                  |             |
| r_en      |           |                       |             |
| wdata     | input     | wire [DATA_WIDTH-1:0] |             |
| rdata     | output    | wire [DATA_WIDTH-1:0] |             |
| full      | output    | wire                  |             |
| empty     |           |                       |             |

## Signals

| Name        | Type                  | Description |
| ----------- | --------------------- | ----------- |
| b_waddr     | wire [ADDR_WIDTH-1:0] |             |
| b_raddr     | wire [ADDR_WIDTH-1:0] |             |
| g_wptr      | wire [ADDR_WIDTH:0]   |             |
| g_rptr      | wire [ADDR_WIDTH:0]   |             |
| g_wptr_sync | wire [ADDR_WIDTH:0]   |             |
| g_rptr_sync | wire [ADDR_WIDTH:0]   |             |

## Constants

| Name       | Type | Value   | Description |
| ---------- | ---- | ------- | ----------- |
| ADDR_WIDTH |      | (DEPTH) |             |

## Instantiations

- mem_inst: fifo_memory
- wr_inst: write_handler
- rd_inst: read_handler
- sync_r2w: synchronizer
- sync_w2r: synchronizer
