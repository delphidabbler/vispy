{
 * URCReporter.pas
 *
 * Defines classes that generates decompiled resource source code and corrected
 * source code that corrects errors and inconsistencies in given version
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
 * The Original Code is URCReporter.pas.
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


unit URCReporter;


interface


uses
  // Delphi
  Windows,
  // Delphi
  IntfVerInfoReport, IntfVerInfoReader, UReporter, UTextStreamWriter;

type

  {
  TAbstractRCReporter:
    Abstract base class for other classes that write source code. This class
    writes code that is common to all source code reports and defines abstract
    methods that are overridden by concreate descendant classes to write the
    parts of the code that vary depending on the class type.
  }
  TAbstractRCReporter = class(TReporter, IVerInfoReporter3)
  protected
    function AddMissingStringTables: Boolean; virtual; abstract;
      {Descendant classes return true if entries for missing string tables are
      to be added to the StringFileInfo block and false if they are to be left
      out}
    procedure ReportStringTableComment(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader); virtual; abstract;
      {Descendant classes write out any required comments in the string table
      described by VarInfo}
    procedure ReportMissingStringTableComment(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader); virtual; abstract;
      {Descendant classes write out any required comments about a missing string
      table for the translation described by VarInfo}
    procedure ReportMissingStringInfoComment(const Writer: TTextStreamWriter);
      virtual; abstract;
      {Descendant classes write out any required comments about a missing
      StringFileInfo block}
    function AddMissingTranslations: Boolean; virtual; abstract;
      {Descendant classes return true if entries for missing translations are to
      be added to the Translation statement and false if they are to be left
      out}
    procedure ReportTranslationComment(const Writer: TTextStreamWriter;
      const Trans: IVerInfoVarReader); virtual; abstract;
      {Descendant classes write out any comments about the translation described
      by VarInfo}
    procedure ReportMissingVarInfoComment(const Writer: TTextStreamWriter);
      virtual; abstract;
      {Descendant classes write out any comments about a missing translation
      described by VarInfo}
    procedure ReportHeader(const Writer: TTextStreamWriter;
      const Header: string); virtual;
      {Writes the given header as comments}
    procedure ReportFFI(const Writer: TTextStreamWriter;
      const FFI: TVSFixedFileInfo); virtual;
      {Writes the source code for the given fixed file information}
    procedure ReportStringFileInfo(const Writer: TTextStreamWriter;
      const VI: IVerInfoReader); virtual;
      {Writes the source code for the string file info within the given version
      information}
    procedure ReportTranslations(const Writer: TTextStreamWriter;
      const VI: IVerInfoReader); virtual;
      {Writes the source code for the variable file info within the given
      version information to the given stream}
    procedure DoReport(const VI: IVerInfoReader;
      const Writer: TTextStreamWriter; const Header: WideString);
      override;
      {Reads version information using given reader and writes its source code
      using the given writer. The given header is included in the source code as
      a comment}
  end;

  {
  TRCReporter:
    Writes version information RC source code to an output stream or file. The
    source code includes comments noting any errors and inconsistencies in the
    version information.
  }
  TRCReporter = class(TAbstractRCReporter, IVerInfoReporter3)
  protected
    function AddMissingStringTables: Boolean; override;
      {Returns false since missing string tables are to be left out of the code}
    procedure ReportStringTableComment(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader); override;
      {Writes out a comment only if the string table has no matching translation
      entry. The comment provides information about the missing entry}
    procedure ReportMissingStringTableComment(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader); override;
      {Writes out a comment noting information about the missing table}
    procedure ReportMissingStringInfoComment(const Writer: TTextStreamWriter);
      override;
      {Writes out a comment noting that the StrFileInfo block is missing from
      the source}
    function AddMissingTranslations: Boolean; override;
      {Returns false since missing translations are to be left out of the code}
    procedure ReportTranslationComment(const Writer: TTextStreamWriter;
      const Trans: IVerInfoVarReader); override;
      {Writes comments for any translation that has inconsistencies: i.e. if a
      translation is missing or if a translation has no associated string table}
    procedure ReportMissingVarInfoComment(const Writer: TTextStreamWriter);
      override;
      {Writes out a comment noting information about the VarFileInfo block}
  end;

  {
  TFixedRCReporter:
    Writes version information RC source code to an output stream or file. The
    source code is modified to fix any errors or inconsistencies in the version
    information.
  }
  TFixedRCReporter = class(TAbstractRCReporter, IVerInfoReporter3)
  protected
    function AddMissingStringTables: Boolean; override;
      {Returns true since the source code is to be corrected to include missing
      string tables}
    procedure ReportStringTableComment(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader); override;
      {Writes out a comment only if the string table was missing from the
      version information. The comment notes an empty string table has been
      added to the source}
    procedure ReportMissingStringTableComment(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader); override;
      {No comments are written about missing string tables since such tables are
      added to the source code}
    procedure ReportMissingStringInfoComment(const Writer: TTextStreamWriter);
      override;
      {No comments are written about missing string info blocks since they are
      added to the source code}
    function AddMissingTranslations: Boolean; override;
      {Returns true since the source code is to be corrected to include missing
      translations}
    procedure ReportTranslationComment(const Writer: TTextStreamWriter;
      const Trans: IVerInfoVarReader); override;
      {Writes a comment to FixedFileInfo blocks noting where translation entries
      have been added}
    procedure ReportMissingVarInfoComment(const Writer: TTextStreamWriter);
      override;
      {No comments are written about VarFileInfo blocks since such blocks are
      added to the source code}
  end;


implementation


uses
  // Delphi
  SysUtils, Classes,
  // Project
  UVerUtils;


resourcestring
  // TRCReporter specific strings
  // warning messages
  sRCNoTransInfo =
    'NOTE: there is no matching translation for this string table';
  sRCTransNeeded = 'NOTE: Translation 0x%0:0.4X, %1:d required for ' +
    'string table %0:0.4X%1:0.4X';
  sRCTransAdded = 'FIX: Translation 0x%0:0.4X, %1:d was added for ' +
    'string table %0:0.4X%1:0.4X';
  sRCNoVarInfoBlock = 'NOTE: The VarFileInfo block is missing';
  sRCStrTableNeeded = 'NOTE: String table %0:0.4X%1:0.4X required for ' +
    'translation 0x%0:0.4X, %1:d';
  sRCStrTableAdded = 'FIX: Empty String table was added for translation '
    + '0x%0.4X, %d';
  sRCStrTableAddedNote = 'NOTE: Enter string values here';
  sRCNoStrTableForTrans = 'NOTE: No string table for translation 0x%0.4X, %d';
  sRCNoStrInfoBlock = 'NOTE: The StringFileInfo block is missing';


{ TAbstractRCReporter }

procedure TAbstractRCReporter.DoReport(const VI: IVerInfoReader;
  const Writer: TTextStreamWriter; const Header: WideString);
  {Reads version information using given reader and writes its source code using
  the given writer. The given header is included in the source code as a
  comment}
begin
  Assert(Assigned(VI));
  // Write out header
  if Header <> '' then
    ReportHeader(Writer, Header);
  // Write version info header
  Writer.WriteTextLine('1 VERSIONINFO');
  Writer.WriteTextLine;
  // Write the fixed file information source
  ReportFFI(Writer, VI.FixedFileInfo);
  // Write string table and translation info if we have any translations
  if VI.VarInfoCount > 0 then
  begin
    Writer.WriteTextLine('{');
    ReportStringFileInfo(Writer, VI);
    ReportTranslations(Writer, VI);
    Writer.WriteTextLine('}');
  end;
end;

procedure TAbstractRCReporter.ReportFFI(const Writer: TTextStreamWriter;
  const FFI: TVSFixedFileInfo);
  {Writes the source code for the given fixed file information}
begin
  // Write Fixed File Info
  // file version
  Writer.WriteTextLine(
    Format('FILEVERSION %d, %d, %d, %d',
      [
        HiWord(FFI.dwFileVersionMS),
        LoWord(FFI.dwFileVersionMS),
        HiWord(FFI.dwFileVersionLS),
        LoWord(FFI.dwFileVersionLS)
      ]
    )
  );
  // product version
  Writer.WriteTextLine(
    Format('PRODUCTVERSION %d, %d, %d, %d',
      [
        HiWord(FFI.dwProductVersionMS),
        LoWord(FFI.dwProductVersionMS),
        HiWord(FFI.dwProductVersionLS),
        LoWord(FFI.dwProductVersionLS)
      ]
    )
  );
  // Write file flags mask in hex format
  Writer.WriteTextLine(
    Format('FILEFLAGSMASK 0x%0.2X', [FFI.dwFileFlagsMask])
  );
  // Write any file flags as symbolic constants
  if FFI.dwFileFlags <> 0 then
    Writer.WriteTextLine(
      Format('FILEFLAGS %s', [UVerUtils.FileFlagsDesc(FFI.dwFileFlags, dtCode)])
    );
  // Write file os as symbolic constant
  Writer.WriteTextLine(
    Format('FILEOS %s', [UVerUtils.FileOSDesc(FFI.dwFileOS, dtCode)])
  );
  // Write file type as symbolic constant
  Writer.WriteTextLine(
    Format('FILETYPE %s', [UVerUtils.FileTypeDesc(FFI.dwFileType, dtCode)])
  );
  // If file has a sub type, write sub type as symbol or hex as required
  if UVerUtils.FileTypeHasSubType(FFI.dwFileType) then
    Writer.WriteTextLine(
      Format('FILESUBTYPE %s',
        [UVerUtils.FileSubTypeDesc(FFI.dwFileType, FFI.dwFileSubType, dtCode)])
    );
  // Write separating line
  Writer.WriteTextLine;
end;

procedure TAbstractRCReporter.ReportHeader(const Writer: TTextStreamWriter;
  const Header: string);
  {Writes the given header as comments}
var
  Headers: TStringList; // list of lines in header
  MaxLen: Integer;      // length of longest line in header
  Idx: Integer;         // loops thru lines of header
begin
  Assert(Header <> '');
  // Store header in string list to make separate lines easily accessible
  Headers := TStringList.Create;
  try
    Headers.Text := Header;
    // Find length of longest line in header: used to format comments
    MaxLen := 0;
    for Idx := 0 to Pred(Headers.Count) do
      if Length(Headers[Idx]) > MaxLen then
        MaxLen := Length(Headers[Idx]);
    // Write out header with rules above and below
    Writer.WriteTextLine(
      ['/* ', StringOfChar('=', MaxLen), ' */']
    );
    Writer.WriteTextLine(
      ['/* ', StringOfChar(' ', MaxLen), ' */']
    );
    for Idx := 0 to Pred(Headers.Count) do
      Writer.WriteTextLine(
        [
          '/* ',
          Headers[Idx],
          StringOfChar(' ', MaxLen - Length(Headers[Idx])),
          ' */'
        ]
      );
    Writer.WriteTextLine(
      ['/* ', StringOfChar(' ', MaxLen), ' */']
    );
    Writer.WriteTextLine(
      ['/* ', StringOfChar('=', MaxLen), ' */']
      );
    Writer.WriteTextLine;
  finally
    Headers.Free;
  end;
end;

procedure TAbstractRCReporter.ReportStringFileInfo(
  const Writer: TTextStreamWriter; const VI: IVerInfoReader);
  {Writes the source code for the string file info within the given version
  information}

  // ---------------------------------------------------------------------------
  function StringInfoBlockPresent: Boolean;
    {Returns true if the version information contains a StringFileInfo block}
  var
    TransIdx: Integer;  // loops thru all translations
  begin
    // We return true if we have any string table or normal entries
    Result := False;
    for TransIdx := 0 to Pred(VI.VarInfoCount) do
    begin
      if VI.VarInfo(TransIdx).Status <> VARVERINFO_STATUS_TRANSONLY then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
  // ---------------------------------------------------------------------------

var
  VarInfo: IVerInfoVarReader; // reads variable file information
  TransIdx: Integer;          // loops thru all translations in version info
  StrIdx: Integer;            // loops thru all strings in string table
begin
  Assert(VI.VarInfoCount > 0);
  // Check if we're to write the string info block
  if StringInfoBlockPresent or AddMissingStringTables then
  begin
    // Write the string file info block
    // Write the header
    Writer.WriteTextLine('  BLOCK "StringFileInfo"');
    Writer.WriteTextLine('  {');
    // Write the string table blocks
    for TransIdx := 0 to Pred(VI.VarInfoCount) do
    begin
      // Get reference to variable file info
      VarInfo := VI.VarInfo(TransIdx);
      // We only write out table if there was one in original file
      if (VarInfo.Status <> VARVERINFO_STATUS_TRANSONLY) or
        AddMissingStringTables then
      begin
        // Write the string table
        // write out sub block for string table
        Writer.WriteTextLine(
          Format(
            '    BLOCK "%0.4X%0.4X"',
            [VarInfo.LanguageID, VarInfo.CharSet]
          )
        );
        Writer.WriteTextLine('    {');
        // write out any comment for string table
        ReportStringTableComment(Writer, VarInfo);
        // write out string table entries
        for StrIdx := 0 to Pred(VarInfo.StringCount) do
          Writer.WriteTextLine(
            Format(
              '      VALUE "%s", "%s\000"',
              [VarInfo.StringName(StrIdx), VarInfo.StringValue(StrIdx)]
            )
          );
        // write closing brace for string table sub-block
        Writer.WriteTextLine('    }');
      end
      else
        // Not writing this table: write any required comment
        ReportMissingStringTableComment(Writer, VarInfo);
    end;
    // Write closing brace for string file info block
    Writer.WriteTextLine('  }');
  end
  else
    // Not writing a StringFileInfo block: write any required comment
    ReportMissingStringInfoComment(Writer);
end;

procedure TAbstractRCReporter.ReportTranslations(
  const Writer: TTextStreamWriter; const VI: IVerInfoReader);
  {Writes the source code for the variable file info within the given version
  information to the given stream}

  // ---------------------------------------------------------------------------
  function TranslationIsPresent: Boolean;
    {Returns true if the version information contains a VarFileInfo block}
  var
    TransIdx: Integer;  // loops thru all translations
  begin
    // We return true if we have any translation or normal entries
    Result := False;
    for TransIdx := 0 to Pred(VI.VarInfoCount) do
    begin
      if VI.VarInfo(TransIdx).Status <> VARVERINFO_STATUS_STRTABLEONLY then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
  // ---------------------------------------------------------------------------

var
  TransIdx: Integer;        // loops thru each translation
  Trans: IVerInfoVarReader; // references object storing translation info
begin
  Assert(VI.VarInfoCount > 0);
  // Check if we're to write the VarFileInfo block
  if TranslationIsPresent or AddMissingTranslations then
  begin
    // Writing the VarFileInfo block
    // Open the block
    Writer.WriteTextLine('  BLOCK "VarFileInfo"');
    Writer.WriteTextLine('  {');
    // Write out translation value key  ...
    Writer.WriteText('    VALUE "Translation"');
    // ... and write language and char set info for each translation on one line
    for TransIdx := 0 to Pred(VI.VarInfoCount) do
    begin
      Trans := VI.VarInfo(TransIdx);
      // Check if we need to write a particular translation
      // we only do this if there's an entry or we're adding missing ones
      if (Trans.Status <> VARVERINFO_STATUS_STRTABLEONLY)
        or AddMissingTranslations then
        Writer.WriteText(
          Format(', 0x%0.4X, %d', [Trans.LanguageID, Trans.CharSet])
        );
    end;
    // Terminate the translation value line
    Writer.WriteTextLine;
    // Write out any required comments for each translation
    for TransIdx := 0 to Pred(VI.VarInfoCount) do
    begin
      Trans := VI.VarInfo(TransIdx);
      ReportTranslationComment(Writer, Trans);
    end;
    // Write closing brace for var file info block
    Writer.WriteTextLine('  }');
  end
  else
    // We're not writing a VarFileInfo block: write any comment about this
    ReportMissingVarInfoComment(Writer);
end;


{ TRCReporter }

function TRCReporter.AddMissingStringTables: Boolean;
  {Returns false since missing string tables are to be left out of the code}
begin
  Result := False;
end;

function TRCReporter.AddMissingTranslations: Boolean;
  {Returns false since missing translations are to be left out of the code}
begin
  Result := False;
end;

procedure TRCReporter.ReportMissingStringInfoComment(
  const Writer: TTextStreamWriter);
  {Writes out a comment noting that the StrFileInfo block is missing from the
  source}
begin
  Writer.WriteTextLine('  /*');
  Writer.WriteTextLine(['    ', sRCNoStrInfoBlock]);
  Writer.WriteTextLine('  */');
end;

procedure TRCReporter.ReportMissingStringTableComment(
  const Writer: TTextStreamWriter; const VarInfo: IVerInfoVarReader);
  {Writes out a comment noting information about the missing table}
begin
  // We have translation with no associated string info: report it
  Writer.WriteTextLine('    /*');
  Writer.WriteTextLine(
    [
      '      ',
      Format(sRCNoStrTableForTrans, [VarInfo.LanguageID, VarInfo.CharSet])
    ]
  );
  Writer.WriteTextLine('    */');
end;

procedure TRCReporter.ReportMissingVarInfoComment(
  const Writer: TTextStreamWriter);
  {Writes out a comment noting information about the VarFileInfo block}
begin
  Writer.WriteTextLine('  /*');
  Writer.WriteTextLine(['    ', sRCNoVarInfoBlock]);
  Writer.WriteTextLine('  */');
end;

procedure TRCReporter.ReportStringTableComment(
  const Writer: TTextStreamWriter; const VarInfo: IVerInfoVarReader);
  {Writes out a comment only if the string table has no matching translation
  entry. The comment provides information about the missing entry}
begin
  if VarInfo.Status = VARVERINFO_STATUS_STRTABLEONLY then
    Writer.WriteTextLine(
      Format('      /* %s */', [sRCNoTransInfo])
    );
end;

procedure TRCReporter.ReportTranslationComment(
  const Writer: TTextStreamWriter; const Trans: IVerInfoVarReader);
  {Writes comments for any translation that has inconsistencies: i.e. if a
  translation is missing or if a translation has no associated string table}
begin
  case Trans.Status of
    VARVERINFO_STATUS_STRTABLEONLY:
      Writer.WriteTextLine(
        [
          '    /* ',
          Format(sRCTransNeeded, [Trans.LanguageID, Trans.CharSet]),
          ' */'
        ]
      );
    VARVERINFO_STATUS_TRANSONLY:
      Writer.WriteTextLine(
        [
          '    /* ',
          Format(sRCStrTableNeeded, [Trans.LanguageID, Trans.CharSet]),
          ' */'
        ]
      );
  end;
end;


{ TFixedRCReporter }

function TFixedRCReporter.AddMissingStringTables: Boolean;
  {Returns true since the source code is to be corrected to include missing
  string tables}
begin
  Result := True;
end;

function TFixedRCReporter.AddMissingTranslations: Boolean;
  {Returns true since the source code is to be corrected to include missing
  translations}
begin
  Result := True;
end;

procedure TFixedRCReporter.ReportMissingStringInfoComment(
  const Writer: TTextStreamWriter);
  {No comments are written about missing string info blocks since they are added
  to the source code}
begin
  // Do nothing
end;

procedure TFixedRCReporter.ReportMissingStringTableComment(
  const Writer: TTextStreamWriter; const VarInfo: IVerInfoVarReader);
  {No comments are written about missing string tables since such tables are
  added to the source code}
begin
  // Do nothing
end;

procedure TFixedRCReporter.ReportMissingVarInfoComment(
  const Writer: TTextStreamWriter);
  {No comments are written about VarFileInfo blocks since such blocks are added
  to the source code}
begin
  // Do nothing
end;

procedure TFixedRCReporter.ReportStringTableComment(
  const Writer: TTextStreamWriter; const VarInfo: IVerInfoVarReader);
  {Writes out a comment only if the string table was missing from the version
  information. The comment notes an empty string table has been added to the
  source}
begin
  if VarInfo.Status = VARVERINFO_STATUS_TRANSONLY then
  begin
    Writer.WriteTextLine(
      [
        '      /* ',
        Format(sRCStrTableAdded, [VarInfo.LanguageID, VarInfo.CharSet]),
        ' */'
      ]
    );
    Writer.WriteTextLine(['      /* ', sRCStrTableAddedNote, ' */']);
  end;
end;

procedure TFixedRCReporter.ReportTranslationComment(
  const Writer: TTextStreamWriter; const Trans: IVerInfoVarReader);
  {Writes a comment to FixedFileInfo blocks noting where translation entries
  have been added}
begin
  if Trans.Status = VARVERINFO_STATUS_STRTABLEONLY then
    Writer.WriteTextLine(
      [
        '    /* ',
        Format(sRCTransAdded, [Trans.LanguageID, Trans.CharSet]),
        ' */'
      ]
    );
end;

end.
