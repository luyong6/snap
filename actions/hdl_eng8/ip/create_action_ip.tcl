
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
set_property -dict [list CONFIG.NUM_SLAVE_PORTS {8} CONFIG.AXI_ADDR_WIDTH {64} CONFIG.INTERCONNECT_DATA_WIDTH {512} CONFIG.S00_AXI_DATA_WIDTH {64} CONFIG.S01_AXI_DATA_WIDTH {64} CONFIG.S02_AXI_DATA_WIDTH {64} CONFIG.S03_AXI_DATA_WIDTH {64} CONFIG.S04_AXI_DATA_WIDTH {64} CONFIG.S05_AXI_DATA_WIDTH {64} CONFIG.S06_AXI_DATA_WIDTH {64} CONFIG.S07_AXI_DATA_WIDTH {64} CONFIG.M00_AXI_DATA_WIDTH {512}] [get_ips host_axi_interconnect_0] >> $log_file
set_property generate_synth_checkpoint false [get_files $src_dir/host_axi_interconnect_0/host_axi_interconnect_0.xci] >> $log_file
generate_target all [get_files $src_dir/host_axi_interconnect_0/host_axi_interconnect_0.xci] >> $log_file

puts "                        Generating host_axi_lite_crossbar_0 ......"
create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name host_axi_lite_crossbar_0 >> $log_file
set_property -dict [list CONFIG.NUM_MI {8} CONFIG.PROTOCOL {AXI4LITE} CONFIG.CONNECTIVITY_MODE {SASD} CONFIG.R_REGISTER {1} CONFIG.S00_WRITE_ACCEPTANCE {1} CONFIG.S01_WRITE_ACCEPTANCE {1} CONFIG.S02_WRITE_ACCEPTANCE {1} CONFIG.S03_WRITE_ACCEPTANCE {1} CONFIG.S04_WRITE_ACCEPTANCE {1} CONFIG.S05_WRITE_ACCEPTANCE {1} CONFIG.S06_WRITE_ACCEPTANCE {1} CONFIG.S07_WRITE_ACCEPTANCE {1} CONFIG.S08_WRITE_ACCEPTANCE {1} CONFIG.S09_WRITE_ACCEPTANCE {1} CONFIG.S10_WRITE_ACCEPTANCE {1} CONFIG.S11_WRITE_ACCEPTANCE {1} CONFIG.S12_WRITE_ACCEPTANCE {1} CONFIG.S13_WRITE_ACCEPTANCE {1} CONFIG.S14_WRITE_ACCEPTANCE {1} CONFIG.S15_WRITE_ACCEPTANCE {1} CONFIG.S00_READ_ACCEPTANCE {1} CONFIG.S01_READ_ACCEPTANCE {1} CONFIG.S02_READ_ACCEPTANCE {1} CONFIG.S03_READ_ACCEPTANCE {1} CONFIG.S04_READ_ACCEPTANCE {1} CONFIG.S05_READ_ACCEPTANCE {1} CONFIG.S06_READ_ACCEPTANCE {1} CONFIG.S07_READ_ACCEPTANCE {1} CONFIG.S08_READ_ACCEPTANCE {1} CONFIG.S09_READ_ACCEPTANCE {1} CONFIG.S10_READ_ACCEPTANCE {1} CONFIG.S11_READ_ACCEPTANCE {1} CONFIG.S12_READ_ACCEPTANCE {1} CONFIG.S13_READ_ACCEPTANCE {1} CONFIG.S14_READ_ACCEPTANCE {1} CONFIG.S15_READ_ACCEPTANCE {1} CONFIG.M00_WRITE_ISSUING {1} CONFIG.M01_WRITE_ISSUING {1} CONFIG.M02_WRITE_ISSUING {1} CONFIG.M03_WRITE_ISSUING {1} CONFIG.M04_WRITE_ISSUING {1} CONFIG.M05_WRITE_ISSUING {1} CONFIG.M06_WRITE_ISSUING {1} CONFIG.M07_WRITE_ISSUING {1} CONFIG.M08_WRITE_ISSUING {1} CONFIG.M09_WRITE_ISSUING {1} CONFIG.M10_WRITE_ISSUING {1} CONFIG.M11_WRITE_ISSUING {1} CONFIG.M12_WRITE_ISSUING {1} CONFIG.M13_WRITE_ISSUING {1} CONFIG.M14_WRITE_ISSUING {1} CONFIG.M15_WRITE_ISSUING {1} CONFIG.M00_READ_ISSUING {1} CONFIG.M01_READ_ISSUING {1} CONFIG.M02_READ_ISSUING {1} CONFIG.M03_READ_ISSUING {1} CONFIG.M04_READ_ISSUING {1} CONFIG.M05_READ_ISSUING {1} CONFIG.M06_READ_ISSUING {1} CONFIG.M07_READ_ISSUING {1} CONFIG.M08_READ_ISSUING {1} CONFIG.M09_READ_ISSUING {1} CONFIG.M10_READ_ISSUING {1} CONFIG.M11_READ_ISSUING {1} CONFIG.M12_READ_ISSUING {1} CONFIG.M13_READ_ISSUING {1} CONFIG.M14_READ_ISSUING {1} CONFIG.M15_READ_ISSUING {1} CONFIG.S00_SINGLE_THREAD {1}] [get_ips host_axi_lite_crossbar_0] >> $log_file
set_property generate_synth_checkpoint false [get_files $src_dir/host_axi_lite_crossbar_0/host_axi_lite_crossbar_0.xci] >> $log_file
generate_target all [get_files $src_dir/host_axi_lite_crossbar_0/host_axi_lite_crossbar_0.xci] >> $log_file


close_project
puts "\[CREATE_ACTION_IPs..........\] done  [clock format [clock seconds] -format {%T %a %b %d %Y}]"
