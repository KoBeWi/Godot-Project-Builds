@echo off
chcp 65001

cls

:: #####
:: Setting variables
:: #####

REM Full Project Path
set "project=%~dp0"
REM Path to Godot Executable
set "gdpath=C:\Proggen\Godot\Godot_v4.3-stable"
set "godotexe=Godot_v4.3-stable_win64.exe"
set "godotver=Godot_v4.3-stable_win64.exe --version"
REM Full Engine Path
set "build_godot=%gdpath%\%godotexe%"

REM Profilename in export_presets.cfg
REM set "build_profile=Windows Desktop"
set "build_profile=Windows Desktop"
REM export Type export-debug or export-release or export-pack (musst be .pck or .zip)
set "build_type=export-debug"
REM set "build_type=export-release"
REM set "build_type=export-pack"

REM Version sufffix for binary name
set "build_version=master"
REM Version sufffix for Engine Version
set "build_gdversion="
FOR /F %%I IN ('=%gdpath%\%godotver%') DO @SET "build_gdversion=%%I"

set "build_project_name=GodotProjectBuilder"
REM Path to Export root folder
set "build_path=C:\Proggen\Godot\Projekte\export\%build_gdversion%\%build_project_name%"
REM Subfolder for Export Profile, overwrites preset
set "build_folder=%build_path%\%build_profile%"

REM Output binary name
set "build_bin=%build_project_name%_%build_version%_%build_gdversion%.exe"
REM Full Build Path+Name
set "build_project=%build_folder%\%build_bin%"
REM Full Build Log output
set "build_log=%build_folder%\export.log.txt"

:: #####
:: execute
:: #####

echo #####
call :check_engine || echo check_engine Failed && exit /b -99
echo #####

call :check_folder || echo check_folder Failed && exit /b -99
echo #####

if exist "%build_project%" (
    echo Existing Binary Exports will deleted first
	del "%build_project%" /F
)
echo #####

REM Godot 4.2.2 dont have the --log-file parameter
REM --log-file "%build_log%"

echo #####
echo Execute Engine for import all resources
"%build_godot%" --verbose --import --headless > "%build_log%" 2>&1
echo #####


echo Execute Build Process overwrite export_presets.cfg export path
"%build_godot%" --verbose --headless  --%build_type% "%build_profile%" --path %project% "%build_project%" >> "%build_log%" 2>&1
echo #####


echo ERRORLEVEL: %ERRORLEVEL%
if %ERRORLEVEL% EQU 0 (
	call :check_export_output || echo Export Failed && exit /b -99
)
exit /b 0

:: #####
:: checks before execute project export
:: #####
:check_engine
echo checking Engine Settings
echo PATH: "%build_godot%"
echo Version: "%build_gdversion%"

if NOT exist "%build_godot%" (
    echo path to engine or engine executabele does not exist
	exit /b -1
)

exit /b 0

:check_folder
echo checking project and export Settings
echo ProjectFile: "%project%project.godot"
if NOT exist "%project%project.godot" (
    echo the project file does not exist
	exit /b -1
)

echo ExportFolder: "%build_folder%"
if NOT exist "%build_folder%\." (
    echo the build folder does not exist
	echo creating ...
	mkdir "%build_folder%"
	::exit /b -1
	call :check_folder || echo check_folder Failed && exit /b -99
)

exit /b 0

:check_export_output
echo checking export success
echo Export Binary: %build_project%
if NOT exist "%build_project%" (
    echo the Exported Binary does not exist
	exit /b -1
)
echo the export was successfull
CHOICE /C XN /M "Start the exported binary [X] Execute or [N] do not" /N /D N /T 10
IF %ERRORLEVEL% EQU 1 (
    call "%build_project%"
) else (
    exit /b 0
)
exit /b 0
:: #####


REM "C:\Proggen\Godot\Godot_v4.2-stable\Godot_v4.2.2-stable_win64.exe" --verbose --headless 
REM --log-file "C:\Proggen\Godot\Projekte\Just4Fun_Mini_Shootergame\export\gd-4-2-2_stable\Windows\export.log.txt" 
REM --export-release "Windows" --path C:\Proggen\Godot\Projekte\Just4Fun_Mini_Shootergame\4.2.2-stable\\ 
REM "C:\Proggen\Godot\Projekte\Just4Fun_Mini_Shootergame\export\gd-4-2-2_stable\Windows\MiniShooterGame_alpha7_4.2.2.stable.official.15073afe3.exe"