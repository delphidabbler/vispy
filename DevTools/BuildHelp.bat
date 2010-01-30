@rem ---------------------------------------------------------------------------
@rem Script used to build all help files for Version Information Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2010
@rem
@rem $Rev$
@rem $Date$
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
