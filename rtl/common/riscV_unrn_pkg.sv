package riscV_unrn_pkg;

  parameter XLEN = 32;

  ///////////////////////////////
  // CSRs Definitions
  //////////////////////////////

  typedef enum logic [11:0] {

     /////////////////////////
     // Machine Mode CSRs
     ////////////////////////////

     // Machine Informtation Registers
     CSR_MVENDORID      = 12'hF11,
     CSR_MARCHID        = 12'hF12,
     CSR_MIMPID         = 12'hF13,
     CSR_MHARTID        = 12'hF14,

     // Machine Trap Setup
     CSR_MSTATUS        = 12'h300,
     CSR_MISA           = 12'h301,
     CSR_MEDELEG        = 12'h302,
     CSR_MIDELEG        = 12'h303,
     CSR_MIE            = 12'h304,
     CSR_MTVEC          = 12'h305,
     CSR_MCOUNTEREN     = 12'h306,

     // Machine Trap Handling
     CSR_MSCRATCH       = 12'h340,
     CSR_MEPC           = 12'h341,
     CSR_MCAUSE         = 12'h342,
     CSR_MTVAL          = 12'h343,
     CSR_MIP            = 12'h344,

     // Machine Protection and Translation
     CSR_PMPCFG0        = 12'h3A0,
     CSR_PMPADDR0       = 12'h3B0,

     // Machine Counters
     CSR_MCYCLE         = 12'hB00,
     CSR_MINSTRET       = 12'hB02,
     CSR_MCYCLEH        = 12'hB80,
     CSR_INSTRETH       = 12'hB82
  } csr_num_t;

  typedef enum logic [1:0] {
     CSRRNOP = 2'h0,
     CSRRW  = 2'h1,
     CSRRS  = 2'h2,
     CSRRC  = 2'h3
  } csr_op_t;

  //////////////////////////////////////
  // Raw CSR typedef
  //////////////////////////////////////
  typedef logic [XLEN-1:0] csr_raw_t;
  typedef logic [63:0] csr_raw64_t;

  //////////////////////////////////////
  // Machine Status Register (mstatus)
  //////////////////////////////////////
  typedef struct packed {
    logic         sd;     //Dirty State                                        - 0 if FS and XS are not Implemented
    logic [7:0]   wpri1;  //Not implemented section
    logic         tsr;    //Trap SRET                                          - 0 if S Mode not Implemented (For virtual memory implementations)
    logic         tw;     //Timeout Wait                                       - 0 if S Mode not Implemented (For virtual memory implementations)
    logic         tvm;    //Trap Virtual Memory bit                            - 0 if S Mode not Implemented (For virtual memory implementations)
    logic         mxr;    //Make eXecutable Readable                           - 0 if S Mode not Implemented (For virtual memory implementations)
    logic         sum;    //Supervisor User Memory access bit                  - 0 if S Mode not Implemented (For virtual memory implementations)
    logic         mprv;   //Modify PRiVilege bit                               - 0 if U Mode not Implemented
    logic [1:0]   xs;     //eXtensions Status encoding                         - 0 if not Implemented
    logic [1:0]   fs;     //Floating point Status enconing                     - 0 if not Implemented
    logic [1:0]   mpp;    //Machine Prior (to trap) Priviliege mode
    logic [1:0]   wpri2;  //Not implemented section
    logic         spp;    //Supervisor Prior (to trap) Priviliege mode
    logic         mpie;   //Machine Prior (to trap) Interrupt Enable bit
    logic         wpri3;  //Not implemented section
    logic         spie;   //Supervisor Prior (to trap) Interrupt Enable bit
    logic         upie;   //User Prior (to trap) Interrupt Enable bit          - 0 if U Mode not Implemented
    logic         mie;    //Machine Interrupt Enable bit
    logic         wpri4;  //Not implemented section
    logic         sie;    //Supervisor Interrupt Enable bit                    - 0 if S Mode not Implemented
    logic         uie;    //User Interrupt Enable bit                          - 0 if U Mode not Implemented
  }mstatus_csr_t;


  //////////////////////////////////////
  // Machine Interrupt Pending Register (mip)
  //////////////////////////////////////
  typedef struct packed {
    logic [XLEN-12:0] wiri1;  //Not implemented section
    logic             meip;   //Pending M-mode external interrupt
    logic             wiri2;  //Not implemented section
    logic             seip;   //Not implemented section - S-mode pending
    logic             ueip;   //Not implemented section - U-mode pending
    logic             mtip;
    logic             wiri3;
    logic             stip;
    logic             utip;
    logic             msip;
    logic             wiri4;
    logic             ssip;
    logic             usip;
  }mip_csr_t;

  //////////////////////////////////////
  // Machine Interrupt Enable Register (mie)
  //////////////////////////////////////
  // Enabled interrupts: External M-mode
  localparam  SUPPORTED_INTERRUPTS_MASK = 32'h880;
  typedef struct packed {
    logic [XLEN-12:0] wiri1;  //Not implemented section
    logic             meie;   // M-mode external interrupt
    logic             wiri2;  //Not implemented section
    logic             seie;   //Not implemented section - S-mode
    logic             ueie;   //Not implemented section - U-mode
    logic             mtie;   // M-mode Timer Interrupt
    logic             wiri3;
    logic             stie;
    logic             utie;
    logic             msie;   // M-mode Software Interrupt
    logic             wiri4;
    logic             ssie;
    logic             usie;
  }mie_csr_t;

  ////////////////////////////////
  // Implemented Exception Codes
  ////////////////////////////////
  localparam  logic [31:0] M_EXT_INT   = (1 << 31) | 11;    // Machine external interrupt
  localparam  logic [31:0] M_TIMER_INT = (1 << 31) | 7;     // Machine timer interrupt
  localparam  logic [31:0] M_INSTR_MISALIGN     = 0;
  localparam  logic [31:0] M_INSTR_AFAULT       = 1;
  localparam  logic [31:0] M_ILL_INSTR          = 2;        // Illegal instruction
  localparam  logic [31:0] M_BREAK              = 3;        // Breakpoint
  localparam  logic [31:0] M_LOAD_MISALIGN      = 4;
  localparam  logic [31:0] M_LOAD_AFAULT        = 5;
  localparam  logic [31:0] M_STORE_MISALIGN     = 6;
  localparam  logic [31:0] M_STORE_AFAULT       = 7;
  localparam  logic [31:0] M_ECALL              = 11;       // Enviroment call from M-Mode


  localparam  logic [31:0] HARDCODED_MTVEC = 32'h8000_0004;

  /////////////////////////
  // Timers address encoding
  ////////////////////////
  localparam  logic [31:0] MTIME_MEM_ADDRESS_LOW = 32'h0000_8004;
  localparam  logic [31:0] MTIME_MEM_ADDRESS_HIGH = 32'h0000_8008;
  localparam  logic [31:0] MTIMECMP_MEM_ADDRESS_LOW = 32'h0000_800C;
  localparam  logic [31:0] MTIMECMP_MEM_ADDRESS_HIGH = 32'h0000_8010;

  typedef enum logic [1:0]{
    MTIME_LOW,
    MTIME_HIGH,
    MTIMECMP_LOW,
    MTIMECMP_HIGH
  }mtime_address_t; //This are addresses internal to CSR unit

  //////////////
  // Memory
  /////////////
  /*	Validez| Tipo de Instruccion | tipo de dato
  		1      |		0			           |	00			    Load Byte
  		1      |		0                |	01			    Load Half
  		1      |		0                |	10			    Load Word
  		1      |		0			           |	11			    Load Unsigned Byte
  		1      |		1                |	00			    Store Byte
  		1      |		1                |	01			    Store Half
  		1      |		1                |	10			    Store Word
  		1      |		1			           |	11			    Load Unsigned Half
   */

   // Instruction and Data Memory boundaries

   localparam  PC_VALID_RANGE_BASE    = 32'h0000_0000;
   localparam  PC_VALID_RANGE_LIMIT   = 32'h0000_FFFF;
   localparam  MEM_VALID_RANGE_BASE   = 32'h0001_0000;
   localparam  MEM_VALID_RANGE_LIMIT  = 32'hFFFF_FFFF;
endpackage
