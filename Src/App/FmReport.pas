{
 * FmReport.pas
 *
 * Defines abstract base class for all dialog boxes that display version
 * information reports in different formats generated by FVReport.dll. Provides
 * core functionality and loads / unloads the DLL.
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
 * The Original Code is FmReport.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2003-2011 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *   NONE
 * 
 * ***** END LICENSE BLOCK *****
}


unit FmReport;


interface


uses
  // Delphi
  Dialogs, StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmGenericViewDlg, FrViewerBase, UReporterLoader, IntfVerInfoReader,
  UTempFiles;

type

  {
  TReportDlgClass:
    Type of classes used to display report dialog boxes.
  }
  TReportDlgClass = class of TReportBaseDlg;

  {
  TReportBaseDlg:
    Abstract base class for dialog boxes that display reports that use the
    FVReport dll to produce the report and a viewer frame that inherits from
    TViewerBase to display the report. Provides core code used to generate the
    report and display it. Also provides framework for copying the report to the
    clipboard and saving it to file. Descendent classes provide suitable viewer
    frames and supply information about the type of report required.
  }
  TReportBaseDlg = class(TGenericViewDlg)
    pnlView: TPanel;
    btnSave: TButton;
    btnCopy: TButton;
    btnView: TButton;
    dlgSave: TSaveDialog;
    procedure btnCopyClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private // properties
    fHeading: string;
    fVerInfo: IVerInfoReader;
    procedure SetHeading(const Value: string);
    procedure SetVerInfo(const Value: IVerInfoReader);
  private
    fSavedFileName: string;
      {Name of last file that was saved: may be used when we need to view a
      report in external application}
    fLoader: TReporterLoader;
      {Object used to load DLL that contains the reporter object}
    fTempFiles: TTempFiles;
      {Object used to create and dispose of temporary files}
  protected
    function GetView: TViewerBase; virtual; abstract;
      {Returns reference to viewer frame used to display report}
    function GetCLSID: TGUID; virtual; abstract;
      {CLSID of the object used to write the report: CLSID determines report
      kind}
    function GetFileDlgFilter: string; virtual; abstract;
      {Returns filter to be used in save file dialog}
    function GetFileExt: string; virtual; abstract;
      {Returns extension of associated file type}
    function StartExternalViewer(const FileName: string): Boolean;
      virtual; abstract;
      {Displays the given file in a suitable viewer application, returning True
      on success or False on failure}
    procedure Display;
      {Displays required report in viewer frame}
    function ShellExec(const FileName, ParamStr: string): Boolean;
      {Executes the given file with the given parameter string. Returns
      True if the application is started successfully and False if not. If file
      name is not an application Windows executes the file's associated
      application}
  public
    property Heading: string read fHeading write SetHeading;
      {Heading text to be written to report: separate lines should separated by
      CRLF characters}
    property VerInfo: IVerInfoReader read fVerInfo write SetVerInfo;
      {The version information to be reported upon}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows, ActiveX, ShellAPI, ClipBrd,
  // Project
  IntfVerInfoReport, UGlobals, UStringListStream;


{$R *.dfm}

resourcestring
  // Error messages
  sCantViewDoc = 'Can''t find an application with which to view document';
  sCantCreateReporter = 'Can''t create required reporter object';


{ TReportBaseDlg }

procedure TReportBaseDlg.btnCopyClick(Sender: TObject);
  {Copy button copies displayed text to clipboard when clicked}
begin
  // Content is stored as string list in viewer frame
  Clipboard.AsText := GetView.Content.Text;
end;

procedure TReportBaseDlg.btnSaveClick(Sender: TObject);
  {Save button saves displayed text to a file when clicked. User provides file
  name}
begin
  // Assign required filter to dialog box
  dlgSave.Filter := GetFileDlgFilter;
  if dlgSave.Execute then
  begin
    // Get viewer frame to save its content to required file
    GetView.SaveToFile(dlgSave.FileName);
    fSavedFileName := dlgSave.FileName;
  end;
end;

procedure TReportBaseDlg.btnViewClick(Sender: TObject);
  {View button displays document in an appropriate external viewer application,
  or displays an error message if there is no suitable viewer}
var
  FileName: string;     // name of file we are to view with external application
begin
  // Get name of file to view
  if (fSavedFileName = '') or not FileExists(fSavedFileName) then
  begin
    // document not been saved: create a temporary file to view
    FileName := fTempFiles.TempFilePath(GetFileExt);
    // viewer frame saves its content to the file
    GetView.SaveToFile(FileName);
  end
  else
    // document has been saved: view the saved file
    FileName := fSavedFileName;
  // View the file
  // first try to open it using external viewer
  if not StartExternalViewer(FileName) then
    raise Exception.Create(sCantViewDoc);
end;

procedure TReportBaseDlg.Display;
  {Displays required report in viewer frame}
var
  Reporter: IVerInfoReporter3;  // object that creates report
  Stm: IStream;                 // stream that report is written to
  Content: TStrings;            // content of report frame
  View: TViewerBase;            // report veiwer frame
begin
  // Get reference to view that stores/displays report & reference to content
  View := Self.GetView;
  Content := View.Content;
  // Clear the display in the frame
  Content.BeginUpdate;
  try
    Content.Clear;
    // Display report
    if Assigned(fVerInfo) then
    begin
      // We have some version info: report on it
      // create stream that updates content string list
      Stm := TStringListIStream.Create(Content, TEncoding.Unicode, True);
      // create reporter object of required kind and write report
      if Failed(fLoader.CreateFunc(GetCLSID, Reporter)) then
        raise Exception.Create(sCantCreateReporter);
      Reporter.ReportToStream(fVerInfo, Stm, fHeading);
    end;
  finally
    Content.EndUpdate;
  end;
end;

procedure TReportBaseDlg.FormCreate(Sender: TObject);
  {Create owned objects when form is created}
begin
  inherited;
  // Create object to manage any required temporary files
  fTempFiles := TTempFiles.Create;
  // Create object that loads the reporter DLL
  fLoader := TReporterLoader.Create;
end;

procedure TReportBaseDlg.FormDestroy(Sender: TObject);
  {Frees owned objects when form destroyed}
begin
  inherited;
  fLoader.Free;     // releases reporter DLL
  fTempFiles.Free;  // deletes any temp files we've created
end;

procedure TReportBaseDlg.FormShow(Sender: TObject);
  {Displays the report when the form is shown}
begin
  inherited;
  Display;
end;

procedure TReportBaseDlg.SetHeading(const Value: string);
  {Write accessor for Heading property: updates display when value changes and
  dialog is visible}
begin
  if fHeading <> Value then
  begin
    fHeading := Value;
    if Visible then
      Display;
  end;
end;

procedure TReportBaseDlg.SetVerInfo(const Value: IVerInfoReader);
  {Write accessor for VerInfo property: updates display when value changes and
  dialog is visible}
begin
  if fVerInfo <> Value then
  begin
    fVerInfo := Value;
    if Visible then
      Display;
  end;
end;

function TReportBaseDlg.ShellExec(const FileName, ParamStr: string): Boolean;
  {Executes the given file with the given parameter string. Returns
  True if the application is started successfully and False if not. If file
  name is not an application Windows executes the file's associated
  application}
begin
  Result := ShellExecute(
    Handle, nil, PChar(FileName), PChar(ParamStr), nil, SW_SHOW
  ) > 32;
end;

end.
