{ ##
  @FILE                     UTempFiles.pas
  @COMMENTS                 Implements a class that produces unique temporary
                            file names without creating them and deletes any
                            existing files when the class is destroyed.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 17/08/2003
      @COMMENTS             Revised method used to produce temp file names from
                            sequential numbering to random numbering. Also
                            improved method used to build file names and record
                            Windows temporary folder name.
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
 * The Original Code is UTempFiles.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2003 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 * 
 * ***** END LICENSE BLOCK *****
}


unit UTempFiles;


interface


uses
  // Delphi
  Classes;


type
  {
  TTempFiles:
    Class that produces unique temporary file names (without creating them) and
    deletes any existing files when the class is destroyed.

    Inheritance: TTempFiles -> [TObject]
  }
  TTempFiles = class(TObject)
  private
    fFileList: TStringList;
      {List of generated files}
    fTempFolderPath: string;
      {Temporary folder name}
    procedure DeleteFiles;
      {Deletes all the file names we've allocated: assumes that each file we've
      generated has been created}
  public
    constructor Create;
      {Class constructor: initialises object and create owned file list}
    destructor Destroy; override;
      {Class destructor: deletes all temp files we've allocated and frees owned
      file list object}
    function TempFilePath(const Ext: string): string;
      {Returns a fully qualified, unique temporary file name with given
      extension}
end;


implementation


uses
  // Delphi
  SysUtils, Windows;


const
  // Format of temporay file names
  cFileFmt = '~tmp%0.4X.%s';


{ Helper function }

function GetTempFolderPath: string;
  {Returns fully qualified name of current temporary folder}
var
  PathBuf: array[0..MAX_PATH] of Char;  // buffer to hold name returned from API
begin
  if Windows.GetTempPath(MAX_PATH, PathBuf) <> 0 then
  begin
    Result := PathBuf;
    if Result[Length(Result)] <> '\' then
      Result := Result + '\';
  end
  else
    Result := 'C:\';
end;


{ TTempFiles }

constructor TTempFiles.Create;
  {Class constructor: initialises object and create owned file list}
begin
  inherited Create;
  // Initialise random number generator used to generate file names
  Randomize;
  // Create list used to record temp files
  fFileList := TStringList.Create;
  // Record path to Windows temp folder
  fTempFolderPath := GetTempFolderPath;
end;

destructor TTempFiles.Destroy;
  {Class destructor: deletes all temp files we've allocated and frees owned
  file list object}
begin
  DeleteFiles;
  fFileList.Free;
  inherited Destroy;
end;

function TTempFiles.TempFilePath(const Ext: string): string;
  {Returns a fully qualified, unique temporary file name with given extension}
var
  ID: LongWord;       // random id that forms part of file name
  FileName: string;   // name of generated file
begin
  // Generate random file names until non-existant file is found
  repeat
    ID := Random(High(Word));
    FileName := Format(cFileFmt, [ID, Ext]);
  until not SysUtils.FileExists(fTempFolderPath + FileName);
  // Record file name and return it along with path to temp folder
  fFileList.Add(FileName);
  Result := fTempFolderPath + FileName;
end;

procedure TTempFiles.DeleteFiles;
  {Deletes all the file names we've allocated: assumes that each file we've
  generated has been created}
var
  I: Integer; // loops thru all allocated file names
begin
  for I := 0 to Pred(fFileList.Count) do
    SysUtils.DeleteFile(fTempFolderPath + fFileList[I]);
end;

end.
