{ ##
  @FILE                     FmDisplayOpts.pas
  @COMMENTS                 Implements a tabbed dialog box where the program's
                            display options are configured.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 19/10/2004
      @COMMENTS             Original version
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
 * The Original Code is FmDisplayOpts.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit FmDisplayOpts;


interface


uses
  // Delphi
  Classes, Controls, StdCtrls, ExtCtrls, ComCtrls, Graphics,
  // Project
  CmpTextBox, FmBaseTabbedDlg;


type
  {
  TDisplayOptsDlg:
    Multi page dialog box where the program's display options are configured.

    Inheritance: TDisplayOptsDlg -> TBaseTabbedDlg -> TGenericOKDlg
      -> TGenericDlg -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  TDisplayOptsDlg = class(TBaseTabbedDlg)
    lblDesc: TLabel;
    tsPopups: TTabSheet;
    lblPopupOverflow: TLabel;
    chkPopupOverflow: TCheckBox;
    tsFFI: TTabSheet;
    lblFFIStructInfo: TLabel;
    lblFFICreateDate: TLabel;
    lblFFIDescFileFlags: TLabel;
    chkFFIStructInfo: TCheckBox;
    chkFFICreateDate: TCheckBox;
    chkFFIDescFileFlags: TCheckBox;
    tsTrans: TTabSheet;
    lblTransHighlightErr: TLabel;
    lblTransHighlightColour: TLabel;
    lblTransExplainErrText: TLabel;
    lblTransExplainErrBtn: TLabel;
    chkTransHighlightErr: TCheckBox;
    cbTransHighlightColour: TColorBox;
    chkTransExplainErrText: TCheckBox;
    chkTransExplainErrBtn: TCheckBox;
    tsStrInfo: TTabSheet;
    lblStrHighlightNonStd: TLabel;
    lblStrHighlightColour: TLabel;
    chkStrHighlightNonStd: TCheckBox;
    cbStrHighlightColour: TColorBox;
    btnDefault: TButton;
    procedure btnDefaultClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure chkStrHighlightNonStdClick(Sender: TObject);
    procedure chkTransHighlightErrClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure UpdateControls(const GUIFlags: Integer;
      const TransHighlightColour, StrHighlightColour: TColor);
      {Updates controls to reflect the given GUI flags and colours}
  protected
    procedure ArrangeForm; override;
      {Positions Default Settings button}
  public
    { Custom text box controls that provide descriptions of tab sheets }
    tbPopups: TTextBox;   // for Pop-ups tab
    tbFFI: TTextBox;      // for Fixed File Info tab
    tbTrans: TTextBox;    // for Translation tab
    tbStrInfo: TTextBox;  // for String Info tab
  end;


implementation


uses
  // Project
  USettings;


{$R *.dfm}

resourcestring
  // Descriptions that appear in custom tab text box controls
  sPopupsTabDesc = 'Overflow information about version information items can '
    + 'be displayed in a pop-up window. Use this page to configure the pop-up.';
  sFFITabDesc = 'Fixed file information is displayed at the top of Version '
    + 'Information Spy''s display. Use this page to customise how it is '
    + 'displayed.';
  sTransTabDesc = 'The program can highlight inconsistencies in translation '
    + 'data. Use this page to configure what information is displayed about '
    + 'such problems.';
  sStrInfoTabDesc = 'String file information is displayed at the bottom of '
    + 'Version Information Spy''s display. Use this page to customise the '
    + 'display.';


{ TDisplayOptsDlg }

procedure TDisplayOptsDlg.ArrangeForm;
  {Positions Default Settings button}
begin
  inherited;
  btnDefault.Top := btnHelp.Top;
  btnDefault.Left := 8;
end;

procedure TDisplayOptsDlg.btnDefaultClick(Sender: TObject);
  {User requested default values should be restored}
begin
  inherited;
  UpdateControls(
    cDefGUIFlags, cDefTransHighlightColour, cDefStrHighlightColour
  );
end;

procedure TDisplayOptsDlg.btnOKClick(Sender: TObject);
  {User OK'd: update Settings with values from dialog box}
var
  GUIFlags: Integer;  // stores flags to be stored in Settings
  CtrlIdx: Integer;   // loops thru components of form
  ChkBox: TCheckBox;  // reference to a check box component
begin
  inherited;
  // Store GUIFlags in Settings property of same name:
  // loops thru all check boxes on form, adding flags that are stored in Tag
  // property of checked check box's
  GUIFlags := 0;
  for CtrlIdx := 0 to Pred(ComponentCount) do
  begin
    if Components[CtrlIdx] is TCheckBox then
    begin
      ChkBox := Components[CtrlIdx] as TCheckBox;
      if ChkBox.Checked then
        GUIFlags := GUIFlags or ChkBox.Tag;
    end;
  end;
  Settings.GUIFlags := GUIFlags;
  // Store highlight colours
  Settings.TransHighlightColour := cbTransHighlightColour.Selected;
  Settings.StrHighlightColour := cbStrHighlightColour.Selected;
end;

procedure TDisplayOptsDlg.chkStrHighlightNonStdClick(Sender: TObject);
  {Disable or enable string highlight combo and label when check box indicates
  user doesn't want to highlight non-standard string items}
begin
  lblStrHighlightColour.Enabled := chkStrHighlightNonStd.Checked;
  cbStrHighlightColour.Enabled := chkStrHighlightNonStd.Checked;
end;

procedure TDisplayOptsDlg.chkTransHighlightErrClick(Sender: TObject);
  {Disable or enable translation highlight combo and label when check box
  indicates user doesn't want to highlight inconsistent translation items}
begin
  lblTransHighlightColour.Enabled := chkTransHighlightErr.Checked;
  cbTransHighlightColour.Enabled := chkTransHighlightErr.Checked;
end;

procedure TDisplayOptsDlg.FormCreate(Sender: TObject);
  {Form creation: create custom text box components and set controls to reflect
  display properties}
var
  TxtBoxW: Integer;   // width of custom text boxes
const
  TxtBoxH = 33;       // height of custom text boxes
  TxtBoxX = 8;        // left offset of custom text boxes
  TxtBoxY = 6;        // top offset of custom text boxes
begin
  inherited;
  // Set up custom text box controls for tab descriptions
  // record required width
  TxtBoxW := pcMain.Width - 24;
  // description for Pop-ups tab
  tbPopups := TTextBox.Create(Self);
  tbPopups.Parent := tsPopups;
  tbPopups.SetBounds(TxtBoxX, TxtBoxY, TxtBoxW, TxtBoxH);
  tbPopups.Caption := sPopupsTabDesc;
  // description for Fixed File Info tab
  tbFFI := TTextBox.Create(Self);
  tbFFI.Parent := tsFFI;
  tbFFI.SetBounds(TxtBoxX, TxtBoxY, TxtBoxW, TxtBoxH);
  tbFFI.Caption := sFFITabDesc;
  // description for Translation tab
  tbTrans := TTextBox.Create(Self);
  tbTrans.Parent := tsTrans;
  tbTrans.SetBounds(TxtBoxX, TxtBoxY, TxtBoxW, TxtBoxH);
  tbTrans.Caption := sTransTabDesc;
  // description for String Info tab
  tbStrInfo := TTextBox.Create(Self);
  tbStrInfo.Parent := tsStrInfo;
  tbStrInfo.SetBounds(TxtBoxX, TxtBoxY, TxtBoxW, TxtBoxH);
  tbStrInfo.Caption := sStrInfoTabDesc;

  // Assign GUI flags to check box tag properties
  chkFFIStructInfo.Tag          := VIGUI_FFI_STRUCTINFO;
  chkFFICreateDate.Tag          := VIGUI_FFI_CREATEDATE;
  chkFFIDescFileFlags.Tag       := VIGUI_FFI_DESCFILEFLAGS;
  chkTransHighlightErr.Tag      := VIGUI_TRANS_HIGHLIGHTERR;
  chkTransExplainErrText.Tag    := VIGUI_TRANS_EXPLAINERRTEXT;
  chkTransExplainErrBtn.Tag     := VIGUI_TRANS_EXPLAINERRBTN;
  chkStrHighlightNonStd.Tag     := VIGUI_STR_HIGHLIGHTNONSTD;
  chkPopupOverflow.Tag          := VIGUI_POPUP_OVERFLOW;

  // Set up controls from settings object
  UpdateControls(
    Settings.GUIFlags,
    Settings.TransHighlightColour,
    Settings.StrHighlightColour
  );
end;

procedure TDisplayOptsDlg.FormDestroy(Sender: TObject);
  {Save current tab index so same tab is displayed the next time the dlg is
  displayed}
begin
  inherited;
  Settings.CurrentTabSheetIdx[Self] := pcMain.ActivePageIndex;
end;

procedure TDisplayOptsDlg.FormShow(Sender: TObject);
  {Ensure that the last-used tab is displayed when dialog box opens}
begin
  inherited;
  pcMain.ActivePageIndex := Settings.CurrentTabSheetIdx[Self];
end;

procedure TDisplayOptsDlg.UpdateControls(const GUIFlags: Integer;
  const TransHighlightColour, StrHighlightColour: TColor);
  {Updates controls to reflect the given GUI flags and colours}
var
  CtrlIdx: Integer;   // loops thru all controls on form
  ChkBox: TCheckBox;  // reference to a check box
begin
  // Check the check boxes according to if their tag properties are present in
  for CtrlIdx := 0 to Pred(ComponentCount) do
  begin
    if Components[CtrlIdx] is TCheckBox then
    begin
      ChkBox := Components[CtrlIdx] as TCheckBox;
      ChkBox.Checked := ChkBox.Tag and GUIFlags = ChkBox.Tag;
    end;
  end;

  // Set up colour controls from settings object
  cbTransHighlightColour.Selected := TransHighlightColour;
  cbStrHighlightColour.Selected := StrHighlightColour;

  // Update control states from settings
  chkTransHighlightErrClick(Self);
  chkStrHighlightNonStdClick(Self);
end;

end.
