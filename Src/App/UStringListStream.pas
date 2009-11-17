{ ##
  @FILE                     UStringListStream.pas
  @COMMENTS                 Defines stream class for reading and writing string
                            lists.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
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
 * The Original Code is UStringListStream.pas.
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


unit UStringListStream;


interface


uses
  // Delphi
  Classes, ActiveX, SysUtils,
  // PJSoft library
  PJIStreams;


type

  {
  TStringListIStream
    Class that implements an IStream interface to reads & writes data from & to
    a string list object.

    Inheritance: TStringListIStream -> [TPJIStreamWrapper]
  }
  TStringListIStream = class(TPJIStreamWrapper, IStream)
  public
    constructor Create(const StrList: TStrings;
      const AutoUpdate: Boolean = False);
      {Class constructor: checks that the given string list is not nil and then
      wraps an underlying TStringListStream object to perform actual stream
      operations. If AutoUpdate parameter is true the string list is updated
      with each write, otherwise it is only updated with changes when the stream
      is destroyed}
  end;


implementation

type

  {
  TStringListStream:
    Class that provides access to a string list using a TStream descended
    stream. A string list can be provided by the used and can be either operated
    on directly or copied and the stream attached to the copy. Updates to
    external streams can either be immediate or can be deferred until just
    before the stream is destroyed.

    Inheritance: TStringListStream -> [TStream]
  }
  TStringListStream = class(TStream)
  private
    // properties
    function GetStrList: TStrings;
  private
    fStrList: TStrings;
      {Refers to the string list being accessed by the stream: either an owned
      string list or an external one}
    fStrStm: TStringStream;
      {A string stream object that is used for all actually input and output}
    fOwnList: Boolean;
      {Whether the string list is owned by this object (true) or by the caller
      (false)}
    fAutoUpdate: Boolean;
      {Whether the string list should be updated after every write (true) or
      just when the StrList property is read and the stream is destroyed}
  public
    constructor Create(const StrList: TStrings;
      const CopyStrings: Boolean = False; const AutoUpdate: Boolean = False);
      {Class constructor: creates stream instance that operates on the given
      string list. If CopyStrings is true that the given string list is copied
      to a new string list owned by the class. If StrList is nil then a new
      owned string list is created and read / write operations work on that
      list. If AutoUpdate is true then the string list is updated with each
      write operation, otherwise it is updated only when either StrList property
      is read or this object is freed}
    destructor Destroy; override;
      {Class destructor: frees the string list if it is owned by the stream or
      updated the external string list if required. Also frees the underlying
      owned stream object that handles i/o internally}
    function Read(var Buffer; Count: Longint): Longint; override;
      {Read Count bytes from stream into Buffer and return number of bytes read:
      we hand off this call to underlying string stream}
    function Write(const Buffer; Count: Longint): Longint; override;
      {Write count bytes from Buffer into stream and return number of bytes
      written: we hand off this call to underlying string stream. If we don't
      own the string list and we are auto-updating then we also update the
      string list to reflect stream contents}
    function Seek(Offset: Longint; Origin: Word): Longint; override;
      {Move stream position Offset bytes from given origin and return new
      position: we hand off this call to underlying string stream}
    property StrList: TStrings read GetStrList;
      {References the string list: either the external string list or the owned
      copy as appropriate. When this property is read the returned string list
      is guaranteed to to be updated to reflect all changes}
  end;


{ TStringListStream }

constructor TStringListStream.Create(const StrList: TStrings;
  const CopyStrings: Boolean; const AutoUpdate: Boolean);
  {Class constructor: creates stream instance that operates on the given string
  list. If CopyStrings is true that the given string list is copied to a new
  string list owned by the class. If StrList is nil then a new owned string list
  is created and read / write operations work on that list. If AutoUpdate is
  true then the string list is updated with each write operation, otherwise it
  is updated only when either StrList property is read or this object is freed}
begin
  inherited Create;
  // Decide if we need to own an internal string list we need to do this if user
  // wants us to copy provided string list or if no string list provided
  fOwnList := CopyStrings or not Assigned(StrList);
  fAutoUpdate := AutoUpdate;
  if fOwnList then
  begin
    // we need to own list: create it and assign any given strings
    fStrList := TStringList.Create;
    if Assigned(StrList) then
      fStrList.Assign(StrList);
  end
  else
    // we need to operate directly on user-provided string list
    fStrList := StrList;
  // Create string stream object that does all the work
  fStrStm := TStringStream.Create(fStrList.Text);
  fStrStm.Position := 0;
end;

destructor TStringListStream.Destroy;
  {Class destructor: frees the string list if it is owned by the stream or
  updated the external string list if required. Also frees the underlying owned
  stream object that handles i/o internally}
begin
  if fOwnList then
    // Only free string list if we own it
    fStrList.Free
  else if not fAutoUpdate then
    // Update non-owned string list with stream contents, unless it was auto-
    // updated, when contents will already be set
    fStrList.Text := fStrStm.DataString;
  // Free underlying string stream
  fStrStm.Free;
  inherited;
end;

function TStringListStream.GetStrList: TStrings;
  {Read access method for StrList property: returns reference to underlying
  string list. If we own the list or we are not auto-updating contents, ensure
  that contents of string list reflect stream contents before returning. If
  don't own list and are auto-updating there is no need to update list since
  it is updated by each write}
begin
  if fOwnList or not fAutoUpdate then
    fStrList.Text := fStrStm.DataString;
  Result := fStrList;
end;

function TStringListStream.Read(var Buffer; Count: Integer): Longint;
  {Read Count bytes from stream into Buffer and return number of bytes read: we
  hand off this call to underlying string stream}
begin
  Result := fStrStm.Read(Buffer, Count);
end;

function TStringListStream.Seek(Offset: Integer; Origin: Word): Longint;
  {Move stream position Offset bytes from given origin and return new position:
  we hand off this call to underlying string stream}
begin
  Result := fStrStm.Seek(Offset, Origin);
end;

function TStringListStream.Write(const Buffer; Count: Integer): Longint;
  {Write count bytes from Buffer into stream and return number of bytes written:
  we hand off this call to underlying string stream. If we don't own the string
  list and we are auto-updating then we also update the string list to reflect
  stream contents}
begin
  // Hand off actual write to underlying string stream
  Result := fStrStm.Write(Buffer, Count);
  // Check if we need to udpate the string list with stream contents
  if not fOwnList and fAutoUpdate then
    // this can be slow and will always re-read all strings into string list
    fStrList.Text := fStrStm.DataString;
end;


{ TStringListIStream }

resourcestring
  // Error messages
  sErrNilStrList = 'Can''t create IStringListStream on nil string list';

constructor TStringListIStream.Create(const StrList: TStrings;
  const AutoUpdate: Boolean);
  {Class constructor: checks that the given string list is not nil and then
  wraps an underlying TStringListStream object to perform actual stream
  operations. If AutoUpdate parameter is true the string list is updated with
  each write, otherwise it is only updated with changes when the stream is
  destroyed}
begin
  // Raise exception if string list is nil
  if not Assigned(StrList) then
    raise EStreamError.Create(sErrNilStrList);
  // Create a new string list stream object and wrap it with IStream interface
  inherited Create(             // this is PJIStreamWrapper constructor
    TStringListStream.Create(   // create a TStringListStream object to do i/o
      StrList,                  // underlying string list
      False,                    // act on actual string list, not a copy
      AutoUpdate                // udpate with each write or when stream freed
    ),
    True                        // destroy TStringListStream when wrapper freed
  );
end;

end.
