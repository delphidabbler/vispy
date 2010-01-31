{
 * CmpTextBox.pas
 *
 * Implements a component that displays text in a framed box. The style of box
 * depends on whether or not Windows XP themes are active.
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
 * The Original Code is CmpTextBox.pas.
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


unit CmpTextBox;


interface


uses
  // Delphi
  Controls;

type

  {
  TTextBox:
    Custom component that displays text within a "box". Designed for use in
    page controls, the box displays differently according to whether XP themes
    are enabled. NOTE: The component is not suitable for publishing on the
    component palette.
  }
  TTextBox = class(TGraphicControl)
  protected
    procedure Paint; override;
      {Paints the text box}
  published
    { Inherited properties }
    property Caption;
    property Left;
    property Top;
    property Width;
    property Height;
  end;


implementation


uses
  // Delphi
  Themes, Windows, Graphics;


{ TTextBox }

procedure TTextBox.Paint;
  {Paints the text box}
var
  R: TRect;                       // rectangle to be painted
  Details: TThemedElementDetails; // details of tab set pane used to paint frame
const
  // flags used when drawing text
  cTextFlags = DT_LEFT or DT_WORDBREAK;
begin
  inherited;
  // Get client rectangle of control
  R := ClientRect;
  with Canvas do
  begin
    if ThemeServices.ThemesEnabled then
    begin
      // Paint in XP style
      // we make control appear like a tab sheet pane
      Details := ThemeServices.GetElementDetails(ttPane);
      // draw the frame and bacground
      ThemeServices.DrawElement(Handle, Details, R);
      // draw the text, word wrapped
      InflateRect(R, -4, -2);
      ThemeServices.DrawText(Handle, Details, Caption, R, cTextFlags, 0);
    end
    else
    begin
      // Paint in classic style
      // panel is framed with a drop shadow
      Brush.Color := clBtnFace;
      // draw the frame and background
      // .. draw drop shadow part of frame: bottom and right edges
      Dec(R.Right, 1);
      Dec(R.Bottom, 1);
      OffsetRect(R, 1, 1);
      DrawEdge(Handle, R, BDR_SUNKENOUTER, BF_BOTTOMRIGHT or BF_FLAT);
      // .. draw background
      OffsetRect(R, -1, -1);
      FillRect(R);
      // .. draw main part of frame
      DrawEdge(Handle, R, BDR_SUNKENOUTER, BF_RECT or BF_FLAT);
      // draw the text, word wrapped
      InflateRect(R, -3, -2);
      DrawText(Handle, PChar(Caption), -1, R, cTextFlags);
    end;
  end;
end;

end.
