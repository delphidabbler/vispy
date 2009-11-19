{ ##
  @PROJECT_NAME             Version Information Spy Shared Code
  @PROJECT_DESC             Code units shared between various Version
                            Information Spy applications and DLLs.
  @FILE                     UDLLLoader.pas
  @COMMENTS                 Defines base for classes used to dynamically load /
                            unload DLLs from a search path. Also defines a
                            descendant class acts as a base for classes that
                            search for DLLs in the application's path or in the
                            DelphiDabbler sub-folder of the system's Common
                            Files folder.
  @DEPENDENCIES             PJSysInfo unit from DelphiDabbler library.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 04/08/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 24/02/2003
      @COMMENTS             Changed name of TPJSoftDLLLoader class to
                            TDDabblerDLLLoader and made it now use place [Common
                            Files]\DelphiDabbler on search path rather than
                            [Common Files]\PJSoft.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 23/05/2004
      @COMMENTS             Changed method of operation of DLL loader - we no
                            longer count number of instances of the class that
                            have been created. Consequently:
                            + We now store the DLL handle in a field rather than
                              requiring a reference to an externally stored
                              handle.
                            + We no longer use an externally stored reference
                              count.
                            + Changed to get module name rather than ParamStr(0)
                              for program path. This is needed in case DLL is
                              loaded from other DLLs not loaded directly from
                              Version Info Spy or command line application.
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
 * The Original Code is UDLLLoader.pas.
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


unit UDLLLoader;


interface


uses
  // Project
  SysUtils, Classes;


type

  {
  TDLLLoader:
    Base class for classes used to dynamically load / unload DLLs from a search
    path. Also provides a helper function for loading routines from DLLs. This
    class is designed only as a base class and should not be instantiated
    directly.

    Inheritance: TDLLLoader -> [TObject]
  }
  TDLLLoader = class(TObject)
  private // properties
    function GetHandle: THandle;
  private
    fPaths: TStringList;
      {List of possible paths to search for DLL}
    fDLLFileName: string;
      {Name of DLL file name, without path}
    fHandle: THandle;
      {Handle to DLL}
    procedure LoadDLL;
      {Ensures the DLL is loaded. Searches for the DLL in the registered
      locations}
    procedure FreeDLL;
      {Unloads the DLL}
  protected
    function LoadRoutine(const RoutineName: string;
      const ErrCheck: Boolean): Pointer;
      {Loads the routine with the given name from the DLL and returns a pointer
      to it. If ErrCheck is true exceptions are raised if DLL is not loaded or
      if routine can't be found in DLL. When ErrCheck is false errors are not
      reported and method returns nil}
    procedure SetSearchPaths(const Paths: TStrings); virtual;
      {Loads list of paths to search for DLL: in this base class the only path
      is the current module's path. Path names must end in '\'}
    property Handle: THandle read GetHandle;
      {Handle to DLL: 0 if not loaded}
  public
    constructor Create(const DLLName: string);
      {Class constructor: creates an object that can be used to load the given
      DLL}
    destructor Destroy; override;
      {Class destructor: frees owned objects and DLL}
  end;


  {
  TDDabblerDLLLoader:
    Class that loads DLLs from either the same directory as the program or from
    the DelphiDabbler sub folder of the common files folder. This call should
    not be instantiated directly, but should be sub classed for specific DLLs.

    Inheritance: TDDabblerDLLLoader -> TDLLLoader -> [TObject]
  }
  TDDabblerDLLLoader = class(TDLLLoader)
  protected
    procedure SetSearchPaths(const Paths: TStrings); override;
      {Loads list of paths to search for DLL: in this class we add the path to
      the DelphiDabbler sub folder of the common file folder}
  public
    constructor Create(const DLLName: string);
      {Class constructor: creates an object that can be used to load the given
      DLL}
  end;


  {
  EDLLLoader:
    Class of exception raised by TDLLLoader class and sub classes.

    Inheritance: EDDLLoader -> [Exception] -> [TObject]
  }
  EDLLLoader = class(Exception);


implementation


uses
  // Delphi
  Windows,
  // DelphiDabbler library
  PJSysInfo,
  // Project
  UGlobals;


resourcestring
  // Error messages
  sCantFindRoutine = 'Can''t find routine "%0:s" in DLL "%1:s".';
  sCantLoadDLL = 'Can''t load DLL "%0:s".';


{ Helper routines }

function MakePathName(const Dir : string) : string;
  {Adds trailing '\' to any path that doesn't have one, unless Dir is empty
  string when no action is taken}
begin
  Result := Dir;
  if (Dir <> '') and (Dir[Length(Dir)] <> '\') then
    Result := Result + '\';
end;


{ TDLLLoader }

constructor TDLLLoader.Create(const DLLName: string);
  {Class constructor: creates an object that can be used to load the given DLL}
begin
  // Don't allow instances of this class to be created unless from sub class
  Assert(
    Self.ClassType <> TDLLLoader,
    'Can''t call TDLLLoader.Create directly: must call from sub class.'
  );
  inherited Create;
  // Create file paths list and load it
  fPaths := TStringList.Create;
  SetSearchPaths(fPaths);
  // Store DLL file name
  fDLLFileName := ExtractFileName(DLLName);
  // Load the DLL
  LoadDLL;
end;

destructor TDLLLoader.Destroy;
  {Class destructor: frees owned objects and DLL}
begin
  // Free the paths list
  fPaths.Free;
  // Free the DLL
  FreeDLL;
  inherited;
end;

procedure TDLLLoader.FreeDLL;
  {Unloads the DLL}
begin
  // Check if we need to free DLL
  if fHandle <> 0 then
  begin
    // free the DLL
    FreeLibrary(fHandle);
    fHandle := 0;
  end;
end;

function TDLLLoader.GetHandle: THandle;
  {Read accessor for Handle property}
begin
  Result := fHandle;
end;

procedure TDLLLoader.LoadDLL;
  {Ensures the DLL is loaded. Searches for the DLL in the registered locations}
var
  PathIdx: Integer;         // index into list of search paths
  FullDLLFileName: string;  // full file name of DLL in a search path
begin
  // Check if we've already loaded DLL:
  if fHandle = 0 then
  begin
    // DLL not loaded: try to load it
    // scan thru search paths until DLL found
    for PathIdx := 0 to Pred(fPaths.Count) do
    begin
      // set full file name for this path as check if file exists
      FullDLLFileName := fPaths[PathIdx] + fDLLFileName;
      if FileExists(FullDLLFileName) then
      begin
        // file exists: try to load and break out of loop if successful
        fHandle := LoadLibrary(PChar(FullDLLFileName));
        if fHandle <> 0 then
          Break;
      end;
    end;
  end;
end;

function TDLLLoader.LoadRoutine(const RoutineName: string;
  const ErrCheck: Boolean): Pointer;
  {Loads the routine with the given name from the DLL and returns a pointer to
  it. If ErrCheck is true exceptions are raised if DLL is not loaded or if
  routine can't be found in DLL. When ErrCheck is false errors are not reported
  and method returns nil}
begin
  // Assume we can't load routine
  Result := nil;
  if fHandle <> 0 then
  begin
    // DLL is loaded: try to get routine from it
    Result := GetProcAddress(fHandle, PChar(RoutineName));
    if not Assigned(Result) and ErrCheck then
      // We failed, and we are reporting errors so raise exception
      raise EDLLLoader.CreateFmt(sCantFindRoutine, [RoutineName, fDLLFileName]);
  end
  else
    // DLL not loaded: raise exception if we're reporting errors
    if ErrCheck then
      raise EDLLLoader.CreateFmt(sCantLoadDLL, [fDLLFileName]);
end;

procedure TDLLLoader.SetSearchPaths(const Paths: TStrings);
  {Loads list of paths to search for DLL: in this base class the only path is
  the current module's path. Path names must end in '\'}
var
  ModuleName: string; // name of current module
begin
  // Get name of current module
  SetLength(ModuleName, MAX_PATH);
  SetLength(
    ModuleName, GetModuleFileName(HInstance, PChar(ModuleName), MAX_PATH)
  );
  // Add module name to list of paths
  Paths.Add(MakePathName(ExtractFilePath(ModuleName)));
end;


{ TDDabblerDLLLoader }

constructor TDDabblerDLLLoader.Create(const DLLName: string);
  {Class constructor: creates an object that can be used to load the given DLL}
begin
  // Don't allow instances of this class to be created unless from sub class
  Assert(
    Self.ClassType <> TDDabblerDLLLoader,
    'Can''t call TDDabblerDLLLoader.Create directly: must call from sub class.'
  );
  inherited;
end;

procedure TDDabblerDLLLoader.SetSearchPaths(const Paths: TStrings);
  {Loads list of paths to search for DLL: in this class we add the path to the
  DelphiDabbler sub folder of the common file folder}
begin
  // Load any paths loaded by base class
  inherited;
  // Add the [Common Files]\DelphiDabbler\ folder to search list
  Paths.Add(
    MakePathName(TPJSystemFolders.CommonFiles) + cDeveloperAlias + '\'
  );
end;

end.
