@echo off
title Radio Tomography Imaging
echo =========================================
echo  2D Radio Tomography Imaging
echo =========================================
echo.
echo Starting Scilab...
echo.

:: ---- Scilab installation path ----
set SCILAB_DIR=C:\Program Files\scilab-2026.0.1
set SCILAB_BAT="%SCILAB_DIR%\bin\scilab.bat"
set SCILAB_EXE="%SCILAB_DIR%\bin\WScilex.exe"

:: ---- Get the folder where this .bat file is located ----
set SCRIPT_DIR=%~dp0
set SCRIPT_PATH=%SCRIPT_DIR%RTI.sce

:: ---- Check if script exists ----
if not exist "%SCRIPT_PATH%" (
    echo ERROR: RTI.sce not found in:
    echo %SCRIPT_DIR%
    pause
    exit /b 1
)

:: ---- Try scilab.bat first (preferred — full GUI mode) ----
if exist %SCILAB_BAT% (
    echo Launching via scilab.bat...
    %SCILAB_BAT% -f "%SCRIPT_PATH%"
    goto END
)

:: ---- Fallback: launch WScilex.exe directly then exec script ----
if exist %SCILAB_EXE% (
    echo Launching via WScilex.exe...
    %SCILAB_EXE% -e "exec('%SCRIPT_PATH%')"
    goto END
)

echo ERROR: Scilab not found in:
echo %SCILAB_DIR%\bin\
echo.
echo Please check your Scilab installation.
pause
exit /b 1

:END
pause