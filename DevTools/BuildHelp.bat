@rem ---------------------------------------------------------------------------
@rem Script used to build help file for Version Information Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2011
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

rem Build Project's HTML help file
setlocal
cd ..\Src\Help
call build
endlocal

rem Build WinHelp for context menu handler
setlocal
cd ..\Src\CtxMenu
call build help
endlocal
