{
 * FrHTMLViewer.pas
 *
 * Implements a frame derived from TViewerBase that is used to display HTML
 * content using the IE browser control. It implements the abstract methods of
 * TViewerBase. Controls the appearance of the web browser user interface.
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
 * The Original Code is FrHTMLViewer.pas.
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


unit FrHTMLViewer;


interface


uses
  // Delphi
  Classes, Controls, OleCtrls, SHDocVw, ActiveX, Windows,
  // Project
  IntfUIHandlers, FrViewerBase;


type

  {
  THTMLLinkClick:
    Type of event handler triggered when web browser navigates to a URL. Sender
    is the web browser object, URL is the URL being navigated to and Cancel is
    a flag that can be set true to prevent the URL being accessed.
  }
  THTMLLinkClick = procedure(Sender: TObject; const URL: string;
    var Cancel: Boolean) of object;


  {
  THTMLViewer:
    A frame used to display HTML content in a Web browser control. Implements
    the abstract methods of TViewerBase. The frame also minimally implement
    IOleClientSite and IDocHostUIHandler interfaces that enable it to act as
    client site for the web browser control and to control its user interface.

    Inheritance: THTMLViewer -> TViewerBase -> [TFrame]
  }
  THTMLViewer = class(TViewerBase,
    IOleClientSite,     // provides client site for web browser
    IDocHostUIHandler   // modifies web browser UI
  )
    webView: TWebBrowser;
    procedure webViewBeforeNavigate2(Sender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
  private // properties
    fOnClickLink: THTMLLinkClick;
  private
    fContent: TStringList;
      {Stores the HTML content}
    procedure LinesChangeHandler(Sender: TObject);
      {Handles change event for string list storing content: redisplays content
      when it changes}
    procedure SetBrowserOleClientSite(const Site: IOleClientSite);
      {Registers the given object as the web browser's client site}
    procedure LoadFromString(const HTML: string);
      {Loads HTML source stored in a string into web browser and displays it}
  protected
    function GetContent: TStrings; override;
      {Read accessor for Content property}
    procedure SetContent(const Value: TStrings); override;
      {Write accessor for Content property}
  protected // interfaces
    { IOleClientSite: all methods mapped onto names with prefix OCS }
    function IOleClientSite.SaveObject = OCSSaveObject;
    function OCSSaveObject: HResult; stdcall;
      {Saves the object associated with the client site. We do nothing}
    function IOleClientSite.GetMoniker = OCSGetMoniker;
    function OCSGetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
      {Returns a moniker to an object's client site. We do not implement}
    function IOleClientSite.GetContainer = OCSGetContainer;
    function OCSGetContainer(out container: IOleContainer): HResult; stdcall;
      {Returns a pointer to the container's IOleContainer interface. We do not
      provide one}
    function IOleClientSite.ShowObject = OCSShowObject;
    function OCSShowObject: HResult; stdcall;
      {Tells the container to position the object so it is visible to the user.
      We do nothing - it is visiable}
    function IOleClientSite.OnShowWindow = OCSOnShowWindow;
    function OCSOnShowWindow(fShow: BOOL): HResult; stdcall;
      {Notifies a container when an embedded object's window is about to become
      visible or invisible. We do nothing}
    function IOleClientSite.RequestNewObjectLayout = OCSRequestNewObjectLayout;
    function OCSRequestNewObjectLayout: HResult; stdcall;
      {Asks container to allocate more or less space for displaying an embedded
      object. We don't implement}
    { IDocHostUIHandler: all methods mapped onto names with prefix DUH }
    function IDocHostUIHandler.ShowContextMenu = DUHShowContextMenu;
    function DUHShowContextMenu(const dwID: DWORD; const ppt: PPOINT;
      const pcmdtReserved: IUnknown; const pdispReserved: IDispatch): HResult;
      stdcall;
      {Called by MSHTML to display a shortcut menu. We prevent this}
    function IDocHostUIHandler.GetHostInfo = DUHGetHostInfo;
    function DUHGetHostInfo(var pInfo: TDocHostUIInfo): HResult; stdcall;
      {Called by MSHTML to retrieve the user interface (UI). We inhibit 3D
      borders}
    function IDocHostUIHandler.ShowUI = DUHShowUI;
    function DUHShowUI(const dwID: DWORD;
      const pActiveObject: IOleInPlaceActiveObject;
      const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
      const pDoc: IOleInPlaceUIWindow): HResult; stdcall;
      {Called by MSHTML to enable the host to replace MSHTML menus and toolbars
      etc. We say we've handled but do nothing}
    function IDocHostUIHandler.HideUI = DUHHideUI;
    function DUHHideUI: HResult; stdcall;
      {Called when MSHTML removes its menus and toolbars. We say we've handled
      but do nothing}
    function IDocHostUIHandler.UpdateUI = DUHUpdateUI;
    function DUHUpdateUI: HResult; stdcall;
      {Called by MSHTML to notify the host that the command state has changed.
      We say we've handed but do nothing}
    function IDocHostUIHandler.EnableModeLess = DUHEnableModeless;
    function DUHEnableModeless(const fEnable: BOOL): HResult; stdcall;
      {Called by the MSHTML when it displays a modal UI. We say we've handled
      OK}
    function IDocHostUIHandler.OnDocWindowActivate = DUHOnDocWindowActivate;
    function DUHOnDocWindowActivate(const fActivate: BOOL): HResult; stdcall;
      {Called by the MSHTML when the document window is activated or
      deactivated. We say we've handled OK}
    function IDocHostUIHandler.OnFrameWindowActivate = DUHOnFrameWindowActivate;
    function DUHOnFrameWindowActivate(const fActivate: BOOL): HResult; stdcall;
      {Called by the MSHTML when the top-level frame window is activated or
      deactivated.  We say we've handled OK}
    function IDocHostUIHandler.ResizeBorder = DUHResizeBorder;
    function DUHResizeBorder(const prcBorder: PRECT;
      const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
      stdcall;
      {Called by the MSHTML when a frame or document's window's border is about
      to be changed. We say we've handled OK}
    function IDocHostUIHandler.TranslateAccelerator = DUHTranslateAccelerator;
    function DUHTranslateAccelerator(const lpMsg: PMSG;
      const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult; stdcall;
      {Called by MSHTML when accelerator keys such as TAB are used. We say we
      don't want to handle}
    function IDocHostUIHandler.GetOptionKeyPath = DUHGetOptionKeyPath;
    function DUHGetOptionKeyPath(var pchKey: POLESTR;
      const dw: DWORD ): HResult; stdcall;
      {Called by the WebBrowser Control to retrieve a registry subkey path that
      overrides the default IE registry settings. We say we don't want to
      override}
    function IDocHostUIHandler.GetDropTarget = DUHGetDropTarget;
    function DUHGetDropTarget(const pDropTarget: IDropTarget;
      out ppDropTarget: IDropTarget): HResult; stdcall;
      {Called by MSHTML when it is used as a drop target. We say we don't want
      to provide alternative drop target}
    function IDocHostUIHandler.GetExternal = DUHGetExternal;
    function DUHGetExternal(out ppDispatch: IDispatch): HResult; stdcall;
      {Called by MSHTML to obtain the host's IDispatch interface. We say we
      don't want to provide an interface}
    function IDocHostUIHandler.TranslateURL = DUHTranslateUrl;
    function DUHTranslateUrl(const dwTranslate: DWORD; const pchURLIn: POLESTR;
      var ppchURLOut: POLESTR): HResult; stdcall;
      {Called by MSHTML to give the host an opportunity to modify the URL to be
      loaded. We translate URLs containing '\' characters because the web
      browser doesn't call OnBeforeNavigate2 for such URLs when
      IDocHostUIHandler is implemented in frame!}
    function IDocHostUIHandler.FilterDataObject = DUHFilterDataObject;
    function DUHFilterDataObject(const pDO: IDataObject;
      out ppDORet: IDataObject): HResult; stdcall;
      {Called by MSHTML to allow the host to replace the MSHTML data object. We
      don't want to provide a data object}
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor: sets up object}
    destructor Destroy; override;
      {Class destructor: tears down object}
    procedure SaveToFile(const FileName: string); override;
      {Saves HTML content to given file}
    property OnClickLink: THTMLLinkClick read fOnClickLink write fOnClickLink;
      {Event triggered just before web browser navigates to a link. The
      navigation can be cancelled by setting the event's cancelled flag}
  end;


implementation


uses
  // Delphi
  SysUtils, Forms;

{$R *.dfm}


resourcestring
  // Error message
  sNoIOleObject = 'Browser''s Default interface does not support IOleObject';


{ THTMLViewer }

constructor THTMLViewer.Create(AOwner: TComponent);
  {Class constructor: sets up object}
begin
  inherited;
  // Create object to store content and assign change handler
  fContent := TStringList.Create;
  fContent.OnChange := LinesChangeHandler;
  // Register this frame as web browser's client site
  SetBrowserOleClientSite(Self);
end;

destructor THTMLViewer.Destroy;
  {Class destructor: tears down object}
begin
  // Unregister this frame as web browser's client site
  SetBrowserOleClientSite(nil);
  // Free content string list
  fContent.Free;
  inherited;
end;

function THTMLViewer.DUHEnableModeless(const fEnable: BOOL): HResult;
  {Called by the MSHTML when it displays a modal UI. We say we've handled OK}
begin
  // We handled without error
  Result := S_OK;
end;

function THTMLViewer.DUHFilterDataObject(const pDO: IDataObject;
  out ppDORet: IDataObject): HResult;
  {Called by MSHTML to allow the host to replace the MSHTML data object. We
  don't want to provide a data object}
begin
  // We *must* set ppDORet to nil
  ppDORet := nil;
  Result := S_FALSE;
end;

function THTMLViewer.DUHGetDropTarget(const pDropTarget: IDropTarget;
  out ppDropTarget: IDropTarget): HResult;
  {Called by MSHTML when it is used as a drop target. We say we don't want to
  provide alternative drop target}
begin
  // We *must* set ppDropTarget to nil.
  ppDropTarget := nil;
  Result := E_FAIL;
end;

function THTMLViewer.DUHGetExternal(out ppDispatch: IDispatch): HResult;
  {Called by MSHTML to obtain the host's IDispatch interface. We say we don't
  want to provide an interface}
begin
  // We *must" set ppDispath to nil
  ppDispatch := nil;
  Result := E_FAIL;
end;

function THTMLViewer.DUHGetHostInfo(var pInfo: TDocHostUIInfo): HResult;
  {Called by MSHTML to retrieve the user interface (UI). We inhibit 3D borders}
begin
  pInfo.dwFlags := DOCHOSTUIFLAG_NO3DBORDER;
  Result := S_OK;
end;

function THTMLViewer.DUHGetOptionKeyPath(var pchKey: POLESTR;
  const dw: DWORD): HResult;
  {Called by the WebBrowser Control to retrieve a registry subkey path that
  overrides the default IE registry settings. We say we don't want to override}
begin
  Result := E_FAIL;
end;

function THTMLViewer.DUHHideUI: HResult;
  {Called when MSHTML removes its menus and toolbars. We say we've handled but
  do nothing}
begin
  Result := S_OK;
end;

function THTMLViewer.DUHOnDocWindowActivate(const fActivate: BOOL): HResult;
  {Called by the MSHTML when the document window is activated or deactivated. We
  say we've handled OK}
begin
  Result := S_OK;
end;

function THTMLViewer.DUHOnFrameWindowActivate(const fActivate: BOOL): HResult;
  {Called by the MSHTML when the top-level frame window is activated or
  deactivated. We say we've handled OK}
begin
  Result := S_OK;
end;

function THTMLViewer.DUHResizeBorder(const prcBorder: PRECT;
  const pUIWindow: IOleInPlaceUIWindow; const fFrameWindow: BOOL): HResult;
  {Called by the MSHTML when a frame or document's window's border is about to
  be changed. We say we've handled OK}
begin
  Result := S_FALSE;
end;

function THTMLViewer.DUHShowContextMenu(const dwID: DWORD;
  const ppt: PPOINT; const pcmdtReserved: IInterface;
  const pdispReserved: IDispatch): HResult;
  {Called by MSHTML to display a shortcut menu. We prevent this}
begin
  Result := S_OK;
end;

function THTMLViewer.DUHShowUI(const dwID: DWORD;
  const pActiveObject: IOleInPlaceActiveObject;
  const pCommandTarget: IOleCommandTarget; const pFrame: IOleInPlaceFrame;
  const pDoc: IOleInPlaceUIWindow): HResult;
  {Called by MSHTML to enable the host to replace MSHTML menus and toolbars etc.
  We say we've handled but do nothing}
begin
  Result := S_OK;
end;

function THTMLViewer.DUHTranslateAccelerator(const lpMsg: PMSG;
  const pguidCmdGroup: PGUID; const nCmdID: DWORD): HResult;
  {Called by MSHTML when accelerator keys such as TAB are used. We say we don't
  want to handle}
begin
  Result := S_FALSE;
end;

function THTMLViewer.DUHTranslateUrl(const dwTranslate: DWORD;
  const pchURLIn: POLESTR; var ppchURLOut: POLESTR): HResult;
  {Called by MSHTML to give the host an opportunity to modify the URL to be
  loaded. We translate URLs containing '\' characters because the web browser
  doesn't call OnBeforeNavigate2 for such URLs when IDocHostUIHandler is
  implemented in frame!}

  function TaskAllocWideString(const S: string): PWChar;
    {Converts a given ANSI string to a wide string and stores in a buffer
    allocated by the Shell's task allocator. If the buffer needs to be freed
    IMalloc.Free should be used to do this}
  var
    StrLen: Integer;  // length of string in bytes
  begin
    // Store length of string allowing for terminal #0
    StrLen := Length(S) + 1;
    // Alloc buffer for wide string using task allocator
    Result := CoTaskMemAlloc(StrLen * SizeOf(WideChar));
    if Assigned(Result) then
      // Convert string to wide string and store in buffer
      StringToWideChar(S, Result, StrLen);
  end;

const
  cBackslash = '\';       // backslash character
  cBackslashEnc = '%92';  // url encoding of backslash character
begin
  if AnsiPos('\', pchURLIn) > 0 then
  begin
    // URL contains '\': we replace '\' by its URL encoding and return this
    // revised URL. We *must* allocate this string using task allocator (we are
    // *not* responsible for freeing the string)
    ppchURLOut := TaskAllocWideString(
      StringReplace(pchURLIn, cBackslash, cBackslashEnc, [rfreplaceall])
    );
    // return OK to indicate we have translated
    Result := S_OK;
  end
  else
  begin
    // URL has no backslashes
    // *required* to set ppchURLOut to nil
    ppchURLOut := nil;
    // return S_FALSE to indicate no translation
    Result := S_FALSE;
  end;
end;

function THTMLViewer.DUHUpdateUI: HResult;
  {Called by MSHTML to notify the host that the command state has changed. We
  say we've handed but do nothing}
begin
  Result := S_OK;
end;

function THTMLViewer.GetContent: TStrings;
  {Read accessor for Content property}
begin
  Result := fContent;
end;

procedure THTMLViewer.LinesChangeHandler(Sender: TObject);
  {Handles change event for string list storing content: redisplays content
  when it changes}
begin
  LoadFromString(fContent.Text);
end;

procedure THTMLViewer.LoadFromString(const HTML: string);
  {Loads HTML source stored in a string into web browser and displays it}

  // ---------------------------------------------------------------------------
  procedure WaitForDocToLoad;
    {Waits until a document has fully loaded into browser}
  begin
    while webView.ReadyState <> READYSTATE_COMPLETE do
    begin
      Application.ProcessMessages;
      Sleep(0);
    end;
  end;
  // ---------------------------------------------------------------------------

var
  PersistStreamInit: IPersistStreamInit;  // object used to load stream into doc
  StreamAdapter: IStream;                 // IStream interface to stream
begin
  // NOTE: do not call this method in a FormCreate event handler since the
  // browser will never reach this state - use a FormShow event handler instead
  // Open new empty document and wait for it to load if we haven't got one
  if not Assigned(webView.Document) then
  begin
    webView.Navigate('about:blank');
    WaitForDocToLoad;
  end;
  // Get IPersistStreamInit interface on document object
  if webView.Document.QueryInterface(
    IPersistStreamInit, PersistStreamInit
  ) = S_OK then
  begin
    // Clear document
    if PersistStreamInit.InitNew = S_OK then
    begin
      // Get IStream interface on stream that can read from the string
      StreamAdapter := TStreamAdapter.Create(
        TStringStream.Create(HTML), soOwned
      );
      // Load data from Stream into WebBrowser
      PersistStreamInit.Load(StreamAdapter);
      // Wait for document to finish loading
      WaitForDocToLoad;
    end;
  end;
end;

function THTMLViewer.OCSGetContainer(out container: IOleContainer): HResult;
  {Returns a pointer to the container's IOleContainer interface. We do not
  provide one}
begin
  container := nil;
  Result := E_NOINTERFACE;
end;

function THTMLViewer.OCSGetMoniker(dwAssign, dwWhichMoniker: Integer;
  out mk: IMoniker): HResult;
  {Returns a moniker to an object's client site. We do not implement}
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function THTMLViewer.OCSOnShowWindow(fShow: BOOL): HResult;
  {Notifies a container when an embedded object's window is about to become
  visible or invisible. We do nothing}
begin
  Result := S_OK;
end;

function THTMLViewer.OCSRequestNewObjectLayout: HResult;
  {Asks container to allocate more or less space for displaying an embedded
  object. We don't implement}
begin
  Result := E_NOTIMPL;
end;

function THTMLViewer.OCSSaveObject: HResult;
  {Saves the object associated with the client site. We do nothing}
begin
  Result := S_OK;
end;

function THTMLViewer.OCSShowObject: HResult;
  {Tells the container to position the object so it is visible to the user. We
  do nothing - it is visiable}
begin
  Result := S_OK;
end;

procedure THTMLViewer.SaveToFile(const FileName: string);
  {Saves HTML content to given file}
begin
  fContent.SaveToFile(FileName);
end;

procedure THTMLViewer.SetBrowserOleClientSite(const Site: IOleClientSite);
  {Registers the given object as the web browser's client site}
var
  OleObj: IOleObject; // web browser's IOleObject interface
begin
  // We use browser's IOleObject.SetClientSite method to register site
  if not Supports(
    webView.DefaultInterface, IOleObject, OleObj
  ) then
    raise Exception.Create(sNoIOleObject);
  OleObj.SetClientSite(Site);
end;

procedure THTMLViewer.SetContent(const Value: TStrings);
  {Write accessor for Content property}
begin
  fContent.Assign(Value);
end;

procedure THTMLViewer.webViewBeforeNavigate2(Sender: TObject;
  const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
  Headers: OleVariant; var Cancel: WordBool);
  {Handles web browser event triggered before navigating to a URL. Can cancel
  navigation by setting Cancel to true. Passes off decision to any assigned
  OnClickLink event handler}
var
  DoCancel: Boolean;  // flag passed to OnClickLink event handler
begin
  if Assigned(fOnClickLink) then
  begin
    webView.Cursor := crHourGlass;
    try
      DoCancel := Cancel;
      fOnClickLink(webView, URL, DoCancel);
      Cancel := DoCancel;
    finally
      webView.Cursor := crDefault;
    end;
  end;
end;


initialization

// Initialise COM library for web browser
CoInitialize(nil);


finalization

// Free COM library
CoUninitialize;


end.
