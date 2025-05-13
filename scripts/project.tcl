set script_dir [file dirname [info script]]

proc _version_check {} {
  global script_dir
  source [file join $script_dir config.tcl]

  set ver [lindex [split $::env(XILINX_VIVADO) /] end]
  if {$ver ne $_vivado_version} {
    error "ERROR: Vivado version mismatch. Required: $_vivado_version, Found: $ver"
  }
}

proc _bd_create {_bd_script bd_name} {
  if {$_bd_script eq ""} {
    puts "INFO: No BD script provided, skipping Block Design processing."
    return
  }

  source $_bd_script
  puts "INFO: Block design created successfully."

  # regenerate_bd_layout
  # validate_bd_design -force
  # save_bd_design

  set wrapper_file "${bd_name}_wrapper.v"
  set wrapper_in_project [llength [get_files -quiet $wrapper_file]]

  if {$wrapper_in_project == 0} {
    make_wrapper -files [get_files $bd_name.bd] -top -import
    puts "INFO: Block design wrapper file: $wrapper_file created and added to project."
  } else {
    puts "INFO: Existing wrapper file $wrapper_file is already in project."
}
}

proc _bd_export {} {
  global script_dir
  source [file join $script_dir config.tcl]

  write_bd_tcl -force -no_project_wrapper $_bd_script
  puts "INFO: Exported Block Design to: $_bd_script"
}

proc _hdf_export {} {
  global script_dir
  source [file join $script_dir config.tcl]

  set vivado_version [lindex [split $::env(XILINX_VIVADO) "/"] end]
  set is_post_2019_2 [expr {[package vcompare $vivado_version "2019.2"] >= 0}]

  if {$is_post_2019_2} {
    set xsa_fn [file join $_hdf_path "${_proj_name}.xsa"]
    write_hw_platform -fixed -force -file $xsa_fn
    puts "INFO: Exported XSA file to: $xsa_fn"
  } else {
    set hdf_fn [file join $_hdf_path "${_top}.hdf"]
    write_hwdef -force -file $hdf_fn
    puts "INFO: Exported HDF file to: $hdf_fn"
  }

}

# proc _project_create {} {
#   global script_dir
#   source [file join $script_dir config.tcl]
#
#   set _outdir [file normalize [file join $script_dir .. proj $_proj_name]]
#   file mkdir $_outdir
#   create_project $_proj_name $_outdir -part $_fpgapart -force
#
#   add_files -fileset [current_fileset] -force -norecurse $_hdl_files
#   add_files -fileset [current_fileset] -force -norecurse $_ip_files
#   add_files -fileset [get_filesets sim_1] -force -norecurse $_sim_files
#   add_files -fileset [current_fileset -constrset] -force -norecurse $_constr_files
#   puts "INFO: All files added."
#
#   set_property ip_repo_paths $_ip_repo_paths [current_project]
#   update_ip_catalog
#   puts "INFO: IP catalog updated."
#
#   _bd_create $_bd_script $_bd_name
#
#   set_property top $_tb_top [get_filesets sim_1]
#   set_property top_lib xil_defaultlib [get_filesets sim_1]
#   update_compile_order -fileset sim_1
#
#   set_property top $_top [current_fileset]
#   puts "INFO: $_top set as top."
#
#   set_property generic DEBUG=TRUE [current_fileset]
#   set_property AUTO_INCREMENTAL_CHECKPOINT 1 [current_run -implementation]
#
#   update_compile_order
#
#   puts "INFO: Project created successfully."
# }
#
proc _project_create {} {
  global script_dir

  source [file join $script_dir config.tcl]

  set _outdir [file normalize [file join $script_dir .. proj $_proj_name]]
  file mkdir $_outdir
  create_project $_proj_name $_outdir -part $_fpgapart -force

  _add_files_safely "HDL"       $_hdl_files    [current_fileset]
  _add_files_safely "IP"        $_ip_files     [current_fileset]
  _add_files_safely "Simulation" $_sim_files   [get_filesets sim_1]
  _add_files_safely "Constraint" $_constr_files [current_fileset -constrset]

  if {[info exists _ip_repo_paths] && [llength $_ip_repo_paths] > 0} {
    set_property ip_repo_paths $_ip_repo_paths [current_project]
    update_ip_catalog
    puts "INFO: IP catalog updated with [llength $_ip_repo_paths] paths."
  } else {
    puts "WARNING: No IP repository paths specified."
  }

  if {[info exists _bd_script] && [info exists _bd_name]} {
    _bd_create $_bd_script $_bd_name
  }

  if {[info exists _tb_top] && $_tb_top ne ""} {
    set_property top $_tb_top [get_filesets sim_1]
    set_property top_lib xil_defaultlib [get_filesets sim_1]
    update_compile_order -fileset sim_1
  }

  if {[info exists _top] && $_top ne ""} {
    set_property top $_top [current_fileset]
    puts "INFO: Top module set to $_top."
  }

  set_property generic DEBUG=TRUE [current_fileset]
  set_property AUTO_INCREMENTAL_CHECKPOINT 1 [current_run -implementation]
  update_compile_order

  puts "INFO: Project created successfully in $_outdir"
}

proc _add_files_safely {type file_list fileset} {
  if {![info exists file_list] || [llength $file_list] == 0} {
    puts "WARNING: No $type files specified."
    return
  }

  set missing_files [list]
  foreach f $file_list {
    if {![file exists $f]} {
      lappend missing_files $f
    }
  }

  if {[llength $missing_files] > 0} {
    puts "ERROR: Missing $type files:\n  [join $missing_files \n  ]"
    error "Critical files missing"
  }

  puts "INFO: Adding [llength $file_list] $type files..."
  add_files -fileset $fileset -force -norecurse $file_list
}

proc _project_build {} {
  global script_dir
  source [file join $script_dir config.tcl]

  upgrade_ip [get_ips]

  launch_runs -jobs $_jobs [current_run -synthesis]
  wait_on_run [current_run -synthesis]

  launch_runs -jobs _jobs [current_run -implementation] -to_step write_bitstream
  wait_on_run [current_run -implementation]
}

proc _project_archive {} {
  global script_dir
  source [file join $script_dir config.tcl]
  set _timestamp [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]
  set _archive [file join $_archive_path "${_proj_name}_${_timestamp}.xpr"]
  archive_project -force $_ar
  puts "INFO: Project archived to: $_archive"
}

proc _files_inspect {} {
  get_files -of [get_filesets sources_1];
  get_files -of [get_filesets sim_1];
  get_property ip_repo_paths [current_project];
}

