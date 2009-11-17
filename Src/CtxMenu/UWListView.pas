{ ##
  @FILE                     UWListView.pas
  @COMMENTS                 Defines a "widget" class that encapsulates a list
                            view control.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 30/05/2004
      @COMMENTS             Original version.
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
 * The Original Code is UWListView.pas.
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


unit UWListView;


interface


uses
  // Delphi
  Messages, Classes,
  // Project
  UWidget;


type

  {
  TListViewWidget:
    Class that encapsulates a list view control that is parented by a "card"
    object.

    Inheritance: TListViewWidget -> TWidget -> [TObject]
  }
  TListViewWidget = class(TWidget)
  protected
    procedure CreateWindow; override;
      {Creates the list view's window and sets required extended style}
    procedure CreateParams(var Params: TWidgetParams); override;
      {Sets required parameters for creation of list view window}
  public
    procedure SetupColumns(const ColTitles: array of string;
      ColWidths: array of Integer);
      {Sets up the list view to have columns with given titles and widths. NOTE:
      ColTitles and ColWidths arrays must be same size}
    procedure AddItem(const Caption: string; SubItems: array of string);
      {Adds an item to the list view with the given caption and subitems}
    procedure Clear;
      {Clears the list view by deleting all the items}
    function Count: Integer;
      {Returns number of items in list view}
  end;

implementation


uses
  // Delphi
  Windows, CommCtrl;


{ TListViewWidget }

procedure TListViewWidget.AddItem(const Caption: string;
  SubItems: array of string);
  {Adds an item to the list view with the given caption and subitems}
var
  lvi: LV_ITEM;           // structure storing information about the new item
  SubItemIdx: Integer;    // loops through array of subitems
begin
  // Initialise list item structure to add text
  ZeroMemory(@lvi, SizeOf(lvi));
  lvi.mask := LVIF_TEXT;

  // Add a new list item to end of list, with required caption
  lvi.pszText := PChar(Caption);        // store caption
  lvi.cchTextMax := Length(Caption);    // provide caption size
  lvi.iItem := Count;                   // insert at end of list
  lvi.iSubItem := 0;                    // note this is not a subitem
  ListView_InsertItem(Handle, lvi);     // perform insertion

  // Add each sub item new list item just created
  for SubItemIdx := 0 to High(SubItems) do
  begin
    lvi.pszText := PChar(SubItems[SubItemIdx]);     // store sub item text
    lvi.cchTextMax := Length(SubItems[SubItemIdx]); // provide text size
    lvi.iSubItem := Succ(SubItemIdx);               // 1-based index of subitem
    ListView_SetItem(Handle, lvi);                  // set the item
  end;
end;

procedure TListViewWidget.Clear;
  {Clears the list view by deleting all the items}
begin
  ListView_DeleteAllItems(Handle);
end;

function TListViewWidget.Count: Integer;
  {Returns number of items in list view}
begin
  Result := ListView_GetItemCount(Handle);
end;

procedure TListViewWidget.CreateParams(var Params: TWidgetParams);
  {Sets required parameters for creation of list view window}
begin
  inherited;
  Params.Style := Params.Style or WS_TABSTOP or LVS_REPORT or LVS_NOSORTHEADER;
  Params.ExStyle := WS_EX_CLIENTEDGE;
  Params.ClassName := WC_LISTVIEW;
end;

procedure TListViewWidget.CreateWindow;
  {Creates the list view's window and sets required extended style}
begin
  // Create the window in inherited method
  inherited;
  // Set required extended style
  ListView_SetExtendedListViewStyle(
    Handle, LVS_EX_GRIDLINES or LVS_EX_FULLROWSELECT or LVS_EX_FLATSB
  );
end;

procedure TListViewWidget.SetupColumns(const ColTitles: array of string;
  ColWidths: array of Integer);
  {Sets up the list view to have columns with given titles and widths. NOTE:
  ColTitles and ColWidths arrays must be same size}
var
  LVC: LV_COLUMN; // data structure that describes a column
  Col: Integer;   // loops thru all required columns
begin
  // Initialise column data structure
  LVC.mask := LVCF_FMT or LVCF_SUBITEM or LVCF_WIDTH or LVCF_TEXT;
  LVC.fmt := LVCFMT_LEFT;
  // Add each column
  for Col := 0 to High(ColTitles) do
  begin
    // set up column data structure
    LVC.cx := ColWidths[Col];                       // set column width
    LVC.pszText := PChar(ColTitles[Col]);           // set title
    LVC.cchTextMax := Length(ColTitles[Col]) + 1;   // .. and provide length
    LVC.iSubItem := Col;                            // column number (0 based)
    // insert the column
    ListView_InsertColumn(Handle, Col, LVC);
  end;
end;

end.
