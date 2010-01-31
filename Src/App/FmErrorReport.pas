{
 * FmErrorReport.pas
 *
 * Implements a dialog box that is used to display HTML reports on
 * inconsistencies and errors in version information.
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
 * The Original Code is FmErrorReport.pas.
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


unit FmErrorReport;


interface


uses
  // Delphi
  Forms, StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmGenericViewDlg, FrViewerBase, FrHTMLViewer,
  UReporterLoader, IntfVerInfoReader;


type

  {
  TErrorReportDlg:
    Dialog box that is used to display HTML reports on inconsistencies and
    errors in version information.

    Inheritance: TErrorReportDlg -> TGenericViewDlg -> TGenericDlg
      -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  TErrorReportDlg = class(TGenericViewDlg)
    frHTML: THTMLViewer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private // properties
    fVerInfo: IVerInfoReader;
    fTransIdx: Integer;
    procedure SetTransIdx(const Value: Integer);
    procedure SetVerInfo(const Value: IVerInfoReader);
  private
    fLoader: TReporterLoader;
      {Object used to load DLL that contains the reporter object}
    procedure Display;
      {Displays report in the HTML viewer frame}
  public
    property VerInfo: IVerInfoReader read fVerInfo write SetVerInfo;
      {The version information containing the translation to be reported upon}
    property TransIdx: Integer read fTransIdx write SetTransIdx;
      {The index of the translation being reported upon}
  end;


implementation


uses
  // Delphi
  SysUtils, ActiveX,
  // Project
  IntfVerInfoReport, UStringListStream;

{$R *.dfm}


resourcestring
  // Error messages
  sNoInconsistencies = 'No inconsistencies to report';
  sCantCreateReport = 'Can''t create required object';


{ TErrorReportDlg }

procedure TErrorReportDlg.Display;
  {Displays report in the HTML viewer frame}
var
  Reporter: IVerInfoErrReporter;  // object that creates report
  Stm: IStream;                   // stream that report is written to
  Content: TStrings;              // content of report frame
  Res: HResult;                   // HRESULT from various functions
begin
  // Get reference to content of HTML frame
  Content := frHTML.Content;
  // Clear the display
  Content.BeginUpdate;
  try
    Content.Clear;
    // Display report
    if Assigned(fVerInfo) then
    begin
      // We have some version info: report on it
      // create stream that updates display memo
      Stm := TStringListIStream.Create(Content, True);
      // create error reporter object
      Res := fLoader.CreateFunc(CLSID_VerInfoHTMLErrReporter, Reporter);
      if Failed(Res) then raise
        Exception.Create(sCantCreateReport);
      // write report and check result
      Res := Reporter.ReportTransErrToStream(fVerInfo, Stm, fTransIdx);
      case Res of
        S_OK: ; {Do nothing - all is well}
        S_FALSE: raise Exception.Create(sNoInconsistencies);
        else raise Exception.Create(Reporter.LastError);
      end;
    end;
  finally
    Content.EndUpdate;
  end;
end;

procedure TErrorReportDlg.FormCreate(Sender: TObject);
  {Create report DLL loader object on form creation}
begin
  inherited;
  fLoader := TReporterLoader.Create;
end;

procedure TErrorReportDlg.FormDestroy(Sender: TObject);
  {Free report DLL loader object}
begin
  inherited;
  fLoader.Free; // releases DLL
end;

procedure TErrorReportDlg.FormShow(Sender: TObject);
  {Display the report in view frame}
begin
  inherited;
  Display;
end;

procedure TErrorReportDlg.SetTransIdx(const Value: Integer);
  {Write accessor for TransIdx property: redisplays report if necessary}
begin
  if fTransIdx <> Value then
  begin
    fTransIdx := Value;
    if Visible then
      Display;
  end;
end;

procedure TErrorReportDlg.SetVerInfo(const Value: IVerInfoReader);
  {Write accessor for VerInfo property: redisplays report if necessary}
begin
  if fVerInfo <> Value then
  begin
    fVerInfo := Value;
    if Visible then
      Display;
  end;
end;

end.
