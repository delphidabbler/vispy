@rem ---------------------------------------------------------------------------
@rem Script used to delete Version Information Spy's temp and backup source
@rem files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007-2011
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

echo Deleting temporary files

set RootDir=.\..

del /S %RootDir%\*.~* 
del /S %RootDir%\*.bak
del /S %RootDir%\*.ddp 
del /S %RootDir%\*.dsk 
del /S /AH %RootDir%\*.GID 
del /S %RootDir%\*.identcache
del /S %RootDir%\*.local
del /S %RootDir%\*.tmp
echo.

echo Deleting temporary sub-directories
if exist %RootDir%\Release rmdir /S /Q %RootDir%\Release
for /F "usebackq" %%i in (`dir /S /B /A:D %RootDir%\__history*`) do rmdir /S /Q %%i

echo Done.

endlocal
