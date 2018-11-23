set_component clock_gen_FCCC_0_FCCC
# Microsemi Corp.
# Date: 2018-Nov-23 13:03:32
#

create_clock -period 20 [ get_pins { CCC_INST/RCOSC_25_50MHZ } ]
create_generated_clock -multiply_by 36 -divide_by 3125 -source [ get_pins { CCC_INST/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { CCC_INST/GL0 } ]
