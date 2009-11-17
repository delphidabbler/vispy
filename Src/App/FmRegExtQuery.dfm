inherited RegExtQueryDlg: TRegExtQueryDlg
  Caption = 'Shell Extension Registration Query'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    Width = 233
    Height = 98
    object lblDesc: TLabel
      Left = 0
      Top = 0
      Width = 212
      Height = 26
      AutoSize = False
      Caption = 'Select which explorer extension(s) to register extension with:'
      WordWrap = True
    end
    object cbCtxMenu: TCheckBox
      Left = 0
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Context menu'
      TabOrder = 0
    end
    object cbPropSheet: TCheckBox
      Left = 0
      Top = 72
      Width = 97
      Height = 17
      Caption = 'Property Sheet'
      TabOrder = 1
    end
  end
end
