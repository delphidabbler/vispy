{ ##
  @PROJECT_NAME             Version Information Spy Reporter DLL
  @PROJECT_DESC             Provides reporter objects that write reports about
                            version information to a stream.
  @FILE                     VIReport.dpr
  @COMMENTS                 Main project file.
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
      @VERSION              2.0
      @DATE                 20/10/2004
      @COMMENTS             + Added new units: UHTMLWriter, UTextStreamWriter,
                              UPlainReporter, URCReporter, UHTMLReporter,
                              UReportConsts, UReportExp, UErrorReporter.
    )
    @REVISION(
      @VERSION              2.1
      @DATE                 21/08/2007
      @COMMENTS             Changed paths to some interfaces. Interfaces are no
                            longer in Intf folder but in Exports sub folder of
                            relevant DLL source code.
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
 * The Original Code is FVReport.dpr.
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


library FVReport;


uses
  UReporter in 'UReporter.pas',
  IntfVerInfoReport in 'Exports\IntfVerInfoReport.pas',
  IntfVerInfoReader in '..\Reader\Exports\IntfVerInfoReader.pas',
  UVerUtils in '..\Shared\UVerUtils.pas',
  UDisplayFmt in '..\Shared\UDisplayFmt.pas',
  UHTMLWriter in 'UHTMLWriter.pas',
  UTextStreamWriter in 'UTextStreamWriter.pas',
  UPlainReporter in 'UPlainReporter.pas',
  URCReporter in 'URCReporter.pas',
  UHTMLReporter in 'UHTMLReporter.pas',
  UReportConsts in 'UReportConsts.pas',
  UReportExp in 'UReportExp.pas',
  UErrorReporter in 'UErrorReporter.pas';

exports
  // Routine exported from DLL that is used to create required objects
  CreateReporter;

{$Resource VFVReport.res}   // version information

begin
end.

