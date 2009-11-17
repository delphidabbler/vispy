{ ##
  @FILE                     FmExplExt.pas
  @COMMENTS                 Defines a dialog box class that enables shell
                            extension handlers to be configured.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None.
  @OTHER_NAMES              Original name was FmCtxMenu.pas. Renamed as
                            FmExplExt.pas at v3.0.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 04/08/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 24/02/2003
      @COMMENTS             Total redesign. The dialog now permits user to
                            specify the extensions that the context menu handler
                            will operate with. The user can now also switch on
                            or off automatic registration of new extensions as
                            they are used. The first page permits basic changes
                            to be made - turning on and off all extensions or
                            other simple configurations. The second page
                            presents the list of all relevant extensions that
                            can be customised.
    )
    @REVISION(
      @VERSION              3.0
      @DATE                 19/10/2004
      @COMMENTS             Major update:
                            + Dialog now derives from a tabbed dialog base class
                              class that in turn derives from a new dialog class
                              heirachy. The bases classes provide alignment of
                              dialog, arrangement of main controls, calling of
                              required help and saving of active tab.
                            + Revised to support configuration of both context
                              menu and property sheet shell extensions.
                            + Added new controls and modified layout, correcting
                              typos.
                            + Supporting code totally rewritten to use a
                              separate object to manage the changes to extension
                              recording and registration.
                            + Made list view control on advanced tab into owner
                              draw control to support two check boxes per item.
                            + Removed inclusion of map file contain help context
                              numbers: help system now uses form name as
                              keyword.
                            + The tab displayed when dialog is closed is now
                              remembered and re-displayed when dialog is next
                              opened.
                            + Renamed dialog box class from TCtxMenuDlg to
                              TExplExtDlg and renamed unit from FmCtxMenu to
                              FmExplExt.
    )
    @REVISION(
      @VERSION              3.1
      @DATE                 22/08/2007
      @COMMENTS             Fixed various problems with list view on advanced
                            tab:
                            + Made checkbox columns fixed size and gave text
                              columns minimum size. Sizes will restore after
                              dragging.
                            + Fixed bug that wasn't vertically aligning text in
                              list view items.
                            + Fixed bug where when columns were dragged across
                              checkboxes, part of check box image was being left
                              behind in dragged column as an artifact.
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
 * The Original Code is FmExplExt.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit FmExplExt;


interface


uses
  // Delphi
  Controls, ComCtrls, StdCtrls, ExtCtrls, Classes, Windows, Messages, Graphics,
  // Project
  UExtensions, FmBaseTabbedDlg;


type

  {
  TRectArray:
    Open array of TRect structures.
  }
  TRectArray = array of TRect;

  {
  TExplExtDlg:
    Implements a dialog box that enables shell extension handlers to be
    configured.
  }
  TExplExtDlg = class(TBaseTabbedDlg)
    tsBasic: TTabSheet;
    lblEnableCtxMenu: TLabel;
    lblSingleAppInst: TLabel;
    lblQueryUser: TLabel;
    cbEnableCtxMenu: TCheckBox;
    cbSingleAppInst: TCheckBox;
    cbQueryUser: TCheckBox;
    tsAdvanced: TTabSheet;
    lblExts: TLabel;
    lvExts: TListView;
    btnSelectAll: TButton;
    btnDeselectAll: TButton;
    btnDelete: TButton;
    lblDesc: TLabel;
    btnAddExt: TButton;
    cbEnablePropSheet: TCheckBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbEnableCtxMenuClick(Sender: TObject);
    procedure lvExtsKeyPress(Sender: TObject; var Key: Char);
    procedure btnSelectAllClick(Sender: TObject);
    procedure btnDeselectAllClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnAddExtClick(Sender: TObject);
    procedure lvExtsDrawItem(Sender: TCustomListView; Item: TListItem;
      Rect: TRect; State: TOwnerDrawState);
    procedure lvExtsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbEnablePropSheetClick(Sender: TObject);
    procedure lvExtsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    fCheckBoxBmp: TBitmap;
      {Stores bitmap containing images of check boxes (unused and set to nil
      when XP themes are enabled)}
    fCheckBoxSize: TSize;
      {Size of a checkbox: calcualted differently according to whether XP themes
      are enabled}
    fExtMgr: TRecordedExtensionMgr;
      {Object used to manage recorded extensions}
    function LVColumnWidth(const ColIdx: Integer): Integer;
      {Returns width of given column in extension list view. This method is used
      instead of list view's ColumnWidth[] property since the property gives
      wrong result when columns are being resized}
    function LVCheckBoxRects(const Item: TListItem): TRectArray;
      {Returns dynamic array of bounding rectangles of all required check boxes,
      centred horizontally in list view column and vertically in list item row}
    procedure LVSetupDisplayFields;
      {Sets up fields required to disply custom drawn list view items, depending
      on whether XP themes are enabled}
    procedure WMWinIniChange(var Msg: TWMWinIniChange); message WM_WININICHANGE;
      {Handles WM_WININICHANGE (= WM_SETTINGCHANGE) message by re-configuring
      fields used to display cutom extension list view}
    procedure PopulateListView;
      {Displays recorded extensions in list view control}
    procedure RegisterAll(Flag: Boolean; ExtIds: Cardinal);
      {Registers or unregisters all recorded extensions for given extension ids
      according to Flag. ExtIds is a bitmask representing the extension(s) to
      register}
    function RegistrationState(ExtFlag: Cardinal): TCheckBoxState;
      {Returns a code indicating the state of registration of extensions for
      the shell extension represented by the given flag. The return value tells
      whether all recorded extensions are registered all are unregistered or
      there is a mixture of both. The code returned represents the state of a
      3-state check box, but can be used for other reasons}
    procedure UpdateAdvTabButtons;
      {Updates state of buttons on advance tab according to extensions
      registered & selected list view item}
    procedure UpdateBasicTabCtrls;
      {Updates state of check boxes on basic tab according to state of context
      menu and property sheet check boxes}
    procedure UpdateCtxMenuCheck;
      {Updates state of context menu handler check box according to how many of
      the recorded extensions are registered with the handler}
    procedure UpdatePropSheetCheck;
      {Updates state of property sheet handler check box according to how many
      of the recorded extensions are registered with the handler}
    procedure UpdateExtensionControls;
      {Updates all controls that depend on supported extensions and those
      registered with shell extension handlers}
    procedure UpdateListViewChecks;
      {Updates check marks of list view control on "advanced" tab to reflect
      which extensions are registered for which shell extension}
    procedure UpdateRegistrationFromListView;
      {Updates record of registered extensions from the state of the check boxes
      in the list view that displays recorded extensions}
  end;


implementation


uses
  // Delphi
  SysUtils, CommCtrl, Themes, UxTheme,
  // Project
  USettings, FmExplExtAdd;

{$R *.dfm}


resourcestring
  // Error messages
  sExtAlreadyRecorded = 'Extension %s is already recorded';


const
  // Column indexes where various items are displayed in list view
  cCtxMenuCheckCol = 0;     // context menu check mark
  cPropSheetCheckCol = 1;   // property sheet check mark
  cExtCol = 2;              // extension text
  cDescCol = 3;             // extension file type description

  // Extension manager flags associated with the checked state of the extension
  // list view check boxes
  cChkBoxFlags: array[cCtxMenuCheckCol..cPropSheetCheckCol] of Cardinal = (
    EXTFLAG_REGCTXMENU, EXTFLAG_REGPROPSHEET
  );


{ Helper routines }

function GetExtFromLVItem(const Item: TListItem): string;
  {Returns the extension associated with the given list view item in the lvExts
  list view}
begin
  Result := Item.SubItems[cExtCol - 1];
end;

function GetDescFromLVItem(const Item: TListItem): string;
  {Returns the description of the extension associated with the given list view
  item in the form's lxExts list view}
begin
  Result := Item.SubItems[cDescCol - 1];
end;

function GetFlagsFromLVItem(const Item: TListItem): Cardinal;
  {Returns the extension manager compatible flags stored with the with the given
  list view item in the form's lxExts list view}
begin
  Result := Cardinal(Item.Data);
end;


{ TExplExtDlg }

procedure TExplExtDlg.btnAddExtClick(Sender: TObject);
  {Add button clicked: display Add Extension dialog box and add any selected
  extension to list of recorded extensions}
begin
  // Create and display Add Extension dialog box
  with TExplExtAddDlg.Create(Self) do
    try
      // Merge all currently displayed extensions into extension dialog box in
      // case they are not yet registered with Windows. (This can happen if user
      // entered an unknown file extensions in a previous call to the "Add"
      // dialog box)
      MergeRecorded(fExtMgr);
      // Display dialog and get user input
      if ShowModal = mrOK then
      begin
        // User OK'd
        if fExtMgr.IsRecorded[Extension] then
          raise Exception.CreateFmt(sExtAlreadyRecorded, [Extension]);
        // Selected extension not recorded: add it to list
        fExtMgr.IsRecorded[Extension] := True;
        // Update controls to reflect change
        UpdateExtensionControls;
      end;
    finally
      Free;
    end;
end;

procedure TExplExtDlg.btnDeleteClick(Sender: TObject);
  {Delete the selected extension from list view and "unrecord" it}
var
  SelItem: TListItem; // selected list view item
  Ext: string;        // extension represented by selected item
begin
  SelItem := lvExts.Selected;
  if Assigned(SelItem) then
  begin
    // "Unrecord" the extension
    Ext := GetExtFromLVItem(SelItem);
    fExtMgr.IsRecorded[Ext] := False;
    // Update control following change
    UpdateExtensionControls;
  end;
end;

procedure TExplExtDlg.btnDeselectAllClick(Sender: TObject);
  {Deselect all recorded extensions displayed in list view and mark for
  unregistration}
begin
  // Unregister all extensions
  RegisterAll(False, EXTFLAG_REGCTXMENU or EXTFLAG_REGPROPSHEET);
  // Update display
  UpdateListViewChecks;
  UpdateCtxMenuCheck;
  UpdatePropSheetCheck;
end;

procedure TExplExtDlg.btnOKClick(Sender: TObject);
  {OK button pressed: accept all changes and record them}
begin
  inherited;
  // Store all changes to file extensions registered with shell extensions
  fExtMgr.CommitChanges;
  // Store all other changes directly via Settings object
  Settings.ShellExRunsSingleInst := cbSingleAppInst.Checked;
  Settings.AutoRegExtension := cbQueryUser.Checked;
end;

procedure TExplExtDlg.btnSelectAllClick(Sender: TObject);
  {Select all recorded extensions displayed in list view and mark for
  registration}
begin
  // Register all extensions
  RegisterAll(True, EXTFLAG_REGCTXMENU or EXTFLAG_REGPROPSHEET);
  // Update display
  UpdateListViewChecks;
  UpdateCtxMenuCheck;
  UpdatePropSheetCheck;
end;

procedure TExplExtDlg.cbEnableCtxMenuClick(Sender: TObject);
  {Register/unregister all recorded extensions according to state of context
  menu check box}
begin
  // Register unregister all extensions for this handler
  RegisterAll(cbEnableCtxMenu.Checked, EXTFLAG_REGCTXMENU);
  // Update display
  UpdateListViewChecks;
  UpdateBasicTabCtrls;
end;

procedure TExplExtDlg.cbEnablePropSheetClick(Sender: TObject);
begin
  // Register unregister all extensions for this handler
  RegisterAll(cbEnablePropSheet.Checked, EXTFLAG_REGPROPSHEET);
  // Update display
  UpdateListViewChecks;
  UpdateBasicTabCtrls;
end;

procedure TExplExtDlg.FormCreate(Sender: TObject);
  {Create extension manager object and initialise controls}
begin
  inherited;
  // Set up information needed by list view custom draw
  LVSetupDisplayFields;
  // Create extension manager (this reads extension info from registry)
  fExtMgr := TRecordedExtensionMgr.Create;
  // Update controls that display extension information
  UpdateExtensionControls;
  // Updates other controls direct from Settings object
  cbSingleAppInst.Checked := Settings.ShellExRunsSingleInst;
  cbQueryUser.Checked := Settings.AutoRegExtension;
end;

procedure TExplExtDlg.FormDestroy(Sender: TObject);
  {Frees owned objects}
begin
  lvExts.OnSelectItem := nil; // prevent from triggering after fExtMgr freed
  FreeAndNil(fExtMgr);
  FreeAndNil(fCheckBoxBmp);
  inherited;
end;

function TExplExtDlg.LVCheckBoxRects(const Item: TListItem): TRectArray;
  {Returns dynamic array of bounding rectangles of all required check boxes,
  centred horizontally in list view column and vertically in list item row}
var
  BoundRect: TRect;   // bound rectangle of list item
  ColLeft: Integer;   // left edge of a list view column
  ColWidth: Integer;  // width of a list view column
  ChkIdx: Integer;    // index of check box (= index of column)
const
  cNumChkBoxes = 2;   // number of check boxes in list view
begin
  Assert(Assigned(Item));
  // Get bounding rectangle of list item
  BoundRect := Item.DisplayRect(drBounds);
  // Set length of resulting array to number of list boxes
  SetLength(Result, cNumChkBoxes);
  // Left edge of first column
  ColLeft := BoundRect.Left;
  // Loop thru each check box (= column index), calculating check box rectangle
  for ChkIdx := 0 to Pred(cNumChkBoxes) do
  begin
    // get column width
    ColWidth := LVColumnWidth(ChkIdx);
    // calculate bounds of check box
    Result[ChkIdx] := Bounds(
      ColLeft + (ColWidth - fCheckBoxSize.cx) div 2,
      (BoundRect.Bottom + BoundRect.Top - fCheckBoxSize.cy) div 2,
      fCheckBoxSize.cx,
      fCheckBoxSize.cy
    );
    // calculate left edge of next column
    Inc(ColLeft, ColWidth);
  end;
end;

function TExplExtDlg.LVColumnWidth(const ColIdx: Integer): Integer;
  {Returns width of given column in extension list view. This method is used
  instead of list view's ColumnWidth[] property since the property gives wrong
  result when columns are being resized}
begin
  Result := ListView_GetColumnWidth(lvExts.Handle, ColIdx);
end;

procedure TExplExtDlg.lvExtsDrawItem(Sender: TCustomListView;
  Item: TListItem; Rect: TRect; State: TOwnerDrawState);
  {Performs custom drawing of list items in extensions list view, handling
  drawing of both check boxes and text}

  // ---------------------------------------------------------------------------
  procedure DrawText(const S: string; R: TRect);
    {Draw the text S in rectangle R, adjusting R to allow for margins and
    displaying ellipsis when text is wider than rectangle}
  begin
    // Adjust rectangle to give margins
    InflateRect(R, -2, 0);
    // Draw the text
    DrawTextEx(
      lvExts.Canvas.Handle,
      PChar(S),
      -1,
      R,
      DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS or DT_LEFT,
      nil
    );
  end;

  procedure DrawCheckBox(const Checked: Boolean; const R: TRect);
    {Draw a check box with given state in given rectangle. Check box drawn
    differently according to whether XP themes enabled}

    // -------------------------------------------------------------------------
    procedure DrawStdCheckBox;
      {Draw a non-themed check box}
    var
      SourceRect: TRect;  // bounding rectangle of internal check box bmp
    const
      // Co-ordinates of checked and unchecked bitmaps in Windows internal
      // bitmap that stores all different check box images
      cBmpCoords: array[Boolean] of TPoint = ((X: 0; Y: 0), (X: 1; Y: 0));
    begin
      // We need to draw a Windows-defined bitmap representing the required
      // checked or unchecked check box. Windows stores all the bitmaps that
      // represent the various check box state in a single large 4 by 3 bitmap
      // First we find bound rectangleof required bitmap in Windows bitmap
      SourceRect := Bounds(
        cBmpCoords[Checked].X * fCheckBoxSize.cx,
        cBmpCoords[Checked].Y * fCheckBoxSize.cy,
        fCheckBoxSize.cx,
        fCheckBoxSize.cy
      );
      // We now copy the require check box bmp to the given rectangle in the
      // list item
      lvExts.Canvas.CopyRect(R, fCheckBoxBmp.Canvas, SourceRect);
    end;

    procedure DrawThemedCheckBox;
      {Draw a XP-themed check box}
    const
      // Type of check box to draw in unchecked and checked state
      cCBType: array[Boolean] of TThemedButton = (
        tbCheckBoxUncheckedNormal, tbCheckBoxCheckedNormal
      );
    begin
      // Get theme services to display check box of required type in required
      // place in list item
      ThemeServices.DrawElement(
        lvExts.Canvas.Handle,
        ThemeServices.GetElementDetails(cCBType[Checked]),
        R
      );
    end;
    // -------------------------------------------------------------------------

  begin
    // Draw check box according to whether XP themes enabled
    if ThemeServices.ThemesEnabled then
      DrawThemedCheckBox
    else
      DrawStdCheckBox;
  end;
  // ---------------------------------------------------------------------------

var
  C: TCanvas;                     // reference to list view's canvas
  ColIdx: Integer;                // loops thru list box columns
  ColLeft: Integer;               // left hand edge of a list view column
  ColWidth: Integer;              // width of a list view column
  ColRects: array[0..3] of TRect; // bounding rectangles of list item column
  Flags: Cardinal;                // flags indicating state of item's chk boxes
  ChkIdx: Integer;                // loops thru check boxes
  ChkRects: TRectArray;           // bounding rectangles of item's chk boxes
begin
  inherited;

  // Record column widths and item rectangle:
  ColLeft := Rect.Left;
  for ColIdx := 0 to 3 do
  begin
    ColWidth := LVColumnWidth(ColIdx);
    ColRects[ColIdx] := Classes.Rect(
      ColLeft, Rect.Top, ColLeft + ColWidth, Rect.Bottom
    );
    Inc(ColLeft, ColWidth);
  end;

  // Get reference to canvas
  C := lvExts.Canvas;

  // Set background and text colours per state
  if odSelected in State then
  begin
    // we need to highlight the item
    if lvExts.Focused then
    begin
      // LV is focussed: highlight it
      C.Brush.Color := clHighlight;
      C.Font.Color := clHighlightText;
    end
    else
    begin
      // LV is not focussed: subdued highlight
      C.Brush.Color := clBtnFace;
      C.Font.Color := clBtnText;
    end;
  end
  else
    C.Brush.Color := lvExts.Color;

  // Fill background
  C.FillRect(Rect);

  // Draw check boxes
  ChkRects := LVCheckBoxRects(Item);     // get bounding rectangles of chk boxes
  Flags := GetFlagsFromLVItem(Item);                     // get check box states
  Assert(Flags and EXTFLAG_RECORDED = EXTFLAG_RECORDED);
  for ChkIdx := Low(ChkRects) to High(ChkRects) do        // draw each check box
  begin
    C.FillRect(ColRects[ChkIdx]);   // prevents artifacts when resizing
    DrawCheckBox(
      Flags and cChkBoxFlags[ChkIdx] = cChkBoxFlags[ChkIdx],  // whether checked
      ChkRects[ChkIdx]                        // bounding rectangle of check box
    );
  end;

  // Draw extension and description text in required columns
  C.FillRect(ColRects[cExtCol]);  // prevents artifacts when resizing
  DrawText(GetExtFromLVItem(Item), ColRects[cExtCol]);
  C.FillRect(ColRects[cDescCol]); // prevents artifacts when resizing
  DrawText(GetDescFromLVItem(Item), ColRects[cDescCol]);

end;

procedure TExplExtDlg.lvExtsKeyPress(Sender: TObject; var Key: Char);
  {Update registration information when space bar pressed on list view: space
  bar toggles selected list item's check state}
var
  Item: TListItem;        // selected list item we operate on
  Flags: Cardinal;        // check box flags for list item
  ChkRects: TRectArray;   // bounding rectangles of item's check boxes
  RectIdx: Integer;       // loops thru elements of ChkRects
begin
  // Keep compiler warnings quiet!
  SetLength(ChkRects, 0);
  // We process space key
  if Key = #32 then
  begin
    Item := lvExts.Selected;
    if Assigned(Item) then
    begin
      // Get flags without Recorded flag: just want registration ones
      Flags := GetFlagsFromLVItem(Item) and not EXTFLAG_RECORDED;
      // Cycle thru possible flags
      case Flags of
        0:
          Flags := EXTFLAG_REGCTXMENU;
        EXTFLAG_REGCTXMENU:
          Flags := EXTFLAG_REGCTXMENU or EXTFLAG_REGPROPSHEET;
        EXTFLAG_REGCTXMENU or EXTFLAG_REGPROPSHEET:
          Flags := EXTFLAG_REGPROPSHEET;
        EXTFLAG_REGPROPSHEET:
          Flags := 0;
      end;
      // Store flags again
      Item.Data := Pointer(Flags or EXTFLAG_RECORDED);
      // Update display of check boxes
      ChkRects := LVCheckBoxRects(Item);
      for RectIdx := Low(ChkRects) to High(ChkRects) do
        InvalidateRect(lvExts.Handle, @ChkRects[RectIdx], False);
      // Update registration data from list view
      UpdateRegistrationFromListView;
    end;
    // Swallow space key
    Key := #0;
  end;
end;

procedure TExplExtDlg.lvExtsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  {Handles mouse down event on extension list view, toggling state of custom
  check boxes if mouse is over them}
var
  Item: TListItem;        // list item under mouse cursor
  ChkId: Integer;         // id of check box (index into array of info)
  ChkRects: TRectArray;   // array of check box bounding rectangles
  I: Integer;             // loops thru array of check box rectangles
  Pt: TPoint;             // mouse position within list view
  ChkFlag: Cardinal;      // flag associated with a checked check box
  Flags: Cardinal;        // current check flags associated with list item
begin
  inherited;
  // Get list view item under mouse, if any
  Item := lvExts.GetItemAt(X, Y);
  if Assigned(Item) then
  begin
    // Check which, if any, of items check boxes mouse is over
    ChkId := -1;                              // assume no check box under mouse
    ChkRects := LVCheckBoxRects(Item);  // get array of check box bounding rects
    Pt := Point(X, Y);           // record point where mouse is within list view
    for I := Low(ChkRects) to High(ChkRects) do            // loop thu chk boxes
    begin
      if PtInRect(ChkRects[I], Pt) then
      begin
        ChkId := I;                                   // mouse in this check box
        Break;
      end;
    end;
    if ChkId >= 0 then
    begin
      // Mouse over a check box
      // toggle check box value
      ChkFlag := cChkBoxFlags[ChkID];      // get flag associated with check box
      Flags := GetFlagsFromLVItem(Item);      // get current flags for list item
      if ChkFlag and Flags <> ChkFlag then
        Flags := Flags or ChkFlag         // box unchecked: add flag to check it
      else
        Flags := Flags and not ChkFlag; // box checked: removde flag to clear it
      Item.Data := Pointer(Flags);             // record new flags for list item
      // re-display check box in new state
      InvalidateRect(lvExts.Handle, @ChkRects[ChkID], False);
      // update registration details in extension manager
      UpdateRegistrationFromListView;
    end;
  end
  else
    SetLength(ChkRects, 0); // keeps compiler happy!
end;

procedure TExplExtDlg.lvExtsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
  {Handles OnSelectItem event for list view: updates buttons on advanced tab
  when selection changes}
begin
  inherited;
  UpdateAdvTabButtons;
end;

procedure TExplExtDlg.LVSetupDisplayFields;
  {Sets up fields required to disply custom drawn list view items, depending on
  whether XP themes are enabled}
var
  Details: TThemedElementDetails; // details of XP themed items
  R: TRect;                       // display area for XP items
begin
  inherited;
  // Free any current check box bitmaps
  FreeAndNil(fCheckBoxBmp);
  if ThemeServices.ThemesEnabled then
  begin
    // XP themes enabled: simply need to record size of a check box
    // get details of a check box: assume all same size
    Details := ThemeServices.GetElementDetails(tbCheckBoxUncheckedNormal);
    // create arbitrary rectangle used in GetThemePartSize
    R := Rect(0, 0, 100, 100);
    // get size of check box that would be drawn in rectangle R
    UxTheme.GetThemePartSize(
      ThemeServices.Theme[Details.Element],
      Canvas.Handle,
      Details.Part,
      Details.State,
      @R,
      TS_DRAW,
      fCheckBoxSize
    );
  end
  else
  begin
    // No theme support: we need check box size + bitmap storing images of all
    // checkboxes that is provided by Windows
    // load bitmap that contains images of all check boxes
    fCheckBoxBmp := TBitmap.Create;
    fCheckBoxBmp.Handle := LoadBitmap(0, MakeIntResource(OBM_CHECKBOXES));
    // this bmp is a 4 x 3 matrix - calculate check box size from size of bmp
    fCheckBoxSize.cx := fCheckBoxBmp.Width div 4;
    fCheckBoxSize.cy := fCheckBoxBmp.Height div 3;
  end;
end;

procedure TExplExtDlg.PopulateListView;
  {Displays recorded extensions in list view control}
var
  Ext: string;    // an extension
  LI: TListItem;  // references a new list item
begin
  // Clear list view
  lvExts.Items.BeginUpdate;
  try
    lvExts.Clear;
    // Enumerate recorded extensions
    fExtMgr.EnumStart(EXTFLAG_RECORDED);
    while fExtMgr.Next(Ext) do
    begin
      // add list item for extension
      LI := lvExts.Items.Add;
      LI.Caption := '';                              // display first check here
      LI.SubItems.Add('');                             // display 2nd check here
      LI.SubItems.Add(Ext);            // ext displayed in 3rd col (2nd subitem)
      LI.SubItems.Add(fExtMgr.FileTypeDesc(Ext));             // desc in 4th col
      LI.Data := Pointer(fExtMgr.RegistrationFlags[Ext]);      // check box info
    end;
  finally
    lvExts.Items.EndUpdate;
  end;
end;

procedure TExplExtDlg.RegisterAll(Flag: Boolean; ExtIds: Cardinal);
  {Registers or unregisters all recorded extensions for given extension ids
  according to Flag. ExtIds is a bitmask representing the extension(s) to
  register}
var
  Ext: string;      // holds each extension
  Flags: Cardinal;  // existing registration flags for extension
begin
  // Enumerate all recorded extensions, registering or unregistering
  fExtMgr.EnumStart(EXTFLAG_RECORDED);
  while fExtMgr.Next(Ext) do
  begin
    Flags := fExtMgr.RegistrationFlags[Ext];
    if Flag then
      Flags := Flags or ExtIds
    else
      Flags := Flags and not ExtIds;
    fExtMgr.RegistrationFlags[Ext] := Flags;
  end;
end;

function TExplExtDlg.RegistrationState(ExtFlag: Cardinal): TCheckBoxState;
  {Returns a code indicating the state of registration of extensions for the
  shell extension represented by the given flag. The return value tells whether
  all recorded extensions are registered all are unregistered or there is a
  mixture of both. The code returned represents the state of a 3-state check
  box, but can be used for other reasons}
var
  Ext: string;        // stores each recorded extension
  RecCount: Integer;  // count of recorded extensions
  RegCount: Integer;  // count of registered extensions
begin
  Assert(Assigned(fExtMgr));
  // Enumerate all recorded extensions, counting recorded & registered exts
  RecCount := 0;
  RegCount := 0;
  fExtMgr.EnumStart(EXTFLAG_RECORDED);
  while fExtMgr.Next(Ext) do
  begin
    Inc(RecCount);
    if fExtMgr.IsRegistered(Ext, ExtFlag) then
      Inc(RegCount);
  end;
  // Return value depending on count
  if RegCount = 0 then
    Result := cbUnchecked // there are no registered extensions
  else if RegCount = RecCount then
    Result := cbChecked   // all extensions are registered
  else
    Result := cbGrayed;   // mix of registered & unregistered extensions
end;

procedure TExplExtDlg.UpdateAdvTabButtons;
  {Updates state of buttons on advance tab according to extensions registered &
  selected list view item}
var
  CtxMenuState,
  PropSheetState: TCheckBoxState;
begin
  Assert(Assigned(fExtMgr));
  // Determine state of Select All and Clear All buttons
  // get state of context menu and property sheet registrations
  CtxMenuState := RegistrationState(EXTFLAG_REGCTXMENU);
  PropSheetState := RegistrationState(EXTFLAG_REGPROPSHEET);
  if CtxMenuState = PropSheetState then
  begin
    // context menu and property sheet states are same: act on state
    case CtxMenuState {= PropSheetState} of
      cbChecked:
      begin
        // all extensions registered: can deselect but not select items
        btnDeselectAll.Enabled := True;
        btnSelectAll.Enabled := False;
      end;
      cbUnchecked:
      begin
        // all extensions unregistered: can select but not deselect items
        btnDeselectAll.Enabled := False;
        btnSelectAll.Enabled := True;
      end;
      cbGrayed:
      begin
        // mix of registered/unregistered exts: can select and deselect
        btnDeselectAll.Enabled := True;
        btnSelectAll.Enabled := True;
      end
    end;
  end
  else
  begin
    // context menu and property sheet states differ: enable all buttons
    btnDeselectAll.Enabled := True;
    btnSelectAll.Enabled := True;
  end;
  // Determine state of Delete button:
  // we can delete items if selected and not default extensions
  btnDelete.Enabled := Assigned(lvExts.Selected)
    and not fExtMgr.IsDefaultExt(GetExtFromLVItem(lvExts.Selected));
end;

procedure TExplExtDlg.UpdateBasicTabCtrls;
  {Updates state of check boxes on basic tab according to state of context menu
  and property sheet check boxes}
begin
  // Can only configure whether shell extensions uses single application
  // instance one of handlers is enabled
  cbSingleAppInst.Enabled := (cbEnableCtxMenu.State <> cbUnchecked)
    or (cbEnablePropSheet.State <> cbUnchecked);
  lblSingleAppInst.Enabled := cbSingleAppInst.Enabled;
end;

procedure TExplExtDlg.UpdateCtxMenuCheck;
  {Updates state of context menu handler check box according to how many of the
  recorded extensions are registered with the handler}
var
  ClickEvent: TNotifyEvent; // stores check box's click event handler
begin
  // Detach click event handler to prevent being fired when State set
  ClickEvent := cbEnableCtxMenu.OnClick;
  try
    cbEnableCtxMenu.OnClick := nil;
    // Set state of check box
    cbEnableCtxMenu.State := RegistrationState(EXTFLAG_REGCTXMENU);
  finally
    // Restore event handler
    cbEnableCtxMenu.OnClick := ClickEvent;
  end;
  // Update controls on basic tab
  UpdateBasicTabCtrls;
end;

procedure TExplExtDlg.UpdateExtensionControls;
  {Updates all controls that depend on supported extensions and those registered
  with shell exetnsion handlers}
begin
  UpdateCtxMenuCheck;     // update context menu handler check box on basic page
  UpdatePropSheetCheck;   // update prop sheet handler check box on basic page
  PopulateListView;       // display current list view on advanced page
  UpdateListViewChecks;   // update which list view items are checked
end;

procedure TExplExtDlg.UpdateListViewChecks;
  {Updates check marks of list view control on "advanced" tab to reflect which
  extensions are registered for which shell extension}
var
  Idx: Integer;     // loops thru all list view items
  Ext: string;      // extension associated with list item
  Item: TListItem;  // list view item being processed
begin
  // Loop thru list view items, checking those representing registered ext
  for Idx := 0 to Pred(lvExts.Items.Count) do
  begin
    Item := lvExts.Items[Idx];
    Ext := GetExtFromLVItem(Item);
    Item.Data := Pointer(fExtMgr.RegistrationFlags[Ext]);
  end;
  // Redraw list view
  lvExts.Invalidate;
  // Update state of buttons on advance tab
  UpdateAdvTabButtons;
end;

procedure TExplExtDlg.UpdatePropSheetCheck;
  {Updates state of property sheet handler check box according to how many of
  the recorded extensions are registered with the handler}
var
  ClickEvent: TNotifyEvent; // stores check box's click event handler
begin
  // Detach click event handler to prevent being fired when State set
  ClickEvent := cbEnablePropSheet.OnClick;
  try
    cbEnablePropSheet.OnClick := nil;
    // Set state of check box
    cbEnablePropSheet.State := RegistrationState(EXTFLAG_REGPROPSHEET);
  finally
    // Restore event handler
    cbEnablePropSheet.OnClick := ClickEvent;
  end;
  // Update controls on basic tab
  UpdateBasicTabCtrls;
end;

procedure TExplExtDlg.UpdateRegistrationFromListView;
  {Updates record of registered extensions from the state of the check boxes in
  the list view that displays recorded extensions}
var
  Idx: Integer;     // loops thru list view items
  Ext: string;      // extension associated with list view item
  Item: TListItem;  // list view item being processed
begin
  // Loop thru list view items, registering/unregistering exts appropriately
  for Idx := 0 to Pred(lvExts.Items.Count) do
  begin
    Item := lvExts.Items[Idx];
    Ext := GetExtFromLVItem(Item);
    fExtMgr.RegistrationFlags[Ext] := GetFlagsFromLVItem(Item);
  end;
  // Update other controls
  UpdateCtxMenuCheck;
  UpdatePropSheetCheck;
  UpdateAdvTabButtons;
end;

procedure TExplExtDlg.WMWinIniChange(var Msg: TWMWinIniChange);
  {Handles WM_WININICHANGE (= WM_SETTINGCHANGE) message by re-configuring
  fields used to display cutom extension list view}
begin
  inherited;
  LVSetupDisplayFields;
end;

end.

