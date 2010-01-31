{
 * UVerInfoFileStream.pas
 *
 * Defines stream class for accessing version information embedded in an
 * executable file.
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
 * The Original Code is UVerInfoStream.pas.
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


unit UVerInfoStream;

interface

uses
  // Delphi
  ActiveX,
  // PJSoft library
  PJIStreams;

type

  {
  TVerInfoFileIStream:
    File stream for accessing version information embedded in an executable
    file. Implements the IStream interface.

    Inheritance: TVerInfoFileIStream -> [TPJIStreamWrapper]
      -> [TInterfacedObject] -> [TObject]
  }
  TVerInfoFileIStream = class(TPJIStreamWrapper, IStream)
  public
    constructor Create(const FileName: string);
      {Class constructor: creates a wrapped TVerInforFileStream stream object
      that is used to access version information. This wrapped stream is auto-
      matically freed when this object is destroyed}
  end;

implementation

uses
  // Delphi
  SysUtils, Classes, Windows;

type

  {
  TVerInfoFileStream:
    Read only stream class for accessing version information embedded in an
    executable file. Where no version information is present the stream is
    empty.

    Inheritance: TVerInfoFileStream -> [TCustomMemoryStream] -> [TStream]
      -> [TObject]
  }
  TVerInfoFileStream = class(TCustomMemoryStream)
  private
    fInfoBuffer: Pointer;
      {Pointer to the buffer used to hold version information data}
    fInfoBufferSize: Integer;
      {Size of version information data buffer}
    procedure AllocBuffer(const Size: Integer);
      {Allocates buffer of given size to store version information data. Any
      pre-existing buffer is first freed}
    procedure FreeBuffer;
      {Frees the version information data buffer, if allocated}
  public
    constructor Create(const FileName: string);
      {Class constructor: accesses version information in given file and stores
      this in internal buffer that stream reads. If version info can't be
      accessed exceptions are raised}
    destructor Destroy; override;
      {Class destructor: frees version info data buffer}
    function Write(const Buffer; Count: LongInt): LongInt; override;
      {Override of TStream's abstract Write method: raise exception since this
      stream is read only}
  end;

{ TVerInfoFileStream }

resourcestring
  // Error messages
  sNoFile = 'File "%s" does not exist';
  sCantWrite = 'Can''t write version information into an executable file';
  sNoVerInfo = 'No version information present in file "%s"';

procedure TVerInfoFileStream.AllocBuffer(const Size: Integer);
  {Allocates buffer of given size to store version information data. Any pre-
  existing buffer is first freed}
begin
  if (fInfoBufferSize <> Size) or (fInfoBuffer = nil) then
  begin
    // We need to allocate buffer: either there isn't one or its wrong size
    // first free any old buffer (this nils fInfoBuffer and sets size to 0)
    FreeBuffer;
    if Size > 0 then
      // non-zero size specified: allocate the buffer
      GetMem(fInfoBuffer, Size);
    // record new buffer size
    fInfoBufferSize := Size;
  end;
end;

constructor TVerInfoFileStream.Create(const FileName: string);
  {Class constructor: accesses version information in given file and stores this
  in internal buffer that stream reads. If version info can't be accessed
  exceptions are raised}
var
  Dummy: DWORD;           // stores 0 in call to GetFileVersionInfoSize
  VerInfoSize: Integer;   // size of version information data
begin
  inherited Create;
  // Check file exists
  if not FileExists(FileName) then
    raise EStreamError.CreateFmt(sNoFile, [FileName]);
  // Get size of version information data in file
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  if VerInfoSize > 0 then
  begin
    // Allocate buffer of required size to hold ver info
    AllocBuffer(VerInfoSize);
    // Read version info into memory stream
    if not GetFileVersionInfo(
      PChar(FileName), Dummy, fInfoBufferSize, fInfoBuffer
    ) then
      // read failed: free the allocated buffer
      FreeBuffer;                                      
  end;
  // If we didn't get version info we raise exception
  if fInfoBufferSize = 0 then
    raise EStreamError.CreateFmt(sNoVerInfo, [FileName]);
  // Set the stream's memory pointer to buffer where ver info is
  SetPointer(fInfoBuffer, fInfoBufferSize);
end;

destructor TVerInfoFileStream.Destroy;
  {Class destructor: frees version info data buffer}
begin
  FreeBuffer;
  inherited;
end;

procedure TVerInfoFileStream.FreeBuffer;
  {Frees the version information data buffer, if allocated}
begin
  if fInfoBufferSize > 0 then
  begin
    // Buffer size > 0 => we must have buffer, so free it
    Assert(Assigned(fInfoBuffer));
    FreeMem(fInfoBuffer, fInfoBufferSize);
    // Reset buffer and size to zero values to indicate buffer not assigned
    fInfoBuffer := nil;
    fInfoBufferSize := 0;
  end;
end;

function TVerInfoFileStream.Write(const Buffer; Count: LongInt): LongInt;
  {Override of TStream's abstract Write method: raise exception since this
  stream is read only}
begin
  raise EStreamError.Create(sCantWrite);
end;

{ TVerInfoFileIStream }

constructor TVerInfoFileIStream.Create(const FileName: string);
  {Class constructor: creates a wrapped TVerInforFileStream stream object that
  is used to access version information. This wrapped stream is automatically
  freed when this object is destroyed}
begin
  inherited Create(TVerInfoFileStream.Create(FileName), True);
end;

end.
