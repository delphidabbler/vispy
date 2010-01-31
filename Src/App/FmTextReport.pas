{
 * FmTextReport.pas
 *
 * Implements a dialog box that displays a plain text report that describes some
 * version information.
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
 * The Original Code is FmTextReport.pas.
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


unit FmTextReport;


interface


uses
  // Delphi
  Forms, Dialogs, StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FrViewerBase, FrMemoViewer, FmReport;


type

  {
  TTextReportDlg:
    Dialog box that displays a plain text report describing some version
    information.

    Inheritance: TTextReportDlg -> TReportBaseDlg -> TGenericViewDlg
      -> TGenericDlg -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  TTextReportDlg = class(TReportBaseDlg)
    frMemoViewer: TMemoViewer;
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
      {Attempts to display the given file in the default text editor and returns
      True on success or False on failure. This method is called by the
      inherited View button click event handler}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  IntfVerInfoReport;


{$R *.dfm}


{ TTextReportDlg }

resourcestring
  // Save dialog filter
  sPlainRepSaveFilter = 'Text files (*.%0:s)|*.%0:s';

function TTextReportDlg.GetCLSID: TGUID;
  {CLSID of the object used to write the report: CLSID is set according to the
  report kind}
begin
  Result := CLSID_VerInfoPlainReporter;
end;

function TTextReportDlg.GetFileDlgFilter: string;
  {Returns filter to be displayed in save file dialog}
begin
  Result := Format(sPlainRepSaveFilter, [GetFileExt]);
end;

function TTextReportDlg.GetFileExt: string;
  {Returns extension of associated file type}
begin
  Result := 'txt';
end;

function TTextReportDlg.GetView: TViewerBase;
  {Returns reference to viewer frame used to display report}
begin
  Result := frMemoViewer;
end;

function TTextReportDlg.StartExternalViewer(
  const FileName: string): Boolean;
  {Attempts to display the given file in the default text editor and returns
  True on success or False on failure. This method is called by the inherited
  View button click event handler}
begin
  Result := ShellExec(FileName, '');
end;

end.
