{ ##
  @PROJECT_NAME             Version Information Spy File Reader DLL.
  @PROJECT_DESC             Enables version information data to be read from
                            excutable and binary resource files that contain
                            version information.
  @FILE                     UResourceFile.pas
  @COMMENTS                 Class that encapsulates a 32 bit bianry resource
                            file and allows its resources to be read edited and
                            written.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 23/05/2004
      @COMMENTS             Added class function IsValidResourceStream to
                            TResourceFile and modified LoadFromStream method to
                            use it.
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
 * The Original Code is UResourceFile.pas.
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


unit UResourceFile;


interface


uses
  // Delphi
  SysUtils, Classes, Windows;

type

  {
  TResourceEntryHeader:
    Class used by other classes in unit to create a resource file header record
    of required kind. Properties of the header are exposed and the class can
    write the header to the current location in any given stream.

    TResourceEntryHeader => [TObject]
  }
  TResourceEntryHeader = class(TObject)
  private // properties
    fResName: PChar;
    fResType: PChar;
    function GetCharacteristics: DWORD;
    function GetDataSize: DWORD;
    function GetDataVersion: DWORD;
    function GetHeaderSize: DWORD;
    function GetLanguageID: WORD;
    function GetMemoryFlags: WORD;
    function GetVersion: DWORD;
    procedure SetCharacteristics(const Value: DWORD);
    procedure SetDataSize(const Value: DWORD);
    procedure SetDataVersion(const Value: DWORD);
    procedure SetLanguageID(const Value: WORD);
    procedure SetVersion(const Value: DWORD);
    procedure SetMemoryFlags(const Value: WORD);
  private
    fPWResType: PWideChar;
      {Pointer to start of resource type in header}
    fPWResName: PWideChar;
      {Pointer to start of resource name in header}
    fPResHeaderPrefix: Pointer;
      {Pointer to fixed-size prefix record in header}
    fPResHeaderPostfix: Pointer;
      {Pointer to fixed-size postfix record in header}
    fHeaderRecSize: Integer;
      {Size of the header record}
    fPHeader: Pointer;
      {Pointer to the whole header record}
    fPCharBuf: PChar;
      {Pointer to buffer used to hold res name and type in as PChars}
    fCharBufSize: Integer;
      {Size of above buffer}
    function NameOrTypeBufSize(ResNameOrType: PChar): Integer;
      {Size of buffer required to hold given resource name or resource type}
    function NameOrTypeWBufSize(ResNameOrType: PWideChar): Integer;
      {Size of wide char buffer required to holf given resource name or type}
    procedure StoreNameOrType(ResNameOrType: PChar; Buf: PWideChar);
      {Stores given resource name or type in the given location in the resource
      header}
    function NameOrTypeStrSize(PHdrNameOrType: PWideChar): Integer;
      {Returns size of buffer required to name or type pointed to by param.
      Size of buffer includes space required for zero terminator. Returns 0 if
      name or type is an ID}
    procedure ReadNameOrType(const PHdrNameOrType: PWideChar; var PBuf: PChar);
      {Reads resource name or type from given wide char buffer in resource
      header into given PChar buffer as string or coded id. If value is a coded
      ID then PBuf is modified to contain the value rather than point to it}
    procedure AllocateNewHeader(const ResName, ResType: PChar);
      {Allocates storage for a new resource header}
    procedure DeallocateHeader;
      {Deallocates storage used for resource header}
    procedure AllocateCharBuf(const Size: Integer);
      {Allocates buffer of required size to hold resource name and type
      properties}
    procedure DeallocateCharBuf;
      {Deallocates buffer used to hold resource name and type properties}
    procedure InitResNameAndTypeProps;
      {Initialise values of resource name and resource type properties: called
      from both constructors}
  public
    constructor Create(const ResName: PChar; const ResType: PChar);
      {Class constructor - creates a header record for the given resource name
      and type. All other properties except for HeaderSize are set to zero}
    constructor CreateFromStream(const Stream: TStream);
      {Class constructor - creates a header record object per that at the
      current position in the given stream}
    destructor Destroy; override;
      {Class destructor: frees storage}
    procedure WriteToStream(const Stream: TStream);
      {Writes header record to stream}
    property DataSize: DWORD
      read GetDataSize write SetDataSize;
      {The size of the resource data, excluding padding}
    property HeaderSize: DWORD
      read GetHeaderSize;
      {The size of the header record}
    property DataVersion: DWORD
      read GetDataVersion write SetDataVersion;
      {Predefined data resource version information}
    property MemoryFlags: WORD
      read GetMemoryFlags write SetMemoryFlags;
      {Attribute flags specifying state of resource - many ignored under Win 32}
    property LanguageID: WORD
      read GetLanguageID write SetLanguageID;
      {The language for the resource}
    property Version: DWORD
      read GetVersion write SetVersion;
      {User specified version number for the resource data}
    property Characteristics: DWORD
      read GetCharacteristics write SetCharacteristics;
      {User defined information about the resource}
    property ResName: PChar read fResName;
      {The resource name: may be a character string or an ID}
    property ResType: PChar read fResType;
      {The resource type: may be a character string or an ID}
  end;

  TResourceFile = class;

  {
  TResourceEntry:
    Class that encapsulates an entry in a resource file. Enables resource name,
    type and other properties to be set and allows resource's data to read and
    written. The resource data is treated as raw binary bytes and it is for the
    user to interpret the meaning of the data. This class may only be
    constructed by TResourceFile objects and should not be constructed by the
    user.

    Inheritance: TResourceEntry => [TObject]
  }
  TResourceEntry = class(TObject)
  private // properties
    fOwner: TResourceFile;
    fDataStream: TStream;
    function GetResName: PChar;
    function GetResType: PChar;
    function GetDataSize: LongInt;
    function GetCharacteristics: DWORD;
    function GetDataVersion: DWORD;
    function GetLanguageID: WORD;
    function GetMemoryFlags: WORD;
    function GetVersion: DWORD;
    procedure SetCharacteristics(const Value: DWORD);
    procedure SetDataVersion(const Value: DWORD);
    procedure SetLanguageID(const Value: WORD);
    procedure SetMemoryFlags(const Value: WORD);
    procedure SetVersion(const Value: DWORD);
  private
    fHeader: TResourceEntryHeader;
      {The resource entry's header}
  protected
    constructor Create(ResType, ResName: PChar; Owner: TResourceFile); overload;
      {Class constructor: creates new resource entry of given type and name
      within given (Owner) resource file. Owner must be provided. This
      constructor can only accessed from resource file object}
    constructor Create(Stream: TStream; Owner: TResourceFile); overload;
      {Class constructor: creates new resource entry from given stream that is
      part of resource file specified by Owner parameter, which must be
      provided. This constructor may only be called from resource file object}
  public
    constructor Create; overload;
      {Public class constructor: must not be called}
    destructor Destroy; override;
      {Class destructor: frees owned objects and unlinks entry from owning
      resource file}
    procedure WriteToStream(Stm: TStream);
      {Writes resource entry to given stream}
    function IsEqualResType(ResType: PChar): Boolean;
      {Returns true if given resource type is same as this entry's type}
    function IsEqualResName(ResName: PChar): Boolean;
      {Returns true if given resource name is same as this entry's name}
    property Owner: TResourceFile read fOwner;
      {Identifies resource file that this entry belongs to}
    property ResName: PChar read GetResName;
      {Name of resource entry}
    property ResType: PChar read GetResType;
      {Type of resource entry}
    property DataSize: LongInt read GetDataSize;
      {Size of data in this entry}
    property DataVersion: DWORD
      read GetDataVersion write SetDataVersion;
      {Predefined data resource version information}
    property MemoryFlags: WORD
      read GetMemoryFlags write SetMemoryFlags;
      {Attribute flags specifying state of resource - many ignored under Win 32}
    property LanguageID: WORD
      read GetLanguageID write SetLanguageID;
      {The language for the resource}
    property Version: DWORD
      read GetVersion write SetVersion;
      {User specified version number for the resource data}
    property Characteristics: DWORD
      read GetCharacteristics write SetCharacteristics;
      {User defined information about the resource}
    property DataStream: TStream read fDataStream;
      {Stream storing the data associated with this resource}
  end;

  {
  TResourceFile:
    Class that encapsulates a 32 bit binary resource file and exposes the
    entries within it. This class allows reading, creation and editing of
    resource files.

    Inheritance: TResourceFile => [TObject]
  }
  TResourceFile = class(TObject)
  private // properties
    fEntries: TList;
    function GetEntry(Idx: Integer): TResourceEntry;
  private
    f32bitMarker: TResourceEntry;
      {A resource entry for the marker entry that begins all 32 bit resource
      files}
  public
    constructor Create;
      {Class constructor: create owned entry list and marker objects}
    destructor Destroy; override;
      {Class destructor: frees all entries and other owned objects}
    procedure LoadFromStream(Stm: TStream);
      {Loads resource file from given stream, checking that the file on the
      stream is valid}
    procedure SaveToStream(Stm: TStream);
      {Writes the resource file to the given stream}
    function AddEntry(ResType, ResName: PChar): TResourceEntry;
      {Adds a new empty resource to the resource file and returns reference to
      object for resource entry. Raises exception if resource of given name and
      type already exists}
    function FindEntry(ResType, ResName: PChar): TResourceEntry;
      {Searches resource file for a resource with given name and type and
      returns an entry object for it if found. Returns nil if matching resource
      not found}
    function FindEntryIndex(ResType, ResName: PChar): Integer;
      {Searches resource file for resource with given name and type and returns
      its index in the entry list. Returns -1 if no matching resource entry is
      found}
    function EntryExists(ResType, ResName: PChar): Boolean;
      {Returns true if a resource with given type and name in the resource file
      exists and false if not}
    function IndexOfEntry(Entry: TResourceEntry): Integer;
      {Returns index of given resource entry object in list of resources or -1
      if there is no such entry in list}
    function DeleteEntry(Entry: TResourceEntry): Boolean;
      {Deletes the given resource entry object from list of resources. Returns
      true if resource was deleted or False in resource entry is not in list}
    procedure Clear;
      {Clears all resources from file and frees the resource entry objects}
    class function IsValidResourceStream(const Stm: TStream): Boolean;
      {Returns true if the given stream contains a valid 32 bit resource "file"
      beginning at the current postion}
    function EntryCount: Integer;
      {Returns number of resources (entries) in file}
    property Entries[Idx: Integer]: TResourceEntry read GetEntry;
      {List of resource entries in file: returns resource entry object that
      encapsulates the resource}
  end;

  {
  EResourceFile:
    Class of exception raised by resource file objects.

    Inheritance: EResourceFile => [Exception]
  }
  EResourceFile = class(Exception);


implementation


uses
  // Project
  UResourceUtils;


type

  {
  TResourceEntryHeaderPrefix:
    Fixed length prefix to resource file header. Preceeds variable length name
    and type records.
  }
  TResourceEntryHeaderPrefix = record
    DataSize: DWORD;        // size of resource data exc padding before next res
    HeaderSize: DWORD;      // size of resource data header
  end;

  {
  PResourceEntryHeaderPrefix:
    Pointer to TResourceEntryHeaderPrefix record.
  }
  PResourceEntryHeaderPrefix = ^TResourceEntryHeaderPrefix;

  {
  TResourceEntryHeaderPostfix:
    Fixed length postfix to resource file header: follows variable length name
    and type records.
  }
  TResourceEntryHeaderPostfix = record
    DataVersion: DWORD;     // version of the data resource - we don't use this
    MemoryFlags: WORD;      // describe the state of the resource
    LanguageId: WORD;       // language for the resource - we don't use this
    Version: DWORD;         // user defined res version - we don't use this
    Characteristics: DWORD; // user defined info about res - we don't use this
  end;

  {
  PResourceEntryHeaderPostfix:
    Pointer to TResourceEntryHeaderPostfix record.
  }
  PResourceEntryHeaderPostfix = ^TResourceEntryHeaderPostfix;

type

  {
  TResourceEntryStream:
    Stream object used to store resource entry's data. Updates data stream size
    in owning resource entry object whenever it changes. This stream must be
    associated with a resource entry object.

    TResourceEntryStream => [TMemoryStream]
  }
  TResourceEntryStream = class(TMemoryStream)
  private
    fOwner: TResourceEntry;
      {Reference to owning resource entry object}
    procedure UpdateDataSize;
      {Updates data size property in owning resource entry object}
  protected
    procedure SetSize(NewSize: Longint); override;
      {Sets stream to given size and records in owning resource entry}
  public
    function Write(const Buffer; Count: Longint): Longint; override;
      {Writes count bytes from Buffer to stream and returns number of bytes
      actually written. Updates data size in owning resource entry with new
      stream size}
    constructor Create(Owner: TResourceEntry);
      {Class constructor: creates stream object associated with given resource
      entry object (which must be provided}
  end;

function PaddingRequired(const ANum: LongInt; const PadTo: Integer): Integer;
  {Returns number of bytes padding required to increase ANum to a multiple of
  PadTo}
begin
  if ANum mod PadTo = 0 then
    Result := 0
  else
    Result := PadTo - ANum mod PadTo;
end;


{ TResourceFile }

function TResourceFile.AddEntry(ResType, ResName: PChar): TResourceEntry;
  {Adds a new empty resource to the resource file and returns reference to
  object for resource entry. Raises exception if resource of given name and
  type already exists}
begin
  if FindEntry(ResType, ResName) <> nil then
    raise EResourceFile.Create('Duplicate entry: can''t add to resource file');
  Result := TResourceEntry.Create(ResType, ResName, Self);
  fEntries.Add(Result);
end;

procedure TResourceFile.Clear;
  {Clears all resources from file and frees the resource entry objects}
var
  Idx: Integer; // loops thru all entries
begin
  for Idx := Pred(EntryCount) downto 0 do
    Entries[Idx].Free;  // entry deletes self from Entries list when freed
end;

constructor TResourceFile.Create;
  {Class constructor: create owned entry list and marker objects}
begin
  inherited;
  fEntries := TList.Create;
  f32bitMarker := TResourceEntry.Create(
    MakeIntResource(0), MakeIntResource(0), Self
  );
end;

function TResourceFile.DeleteEntry(Entry: TResourceEntry): Boolean;
  {Deletes the given resource entry object from list of resources. Returns true
  if resource was deleted or False in resource entry is not in list}
var
  Idx: Integer; // index of entry in list
begin
  Idx := IndexOfEntry(Entry);
  Result := Idx > -1;
  if Result then
    fEntries.Delete(Idx);
end;

destructor TResourceFile.Destroy;
  {Class destructor: frees all entries and other owned objects}
begin
  Clear;  // frees the entries
  f32bitMarker.Free;
  fEntries.Free;
  inherited;
end;

function TResourceFile.EntryCount: Integer;
  {Returns number of resources (entries) in file}
begin
  Result := fEntries.Count;
end;

function TResourceFile.EntryExists(ResType, ResName: PChar): Boolean;
  {Returns true if a resource with given type and name in the resource file
  exists and false if not}
begin
  Result := Assigned(FindEntry(ResType, ResName));
end;

function TResourceFile.FindEntry(ResType, ResName: PChar): TResourceEntry;
  {Searches resource file for a resource with given name and type and returns
  an entry object for it if found. Returns nil if matching resource not found}
var
  Idx: Integer; // loops thru all resource entries in file
begin
  Result := nil;
  for Idx := 0 to Pred(EntryCount) do
    if Entries[Idx].IsEqualResType(ResType)
      and Entries[Idx].IsEqualResName(ResName) then
    begin
      Result := Entries[Idx];
      Break;
    end;
end;

function TResourceFile.FindEntryIndex(ResType, ResName: PChar): Integer;
  {Searches resource file for resource with given name and type and returns its
  index in the entry list. Returns -1 if no matching resource entry is found}
begin
  Result := IndexOfEntry(FindEntry(ResType, ResName))
end;

function TResourceFile.GetEntry(Idx: Integer): TResourceEntry;
  {Read access method for Entries property}
begin
  Result := TResourceEntry(fEntries[Idx]);
end;

function TResourceFile.IndexOfEntry(Entry: TResourceEntry): Integer;
  {Returns index of given resource entry object in list of resources or -1 if
  there is no such entry in list}
begin
  Result := fEntries.IndexOf(Entry);
end;

class function TResourceFile.IsValidResourceStream(const Stm: TStream): Boolean;
  {Returns true if the given stream contains a valid 32 bit resource "file"
  beginning at the current postion}
const
  DummyHeader: array[0..7] of Byte = ($00, $00, $00, $00, $20, $00, $00, $00);
    {Expected bytes in the header record that introduces a 32 bit resource file}
var
  HeaderBuf: array[0..31] of Byte;  // stores bytes in introcutory header
begin
  // Try to read in header
  if Stm.Read(HeaderBuf, SizeOf(HeaderBuf)) = SizeOf(HeaderBuf) then
    // Check if header is equivalent to dummy header that starts resource files
    Result := CompareMem(@HeaderBuf, @DummyHeader, SizeOf(DummyHeader))
  else
    // Couldn't read header
    Result := False;
end;

procedure TResourceFile.LoadFromStream(Stm: TStream);
  {Loads resource file from given stream, checking that the file on the stream
  is valid}
begin
  // Clear any previous entries from file object
  Clear;
  // Test for header of 32 bit resource file
  if not IsValidResourceStream(Stm) then
    raise EResourceFile.Create('Invalid 32 bit resource file');
  // We have 32 bit resource file and we've passed header: read the resources
  while Stm.Position < Stm.Size do
    fEntries.Add(TResourceEntry.Create(Stm, Self));
end;

procedure TResourceFile.SaveToStream(Stm: TStream);
  {Writes the resource file to the given stream}
var
  Idx: Integer; // loops thru all entries
begin
  // Write the 32 bit resource file header entry
  f32bitMarker.WriteToStream(Stm);
  // Write the entries
  for Idx := 0 to Pred(EntryCount) do
    Entries[Idx].WriteToStream(Stm);
end;


{ TResourceEntry }

constructor TResourceEntry.Create(ResType, ResName: PChar;
  Owner: TResourceFile);
  {Class constructor: creates new resource entry of given type and name within
  given (Owner) resource file. Owner must be provided. This constructor can only
  accessed from resource file object}
begin
  Assert(Assigned(Owner));
  inherited Create;
  // Record reference to owner file
  fOwner := Owner;
  // Create owned header and data objects
  fHeader := TResourceEntryHeader.Create(ResName, ResType);
  fDataStream := TResourceEntryStream.Create(Self);
end;

constructor TResourceEntry.Create;
  {Public class constructor: must not be called}
begin
  Assert(False, 'Can''t construct instances of TResourceEntry directly');
end;

constructor TResourceEntry.Create(Stream: TStream;
  Owner: TResourceFile);
  {Class constructor: creates new resource entry from given stream that is part
  of resource file specified by Owner parameter, which must be provided. This
  constructor may only be called from resource file object}
var
  Padding: Integer;                       // no of padding bytes required
  Dummy: array[0..SizeOf(DWORD)] of Byte; // array used to write padding bytes
begin
  Assert(Assigned(Owner));
  inherited Create;
  // Record owner
  fOwner := Owner;
  // Create owned header object from stream
  fHeader := TResourceEntryHeader.CreateFromStream(Stream);
  // Create data object and read from stream
  fDataStream := TResourceEntryStream.Create(Self);
  if fHeader.DataSize > 0 then
  begin
    // copy data and set data position to start
    fDataStream.CopyFrom(Stream, fHeader.DataSize);
    fDataStream.Position := 0;
    // read and discard any padding that follows data in stream
    Padding := PaddingRequired(fHeader.DataSize, SizeOf(DWORD));
    if Padding > 0 then
      Stream.Read(Dummy, Padding);
  end;
end;

destructor TResourceEntry.Destroy;
  {Class destructor: frees owned objects and unlinks entry from owning resource
  file}
begin
  fDataStream.Free;
  // Delete from owner list
  if Assigned(fOwner) then
    fOwner.DeleteEntry(Self);
  // Free header class
  fHeader.Free;
  inherited;
end;

function TResourceEntry.GetCharacteristics: DWORD;
  {Read access method for Characteristics property: retrieved from owned header
  object}
begin
  Result := fHeader.Characteristics;
end;

function TResourceEntry.GetDataSize: LongInt;
  {Read access method for DataSize property: retrieved from owned header object}
begin
  Assert(LongInt(fHeader.DataSize) = fDataStream.Size);
  Result := fHeader.DataSize;
end;

function TResourceEntry.GetDataVersion: DWORD;
  {Read access method for DataVersion property: retrieved from owned header
  object}
begin
  Result := fHeader.DataVersion;
end;

function TResourceEntry.GetLanguageID: WORD;
  {Read access method for LanguageID property: retrieved from owned header
  object}
begin
  Result := fHeader.LanguageID;
end;

function TResourceEntry.GetMemoryFlags: WORD;
  {Read access method for MemoryFlags property: retrieved from owned header
  object}
begin
  Result := fHeader.MemoryFlags;
end;

function TResourceEntry.GetResName: PChar;
  {Read access method for ResName property: retrieved from owned header object}
begin
  Result := fHeader.ResName;
end;

function TResourceEntry.GetResType: PChar;
  {Read access method for ResType property: retrieved from owned header object}
begin
  Result := fHeader.ResType;
end;

function TResourceEntry.GetVersion: DWORD;
  {Read access method for Version property: retrieved from owned header object}
begin
  Result := fHeader.Version;
end;

function TResourceEntry.IsEqualResName(ResName: PChar): Boolean;
  {Returns true if given resource name is same as this entry's name}
begin
  Result := IsEqualResNameOrType(ResName, Self.ResName);
end;

function TResourceEntry.IsEqualResType(ResType: PChar): Boolean;
  {Returns true if given resource type is same as this entry's type}
begin
  Result := UResourceUtils.IsEqualResNameOrType(ResType, Self.ResType);
end;

procedure TResourceEntry.SetCharacteristics(const Value: DWORD);
  {Read access method for Characteristices property: sets equivalent property in
  owned header object}
begin
  fHeader.Characteristics := Value;
end;

procedure TResourceEntry.SetDataVersion(const Value: DWORD);
  {Read access method for DataVersion property: sets equivalent property in
  owned header object}
begin
  fHeader.DataVersion := Value;
end;

procedure TResourceEntry.SetLanguageID(const Value: WORD);
  {Read access method for LanguageID property: sets equivalent property in
  owned header object}
begin
  fHeader.LanguageID := Value;
end;

procedure TResourceEntry.SetMemoryFlags(const Value: WORD);
  {Read access method for MemoryFlags property: sets equivalent property in
  owned header object}
begin
  fHeader.MemoryFlags := Value;
end;

procedure TResourceEntry.SetVersion(const Value: DWORD);
  {Read access method for Version property: sets equivalent property in owned
  header object}
begin
  fHeader.Version := Value;
end;

procedure TResourceEntry.WriteToStream(Stm: TStream);
  {Writes resource entry to given stream}
var
  DataPos: LongInt;                       // bookmarks data stream position
  Padding: Integer;                       // no of padding bytes required
  Dummy: array[0..SizeOf(DWORD)] of Byte; // array used to write padding bytes
begin
  Assert(LongInt(fHeader.DataSize) = fDataStream.Size);
  // Write header to stream
  fHeader.WriteToStream(Stm);
  // Write data to stream and restore original stream position when finished
  DataPos := fDataStream.Position;
  try
    fDataStream.Position := 0;
    Stm.CopyFrom(fDataStream, fHeader.DataSize);
  finally
    fDataStream.Position := DataPos;
  end;
  // Write out any required padding
  Padding := PaddingRequired(fHeader.DataSize, SizeOf(DWORD));
  if Padding > 0 then
    Stm.Write(Dummy, Padding);
end;


{ TResourceEntryStream }

constructor TResourceEntryStream.Create(Owner: TResourceEntry);
  {Class constructor: creates stream object associated with given resource entry
  object (which must be provided}
begin
  Assert(Owner <> nil);
  inherited Create;
  fOwner := Owner;
end;

procedure TResourceEntryStream.SetSize(NewSize: Integer);
  {Sets stream to given size and records in owning resource entry}
begin
  inherited;
  UpdateDataSize;
end;

procedure TResourceEntryStream.UpdateDataSize;
  {Updates data size property in owning resource entry object}
begin
  // We actually update datasize record in entry's header object
  fOwner.fHeader.DataSize := Size;
end;

function TResourceEntryStream.Write(const Buffer; Count: Integer): Longint;
  {Writes count bytes from Buffer to stream and returns number of bytes actually
  written. Updates data size in owning resource entry with new stream size}
begin
  Result := inherited Write(Buffer, Count);
  UpdateDataSize;
end;


{ TResourceEntryHeader }

procedure TResourceEntryHeader.AllocateCharBuf(const Size: Integer);
  {Allocates buffer of required size to hold resource name and type properties}
begin
  DeallocateCharBuf;
  if Size > 0 then
    GetMem(fPCharBuf, Size);
  fCharBufSize := Size;
end;

procedure TResourceEntryHeader.AllocateNewHeader(const ResName, ResType: PChar);
  {Allocates storage for a new resource header}
var
  ResNameSize: Integer;   // size of resource name buffer
  ResTypeSize: Integer;   // size of resource type buffer
  Padding: Integer;       // padding require in header after resource name
  P: PByte;               // points to start of various header sub-records
begin
  // Calculate size of header required
  ResNameSize := NameOrTypeBufSize(ResName);
  ResTypeSize := NameOrTypeBufSize(ResType);
  Padding := PaddingRequired(ResNameSize + ResTypeSize, SizeOf(DWORD));
  fHeaderRecSize := SizeOf(TResourceEntryHeaderPrefix)
    + SizeOf(TResourceEntryHeaderPostfix)
    + ResNameSize + ResTypeSize + Padding;
  // Allocate header and set bytes to zero
  GetMem(fPHeader, fHeaderRecSize);
  FillChar(fPHeader^, fHeaderRecSize, #0);
  // Record pointers to data items
  // .. resource header prefix record
  P := fPHeader;
  fPResHeaderPrefix := Pointer(P);
  // .. resource type
  Inc(P, SizeOf(TResourceEntryHeaderPrefix));
  fPWResType := Pointer(P);
  // .. resource name
  Inc(P, ResTypeSize);
  fPWResName := Pointer(P);
  // .. resource header postfix record
  Inc(P, ResNameSize);
  Inc(P, PaddingRequired(ResTypeSize + ResNameSize, SizeOf(DWORD)));
  fPResHeaderPostfix := Pointer(P);
  // Record header buffer size in buffer
  PResourceEntryHeaderPrefix(fPResHeaderPrefix)^.HeaderSize := fHeaderRecSize;
end;

constructor TResourceEntryHeader.Create(const ResName, ResType: PChar);
  {Class constructor - creates a header record for the given resource name and
  type. All other properties except for HeaderSize are set to zero}
begin
  inherited Create;
  // Create storage for new header
  AllocateNewHeader(ResName, ResType);
  // Store resource name and type in header
  StoreNameOrType(ResName, fPWResName);
  StoreNameOrType(ResType, fPWResType);
  // Record resource name and type properties
  InitResNameAndTypeProps;
end;

constructor TResourceEntryHeader.CreateFromStream(const Stream: TStream);
  {Class constructor - creates a header record object per that at the current
  position in the given stream}
var
  ResHeaderPrefix: TResourceEntryHeaderPrefix;
  Pos: LongInt;
  P: PByte;
begin
  inherited Create;

  // Allocate header of required size
  // read header prefix and extract header size from it
  Pos := Stream.Position;  // remember where we are in stream: we come back here
  Stream.Read(ResHeaderPrefix, SizeOf(TResourceEntryHeaderPrefix));
  fHeaderRecSize := ResHeaderPrefix.HeaderSize;
  // now alocate required memory
  GetMem(fPHeader, fHeaderRecSize);

  // Read in the whole header
  // rewind stream to where we were before reading ahead
  Stream.Position := Pos;
  // read the header
  Stream.Read(fPHeader^, fHeaderRecSize);

  // Set required header pointers
  // header prefix
  P := Pointer(fPHeader);
  fPResHeaderPrefix := Pointer(P);
  // resource type
  Inc(P, SizeOf(TResourceEntryHeaderPrefix));
  fPWResType := Pointer(P);
  // resource name
  Inc(P, NameOrTypeWBufSize(fPWResType));
  fPWResName := Pointer(P);
  // header postfix
  Inc(P, NameOrTypeWBufSize(fPWResName));
  Inc(P, PaddingRequired(NameOrTypeWBufSize(fPWResName)
    + NameOrTypeWBufSize(fPWResType), SizeOf(DWORD)));
  fPResHeaderPostfix := Pointer(P);

  // Record resource name and type properties
  InitResNameAndTypeProps;
end;

procedure TResourceEntryHeader.DeallocateCharBuf;
  {Deallocates buffer used to hold resource name and type properties}
begin
  if fCharBufSize <> 0 then
    FreeMem(fPCharBuf, fCharBufSize);
  fCharBufSize := 0;
end;

procedure TResourceEntryHeader.DeallocateHeader;
  {Deallocates storage used for resource header}
begin
  if fHeaderRecSize <> 0 then
    FreeMem(fPHeader, fHeaderRecSize);
  fHeaderRecSize := 0;
end;

destructor TResourceEntryHeader.Destroy;
  {Class destructor: frees storage}
begin
  DeallocateCharBuf;
  DeallocateHeader;
  inherited Destroy;
end;

function TResourceEntryHeader.GetCharacteristics: DWORD;
  {Read access method for Characteristics property}
begin
  Result := PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.Characteristics;
end;

function TResourceEntryHeader.GetDataSize: DWORD;
  {Read access method for DataSize property}
begin
  Result := PResourceEntryHeaderPrefix(fPResHeaderPrefix)^.DataSize;
end;

function TResourceEntryHeader.GetDataVersion: DWORD;
  {Read access method for DataVersion property}
begin
  Result := PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.DataVersion;
end;

function TResourceEntryHeader.GetHeaderSize: DWORD;
  {Read access method for HeaderSize property}
begin
  Result := PResourceEntryHeaderPrefix(fPResHeaderPrefix)^.HeaderSize;
end;

function TResourceEntryHeader.GetLanguageID: WORD;
  {Read access method for LanguageID property}
begin
  Result := PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.LanguageId;
end;

function TResourceEntryHeader.GetMemoryFlags: WORD;
  {Read access method for MemoryFlags property}
begin
  Result := PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.MemoryFlags;
end;

function TResourceEntryHeader.GetVersion: DWORD;
  {Read access method for Version property}
begin
  Result := PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.Version;
end;

procedure TResourceEntryHeader.InitResNameAndTypeProps;
  {Initialise values of resource name and resource type properties: called from
  both constructors}
begin
  // Allocate buffer to hold resource name and resource type properties
  AllocateCharBuf(NameOrTypeStrSize(fPWResName)
    + NameOrTypeStrSize(fPWResType));
  // Set pointers to resource name and resource type properties
  fResName := fPCharBuf;
  fResType := fPCharBuf;
  Inc(fResType, NameOrTypeStrSize(fPWResName));
  // Store property values
  ReadNameOrType(fPWResName, fResName);
  ReadNameOrType(fPWResType, fResType);
end;

function TResourceEntryHeader.NameOrTypeBufSize(ResNameOrType: PChar): Integer;
  {Size of buffer required to hold given resource name or resource type}
begin
  if ResNameOrTypeIsID(ResNameOrType) then
    // This is an integer valued id - we store it in a DWORD size record
    Result := SizeOf(DWORD)
  else
    // This is a string valued id - we store it as 0 terminated Unicode
    Result := SizeOf(WideChar) * (StrLen(ResNameOrType) + 1);
end;

function TResourceEntryHeader.NameOrTypeStrSize(
  PHdrNameOrType: PWideChar): Integer;
  {Returns size of buffer required to name or type pointed to by param. Size of
  buffer includes space required for zero terminator. Returns 0 if name or type
  is an ID}
begin
  if WORD(PHdrNameOrType^) = $FFFF then
    Result := 0
  else
    Result := Length(WideCharToString(PHdrNameOrType)) + 1;
end;

function TResourceEntryHeader.NameOrTypeWBufSize(
  ResNameOrType: PWideChar): Integer;
  {Size of wide char buffer required to holf given resource name or type}
begin
  if Word(ResNameOrType^) = $FFFF then
    Result := SizeOf(DWORD)
  else
    Result := SizeOf(WideChar) * (Length(ResNameOrType) + 1);
end;

procedure TResourceEntryHeader.ReadNameOrType(const PHdrNameOrType: PWideChar;
  var PBuf: PChar);
  {Reads resource name or type from given wide char buffer in resource header
  into given PChar buffer as string or coded id. If value is a coded ID then
  PBuf is modified to contain the value rather than point to it}
var
  WPtr: PWideChar;  // pointer into wide char buffer
  PPtr: PChar;      // pointer into character buffer
begin
  // Point to start of wide char buffer in header record
  WPtr := PHdrNameOrType;
  if WORD(PHdrNameOrType^) = $FFFF then
  begin
    // This is an ID: make character pointer store the value
    Inc(WPtr);
    PBuf := MakeIntResource(WORD(WPtr^));
  end
  else
  begin
    // This is a name: copy it into character buffer
    PPtr := PBuf;
    while WPtr^ <> WideChar(#0) do
    begin
      PPtr^ := WideCharToString(WPtr)[1];
      Inc(WPtr);
      Inc(PPtr);
    end;
    PPtr^ := #0;
  end;
end;

procedure TResourceEntryHeader.SetCharacteristics(const Value: DWORD);
  {Write access method for Characteristics property}
begin
  PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.Characteristics := Value;
end;

procedure TResourceEntryHeader.SetDataSize(const Value: DWORD);
  {Write access method for DataSize property}
begin
  PResourceEntryHeaderPrefix(fPResHeaderPrefix)^.DataSize := Value;
end;

procedure TResourceEntryHeader.SetDataVersion(const Value: DWORD);
  {Write access method for DataVersion property}
begin
  PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.DataVersion := Value;
end;

procedure TResourceEntryHeader.SetLanguageID(const Value: WORD);
  {Write access method for LanguageID property}
begin
  PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.LanguageId := Value;
end;

procedure TResourceEntryHeader.SetMemoryFlags(const Value: WORD);
  {Write access method for MemoryFlags property}
begin
  PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.MemoryFlags := Value;
end;

procedure TResourceEntryHeader.SetVersion(const Value: DWORD);
  {Write access method for Version property}
begin
  PResourceEntryHeaderPostfix(fPResHeaderPostfix)^.Version := Value;
end;

procedure TResourceEntryHeader.StoreNameOrType(ResNameOrType: PChar;
  Buf: PWideChar);
  {Stores given resource name or type in the given location in the resource
  header}
var
  Size: Integer;    // size of string (for string valued id)
  Str: string;      // the string to be stored (for string valued id)
  Value: DWORD;     // the value to be stored (for integer valued id)
begin
  if ResNameOrTypeIsID(ResNameOrType) then
  begin
    // This is an integer valued id - we store it with FFFF as high word
    Value := $0000FFFF or (DWORD(LoWord(ResNameOrType)) shl 16);
    Move(Value, Buf^, SizeOf(DWORD));
  end
  else
  begin
    // This is string valued is - we store it as a 0 terminated Unicode string
    Str := StrPas(ResNameOrType);       // convert to string
    Size := Length(ResNameOrType) + 1;  // record buffer size
    StringToWideChar(Str, Buf, Size);   // convert Unicode
  end;
end;

procedure TResourceEntryHeader.WriteToStream(const Stream: TStream);
  {Writes header record to stream}
var
  PHeader: PByte;     // points to header record
begin
  // Record pointer to array of bytes that is header record
  PHeader := fPHeader;
  // Write the array of bytes to stream
  Stream.WriteBuffer(PHeader^, fHeaderRecSize);
end;

end.
