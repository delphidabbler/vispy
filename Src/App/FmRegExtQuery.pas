{ ##
  @FILE                     FmRegExtQuery.pas
  @COMMENTS                 Defines a dialog box class that queries which (if
                            any) shell extension to register as file extension
                            with.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 31/05/2004
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
 * The Original Code is FmRegExtQuery.pas.
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


unit FmRegExtQuery;


interface


uses
  // Delphi
  StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmGenericOKDlg;


type

  {
  TRegisteredServers:
    Set that specifies possible shell extension COM objects that can be
    registered with an extension.
  }
  TRegisteredServers = set of (rsPropSheet, rsCtxMenu);

  {
  TRegExtQueryDlg:
    Implements a dialog box class that queries which (if any) shell extension to
    register as file extension with.

    Inheritance: TCtxMenuDlg -> TGenericOKDlg -> TGenericDlg -> THelpAwareForm
      -> TBaseForm -> [TForm]
  }
  TRegExtQueryDlg = class(TGenericOKDlg)
    lblDesc: TLabel;
    cbCtxMenu: TCheckBox;
    cbPropSheet: TCheckBox;
  private // properties
    fExtension: string;
    function GetRegExtensions: TRegisteredServers;
    procedure SetRegExtensions(const Value: TRegisteredServers);
    procedure SetExtension(const Value: string);
  public
    property Extension: string
      read fExtension write SetExtension;
      {Extension under consideration: used for display purposes only}
    property RegExtensions: TRegisteredServers
      read GetRegExtensions write SetRegExtensions;
      {Set indicating which shell extension to register extension with}
  end;


implementation


uses
  // Delphi
  SysUtils;


{$R *.dfm}

resourcestring
  // Caption for dialog box's label
  sDescription = 'Select which explorer extension(s) to register for use with'
    + ' %s files.';


{ TRegExtQueryDlg }

function TRegExtQueryDlg.GetRegExtensions: TRegisteredServers;
  {Read accessor for RegExtensions property: returns set that depends on state
  of check boxes}
begin
  Result := [];
  if cbCtxMenu.Checked then
    Include(Result, rsCtxMenu);
  if cbPropSheet.Checked then
    Include(Result, rsPropSheet);
end;

procedure TRegExtQueryDlg.SetExtension(const Value: string);
  {Write accessor for Extension method: displays extension in label on form that
  provides description of usage}
begin
  fExtension := Value;
  lblDesc.Caption := Format(sDescription, [fExtension]);
end;

procedure TRegExtQueryDlg.SetRegExtensions(const Value: TRegisteredServers);
  {Write accessor for RegExtensions property: checks check boxes according to
  property value}
begin
  cbCtxMenu.Checked := rsCtxMenu in Value;
  cbPropSheet.Checked := rsPropSheet in Value;
end;

end.
