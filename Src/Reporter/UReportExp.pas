{
 * UReportExp.pas
 *
 * Defines exported report object creator routine that creates report objects in
 * FVReport.dll.
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
 * The Original Code is UReportExp.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2004-2009 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UReportExp;


interface


function CreateReporter(const CLSID: TGUID; out Obj): HResult; stdcall;
  {Creates the reporter object of the type specified by CLSID. If the library
  supports the object then an instance is created. A reference to the object is
  stored in Obj and S_OK is returned. If the library does not support CLSID then
  Obj is set to nil and E_NOTIMPL is returned. If there is an error in creating
  the object Obj is set to nil and E_FAIL is returned}


implementation


uses
  // Delphi
  Windows, ActiveX,
  // Project
  UPlainReporter, UHTMLReporter, URCReporter, UXMLReporter, UErrorReporter,
  IntfVerInfoReport;


function CreateReporter(const CLSID: TGUID; out Obj): HResult; stdcall;
  {Creates the reporter object of the type specified by CLSID. If the library
  supports the object then an instance is created. A reference to the object is
  stored in Obj and S_OK is returned. If the library does not support CLSID then
  Obj is set to nil and E_NOTIMPL is returned. If there is an error in creating
  the object Obj is set to nil and E_FAIL is returned}
begin
  try
    // Assume success
    Result := S_OK;
    if IsEqualIID(CLSID, CLSID_VerInfoPlainReporter) then
      // Create plain text reporter
      IVerInfoReporter(Obj) := TPlainReporter.Create
        as IVerInfoReporter
    else if IsEqualIID(CLSID, CLSID_VerInfoRCReporter) then
      // Create resource source reporter
      IVerInfoReporter(Obj) := TRCReporter.Create
        as IVerInfoReporter
    else if IsEqualIID(CLSID, CLSID_VerInfoRCFixedReporter) then
      // Create resource source reporter
      IVerInfoReporter(Obj) := TFixedRCReporter.Create
        as IVerInfoReporter
    else if IsEqualIID(CLSID, CLSID_VerInfoHTMLReporter) then
      // Create resource source reporter
      IVerInfoReporter(Obj) := THTMLReporter.Create
        as IVerInfoReporter
    else if IsEqualIID(CLSID, CLSID_VerInfoXMLReporter) then
      IVerInfoReporter(Obj) := TXMLReporter.Create
        as IVerInfoReporter
    else if IsEqualIID(CLSID, CLSID_VerInfoHTMLErrReporter) then
      IVerInfoErrReporter(Obj) := TErrorReporter.Create
        as IVerInfoErrReporter
    else
    begin
      // Unsupported object: set object nil and set error code
      Pointer(Obj) := nil;
      Result := E_NOTIMPL;
    end;
  except
    // Something went wrong: set object to nil and set error code
    Pointer(Obj) := nil;
    Result := E_FAIL;
  end;
end;

end.

