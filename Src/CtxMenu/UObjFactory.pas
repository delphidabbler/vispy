{
 * UObjFactory.pas
 *
 * Defines the class factory object that creates the supported shell extension
 * handler and file extension registrar COM objects.
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
 * The Original Code is UObjFactory.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UObjFactory;


interface


uses
  // Delphi
  Windows, ActiveX;


type

  {
  TObjFactory:
    The class factory object that creates the supported shell extension handler
    and file extension registrar COM objects.

    Inheritance: TObjFactory -> [TInterfacedObject]
  }
  TObjFactory = class(TInterfacedObject, IClassFactory)
  private
    fCLSID: TGUID;
      {CLSID of COM object we're creating}
  protected
    { IClassFactory }
    function CreateInstance(const UnkOuter: IUnknown;
      const IID: TGUID; out Obj): HResult; stdcall;
      {Creates an uninitialized object of required kind. Returns S_OK if object
      can be created or error code if not}
    function LockServer(fLock: BOOL): HResult; stdcall;
      {Increments or decrements a lock count according to state of fLock. When
      the count is non-zero the object is locked in memory}
  public
    constructor Create(CLSID: TGUID);
      {Class constructor: creates factory object that can create instances of
      COM objects as specified by CLSID}
    class function GetLockCount: Integer;
      {Returns number of locks on server: can't free DLL until this is 0}
    class procedure IncLockCount;
      {Increments lock count: for external use without using COM interface}
  end;


implementation


uses
  // Delphi
  ComObj,
  // Project
  IntfFileVerShellExt, UPropSheetHandler, UCtxMenuHandler, UShellExtReg;


{ TObjFactory }

var
  LockCount: Integer;   // counts server locks from all class factory instances

constructor TObjFactory.Create(CLSID: TGUID);
  {Class constructor: creates factory object that can create instances of COM
  objects as specified by CLSID}
begin
  inherited Create;
  // Simply record CLSID of objects we can create
  fCLSID := CLSID;
end;

function TObjFactory.CreateInstance(const UnkOuter: IUnknown;
  const IID: TGUID; out Obj): HResult;
  {Creates an uninitialized object of required kind. Returns S_OK if object can
  be created or error code if not}
var
  Unk: IUnknown;  // reference to created object
begin
  // Init output pointer to nil - assumes failure
  Pointer(Obj) := nil;
  // Don't support aggregation
  if UnkOuter <> nil then
  begin
    Result := CLASS_E_NOAGGREGATION;
    Exit;
  end;
  // Create COM object of type specified by CLSID factory was created with
  if IsEqualIID(fCLSID, CLSID_FileVerReg) then
    // we're creating extension registrar COM object
    Unk := TFileRegistrar.Create
  else if IsEqualIID(fCLSID, CLSID_FileVerCM) then
    // we're creating context menu handler COM object
    Unk := TContextMenuHandler.Create
  else if IsEqualIID(fCLSID, CLSID_FileVerPS) then
    // we're creating property sheet handler COM object
    Unk := TPropSheetHandler.Create
  else
    // don't recognise COM object
    Unk := nil;
  // Now query COM object to see if interface is supported if we managed to
  // create object above. If not flag that we don't support required interface
  if Assigned(Unk) then
    Result := Unk.QueryInterface(IID, Obj)
  else
    Result := E_NOINTERFACE;
end;

class function TObjFactory.GetLockCount: Integer;
  {Returns number of locks on server: can't free DLL until this is 0}
begin
  Result := LockCount;
end;

class procedure TObjFactory.IncLockCount;
  {Increments lock count: for external use without using COM interface}
begin
  InterlockedIncrement(LockCount);
end;

function TObjFactory.LockServer(fLock: BOOL): HResult;
  {Increments or decrements a lock count according to state of fLock. When the
  count is non-zero the object is locked in memory}
begin
  if fLock then
    InterlockedIncrement(LockCount)
  else
    InterlockedDecrement(LockCount);
  Result := S_OK;
end;

end.
