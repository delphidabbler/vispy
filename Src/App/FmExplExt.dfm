inherited ExplExtDlg: TExplExtDlg
  Left = 527
  Top = 121
  Caption = 'Explorer Extensions'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    Width = 361
    Height = 362
    object lblDesc: TLabel [0]
      Left = 0
      Top = 0
      Width = 361
      Height = 41
      AutoSize = False
      Caption = 
        'Version Information Spy can be activated from a right-click cont' +
        'ext menu in the Windows Explorer and can also add a new page to ' +
        'Explorer'#39's property sheet. Use this dialog to configure how the ' +
        'program works with Explorer.'
      WordWrap = True
    end
    inherited pcMain: TPageControl
      Width = 361
      Height = 314
      ActivePage = tsAdvanced
      object tsBasic: TTabSheet
        Caption = '&Basic'
        object lblEnableCtxMenu: TLabel
          Left = 33
          Top = 23
          Width = 312
          Height = 40
          AutoSize = False
          Caption = 
            'Check this box to enable the program to be started from a contex' +
            't menu item in Explorer. Use the "Advanced" tab for fine control' +
            ' over the registered file types.'
          WordWrap = True
        end
        object lblSingleAppInst: TLabel
          Left = 33
          Top = 145
          Width = 312
          Height = 40
          AutoSize = False
          Caption = 
            'When an explorer extension activates Version Information Spy it ' +
            'can be restricted to use only a single instance of the program b' +
            'y checking this box.'
          WordWrap = True
        end
        object lblQueryUser: TLabel
          Left = 33
          Top = 218
          Width = 312
          Height = 53
          AutoSize = False
          Caption = 
            'If this box is checked and a file that contains version informat' +
            'ion is opened and its extension is unknown to Version Informatio' +
            'n Spy the program will ask the user whether to register the file' +
            ' type with the explorer extensions.'
          WordWrap = True
        end
        object Label1: TLabel
          Left = 33
          Top = 84
          Width = 312
          Height = 40
          AutoSize = False
          Caption = 
            'Check this box to display an new, extended, Explorer property sh' +
            'eet tab for files that contain version information. Use the "Adv' +
            'anced" tab for fine control over the registered file types.'
          WordWrap = True
        end
        object cbEnableCtxMenu: TCheckBox
          Left = 8
          Top = 8
          Width = 337
          Height = 13
          Caption = '&Enable Explorer context menu extension.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = cbEnableCtxMenuClick
        end
        object cbSingleAppInst: TCheckBox
          Left = 8
          Top = 130
          Width = 337
          Height = 13
          Caption = 'Explorer extensions use a &single application instance.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
        end
        object cbQueryUser: TCheckBox
          Left = 8
          Top = 191
          Width = 337
          Height = 25
          Caption = 'As&k user whether to register extension for new file extensions.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
          WordWrap = True
        end
        object cbEnablePropSheet: TCheckBox
          Left = 8
          Top = 69
          Width = 337
          Height = 13
          Caption = 'Enable E&xplorer property sheet tab.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
          OnClick = cbEnablePropSheetClick
        end
      end
      object tsAdvanced: TTabSheet
        Caption = 'Ad&vanced'
        ImageIndex = 1
        object lblExts: TLabel
          Left = 8
          Top = 229
          Width = 337
          Height = 53
          AutoSize = False
          Caption = 
            'Check the boxes to register a file type with the relevant shell ' +
            'extension. Use column CM for the Context Menu handler and PS for' +
            ' the Property Sheet extension. Use the Add and Delete buttons to' +
            ' add and remove listed extensions.'
          WordWrap = True
        end
        object lvExts: TListView
          Left = 8
          Top = 8
          Width = 257
          Height = 217
          Checkboxes = True
          Columns = <
            item
              Caption = 'CM'
              MaxWidth = 34
              MinWidth = 34
              Width = 34
            end
            item
              Caption = 'PS'
              MaxWidth = 34
              MinWidth = 34
              Width = 34
            end
            item
              Caption = 'Ext'
              MinWidth = 50
            end
            item
              Caption = 'File Type'
              MinWidth = 60
              Width = 118
            end>
          ColumnClick = False
          HideSelection = False
          OwnerDraw = True
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnDrawItem = lvExtsDrawItem
          OnKeyPress = lvExtsKeyPress
          OnMouseDown = lvExtsMouseDown
          OnSelectItem = lvExtsSelectItem
        end
        object btnSelectAll: TButton
          Left = 272
          Top = 8
          Width = 75
          Height = 25
          Caption = '&Select All'
          TabOrder = 1
          OnClick = btnSelectAllClick
        end
        object btnDeselectAll: TButton
          Left = 272
          Top = 40
          Width = 75
          Height = 25
          Caption = '&Clear All'
          TabOrder = 2
          OnClick = btnDeselectAllClick
        end
        object btnDelete: TButton
          Left = 272
          Top = 88
          Width = 75
          Height = 25
          Caption = '&Delete'
          TabOrder = 3
          OnClick = btnDeleteClick
        end
        object btnAddExt: TButton
          Left = 272
          Top = 128
          Width = 75
          Height = 25
          Caption = '&Add...'
          TabOrder = 4
          OnClick = btnAddExtClick
        end
      end
    end
  end
  inherited btnOK: TButton
    OnClick = btnOKClick
  end
end
