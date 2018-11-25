import Common::*;

package MemoryBus;

typedef struct packed {
   logic        mem_read;
   logic [3:0]  mask_byte;
   Common::uint32 write_data;
} Cmd;

typedef Common::uint32 Result;

endpackage // MemoryBus
