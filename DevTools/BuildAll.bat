@rem ---------------------------------------------------------------------------
@rem Script used to build all Version Information Spy Applications, DLLs and the
@rem install program.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

set ErrorMsg=
if exist ..\Exe\VIBinData.dll goto allok

echo *** ERROR: VIBinData.dll not found
goto end

:allok

rem First build binary resource files
:Build_Resources
call BuildResources.bat

rem Next build pascal files (requires resource file to exist)
:Build_Pascal
call BuildPascal.bat

rem Now build help files
:Build_Help
call BuildHelp.bat

rem Finally build install program (requires exe, dll, help and 3rd party files)
:Build_Installer
call BuildInstaller.bat

:end

endlocal
