{
 * URegistry.pas
 *
 * Unit that defines various registry constants and access routines used by
 * various components of  the program.
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
 * The Original Code is URegistry.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit URegistry;


interface


uses
  // Delphi
  UGlobals;


const

  // Program Registry keys under HKEY_CURRENT_USER
  cRegKey = '\Software\' + cDeveloperAlias
    + '\' + cShortSuiteName + '\' + cVersion;                        // root key
  cPrefRegKey = cRegKey + '\Preferences';    // general windows prog preferences
  cExplExtKey = cRegKey + '\ExplExt';     // shell extension handler preferences
  cRegExtsKey = cExplExtKey + '\RegExt';       // recorded registered extensions
  cGUIKey = cRegKey + '\GUI';        // root subkey for persistent form settings


function AppPath(const AppName: string): string;
  {Returns full path to the the given application that is recorded in registry.
  If there is no record the application '' is returned}

function GUIWindowKey(const FormName: string): string;
  {Returns subkey under which persistent settings for the form with the given
  name are stored}


implementation


uses
  // Delphi
  Windows, RegStr, Registry;


function AppPath(const AppName: string): string;
  {Returns full path to the the given application that is recorded in registry.
  If there is no record the application '' is returned}
var
  Reg: TRegistry;   // registry access object
begin
  // Assume we can't get path
  Result := '';
  // Read path from App Paths section in registry
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKeyReadOnly('\' + REGSTR_PATH_APPPATHS + '\' + AppName)
      and Reg.ValueExists('') then
      Result := Reg.ReadString('');
  finally
    Reg.Free;
  end;
end;

function GUIWindowKey(const FormName: string): string;
  {Returns subkey under which persistent settings for the form with the given
  name are stored}
begin
  // Actual key is a subkey of the GUI key
  Result := cGUIKey + '\' + FormName;
end;

end.
