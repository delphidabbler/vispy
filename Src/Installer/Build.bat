@rem ---------------------------------------------------------------------------
@rem Script used to build the DelphiDabbler Version Information Installer
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 21 August 2007 - First version.
@rem
@rem Requires:
@rem   Inno Setup Compiler 5 with ISPP 5
@rem
@rem Also requires the following environment variables:
@rem   INNOSETUP to be set to the install directory of Inno Setup 5
@rem
@rem Switches: no switches are required
@rem
@rem ---------------------------------------------------------------------------

@echo off

setlocal


rem ----------------------------------------------------------------------------
rem Sign on
rem ----------------------------------------------------------------------------

echo DelphiDabbler VIS Installer Build Script
echo ----------------------------------------


rem ----------------------------------------------------------------------------
rem Check that required environment variables exist
rem ----------------------------------------------------------------------------

:CheckEnvVars

echo Checking predefined environment environment variables
if not defined INNOSETUP goto BadINNOSETUPEnv
echo Done.
echo.

goto SetEnvVars

:BadINNOSETUPEnv
set ErrorMsg=INNOSETUP Environment varibale not defined
goto Error


rem ----------------------------------------------------------------------------
rem Set up required environment variables
rem ----------------------------------------------------------------------------

:SetEnvVars
echo Setting Up Local Environment Variables

rem Set application paths
rem Inno Setup command line compiler
set ISCCExe="%INNOSETUP%\ISCC.exe"

rem Set input and output directories and files
set SrcDir=.\
set ExeDir=..\..\Exe
set SetupSrc=%SrcDir%FileVer7.iss
set SetupExeWild=%ExeDir%\VIS-Setup-*
echo Local Environment Variables OK.
echo.


rem ----------------------------------------------------------------------------
rem Start of build process
rem ----------------------------------------------------------------------------

:Build
echo BUILDING ...
echo.

rem ----------------------------------------------------------------------------
rem Build setup program
rem ----------------------------------------------------------------------------

rem ISCC does not return error code if compile fails so find another way to
rem detect errors

if exist %SetupExeWild% del %SetupExeWild%

%ISCCExe% %SetupSrc%

if exist %SetupExeWild% goto Setup_End
set ErrorMsg=Failed to compile %SetupSrc%
goto Error

:Setup_End
echo Done.
echo.


rem ----------------------------------------------------------------------------
rem Build completed
rem ----------------------------------------------------------------------------

:Build_End
echo BUILD COMPLETE
echo.

goto End


rem ----------------------------------------------------------------------------
rem Handle errors
rem ----------------------------------------------------------------------------

:Error
echo.
echo *** ERROR: %ErrorMsg%
echo.


rem ----------------------------------------------------------------------------
rem Finished
rem ----------------------------------------------------------------------------

:End
echo.
echo DONE.

endlocal
