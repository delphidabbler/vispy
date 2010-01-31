{
 * UWidget.pas
 *
 * Defines the base case class for all GUI "widgets".
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
 * The Original Code is UWidget.pas.
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


unit UWidget;


interface


uses
  // Delphi
  Windows;


type

  {
  TWidgetParams:
    Parameters used in creation of widget windows.
  }
  TWidgetParams = record
    Style: UINT;        // window style
    ExStyle: UINT;      // extended window style
    ClassName: string;  // window class name
  end;


  {
  TWidget:
    Base class for all GUI "widgets". This class creates windows according to
    parameters provided by sub classes. Also provides properties common to all
    widgets.
  }
  TWidget = class(TObject)
  private // properties
    fHandle: HWND;
    fHelpContext: Integer;
    function GetCaption: string;
    procedure SetCaption(const Value: string);
    function GetHeight: Integer;
    function GetEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
  private
    fOwner: TObject;
      {Owning "card" window object}
    fBounds: TRect;
      {Bounding rectangle of control: set in constructor and used when window
      created}
  protected
    function GetParentWdw: HWND;
      {Returns window handle of widget's owner "card"}
    procedure CreateWindow; virtual;
      {Creates the widget's window using required parameters provided by
      descendant classes}
    procedure CreateParams(var Params: TWidgetParams); virtual;
      {Set widget's window creation parameters: in this base class we just set
      default windows style: sub classes override to create required windows}
  public
    constructor Create(Owner: TObject; const Bounds: TRect);
      {Class constructor: create widget and the window it wraps}
    property Handle: HWND read fHandle;
      {Windows handle of the widget}
    property Caption: string read GetCaption write SetCaption;
      {Text associated with the widget: this text may or may not be displayed in
      the control}
    property Enabled: Boolean read GetEnabled write SetEnabled;
      {Whether widget is enabled: setting this property enables or disables the
      widget's window}
    property Height: Integer read GetHeight;
      {Height of widget}
    property HelpContext: Integer read fHelpContext write fHelpContext;
      {Help context number associated with the widget. Owning "card" (window)
      handles display of help using this property}
  end;


implementation


uses
  // Delphi
  SysUtils, Messages,
  // Project
  UCard;


{ TWidget }

constructor TWidget.Create(Owner: TObject; const Bounds: TRect);
  {Class constructor: create widget and the window it wraps}
begin
  inherited Create;
  // Add the widget to the owning "card" window
  if Assigned(Owner) and (Owner is TCard) then
  begin
    (Owner as TCard).AddWidget(Self);
    fOwner := Owner;
  end;
  // Record bounds for use in CreateWindow
  fBounds := Bounds;
  // Create the widget's window
  CreateWindow;
end;

procedure TWidget.CreateParams(var Params: TWidgetParams);
  {Set widget's window creation parameters: in this base class we just set
  default windows style: sub classes override to create required windows}
begin
  ZeroMemory(@Params, SizeOf(Params));
  Params.Style := WS_CHILD or WS_VISIBLE;
end;

procedure TWidget.CreateWindow;
  {Creates the widget's window using required parameters provided by descendant
  classes}
var
  Params: TWidgetParams;  // widget creation parameters
begin
  // Get creation parameters
  CreateParams(Params);
  // Create window: raise exception if we can't create it
  fHandle := Windows.CreateWindowEx(
    Params.ExStyle,                 // use ExStyle from widget's parameters
    PChar(Params.ClassName),        // use class name from parameters
    nil,                            // don't set window text here
    Params.Style,                   // use window style from widget's parameters
    fBounds.Left,                   // set bounds as passed to constructor
    fBounds.Top,                    // ...
    fBounds.Right - fBounds.Left,   // ...
    fBounds.Bottom - fBounds.Top,   // ...
    GetParentWdw,                   // get parent window of widget
    0,                              // no menu
    MainInstance,                      // instance this module
    nil                             // no custom application data
  );
  if fHandle = 0 then
    raise Exception.Create('Can''t create widget ' + ClassName);
  // Set conrol's font to be same as parent
  SendMessage(
    Handle, WM_SETFONT, SendMessage(GetParentWdw, WM_GETFONT, 0, 0), 0
  );
end;

function TWidget.GetCaption: string;
  {Read accessor method for Caption property: returns text associated with
  underlying window}
var
  Len: Integer; // length of window text
begin
  Len := GetWindowTextLength(fHandle);
  if Len > 0 then
  begin
    SetLength(Result, Len);
    GetWindowText(fHandle, PChar(Result), Len);
  end
  else
    Result := '';
end;

function TWidget.GetEnabled: Boolean;
  {Read accessor from Enabled property: checks underlying control for presence
  of disabled window style}
begin
  Result := GetWindowLong(Handle, GWL_STYLE) and WS_DISABLED = 0;
end;

function TWidget.GetHeight: Integer;
  {Read accessor method for Height property: get height of underlying control}
var
  R: TRect; // window's bounding rectangle
begin
  GetWindowRect(Handle, R);
  Result := R.Bottom - R.Top;
end;

function TWidget.GetParentWdw: HWND;
  {Returns window handle of widget's owner "card"}
begin
  if Assigned(fOwner) then
    Result := (fOwner as TCard).Handle
  else
    Result := 0;
end;

procedure TWidget.SetCaption(const Value: string);
  {Write access method for Caption property: sets text of underlying window}
begin
  SetWindowText(fHandle, PChar(Value));
end;

procedure TWidget.SetEnabled(const Value: Boolean);
  {Write access method for Enabled property}
begin
  EnableWindow(Handle, Value);
end;

end.
