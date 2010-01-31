{
 * FmBase.pas
 *
 * Implements a form that provides the ancestor for all forms in the
 * application. Provides default names for form window classes along with some
 * routines that display a basic, aligned, pop-up dialog box.
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
 * The Original Code is FmBase.pas.
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


unit FmBase;


interface


uses
  // Delphi
  Controls, Forms;


type

  {
  TBaseForm:
    Base class for all forms in application. Sets a unique window class name for
    derived forms and provides for customisation of the name.

    Inheritance: TBaseForm -> [TForm]
  }
  TBaseForm = class(TForm)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
      {Sets window class name to that provided by WindowClassName method}
    function WindowClassName: string; virtual;
      {Returns name of form's window class: this is a name comprised of program
      and form class name. Override this method to provide a custom name}
  end;


implementation


uses
  // Delphi
  SysUtils,
  // Project
  UGlobals;


{$R *.dfm}


{ TBaseForm }

procedure TBaseForm.CreateParams(var Params: TCreateParams);
  {Sets window class name to that provided by WindowClassName method}
var
  ClassName: string;  // window class name
begin
  inherited;
  ClassName := WindowClassName;
  if ClassName <> '' then
    StrLCopy(Params.WinClassName, PChar(ClassName), 62);
end;

function TBaseForm.WindowClassName: string;
  {Returns name of form's window class: this is a name comprised of program
  and form class name}
begin
  Result := cDeveloperAlias + '.'
    + cShortSuiteName + '.'
    + Copy(ClassName, 2, MaxInt);
end;

end.
