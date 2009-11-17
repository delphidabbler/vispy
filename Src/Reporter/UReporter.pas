{ ##
  @PROJECT_NAME             Version Information Spy Reporter DLL
  @PROJECT_DESC             Provides reporter objects that write reports about
                            version information to a stream.
  @FILE                     UReporter.pas
  @COMMENTS                 Defines abstract base class for objects that
                            implement the IVerInfoReporter interface and write
                            reports that describe version information.
  @DEPENDENCIES             DelphiDabbler PJIStreams unit for TPJFileIStream
                            class.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 14/08/2003
      @COMMENTS             Changed code that writes table cells to write out
                            &nbsp; character if an empty string is to be written
                            to the cell. This ensures empty table cells display
                            properly.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 20/05/2004
      @COMMENTS             Major update - code for specific reports and support
                            code moved to separate units. This unit now contains
                            only the abstract base class for all version
                            information reports.\
                            Specifically:
                            + Removed concrete classes (TPlainReporter,
                              TSourceReporter, THTMLReporter) to separate units
                            + Moved CSS style sheet const to UHTMLWriter unit
                              (and added new values to it)
                            + Removed text writing helper routines - we now use
                              new text writing class is defined in a different
                              unit.
                            + Report object creator function moved to new unit.
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
 * The Original Code is UReporter.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2004 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UReporter;


interface


uses
  // Delphi
  ActiveX,
  // Project
  IntfVerInfoReader, UTextStreamWriter;


type

  {
  TReporter:
    Abstract base class for reporter objects that implement IVerInfoReporter.
    This class mapping the interface's output methods to a single abstract
    method that decendant classes override to produce the actual report content.

    Inheritance: TReporter -> [TInterfacedObject]
  }
  TReporter = class(TInterfacedObject)
  private
    fLastError: string;
      {Describes error if last operation failed, else is '' if last operation
      succeeded}
    procedure InternalReportToStream(const VI: IVerInfoReader;
      const Stm: IStream; const Header: WideString);
      {Performs reporting by calling abstract DoReport method: raises exception
      on error}
    procedure InternalReportToFile(const VI: IVerInfoReader;
      const FileName, Header: WideString);
      {Opens stream onto file and then performs reporting by calling abstract
      DoReport method: raises exception on error}
  protected
    procedure DoReport(const VI: IVerInfoReader;
      const Writer: TTextStreamWriter; const Header: WideString);
      virtual; abstract;
      {Abstract method that sub classes override to write a specific report of
      the given version information and header to the given stream}
  protected
    { IVerInfoReporter methods }
    function ReportToStream(const VI: IVerInfoReader;
      const Stm: IStream; const Header: WideString): WordBool; stdcall;
      {Writes report of version information accessed by the given VI object to
      the given stream. Any header specified is written out before the version
      information}
    function ReportToFile(const VI: IVerInfoReader;
      const FileName: WideString; const Header: WideString): WordBool; stdcall;
      {Writes report of version information accessed by the given VI object to
      the given file. Any header specified is written out before the version
      information}
    function LastError: WideString; stdcall;
      {Returns description of error if previous operation failed, or '' if
      previous operation succeeded}
  end;

                                     
implementation


uses
  // Delphi
  SysUtils, Classes,
  // DelphiDabbler Library
  PJIStreams;


{ TReporter }

procedure TReporter.InternalReportToFile(const VI: IVerInfoReader;
  const FileName, Header: WideString);
  {Opens stream onto file and then performs reporting by calling abstract
  DoReport method: raises exception on error}
var
  Stm: IStream;
begin
  Stm := TPJFileIStream.Create(FileName, fmCreate);
  InternalReportToStream(VI, Stm, Header);
end;

procedure TReporter.InternalReportToStream(const VI: IVerInfoReader;
  const Stm: IStream; const Header: WideString);
  {Performs reporting by calling abstract DoReport method: raises exception on
  error}
var
  Writer: TTextStreamWriter;
begin
  Writer := TTextStreamWriter.Create(Stm);
  try
    DoReport(VI, Writer, Header);
  finally
    Writer.Free;
  end;
end;

function TReporter.LastError: WideString;
  {Returns description of error if previous operation failed, or '' if previous
  operation succeeded}
begin
  Result := fLastError;
end;

function TReporter.ReportToFile(const VI: IVerInfoReader;
  const FileName, Header: WideString): WordBool;
  {Writes report of version information accessed by the given VI object to the
  given file. Any header specified is written out before the version
  information}
begin
  // Assume success
  Result := True;
  fLastError := '';
  try
    // Do the reporting
    InternalReportToFile(VI, FileName, Header);
  except
    // We have error: record text and return false
    on E: Exception do
    begin
      Result := False;
      fLastError := E.Message;
    end;
  end;
end;

function TReporter.ReportToStream(const VI: IVerInfoReader;
  const Stm: IStream; const Header: WideString): WordBool;
  {Writes report of version information accessed by the given VI object to the
  given stream. Any header specified is written out before the version
  information}
begin
  // Assume success
  Result := True;
  fLastError := '';
  try
    // Do the reporting
    InternalReportToStream(VI, Stm, Header);
  except
    // We have error: record text and return false
    on E: Exception do
    begin
      Result := False;
      fLastError := E.Message;
    end;
  end;
end;

end.
