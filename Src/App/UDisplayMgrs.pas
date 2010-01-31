{
 * UDisplayMgrs.pas
 *
 * Defines a base class for all objects that manage GUI objects. It also defines
 * a class that maintains a list of display managers and passes on a global
 * timer event to the manager objects.
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
 * The Original Code is UDisplayMgrs.pas.
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


unit UDisplayMgrs;


interface


type

  {
  TDisplayMgr:
    Abstract base class for objects used to manage GUI objects. Registers class
    with global manager list object and responds to global timer events
    triggered by list manager

    Inheritance: TDisplayMgr -> [TObject]
  }
  TDisplayMgr = class(TObject)
  private // properties
    fTimerEnabled: Boolean;
  protected
    procedure TimerEvent; virtual; abstract;
      {Method called when the global timer is triggered: descendants override
      this method to take required action on timer events}
    property TimerEnabled: Boolean read fTimerEnabled write fTimerEnabled;
      {Determines if timer is enabled}
  public
    constructor Create;
      {Class constructor: records object with global list manager object}
    destructor Destroy; override;
      {Class destructor: removes this object from global list manager object}
  end;


implementation


uses
  // Delphi
  SysUtils, Contnrs, Windows;


type

  {
  TDisplayMgrList:
    Class that maintains a list of registered display managers and passes on a
    global timer event to the registered objects.

    Inheritance: TDisplayMgrList -> [TObject]
  }
  TDisplayMgrList = class(TObject)
  private
    fList: TObjectList;
      {List of display managers}
    fTimerID: Cardinal;
      {ID of Windows timer}
    fTimerInhibited: Boolean;
      {Flag noting when timer is inhibited: prevents timer triggering when
      previous event is executing}
  public
    constructor Create;
      {Class constructor: create owned list}
    destructor Destroy; override;
      {Class destructor: frees owned list object}
    procedure RegisterManager(const Mgr: TDisplayMgr);
      {Registers the given manager with the timer}
    procedure UnregisterManager(const Mgr: TDisplayMgr);
      {Unregisters the given manager object with the timer}
    procedure TimerEvent;
  end;


var
  pvtMgrList: TDisplayMgrList;
    {Private global display manager list object: used to record all program's
    display managers that need the heartbeat timer}


{ TDisplayMgrList }

procedure TimerProc(hwnd: HWND; uMsg, idEvent: UINT; dwTime: DWORD); stdcall;
  {Timer procedure call by Windows timer: calls the list object's timer event}
begin
  pvtMgrList.TimerEvent;
end;

constructor TDisplayMgrList.Create;
  {Class constructor: create owned list}
begin
  inherited;
  fList := TObjectList.Create(False);
end;

destructor TDisplayMgrList.Destroy;
  {Class destructor: frees owned list object}
begin
  fList.Free;
  inherited;
end;

procedure TDisplayMgrList.RegisterManager(const Mgr: TDisplayMgr);
  {Registers the given manager with the timer}
begin
  // Prevent timer from triggering during this method
  fTimerInhibited := True;
  try
    // Add manager object to list
    fList.Add(Mgr);
    if fList.Count = 1 then
      // First manager just added: start the timer
      fTimerID := SetTimer(0, 0, 500, @TimerProc);
  finally
    fTimerInhibited := False;
  end;
end;

procedure TDisplayMgrList.TimerEvent;
  {Called when global timer ticks: calls TDisplayMgr.TimerEvent for each
  registered display manager with an enabled timer}
var
  Idx: Integer;       // loops thru registered display managers
  Mgr: TDisplayMgr;   // reference to a display manager
begin
  // Do nothing if timer inhibited
  if fTimerInhibited then
    Exit;
  // Prevent timer from triggering again during this method
  fTimerInhibited := True;
  try
    // Loop thru each registered display manager
    for Idx := 0 to Pred(fList.Count) do
    begin
      // Call manager's timer event method if it has not disabled its timer code
      Mgr := fList[Idx] as TDisplayMgr;
      if Mgr.TimerEnabled then
        Mgr.TimerEvent;
    end;
  finally
    fTimerInhibited := False;
  end;
end;

procedure TDisplayMgrList.UnregisterManager(const Mgr: TDisplayMgr);
  {Unregisters the given manager object with the timer}
begin
  // Prevent timer from triggering during this method
  fTimerInhibited := True;
  try
    // Remove manager from list
    fList.Remove(Mgr);
    if fList.Count = 0 then
    begin
      // List is empty: stop the timer
      KillTimer(0, fTimerID);
      fTimerID := 0;
    end;
  finally
    fTimerInhibited := False;
  end;
end;


{ TDisplayMgr }

constructor TDisplayMgr.Create;
  {Class constructor: records object with global list manager object}
begin
  inherited;
  pvtMgrList.RegisterManager(Self);
end;

destructor TDisplayMgr.Destroy;
  {Class destructor: removes this object from global list manager object}
begin
  pvtMgrList.UnregisterManager(Self);
  inherited;
end;


initialization


// Create global display manager list object
pvtMgrList := TDisplayMgrList.Create;


finalization


// Free the display manager list object
FreeAndNil(pvtMgrList);

end.
