{
 * FmXMLReport.pas
 *
 * Implements a dialog box that displays a XML format report that describes
 * some version information.
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
 * The Original Code is FmXMLReport.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit FmXMLReport;


interface


uses
  // Delphi
  Forms, Dialogs, StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FrViewerBase, FrMemoViewer, FmReport;


type

  {
  TXMLReportDlg:
    Dialog box that displays a XML format report that describes some version
    information.
  }
  TXMLReportDlg = class(TReportBaseDlg)
    frXMLViewer: TMemoViewer;
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
      {Attempts to display the given file in Notepad and returns True on success
      or False on failure. This method is called by the inherited View button
      click event handler}
  end;


implementation


uses
  // Delphi
  ShellAPI,
  // Project
  IntfVerInfoReport;

{$R *.dfm}


resourcestring
  // Save dialog filter
  sXMLRepSaveFilter = 'XML files (*.%0:s)|*.%0:s';

{ TXMLReportDlg }

function TXMLReportDlg.GetCLSID: TGUID;
  {CLSID of the object used to write the report: CLSID is set according to the
  report kind}
begin
  Result := CLSID_VerInfoXMLReporter;
end;

function TXMLReportDlg.GetFileDlgFilter: string;
  {Returns filter to be displayed in save file dialog}
begin
  Result := Format(sXMLRepSaveFilter, [GetFileExt]);
end;

function TXMLReportDlg.GetFileExt: string;
  {Returns extension of associated file type}
begin
  Result := 'xml';
end;

function TXMLReportDlg.GetView: TViewerBase;
  {Returns reference to viewer frame used to display report}
begin
  Result := frXMLViewer;
end;

function TXMLReportDlg.StartExternalViewer(
  const FileName: string): Boolean;
  {Attempts to display the given file in Notepad and returns True on success or
  False on failure. This method is called by the inherited View button click
  event handler}
begin
  Result := ShellAPI.ShellExecute(
    Self.Handle,
    'open',
    'notepad.exe',
    PChar(FileName),
    nil,
    SW_SHOW
  ) > 32;
end;

end.
