{
 * UBaseCOMObj.pas
 *
 * Defines an ancestor class for COM objects. Keeps track of total number of
 * instances of the object in the server.
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
 * The Original Code is UBaseCOMObj.pas.
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


unit UBaseCOMObj;


interface


type

  {
  TBaseCOMObj:
    Ancestor class of the COM objects in the DLL. Keeps track of total number of
    instances of the object in the server.

    Inheritance: TBaseCOMObj -> [TInterfacedObject]
  }
  TBaseCOMObj = class(TInterfacedObject)
  public
    constructor Create;
      {Class constructor: increments the object instance count}
    destructor Destroy; override;
      {Class destructor: decrements the object instance count}
    class function InstanceCount: Integer;
      {Returns the object instance count}
  end;


implementation


uses
  // Delphi
  Windows;


{ TBaseCOMObj }

var
  gInstanceCount: Integer = 0;  // total number of instances of COM object

constructor TBaseCOMObj.Create;
  {Class constructor: increments the object instance count}
begin
  inherited Create;
  InterlockedIncrement(gInstanceCount);
end;

destructor TBaseCOMObj.Destroy;
  {Class destructor: decrements the object instance count}
begin
  InterlockedDecrement(gInstanceCount);
  inherited Destroy;
end;

class function TBaseCOMObj.InstanceCount: Integer;
  {Returns the object instance count}
begin
  Result := gInstanceCount;
end;

end.
