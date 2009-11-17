{ ##
  @FILE                     IntfFileVerShellExt.pas
  @COMMENTS                 Provides CLSIDs for supported COM server objects and
                            defines interfaces to registrar, extension recorder
                            and extension information objects.
  @PROJECT_NAME             Version Information Spy Shell Extension.
  @PROJECT_DESC             Provides a context menu handler that can launch
                            Version Information Spy from the Explorer context
                            menu for executable files and adds a version info
                            tab to the property sheet.
  @DEPENDENCIES             None.
  @OTHER_NAMES              Original name was IntfFileVerCM.pas. Renamed as
                            IntfFileVerShellExt.pas at v2.0.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 05/06/2004
      @COMMENTS             Major update to provide recording and registration
                            support for both shell extension COM servers. The
                            registration / recording and extension info
                            functionality encapsulated by the
                            IFileVerCMRegistrar interface has now been split
                            between three distinct interfaces. Specifically:
                            + Added new IFileVerExtRecorder,
                              IFileVerExtRegistrar and IFileVerExtInfo
                              interfaces.
                            + Added CLSID for new property sheet extension.
                            + Added CLSIDStr_FileVerReg as a synomim for
                              CLSIDStr_FileVerCMReg.
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
 * The Original Code is IntfFileVerShellExt.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit IntfFileVerShellExt;


interface


const

  // CLSIDs of COM server objects provided by DLL

  // Context menu handler COM server: in string and GUID form
  CLSIDStr_FileVerCM = '{D00E6ACF-0B96-42C5-B547-6354EC573F63}';
  CLSID_FileVerCM: TGUID = CLSIDStr_FileVerCM;

  // Property sheet extension COM server: in string and GUID form
  CLSIDStr_FileVerPS = '{F214C702-972E-4EF0-A4D1-0E9568680EB9}';
  CLSID_FileVerPS: TGUID = CLSIDStr_FileVerPS;

  // Shell extension registrar COM server: in string and GUID form
  CLSIDStr_FileVerReg = '{7C16D0DF-2A32-4ECE-A27D-4D990599D827}';
  CLSID_FileVerReg: TGUID = CLSIDStr_FileVerReg;
  // versions of the above used in older code: for backwards compatibility
  // ** Deprecated **
  CLSIDStr_FileVerCMReg = CLSIDStr_FileVerReg;
  CLSID_FileVerCMReg: TGUID = CLSIDStr_FileVerReg;



type

  {
  IFileVerCMRegistrar:
    Interface to registrar COM object that is used to manipulate registration of
    file extensions with context menu handler.
    NOTE: This interface is now Deprecated.
  }
  IFileVerCMRegistrar = interface(IUnknown)
    ['{DCF0BBFC-0862-4382-BB33-BCAB7C5ADC50}']
    function IsExtRegistered(const FileName: WideString): HResult; stdcall;
      {Returns S_OK if extension of given file is registered with context menu
      handler and S_FALSE if not. Returns E_FAIL if any error was encountered}
    function RegisterExt(const FileName: WideString): HResult; stdcall;
      {Registers the extension of the given file name with the context menu
      handler. Returns S_OK if the extension was successfully registered and
      E_FAIL if there was a problem}
    function UnregisterExt(const FileName: WideString): HResult; stdcall;
      {Unregisters the context menu handler for extension of the given file
      name. If extension was unregistered then S_OK is returned. If the
      extension was not registered in the first place then S_FALSE is returned.
      If any error occurs then E_FAIL is returned}
    function RecordExt(const FileName: WideString;
      IsDefault: Boolean): HResult; stdcall;
      {Record extension of given file name in list of known extensions. If
      IsDefault is true, flag the extension as one of program's defaults (that
      shouldn't be deleted). Return S_OK is extension is successfully recorded
      and E_FAIL on error. Note that it is not possible to clear the default
      flag on an existing default extension}
    function UnrecordExt(const FileName: WideString): HResult; stdcall;
      {Unrecord extension if given file name in list of known extensions.
      Returns S_OK if key was unrecorded, S_FALSE if key was not recorded in
      first place and E_FAIL if an error occurs}
    function RecordedExtCount: Integer; stdcall;
      {Returns number of recorded extensions or -1 on error}
    function RecordedExts(Idx: Integer; out Name: WideString): HResult;
      stdcall;
      {Passes back the extension at the given index in the list of known
      extensions in Name parameter. Returns S_OK on success and E_FAIL on error}
    function IsDefaultExt(const FileName: WideString): HResult; stdcall;
      {Returns S_OK if given file's extension is recorded and is a default
      extension i.e. should not be deleted) or S_FALSE if not. Returns E_FAIL if
      an error occurs}
    function FileDesc(const FileName: WideString;
      out Desc: WideString): HResult; stdcall;
      {Passes back a description of the extension of the given file name in the
      Desc parameter. Returns S_OK if a description is found, returns S_FALSE
      and sets Desc to '' if there is no registered description or returns
      E_FAIL on error}
  end;

  {
  IFileVerExtInfo:
    Interface to object that provides a description of a file extension.
  }
  IFileVerExtInfo = interface(IUnknown)
    ['{2DD26C59-ABDA-47A2-B19F-C70BEDE41673}']
    function FileDescEx(const FileName: WideString;
      out Desc: WideString): HResult; stdcall;
      {Passes back a description of the extension of the given file name in the
      Desc parameter. Returns S_OK if a description is found, returns S_FALSE
      and sets Desc to the upper case name of the extension followed by "File"
      if there is no registered description or returns E_FAIL on error}
  end;

  {
  IFileVerExtRecorder:
    Interface to object that records and un-records information about a given
    file extension that is known to Version Information Spy. Also provides
    methods to enumerate and provide information about recorded extensions.
  }
  IFileVerExtRecorder = interface(IUnknown)
    ['{5EB1C823-67D1-474D-8C7E-FCDC652B5889}']
    function RecordExt(const FileName: WideString;
      IsDefault: Boolean): HResult; stdcall;
      {Record extension of given file name in list of known extensions. If
      IsDefault is true, flag the extension as one of program's defaults (that
      shouldn't be deleted). Return S_OK is extension is successfully recorded
      and E_FAIL on error. Note that it is not possible to clear the default
      flag on an existing default extension}
    function UnrecordExt(const FileName: WideString): HResult; stdcall;
      {Unrecord extension of given file name in list of known extensions.
      Returns S_OK if key was unrecorded, S_FALSE if key was not recorded in
      first place and E_FAIL if an error occurs}
    function RecordedExtCount: Integer; stdcall;
      {Returns number of recorded extensions or -1 on error}
    function RecordedExts(Idx: Integer; out Name: WideString): HResult;
      stdcall;
      {Passes back the extension at the given index in the list of known
      extensions in Name parameter. Returns S_OK on success and E_FAIL on error}
    function IsDefaultExt(const FileName: WideString): HResult; stdcall;
      {Returns S_OK if given file's extension is recorded and is a default
      extension i.e. should not be deleted) or S_FALSE if not. Returns E_FAIL if
      an error occurs}
  end;

  {
  IFileVerExtRegistrar:
    Interface to object that can register/unregister a file extension with a
    given explorer extension COM object. Also provides information about whether
    an extensions is registered with a COM object
  }
  IFileVerExtRegistrar = interface(IUnknown)
    ['{EE49F820-DB72-4B76-80B6-71ECEED95AD6}']
    function IsExtRegistered(const FileName: WideString;
      const CLSID: TGUID): HResult; stdcall;
      {Returns S_OK if extension of given file is registered with explorer
      extension with given CLSID and S_FALSE if not. Returns E_NOTIMPL if CLSID
      is not supported or E_FAIL if any other error was encountered}
    function RegisterExt(const FileName: WideString;
      const CLSID: TGUID): HResult; stdcall;
      {Registers the extension of the given file name with the explorer
      extension with given CLSID. Returns S_OK if the extension was successfully
      registered, E_NOTIMPL is CLSID is not supported and E_FAIL if there was
      any other problem}
    function UnregisterExt(const FileName: WideString;
      const CLSID: TGUID): HResult; stdcall;
      {Unregisters the explorer extension of given CLSID for files with given
      extension. If extension was unregistered then S_OK is returned. If the
      extension was not registered in the first place then S_FALSE is returned.
      If CLSID is not supported E_NOTIMPL is returned and E_FAIL is returned for
      any other error}
  end;


implementation


end.
