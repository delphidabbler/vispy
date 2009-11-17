{ ##
  @FILE                     FmHelpAware.pas
  @COMMENTS                 Implements a form base class descends from TBaseForm
                            and adds awareness of the F1 to access help. Also
                            provides code to access help files using the name of
                            a descendant form as a keyword.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 20/10/2004
      @COMMENTS             Original version
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
 * The Original Code is FmHelpAware.pas.
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


unit FmHelpAware;


interface


uses
  // Delphi
  Classes,
  // Projct
  FmBase;


type

  {
  THelpActivator:
    Enumerated type of flags passed to DisplayHelp and CustomHelpKeyword to tell
    how help was activated.
  }
  THelpActivator = (
    haF1,         // F1 key was pressed
    haButton,     // Help button was pressed
    haOther       // Other method of activation
  );


  {
  THelpAwareForm:
    Form class that provides help functionality and F1 key awareness to
    descendant forms.

    Inheritance: THelpAwareForm -> TBaseForm -> [TForm]
  }
  THelpAwareForm = class(TBaseForm)
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  protected
    procedure DisplayHelp(Activator: THelpActivator = haOther); overload;
      virtual;
      {Displays help according to various help related form properties: uses
      keyword provided by form properties, or if they are not set, by the
      CustomHelpKeyword method. The Activator parameter informs how the help was
      activated}
    procedure DisplayHelp(const Keyword: string); overload; virtual;
      {Displays help using the given A-link keyword}
    procedure DisplayHelp(const HelpContext: THelpContext); overload; virtual;
      {Display given help context}
    function CustomHelpKeyword(Activator: THelpActivator): string; virtual;
      {Returns the help A-link keyword to be used if help context or keyword is
      not supplied via form properties. By default this returns the name of the
      form, but this can be overridden in descendant forms. The Activator
      parameter informs how the help was activated}
  end;


implementation


uses
  // Delphi
  Windows, Forms;


{$R *.dfm}


function THelpAwareForm.CustomHelpKeyword(Activator: THelpActivator): string;
  {Returns the help A-link keyword to be used if help context or keyword is not
  supplied via form properties. By default this returns the name of the form,
  but this can be overridden in descendant forms. The Activator parameter
  informs how the help was activated}
begin
  Result := Self.Name;
end;

procedure THelpAwareForm.DisplayHelp(Activator: THelpActivator);
  {Displays help according to various help related form properties: uses keyword
  provided by form properties, or if they are not set, by the CustomHelpKeyword
  method. The Activator parameter informs how the help was activated}
begin
  if HelpContext = 0 then
  begin
    // No help context number specified: we'll use an A-link keyword
    if (HelpType = htKeyword) and (HelpKeyword <> '') then
      // key word property specified: use it
      DisplayHelp(HelpKeyword)
    else
      // no key word specified: use name of form
      DisplayHelp(CustomHelpKeyword(Activator))
  end
  else
    // Help context number specified: use it
    DisplayHelp(HelpContext);
end;

procedure THelpAwareForm.DisplayHelp(const Keyword: string);
  {Displays help using the given A-link keyword}
begin
  Application.HelpKeyword(Keyword);
end;

procedure THelpAwareForm.DisplayHelp(const HelpContext: THelpContext);
  {Display given help context}
begin
  Application.HelpContext(HelpContext);
end;

procedure THelpAwareForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  {Trap form key-down event. If FI key pressed with no modifiers we display
  help}
begin
  inherited;
  if (Key = VK_F1) and (Shift = []) then
  begin
    // F1 pressed with no modifier: display help
    DisplayHelp(haF1);
    Key := 0;
  end;
end;

end.
