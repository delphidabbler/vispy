@rem ---------------------------------------------------------------------------
@rem Script used to build the DelphiDabbler Version Information Spy help file.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2011
@rem
@rem $Rev$
@rem $Date$
@rem
@rem Requires:
@rem   Microsoft HTML Help Compiler
@rem
@rem The are no required environment variables, however the following
@rem environment variable is optional:
@rem   HHCROOT to reference the directory where Microsoft HTML Help Compiler is
@rem     installed. If not set the compiler must be on the path
@rem
@rem Switches: no switches are required
@rem
@rem ---------------------------------------------------------------------------

@echo off

setlocal

echo DelphiDabbler VIS Help Build Script
echo -----------------------------------

echo Setting Up Local Environment Variables

set HelpSrcDir=.\
set HHCExe="%HHCROOT%\HHC.exe"
if "%HHCROOT%" == "" set HHCExe="HHC.exe"

echo Local Environment Variables OK.

echo Building Help Project ...
echo.

set FVHelpBase=VIS
set FVHelpPrj=%HelpSrcDir%%FVHelpBase%.hhp

echo Compiling %FVHelpPrj%

%HHCExe% %FVHelpPrj%

echo.
echo DONE.

endlocal
