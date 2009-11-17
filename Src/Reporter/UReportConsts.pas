{ ##
  @PROJECT_NAME             Version Information Spy Reporter DLL
  @PROJECT_DESC             Provides reporter objects that write reports about
                            version information to a stream.
  @FILE                     UReportConsts.pas
  @COMMENTS                 Defines constants etc used by other units in the DLL
                            project.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 20/05/2004
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
 * The Original Code is UReportConsts.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit UReportConsts;


interface


resourcestring
  // Common strings
  // fixed file info labels
  sSignature        = 'Signature';
  sStructVer        = 'Structure Version';
  sFileVersion      = 'File Version';
  sProductVersion   = 'Product Version';
  sFileFlagsMask    = 'File Flags Mask';
  sFileFlags        = 'File Flags';
  sFileOS           = 'Operating System';
  sFileType         = 'File Type';
  sFileSubType      = 'File Sub-type';
  sCreateDate       = 'Creation Date';
  // miscellaneous
  sNA               = 'N/a';


implementation

end.
