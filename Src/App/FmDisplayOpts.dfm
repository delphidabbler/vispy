inherited DisplayOptsDlg: TDisplayOptsDlg
  Caption = 'Display Options'
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBody: TPanel
    Height = 333
    object lblDesc: TLabel [0]
      Left = 8
      Top = 8
      Width = 361
      Height = 41
      AutoSize = False
      Caption = 
        'Use this dialog to change the way that version information is di' +
        'splayed.'
      WordWrap = True
    end
    inherited pcMain: TPageControl
      Top = 31
      Height = 302
      ActivePage = tsTrans
      object tsPopups: TTabSheet
        Caption = '&Pop-ups'
        ImageIndex = 3
        object lblPopupOverflow: TLabel
          Left = 33
          Top = 63
          Width = 312
          Height = 53
          AutoSize = False
          Caption = 
            'When text is too long for the space available to display it the ' +
            'program can display a pop-up window containing the full text whe' +
            'n the mouse is over the item. Check this box to enable this feat' +
            'ure.'
          WordWrap = True
        end
        object chkPopupOverflow: TCheckBox
          Left = 8
          Top = 48
          Width = 337
          Height = 13
          Caption = 'Display &overflow text in pop-up window'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
        end
      end
      object tsFFI: TTabSheet
        Caption = '&Fixed File Info'
        object lblFFIStructInfo: TLabel
          Left = 33
          Top = 63
          Width = 312
          Height = 40
          AutoSize = False
          Caption = 
            'The fixed file information data structure contains a version num' +
            'ber and a "signature" field. This structure information can be d' +
            'isplayed by checking this box.'
          WordWrap = True
        end
        object lblFFICreateDate: TLabel
          Left = 33
          Top = 124
          Width = 312
          Height = 40
          AutoSize = False
          Caption = 
            'Fixed file information contains a field to record the file'#39's cre' +
            'ation date. This field is rarely used by programs. Check this bo' +
            'x to display the creation date.'
          WordWrap = True
        end
        object lblFFIDescFileFlags: TLabel
          Left = 33
          Top = 185
          Width = 312
          Height = 53
          AutoSize = False
          Caption = 
            'The File Flags and File Flags Mask fields are bitmasks. You can ' +
            'either display the numeric value of these fields (in hex) or dis' +
            'play a description of the flags included in the bitmask. Check t' +
            'his box to display a description of the flags.'
          WordWrap = True
        end
        object chkFFIStructInfo: TCheckBox
          Left = 8
          Top = 48
          Width = 337
          Height = 13
          Caption = '&Display structure information.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
        end
        object chkFFICreateDate: TCheckBox
          Left = 8
          Top = 109
          Width = 337
          Height = 13
          Caption = 'Display &creation date.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 1
        end
        object chkFFIDescFileFlags: TCheckBox
          Left = 8
          Top = 170
          Width = 337
          Height = 13
          Caption = 'D&escribe file flags.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
        end
      end
      object tsTrans: TTabSheet
        Caption = '&Translation'
        ImageIndex = 2
        object lblTransHighlightErr: TLabel
          Left = 33
          Top = 63
          Width = 312
          Height = 65
          AutoSize = False
          Caption = 
            'Sometimes the translation information contained in the variable ' +
            'file information section does not match a string table'#39's languag' +
            'e and vice versa. Such problems can be highlighted in the transl' +
            'ation combo box. Check this box if you wish to do this then sele' +
            'ct the required highlight colour below.'
          WordWrap = True
        end
        object lblTransHighlightColour: TLabel
          Left = 33
          Top = 138
          Width = 76
          Height = 13
          Caption = 'Highlight &colour:'
        end
        object lblTransExplainErrText: TLabel
          Left = 33
          Top = 179
          Width = 312
          Height = 27
          AutoSize = False
          Caption = 
            'Check this box to display an explanation of any translation inco' +
            'nsistency above the translation combo box.'
          WordWrap = True
        end
        object lblTransExplainErrBtn: TLabel
          Left = 33
          Top = 227
          Width = 312
          Height = 40
          AutoSize = False
          Caption = 
            'Check to display a button that leads to a detailed explanation o' +
            'f translation inconsistencies. The button is not displayed when ' +
            'there is no problem.'
          WordWrap = True
        end
        object chkTransHighlightErr: TCheckBox
          Left = 8
          Top = 48
          Width = 337
          Height = 13
          Caption = 'Hi&ghlight inconsistent translation entries.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = chkTransHighlightErrClick
        end
        object cbTransHighlightColour: TColorBox
          Left = 120
          Top = 133
          Width = 177
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 1
        end
        object chkTransExplainErrText: TCheckBox
          Left = 8
          Top = 164
          Width = 337
          Height = 13
          Caption = '&Explain translation inconsistencies'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 2
        end
        object chkTransExplainErrBtn: TCheckBox
          Left = 8
          Top = 212
          Width = 337
          Height = 13
          Caption = '&Add explanation button.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 3
        end
      end
      object tsStrInfo: TTabSheet
        Caption = '&String Info'
        ImageIndex = 1
        object lblStrHighlightNonStd: TLabel
          Left = 33
          Top = 63
          Width = 312
          Height = 53
          AutoSize = False
          Caption = 
            'Microsoft has defined a set of "standard" string information ite' +
            'ms. In addition, developers can specify additional items. These ' +
            'non- standard items can be highlighted in the string information' +
            ' display. Check this box to do this and select the highlight col' +
            'our below.'
          WordWrap = True
        end
        object lblStrHighlightColour: TLabel
          Left = 33
          Top = 126
          Width = 76
          Height = 13
          Caption = 'Highlight &colour:'
        end
        object chkStrHighlightNonStd: TCheckBox
          Left = 8
          Top = 48
          Width = 337
          Height = 13
          Caption = 'Hi&ghlight non-standard string information items.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 0
          OnClick = chkStrHighlightNonStdClick
        end
        object cbStrHighlightColour: TColorBox
          Left = 120
          Top = 121
          Width = 177
          Height = 22
          Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbPrettyNames]
          ItemHeight = 16
          TabOrder = 1
        end
      end
    end
  end
  inherited btnHelp: TButton
    TabOrder = 4
  end
  inherited btnCancel: TButton
    TabOrder = 3
  end
  inherited btnOK: TButton
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnDefault: TButton
    Left = 24
    Top = 296
    Width = 97
    Height = 25
    Caption = '&Restore Defaults'
    TabOrder = 1
    OnClick = btnDefaultClick
  end
end
