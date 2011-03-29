{
 * UHelpManager.pas
 *
 * Implements static class that manages the Version Information Spy HTML Help
 * system.
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
 * The Original Code is UHelpManager.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 2011 Peter
 * Johnson. All Rights Reserved.
 *
 * Contributors:
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit UHelpManager;


interface


uses
  // Delphi
  Windows;


type

  {
  THelpManager:
    Static class that manages the Version Informatio Spy HTML help system.
  }
  THelpManager = class(TObject)
  private
    class function HelpFileName: string;
      {Gets name of help file.
        @return Fully qualified help file name.
      }
    class function TopicURL(const TopicName: string): string;
      {Gets fully specified topic URL from a topic name.
        @param TopicName [in] Name of topic (same as associated topic file,
          without the extension).
        @return Full topic URL.
      }
    class procedure DoAppHelp(const Command: LongWord;
      const TopicName: string; const Data: LongWord);
      {Calls the HtmlHelp API with a specified command and parameters.
        @param Command [in] Command to send to HTML Help.
        @param TopicName [in] Names an HTML topic file within the help file,
          without extension. May be '' if no specific topic is required.
        @param Data [in] Command dependent data to pass to HTML Help.
      }
  public
    const
      //  Topic displayed if requested a-link for a dialog box doesn't exist.
      NoDlgHelpTopic = 'no-dlg-help';
    class procedure Contents;
      {Displays help contents.
      }
    class procedure ShowTopic(Topic: string);
      {Displays a given help topic.
        @param Topic [in] Help topic to display. Topic is the name of the HTML
          file that stores the topic, without the extension.
      }
    class procedure ShowALink(const AKeyword: string; const ErrTopic: string);
      {Displays help topic(s) specified by an A-Link keyword.
        @param AKeyword [in] Required A-Link keyword. Must be valid as ANSI
          string.
        @param ErrTopic [in] Name of topic to display if keyword not found. Must
          be valid as ANSI string.
      }
    class procedure Quit;
      {Closes down the help system.
      }
  end;



implementation


uses
  // Delphi
  SysUtils,
  // Project
  UHTMLHelp;


{ THelpManager }

class procedure THelpManager.Contents;
  {Displays help contents.
  }
begin
  DoAppHelp(HH_DISPLAY_TOC, '', 0);
end;

class procedure THelpManager.DoAppHelp(const Command: LongWord;
  const TopicName: string; const Data: LongWord);
  {Calls the HtmlHelp API with a specified command and parameters.
    @param Command [in] Command to send to HTML Help.
    @param TopicName [in] Names an HTML topic file within the help file, without
      extension. May be '' if no specific topic is required.
    @param Data [in] Command dependent data to pass to HTML Help.
  }
var
  HelpURL: string; // URL of help file, or topic with help file
begin
  if TopicName = '' then
    HelpURL := HelpFileName
  else
    HelpURL := TopicURL(TopicName);
  HtmlHelp(GetDesktopWindow(), PChar(HelpURL), Command, Data);
end;

class function THelpManager.HelpFileName: string;
  {Gets name of help file.
    @return Fully qualified help file name.
  }
begin
  Result := ExtractFilePath(ParamStr(0)) + 'VIS.chm';
end;

class procedure THelpManager.Quit;
  {Closes down the help system.
  }
begin
  HtmlHelp(0, nil, HH_CLOSE_ALL, 0);
end;

class procedure THelpManager.ShowALink(const AKeyword: string;
  const ErrTopic: string);
  {Displays help topic(s) specified by an A-Link keyword.
    @param AKeyword [in] Required A-Link keyword. Must be valid as ANSI string.
    @param ErrTopic [in] Name of topic to display if keyword not found. Must be
      valid as ANSI string.
  }
var
  ALink: THHAKLink;   // structure containing details of A-Link
begin
  // Fill in A link structure
  ZeroMemory(@ALink, SizeOf(ALink));
  ALink.cbStruct := SizeOf(ALink);      // size of structure
  ALink.fIndexOnFail := False;
  // This one is weird: when using the Unicode API just casting the keyword to
  // PChar causes HTML Help to see only the first character of the keyword. We
  // have to cast to Ansi string and then to a pointer to get this to work,
  // even though pszUrl and pszKeywords are declared as PWideChar
  {$WARN EXPLICIT_STRING_CAST_LOSS OFF}
  ALink.pszUrl := Pointer(PAnsiChar(AnsiString(TopicURL(ErrTopic))));
  ALink.pszKeywords := Pointer(PAnsiChar(AnsiString(AKeyword)));
  {$WARN EXPLICIT_STRING_CAST_LOSS ON}
  // Display help
  DoAppHelp(HH_ALINK_LOOKUP, '', LongWord(@ALink));
end;

class procedure THelpManager.ShowTopic(Topic: string);
  {Displays a given help topic.
    @param Topic [in] Help topic to display. Topic is the name of the HTML file
      that stores the topic, without the extension.
  }
begin
  DoAppHelp(HH_DISPLAY_TOPIC, Topic, 0);
end;

class function THelpManager.TopicURL(const TopicName: string): string;
  {Gets fully specified topic URL from a topic name.
    @param TopicName [in] Name of topic (same as associated topic file, without
      the extension).
    @return Full topic URL.
  }
begin
  Result := HelpFileName + '::/HTML/' + TopicName + '.htm';
end;

end.

