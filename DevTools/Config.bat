@rem ---------------------------------------------------------------------------
@rem Script used to prepare Version Information Spy project source code tree.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2009
@rem
@rem $Rev$
@rem $Date$
@rem ---------------------------------------------------------------------------

@echo off

setlocal

cd ..\Src

echo Creating .cfg and .dof files from templates:
echo   FileVer
copy App\FileVer.cfg.tplt App\FileVer.cfg
copy App\FileVer.dof.tplt App\FileVer.dof

echo   FileVerCmd
copy CmdApp\FileVerCmd.cfg.tplt CmdApp\FileVerCmd.cfg
copy CmdApp\FileVerCmd.dof.tplt CmdApp\FileVerCmd.dof

echo   FileVerCM
copy CtxMenu\FileVerCM.cfg.tplt CtxMenu\FileVerCM.cfg
copy CtxMenu\FileVerCM.dof.tplt CtxMenu\FileVerCM.dof

echo   FVFileReader
copy Reader\FVFileReader.cfg.tplt Reader\FVFileReader.cfg
copy Reader\FVFileReader.dof.tplt Reader\FVFileReader.dof

echo   FVReport
copy Reporter\FVReport.cfg.tplt Reporter\FVReport.cfg
copy Reporter\FVReport.dof.tplt Reporter\FVReport.dof

echo DONE

endlocal
