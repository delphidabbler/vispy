{ ##
  @FILE                     FmMain.pas
  @COMMENTS                 Defines main program window, user interaction and
                            display of version information.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             Required components:
                            + TPJAboutBox Release 3.2
                            + TPJVersionInfo Release 3.1
                            + Drop file components release 3.2 for
                              TPJFormDropFiles
                            + TPJRegWdwState Release 4.2\
                            + PJMessageDialogs unit v2.0
                            DLLs:
                            + Requires FVFileReader.dll to read the version info
                              from executable files.
                            + FVFileReader.dll itself requires VIBinData.dll.
  @OTHER_NAMES              + Original unit name was Main.pas
                            + Changed to Main_f.pas at v2.0
                            + Changed to FmMain.pas at v4.0
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 25/04/1998
      @COMMENTS             Original version
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 03/05/1998
      @COMMENTS             + Removed Refresh button and re-wrote display
                              refresh code accordingly.
                            + Added file drag-drop ability
                            + Added ability to automatically refresh display
                              when user exits file name edit box or presses
                              enter in it. Display only refreshes if file name
                              has actually changed.
                            + Made pressing escape restore previous file name.
                            + File names now always appear in lower case.
                            + Added comment listing component dependencies.
    )
    @REVISION(
      @VERSION              1.2
      @DATE                 15/05/1998
      @COMMENTS             + Added TPJDropFiles component to access files
                              dragged from File Manager and removed all specific
                              code used to allow file drag and drop.
                            + Removed system menu from form.
    )
    @REVISION(
      @VERSION              1.3
      @DATE                 15/05/1998
      @COMMENTS             + Added standard open dialogue box to use as browse
                              dialogue along with a browse button and supporting
                              code to use the dialogue.
                            + Rearranged form so that file name edit box /
                              browse button are at top and About and Exit
                              buttons are in a new panel at the bottom.
                            + Also added some rulings using bevels.
                            + Modified tab order accordingly.
                            + Prevented program from beeping when user presses
                              enter after entering a file name in edit box.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 07/07/1998
      @COMMENTS             + Renamed from main.pas.
                            + Uses new code based on spy template altered to add
                              required functionality and to remove unwanted
                              features.
                            + This code implements main user interface. Reads
                              version information using logic from v1.
    )
    @REVISION(
      @VERSION              2.1
      @DATE                 27/08/1998
      @COMMENTS             Updated DropFiles event handler to activate this
                            program's window after files had been dropped.
    )
    @REVISION(
      @VERSION              3.0
      @DATE                 29/11/1999
      @COMMENTS             + Entirely reworked code to support new interface -
                              all program's functionality is now in this unit
                              (other units have been dropped).
                            + Made use of TPJRegWdwState component to remember
                              window's position and size between executions
                              instead of using custom code in a separate unit.
    )
    @REVISION(
      @VERSION              4.0
      @DATE                 30/03/2002
      @COMMENTS             + Complete rewrite to support version information
                              resources that contain one or more translations.
                            + Implemented another new user interface.
                            + More informative descriptions of fixed file
                              information flags and codes now provided.
                            + Provided menu in addition to toolbar.
                            + Added user customisation of whether toolbar is
                              displayed and how some fixed file information is
                              displayed.
                            + Made Help | Contents menu option display contents
                              dialog rather than contents topic.
    )
    @REVISION(
      @VERSION              5.0
      @DATE                 04/08/2002
      @COMMENTS             + Now uses version information access code from an
                              external DLL rather than the TPJVersionInfo
                              component. This code can display version info from
                              files that are not internally consistant. The DLL
                              is loaded dynamically and the application is
                              terminated gracefully if the DLL is not present.
                            + Where there is an internal integrity problem
                              within version information this is now flagged by
                              displayed affected translations in red.
                            + Improved error handling when accessing the PJSoft
                              website via PJSoftNet.dll.
                            + Reworked display methods to use new version info
                              object.
                            + All version information string information is now
                              displayed rather just the predefined strings. The
                              string information can now be sorted on the string
                              name.
                            + Added display of Creation date in fixed file
                              information and provided option to the fixed file
                              info structure information.
                            + Moved File | Preferences sub menu to its own
                              Options menu.
                            + Added ability to configure the new context menu
                              handler.
                            + Added ability to open file from command line.
                            + Added ability to optionally run only one instance
                              of application when called from context menu
                              handler.
                            + Gave main form window class a unique name for
                              search purposes.
                            + Added custom exception dialog box.
    )
    @REVISION(
      @VERSION              6.0
      @DATE                 24/02/2003
      @COMMENTS             + Changed to use object in FVFileReader.dll to read
                              data - we no longer use UVersionInfo unit (which
                              has been removed). Display methods for again
                              revised to work with new DLL.
                            + Now access delphiDabbler website rather than
                              PJSoft website. Method of accessing changed to use
                              the DDNet COM server.
                            + Version number and date formatting routines moved
                              to UDisplayFmt unit.
                            + Changed to use constants instead of enumerations
                              for variable ver info status codes.
                            + Upgraded PJDropFiles component to release 3 and
                              removed exception handling from its drop files
                              event handler now that component handles its
                              exceptions properly.
                            + Added .res files to file open dialog box.
                            + Added new method to align dialogs over form.
                            + Added facility to display reports about the
                              currently loaded file's version information - new
                              "Report" main menu item and choice between a
                              description of version info and source code.
                            + File name is no longer displayed in title bar if
                              file could not be loaded.
                            + Added ability to automatically register the
                              context menu handler for the types of files
                              successfully opened by the program.
    )
    @REVISION(
      @VERSION              6.1
      @DATE                 31/05/2003
      @COMMENTS             Changed display of translations to:
                            + Display any error for selected translation above
                              combo box (rather than after translation in combo
                              box).
                            + Display number of translations and index of
                              selected translation.
    )
    @REVISION(
      @VERSION              6.2
      @DATE                 14/08/2003
      @COMMENTS             + Placed assertion in DisplayStringInfo method to
                              check there a some string tables to display.
                            + Added test to cmbTrans change event handler to
                              check if there are any translations and to execute
                              different code (to clear string table and reset
                              translation count and error messages) if so.
                            + Deleted call to DisplayStringInfo method from
                              Display method - this code is now executed from
                              cmbTransChange method that is triggered from
                              DisplayTransInfo method.
    )
    @REVISION(
      @VERSION              7.0
      @DATE                 05/06/2004
      @COMMENTS             Major update: many aspects of form and its code
                            changed:
                            + The form now inherits from THelpAwareForm to
                              provide help support.
                            + User interface reworked to support Windows XP
                              themes.
                            + Toolbar buttons changed, glyphs updated and panel
                              based toolbar replaced by toolbar control.
                            + Added glyphs to main menu items where relevant.
                            + Removed custom draw and event management code for
                              controls that display version information. Manager
                              objects are now used to provide and extend this
                              functionality.
                            + Replaced all menu event handlers with TAction
                              objects stored in action list. Some standard
                              actions utilised.
                            + DelphiDabbler website is now accessed directly
                              rather than via a COM server object.
                            + Added access to new Display Options dialog and
                              removed menu items previously used to configure
                              options that are now dealt with by the dialog.
                            + Modifed to use new report dialog class heirachies
                              rather than single report dialog class. Also added
                              access to new "corrected source code" report and
                              changed some report headings.
                            + Added custom button that is displayed when there
                              are inconsistent translations. The button triggers
                              and action that displays an explanation of the
                              problem.
                            + Moved remaining string literals to resource
                              strings.
                            + Deleted code to align dialog boxes: they now align
                              themselves.
                            + Window class name now provided by overriding the
                              WindowClassName method inherited from TBaseForm,
                              instead of overriding CreateParams method.
                            + Refactored various methods.
                            + Now gets registry key for window information from
                              registry.
                            + Now set up Application's Title and HelpFile
                              in form creation rather than in project file.
    )
    @REVISION(
      @VERSION              7.1
      @DATE                 28/08/2007
      @COMMENTS             Fixed bug where form caption was being incorrectly
                            set on startup. Now displays application name.
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
 * The Original Code is FmMain.pas
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


unit FmMain;


interface


uses
  // Delphi
  SysUtils, Windows, Messages, ActnList, StdActns, Classes, ImgList, Controls,
  Menus, StdCtrls, ComCtrls, ExtCtrls, ToolWin, XPMan,
  // DelphiDabbler library
  PJAbout, PJDropFiles, PJVersionInfo, PJWdwState, PJMessageDialog,
  // Project
  CmpHotButton, FmHelpAware, FmReport,
  IntfVerInfoReader, UFileReaderLoader, ULVDisplayMgr, UCBDisplayMgr;


type

  {
  TMainForm:
    Application's main form class: handles main user interface code and
    initialisation and finalisation.

    Inheritance: TMainForm -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  TMainForm = class(THelpAwareForm)
    bvlSpacer1: TBevel;
    bvlSpacer2: TBevel;
    dlgAbout: TPJAboutBoxDlg;
    fdfFileCatcher: TPJFormDropFiles;
    miAbout: TMenuItem;
    miDelphiDabblerWeb: TMenuItem;
    miExplorerExt: TMenuItem;
    miFile: TMenuItem;
    miFileSpacer: TMenuItem;
    miHelp: TMenuItem;
    miHelpContents: TMenuItem;
    miHelpSpacer: TMenuItem;
    miOpen: TMenuItem;
    miOptions: TMenuItem;
    miOptionsSpacer: TMenuItem;
    miReport: TMenuItem;
    miReportSource: TMenuItem;
    miSortStringInfo: TMenuItem;
    miToolbar: TMenuItem;
    mnuMain: TMainMenu;
    mnuStr: TPopupMenu;
    regWdwState: TPJRegWdwState;
    viAbout: TPJVersionInfo;
    miReportHTML: TMenuItem;
    ilMain: TImageList;
    pnlFixed: TPanel;
    gpFixed: TGroupBox;
    lvFixed: TListView;
    pnlVar: TPanel;
    gpVar: TGroupBox;
    lblTrans: TLabel;
    lblStr: TLabel;
    lblErrors: TLabel;
    cmbTrans: TComboBox;
    lvStr: TListView;
    tbarMain: TToolBar;
    tbOpen: TToolButton;
    tbSpacer1: TToolButton;
    tbHelpContents: TToolButton;
    tbAbout: TToolButton;
    alMain: TActionList;
    actOpen: TFileOpen;
    actExit: TFileExit;
    actReportText: TAction;
    actReportHTML: TAction;
    actReportSource: TAction;
    actToolbar: TAction;
    actExplorerExt: TAction;
    actHelpContents: THelpContents;
    actDelphiDabblerWeb: TAction;
    actAbout: TAction;
    actSortStringInfo: TAction;
    miExit: TMenuItem;
    actDisplayOpts: TAction;
    miDisplayOpts: TMenuItem;
    miReportText: TMenuItem;
    actExplainProblem: TAction;
    actReportFixedSource: TAction;
    miReportSourceFixed: TMenuItem;
    RegisterExplorerExtensions1: TMenuItem;
    procedure fdfFileCatcherDropFiles(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvStrColumnClick(Sender: TObject; Column: TListColumn);
    procedure regWdwStateGetRegData(var RootKey: HKEY; var SubKey: String);
    procedure actAboutExecute(Sender: TObject);
    procedure actDelphiDabblerWebExecute(Sender: TObject);
    procedure actExplorerExtExecute(Sender: TObject);
    procedure actOpenAccept(Sender: TObject);
    procedure actReportHTMLExecute(Sender: TObject);
    procedure actReportSourceExecute(Sender: TObject);
    procedure actReportTextExecute(Sender: TObject);
    procedure actSortStringInfoExecute(Sender: TObject);
    procedure actToolbarExecute(Sender: TObject);
    procedure actDisplayOptsExecute(Sender: TObject);
    procedure actExplainProblemExecute(Sender: TObject);
    procedure actReportFixedSourceExecute(Sender: TObject);
  private
    fFixedLVMgr: TLVDisplayMgr;
      {Object that manages display of fixed file info list view}
    fStrLVMgr: TLVDisplayMgr;
      {Object that manages display of string info list view}
    fTransCBMgr: TCBDisplayMgr;
      {Object that manages display of translation combo box}
    fFileLoaded: Boolean;
      {Flag true if a file has been loaded and displayed, false otherwise}
    fMaxTopPnlHeight: Integer;
      {Maximum height of fixed file info panel on display}
    fFirstFFIItemIdx: Integer;
      {Index of first fixed file info item to be displayed: depends on if we
      display structure info}
    fLastFFIItemIdx: Integer;
      {Index of last fixed file info item to be displayed: depends on if we
      display creation date}
    fFileName: string;
      {Name of current file for which version information is being displayed}
    fVIAccessor: IVerInfoFileReader;
      {Object within DLL that provides access to version information in
      executable files}
    fVIExeReaderLoader: TVIFileReaderLoader;
      {Object that loads the DLL that contains the accessor object used to gain
      access to version information}
    fShellExtSvrRegistered: Boolean;
      {Flag indicating whether shell extension COM server is registered}
    procedure ApplyDisplaySettings;
      {Updates display according to persistent settings}
    procedure ShowReport(const DlgClass: TReportDlgClass;
      const Heading: string);
      {Display a report of the current version information using the given
      heading. The report is displayed in a format that depends on the given
      dialog box type}
    procedure ProcessFile(const FileName: string);
      {Display any version information in the given file}
    function CheckShellExtServer: Boolean;
      {Returns true if shell extension COM server is registered and false if
      not}
    procedure CheckExtension(const FileName: string);
      {Ensures that the given extension is recorded by shell extenstion handler
      and, optionally registers the extension with a handler. Should only be
      called with the name of a file of a type known to be able to have version
      information extracted}
    procedure ArrangeControls;
      {Arranges controls in main window}
    procedure UpdateTransErrorCtrls;
      {Updates colour, position and visibility of translation error controls}
    procedure SetupFixedLV;
      {Sets up fixed file info list view control with required number of lines}
    procedure Display;
      {Display version info for current file: only call when there's something
      to display}
    procedure DisplayFFI;
      {Display fixed file info}
    procedure DisplayFFIItem(const Index: Integer; const FFI: TVSFixedFileInfo);
      {Display the fixed file item per with the given index from the given fixed
      file info structure}
    procedure DisplayTransInfo;
      {Display translation information: stores language and char set info in
      combo box and selects first item if present}
    procedure DisplayStringInfo(const HandlerIdx: Integer);
      {Display standard string information relating to translation with given
      index in variable info object}
    procedure DisplayClear;
      {Clears the display when there is no version information to display}
    procedure UpdateReportActions;
      {Enables/disables report actions according to if there is anything to
      report}
    procedure UpdateCaption;
      {Updates caption to display program title and any current file name}
    procedure TransChange(Sender: TObject);
      {Handles change of translation notified by the translation combo box
      manager object}
    procedure ExceptionHandler(Sender: TObject; E: Exception);
      {Handler for all un trapped application exceptions: display exception
      messages in error dialog box}
    procedure ErrorMsg(const AMsg: string; const ATitle: string = '');
      {Displays an error message dialog box aligned to active form. If a title
      is specified it is used, otherwise a default title is used}
  protected
    function WindowClassName: string; override;
      {Returns name of form's window class: this name used to recognise existing
      instances of this program at startup}
    procedure WMCopyData(var Msg: TMessage); message WM_COPYDATA;
      {WM_COPYDATA message handler: checks if message has been sent from another
      instance of this application and, if so, processes the data passed in the
      message: opens any file whose name was passed in message's data}
  public
    hbExplain: THotButton;
      {Custom control: button that leads to explanation of errors in translation
      tables: appears only when their are errors}
  end;


var
  MainForm: TMainForm;


implementation


uses
  // Delphi
  Math, Graphics, ComObj, ShellAPI, Forms, Dialogs,
  // Project
  IntfFileVerShellExt,
  FmHTMLReport, FmTextReport, FmSourceReport,
  FmFixedSourceReport, FmErrorReport, FmExplExt, FmDisplayOpts, FmRegExtQuery,
  UGlobals, URegistry, USettings, UStartup, UVerUtils, UDisplayFmt;


{$R *.DFM}


resourcestring
  // Messages for dialogs
  sFatalErr           = 'Version Information Spy must close down because of '
                          + 'the following fatal error:'#13#13'%s'#13#13
                          + 'Please re-install the program.';
  sRegExtQuery        = 'Version Information Spy''s Explorer shell extension '
                          + 'is not registered for files with  extension %s.'
                          + #13#10#13#10'Do you wish to register it now?';
  sBadWebsite         = 'Can''t access "%s"';
  sCantRecordExt      = 'Can''t record extension %s';
  sCantRegisterExt    = 'Can''t register %s';
  sCantLoadShellEx    = 'Can''t find of load shell extension DLL %s';
  sCantFindShellExFn  = 'Can''t find required exported function in %s';
  sCantCheckShellEx   = 'Can''t find out if Shell Extension COM server is '
                          + 'registered';

  // Dialog box titles
  sFatalErrDlgTitle   = '%s: Fatal Error!';
  // Text displayed in version info display
  sNA                 = 'N/a';
  sNoStringInfo       = '(No string info)';
  sNoTransInfo        = '(No translation info)';
  sNoTranslationLbl   = 'Translations:';
  sTranslationLbl     = 'Translation %0:d of %1:d:';
  sZeroTranslationLbl = 'No translations in file';
  // Fixed file info labels
  sSignature          = 'Signature';
  sStructVer          = 'Structure Version';
  sFileVersion        = 'File Version';
  sProductVersion     = 'Product Version';
  sFileFlagsMask      = 'File Flags Mask';
  sFileFlags          = 'File Flags';
  sFileOS             = 'Operating System';
  sFileType           = 'File Type';
  sFileSubType        = 'File Sub-type';
  sCreateDate         = 'Creation Date';
  // Report headings
  sReportTitle        = 'Version Information for %s';
  sReportCreator      = 'Created by ' + cLongSuiteName + ' from '
                          + cDeveloperAlias;
const

  // Identifiers of fixed file info items in lvFixed
  cIdxSignature       = 0;
  cIdxStructVer       = 1;
  cIdxFileVersion     = 2;
  cIdxProductVersion  = 3;
  cIdxFileFlagsMask   = 4;
  cIdxFileFlags       = 5;
  cIdxFileOS          = 6;
  cIdxFileType        = 7;
  cIdxFileSubType     = 8;
  cIdxCreateDate      = 9;

  // "Cursors" into list of fixed file info items
  cFirstFFIIndex      = cIdxSignature;
  cPostStructFFIIndex = cIdxFileVersion;
  cPreDateFFIIndex    = cIdxFileSubType;
  cLastFFIIndex       = cIdxCreateDate;

  // Fixed file info label array
  cFFILabels: array[cFirstFFIIndex..cLastFFIIndex] of string = (
    sSignature, sStructVer, sFileVersion, sProductVersion, sFileFlagsMask,
    sFileFlags, sFileOS, sFileType, sFileSubType, sCreateDate
  );


{ TMainForm }

procedure TMainForm.actAboutExecute(Sender: TObject);
  {Display about box}
begin
  dlgAbout.DlgLeft := Left + 60;
  dlgAbout.DlgTop := Top + 60;
  dlgAbout.Execute;
end;

procedure TMainForm.actDelphiDabblerWebExecute(Sender: TObject);
  {Go to DelphiDabbler website}
begin
  if ShellExecute(0, nil, cWebAddress, nil, nil, SW_SHOW) <= 32 then
    Self.ErrorMsg(Format(sBadWebsite, [cWebAddress]));
end;

procedure TMainForm.actDisplayOptsExecute(Sender: TObject);
  {Displays display options dialog box}
begin
  // Create instance of dialog box
  with TDisplayOptsDlg.Create(Self) do
    try
      // Display dialog box (dlg box updates display configuration)
      if ShowModal = mrOK then
        // apply changes setting to display
        ApplyDisplaySettings;
    finally
      Free;
    end;
end;

procedure TMainForm.actExplainProblemExecute(Sender: TObject);
  {Displays explanation of a translation error}
begin
  with TErrorReportDlg.Create(Self) do
    try
      // Set up properties
      TransIdx := cmbTrans.ItemIndex;
      VerInfo := fVIAccessor.VerInfo;
      // Display dialog box
      ShowModal;
    finally
      Free
    end;
end;

procedure TMainForm.actExplorerExtExecute(Sender: TObject);
  {Displays explorer extension configuation dialog box}
begin
  // Create instance of dialog box
  with TExplExtDlg.Create(Self) do
    try
      // Display dialog box (dlg box updates explorer extension configuration)
      ShowModal;
    finally
      Free;
    end;
end;

procedure TMainForm.actOpenAccept(Sender: TObject);
  {Opens file selected in file open dialog box}
begin
  ProcessFile(actOpen.Dialog.FileName);
end;

procedure TMainForm.actReportFixedSourceExecute(Sender: TObject);
  {Displays dialog box that contains the source code for the currently loaded
  version information with all inconsistencies fixed}
begin
  ShowReport(
    TFixedSourceReportDlg,              // dialog box class
    Format(sReportTitle, [fFileName])   // report heading
      + #13#10 + sReportCreator         //   (2 lines)
  );
end;

procedure TMainForm.actReportHTMLExecute(Sender: TObject);
  {Displays dialog box that contains an HTML description of the currently loaded
  version information}
begin
  ShowReport(
    THTMLReportDlg,                     // dialog box class
    Format(sReportTitle, [fFileName])   // heading
  );
end;

procedure TMainForm.actReportSourceExecute(Sender: TObject);
  {Displays dialog box that contains the source code for the currently loaded
  version information}
begin
  ShowReport(
    TSourceReportDlg,                   // dialog box class
    Format(sReportTitle, [fFileName])   // report heading
      + #13#10 + sReportCreator         //   (2 lines)
  );
end;

procedure TMainForm.actReportTextExecute(Sender: TObject);
  {Displays dialog box that contains a description of the currently loaded
  version information}
begin
  ShowReport(
    TTextReportDlg,                     // dialog box class
    Format(sReportTitle, [fFileName])   // report heading
  );
end;

procedure TMainForm.actSortStringInfoExecute(Sender: TObject);
  {Sorts/unsorts string info by name according to checked state}
begin
  // Act only if we have a translation selected => have string info details
  if (cmbTrans.ItemIndex > -1) then
  begin
    // Sort or unsort strings according to state of menu item
    if actSortStringInfo.Checked then
      // Need to sort
      lvStr.AlphaSort
    else
      // Need to unsort
      DisplayStringInfo(cmbTrans.ItemIndex);
  end;
end;

procedure TMainForm.actToolbarExecute(Sender: TObject);
  {Toggles display of toolbar on and off}
begin
  tbarMain.Visible := actToolbar.Checked;
  ArrangeControls;
end;

procedure TMainForm.ApplyDisplaySettings;
  {Updates display according to persistent settings}
begin
  // Set up fixed file info list view with new arrangement (clears display)
  SetupFixedLV;
  // Re-arrange window to account for size of fixed file info list view
  ArrangeControls;
  // Redisplay fixed file info if file loaded
  if fFileLoaded then
    DisplayFFI;
  // Apply any new string highlight
  if Settings.GUIFlags and VIGUI_STR_HIGHLIGHTNONSTD <> 0 then
    fStrLVMgr.SpecialHighlightColour := Settings.StrHighlightColour
  else
    fStrLVMgr.SpecialHighlightColour := clNone;
  // Apply any new translation error colours
  // these colours used in combo box, label indicating error & explain button
  if Settings.GUIFlags and VIGUI_TRANS_HIGHLIGHTERR <> 0 then
  begin
    fTransCBMgr.ErrorTextColour := Settings.TransHighlightColour;
    lblErrors.Font.Color := Settings.TransHighlightColour;
    hbExplain.Font.Color := Settings.TransHighlightColour;
  end
  else
  begin
    fTransCBMgr.ErrorTextColour := clNone;
    lblErrors.ParentFont := True;
    hbExplain.ParentFont := True;
  end;
  hbExplain.HotColor := hbExplain.Font.Color;
  // Apply popup window settings
  fFixedLVMgr.DisplayPopups := Settings.GUIFlags and VIGUI_POPUP_OVERFLOW <> 0;
  fStrLVMgr.DisplayPopups := Settings.GUIFlags and VIGUI_POPUP_OVERFLOW <> 0;
  fTransCBMgr.DisplayPopups := Settings.GUIFlags and VIGUI_POPUP_OVERFLOW <> 0;
end;

procedure TMainForm.ArrangeControls;
  {Arranges controls in main window}
const
  cSpacing = 8;         // spacing between dynamically placed controls
var
  BodyHeight: Integer;  // height of client area below toolbar
begin
  // Find height available for version info
  BodyHeight := ClientHeight;
  if tbarMain.Visible then
    Dec(BodyHeight, tbarMain.Height);
  // Size fixed file info controls
  pnlFixed.Height := Min((BodyHeight - 78) div 2, fMaxTopPnlHeight);
  lvFixed.Width := gpFixed.Width - 2 * cSpacing;
  lvFixed.Height := gpFixed.Height - lvFixed.Top - cSpacing;
  // Size variable file info controls
  cmbTrans.Width := gpVar.Width - 2 * cSpacing;
  lvStr.Width := gpVar.Width - 2 * cSpacing;
  lvStr.Height := gpVar.Height - lvStr.Top - cSpacing;
  // Size the list view coloumns
  fFixedLVMgr.SizeColumns;
  fStrLVMgr.SizeColumns;
  // Update the error labels
  UpdateTransErrorCtrls;
end;

procedure TMainForm.CheckExtension(const FileName: string);
  {Ensures that the given extension is recorded by shell extenstion handler and,
  optionally registers the extension with a handler. Should only be called with
  the name of a file of a type known to be able to have version information
  extracted}
 var
  Recorder: IFileVerExtRecorder;    // to record extensions
  Registrar: IFileVerExtRegistrar;  // to register extensions
  Dlg: TRegExtQueryDlg;             // dialog gets shell exts to register
  RegExts: TRegisteredServers;      // set of registered servers for extension
begin
  // Check that registrar COM object registered: get out if not
  if not fShellExtSvrRegistered then
    Exit;
  // Create recorder / registrar object
  // IFileVerExtRecorder & IFileVerExtRegistrar supported by same COM obj
  Recorder := CreateCOMObject(CLSID_FileVerReg) as IFileVerExtRecorder;
  Registrar := Recorder as IFileVerExtRegistrar;
  // Record file extension: we always do this
  if Failed(Recorder.RecordExt(FileName, False)) then
    raise Exception.CreateFmt(sCantRecordExt, [ExtractFileExt(FileName)]);
  // Decide if to register extension with shell extension. We do this if:
  // (a) user has requested this (Settings.AutoRegExtension is true) ...
  // (b) extension isn't registered with either shell extension and ...
  // (c) user permits this
  if Settings.AutoRegExtension then
  begin
    // We need to check for registration
    RegExts := [];
    if Registrar.IsExtRegistered(FileName, CLSID_FileVerCM) = S_OK then
      Include(RegExts, rsCtxMenu);
    if Registrar.IsExtRegistered(FileName, CLSID_FileVerPS) = S_OK then
      Include(RegExts, rsPropSheet);
    if RegExts = [] then
    begin
      // Neither extension is registered: put up dialog to see what to register
      Dlg := TRegExtQueryDlg.Create(Self);
      try
        Dlg.RegExtensions := RegExts;
        Dlg.Extension := ExtractFileExt(FileName);
        if Dlg.ShowModal = mrOK then
        begin
          RegExts := Dlg.RegExtensions;
          // user has selected: we register selected extensions
          // (no need to un-register since we only get here if nothing was
          // registered)
          if rsCtxMenu in RegExts then
            Registrar.RegisterExt(FileName, CLSID_FileVerCM);
          if rsPropSheet in RegExts then
            Registrar.RegisterExt(FileName, CLSID_FileVerPS);
        end;
      finally
        Dlg.Free;
      end;
    end;
  end;
end;

function TMainForm.CheckShellExtServer: Boolean;
  {Returns true if shell extension COM server is registered and false if not}
var
  DLLFileName: string;          // name of COM server DLL
  DLLHandle: THandle;           // handle to COM server DLL
  IsServerRegistered:
    function: HResult; stdcall; // imported function used to check registration
begin
  Result := False;  // keep compiler happy!
  // DLL is file in same directory as this application
  DLLFileName := ExtractFilePath(GetModuleName(HInstance)) + cVISShellExDll;
  // Try load COM server DLL and get IsServerRegistered function from it
  DLLHandle := LoadLibrary(PChar(DLLFileName));
  if DLLHandle = 0 then
    raise Exception.CreateFmt(sCantLoadShellEx, [cVISShellExDll]);
  try
    IsServerRegistered := GetProcAddress(DLLHandle, 'IsServerRegistered');
    if not Assigned(IsServerRegistered) then
      raise Exception.CreateFmt(sCantFindShellExFn, [cVISShellExDll]);
    // Check if server registered: error if this call fails
    case IsServerRegistered of
      S_OK:     Result := True;
      S_FALSE:  Result := False;
      E_FAIL:   raise Exception.Create(sCantCheckShellEx);
    end;
  finally
    // Unload the DLL
    FreeLibrary(DLLHandle);
  end;
end;

procedure TMainForm.Display;
  {Display version info for current file}
begin
  Assert(Assigned(fVIAccessor.VerInfo));
  // We always start off with string info un-sorted: reset
  actSortStringInfo.Checked := False;
  // Now do the display
  DisplayFFI;
  DisplayTransInfo;
  // NOTE: we don't call DisplayStringInfo here since this is called indirectly
  // by the DisplayTransInfo method.
end;

procedure TMainForm.DisplayClear;
  {Clears the display when there is no version information to display}
var
  Idx: Integer; // loops through all fixed file info items in display
begin
  // Clear all values from fixed file info display
  for Idx := 0 to Pred(lvFixed.Items.Count) do
    if lvFixed.Items[Idx].SubItems.Count > 0 then
      lvFixed.Items[Idx].SubItems[0] := '';
  // Clear combo box that contains translations
  cmbTrans.Clear;
  // Clear string items display
  lvStr.Items.Clear;
  // Clear error messages
  lblErrors.Caption := '';
  hbExplain.Visible := False;
  // Set number of translations to 0
  lblTrans.Caption := sNoTranslationLbl;
end;

procedure TMainForm.DisplayFFI;
  {Display fixed file info}
var
  Idx: Integer;           // scans thru items in list view
  FFI: TVSFixedFileInfo;  // fixed file info record
begin
  // Get the fixed file info
  FFI := fVIAccessor.VerInfo.FixedFileInfo;
  // Display each fixed file item
  for Idx := 0 to Pred(lvFixed.Items.Count) do
    // Display the item
    DisplayFFIItem(Idx, FFI);
end;

procedure TMainForm.DisplayFFIItem(const Index: Integer;
  const FFI: TVSFixedFileInfo);
  {Display the fixed file item per with the given index from the given fixed
  file info structure}

  // ---------------------------------------------------------------------------
  procedure AddItem(const Index: Integer; const Value: string);
    {Set the first sub item of the given list item to the given value}
  begin
    // Ensure there's a sub item in list view for this item
    if lvFixed.Items[Index].SubItems.Count = 0 then
      lvFixed.Items[Index].SubItems.Add('');
    lvFixed.Items[Index].SubItems[0] := Value;
  end;
  // ---------------------------------------------------------------------------

begin
  // Display the required item (related FFI item is stored in list item's data)
  case Integer(lvFixed.Items[Index].Data) of
    cIdxSignature:
      // Structure signature
      AddItem(Index, IntToHex(FFI.dwSignature, 8));
    cIdxStructVer:
      // Structure version
      AddItem(Index, UDisplayFmt.ShortVerFmt(FFI.dwStrucVersion));
    cIdxFileVersion:
      // File version number
      AddItem(Index,
        UDisplayFmt.VerFmt(FFI.dwFileVersionMS, FFI.dwFileVersionLS));
    cIdxProductVersion:
      // Product version number
      AddItem(Index,
        UDisplayFmt.VerFmt(FFI.dwProductVersionMS, FFI.dwProductVersionLS));
    cIdxFileFlagsMask:
      // File flags mask: display as hex number or as description per option
      if Settings.GUIFlags and VIGUI_FFI_DESCFILEFLAGS <> 0 then
        AddItem(Index,
          UVerUtils.FileFlagsDesc(FFI.dwFileFlagsMask, dtDesc))
      else
        AddItem(Index, IntToHex(FFI.dwFileFlagsMask, 8));
    cIdxFileFlags:
      // File flags: display as hex number or as description per option
      if Settings.GUIFlags and VIGUI_FFI_DESCFILEFLAGS <> 0 then
        AddItem(Index, UVerUtils.FileFlagsDesc(FFI.dwFileFlags, dtDesc))
      else
        AddItem(Index, IntToHex(FFI.dwFileFlags, 8));
    cIdxFileOS:
      // FileOS code: display a description
      AddItem(Index, UVerUtils.FileOSDesc(FFI.dwFileOS, dtDesc));
    cIdxFileType:
      // File type: display a description
      AddItem(Index, UVerUtils.FileTypeDesc(FFI.dwFileType, dtDesc));
    cIdxFileSubType:
      // File sub type: display a description
      if UVerUtils.FileTypeHasSubType(FFI.dwFileType) then
        // sub-types are valid for current file type: display desc
        AddItem(Index,
          UVerUtils.FileSubTypeDesc(FFI.dwFileType, FFI.dwFileSubType, dtDesc))
      else
        // sub-types not valid for this file type
        AddItem(Index, sNA);
    cIdxCreateDate:
      // File creation date
      AddItem(Index, UDisplayFmt.DateFmt(FFI.dwFileDateMS, FFI.dwFileDateLS));
  end;
end;

procedure TMainForm.DisplayStringInfo(const HandlerIdx: Integer);
  {Display standard string information relating to translation with given index
  in variable info object}
var
  StrIdx: Integer;          // index of string info item in string table
  Item: TListItem;          // new list view item to for each string
begin
  Assert(fVIAccessor.VerInfo.VarInfoCount > 0);
  lvStr.Items.BeginUpdate;
  try
    // Clear the list view ready for new entries
    lvStr.Items.Clear;
    // Use ver info accessor object to scan thru all strings in table (if any)
    with fVIAccessor.VerInfo.VarInfo(HandlerIdx) do
    begin
      for StrIdx := 0 to Pred(StringCount) do
      begin
        // display name and value in new list item
        Item := lvStr.Items.Add;
        Item.Caption := StringName(StrIdx);
        Item.SubItems.Add(StringValue(StrIdx));
        Item.Data := Pointer(not UVerUtils.IsStdStrFileInfoName(Item.Caption));
      end;
    end;
  finally
    lvStr.Items.EndUpdate;
  end;
end;

procedure TMainForm.DisplayTransInfo;
  {Display translation information: stores language and char set info in combo
  box and selects first item if present}
var
  VarIdx: Integer;            // loops thru all var ver info entries in handler
  DispStr: string;            // string to be displayed in combo box
begin
  // Set up translations in combo box: indexes of items in combo = trans index
  cmbTrans.Clear;
  // Use VerInfo object in accessor to loop thru all translation tables
  with fVIAccessor.VerInfo do
  begin
    for VarIdx := 0 to Pred(VarInfoCount) do
    begin
      // Use variable file info object from accessor to display translation
      with VarInfo(VarIdx) do
      begin
        // Create display string from var info item's language and character set
        DispStr := Format(
          '%s - %s',
          [LanguageDesc(LanguageID), CharSetDesc(CharSet)]
        );
        // Add display string and status of var info item (this affects display)
        cmbTrans.Items.AddObject(DispStr, Pointer(Status));
      end;
    end;
    // Select first item in combo box if there is one
    if VarInfoCount > 0 then
      cmbTrans.ItemIndex := 0
    else
      cmbTrans.ItemIndex := -1;
    // Trigger change event for combo box
    // (updates index, error messages and displays associated string table)
    TransChange(cmbTrans);
  end;
end;

procedure TMainForm.ErrorMsg(const AMsg: string; const ATitle: string = '');
  {Displays an error message dialog box aligned to active form. If a title is
  specified it is used, otherwise a default title is used}
begin
  // Create an error dialog box:
  // we align this to active form since this routine is used by default
  // exception handler that can be called when any dialog box is displayed
  with TPJVCLMsgDlg.Create(Screen.ActiveForm) do
    try
      // Configure dialog box
      Kind := mkError;
      ButtonGroup := bgOK;
      MakeSound := True;
      Align := mdaFormCentre;
      // Set text and title
      Text := AMsg;
      if ATitle <> '' then
        Title := ATitle;
      // Display dialog: result not used
      Execute;
    finally
      Free;
    end;
end;

procedure TMainForm.ExceptionHandler(Sender: TObject; E: Exception);
  {Handler for all un trapped application exceptions: display exception messages
  in error dialog box}
begin
  ErrorMsg(E.Message);
end;

procedure TMainForm.fdfFileCatcherDropFiles(Sender: TObject);
  {File-drop event handler: processes the first file dropped}
begin
  // Attempt to process (load) the file dropped
  ProcessFile(fdfFileCatcher.FileName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
  {Form creation event: initialise window}
begin
  inherited;

  // Create and set up custom hot button to display translation errors
  hbExplain := THotButton.Create(Self);
  hbExplain.Parent := gpVar;              // parented by variable info gp box
  hbExplain.SetBounds(28, 14, 80, 22);    // default size and position
  hbExplain.GlyphText := 'F';             // glyph text is right pointing hand
  hbExplain.HotUnderline := True;         // we underline hot text
  hbExplain.AutoSize := True;             // automatically size button
  hbExplain.Action := actExplainProblem;  // action when explain btn pressed

  // Set Application object
  Application.HelpFile := UGlobals.cAppHelpFile;
  Application.Title := UGlobals.cLongSuiteName;
  Application.OnException := ExceptionHandler;

  // Set form caption
  UpdateCaption;

  // Update toolbar to state stored in registry
  actToolbar.Checked := Settings.ShowToolbar;
  tbarMain.Visible := Settings.ShowToolbar;

  // Set up display managers
  // fixed file info list view manager
  fFixedLVMgr := TLVDisplayMgr.Create(lvFixed);
  // string info list view manager
  fStrLVMgr := TLVDisplayMgr.Create(lvStr);
  // translation combo box manager: set OnChange event
  fTransCBMgr := TCBDisplayMgr.Create(cmbTrans);
  fTransCBMgr.OnChange := TransChange;

  // Set display according to user-configurable settings
  ApplyDisplaySettings;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
  {Form destruction event: destroy owned objects, save required state and close
  help}
begin
  // Free owned objects
  // display managers
  fTransCBMgr.Free;
  fStrLVMgr.Free;
  fFixedLVMgr.Free;
  // sree the VI Accessor object and unload its DLL
  fVIAccessor := nil;       // need to nil this to free it before unloading DLL
  fVIExeReaderLoader.Free;

  // Save preferences in registry
  Settings.ShowToolbar := actToolbar.Checked;

  // Notify Windows Help that we've finished with it
  Application.HelpCommand(HELP_QUIT, 0);

  inherited;
end;

procedure TMainForm.FormResize(Sender: TObject);
  {Handles form resizing: re-arranges components contained on form}
begin
  inherited;
  ArrangeControls;
end;

procedure TMainForm.FormShow(Sender: TObject);
  {Form show event handler: creates object that is used to access version
  information and loads any file passed on command line}
var
  Params: TParams;  // object that parses command line
  OldH: Integer;    // store client height: used in kludge to fix display prob
begin
  inherited;

  // Create version info accessor object.
  try
    // first create object that loads the DLL: raises exception if can't load
    fVIExeReaderLoader := TVIFileReaderLoader.Create;
    // now call create function to create the accessor object
    OleCheck(
      fVIExeReaderLoader.CreateFunc(CLSID_VerInfoFileReader, fVIAccessor)
    );

    // Update report menu options
    UpdateReportActions;

  except
    // Can''t create accessor display message and terminate program.
    on E: Exception do
    begin
      ErrorMsg(
        Format(sFatalErr, [E.Message]),
        Format(sFatalErrDlgTitle, [Application.Title])
      );
      Close;
      Exit;
    end;
  end;

  // Check if shell extension COM server fully registered
  try
    fShellExtSvrRegistered := CheckShellExtServer;
    actExplorerExt.Enabled := fShellExtSvrRegistered;
  except
    // Can't find shell extension DLL: display message and terminate program.
    on E: Exception do
    begin
      ErrorMsg(
        Format(sFatalErr, [E.Message]),
        Format(sFatalErrDlgTitle, [Application.Title])
      );
      Close;
      Exit;
    end;
  end;

  // Check command line for any file to open
  // create params object: this parses command line
  Params := TParams.Create;
  try
    if Params.FileName <> '' then
      // there was a file passed on command line: load it
      ProcessFile(Params.FileName)
    else
      // there was no file on command line: present empty display
      DisplayClear;
  finally
    Params.Free;
  end;

  // KLUDGE: Temporarily change client height to ensure listviews draw correctly
  OldH := ClientHeight;
  ClientHeight := OldH + 2;
  ClientHeight := OldH;
end;

procedure TMainForm.lvStrColumnClick(Sender: TObject; Column: TListColumn);
  {OnColumnClick event handler for string info list view: orders and un-orders
  the string names when the 1st column is clicked}
begin
  if (Column.ID = 0) then
    // 1st column was clicked: change sort by emulating popup menu click
    actSortStringInfo.Execute;
end;

procedure TMainForm.ProcessFile(const FileName: string);
  {Display any version information in the given file}
begin
  // Try to load version information from file
  fFileLoaded := fVIAccessor.LoadFile(PChar(FileName));
  if fFileLoaded then
  begin
    // Version info loaded OK
    // record file name
    fFileName := FileName;
    // display version information
    Display;
    // check file extension to see if needs adding to shell extension handler
    CheckExtension(FileName);
  end
  else
  begin
    // Version info failed to load
    // reset file name
    fFileName := '';
    // clear display
    DisplayClear;
    // display error message returned by version info accessor object
    ErrorMsg(fVIAccessor.LastError);
  end;
  // Update main window caption
  UpdateCaption;
  // Enable/disable reports depending on if version info loaded
  UpdateReportActions;
end;

procedure TMainForm.regWdwStateGetRegData(var RootKey: HKEY;
  var SubKey: string);
  {Set registry keys to be used by window state component}
begin
  SubKey := URegistry.GUIWindowKey(Self.Name);
end;

procedure TMainForm.SetupFixedLV;
  {Sets up fixed file info list view control with required number of lines}
var
  Idx: Integer;   // loops thru fixed file info labels
begin
  // Determine max size of list view and index of first & last item displayed
  // start by assuming no strucure info & no creation date
  fMaxTopPnlHeight := 156;
  fFirstFFIItemIdx := cPostStructFFIIndex;
  fLastFFIItemIdx := cPreDateFFIIndex;
  // increase to accomodate structure info if showing
  if Settings.GUIFlags and VIGUI_FFI_STRUCTINFO <> 0 then
  begin
    Inc(fMaxTopPnlHeight, 28);
    fFirstFFIItemIdx := cFirstFFIIndex;
  end;
  // increase to accomodate creation date if showing
  if Settings.GUIFlags and VIGUI_FFI_CREATEDATE <> 0 then
  begin
    Inc(fMaxTopPnlHeight, 14);
    fLastFFIItemIdx := cLastFFIIndex;
  end;

  // Redisplay list view with required entries
  lvFixed.Items.BeginUpdate;
  try
    lvFixed.Items.Clear;
    for Idx := fFirstFFIItemIdx to fLastFFIItemIdx do
    begin
      with lvFixed.Items.Add do
      begin
        Caption := cFFILabels[Idx];
        Data := Pointer(Idx); // store FFI item index in list item
      end;
    end;
  finally
    lvFixed.Items.EndUpdate;
  end;
end;

procedure TMainForm.ShowReport(const DlgClass: TReportDlgClass;
  const Heading: string);
  {Display a report of the current version information using the given heading.
  The report is displayed in a format that depends on the given dialog box type}
begin
  with DlgClass.Create(Self) do
    try
      // Set up properties
      Heading := Heading;
      VerInfo := fVIAccessor.VerInfo;
      // Display dialog box
      ShowModal;
    finally
      Free
    end;
end;

procedure TMainForm.TransChange(Sender: TObject);
  {Handles change of translation notified by the translation combo box manager
  object}
begin
  // We always start off with string info un-sorted: so reset action
  actSortStringInfo.Checked := False;
  // Now display required messages and string table associated with translation
  if fVIAccessor.VerInfo.VarInfoCount > 0 then
  begin
    // We have translations
    // display the associated string table and ensure columns have correct width
    DisplayStringInfo(cmbTrans.ItemIndex);
    fStrLVMgr.SizeColumns;
    // display any errors for this translation
    // .. record status in combo's tag
    cmbTrans.Tag := fVIAccessor.VerInfo.VarInfo(cmbTrans.ItemIndex).Status;
    // .. update translation caption to show number of translations
    lblTrans.Caption := Format(
      sTranslationLbl + ' ',
      [cmbTrans.ItemIndex + 1, fVIAccessor.VerInfo.VarInfoCount]
    );
    // .. update error controls
    UpdateTransErrorCtrls;
  end
  else
  begin
    // We have no translations
    // clear associated string tables
    lvStr.Items.Clear;
    // clear any error controls
    // .. clear status code in combo's tag
    cmbTrans.Tag := 0;
    // .. update translation caption to note no translations
    lblTrans.Caption := sZeroTranslationLbl;
    // .. update error controls
    UpdateTransErrorCtrls;
  end;
end;

procedure TMainForm.UpdateCaption;
  {Updates caption to display program title and any current file name}
begin
  if fFileLoaded then
    // We have file loaded: display its name with application title
    Caption := Format('%s - %s',
      [Application.Title, ExtractFileName(fFileName)])
  else
    // No file loaded: just display application title
    Caption := Application.Title;
end;

procedure TMainForm.UpdateReportActions;
  {Enables/disables report actions according to if there is anything to report}

  // ---------------------------------------------------------------------------
  function IsTranslationError: Boolean;
    {Return true if there's an error in any of the translations in currently
    loaded version information}
  var
    Idx: Integer; // loops thru all translations
  begin
    Assert(Assigned(fVIAccessor.VerInfo));
    // Scan through each translation check for errors
    Result := False;
    for Idx := 0 to Pred(fVIAccessor.VerInfo.VarInfoCount) do
      if fVIAccessor.VerInfo.VarInfo(Idx).Status <> VARVERINFO_STATUS_OK then
      begin
        Result := True;
        Break;
      end;
  end;
  // ---------------------------------------------------------------------------

begin
  // Reports are disable if no version info loaded
  actReportHTML.Enabled := Assigned(fVIAccessor.VerInfo);
  actReportText.Enabled := Assigned(fVIAccessor.VerInfo);
  actReportSource.Enabled := Assigned(fVIAccessor.VerInfo);
  // ... and fixed source code report only available if we also have some errors
  actReportFixedSource.Enabled := Assigned(fVIAccessor.VerInfo)
    and IsTranslationError;
end;

procedure TMainForm.UpdateTransErrorCtrls;
  {Updates colour, position and visibility of translation error controls}
var
  Status: Integer;    // selected translation status
  GUIFlags: Integer;  // display options that determine visibility of controls
const
  // possible content of error label
  cErrText: array[VARVERINFO_STATUS_OK..VARVERINFO_STATUS_STRTABLEONLY] of
    string = ('', sNoStringInfo, sNoTransInfo);
begin
  // Record translation status and GUI display flags
  Status := cmbTrans.Tag;
  GUIFlags := Settings.GUIFlags;

  // Set error label text and visibility and explain button visibility
  lblErrors.Caption := cErrText[Status];
  lblErrors.Visible := (Status <> VARVERINFO_STATUS_OK)
    and (GUIFlags and VIGUI_TRANS_EXPLAINERRTEXT <> 0);
  hbExplain.Visible := (Status <> VARVERINFO_STATUS_OK)
    and (GUIFlags and VIGUI_TRANS_EXPLAINERRBTN <> 0);

  // Align error label and explain button
  lblErrors.Left := lblTrans.Left + lblTrans.Width;
  hbExplain.Left := cmbTrans.Width + cmbTrans.Left - hbExplain.Width;
end;

function TMainForm.WindowClassName: string;
  {Returns name of form's window class: this name used to recognise existing
  instances of this program at startup}
begin
  Result := UStartup.cWdwClassName;
end;

procedure TMainForm.WMCopyData(var Msg: TMessage);
  {WM_COPYDATA message handler: checks if message has been sent from another
  instance of this application and, if so, processes the data passed in the
  message: opens any file whose name was passed in message's data}
var
  CopyData: PCopyDataStruct;  // points to data structure passed in message
  DataPacket: ^TDataPacket;   // points to our data packet contained in CopyData
begin
  inherited;
  // Get pointer to data structure sent from other app
  CopyData := PCopyDataStruct(Msg.LParam);
  // Check that record is from another instance of our app:
  //   watermark must match and data packet size must agree
  if (CopyData^.dwData = cCopyDataWaterMark)
    and (CopyData^.cbData = SizeOf(TDataPacket)) then
  begin
    // Valid data packet: handle it
    // get reference to data packet
    DataPacket := CopyData^.lpData;
    // we ignore switches bitmask in this version
    // check if there's a file name to open
    if DataPacket^.FileName <> '' then
      ProcessFile(DataPacket^.FileName);
    // set return value to indicate we handled message
    Msg.Result := 1;
  end
  else
    // Copy data structure invalid: return 0 indicating failure to handle
    Msg.Result := 0;
end;

end.
