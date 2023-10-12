# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: /users/students/r0792566/Documents/SW_package/sw_project/project_sw/sw_design_system/_ide/scripts/debugger_sw_design-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source /users/students/r0792566/Documents/SW_package/sw_project/project_sw/sw_design_system/_ide/scripts/debugger_sw_design-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Xilinx TUL 1234-tulA" && level==0 && jtag_device_ctx=="jsn-TUL-1234-tulA-23727093-0"}
fpga -file /users/students/r0792566/Documents/SW_package/sw_project/project_sw/sw_design/_ide/bitstream/rsa_project_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw /users/students/r0792566/Documents/SW_package/sw_project/project_sw/rsa_project_wrapper/export/rsa_project_wrapper/hw/rsa_project_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source /users/students/r0792566/Documents/SW_package/sw_project/project_sw/sw_design/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow /users/students/r0792566/Documents/SW_package/sw_project/project_sw/sw_design/Debug/sw_design.elf
configparams force-mem-access 0
targets -set -nocase -filter {name =~ "*A9*#0"}
con
