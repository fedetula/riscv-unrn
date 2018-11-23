set_component clock_gen_OSC_0_OSC
# Microsemi Corp.
# Date: 2018-Nov-23 13:03:34
#

create_clock -ignore_errors -period 20 [ get_pins { I_RCOSC_25_50MHZ/CLKOUT } ]
