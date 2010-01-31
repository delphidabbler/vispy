{
 * UWButton.pas
 *
 * Defines a "widget" class that encapsulates a button control.
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
 * The Original Code is UWButton.pas.
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


unit UWButton;


interface


uses
  // Delphi
  Messages, Classes,
  // Project
  UWidget;


type

  {
  TButtonWidget:
    Class that encapsulates a button control that is parented by a "card"
    object.

    Inheritance: TButtonWidget -> TWidget -> [TObject]
  }
  TButtonWidget = class(TWidget)
  private // properties
    fOnClick: TNotifyEvent;
  private
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;
      {Handles WM_COMMAND message: triggers OnClick event if this is a button
      click notification}
  protected
    procedure DoClick; virtual;
      {Triggers OnClick event if event handler is assigned}
    procedure CreateParams(var Params: TWidgetParams); override;
      {Sets required parameters for creation of button window}
  public
    property OnClick: TNotifyEvent read fOnClick write fOnClick;
      {Event triggered when button is clicked}
  end;


implementation


uses
  // Delphi
  Windows;

{ TButtonWidget }

procedure TButtonWidget.CreateParams(var Params: TWidgetParams);
  {Sets required parameters for creation of button window}
begin
  inherited;
  Params.Style := Params.Style or WS_TABSTOP or BS_PUSHBUTTON;
  Params.ClassName := 'BUTTON';
end;

procedure TButtonWidget.DoClick;
  {Triggers OnClick event if event handler is assigned}
begin
  if Assigned(OnClick) then
    OnClick(Self);
end;

procedure TButtonWidget.WMCommand(var Msg: TWMCommand);
  {Handles WM_COMMAND message: triggers OnClick event if this is a button click
  notification}
begin
  if (Msg.Ctl = Handle) and (Msg.NotifyCode = BN_CLICKED) then
  begin
    DoClick;
    Msg.Result := 0;  // 0 result indicates we handled message
  end;
end;

end.
