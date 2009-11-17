{ ##
  @PROJECT_NAME             Version Information Spy File Reader DLL.
  @PROJECT_DESC             Enables version information data to be read from
                            excutable and binary resource files that contain
                            version information.
  @FILE                     UVIBinary.pas
  @COMMENTS                 Defines a class that wraps object creation entry
                            point exported by VIBinData.dll and dynamically
                            loads and unloads the DLL.
  @DEPENDENCIES             This unit requires VIBinData.dll to be located in
                            the application's path or in the DelphiDabbler sub
                            folder of the system's Common Files folder.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 04/08/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 24/02/2003
      @COMMENTS             Changed to derive from TDDabblerDLLLoader class
                            rather than previous TPJSoftDLLLoader.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 23/05/2004
      @COMMENTS             Changed method of operation of DLL loader to be
                            compatible with revised parent class:
                            + Removed DLL global reference count.
                            + Removed global DLL handle.
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
 * The Original Code is UVIBinary.pas.
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


unit UVIBinary;


interface


uses
  // Project
  IntfBinaryVerInfo, UDLLLoader;


type

  {
  TVIBinaryLoader:
    Class that wraps object creation entry point exported by VIBinData.dll and
    dynamically loads and unloads the DLL.

    Inheritance: TVIBinaryLoader -> TDDabblerDLLLoader -> TDLLLoader
      -> [TObject]
  }
  TVIBinaryLoader = class(TDDabblerDLLLoader)
  private
    fCreateFunc: TVerInfoBinaryCreateFunc;
      {Reference to entry point in DLL used to create objects within DLL}
  public
    constructor Create;
      {Class constructor: loads DLL and imports required routine from it. An
      exception is raised if DLL can't be found or if routine can't be imported}
    property CreateFunc: TVerInfoBinaryCreateFunc read fCreateFunc;
      {Reference to the function in the DLL that is used to create objects
      within the DLL}
  end;


implementation


uses
  // Delphi
  Windows;


const
  cDLLName = 'VIBinData.dll';     // name of DLL binary version info code
  cEntryPoint = 'CreateInstance'; // name of function in DLL we require


{ TVIBinaryLoader }

constructor TVIBinaryLoader.Create;
  {Class constructor: loads DLL and imports required routine from it. An
  exception is raised if DLL can't be found or if routine can't be imported}
begin
  inherited Create(cDLLName);
  fCreateFunc := LoadRoutine(cEntryPoint, True);
end;

end.
