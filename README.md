# unrn-riscv-softCPU

This project was done for the RISC-V contest by my students (UNRN - Universidad Nacional de Rio Negro / Argentina):

  * Santiago Abbate (graduate)
  * Nicolás Bértolo
  * Leandro Jalil
  * Tomás Kromer

It is only a partial upload of their work, it succesfully runs all tests and both (Philosophers and Synchronization) Zephyr's samples in Verilator, however the target to the Microsemi and Lattice board was not finished due to lack of time (however, they did manage to run parts of the core). They initially set up a basic unicycle (emulator) that passed all tests and zephyr samples and then aimed for minimum area implementation by redesigning it with microcoding and bit serial implementation.

I personally congratulate them for their work and commitment to this contest, considering they started learning Verilog/SystemVerilog and most of the fundamental concepts of Computer Architecture (ISA, unicycle, pipeline, cache, virtual memory, etc) and RISC-V just four months ago.
This is their first time using Verilator, Zephyr (they have possibly found an important bug that will be reported once fully analyzed), Microsemi and Lattice tools... and they have done all that, from scratch, without any help and within their limited spare time.

These contest has helped us to initiate a RISC-V implementation as part of a research project targeting FPGAs so hopefully I will have more of these exceptional students in future for the following contests.


Note: We will upload instruction to run simulation and the rest once they tidy up their project/docs
