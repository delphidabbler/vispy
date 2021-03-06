{
 * FmBaseTabbedDlg.pas
 *
 * Provides a base class for tabbed dialog boxes that saves and restores the
 * last used tab.
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
 * The Original Code is FmBaseTabbedDlg.pas.
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


unit FmBaseTabbedDlg;


interface


uses
  // Delphi
  ComCtrls, StdCtrls, Controls, ExtCtrls, Classes,
  // Project
  FmGenericOKDlg;


type

  {
  TBaseTabbedDlg:
    Base class for tabbed dialog boxes that saves and restores the last used
    tab via the settings object. Also hides the bevel inherited from
    TGenericOKDlg.

    Inheritance: TBaseTabbedDlg -> TGenericOKDlg -> TGenericDlg
      -> THelpAwareForm -> TBaseForm -> [TForm]
  }
  TBaseTabbedDlg = class(TGenericOKDlg)
    pcMain: TPageControl;
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;


implementation


uses
  // Project
  USettings;


{$R *.dfm}


{ TBaseTabbedDlg }

procedure TBaseTabbedDlg.FormDestroy(Sender: TObject);
  {Save record of active tab sheet}
begin
  inherited;
  Settings.CurrentTabSheetIdx[Self] := pcMain.ActivePageIndex;
end;

procedure TBaseTabbedDlg.FormShow(Sender: TObject);
  {Select last used tab sheet}
begin
  inherited;
  pcMain.ActivePageIndex := Settings.CurrentTabSheetIdx[Self];
end;

end.
