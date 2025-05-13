VIVADO_PATH_WIN := C:/Xilinx/Vivado/2021.1
VIVADO_PATH_LINUX := /tools/Xilinx/Vivado/2021.1

SCRIPTS_PATH := scripts
TCL_SCRIPT := $(SCRIPTS_PATH)/create.tcl

PROJECT_NAME := project
PROJECT_PATH := proj/$(PROJECT_NAME)
PROJECT_FILE := $(PROJECT_PATH)/$(PROJECT_NAME).xpr

PETALINUX_DIR := petalinux

HW_DESCRIPTION := hw_handoff/
BD_DESIGN_NAME := design_1
BD_EXPORT_DIR := src/bd

LOG_FILE := vivado_makefile.log

ifeq ($(OS),Windows_NT)
    SHELL := cmd
    .SHELLFLAGS := /C
    RD := rmdir /s /q
    RM := del /q
    MKDIR := mkdir
	  FIXPATH = $(subst /,\,$1)
    VIVADO_PATH := $(subst /,\\, $(VIVADO_PATH_WIN))
    VIVADO_SETTINGS := $(VIVADO_PATH)\\settings64.bat
    SOURCE := call $(VIVADO_SETTINGS)
    RUN_VIVADO := $(VIVADO_PATH)\\bin\\vivado.bat
    RUN_VIVADO_GUI := start /B "" $(VIVADO_PATH)\\bin\\vivado.bat
else
    SHELL := bash
    RD := rm -rf
    RM := rm -f
    MKDIR := mkdir -p
	  FIXPATH = $1
    VIVADO_SETTINGS := $(VIVADO_PATH_LINUX)/settings64.sh
    SOURCE := source $(VIVADO_SETTINGS)
    RUN_VIVADO := source $(VIVADO_SETTINGS) && vivado
    RUN_VIVADO_GUI := nohup vivado >$(LOG_FILE) 2>&1 &
endif

all: help

project:
	@echo Sourcing Vivado settings and creating project...
	$(RUN_VIVADO) -mode batch -source $(TCL_SCRIPT)
	@echo Vivado project created successfully!

gui:
	@echo Launching Vivado GUI...
ifeq ($(OS),Windows_NT)
	$(RUN_VIVADO_GUI) "$(PROJECT_FILE)"
else
	$(RUN_VIVADO_GUI) $(PROJECT_FILE)
endif
	@echo "Vivado GUI started. Check $(LOG_FILE) for details."

# bd-export:
# 	@echo Exporting Block Design...
# 	$(MKDIR) $(BD_EXPORT_DIR)
# 	$(RUN_VIVADO) -mode batch -source $(SCRIPTS_PATH)/export_bd.tcl -tclargs $(PROJECT_FILE) $(BD_DESIGN_NAME) $(BD_EXPORT_DIR)
# 	@echo Block Design exported to $(BD_EXPORT_DIR)/$(BD_DESIGN_NAME).tcl

clean:
	@echo Cleaning generated files...
	- $(RM) *.log
	- $(RM) *.jou
	- $(RD) $(call FIXPATH, $(PROJECT_PATH))
	@echo Cleanup complete!

help:
	@echo Usage: make [target]
	@echo Targets:
	@echo   project       - Generate Vivado project in batch mode
	@echo   gui           - Open Vivado project in GUI mode
	# @echo   bd-export     - Export Block Design to TCL file
	@echo   clean         - Clean up generated files
	@echo   help          - Show this help message

.PHONY: all project gui bd-export clean help
