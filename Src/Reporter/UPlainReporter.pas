{
 * UPlainReporter.pas
 *
 * Defines classes that generates a plain text report about some given version
 * information.
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
 * The Original Code is UPlainReporter.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2004-2011 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *   NONE
 * 
 * ***** END LICENSE BLOCK *****
}


unit UPlainReporter;


interface

uses
  // Delphi
  Windows,
  // Project
  IntfVerInfoReport, IntfVerInfoReader, UReporter, UTextStreamWriter;

type

  {
  TPlainReporter:
    Writes a descriptive report about given version information.
  }
  TPlainReporter = class(TReporter, IVerInfoReporter3)
  private
    procedure ReportFFI(const Writer: TTextStreamWriter;
      const FFI: TVSFixedFileInfo);
      {Writes details of fixed file information that is stored in given
      structure}
    procedure ReportVarInfo(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader);
      {Writes information about the given variable file information}
  protected
    procedure DoReport(const VI: IVerInfoReader;
      const Writer: TTextStreamWriter; const Header: WideString); override;
      {Reads version information using given reader and writes a report on it,
      including given header, as plain text}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UReportConsts, UDisplayFmt, UVerUtils;


{ TPlainReporter }

resourcestring
  // TPlainReporter specific strings
  // translation label and descriptions
  sTXTTranslation    = 'Translation';
  sTXTNoStringInfo   = '(No string info)';
  sTXTNoTransInfo    = '(No translation info)';


procedure TPlainReporter.DoReport(const VI: IVerInfoReader;
  const Writer: TTextStreamWriter; const Header: WideString);
  {Reads version information using given reader and writes a report on it,
  including given header, as plain text}
var
  Idx: Integer; // loops thru all translations in version info
begin
  Assert(Assigned(VI));
  // Write out the header, if any
  if Header <> '' then
  begin
    Writer.WriteTextLine(Header);
    Writer.WriteTextLine;
  end;
  // Display the fixed file information
  ReportFFI(Writer, VI.FixedFileInfo);
  // Display variable file info for each translation
  for Idx := 0 to Pred(VI.VarInfoCount) do
    ReportVarInfo(Writer, VI.VarInfo(Idx));
end;

procedure TPlainReporter.ReportFFI(const Writer: TTextStreamWriter;
  const FFI: TVSFixedFileInfo);
  {Writes details of fixed file information that is stored in given structure}
begin
  // Display file and product information
  Writer.WriteTextLine([sFileVersion, ' = ',
    UDisplayFmt.VerFmt(FFI.dwFileVersionMS, FFI.dwFileVersionLS)]);
  Writer.WriteTextLine([sProductVersion, ' = ',
    UDisplayFmt.VerFmt(FFI.dwProductVersionMS, FFI.dwProductVersionLS)]);
  // display file flags and mask as descriptions or as symbolic constants
  Writer.WriteTextLine([sFileFlagsMask, ' = ',
    UVerUtils.FileFlagsDesc(FFI.dwFileFlagsMask, dtDesc)]);
  Writer.WriteTextLine([sFileFlags, ' = ',
    UVerUtils.FileFlagsDesc(FFI.dwFileFlags, dtDesc)]);
  // Display file OS
  Writer.WriteTextLine([sFileOS,' = ',
    UVerUtils.FileOSDesc(FFI.dwFileOS, dtDesc)]);
  // Display file type
  Writer.WriteTextLine([sFileType, ' = ',
    UVerUtils.FileTypeDesc(FFI.dwFileType, dtDesc)]);
  // Display file sub type if required
  if UVerUtils.FileTypeHasSubType(FFI.dwFileType) then
    // we have a sub type
    Writer.WriteTextLine([sFileSubType, ' = ',
      UVerUtils.FileSubTypeDesc(FFI.dwFileType, FFI.dwFileSubType, dtDesc)])
  else
    // no sub type: say so
    Writer.WriteTextLine([sFileSubType, ' = ', sNa]);
  // Display date
  Writer.WriteTextLine([sCreateDate, ' = ',
    UDisplayFmt.DateFmt(FFI.dwFileDateMS, FFI.dwFileDateLS)]);
end;

procedure TPlainReporter.ReportVarInfo(const Writer: TTextStreamWriter;
  const VarInfo: IVerInfoVarReader);
  {Writes information about the given variable file information}
var
  DispStr: string;  // string used to display translation
  Idx: Integer;     // loops thru all strings in translation
begin
  // Set up translation string
  // store language and character set
  DispStr := Format(
    '%s - %s',
    [LanguageDesc(VarInfo.LanguageID), CharSetDesc(VarInfo.CharSet)]
  );
  // note if there is a problem
  case VarInfo.Status of
    VARVERINFO_STATUS_OK: ;// Do nothing
    VARVERINFO_STATUS_TRANSONLY: DispStr := DispStr + ' ' + sTXTNoStringInfo;
    VARVERINFO_STATUS_STRTABLEONLY: DispStr := DispStr + ' ' + sTXTNoTransInfo;
  end;
  // write out translation info
  Writer.WriteTextLine([sTXTTranslation, ' = ', DispStr]);
  // Display all strings in translation
  for Idx := 0 to Pred(VarInfo.StringCount) do
    Writer.WriteTextLine(
      ['  ', VarInfo.StringName(Idx), ' = ', VarInfo.StringValue(Idx)]
    );
end;

end.
