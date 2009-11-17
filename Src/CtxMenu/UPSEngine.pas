{ ##
  @FILE                     UPSEngine.pas
  @COMMENTS                 Defines the class that wraps and accesses the file
                            reader engine from FVFileReader.dll and exposes a
                            IVerInfoReader object used to read version
                            information. The class is used to by the property
                            sheet shell extension.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 23/05/2004
      @COMMENTS             Original version.
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
 * The Original Code is UPSEngine.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UPSEngine;


interface


uses
  // Project
  IntfVerInfoReader, UFileReaderLoader;


type

  {
  TPSEngine:
    Class used to load version information from a file and exposes a
    IVerInfoReader object to access the version information. The class manages
    loading and freeing the reader object from FVFileReader.dll. Used by the
    property sheet extension.

    Inheritance: TPSEngine -> [TObject]
  }
  TPSEngine = class(TObject)
  private // properties
    function GetVerInfo: IVerInfoReader;
  private
    fLoader: TVIFileReaderLoader;
      {Object that loads the VI reader DLL and instantiates a reader object}
    fReader: IVerInfoFileReader;
      {Object used to read version information}
  public
    constructor Create;
      {Class constructor: loads VI reader DLL and get reader object from it}
    destructor Destroy; override;
      {Class destructor: frees VI reader object and release its DLL}
    function LoadFromFile(const FileName: string): Boolean;
      {Loads version information from given file and returns true on success and
      false on failure}
    property VerInfo: IVerInfoReader read GetVerInfo;
      {Object used to access version information: can be nil if no version
      information available}
  end;


implementation


uses
  // Delphi
  SysUtils, ComObj;


{ TPSEngine }

constructor TPSEngine.Create;
  {Class constructor: loads VI reader DLL and get reader object from it}
begin
  fLoader := TVIFileReaderLoader.Create;
  OleCheck(fLoader.CreateFunc(CLSID_VerInfoFileReader, fReader));
end;

destructor TPSEngine.Destroy;
  {Class destructor: frees VI reader object and release its DLL}
begin
  fReader := nil;   // must free this before unloading DLL
  FreeAndNil(fLoader);
  inherited;
end;

function TPSEngine.GetVerInfo: IVerInfoReader;
  {Read access method for VerInfo property}
begin
  if Assigned(fReader) then
    Result := fReader.VerInfo
  else
    Result := nil;
end;

function TPSEngine.LoadFromFile(const FileName: string): Boolean;
  {Loads version information from given file and returns true on success and
  false on failure}
begin
  // Use reader object to load version info
  Result := fReader.LoadFile(PChar(FileName));
end;

end.
