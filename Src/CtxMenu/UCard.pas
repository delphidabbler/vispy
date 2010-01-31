{
 * UCard.pas
 *
 * Defines a class that encapsulates a window and the "widgets" it contains.
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
 * The Original Code is UCard.pas
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


unit UCard;


interface


uses
  // Delphi
  Windows, Contnrs, Messages,
  // Project
  UWidget;


type

  {
  TCard:
    Class that encapsulates a  window and the "widgets" it contains.
  }
  TCard = class(TObject)
  private // properties
    fHandle: HWND;
  private
    fWidgets: TObjectList;
      {List that stores widget objects that wrap child window objects}
    procedure WMHelp(var Msg: TWMHelp); message WM_HELP;
      {Handles WM_HELP message: calls WinHelp using help context of widget
      associated with window handle provided by help message}
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;
      {WM_COMMAND message handler: we pass message on to widget with window
      handle specified in message}
  protected
    function FindWidgetFromHandle(Wnd: HWND): TWidget;
      {Returns widget object accosiated with the given window handle: i.e. the
      widget object that wraps the child window with the given handle. Returns
      nil if no widget is found}
    function TextHeight: Integer;
      {Returns the height of text in the window's default font}
    procedure CreateControls; virtual; abstract;
      {Abstract method overridden in sub-classes to create the controls that are
      hosted by the "card"}
  public
    constructor Create(ParentWdw: HWND);
      {Class constructor: creates a property sheet "card" object associated with
      the given parent window}
    destructor Destroy; override;
      {Class destructor: frees owned objects}
    procedure AddWidget(AWidget: TWidget);
      {Add a widget to the property sheet card}
    property Handle: HWND read fHandle;
      {Handle of window associated the "card"}
  end;


implementation


uses
  // Project
  UGlobals;


{ TCard }

procedure TCard.AddWidget(AWidget: TWidget);
  {Add a widget to the property sheet card}
begin
  // Simply add widget to widget list
  fWidgets.Add(AWidget);
end;

constructor TCard.Create(ParentWdw: HWND);
  {Class constructor: creates a property sheet "card" object associated with the
  given parent window}
begin
  inherited Create;
  // Record window handle
  fHandle := ParentWdw;
  // Create object list to store widgets
  fWidgets := TObjectList.Create; // list owns objects
  // Create the controls to be stored on the property sheet card
  CreateControls;
end;

destructor TCard.Destroy;
  {Class destructor: frees owned objects}
begin
  // Free list of widget objects: freeing list frees the objects
  fWidgets.Free;
  inherited;
end;

function TCard.FindWidgetFromHandle(Wnd: HWND): TWidget;
  {Returns widget object accosiated with the given window handle: i.e. the
  widget object that wraps the child window with the given handle. Returns nil
  if no widget is found}
var
  Idx: Integer; // loops thru all widgets owned by the "card"
begin
  // loop thru all widgets in list looking for one with require handle
  Result := nil;
  for Idx := 0 to Pred(fWidgets.Count) do
  begin
    if (fWidgets[Idx] as TWidget).Handle = Wnd then
    begin
      Result := fWidgets[Idx] as TWidget;
      Exit;
    end;
  end;
end;

function TCard.TextHeight: Integer;
  {Returns the height of text in the window's default font}
var
  DC: HDC;          // device context of window
  TM: TTextMetric;  // text metric structure: contains font height
begin
  // We use GetTextMetrics API to get font height from window's DC
  DC := GetDC(Handle);
  try
    GetTextMetrics(DC, TM);
    Result := TM.tmHeight;
  finally
    ReleaseDC(Handle, DC);
  end;
end;

procedure TCard.WMCommand(var Msg: TWMCommand);
  {WM_COMMAND message handler: we pass message on to widget with window handle
  specified in message}
var
  Widget: TWidget;  // reference to required widget
begin
  // Find widget associated with given window handle
  Widget := FindWidgetFromHandle(Msg.Ctl);
  if Assigned(Widget) then
    // Pass message on to required widget
    Widget.Dispatch(Msg);
end;

procedure TCard.WMHelp(var Msg: TWMHelp);
  {Handles WM_HELP message: calls WinHelp using help context of widget
  associated with window handle provided by help message}
var
  Widget: TWidget;  // reference to widget
begin
  // Find widget associated with given window handle
  Widget := FindWidgetFromHandle(Msg.HelpInfo.hItemHandle);
  // If widget found and it has a help keyword, display help
  if Assigned(Widget) and (Widget.HelpContext <> 0) then
    WinHelp(
      Handle,
      UGlobals.cShExtHelpFile,
      HELP_CONTEXTPOPUP,
      Widget.HelpContext
    );
  // Indicate we handled message
  Msg.Result := 1;
end;

end.

