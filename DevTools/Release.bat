@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of Version
@rem Information Spy
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2011
@rem
@rem Uses the ZIPROOT environment variable, if set, to find Zip.exe. If ZIPROOT
@rem is not set Zip.exe must be on the system path.
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

set ZIPEXE="%ZIPROOT%\Zip.exe"
if "%ZIPROOT%" == "" set ZIPEXE="Zip.exe"

cd ..

set OutFile=Release\dd-vis7.zip

rem Ensure Release folder exists and does not contain output file
if not exist Release mkDir Release
if exist %OutFile% del %OutFile%

rem Create zip file containing setup program and readme
%ZIPEXE% -j -9 %OutFile% Exe\VIS-Setup-*.exe
%ZIPEXE% -j -9 %OutFile% Docs\ReadMe.htm

endlocal
