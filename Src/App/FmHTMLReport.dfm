inherited HTMLReportDlg: THTMLReportDlg
  Caption = 'Descriptive HTML Report'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    inherited pnlView: TPanel
      inline frWebViewer: THTMLViewer
        Left = 1
        Top = 1
        Width = 503
        Height = 311
        Align = alClient
        TabOrder = 0
        inherited webView: TWebBrowser
          Width = 503
          Height = 311
          ControlData = {
            4C000000FD330000252000000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
    inherited btnView: TButton
      Caption = '&View in IE'
    end
  end
end
