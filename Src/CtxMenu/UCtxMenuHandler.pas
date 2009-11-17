{ ##
  @FILE                     UCtxMenuHandler.pas
  @COMMENTS                 Defines the class that implements the version
                            information context menu handler COM object.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             Requires FVFileReader.dll for object that tests for
                            presence of version information in files.
  @OTHER_NAMES              Original name was UFileVerCMHandler.pas. Renamed as
                            UCtxMenuHandler.pas at v2.0.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 04/08/2002
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 24/02/2003
      @COMMENTS             + Moved base COM object class to own unit (since now
                              used by other units.
                            + Moved CLSID for handler object to new interface
                              unit.
                            + Moved code to find location of FileVer.exe from
                              UFileVerCMReg unit to here.
                            + Changed fatal error prompt to advise user to
                              contact author rather than PJSoft.
                            + Removed check for file containing version
                              information before loading program: now loads
                              program and lets the program report any errors
                              since these messages are more informative.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 19/10/2004
      @COMMENTS             + Changed to derive from new TVIShellExtBase class
                              rather than directly from TBaseCOMObject. This new
                              parent class provides common functionality shared
                              with other version information shell extensions.
                            + Context menu option is now greyed out if selected
                              file contains version information. Consequently
                              Version Information Spy is now not loaded in these
                              cases.
                            + Problems with hints not displaying correctly in
                              Explorer status bar fixed.
                            + Hint now indicates if selected file contains
                              version information.
                            + Provided message window now passed to ShellExecute
                              rather than desktop handle (0).
                            + Renamed TVIContextMenu class as
                              TContextMenuHandler.
    )
    @REVISION(
      @VERSION              2.1
      @DATE                 23/11/2005
      @COMMENTS             Fixed bug in setting "help text" that appears in
                            Windows status bar. Now provides unicode or ANSI
                            text as requested by Windows rather that always
                            providing Unicode.
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
 * The Original Code is UCtxMenuHandler.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2005 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UCtxMenuHandler;


interface


uses
  // Delphi
  Windows, ShlObj,
  // Project
  UVIShellExtBase;


type

  {
  TContextMenuHandler:
    Class that implements version information context menu handler. Adds context
    menu functionality to basic COM object class.

    Inheritance: TContextMenuHandler -> TVIShellExtBase -> TShellExtBase
      -> TBaseCOMObj -> [TInterfacedObject]
  }
  TContextMenuHandler = class(TVIShellExtBase, IShellExtInit, IContextMenu, IUnknown)
  private
    fMenuItemIdx: UINT;
      {Index of our menu item in context menu}
  protected // initerface implementation
    { IShellExtInit }
    // Method implemented in ancestor class
    { IContextMenu }
    function QueryContextMenu(Menu: HMENU;
      indexMenu, idCmdFirst, idCmdLast, uFlags: UINT): HResult; stdcall;
      {Adds commands to a context menu}
    function InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult; stdcall;
      {Carries out the command associated with a context menu item}
    function GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
      pszName: LPSTR; cchMax: UINT): HResult; stdcall;
      {Retrieves the the help text for the context menu item}
  end;


implementation


uses
  // Delphi
  SysUtils, ShellAPI,
  // Project
  UGlobals, URegistry;


resourcestring
  // Menu help hints (< 40 chars per SDK)
  sHint = 'View embedded version information.';
  sNoVIHint = 'File contains no version information.';
  // Pop-up menu caption
  sMenuCaption = 'Version Information...';


{ TContextMenuHandler }

function TContextMenuHandler.GetCommandString(idCmd, uType: UINT;
  pwReserved: PUINT; pszName: LPSTR; cchMax: UINT): HResult;
  {Retrieves the the help text for the context menu item}
var
  HelpBufLen: UINT; // length of help text buffer inc terminating #0
  Hint: string;     // the hint to display
begin
  if (idCmd = fMenuItemIdx) and ((uType and GCS_HELPTEXT) <> 0) then
  begin
    // Help text has been requested and its for our menu item: return help text
    // decide which hint info to use
    if FileHasVerInfo then
      Hint := sHint
    else
      Hint := sNoVIHint;
    if uType and GCS_UNICODE <> 0 then
    begin
      // unicode help string needed:
      //   StringToWideChar needs exact length of string + 1: so we calculate
      //   this and reduce if greater than max allowed size
      HelpBufLen := Length(Hint) + 1;
      if HelpBufLen > cchMax then
        HelpBufLen := cchMax;
      StringToWideChar(Hint, PWideChar(pszName), HelpBufLen);
    end
    else
      // ansi help string needed
      StrPLCopy(pszName, Hint, cchMax);
    // whether we pass back text or not we return OK
    Result := S_OK;
  end
  else
    // Either not our item or help text not requested
    Result := E_INVALIDARG;
end;

function TContextMenuHandler.InvokeCommand(
  var lpici: TCMInvokeCommandInfo): HResult;
  {Carries out the command associated with a context menu item}

  function CheckCommand: HResult;
    {Checks the command passed in lpici and returns S_OK if this command refers
    to this object or an error code if not}
  var
    MenuItemIdx: Integer; // menu index of command being invoked
  begin
    // Get the menu item index from the lpVerb member
    MenuItemIdx := Integer(lpici.lpVerb);
    if HiWord(MenuItemIdx) = 0 then
      // This is a true menu item: check the index
      if LoWord(MenuItemIdx) = fMenuItemIdx then
        // this is our index: we do invoke the command
        Result := S_OK
      else
        // this is not our mnu command: ignore it
        Result := E_INVALIDARG
    else
      // not a true menu item
      Result := E_FAIL;
  end;

begin
  // Check what command was received: this returns S_OK if it's our menu item
  Result := CheckCommand;
  if Succeeded(Result) then
    // This is our command: perform the action - i.e. load the VIS application
    // (hwnd is window which will own any dialog box)
    ExecVIS(lpici.hwnd);
end;

function TContextMenuHandler.QueryContextMenu(Menu: HMENU; indexMenu,
  idCmdFirst, idCmdLast, uFlags: UINT): HResult;
  {Adds commands to a context menu}

  // ---------------------------------------------------------------------------
  procedure DoInsertMenu(Text: string);
    {Insert menu item at required position with given text using Windows API,
    disabling if selected file contains no version information}
  var
    Flags: UINT;  // flags passed to API InsertMenu function
  begin
    // Record default insert menu flags
    Flags := MF_STRING or MF_BYPOSITION;
    // If file has no version info we add flag to grey the menu item
    if not FileHasVerInfo then
      Flags := Flags or MF_GRAYED;
    // Insert the menu item
    Windows.InsertMenu(
      Menu, indexMenu, Flags, idCmdFirst, PChar(Text)
    );
  end;
  // ---------------------------------------------------------------------------

begin
  // Record menu item index for our menu item
  fMenuItemIdx := indexMenu;
  // Check if we are to insert a menu item
  if ((uFlags and $000F) = CMF_NORMAL)
    or ((uFlags and CMF_EXPLORE) <> 0)
    or ((uFlags and CMF_VERBSONLY) <> 0) then
  begin
    // we are inserting menu item: do it and return number of inserted items (1)
    DoInsertMenu(sMenuCaption);
    Result := 1;
  end
  else
    // we are not inserting menu item: return 0 inserted items
    Result := 0;
end;

end.
