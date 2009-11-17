inherited BaseTabbedDlg: TBaseTabbedDlg
  Caption = 'BaseTabbedDlg'
  ClientHeight = 339
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited bvlBottom: TBevel
    Visible = False
  end
  inherited pnlBody: TPanel
    object pcMain: TPageControl
      Left = 0
      Top = 48
      Width = 369
      Height = 257
      Align = alBottom
      TabOrder = 0
    end
  end
end
