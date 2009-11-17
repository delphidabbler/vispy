inherited ErrorReportDlg: TErrorReportDlg
  Caption = 'Translation Inconsistency Explanation'
  ClientWidth = 676
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    Width = 613
    Height = 313
    BevelOuter = bvLowered
    inline frHTML: THTMLViewer
      Left = 1
      Top = 1
      Width = 611
      Height = 311
      Align = alClient
      TabOrder = 0
      inherited webView: TWebBrowser
        Width = 611
        Height = 311
        ControlData = {
          4C000000263F0000252000000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
end
