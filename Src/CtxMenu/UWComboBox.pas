{
 * UWComboBox.pas
 *
 * Defines a "widget" class that encapsulates a combo-box control.
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
 * The Original Code is UWComboBox.pas.
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


unit UWComboBox;


interface


uses
  // Delphi
  Messages, Classes,
  // Project
  UWidget;


type

  {
  TComboBoxWidget:
    Class that encapsulates a combo-box control that is parented by a "card"
    object.

    Inheritance: TComboBoxWidget -> TWidget -> [TObject]
  }
  TComboBoxWidget = class(TWidget)
  private // properties
    fOnChange: TNotifyEvent;
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
  private
    procedure WMCommand(var Msg: TWMCommand); message WM_COMMAND;
      {Handles WM_COMMAND message: triggers OnChange event if this is a
      selection change notification}
  protected
    procedure DoChange; virtual;
      {Triggers OnChange event if assigned}
    procedure CreateParams(var Params: TWidgetParams); override;
      {Sets required parameters for creation of combo box window}
  public
    function Add(const S: string): Integer;
      {Adds the given string to the combo box}
    procedure Clear;
      {Clears the combo box}
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
      {Event triggered when selected item in combo box changes}
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
      {Index of selected item in combo box: -1 if nothing selected}
 end;


implementation


uses
  // Delphi
  Windows;


{ TComboBoxWidget }

function TComboBoxWidget.Add(const S: string): Integer;
  {Adds the given string to the combo box}
begin
  Result := SendMessage(Handle, CB_ADDSTRING, 0, LPARAM(PChar(S)));
end;

procedure TComboBoxWidget.Clear;
  {Clears the combo box}
begin
  SendMessage(Handle, CB_RESETCONTENT, 0, 0);
end;

procedure TComboBoxWidget.CreateParams(var Params: TWidgetParams);
  {Sets required parameters for creation of combo box window}
begin
  inherited;
  Params.Style := Params.Style or WS_TABSTOP
    or CBS_DROPDOWNLIST or CBS_HASSTRINGS;
  Params.ClassName := 'COMBOBOX';
end;

procedure TComboBoxWidget.DoChange;
  {Triggers OnChange event if assigned}
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

function TComboBoxWidget.GetItemIndex: Integer;
  {Read accessor for ItemIndex property}
begin
  Result := SendMessage(Handle, CB_GETCURSEL, 0, 0);
end;

procedure TComboBoxWidget.SetItemIndex(const Value: Integer);
  {Write accessot for ItemIndex property}
begin
  SendMessage(Handle, CB_SETCURSEL, Value, 0);
end;

procedure TComboBoxWidget.WMCommand(var Msg: TWMCommand);
  {Handles WM_COMMAND message: triggers OnChange event if this is a selection
  change notification}
begin
  if (Msg.Ctl = Handle) and (Msg.NotifyCode = CBN_SELCHANGE) then
  begin
    DoChange;
    Msg.Result := 0;  // 0 result indicates we handled message
  end;
end;

end.
