@rem ---------------------------------------------------------------------------
@rem Script used to build all Version Information Spy Applications, DLLs and
@rem install program.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 AUg 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

setlocal

rem First build binary resource files
:Build_Resources
call BuildResources.bat

rem Next build pascal files (requires resource file to exist)
:Build_Pascal
call BuildPascal.bat

rem Now build help files
:Build_Help
call BuildHelp.bat

rem Copy third party files to required locations within VIS build tree
:Collect_Assets
call CollectAssets.bat

rem Finally build install program (requires exe, dll, help and 3rd party files)
:Build_Installer
call BuildInstaller.bat

endlocal
