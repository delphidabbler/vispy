@rem ---------------------------------------------------------------------------
@rem Script used to build the DelphiDabbler Version Information Spy project
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2011
@rem
@rem $Rev$
@rem $Date$
@rem
@rem Requires:
@rem   Borland Delphi 2010
@rem   Borland BRCC32 from Delphi 2010 installation
@rem   DelphiDabbler Version Information Editor v2.11 or later, available from
@rem     www.delphidabbler.com 
@rem
@rem Also requires the following environment variables:
@rem   DELPHI2010 to be set to the install directory of Delphi 2010
@rem   DELPHIDABLIBD2010 to be set to the install directory of the required
@rem     DelphiDabbler components on Delphi 2010
@rem
@rem The following environment variables are optional:
@rem   VIEDROOT to reference the directory where Version Information Editor is
@rem     installed. If not set the program must be on the path
@rem
@rem Switches: exactly one of the following must be provided
@rem   all - build everything
@rem   res - build binary resource files only
@rem   pas - build Delphi Pascal project only
@rem
@rem ---------------------------------------------------------------------------

@echo off

setlocal


rem ----------------------------------------------------------------------------
rem Sign on
rem ----------------------------------------------------------------------------

echo DelphiDabbler VIS App Build Script
echo ----------------------------------

goto Config


rem ----------------------------------------------------------------------------
rem Configure script per command line parameter
rem ----------------------------------------------------------------------------

:Config
echo Configuring script

rem reset all config variables
set BuildAll=
set BuildResources=
set BuildPascal=

rem check switches
if "%~1" == "all" goto Config_BuildAll
if "%~1" == "res" goto Config_BuildResources
if "%~1" == "pas" goto Config_BuildPascal
set ErrorMsg=Unknown switch "%~1"
if "%~1" == "" set ErrorMsg=No switch specified
goto Error

rem set config variables
:Config_BuildAll
set BuildResources=1
set BuildPascal=1
goto Config_OK

:Config_BuildResources
set BuildResources=1
goto Config_OK

:Config_BuildPascal
set BuildPascal=1
goto Config_OK

:Config_OK
echo Configured OK.
echo.

goto CheckEnvVars


rem ----------------------------------------------------------------------------
rem Check that required environment variables exist
rem ----------------------------------------------------------------------------

:CheckEnvVars

echo Checking predefined environment environment variables
if not defined DELPHI2010 goto BadDELPHI2010Env
if not defined DELPHIDABLIBD2010 goto BadDELPHIDABLIBD2010Env
echo Environment Variables OK.
echo.

goto SetEnvVars

:BadDELPHI2010Env
set ErrorMsg=DELPHI2010 Environment variable not defined
goto Error

:BadDELPHIDABLIBD2010Env
set ErrorMsg=DELPHIDABLIBD2010 Environment variable not defined
goto Error


rem ----------------------------------------------------------------------------
rem Set up required environment variables
rem ----------------------------------------------------------------------------

:SetEnvVars
echo Setting Up Local Environment Variables

rem source directory
set SrcDir=.\
rem binary files directory
set BinDir=..\..\Bin\App\
rem executable files directory
set ExeDir=..\..\Exe\

rem executable programs
rem Delphi 2010 - use full path since maybe multple installations
set DCC32Exe="%DELPHI2010%\Bin\DCC32.exe"
rem Borland Resource Compiler - use full path since maybe multple installations
set BRCC32Exe="%DELPHI2010%\Bin\BRCC32.exe"
rem Version Information Editor: VIEDROOT may specify install dir
set VIEDExe="%VIEDROOT%\VIEd.exe"
if "%VIEDROOT%" == "" set VIEDExe="VIEd.exe"

echo Local Environment Variables OK.
echo.


rem ----------------------------------------------------------------------------
rem Start of build process
rem ----------------------------------------------------------------------------

:Build
echo BUILDING ...
echo.

goto Build_Resources


rem ----------------------------------------------------------------------------
rem Build resource files
rem ----------------------------------------------------------------------------

:Build_Resources
if not defined BuildResources goto Build_Pascal
echo Building Resources
echo.

rem Ver info resource

set VerInfoBase=VFileVer
set VerInfoSrc=%SrcDir%%VerInfoBase%.vi
set VerInfoTmp=%SrcDir%%VerInfoBase%.rc
set VerInfoRes=%BinDir%%VerInfoBase%.res

echo Compiling %VerInfoSrc% to %VerInfoRes%
rem VIedExe creates temp resource .rc file from .vi file
set ErrorMsg=
%VIEdExe% -makerc %VerInfoSrc%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoSrc%
if not "%ErrorMsg%"=="" goto VerInfoRes_Tidy
rem BRCC32Exe compiles temp resource .rc file to required .res
%BRCC32Exe% %VerInfoTmp% -fo%VerInfoRes%
if errorlevel 1 set ErrorMsg=Failed to compile %VerInfoTmp%
:VerInfoRes_Tidy
if exist %VerInfoTmp% del %VerInfoTmp%
if not "%ErrorMsg%"=="" goto Error
echo.

rem Images resource

set ImagesBase=Images
set ImagesSrc=%SrcDir%%ImagesBase%.rc
set ImagesRes=%BinDir%%ImagesBase%.res
echo Compiling %ImagesSrc% to %ImagesRes%
%BRCC32Exe% %ImagesSrc% -fo%ImagesRes%
if errorlevel 1 set ErrorMsg=Failed to compile %ImagesRes%
if not "%ErrorMsg%"=="" goto Error

goto Build_Pascal


rem ----------------------------------------------------------------------------
rem Build Pascal project
rem ----------------------------------------------------------------------------

:Build_Pascal
if not defined BuildPascal goto Build_End
echo Building Pascal Source
echo.

rem Set up required env vars
set PascalBase=FileVer
set PascalSrc=%SrcDir%%PascalBase%.dpr
set PascalExe=%ExeDir%%PascalBase%.exe
set DDabLib=%DELPHIDABLIBD2010%

rem Do compilation
%DCC32Exe% -B %PascalSrc% -U"%DDabLib%"
if errorlevel 1 goto Pascal_Error
goto Pascal_End

rem Handle errors
:Pascal_Error
set ErrorMsg=Failed to compile %PascalSrc%
if exist %PascalExe% del %PascalExe%
goto Error

:Pascal_End
echo Pascal Source Built OK.
echo.

goto Build_End


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
