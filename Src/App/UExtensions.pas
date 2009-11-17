{ ##
  @FILE                     UExtensions.pas
  @COMMENTS                 Defines some classes that are used to edit and
                            manipulate files extensions that can be recorded and
                            regsitered with the shell extension COM server.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             Requires the FileVerCM.dll COM server.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 19/10/2004
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 28/08/2007
      @COMMENTS             Refactoring. Added a helper function to test for
                            presence of a flag in a bitmask to replace numerous
                            explicit bitmask tests.
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
 * The Original Code is UExtensions.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UExtensions;


interface


uses
  // Project
  IntfFileVerShellExt, UDictionaries;


const
  // Bitmask flags that give status of a file extension
  EXTFLAG_UNRECORDED    = $00000000;  // ext not recorded
  EXTFLAG_RECORDED      = $00000001;  // ext recorded
  EXTFLAG_REGCTXMENU    = $00000002;  // ext registered with ctx menu handler
  EXTFLAG_REGPROPSHEET  = $00000004;  // ext registered with prop sheet handler
  // NOTE: registered exts must also be recorded

type

  {
  TBaseExtensionHandler:
    Base class for extension manager objects: provides core functionality and
    maintains data structures.
  }
  TBaseExtensionHandler = class(TObject)
  private
    fExtDict: TBitMaskDictionary;
      {Value of ExtDict property}
    fExtensionManager: IUnknown;
      {Value of ExtensionManager property}
    fEnumIdx: Integer;
      {Idx of last item in extension dictionary returned in current enumeration}
    fEnumFlags: Cardinal;
      {Flags used to filter current enumeration of extension dictionary}
  protected
    property ExtDict: TBitMaskDictionary read fExtDict;
      {Dictionary object mapping extensions onto a bitmask of flags giving
      status of extension}
    property ExtensionManager: IUnknown read fExtensionManager;
      {File extension recorder and registration object used to record file
      extensions with the program, to register / unregister shell extensions for
      specific file extensions and to provide informaiton about a file
      extension. The object suppports various interfaces to provide the various
      functions}
  public
    constructor Create;
      {Class constructor. Sets up object}
    destructor Destroy; override;
      {Class destructor. Tears down object}
    procedure EnumStart(Flags: Cardinal = 0);
      {Prepare to enumerate all extensions in dictionary that match the given
      flags}
    procedure Merge(const ExtHandler: TBaseExtensionHandler;
      const EnumFlags: Cardinal = 0);
      {Merges all extensions matching given flags(s) that exist in given
      extension handler object into this extension handler}
    function Next(out Ext: string): Boolean; overload;
      {Returns the next extension in current enumeration via the Ext parameter.
      Returns True if an extension is passed back or False if beyond end of
      list}
    function Next(out Ext: string; out Flags: Cardinal): Boolean; overload;
      {Returns the next extension in current enumeration via the Ext parameter
      and its status flags in the Flags parameter. Returns True if an extension
      is passed back or False if beyond end of list}
    function FileTypeDesc(const Ext: string): string;
      {Returns a description of the file type of the given extension}
  end;


  {
  TGlobalExtensionList:
    Class that gathers details of all extensions known to Windows. Enables user
    to enumerate the extensions, to get descriptions of file types and to get
    shell extension handler related information about extensions.
  }
  TGlobalExtensionList = class(TBaseExtensionHandler)
  public
    constructor Create;
      {Class constuctor. Sets up object. Gathers details of all file extensions
      known to Windows}
  end;


  {
  TRecordedExtensionMgr:
    Class that enables the extensions associated with the shell extension
    handlers to be enumerated, interogated and edited. Changes can be abandoned
    or the shell extension register can be updated with the changes.
  }
  TRecordedExtensionMgr = class(TBaseExtensionHandler)
  private
    function GetIsRecorded(const Ext: string): Boolean;
      {Read accessor for the IsRecorded[] property: tests for presence of the
      "recorded" flag in the extension's bitmask}
    procedure SetIsRecorded(const Ext: string; const Value: Boolean);
      {Write accessor for IsRecorded[] property. Includes or excludes "recorded"
      flag in the extension bitmask}
    function GetRegistrationFlags(const Ext: string): Cardinal;
      {Read accessor for RegistrationFlags[] property: raises exception if file
      extension is not recorded}
    procedure SetRegistrationFlags(const Ext: string; const Value: Cardinal);
      {Write accessor for RegsitrationFlags[] property: raises exception if file
      extension is not recorded}
  public
    constructor Create;
      {Class constructor. Sets up object. Builds a list of extensions currently
      recorded with shell extension handlers, recording the status of the
      extensions}
    procedure CommitChanges;
      {Stores the changes made to file extensions registered with shell
      extensions}
    function IsDefaultExt(const Ext: string): Boolean;
      {Returns true if the given extension is a "Default" extension: i.e. an
      extension compulsorily recorded with the shell extension handlers that
      can't be deleted}
    property IsRecorded[const Ext: string]: Boolean
      read GetIsRecorded write SetIsRecorded;
      {This property is true if the extension recorded with the application. The
      extension's status can be altered by writing to this property}
    property RegistrationFlags[const Ext: string]: Cardinal
      read GetRegistrationFlags write SetRegistrationFlags;
      {RegistrationFlags tells if an extension is registered with the context
      menu handler, property sheet handler or both. Write the property to change
      the registration status of an extension. It is an error to read or write
      the property for an unrecorded extension: i.e. when IsRecorded is False}
    function IsRegistered(const Ext: string; const ExtFlag: Cardinal): Boolean;
      {Returns true if the shell extension represented by ExtFlag is registered
      for the given extension or false if not. Raises exception if extension not
      recorded}
  end;


implementation


uses
  // Delphi
  SysUtils, Windows, Registry, ComObj;


resourcestring
  // Descriptions
  sDefFileTypeDesc = '%s File';
  // Error messages
  sCantCheckReg = 'Can''t check registration of unrecorded extension %s';
  sCantRegOrUnreg = 'Can''t register/unregister an unrecorded extension %s';


{ Helper routines }

procedure NoteSystemExts(const ExtDict: TBitMaskDictionary);
  {Adds every file extension registered with windows to extension list. Does not
  note if file extensions are recorded or registered with shell extension
  handlers}
var
  Info: TRegKeyInfo;    // information about registry key
  Idx: Integer;         // loops through all extension registry subkeys
  ExtBuf, Ext: string;  // storage for each extension in registry
  Len: Cardinal;        // length of an extension read from registry
begin
  // Open registry and access HKCR root key
  with TRegistry.Create do
    try
      RootKey := HKEY_CLASSES_ROOT;
      if OpenKeyReadOnly('') and GetKeyInfo(Info) then
      begin
        // Root of HKCR stores list of extensions: read each one
        SetLength(ExtBuf, Info.MaxSubKeyLen + 1);
        for Idx := 0 to Pred(Info.NumSubKeys) do
        begin
          Len := Info.MaxSubKeyLen + 1;
          RegEnumKeyEx(CurrentKey, Idx, PChar(ExtBuf), Len, nil, nil, nil, nil);
          SetString(Ext, PChar(ExtBuf), Len);
          if (Ext <> '') and (Ext[1] = '.') then
            // we only record keys beginning with '.': these are extensions
            ExtDict.Values[Ext] := EXTFLAG_UNRECORDED;
        end;
      end;
    finally
      Free;
    end;
end;

procedure NoteRecordedExts(const ExtDict: TBitMaskDictionary;
  const ExtMgr: IUnknown);
  {Records each extension in a dictionary that is recorded with application. The
  list's flags are set to show if extension is recorded and which shell
  extension it is recorded with}
var
  Idx: Integer;                     // loops through recorded extensions
  Ext: WideString;                  // an extension
  Flags: Cardinal;                  // flags associated with an extension
  Recorder: IFileVerExtRecorder;    // recorder interface to ext mgr object
  Registrar: IFileVerExtRegistrar;  // registrar interface to ext mgr object
begin
  // Get required interfaces onto extension manager object
  Recorder := ExtMgr as IFileVerExtRecorder;
  Registrar := ExtMgr as IFileVerExtRegistrar;
  // Loop thru each of recorded extensions
  for Idx := 0 to Pred(Recorder.RecordedExtCount) do
  begin
    // Get extension
    OleCheck(Recorder.RecordedExts(Idx, Ext));
    // Set flags
    // note that extension is recorded (that's how we got it!)
    Flags := EXTFLAG_RECORDED;
    if Registrar.IsExtRegistered(Ext, CLSID_FileVerCM) = S_OK then
      // extension is also registered with context menu handler
      Flags := Flags or EXTFLAG_REGCTXMENU;
    if Registrar.IsExtRegistered(Ext, CLSID_FileVerPS) = S_OK then
      // extension is also registered with property sheet handler
      Flags := Flags or EXTFLAG_REGPROPSHEET;
    // Store extension and flags in dictionary
    ExtDict.Values[Ext] := Flags;
  end;
end;

function BitmaskHasFlag(const Bitmask, Flag: Cardinal): Boolean;
  {Checks if a given bitmask contains a specified flag}
begin
  Result := Bitmask and Flag = Flag;
end;


{ TBaseExtensionHandler }

constructor TBaseExtensionHandler.Create;
  {Class constructor. Sets up object}
begin
  inherited Create;
  fExtensionManager := CreateCOMObject(CLSID_FileVerReg);
  fExtDict := TBitMaskDictionary.Create;
end;

destructor TBaseExtensionHandler.Destroy;
  {Class destructor. Tears down object}
begin
  fExtDict.Free;
  fExtensionManager := nil;
  inherited;
end;

procedure TBaseExtensionHandler.EnumStart(Flags: Cardinal);
  {Prepare to enumerate all extensions in dictionary that match the given flags}
begin
  fEnumIdx := -1;
  fEnumFlags := Flags;
end;

function TBaseExtensionHandler.FileTypeDesc(const Ext: string): string;
  {Returns a description of the file type of the given extension}
var
  Desc: WideString; // description of file type
begin
  // We use info interface on extension manager object to get the info
  OleCheck((ExtensionManager as IFileVerExtInfo).FileDescEx(Ext, Desc));
  Result := Desc;
end;

procedure TBaseExtensionHandler.Merge(const ExtHandler: TBaseExtensionHandler;
  const EnumFlags: Cardinal = 0);
  {Merges all extensions matching given flags(s) that exist in given extension
  handler object into this extension handler}
var
  Ext: string;      // an extension
  Flags: Cardinal;  // flags associated with extension
begin
  // Enumerate all items in source handler that match given flags, adding to
  // this handler
  ExtHandler.EnumStart(EnumFlags);
  while ExtHandler.Next(Ext, Flags) do
    ExtDict.Values[Ext] := Flags;
end;

function TBaseExtensionHandler.Next(out Ext: string): Boolean;
  {Returns the next extension in current enumeration via the Ext parameter.
  Returns True if an extension is passed back or False if beyond end of list}
var
  Dummy: Cardinal;  // unused flags value
begin
  Result := Next(Ext, Dummy);
end;

function TBaseExtensionHandler.Next(out Ext: string;
  out Flags: Cardinal): Boolean;
  {Returns the next extension in current enumeration via the Ext parameter and
  its status flags in the Flags parameter. Returns True if an extension is
  passed back or False if beyond end of list}
begin
  // Move onto to next entry in dictionary that matches enumeration flags
  repeat
    Inc(fEnumIdx);
  until (fEnumIdx >= ExtDict.Count)
    or BitmaskHasFlag(ExtDict.ValuesByIdx[fEnumIdx], fEnumFlags);
  // Check if we found another entry or went off end of list
  Result := fEnumIdx < ExtDict.Count;
  if Result then
  begin
    // we have entry: return extension and flags
    Ext := ExtDict.Names[fEnumIdx];
    Flags := ExtDict.ValuesByIdx[fEnumIdx];
  end;
end;


{ TGlobalExtensionList }

constructor TGlobalExtensionList.Create;
  {Class constuctor. Sets up object. Gathers details of all file extensions
  known to Windows}
begin
  inherited Create;
  NoteSystemExts(ExtDict);
end;


{ TRecordedExtensionMgr }

procedure TRecordedExtensionMgr.CommitChanges;
  {Stores the changes made to file extensions registered with shell extensions}
var
  Ext: string;                      // a file extension
  Recorder: IFileVerExtRecorder;    // records file exts known to application
  Registrar: IFileVerExtRegistrar;  // registers file exts with shell handler
begin
  // Get IFileVerExtRecorder & IFileVerExtRegistrar interfaces of extension mgr
  Recorder := ExtensionManager as IFileVerExtRecorder;
  Registrar := ExtensionManager as IFileVerExtRegistrar;
  // Enumerate all extensions stored in object
  EnumStart;
  while Next(Ext) do
  begin
    if IsRecorded[Ext] then
    begin
      // Extension should be recorded
      Recorder.RecordExt(Ext, False);
      // Register / unregister as required
      // update context menu handler registration
      if BitmaskHasFlag(RegistrationFlags[Ext], EXTFLAG_REGCTXMENU) then
        Registrar.RegisterExt(Ext, CLSID_FileVerCM)
      else
        Registrar.UnregisterExt(Ext, CLSID_FileVerCM);
      // update property sheet handler extension
      if BitmaskHasFlag(RegistrationFlags[Ext], EXTFLAG_REGPROPSHEET) then
        Registrar.RegisterExt(Ext, CLSID_FileVerPS)
      else
        Registrar.UnregisterExt(Ext, CLSID_FileVerPS);
    end
    else
    begin
      // Unrecord extension: this unregisters if needed
      Recorder.UnrecordExt(Ext);
    end;
  end;
end;

constructor TRecordedExtensionMgr.Create;
  {Class constructor. Sets up object. Builds a list of extensions currently
  recorded with shell extension handlers, recording the status of the
  extensions}
begin
  inherited Create;
  // Build list of all exts recorded by shell extension handlers
  NoteRecordedExts(ExtDict, ExtensionManager);
end;

function TRecordedExtensionMgr.GetIsRecorded(const Ext: string): Boolean;
  {Read accessor for the IsRecorded[] property: tests for presence of the
  "recorded" flag in the extension's bitmask}
begin
  Result := BitmaskHasFlag(ExtDict.Values[Ext], EXTFLAG_RECORDED);
end;

function TRecordedExtensionMgr.GetRegistrationFlags(
  const Ext: string): Cardinal;
  {Read accessor for RegistrationFlags[] property: raises exception if file
  extension is not recorded}
begin
  // It is an error if extension is not recorded
  Result := ExtDict.Values[Ext];
  if not BitmaskHasFlag(Result, EXTFLAG_RECORDED) then
    raise Exception.CreateFmt(sCantCheckReg, [Ext]);
end;

function TRecordedExtensionMgr.IsDefaultExt(const Ext: string): Boolean;
  {Returns true if the given extension is a "Default" extension: i.e. an
  extension compulsorily recorded with the shell extension handlers that can't
  be deleted}
begin
  // Get information from shell extension recorder object
  Result := (ExtensionManager as IFileVerExtRecorder).IsDefaultExt(Ext) = S_OK;
end;

function TRecordedExtensionMgr.IsRegistered(const Ext: string;
  const ExtFlag: Cardinal): Boolean;
  {Returns true if the shell extension represented by ExtFlag is registered for
  the given extension or false if not. Raises exception if extension not
  recorded}
var
  Flags: Cardinal;  // flags for given extension
begin
  Flags := RegistrationFlags[Ext];  // raises exception if not recorded
  Result := BitmaskHasFlag(Flags, ExtFlag);
end;

procedure TRecordedExtensionMgr.SetIsRecorded(const Ext: string;
  const Value: Boolean);
  {Write accessor for IsRecorded[] property. Includes or excludes "recorded"
  flag in the extension bitmask}
var
  Flags: Cardinal;  // extension flags bitmask
begin
  // Update bitmask as required
  Flags := ExtDict.Values[Ext];
  if Value then
    Flags := Flags or EXTFLAG_RECORDED
  else
    // unrecording also unregisters
    Flags := EXTFLAG_UNRECORDED;
  ExtDict.Values[Ext] := Flags;
end;

procedure TRecordedExtensionMgr.SetRegistrationFlags(const Ext: string;
  const Value: Cardinal);
  {Write accessor for RegsitrationFlags[] property: raises exception if file
  extension is not recorded}
var
  Flags: Cardinal;  // existing flags for file extension
begin
  // Get and check existing flags to ensure recorded
  Flags := ExtDict.Values[Ext];
  if not BitmaskHasFlag(Flags, EXTFLAG_RECORDED) then
    raise Exception.CreateFmt(sCantRegOrUnreg, [Ext]);
  // Record new flags, ensuring recorded flag is included
  ExtDict.Values[Ext] := Value or EXTFLAG_RECORDED;
end;

end.

