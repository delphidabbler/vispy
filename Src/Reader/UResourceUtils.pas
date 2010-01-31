{
 * UResourceUtils.pas
 *
 * Provides some utility functions to assist in working with resource files.
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
 * The Original Code is UResourceUtils.pas.
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


unit UResourceUtils;


interface


function IsEqualResNameOrType(R1, R2: PChar): Boolean;
  {Returns true if the resource name or types pointed to by parameters are
  equal and false if not. The parameters can be either numeric ids or zero
  terminated strings}

function ResNameOrTypeIsID(const Name: PChar): Boolean;
  {Returns true if the given name is a numeric resource identifier or false if
  the name is a zero terminated string}

function ResNameOrTypeAsString(const Name: PChar): string;
  {Returns a string representation of the given resource name or id. If name is
  a standard string, the string is returned. If name is a numeric resource id
  then the number is converted to a string preceeded by hash character}


implementation


uses
  // Delphi
  SysUtils, Windows;


function IsEqualResNameOrType(R1, R2: PChar): Boolean;
  {Returns true if the resource name or types pointed to by parameters are
  equal and false if not. The parameters can be either numeric ids or zero
  terminated strings}
begin
  if ResNameOrTypeIsID(R1) then
    Result := ResNameOrTypeIsID(R2) and (LoWord(DWORD(R1)) = LoWord(DWORD(R2)))
  else
    Result := not ResNameOrTypeIsID(R2) and (StrIComp(R1, R2) = 0);
end;

function ResNameOrTypeIsID(const Name: PChar): Boolean;
  {Returns true if the given name is a numeric resource identifier or false if
  the name is a zero terminated string}
begin
  Result := (HiWord(DWORD(Name)) = 0);
end;

function ResNameOrTypeAsString(const Name: PChar): string;
  {Returns a string representation of the given resource name or id. If name is
  a standard string, the string is returned. If name is a numeric resource id
  then the number is converted to a string preceeded by hash character}
begin
  if ResNameOrTypeIsID(Name) then
    Result := '#' + IntToStr(LoWord(DWORD(Name)))
  else
    Result := Name;
end;

end.
