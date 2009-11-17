{ ##
  @FILE                     FrMemoViewer.pas
  @COMMENTS                 Implements a frame derived from TViewerBase that is
                            used to display text content in a memo control. It
                            implements the abstract methods of TViewerBase.
  @PROJECT_NAME             Version Information Spy Windows application.
  @PROJECT_DESC             Displays version information embedded in executable
                            and binary resource files.
  @DEPENDENCIES             None
  @HISTORY(
    @REVISION(
      @VERSION              1.0
      @DATE                 23/05/2004
      @COMMENTS             Original version
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
 * The Original Code is FrMemoViewer.pas.
 * 
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 * 
 * Portions created by the Initial Developer are Copyright (C) 2004 Peter
 * Johnson. All Rights Reserved.
 * 
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK *****
}


unit FrMemoViewer;


interface


uses
  // Delphi
  Classes, Controls, StdCtrls,
  // Project
  FrViewerBase;


type

  {
  TMemoViewer:
    A frame used to display text content in a memo control. Implements the
    abstract methods of TViewerBase.

    Inheritance: TMemoViewer -> TViewerBase -> [TFrame]
  }
  TMemoViewer = class(TViewerBase)
    edView: TMemo;
  protected
    function GetContent: TStrings; override;
      {Read accessor for Content property: copies content from memo control's
      lines property}
    procedure SetContent(const Value: TStrings); override;
      {Write accessor for Content property: stores content in memo control's
      lines property}
  public
    procedure SaveToFile(const FileName: string); override;
      {Saves content of memo to given file}
  end;


implementation


{$R *.dfm}


{ TMemoViewer }

function TMemoViewer.GetContent: TStrings;
  {Read accessor for Content property: copies content from memo control's lines
  property}
begin
  Result := edView.Lines;
end;

procedure TMemoViewer.SaveToFile(const FileName: string);
  {Saves content of memo to given file}
begin
  edView.Lines.SaveToFile(FileName);
end;

procedure TMemoViewer.SetContent(const Value: TStrings);
  {Write accessor for Content property: stores content in memo control's lines
  property}
begin
  edView.Lines := Value;
end;

end.
