{ ##
  @FILE                     URegistry.pas
  @COMMENTS                 Unit that defines various registry constants and
                            access routines used by various components of
                            program.
  @PROJECT_NAME             Version Information Spy Shared Code
  @PROJECT_DESC             Code units shared between various Version
                            Information Spy applications and DLLs.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 05/06/2004
      @COMMENTS             Major update
                            + Added new GUI subkey to store all GUI persistent
                              values.
                            + Added GUIWindowKey function to return a registry
                              subkey for any form under the new GUI subkey.
                            + Deleted cWdwRegKey subkey - main form's subkey now
                              returned by GUIWindowKey function.
                            + Changed registry key to increment product version
                              from 6 to 7.
                            + Added AppPath routine that looks up applications
                              in App Paths section of registry and returns full
                              path to registered extensions. Deleted constant
                              giving key for VIS in REGSTR_PATH_APPPATHS.
                            + Replaced former cCtxMenuKey constant with new
                              cExplExtKey constant and changed value to
                              "ExplExt".
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
 * The Original Code is URegistry.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
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
