import Common::*;

package MemoryBus;

typedef struct packed {
   logic        mem_read;
   logic [3:0]  mask_byte;
   Common::uint32 write_data;
   logic        start;
} Cmd;

typedef struct packed {
   Common::uint32 data;
   logic  done;
} Result;

endpackage // MemoryBus
