{
 * UPropSheetHandler.pas
 *
 * Defines the class that implements an extended version information property
 * sheet that can be added to the Windows explorer property dialog.
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
 * The Original Code is UPropSheetHandler.pas.
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


unit UPropSheetHandler;


interface


uses
  // Delphi
  Windows, ShlObj, CommCtrl,
  // Project
  UVIShellExtBase, UPSEngine, UVIPropSheetCard, UPSView;

type

  {
  TPropSheetHandler:
    COM object used to provide and manage an extended version information
    property sheet to Windows explorer.

    Inheritance: TPropSheetHandler -> TVIShellExtBase -> TShellExtBase
      -> TBaseCOMObj -> [TInterfacedObject]
  }
  TPropSheetHandler = class(TVIShellExtBase,
    IShellExtInit, IShellPropSheetExt, IUnknown)
  private
    fEngine: TPSEngine;
      {"Engine" object used to read version information from a file an return
      object that can access it}
    fView: TPSView;
      {View object used to format and display version information in property
      sheet}
    fPropSheetCard: TVIPropSheetCard;
      {Display "card" object used to encapsulate the property sheet and create
      and manage the "widget" displayed on it - similar to a much simplified
      delphi form}
    procedure AdvButtonClick(Sender: TObject);
      {Handles "Advanced" button clicks: displays version information for
      current file in main application}
    function CreateVIPropSheetPage: HPropSheetPage;
      {Creates the property sheet page and returns handle to it}
    procedure InitDialog(DlgWnd: HWND);
      {Initialises the property sheet dialog box and the objects required to
      display version information data. This method is called from the property
      page's dialog box procedure}
  protected
    { IShellExtInit }
    // Method implemented in ancestor class
    { IShellPropSheetExt }
    function AddPages(lpfnAddPage: TFNAddPropSheetPage;
      lParam: LPARAM): HResult; stdcall;
      {Adds page to property sheet that the shell displays for a file object.
      When it is about to display the property sheet, the shell calls the
      AddPages method}
    function ReplacePage(uPageID: UINT; lpfnReplaceWith: TFNAddPropSheetPage;
      lParam: LPARAM): HResult; stdcall;
      {Replaces a page in a property sheet for a control panel object: NOTE -
      not used for shell property page extensions}
  public
    destructor Destroy; override;
      {Class destructor: frees owned objects (created in InitDialog)}
    procedure DefaultHandler(var Msg); override;
      {Handles messages passed to this handler from the property sheet's dialog
      box procedure. Messages are passed on to the property sheet "card" object
      that maintains the dialog box controls}
  end;


implementation


uses
  // Delpi
  SysUtils, Messages;


{$Resource VIPropSheetDlg.res}

resourcestring
  // Property sheet strings
  sTabCaption = 'Version Extra';


{ TPropSheetHandler }

function PropSheetDlgProc(hwndDlg: HWND; msg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
  {Dialog box procedure for our property page. Handles messages to property
  sheet}

  // ---------------------------------------------------------------------------
  procedure InitDialog;
    {Initialises dialog box by calling handler object's InitDialog method}
  var
    PPSP: PPropSheetPage;       // pointer to property page description
    Handler: TPropSheetHandler; // reference to property page handler object
  begin
    // Get reference to handler object via property page
    PPSP := PPropSheetPage(lParam);
    Handler := TPropSheetHandler(PPSP^.lParam);
    // .. handler object reference is stored in window's user data: it is
    //    referenced by prop sheet page's lParam field
    SetWindowLong(hwndDlg, DWL_USER, PPSP.lParam);
    // Initialize manager object (creates controls)
    Handler.InitDialog(hwndDlg);
    // Return that we've not set focus
    // (must be false if we do call SetFocus)
    Result := True;
  end;

  procedure HandleMsg;
    {Handles current message by dispatching it to the property sheet handler}
  var
    DMsg: TMessage;               // delphi format message
    Handler: TPropSheetHandler;   // handler object
  begin
    // Get reference to handler object from window's user data
    Handler := TPropSheetHandler(GetWindowLong(hwndDlg, DWL_USER));
    if Assigned(Handler) then
    begin
      // Build the delphi format message from dialog proc's parameters
      DMsg.Msg := msg;
      DMsg.WParam := wParam;
      DMsg.LParam := lParam;
      DMsg.Result := 0;
      // Dispatch message to handler
      Handler.Dispatch(DMsg);
      // Note we've handled message ...
      Result := True;
      // ... and record result as required by API documentation
      SetWindowLong(hwndDlg, DWL_MSGRESULT, DMsg.Result);
    end;
  end;
  // ---------------------------------------------------------------------------

begin
  // Assume message not handled
  Result := False;
  case msg of
    WM_INITDIALOG:        InitDialog;     // Initialise the dialog box
    WM_COMMAND, WM_HELP:  HandleMsg;      // Handle messages we're interested in
  end;
end;

function PropSheetCallback(hWndDlg: HWnd; Msg: Integer;
  var PSP: TPropSheetPage): Integer; stdcall;
  {Callback function called when property sheet is being created and destroyed}
begin
  // Always return non-zero
  Result := 1;
  case Msg of
    PSPCB_CREATE:
      {Don nothing};
    PSPCB_RELEASE:
      // Releasing property sheet: release the handler object
      // (the matching _AddRef is in TPropSheetHandler.AddPages)
      TPropSheetHandler(PSP.lParam)._Release; //result is ignored
  end;
end;

function TPropSheetHandler.AddPages(lpfnAddPage: TFNAddPropSheetPage;
  lParam: LPARAM): HResult;
  {Adds page to property sheet that the shell displays for a file object. When
  it is about to display the property sheet, the shell calls the AddPages
  method}
var
  hPage: HPropSheetPage;  // pointer to property sheet page
begin
  // Assume failure
  Result := E_FAIL;
  if not FileHasVerInfo then
    Exit;
  // Create property sheet page
  hPage := CreateVIPropSheetPage;
  if Assigned(hPage) then
  begin
    // Try to add page to property sheet
    if lpfnAddPage(hPage, lParam) then
    begin
      // Added OK: reference self sheet handler to prevent early freeing
      _AddRef;  // _Release called in PropSheetCallback
      Result := S_OK;
    end
    else
      // Failed to add: we must destroy page
      DestroyPropertySheetPage(hPage);
  end;
end;

procedure TPropSheetHandler.AdvButtonClick(Sender: TObject);
  {Handles "Advanced" button clicks: displays version information for current
  file in main application}
begin
  ExecVIS(0);
end;

function TPropSheetHandler.CreateVIPropSheetPage: HPropSheetPage;
  {Creates the property sheet page and returns handle to it}
var
  PSP: TPropSheetPage;  // property sheet page structure
begin
  // Initialise structure
  ZeroMemory(@PSP, SizeOf(PSP));
  PSP.dwSize := SizeOf(TPropSheetPage);
  // Set up page
  // flags set optional items and determine which fields are valid
  PSP.dwFlags := PSP_USETITLE                 // use pzTitle field for tab entry
    or PSP_USECALLBACK;       // call pfnCallback when page created or destroyed
  // information from resources
  PSP.hInstance := SysInit.HInstance;          // this module contains resources
  PSP.pszTemplate := 'VIPROPSHEETDLG';            // name of dialog box resource
  PSP.pszTitle := PChar(sTabCaption);             // "title" appears in page tab
  // set callbacks
  PSP.pfnDlgProc := @PropSheetDlgProc;                   // dialog box procedure
  PSP.pfnCallback := @PropSheetCallback;               // create/delete callback
  // Record reference to this object in application data
  PSP.lParam := Integer(Self);
  // Create the property sheet page and return it
  Result := CommCtrl.CreatePropertySheetPage(PSP);
end;

procedure TPropSheetHandler.DefaultHandler(var Msg);
  {Handles messages passed to this handler from the property sheet's dialog box
  procedure. Messages are passed on to the property sheet "card" object that
  maintains the dialog box controls}
begin
  if Assigned(fPropSheetCard) then
    fPropSheetCard.Dispatch(Msg)
  else
    inherited;
end;

destructor TPropSheetHandler.Destroy;
  {Class destructor: frees owned objects (created in InitDialog)}
begin
  FreeAndNil(fPropSheetCard);
  FreeAndNil(fView);
  FreeAndNil(fEngine);
  inherited;
end;

procedure TPropSheetHandler.InitDialog(DlgWnd: HWND);
  {Initialises the property sheet dialog box and the objects required to display
  version information data. This method is called from the property page's
  dialog box procedure}
begin
  // Create "card" object that creates and manages the property page's controls
  fPropSheetCard := TVIPropSheetCard.Create(DlgWnd);
  // Create view object that displays the version information in the dialog
  fView := TPSView.Create(fPropSheetCard);
  // Create the engine object used to read the version informatiom
  fEngine := TPSEngine.Create;
  // Load and display the version info in the dialog box
  if (FileName <> '') and fEngine.LoadFromFile(FileName) then
  begin
    fView.VerInfo := fEngine.VerInfo;
    fView.Display;
  end;
  // Set event handler for property page's "Advanced" button
  fPropSheetCard.AdvButton.OnClick := AdvButtonClick;
end;

function TPropSheetHandler.ReplacePage(uPageID: UINT;
  lpfnReplaceWith: TFNAddPropSheetPage; lParam: LPARAM): HResult;
  {Replaces a page in a property sheet for a control panel object: NOTE - not
  used for shell property page extensions}
begin
  // We don't implement this method
  Result := E_NOTIMPL;
end;

end.
