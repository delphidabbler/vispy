{ ##
  @FILE                     FmGenericOKDlg.pas
  @COMMENTS                 Implements a dialog box base class derived from
                            TGenericDlg that adds an OK and Cancel button to
                            dialog.
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
 * The Original Code is FmGenericOKDlg.pas.
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


unit FmGenericOKDlg;


interface


uses
  // Delphi
  StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmGenericDlg;


type

  {
  TGenericOKDlg:
    Generic OK dialog box used as a base class for dialog boxes that permit
    editing of data. It adds OK and Cancel buttons to the form that close the
    dialog box with the appropriate modal result.
  }
  TGenericOKDlg = class(TGenericDlg)
    btnCancel: TButton;
    btnOK: TButton;
  protected
    procedure ArrangeForm; override;
      {Positions controls and sets form size according to body panel dimensions}
  end;


implementation


{$R *.DFM}


{ TGenericOKDlg }

procedure TGenericOKDlg.ArrangeForm;
  {Positions controls and sets form size according to body panel dimensions}
begin
  // Arrange inherited controls and size the form
  inherited;
  // Arrange OK and Cancel buttons
  btnOK.Top := btnHelp.Top;
  btnCancel.Top := btnOK.Top;
  if btnHelp.Visible then
    btnCancel.Left := btnHelp.Left - btnCancel.Width - 4
  else
    btnCancel.Left := btnHelp.Left;
  btnOK.Left := btnCancel.Left - btnOK.Width - 4;
end;

end.
