@rem ---------------------------------------------------------------------------
@rem Script used to gather together all thrid party assets required to test, and
@rem create install file for, Version Information Spy.
@rem
@rem Copyright (C) Peter Johnson (www.delphidabbler.com), 2007
@rem
@rem v1.0 of 22 AUg 2007 - First version.
@rem ---------------------------------------------------------------------------

@echo off

rem VIBinData.dll is required in Exe directory
echo Getting VIBinData.dll
copy ..\..\VIBinData\Exe\VIBinData.dll ..\Exe\VIBinData.dll

echo.
echo DONE.
