{ ##
  @FILE                     UShellExtReg.pas
  @COMMENTS                 Defines routines that register/unregister the COM
                            server.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @OTHER_NAMES              Original name was UFileVerCMReg.pas. Renamed as
                            UShellExtReg.pas at v3.0.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 04/08/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 24/02/2003
      @COMMENTS             Major update:
                            + Extensions supported by context menu handler can
                              now be user defined.
                            + Added new registrar COM object and helper routines
                              used to manage the extensions supported by context
                              menu handler. New registry constants for
                              registering new COM object.
                            + Moved some registry settings that are used by this
                              DLL and other applications to a new common unit.
                            + Changed prog id of context menu handler to show
                              version 2.
                            + Now automatically registers just three extensions
                              for context menu handler, but provides details of
                              others that user can register.
                            + Removed code to find location FileVer.exe from
                              registry to UFileVerCMHandler unit.
                            + Created new static class to be used to register/
                              unregister COM objects and removed previous
                              simple procedures.
                            + Fixed problem where unregister routine was failing
                              to delete references to removed file type registry
                              entries.
    )
    @REVISION(
      @VERSION              3.0
      @DATE                 05/06/2004
      @COMMENTS             Major update:
                            + Added support for registering Property Sheet shell
                              extension COM server.
                            + Extended registration functions to register either
                              property sheet or contect menu shell extensions
                              for given file extensions and added approval
                              registry entry when running on NT.
                            + Added support for new IFileVerExtRecorder,
                              IFileVerExtRegistrar and IFileVerExtInfo
                              interfaces to TFileRegistrar.
                            + Left old IFileVerCMRegistrar methods in
                              TFileRegistrar but re-implemented in terms of
                              new multi-extension registration code.
                            + Renamed many constants to do with registration.
                            + Changed to use renamed units.
                            + Fixed problem where unregister routine was failing
                              to delete references to removed file type registry
                              entries.
                            + Replaced some string literals with constants from
                              globals unit.
    )
    @REVISION(
      @VERSION              3.1
      @DATE                 28/08/2007
      @COMMENTS             Changed so that code that checks if shell extension
                            COM server is registered is no longer case
                            sensitive.
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
 * The Original Code is UShellExtReg.pas.
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


unit UShellExtReg;


interface


uses
  // Project
  UBaseCOMObj, IntfFileVerShellExt;


type

  {
  TServerRegistrar:
    Static class used to register, unregister and query registration of COM
    server and its supported COM objects.

    Inheritance: TServerRegistrar -> [TObject]
  }
  TServerRegistrar = class(TObject)
  public
    class procedure RegisterServer;
      {Registers the COM servers in the DLL}
    class procedure UnregisterServer;
      {Unregisters the DLL's COM servers}
    class function IsServerRegistered: HResult;
      {Returns S_OK if server is registered, S_FALSE if not (or partially
      registered or E_FAIL on error}
  end;

  {
  TFileRegistrar:
    Implements COM server object that manages the registration of file
    extensions with supported shell extension handlers. It also records a list
    of known file types that can contain version information. Dedicated support
    for registering Context Menu handler code is included for backward
    compatibility.

    Inheritance: TFileRegistrar -> TBaseCOMObj -> [TInterfacedObject]
  }
  TFileRegistrar = class(TBaseCOMObj,
    IFileVerExtInfo, IFileVerExtRecorder, IFileVerExtRegistrar,
    IFileVerCMRegistrar, IUnknown)
  private
    function InternalIsExtRegistered(const FileName, CLSIDStr,
      HandlerKey: string): HResult;
      {Returns S_OK if a shell extension object with key CLSID string is
      registered under the extension handler for the given extension and handler
      key or S_FALSE if not. Returns E_FAIL if any error is encountered}
    function InternalRegisterExt(const FileName, CLSIDStr,
      HandlerKey: string): HResult;
      {Registers the extension of the given file name with the explorer
      extension with given handler key and CLSID string. Returns S_OK if the
      extension was successfully registered and E_FAIL if there was a problem}
    function InternalUnRegisterExt(const FileName, CLSIDStr,
      HandlerKey: string): HResult;
      {Unregisters the explorer extension of given CLSID string for files with
      given extension registered under given handler key. If extension was
      unregistered then S_OK is returned. If the extension was not registered in
      the first place then S_FALSE is returned. E_FAIL is returned if any error
      occurs}
  protected
    { IFileVerCMRegistrar }
    function IFileVerCMRegistrar.IsExtRegistered = IsCMExtRegistered;
    function IsCMExtRegistered(const FileName: WideString): HResult; stdcall;
      {Returns S_OK if extension of given file is registered with context menu
      handler and S_FALSE if not. Returns E_FAIL if any error was encountered}
    function IFileVerCMRegistrar.RegisterExt = RegisterCMExt;
    function RegisterCMExt(const FileName: WideString): HResult; stdcall;
      {Registers the extension of the given file name with the context menu
      handler. Returns S_OK if the extension was successfully registered and
      E_FAIL if there was a problem}
    function IFileVerCMRegistrar.UnregisterExt = UnregisterCMExt;
    function UnregisterCMExt(const FileName: WideString): HResult;
      overload; stdcall;
      {Unregisters the context menu handler for extension of the given file
      name. If extension was unregistered then S_OK is returned. If the
      extension was not registered in the first place then S_FALSE is returned.
      If any error occurs then E_FAIL is returned}
    function FileDesc(const FileName: WideString;
      out Desc: WideString): HResult; stdcall;
      {Passes back a description of the extension of the given file name in the
      Desc parameter. Returns S_OK if a description is found, returns S_FALSE
      and sets Desc to '' if there is no registered description or returns
      E_FAIL on error}
    { IFileVerCMRegistrar and IFileVerExtRecorder }
    function RecordExt(const FileName: WideString;
      IsDefault: Boolean): HResult; stdcall;
      {Record extension of given file name in list of known extensions. If
      IsDefault is true, flag the extension as one of program's defaults (that
      shouldn't be deleted). Return S_OK is extension is successfully recorded
      and E_FAIL on error. Note that it is not possible to clear the default
      flag on an existing default extension}
    function UnrecordExt(const FileName: WideString): HResult; stdcall;
      {Unrecord extension if given file name in list of known extensions.
      Returns S_OK if key was unrecorded, S_FALSE if key was not recorded in
      first place and E_FAIL if an error occurs}
    function RecordedExtCount: Integer; stdcall;
      {Returns number of recorded extensions or -1 on error}
    function RecordedExts(Idx: Integer; out Name: WideString): HResult;
      stdcall;
      {Passes back the extension at the given index in the list of known
      extensions in Name parameter. Returns S_OK on success and E_FAIL on error}
    function IsDefaultExt(const FileName: WideString): HResult; stdcall;
      {Returns S_OK if given file's extension is recorded and is a default
      extension i.e. should not be deleted) or S_FALSE if not. Returns E_FAIL if
      an error occurs}
    { IFileVerExtInfo }
    function FileDescEx(const FileName: WideString;
      out Desc: WideString): HResult; stdcall;
      {Passes back a description of the extension of the given file name in the
      Desc parameter. Returns S_OK if a description is found, returns S_FALSE
      and sets Desc to the upper case name of the extension followed by "File"
      if there is no registered description or returns E_FAIL on error}
    { IFileVerExtRegistrar }
    function IsExtRegistered(const FileName: WideString;
      const CLSID: TGUID): HResult; stdcall;
      {Returns S_OK if extension of given file is registered with explorer
      extension with given CLSID and S_FALSE if not. Returns E_NOTIMPL if CLSID
      is not supported or E_FAIL if any other error was encountered}
    function RegisterExt(const FileName: WideString;
      const CLSID: TGUID): HResult; stdcall;
      {Registers the extension of the given file name with the explorer
      extension with given CLSID. Returns S_OK if the extension was successfully
      registered, E_NOTIMPL is CLSID is not supported and E_FAIL if there was
      any other problem}
    function UnregisterExt(const FileName: WideString;
      const CLSID: TGUID): HResult; overload; stdcall;
      {Unregisters the explorer extension of given CLSID for files with given
      extension. If extension was unregistered then S_OK is returned. If the
      extension was not registered in the first place then S_FALSE is returned.
      If CLSID is not supported E_NOTIMPL is returned and E_FAIL is returned for
      any other error}
    end;


implementation


uses
  // Delphi
  SysUtils, StrUtils, Windows, Registry, Classes, ActiveX,
  // Project
  UCtxMenuHandler, UGlobals, URegistry;


const

  // Registry keys

  //
  // COM server keys and values
  //

  // ProgId names
  cProgIDNameCM = 'VIS.CtxMenu.3';
  cProgIDNamePS = 'VIS.PropSheet.3';
  cProgIDNameReg = 'VIS.Registrar.3';

  // ProgId keys
  cProgIDKeyCM = '\' + cProgIDNameCM;
  cProgIDKeyPS = '\' + cProgIDNamePS;
  cProgIDKeyReg = '\' + cProgIDNameReg;

  // CLSID keys
  cCLSIDKeyCM = '\CLSID\' + CLSIDStr_FileVerCM;
  cCLSIDKeyPS = '\CLSID\' + CLSIDStr_FileVerPS;
  cCLSIDKeyReg = '\CLSID\' + CLSIDStr_FileVerReg;

  // InProcServer Keys
  cInprocServerKeyCM = cCLSIDKeyCM + '\InprocServer32';
  cInprocServerKeyPS = cCLSIDKeyPS + '\InprocServer32';
  cInprocServerKeyReg = cCLSIDKeyReg + '\InprocServer32';

  // CLSID/ProgId keys
  cCLSIDProgIDKeyCM = cCLSIDKeyCM + '\ProgID';
  cCLSIDProgIDKeyPS = cCLSIDKeyPS + '\ProgID';
  cCLSIDProgIDKeyReg = cCLSIDKeyReg + '\ProgID';

  // ProgId/CLSID keys
  cProgIDCLSIDKeyCM = cProgIDKeyCM + '\CLSID';
  cProgIDCLSIDKeyPS = cProgIDKeyPS + '\CLSID';
  cProgIDCLSIDKeyReg = cProgIDKeyReg + '\CLSID';

  // Server descriptions
  cSvrDescCM = cLongSuiteName + ' Context Menu Handler';
  cSvrDescPS = cLongSuiteName + ' Property Sheet Handler';
  cSvrDescReg = cLongSuiteName + ' Extension Registrar';

  //
  // Shell extension handlers
  //

  // Keys if HKCR where shell extensions are recorded
  //   HKCR\<filetype>\shellex\<handlertype>\<handlerid>
  // shellex sub key of file type keys
  cShellExKey = '\shellex';

  // handler sub keys of file type keys
  cCtxtMenuHandlerKey = cShellExKey + '\ContextMenuHandlers';
  cPropSheetHandlerKey = cShellExKey + '\PropertySheetHandlers';

  // our servers handler sub key of handler types
  cFileVerHandlerKeyCM = cShellExKey + '\ContextMenuHandlers\FileVerCM';
  cFileVerHandlerKeyPS = cShellExKey + '\PropertySheetHandlers\FileVerPS';

  // List of standard extensions recorded with VIS: those marked IsDefault can't
  // be deleted and are provisionally registered with all shell extensions
  cStdExts: array[1..8] of record
    Ext: string;        // extension
    IsDefault: Boolean; // whether extension registered by default
  end = (
    (Ext: '.exe'; IsDefault: True;),
    (Ext: '.dll'; IsDefault: True;),
    (Ext: '.res'; IsDefault: True;),
    (Ext: '.drv'; IsDefault: False;),
    (Ext: '.ocx'; IsDefault: False;),
    (Ext: '.cpl'; IsDefault: False;),
    (Ext: '.scr'; IsDefault: False;),
    (Ext: '.com'; IsDefault: False;)
  );

  //
  // NT approval registry key (in HKLM)
  //
  cNTApprovalKey =
    'Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved';



{ Helper routines }

function ParentKey(const Key: string): string;
  {Given a registry key path, returns the path to the immediate parent key: i.e.
  returns given path with final key removed. Returns '' if there are no more
  keys to remove. E.g. ParentKey('\Software\DelphiDabbler\VIS') =
  '\Software\DelphiDabbler'}
var
  DelimPos: Integer;  // position of last path delimiter in key
begin
  DelimPos := LastDelimiter('\', Key);
  if DelimPos > 1 then
    // We have path of > 1 key: chop off terminal key
    Result := Copy(Key, 1, DelimPos - 1)
  else
    // We have single key: return ''
    Result := '';
end;

procedure RemoveEmptyKeyPath(const Reg: TRegistry; Key: string);
  {Removes any of the registry keys in the given Key path under the root key
  recorded in Reg object that are empty}
var
  Info: TRegKeyInfo;  // info about a registry key
begin
  // check each of keys in path
  while Key <> '' do
  begin
    // Open current key and get info about it
    if Reg.OpenKey(Key, False) then
    begin
      try
        if Reg.GetKeyInfo(Info) then
          // We delete key if empty and exit routine if not
          if (Info.NumSubKeys = 0) and (Info.NumValues = 0) then
            Reg.DeleteKey(Key)
          else
            Exit; // Reg.CloseKey in finally section gets executed
      finally
        // Close key: in finally clauses so this gets called on break
        Reg.CloseKey;
      end;
      // move up to parent key and go round again
      Key := ParentKey(Key);
    end;
  end;
end;

function DLLName: string;
  {Returns fully qualified file path to this DLL}
begin
  // We get file name from Windows API
  SetLength(Result, MAX_PATH);
  SetLength(
    Result,
    Windows.GetModuleFileName(HInstance, PChar(Result), MAX_PATH)
  );
end;


{ TServerRegistrar }

class function TServerRegistrar.IsServerRegistered: HResult;
  {Returns S_OK if server is registered, S_FALSE if not (or partially registered
  or E_FAIL on error}
var
  Reg: TRegistry;   // registry object instance
  Res: Boolean;     // result of registry tests
begin
  Reg := TRegistry.Create;
  try
    try
      Reg.RootKey := HKEY_CLASSES_ROOT;

      Res :=
        // prog ids in HKCR\{-PROGID-}\(default)
        Reg.OpenKeyReadOnly(cProgIDKeyCM)
        and AnsiSameText(Reg.ReadString(''), cSvrDescCM)
        and Reg.OpenKeyReadOnly(cProgIDKeyPS)
        and AnsiSameText(Reg.ReadString(''), cSvrDescPS)
        and Reg.OpenKeyReadOnly(cProgIDKeyReg)
        and AnsiSameText(Reg.ReadString(''), cSvrDescReg)
        // class ids under prog ids in HKCR\{-PROGID-}\CLSID\(default)
        and Reg.OpenKeyReadOnly(cProgIDCLSIDKeyCM)
        and AnsiSameText(Reg.ReadString(''), CLSIDStr_FileVerCM)
        and Reg.OpenKeyReadOnly(cProgIDCLSIDKeyPS)
        and AnsiSameText(Reg.ReadString(''), CLSIDStr_FileVerPS)
        and Reg.OpenKeyReadOnly(cProgIDCLSIDKeyReg)
        and AnsiSameText(Reg.ReadString(''), CLSIDStr_FileVerReg)
        // descriptions in HKCR\CLSID\{-CLSID-}\(default)
        and Reg.OpenKeyReadOnly(cCLSIDKeyCM)
        and AnsiSameText(Reg.ReadString(''), cSvrDescCM)
        and Reg.OpenKeyReadOnly(cCLSIDKeyPS)
        and AnsiSameText(Reg.ReadString(''), cSvrDescPS)
        and Reg.OpenKeyReadOnly(cCLSIDKeyReg)
        and AnsiSameText(Reg.ReadString(''), cSvrDescReg)
        // server key names in HKCR\CLSID\{-CLSID-}\InprocServer32\(default)
        and Reg.OpenKeyReadOnly(cInprocServerKeyCM)
        and AnsiSameText(Reg.ReadString(''), DLLName)
        and AnsiSameText(Reg.ReadString('ThreadingModel'), 'Apartment')
        and Reg.OpenKeyReadOnly(cInprocServerKeyPS)
        and AnsiSameText(Reg.ReadString(''), DLLName)
        and AnsiSameText(Reg.ReadString('ThreadingModel'), 'Apartment')
        and Reg.OpenKeyReadOnly(cInprocServerKeyReg)
        and AnsiSameText(Reg.ReadString(''), DLLName)
        and AnsiSameText(Reg.ReadString('ThreadingModel'), 'Apartment')
        // progids under class IDs in HKCR\CLSID\{-CLSID-}\ProgID\(default)
        and Reg.OpenKeyReadOnly(cCLSIDProgIDKeyCM)
        and AnsiSameText(Reg.ReadString(''), cProgIDNameCM)
        and Reg.OpenKeyReadOnly(cCLSIDProgIDKeyPS)
        and AnsiSameText(Reg.ReadString(''), cProgIDNamePS)
        and Reg.OpenKeyReadOnly(cCLSIDProgIDKeyReg)
        and AnsiSameText(Reg.ReadString(''), cProgIDNameReg);
      // We have to approve the shell extension if we're on NT
      if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
      begin
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        Res := Res
          and Reg.OpenKeyReadOnly(cNTApprovalKey)
          and AnsiSameText(Reg.ReadString(CLSIDStr_FileVerPS), cSvrDescPS);
      end;
      if Res then
        Result := S_OK
      else
        Result := S_FALSE;
    except
      Result := E_FAIL;
    end;
  finally
    // Close registry
    Reg.Free;
  end;
end;

class procedure TServerRegistrar.RegisterServer;
  {Registers the COM servers in the DLL}
var
  Reg: TRegistry;               // registry object instance
  Idx: Integer;                 // loops thru all supported file type keys
  FileReg: IUnknown;            // object used to unregister extensions
begin
  // Register COM server objects
  // open registry HKEY_CLASSES_ROOT hive
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    // store prog ids
    //  HKCR\{-PROGID-}\(default)
    Reg.OpenKey(cProgIDKeyCM, True);
    Reg.WriteString('', cSvrDescCM);
    Reg.OpenKey(cProgIDKeyPS, True);
    Reg.WriteString('', cSvrDescPS);
    Reg.OpenKey(cProgIDKeyReg, True);
    Reg.WriteString('', cSvrDescReg);
    // store class ids under prog ids
    //  HKCR\{-PROGID-}\CLSID\(default)
    Reg.OpenKey(cProgIDCLSIDKeyCM, True);
    Reg.WriteString('', CLSIDStr_FileVerCM);
    Reg.OpenKey(cProgIDCLSIDKeyPS, True);
    Reg.WriteString('', CLSIDStr_FileVerPS);
    Reg.OpenKey(cProgIDCLSIDKeyReg, True);
    Reg.WriteString('', CLSIDStr_FileVerReg);
    // store descriptions in
    //  HKCR\CLSID\{-CLSID-}\(default)
    Reg.OpenKey(cCLSIDKeyCM, True);
    Reg.WriteString('', cSvrDescCM);
    Reg.OpenKey(cCLSIDKeyPS, True);
    Reg.WriteString('', cSvrDescPS);
    Reg.OpenKey(cCLSIDKeyReg, True);
    Reg.WriteString('', cSvrDescReg);
    // store server key names in
    //  HKCR\CLSID\{-CLSID-}\InprocServer32\(default)
    Reg.OpenKey(cInprocServerKeyCM, True);
    Reg.WriteString('', DLLName);
    Reg.WriteString('ThreadingModel', 'Apartment'); // store threading model
    Reg.OpenKey(cInprocServerKeyPS, True);
    Reg.WriteString('', DLLName);
    Reg.WriteString('ThreadingModel', 'Apartment'); // store threading model
    Reg.OpenKey(cInprocServerKeyReg, True);
    Reg.WriteString('', DLLName);
    Reg.WriteString('ThreadingModel', 'Apartment'); // store threading model
    // store progids under class IDs
    //  HKCR\CLSID\{-CLSID-}\ProgID\(default)
    Reg.OpenKey(cCLSIDProgIDKeyCM, True);
    Reg.WriteString('', cProgIDNameCM);
    Reg.OpenKey(cCLSIDProgIDKeyPS, True);
    Reg.WriteString('', cProgIDNamePS);
    Reg.OpenKey(cCLSIDProgIDKeyReg, True);
    Reg.WriteString('', cProgIDNameReg);

    // We have to approve the shell extension if we're on NT
    if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      Reg.OpenKey(cNTApprovalKey, True);
      Reg.WriteString(CLSIDStr_FileVerPS, cSvrDescPS);
    end;

  finally
    // Close registry
    Reg.Free;
  end;

  // Record and register extensions for use with context menu handler and
  // property sheet handler
  // create instance of registrar object to register and record file extensions
  FileReg := TFileRegistrar.Create;
  // record and register default extensions: loop thru them all
  for Idx := Low(cStdExts) to High(cStdExts) do
  begin
    // record the standard extension
    (FileReg as IFileVerExtRecorder).RecordExt(
      cStdExts[Idx].Ext, cStdExts[Idx].IsDefault
    );
    // register the extension with context menu and property sheet handler
    // if it is a default extension
    if cStdExts[Idx].IsDefault then
    begin
      (FileReg as IFileVerExtRegistrar).RegisterExt(
        cStdExts[Idx].Ext, CLSID_FileVerCM
      );
      (FileReg as IFileVerExtRegistrar).RegisterExt(
        cStdExts[Idx].Ext, CLSID_FileVerPS
      );
    end;
  end;
end;

class procedure TServerRegistrar.UnregisterServer;
  {Unregisters the DLL's COM servers}
var
  Reg: TRegistry;               // registry object instance
  Idx: Integer;                 // loops thru all supported file type keys
  FileRec: IFileVerExtRecorder; // object used to unrecord extensions
  FileReg: IFileVerExtRegistrar;// object used to unregister extensions
  Ext: WideString;              // extension being unregistered
  ExtList: TStringList;         // list of all known extensions
begin

  // Delete all registered shell extensions
  // create string list to hold all registered extensions
  ExtList := TStringList.Create;
  try
    // create objects to do unregistration / unrecording
    FileReg := TFileRegistrar.Create;
    FileRec := FileReg as IFileVerExtRecorder;
    // record list of known extensions: we don't access directly by index since
    // we're deleting keys which will have side effect on indexes
    for Idx := 0 to Pred(FileRec.RecordedExtCount) do
      if Succeeded(FileRec.RecordedExts(Idx, Ext)) then
        ExtList.Add(Ext);
    // now unregister and unrecord every extension in list
    // (its safe to unregister extensions that aren't actually registered)
    for Idx := 0 to Pred(ExtList.Count) do
    begin
      FileReg.UnregisterExt(ExtList[Idx], CLSID_FileVerCM);
      FileReg.UnregisterExt(ExtList[Idx], CLSID_FileVerPS);
      FileRec.UnrecordExt(ExtList[Idx]);
    end;
  finally
    ExtList.Free;
  end;

  // Unregister the COM servers
  // open registry HKEY_CLASSES_ROOT hive
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CLASSES_ROOT;
    // delete InprocServer32 keys
    Reg.DeleteKey(cInprocServerKeyCM);
    Reg.DeleteKey(cInprocServerKeyPS);
    Reg.DeleteKey(cInprocServerKeyReg);
    // delete ProgID keys under CLSIDs
    Reg.DeleteKey(cCLSIDProgIDKeyCM);
    Reg.DeleteKey(cCLSIDProgIDKeyPS);
    Reg.DeleteKey(cCLSIDProgIDKeyReg);
    // delete CLSID keys
    Reg.DeleteKey(cCLSIDKeyCM);
    Reg.DeleteKey(cCLSIDKeyPS);
    Reg.DeleteKey(cCLSIDKeyReg);
    // delete CLSID keys under ProgIDs
    Reg.DeleteKey(cProgIDCLSIDKeyCM);
    Reg.DeleteKey(cProgIDCLSIDKeyPS);
    Reg.DeleteKey(cProgIDCLSIDKeyReg);
    // delete ProgID keys
    Reg.DeleteKey(cProgIDKeyCM);
    Reg.DeleteKey(cProgIDKeyPS);
    Reg.DeleteKey(cProgIDKeyReg);

    // Delete approval key if on NT
    if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      Reg.RootKey := HKEY_LOCAL_MACHINE;
      if Reg.OpenKey(cNTApprovalKey, False) then
        Reg.DeleteValue(CLSIDStr_FileVerPS);
    end;

  finally
    // Close registry
    Reg.Free;
  end;

end;


{ TFileRegistrar }

resourcestring
  // Descriptive strings
  sDefaultExtDesc = '%s File';

function TFileRegistrar.FileDesc(const FileName: WideString;
  out Desc: WideString): HResult;
  {Passes back a description of the extension of the given file name in the Desc
  parameter. Returns S_OK if a description is found, returns S_FALSE and sets
  Desc to '' if there is no registered description or returns E_FAIL on error}
var
  Reg: TRegistry; // accesses registry
  Ext: string;    // extension we want description of
begin
  try
    // Assume there is no description available
    Result := S_FALSE;
    Desc := '';
    // Record extension we're checking
    Ext := ExtractFileExt(FileName);
    // Open registry HKEY_CLASSES_ROOT hive
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CLASSES_ROOT;
      // Open file type's registry key in
      //   HKCR\filetype where filetype is read from HKCR\.exe
      if Reg.OpenKeyReadOnly('\' + Ext)
        and Reg.ValueExists('')
        and Reg.OpenKeyReadOnly('\' + Reg.ReadString(''))
        and Reg.ValueExists('') then
      begin
        // read description from HKCR\filetype's default value
        Desc := Reg.ReadString('');
        if Desc <> '' then
          // there is a file type description
          Result := S_OK;
      end;
    finally
      Reg.Free;
    end;
  except
    // There was an error: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.FileDescEx(const FileName: WideString;
  out Desc: WideString): HResult;
  {Passes back a description of the extension of the given file name in the
  Desc parameter. Returns S_OK if a description is found, returns S_FALSE and
  sets Desc to the upper case name of the extension followed by "File" if there
  is no registered description or returns E_FAIL on error}
begin
  // Get description from FileDesc
  Result := FileDesc(FileName, Desc);
  if Result = S_FALSE then
    // No registered description: return default name
    Desc := Format(
      sDefaultExtDesc, [Copy(UpperCase(ExtractFileExt(FileName)), 2, MaxInt)]
    );
end;

function TFileRegistrar.InternalIsExtRegistered(
  const FileName, CLSIDStr, HandlerKey: string): HResult;
  {Returns S_OK if a shell extension object with key CLSID string is registered
  under the extension handler for the given extension and handler key or S_FALSE
  if not. Returns E_FAIL if any error is encountered}
var
  Reg: TRegistry; // accesses registry
  Ext: string;    // extension of file
begin
  // Record extension
  Ext := ExtractFileExt(FileName);
  // Open HKEY_CLASSES_ROOT registry hive
  Reg := TRegistry.Create;
  try
    try
      Reg.RootKey := HKEY_CLASSES_ROOT;
      // Look up extension in registry and return whether it's found
      //   we open HKCR\.ext to get file type name
      //   then open HKCR\<filetype>\shellex\<HandlerKey>\<CLSID>
      //   and check for default string, which is CLSID of shell extension
      //   handler
      if Reg.OpenKeyReadOnly('\' + Ext)
        and Reg.ValueExists('')
        and Reg.OpenKeyReadOnly('\' + Reg.ReadString('') + HandlerKey)
        and Reg.ValueExists('')
        and AnsiSameText(Reg.ReadString(''), CLSIDStr) then
        Result := S_OK
      else
        Result := S_FALSE;
    finally
      Reg.Free;
    end;
  except
    // There have been errors: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.InternalRegisterExt(const FileName, CLSIDStr,
  HandlerKey: string): HResult;
  {Registers the extension of the given file name with the explorer extension
  with given handler key and CLSID string. Returns S_OK if the extension was
  successfully registered and E_FAIL if there was a problem}
var
  Ext: string;          // extension we're registereing
  FileTypeName: string; // file type name for extension
  Reg: TRegistry;       // accesses registry
begin
  try
    // Assume failure
    Result := E_FAIL;
    // Record extension to be registered
    Ext := ExtractFileExt(FileName);
    Reg := TRegistry.Create;
    // Open HKEY_CLASSES_ROOT registry hive
    try
      Reg.RootKey := HKEY_CLASSES_ROOT;
      // Ensure extension is known to registry in HKCR\.ext and open it
      if Reg.OpenKey('\' + Ext, True) then
      begin
        // If extension key exists, try to get file type key name from it
        if Reg.ValueExists('') then
          FileTypeName := Reg.ReadString('')
        else
          FileTypeName := '';
        if FileTypeName = '' then
        begin
          // We haven't a file type name: create one and write it to ext key
          FileTypeName := Copy(Ext, 2, MaxInt) + 'file';
          Reg.WriteString('', FileTypeName);
        end;
        // Ensure shell extension is known to registry in
        //   HKCR\<filetype>\shellex\<HandlerKey>\<CLSIDStr>
        //   and write COM server's CLSID as its default value: we're registered
        if Reg.OpenKey('\' + FileTypeName + HandlerKey, True) then
        begin
          Reg.WriteString('', CLSIDStr);
          Result := S_OK;
        end;
      end;
    finally
      Reg.Free;
    end;
    // We ensure that extension is recorded if we succeeded
    if Succeeded(Result) then
      RecordExt(Ext, False);
  except
    // There was an error: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.InternalUnRegisterExt(const FileName, CLSIDStr,
  HandlerKey: string): HResult;
  {Unregisters the explorer extension of given CLSID string for files with given
  extension registered under given handler key. If extension was unregistered
  then S_OK is returned. If the extension was not registered in the first place
  then S_FALSE is returned. E_FAIL is returned if any error occurs}
var
  ExtKey: string;       // extension's key in HKCR
  Reg: TRegistry;       // accesses registry
  FileTypeName: string; // file type name for extension
  Key: string;          // shell extension handler's key under file type
  DelFileType: Boolean; // flag true if we delete the file type registry entry
begin
  try
    // Assume failure
    Result := E_FAIL;
    // If extension not registered for this shell extension then nothing to do
    if InternalIsExtRegistered(FileName, CLSIDStr, HandlerKey) = S_FALSE then
      Result := S_FALSE
    else
    begin
      // Assume we don't delete file type
      DelFileType := False;
      // Record extension's key in registry: HKCR\.ext
      ExtKey := '\' + ExtractFileExt(FileName);
      Reg := TRegistry.Create;
      try
        Reg.RootKey := HKEY_CLASSES_ROOT;
        if Reg.OpenKeyReadOnly(ExtKey) then
        begin
          // Get file type from ext key
          FileTypeName := Reg.ReadString('');
          if FileTypeName <> '' then
          begin
            // Delete shell extension key:
            //   HKCR\<filetype>\shellex\<handlertype>\<HandlerKey>\<CLSIDStr>
            Key := '\' + FileTypeName + HandlerKey;
            if Reg.DeleteKey(Key) then
              Result := S_OK;
            // Delete all parent keys that are now empty
            RemoveEmptyKeyPath(Reg, ParentKey(Key));
            // Record if we've deleted file type key
            DelFileType := not Reg.KeyExists('\' + FileTypeName);
          end;
        end;
      finally
        Reg.Free;
      end;
      // If we've deleted file type key we need to delete reference to it in
      // extension registry key (HCKR\.ext)
      // NOTE: We appear to need to free and re-create the registry to delete
      // this default entry - doesn't work otherwise!!!
      if DelFileType then
      begin
        Reg := TRegistry.Create;
        try
          Reg.RootKey := HKEY_CLASSES_ROOT;
          // Delete HCKR\.ext key's default value that refers to file type key
          if Reg.OpenKey(ExtKey, False) then
            Reg.DeleteValue('');
          Reg.CloseKey;
          // Now remove HCKR\.ext key if it is empty
          RemoveEmptyKeyPath(Reg, ExtKey);
        finally
          Reg.Free;
        end;
      end;
    end;
  except
    // There was an error: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.IsCMExtRegistered(
  const FileName: WideString): HResult;
  {Returns S_OK if extension of given file is registered with context menu
  handler and S_FALSE if not. Returns E_FAIL if any error was encountered}
begin
  Result := IsExtRegistered(FileName, CLSID_FileVerCM);
end;

function TFileRegistrar.IsDefaultExt(const FileName: WideString): HResult;
  {Returns S_OK if given file's extension is recorded and is a default extension
  (i.e. should not be deleted) or S_FALSE if not. Returns E_FAIL if an error
  occurs}
var
  Reg: TRegistry; // accesses registry
  Ext: string;    // extension we are checking
begin
  try
    // Record extension
    Ext := ExtractFileExt(FileName);
    // Open registry key for recorded key and check IsDefault data item value
    //   the key has IsDefault value of 1 if this is a default extension
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly(cRegExtsKey + '\' + Ext)
        and Reg.ValueExists('IsDefault')
        and (Reg.ReadInteger('IsDefault') = 1) then
        Result := S_OK
      else
        Result := S_FALSE;
    finally
      Reg.Free;
    end;
  except
    // Error: report it
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.IsExtRegistered(const FileName: WideString;
  const CLSID: TGUID): HResult;
  {Returns S_OK if extension of given file is registered with explorer extension
  with given CLSID and S_FALSE if not. Returns E_NOTIMPL if CLSID is not
  supported or E_FAIL if any other error was encountered}
begin
  if IsEqualIID(CLSID, CLSID_FileVerCM) then
    Result := InternalIsExtRegistered(
      FileName, CLSIDStr_FileVerCM, cFileVerHandlerKeyCM
    )
  else if IsEqualIID(CLSID, CLSID_FileVerPS) then
    Result := InternalIsExtRegistered(
      FileName, CLSIDStr_FileVerPS, cFileVerHandlerKeyPS
    )
  else
    Result := E_NOTIMPL;
end;

function TFileRegistrar.RecordedExtCount: Integer;
  {Returns number of recorded extensions or -1 on error}
var
  Reg: TRegistry;     // accesses registry
  Info: TRegKeyInfo;  // info about registry key
begin
  try
    // Open registry key where we record known extensions and get info about it,
    // returning number of subkeys in it: there's a key for each known extension
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly(cRegExtsKey) and Reg.GetKeyInfo(Info) then
        Result := Info.NumSubKeys
      else
        Result := 0;
    finally
      Reg.Free;
    end;
  except
    // We have an error: return -1
    Result := -1;
  end;
end;

function TFileRegistrar.RecordedExts(Idx: Integer;
  out Name: WideString): HResult;
  {Passes back the extension at the given index in the list of known extensions
  in Name parameter. Returns S_OK on success and E_FAIL on error}
var
  Reg: TRegistry;     // accesses registry
  Keys: TStringList;  // list of extension sub keys
begin
  // Set name to '' in case of error
  Name := '';
  try
    Keys := nil;
    // Open registry key where list of known extensions is stored
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKeyReadOnly(cRegExtsKey) then
      begin
        // Each extension has its own sub key: get list of all extensions
        Keys := TStringList.Create;
        Reg.GetKeyNames(Keys);
        // Record name of extension at required index
        Name := Keys[Idx];
        Result := S_OK;
      end
      else
        // Can't open key: this is error
        Result := E_FAIL;
    finally
      Keys.Free;
      Reg.Free;
    end;
  except
    // There was an error: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.RecordExt(const FileName: WideString;
  IsDefault: Boolean): HResult;
  {Record extension of given file name in list of known extensions. If IsDefault
  is true, flag the extension as one of program's defaults (that shouldn't be
  deleted). Return S_OK is extension is successfully recorded and E_FAIL on
  error. Note that it is not possible to clear the default flag on an existing
  default extension}
var
  Reg: TRegistry; // accesses registry
  Ext: string;    // extension we're recording
begin
  try
    // Record extension we're recording
    Ext := ExtractFileExt(FileName);
    // Open or create registry key where known extensions are recorded
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if Reg.OpenKey(cRegExtsKey + '\' + Ext, True) then
      begin
        // Record if this is default: note that IsDefault false causes nothing
        // to be written => can't reset IsDefault once set
        if IsDefault then
          Reg.WriteInteger('IsDefault', Ord(IsDefault));
        // key recorded
        Result := S_OK;
      end
      else
        // can't record key
        Result := E_FAIL;
    finally
      Reg.Free;
    end;
  except
    // Some error ocurred: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.RegisterCMExt(const FileName: WideString): HResult;
  {Registers the extension of the given file name with the context menu handler.
  Returns S_OK if the extension was successfully registered and E_FAIL if there
  was a problem}
begin
  Result := RegisterExt(FileName, CLSID_FileVerCM);
end;

function TFileRegistrar.RegisterExt(const FileName: WideString;
  const CLSID: TGUID): HResult;
  {Registers the extension of the given file name with the explorer extension
  with given CLSID. Returns S_OK if the extension was successfully registered,
  E_NOTIMPL is CLSID is not supported and E_FAIL if there was any other problem}
begin
  if IsEqualIID(CLSID, CLSID_FileVerCM) then
    Result := InternalRegisterExt(
      FileName, CLSIDStr_FileVerCM, cFileVerHandlerKeyCM
    )
  else if IsEqualIID(CLSID, CLSID_FileVerPS) then
    Result := InternalRegisterExt(
      FileName, CLSIDStr_FileVerPS, cFileVerHandlerKeyPS
    )
  else
    Result := E_NOTIMPL;
end;

function TFileRegistrar.UnrecordExt(const FileName: WideString): HResult;
  {Unrecord extension if given file name in list of known extensions. Returns
  S_OK if key was unrecorded, S_FALSE if key was not recorded in first place and
  E_FAIL if an error occurs}
var
  Reg: TRegistry; // accesses registry
  Ext: string;    // extension we're unrecording
  Key: string;    // registry key for extension
begin
  try
    // Ensure that any extension is unregistered with all shell extensions
    UnregisterExt(FileName, CLSID_FileVerCM);
    UnregisterExt(FileName, CLSID_FileVerPS);

    // Store extension we're deleting
    Ext := ExtractFileExt(FileName);
    // Try to open registry key where known extensions are recorded
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Key := cRegExtsKey + '\' + Ext;
      if Reg.KeyExists(Key) then
        if Reg.DeleteKey(Key) then
          // key actually deleted
          Result := S_OK
        else
          // error deleting key we know exists
          Result := E_FAIL
      else
        // key wasn't present
        Result := S_FALSE;
    finally
      Reg.Free;
    end;
  except
    // There was an error: say so
    Result := E_FAIL;
  end;
end;

function TFileRegistrar.UnregisterCMExt(const FileName: WideString): HResult;
  {Unregisters the context menu handler for extension of the given file name. If
  extension was unregistered then S_OK is returned. If the extension was not
  registered in the first place then S_FALSE is returned. If any error occurs
  then E_FAIL is returned}
begin
  Result := UnregisterExt(FileName, CLSID_FileVerCM);
end;

function TFileRegistrar.UnregisterExt(const FileName: WideString;
  const CLSID: TGUID): HResult;
  {Unregisters the explorer extension of given CLSID for files with given
  extension. If extension was unregistered then S_OK is returned. If the
  extension was not registered in the first place then S_FALSE is returned. If
  CLSID is not supported E_NOTIMPL is returned and E_FAIL is returned for any
  other error}
begin
  if IsEqualIID(CLSID, CLSID_FileVerCM) then
    Result := InternalUnRegisterExt(
      FileName, CLSIDStr_FileVerCM, cFileVerHandlerKeyCM
    )
  else if IsEqualIID(CLSID, CLSID_FileVerPS) then
    Result := InternalUnRegisterExt(
      FileName, CLSIDStr_FileVerPS, cFileVerHandlerKeyPS
    )
  else
    Result := E_NOTIMPL;
end;

end.
