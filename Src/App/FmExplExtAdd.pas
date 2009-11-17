{ ##
  @FILE                     FmExplExtAdd.pas
  @COMMENTS                 Implements a dialog box that enables the user to
                            select or enter an extension to be registered with
                            the shell extension COM object.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 05/06/2004
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
 * The Original Code is FmExplExtAdd.pas.
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


unit FmExplExtAdd;


interface


uses
  // Delphi
  StdCtrls, Controls, ComCtrls, ExtCtrls, Classes,
  // Project
  ULVDisplayMgr, UExtensions, FmGenericOKDlg;


type

  {
  TExplExtAddDlg:
    Dialog box that enables the user to provide an extension to be registered
    with the shell extension COM objects. The dialog displays a list all
    file extensions registered with Windows and permits user to select an
    extension from the list or to enter the extension directly into an edit box.

    Inheritance: TExplExtAddDlg -> TGenericOKDlg -> TGenericDlg
      -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  TExplExtAddDlg = class(TGenericOKDlg)
    lvExts: TListView;
    lblSelectExt: TLabel;
    lblExtText: TLabel;
    edExt: TEdit;
    procedure btnOKClick(Sender: TObject);
    procedure edExtChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvExtsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormShow(Sender: TObject);
  private // properties
    fExtension: string;
  private
    fLVMgr: TLVDisplayMgr;
      {Object that manages display of the list view that displays file
      extensions. This object displays any extensions that are already recorded
      in grey}
    fExtMgr: TGlobalExtensionList;
      {Object that gets and manages the list of extensions registered with
      Windows}
    procedure PopulateListView;
      {Populates list view control with list of all extensions registered with
      Windows}
  public
    procedure MergeRecorded(const ExtHandler: TBaseExtensionHandler);
      {Merges recorded extensions from given handler into list of extensions
      from Windows. This allows us to ensure that extensions created and added
      to owing window during earlier calls to this dialog box, that are not yet
      recorded in registry are displayed in this dialog again}
    property Extension: string read fExtension;
      {The extension entered by the user. Only valid when OK is pressed}
  end;


implementation


uses
  // Delphi
  Graphics;


{$R *.dfm}


{ TExplExtAddDlg }

procedure TExplExtAddDlg.btnOKClick(Sender: TObject);
  {User has accepted extension: update Extension property and close dialog}
var
  Ext: string;  // entered extension
begin
  inherited;
  // Get extension from edit box
  Ext := edExt.Text;
  Assert(Ext <> '');  // OK button disable when this is true
  // Prepend a '.' if one was not entered
  if Ext[1] <> '.' then
    Ext := '.' + Ext;
  // Update property
  fExtension := Ext;
end;

procedure TExplExtAddDlg.edExtChange(Sender: TObject);
  {Text in edit control has changed: highlight it if present in list view and
  update state of OK button according to if text is valid extension}
var
  Ext: string;                  // extension entered in edit box
  LI: TListItem;                // list view item for entered extension
  SelEvent: TLVSelectItemEvent; // store for listview select item event handler
  Flags: Cardinal;              // recording flags assoicated with extension
begin
  inherited;
  // Assume no flags => not recorded
  Flags := 0;
  // Record text in edit box
  Ext := edExt.Text;
  if Ext <> '' then
  begin
    // Select and highlight entered item in list view
    // ensure extension begins with '.'
    if Ext[1] <> '.' then
      Ext := '.' + Ext;
    // find any matching extension in list view
    LI := lvExts.FindCaption(0, Ext, False, True, False);
    // temporarily prevent OnSelectItem from firing and changed edit text
    SelEvent := lvExts.OnSelectItem;
    try
      lvExts.OnSelectItem := nil;
      // select any found item and ensure it is visible
      lvExts.Selected := LI;
      if Assigned(LI) then
      begin
        LI.MakeVisible(False);
        Flags := Cardinal(LI.Data);
      end;
    finally
      // restore selection event handler
      lvExts.OnSelectItem := SelEvent;
    end;
  end;
  // Enable / disable OK button per entry
  btnOK.Enabled := (Ext <> '') and (Ext <> '.') and (Flags = 0);
end;

procedure TExplExtAddDlg.FormCreate(Sender: TObject);
  {Create owned manager objects}
begin
  inherited;
  // Create extension manager object: reads in extensions on creation
  fExtMgr := TGlobalExtensionList.Create;
  // Create & configure list view manager
  fLVMgr := TLVDisplayMgr.Create(lvExts);
  fLVMgr.HighlightSelected := True;
  fLVMgr.DisplayPopups := False;
  fLVMgr.SpecialHighlightColour := clGrayText;
end;

procedure TExplExtAddDlg.FormDestroy(Sender: TObject);
  {Free owned objects}
begin
  inherited;
  fLVMgr.Free;
  fExtMgr.Free;
end;

procedure TExplExtAddDlg.FormShow(Sender: TObject);
  {Displays items in list view after user has chance to update}
begin
  inherited;
  // Copy extensions from extension manager to list view
  PopulateListView;
end;

procedure TExplExtAddDlg.lvExtsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
  {If an item was selected in list view, copy the extension to the edit box}
begin
  if Selected and Assigned(Item) then
    edExt.Text := Item.Caption;
end;

procedure TExplExtAddDlg.MergeRecorded(const ExtHandler: TBaseExtensionHandler);
  {Merges recorded extensions from given handler into list of extensions from
  Windows. This allows us to ensure that extensions created and added to owing
  window during earlier calls to this dialog box, that are not yet recorded in
  registry are displayed in this dialog again}
begin
  fExtMgr.Merge(ExtHandler, EXTFLAG_RECORDED);
end;

procedure TExplExtAddDlg.PopulateListView;
  {Populates list view control with list of all extensions registered with
  Windows}
var
  Ext: string;      // an extension
  Flags: Cardinal;  // flags associated with extension
  LI: TListItem;    // references new list items
begin
  // Enumerate all the extensions registered with Windows, adding to list view
  lvExts.Clear;
  fExtMgr.EnumStart;
  while fExtMgr.Next(Ext, Flags) do
  begin
    // add an item
    LI := lvExts.Items.Add;
    LI.Caption := Ext;                          // extension
    LI.SubItems.Add(fExtMgr.FileTypeDesc(Ext)); // file type description
    // store any registration/recording flags in list item:
    // the list view manager highlights these already-recorded items in grey
    LI.Data := Pointer(Flags);
  end;
end;

end.
