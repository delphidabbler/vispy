{
 * UTextStreamWriter.pas
 *
 * Defines a writer class that outputs text to a wrapped IStream.
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
 * The Original Code is UTextStreamWriter.pas.
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


unit UTextStreamWriter;


interface


uses
  // Delphi
  ActiveX;


type

  {
  TTextStreamWriter:
    Class that outputs text to a wrapped IStream.

    Inheritance: TTextStreamWriter -> [TObject]
  }
  TTextStreamWriter = class(TObject)
  private
    fStream: IStream;
      {Stream that writer outputs text to}
  public
    constructor Create(const Stm: IStream);
      {Class constructor: records non-nil stream we're to write to}
    procedure WriteText(const Str: UnicodeString);
      {Writes the text in Str to the given stream}
    procedure WriteTextLine(const Str: UnicodeString); overload;
      {Writes the text in Str followed by a newline to the given stream}
    procedure WriteTextLine(const Strs: array of UnicodeString); overload;
      {Consecutively writes all the strings in the given array to the given
      stream, followed by a new line}
    procedure WriteTextLine; overload;
      {Writes out a new line to the given stream}
  end;


implementation


{ TTextStreamWriter }

constructor TTextStreamWriter.Create(const Stm: IStream);
  {Class constructor: records non-nil stream we're to write to}
begin
  Assert(Assigned(Stm));
  inherited Create;
  fStream := Stm;
end;

procedure TTextStreamWriter.WriteText(const Str: UnicodeString);
  {Writes the text in Str to the given stream}
begin
  fStream.Write(Pointer(PChar(Str)), Length(Str) * SizeOf(Char), nil);
end;

procedure TTextStreamWriter.WriteTextLine(const Str: UnicodeString);
  {Writes the text in Str followed by a newline to the given stream}
begin
  WriteText(Str);
  WriteText(#13#10);
end;

procedure TTextStreamWriter.WriteTextLine;
  {Writes out a new line to the given stream}
begin
  WriteTextLine('');
end;

procedure TTextStreamWriter.WriteTextLine(const Strs: array of UnicodeString);
  {Consecutively writes all the strings in the given array to the given stream,
  followed by a new line}
var
  Idx: Integer; // loops thru all strings in array
begin
  for Idx := Low(Strs) to High(Strs) do
    WriteText(Strs[Idx]);
  WriteText(#13#10);
end;

end.
