{
 * UCOMLibExp.pas
 *
 * Defines the functions that are need to be exported by the COM in process
 * server.
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
 * The Original Code is UCOMLibExp.pas.
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


unit UCOMLibExp;


interface

{
  Functions exported by in process servers for use by COM libraries and
  registration programs
}

function DllGetClassObject(const CLSID, IID: TGUID; var Obj): HResult; stdcall;
  {Returns a class factory in Obj for the interface specified by CLSID. IID is
  the class factory interface required. Only IClassFactory is supported}

function DllCanUnloadNow: HResult; stdcall;
  {DLL can unload only if there are no current object instances and server is
  not locked by class factory}

function DllRegisterServer: HResult; stdcall;
  {Register the server's COM object and the shell extension handlers with
  supported file types in registry}

function DllUnregisterServer: HResult; stdcall;
  {Remove server's COM object and shell extension handlers registration from
  registry}


{
  Function exported by this DLL for non-COM use
}

function IsServerRegistered: HResult; stdcall;
  {Returns S_OK if shell extension COM servers are all registered correctly,
  S_FALSE if not or E_FAIL if check cannot be performed}


implementation


uses
  // Delphi
  Windows, ActiveX,
  // Project
  UShellExtReg, UCtxMenuHandler, UObjFactory, UBaseCOMObj,
  IntfFileVerShellExt;


{ Exported functions }

function DllGetClassObject(const CLSID, IID: TGUID; var Obj): HResult; stdcall;
  {Returns a class factory in Obj for the interface specified by CLSID. IID is
  the class factory interface required. Only IClassFactory is supported}
var
  ClassFactory: TObjFactory;  // class factory instance
begin
  // Check if our only supported object is being requested
  if IsEqualIID(CLSID, CLSID_FileVerCM)
    or IsEqualIID(CLSID, CLSID_FileVerPS)
    or IsEqualIID(CLSID, CLSID_FileVerReg) then
    // this is our supported object: create class factory
    ClassFactory := TObjFactory.Create(CLSID)
  else
  begin
    // not a supported object: say so
    Result := CLASS_E_CLASSNOTAVAILABLE;
    Exit;
  end;
  // Check if class factory supports required interface
  if ClassFactory.GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function DllCanUnloadNow: HResult; stdcall;
  {DLL can unload only if there are no current object instances and server is
  not locked by class factory}
begin
  if (TBaseCOMObj.InstanceCount = 0)
    and (TObjFactory.GetLockCount = 0) then
    Result := S_OK
  else
    Result := S_FALSE;

  if (Result = S_FALSE) and (TObjFactory.GetLockCount = 0) then
    TObjFactory.IncLockCount;
end;

function DllRegisterServer: HResult; stdcall;
  {Register the server's COM object and the shell extension handlers with
  supported file types in registry}
begin
  try
    TServerRegistrar.RegisterServer;
    Result := S_OK;
  except
    Result := E_FAIL;
  end;
end;

function DllUnregisterServer: HResult; stdcall;
  {Remove server's COM object and shell extension handlers registration from
  registry}
begin
  try
    TServerRegistrar.UnregisterServer;
    Result := S_OK;
  except
    Result := E_FAIL;
  end;
end;

function IsServerRegistered: HResult; stdcall;
  {Returns S_OK if shell extension COM servers are all registered correctly,
  S_FALSE if not or E_FAIL if check cannot be performed}
begin
  try
    Result := TServerRegistrar.IsServerRegistered;
  except
    Result := E_FAIL;
  end;
end;

end.
