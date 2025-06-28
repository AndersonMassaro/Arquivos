object F_importXML: TF_importXML
  Left = 0
  Top = 0
  Caption = 'Importar XML'
  ClientHeight = 638
  ClientWidth = 841
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 619
    Width = 841
    Height = 19
    Panels = <>
  end
  object Pcabecario: TPanel
    Left = 6
    Top = 8
    Width = 827
    Height = 41
    BorderWidth = 2
    TabOrder = 1
    object Larquivo: TLabel
      Left = 16
      Top = 11
      Width = 57
      Height = 16
      Caption = 'Arq. XML:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object edtXML: TEdit
      Left = 78
      Top = 10
      Width = 403
      Height = 21
      TabOrder = 0
    end
    object btCarregar: TBitBtn
      Left = 484
      Top = 8
      Width = 75
      Height = 23
      Caption = 'Abrir'
      TabOrder = 1
      OnClick = btCarregarClick
    end
    object btImportar: TBitBtn
      Left = 565
      Top = 8
      Width = 75
      Height = 23
      Caption = 'Importar'
      TabOrder = 2
      OnClick = btImportarClick
    end
  end
  object Pitens: TPanel
    Left = 6
    Top = 63
    Width = 827
    Height = 410
    BorderWidth = 2
    TabOrder = 2
    object Litens: TLabel
      Left = 8
      Top = 150
      Width = 134
      Height = 16
      Caption = 'Itens das Notas Fiscais '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Lcabecario: TLabel
      Left = 8
      Top = 3
      Width = 163
      Height = 16
      Caption = 'Cabe'#231'ario das Notas Fiscais '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object DBGrid2: TDBGrid
      Left = 4
      Top = 167
      Width = 815
      Height = 223
      Align = alCustom
      DataSource = dsItensNFE
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
    object DBGrid1: TDBGrid
      Left = 4
      Top = 22
      Width = 815
      Height = 120
      Align = alCustom
      DataSource = dsCabNFE
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
    end
  end
  object QryCabNFE: TFDQuery
    Connection = DM.Conexao
    UpdateObject = UpCabNFE
    SQL.Strings = (
      'select * from importCABNFE')
    Left = 32
    Top = 552
    object QryCabNFENroNFE: TIntegerField
      FieldName = 'NroNFE'
      Origin = 'NroNFE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryCabNFENatOperacao: TStringField
      FieldName = 'NatOperacao'
      Origin = 'NatOperacao'
      Size = 50
    end
    object QryCabNFEEmissao: TDateField
      FieldName = 'Emissao'
      Origin = 'Emissao'
    end
    object QryCabNFEStatus: TStringField
      FieldName = 'Status'
      Origin = 'Status'
      Size = 50
    end
    object QryCabNFEEmi_Nome: TStringField
      FieldName = 'Emi_Nome'
      Origin = 'Emi_Nome'
      Size = 50
    end
    object QryCabNFEEmi_CNPJ: TStringField
      FieldName = 'Emi_CNPJ'
      Origin = 'Emi_CNPJ'
      Size = 15
    end
    object QryCabNFEEmi_End: TStringField
      FieldName = 'Emi_End'
      Origin = 'Emi_End'
      Size = 50
    end
    object QryCabNFEEmi_Bairro: TStringField
      FieldName = 'Emi_Bairro'
      Origin = 'Emi_Bairro'
      Size = 50
    end
    object QryCabNFEEmi_Cidade: TStringField
      FieldName = 'Emi_Cidade'
      Origin = 'Emi_Cidade'
      Size = 50
    end
    object QryCabNFEEmi_UF: TStringField
      FieldName = 'Emi_UF'
      Origin = 'Emi_UF'
      Size = 2
    end
    object QryCabNFEDest_Nome: TStringField
      FieldName = 'Dest_Nome'
      Origin = 'Dest_Nome'
      Size = 50
    end
    object QryCabNFEDest_CNPJ: TStringField
      FieldName = 'Dest_CNPJ'
      Origin = 'Dest_CNPJ'
      Size = 15
    end
    object QryCabNFEDest_End: TStringField
      FieldName = 'Dest_End'
      Origin = 'Dest_End'
      Size = 50
    end
    object QryCabNFEDest_Bairro: TStringField
      FieldName = 'Dest_Bairro'
      Origin = 'Dest_Bairro'
      Size = 50
    end
    object QryCabNFEDest_Cidade: TStringField
      FieldName = 'Dest_Cidade'
      Origin = 'Dest_Cidade'
      Size = 50
    end
    object QryCabNFEDest_UF: TStringField
      FieldName = 'Dest_UF'
      Origin = 'Dest_UF'
      Size = 2
    end
  end
  object QryItensNFE: TFDQuery
    IndexFieldNames = 'NroNFE'
    MasterSource = dsCabNFE
    MasterFields = 'NroNFE'
    Connection = DM.Conexao
    UpdateObject = UpItensNFE
    SQL.Strings = (
      'select * from ImportITENSNFE')
    Left = 32
    Top = 608
    object QryItensNFENroNFE: TIntegerField
      FieldName = 'NroNFE'
      Origin = 'NroNFE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryItensNFEItem: TIntegerField
      FieldName = 'Item'
      Origin = 'Item'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object QryItensNFEBarras: TStringField
      FieldName = 'Barras'
      Origin = 'Barras'
      Size = 13
    end
    object QryItensNFECodProd: TStringField
      FieldName = 'CodProd'
      Origin = 'CodProd'
      Size = 13
    end
    object QryItensNFEDescProd: TStringField
      FieldName = 'DescProd'
      Origin = 'DescProd'
      Size = 50
    end
    object QryItensNFECFOP_Prod: TStringField
      FieldName = 'CFOP_Prod'
      Origin = 'CFOP_Prod'
      Size = 5
    end
    object QryItensNFENCM_Prod: TWideStringField
      FieldName = 'NCM_Prod'
      Origin = 'NCM_Prod'
      FixedChar = True
      Size = 10
    end
    object QryItensNFEUnidade_Prod: TStringField
      FieldName = 'Unidade_Prod'
      Origin = 'Unidade_Prod'
      Size = 3
    end
    object QryItensNFEValUnit_Prod: TBCDField
      FieldName = 'ValUnit_Prod'
      Origin = 'ValUnit_Prod'
      Precision = 7
      Size = 3
    end
    object QryItensNFEQuant_Prod: TBCDField
      FieldName = 'Quant_Prod'
      Origin = 'Quant_Prod'
      Precision = 7
      Size = 3
    end
    object QryItensNFEDesc_Prod: TBCDField
      FieldName = 'Desc_Prod'
      Origin = 'Desc_Prod'
      Precision = 7
      Size = 3
    end
    object QryItensNFETotItens_Prod: TBCDField
      FieldName = 'TotItens_Prod'
      Origin = 'TotItens_Prod'
      Precision = 7
      Size = 3
    end
    object QryItensNFEICMS_CST: TStringField
      FieldName = 'ICMS_CST'
      Origin = 'ICMS_CST'
      Size = 3
    end
    object QryItensNFEICMS_CSOSN: TStringField
      FieldName = 'ICMS_CSOSN'
      Origin = 'ICMS_CSOSN'
      Size = 6
    end
    object QryItensNFEICMS_PER: TBCDField
      FieldName = 'ICMS_PER'
      Origin = 'ICMS_PER'
      Precision = 7
      Size = 3
    end
    object QryItensNFEICMS_VAL: TBCDField
      FieldName = 'ICMS_VAL'
      Origin = 'ICMS_VAL'
      Precision = 7
      Size = 3
    end
    object QryItensNFEPIS_CST: TStringField
      FieldName = 'PIS_CST'
      Origin = 'PIS_CST'
      Size = 3
    end
    object QryItensNFEPIS_PER: TBCDField
      FieldName = 'PIS_PER'
      Origin = 'PIS_PER'
      Precision = 7
      Size = 3
    end
    object QryItensNFEPIS_VAL: TBCDField
      FieldName = 'PIS_VAL'
      Origin = 'PIS_VAL'
      Precision = 7
      Size = 3
    end
    object QryItensNFECOFINS_CST: TStringField
      FieldName = 'COFINS_CST'
      Origin = 'COFINS_CST'
      Size = 3
    end
    object QryItensNFECOFINS_PER: TBCDField
      FieldName = 'COFINS_PER'
      Origin = 'COFINS_PER'
      Precision = 7
      Size = 3
    end
    object QryItensNFECOFINS_VAL: TBCDField
      FieldName = 'COFINS_VAL'
      Origin = 'COFINS_VAL'
      Precision = 7
      Size = 3
    end
    object QryItensNFEStatus: TStringField
      FieldName = 'Status'
      Origin = 'Status'
      Size = 1
    end
  end
  object dsCabNFE: TDataSource
    DataSet = tbcabnfe
    Left = 96
    Top = 552
  end
  object dsItensNFE: TDataSource
    DataSet = QryItensNFE
    Left = 96
    Top = 608
  end
  object NFE: TACBrNFe
    Configuracoes.Geral.SSLLib = libNone
    Configuracoes.Geral.SSLCryptLib = cryNone
    Configuracoes.Geral.SSLHttpLib = httpNone
    Configuracoes.Geral.SSLXmlSignLib = xsNone
    Configuracoes.Geral.FormatoAlerta = 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.'
    Configuracoes.Arquivos.OrdenacaoPath = <>
    Configuracoes.WebServices.UF = 'SP'
    Configuracoes.WebServices.AguardarConsultaRet = 0
    Configuracoes.WebServices.QuebradeLinha = '|'
    Configuracoes.RespTec.IdCSRT = 0
    Left = 256
    Top = 560
  end
  object UpCabNFE: TFDUpdateSQL
    Connection = DM.Conexao
    InsertSQL.Strings = (
      'INSERT INTO TESTE.dbo.importCABNFE'
      '(NroNFE, NatOperacao, Emissao, Status, Emi_Nome, '
      '  Emi_CNPJ, Emi_End, Emi_Bairro, Emi_Cidade, '
      '  Emi_UF, Dest_Nome, Dest_CNPJ, Dest_End, '
      '  Dest_Bairro, Dest_Cidade, Dest_UF)'
      
        'VALUES (:NEW_NroNFE, :NEW_NatOperacao, :NEW_Emissao, :NEW_Status' +
        ', :NEW_Emi_Nome, '
      
        '  :NEW_Emi_CNPJ, :NEW_Emi_End, :NEW_Emi_Bairro, :NEW_Emi_Cidade,' +
        ' '
      '  :NEW_Emi_UF, :NEW_Dest_Nome, :NEW_Dest_CNPJ, :NEW_Dest_End, '
      '  :NEW_Dest_Bairro, :NEW_Dest_Cidade, :NEW_Dest_UF)')
    ModifySQL.Strings = (
      'UPDATE TESTE.dbo.importCABNFE'
      
        'SET NroNFE = :NEW_NroNFE, NatOperacao = :NEW_NatOperacao, Emissa' +
        'o = :NEW_Emissao, '
      
        '  Status = :NEW_Status, Emi_Nome = :NEW_Emi_Nome, Emi_CNPJ = :NE' +
        'W_Emi_CNPJ, '
      
        '  Emi_End = :NEW_Emi_End, Emi_Bairro = :NEW_Emi_Bairro, Emi_Cida' +
        'de = :NEW_Emi_Cidade, '
      
        '  Emi_UF = :NEW_Emi_UF, Dest_Nome = :NEW_Dest_Nome, Dest_CNPJ = ' +
        ':NEW_Dest_CNPJ, '
      '  Dest_End = :NEW_Dest_End, Dest_Bairro = :NEW_Dest_Bairro, '
      '  Dest_Cidade = :NEW_Dest_Cidade, Dest_UF = :NEW_Dest_UF'
      'WHERE NroNFE = :OLD_NroNFE')
    DeleteSQL.Strings = (
      'DELETE FROM TESTE.dbo.importCABNFE'
      'WHERE NroNFE = :OLD_NroNFE')
    FetchRowSQL.Strings = (
      
        'SELECT NroNFE, NatOperacao, Emissao, Status, Emi_Nome, Emi_CNPJ,' +
        ' Emi_End, '
      
        '  Emi_Bairro, Emi_Cidade, Emi_UF, Dest_Nome, Dest_CNPJ, Dest_End' +
        ', '
      '  Dest_Bairro, Dest_Cidade, Dest_UF'
      'FROM TESTE.dbo.importCABNFE'
      'WHERE NroNFE = :NroNFE')
    Left = 184
    Top = 552
  end
  object UpItensNFE: TFDUpdateSQL
    Connection = DM.Conexao
    InsertSQL.Strings = (
      'INSERT INTO TESTE.dbo.ImportITENSNFE'
      '(NroNFE, Item, Barras, CodProd, DescProd, '
      '  CFOP_Prod, NCM_Prod, Unidade_Prod, ValUnit_Prod, '
      '  Quant_Prod, Desc_Prod, TotItens_Prod, ICMS_CST, '
      '  ICMS_CSOSN, ICMS_PER, ICMS_VAL, PIS_CST, '
      '  PIS_PER, PIS_VAL, COFINS_CST, COFINS_PER, '
      '  COFINS_VAL)'
      
        'VALUES (:NEW_NroNFE, :NEW_Item, :NEW_Barras, :NEW_CodProd, :NEW_' +
        'DescProd, '
      
        '  :NEW_CFOP_Prod, :NEW_NCM_Prod, :NEW_Unidade_Prod, :NEW_ValUnit' +
        '_Prod, '
      
        '  :NEW_Quant_Prod, :NEW_Desc_Prod, :NEW_TotItens_Prod, :NEW_ICMS' +
        '_CST, '
      '  :NEW_ICMS_CSOSN, :NEW_ICMS_PER, :NEW_ICMS_VAL, :NEW_PIS_CST, '
      '  :NEW_PIS_PER, :NEW_PIS_VAL, :NEW_COFINS_CST, :NEW_COFINS_PER, '
      '  :NEW_COFINS_VAL)')
    ModifySQL.Strings = (
      'UPDATE TESTE.dbo.ImportITENSNFE'
      
        'SET NroNFE = :NEW_NroNFE, Item = :NEW_Item, Barras = :NEW_Barras' +
        ', '
      
        '  CodProd = :NEW_CodProd, DescProd = :NEW_DescProd, CFOP_Prod = ' +
        ':NEW_CFOP_Prod, '
      '  NCM_Prod = :NEW_NCM_Prod, Unidade_Prod = :NEW_Unidade_Prod, '
      
        '  ValUnit_Prod = :NEW_ValUnit_Prod, Quant_Prod = :NEW_Quant_Prod' +
        ', '
      
        '  Desc_Prod = :NEW_Desc_Prod, TotItens_Prod = :NEW_TotItens_Prod' +
        ', '
      '  ICMS_CST = :NEW_ICMS_CST, ICMS_CSOSN = :NEW_ICMS_CSOSN, '
      
        '  ICMS_PER = :NEW_ICMS_PER, ICMS_VAL = :NEW_ICMS_VAL, PIS_CST = ' +
        ':NEW_PIS_CST, '
      
        '  PIS_PER = :NEW_PIS_PER, PIS_VAL = :NEW_PIS_VAL, COFINS_CST = :' +
        'NEW_COFINS_CST, '
      '  COFINS_PER = :NEW_COFINS_PER, COFINS_VAL = :NEW_COFINS_VAL'
      'WHERE NroNFE = :OLD_NroNFE AND Item = :OLD_Item')
    DeleteSQL.Strings = (
      'DELETE FROM TESTE.dbo.ImportITENSNFE'
      'WHERE NroNFE = :OLD_NroNFE AND Item = :OLD_Item')
    FetchRowSQL.Strings = (
      
        'SELECT NroNFE, Item, Barras, CodProd, DescProd, CFOP_Prod, NCM_P' +
        'rod, '
      
        '  Unidade_Prod, ValUnit_Prod, Quant_Prod, Desc_Prod, TotItens_Pr' +
        'od, '
      '  ICMS_CST, ICMS_CSOSN, ICMS_PER, ICMS_VAL, PIS_CST, PIS_PER, '
      '  PIS_VAL, COFINS_CST, COFINS_PER, COFINS_VAL'
      'FROM TESTE.dbo.ImportITENSNFE'
      'WHERE NroNFE = :NroNFE AND Item = :Item')
    Left = 176
    Top = 608
  end
  object OpenDialog: TOpenDialog
    Filter = 'xml'
    Title = 'Arquivos XML'
    Left = 256
    Top = 616
  end
  object tbcabnfe: TFDTable
    IndexFieldNames = 'NroNFE'
    Connection = DM.FDConnection1
    UpdateOptions.UpdateTableName = 'teste.dbo.ImportCABNFE'
    TableName = 'teste.dbo.ImportCABNFE'
    Left = 336
    Top = 568
    object tbcabnfeNroNFE: TIntegerField
      FieldName = 'NroNFE'
      Origin = 'NroNFE'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object tbcabnfeNatOperacao: TStringField
      FieldName = 'NatOperacao'
      Origin = 'NatOperacao'
      Size = 50
    end
    object tbcabnfeEmissao: TDateField
      FieldName = 'Emissao'
      Origin = 'Emissao'
    end
    object tbcabnfeStatus: TStringField
      FieldName = 'Status'
      Origin = 'Status'
      Size = 50
    end
    object tbcabnfeEmi_Nome: TStringField
      FieldName = 'Emi_Nome'
      Origin = 'Emi_Nome'
      Size = 50
    end
    object tbcabnfeEmi_CNPJ: TStringField
      FieldName = 'Emi_CNPJ'
      Origin = 'Emi_CNPJ'
      Size = 15
    end
    object tbcabnfeEmi_End: TStringField
      FieldName = 'Emi_End'
      Origin = 'Emi_End'
      Size = 50
    end
    object tbcabnfeEmi_Bairro: TStringField
      FieldName = 'Emi_Bairro'
      Origin = 'Emi_Bairro'
      Size = 50
    end
    object tbcabnfeEmi_Cidade: TStringField
      FieldName = 'Emi_Cidade'
      Origin = 'Emi_Cidade'
      Size = 50
    end
    object tbcabnfeEmi_UF: TStringField
      FieldName = 'Emi_UF'
      Origin = 'Emi_UF'
      Size = 2
    end
    object tbcabnfeDest_Nome: TStringField
      FieldName = 'Dest_Nome'
      Origin = 'Dest_Nome'
      Size = 50
    end
    object tbcabnfeDest_CNPJ: TStringField
      FieldName = 'Dest_CNPJ'
      Origin = 'Dest_CNPJ'
      Size = 15
    end
    object tbcabnfeDest_End: TStringField
      FieldName = 'Dest_End'
      Origin = 'Dest_End'
      Size = 50
    end
    object tbcabnfeDest_Bairro: TStringField
      FieldName = 'Dest_Bairro'
      Origin = 'Dest_Bairro'
      Size = 50
    end
    object tbcabnfeDest_Cidade: TStringField
      FieldName = 'Dest_Cidade'
      Origin = 'Dest_Cidade'
      Size = 50
    end
    object tbcabnfeDest_UF: TStringField
      FieldName = 'Dest_UF'
      Origin = 'Dest_UF'
      Size = 2
    end
  end
end
