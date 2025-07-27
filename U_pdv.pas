unit U_pdv;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.Mask, Vcl.DBCtrls, Vcl.Buttons, Data.DB,
  Datasnap.DBClient, Vcl.Imaging.pngimage, FireDAC.Stan.Intf,Math,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, ACBrNFe;

type
  TF_caixa = class(TForm)
    STB: TStatusBar;
    timer: TTimer;
    DBG_pdv: TDBGrid;
    P1: TPanel;
    P2: TPanel;
    P3: TPanel;
    Edit_quant: TEdit;
    Ecodigo: TEdit;
    L_Total: TLabel;
    L_tot: TLabel;
    Lcodigo: TLabel;
    Lquantidade: TLabel;
    Lconsulta: TLabel;
    Lfinaliza: TLabel;
    L_usu: TLabel;
    QryPdvMov: TFDQuery;
    Lsangria: TLabel;
    Lfechacaixa: TLabel;
    Lcancelaitem: TLabel;
    EditDesc: TEdit;
    EditItens: TEdit;
    Ldescproduto: TLabel;
    Lvalorproduto: TLabel;
    Ldescricao: TLabel;
    Litens: TLabel;
    Imagempdv: TImage;
    EditValor: TEdit;
    Qrycaixa: TFDQuery;
    QrycaixaCa_item: TIntegerField;
    QrycaixaCa_caixa: TStringField;
    QrySalvaNotas: TFDQuery;

    procedure EcodigoKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Edit_quantExit(Sender: TObject);
    procedure DBG_pdvDblClick(Sender: TObject);
    procedure Edit_quantKeyPress(Sender: TObject; var Key: Char);
    procedure SalvarNotaEmitida(NFeItem: TACBrNFe);
    procedure GerarXMLNFCe(nNF: Integer);
    function GetProximoNumeroNFCe(const ACNPJ: string): Integer;
    Function RetiraCaracteres(texto : string; caracteres:string) : string;
    function CalcularDV(const chave: string): Integer;
    function OnlyNumbers(const S: string): string;
    function GerarChaveAcesso(const cUF, AAMM, CNPJ, modelo, serie: string; nNF: Integer): string;

  private
    { Private declarations }
    Cupom,item : Integer;
    classifica,Lote,nf,estoque,unidade,ValorTot : String;
    unitario,custo : currency;
    procedure EtiquetaBal;
  public
    { Public declarations }
     usuario,Produto,NCM,ValorUnit,quantidade,Barras,Status :String;
     Ultvenda,Total : Currency;
     Id,Movid : Integer;
     procedure ValorTotal;
  end;

var
  F_caixa: TF_caixa;

implementation

{$R *.dfm}

uses U_dm, U_produto, U_login, U_consulta, U_formapagto, U_abrecaixa, U_entrada,
  U_usuarios, U_sangria, U_fechamentocaixa, U_cancelaItem, U_fechamentopdv,
  U_certificado;

function TF_caixa.CalcularDV(const chave: string): Integer;
const
  Pesos: array[0..8] of Integer = (2, 3, 4, 5, 6, 7, 8, 9, 2);
var
  Soma, Peso, i, j: Integer;
begin
  Soma := 0;
  j := 0;
  for i := Length(chave) downto 1 do
  begin
    Peso := Pesos[j];
    Inc(Soma, StrToInt(chave[i]) * Peso);
    Inc(j);
    if j > High(Pesos) then
      j := 0;
  end;
  Result := 11 - (Soma mod 11);
  if Result >= 10 then
    Result := 0;
end;
procedure TF_caixa.DBG_pdvDblClick(Sender: TObject);
begin
 F_cancelaItem := TF_cancelaItem.Create(Self);
 F_cancelaItem.Showmodal;
 F_cancelaItem.Free;
end;

procedure TF_caixa.EcodigoKeyPress(Sender: TObject; var Key: Char);
Var
S : string;
Q : Integer;
begin
  Ecodigo.SetFocus;
  if Key = #13 then
  Begin
 //   Msgpanel.Caption := '';
    if Ecodigo.Text='' then
    Begin
      Messagedlg('Atenção!!! Campo de Preenchimento Obrigatorio',mtInformation,[mbOk],0);
      exit;
    End;
    EtiquetaBal;
    with dm.Qrymovimentacao do
    Begin
      close;
      SQL.Clear;
      SQL.Add('exec BuscaPoduto' +' '+ QuotedStr(Ecodigo.Text));
      Open;
      if RecordCount = 0 then
      Begin
       Messagedlg('Atenção!!! Produto não Encontrado',mtInformation,[mbOk],0);
       Ecodigo.Text := '';
       exit;
      End;
      Movid     := Dm.Qrymovimentacao.FieldByName('Mov_id').AsInteger;
      NCM       := Dm.Qryproduto.FieldByName('Prod_ncm').AsString;
      With QryPdvMov do
      Begin
        Close;
        SQL.Clear;
        SQL.Add('exec Somaqtd' +' '+ QuotedStr(Ecodigo.Text)+' '+','+ InttoStr(Movid));
        open;
      End;
      Ultvenda := QryPdvMov.FieldByName('Mov_ultvenda').AsCurrency;
      if (Ultvenda >= Dm.QrymovimentacaoMov_quantidade.Value) then
      Begin
       S := 'S';
       Q := 0;
       Close;
       SQL.Clear;
       SQL.Add('UPDATE Movimentacao SET Mov_status = :S, Mov_quantidade = :vQ, Mov_ultvenda = :vultvenda where Mov_id = :Movid');
       ParamByName('vultvenda').ascurrency := Ultvenda;
       ParamByName('S').AsString := S;
       ParamByName('vQ').AsInteger := Q;
       ParamByName('Movid').AsInteger := Movid;
       dm.Qrymovimentacao.ExecSQL;
       exit;
      End;
      Produto            := Dm.Qrymovimentacao.FieldByName('Mov_produto').AsString;
      Classifica         := Dm.Qrymovimentacao.FieldByName('Prod_classificacao').AsString;
      Barras             := Dm.Qrymovimentacao.FieldByName('Mov_Barras').AsString;
      Id                 := Dm.Qrymovimentacao.FieldByName('Prod_id').AsInteger;
      custo              := Dm.Qrymovimentacao.FieldByName('Mov_custo').AsCurrency;
      nf                 := Dm.Qrymovimentacao.FieldByName('Mov_nf').AsString;
      lote               := Dm.Qrymovimentacao.FieldByName('Mov_lote').AsString;
      ValorUnit          := Dm.Qrymovimentacao.FieldByName('Mov_Venda').AsString;
      unidade            := Dm.Qrymovimentacao.FieldByName('Prod_unidade').AsString;
      Status             := Dm.Qrymovimentacao.FieldByName('Mov_status').AsString;
      unitario           := strtofloat(ValorUnit);
      Editdesc.Text      := Produto;
      EditValor.Text     := FormatFloat('#,0.00',unitario);
      if (classifica <> '01') then
      Begin
         MessageBox(0,'Produto não Disponivel para Venda','Aviso',0+MB_ICONWARNING+8192);
         exit;
      End;
      estoque := Dm.Qryproduto.FieldByName('Prod_minimo').AsString;
      if (estoque = '0') then
      Begin
        MessageBox(0,'Produto não Disponivel no Estoque','Aviso',0+MB_ICONWARNING+8192);
        exit;
      End;
    End;
    Quantidade := Edit_quant.Text;
    ValorTot := floattostr(StrtoFloat(ValorUnit)*StrtoFloat(Quantidade));
    With Qrycaixa do
    Begin
     Close;
     SQl.Clear;
     SQL.Add('Select count(Ca_item)as ca_item, Ca_caixa from Caixa where Ca_caixa = :vCaixa Group by Ca_caixa');
     ParamByName('vCaixa').AsString :=  F_abrecaixa.Combocaixa.Text;
     Open;
     item := Qrycaixa.FieldByName('Ca_item').AsInteger + 1;
    End;

    With dm.Qrycaixa do
    Begin
     Close;
     SQL.Clear;
     Sql.Add('Insert into caixa (Ca_item,Ca_Desc,Ca_Quant,Ca_PrecUnit,Ca_PrecTotal,Ca_DtVenda,Ca_Usuario,Ca_Unidade,');
     Sql.Add('Ca_caixa,Ca_Prod_id,Ca_Barras,Ca_status,Ca_custo,Ca_nf,Ca_lote, Ca_usnome,Ca_codCupom)');
     Sql.Add('VALUES (:item,:Produto,:quantidade,:ValorUnit,:ValorTot,:data,:usu,:unidade,:caixa,:id,:Barras,:status,:custo,:nf,:lote, :usnome, :Cupom)');
     ParamByName('item').Asinteger := item;
     ParamByName('produto').AsString := Produto;
     ParamByName('quantidade').AsFloat := StrtoFloat(quantidade);
     ParamByName('ValorUnit').AsFloat := StrtoFloat(ValorUnit);
     ParamByName('ValorTot').AsFloat := StrtoFloat(ValorTot);
     ParamByName('data').AsDateTime := Now();
     ParamByName('usu').AsString := F_login.usuario;
     ParamByName('unidade').AsString := unidade;
     ParamByName('caixa').AsString := F_abrecaixa.Combocaixa.Text;
     ParamByName('id').AsInteger := id;
     ParamByName('Barras').AsString := Barras;
     ParamByName('status').AsString := 'S';
     ParamByName('custo').AsFloat := custo;
     ParamByName('nf').AsString := nf;
     ParamByName('lote').AsString := lote;
     ParamByName('usnome').AsString := F_login.usuario;
     ParamByName('cupom').AsInteger := Cupom;
     dm.Qrycaixa.ExecSQL;
     dm.ds_caixa.DataSet.Open;
     DBG_pdv.DataSource.DataSet.Refresh;
     ValorTotal;
    End;
    dm.ds_caixa.DataSet.Open;
    dm.ds_caixa.DataSet.Refresh;
    DBG_pdv.DataSource.DataSet.Refresh;
    if Edit_quant.Text='' then
       MessageBox(0,'Informe aquantidade ','Aviso',0+MB_ICONWARNING+8192)
     Else
       Perform(Wm_NextDlgCtl,0,0);
       Edit_quant.Text := '1';
       Ecodigo.Text    := '';
       Ecodigo.SetFocus;
  End;

end;

procedure TF_caixa.Edit_quantExit(Sender: TObject);
begin
Edit_quant.Text := formatfloat('#,0.000',StrToFloat(StringReplace(Edit_quant.Text, '.', '', [rfReplaceAll])));
end;

procedure TF_caixa.Edit_quantKeyPress(Sender: TObject; var Key: Char);
begin
if Key = #13 then
  Begin
   Perform(Wm_NextDlgCtl,0,0);
   Ecodigo.Text := '';
   Ecodigo.SetFocus;
  End;
end;

procedure TF_caixa.EtiquetaBal;
Var
nPESO,nVALOR,vVUNIT: Real;
nPROD : String;
begin
  nPESO := 0;
  nVALOR := 0;
  if Length(Ecodigo.Text) = 13 then
     Begin
       if Copy(ecodigo.Text, 1,1) = '2' then
          Begin
            //Etiqueta com valor
            nVALOR := StrtoFloat(copy(ecodigo.Text, 8,5));
            Ecodigo.Text := copy(ecodigo.Text, 2,6);
          End
       else if Copy(ecodigo.Text, 1,2) = '31' then
          Begin
            // Etiqueta com peso
            nPESO := StrtoFloat(copy(Ecodigo.Text, 8,5))/1000;
            Ecodigo.Text := copy(Ecodigo.Text, 3,5);
          End;

          with dm.Qrymovimentacao do
          Begin
           close;
           SQL.Clear;
           SQL.Add('exec BuscaPoduto' +' '+ QuotedStr(Ecodigo.Text));
           Open;
           if RecordCount = 0 then
           Begin
             Messagedlg('Atenção!!! Produto não Encontrado',mtInformation,[mbOk],0);
             Ecodigo.Text := '';
             exit;
           End;
           nPROD  := Dm.Qrymovimentacao.FieldByName('Prod_desc_Prod').AsString;
           vVUNIT := Dm.Qrymovimentacao.FieldByName('Mov_venda').AsFloat;
          End;
          if nVALOR > 0 then
           Begin
            nVALOR := (nVALOR/vVUNIT)/100;
            Edit_quant.Text := FloattoStr(nVALOR);
           End;
     End;
end;



procedure TF_caixa.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
      if key = VK_F3 then
      Begin
         F_consulta := TF_consulta.Create(Self);
         F_consulta.Showmodal;
         F_consulta.Free;
      End;
      if key = VK_F2 then
      Begin
         item := 0;
         with Dm.Qrycaixaf do
         Begin
           Close;
           SQL.Clear;
           SQL.Add('Select * from CaixaFechado order by Cxf_cupom desc');
           open;
           cupom := fieldByName('cxf_cupom').AsInteger;
           Cupom := cupom + 1;
         End;
         F_finaliza := TF_finaliza.Create(Self);
         F_finaliza.Showmodal;
         F_finaliza.Free;
      End;
      if key = VK_F4 then
      Begin
         F_sangria := TF_sangria.Create(Self);
         F_sangria.Showmodal;
         F_sangria.Free;
      End;
      if key = VK_F5 then
      Begin
         F_fechamentocaixa := TF_fechamentocaixa.Create(Self);
         F_fechamentocaixa.Showmodal;
         F_fechamentocaixa.Free;
      End;
      if key = VK_F6 then
      Begin
         F_cancelaItem := TF_cancelaItem.Create(Self);
         F_cancelaItem.Showmodal;
         F_cancelaItem.Free;
      End;
end;

procedure TF_caixa.FormShow(Sender: TObject);
begin
     dm.Qrycaixa.Close;
     dm.Qrycaixa.SQL.Clear;
     dm.Qrycaixa.SQL.Add('SELECT * FROM caixa WHERE Ca_caixa = :nome');
     dm.Qrycaixa.ParamByName('nome').Value := F_abrecaixa.Combocaixa.Text;
     with Dm.Qrycaixaf do
     Begin
       Close;
       SQL.Clear;
       SQL.Add('Select * from CaixaFechado order by Cxf_cupom desc');
       open;
       cupom := fieldByName('cxf_cupom').AsInteger;
       Cupom := cupom + 1;
     End;
     dm.Qrycaixa.open;
     dm.ds_caixa.DataSet.Filtered := False;
     dm.ds_caixa.DataSet.Filter := ' UPPER(Ca_caixa) like ' +
     UpperCase(QuotedStr('%' + F_abrecaixa.Combocaixa.Text + '%'));
     dm.ds_caixa.DataSet.Filtered := True;
     dm.Qrycaixa.First;
     Ecodigo.SetFocus;
     STB.Panels.Items[0].Text := 'Operador:' + ' ' + F_login.usuario;
     STB.Panels.Items[1].Text := 'Caixa:' + ' ' + F_abrecaixa.Combocaixa.Text;
     STB.Panels.Items[2].Text := 'Loja:' + ' ' + '0000120';
     STB.Panels.Items[3].Text := 'Data:' + ' ' + datetostr(Now);
     STB.Panels.Items[4].Text := 'Hora:' + ' ' + timetostr(Now);
     Dm.Qrycaixa.Open;
     Imagempdv.Picture.LoadFromFile(Dm.TB_empresaImagem.Value);
end;

function TF_caixa.GerarChaveAcesso(const cUF, AAMM, CNPJ, modelo, serie: string;
  nNF: Integer): string;
var
  cNF: string;
  chaveSemDV, dv: string;
begin
  Randomize;
  // Gerar código numérico (cNF) aleatório com 8 dígitos
  cNF := FormatFloat('00000000', RandomRange(10000000, 99999999));

  // Monta os 43 dígitos da chave (sem o dígito verificador)
  chaveSemDV :=
    '35' +                                 // 2 dígitos (ex: '35')
    AAMM +                                // 4 dígitos (ex: '2507')
    RetiraCaracteres(CNPJ, '.-/ ') +      // 14 dígitos
    modelo +                              // 2 dígitos ('65')
    serie +                               // 3 dígitos ('001')
    FormatFloat('000000000', nNF) +       // 9 dígitos
    cNF;                                  // 8 dígitos

  // Calcula o dígito verificador (DV) com base nos 43 dígitos numéricos
  dv := IntToStr(CalcularDV(chaveSemDV));

  // Retorna a chave final com o prefixo 'NFe'
  Result := 'NFe' + chaveSemDV + dv;
end;

procedure TF_caixa.GerarXMLNFCe(nNF: Integer);
var
  XML: TStringList;
  CaminhoXML, IdNFe, DataHoraAtual, cProd, xProd, NCM, CST_ICMS, CST_PIS, CST_COFINS, CST_IPI: string;
  vTotal, vUnit, qItem, vItem: Double;
  i, codPag: Integer;
  CNPJLimpo, CNPJ, RazaoSocial, Endereco, Numero, Bairro, Cidade, UF, CEP, IE: string;
  cMun: string;
  vPag, vTroco: Double;
  cNF: string;
begin
  XML := TStringList.Create;
  try
    ForceDirectories('C:\NFCe\Geradas');

    if not DM.TB_Empresa.Active then
      DM.TB_Empresa.Open;
    DM.TB_Empresa.First;

    CNPJ := DM.TB_Empresa.FieldByName('CNPJ').AsString;
    RazaoSocial := DM.TB_Empresa.FieldByName('RazaoSocial').AsString;
    Endereco := DM.TB_Empresa.FieldByName('Endereco').AsString;
    Numero := DM.TB_Empresa.FieldByName('Numero').AsString;
    Bairro := DM.TB_Empresa.FieldByName('Bairro').AsString;
    Cidade := DM.TB_Empresa.FieldByName('Cidade').AsString;
    UF := DM.TB_Empresa.FieldByName('UF').AsString;
    CEP := DM.TB_Empresa.FieldByName('Cep').AsString;
    IE := DM.TB_Empresa.FieldByName('IncrEstadual').AsString;
    cMun := '3550308'; // fixo por enquanto
    CNPJ := RetiraCaracteres(CNPJ, '.-/ ');
    IdNFe := GerarChaveAcesso(
      Copy(UF, 1, 2),               // Código UF (ex: '35')
      FormatDateTime('yyMM', Now),  // Ano e mês atual
      CNPJ,                        // CNPJ da empresa (somente números)
      '65',                        // Modelo NFC-e
      '001',                       // Série (3 dígitos)
      nNF                          // Número da NF (inteiro)
    );
    cNF := Copy(IdNFe, 39, 8); // pega o cNF gerado aleatório dentro da chave (posição 39 a 46)

    CaminhoXML := 'C:\NFCe\Geradas\' + IdNFe + '.xml';
    DataHoraAtual := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss-03:00', Now);
    codPag := 01;
    case F_finaliza.CBBforma.ItemIndex of
      0: codPag := 01; // Dinheiro
      1: codPag := 02; // Débito
      2: codPag := 03; // Crédito
      3: codPag := 17; // Pix
    end;

    vPag := StrToFloatDef(StringReplace(F_finaliza.Epago.Text, ',', '.', [rfReplaceAll]), 0);
    vTroco := StrToFloatDef(StringReplace(F_finaliza.Etroco.Text, ',', '.', [rfReplaceAll]), 0);

    XML.Add('<?xml version="1.0" encoding="UTF-8"?>');
    XML.Add('<NFe xmlns="http://www.portalfiscal.inf.br/nfe">');
    XML.Add('  <infNFe versao="4.00" Id="' + IdNFe + '">');
    XML.Add('    <ide>');
    XML.Add('      <cUF>35</cUF>');
    XML.Add('      <cNF>' + cNF + '</cNF>');
    XML.Add('      <natOp>VENDA AO CONSUMIDOR</natOp>');
    XML.Add('      <mod>65</mod>');
    XML.Add('      <serie>1</serie>');
    XML.Add('      <nNF>' + IntToStr(nNF) + '</nNF>');
    XML.Add('      <dhEmi>' + DataHoraAtual + '</dhEmi>');
    XML.Add('      <tpNF>1</tpNF>');
    XML.Add('      <idDest>1</idDest>');
    XML.Add('      <cMunFG>' + cMun + '</cMunFG>');
    XML.Add('      <tpImp>4</tpImp>');
    XML.Add('      <tpEmis>1</tpEmis>');
    XML.Add('      <cDV>' + IdNFe[44] + '</cDV>'); // DV da chave no último dígito
    XML.Add('      <tpAmb>2</tpAmb>');
    XML.Add('      <finNFe>1</finNFe>');
    XML.Add('      <indFinal>1</indFinal>');
    XML.Add('      <indPres>1</indPres>');
    XML.Add('      <procEmi>0</procEmi>');
    XML.Add('      <verProc>PDV-Delphi</verProc>');
    XML.Add('    </ide>');

    XML.Add('    <emit>');
    XML.Add('      <CNPJ>' + CNPJ + '</CNPJ>');
    XML.Add('      <xNome>' + RazaoSocial + '</xNome>');
    XML.Add('      <enderEmit>');
    XML.Add('        <xLgr>' + Endereco + '</xLgr>');
    XML.Add('        <nro>' + Numero + '</nro>');
    XML.Add('        <xBairro>' + Bairro + '</xBairro>');
    XML.Add('        <cMun>' + cMun + '</cMun>');
    XML.Add('        <xMun>' + Cidade + '</xMun>');
    XML.Add('        <UF>' + UF + '</UF>');
    XML.Add('        <CEP>' + CEP + '</CEP>');
    XML.Add('        <cPais>1058</cPais>');
    XML.Add('        <xPais>Brasil</xPais>');
    XML.Add('      </enderEmit>');
    XML.Add('      <IE>' + IE + '</IE>');
    XML.Add('      <CRT>1</CRT>');
    XML.Add('    </emit>');

    DM.QryCaixa.First;
    i := 1;
    vTotal := 0;
    while not DM.QryCaixa.Eof do
    begin
      cProd := DM.QryCaixa.FieldByName('Ca_barras').AsString;
      xProd := DM.QryCaixa.FieldByName('Ca_desc').AsString;
      qItem := DM.QryCaixa.FieldByName('Ca_Quant').AsFloat;
      vUnit := DM.QryCaixa.FieldByName('Ca_PrecUnit').AsFloat;
      vItem := DM.QryCaixa.FieldByName('Ca_PrecTotal').AsFloat;
      vTotal := vTotal + vItem;

      if DM.QryProduto.Locate('Prod_cod_barras', cProd, []) then
      begin
        NCM := DM.QryProduto.FieldByName('Prod_ncm').AsString;
        CST_ICMS := DM.QryProduto.FieldByName('Prod_cst_icmsd').AsString;
        CST_PIS := DM.QryProduto.FieldByName('Prod_cst_pisd').AsString;
        CST_COFINS := DM.QryProduto.FieldByName('Prod_cst_cofinsd').AsString;
        CST_IPI := DM.QryProduto.FieldByName('Prod_cst_ipid').AsString;
      end else
      begin
        NCM := '00000000';
        CST_ICMS := '101';
        CST_PIS := '07';
        CST_COFINS := '07';
        CST_IPI := '52';
      end;

      XML.Add('    <det nItem="' + IntToStr(i) + '">');
      XML.Add('      <prod>');
      XML.Add('        <cProd>' + cProd + '</cProd>');
      XML.Add('        <xProd>' + xProd + '</xProd>');
      XML.Add('        <NCM>' + NCM + '</NCM>');
      XML.Add('        <CFOP>5102</CFOP>');
      XML.Add('        <uCom>UN</uCom>');
      XML.Add('        <qCom>' + FormatFloat('0.0000', qItem) + '</qCom>');
      XML.Add('        <vUnCom>' + FormatFloat('0.00', vUnit) + '</vUnCom>');
      XML.Add('        <vProd>' + FormatFloat('0.00', vItem) + '</vProd>');
      XML.Add('        <uTrib>UN</uTrib>');
      XML.Add('        <qTrib>' + FormatFloat('0.0000', qItem) + '</qTrib>');
      XML.Add('        <vUnTrib>' + FormatFloat('0.00', vUnit) + '</vUnTrib>');
      XML.Add('        <indTot>1</indTot>');
      XML.Add('      </prod>');
      XML.Add('      <imposto>');
      XML.Add('        <ICMS>');
      XML.Add('          <ICMSSN101>');
      XML.Add('            <orig>0</orig>');
      XML.Add('            <CSOSN>' + CST_ICMS + '</CSOSN>');
      XML.Add('            <pCredSN>0.00</pCredSN>');
      XML.Add('            <vCredICMSSN>0.00</vCredICMSSN>');
      XML.Add('          </ICMSSN101>');
      XML.Add('        </ICMS>');
      XML.Add('        <PIS><PISNT><CST>' + CST_PIS + '</CST></PISNT></PIS>');
      XML.Add('        <COFINS><COFINSNT><CST>' + CST_COFINS + '</CST></COFINSNT></COFINS>');
      XML.Add('        <IPI><IPINT><CST>' + CST_IPI + '</CST></IPINT></IPI>');
      XML.Add('      </imposto>');
      XML.Add('    </det>');

      Inc(i);
      DM.QryCaixa.Next;
    end;

    XML.Add('    <total>');
    XML.Add('      <ICMSTot>');
    XML.Add('        <vProd>' + FormatFloat('0.00', vTotal) + '</vProd>');
    XML.Add('        <vNF>' + FormatFloat('0.00', vTotal) + '</vNF>');
    XML.Add('        <vBC>0.00</vBC><vICMS>0.00</vICMS><vICMSDeson>0.00</vICMSDeson>');
    XML.Add('        <vFCP>0.00</vFCP><vBCST>0.00</vBCST><vST>0.00</vST><vFCPST>0.00</vFCPST>');
    XML.Add('        <vFCPSTRet>0.00</vFCPSTRet><vFrete>0.00</vFrete><vSeg>0.00</vSeg>');
    XML.Add('        <vDesc>0.00</vDesc><vII>0.00</vII><vIPI>0.00</vIPI><vIPIDevol>0.00</vIPIDevol>');
    XML.Add('        <vPIS>0.00</vPIS><vCOFINS>0.00</vCOFINS><vOutro>0.00</vOutro>');
    XML.Add('      </ICMSTot>');
    XML.Add('    </total>');

    XML.Add('    <pag>');
    XML.Add('      <detPag>');
    XML.Add('        <tPag>' + IntToStr(codPag) + '</tPag>');
    XML.Add('        <vPag>' + FormatFloat('0.00', vPag) + '</vPag>');
    XML.Add('      </detPag>');
    XML.Add('      <vTroco>' + FormatFloat('0.00', vTroco) + '</vTroco>');
    XML.Add('    </pag>');

    XML.Add('    <infAdic><infCpl>Documento sem valor fiscal - homologação</infCpl></infAdic>');
    XML.Add('  </infNFe>');
    XML.Add('</NFe>');

    XML.SaveToFile(CaminhoXML);
    ShowMessage('XML gerado com sucesso: ' + CaminhoXML);
  finally
    XML.Free;
  end;
end;



function TF_caixa.GetProximoNumeroNFCe(const ACNPJ: string): Integer;
var
  FDQuery: TFDQuery;
begin
  Result := 1;
  try
    QrySalvaNotas.SQL.Text :=
      'SELECT MAX(numero_nfe) AS UltimoNumero ' +
      'FROM nfe_emitidas ' +
      'WHERE cnpj_emitente = :cnpj AND tipo = ''NFC-e''';
    QrySalvaNotas.ParamByName('cnpj').AsString := ACNPJ;
    QrySalvaNotas.Open;

    if not QrySalvaNotas.FieldByName('UltimoNumero').IsNull then
      Result := QrySalvaNotas.FieldByName('UltimoNumero').AsInteger + 1;
  finally
    QrySalvaNotas.Free;
  end;
end;


function TF_caixa.OnlyNumbers(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if CharInSet(S[i], ['0'..'9']) then
      Result := Result + S[i];
end;

function TF_caixa.RetiraCaracteres(texto, caracteres: string): string;
Var
 novoTexto : string;
 x: integer;
begin
  novotexto := '';
  for x := 1 to Length(texto) do
  begin
    if pos(texto[x], caracteres) <= 0 then
    begin
      Novotexto := Novotexto + texto[x];
    end;
  end;
  result := Novotexto;
end;

procedure TF_caixa.SalvarNotaEmitida(NFeItem: TACBrNFe);
begin
  With QrySalvaNotas do
  Begin
    try
      Close;
      SQL.Clear;
      SQL.Text :=
        'INSERT INTO nfe_emitidas (numero_nfe, serie, modelo, tipo, data_emissao, chave_nfe, xml_nfe, cnpj_emitente, valor_total, status_envio) ' +
        'VALUES (:numero, :serie, :modelo, :tipo, :data, :chave, :xml, :cnpj, :valor, :status)';
      ParamByName('numero').AsInteger := Dm.ACBrNFe.NotasFiscais.Add.NFe.ide.nNF;
      ParamByName('serie').AsInteger  := Dm.ACBrNFe.NotasFiscais.Add.NFe.ide.serie;
      ParamByName('modelo').AsString  := FormatFloat('00', Dm.ACBrNFe.NotasFiscais.Add.NFe.ide.modelo);
      ParamByName('tipo').AsString    := 'NFC-e';
      ParamByName('data').AsDateTime  := Now;
      ParamByName('chave').AsString   := Copy(Dm.ACBrNFe.NotasFiscais.Add.NFe.InfNFe.Id, 4, 44); // Remove "NFe"
      ParamByName('xml').AsString     := Dm.ACBrNFe.NotasFiscais.Items[0].XML;
      ParamByName('cnpj').AsString    := RetiraCaracteres(Dm.ACBrNFe.NotasFiscais.Add.NFe.emit.CNPJCPF,'.-/\');
      ParamByName('valor').AsFloat    := Dm.ACBrNFe.NotasFiscais.Add.NFe.Total.ICMSTot.vNF;
      ParamByName('status').AsString  := Dm.ACBrNFe.WebServices.Retorno.xMotivo;
      QrySalvaNotas.ExecSQL;
    finally
      QrySalvaNotas.Free;
    end;
  end;
end;


procedure TF_caixa.ValorTotal;
begin
     Total := 0;
     EditItens.Text := INttoStr(item);
     dm.Qrycaixa.close;
     dm.Qrycaixa.SQL.Clear;
     dm.Qrycaixa.SQL.Add('SELECT * FROM caixa WHERE Ca_caixa = :nome order by Ca_item asc');
     dm.Qrycaixa.ParamByName('nome').Value := F_abrecaixa.Combocaixa.Text;
     dm.Qrycaixa.open;
     dm.ds_caixa.DataSet.Filtered := False;
     dm.ds_caixa.DataSet.Filter := ' UPPER(Ca_caixa) like ' +
     UpperCase(QuotedStr('%' + F_abrecaixa.Combocaixa.Text + '%'));
     dm.ds_caixa.DataSet.Filtered := True;
     dm.Qrycaixa.First;
     while not dm.Qrycaixa.Eof  do begin
        Total := Total + dm.Qrycaixa.FieldByName('Ca_PrecTotal').AsCurrency;
        dm.Qrycaixa.Next;
     end;
     Total := Total;
     L_total.Caption := 'R$' + ' ' + FormatFloat('#,0.00',Total);
end;

end.
function TF_caixa.RetiraCaracteres(texto, caracteres: string): string;
begin

end;

procedure TF_caixa.SalvarNotaEmitida(NFeItem: TACBrNFe);
begin

end;

procedure TF_caixa.ValorTotal;
begin

end;


