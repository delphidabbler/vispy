{ ##
  @FILE                     CmpHotButton.pas
  @COMMENTS                 Implements a "flat" button that highlights when
                            cursor passes over it and that can display a symbol
                            in addition to a caption. The style of the button
                            depends on whether or not Windows XP themes are
                            active.
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
 * The Original Code is CmpHotButton.pas.
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


unit CmpHotButton;


interface


uses
  // Delphi
  Classes, Controls, Graphics, Messages;

type

  {
  THotButtonState:
    Enumeration of the three possible visible states of a THotButton.
  }
  THotButtonState = (
    hbsNormal,    // button is in normal state: not pressed and not hot
    hbsHot,       // button is "hot" - i.e. mouse over it but not pressed
    hbsPressed    // button is pressed
  );

  {
  THotButton:
    Custom "flat" button that highlights when cursor passes over it and that can
    display a symbol in addition to a caption. The style of the button depends
    on whether or not Windows XP themes are active.

    Inheritance: THotButton -> [TCustomControl]
  }
  THotButton = class(TCustomControl)
  private // properties
    fBorderWidth: Integer;
    fAutoSize: Boolean;
    fGlyphText: TCaption;
    fHotColor: TColor;
    fHotUnderline: Boolean;
    procedure SetBorderWidth(const Value: Integer);
    procedure SetGlyphText(const Value: TCaption);
    procedure SetHotColor(const Value: TColor);
    procedure SetHotUnderline(const Value: Boolean);
  protected // properties
    procedure SetAutoSize(Value: Boolean); override;
  private
    fGlyphFont: TFont;
      {Stores font used to display any glyph text}
    fState: THotButtonState;
      {Current state of button: normal, pressed or hot}
    fDragging: Boolean;
      {True if mouse is dragging with left button down, false if not}
    fMouseEntering: Boolean;
      {Flag set true when mouse enters control to allow event handlers to update
      state of control, then reset this flag}
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
      {Adjusts bounds of control to allow for changed font}
    procedure CMTextChanged(var Msg: TMessage); message CM_TEXTCHANGED;
      {Adjusts bounds of control to fit changed text}
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
      {Sets flag to note that mouse is entering the control}
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      {Sets state to normal when mouse leaves control}
    procedure SetState(State: THotButtonState);
      {Sets state that governs the control's appearance to given value and
      updates control}
    procedure AdjustBounds;
      {Adjusts size of control to fit contents if AutoSize property is true}
    function TextWidth: Integer;
      {Returns width required for control's text and any optional glyph text}
    procedure CaptionFontToCanvas;
      {Updates the control's canvas to use the font required to display the
      caption taking into account various other property values}
    procedure GlyphFontToCanvas;
      {Updates the control's canvas to use the font required to display the
      glyph text taking into account various other property values}
  protected
    procedure Paint; override;
      {Paint the control, taking into account Windows XP themes if active}
    procedure CreateWnd; override;
      {Adjust control bounds when control's window is created}
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
      {Set control to appropriate state when mouse is in the control: either hot
      or pressed depending on whether mouse is dragging}
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
      {Set button to pressed state if left button pressed}
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
      {Generate a click event when mouse is released over a pressed control}
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor: creates control and its owned objects and sets default
      values}
    destructor Destroy; override;
      {Class destructor: frees owned object}
    { New properties }
    property AutoSize: Boolean read fAutoSize write SetAutoSize;
      {When property is true the button sizes itself to the Caption and optional
      glyph text. Width, but not height is affected by this property}
    property BorderWidth: Integer read fBorderWidth write SetBorderWidth;
      {Width of border between edges of button and text}
    property GlyphText: TCaption read fGlyphText write SetGlyphText;
      {Optional text that displays as a glyph in WingDings font on the left of
      the Caption text}
    property HotColor: TColor read fHotColor write SetHotColor;
      {Colour of Caption and GlyphText when button is "hot" or pressed}
    property HotUnderline: Boolean read fHotUnderline write SetHotUnderline;
      {Determines whether Caption is underlined when button is "hot" or pressed}
    { Inherited properties }
    property Action;
    property Caption;
    property Cursor default crHandPoint;
    property Font;
    property ParentFont;
    property OnClick;
  end;


implementation


uses
  // Delphi
  Windows, SysUtils, Themes;


{ THotButton }

const
  cMargin = 4;    // margin separating text from edge of button
  cSpacing = 2;   // spacing between glyph text and caption text


procedure THotButton.AdjustBounds;
  {Adjusts size of control to fit contents if AutoSize property is true}
var
  W: Integer; // required width of control
begin
  if not (csReading in ComponentState) and fAutoSize and HandleAllocated then
  begin
    // Control width allows for border, a margin and width of text
    W := TextWidth + 2 * (cMargin + fBorderWidth);
    SetBounds(Left, Top, W, Height);
  end;
end;

procedure THotButton.CaptionFontToCanvas;
  {Updates the control's canvas to use the font required to display the caption
  taking into account various other property values}
begin
  // Use the control's font
  Canvas.Font.Assign(Font);
  if fState <> hbsNormal then
  begin
    // Control is "hot": update font style to allow for hot colour and underline
    Canvas.Font.Color := fHotColor;
    if fHotUnderline then
      Canvas.Font.Style := Canvas.Font.Style + [fsUnderline]
    else
      Canvas.Font.Style := Canvas.Font.Style - [fsUnderline];
  end;
end;

procedure THotButton.CMFontChanged(var Msg: TMessage);
  {Adjusts bounds of control to allow for changed font}
begin
  inherited;
  AdjustBounds;
  Invalidate;
end;

procedure THotButton.CMMouseEnter(var Msg: TMessage);
  {Sets flag to note that mouse is entering the control}
begin
  inherited;
  fMouseEntering := True;
end;

procedure THotButton.CMMouseLeave(var Msg: TMessage);
  {Sets state to normal when mouse leaves control}
begin
  inherited;
  if fState = hbsNormal then
    Invalidate;
  SetState(hbsNormal);
end;

procedure THotButton.CMTextChanged(var Msg: TMessage);
  {Adjusts bounds of control to fit changed text}
begin
  inherited;
  Invalidate;
  AdjustBounds;
end;

constructor THotButton.Create(AOwner: TComponent);
  {Class constructor: creates control and its owned objects and sets default
  values}
begin
  inherited;
  // Set property defaults
  // inherited properties
  Height := 25;
  Width := 75;
  Cursor := crHandPoint;
  TabStop := False;
  // new properties
  fHotColor := clBlue;
  fHotUnderline := True;
  // Create glyph font
  fGlyphFont := TFont.Create;
  fGlyphFont.Name := 'WingDings';
  fGlyphFont.Size := 12;
  // Intialise button to normal state
  fState := hbsNormal;
end;

procedure THotButton.CreateWnd;
  {Adjust control bounds when control's window is created}
begin
  inherited;
  AdjustBounds;
end;

destructor THotButton.Destroy;
  {Class destructor: frees owned object}
begin
  FreeAndNil(fGlyphFont);
  inherited;
end;

procedure THotButton.GlyphFontToCanvas;
  {Updates the control's canvas to use the font required to display the glyph
  text taking into account various other property values}
begin
  // Use the control's font
  Canvas.Font.Assign(fGlyphFont);
  // Use either the hot colour or main font colour depending on if control "hot"
  if fState <> hbsNormal then
    Canvas.Font.Color := fHotColor
  else
    Canvas.Font.Color := Font.Color;
end;

procedure THotButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
  {Set button to pressed state if left button pressed}
begin
  inherited;
  if ([ssRight, ssMiddle] * Shift = []) and (ssLeft in Shift) then
  begin
    // Left button pressed: set pressed and note we are dragging mouse
    SetState(hbsPressed);
    fDragging := True;
  end
  else
    // Note we are not dragging mouse
    fDragging := False;
end;

procedure THotButton.MouseMove(Shift: TShiftState; X, Y: Integer);
  {Set control to appropriate state when mouse is in the control: either hot or
  pressed depending on whether mouse is dragging}
begin
  inherited;
  if fMouseEntering then
  begin
    // Mouse has just entered control: possibly change state
    if fDragging then
      // mouse dragging on re-entering control: make button pressed
      SetState(hbsPressed)
    else
      // mouse over button but not pressed: make button "hot"
      SetState(hbsHot);
    // Note we have now entered control & redraw
    fMouseEntering := False;
    Invalidate;
  end;
end;

procedure THotButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
  {Generate a click event when mouse is released over a pressed control}
begin
  inherited;
  // Mouse up => not dragging
  fDragging := False;
  if fState = hbsPressed then
  begin
    // Button pressed and left button being released => click event
    if ([ssRight, ssMiddle] * Shift = []) and (ssLeft in Shift) then
      Click;
    // Un-press then button
    SetState(hbsHot);
  end;
end;

procedure THotButton.Paint;
  {Paint the control, taking into account Windows XP themes if active}
var
  R: TRect;                       // stores bounds of drawing rectangles
  TextW: Integer;                 // width of text to be drawn
  Details: TThemedElementDetails; // details of XP themed element
const
  // Map of button states onto XP themed button styles
  cThemeStyles: array[THotButtonState] of TThemedToolBar = (
    ttbButtonNormal, ttbButtonHot, ttbButtonPressed
  );
  // Map of button states onto non-themed button styles
  cNormalStyles: array[THotButtonState] of Integer = (
    0, BDR_RAISEDINNER, BDR_SUNKENOUTER
  );
begin
  inherited;

  // Initialise canvas to control colour
  Canvas.Brush.Color := Color;
  Canvas.Brush.Style := bsSolid;

  // Record client rectangle of control
  R := Rect(0, 0, Width, Height);

  // Draw button
  begin
    if ThemeServices.ThemesEnabled then
    begin
      // draw XP-themed button
      Details := ThemeServices.GetElementDetails(cThemeStyles[fState]);
      ThemeServices.DrawElement(Canvas.Handle, Details, R);
    end
    else
      // draw non-themed button
      DrawEdge(Canvas.Handle, R, cNormalStyles[fState], BF_RECT or BF_MIDDLE);
  end;

  // Draw text
  // reduce client rect to allow for use defined border and fixed margins
  InflateRect(R, -(cMargin + fBorderWidth), -(cMargin + fBorderWidth));
  // paint with clear brush
  Canvas.Brush.Style := bsClear;
  if fGlyphText = '' then
  begin
    // no glyph text: just draw caption centered in button
    CaptionFontToCanvas;
    DrawText(
      Canvas.Handle,
      PChar(Caption),
      -1,
      R,
      DT_VCENTER or DT_SINGLELINE or DT_CENTER
    )
  end
  else
  begin
    // we have glyph text
    // calculate a rectangle large enough for glyph text and caption and centre
    // it in the control
    TextW := TextWidth;
    R := Bounds(
      (Width - TextW) div 2,
      R.Top,
      TextW,
      R.Bottom - R.Top
    );
    // draw caption, right justified in rectangle
    CaptionFontToCanvas;
    DrawText(
      Canvas.Handle,
      PChar(Caption),
      -1,
      R,
      DT_VCENTER or DT_SINGLELINE or DT_RIGHT
    );
    // draw glyph text, left justified in rectangle
    GlyphFontToCanvas;
    DrawText(
      Canvas.Handle,
      PChar(fGlyphText),
      -1,
      R,
      DT_VCENTER or DT_SINGLELINE or DT_LEFT
    );
  end;

end;

procedure THotButton.SetAutoSize(Value: Boolean);
  {Write accessor for AutoSize property}
begin
  if fAutoSize <> Value then
  begin
    fAutoSize := Value;
    AdjustBounds; // has no effect when AutoSize set to False
  end;
end;

procedure THotButton.SetBorderWidth(const Value: Integer);
  {Write accessor for BorderWidth property}
begin
  if fBorderWidth <> Value then
  begin
    fBorderWidth := Value;
    AdjustBounds; // allow for new border width
    Invalidate;
  end;
end;

procedure THotButton.SetGlyphText(const Value: TCaption);
  {Write accessor for GlyphText property}
begin
  if fGlyphText <> Value then
  begin
    fGlyphText := Value;
    AdjustBounds; // allow for any change in size of glyph
    Invalidate;
  end;
end;

procedure THotButton.SetHotColor(const Value: TColor);
  {Write accessor for HotColor property}
begin
  if fHotColor <> Value then
  begin
    fHotColor := Value;
    if fState <> hbsNormal then
      // only invalidate when not normal state: colour not used when normal
      Invalidate;
  end;
end;

procedure THotButton.SetHotUnderline(const Value: Boolean);
  {Write accessor for HotUnderline property}
begin
  if fHotUnderline <> Value then
  begin
    fHotUnderline := Value;
    if fState <> hbsNormal then
      // only invalidate when not normal state: underline not used when normal
      Invalidate;
  end;
end;

procedure THotButton.SetState(State: THotButtonState);
  {Sets state that governs the control's appearance to given value and updates
  control}
begin
  if State <> fState then
  begin
    fState := State;
    Invalidate;
  end;
end;

function THotButton.TextWidth: Integer;
  {Returns width required for control's text and any optional glyph text}
var
  Rect: TRect;    // rectangle used to calculate Caption size
  GRect: TRect;   // rectangle used to calculate GlyphText size
begin
  // Intialise rectangle
  Rect := ClientRect;
  // Calculate width of Caption
  CaptionFontToCanvas;
  DrawText(
    Canvas.Handle,
    PChar(Caption),
    -1,
    Rect,
    DT_VCENTER or DT_SINGLELINE or DT_CENTER or DT_CALCRECT
  );
  Result := Rect.Right - Rect.Left;
  // If we have GlyphText, calculate its size
  if fGlyphText <> '' then
  begin
    GRect := ClientRect;
    GlyphFontToCanvas;
    DrawText(
      Canvas.Handle,
      PChar(fGlyphText),
      -1,
      GRect,
      DT_VCENTER or DT_SINGLELINE or DT_CENTER or DT_CALCRECT
    );
    // add glyph text size to caption size and allowing for separating space
    Result := Result + GRect.Right - GRect.Left + cSpacing;
  end;
end;

end.
