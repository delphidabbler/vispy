{ ##
  @FILE                     FmHTMLReport.pas
  @COMMENTS                 Implements a dialog box that displays a HTML format
                            report that describes some version information.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 20/10/2004
      @COMMENTS             Original version
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 07/03/2005
      @COMMENTS             Added lowered outer bevel to panel that hosts web
                            browser since browser no longer displays a border.
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
 * The Original Code is FmHTMLReport.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2005 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit FmHTMLReport;


interface


uses
  // Delphi
  Forms, Dialogs, StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FrHTMLViewer, FrViewerBase, FmReport;


type

  {
  THTMLReportDlg:
    Dialog box that displays a HTML format report that describes some version
    information.

    Inheritance: THTMLReportDlg -> TReportBaseDlg -> TGenericViewDlg
      -> TGenericDlg -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  THTMLReportDlg = class(TReportBaseDlg)
    frWebViewer: THTMLViewer;
    procedure FormCreate(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
  private
    procedure ClickHandler(Sender: TObject; const URL: string;
      var Cancel: Boolean);
      {Handle web browser frame click event handler: checks for special res://
      URL that links to a help keyword and passes this on to help system,
      preventing browser from trying to navigate to link. Other URLs are ignored
      and web browser navigates to them}
  protected
    function GetView: TViewerBase; override;
      {Returns reference to viewer frame used to display report}
    function GetCLSID: TGUID; override;
      {CLSID of the object used to write the report: CLSID is set according to
      the report kind}
    function GetFileDlgFilter: string; override;
      {Returns filter to be displayed in save file dialog}
    function GetFileExt: string; override;
      {Returns extension of associated file type}
    function StartExternalViewer(const FileName: string): Boolean; override;
      {Attempts to displays the given file in Internet Explorer and returns True
      on success or False on failure. The HTML reports displayed in this dialog
      use some IE specific proptocols, therefore IE is used to display the file
      even if it is not the default browser. This method is called by the
      inherited View button click event handler}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  IntfVerInfoReport, UGlobals, URegistry;

{$R *.dfm}


resourcestring
  // Save dialog captions and filters
  sHTMLRepSaveFilter = 'HTML files (*.%0:s)|*.%0:s';
  // Error message
  sNoIE = 'Can''t find Internet Explorer.';


{ Helper function }

function PathToIE: string;
  {Returns the path to Internet Explorer}
begin
  Result := URegistry.AppPath(UGlobals.cIEExe)
end;


{ THTMLReportDlg }

procedure THTMLReportDlg.btnViewClick(Sender: TObject);
  {Overridden View button click hander: reports that IE can't be found if the
  inherited code can't start the browser}
begin
  try
    inherited;
  except
    raise Exception.Create(sNoIE);
  end;
end;

procedure THTMLReportDlg.ClickHandler(Sender: TObject; const URL: string;
  var Cancel: Boolean);
  {Handle web browser frame click event handler: checks for special res:// URL
  that links to a help keyword and passes this on to help system, preventing
  browser from trying to navigate to link. Other URLs are ignored and web
  browser navigates to them}
const
  cResProtocol = 'res://';  // resource protocol
  cHelpSuffix = '_hlp';     // resource name suffix indicates help keyword
var
  Keyword: string;          // help keyword
  HelpSuffixStart: Integer; // start of item indicating help suffix
  PKeyword: PChar;          // points to start of help keyword in url
begin
  // help file protocol is of form
  //   res://<report DLL name>/<res_name>/ where <resname> ends in _hlp
  HelpSuffixStart := AnsiPos(cHelpSuffix, URL);
  if (AnsiPos(cResProtocol, URL) > 0) and (HelpSuffixStart > 0) then
  begin
    // We have res:// URL that contains a help keyword: extract keyword
    // record URL and delete _hlp suffix and any trailing '/'
    Keyword := URL;
    Delete(Keyword, HelpSuffixStart, MaxInt);
    // keyword starts after last '/' in remaining string
    PKeyword := AnsiStrRScan(PChar(Keyword), '/');
    if Assigned(PKeyword) then
    begin
      Inc(PKeyword);
      // we can now record keyword and display help if keyword is not ''
      Keyword := PKeyword;
      if Keyword <> '' then
        DisplayHelp(Keyword);
      // Cancel navigation: don't display this URL in browser
      Cancel := True;
    end;
  end;
end;

procedure THTMLReportDlg.FormCreate(Sender: TObject);
  {Assigns handler to web browser frame's OnClickLink event}
begin
  inherited;
  frWebViewer.OnClickLink := ClickHandler;
  btnView.Enabled := PathToIE <> '';
end;

function THTMLReportDlg.GetCLSID: TGUID;
  {CLSID of the object used to write the report: CLSID is set according to the
  report kind}
begin
  Result := CLSID_VerInfoHTMLReporter;
end;

function THTMLReportDlg.GetFileDlgFilter: string;
  {Returns filter to be displayed in save file dialog}
begin
  Result := Format(sHTMLRepSaveFilter, [GetFileExt]);
end;

function THTMLReportDlg.GetFileExt: string;
  {Returns extension of associated file type}
begin
  Result := 'html';
end;

function THTMLReportDlg.GetView: TViewerBase;
  {Returns reference to viewer frame used to display report}
begin
  Result := frWebViewer;
end;

function THTMLReportDlg.StartExternalViewer(const FileName: string): Boolean;
  {Attempts to displays the given file in Internet Explorer and returns True on
  success or False on failure. The HTML reports displayed in this dialog use
  some IE specific proptocols, therefore IE is used to display the file even if
  it is not the default browser. This method is called by the inherited View
  button click event handler}
var
  IEPath: string; // path to Internet Explorer
begin
  // Assume we can't find IE
  Result := False;
  // Get IE Path
  IEPath := PathToIE;
  if IEPath <> '' then
    // Execute IE to display required file
    Result := ShellExec(IEPath, FileName);
end;

end.
