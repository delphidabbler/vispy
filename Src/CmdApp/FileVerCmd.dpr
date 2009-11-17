{ ##
  @FILE                     FileVerCmd.dpr
  @COMMENTS                 Main project file that also includes code to access
                            and display version information.
  @PROJECT_NAME             Version Information Spy Command Line Program
  @PROJECT_DESC             Command line application that displays version
                            information embedded in executable and binary
                            resource files.
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
      @VERSION              1.1
      @DATE                 20/10/2004
      @COMMENTS             + Added UGlobals unit.
                            + Now uses constants from UGlobals for some system
                              wide information.
    )
    @REVISION(
      @VERSION              1.2
      @DATE                 21/08/2007
      @COMMENTS             + Changed paths to some interfaces. Interfaces are
                              no longer in Intf folder but in Exports sub folder
                              of relevant DLL source code.
                            + Deleted reference to FileVerCmd.res and replaced
                              with inclusion of FVCImages.res that now contains
                              MAINICON.
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
 * The Original Code is FileVerCmd.dpr.
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


program FileVerCmd;


{$APPTYPE CONSOLE}  // This is a console application


uses
  SysUtils,
  ActiveX,
  UStdOutStream in 'UStdOutStream.pas',
  UDLLLoader in '..\Shared\UDLLLoader.pas',
  UGlobals in '..\Shared\UGlobals.pas',
  UFileReaderLoader in '..\Shared\UFileReaderLoader.pas',
  UReporterLoader in '..\Shared\UReporterLoader.pas',
  IntfVerInfoReader in '..\Reader\Exports\IntfVerInfoReader.pas',
  IntfVerInfoReport in '..\Reporter\Exports\IntfVerInfoReport.pas';

resourcestring

  // Error messages
  sErrorPrefix = 'Error: %s';
  sParamRequired = 'Parameter required';
  sBadReader = 'Can''t create object to read version information';

  // General display text
  sSignOn = 'Version Information Spy by ' + cDeveloperAlias;
  sCopyright = 'Copyright (C) ' + cUpdateYear + ', ' + cDeveloperName;
  sFileTitle = 'Version Information for %s';
  sFileCreator = 'Created by ' + cLongSuiteName + ' ' + cDeveloperAlias;
  sUsage =
    'Usage is:'#13#10#13#10 +
    '  %0:s filename [-r] [-p] [-q|-Q]'#13#10 +
    '    or'#13#10 +
    '  %0:s -? | -h [-p]'#13#10#13#10 +
    '  Switches:'#13#10 +
    '    -r,-R    : display resource source code rather than description'#13#10+
    '    -p,-P    : prompt and wait for input before closing'#13#10 +
    '    -q       : display only version info and errors - other output ' +
                    'inhibited'#13#10 +
    '    -Q       : display version info only - other output and errors ' +
                    'inhibited'#13#10 +
    '    -?,-h,-H : displays this help (-q,-Q,-r & filename ignored)';
  sClosePrompt = 'Press return to close program';

var
  // Global flags
  PauseBeforeClose: Boolean;
    {Flag true if program is to pause for user input before closing}
  WantHelp: Boolean;
    {Flag true if help information is to be displayed rather than showing
    version information}
  DisplaySource: Boolean;
    {Flag true if resource source to be displayed, false if resource is to be
    described}
  OutputMode: Integer;
    {Level of output to be used: 0 -> all output displayed, 1 -> resource
    information and error messages to be displayed and 2 -> only resource info
    to be displayed and errors not displayed. Closing prompt will be displayed
    if -p specified regardless of output mode}

{$Resource FVCImages.res}     // contains program's icon
{$Resource VFileVerCmd.res}   // version information



procedure UnderLineText(const Strs: array of string);
  {Writes out one or more lines of text the writes an "underline" on last line
  that is as long as the longest line.
    @param Strs [in] Dynamic array of strings to be written, each on separate
      line.
  }
var
  Idx: Integer; // loops thru array of strings
  Max: Integer; // length of longest string in array
  S: string;    // current string in the array
begin
  // Zero the longest string length
  Max := 0;
  // Loop thru array, writing out strings and record length of longest
  for Idx := Low(Strs) to High(Strs) do
  begin
    S := Strs[Idx];
    if Length(S) > Max then
      Max := Length(S);
    WriteLn(S);
  end;
  // Write out underline
  WriteLn(StringOfChar('-', Max));
end;

procedure Display(const VI: IVerInfoReader);
  {Display version information stored in a reader object.
    @param VI [in] Data reader object storing required version information.
  }
var
  Stm: IStream;               // stream on which we output report
  RepLoader: TReporterLoader; // object that loads reporter DLL
  Reporter: IVerInfoReporter; // report generator object
  CLSID: TGUID;               // id of report generator object
  Title: string;              // title containing file name
  Header: WideString;         // header string ot be written out
begin
  Assert(Assigned(VI));
  // Create title
  Title := Format(sFileTitle, [ParamStr(1)]);
  // Create header string to be displayed in report
  if DisplaySource then
    Header := Title + #13#10 + sFileCreator
  else
    // simple write out file name for simple description
    Header := Format(sFileTitle, [ParamStr(1)]);
  // Create stream onto standard output for use by reporter
  Stm := TStdOutIStream.Create;
  // Load the reporter DLL
  RepLoader := TReporterLoader.Create;
  try
    // Select required reporter obect
    if DisplaySource then
      CLSID := CLSID_VerInfoRCReporter      // resource source output
    else
      CLSID := CLSID_VerInfoPlainReporter;  // description of ver info output
    // Create the required reporter object
    if Succeeded(RepLoader.CreateFunc(CLSID, Reporter)) then
      // Do report onto standard output
      Reporter.ReportToStream(VI, Stm, Header);
  finally
    Stm := nil;
    Reporter := nil;
    RepLoader.Free;
  end;
end;

procedure ClosePrompt;
  {If prompts are enabled, display prompt and wait for user to press enter
  otherwise do nothing.
  }
begin
  if PauseBeforeClose then
  begin
    WriteLn;
    Write(sClosePrompt);
    ReadLn;
  end;
end;

function UsageText: string;
  {Generates a string that describes how to use the program.
    @return Required usage string.
  }
begin
  Result := Format(sUsage, [ExtractFileName(ParamStr(0))]);
end;

procedure DisplayHelp;
  {Displays help (usage information) on standard output.
  }
begin
  WriteLn(UsageText);
end;

procedure ParseParams;
  {Checks for switches on command line and sets global flags accordingly.
    @except Exception raised if no parameters are provided.
  }
begin
  // It's an error to supply no parameter: output error message and usage info
  if ParamCount = 0 then
    raise Exception.Create(sParamRequired + #13#10 + UsageText);
  // -p switch => program pauses for user input before closing
  PauseBeforeClose := FindCmdLineSwitch('p', ['/', '-'], True);
  // -h or -? switches => display help
  WantHelp := FindCmdLineSwitch('h', ['/', '-'], True) or
    FindCmdLineSwitch('?', ['/', '-'], False);
  // -r switch => display resource source code rather than description
  DisplaySource := FindCmdLineSwitch('r', ['/', '-'], True);
  // -Q and -q switch: determines what output is produced
  if FindCmdLineSwitch('q', ['/', '-'], False) then
    OutputMode := 1
  else if FindCmdLineSwitch('Q', ['/', '-'], False) then
    OutputMode := 2
  else
    OutputMode := 0;
end;

procedure Main;
  {Controls and executes program.
  }
var
  Loader: TVIFileReaderLoader;  // object that loads and instantiates reader
  Reader: IVerInfoFileReader;   // version information file reader object
  VI: IVerInfoReader;           // version information data reader object
begin
  try
    // Parse the switches on command line
    ParseParams;
    // Sign on: display program name, underlined if not in quiet mode
    if (OutputMode = 0) or WantHelp then
      UnderlineText([sSignOn, sCopyright]);
    if WantHelp then
      // User wants to display help: do it
      DisplayHelp
    else
    begin
      // User wants to display version info in required form on standard output
      // load the DLL containing reader object
      Loader := TVIFileReaderLoader.Create;
      try
        // create object to read version information: report any problem
        if Failed(Loader.CreateFunc(CLSID_VerInfoFileReader, Reader)) then
          raise Exception.Create(sBadReader);
        // read version info from file: report any errors
        if not Reader.LoadFile(PChar(ParamStr(1))) then
          raise Exception.Create(Reader.LastError);
        // display the version info
        // (need to assign and nil VI to get reference counting to work!)
        VI := Reader.VerInfo;
        Display(VI);
        VI := nil;
      finally
        // free the reader object and then unload the reader DLL
        Reader := nil;
        Loader.Free;
      end;
    end;
    // We succeeded: return zero
    ExitCode := 0;
  except
    // There was an error: display error info (if not output mode 2)
    // and return 1 to indicate error
    on E: Exception do
    begin
      ExitCode := 1;
      if OutputMode < 2 then
        WriteLn(Format(sErrorPrefix, [E.Message]));
    end;
  end;
end;

begin
  Main;
  // Prompt user to close if required
  ClosePrompt;
end.

