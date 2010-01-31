{
 * UCBDisplayMgr.pas
 *
 * Defines a class that manages the display of a combo box used in Version
 * Information Spy's main form to display translation information.
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
 * The Original Code is UCBDisplayMgr.pas.
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


unit UCBDisplayMgr;


interface


uses
  // Delphi
  Windows, Graphics, Classes, Controls, StdCtrls, Forms,
  // Project
  UDisplayMgrs, UPopupWindow;


type

  {
  TCBDisplayMgr:
    Class used to manage the display of translation combo box used in Version
    Information Spy's main form. Sets the combo box's OnDrawItem, OnDropDown and
    OnChange event handlers and sets the Style property to csOwnerDrawFixed.

    Inheritance: TCBDisplayMgr -> TDisplayMgr -> [TObject]
  }
  TCBDisplayMgr = class(TDisplayMgr)
  private // properties
    fErrorTextColour: TColor;
    fOnChange: TNotifyEvent;
    fDisplayPopups: Boolean;
    procedure SetErrorTextColour(const Value: TColor);
    procedure SetDisplayPopups(const Value: Boolean);
  private
    fPopupWdw: TPopupWindow;
      {Popup window object}
    fHintShowing: Boolean;
      {Flag indcating whether hint window is displayed}
    fCB: TComboBox;
      {Reference to managed combo box}
    function GetOwnerForm: TForm;
      {Returns reference to form that owns the combo box}
    function GetSelectedText: string;
      {Text selected in combo box: '' if no selection}
    function GetSelectedTextBoxBounds: TRect;
      {Get bounds of rectangle in which combo box displays selected text}
    function SelectedTextFitsDisplay: Boolean;
      {Returns true if combo box's selected text fits within combo box's
      selected text display and false otherwise}
    procedure DisplayHint(const Pos: TPoint; const HintStr: string);
      {Display hint per HintStr below given mouse position in control}
    procedure HideHint;
      {Closes hint window}
    procedure CBDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
      {Combo box's OnDrawItem event handler: draws item in owner draw combo box.
      Also enables or disables hint timer as required}
    procedure CBDropDown(Sender: TObject);
      {Combo box's OnDropDown event handler: triggered when combo box is dropped
      down and hides any current hint}
    procedure CBChange(Sender: TObject);
      {Combo box's OnChange event handler: triggered when combo box's selection
      changes - hides any showing hint and triggers manager's own OnChange
      event}
  protected
    procedure TimerEvent; override;
      {Checks if mouse is in combo box and displays any required hint or hides
      current hint as required on timer tick}
  public
    constructor Create(CB: TComboBox);
      {Class constructor: sets up managed combo box, sets property defaults and
      creates owned objects}
    destructor Destroy; override;
      {Class destructor: frees owned objects}
    property DisplayPopups: Boolean
      read fDisplayPopups write SetDisplayPopups default True;
      {Determines whether pop-up hint windows are displayed when combo box is
      not wide enough to display all of translation description. The hint
      window displays the full text}
    property ErrorTextColour: TColor
      read fErrorTextColour write SetErrorTextColour default clNone;
      {Color in which to display error items in display (error items idicated
      by combo object's Items.Objects[] property)}
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
      {Event triggered when combo box's selection changes}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  IntfVerInfoReader;


{ TCBDisplayMgr }

procedure TCBDisplayMgr.CBChange(Sender: TObject);
  {Combo box's OnChange event handler: triggered when combo box's selection
  changes - hides any showing hint and triggers manager's own OnChange event}
begin
  // Hide hint if showing when selection changes
  if fHintShowing then
    HideHint;
  // Trigger change event if assigned
  if Assigned(OnChange) then
    OnChange(fCB);
end;

procedure TCBDisplayMgr.CBDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
  {Combo box's OnDrawItem event handler: draws item in owner draw combo box.
  Also enables or disables hint timer as required}
var
  Canvas: TCanvas;  // reference to combo box's canvas
  Status: Integer;  // status of var file info item assoc with item
  TextH: Integer;   // height of text
  Text: string;     // text to be displayed
begin
  // Get various information from combo box:
  // status of associated var file info item
  Status := Integer(fCB.Items.Objects[Index]);
  // text to display
  Text := fCB.Items[Index];
  // reference to canvas
  Canvas := fCB.Canvas;

  // Draw the item
  // clear background
  Canvas.FillRect(Rect);
  // draw the text
  if (Status in [VARVERINFO_STATUS_TRANSONLY, VARVERINFO_STATUS_STRTABLEONLY])
    and not (odSelected in State)
    and (fErrorTextColour <> clNone) then
    Canvas.Font.Color := fErrorTextColour;    // error item: use required colour
  TextH := Canvas.TextHeight(Text);                    // measure height of text
  Canvas.TextOut(Rect.Left + 2, (Rect.Bottom + Rect.Top - TextH) div 2, Text);

  // If we're drawing selected item in selected text window we enable hint timer
  // if a hint may be needed: i.e. selected text doesn't fit display
  if (Index = fCB.ItemIndex) and not fCB.DroppedDown then
    TimerEnabled := not SelectedTextFitsDisplay;
end;

procedure TCBDisplayMgr.CBDropDown(Sender: TObject);
  {Combo box's OnDropDown event handler: triggered when combo box is dropped
  down and hides any current hint}
begin
  // We don't want hint displayed if combo box is dropped down
  if fHintShowing then
    HideHint;
end;

constructor TCBDisplayMgr.Create(CB: TComboBox);
  {Class constructor: sets up managed combo box, sets property defaults and
  creates owned objects}
begin
  Assert(Assigned(CB));
  inherited Create;

  // Record and set up managed combo box
  fCB := CB;
  // event handlers
  fCB.OnDrawItem := CBDrawItem;
  fCB.OnDropDown := CBDropDown;
  fCB.OnChange := CBChange;
  // required properties
  fCB.Style := csOwnerDrawFixed;

  // Default property values
  fErrorTextColour := clNone;
  fDisplayPopups := True;

  // Create owned objects
  // create & set up popup window object
  fPopupWdw := TPopupWindow.Create(fCB);
  fPopupWdw.Color := clInfoBk;
end;

destructor TCBDisplayMgr.Destroy;
  {Class destructor: frees owned objects}
begin
  FreeAndNil(fPopupWdw);
  inherited;
end;

procedure TCBDisplayMgr.DisplayHint(const Pos: TPoint; const HintStr: string);
  {Display hint per HintStr below given mouse position in control. If HintStr is
  '' then or hints are inhibited no hint is displayed}
begin
  if (HintStr <> '') and fDisplayPopups then
  begin
    fPopupWdw.DisplayPopup(Pos, HintStr);
    fHintShowing := True;
  end;
end;

function TCBDisplayMgr.GetOwnerForm: TForm;
  {Returns reference to form that owns the combo box}
begin
  Result := fCB.Owner as TForm;
end;

function TCBDisplayMgr.GetSelectedText: string;
  {Text selected in combo box: '' if no selection}
var
  ItemIdx: Integer; // index of selected item
begin
  ItemIdx := fCB.ItemIndex;
  if ItemIdx > -1 then
    Result := fCB.Items[ItemIdx]
  else
    Result := '';
end;

function TCBDisplayMgr.GetSelectedTextBoxBounds: TRect;
  {Get bounds of rectangle in which combo box displays selected text}
var
  CBTextW: Integer;         // width available to display combo box text
  CBTextH: Integer;         // height of text display in combo box
  CXEdge, CYEdge: Integer;  // horizontal & vertical control border size
  ArrowW: Integer;          // width of drop down arrow
begin
  // Get size of combo box elements
  CXEdge := GetSystemMetrics(SM_CXEDGE);    // left & right border of combo
  CYEdge := GetSystemMetrics(SM_CYEDGE);    // top & bottom border of combo
  ArrowW := GetSystemMetrics(SM_CXVSCROLL); // width of drop down arrow

  // Calculate width and height of rect in which combo box text is displayed
  CBTextW := fCB.Width    // width of control
    - ArrowW              // width of drop down arrow
    - 2 * CXEdge          // width of 2 vertical borders
    - 2;                  // delta value
  CBTextH := fCB.Height   // height of control
    - 2 * CYEdge          // width of 2 horizontal borders
    - 2;                  // delta value

  // Calculate bounding rectangle of combo box text rectangle
  Result := Bounds(CXEdge + 1, CYEdge + 1, CBTextW, CBTextH);
end;

procedure TCBDisplayMgr.HideHint;
  {Closes hint window}
begin
  if fHintShowing then
  begin
    fPopupWdw.Close;
    fHintShowing := False;
  end;
end;

function TCBDisplayMgr.SelectedTextFitsDisplay: Boolean;
  {Returns true if combo box's selected text fits within combo box's selected
  text display and false otherwise}
var
  CBTextW: Integer;   // width avail to display combo box text
  CBTextR: TRect;     // rect containing text in combo box
begin
  // Calculate rectangle in which combo box text is displayed
  CBTextR := GetSelectedTextBoxBounds;
  CBTextW := CBTextR.Right - CBTextR.Left;
  // Determine if selected text fits in the display rectangle
  Result := fCB.Canvas.TextWidth(GetSelectedText) <= CBTextW - 4;
end;

procedure TCBDisplayMgr.SetDisplayPopups(const Value: Boolean);
  {Write accessor for DisplayPopups property}
begin
  if fDisplayPopups <> Value then
  begin
    fDisplayPopups := Value;
    // hide any existing hint of popups not allowed
    if not fDisplayPopups then
      HideHint;
    // start or stop hint timer
    TimerEnabled := Value;
  end;
end;

procedure TCBDisplayMgr.SetErrorTextColour(const Value: TColor);
  {Write accessor for ErrorTextColour property}
begin
  if fErrorTextColour <> Value then
  begin
    fErrorTextColour := Value;
    fCB.Invalidate;
  end;
end;

procedure TCBDisplayMgr.TimerEvent;
  {Checks if mouse is in combo box and displays any required hint or hides
  current hint as required on timer tick}
var
  CBPos: TPoint;      // position of mouse within combobox
  WantHint: Boolean;  // whether hint should be shown or hidden
begin
  // Get mouse position: get out if cursor position not known
  if not Windows.GetCursorPos(CBPos) then
    Exit;
  CBPos := fCB.ScreenToClient(CBPos); // translate to combo box co-ords

  // We want hint displayed if:
  WantHint :=
    GetOwnerForm.Active                                   // this form is active
    and not fCB.DroppedDown                   // & combo box is not dropped down
    and not SelectedTextFitsDisplay       // & selected text larger than display
    and PtInRect(GetSelectedTextBoxBounds, CBPos); // & mouse over combobox text

  // Display or hide hint or do nothing if hint is already in required state
  case WantHint of
    True:
      if not fHintShowing then
        DisplayHint(CBPos, GetSelectedText);
    False:
      if fHintShowing then
        HideHint;
  end;
end;

end.
