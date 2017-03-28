#Tcl script that builds a Zynq project using Vivado
#AXI SoC interconnect
#


set current_dir [pwd]
set fpga_part "xc7z020clg484-1"
set temp_prj_name "temp"
set board_name "xilinx.com:zynq:zc702:1.0"
set synth_language "VHDL"
set sim_language "VHDL"
set bd_name "zynq_sys"
set legup_ip_dir "./AXI_Interface_IP/"
set full_ip_name "stfleming:legup:legup_axi_interface:1.0"
set ip_instantiation_name "legup_axi_interface_0"

create_project $temp_prj_name $current_dir/tmp/$temp_prj_name -part $fpga_part -force
set_property board $board_name [current_project]
set_property target_language $synth_language [current_project]
set_property simulator_language $sim_language [current_project]

#Create the block design now that the project is created

create_bd_design "${bd_name}"

#Add the processing system
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
#run block automation on the processing system
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" }  [get_bd_cells processing_system7_0]

#expose the AXI slave port into the FPGA fabric GP0
startgroup
set_property -dict [list CONFIG.PCW_USE_S_AXI_GP0 {1}] [get_bd_cells processing_system7_0]
endgroup

#Add the output directory where the GOS IP core has been created
set_property ip_repo_paths ./ [current_fileset]
update_ip_catalog

#Add our newly generated IP block
startgroup
create_bd_cell -type ip -vlnv $full_ip_name $ip_instantiation_name
endgroup

#Connect the IP core to the PS via AXI using the names defined in Component.xml in the generated IP core
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" }  [get_bd_intf_pins $ip_instantiation_name/S_AXI]
#set_property offset 0x43C00000 [get_bd_addr_segs {processing_system7_0/Data/SEG_axi_legup_interface_0_S_AXI_reg0}]

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/legup_axi_interface_0/m" }  [get_bd_intf_pins processing_system7_0/S_AXI_GP0]

startgroup
set_property -dict [list CONFIG.PCW_USE_HIGH_OCM {1}] [get_bd_cells processing_system7_0]
endgroup

#Save the current board design
save_bd_design

#Create System Wrapper
make_wrapper -files [get_files  $current_dir/tmp/$temp_prj_name/$temp_prj_name.srcs/sources_1/bd/$bd_name/${bd_name}.bd] -top
add_files -norecurse $current_dir/tmp/$temp_prj_name/$temp_prj_name.srcs/sources_1/bd/$bd_name/hdl/${bd_name}_wrapper.vhd
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

#Build the bitstream
reset_run synth_1
reset_run impl_1
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1
wait_on_run impl_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1


#Cleaning up
#file copy -force $current_dir/tmp/$temp_prj_name/$temp_prj_name.runs/impl_1/${bd_name}_wrapper.bit $current_dir/
file copy -force $current_dir/tmp/$temp_prj_name/$temp_prj_name.runs/impl_1/${bd_name}_wrapper.bin $current_dir/

