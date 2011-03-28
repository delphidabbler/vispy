@rem ---------------------------------------------------------------------------
@rem Script used to prepare the Version Information Spy project source tree.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

echo Creating output directories:

setlocal
cd ..

echo   Bin and sub-directories
if exist Bin rmdir Bin /S /Q
mkdir Bin
cd Bin
mkdir App
mkdir CmdApp
mkdir CtxMenu
mkdir Reader
mkdir Reporter

cd ..
echo   Exe
if exist Exe rmdir Exe /S /Q
mkdir Exe

echo   Release
if exist Release rmdir Release /S /Q
mkdir Release

endlocal

echo .

setlocal

echo Creating .cfg files from templates:
cd ..\Src

echo   FileVer
copy App\FileVer.cfg.tplt App\FileVer.cfg

echo   FileVerCmd
copy CmdApp\FileVerCmd.cfg.tplt CmdApp\FileVerCmd.cfg

echo   FileVerCM
copy CtxMenu\FileVerCM.cfg.tplt CtxMenu\FileVerCM.cfg

echo   FVFileReader
copy Reader\FVFileReader.cfg.tplt Reader\FVFileReader.cfg

echo   FVReport
copy Reporter\FVReport.cfg.tplt Reporter\FVReport.cfg

echo DONE

endlocal
