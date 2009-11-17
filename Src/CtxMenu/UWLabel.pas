{ ##
  @FILE                     UWLabel.pas
  @COMMENTS                 Defines a "widget" class that encapsulates a static
                            label control.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 30/05/2004
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
 * The Original Code is UWLabel.pas.
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


unit UWLabel;


interface


uses
  // Project
  UWidget;


type

  {
  TLabelWidget:
    Class that encapsulates a static label control that is parented by a "card"
    object.

    Inheritance: TLabelWidget -> TWidget -> [TObject]
  }
  TLabelWidget = class(TWidget)
  protected
    procedure CreateParams(var Params: TWidgetParams); override;
      {Sets required parameters for creation of (static) label window}
  end;


implementation


uses
  // Delphi
  Windows;


{ TLabelWidget }

procedure TLabelWidget.CreateParams(var Params: TWidgetParams);
  {Sets required parameters for creation of (static) label window}
begin
  inherited;
  Params.ExStyle := WS_EX_TRANSPARENT;
  Params.Style := Params.Style or SS_LEFTNOWORDWRAP;
  Params.ClassName := 'STATIC';
end;

end.
