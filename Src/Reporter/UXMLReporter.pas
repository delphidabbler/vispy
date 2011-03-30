{
 * UXMLReporter.pas
 *
 * Defines a class that generates a XML report about some given version
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
 * The Original Code is UXMLReporter.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UXMLReporter;


interface


uses
  // Delphi
  Windows,
  // Project
  IntfVerInfoReader, IntfVerInfoReport, UReporter, UTextStreamWriter;


type

  {
  TXMLReporter:
    Writes an XML report about given version information.
  }
  TXMLReporter = class(TReporter, IVerInfoReporter3)
  private
    procedure ReportFFI(const Writer: TTextStreamWriter;
      const FFI: TVSFixedFileInfo);
      {Writes XML describing fixed file information that is stored in given
      structure}
    procedure ReportVarInfo(const Writer: TTextStreamWriter;
      const VarInfo: IVerInfoVarReader);
      {Writes XML describing the given variable file information}
  protected
    procedure DoReport(const VI: IVerInfoReader;
      const Writer: TTextStreamWriter; const Header: WideString); override;
      {Reads version information using given reader and writes an XML report of
      it. Header is written as an XML comment}
  end;


implementation


uses
  // Delphi
  SysUtils, Classes,
  // Project
  UDisplayFmt;


function Indent(const Level: Byte): string;
  {Returns spaces used to indent text to a specified level}
begin
  if Level = 0 then
    Result := ''
  else
    Result := StringOfChar(' ', Level * 4);
end;

function XMLAttrs(const Attrs: TStrings): string;
  {Converts attribute info as name=value pairs into the text describing the
  attributes in XML tags}
var
  Idx: Integer; // loops thru all attributes
begin
  Result := '';
  for Idx := 0 to Pred(Attrs.Count) do
    Result := Result +
      Format(' %s="%s"', [Attrs.Names[Idx], Attrs.ValueFromIndex[Idx]]);
end;

function XMLOpeningTag(const TagName: string;
  const Attrs: TStrings = nil): string;
  {Returns an XML opening tag with optional attributes}
begin
  Result := '<' + TagName;
  if Assigned(Attrs) then
    Result := Result + XMLAttrs(Attrs);
  Result := Result + '>';
end;

function XMLSimpleTag(const TagName: string;
  const Attrs: TStrings = nil): string;
  {Returns an XML simple tag with optional attributes}
begin
  Result := '<' + TagName;
  if Assigned(Attrs) then
    Result := Result + XMLAttrs(Attrs);
  Result := Result + ' />';
end;

function XMLClosingTag(const TagName: string): string;
  {Returns an XML closing tag}
begin
  Result := Format('</%s>', [TagName]);
end;

function XMLEnclose(const TagName, Text: string;
  const Attrs: TStrings = nil): string;
  {Encloses specified text within an compound XML tag with optional attributes}
begin
  Result := XMLOpeningTag(TagName, Attrs) + Text + XMLClosingTag(TagName);
end;

function XMLCDATA(const Text: string): string;
  {Returns specified text as XML CDATA}
begin
  Result := '<![CDATA[' + Text + ']]>';
end;

{ TXMLReporter }

procedure TXMLReporter.DoReport(const VI: IVerInfoReader;
  const Writer: TTextStreamWriter; const Header: WideString);
  {Reads version information using given reader and writes an XML report of it.
  Header is written as an XML comment}
var
  Idx: Integer; // loops through all translations
begin
  inherited;
  Writer.WriteTextLine('<?xml version="1.0"?>');
  Writer.WriteTextLine(Format('<!-- %s -->', [Header]));
  Writer.WriteTextLine(XMLOpeningTag('version-info'));
  ReportFFI(Writer, VI.FixedFileInfo);
  for Idx := 0 to Pred(VI.VarInfoCount) do
    ReportVarInfo(Writer, VI.VarInfo(Idx));
  Writer.WriteTextLine(XMLClosingTag('version-info'));
end;

procedure TXMLReporter.ReportFFI(const Writer: TTextStreamWriter;
  const FFI: TVSFixedFileInfo);
  {Writes XML describing fixed file information that is stored in given
  structure}
begin
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose(
      'file-version',
      UDisplayFmt.VerFmt(FFI.dwFileVersionMS, FFI.dwFileVersionLS)
    )
  );
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose(
      'product-version',
      UDisplayFmt.VerFmt(FFI.dwProductVersionMS, FFI.dwProductVersionLS)
    )
  );
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose('file-flags-mask', IntToStr(FFI.dwFileFlagsMask))
  );
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose('file-flags', IntToStr(FFI.dwFileFlags))
  );
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose('os', IntToStr(FFI.dwFileOS))
  );
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose('file-type', IntToStr(FFI.dwFileType))
  );
  Writer.WriteTextLine(
    Indent(1) +
    XMLEnclose('file-sub-type', IntToStr(FFI.dwFileSubtype))
  );
  if (FFI.dwFileDateMS = 0) and (FFI.dwFileDateLS = 0) then
    Writer.WriteTextLine(Indent(1) + XMLSimpleTag('create-date'))
  else
    Writer.WriteTextLine(
      Indent(1) +
      XMLEnclose(
        'create-date', UDisplayFmt.DateFmt(FFI.dwFileDateMS, FFI.dwFileDateLS)
      )
    );
end;

procedure TXMLReporter.ReportVarInfo(const Writer: TTextStreamWriter;
  const VarInfo: IVerInfoVarReader);
  {Writes XML describing the given variable file information}
var
  Attrs: TStringList; // stores various attributes to be output in XML
  StrIdx: Integer;    // loops through all string info in translation
begin
  Attrs := TStringList.Create;
  try
    // write translation info
    Attrs.Add(Format('codepage=%d', [VarInfo.CharSet]));
    Attrs.Add(Format('locale=%d', [VarInfo.LanguageID]));
    Writer.WriteTextLine(Indent(1) + XMLOpeningTag('string-info', Attrs));
    for StrIdx := 0 to Pred(VarInfo.StringCount) do
    begin
      // write each string info value
      Attrs.Clear;
      Attrs.Add(Format('name=%s', [VarInfo.StringName(StrIdx)]));
      Writer.WriteTextLine(
        Indent(2) +
        XMLEnclose('value', XMLCDATA(VarInfo.StringValue(StrIdx)), Attrs)
      );
    end;
    Writer.WriteTextLine(Indent(1) + XMLClosingTag('string-info'));
  finally
    FreeAndNil(Attrs);
  end;
end;

end.
