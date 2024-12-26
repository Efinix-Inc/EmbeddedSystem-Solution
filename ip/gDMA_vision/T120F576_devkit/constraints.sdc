#################
create_clock -period 20 io_systemClk
create_clock -period 10 io_memoryClk
create_clock -period 100 jtag_inst1_TCK

# False Path
#################
set_false_path -setup -hold io_asyncReset
set_false_path -setup -hold RubySoc_inst/io_memoryReset*
set_false_path -setup -hold RubySoc_inst/io_systemReset*
set_clock_groups -exclusive -group {io_systemClk} -group {io_memoryClk} -group {jtag_inst1_TCK}
