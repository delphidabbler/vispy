{ ##
  @FILE                     FileVer.dpr
  @COMMENTS                 Main project file
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @AUTHOR                   Peter D Johnson, LLANARTH, Ceredigion, Wales, UK.
  @EMAIL                    delphidabbler@yahoo.co.uk
  @COPYRIGHT                © Peter D Johnson, 1998-2007.
  @WEBSITE                  http://www.delphidabbler.com/
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 25/04/1998
      @COMMENTS             Original version
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 07/07/1998
      @COMMENTS             + Totally re-written to accomodate new units added
                              to project
                            + Re-named main unit
    )
    @REVISION(
      @VERSION              3.0
      @DATE                 29/11/1999
      @COMMENTS             Re-written to remove abandoned units.
    )
    @REVISION(
      @VERSION              4.0
      @DATE                 30/03/2002
      @COMMENTS             Modified for new and renamed units
                            + Added UVerUtils, USettings and UPJSoftNet units.
                            + Renamed Main_f.pas to FmMain.pas
    )
    @REVISION(
      @VERSION              5.0
      @DATE                 03/08/2002
      @COMMENTS             + Added new units: FmCtxMenu.pas, UCtxMenuMgr.pas,
                              UDLLLoader.pas, UPJSoftNet.pas, UStartup.pas,
                              UVerInfoStream.pas, UVersionInfo.pas,
                              UVIBinary.pas.
                            + Added include statement for new version
                              information resource (version information no
                              longer added automatically by compiler).
                            + Added code to detect if program is to run or is to
                              terminate in favour of another instance of the
                              program. The program halts without creating a main
                              window if it is not to run.
    )
    @REVISION(
      @VERSION              6.0
      @DATE                 24/02/2003
      @COMMENTS             + Added new units: UFileReaderLoader, UDisplayFmt,
                              IntfVerInfoReader, UReporterLoader,
                              IntfVerInfoReport, UStringListStream, FmReport,
                              IntfFileVerCM, URegistry.
                            + Removed units: UVersionInfo, UVerInfoStream,
                              UVIBinary, UPJSoftNet.
                            + Moved UDLLLoader and UVerUtils to shared units
                              folder.
    )
    @REVISION(
      @VERSION              7.0
      @DATE                 20/10/2004
      @COMMENTS             + Added new units: CmpHotButton, CmpTextBox, FmBase,
                              FmBaseTabbedDlg, FmDisplayOpts, FmErrorReport,
                              FmExplExtAdd, FmFixedSourceReport, FmGenericDlg,
                              FmGenericOKDlg, FmGenericViewDlg, FmHelpAware,
                              FmHTMLReport, FmRegExtQuery, FmSourceReport,
                              FmTextReport, FrHTMLViewer, FrMemoViewer,
                              FrViewerBase, UCBDisplayMgr, UDictionaries,
                              UDisplayMgrs, UExtensions, UGlobals,
                              ULVDisplayMgr, UPopupWindow.
                            + Renamed FmCtxMenu as FmExplExt and
                              IntfFileVerCM as IntfFileVerShellExt.
                            + Removed Application.HelpFile and Application.Title
                              settings (now set in main form).
    )
    @REVISION(
      @VERSION              7.1
      @DATE                 07/03/2005
      @COMMENTS             Added new unit: IntfUIHandlers.
    )
    @REVISION(
      @VERSION              7.2
      @DATE                 21/08/2007
      @COMMENTS             + Fixed corrupt form entries for FmHTMLReport and
                              FmFixedSourceReport.
                            + Changed paths to some interfaces. Interfaces are
                              no longer in Intf folder but in Exports sub folder
                              of relevant DLL source code.
                            + Deleted reference to FileVer.res and replaced with
                              inclusion of Images.res that now contains the
                              program's MAINICON.
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
 * The Original Code is FileVer.dpr.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1998-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
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
  IntfVerInfoReport in '..\Reporter\Exports\IntfVerInfoReport.pas';

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
