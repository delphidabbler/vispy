{
 * UStartup.pas
 *
 * Defines data types, constants and classes that handle start-up for the
 * application. This includes parsing the command line and determining if the
 * application should run or simply pass its command line to another instance of
 * the application.
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
 * The Original Code is UStartup.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2002-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UStartup;


interface


uses
  // Delphi
  Windows,
  // Project
  UGlobals, USettings;


const
  // Name of main form's window class: used by TStartup to find other instances
  // of the application
  cWdwClassName = cDeveloperAlias + '.' + cShortSuiteName + '.' + cVersion;

  // Watermark stored in data structure passed between instances of application
  // using WM_COPYDATA: used to ensure that the message came from another
  // instance of this application
  cCopyDataWaterMark: LongWord = $46563036; // = 'FV07'

type

  {
  TDataPacket:
    Structure used to pass between instances of application: carries filename
    passed on command line with bitmask representing switches (has some
    reserved records for potential use by later versions).
  }
  TDataPacket = record
    FileName: array[0..MAX_PATH] of Char;         // cmd line file name
    Switches: LongWord;                           // bitmask of switches
  end;

  {
  PDataPacket:
    Pointer to TDataPacket record.
  }
  PDataPacket = ^TDataPacket;


const
  // Parameters passed to program as command line switched:
  // a bit mask of these is made available in the TParams.Switches property
  Param_StartFromShellEx    = $00000001;    // -shellex switch


type

  {
  TParams:
    Class that interprets the command line passed to the program and exposes
    properties representing the parameters it contains.

    Inheritance: TParams -> [TObject]
  }
  TParams = class(TObject)
  private // properties
    fFileName: string;
    fSwitches: LongWord;
  public
    constructor Create;
      {Class constructor: processes command line settting properties as
      required}
    property FileName: string read fFileName;
      {First file name passed on command line: '' if no file was passed}
    property Switches: LongWord read fSwitches;
      {Bit mask representing valid switches found on command line: currently
      only -c is supported}
  end;


  {
  TStartup:
    Class that analyses the start-up condition of the program and determines
    whether or not the application should run or pass it's command line to
    another instance and terminate.

    Inheritance: TStartup -> [TObject]
  }
  TStartup = class(TObject)
  private
    fParams: TParams;
      {TParams object used to analyse the program's command line}
    function DuplicateAppInstWdw: HWND;
      {Finds if another instance of the application is running and returns its
      main window handle if so, or 0 if there is no other instance.
      **NOTE** this method must be called before our app's main window is
      created or its own main window will be found by this method call}
    function ActivateDuplicateAppInst(WndH: HWND): Boolean;
      {Activates the instance of the application with the given window handle
      and sends it a message containing information from this instance's command
      line. Returns true if the other instance ackowledges receipt of the info
      and false if not}
  public
    constructor Create;
      {Class constructor: create owned settings and params objects}
    destructor Destroy; override;
      {Class destructor: frees owned objects}
    function CanExecuteAPP: Boolean;
      {Determines whether application should be allowed to run or not: returns
      true if app should run and false if not. If app should not be allowed to
      run this method activates another instance of the application and passes
      the command line information to the other instance}
  end;


implementation


uses
  // Delphi
  SysUtils, StrUtils, Messages;


{ TParams }

constructor TParams.Create;
  {Class constructor: processes command line settting properties as required}
var
  ParamIdx: Integer;  // index into parameter strings
  Param: string;      // a single command line parameter
  Switch: string;     // switch with leading / or - removed and made lower case
begin
  inherited;
  // Set file name to '' => no file name to open
  fFileName := '';
  // Zero switched
  fSwitches := 0;
  // Scan all parameters
  for ParamIdx := 1 to ParamCount do
  begin
    Param := ParamStr(ParamIdx);
    // Check for switches
    if (Length(Param) > 1)
      and (Param[1] in ['-', '/']) then
    begin
      // We have a switch
      Switch := AnsiLowerCase(Copy(Param, 2, Length(Param) - 1));
      if Switch = 'shellex' then
        // switch indicates started from one of shell extensions
        fSwitches := fSwitches or Param_StartFromShellEx;
    end
    else
    begin
      // Not a switch: assume it's a file name - ignore all but first
      if fFileName = '' then
        fFileName := ParamStr(ParamIdx);
    end;
  end;
end;


{ TStartup }

function EnumWdwProc(WndH: HWND; Param: LPARAM): BOOL; stdcall;
  {Window enumeration procedure called by EnumWindows in DuplicateAppInstWdw
  method: checks if window is that of an instance of this application and
  returns its handle if so in Param, the stops further enumeration}
type
  PHWND = ^HWND;  // pointer to HWND type
var
  PFoundHWnd: PHWND;    // points to app's window handle
  WdwClassName: string; // class name of window given by WndH
begin
  // Get pointer to window handle variable passed from caller
  PFoundHWnd := PHWND(Param);
  // Get name of passed window's class and compare to ours
  SetLength(WdwClassName, 256);
  SetLength(
    WdwClassName, GetClassNameW(WndH, PChar(WdwClassName), Length(WdwClassName))
  );
  if AnsiSameText(WdwClassName, cWdwClassName) then
  begin
    // given window is an instance of this app: record it
    PFoundHWnd^ := WndH;
    // stop enumeration
    Result := False
  end
  else
    // not our window: continue enumeration
    Result := True;
end;

function TStartup.ActivateDuplicateAppInst(WndH: HWND): Boolean;
  {Activates the instance of the application with the given window handle and
  sends it a message containing information from this instance's command line.
  Returns true if the other instance ackowledges receipt of the info and false
  if not}
var
  CopyData: TCopyDataStruct;  // WM_COPYDATA data structure
  DataPacket: TDataPacket;    // Data packet passed in CopyData
begin
  // Bring other app to front
  SetForegroundWindow(WndH);
  // Set up data packet to be sent to other instance
  // store file name and switches in data packet
  FillChar(DataPacket.FileName, SizeOf(DataPacket.FileName), 0);
  StrPLCopy(
    DataPacket.FileName, fParams.FileName, SizeOf(DataPacket.FileName) - 1
  );
  DataPacket.Switches := fParams.Switches;
  // store info to be transmitted in require structure
  CopyData.lpData := @DataPacket;         // pointer to data
  CopyData.cbData := SizeOf(DataPacket);  // size of data
  CopyData.dwData := cCopyDataWaterMark;  // watermark in data field
  // Send the copy data message with the data we're sending
  // set result according to result returned from other instance
  Result := SendMessage(WndH, WM_COPYDATA, 0, LPARAM(@CopyData)) = 1;
end;

function TStartup.CanExecuteAPP: Boolean;
  {Determines whether application should be allowed to run or not: returns true
  if app should run and false if not. If app should not be allowed to run this
  method activates another instance of the application and passes the command
  line information to the other instance}
var
  AppWnd: HWND; // window handle of another instance
begin
  // Assume app can be executed
  Result := True;
  if fParams.Switches and Param_StartFromShellEx = Param_StartFromShellEx then
  begin
    // We were we called from one of shell extensions
    if Settings.ShellExRunsSingleInst then
    begin
      // Shell extension handler must only use single instance of app
      AppWnd := DuplicateAppInstWdw;
      if AppWnd <> 0 then
      begin
        // There is already another application running: pass params to it
        if ActivateDuplicateAppInst(AppWnd) then
          // We successfuly passed data to other app: so we don't exec this one
          Result := False;
      end;
    end;
  end
end;

constructor TStartup.Create;
  {Class constructor: create owned settings and params objects}
begin
  inherited;
  fParams := TParams.Create;
end;

destructor TStartup.Destroy;
  {Class destructor: frees owned objects}
begin
  fParams.Free;
  inherited;
end;

function TStartup.DuplicateAppInstWdw: HWND;
  {Finds if another instance of the application is running and returns its main
  window handle if so, or 0 if there is no other instance.
  **NOTE** this method must be called before our app's main window is created or
  its own main window will be found by this method call}
begin
  // Assume we find no other instance of this app
  Result := 0;
  // Scan all top level windows: stop if we find an instance of this app
  // any found window handle will be returned from enum prooc
  EnumWindows(@EnumWdwProc, LPARAM(@Result));
end;

end.
