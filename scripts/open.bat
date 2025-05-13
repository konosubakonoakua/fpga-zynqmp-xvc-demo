@echo off

:: Set default values if environment variables are not defined
if "%VIVADO_VERSION%"=="" set VIVADO_VERSION=2021.1
if "%PROJECT_NAME%"=="" set PROJECT_NAME=project

:: Set Vivado executable path
set VIVADO_PATH="C:\Xilinx\Vivado\%VIVADO_VERSION%\bin\vivado.bat"

:: Check if Vivado exists
if not exist %VIVADO_PATH% (
    echo Vivado not found at %VIVADO_PATH%, please check VIVADO_VERSION or installation.
    pause
    exit /b 1
)

:: Set project file path
set PROJECT_PATH=%~dp0
set PROJECT_FILE="%PROJECT_PATH%\%PROJECT_NAME%\%PROJECT_NAME%.xpr"

echo Checking project file: %PROJECT_FILE%
if not exist %PROJECT_FILE% (
    echo Project "%PROJECT_NAME%" not found at %PROJECT_FILE%.
    pause
    exit /b 1
)

:: Launch Vivado with the project file
%VIVADO_PATH% %PROJECT_FILE%

pause
