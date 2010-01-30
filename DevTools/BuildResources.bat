@rem ---------------------------------------------------------------------------
@rem Script used to build binary resource files for all Version Information Spy
@rem Applications and DLLs.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2010
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

rem Windows application
setlocal
cd ..\Src\App
call build res
endlocal

rem Command line application
setlocal
cd ..\Src\CmdApp
call build res
endlocal

rem Shell extension
setlocal
cd ..\Src\CtxMenu
call build res
endlocal

rem File reader DLL
setlocal
cd ..\Src\Reader
call build res
endlocal

rem Reporter DLL
setlocal
cd ..\Src\Reporter
call build res
endlocal
