{ ##
  @PROJECT_NAME             Version Information Spy File Reader DLL.
  @PROJECT_DESC             Enables version information data to be read from
                            excutable and binary resource files that contain
                            version information.
  @FILE                     UVInfoResFileStream.pas
  @COMMENTS                 Defines a stream class that reads or writes the data
                            of a version information resource within a binary
                            resource file.
  @DEPENDENCIES             None.
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
 * The Original Code is UVInfoResFileStream.pas.
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


unit UVInfoResFileStream;


interface


uses
  // Delphi
  ActiveX,
  // Project
  UResourceFileStream;


type

  {
  TVInfoResFileIStream:
    Stream class to read or write the data of a version information resource
    within a binary resource file.

    Inheritance: TVInfoResFileIStream -> TResourceFileIStream
      -> [TPJIStreamWrapper]
  }
  TVInfoResFileIStream = class(TResourceFileIStream, IStream)
  public
    constructor Create(const FileName: string; Mode: Word);
      {Class constructor: creates an IStream instance that can access the data
      associated with the version information resource in the given file. Mode
      indicates how the stream is to be accessed}
  end;


implementation


uses
  // Delphi
  Windows, Classes;

resourcestring
  // Error message
  sNoVerInfoResource = 'Can''t access version information resource in "%s"';


{ TVInfoResFileIStream }

constructor TVInfoResFileIStream.Create(const FileName: string;
  Mode: Word);
  {Class constructor: creates an IStream instance that can access the data
  associated with the version information resource in the given file. Mode
  indicates how the stream is to be accessed}
begin
  try
    // We create the required ver info resource in parent TResourceFileIStream
    // class: these resources always have ID of 1
    inherited CreateFromID(FileName, Mode, 1, RT_VERSION)
  except on
    // Convert any exception raised when resource not found to a different
    // exception with more explicit message, and re-raise any others
    E: EBinaryResNotFound do
      raise EBinaryResNotFound.CreateFmt(sNoVerInfoResource, [FileName]);
    else
      raise;
  end;
end;

end.
