{
 * UHTMLWriter.pas
 *
 * Defines a class and helper functions that output HTML tags and content.
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
 * The Original Code is UHTMLWriter.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UHTMLWriter;


interface


uses
  // Delphi
  ActiveX,
  // Project
  UTextStreamWriter;


type

  {
  TCompoundTags:
    Enumeration of the supported compound HTML tags.
  }
  TCompoundTags = (
    tgHTML, tgHead, tgTitle, tgStyle, tgBody,
    tgHeading1, tgHeading2, tgHeading3, tgPara, tgPre,
    tgTable, tgTableRow, tgTableHead, tgTableCell,
    tgSpan, tgEmphasised, tgStrong
  );

  {
  TSimpleTags:
    Enumerations of the supported simple HTML tags.
  }
  TSimpleTags = (tgBreak, tgLink);

  {
  THTMLWriter:
    Class that outputs HTML tags and content.

    Inheritance: THTMLWriter -> [TObject]
  }
  THTMLWriter = class(TObject)
  private
    fWriter: TTextStreamWriter;
      {Writer object used to output the HTML code}
    fOwnWriter: Boolean;
      {Flag determines if the text writer object used to write to streams is
      owned by this object (and therefore freed by it) or is owned externally}
  public
    constructor Create(const Writer: TTextStreamWriter;
      const OwnWriter: Boolean = False); overload;
      {Class constructor: creates object that will write output using the given
      writer object. If OwnWriter is true then the writer will be freed when
      this object is destroyed}
    constructor Create(const Stm: IStream); overload;
      {Class constructor: creates object that will write output onto the given
      stream}
    destructor Destroy; override;
      {Class destructor: frees any owned writer object}
    procedure WriteHeader(const Title: string);
      {Begins HTML document with given title and embedded style sheet}
    procedure WriteBodyStart;
      {Opens body section with single cell table containing whole body to
      constrain report to required width}
    procedure WriteBodyEnd;
      {Closes main body table and body element}
    procedure WritePara(const Tag: TCompoundTags; const Attrib, Text: string);
      {Writes a paragraph or other compound HTML statement. The given text is
      enclosed in opening and closing tags of given kind. If Attrib is not ''
      the attributes passed in this parameter are included in the opening tag}
    procedure WriteTableStart;
      {Begins a table}
    procedure WriteTableRow(const Cols: array of string);
      {Writes a table row with each string in the Cols array written to a
      separate column}
    procedure WriteTableSepRow(const ColSpan: Integer);
      {Writes an empty "separator" row that spans width of table and has a rule
      image as a background}
    procedure WriteTableHeader(const Header: string; const ColSpan: Integer);
      {Writes a table header row with given title spanned across given number of
      columns}
    procedure WriteTableEnd;
      {Closes a table}
    procedure WriteBreak;
      {Writes out a HTML line break}
    procedure WriteFooter;
      {Closes HTML document}
  end;


{ Helper routines }

function HTMLTag(Tag: TCompoundTags; Open: Boolean;
  const Params: string = ''): string; overload;
  {Returns code for given compound tag. If Open then an opening tag is returned,
  which include the given parameters if Params <> ''. If Open is false then
  Params is ignored and a closing tag is returned}

function HTMLTag(Tag: TSimpleTags; const Params: string = ''): string; overload;
  {Returns code for given simple tag. If Params <> '' then the tag includes the
  given parameters}

function HTMLResURL(const ResName: string): string;
  {Returns a URL using the res:// protocol for the given resource name within
  this DLL's resources}

function HTMLEnclose(const Tag: TCompoundTags; const Text: string): string;
  {Returns the given text enclosed between opening and closing tags of the
  given kind}

function HTMLHelpLink(const HelpKW: string): string;
  {Returns an image link that references a custom help:// protocol link for the
  given help keyword. (These links are used to access WinHelp from the rendered
  HTML}

function HTMLFillBackgroundStyle: string;
  {Returns an in-line style attribute that causes an object to display a
  gradient filled bar in its background}

function HTMLRuleBackgroundStyle: string;
  {Returns an in-line style attribute that causes an object to display a
  gradient filled rule in its background}

function HTMLBombImage: string;
  {Returns the HTML for an image of a "bomb" used to denote errors}


implementation


{$Resource HTML.res}  // contains style sheet, images and help html used in
                      // html reports etc


uses
  // Delphi
  SysUtils;


const
  // List of compound tags
  cCompoundTags: array[TCompoundTags] of string = (
    'html', 'head', 'title', 'style', 'body',
    'h1', 'h2', 'h3', 'p', 'pre',
    'table', 'tr', 'th', 'td',
    'span', 'em', 'strong'
  );

  // List of simple tags
  cSimpleTags: array[TSimpleTags] of string = (
    'br', 'link'
  );


{ Helper routines }

function HTMLTag(Tag: TCompoundTags; Open: Boolean;
  const Params: string = ''): string; overload;
  {Returns code for given compound tag. If Open then an opening tag is returned,
  which include the given parameters if Params <> ''. If Open is false then
  Params is ignored and a closing tag is returned}
const
  // the opening parts of closing and opening tags respectively
  cTagOpeners: array[Boolean] of string = ('</', '<');
begin
  Result := cTagOpeners[Open] + cCompoundTags[Tag];
  if Open and (Params <> '') then
    Result := Result + ' ' + Params;
  Result := Result + '>'
end;

function HTMLTag(Tag: TSimpleTags; const Params: string = ''): string; overload;
  {Returns code for given simple tag. If Params <> '' then the tag includes the
  given parameters}
begin
  Result := '<' + cSimpleTags[Tag];
  if Params <> '' then
    Result := Result + ' ' + Params;
  Result := Result + ' />';
end;

function HTMLEnclose(const Tag: TCompoundTags; const Text: string): string;
  {Returns the given text enclosed between opening and closing tags of the
  given kind}
begin
  Result := HTMLTag(Tag, True) + Text + HTMLTag(Tag, False);
end;

function HTMLResURL(const ResName: string): string;
  {Returns a URL using the res:// protocol for the given resource name within
  this DLL's resources}
begin
  // Format is res://<DLL name>/<resource name>
  // by default resource 23 (RT_HTML) is assumed
  Result := Format('res://%s/%s', [GetModuleName(HInstance), ResName]);
end;

function HTMLHelpLink(const HelpKW: string): string;
  {Returns an image link that references a custom help:// protocol link for the
  given help keyword. (These links are used to access WinHelp from the rendered
  HTML}
begin
  Result := Format(
    '<a href="%s_hlp"><img src="%s" border="0" align="right" /></a>',
    [HTMLResURL(HelpKW), HTMLResURL('Help_gif')]
  );
end;

function HTMLFillBackgroundStyle: string;
  {Returns an in-line style attribute that causes an object to display a
  gradient filled bar in its background}
begin
  Result := 'style="background-image:url('''
    + HTMLResURL('Fill_gif')
    + '''); background-repeat: no-repeat;"';
end;

function HTMLRuleBackgroundStyle: string;
  {Returns an in-line style attribute that causes an object to display a
  gradient filled rule in its background}
begin
  Result := 'style="background-image:url('''
    + HTMLResURL('Rule_gif')
    + '''); background-repeat: no-repeat;"';
end;

function HTMLBombImage: string;
  {Returns the HTML for an image of a "bomb" used to denote errors}
begin
  Result := Format(
    '<img src="%s" border="0" align="left" />', [HTMLResURL('Bomb_gif')]
  );
end;


{ THTMLWriter }

constructor THTMLWriter.Create(const Stm: IStream);
  {Class constructor: creates object that will write output onto the given
  stream}
begin
  // Create owned writer object that wraps stream
  Create(TTextStreamWriter.Create(Stm), True);
end;

constructor THTMLWriter.Create(const Writer: TTextStreamWriter;
  const OwnWriter: Boolean);
  {Class constructor: creates object that will write output using the given
  writer object. If OwnWriter is true then the writer will be freed when this
  object is destroyed}
begin
  inherited Create;
  // Record parameters
  fWriter := Writer;
  fOwnWriter := OwnWriter;
end;

destructor THTMLWriter.Destroy;
  {Class destructor: frees any owned writer object}
begin
  if fOwnWriter then
    FreeAndNil(fWriter);
  inherited;
end;

procedure THTMLWriter.WriteBodyEnd;
  {Closes main body table and body element}
begin
  // Close body table
  fWriter.WriteTextLine(HTMLTag(tgTableCell, False));
  fWriter.WriteTextLine(HTMLTag(tgTableRow, False));
  fWriter.WriteTextLine(HTMLTag(tgTable, False));
  // Close body section
  fWriter.WriteTextLine(HTMLTag(tgBody, False));
end;

procedure THTMLWriter.WriteBodyStart;
  {Opens body section with single cell table containing whole body to constrain
  report to required width}
begin
  // Open body section
  fWriter.WriteTextLine(HTMLTag(tgBody, True));
  // Open single cell body table
  fWriter.WriteTextLine(
    HTMLTag(tgTable, True, 'width="461px" cellspacing="0" cellpadding="0"'
    )
  );
  fWriter.WriteTextLine(HTMLTag(tgTableRow, True));
  fWriter.WriteTextLine(HTMLTag(tgTableCell, True));
end;

procedure THTMLWriter.WriteBreak;
  {Writes out a HTML line break}
begin
  fWriter.WriteTextLine(HTMLTag(tgBreak));
end;

procedure THTMLWriter.WriteFooter;
  {Closes HTML document}
begin
  fWriter.WriteTextLine(HTMLTag(tgHTML, False));
end;

procedure THTMLWriter.WriteHeader(const Title: string);
  {Begins HTML document with given title and embedded style sheet}
begin
  // Open document
  fWriter.WriteTextLine(HTMLTag(tgHTML, True));
  // Write head section ...
  fWriter.WriteTextLine(HTMLTag(tgHead, True));
  // ... with linked style sheet (in resources) ...
  fWriter.WriteTextLine(
    HTMLTag(
      tgLink,
      Format('rel="stylesheet" href="%s"', [HTMLResURL('Report_css')])
    )
  );
  // ... and required title ...
  fWriter.WriteTextLine(
    [HTMLTag(tgTitle, True), Title, HTMLTag(tgTitle, False)]
  );
  // ... and finally close section
  fWriter.WriteTextLine(HTMLTag(tgHead, False));
end;

procedure THTMLWriter.WritePara(const Tag: TCompoundTags;
  const Attrib, Text: string);
  {Writes a paragraph or other compound HTML statement. The given text is
  enclosed in opening and closing tags of given kind. If Attrib is not '' the
  attributes passed in this parameter are included in the opening tag}
var
  OpenTag: string;  // the opening tag (may include attributes)
  CloseTag: string; // the closing tag
begin
  // Create the opening and closing tags
  OpenTag := HTMLTag(Tag, True, Attrib);
  CloseTag := HTMLTag(Tag, False);
  // Write out the text, surrounded by the tags
  fWriter.WriteTextLine([OpenTag, Text, CloseTag]);
end;

procedure THTMLWriter.WriteTableEnd;
  {Closes a table}
begin
  fWriter.WriteTextLine(HTMLTag(tgTable, False));
end;

procedure THTMLWriter.WriteTableHeader(const Header: string;
  const ColSpan: Integer);
  {Writes a table header row with given title spanned across given number of
  columns}
begin
  fWriter.WriteTextLine(
    [HTMLTag(tgTableRow, True),
    HTMLTag(tgTableHead, True, Format('colspan="%d"', [ColSpan])),
    Header,
    HTMLTag(tgTableHead, False),
    HTMLTag(tgTableRow, False)]
  );
end;

procedure THTMLWriter.WriteTableRow(const Cols: array of string);
  {Writes a table row with each string in the Cols array written to a separate
  column}
var
  Idx: Integer; // loops thru column text
begin
  // Open the row
  fWriter.WriteTextLine(HTMLTag(tgTableRow, True));
  // Write a column for each item of text (use &nbsp; if no text)
  for Idx := Low(Cols) to High(Cols) do
    if Cols[Idx] <> '' then
      WritePara(tgTableCell, '', Cols[Idx])
    else
      WritePara(tgTableCell, '', '&nbsp;');
  // Close the row
  fWriter.WriteTextLine(HTMLTag(tgTableRow, False));
end;

procedure THTMLWriter.WriteTableSepRow(const ColSpan: Integer);
  {Writes an empty "separator" row that spans width of table and has a rule
  image as a background}
begin
  // Open the row (we use ruled background style
  fWriter.WriteTextLine(HTMLTag(tgTableRow, True, HTMLRuleBackgroundStyle));
  // Write empty cell spanning given number of rows
  fWriter.WriteTextLine(HTMLTag(tgTableCell, True, 'colspan="2"'));
  fWriter.WriteTextLine(HTMLTag(tgTableCell, False));
  // Close the row
  fWriter.WriteTextLine(HTMLTag(tgTableRow, False));
end;

procedure THTMLWriter.WriteTableStart;
  {Begins a table}
begin
  fWriter.WriteTextLine(HTMLTag(tgTable, True, 'width="461px" border="0"'));
end;

end.
