inherited TextReportDlg: TTextReportDlg
  Caption = 'Descriptive Text Report'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    inherited pnlView: TPanel
      inline frMemoViewer: TMemoViewer
        Left = 1
        Top = 1
        Width = 503
        Height = 311
        Align = alClient
        TabOrder = 0
        inherited edView: TMemo
          Width = 503
          Height = 311
        end
      end
    end
  end
end
