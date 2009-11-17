{ ##
  @PROJECT_NAME             Version Information Spy File Reader DLL.
  @PROJECT_DESC             Enables version information data to be read from
                            excutable and binary resource files that contain
                            version information.
  @FILE                     IntfVerInfoReader.pas
  @COMMENTS                 Provides interface to objects that can read and
                            interpret version information data where variable
                            information is viewed as a single entity, matching
                            translations to string tables.
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
      @COMMENTS             + Added IVerInfoVarReader2 interface that extends
                              IVerInfoVarReader to support an extended status
                              method: StatusEx.
                            + Created additional VARVERINFO_STATUS_* constants
                              to use with IVerInfoVarReader2.StatusEx.
                            + Added new Added IVerInfoFileQuery and new class id
                              to use to create a supporting object.
                            + Replaced IUnknown with IInterface: interfaces here
                              do not represent COM objects.
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
 * The Original Code is IntfVerInfoReader.pas.
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


unit IntfVerInfoReader;


interface


uses
  // Delphi
  Windows;


const
  // Class IDs for various objects supported by this DLL

  // Exe and binary file version information reader:
  // supports IVerInfoExeFileReader
  CLSID_VerInfoFileReader: TGUID = '{131398B5-7AB9-4405-A45B-C7159FB9B5A7}';
  // File query object
  // supports IVerInfoFileQuery
  CLSID_VerInfoFileQuery: TGUID = '{D8156B6C-B83F-44A8-9915-ED1639B2AC58}';

  // Constants returned by functions
  {
    Constants that denote whether a variable file information record is
    cohesive: i.e. if there is a matching string table for every translation and
    vice versa or if there is a translation with no matching string table, or an
    orphaned string table for which there is no translation.
  }
  VARVERINFO_STATUS_OK            = $0; // translation has matching string table
  VARVERINFO_STATUS_TRANSONLY     = $1; // translation has no assoc string table
  VARVERINFO_STATUS_STRTABLEONLY  = $2; // string table has no assoc translation

  VARVERINFO_STATUS_V1MASK        = $3; // masks version 1 fields

  {
    Additional constants that denoting whether a variable file information
    record is cohesive. These provide additional info to the above and can be
    used as bitmasks.
  }
  VARVERINFO_STATUSEX_NOTRANS     = $10; // no translation tables at all
  VARVERINFO_STATUSEX_NOSTRTABLE  = $20; // no string table at all


type

  {
  IVerInfoVarReader:
    Interface to object that can read and interpret variable version information
    data. The variable information data is viewed as a single entity, matching
    translations to string tables.

    Inheritance: IVerInfoVarReader -> [IInterface]
  }
  IVerInfoVarReader = interface(IInterface)
    ['{30A49316-391B-4AC9-9A40-4879D7664726}']
    function StringCount: Integer; stdcall;
      {Returns number of strings in string table}
    function StringName(Idx: Integer): WideString; stdcall;
      {Returns name of string at given index in string table}
    function StringValue(Idx: Integer): WideString; stdcall;
      {Returns value of string at given index in string table}
    function LanguageID: Word; stdcall;
      {Returns langauge ID for variable ver info item}
    function CharSet: Word; stdcall;
      {Returns character set for variable ver info item}
    function Status: Integer; stdcall;
      {Returns code showing whether item is internally consistent: i.e. if both
      a translation and associated string table are present or, if not, which is
      present}
  end;


  {
  IVerInfoVarReader2:
    Extended interface to object that can read and interpret variable version
    information data. This interface derives from IVerInfoVarReader and adds a
    new extended status method.

    Inheritance: IVerInfoVarReader2 -> IVerInfoVarReader -> [IInterface]
  }
  IVerInfoVarReader2 = interface(IVerInfoVarReader)
    ['{39E406AB-6419-418A-834D-D3FC6F5C19A1}']
    function StatusEx: Integer; stdcall;
      {Returns bitmask showing whether item is internally consistent: i.e. if
      both a translation and associated string table are present or, if not,
      which is present. Additionally StatusEx indicates of there are no
      translation entries or string tables at all}
  end;


  {
  IVerInfoReader:
    Interface to object that can read and interpret version information data.
    The object presents a view of the data such that translations are matched to
    string tables, rather than having translations and string tables treated as
    separate entities as they are in the underlying data.

    Inheritance: IVerInfoReader -> [IInterface]
  }
  IVerInfoReader = interface(IInterface)
    ['{AEA8138F-AA6A-449D-9F28-FFEC42695436}']
    function FixedFileInfo: TVSFixedFileInfo; stdcall;
      {Returns fixed file information from version information}
    function VarInfoCount: Integer; stdcall;
      {Returns number of variable version information entries within version
      information}
    function VarInfo(Idx: Integer): IVerInfoVarReader; stdcall;
      {Returns reference to object used to access variable version information
      at given index in version information}
  end;


  {
  IVerInfoFileReader:
    Interface to object that can read and interpret variable version information
    data from a file.

    Inheritance: IVerInfoFileReader -> [IInterface]
  }
  IVerInfoFileReader = interface(IInterface)
    ['{170E9300-5561-4D3D-BEFA-11C2D25D75E8}']
    function LoadFile(const FileName: PChar): WordBool; stdcall;
      {Loads version information from a file. Returns true if file is loaded
      successfully and false on error (refer to LastError function for details
      of error if file fails to load}
    function VerInfo: IVerInfoReader; stdcall;
      {Reference to object that is used to read the version information that
      has been read (or nil if either no information has been read or loaded
      file contains no such information}
    function LastError: WideString; stdcall;
      {Details of last error encountered in object ('' if last load operation
      succeeded)}
  end;


  {
  IVerInfoFileQuery:
    Interface to object that interogates a file to find information about it.

    Inheritance: IVerInfoFileQuery -> [IInterface]
  }
  IVerInfoFileQuery = interface(IInterface)
    ['{D0997C1E-1390-4813-A4FC-42F1C9AE6643}']
    function FileContainsVersionInfo(const FileName: PChar): WordBool; stdcall;
      {Returns true if given file contains version information and false if not}
  end;

  {
  TVIReaderCreateFunc:
    Prototype of function that can create a version info file reader object of
    a given class id.
  }
  TVIReaderCreateFunc = function(const CLSID: TGUID;
    out Obj): HResult; stdcall;


implementation

end.
