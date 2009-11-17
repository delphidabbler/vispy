{ ##
  @FILE                     UPSView.pas
  @COMMENTS                 Defines a class that manages a view of version
                            information displayed in the property sheet
                            extension tab sheet.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 23/05/2004
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
 * The Original Code is UPSView.pas.
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


unit UPSView;


interface


uses
  // Project
  IntfVerInfoReader, UVIPropSheetCard;


type

  {
  TPSView:
    Class that manages a view of version information as displayed in the
    property sheet extension tab sheet. The class uses the widgets on a
    TVIPropSheetCard object.

    Inheritance: TPSView -> [TObject]
  }
  TPSView = class(TObject)
  private // properties
    fVerInfo: IVerInfoReader;
  private
    fPSC: TVIPropSheetCard;
      {Property sheet "card" that hosts widgets used to control and display
      version information}
    procedure CBChange(Sender: TObject);
      {OnChange event handler for card's translation combo box}
    procedure ClearTranslations;
      {Clear the translation combo box & reset translation label}
    procedure ClearStringTable;
      {Clear the string table display}
    procedure DisplayFFI;
      {Display the fixed file information for the current version information}
    procedure DisplayTranslations;
      {Display all translations: assume combo box is empty when calling}
    procedure DisplayTranslation(Idx: Integer);
      {Display the translation at the given index in the version information}
    procedure DisplayStringTable(Idx: Integer);
      {Display the string table at the given index in the version information}
  public
    constructor Create(PSC: TVIPropSheetCard);
      {Class constructor: creates view instance for given "card"}
    procedure Display;
      {Displays default view of version information}
    property VerInfo: IVerInfoReader read fVerInfo write fVerInfo;
      {Object that holds details of version information that is to be displayed}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows,
  // Project
  UDisplayFmt, UVerUtils;


resourcestring
  // Fixed file info labels
  sFileVersion        = 'File Version';
  sProductVersion     = 'Product Version';
  sFileFlagsMask      = 'File Flags Mask';
  sFileFlags          = 'File Flags';
  sFileOS             = 'Operating System';
  sFileType           = 'File Type';
  sFileSubType        = 'File Sub-type';
  // Other FFI output
  sNA                 = 'N/a';


{ TPSView }

procedure TPSView.CBChange(Sender: TObject);
  {OnChange event handler for card's translation combo box}
begin
  // Display translation and string table at selected index
  DisplayTranslation(fPSC.TransCombo.ItemIndex);
  DisplayStringTable(fPSC.TransCombo.ItemIndex);
end;

procedure TPSView.ClearStringTable;
  {Clear the string table display}
begin
  // clear the string table list view
  fPSC.StrInfoListView.Clear;
end;

procedure TPSView.ClearTranslations;
  {Clear the translation combo box & reset translation label}
begin
  fPSC.TransCombo.Clear;
  fPSC.TransLabel.Caption := 'No translations';
  fPSC.TransCombo.Enabled := False;
end;

constructor TPSView.Create(PSC: TVIPropSheetCard);
  {Class constructor: creates view instance for given "card"}
begin
  inherited Create;
  // Record reference to "card" object
  fPSC := PSC;
  // Set card's on change event handler
  fPSC.TransCombo.OnChange := CBChange;
end;

procedure TPSView.Display;
  {Displays default view of version information}
begin
  // Display fixed file info
  DisplayFFI;
  if fVerInfo.VarInfoCount > 0 then
  begin
    // We have variable file info: display it
    DisplayTranslations;    // display all translations
    DisplayTranslation(0);  // display 1st translation
    DisplayStringTable(0);  // display string table assoc with 1st translation
  end
  else
  begin
    // We have no variable file info: clear relevant part of display
    ClearTranslations;
    ClearStringTable;
  end;
end;

procedure TPSView.DisplayFFI;
  {Display the fixed file information for the current version information}

  // ---------------------------------------------------------------------------
  procedure AddItem(const Name, Value: string);
    {Adds name/value pair to fixed file info list view}
  begin
    fPSC.FFIListView.AddItem(Name, [Value]);
  end;
  // ---------------------------------------------------------------------------

var
  FFI: TVSFixedFileInfo;  // records fixed file info we are to display
begin
  // Record fixed file info
  FFI := fVerInfo.FixedFileInfo;
  // File version number
  AddItem(
    sFileVersion,
    UDisplayFmt.VerFmt(FFI.dwFileVersionMS, FFI.dwFileVersionLS)
  );
  // Product version number
  AddItem(
    sProductVersion,
    UDisplayFmt.VerFmt(FFI.dwProductVersionMS, FFI.dwProductVersionLS)
  );
  // File flags mask: as description
  AddItem(
    sFileFlagsMask, UVerUtils.FileFlagsDesc(FFI.dwFileFlagsMask, dtDesc)
  );
  // File flags: as description
  AddItem(sFileFlags, UVerUtils.FileFlagsDesc(FFI.dwFileFlags, dtDesc));
  // FileOS code: display a description
  AddItem(sFileOS, UVerUtils.FileOSDesc(FFI.dwFileOS, dtDesc));
  // File type: display a description
  AddItem(sFileType, UVerUtils.FileTypeDesc(FFI.dwFileType, dtDesc));
  // File sub type: display a description
  if UVerUtils.FileTypeHasSubType(FFI.dwFileType) then
    // sub-types are valid for current file type: display desc
    AddItem(
      sFileSubType,
      UVerUtils.FileSubTypeDesc(FFI.dwFileType, FFI.dwFileSubType, dtDesc)
    )
  else
    // sub-types not valid for this file type
    AddItem(sFileSubType, sNA);
end;

procedure TPSView.DisplayStringTable(Idx: Integer);
  {Display the string table at the given index in the version information}
var
  StrIdx: Integer;            // index into string table
  VarInfo: IVerInfoVarReader; // object used to access variable ver info
begin
  // Clear string list view
  ClearStringTable;
  // Write string name/value pairs to list view
  VarInfo := fVerInfo.VarInfo(Idx);
  for StrIdx := 0 to Pred(VarInfo.StringCount) do
    fPSC.StrInfoListView.AddItem(
      VarInfo.StringName(StrIdx), [VarInfo.StringValue(StrIdx)]
    );
end;

procedure TPSView.DisplayTranslation(Idx: Integer);
  {Display the translation at the given index in the version information}
begin
  // Select required entry in combo box
  fPSC.TransCombo.ItemIndex := Idx;
  // Update translation id string
  fPSC.TransLabel.Caption :=
    Format('Translation: %d of %d', [Succ(Idx), fVerInfo.VarInfoCount]);
end;

procedure TPSView.DisplayTranslations;
  {Display all translations: assume combo box is empty when calling}
var
  TransIdx: Integer;            // index into translations
  VarInfo: IVerInfoVarReader;   // object used to access variable ver info
begin
  if fVerInfo.VarInfoCount > 0 then
  begin
    // We have some translations: populate the translation combo box
    // enable combo box
    fPSC.TransCombo.Enabled := True;
    // add details of all translations to combo
    for TransIdx := 0 to Pred(fVerInfo.VarInfoCount) do
    begin
      VarInfo := fVerInfo.VarInfo(TransIdx);
      fPSC.TransCombo.Add(
        Format(
          '%s - %s',
          [UVerUtils.LanguageDesc(VarInfo.LanguageID),
            UVerUtils.CharSetDesc(VarInfo.CharSet)]
        )
      );
    end;
  end
  else
    // No translations: disable combo box
    fPSC.TransCombo.Enabled := False;
end;

end.
