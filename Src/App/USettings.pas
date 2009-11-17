{ ##
  @FILE                     USettings.pas
  @COMMENTS                 Defines a class used to save and retrieve the
                            program's user-configurable settings.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 30/03/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 04/08/2002
      @COMMENTS             + Changed registry key to use version 5.0 rather
                              than 4.0.
                            + Added ShowFFIStructure and CtxMenuRunsSingleInst
                              properties and supporting registry settings.
    )
    @REVISION(
      @VERSION              1.2
      @DATE                 24/02/2003
      @COMMENTS             + Moved the registry key constants that are shared
                              with other apps to new URegistry unit.
                            + Renamed CtxMenuRunsSingleInst property registry
                              value to RunSingleInst and moved it to the CtxMenu
                              key.
                            + Added AutoRegExtension property and associated
                              AutoRegExts registry value under CtxMenu key.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 19/10/2004
      @COMMENTS             Major update:
                            + Changed the usage of the class: we now create a
                              globally available singleton Settings object
                              rather than having to create and destroy setting
                              objects objects wherever they are used.
                            + Replaced DescFileFlags and ShowFFIStructure
                              properties with GUIFlags bit mask property and
                              added many other flags to control ther appearance
                              of the program's GUI.
                            + Added new Integer accessor methods
                            + Added StrHighlightColour and TransHighlightColour
                              integer properties under Preferences key to store
                              the colours used to highlight items in the
                              translation combo box and string information list
                              view.
                            + Changed record structure holding settings
                              information to use a union of different types of
                              fields for different default value types.
                            + Changed registry access engine so that indexed
                              values are read from registry only once and cached
                              for future reads.
                            + Added CurrentTabSheetIdx property that records
                              last used tab in a given tabbed dialog box. This
                              property is not indexed and does not cache reads.
                            + Added QueryMissingCOMServer property that records
                              whether to notify user if shell extension COM
                              server not registered at startup.
                            + Renamed CtxMenuRunsSingleInst property as
                              ShellExRunsSingleInst property.
                            + Deleted WdwRegKey class function.
                            + Changed usage of constants from URegistry to deal
                              with renamed constants.
                            + Replaced use of CtxMenu registry key with ExplExt
                              key.
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
 * The Original Code is USettings.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit USettings;


interface


uses
  // Delphi
  Graphics, Forms;


const

  // GUI flags constants: used in GUIFlags property
  VIGUI_FFI_STRUCTINFO        = $00000001;  // default is off
    {Whether to display fixed file info structure information fields}
  VIGUI_FFI_CREATEDATE        = $00000002;  // default is off
    {Whether to display fixed file info creation date field}
  VIGUI_FFI_DESCFILEFLAGS     = $00000004;  // default is on
    {Whether to describe fixed file info file flags}
  VIGUI_TRANS_HIGHLIGHTERR    = $00000008;  // default is on
    {Whether to highlight inconsistent translations in translation combo}
  VIGUI_TRANS_EXPLAINERRTEXT  = $00000010;  // default is on
    {Whether to display text explaining inconsistent translations}
  VIGUI_TRANS_EXPLAINERRBTN   = $00000020;  // default is on
    {Whether to display button leading to detailed explanation of inconsistent
    translations}
  VIGUI_STR_HIGHLIGHTNONSTD   = $00000040;  // default is on
    {Whether to highlight non-standard string file information}
  VIGUI_POPUP_OVERFLOW        = $00000080;  // default is on
    {Whether to display overflow text in pop-up window}

  // Default settings
  cDefGUIFlags = VIGUI_FFI_DESCFILEFLAGS or VIGUI_TRANS_HIGHLIGHTERR
    or VIGUI_TRANS_EXPLAINERRTEXT or VIGUI_TRANS_EXPLAINERRBTN
    or VIGUI_STR_HIGHLIGHTNONSTD or VIGUI_POPUP_OVERFLOW; // GUI flags
  cDefStrHighlightColour = clBlue;  // string highlight colour
  cDefTransHighlightColour = clRed; // translation error highlight colour


type

  {
  TSettings:
    Class that stores and reads program's persistent values in registry.

    Inheritance: TSettings -> [TObject]
  }
  TSettings = class(TObject)
  private // properties
    function GetBoolean(const Idx: Integer): Boolean;
    procedure SetBoolean(const Idx: Integer; const Value: Boolean);
    function GetInteger(const Idx: Integer): Integer;
    procedure SetInteger(const Idx: Integer; const Value: Integer);
    function GetCurrentTabSheetIdx(Form: TForm): Integer;
    procedure SetCurrentTabSheetIdx(Form: TForm; const Value: Integer);
  private
    fValues: array [1..6] of record
      Loaded: Boolean;            // shows if value read from registry or not
      case Integer of
        0: (IntValue: Integer);   // integer value
        1: (BoolValue: Boolean);  // boolean value
      end;
      {Array storing values as they are read from registry}
    function IsLoaded(Idx: Integer): Boolean;
      {Returns true if value at given index has already been loaded, false if
      not}
  public
    property ShowToolbar: Boolean
      index 1 read GetBoolean write SetBoolean;
      {Flag true if toolbar is to be shown and false if it is hidden}
    property ShellExRunsSingleInst: Boolean
      index 2 read GetBoolean write SetBoolean;
      {When true the shell extensions always runs single instances of the
      application, when false each time the program is run from a shell
      extension a new instance of application is run}
    property AutoRegExtension: Boolean
      index 3 read GetBoolean write SetBoolean;
      {When true program prompts user to register any previously unrecorded
      extension with shell extension handlers. Ignored if shell extensions
      handlers are disabled}
    property StrHighlightColour: Integer
      index 4 read GetInteger write SetInteger;
      {Colour used to highlight non-standard string info items}
    property TransHighlightColour: Integer
      index 5 read GetInteger write SetInteger;
      {Colour used to highlight inconsistent translations}
    property GUIFlags: Integer
      index 6 read GetInteger write SetInteger;
      {Bitmask storing various display options per VIGUI_ constants}
    property CurrentTabSheetIdx[Form: TForm]: Integer
      read GetCurrentTabSheetIdx write SetCurrentTabSheetIdx;
      {The index of the last used tabsheet of the given form}
  end;


function Settings: TSettings;
  {Returns singleton Settings object}


implementation


uses
  // Delphi
  SysUtils, Registry,
  // Project
  URegistry;


const

  // Value names and default values for indexed properties
  cTable: array[1..6] of record
    // Table of registry sub keys, value names and default values for properties
    SubKey, ValName: string;
    case Integer of
      0: (DefBool: Boolean;);
      1: (DefInt: Integer;);
  end =
  (
    (SubKey: cPrefRegKey; ValName: 'ShowToolbar'; DefBool: True),          //#01
    (SubKey: cExplExtKey; ValName: 'RunSingleInst'; DefBool: True),        //#02
    (SubKey: cExplExtKey; ValName: 'AutoRegExts'; DefBool: True),          //#03
    (SubKey: cPrefRegKey; ValName: 'StrHighlightColour';
      DefInt: cDefStrHighlightColour),                                     //#04
    (SubKey: cPrefRegKey; ValName: 'TransHighlightColour';
      DefInt: cDefTransHighlightColour),                                   //#05
    (SubKey: cPrefRegKey; ValName: 'GUIFlags'; DefInt: cDefGUIFlags)       //#06
  );


{ TSettings }

function TSettings.GetBoolean(const Idx: Integer): Boolean;
  {Read accessor for Boolean properties: reads value from registry when first
  accessed and returns recorded value thereafter}
var
  Reg: TRegistry; // registry object
begin
  if IsLoaded(Idx) then
    // Value has been loaded: return from values array
    Result := fValues[Idx].BoolValue
  else
  begin
    // Set default result in case we can't read from registy
    Result := cTable[Idx].DefBool;
    Reg := TRegistry.Create;
    try
      // Attempt to get required value from appropriate sub-key in registry
      if Reg.OpenKey(cTable[Idx].SubKey, True)
        and Reg.ValueExists(cTable[Idx].ValName) then
        Result := Reg.ReadBool(cTable[Idx].ValName);
    finally
      Reg.Free;
    end;
    // Record read value in values array
    fValues[Idx].BoolValue := Result;
    fValues[Idx].Loaded := True;
  end;
end;

function TSettings.GetCurrentTabSheetIdx(Form: TForm): Integer;
  {Read accessor for CurrentTabSheetIdx property: access value directly from
  registry, returning a default value of 0 if value can't be read}
var
  Reg: TRegistry; // registry object
begin
  // Set default result in case we can't read from registy
  Result := 0;
  Reg := TRegistry.Create;
  try
    // Attempt to get required value from sub-key based on form name in registry
    if Reg.OpenKey(URegistry.GUIWindowKey(Form.Name), True)
      and Reg.ValueExists('TabSheetIdx') then
      Result := Reg.ReadInteger('TabSheetIdx');
  finally
    Reg.Free;
  end;
end;

function TSettings.GetInteger(const Idx: Integer): Integer;
  {Read accessor for integer properties: reads value from registry when first
  accessed and returns recorded value thereafter}
var
  Reg: TRegistry; // registry object
begin
  if IsLoaded(Idx) then
    // Value has been loaded: return from values array
    Result := fValues[Idx].IntValue
  else
  begin
    // Set default result in case we can't read from registy
    Result := cTable[Idx].DefInt;
    Reg := TRegistry.Create;
    try
      // Attempt to get required value from appropriate sub-key in registry
      if Reg.OpenKey(cTable[Idx].SubKey, True)
        and Reg.ValueExists(cTable[Idx].ValName) then
        Result := Reg.ReadInteger(cTable[Idx].ValName);
    finally
      Reg.Free;
    end;
    // Record read value in values array
    fValues[Idx].IntValue := Result;
    fValues[Idx].Loaded := True;
  end;
end;

function TSettings.IsLoaded(Idx: Integer): Boolean;
  {Returns true if value at given index has already been loaded, false if not}
begin
  Result := fValues[Idx].Loaded;
end;

procedure TSettings.SetBoolean(const Idx: Integer; const Value: Boolean);
  {Write accessor for Boolean properties: writes value to registry and records
  value locally for later read access}
var
  Reg: TRegistry;   // registry object
begin
  // Only update value if we don't yet know it or we know it and it's different
  if not fValues[Idx].Loaded or (fValues[Idx].BoolValue <> Value) then
  begin
    Reg := TRegistry.Create;
    try
      // Open required key and write value with appropriate name
      Reg.OpenKey(cTable[Idx].SubKey, True);
      Reg.WriteBool(cTable[Idx].ValName, Value);
    finally
      Reg.Free;
    end;
    // Record value in values array
    fValues[Idx].BoolValue := Value;
    fValues[Idx].Loaded := True;
  end;
end;

procedure TSettings.SetCurrentTabSheetIdx(Form: TForm; const Value: Integer);
  {Write accessor for CurrentTabSheetIdx property: writes value directly to
  registry}
var
  Reg: TRegistry;   // registry object
begin
  Reg := TRegistry.Create;
  try
    // Open key based of form name and write value
    Reg.OpenKey(URegistry.GUIWindowKey(Form.Name), True);
    Reg.WriteInteger('TabSheetIdx', Value);
  finally
    Reg.Free;
  end;
end;

procedure TSettings.SetInteger(const Idx, Value: Integer);
  {Write accessor for integer properties: writes value to registry and records
  value locally for later read access}
var
  Reg: TRegistry;   // registry object
begin
  // Only update value if we don't yet know it or we know it and it's different
  if not fValues[Idx].Loaded or (fValues[Idx].IntValue <> Value) then
  begin
    Reg := TRegistry.Create;
    try
      // Open required key and write value with appropriate name
      Reg.OpenKey(cTable[Idx].SubKey, True);
      Reg.WriteInteger(cTable[Idx].ValName, Value);
    finally
      Reg.Free;
    end;
    // Record value in values array
    fValues[Idx].IntValue := Value;
    fValues[Idx].Loaded := True;
  end;
end;


var
  // Private Settings singleton object
  pvtSettings: TSettings;

function Settings: TSettings;
  {Returns singleton Settings object}
begin
  // If settings object is not yet created create it
  if not Assigned(pvtSettings) then
    pvtSettings := TSettings.Create;
  Result := pvtSettings;
end;


initialization


finalization

// Free the global settings object
FreeAndNil(pvtSettings);

end.
