{
 * FileVerCM.dpr
 *
 * Main project file for Version Information Spy Shell Extension.
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
 * The Original Code is FileVerCM.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


library FileVerCM;


uses
  UBaseCOMObj in 'UBaseCOMObj.pas',
  UCOMLibExp in 'UCOMLibExp.pas',
  UCtxMenuHandler in 'UCtxMenuHandler.pas',
  UObjFactory in 'UObjFactory.pas',
  UCard in 'UCard.pas',
  UPropSheetHandler in 'UPropSheetHandler.pas',
  UPSEngine in 'UPSEngine.pas',
  UPSView in 'UPSView.pas',
  UShellExtBase in 'UShellExtBase.pas',
  UShellExtReg in 'UShellExtReg.pas',
  UVIPropSheetCard in 'UVIPropSheetCard.pas',
  UVIShellExtBase in 'UVIShellExtBase.pas',
  UWButton in 'UWButton.pas',
  UWComboBox in 'UWComboBox.pas',
  UWidget in 'UWidget.pas',
  UWLabel in 'UWLabel.pas',
  UWListView in 'UWListView.pas',
  UDisplayFmt in '..\Shared\UDisplayFmt.pas',
  UDLLLoader in '..\Shared\UDLLLoader.pas',
  UFileReaderLoader in '..\Shared\UFileReaderLoader.pas',
  UGlobals in '..\Shared\UGlobals.pas',
  URegistry in '..\Shared\URegistry.pas',
  UVerUtils in '..\Shared\UVerUtils.pas',
  IntfFileVerShellExt in 'Exports\IntfFileVerShellExt.pas',
  IntfVerInfoReader in '..\Reader\Exports\IntfVerInfoReader.pas',
  UHTMLHelp in '..\Shared\UHTMLHelp.pas';

{$Resource 'VFileVerCM.res'}   // version information


exports
  // COM object support functions
  DllGetClassObject,
  DllCanUnloadNow,
  // COM server registration functions
  DllRegisterServer,
  DllUnregisterServer,
  // Other functions
  IsServerRegistered;

begin
end.

