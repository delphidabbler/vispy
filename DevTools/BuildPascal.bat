@rem ---------------------------------------------------------------------------
@rem Script used to build Pascal source files for all Version Information Spy
@rem Applications and DLLs.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2010
@rem
@rem $Rev$
@rem $Date$
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
