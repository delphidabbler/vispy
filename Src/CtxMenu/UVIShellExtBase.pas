{
 * UVIShellExtBase.pas
 *
 * Defines a base class for Windows shell extension COM objects that process
 * version information.
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
 * The Original Code is UVIShellExtBase.pas.
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


unit UVIShellExtBase;


interface


uses
  // Delphi
  Windows, ShlObj, ActiveX,
  // Project
  IntfVerInfoReader, UShellExtBase, UFileReaderLoader;


type

  {
  TVIShellExtBase:
    Base class for shell extensions that handle version information: extends
    base class to detect whether file which shell extension is processing
    contains version information.

    Inheritance: TVIShellExtBase -> TShellExtBase -> TBaseCOMObj
      -> [TInterfacedObject]
  }
  TVIShellExtBase = class(TShellExtBase)
  private
    fReaderLoader: TVIFileReaderLoader;
      {Object that loads FVFileReader.dll}
    fVIQuery: IVerInfoFileQuery;
      {Object in FVFileReader.dll that enables check to be made if a file
      contains version information}
    fFileHasVerInfo: Boolean;
      {Object in FVFileReader.dll that enables check to be made if a file
      contains version information}
  protected
    function FileContainsVerInfo: HResult;
      {Returns whether current file contains version information (S_OK) or not
      (S_FALSE). If file name is '' then E_INVALIDARG is returned. E_FAIL is
      returned if any other error is encountered}
    property FileHasVerInfo: Boolean read fFileHasVerInfo;
      {This property is true if the file to be operated on contains version
      information and false if not, or if no file registered or there was an
      error reading the file}
    procedure ExecVIS(MsgWnd: HWND);
      {Executes Version Information Spy program to display required file name,
      passing the -shellex command line switch}
  protected
    { IShellExtInit }
    function Initialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; override; stdcall;
      {Initializes shell extension, records name of file to be passed to shell
      extension and also records whether file contains version information. We
      only accept one file. This method is called by Windows}
  public
    destructor Destroy; override;
      {Class destructor: frees owned object and file reader DLL}
  end;


implementation


uses
  // Delphi
  SysUtils, ShellAPI,
  // Project
  UGlobals, URegistry;


resourcestring
  // Error messages
  sCantCreateReader = 'Can''t create version info file reader object';
  sCantFindApp = 'Can''t locate ' + UGlobals.cLongSuiteName + '.';
  sCantRunApp = 'Can''t run ' + UGlobals.cLongSuiteName + '.';
  sErrorAdvice = 'Please re-install the program and try again. If this fails '
    + 'please contact the author.';


{ TVIShellExtBase }

destructor TVIShellExtBase.Destroy;
  {Class destructor: frees owned object and file reader DLL}
begin
  // Release query object in file reader DLL ...
  fVIQuery := nil;
  // ... and then release the DLL
  FreeAndNil(fReaderLoader);
  inherited;
end;

procedure TVIShellExtBase.ExecVIS(MsgWnd: HWND);
  {Executes Version Information Spy program to display required file name,
  passing the -shellex command line switch}

  // ---------------------------------------------------------------------------
  procedure DisplayMessage(const Msg: string; DlgType: Integer);
    {Displays given message using owner window supplied to DoInvokeCommand.
    Dialog displays icons according to given dialog type}
  begin
    MessageBox(MsgWnd, PChar(Msg), UGlobals.cLongSuiteName, MB_OK or DlgType);
  end;
  // ---------------------------------------------------------------------------

var
  FileVerPath: string;  // path to FileVer program
begin
  // Get location of FileVer program
  FileVerPath := URegistry.AppPath(UGlobals.cVISExe);
  if FileVerPath <> '' then
  begin
    // execute FileVer with -shellex switch (to show executed from shell
    // extension handler) and required file as a parameter
    if ShellExecute(
      MsgWnd,                               // window for any dialog
      nil,                                  // "open" operation by default
      PChar(FileVerPath),                   // path to file ver application
      PChar('"' + FileName + '" -shellex'), // params: file & -shellex switch
      nil,                                  // startup dir not specified
      SW_SHOW                               // show file ver normally
    ) <= 32 then
      // error occurred trying to run FileVer: say so
      DisplayMessage(sCantRunApp + #13#10#13#10 + sErrorAdvice, MB_ICONERROR)
  end
  else
    // can't find FileVer: say so
    DisplayMessage(sCantFindApp + #13#10#13#10 + sErrorAdvice, MB_ICONERROR)
end;

function TVIShellExtBase.FileContainsVerInfo: HResult;
  {Returns whether current file contains version information (S_OK) or not
  (S_FALSE). If file name is '' then E_INVALIDARG is returned. E_FAIL is
  returned if any other error is encountered}
begin
  if FileName <> '' then
  begin
    try
      // If we haven't yet loaded file reader DLL do so
      if not Assigned(fReaderLoader) then
      begin
        fReaderLoader := TVIFileReaderLoader.Create;
        // Create query object in DLL: use this to check for ver info in a file
        if Failed(fReaderLoader.CreateFunc(
          CLSID_VerInfoFileQuery, fVIQuery)
        ) then
          // Can't create reader: catastrophic failure
          raise Exception.Create(sCantCreateReader);
      end;
      // Check file for version info and return result
      if fVIQuery.FileContainsVersionInfo(PChar(FileName)) then
        Result := S_OK
      else
        Result := S_FALSE;
    except
      // An exception was raised: fail this call
      Result := E_FAIL;
    end;
  end
  else
    // File name is ''
    Result := E_INVALIDARG;
end;

function TVIShellExtBase.Initialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
  {Initializes shell extension, records name of file to be passed to shell
  extension and also records whether file contains version information. We only
  accept one file. This method is called by Windows}
begin
  // Call inherited method to get file name
  Result := inherited Initialize(pidlFolder, lpdobj, hKeyProgID);
  if not Failed(Result) then
  begin
    // Record if file contains version info
    case FileContainsVerInfo of
      S_OK:
        fFileHasVerInfo := True;
      S_FALSE:
        fFileHasVerInfo := False;
      E_FAIL, E_INVALIDARG:
      begin
        fFileHasVerInfo := False;
        Result := E_FAIL;
      end;
    end;
  end;
end;

end.
