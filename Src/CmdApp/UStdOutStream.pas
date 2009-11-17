{ ##
  @FILE                     UStdOutStream.pas
  @COMMENTS                 Defines a class that provides IStream access to the
                            standard output.
  @PROJECT_NAME             Version Information Spy Command Line Program
  @PROJECT_DESC             Command line application that displays version
                            information embedded in executable and binary
                            resource files.
  @DEPENDENCIES             PJ library PJIStreams unit.
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
 * The Original Code is UStdOutStream.pas.
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


unit UStdOutStream;


interface


uses
  // Delphi
  ActiveX,
  // PJ library
  PJIStreams;

type

  {
  TStdOutIStream:
    File stream for writing to standard output. Implements the IStream
    interface. Stream is read only and serial: attempts to write or seek on the
    stream raises an exception.

    Inheritance: TStdOutIStream -> [TPJIStreamWrapper]
  }
  TStdOutIStream = class(TPJIStreamWrapper, IStream)
  public
    constructor Create;
      {Class constructor: creates a wrapped TStdOutStream object that is used to
      perform actual writing. This wrapped stream is auto-matically freed when
      this object is destroyed}
  end;


implementation


uses
  // Delphi
  Classes;


type

  {
  TStdOutStream:
    Enables writing to standard output using a TStream interface. Since standard
    output is write only and serial, the Write and Seek methods raise
    exceptions.

    Inheritance: TStdOutStream => [TStream]
  }
  TStdOutStream = class(TStream)
  public
    function Read(var Buffer; Count: Longint): Longint; override;
      {Read method raise exception since standard output is write only}
    function Write(const Buffer; Count: Longint): Longint; override;
      {Writes Count bytes from Buffer to standard output as text and returns
      number of bytes written}
    function Seek(Offset: Longint; Origin: Word): Longint; override;
      {Seek method raises exception since standard output is serial}
  end;


{ TStdOutIStream }

constructor TStdOutIStream.Create;
  {Class constructor: creates a wrapped TStdOutStream object that is used to
  perform actual writing. This wrapped stream is auto-matically freed when this
  object is destroyed}
begin
  inherited Create(TStdOutStream.Create, True);
end;


{ TStdOutStream }

function TStdOutStream.Read(var Buffer; Count: Integer): Longint;
  {Read method raise exception since standard output is write only}
begin
  raise EStreamError.Create('Can''t read from standard output');
end;

function TStdOutStream.Seek(Offset: Integer; Origin: Word): Longint;
  {Seek method raises exception since standard output is serial}
begin
  raise EStreamError.Create('Can''t seek on serial standard output');
end;

function TStdOutStream.Write(const Buffer; Count: Integer): Longint;
  {Writes Count bytes from Buffer to standard output as text and returns number
  of bytes written}
var
  OutBuf: PChar;  // output buffer as zero terminated text
begin
  // Copy bytes from buffer into output buffer, and #0 terminate it
  GetMem(OutBuf, Count + 1);
  try
    FillChar(OutBuf^, Count + 1, 0);
    Move(Buffer, OutBuf^, Count);
    // Write the text from the output buffer
    System.Write(OutBuf);
  finally
    FreeMem(OutBuf, Count);
  end;
  // Assume we wrote all the output
  Result := Count;
end;

end.
