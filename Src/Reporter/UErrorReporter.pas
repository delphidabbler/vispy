{ ##
  @PROJECT_NAME             Version Information Spy Reporter DLL
  @PROJECT_DESC             Provides reporter objects that write reports about
                            version information to a stream.
  @FILE                     UErrorReporter.pas
  @COMMENTS                 Defines an object that implements the
                            IVerInfoErrReporter interface. The object writes a
                            HTML report of any errors or inconsistencies in
                            version information.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 06/05/2004
      @COMMENTS             Original version.
    )
  )
}


{
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
 * The Original Code is UErrorReporter.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UErrorReporter;


interface


uses
  // Delphi
  ActiveX,
  // Project
  IntfVerInfoReport, IntfVerInfoReader, UHTMLWriter;

type

  {
    TErrorReporter:
      This class implements the IVerInfoErrReporter interface and writes a HTML
      report of any errors or inconsistencies in version information.

      Inheritance: TErrorReporter -> [TInterfacedObject]
  }
  TErrorReporter = class(TInterfacedObject, IVerInfoErrReporter)
  private
    fLastError: WideString;
      {Records details of last error, or '' if no error}
  protected
    procedure WriteErrorReport(const Stm: IStream; const VI: IVerInfoReader;
      const VarInfo: IVerInfoVarReader2);
      {Writes error report to given strram for translation referenced by VarInfo
      within version information given by VI. VarInfo must reference a
      translation whose status indicates an error condition}
    procedure DoMissingTransReport(const Writer: THTMLWriter;
      const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
      {Writes an error report noting that there is no translation entry matching
      the string table whose details are given by VarInfo, in the version
      information referenced by VI. Error report includes source code example
      showing required corrections}
    procedure DoNoTransReport(const Writer: THTMLWriter;
      const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
      {Writes an error report noting that there is no translation entry present
      in the version information referenced by VI, but there is a string table
      referenced by VarInfo. Error report includes source code example showing
      required corrections}
    procedure DoMissingStrTableReport(const Writer: THTMLWriter;
      const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
      {Writes an error report noting that there is no string table matching the
      translation given by VarInfo in the version information referenced by VI.
      Error report includes source code example showing required corrections}
    procedure DoNoStrInfoReport(const Writer: THTMLWriter;
      const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
      {Writes an error report noting that there is no string table present in
      the version information referenced by VI, but there is a translation entry
      referenced by VarInfo. Error report includes source code example showing
      required corrections}
  protected
    { IVerInfoErrReporter methods }
    function ReportTransErrToStream(const VI: IVerInfoReader;
      const Stm: IStream; const TransIdx: Integer): HResult; stdcall;
      {Writes an HTML report of any errors and inconsistencies in the version
      information accessed by the given VI object to the given stream}
    function LastError: WideString;
      {Returns description of error if previous operation failed, or '' if
      previous operation succeeded}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows,
  // Project
  UVerUtils;


{ TErrorReporter }

resourcestring
  // THTMLReporter specific strings
  // title
  sHTMLTitle              = 'Version Information Spy Error Report';
  // string table errors
  sMissingStrExplain      = 'The version information''s VarFileInfo block '
                            + 'contains a Translation entry for language '
                            + '0x%0:0.4X [%2:s] and character set %1:d [%3:s] '
                            + 'but there is no string table in the '
                            + 'StringFileInfo block that matches this '
                            + 'translation. A string table named '
                            + '"%0:0.4X%1:0.4X" is required to fix this '
                            + 'problem.';
  sMissingStrCodeIntro    = 'The string file info block could be ammended as '
                            + 'follows (additions highlighted in red):';
  sOtherStrValueNote      = 'other string table blocks here';
  sStrEntryNote           = 'any required string table entries go here';
  sNoStrExplain           = 'The version information''s VarFileInfo block '
                            + 'contains a Translation entry for language '
                            + '0x%0:0.4X [%2:s] and character set %1:d [%3:s] '
                            + 'but there are no string tables in the '
                            + 'StringFileInfo block. A string table named '
                            + '"%0:0.4X%1:0.4X" is required to fix this '
                            + 'problem.';
  sNoStrCodeIntro         = 'The required string file info block is as follows '
                            + '(additions highlighted in red):';
  sNoStrCodeNote          = 'NOTE: If the resource file contains no '
                            + 'StringFileInfo block then such a block must '
                            + 'also be added to the file (see above).';
  // translation table errors
  sMissingTransExplain    =  'The version information contains a string '
                            + 'information table (BLOCK "%0:0.4X%1:0.4X") for '
                            + 'which there is no matching Translation value in '
                            + 'the VarFileInfo block. A translation entry of '
                            + '0x%0:0.4X, %1:d is required to fix this '
                            + 'problem, as follows.';
  sMissingTransCodeNote   = 'NOTE: the required additions are highlighted in '
                            + 'red.';
  sNoTransExplain         = 'The version information contains a string '
                            + 'information table (BLOCK "%0:0.4X%1:0.4X") but '
                            + 'the VarFileInfo block contains no translation '
                            + 'information. A translation entry of '
                            + '0x%0:0.4X, %1:d is required to fix this '
                            + 'problem, as follows.';
  sNoTransCodeNote        = 'NOTE: the required additions are highlighted in '
                            + 'red. If the VarFileInfo block is not present '
                            + 'such a block should also be added.';
  // error messages
  sBadStatusCode          = 'Invalid translation status code';
  sBadStatusExCode        = 'Unexpected extended status value in translation';


procedure TErrorReporter.DoMissingStrTableReport(const Writer: THTMLWriter;
  const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
  {Writes an error report noting that there is no string table matching the
  translation given by VarInfo in the version information referenced by VI.
  Error report includes source code example showing required corrections}
var
  LangID: Word;     // language ID of translation
  CharSet: Word;    // character set of translation
  CodeStr: string;  // used to store corrected RC source code
begin
  // Record translation's language and character set
  LangID := VarInfo.LanguageID;
  CharSet := VarInfo.CharSet;
  // Write explanatory paragraphs
  Writer.WritePara(
    tgPara,
    '',
    Format(
      sMissingStrExplain,
      [LangID, CharSet,
      UVerUtils.LanguageDesc(LangID), UVerUtils.CharSetDesc(CharSet)]
    )
  );
  Writer.WritePara(tgPara, '', sMissingStrCodeIntro);
  // Build string showing corrected RC source code & write it preformatted
  CodeStr := 'BLOCK "StringFileInfo"'#13#10
    + '{'#13#10
    + '  ...'#13#10
    + '  ... ' + sOtherStrValueNote + #13#10
    + '  ...'#13#10
    + HTMLTag(tgSpan, True, 'class="highlight"')
    + Format('  BLOCK "%0:0.4X%1:0.4X"'#13#10, [LangID, CharSet])
    + '  {'#13#10
    + '    /* ' + sStrEntryNote + ' */'#13#10
    + '  }'#13#10
    + HTMLTag(tgSpan, False)
    + '}';
  Writer.WritePara(tgPre, '', CodeStr);
end;

procedure TErrorReporter.DoMissingTransReport(const Writer: THTMLWriter;
  const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
  {Writes an error report noting that there is no translation entry matching the
  string table whose details are given by VarInfo, in the version information
  referenced by VI. Error report includes source code example showing required
  corrections}
var
  Idx: Integer;     // loops thru all translations in version info
  CodeStr: string;  // used to build corrected source code
begin
  // Write explanatory paragraph
  Writer.WritePara(
    tgPara,
    '',
    Format(sMissingTransExplain, [VarInfo.LanguageID, VarInfo.CharSet])
  );
  // Write pre-formatted corrected source code
  // start of VarFileInfo block
  CodeStr := 'BLOCK "VarFileInfo"'#13#10
    + '{'#13#10;
  CodeStr := CodeStr + '  VALUE "Translation"';
  // output each translation, with correction highlighted
  for Idx := 0 to Pred(VI.VarInfoCount) do
  begin
    CodeStr := CodeStr;
    if VI.VarInfo(Idx) = VarInfo then
      CodeStr := CodeStr + HTMLTag(tgSpan, True, 'class="highlight"');
    CodeStr := CodeStr + Format(
      ', 0x%0:0.4X, %1:d', [VI.VarInfo(Idx).LanguageID, VI.VarInfo(Idx).CharSet]
    );
    if VI.VarInfo(Idx) = VarInfo then
      CodeStr := CodeStr + HTMLTag(tgSpan, False);
  end;
  // close VarFileInfo block
  CodeStr := CodeStr + #13#10'}';
  // write the code
  Writer.WritePara(tgPre, '', CodeStr);
  // Write note about corrected code
  Writer.WritePara(tgPara, '', sMissingTransCodeNote);
end;

procedure TErrorReporter.DoNoStrInfoReport(const Writer: THTMLWriter;
  const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
  {Writes an error report noting that there is no string table present in the
  version information referenced by VI, but there is a translation entry
  referenced by VarInfo. Error report includes source code example showing
  required corrections}
var
  LangID: Word;     // language ID of translation
  CharSet: Word;    // character set of translation
  CodeStr: string;  // used to store corrected RC source code
begin
  // Record translation's language and character set
  LangID := VarInfo.LanguageID;
  CharSet := VarInfo.CharSet;
  // Write explanatory paragraphs
  Writer.WritePara(
    tgPara,
    '',
    Format(
      sNoStrExplain,
      [LangID, CharSet,
      UVerUtils.LanguageDesc(LangID), UVerUtils.CharSetDesc(CharSet)]
    )
  );
  Writer.WritePara(tgPara, '', sNoStrCodeIntro);
  // Build string showing corrected RC source code & write it preformatted
  CodeStr := 'BLOCK "StringFileInfo"'#13#10
    + '{'#13#10
    + HTMLTag(tgSpan, True, 'class="highlight"')
    + Format('  BLOCK "%0:0.4X%1:0.4X"'#13#10, [LangID, CharSet])
    + '  {'#13#10
    + '    /* ' + sStrEntryNote + ' */'#13#10
    + '  }'#13#10
    + HTMLTag(tgSpan, False)
    + '}';
  Writer.WritePara(tgPre, '', Format(CodeStr, [LangID, CharSet]));
  // Write note about corrected code
  Writer.WritePara(tgPara, '', sNoStrCodeNote);
end;

procedure TErrorReporter.DoNoTransReport(const Writer: THTMLWriter;
  const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
  {Writes an error report noting that there is no translation entry present in
  the version information referenced by VI, but there is a string table
  referenced by VarInfo. Error report includes source code example showing
  required corrections}
var
  Idx: Integer;     // loops thru all translations in version info
  CodeStr: string;  // used to build corrected source code
begin
  // Write explanatory paragraph
  Writer.WritePara(
    tgPara,
    '',
    Format(sNoTransExplain, [VarInfo.LanguageID, VarInfo.CharSet])
  );
  // Write pre-formatted corrected source code
  // start of VarFileInfo block - highlight the whole block
  CodeStr := 'BLOCK "VarFileInfo"'#13#10
    + '{'#13#10
    + HTMLTag(tgSpan, True, 'class="highlight"')
    + '  VALUE "Translation"';
  // output translation(s)
  for Idx := 0 to Pred(VI.VarInfoCount) do
  begin
    CodeStr := CodeStr + ', ' + Format(
      '0x%0:0.4X, %1:d', [VI.VarInfo(Idx).LanguageID, VI.VarInfo(Idx).CharSet]
    );
  end;
  // close VarFileInfo block
  CodeStr := CodeStr + HTMLTag(tgSpan, False) + #13#10'}';
  // write the code
  Writer.WritePara(tgPre, '', CodeStr);
  // Write note about corrected code
  Writer.WritePara(tgPara, '', sNoTransCodeNote);
end;

function TErrorReporter.LastError: WideString;
  {Returns description of error if previous operation failed, or '' if previous
  operation succeeded}
begin
  Result := fLastError;
end;

function TErrorReporter.ReportTransErrToStream(const VI: IVerInfoReader;
  const Stm: IStream; const TransIdx: Integer): HResult;
  {Writes an HTML report of any errors and inconsistencies in the version
  information accessed by the given VI object to the given stream}
var
  VarInfo: IVerInfoVarReader2;  // interface to translation details
begin
  try
    // Assume no error
    fLastError := '';
    // Get interface to required translation details
    VarInfo := VI.VarInfo(TransIdx) as IVerInfoVarReader2;
    if not Assigned(VarInfo) then
      raise Exception.CreateFmt(
        'Translation index %d out of range', [TransIdx]
      );
    // Report depends on translation's status
    case VarInfo.Status of
      VARVERINFO_STATUS_OK:
        // No report: return value to indicate this
        Result := S_FALSE;
      VARVERINFO_STATUS_TRANSONLY,
      VARVERINFO_STATUS_STRTABLEONLY:
      begin
        // Report required: write it
        WriteErrorReport(Stm, VI, VarInfo);
        Result := S_OK;
      end;
      else
        // Invalid / unknown status report
        raise Exception.Create(sBadStatusCode);
    end;
  except
    // We have error: record text and return error code
    on E: Exception do
    begin
      Result := E_FAIL;
      fLastError := E.Message;
    end;
  end;
end;

procedure TErrorReporter.WriteErrorReport(const Stm: IStream;
  const VI: IVerInfoReader; const VarInfo: IVerInfoVarReader2);
  {Writes error report to given strram for translation referenced by VarInfo
  within version information given by VI. VarInfo must reference a translation
  whose status indicates an error condition}
var
  Writer: THTMLWriter;  // helper object used to write HTML to stream
begin
  // Create writer object
  Writer := THTMLWriter.Create(Stm);
  try
    // Write out HTML header code
    Writer.WriteHeader(sHTMLTitle);
    // Write report appropriate to error
    case VarInfo.StatusEx of
      VARVERINFO_STATUS_TRANSONLY:
        DoMissingStrTableReport(Writer, VI, VarInfo);
      VARVERINFO_STATUS_STRTABLEONLY:
        DoMissingTransReport(Writer, VI, VarInfo);
      VARVERINFO_STATUS_TRANSONLY or VARVERINFO_STATUSEX_NOSTRTABLE:
        DoNoStrInfoReport(Writer, VI, VarInfo);
      VARVERINFO_STATUS_STRTABLEONLY or VARVERINFO_STATUSEX_NOTRANS:
        DoNoTransReport(Writer, VI, VarInfo);
      else
        // Invalid status
        raise Exception.Create(sBadStatusExCode);
    end;
    // Write HTML footer code
    Writer.WriteFooter;
  finally
    Writer.Free;
  end;
end;

end.
