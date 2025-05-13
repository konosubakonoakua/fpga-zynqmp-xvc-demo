@echo off
set VIVADO_VERSION=%VIVADO_VERSION%
if "%VIVADO_VERSION%"=="" set VIVADO_VERSION=2021.1

set VIVADO_PATH="C:\Xilinx\Vivado\%VIVADO_VERSION%\bin\vivado.bat"
set TCL_SCRIPT="create.tcl"

if not exist %VIVADO_PATH% (
    echo Vivado not found at %VIVADO_PATH%, please check VIVADO_VERSION or installation.
    pause
    exit /b 1
)

if not exist %TCL_SCRIPT% (
    echo TCL script not found, please check TCL_SCRIPT.
    pause
    exit /b 1
)

%VIVADO_PATH% -mode gui -source %TCL_SCRIPT%

pause
