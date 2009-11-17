@rem ---------------------------------------------------------------------------
@rem Script used to build all help files for Version Information Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 AUg 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

rem Build WinHelp for Windows application
setlocal
cd ..\Src\App
call build help
endlocal

rem Build WinHelp for context menu handler
setlocal
cd ..\Src\CtxMenu
call build help
endlocal
