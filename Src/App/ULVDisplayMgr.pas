{ ##
  @FILE                     ULVDisplayMgr.pas
  @COMMENTS                 Defines a class that manages the display of various
                            list view controls used in Version Information Spy.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @DATE                 18/10/2004
      @VERSION              1.0
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
 * The Original Code is ULVDisplayMgr.pas.
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


unit ULVDisplayMgr;


interface


uses
  // Delphi
  Windows, Graphics, Classes, ComCtrls, Forms,
  // Project
  UDisplayMgrs, UPopupWindow;


type

  {
  TLVItemInfo:
    Record used to store information about list view items under mouse cursor.
  }
  TLVItemInfo = record
    ItemIdx: Integer;   // index of item under mouse cursor
    Part: (lviCaption, lviSubItem, lviNowhere);
                        // part of item undex mouse cursor
  end;


  {
  TLVDisplayMgr:
    Class used to manage the display of various list view controls used in
    Version Information Spy. Sets the list view's OnDrawItem and OnMouseMove
    event handlers and sets the OwnerDraw and RowSelect properties to True.

    Inheritance: TLVDisplayMgr -> TDisplayMgr -> [TObject]
  }
  TLVDisplayMgr = class(TDisplayMgr)
  private // properties
    fSpecialHighlightColour: TColor;
    fHighlightSelected: Boolean;
    fDisplayPopups: Boolean;
    procedure SetSpecialHighlightColour(const Value: TColor);
    procedure SetHighlightSelected(const Value: Boolean);
    procedure SetDisplayPopups(const Value: Boolean);
  private
    fPopupWdw: TPopupWindow;
      {Popup window object}
    fLV: TListView;
      {Reference to managed list view}
    fLastHintInfo: TLVItemInfo;
      {Information about last list item under mouse cursor}
    function GetOwnerForm: TForm;
      {Returns reference to form that owns the combo box}
    function GetLVColumnWidth(ColIdx: Integer): Integer;
      {Returns width of given list view column: this is used instead of
      fLV.Columns[Idx].Width because it doesn't return correct value when
      dragging}
    function GetLVItemRect(ItemIdx: Integer): TRect;
      {Returns the bounding rectangle of the given list view item}
    procedure DisplayHint(X, Y: Integer; const HintStr: string);
      {Displays popup hint window containing given hint string. The placing of
      the hint depends on mouse location X,Y. If HintStr is '' then or hints are
      inhibited no hint is displayed}
    procedure HideHint;
      {Hides any currently displayed hint window}
    procedure LVMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
      {Handle's list view's mouse move event and determines whether or not to
      display a hint window for the list item under the mouse}
    procedure LVDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
      {List view's OnDrawItem event handler: draws list items}
  protected
    procedure TimerEvent; override;
      {Hides any active hint window if mouse moves away from the list view's
      items on timer tick}
  public
    constructor Create(LV: TListView);
      {Class constructor: sets up managed list view, sets property defaults and
      creates owned objects}
    destructor Destroy; override;
      {Class destructor: frees owned objects}
    procedure SizeColumns;
      {Sizes the list view columns to fit the width of the list view control}
    property SpecialHighlightColour: TColor
      read fSpecialHighlightColour write SetSpecialHighlightColour;
      {Font colour used to highlight an item in the list view}
    property HighlightSelected: Boolean
      read fHighlightSelected write SetHighlightSelected default False;
      {Determines whether selected items are displayed highlighted or not}
    property DisplayPopups: Boolean
      read fDisplayPopups write SetDisplayPopups default True;
      {Determines whether pop-up hint windows are displayed when list view text
      overflows the space available. The hint windows display the full text}
  end;


implementation


uses
  // Delphi
  SysUtils, Controls, CommCtrl;


{ TLVDisplayMgr }

constructor TLVDisplayMgr.Create(LV: TListView);
  {Class constructor: sets up managed list view, sets property defaults and
  creates owned objects}
begin
  Assert(Assigned(LV));
  inherited Create;

  // Record and set up managed list view
  fLV := LV;
  // event handlers
  LV.OnDrawItem := LVDrawItem;
  LV.OnMouseMove := LVMouseMove;
  // required property values
  LV.OwnerDraw := True;
  LV.RowSelect := True;
  // disable list view's native info tip abilities
  ListView_SetExtendedListViewStyle(
    LV.Handle,
    Listview_GetExtendedListViewStyle(LV.Handle) and not LVS_EX_INFOTIP
  );

  // Default property values
  fSpecialHighlightColour := clNone;
  fDisplayPopups := True;

  // Create owned objects
  // create & set up popup window object
  fPopupWdw := TPopupWindow.Create(LV);
  fPopupWdw.Color := clInfoBk;

  // Record that no hint showing
  fLastHintInfo.ItemIdx := -1;
end;

destructor TLVDisplayMgr.Destroy;
  {Class destructor: frees owned objects}
begin
  FreeAndNil(fPopupWdw);
  inherited;
end;

procedure TLVDisplayMgr.DisplayHint(X, Y: Integer; const HintStr: string);
  {Displays popup hint window containing given hint string. The placing of the
  hint depends on mouse location X,Y. If HintStr is '' then or hints are
  inhibited no hint is displayed}
begin
  if (HintStr <> '') and fDisplayPopups then
    fPopupWdw.DisplayPopup(Point(X, Y), HintStr);
end;

function TLVDisplayMgr.GetLVColumnWidth(ColIdx: Integer): Integer;
  {Returns width of given list view column: this is used instead of
  fLV.Columns[Idx].Width because it doesn't return correct value when dragging}
begin
  Result := ListView_GetColumnWidth(fLV.Handle, ColIdx);
end;

function TLVDisplayMgr.GetLVItemRect(ItemIdx: Integer): TRect;
  {Returns the bounding rectangle of the given list view item}
begin
  ListView_GetItemRect(fLV.Handle, ItemIdx, Result, LVIR_BOUNDS);
end;

function TLVDisplayMgr.GetOwnerForm: TForm;
  {Returns reference to form that owns the combo box}
begin
  Result := fLV.Owner as TForm;
end;

procedure TLVDisplayMgr.HideHint;
  {Hides any currently displayed hint window}
begin
  // Hide the hint window
  fPopupWdw.Close;
  // Record dummy values for last hint info to trigger change when mouse moves
  fLastHintInfo.ItemIdx := -1;
  fLastHintInfo.Part := lviNowhere;
end;

procedure TLVDisplayMgr.LVDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
  {List view's OnDrawItem event handler: draws list items}

  // ---------------------------------------------------------------------------
  procedure DrawText(const S: string; R: TRect);
    {Draw the text S in rectangle R, adjusting R to allow for margins and
    displaying ellipsis when text is wider than rectangle}
  begin
    // Adjust rectangle to give margins
    InflateRect(R, -2, 0);
    // Draw the text
    DrawTextEx(
      fLV.Canvas.Handle,
      PChar(S),
      -1,
      R,
      DT_VCENTER or DT_END_ELLIPSIS or DT_LEFT,
      nil
    );

  end;
  // ---------------------------------------------------------------------------

var
  CW: Integer;    // width of caption column
  CR, IR: TRect;  // caption and sub-item bounding rectangles
begin

  // Set background and text colours per state
  if HighlightSelected and (odSelected in State) then
  begin
    // we need to highlight the item
    if fLV.Focused then
    begin
      // LV is focussed: highlight it
      fLV.Canvas.Brush.Color := clHighlight;
      fLV.Canvas.Font.Color := clHighlightText;
    end
    else
    begin
      // LV is not focussed: subdued highlight
      fLV.Canvas.Brush.Color := clBtnFace;
      fLV.Canvas.Font.Color := clBtnText;
    end;
  end
  else
  begin
    fLV.Canvas.Brush.Color := fLV.Color;
    // set special highlight font colour if required
    if (fSpecialHighlightColour <> clNone) and Assigned(Item.Data)
      and not (odSelected in State) then
      fLV.Canvas.Font.Color := fSpecialHighlightColour;
  end;

  // Fill background
  fLV.Canvas.FillRect(Rect);

  // Draw caption
  // calculate drawing rectangle
  CW := GetLVColumnWidth(0);  // don't use Column[0].Width: fails when resizing
  CR := Rect;
  CR.Right := CW;
  // draw text
  DrawText(Item.Caption, CR);

  // Draw sub item if present
  if Item.SubItems.Count > 0 then
  begin
    // calculate drawing rectangle
    IR := Rect;
    IR.Left := CW;
    // draw text
    DrawText(Item.SubItems[0], IR);
  end;
end;

procedure TLVDisplayMgr.LVMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
  {Handle's list view's mouse move event and determines whether or not to
  display a hint window for the list item under the mouse}

  // ---------------------------------------------------------------------------
  function CheckTextFits(const S: string; W: Integer): Boolean;
    {Returns true if width text of given fits in rectangle of width W}
  begin
    Result := fLV.StringWidth(S) <= W - 4;
  end;
  // ---------------------------------------------------------------------------

var
  LI: TListItem;              // list item under mouse cursor
  CaptionW: Integer;          // width of list item caption column
  SubItemW: Integer;          // width of list view sub item column
  ThisHintInfo: TLVItemInfo;  // information about list item under mouse
  TextW: Integer;             // width of text in list item part
  HintStr: string;            // hint to be displayed
begin
  // Switch off hint timer to prevent changes to hint mid calculation
  TimerEnabled := False;
  // We only display hint if DisplayPopups property is true
  if fDisplayPopups then
  begin
    // Assume no list item under mouse & no hint
    ThisHintInfo.ItemIdx := -1;
    ThisHintInfo.Part := lviNowhere;
    HintStr := '';
    // Set text width to max value
    TextW := MaxInt;
    // Get current list item if any
    LI := fLV.GetItemAt(X, Y);
    if Assigned(LI) then
    begin
      // We have a list item under mouse:
      // record item mindex
      ThisHintInfo.ItemIdx := LI.Index;
      // find which part of list item mouse is over (assume nowhere)
      CaptionW := GetLVColumnWidth(0);
      SubItemW := GetLVColumnWidth(1);
      if (X >= 0) and (X <= CaptionW) then
      begin
        // mouse over caption
        ThisHintInfo.Part := lviCaption;
        HintStr := LI.Caption;
        TextW := CaptionW;
      end
      else if (X > CaptionW)
        and (X <= CaptionW + SubItemW)
        and (LI.SubItems.Count > 0) then
      begin
        // mouse over sub item
        ThisHintInfo.Part := lviSubItem;
        HintStr := LI.SubItems[0];
        TextW := SubItemW;
      end;
    end;
    // Check if list item or list item part under mouse has changed
    if (ThisHintInfo.ItemIdx <> fLastHintInfo.ItemIdx)
      or (ThisHintInfo.Part <> fLastHintInfo.Part) then
    begin
      // Item (or part of item) under mouse has changes
      // hide any visible hint window
      HideHint;
      if (ThisHintInfo.ItemIdx > -1)
        and (ThisHintInfo.Part <> lviNowhere)
        and not CheckTextFits(HintStr, TextW) then
        // we're over a valid part of a list item and its text is too large so
        // display the hint
        DisplayHint(X, Y, HintStr);
      // record current hint item and part
      fLastHintInfo := ThisHintInfo;
    end;
    // Re-enable hint timer
    TimerEnabled := True;
  end;
end;

procedure TLVDisplayMgr.SetDisplayPopups(const Value: Boolean);
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
    // ensure that next mouse move records change in hint state
    fLastHintInfo.ItemIdx := -1;
  end;
end;

procedure TLVDisplayMgr.SetHighlightSelected(const Value: Boolean);
  {Write accessor for HighlightSelected property}
begin
  if fHighlightSelected <> Value then
  begin
    fHighlightSelected := Value;
    fLV.Invalidate;
  end;
end;

procedure TLVDisplayMgr.SetSpecialHighlightColour(const Value: TColor);
  {Write accessor for SpecialHighlightColour property}
begin
  if fSpecialHighlightColour <> Value then
  begin
    fSpecialHighlightColour := Value;
    fLV.Invalidate;
  end;
end;

procedure TLVDisplayMgr.SizeColumns;
  {Sizes the list view columns to fit the width of the list view control}
var
  C1W: Integer;   // width of column 1
begin
  // Set size of col 1, assuming no scroll bars
  C1W := fLV.Width - GetLVColumnWidth(0) - 4;
  // Reduce col 1 width appropriately if scroll bars
  if fLV.Items.Count > ListView_GetCountPerPage(fLV.Handle) then
    Dec(C1W, GetSystemMetrics(SM_CXVSCROLL));
  // Set the required width
  fLV.Column[1].Width := C1W;
end;

procedure TLVDisplayMgr.TimerEvent;
  {Hides any active hint window if mouse moves away from the list view's items
  on timer tick}
var
  LVPos: TPoint;  // mouse cursor position in list view
  ItemR: TRect;   // bounding rectangle of list item at top of client area
  NoHdrR: TRect;  // bounding rectangle of list view client area, less header
begin
  // Record current mouse position
  LVPos := fLV.ScreenToClient(Mouse.CursorPos);
  // Calculate areas occupied by list items in list view client area
  ItemR := GetLVItemRect(ListView_GetTopIndex(fLV.Handle));
  NoHdrR := fLV.ClientRect;
  NoHdrR.Top := ItemR.Top;
  if not PtInRect(NoHdrR, LVPos) then
    // Mouse has moved off list items: hide the hint
    HideHint;
  if fLastHintInfo.ItemIdx = -1 then
    // No hint visible: we can suspend the timer
    TimerEnabled := False
  else
    // Hint is visible: hide it if owner form doesn't have focus
    if not GetOwnerForm.Active then
      HideHint;
end;

end.
