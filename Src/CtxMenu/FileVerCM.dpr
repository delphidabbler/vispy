{ ##
  @FILE                     FileVerCM.dpr
  @COMMENTS                 Main project file.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @AUTHOR                   Peter D Johnson, LLANARTH, Ceredigion, Wales, UK.
  @EMAIL                    delphidabbler@yahoo.co.uk
  @COPYRIGHT                © Peter D Johnson, 2002-2007.
  @WEBSITE                  http://www.delphidabbler.com/
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 04/08/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 24/02/2003
      @COMMENTS             Added new units: UFileVerBaseCM, IntfFileVerCM,
                            URegistry.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 20/10/2004
      @COMMENTS             + Added new units: IntfVerInfoReader,
                              UFileReaderLoader, UDisplayFmt, UDLLLoader,
                              UGlobals, UPropSheetCard, UPropSheetHandler,
                              UPSEngine, UPSView, URegistry, UShellExtBase,
                              UVerUtils, UVIPropSheetCard, UVIShellExtBase,
                              UWButton, UWComboBox, UWidget, UWLabel,
                              UWListView.
                            + Renamed UFileVerCM as UCOMLibExp,
                              IntfFileVerCM as IntfFileVerShellExt,
                              UFileVerCMFactory as UObjFactory,
                              UFileVerCMHandler as UCtxMenuHandler,
                              UFileVerCMReg as UShellExtReg, UFileVerCMBase as
                              UBaseCOMObj.
                            + Added new IsServerRegistered function to export
                              list.
    )
    @REVISION(
      @VERSION              2.1
      @DATE                 28/08/2007
      @COMMENTS             + Changed paths to some interfaces. Interfaces are
                              no longer in Intf folder but in Exports sub folder
                              of relevant DLL source code.
                            + Changed to use renamed UCard unit.
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
 * The Original Code is FileVerCM.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
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
  IntfVerInfoReader in '..\Reader\Exports\IntfVerInfoReader.pas';

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

