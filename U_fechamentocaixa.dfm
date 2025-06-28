object F_fechamentocaixa: TF_fechamentocaixa
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = 'Fechamento do Caixa'
  ClientHeight = 358
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesktopCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 339
    Width = 447
    Height = 19
    Panels = <
      item
        Text = 'Pressione [ ESC ] para sair da tela.'
        Width = 50
      end>
  end
  object Pfcaixa: TPanel
    Left = 8
    Top = 8
    Width = 433
    Height = 321
    TabOrder = 1
    object Lcaixa: TLabel
      Left = 8
      Top = 15
      Width = 35
      Height = 13
      Caption = 'Caixa.:'
    end
    object Loperador: TLabel
      Left = 158
      Top = 15
      Width = 54
      Height = 13
      Caption = 'Operador.:'
    end
    object GroupBox3: TGroupBox
      Left = 8
      Top = 207
      Width = 417
      Height = 106
      Caption = 'Fechamento (Total + Abertura) - Sangria = Valor em caixa)'
      TabOrder = 4
      object Lvalor: TLabel
        Left = 8
        Top = 36
        Width = 144
        Height = 13
        Caption = 'Informe o Valor em Caixa  R$:'
      end
      object Lmsg: TLabel
        Left = 17
        Top = 69
        Width = 281
        Height = 19
        Caption = 'Caixa esta com uma diferen'#231'a de :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
      end
      object Lresult: TLabel
        Left = 300
        Top = 69
        Width = 20
        Height = 19
        Caption = 'ee'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Visible = False
      end
      object Evalor: TMaskEdit
        Left = 158
        Top = 33
        Width = 82
        Height = 21
        Alignment = taCenter
        TabOrder = 0
        Text = ''
        OnKeyPress = EvalorKeyPress
      end
    end
    object Ecaixa: TEdit
      Left = 46
      Top = 11
      Width = 103
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 38
      Width = 196
      Height = 163
      Caption = 'Valores Pagos'
      TabOrder = 1
      object Ldinheiro: TLabel
        Left = 8
        Top = 24
        Width = 92
        Height = 13
        Caption = 'Dinheiro            R$:'
      end
      object Lcredito: TLabel
        Left = 8
        Top = 48
        Width = 91
        Height = 13
        Caption = 'Cart'#227'o Cr'#233'dito R$:'
      end
      object Ldebito: TLabel
        Left = 8
        Top = 74
        Width = 90
        Height = 13
        Caption = 'Cart'#227'o Debito  R$:'
      end
      object Lpix: TLabel
        Left = 8
        Top = 99
        Width = 91
        Height = 13
        Caption = 'Pix                    R$:'
      end
      object Ltotal: TLabel
        Left = 8
        Top = 135
        Width = 91
        Height = 13
        Caption = 'Total em Caixa R$:'
      end
      object Edinheiro: TMaskEdit
        Left = 101
        Top = 21
        Width = 79
        Height = 21
        Alignment = taCenter
        ReadOnly = True
        TabOrder = 0
        Text = '0,00'
      end
      object Ecredito: TMaskEdit
        Left = 101
        Top = 45
        Width = 79
        Height = 21
        Alignment = taCenter
        ReadOnly = True
        TabOrder = 1
        Text = '0,00'
      end
      object Edebito: TMaskEdit
        Left = 101
        Top = 71
        Width = 79
        Height = 21
        Alignment = taCenter
        ReadOnly = True
        TabOrder = 2
        Text = '0,00'
      end
      object Epix: TMaskEdit
        Left = 101
        Top = 96
        Width = 79
        Height = 21
        Alignment = taCenter
        ReadOnly = True
        TabOrder = 3
        Text = '0,00'
      end
      object Etotalentrada: TMaskEdit
        Left = 101
        Top = 132
        Width = 79
        Height = 21
        Alignment = taCenter
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 4
        Text = ''
      end
    end
    object GroupBox2: TGroupBox
      Left = 210
      Top = 38
      Width = 215
      Height = 163
      Caption = 'Entradas e sa'#237'das'
      TabOrder = 2
      object Labertura: TLabel
        Left = 8
        Top = 24
        Width = 108
        Height = 13
        Caption = 'Abertura de Caixa R$:'
      end
      object Lsangria: TLabel
        Left = 8
        Top = 49
        Width = 109
        Height = 13
        Caption = 'Sangrias                 R$:'
      end
      object Eaberturacaixa: TMaskEdit
        Left = 118
        Top = 21
        Width = 79
        Height = 21
        Alignment = taCenter
        ReadOnly = True
        TabOrder = 0
        Text = ''
      end
      object Esangria: TMaskEdit
        Left = 118
        Top = 46
        Width = 79
        Height = 21
        Alignment = taCenter
        ReadOnly = True
        TabOrder = 1
        Text = ''
      end
    end
    object Eoperador: TEdit
      Left = 215
      Top = 11
      Width = 210
      Height = 21
      ReadOnly = True
      TabOrder = 3
    end
  end
  object Qryfechacaixa: TFDQuery
    Connection = DM.Conexao
    SQL.Strings = (
      ''
      
        'select sum(Cxf_vltotal)as Valor, Cxf_fpagto as Tipo from CaixaFe' +
        'chado '
      'group by  Cxf_fpagto')
    Left = 504
    Top = 232
    object QryfechacaixaValor: TCurrencyField
      FieldName = 'Valor'
      Origin = 'Valor'
      ReadOnly = True
    end
    object QryfechacaixaTipo: TStringField
      FieldName = 'Tipo'
      Origin = 'Tipo'
      Size = 50
    end
  end
  object QryabreCaixa: TFDQuery
    Connection = DM.Conexao
    SQL.Strings = (
      'select sum(Abertura_valor) as AValor from AberturaCaixa ')
    Left = 504
    Top = 176
    object QryabreCaixaAValor: TCurrencyField
      FieldName = 'AValor'
      Origin = 'AValor'
      ReadOnly = True
    end
  end
  object QrysangriaCaixa: TFDQuery
    Connection = DM.Conexao
    SQL.Strings = (
      'select sum(Sa_valor) as SValor from Sangria')
    Left = 504
    Top = 128
    object QrysangriaCaixaSValor: TCurrencyField
      FieldName = 'SValor'
      Origin = 'SValor'
      ReadOnly = True
    end
  end
  object QryresumoCaixa: TFDQuery
    Connection = DM.Conexao
    SQL.Strings = (
      'select * from Resumocaixa')
    Left = 496
    Top = 80
    object QryresumoCaixaRe_id: TFDAutoIncField
      FieldName = 'Re_id'
      Origin = 'Re_id'
      ReadOnly = True
    end
    object QryresumoCaixaRe_Total: TFloatField
      FieldName = 'Re_Total'
      Origin = 'Re_Total'
    end
    object QryresumoCaixaRe_emCaixa: TFloatField
      FieldName = 'Re_emCaixa'
      Origin = 'Re_emCaixa'
    end
    object QryresumoCaixaRe_diferenca: TFloatField
      FieldName = 'Re_diferenca'
      Origin = 'Re_diferenca'
    end
    object QryresumoCaixaRe_caixa: TStringField
      FieldName = 'Re_caixa'
      Origin = 'Re_caixa'
      Size = 30
    end
    object QryresumoCaixaRe_dtFechamento: TSQLTimeStampField
      FieldName = 'Re_dtFechamento'
      Origin = 'Re_dtFechamento'
    end
    object QryresumoCaixaRe_obs: TMemoField
      FieldName = 'Re_obs'
      Origin = 'Re_obs'
      BlobType = ftMemo
      Size = 2147483647
    end
  end
end
