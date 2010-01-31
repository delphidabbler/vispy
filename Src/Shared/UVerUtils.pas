{
 * UVerUtils.pas
 *
 * Library of functions that provide English language descriptions of version
 * information related values and flags.
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
 * The Original Code is UVerUtils.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2002-2010 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UVerUtils;


interface


uses
  // Delphi
  Windows;


type

  {
  TVerInfoDescType:
    Codes that identify the type of information returned by fixed file info
    routines.
  }
  TVerInfoDescType = (
    dtDesc,   // routines return descriptions of fixed file info values
    dtCode    // routines return symbolic constants of fixed file info values
  );


function FileOSDesc(const OS: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representing the operating system deduced from the given OS
  flags. The string returned can be either a full description or symbolic
  constant expression, depending on DescType}

function FileTypeDesc(const FileType: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representing the given file type. The string returned can be
  either a full description or symbolic constant expression, depending on
  DescType}

function FileTypeHasSubType(const FileType: DWORD): Boolean;
  {Return true if given File Type has Sub-Types, false if not}

function FileSubTypeDesc(const FileType, FileSubType: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns string representing the  given sub-type FSType of given file type
  FileType. The string returned can be either a full description or symbolic
  constant expression, depending on DescType for the VFT_DRV and FT_FONT sub-
  types or a hex value for other types}

function FileFlagsDesc(const Flags: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representing the given file flags. The string returned can
  be either a full description or symbolic constant expression, depending on
  DescType}

function CharSetDesc(CharSet: Word): string;
  {Return string describing given character set}

function LanguageDesc(LangID: Word): string;
  {Return string describing given language}

function IsStdStrFileInfoName(const Name: string): Boolean;
  {Return true if given name is a standard string file info name and false
  otherwise}


implementation


uses
  // Delphi
  SysUtils;


{ --- Helper code --- }

type

  {
  TTableEntry:
    Record used in lookup tables in this unit.
  }
  TTableEntry = record
    Code: DWORD;          // value of a code
    Desc: string;         // description of the code
    Name: string;         // symbolic constant name
  end;

function PvtIndexToStr(const Idx: Integer; const Table: array of TTableEntry;
  const DescType: TVerInfoDescType): string;
  {Returns either a description or symbolic constant for the entry at the given
  index in the given lookup table, depending on the type of description required
  by the DescType parameter}
begin
  case DescType of
    dtDesc: Result := Table[Idx].Desc;
    dtCode: Result := Table[Idx].Name;
    else Result := '';
  end;
end;

function PvtCodeToStr(const Code: DWORD;
  const Table: array of TTableEntry;
  const DescType: TVerInfoDescType): string;
  {Looks up the given code in the given table and returns ans associated string
  representation or '' if no match. The string returned can be either a full
  description or symbolic constant expression, depending on DescType}
var
  I: Integer; // loops thru table
begin
  Result := '';
  for I := Low(Table) to High(Table) do
    if Table[I].Code = Code then
    begin
      Result := PvtIndexToStr(I, Table, DescType);
      Break;
    end;
end;


{ --- File OS --- }

resourcestring
  // Base operating system descriptions
  sVOSNT        = 'Windows NT';
  sVOSDOS       = 'MS-DOS';
  sVOSOS232     = 'OS2 32 bit';
  sVOSOS216     = 'OS2 16 bit';
  sVOSUnknown   = 'Any';
  // Target operating system descriptions
  sVOSWindows32 = '32 bit Windows';
  sVOSWindows16 = 'Windows 3.x';
  sVOSPM32      = 'Presentation Manager 32';
  sVOSPM16      = 'Presentation Manager 16';
  sVOSBase      = 'Unknown';

const
  // Lookup table of base operating systems
  cFileOSBase: array[0..4] of TTableEntry =
  (
    ( Code: VOS_NT;           Desc: sVOSNT;         Name: 'VOS_NT';),
    ( Code: VOS_DOS;          Desc: sVOSDOS;        Name: 'VOS_DOS';),
    ( Code: VOS_OS232;        Desc: sVOSOS232;      Name: 'VOS_OS232';),
    ( Code: VOS_OS216;        Desc: sVOSOS216;      Name: 'VOS_OS216';),
    ( Code: VOS_UNKNOWN;      Desc: sVOSUnknown;    Name: 'VOS_UNKNOWN';)
  );

  // Lookup table of target operating systems
  cFileOSTarget: array[0..4] of TTableEntry =
  (
    ( Code: VOS__WINDOWS32;   Desc: sVOSWindows32;  Name: 'VOS__WINDOWS32';),
    ( Code: VOS__WINDOWS16;   Desc: sVOSWindows16;  Name: 'VOS__WINDOWS16';),
    ( Code: VOS__PM32;        Desc: sVOSPM32;       Name: 'VOS__PM32';),
    ( Code: VOS__PM16;        Desc: sVOSPM16;       Name: 'VOS__PM16';),
    ( Code: VOS__BASE;        Desc: sVOSBase;       Name: 'VOS__BASE';)
  );

  // Lookup table of symbolic constants for combined target and base OSs
  // (Desc field not used here)
  cCombinedOS: array[0..4] of TTableEntry =
  (
    ( Code: VOS_DOS_WINDOWS16;                      Name: 'VOS_DOS_WINDOWS16';),
    ( Code: VOS_DOS_WINDOWS32;                      Name: 'VOS_DOS_WINDOWS32';),
    ( Code: VOS_OS216_PM16;                         Name: 'VOS_OS216_PM16';),
    ( Code: VOS_OS232_PM32;                         Name: 'VOS_OS232_PM32';),
    ( Code: VOS_NT_WINDOWS32;                       Name: 'VOS_NT_WINDOWS32';)
  );

procedure PvtDecodeFileOS(const OS: DWORD; var Target, Base: DWORD);
  {Decodes the target and base operating systems from the given OS description}
begin
  Target := OS and $0000FFFF;
  Base := OS and $FFFF0000;
end;

function PvtFileOSTargetDesc(const OS: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representationof the given target operating system. The
  string returned can be either a full description or symbolic constant
  expression, depending on DescType}
begin
  Result := PvtCodeToStr(OS, cFileOSTarget, DescType);
end;

function PvtFileOSBaseDesc(const OS: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representation of the given base operating system. The
  string returned can be either a full description or symbolic constant
  expression, depending on DescType}
begin
  Result := PvtCodeToStr(OS, cFileOSBase, DescType);
end;

function FileOSDesc(const OS: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representing the operating system deduced from the given OS
  flags. The string returned can be either a full description or symbolic
  constant expression, depending on DescType}
resourcestring
  sRunning = 'running on';    // text for part of OS description
const
  cSeps: array[TVerInfoDescType] of string = (sRunning, '+');
var
  Target, Base: DWORD;        // codes for target and base operating systems
begin
  // Get the target and base OSs from the OS code
  PvtDecodeFileOS(OS, Target, Base);
  // Set result to any special combined symbolic constant if we're returning
  // symbolic constants otherwise set result to '' to indicate we haven't found
  // result yet
  if DescType = dtCode then
    Result := PvtCodeToStr(OS, cCombinedOS, dtCode) // returns '' if no const
  else
    Result := '';
  // Check if we've already found a result, and calculate it if not
  if Result = '' then
  begin
    // Build up description
    if Base = VOS_UNKNOWN then
      // we don't know base: just return target
      Result := PvtFileOSTargetDesc(Target, DescType)
    else if Target = VOS__BASE then
      // we don't know base: just return target
      Result := PvtFileOSBaseDesc(Base, DescType)
    else
      // we know both target and base: return both
      Result := Format('%s %s %s',
        [
          PvtFileOSTargetDesc(Target, DescType),
          cSeps[DescType],
          PvtFileOSBaseDesc(Base, DescType)
        ]
      );
  end;
end;


{ --- File type --- }

resourcestring
  // Descriptions for file types
  sVFTApp       = 'Application';
  sVFTDLL       = 'Dynamic link library (DLL)';
  sVFTDrv       = 'Device driver';
  sVFTFont      = 'Font';
  sVFTStaticLib = 'Static-link library';
  sVFTVXD       = 'Virtual device';
  sVFTUnknown   = 'Unknown file type';

const
  // Lookup table of file types
  cFileType: array[0..6] of TTableEntry =
  (
    (Code: VFT_APP;         Desc: sVFTApp;          Name: 'VFT_APP';),
    (Code: VFT_DLL;         Desc: sVFTDLL;          Name: 'VFT_DLL';),
    (Code: VFT_DRV;         Desc: sVFTDrv;          Name: 'VFT_DRV';),
    (Code: VFT_FONT;        Desc: sVFTFont;         Name: 'VFT_FONT';),
    (Code: VFT_STATIC_LIB;  Desc: sVFTStaticLib;    Name: 'VFT_STATIC_LIB';),
    (Code: VFT_VXD;         Desc: sVFTVXD;          Name: 'VFT_VXD';),
    (Code: VFT_UNKNOWN;     Desc: sVFTUnknown;      Name: 'VFT_UNKNOWN';)
  );

function FileTypeDesc(const FileType: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representing the given file type. The string returned can be
  either a full description or symbolic constant expression, depending on
  DescType}
begin
  Result := PvtCodeToStr(FileType, cFileType, DescType);
end;

function FileTypeHasSubType(const FileType: DWORD): Boolean;
  {Return true if given File Type has Sub-Types, false if not}
begin
  Result := FileType in [VFT_DRV, VFT_FONT, VFT_VXD];
end;


{ --- File sub type --- }

function PvtDriverSubTypeDesc(const DrvSubType: DWORD;
  const DescType: TVerInfoDescType): string; forward;
  {Private routine to return a string representation of the given driver sub-
  type. The string returned can be either a full description or symbolic
  constant expression, depending on DescType}
function PvtFontSubTypeDesc(const FontSubType: DWORD;
  const DescType: TVerInfoDescType): string; forward;
  {Private routine to return a string representation of the given font sub-
  type. The string returned can be either a full description or symbolic
  constant expression, depending on DescType}

function FileSubTypeDesc(const FileType, FileSubType: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns string representing the  given sub-type FSType of given file type
  FileType. The string returned can be either a full description or symbolic
  constant expression, depending on DescType for the VFT_DRV and FT_FONT sub-
  types or a hex value for other types}
begin
  case FileType of
    VFT_DRV: Result := PvtDriverSubTypeDesc(FileSubType, DescType);
    VFT_FONT: Result := PvtFontSubTypeDesc(FileSubType, DescType);
    else Result := IntToHex(FileSubType, 8);
  end;
end;


{ --- Driver sub type --- }

resourcestring
  // Descriptions for driver sub types
  sVFT2UnknownDrv     = 'Unknown driver type';
  sVFT2CommDrv        = 'Communications driver';
  sVFT2PrinterDrv     = 'Printer driver';
  sVFT2KeyboardDrv    = 'Keyboard driver';
  sVFT2LanguageDrv    = 'Language driver';
  sVFT2DisplayDrv     = 'Display driver';
  sVFT2MouseDrv       = 'Mouse driver';
  sVFT2NetworkDrv     = 'Network driver';
  sVFT2SystemDrv      = 'System driver';
  sVFT2InstallableDrv = 'Installable driver';
  sVFT2SoundDrv       = 'Sound driver';

const
  // Lookup table for driver sub types
  cDrvSubType: array[0..10] of TTableEntry =
  (
    (Code: VFT2_UNKNOWN;          Desc: sVFT2UnknownDrv;
        Name: 'VFT2_UNKNOWN';),
    (Code: VFT2_DRV_COMM;         Desc: sVFT2CommDrv;
        Name: 'VFT2_DRV_COMM';),
    (Code: VFT2_DRV_PRINTER;      Desc: sVFT2PrinterDrv;
        Name: 'VFT2_DRV_PRINTER';),
    (Code: VFT2_DRV_KEYBOARD;     Desc: sVFT2KeyboardDrv;
        Name: 'VFT2_DRV_KEYBOARD';),
    (Code: VFT2_DRV_LANGUAGE;     Desc: sVFT2LanguageDrv;
        Name: 'VFT2_DRV_LANGUAGE';),
    (Code: VFT2_DRV_DISPLAY;      Desc: sVFT2DisplayDrv;
        Name: 'VFT2_DRV_DISPLAY';),
    (Code: VFT2_DRV_MOUSE;        Desc: sVFT2MouseDrv;
        Name: 'VFT2_DRV_MOUSE';),
    (Code: VFT2_DRV_NETWORK;      Desc: sVFT2NetworkDrv;
        Name: 'VFT2_DRV_NETWORK';),
    (Code: VFT2_DRV_SYSTEM;       Desc: sVFT2SystemDrv;
        Name: 'VFT2_DRV_SYSTEM';),
    (Code: VFT2_DRV_INSTALLABLE;  Desc: sVFT2InstallableDrv;
        Name: 'VFT2_DRV_INSTALLABLE';),
    (Code: VFT2_DRV_SOUND;        Desc: sVFT2SoundDrv;
        Name: 'VFT2_DRV_SOUND';)
  );

function PvtDriverSubTypeDesc(const DrvSubType: DWORD;
  const DescType: TVerInfoDescType): string;
  {Private routine to return a string representation of the given driver sub-
  type. The string returned can be either a full description or symbolic
  constant expression, depending on DescType}
begin
  Result := PvtCodeToStr(DrvSubType, cDrvSubType, DescType);
end;


{ --- Font sub type --- }

resourcestring
  // Descriptions of font sub types
  sVFT2UnknownFont  = 'Unknown font type';
  sVFT2RasterFont   = 'Raster font';
  sVFT2VectorFont   = 'Vector font';
  sVFT2TrueTypeFont = 'True type font';

const
  // Lookup table of font sub types
  cFontSubType: array[0..3] of TTableEntry =
  (
    (Code: VFT2_UNKNOWN;        Desc: sVFT2UnknownFont;
        Name: 'VFT2_UNKNOWN';),
    (Code: VFT2_FONT_RASTER;    Desc: sVFT2RasterFont;
        Name: 'VFT2_FONT_RASTER';),
    (Code: VFT2_FONT_VECTOR;    Desc: sVFT2VectorFont;
        Name: 'VFT2_FONT_VECTOR';),
    (Code: VFT2_FONT_TRUETYPE;  Desc: sVFT2TrueTypeFont;
        Name: 'VFT2_FONT_TRUETYPE';)
  );

function PvtFontSubTypeDesc(const FontSubType: DWORD;
  const DescType: TVerInfoDescType): string;
  {Private routine to return a string representation of the given font sub-
  type. The string returned can be either a full description or symbolic
  constant expression, depending on DescType}
begin
  Result := PvtCodeToStr(FontSubType, cFontSubType, DescType);
end;


{ --- File flags --- }

resourcestring
  // Descriptions of file flags
  sFFDebug        = 'Debug';
  sFFPreRelease   = 'Pre-release';
  sFFPatched      = 'Patched';
  sFFPrivateBuild = 'Private build';
  sFFDynVerInfo   = 'Dynamically-created version info';
  sFFSpecialBuild = 'Special build';

const
  // Lookup table of file flags
  cFileFlags: array[0..5] of TTableEntry =
  (
    (Code: VS_FF_DEBUG;         Desc: sFFDebug;
        Name: 'VS_FF_DEBUG';),
    (Code: VS_FF_PRERELEASE;    Desc: sFFPreRelease;
        Name: 'VS_FF_PRERELEASE';),
    (Code: VS_FF_PATCHED;       Desc: sFFPatched;
        Name: 'VS_FF_PATCHED';),
    (Code: VS_FF_PRIVATEBUILD;  Desc: sFFPrivateBuild;
        Name: 'VS_FF_PRIVATEBUILD';),
    (Code: VS_FF_INFOINFERRED;  Desc: sFFDynVerInfo;
        Name: 'VS_FF_INFOINFERRED';),
    (Code: VS_FF_SPECIALBUILD;  Desc: sFFSpecialBuild;
        Name: 'VS_FF_SPECIALBUILD';)
  );

function FileFlagsDesc(const Flags: DWORD;
  const DescType: TVerInfoDescType): string;
  {Returns a string representing the given file flags. The string returned can
  be either a full description or symbolic constant expression, depending on
  DescType}
resourcestring
  sNone = 'None';   // text used where there are no file flags
var
  I: Integer;       // loops thru lookup table
const
  cSeps: array[TVerInfoDescType] of string = (', ', ' + ');
    // separators between string values, depending on description type
  cNos: array[TVerInfoDescType] of string = (sNone, '0');
    // value to return when no flags, depending on description type
begin
  // Initialise result
  Result := '';
  // Scan lookup table, adding description of any flag found to result
  for I := Low(cFileFlags) to High(cFileFlags) do
  begin
    if Flags and cFileFlags[I].Code = cFileFlags[I].Code then
    begin
      if Result = '' then
        Result := PvtIndexToStr(I, cFileFlags, DescType)
      else
        Result := Result
          + cSeps[DescType]
          + PvtIndexToStr(I, cFileFlags, DescType);
    end
  end;
  // If there are no file flags we return an appropriate indicator per DescType
  if Result = '' then
    Result := cNos[DescType];
end;


{ --- Character sets --- }

resourcestring
  // Descriptions of character sets
  s00000 = '7-bit ASCII';               
  s00037 = 'EBCDIC';
  s00437 = 'MS-DOS  United States';
  s00500 = 'EBCDIC "500V1"';
  s00708 = 'Arabic (ASMO 708)';
  s00709 = 'Arabic (ASMO 449+, BCON V4)';
  s00710 = 'Arabic (Transparent Arabic)';
  s00720 = 'Arabic (Transparent ASMO)';
  s00737 = 'Greek (formerly 437G)';
  s00775 = 'Baltic';
  s00850 = 'MS-DOS  Multilingual (Latin I)';
  s00852 = 'MS-DOS  Slavic (Latin II)';
  s00855 = 'IBM Cyrillic (primarily Russian)';
  s00857 = 'IBM Turkish';
  s00860 = 'MS-DOS  Portuguese';
  s00861 = 'MS-DOS Icelandic';
  s00862 = 'Hebrew';
  s00863 = 'MS-DOS Canadian-French';
  s00864 = 'Arabic';
  s00865 = 'MS-DOS Nordic';
  s00866 = 'MS-DOS Russian';
  s00869 = 'IBM Modern Greek';
  s00874 = 'Thai';
  s00875 = 'EBCDIC';
  s00932 = 'Japan';
  s00936 = 'Chinese (PRC, Singapore)';
  s00949 = 'Korean';
  s00950 = 'Chinese (Taiwan, Hong Kong)';
  s01026 = 'EBCDIC';
  s01200 = 'Unicode (BMP of ISO 10646)';
  s01250 = 'Windows 3.1 Eastern European';
  s01251 = 'Windows 3.1 Cyrillic';
  s01252 = 'Windows 3.1 US (ANSI) / Multilingual';    
  s01253 = 'Windows 3.1 Greek';
  s01254 = 'Windows 3.1 Turkish';
  s01255 = 'Hebrew';
  s01256 = 'Arabic';
  s01257 = 'Baltic';
  s01361 = 'Korean (Johab)';
  s10000 = 'Macintosh Roman';
  s10001 = 'Macintosh Japanese';
  s10006 = 'Macintosh Greek I';
  s10007 = 'Macintosh Cyrillic';
  s10029 = 'Macintosh Latin 2';
  s10079 = 'Macintosh Icelandic';
  s10081 = 'Macintosh Turkish';

const
  // Lookup table of character sets (Name field not used here)
  cCharSets: array[0..45] of TTableEntry =
  (
    (Code: 00000; Desc: s00000),    
    (Code: 00037; Desc: s00037),
    (Code: 00437; Desc: s00437),
    (Code: 00500; Desc: s00500),
    (Code: 00708; Desc: s00708),
    (Code: 00709; Desc: s00709),
    (Code: 00710; Desc: s00710),
    (Code: 00720; Desc: s00720),
    (Code: 00737; Desc: s00737),
    (Code: 00775; Desc: s00775),
    (Code: 00850; Desc: s00850),
    (Code: 00852; Desc: s00852),
    (Code: 00855; Desc: s00855),
    (Code: 00857; Desc: s00857),
    (Code: 00860; Desc: s00860),
    (Code: 00861; Desc: s00861),
    (Code: 00862; Desc: s00862),
    (Code: 00863; Desc: s00863),
    (Code: 00864; Desc: s00864),
    (Code: 00865; Desc: s00865),
    (Code: 00866; Desc: s00866),
    (Code: 00869; Desc: s00869),
    (Code: 00874; Desc: s00874),
    (Code: 00875; Desc: s00875),
    (Code: 00932; Desc: s00932),
    (Code: 00936; Desc: s00936),
    (Code: 00949; Desc: s00949),
    (Code: 00950; Desc: s00950),
    (Code: 01026; Desc: s01026),
    (Code: 01200; Desc: s01200),
    (Code: 01250; Desc: s01250),
    (Code: 01251; Desc: s01251),
    (Code: 01252; Desc: s01252),
    (Code: 01253; Desc: s01253),
    (Code: 01254; Desc: s01254),
    (Code: 01255; Desc: s01255),
    (Code: 01256; Desc: s01256),
    (Code: 01257; Desc: s01257),
    (Code: 01361; Desc: s01361),
    (Code: 10000; Desc: s10000),
    (Code: 10001; Desc: s10001),
    (Code: 10006; Desc: s10006),
    (Code: 10007; Desc: s10007),
    (Code: 10029; Desc: s10029),
    (Code: 10079; Desc: s10079),
    (Code: 10081; Desc: s10081)
  );

function CharSetDesc(CharSet: Word): string;
  {Return string describing given character set}
begin
  Result := PvtCodeToStr(CharSet, cCharSets, dtDesc);
end;


{ --- Languages --- }

function LanguageDesc(LangID: Word): string;
  {Return string describing given language}
var
  Buf: array[0..255] of char;   // stores langauge string from API call
begin
  // Assume failure
  Result := '';
  // Try to get language name from Win API if we have ver info
  if VerLanguageName(LangID, Buf, 255) > 0 then
    Result := Buf;
end;


{ --- String File Info --- }

const
  // Table of all standard string file info strings
  cStrNames: array[0..11] of string = (
    'Comments',
    'CompanyName',
    'FileDescription',
    'FileVersion',
    'InternalName',
    'LegalCopyright',
    'LegalTrademarks',
    'OriginalFileName',
    'PrivateBuild',
    'ProductName',
    'ProductVersion',
    'SpecialBuild'
  );

function IsStdStrFileInfoName(const Name: string): Boolean;
  {Return true if given name is a standard string file info name and false
  otherwise}
var
  Idx: Integer; // loops thru table of std string file info names
begin
  Result := False;
  for Idx := Low(cStrNames) to High(cStrNames) do
  begin
    if AnsiCompareText(Name, cStrNames[Idx]) = 0 then
    begin
      Result := True;
      Break;
    end;
  end;
end;

end.
