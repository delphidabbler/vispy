{
 * FileVer.dpr
 *
 * Main project file for FileVer.exe application.
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
 * The Original Code is FileVer.dpr.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1998-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


program FileVer;


uses
  Forms,
  CmpHotButton in 'CmpHotButton.pas',
  CmpTextBox in 'CmpTextBox.pas',
  FmBase in 'FmBase.pas' {BaseForm},
  FmBaseTabbedDlg in 'FmBaseTabbedDlg.pas' {BaseTabbedDlg},
  FmDisplayOpts in 'FmDisplayOpts.pas' {DisplayOptsDlg},
  FmErrorReport in 'FmErrorReport.pas' {ErrorReportDlg},
  FmExplExt in 'FmExplExt.pas' {ExplExtDlg},
  FmExplExtAdd in 'FmExplExtAdd.pas' {ExplExtAddDlg},
  FmFixedSourceReport in 'FmFixedSourceReport.pas' {FixedSourceReportDlg},
  FmGenericDlg in 'FmGenericDlg.pas' {GenericDlg},
  FmGenericOKDlg in 'FmGenericOKDlg.pas' {GenericOKDlg},
  FmGenericViewDlg in 'FmGenericViewDlg.pas' {GenericViewDlg},
  FmHelpAware in 'FmHelpAware.pas' {HelpAwareForm},
  FmHTMLReport in 'FmHTMLReport.pas' {HTMLReportDlg},
  FmMain in 'FmMain.pas' {MainForm},
  FmRegExtQuery in 'FmRegExtQuery.pas' {RegExtQueryDlg},
  FmReport in 'FmReport.pas' {ReportBaseDlg},
  FmSourceReport in 'FmSourceReport.pas' {SourceReportDlg},
  FmTextReport in 'FmTextReport.pas' {TextReportDlg},
  FrHTMLViewer in 'FrHTMLViewer.pas' {HTMLViewer: TFrame},
  FrMemoViewer in 'FrMemoViewer.pas' {MemoViewer: TFrame},
  FrViewerBase in 'FrViewerBase.pas' {ViewerBase: TFrame},
  UCBDisplayMgr in 'UCBDisplayMgr.pas',
  UDictionaries in 'UDictionaries.pas',
  UDisplayMgrs in 'UDisplayMgrs.pas',
  UExtensions in 'UExtensions.pas',
  ULVDisplayMgr in 'ULVDisplayMgr.pas',
  UPopupWindow in 'UPopupWindow.pas',
  USettings in 'USettings.pas',
  UStringListStream in 'UStringListStream.pas',
  UStartup in 'UStartup.pas',
  UTempFiles in 'UTempFiles.pas',
  UDisplayFmt in '..\Shared\UDisplayFmt.pas',
  UDLLLoader in '..\Shared\UDLLLoader.pas',
  UFileReaderLoader in '..\Shared\UFileReaderLoader.pas',
  UGlobals in '..\Shared\UGlobals.pas',
  URegistry in '..\Shared\URegistry.pas',
  UReporterLoader in '..\Shared\UReporterLoader.pas',
  UVerUtils in '..\Shared\UVerUtils.pas',
  IntfFileVerShellExt in '..\CtxMenu\Exports\IntfFileVerShellExt.pas',
  IntfUIHandlers in 'IntfUIHandlers.pas',
  IntfVerInfoReader in '..\Reader\Exports\IntfVerInfoReader.pas',
  IntfVerInfoReport in '..\Reporter\Exports\IntfVerInfoReport.pas',
  FmXMLReport in 'FmXMLReport.pas' {XMLReportDlg};

{$Resource Images.res}    // contains program's icon
{$Resource VFileVer.res}  // version information


function CanStart: Boolean;
  {Checks if application can start.
    @return True if application can startup or False if it should be terminated
      immediately.
  }
begin
  // Use TStartup object to determine if app can start
  with TStartup.Create do
    try
      Result := CanExecuteAPP;
    finally
      Free;
    end;
end;


begin
  if CanStart then
  begin
    // App can start: do it
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  end;
end.
