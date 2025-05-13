set script_dir [file dirname [info script]]

source [file normalize [file join $script_dir project.tcl]]

_version_check

_project_create

# _project_build


