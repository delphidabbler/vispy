{
 * UFileReader.pas
 *
 * Defines classes which provide read access to version information contained in
 * executable programs and implement the interface defined in
 * IntfVerInfoReader.pas. The classes use objects exported from the VIBinData
 * DLL to process the raw version information.
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
 * The Original Code is UFileReader.pas.
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


unit UFileReader;


interface


function CreateFileReader(const CLSID: TGUID; out Obj): HResult; stdcall;
  {Creates the version info file reader object of the type specified by CLSID.
  If the library supports the object then an instance is created. A reference to
  the object is stored in Obj and S_OK is returned. If the library does not
  support CLSID then Obj is set to nil and E_NOTIMPL is returned. If there is an
  error in creating the object Obj is set to nil and E_FAIL is returned}


implementation


uses
  // Delphi
  SysUtils, Windows, ActiveX, Classes,
  // Project
  IntfBinaryVerInfo, IntfVerInfoReader,
  UVIBinary, UVerInfoStream, UVInfoResFileStream, UResourceFileStream,
  UResourceFile;



resourcestring
  // Error messages
  sVerInfoDataError = 'Version info data error: %s';
  sNoTableForNames = 'There is no string table to read names from';
  sNoTableForValues = 'There is no string table to read values from';
  sNoWrapper = 'Can''t create version information data wrapper object.';
  sNotValidFile =
     '"%s" is not an executable file or 32 bit binary resource file';
  sDOSExecutable = '"%s" is a DOS executable and so contains no version '
    + 'information';
  sVXDExecutable = '"%s" is a virtual device driver and any version '
    + 'information can''t be read from it';


type

  {
  TVerInfoWrapper:
    Base class for objects that provide a high level wrapper round the
    IVerInfoBinaryReader object exported from VIBinData.dll. Keeps a reference
    to a IVerInfoBinaryReader object and provides a method to check the result
    of the object's methods, raising an exception on error.

    Inheritance: TVerInfoWrapper -> [TInterfacedObject]
  }
  TVerInfoWrapper = class(TInterfacedObject)
  private // properties
    fVIData: IVerInfoBinaryReader;
  protected
    procedure CheckVI(Res: HResult);
      {Checks whether the given return value from a IVerInfoBinaryReader is
      an error and, if so, raises an exception with the IVerInfoBinaryReader
      object's last error message}
    property VIData: IVerInfoBinaryReader read fVIData;
      {Provides a reference to the wrapped binary version info data reader
      object}
  public
    constructor Create(const VIData: IVerInfoBinaryReader);
      {Class constructor: records reference to wrapped version info data reader
      object}
    destructor Destroy; override;
      {Class destructor: releases reference to wrapped object}
  end;

  {
  TVarVerInfo:
    Class that provides high level read only access to variable file
    information. It treats string tables as being owned by a particular
    translation (as per view of data provided by program). This class links
    translations and string tables together and creates dummy translations to
    match any isolated string tables. Implements the IVerInfoVarReader and
    IVerInfoVarReader2 interfaces.

    Inheritance: TVarVerInfo -> TVerInfoWrapper -> [TInterfacedObject]
  }
  TVarVerInfo = class(TVerInfoWrapper, IVerInfoVarReader, IVerInfoVarReader2)
  private
    fLanguageID: Word;
      {Language ID for the variable file info item}
    fCharSet: Word;
      {Character set for the variable file info item}
    fStatus: Integer;
      {Code giving status of the var info item: this code includes extended
      information provided by StatusEx method of IVerInfoVarReader2}
    fStrTableIdx: Integer;
      {Index into string table associated with this translation}
  protected
    { IVerInfoVarReader }
    function StringCount: Integer; stdcall;
      {Returns number of strings in string table}
    function StringName(Idx: Integer): WideString; stdcall;
      {Returns name of string at given index in string table}
    function StringValue(Idx: Integer): WideString; stdcall;
      {Returns value of string at given index in string table}
    function LanguageID: Word; stdcall;
      {Returns langauge ID for variable ver info item}
    function CharSet: Word; stdcall;
      {Returns character set for variable ver info item}
    function Status: Integer; stdcall;
      {Returns code showing whether item is internally consistent}
    { IVerInfoVarReader2 }
    function StatusEx: Integer; stdcall;
      {Returns extended status information as a bitmask}
  public
    constructor Create(StrTableIdx: Integer; LanguageID, Charset: Word;
      Status: Integer; const VIData: IVerInfoBinaryReader);
      {Class constructor: records values passed as parameters}
  end;

  {
  TVerInfo:
    Class that provides high level read only access to version information
    binary data. It provides a wrapper round the IVerInfoBinaryReader object
    exported from VIBinData.dll. Implements the IVerInfoReader interface.

    Inheritance: TVerInfo -> TVerInfoWrapper -> [TInterfacedObject]
  }
  TVerInfo = class(TVerInfoWrapper, IVerInfoReader)
  private
    fVarList: TInterfaceList;
      {Holds list of variable file information objects}
    procedure UpdateData;
      {Updates the variable file information with details of current version
      information}
    procedure DestroyVarList;
      {Destroys all objects in the variable file information list and clears
      list}
  protected
    { IVerInfoReader }
    function FixedFileInfo: TVSFixedFileInfo; stdcall;
      {Returns fixed file information from version information}
    function VarInfoCount: Integer; stdcall;
      {Returns number of variable version information entries within version
      information}
    function VarInfo(Idx: Integer): IVerInfoVarReader; stdcall;
      {Returns reference to object used to access variable version information
      at given index in version information}
  public
    constructor Create(const VIData: IVerInfoBinaryReader);
      {Class contructor: records reference to wrapped binary version info access
      object and creates and updates list to hold the variable file information}
    destructor Destroy; override;
      {Class destructor: frees owned list and all objects in it}
  end;

  {
  TVerInfoAccessor:
    Defines a class which interacts with the VIBinData DLL and instantiates 16
    or 32 bit reader objects when user requests a file to be opened. The reader
    object is wrapped by a TVerInfo object implementing the IVerInfoReader
    interface which is made available for access by users. This class implements
    the IVerInfoFileReader interface.

    Inheritance: TVerInfoAccessor -> [TInterfacedObject]
  }
  TVerInfoAccessor = class(TInterfacedObject, IVerInfoFileReader)
  private
    fVerInfo: IVerInfoReader;
      {Reference to object that implements the IVerInfoReader interface that
      user can use to access the version information}
    fVIBinDLL: TVIBinaryLoader;
      {Object used to load and validate VIBinData.dll and to exposes function to
      create version info reader objects within DLL}
    fLastError: string;
      {The last error generated by class, or '' if last operation was
      successful}
    procedure InternalLoadFile(const FileName: string);
      {Loads version information (if present) from given file and creates a new
      reader object and wrapper for it. If file contains no version information
      then no wrapper object is created and its reference is set to nil}
  protected
    { IVerInfoFileReader }
    function LoadFile(const FileName: PChar): WordBool; stdcall;
      {Loads version information from a file. Returns true if file is loaded
      successfully and false on error (refer to LastError function for details
      of error if file fails to load)}
    function VerInfo: IVerInfoReader; stdcall;
      {Reference to object that is used to read the version information that
      has been read (or nil if either no information has been read or loaded
      file contains no such information}
    function LastError: WideString; stdcall;
      {Details of last error encountered in object ('' if last load operation
      succeeded)}
  public
    constructor Create;
      {Class constructor: loads the VIBinData.dll and checks for validity:
      raises an exception if DLL is missing or invalid}
    destructor Destroy; override;
      {Class destructor: frees owned objects}
  end;

  {
  TVerInfoQuery:
    Defines a class which queries files about the contained version information.
    Implements the IVerInfoFileQuery interface.

    Inheritance: TVerInfoQuery -> [TInterfacedObject]
  }
  TVerInfoQuery = class(TInterfacedObject, IVerInfoFileQuery)
  protected
    { IVerInfoFileQuery }
    function FileContainsVersionInfo(const FileName: PChar): WordBool; stdcall;
      {Returns true if given file contains version information and false if not}
  end;


{ TVerInfoWrapper }

procedure TVerInfoWrapper.CheckVI(Res: HResult);
  {Checks whether the given return value from a IVerInfoBinaryReader is an error
  and, if so, raises an exception with the IVerInfoBinaryReader object's last
  error message}
begin
  if Failed(Res) then
    raise Exception.CreateFmt(sVerInfoDataError, [VIData.LastErrorMsg]);
end;

constructor TVerInfoWrapper.Create(const VIData: IVerInfoBinaryReader);
  {Class constructor: records reference to wrapped version info data reader
  object}
begin
  inherited Create;
  fVIData := VIData;
end;

destructor TVerInfoWrapper.Destroy;
  {Class destructor: releases reference to wrapped object}
begin
  fVIData := nil;
  inherited;
end;


{ TVerInfo }

constructor TVerInfo.Create(const VIData: IVerInfoBinaryReader);
  {Class contructor: records reference to wrapped binary version info access
  object and creates and updates list to hold the variable file information}
begin
  inherited;
  fVarList := TInterfaceList.Create;
  UpdateData;
end;

destructor TVerInfo.Destroy;
  {Class destructor: frees owned list and all objects in it}
begin
  DestroyVarList;
  fVarList.Free;
  inherited;
end;

procedure TVerInfo.DestroyVarList;
  {Destroys all objects in the variable file information list and clears list}
begin
  // Clear the list
  fVarList.Clear;   // this frees all objects in list
end;

function TVerInfo.FixedFileInfo: TVSFixedFileInfo;
  {Returns fixed file information from version information}
begin
  try
    CheckVI(VIData.GetFixedFileInfo(Result));
  except
    FillChar(Result, SizeOf(Result), 0);
  end;
end;

procedure TVerInfo.UpdateData;
  {Updates the variable file information with details of current version
  information}
var
  TransCount, StrTableCount: Integer; // count of translations & string tables
  TransIdx, StrTableIdx: Integer;     // index into translations & string tables
  TransCode: TTranslationCode;        // stores a translation code
  Status: Integer;                    // status code for a translation
begin
  // Destroy existing variable file info objects
  DestroyVarList;
  // Get number of translations and number of string tables in version info
  CheckVI(VIData.GetTranslationCount(TransCount));
  CheckVI(VIData.GetStringTableCount(StrTableCount));
  // Check the translation list entries for matching string tables
  for TransIdx := 0 to Pred(TransCount) do
  begin
    // Get translation code for this translation
    CheckVI(VIData.GetTranslation(TransIdx, TransCode));
    // Look up this translation in string table list
    CheckVI(VIData.IndexOfStringTableByCode(TransCode, StrTableIdx));
    if StrTableIdx > -1 then
      // We have a matching string table: create a new var file info object
      // that maps the translation to the string table
      fVarList.Add(
        TVarVerInfo.Create(
          StrTableIdx,          // index of matching string table
          TransCode.LanguageID, // language code for translation
          TransCode.CharSet,    // character set for translation
          VARVERINFO_STATUS_OK, // translation/string table match OK
          VIData                // reference to binary data access object
        )
      )
    else
    begin
      // We have no matching string table: create a new var file info object
      // that has no associated string table, and flag the error
      // ... record that there is no matching string table
      Status := VARVERINFO_STATUS_TRANSONLY;
      if StrTableCount = 0 then
        // ... in fact no string tables at all
        Status := Status or VARVERINFO_STATUSEX_NOSTRTABLE;
      fVarList.Add(
        TVarVerInfo.Create(
          -1,                   // no matching string table: dummy index
          TransCode.LanguageID, // language code for translation
          TransCode.CharSet,    // character set for translation
          Status,               // there is no matching string table
          VIData                // ref to binary data access object
        )
      );
    end;
  end;
  // Check the string info entries
  for StrTableIdx := 0 to Pred(StrTableCount) do
  begin
    // Get translation code that identifies this string table
    CheckVI(VIData.GetStringTableTransCode(StrTableIdx, TransCode));
    // Look up string table's translation code in translation list
    CheckVI(VIData.IndexOfTranslation(TransCode, TransIdx));
    if TransIdx = -1 then
    begin
      // There is no matching translation: create a new var file info object
      // for string table that notes there is no associated translation entry
      // NOTE: if there is a matching translation object is added above
      // ... record that there is no matching translation entry
      Status := VARVERINFO_STATUS_STRTABLEONLY;
      if TransCount = 0 then
        // ... in fact no translation statement at all
        Status := Status or VARVERINFO_STATUSEX_NOTRANS;
      fVarList.Add(
        TVarVerInfo.Create(
          StrTableIdx,          // index of orphaned string table
          TransCode.LanguageID, // lang code for string table's trans
          TransCode.CharSet,    // char set for string table's trans
          Status,               // there is no matching translation
          VIData                // ref to binary data access object
        )
      );
    end;
  end;
end;

function TVerInfo.VarInfo(Idx: Integer): IVerInfoVarReader;
  {Returns reference to object used to access variable version information at
  given index in version information}
begin
  try
    Result := fVarList[Idx] as IVerInfoVarReader;
  except
    Result := nil;
  end;
end;

function TVerInfo.VarInfoCount: Integer;
  {Returns number of variable version information entries within version
  information}
begin
  try
    Result := fVarList.Count;
  except
    Result := 0;
  end;
end;


{ TVarVerInfo }

function TVarVerInfo.CharSet: Word;
  {Returns character set for variable ver info item}
begin
  Result := fCharSet;
end;

constructor TVarVerInfo.Create(StrTableIdx: Integer; LanguageID,
  Charset: Word; Status: Integer; const VIData: IVerInfoBinaryReader);
  {Class constructor: records values passed as parameters}
begin
  // Parent object stores reference to data object used to read binary data
  inherited Create(VIData);
  // We store values of other parameters in this object
  fStrTableIdx := StrTableIdx;
  fLanguageID := LanguageID;
  fCharSet := CharSet;
  fStatus := Status;
end;

function TVarVerInfo.LanguageID: Word;
  {Returns langauge ID for variable ver info item}
begin
  Result := fLanguageID;
end;

function TVarVerInfo.Status: Integer;
  {Returns code showing whether item is internally consistent}
begin
  // We return only original status info my masking out any extended information
  Result := fStatus and VARVERINFO_STATUS_V1MASK;
end;

function TVarVerInfo.StatusEx: Integer;
  {Returns extended status information as a bitmask}
begin
  Result := fStatus;
end;

function TVarVerInfo.StringCount: Integer;
  {Returns number of strings in string table}
begin
  if fStrTableIdx > -1 then
  begin
    try
      // There is an associated string table: get number of strings
      CheckVI(VIData.GetStringCount(fStrTableIdx, Result))
    except
      Result := 0;
    end;
  end
  else
    // There is no associated string table: return 0
    Result := 0;
end;

function TVarVerInfo.StringName(Idx: Integer): WideString;
  {Returns name of string at given index in string table}
begin
  // Check that string table exists
  try
    if fStrTableIdx = -1 then
      raise Exception.Create(sNoTableForNames);
    // Get string name: exception if indices out of range
    CheckVI(VIData.GetStringName(fStrTableIdx, Idx, Result));
  except
    Result := '';
  end;
end;

function TVarVerInfo.StringValue(Idx: Integer): WideString;
  {Returns value of string at given index in string table}
begin
  // Check that string table exists
  try
    if fStrTableIdx = -1 then
      raise Exception.Create(sNoTableForValues);
    // Get string value: exception if indices out of range
    CheckVI(VIData.GetStringValue(fStrTableIdx, Idx, Result));
  except
    Result := '';
  end;
end;


{ TVerInfoAccessor }

type

  {
  IMAGE_DOS_HEADER:
    DOS .EXE header.
  }
  IMAGE_DOS_HEADER = packed record
    e_magic   : Word;                         // Magic number ("MZ")
    e_cblp    : Word;                         // Bytes on last page of file
    e_cp      : Word;                         // Pages in file
    e_crlc    : Word;                         // Relocations
    e_cparhdr : Word;                         // Size of header in paragraphs
    e_minalloc: Word;                         // Minimum extra paragraphs needed
    e_maxalloc: Word;                         // Maximum extra paragraphs needed
    e_ss      : Word;                         // Initial (relative) SS value
    e_sp      : Word;                         // Initial SP value
    e_csum    : Word;                         // Checksum
    e_ip      : Word;                         // Initial IP value
    e_cs      : Word;                         // Initial (relative) CS value
    e_lfarlc  : Word;                         // Address of relocation table
    e_ovno    : Word;                         // Overlay number
    e_res     : packed array [0..3] of Word;  // Reserved words
    e_oemid   : Word;                         // OEM identifier (for e_oeminfo)
    e_oeminfo : Word;                         // OEM info; e_oemid specific
    e_res2    : packed array [0..9] of Word;  // Reserved words
    e_lfanew  : Longint;                      // File address of new exe header
  end;

  {
  TExeFileType:
    Enumeration indicating the various types of executable file.
  }
  TExeFileType = (
    etNotExec,  // not an executable file
    etPE,       // PE format file (Windows 32 bit executable)
    etNE,       // NE format file (Windows 16 bit executable)
    etDOS,      // DOS format executable
    etVXD       // virtual device driver
  );

function ExeType(const FileName: string): TExeFileType;
  {Examines given file and returns a code that indicates the type of executable
  file it is (or if it isn't an executable)}
const
  cWinHeaderOffset = $3C; // offset of "pointer" to windows header in file
  cDOSMagic = $5A4D;      // magic number identifying a DOS executable
  cNEMagic = $454E;       // magic number identifying a NE executable (Win 16)
  cPEMagic = $4550;       // magic nunber identifying a PE executable (Win 32)
  cLEMagic = $454C;       // magic number identifying a Virtual Device Driver
var
  FS: TFileStream;              // stream to executable file
  Offset: LongInt;              // offset of windows header in exec file
  WinMagic: Word;               // magic numbers for windows executables
  DOSHeader: IMAGE_DOS_HEADER;  // DOS header
  DOSFileSize: Integer;         // size of DOS file
begin
  // Assume we can't find type of file
  Result := etNotExec;
  // Open file for analysis
  FS := TFileStream.Create(FileName, fmOpenRead + fmShareDenyNone);
  try
    // Try to read word at start of file: exit if not DOS magic number
    // Any exec file is at least size of DOS header long
    if FS.Size < SizeOf(DOSHeader) then
      Exit;
    FS.ReadBuffer(DOSHeader, SizeOf(DOSHeader));
    // DOS files begin with "MZ"
    if DOSHeader.e_magic <> cDOSMagic then
      Exit;
    // DOS files have length >= size indicated at offset $02 and $04
    // (offset $02 indicates length of file mod 512 and offset $04 indicates
    // no. of 512 pages in file)
    if (DOSHeader.e_cblp = 0) then
      DOSFileSize := DOSHeader.e_cp * 512
    else
      DOSFileSize := (DOSHeader.e_cp - 1) * 512 + DOSHeader.e_cblp;
    if FS.Size <  DOSFileSize then
      Exit;
    // DOS file relocation offset must be within DOS file size.
    if DOSHeader.e_lfarlc > DOSFileSize then
      Exit;
    // We now know we have at least a DOS program
    Result := etDOS;
    // Try to find offset of windows program header
    if FS.Size <= cWinHeaderOffset + SizeOf(LongInt) then
      Exit;
    FS.Position := cWinHeaderOffset;
    FS.ReadBuffer(Offset, SizeOf(LongInt));
    // Now try to read first word of Windows program header
    if FS.Size <= Offset + SizeOf(Word) then
      Exit;
    FS.Position := Offset;
    FS.ReadBuffer(WinMagic, SizeOf(Word));
    // This word should identifies either a NE or PE format file: check which
    if WinMagic = cNEMagic then
      Result := etNE
    else if WinMagic = cPEMagic then
      Result := etPE
    else if WinMagic = cLEMagic then
      Result := etVXD;
  finally
    FS.Free;
  end;
end;

constructor TVerInfoAccessor.Create;
  {Class constructor: loads the VIBinData.dll and checks for validity: raises an
  exception if DLL is missing or invalid}
begin
  inherited;
  // Create DLL loader, which in turn loads the DLL (exception on failure)
  fVIBinDLL := TVIBinaryLoader.Create;
end;

destructor TVerInfoAccessor.Destroy;
  {Class destructor: frees owned objects}
begin
  fVerInfo := nil;  // we free this object which frees an object from DLL
  fVIBinDLL.Free;   // ... before freeing DLL the object was created within
  inherited;
end;

procedure TVerInfoAccessor.InternalLoadFile(const FileName: string);
  {Loads version information (if present) from given file and creates a new
  reader object and wrapper for it. If file contains no version information then
  no wrapper object is created and its reference is set to nil}
var
  FileType: TExeFileType;       // type of executable file
  VIData: IVerInfoBinaryReader; // reader object for version info
  Stm: IStream;                 // stream used to read version info
  CLSID: TGUID;                 // id of binary ver info reader object required
begin
  // Dispose of any existing version info object
  fVerInfo := nil;
  // Assume no stream
  Stm := nil;
  // Get type of file to load and process accordingly
  FileType := ExeType(FileName);
  case FileType of
    etNotExec:
    begin
      // File may be a 32 bit resource file: we load it if so
      // a unicode reader is required for 32 bit resource files
      CLSID := CLSID_VerInfoBinaryReaderW;
      // open stream on ver info in res file: raises exception if not present
      // or if invalid resource file
      try
        Stm := TVInfoResFileIStream.Create(FileName, fmOpenRead);
      except
        // we have exception: say if file is not valid
        on EInvalidResourceFile do
          raise Exception.CreateFmt(sNotValidFile, [FileName]);
        on E: Exception do
          raise Exception.Create(E.Message);
      end;
    end;
    etDOS:
      // file is a DOS file: they contain no version info
      raise Exception.CreateFmt(sDOSExecutable, [FileName]);
    etVXD:
      // file is a virtual device driver: can't read version info from them
      raise Exception.CreateFmt(sVXDExecutable, [FileName]);
    etNE:
    begin
      // file is a 16 bit Windows executable:
      // an ansi reader is require on both NT and 9x
      CLSID := CLSID_VerInfoBinaryReaderA;
      // open stream on file's version info: exception if no info
      Stm := TVerInfoFileIStream.Create(FileName);
    end;
    etPE:
    begin
      // file is a 32 bit Windows executable
      // whether we need ansi or unicode reader depends on if we're running NT
      // since version info API we rely returns ansi encoding on 9x and unicode
      // on NT
      if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
        CLSID := CLSID_VerInfoBinaryReaderW
      else
        CLSID := CLSID_VerInfoBinaryReaderA;
      // open stream on file's version info: exception if no info
      Stm := TVerInfoFileIStream.Create(FileName);
    end;
    else
      // we should never get here unless TExeType enumeration extended
      Assert(False, 'Unexpected result from ExeType function');
  end;
  // Create version info reader object from within DLL
  if Failed(fVIBinDLL.CreateFunc(CLSID, VIData)) then
    // can't create binary data object
    raise Exception.Create(sNoWrapper);
  // Read the data from the stream: raise exception on error
  if Failed(VIData.ReadFromStream(Stm)) then
    raise Exception.CreateFmt(sVerInfoDataError, [VIData.LastErrorMsg]);
  // Create version info object to interface with DLL object
  fVerInfo := TVerInfo.Create(VIData);
end;

function TVerInfoAccessor.LastError: WideString;
  {Details of last error encountered in object ('' if last load operation
  succeeded)}
begin
  Result := fLastError;
end;

function TVerInfoAccessor.LoadFile(const FileName: PChar): WordBool;
  {Loads version information from a file. Returns true if file is loaded
  successfully and false on error (refer to LastError function for details of
  error if file fails to load)}
begin
  // Reset last error message: expect no error
  fLastError := '';
  try
    // Actually load the file: creates exception on error
    InternalLoadFile(FileName);
    //If we get here, everthing's worked OK
    Result := True;
  except
    // We have exception: store exception message for future access
    on E: Exception do
    begin
      Result := False;
      fLastError := E.Message;
    end;
  end;
end;

function TVerInfoAccessor.VerInfo: IVerInfoReader;
  {Reference to object that is used to read the version information that has
  been read (or nil if either no information has been read or loaded file
  contains no such information}
begin
  Result := fVerInfo;
end;


{ TVerInfoQuery }

function TVerInfoQuery.FileContainsVersionInfo(const FileName: PChar): WordBool;
  {Returns true if given file contains version information and false if not}
var
  Dummy: DWORD;           // dummy parameter for passing to Windows API call
  Stm: TStream;           // stream onto file
  ResFile: TResourceFile; // resource file object
begin
  try
    // First check if we have executable file containing version info
    Result := Windows.GetFileVersionInfoSize(FileName, Dummy) > 0;
    if Result then
      Exit;
    // Now check if file is a valid 32 bit resource file
    ResFile := nil;
    // create stream onto file
    Stm := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
    try
      // test to see if stream contains 32 bit resources
      if TResourceFile.IsValidResourceStream(Stm) then
      begin
        // valid resource file: rewind stream and load into resource file obj
        Stm.Position := 0;
        ResFile := TResourceFile.Create;
        ResFile.LoadFromStream(Stm);
        // test to see if version info resource is present
        Result := ResFile.EntryExists(RT_VERSION, MakeIntResource(1));
      end;
    finally
      ResFile.Free;
      Stm.Free;
    end;
  except
    // Exception raised: return false
    Result := False;
  end;
end;


{ Exported creator function }

function CreateFileReader(const CLSID: TGUID; out Obj): HResult; stdcall;
  {Creates the version info file reader object of the type specified by CLSID.
  If the library supports the object then an instance is created. A reference to
  the object is stored in Obj and S_OK is returned. If the library does not
  support CLSID then Obj is set to nil and E_NOTIMPL is returned. If there is an
  error in creating the object Obj is set to nil and E_FAIL is returned}
begin
  try
    // Assume success
    Result := S_OK;
    // Return requested objects
    if IsEqualIID(CLSID, CLSID_VerInfoFileReader) then
      IVerInfoFileReader(Obj) := TVerInfoAccessor.Create as IVerInfoFileReader
    else if IsEqualIID(CLSID, CLSID_VerInfoFileQuery) then
      IVerInfoFileQuery(Obj) := TVerInfoQuery.Create as IVerInfoFileQuery
    else
    begin
      // Unsupported object: set object nil and set error code
      Pointer(Obj) := nil;
      Result := E_NOTIMPL;
    end;
  except
    // Something went wrong: set object to nil and set error code
    Pointer(Obj) := nil;
    Result := E_FAIL;
  end;
end;

end.
