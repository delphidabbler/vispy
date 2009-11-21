@rem ---------------------------------------------------------------------------
@rem Script used to create zip file containing binary release of Version
@rem Information Spy
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..

set OutFile=Release\dd-vis7.zip

rem Ensure Release folder exists and does not contain output file
if not exist Release mkDir Release
if exist %OutFile% del %OutFile%

rem Create zip file containing setup program and readme
zip -j -9 %OutFile% Exe\VIS-Setup-*.exe
zip -j -9 %OutFile% Docs\ReadMe.htm

endlocal
