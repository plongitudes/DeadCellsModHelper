echo off
setlocal

set paths_okay=false 1>nul
set path_steamlibrary=false 1>nul
set path_mods=false 1>nul

:menu
if %path_steamlibrary% equ false goto varsetup
if %path_mods% equ false goto varsetup

echo.
echo        ...---===### Dead Cells ModTools Helper ###===---...
echo.
if %path_steamlibrary% equ unset (
    echo  [[ [!] SteamLibrary path not set ]]
)
if %path_mods% equ unset (
    echo  [[ [!] mod files path not set ]]
)
if %path_steamlibrary% equ unset (
    echo  [1] - Set root path for your SteamLibrary
) else (
    echo  [1] - Change SteamLibrary path (currently %path_steamlibrary%^)
)
if %path_steamlibrary% equ unset (
    echo  [2] - Set root path for unpacked files and mods
) else (
    echo  [2] - Change mods path (currently %path_mods%^)
)
echo  [3] - Unpack original Dead Cells res.pak
echo  [4] - Unpack data.cdb from unpacked res.pak
echo        (this will overwrite any changes you have made
echo        to previously unpacked data)
echo  [5] - Collapse unpacked data.cdb directory
echo        into a new data.cdb file, stored in the mod 
echo        directory (set this in step 2).
echo  [6] - Pack collapsed data.cdb file and any modified
echo        assets from the mod dir into a new res.pak
echo  [7] - Quit this batch file.
echo.
choice /C 1234567 /n /m " Select menu item => "
set m=%ERRORLEVEL%
if %m%==1 goto path_steamlibrary
if %m%==2 goto path_mods
if %m%==3 goto unpack_res_pak
if %m%==4 goto unpack_data_cdb
if %m%==5 goto collapse_data_cdb
if %m%==6 goto pack_res_pack
if %m%==7 goto end
if "%m%"=="" goto menu
goto menu

:varsetup
rem set steam library path if already stored
if exist "path_steamlibrary.ini" (
    set /p path_steamlibrary=<path_steamlibrary.ini
) else (
    set "path_steamlibrary=unset" 1>nul
)
if "%path_steamlibrary:~-1%" EQU "\" set /p path_steamlibrary=%path_steamlibrary:~0,-1%

rem set mods dir if already stored
if exist "path_mods.ini" (
    set /p path_mods=<path_mods.ini
) else (
    set "path_mods=unset" 1>nul
)
if "%path_mods:~-1%" EQU "\" set /p path_mods=%path_mods:~0,-1%

if not %path_steamlibrary% equ unset if not %path_mods% equ unset set "paths_okay=true"

rem set some vars
set "paktool_exe=\steamapps\common\Dead Cells\ModTools\PAKTool.exe"
set "cdbtool_exe=\steamapps\common\Dead Cells\ModTools\CDBTool.exe"
set "res_pak_file=\steamapps\common\Dead Cells\res.pak"
set "res_pak_dir=\00_unpacked_res_pak"
set "data_cdb_dir=\01_expanded_data_cdb"
set "modded_data_cdb_dir=\02_collapsed_modded_data_cdb"
set "modded_res_pak_dir=\03_packed_modded_res_pak"

set unpacked_res_pak_dir="%path_mods%%res_pak_dir%"
set expanded_data_cdb_dir="%path_mods%%data_cdb_dir%"
set collapsed_modded_data_cdb_dir="%path_mods%%modded_data_cdb_dir%"
set packed_modded_res_pak_dir="%path_mods%%modded_res_pak_dir%"

set paktool="%path_steamlibrary%%paktool_exe%"
set cdbtool="%path_steamlibrary%%cdbtool_exe%"

set res_pak="%path_steamlibrary%%res_pak_file%"
set data_cdb="%path_mods%%res_pak_dir%\data.cdb"
set modded_data_cdb="%path_mods%%modded_data_cdb_dir%\data.cdb"
set modded_res_pak="%path_mods%%modded_res_pak_dir%\res.pak"

REM echo %unpacked_res_pak_dir%
REM echo %expanded_data_cdb_dir%
REM echo %collapsed_modded_data_cdb_dir%
REM echo %packed_modded_res_pak_dir%

REM echo %paktool%
REM echo %cdbtool%

REM echo %res_pak%
REM echo %data_cdb%
REM echo %modded_data_cdb%
REM echo %modded_res_pak%

if %paths_okay% equ true if not exist %unpacked_res_pak_dir% md %unpacked_res_pak_dir%
if %paths_okay% equ true if not exist %expanded_data_cdb_dir% md %expanded_data_cdb_dir%
if %paths_okay% equ true if not exist %collapsed_modded_data_cdb_dir% md %collapsed_modded_data_cdb_dir%
if %paths_okay% equ true if not exist %packed_modded_res_pak_dir% md %packed_modded_res_pak_dir%
goto menu

:path_steamlibrary 
echo  ...---===### SteamLibrary Path ###===---...
echo.
echo  Enter the full path to your SteamLibrary directory.
echo  Like so (but obviously make it _your_ path):
echo  C:\Program Files (x86)\Steam\SteamLibrary
echo  (no need for double-quotes around the path)
echo.
echo  NOTE: This will overwrite any previously stored path.
echo.
set /p "path_steamlibrary=Enter path and press return > "
>path_steamlibrary.ini echo %path_steamlibrary%
goto varsetup

:path_mods
echo  ...---===### ModFiles Path ###===---...
echo.
echo  Enter the full path to your Mods directory where
echo  you want to store unpacked and modified files.
echo  Like so (but make it the path you want to use):
echo  D:\deadcells_datadir
echo  (no need for double-quotes around the path)
echo.
echo  NOTE: This will overwrite any previously stored path.
echo.
set /p "path_mods=Enter path and press return > "
>path_mods.ini echo %path_mods%
goto varsetup

:unpack_res_pak
if %path_steamlibrary% equ unset goto failure
if %path_mods% equ unset goto failure
rem unpack original res.pak
echo.
echo  Unpacking res.pak: --------------------------------
echo on
%paktool% -expand -outdir %unpacked_res_pak_dir% -refpak %res_pak%
echo off 1>nul
echo  ---------------------------------------------------
goto menu

:unpack_data_cdb
if %path_steamlibrary% equ unset goto failure
if %path_mods% equ unset goto failure
rem unpack original data.cdb from unpacked res.pak
echo.
echo  Expanding data.cdb: -------------------------------
echo on
%cdbtool% -expand -outdir %expanded_data_cdb_dir% -refCDB %data_cdb%
echo off 1>nul
echo  ---------------------------------------------------
goto menu

:collapse_data_cdb
if %path_steamlibrary% equ unset goto failure
if %path_mods% equ unset goto failure
rem collapse modified data.cdb directory into a new data.cdb
echo.
echo  Collapsing to new data.cdb: -----------------------
echo on
%cdbtool% -collapse -indir %expanded_data_cdb_dir% -outcdb %modded_data_cdb%
echo off 1>nul
echo  ---------------------------------------------------
goto menu

:pack_res_pack
if %path_steamlibrary% equ unset goto failure
if %path_mods% equ unset goto failure
rem pack new (modified) data.cdb into a res.pak suitable for using as a mod
echo.
echo  Packing new res.pak: ------------------------------
echo on
%paktool% -creatediffpak -refpak %res_pak% -indir %collapsed_modded_data_cdb_dir% -outpak %modded_res_pak%
echo off 1>nul
echo  ---------------------------------------------------
goto menu

:failure
echo.
echo  Cannot proceed; steam library or mod path aren't set.
echo  Set both of those and then try again.
echo  ----
pause
goto menu

:end

