; FileVer7.iss
;
; Install file generation script for use with Inno Setup 5
;
; $Rev$
; $Date$
;
; ***** BEGIN LICENSE BLOCK *****
;
; Version: MPL 1.1
;
; The contents of this file are subject to the Mozilla Public License Version
; 1.1 (the "License"); you may not use this file except in compliance with the
; License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
;
; Software distributed under the License is distributed on an "AS IS" basis,
; WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
; the specific language governing rights and limitations under the License.
;
; The Original Code is FileVer7.iss
;
; The Initial Developer of the Original Code is Peter Johnson
; (http://www.delphidabbler.com/).
;
; Portions created by the Initial Developer are Copyright (C) 2004-2009 Peter
; Johnson. All Rights Reserved.
;
; Contributor(s):
;   NONE
;
; ***** END LICENSE BLOCK *****


#define DeleteToVerStart(str S) \
  /* assumes S begins with "Release " followed by version as x.x.x */ \
  Local[0] = Copy(S, Len("Release ") + 1, 99), \
  Local[0]

#define OutDir "..\..\Exe"
#define SrcExePath "..\..\Exe\"
#define SrcDocsPath "..\..\Docs\"
#define ExeProg SrcExePath + "FileVer.exe"
#define Company "DelphiDabbler.com"
#define AppPublisher "DelphiDabbler"
#define AppName "Version Information Spy"
#define AppVersion DeleteToVerStart(GetFileProductVersion(ExeProg))
#define Copyright GetStringFileInfo(ExeProg, LEGAL_COPYRIGHT)
#define WebAddress "www.delphidabbler.com"
#define WebURL "http://" + WebAddress + "/"
#define AppURL WebURL + "vis"

[Setup]
AppID={{1FC85B62-9B38-4592-A2D0-4A4363894AE4}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#WebURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
AppReadmeFile={app}\Docs\ReadMe.htm
AppCopyright={#Copyright} ({#WebAddress})
AppComments=
AppContact=
DefaultDirName={pf}\{#AppPublisher}\VIS7
DefaultGroupName={#AppName}
AllowNoIcons=false
LicenseFile={#SrcDocsPath}License.rtf
Compression=lzma/ultra
SolidCompression=true
OutputDir={#OutDir}
OutputBaseFilename=VIS-Setup-{#AppVersion}
MinVersion=4.1.1998,4.0.1381
RestartIfNeededByRun=false
PrivilegesRequired=poweruser
UsePreviousAppDir=true
UsePreviousGroup=true
UsePreviousSetupType=false
UsePreviousTasks=false
ShowLanguageDialog=no
LanguageDetectionMethod=none
InternalCompressLevel=ultra
InfoAfterFile=
InfoBeforeFile={#SrcDocsPath}InstMsg.rtf
VersionInfoVersion={#AppVersion}.0
VersionInfoCompany={#Company}
VersionInfoDescription=Installer for {#AppName}
VersionInfoTextVersion={#AppVersion}.0
UninstallFilesDir={app}\Uninst
UpdateUninstallLogAppName=true
UninstallDisplayIcon={app}\FileVer.exe
UserInfoPage=false

[Tasks]
Name: desktopicon; Description: {cm:CreateDesktopIcon}; GroupDescription: {cm:AdditionalIcons}; Flags: unchecked

[Files]
; Executable files
Source: {#SrcExePath}FileVer.exe; DestDir: {app}; Flags: uninsrestartdelete
Source: {#SrcExePath}FileVer.cnt; DestDir: {app}; Flags: ignoreversion
Source: {#SrcExePath}FileVer.hlp; DestDir: {app}; Flags: ignoreversion
Source: {#SrcExePath}FileVerCM.dll; DestDir: {app}; Flags: regserver uninsrestartdelete
Source: {#SrcExePath}FileVerCmd.exe; DestDir: {app}; Flags: uninsrestartdelete
Source: {#SrcExePath}FileVerShExt.hlp; DestDir: {app}; Flags: ignoreversion
Source: {#SrcExePath}FVFileReader.dll; DestDir: {app}; Flags: uninsrestartdelete
Source: {#SrcExePath}FVReport.dll; DestDir: {app}; Flags: uninsrestartdelete
Source: {#SrcExePath}VIBinData.dll; DestDir: {app}; Flags: uninsrestartdelete
; Documentation
Source: {#SrcDocsPath}License.txt; DestDir: {app}\Docs; Flags: ignoreversion
Source: {#SrcDocsPath}ReadMe.htm; DestDir: {app}\Docs; Flags: isreadme ignoreversion
Source: {#SrcDocsPath}ChangeLog.txt; DestDir: {app}\Docs; Flags: ignoreversion

[INI]
; Shortcut to VIS home page
Filename: {app}\FileVer.url; Section: InternetShortcut; Key: URL; String: {#AppURL}

[Icons]
Name: {group}\{#AppName}; Filename: {app}\FileVer.exe
Name: {group}\{cm:ProgramOnTheWeb,{#AppName}}; Filename: {app}\FileVer.url
Name: {group}\{cm:UninstallProgram,{#AppName}}; Filename: {uninstallexe}
Name: {userdesktop}\{#AppName}; Filename: {app}\FileVer.exe; Tasks: desktopicon

[Run]
Filename: {app}\FileVer.exe; Description: {cm:LaunchProgram,{#AppName}}; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; Specify this shortcut since created by installer rather than copied
Type: files; Name: {app}\FileVer.url

[Dirs]
Name: {app}\Docs; Flags: uninsalwaysuninstall
Name: {app}\Uninst; Flags: uninsalwaysuninstall

[Registry]
; Create program customisation key
Root: HKCU; Subkey: Software\{#AppPublisher}; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: Software\{#AppPublisher}\FileVer; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: Software\{#AppPublisher}\FileVer\7; Flags: uninsdeletekey
; Register help files
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Help; ValueType: string; ValueName: FileVer.hlp; ValueData: {app}; Flags: uninsdeletevalue
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\Help; ValueType: string; ValueName: FileVerShExt.hlp; ValueData: {app}; Flags: uninsdeletevalue
; Register applications and their paths
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\FileVer.exe; ValueType: string; ValueData: {app}\FileVer.exe; Flags: uninsdeletekey
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\FileVer.exe; ValueType: string; ValueName: Path; ValueData: {app}\; Flags: uninsdeletekey
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\FileVerCmd.exe; ValueType: string; ValueData: {app}\FileVerCmd.exe; Flags: uninsdeletekey
Root: HKLM; Subkey: SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\FileVerCmd.exe; ValueType: string; ValueName: Path; ValueData: {app}\; Flags: uninsdeletekey

[Messages]
; Brand installer
BeveledLabel={#Company}

[Code]
#include <Uninstall.ps>

