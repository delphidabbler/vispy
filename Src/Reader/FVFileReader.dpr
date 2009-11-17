{ ##
  @PROJECT_NAME             Version Information Spy File Reader DLL.
  @PROJECT_DESC             Enables version information data to be read from
                            excutable and binary resource files that contain
                            version information.
  @FILE                     VIFileReader.dpr
  @COMMENTS                 Main project file for executable file reader DLL.
  @AUTHOR                   Peter D Johnson, LLANARTH, Ceredigion, Wales, UK.
  @EMAIL                    delphidabbler@yahoo.co.uk
  @COPYRIGHT                © Peter D Johnson, 2003-2007.
  @WEBSITE                  http://www.delphidabbler.com/
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              1.1
      @DATE                 20/10/2004
      @COMMENTS             Added UGlobals unit.
    )
    @REVISION(
      @VERSION              1.2
      @DATE                 21/08/2007
      @COMMENTS             Changed paths to some interfaces. Interfaces are no
                            longer in Intf folder but in Exports sub folder of
                            relevant DLL source code or in Imports folder if
                            providing interface to external DLL.
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
 * The Original Code is FVFileReader.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


library FVFileReader;


uses
  UFileReader in 'UFileReader.pas',
  UResourceFile in 'UResourceFile.pas',
  UResourceFileStream in 'UResourceFileStream.pas',
  UResourceUtils in 'UResourceUtils.pas',
  UVerInfoStream in 'UVerInfoStream.pas',
  UVIBinary in 'UVIBinary.pas',
  UVInfoResFileStream in 'UVInfoResFileStream.pas',
  UDLLLoader in '..\Shared\UDLLLoader.pas',
  UGlobals in '..\Shared\UGlobals.pas',
  IntfBinaryVerInfo in '..\Imports\IntfBinaryVerInfo.pas',
  IntfVerInfoReader in 'Exports\IntfVerInfoReader.pas';


exports
  // Routine exported from DLL that is used to create required objects
  CreateFileReader;


{$Resource VFVFileReader.res}   // version information


begin
end.
