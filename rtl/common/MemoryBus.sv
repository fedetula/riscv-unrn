import Common::*;

package MemoryBus;

typedef struct packed {
   logic [29:0] address;
   logic        mem_read, mem_write;
   logic [3:0]  mask_byte;
   Common::uint32 write_data;
} Cmd;

typedef Common::uint32 Result;

endpackage // MemoryBus
