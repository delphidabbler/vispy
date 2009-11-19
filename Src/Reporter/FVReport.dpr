{
 * FVReport.dpr
 *
 * Main project file for FVReport.dll that provides reporter objects that write
 * reports about version information to a stream.
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
 * The Original Code is FVReport.dpr.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2003-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
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
  UErrorReporter in 'UErrorReporter.pas',
  UXMLReporter in 'UXMLReporter.pas';

exports
  // Routine exported from DLL that is used to create required objects
  CreateReporter;

{$Resource VFVReport.res}   // version information

begin
end.

