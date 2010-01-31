{
 * UDisplayFmt.pas
 *
 * Provides routines to format version numbers and dates as strings.
 *
 * $Rev$
 * $Date$
 *
 * ***** BEGIN LICENSE BLOCK *****
 * 
 * Version: MPL 1.1
 * 
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 * 
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 * 
 * The Original Code is UDisplayFmt.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2003-2010 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *   NONE
 * 
 * ***** END LICENSE BLOCK *****
}


unit UDisplayFmt;


interface


uses
  // Delphi
  Windows;


function DateFmt(const MS, LS: DWORD): string;
  {Formats the most and least significant DWORDs making up the file creation
  time as a data string or a comment if no time is specified}

function ShortVerFmt(const Ver: DWORD): string;
  {Format the version number encoded in the given DWORD}

function VerFmt(const MS, LS: DWORD): string;
  {Format the version number encoded in the two given DWORDs}


implementation


uses
  // Delphi
  SysUtils;


resourcestring
  // Display strings
  sNoDate        = 'No date specified';
  sDateError     = 'Date has invalid value';


function DateFmt(const MS, LS: DWORD): string;
  {Formats the most and least significant DWORDs making up the file creation
  time as a data string or a comment if no time is specified}
  // -----------------------------------------------------------------------
  function WinFileTimeToDOSDateTime(const FileTime: TFileTime): Integer;
    {Converts Windows file time to DOS file date time adjusting for time zones.
    Returns 0 on error}
  var
    LocalFileTime: TFileTime; // records local Windows file time
  begin
    // Convert file time to local time
    FileTimeToLocalFileTime(FileTime, LocalFileTime);
    // Convert local time to DOS date time: return 0 on error
    if not FileTimeToDOSDateTime(
      LocalFileTime,
      LongRec(Result).Hi,
      LongRec(Result).Lo
    ) then
      Result := 0;
  end;
  // -------------------------------------------------------------------------
var
  FileTime: TFileTime;  // Windows file time (as stored in ver info)
  Date: TDateTime;      // Delphi date time for passing to format routine
begin
  try
    if (MS = 0) and (LS = 0) then
      // No date specified: return comment
      Result := sNoDate
    else
    begin
      // Store DWORDs in a Windows file time structure
      FileTime.dwLowDateTime := LS;
      FileTime.dwHighDateTime := MS;
      // Convert Windows file time to Delphi date
      Date := FileDateToDateTime(WinFileTimeToDOSDateTime(FileTime));
      // Format the date as required
      Result := DateTimeToStr(Date);
    end;
  except
    // There has been an error: return error date comment
    Result := sDateError;
  end;
end;

function ShortVerFmt(const Ver: DWORD): string;
  {Format the version number encoded in the given DWORD}
begin
  Result := Format('%d.%d', [HiWord(Ver), LoWord(Ver)]);
end;

function VerFmt(const MS, LS: DWORD): string;
  {Format the version number encoded in the two given DWORDs}
begin
  Result := Format('%d.%d.%d.%d',
    [HiWord(MS), LoWord(MS), HiWord(LS), LoWord(LS)])
end;

end.
