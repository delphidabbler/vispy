inherited ExplExtAddDlg: TExplExtAddDlg
  Caption = 'Add Extension'
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    Width = 321
    Height = 228
    object lblSelectExt: TLabel
      Left = 0
      Top = 0
      Width = 240
      Height = 13
      Caption = '&Select extension from list below or enter in edit box:'
      FocusControl = lvExts
    end
    object lblExtText: TLabel
      Left = 0
      Top = 211
      Width = 101
      Height = 13
      Caption = '&Extension to register: '
      FocusControl = edExt
    end
    object lvExts: TListView
      Left = 0
      Top = 18
      Width = 321
      Height = 178
      Columns = <
        item
          Caption = 'Ext'
          Width = 70
        end
        item
          Caption = 'File Type'
          Width = 230
        end>
      ColumnClick = False
      HideSelection = False
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnSelectItem = lvExtsSelectItem
    end
    object edExt: TEdit
      Left = 112
      Top = 207
      Width = 121
      Height = 21
      TabOrder = 1
      OnChange = edExtChange
    end
  end
  inherited btnOK: TButton
    Enabled = False
    OnClick = btnOKClick
  end
end
