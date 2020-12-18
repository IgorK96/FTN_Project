start_gui
create_project rsa ./rsa -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
set_property target_language VHDL [current_project]
create_peripheral user.org user rsa 1.0 -dir ./ip_repo
add_peripheral_interface S00_AXI -interface_mode slave -axi_type lite [ipx::find_open_core user.org:user:rsa:1.0]
set_property VALUE 9 [ipx::get_bus_parameters WIZ_NUM_REG -of_objects [ipx::get_bus_interfaces S00_AXI -of_objects [ipx::find_open_core user.org:user:rsa:1.0]]]
generate_peripheral -driver -bfm_example_design -debug_hw_example_design -force [ipx::find_open_core user.org:user:rsa:1.0]
write_peripheral [ipx::find_open_core user.org:user:rsa:1.0]
set_property  ip_repo_paths  ./ip_repo/rsa_1.0 [current_project]
update_ip_catalog -rebuild
ipx::edit_ip_in_project -upgrade true -name edit_rsa_v1_0 -directory ./ip_repo ./ip_repo/rsa_1.0/component.xml
update_compile_order -fileset sources_1
add_files -norecurse -copy_to ./ip_repo/rsa_1.0/src {./RTL/rsa.vhd }
update_files -from_files ./RTL/rsa_v1_0.vhd -to_files ./ip_repo/rsa_1.0/hdl/rsa_v1_0.vhd -filesets [get_filesets *]
update_files -from_files ./RTL/rsa_v1_0_S00_AXI.vhd -to_files ./ip_repo/rsa_1.0/hdl/rsa_v1_0_S00_AXI.vhd -filesets [get_filesets *]
update_compile_order -fileset sources_1
set_property SOURCE_SET sources_1 [get_filesets sim_1]
update_compile_order -fileset sim_1
update_compile_order -fileset sim_1
set_property library work [get_files  ./ip_repo/rsa_1.0/src/rsa.vhd]
set_property library work [get_files  ./RTL/rsa_v1_0_S00_AXI.vhd]
set_property library work [get_files  ./RTL/rsa_v1_0.vhd]
ipx::merge_project_changes ports [ipx::current_core]
ipx::merge_project_changes File_Groups [ipx::current_core]
update_compile_order -fileset sources_1
ipx::add_bus_interface BRAM_A [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:bram_rtl:1.0 [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:bram:1.0 [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property display_name BRAM_A [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property description BRAM_A [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
ipx::add_port_map RST [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name reseta [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map CLK [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name clka [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map DIN [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name dina [ipx::get_port_maps DIN -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map EN [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name ena [ipx::get_port_maps EN -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map DOUT [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name douta [ipx::get_port_maps DOUT -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map WE [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name wea [ipx::get_port_maps WE -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_port_map ADDR [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
set_property physical_name addra [ipx::get_port_maps ADDR -of_objects [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]]
ipx::add_bus_interface BRAM_B [ipx::current_core]
set_property abstraction_type_vlnv xilinx.com:interface:bram_rtl:1.0 [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property bus_type_vlnv xilinx.com:interface:bram:1.0 [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property interface_mode master [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property display_name BRAM_B [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property description BRAM_B [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
ipx::add_port_map RST [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name resetb [ipx::get_port_maps RST -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map CLK [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name clkb [ipx::get_port_maps CLK -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map DIN [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name dinb [ipx::get_port_maps DIN -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map EN [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name enb [ipx::get_port_maps EN -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map DOUT [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name doutb [ipx::get_port_maps DOUT -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map WE [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name web [ipx::get_port_maps WE -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_port_map ADDR [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
set_property physical_name addrb [ipx::get_port_maps ADDR -of_objects [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]]
ipx::add_bus_parameter CONFIG.MASTER_TYPE [ipx::get_bus_interfaces BRAM_B -of_objects [ipx::current_core]]
ipx::add_bus_parameter CONFIG.MASTER_TYPE [ipx::get_bus_interfaces BRAM_A -of_objects [ipx::current_core]]
launch_runs synth_1
wait_on_run synth_1
set_property core_revision 1 [ipx::current_core]
ipx::update_source_project_archive -component [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::move_temp_component_back -component [ipx::current_core]
close_project -delete
update_ip_catalog -rebuild -repo_path ./ip_repo/rsa_1.0
