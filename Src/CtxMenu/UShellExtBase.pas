{
 * UShellExtBase.pas
 *
 * Defines a base class for Windows shell extension COM objects.
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
 * The Original Code is UShellExtBase.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UShellExtBase;


interface


uses
  // Delphi
  Windows, ShlObj, ActiveX,
  // Project
  UBaseCOMObj;

type

  {
  TShellExtBase:
    Base class for Windows shell extension COM objects. Implements core shell
    extension functionality.

    Inheritance: TShellExtBase -> TBaseCOMObj -> [TInterfacedObject]
  }
  TShellExtBase = class(TBaseCOMObj, IShellExtInit)
  private // properties
    fFileName: string;
  protected
    property FileName: string read fFileName;
      {Name of file shell extension is to operate on: '' if no file}
  protected
    { IShellExtInit }
    function Initialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; virtual; stdcall;
      {Initializes shell extension and records name of file to be passed to
      shell extension. We only accept one file: we return E_FAIL if >1 being
      operated on. This method is called by Windows}
  end;


implementation


uses
  // Delphi
  ShellAPI;


{ TShellExtBase }

function TShellExtBase.Initialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
  {Initializes shell extension and records name of file to be passed to shell
  extension. We only accept one file: we return E_FAIL if >1 being operated on.
  This method is called by Windows}
var
  Medium: TStgMedium; // contains details of selected file
  Format: TFormatEtc; // informs system of format of data requested
begin
  // Assume no file is accepted
  fFileName := '';
  // Check that IDataObject instance is assigned
  if not Assigned(lpdobj) then
  begin
    Result := E_FAIL;
    Exit;
  end;
  // Set up format structure (boilerplate code): used to get IDataObject data
  with Format do
  begin
    cfFormat := CF_HDROP;
    ptd := nil;
    dwAspect := DVASPECT_CONTENT;
    lIndex := -1;
    tymed := TYMED_HGLOBAL;
  end;
  // Get information about selected files in Medium
  Result := lpdobj.GetData(Format, Medium);
  if Failed(Result) then
    Exit;
  try
    // Get number of files selected using handle in Medium structure
    // (we only accept one file)
    if ShellAPI.DragQueryFile(Medium.hGlobal, $FFFFFFFF, nil, 0) = 1 then
    begin
      // set length of file name field and read file name
      SetLength(
        fFileName,
        ShellAPI.DragQueryFile(Medium.hGlobal, 0, nil, 0)
      );
      ShellAPI.DragQueryFile(Medium.hGlobal, 0, PChar(fFileName), MAX_PATH);
      // assume this function has succeeded
      Result := NOERROR;
    end
    else
      // more than one file
      Result := E_FAIL;
  finally
    // free the storage medium
    ReleaseStgMedium(Medium);
  end;
end;

end.
