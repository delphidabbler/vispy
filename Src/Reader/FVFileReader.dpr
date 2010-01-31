{
 * FVFileReader.dpr
 *
 * Main project file for executable file reader DLL.
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
 * The Original Code is FVFileReader.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
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
