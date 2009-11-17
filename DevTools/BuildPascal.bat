@rem ---------------------------------------------------------------------------
@rem Script used to build Pascal source files for all Version Information Spy
@rem Applications and DLLs.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 AUg 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

rem Build Windows application
setlocal
cd ..\Src\App
call build pas
endlocal

rem Build command line application
setlocal
cd ..\Src\CmdApp
call build pas
endlocal

rem Build shell extension
setlocal
cd ..\Src\CtxMenu
call build pas
endlocal

rem Build file reader DLL
setlocal
cd ..\Src\Reader
call build pas
endlocal

rem Build reporter DLL
setlocal
cd ..\Src\Reporter
call build pas
endlocal
