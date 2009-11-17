@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of Version
@rem Information Spy
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 AUg 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set OutFile=Release\dd-vis7.zip

rem Delete any existing binary release zip file
if exist %OutFile% del %OutFile%

rem Store setup file in zip file
zip -j -9 %OutFile% Exe\VIS-Setup-*.exe
rem Store readme file in zip file
zip -j -9 %OutFile% Docs\ReadMe.htm

endlocal
