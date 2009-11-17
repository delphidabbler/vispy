{ ##
  @PROJECT_NAME             Version Information Spy File Reader DLL.
  @PROJECT_DESC             Enables version information data to be read from
                            excutable and binary resource files that contain
                            version information.
  @FILE                     UResourceFileStream.pas
  @COMMENTS                 Defines a stream class that reads or writes the data
                            of a given resource within a binary resource file.
  @DEPENDENCIES             PJIStreamWrapper from the PJIStreams library unit.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
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
 * The Original Code is UResourceFileStream.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2003 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 * 
 * ***** END LICENSE BLOCK *****
}


unit UResourceFileStream;


interface


uses
  // Delphi
  Classes, SysUtils, ActiveX,
  // PJSoft library
  PJIStreams,
  // Project
  UResourceFile;


type

  {
  TResourceFileIStream:
    Stream class to read or write the data of a given resource within a binary
    resource file.

    Inheritance: TResourceFileIStream -> [TPJIStreamWrapper]
  }
  TResourceFileIStream = class(TPJIStreamWrapper, IStream)
  private
    fResFile: TResourceFile;
      {Instance of object that can read / write binary resource streams}
    fFileStream: TFileStream;
      {File stream open on the binary resource file for reading / writing by the
      fResFile object}
    fMode: Word;
      {File open mode including sharing information}
    fOpenCode: Integer;
      {File open mode without sharing information}
    function OpenCode(Mode: Word): Integer;
      {Strips out the sharing information from the given file open mode and
      returns a code which describes whether file was created, opened for
      reading, opened for writing or opened for read/write}
  public
    constructor Create(const FileName: string; Mode: Word;
      const ResName, ResType: PChar);
      {Class constructor: creates an IStream instance that can access the data
      associated with the given resource type and name in the given file. Mode
      indicates how the stream is to be accessed}
    constructor CreateFromID(const FileName: string; Mode: Word;
      ResID: Integer; const ResType: PChar);
      {Class constructor: creates an IStream instance that can access the data
      associated with the given resource type and resource id in the given file.
      Mode indicates how the stream is to be accessed}
    destructor Destroy; override;
      {Class destructor: update resource file if changes made and free owned
      objects}
  end;

  {
  ENoResourceInStream:
    Exception raised by TResourceFileIStream when required resource can't be
    found.

    Inheritance: ENoResourceInStream -> [EStreamError]
  }
  EBinaryResNotFound = class(EStreamError);

  {
  EInvalidResourceFile:
    Exception raise by TResourceFileIStream when file is not a valid 32 bit
    resource file.

    Inheritance: EInvalidResourceFile -> [EStreamError]
  }
  EInvalidResourceFile = class(EStreamError);


implementation

uses
  // Delphi
  Windows,
  // Project
  UResourceUtils;


{ TResourceFileIStream }

resourcestring
  // Error messages
  sResNotFoundInFile =
    'Resource %0:s of type %1:s not found in resource file "%2:s".';
  sInvalidResFile = '"%s" is not a 32 bit resource file.';
  sBadOpenMode = 'Unrecognised open mode %0.8X in TResourceFileIStream.';

constructor TResourceFileIStream.Create(const FileName: string; Mode: Word;
  const ResName, ResType: PChar);
  {Class constructor: creates an IStream instance that can access the data
  associated with the given resource type and name in the given file. Mode
  indicates how the stream is to be accessed}
var
  Entry: TResourceEntry;  // resource file entry for ver info resource
  EntryDataStm: TStream;  // data stream associated with required res file entry
begin
  // Record file mode and record type of opening required without share info
  fMode := Mode;
  fOpenCode := OpenCode(Mode);
  // Create instance of resource file object to manipulate resources in file
  fResFile := TResourceFile.Create;
  // Open the existing file, if any
  fFileStream := TFileStream.Create(FileName, Mode);
  try
    case fOpenCode of
      fmOpenRead:
      begin
        // read only: load contents & free file stream (no longer required)
        fResFile.LoadFromStream(fFileStream);
        fFileStream.Free;
        fFileStream := nil;
      end;
      fmOpenReadWrite:
        // read write: load contents for updating & leave file stream open
        fResFile.LoadFromStream(fFileStream);
      fmCreate, fmOpenWrite:
        // creating or write only: nothing to load & leave file stream open
        {Do nothing};
    end;
  except
    // Convert any resource file exception to own exception
    on E: EResourceFile do
      raise EInvalidResourceFile.CreateFmt(sInvalidResFile, [FileName]);
    else
      raise
  end;
  // Find any existing resource entry with required name and id
  Entry := fResFile.FindEntry(ResType, ResName);
  // Add any new entry if not found
  case fOpenCode of
    fmOpenRead:
      // opening for reading not valid if there's no matching entry
      if not Assigned(Entry) then
        raise EBinaryResNotFound.CreateFmt(
          sResNotFoundInFile,
          [
            ResNameOrTypeAsString(ResName),
            ResNameOrTypeAsString(ResType),
            FileName
          ]
        );
    fmOpenReadWrite:
      // we're opening for read / write: if there's no entry, create it
      if not Assigned(Entry) then
        Entry := fResFile.AddEntry(ResType, PChar(ResName));
    fmCreate, fmOpenWrite:
    begin
      // we're creating or overwriting: we must create entry
      Assert(not Assigned(Entry));      // can't be entry - we didn't load file!
      Entry := fResFile.AddEntry(ResType, PChar(ResName));
    end;
  end;
  // If we get here there must be an entry: get reference to its data stream
  EntryDataStm := Entry.DataStream;
  // Now create an IStream on the given entry stream:
  // don't close it when done since it's owned by TResourceFile
  inherited Create(EntryDataStm, False);
end;

constructor TResourceFileIStream.CreateFromID(const FileName: string;
  Mode: Word; ResID: Integer; const ResType: PChar);
  {Class constructor: creates an IStream instance that can access the data
  associated with the given resource type and resource id in the given file.
  Mode indicates how the stream is to be accessed}
begin
  // Call other constructor with reasource id converted to a name
  Create(FileName, Mode, MakeIntResource(ResID), ResType);
end;

destructor TResourceFileIStream.Destroy;
  {Class destructor: update resource file if changes made and free owned
  objects}
begin
  case fOpenCode of
    fmOpenRead:
      // Read only: nothing to save
      {Do nothing};
    fmOpenReadWrite, fmOpenWrite, fmCreate:
    begin
      // In write mode: save updated resource file to file stream, overwriting
      fFileStream.Position := 0;
      fFileStream.Size := 0;
      fResFile.SaveToStream(fFileStream);
    end;
  end;
  // Free file stream and resource file instance
  fFileStream.Free;
  fResFile.Free;
  inherited;
end;

function TResourceFileIStream.OpenCode(Mode: Word): Integer;
  {Strips out the sharing information from the given file open mode and returns
  a code which describes whether file was created, opened for reading, opened
  for writing or opened for read/write}
begin
  if (Mode or fmOpenRead = fmOpenRead) then
    Result := fmOpenRead
  else if (Mode or fmOpenWrite = fmOpenWrite) then
    Result := fmOpenWrite
  else if (Mode or fmOpenReadWrite = fmOpenReadWrite) then
    Result := fmOpenReadWrite
  else if (Mode or fmCreate = fmCreate) then
    Result := fmCreate
  else
    raise EFOpenError.CreateFmt(sBadOpenMode, [Mode]);
end;

end.
