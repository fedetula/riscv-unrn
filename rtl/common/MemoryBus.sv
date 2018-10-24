import Common::*;

typedef struct packed {
   logic [29:0] address;
   logic        mem_read, mem_write;
   logic [3:0]  mask_byte;
   uint32 write_data;
} MemoryBusCmd;

typedef struct packed {
   uint32 read_data;
} MemoryBusResult;
