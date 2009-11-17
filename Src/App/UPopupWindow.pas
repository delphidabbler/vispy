{ ##
  @FILE                     UPopupWindow.pas
  @COMMENTS                 Implements a hint-style window used to display
                            popups over the main GUI controls. There is a delay
                            between requesting the window and it popping up on
                            screen.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
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
 * The Original Code is UPopupWindow.pas.
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


unit UPopupWindow;


interface


uses
  // Delphi
  Classes, Controls, Messages, Windows;


type

  {
  TPopupWdwState:
    The various states of a popup window.
  }
  TPopupWdwState = (
    wsHidden,   // window is hidden
    wsPending,  // window is waiting to be shown
    wsShowing   // window is currently displayed
  );

  {
  TPopupWindow:
    A hint-style window used to display popups over the main GUI controls. There
    is a delay between requesting the window and it popping up on screen.

    Inheritance: TPopupWindow -> [THintWindow]
  }
  TPopupWindow = class(THintWindow)
  private
    fState: TPopupWdwState;
      {Display state of popup window}
    fControl: TWinControl;
      {Owning control}
    fTimer: Cardinal;
      {Identifier of Windows timer use to delay pop-up of the window}
    fPending: record
      Pos: TPoint;  // top left corner where window to be displayed
      Text: string; // text to be displayed in window
    end;
      {Records details of pending window}
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
      {Event triggered by timer: displays any pending window}
    procedure DoDisplay;
      {Displays any pending popup window: does nothing if we're not waiting to
      display a window}
    procedure StartTimer;
      {Starts the timer used to delay appearance of popup window}
    procedure StopTimer;
      {Stops the popup timer}
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor: creates hidden popup window}
    destructor Destroy; override;
      {Class destructor: closes popup window if displayed}
    procedure Close;
      {Closes popup window if open}
    procedure DisplayPopup(Pos: TPoint; const Text: string);
      {Records details of a popup window and starts timer to delay the window
      appearing}
  end;


implementation


uses
  // Delphi
  SysUtils;


{ TPopupWindow }

procedure TPopupWindow.Close;
  {Closes popup window if open}
begin
  // Close any open window
  if fState = wsShowing then
    ReleaseHandle;
  // Stop timer if active
  StopTimer;
  // Note that window is hidden: required even if not showing - could be pending
  fState := wsHidden;
end;

constructor TPopupWindow.Create(AOwner: TComponent);
  {Class constructor: creates hidden popup window}
begin
  inherited;
  // Record reference to owner control and note its hidden
  fControl := AOwner as TWinControl;
  fState := wsHidden;
end;

destructor TPopupWindow.Destroy;
  {Class destructor: closes popup window if displayed}
begin
  Close;
  inherited;
end;

procedure TPopupWindow.DisplayPopup(Pos: TPoint; const Text: string);
  {Records details of a popup window and starts timer to delay the window
  appearing}
begin
  // Close any open window
  Close;
  // Record popup position and window text
  fPending.Pos := Pos;
  fPending.Text := Text;
  // Note display of popup is pending and start timer that will display it
  fState := wsPending;
  StartTimer;
end;

procedure TPopupWindow.DoDisplay;
  {Displays any pending popup window: does nothing if we're not waiting to
  display a window}
var
  ScreenPos: TPoint;  // popup position in screen co-ords
  PopupRect: TRect;   // bounding rectanlge of popup window
begin
  // Stop the timer if running
  StopTimer;
  if fState = wsPending then
  begin
    // Show the window
    // note it's showing
    fState := wsShowing;
    // work out bounding rectangle of popup window
    ScreenPos := fControl.ClientToScreen(fPending.Pos);
    PopupRect := CalcHintRect(200, fPending.Text, nil);
    OffsetRect(PopupRect, ScreenPos.X, ScreenPos.Y + 16);
    // display the window
    ActivateHint(PopupRect, fPending.Text);
  end;
end;

procedure TPopupWindow.StartTimer;
  {Starts the timer used to delay appearance of popup window}
begin
  if fTimer = 0 then
    fTimer := SetTimer(Handle, 1, 500, nil);
end;

procedure TPopupWindow.StopTimer;
  {Stops the popup timer}
begin
  if fTimer <> 0 then
  begin
    KillTimer(Handle, fTimer);
    fTimer := 0;
  end;
end;

procedure TPopupWindow.WMTimer(var Msg: TWMTimer);
  {Event triggered by timer: displays any pending window}
begin
  DoDisplay;
end;

end.
