{
 * FmFixedSourceReport.pas
 *
 * Implements a dialog box that displays the decompiled source code of the
 * version information, with any inconsistencies and errors corrected.
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
 * The Original Code is FmFixedSourceReport.pas.
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


unit FmFixedSourceReport;


interface


uses
  // Delphi
  Dialogs, StdCtrls, Forms, Controls, ExtCtrls, Classes,
  // Project
  FmSourceReport, FrViewerBase, FrMemoViewer;

type

  {
  TFixedSourceReportDlg:
    Dialog box that displays the decompiled source code of the version
    information, with any inconsistencies and errors corrected.

    Inheritance: TFixedSourceReportDlg -> TSourceReportDlg -> TTextReportDlg
      -> TReportBaseDlg -> TGenericViewDlg -> TGenericDlg -> THelpAwareForm
      -> TBaseForm -> [TForm]
  }
  TFixedSourceReportDlg = class(TSourceReportDlg)
  protected
    function GetCLSID: TGUID; override;
      {CLSID of the object used to write the report: CLSID is set according to
      the report kind}
  end;


implementation


uses
  // Project
  IntfVerInfoReport;


{$R *.dfm}

{ TFixedSourceReportDlg }

function TFixedSourceReportDlg.GetCLSID: TGUID;
  {CLSID of the object used to write the report: CLSID is set according to the
  report kind}
begin
  Result := CLSID_VerInfoRCFixedReporter;
end;

end.
