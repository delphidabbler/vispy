{
 * FrViewerBase.pas
 *
 * Implements a TFrame descendant that contains no controls but provides an
 * abstract base class for frames that are used to view and save some TStrings
 * based content. This class exposes methods by which controlling code can
 * manipulate the frame content without knowledge of how it is displayed or
 * stored.
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
 * The Original Code is FrViewerBase.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2004-2010 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *   NONE
 *
 * ***** END LICENSE BLOCK *****
}


unit FrViewerBase;


interface


uses
  // Delphi
  Forms, Classes;


type

  {
  TViewerBase:
    TFrame descendant that contains no controls but provides an abstract base
    class for frames that are used to view and save some TStrings based content.
    This class exposes methods by which controlling code can manipulate the
    frame content without knowledge of how it is displayed or stored.

    Inheritance: TViewerBase -> [TFrame]
  }
  TViewerBase = class(TFrame)
  protected // properties
    function GetContent: TStrings; virtual; abstract;
      {Read accessor for Content property}
    procedure SetContent(const Value: TStrings); virtual; abstract;
      {Write accessor for Content property}
  public
    procedure SaveToFile(const FileName: string); virtual; abstract;
      {Saves the content to the given file}
    property Content: TStrings read GetContent write SetContent;
      {The content that is displayed in the frame}
  end;


implementation

{$R *.dfm}

end.
