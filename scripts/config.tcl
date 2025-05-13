set script_dir [file dirname [info script]]

# config
set _vivado_version "2021.1"

set _proj_name project

set _fpgapart xczu9eg-ffvb1156-2-i

set _bd_name design_1

set _top ${_bd_name}_wrapper

set _tb_top ${_bd_name}_wrapper

set _jobs 16

# relative to xci file path: src/ip/*.xci
# set _ip_gen_path "../../proj/$_proj_name/$_proj_name.gen/ip"
set _ip_gen_path [file normalize [file join $script_dir .. .. proj $_proj_name $_proj_name.gen ip]]


# file
# set _hdf_path "../hw_handoff/"
set _hdf_path [file normalize [file join $script_dir .. hw_handoff]]

# set _archive_path "../release/"
set _archive_path [file normalize [file join $script_dir .. release]]

# set _bd_script "../src/bd/$_bd_name.tcl"
set _bd_script [file normalize [file join $script_dir .. src bd $_bd_name.tcl]]

set _hdl_files {

}

set _ip_files {

}

set _sim_files {

}

set _constr_files {

}

set _ip_repo_paths {

}
