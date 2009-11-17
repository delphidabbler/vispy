{ ##
  @FILE                     UBaseCOMObj.pas
  @COMMENTS                 Defines an ancestor class for COM objects. Keeps
                            track of total number of instances of the object in
                            the server.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @OTHER_NAMES              Original name was UFileVerCMBase.pas. Renamed as
                            UBaseCOMObj.pas at v1.1.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 05/06/2004
      @COMMENTS             + Renamed GetInstanceCount method as InstanceCount
                              and renamed clashing global variable as
                              gInstanceCount.
                            + Renamed unit from UFileVerCMBase to UBaseCOMObj.
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
 * The Original Code is UBaseCOMObj.pas.
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
