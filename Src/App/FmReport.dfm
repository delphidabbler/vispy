inherited ReportBaseDlg: TReportBaseDlg
  Caption = 'ReportBaseDlg'
  ClientHeight = 378
  ClientWidth = 671
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    Width = 616
    Height = 313
    object pnlView: TPanel
      Left = 0
      Top = 0
      Width = 505
      Height = 313
      BevelOuter = bvLowered
      TabOrder = 0
    end
    object btnSave: TButton
      Left = 512
      Top = 0
      Width = 100
      Height = 25
      Caption = '&Save...'
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object btnCopy: TButton
      Left = 512
      Top = 32
      Width = 100
      Height = 25
      Caption = '&Copy'
      TabOrder = 2
      OnClick = btnCopyClick
    end
    object btnView: TButton
      Left = 512
      Top = 64
      Width = 100
      Height = 25
      Caption = '&View Externally'
      TabOrder = 3
      OnClick = btnViewClick
    end
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'rc'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 64
    Top = 256
  end
end
