{
 * UGlobals.pas
 *
 * Unit that defines global values used throughout the program suite.
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
 * The Original Code is UGlobals.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UGlobals;


interface


const
  // Version Information Spy suite
  cDeveloperName = 'Peter D Johnson';   // developer name
  cDeveloperAlias = 'DelphiDabbler';    // developer alias
  cShortSuiteName = 'FileVer';          // short name of suite (used as reg key)
  cLongSuiteName
    = 'Version Information Spy';        // long name of suite
  cVersion = '7';                       // major version number
  cUpdateYear = '2007';                 // year of last update

  // Application file names
  cVISExe = 'FileVer.exe';              // main GUI application
  cVISShellExDll = 'FileVerCM.dll';     // shell extension COM server

  // Help files
  cAppHelpFile = 'FileVer.hlp';         // main application
  cShExtHelpFile = 'FileVerShExt.hlp';  // shel extension help file

  // 3rd party application names
  cIEExe = 'IExplore.exe';            // internet explorer
  cNotepad = 'Notepad.exe';           // notepad

  // Web address
  cWebAddress = 'http://www.delphidabbler.com/';


implementation

end.
