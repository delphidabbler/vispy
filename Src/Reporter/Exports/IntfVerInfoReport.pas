{ ##
  @PROJECT_NAME             Version Information Spy Reporter DLL
  @PROJECT_DESC             Provides reporter objects that write reports about
                            version information to a stream, either as resource
                            source code or as a description.
  @FILE                     IntfVerInfoReport.pas
  @COMMENTS                 Provides interface to objects that can write version
                            information reports to streams.
  @DEPENDENCIES             None.
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 24/02/2003
      @COMMENTS             Original version.
    )
    @REVISION(
      @VERSION              2.0
      @DATE                 20/05/2004
      @COMMENTS             + Added completely new IVerInfoErrReporter interface
                              to access new error reporter object in
                              FVReport.dll.
                            + Added new CLSID to identify the error reporter
                              object that implements the new interface.
                            + Added new CLSID for a new object in FVReport.dll
                              that implements IVerInfoReporter.
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
 * The Original Code is IntfVerInfoReport.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2003-2004 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 * 
 * ***** END LICENSE BLOCK *****
}


unit IntfVerInfoReport;


interface


uses
  // Delphi
  ActiveX,
  // Project
  IntfVerInfoReader;


const
  // Class IDs for various objects supported by this DLL

  // Plain text report generator: supports IVerInfoReporter
  CLSID_VerInfoPlainReporter:
    TGUID = '{9B69F292-B6E4-4503-A290-08EC0354268C}';
  // RC source code report generator: supports IVerInfoReporter
  CLSID_VerInfoRCReporter:
    TGUID = '{90461D4E-DC09-4A1F-A5D8-B09704DCD8E7}';
  // RC source code report generator with errors fixed:
  // supports IVerInfoReporter
  CLSID_VerInfoRCFixedReporter:
    TGUID = '{A6EE55E4-C5EC-4139-A555-5BB6780F641B}';
  // HTML source code report generator: supports IVerInfoReporter
  CLSID_VerInfoHTMLReporter:
    TGUID = '{0B75983C-3A13-4F4A-A1FB-44B22BD8D60A}';
  // HTML error reporter: supports IVerInfoErrReporter
  CLSID_VerInfoHTMLErrReporter:
    TGUID = '{5AD57743-04EF-47B9-8CCD-2805F0AAF41A}';


type

  {
  IVerInfoReporter:
    Interface to objects that can write version information reports.

    Inheritance: IVerInfoReporter => [IUnknown]
  }
  IVerInfoReporter = interface(IUnknown)
    ['{07D632A3-8563-4AEF-A2D0-07122158E837}']
    function ReportToStream(const VI: IVerInfoReader;
      const Stm: IStream; const Header: WideString): WordBool; stdcall;
      {Writes report of version information accessed by the given VI object to
      the given stream. Any header specified is written out before the version
      information. Returns true if report succeeds. If report fails false
      is returned and LastError provides a description of the error}
    function ReportToFile(const VI: IVerInfoReader;
      const FileName: WideString; const Header: WideString): WordBool; stdcall;
      {Writes report of version information accessed by the given VI object to
      the given file. Any header specified is written out before the version
      information. Returns true if report succeeds. If report fails, false is
      returned and LastError provides a description of the error}
    function LastError: WideString; stdcall;
      {Returns description of error if previous operation failed, or '' if
      previous operation succeeded}
  end;

  {
  IVerInfoErrReporter:
    Interface to objects that can write report of any inconsistencies or errors
    in version information.

    Inheritance: IVerInfoErrReporter => [IInterface]
  }
  IVerInfoErrReporter = interface(IInterface)
    ['{7D3692D3-80B6-472D-B3E2-C11D2C885302}']
    function ReportTransErrToStream(const VI: IVerInfoReader;
      const Stm: IStream; const TransIdx: Integer): HResult; stdcall;
      {Writes a report of any errors and inconsistencies in the version
      information accessed by the given VI object to the given stream. If the
      version information does contain errors the report is written and S_OK is
      returned. If the version information has no errors nothing is written and
      S_FALSE is returned. If an error occurs then nothing is written, E_FAIL is
      returned and LastError provides a description of the error}
    function LastError: WideString;
      {Returns description of error if previous operation failed, or '' if
      previous operation succeeded}
  end;

  {
  TVIReporterCreateFunc:
    Prototype of function that can create any of the objects supported in the
    DLL.
  }
  TVIReporterCreateFunc = function(const CLSID: TGUID;
    out Obj): HResult; stdcall;


implementation

end.
