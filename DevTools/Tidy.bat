@rem ---------------------------------------------------------------------------
@rem Script used to delete Version Information Spy's temp and backup source
@rem files
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 Aug 2007 - First version.
@rem ---------------------------------------------------------------------------

setlocal

@echo off
set SrcDir=..\Src
set DocsDir=..\Docs

echo Deleting *.~* from "%SrcDir%" and subfolders
del /S %SrcDir%\*.~* 
echo.

echo Deleting *.~* from "%DocsDir%" and subfolders
del /S %DocsDir%\*.~*
echo.

echo Deleting *.ddp from "%SrcDir%" and subfolders
del %SrcDir%\App\*.ddp
echo.

echo Done.

endlocal
