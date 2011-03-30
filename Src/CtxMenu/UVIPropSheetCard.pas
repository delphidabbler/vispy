{
 * UVIPropSheetCard.pas
 *
 * Defines the class that encapsulates the property sheet "dialog" that displays
 * extended version information in the windows explorer property sheet dialog.
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
 * The Original Code is UVIPropSheetCard.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UVIPropSheetCard;


interface


uses
  // Delphi
  Messages,
  // Project
  UCard, UWLabel, UWButton, UWComboBox, UWListView;


type

  {
  TVIPropSheetCard:
    Class that encapsulates the property sheet "dialog" that displayed extended
    version information is displayed in the windows explorer property sheet
    dialog. This class simply adds the required controls to the parent window -
    other functionality is provided by the parent class.
  }
  TVIPropSheetCard = class(TCard)
  private // properties
    fFFILabel: TLabelWidget;
    fTransLabel: TLabelWidget;
    fStrInfoLabel: TLabelWidget;
    fAdvButton: TButtonWidget;
    fTransCombo: TComboBoxWidget;
    fFFIListView: TListViewWidget;
    fStrInfoListView: TLIstViewWidget;
  private
    procedure WMHelp(var Msg: TWMHelp); message WM_HELP;
      {Handles WM_HELP message: calls WinHelp using help context of widget
      associated with window handle provided by help message}
  protected
    procedure CreateControls; override;
      {Overridden method that creates the controls (widgets) that populate the
      dialog box}
  public
    destructor Destroy; override;
      {Object destructor. Releases help system}
    property FFILabel: TLabelWidget read fFFILabel;
      {Label that describes the fixed file info list view}
    property FFIListView: TListViewWidget read fFFIListView;
      {List view control that displays fixed file information}
    property TransLabel: TLabelWidget read fTransLabel;
      {Label that describes the translation combo box}
    property TransCombo: TComboBoxWidget read fTransCombo;
      {Combo box that holds all translations in the version information}
    property StrInfoLabel: TLabelWidget read fStrInfoLabel;
      {Label that describes the string table list view}
    property StrInfoListView: TLIstViewWidget read fStrInfoListView;
      {List view that displays string file information}
    property AdvButton: TButtonWidget read fAdvButton;
      {"Advanced" button: clicking this displays the full version information}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows, Classes,
  // Project
  UGlobals, UHTMLHelp;


{ TVIPropSheetCard }

procedure TVIPropSheetCard.CreateControls;
  {Overridden method that creates the controls (widgets) that populate the
  dialog box}
const
  cDlgMargin = 4;           // margin between controls & edge of dlg window
var
  R: TRect;                 // bounds of dialog window
  DlgW, DlgH: Integer;      // width & height of dialog window
  CtlW: Integer;            // width available for controls (DlgW - margins)
  TextH: Integer;           // height of text in dialog's font
  NextTop: Integer;         // vertical pos of top of next control
begin

  // Record width of dialog window
  GetWindowRect(Handle, R);
  DlgW := R.Right - R.Left;
  DlgH := R.Bottom - R.Top;
  CtlW := DlgW - 2 * cDlgMargin;
  TextH := TextHeight;
  NextTop := 2 * cDlgMargin;

  // Create widgets

  // fixed file information label
  fFFILabel := TLabelWidget.Create(
    Self, Bounds(cDlgMargin, NextTop, CtlW, TextH)
  );
  FFILabel.Caption := 'Fixed file information:';
  Inc(NextTop, FFILabel.Height);

  // fixed file information list view
  fFFIListView := TListViewWidget.Create(
    Self, Bounds(cDlgMargin, NextTop, CtlW, 122)
  );
  FFIListView.SetupColumns(['FFI Item', 'Details'], [100, CtlW - 124]);
  Inc(NextTop, FFIListView.Height + cDlgMargin);

  // trans combo label
  fTransLabel := TLabelWidget.Create(
    Self, Bounds(cDlgMargin, NextTop, CtlW, TextH)
  );
  TransLabel.Caption := '';   // caption is set when version info loaded
  Inc(NextTop, TransLabel.Height);

  // trans comb box
  fTransCombo := TComboBoxWidget.Create(
    Self, Bounds(cDlgMargin, NextTop, CtlW, TextH * 4)  // height=>dropdown size
  );
  Inc(NextTop, TransCombo.Height + cDlgMargin);

  // string info label
  fStrInfoLabel := TLabelWidget.Create(
    Self, Bounds(cDlgMargin, NextTop, CtlW, TextH)
  );
  StrInfoLabel.Caption := 'String file information:';
  Inc(NextTop, StrInfoLabel.Height);

  // string info list view
  fStrInfoListView := TListViewWidget.Create(
    Self,
    Bounds(cDlgMargin, NextTop, CtlW, DlgH - NextTop - 2 * cDlgMargin - 23)
  );
  StrInfoListView.SetupColumns(
    ['String Item', 'Details'], [100, CtlW - 124]
  );
  NextTop := DlgH - cDlgMargin - 23;

  // "advanced" button
  fAdvButton := TButtonWidget.Create(
    Self, Bounds(DlgW - cDlgMargin - 75, NextTop, 75, 23)
  );
  AdvButton.Caption := 'Ad&vanced...';

end;

destructor TVIPropSheetCard.Destroy;
begin
  HtmlHelp(0, nil, HH_CLOSE_ALL, 0);
  inherited;
end;

procedure TVIPropSheetCard.WMHelp(var Msg: TWMHelp);
  {Handles WM_HELP message: calls WinHelp using help context of widget
  associated with window handle provided by help message}
var
  HelpFile: string;   // help file containing required topic
  HelpTopic: string;  // full path to property sheet help topic
begin
  // TODO: Move 'VIS.chm' to UGlobals and use in FileVer project also
  HelpFile := ExtractFilePath(GetModuleName(HInstance))
    + UGlobals.cHelpFile;
  HelpTopic := HelpFile + '::/HTML/property-sheet.htm';
  HtmlHelp(GetDesktopWindow, PChar(HelpTopic), HH_DISPLAY_TOPIC, 0);
end;

end.

