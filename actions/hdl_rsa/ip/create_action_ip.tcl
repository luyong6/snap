
## Env Variables

set action_root [lindex $argv 0]
set fpga_part  	[lindex $argv 1]
#set fpga_part    xcvu9p-flgb2104-2l-e
#set action_root ../

set aip_dir 	$action_root/ip
set log_dir     $action_root/../../hardware/logs
set log_file    $log_dir/create_action_ip.log
set src_dir 	$aip_dir/action_ip_prj/action_ip_prj.srcs/sources_1/ip

## Create a new Vivado IP Project
puts "\[CREATE_ACTION_IPs..........\] start [clock format [clock seconds] -format {%T %a %b %d/ %Y}]"
puts "                        FPGACHIP = $fpga_part"
puts "                        ACTION_ROOT = $action_root"
puts "                        Creating IP in $src_dir"
create_project action_ip_prj $aip_dir/action_ip_prj -force -part $fpga_part -ip >> $log_file

# Project IP Settings
# General
puts "                        Generating fifo_sync_256_64i64o ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_sync_256_64i64o  >> $log_file
set_property -dict [list  CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} CONFIG.Input_Data_Width {64} CONFIG.Input_Depth {256} CONFIG.Output_Data_Width {64} CONFIG.Output_Depth {256} CONFIG.Use_Embedded_Registers {false} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Valid_Flag {true} CONFIG.Data_Count {true} CONFIG.Data_Count_Width {8} CONFIG.Write_Data_Count_Width {8} CONFIG.Read_Data_Count_Width {8} CONFIG.Full_Threshold_Assert_Value {254} CONFIG.Full_Threshold_Negate_Value {253} CONFIG.Enable_Safety_Circuit {true}] [get_ips fifo_sync_256_64i64o]
set_property generate_synth_checkpoint false [get_files $src_dir/fifo_sync_256_64i64o/fifo_sync_256_64i64o.xci] >> $log_file
generate_target all [get_files $src_dir/fifo_sync_256_64i64o/fifo_sync_256_64i64o.xci] >> $log_file


puts "                        Generating host_axi_interconnect_0 ......"
create_ip -name axi_interconnect -vendor xilinx.com -library ip -version 1.7 -module_name host_axi_interconnect_0 >> $log_file
set_property -dict [list CONFIG.NUM_SLAVE_PORTS {9} CONFIG.AXI_ADDR_WIDTH {64} CONFIG.INTERCONNECT_DATA_WIDTH {512} CONFIG.S00_AXI_DATA_WIDTH {64} CONFIG.S01_AXI_DATA_WIDTH {64} CONFIG.S02_AXI_DATA_WIDTH {64} CONFIG.S03_AXI_DATA_WIDTH {64} CONFIG.S04_AXI_DATA_WIDTH {64} CONFIG.S05_AXI_DATA_WIDTH {64} CONFIG.S06_AXI_DATA_WIDTH {64} CONFIG.S07_AXI_DATA_WIDTH {64} CONFIG.S08_AXI_DATA_WIDTH {512} CONFIG.S08_AXI_ARB_PRIORITY {15} CONFIG.M00_AXI_DATA_WIDTH {512}] [get_ips host_axi_interconnect_0] >> $log_file
set_property generate_synth_checkpoint false [get_files $src_dir/host_axi_interconnect_0/host_axi_interconnect_0.xci] >> $log_file
generate_target all [get_files $src_dir/host_axi_interconnect_0/host_axi_interconnect_0.xci] >> $log_file

puts "                        Generating host_axi_lite_crossbar_0 ......"
create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name host_axi_lite_crossbar_0 >> $log_file
set_property -dict [list CONFIG.NUM_MI {9} CONFIG.PROTOCOL {AXI4LITE} CONFIG.M00_A00_BASE_ADDR {0x0000000000000200} CONFIG.M01_A00_BASE_ADDR {0x0000000000000300} CONFIG.M02_A00_BASE_ADDR {0x0000000000000400} CONFIG.M03_A00_BASE_ADDR {0x0000000000000500} CONFIG.M04_A00_BASE_ADDR {0x0000000000000600} CONFIG.M05_A00_BASE_ADDR {0x0000000000000700} CONFIG.M06_A00_BASE_ADDR {0x0000000000000800} CONFIG.M07_A00_BASE_ADDR {0x0000000000000900} CONFIG.M08_A00_BASE_ADDR {0x0000000000000000} CONFIG.M00_A00_ADDR_WIDTH {8} CONFIG.M01_A00_ADDR_WIDTH {8} CONFIG.M02_A00_ADDR_WIDTH {8} CONFIG.M03_A00_ADDR_WIDTH {8} CONFIG.M04_A00_ADDR_WIDTH {8} CONFIG.M05_A00_ADDR_WIDTH {8} CONFIG.M06_A00_ADDR_WIDTH {8} CONFIG.M07_A00_ADDR_WIDTH {8} CONFIG.M08_A00_ADDR_WIDTH {8}] [get_ips host_axi_lite_crossbar_0] >> $log_file

set_property generate_synth_checkpoint false [get_files $src_dir/host_axi_lite_crossbar_0/host_axi_lite_crossbar_0.xci] >> $log_file
generate_target all [get_files $src_dir/host_axi_lite_crossbar_0/host_axi_lite_crossbar_0.xci] >> $log_file

puts "                        Generating job_manager_fifo ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name job_manager_fifo >> $log_file
set_property -dict [list  CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} CONFIG.Input_Data_Width {512} CONFIG.Input_Depth {16} CONFIG.Output_Data_Width {512} CONFIG.Output_Depth {16} CONFIG.Use_Embedded_Registers {false} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Valid_Flag {true} CONFIG.Data_Count {true} CONFIG.Data_Count_Width {4} CONFIG.Write_Data_Count_Width {4} CONFIG.Read_Data_Count_Width {4} CONFIG.Full_Threshold_Assert_Value {14} CONFIG.Full_Threshold_Negate_Value {13} CONFIG.Enable_Safety_Circuit {true}] [get_ips job_manager_fifo]
set_property generate_synth_checkpoint false [get_files $src_dir/job_manager_fifo/job_manager_fifo.xci] >> $log_file
generate_target all [get_files $src_dir/job_manager_fifo/job_manager_fifo.xci] >> $log_file

puts "                        Generating axi_rid_fifo ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name axi_rid_fifo >> $log_file
set_property -dict [list CONFIG.Component_Name {axi_rid_fifo} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {8} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {8} CONFIG.Output_Depth {512} CONFIG.Use_Embedded_Registers {false} CONFIG.Data_Count_Width {9} CONFIG.Write_Data_Count_Width {9} CONFIG.Read_Data_Count_Width {9} CONFIG.Full_Threshold_Assert_Value {511} CONFIG.Full_Threshold_Negate_Value {510} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips axi_rid_fifo] >> $log_file
set_property generate_synth_checkpoint false [get_files $src_dir/axi_rid_fifo/axi_rid_fifo.xci] >> $log_file
generate_target all [get_files $src_dir/axi_rid_fifo/axi_rid_fifo.xci] >> $log_file


puts "                        Generating axi_wid_fifo ......"
create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name axi_wid_fifo >> $log_file
set_property -dict [list CONFIG.Component_Name {axi_wid_fifo} CONFIG.Performance_Options {First_Word_Fall_Through} CONFIG.Input_Data_Width {8} CONFIG.Input_Depth {512} CONFIG.Output_Data_Width {8} CONFIG.Output_Depth {512} CONFIG.Use_Embedded_Registers {false} CONFIG.Data_Count_Width {9} CONFIG.Write_Data_Count_Width {9} CONFIG.Read_Data_Count_Width {9} CONFIG.Full_Threshold_Assert_Value {511} CONFIG.Full_Threshold_Negate_Value {510} CONFIG.Empty_Threshold_Assert_Value {4} CONFIG.Empty_Threshold_Negate_Value {5}] [get_ips axi_wid_fifo] >> $log_file
set_property generate_synth_checkpoint false [get_files $src_dir/axi_wid_fifo/axi_wid_fifo.xci] >> $log_file
generate_target all [get_files $src_dir/axi_wid_fifo/axi_wid_fifo.xci] >> $log_file


close_project
puts "\[CREATE_ACTION_IPs..........\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
