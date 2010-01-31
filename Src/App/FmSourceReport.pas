{
 * FmSourceReport.pas
 *
 * Implements a dialog box that displays the decompiled source code of the
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
 * The Original Code is FmSourceReport.pas.
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


unit FmSourceReport;


interface


uses
  // Delphi
  Dialogs, StdCtrls, Forms, Controls, ExtCtrls, Classes,
  // Project
  FmTextReport, FrMemoViewer, FrViewerBase;


type

  {
  TSourceReportDlg:
    Dialog box that displays the decompiled source code of the version
    information.

    Inheritance: TSourceReportDlg -> TTextReportDlg -> TReportBaseDlg
      -> TGenericViewDlg -> TGenericDlg -> THelpAwareForm -> TBaseForm
      -> [TForm]
  }
  TSourceReportDlg = class(TTextReportDlg)
  protected
    function GetCLSID: TGUID; override;
      {CLSID of the object used to write the report: CLSID is set according to
      the report kind}
    function GetFileDlgFilter: string; override;
      {Returns filter to be displayed in save file dialog}
    function GetFileExt: string; override;
      {Returns extension of associated file type}
    function StartExternalViewer(const FileName: string): Boolean; override;
      {Attempts to displays the given file in Notepad and returns True on
      success or False on failure. This method is called by the inherited View
      button click event handler}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  IntfVerInfoReport, UGlobals;

{$R *.dfm}


{ TSourceReportDlg }

resourcestring
  // Save dialog filter
  sRCRepSaveFilter = 'Resource source files (*.%0:s)|*.%0:s';

function TSourceReportDlg.GetCLSID: TGUID;
  {CLSID of the object used to write the report: CLSID is set according to the
  report kind}
begin
  Result := CLSID_VerInfoRCReporter;
end;

function TSourceReportDlg.GetFileDlgFilter: string;
  {Returns filter to be displayed in save file dialog}
begin
  Result := Format(sRCRepSaveFilter, [GetFileExt]);
end;

function TSourceReportDlg.GetFileExt: string;
  {Returns extension of associated file type}
begin
  Result := 'rc';
end;

function TSourceReportDlg.StartExternalViewer(
  const FileName: string): Boolean;
  {Attempts to displays the given file in Notepad and returns True on success or
  False on failure. This method is called by the inherited View button click
  event handler}
begin
  Result := ShellExec(UGlobals.cNotepad, FileName);
end;

end.
