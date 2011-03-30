{
 * IntfVerInfoReport.pas
 *
 * Provides interface to objects that can write version information reports to
 * streams.
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
 * The Original Code is IntfVerInfoReport.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2003-2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
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

  ///  Plain text report generator: supports IVerInfoReporter
  CLSID_VerInfoPlainReporter:
    TGUID = '{F2D14AD7-7776-4D84-BDB5-0D6517196F72}';
  ///  RC source code report generator: supports IVerInfoReporter
  CLSID_VerInfoRCReporter:
    TGUID = '{C46EBCDD-F346-4900-8EF0-459C886A3E90}';
  ///  RC source code report generator with errors fixed: supports
  ///  IVerInfoReporter
  CLSID_VerInfoRCFixedReporter:
    TGUID = '{585A042E-F321-4ABF-A099-DF311C142E23}';
  ///  HTML report generator: supports IVerInfoReporter
  CLSID_VerInfoHTMLReporter:
    TGUID = '{C6E1B57D-4214-48F8-850F-01B350A0DFD6}';
  ///  XML report generator: supports IVerInfoReporter
  CLSID_VerInfoXMLReporter:
    TGUID = '{5E40F0F8-7B49-4932-A9D0-64E29C235541}';
  ///  HTML error reporter: supports IVerInfoErrReporter
  CLSID_VerInfoHTMLErrReporter:
    TGUID = '{287C9617-5C02-4DAE-9A06-893DDCC2DD97}';

type

  ///  <summary>
  ///  Interface to objects that write a version information report.
  ///  </summary>
  IVerInfoReporter3 = interface(IUnknown)
    ['{B0CA21C7-A6C0-4840-A22D-2D2A14A4D3F5}']
    ///  <summary>Writes a version information report to a stream.</summary>
    ///  <param name="VI">IVerInfoReader [in] Object storing details of version
    ///  information.</param>
    ///  <param name="Stm">IStream in] Stream to which report is written.
    ///  </param>
    ///  <param name="Header">WideString [in] Heading text that is written
    ///  before the body of the report. Ignored if empty string.</param>
    ///  <returns>Boolean. True on success, False on failure.</returns>
    ///  <remarks>If report fails the LastError function provides a description.
    ///  </remarks>
    function ReportToStream(const VI: IVerInfoReader;
      const Stm: IStream; const Header: WideString): WordBool; stdcall;
    ///  <summary>Returns a description of error if previous operation failed,
    ///  or empty string if previous operation succeeded.</summary>
    function LastError: WideString; stdcall;
  end;

type
  ///  <summary>
  ///  Interface to objects that can write report of any inconsistencies or
  ///  errors in version information.
  ///  </summary>
  IVerInfoErrReporter3 = interface(IInterface)
    ['{E103B003-2EBD-4AF8-9CB2-CB03086CB11D}']
    ///  <summary>Checks a version information translation and reports any
    ///  inconsistencies to a stream. No report is written if translation is
    ///  valid.</summary>
    ///  <param name="VI">IVerInfoReader [in] Object storing details of version
    ///  information.</param>
    ///  <param name="Stm">IStream in] Stream to which any report is written.
    ///  </param>
    ///  <param name="TransIdx">Integer [in] Index of translation to be tested.
    ///  </param>
    ///  <returns>HResult. S_OK returned if translation contains errors and a
    ///  report was written. S_FALSE returned if translation has no errors and
    ///  no report was written. E_FAIL returned on error.</returns>
    ///  <remarks>If report fails the LastError function provides a description.
    ///  </remarks>
    function ReportTransErrToStream(const VI: IVerInfoReader;
      const Stm: IStream; const TransIdx: Integer): HResult; stdcall;
    ///  <summary>Returns a description of error if previous operation failed,
    ///  or empty string if previous operation succeeded.</summary>
    function LastError: WideString;
  end;

type
  ///  <summary>
  ///  Prototype of function that can create any of the objects supported in the
  ///  DLL.
  ///  </summary>
  ///  <param name="CLSID">TGUID [in] CLSID of object to be created.</param>
  ///  <param name="Obj">Untyped [out] Set to reference to created object or
  ///  nil on error.</param>
  ///  <returns>HResult. S_OK on success; E_NOTIMPL if CLSID not supported;
  ///  E_FAIL if error creating object.</returns>
  TVIReporterCreateFunc = function(const CLSID: TGUID;
    out Obj): HResult; stdcall;


implementation

end.

