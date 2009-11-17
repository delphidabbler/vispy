@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing source code of Version
@rem Information Spy
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 Aug 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

rem Tidy up temp and non required files
call Tidy.bat

setlocal

cd ..

set OutFile=Release\dd-vis7-src.zip

rem Delete any existing source release zip file
if exist %OutFile% del %OutFile%

rem Copy all source files except .dsk files to Src sub directory
zip -r -9 %OutFile% Src
zip -d %OutFile% *.dsk

rem Copy all binary resource files to Bin subsdirectory
zip -r -9 %OutFile% Bin\*\*.res

rem Copy subsidiary documentation files to Doc sub directory
zip -r -9 %OutFile% Docs\License.txt Docs\License.rtf Docs\ReadMe.htm
zip -r -9 %OutFile% Docs\pad_file.xml Docs\ChangeLog.txt Docs\InstMsg.rtf

rem Copy main documentation files to root directory
zip -j -9 %OutFile% Docs\ReadMe-Src.txt Docs\MPL.txt Docs\SourceCodeLicenses.txt

endlocal
