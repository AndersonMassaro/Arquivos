unit U_formapagto;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.ComCtrls, frxClass, frxDBSet, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, ACBrBase, ACBrDFeReport,
  ACBrDFeDANFeReport, ACBrNFeDANFEClass, ACBrNFCeDANFeFPDF, ACBrDFe, ACBrNFe,
  ACBrUtil, pcnconversao, pcnconversaoNFE, ACBrNFeDANFEFR;



type
  TF_finaliza = class(TForm)
    Panel: TPanel;
    Lvalor: TLabel;
    Lpago: TLabel;
    Ltroco: TLabel;
    Epago: TEdit;
    Etroco: TEdit;
    Lformapagto: TLabel;
    CBBforma: TComboBox;
    Lvalor1: TLabel;
    BtnFinalizar: TBitBtn;
    StatusBar1: TStatusBar;
    BitBtn1: TBitBtn;
    frxCupomVendaPDV: TfrxReport;
    frxCaixa: TfrxDBDataset;
    Qrycaixa: TFDQuery;
    Qrymv: TFDQuery;
    frxEmpresa: TfrxDBDataset;
    ACBrNFCe: TACBrNFe;
    nfce: TACBrNFe;
    Qryprodutos: TFDQuery;
    ACBrNFeDANFEFR1: TACBrNFeDANFEFR;
    nfe: TACBrNFe;
    procedure CBBformaChange(Sender: TObject);
    procedure EpagoKeyPress(Sender: TObject; var Key: Char);
    procedure BtnFinalizarClick(Sender: TObject);
    procedure imprime;
    procedure EmitirCupomFiscal;
    Function RetiraCaracteres(texto : string; caracteres:string) : string;
  private
    { Private declarations }
    Soma, Troco, Ultqtd, QtdSaida, Qtdnv   : Currency;
    idmv    : Integer;
    addRow : Boolean;
    Aserie : String;
    Procedure IniciarNFCE;
    Procedure GeraNFCe();
  public
    { Public declarations }
    Total : Currency;
    Ultvenda : Currency;
  end;

var
  F_finaliza: TF_finaliza;
    ACBrNFCe: TACBrNFe;

implementation

{$R *.dfm}

uses U_pdv, U_dm, U_abrecaixa, U_empresa, U_certificado;


procedure TF_finaliza.BtnFinalizarClick(Sender: TObject);
begin
 if ( MessageDlg ('Confirma a Finalização das compras?', mtCustom,mbYesNo, 0) = mrYes) then
 if (Epago.Text = '') then
    MessageBox(0,'Informar o Valor a ser Pago','Aviso',0+MB_ICONWARNING+8192);
// Salvar informações na tabela de movimentação
 With dm.Qrymovimentacao do
 Begin
    Close;
    SQL.Clear;
    Sql.Add('Insert into movimentacao (Mov_prod_id,Mov_barras,Mov_produto,Mov_quantidade,mov_custo, Mov_Venda,Mov_dtvenda,Mov_status,Mov_nf,Mov_lote,Mov_ultvenda)');
    Sql.Add('select Ca_prod_id,Ca_barras,Ca_Desc,Ca_Quant,Ca_custo, Ca_PrecUnit,Ca_dtVenda,Ca_status,Ca_nf,Ca_lote,Ca_Quant from Caixa');
    SQL.Add('where Ca_caixa = :caixa');
    ParamByName('caixa').Value := F_abrecaixa.Combocaixa.Text;
    dm.Qrymovimentacao.ExecSQL;
 End;
 // Salva informações na Tabela Caixa
    With dm.Qrycaixaf do
    Begin
     Close;
     SQL.Clear;
     SQL.Add('Insert into caixafechado (Cxf_vlunitario,Cxf_vltotal,Cxf_dtvenda,Cxf_usuario,Cxf_caixa,Cxf_prodid,');
     SQL.Add('Cxf_barras,Cxf_quant,Cxf_fpagto, Cxf_unidade,Cxf_custo,Cxf_lote,Cxf_nf, Cxf_Cupom)');
     SQL.Add('select Ca_PrecUnit,Ca_PrecTotal,Ca_dtVenda,Ca_Usuario,Ca_caixa,Ca_Prod_id,Ca_barras,Ca_Quant, :fpagto,Ca_unidade,Ca_custo,Ca_lote,Ca_nf,Ca_codCupom from Caixa ');
     SQL.Add('where Ca_caixa = :Pnome');
     ParamByName('Pnome').Value := F_abrecaixa.Combocaixa.Text;
     ParamByName('fpagto').Value := CBBforma.ItemIndex;
     dm.Qrycaixaf.ExecSQL;
    End;
    With Qrycaixa do
    Begin
      Close;
      SQL.Clear;
      SQL.Add('exec SomaqtdSaida' +' '+ QuotedStr(f_caixa.Barras)+' '+','+ QuotedStr(F_abrecaixa.Combocaixa.Text));
      open;
    End;
    idmv := F_caixa.Movid;
    QtdSaida := Qrycaixa.FieldByName('Ca_Quant').AsCurrency;
    Qtdnv := F_caixa.Ultvenda + Qtdsaida;
    // Altera ultima quantidade na tabela de movimentação
    With Qrymv do
    Begin
      Close;
      Sql.Clear;
      Sql.Add('update Movimentacao set Mov_ultvenda = :Qtdnv where Mov_id = :idmv');
      ParamByName('Qtdnv').Value := Qtdnv;
      ParamByName('idmv').Value  := idmv;
      Qrymv.ExecSQL;
    End;

    if MessageDlg('Deseja Imprimir o Recibo?', mtConfirmation,[mbYes, mbNo], 0) = mrYes then
    begin
        imprime();
//      IniciarNFCE;
//      EmitirCupomFiscal;

    end;
    With dm.Qrycaixa do
    Begin
      Close;
      SQL.Clear;
      Sql.Add('delete from caixa');
      SQL.Add('where Ca_caixa = :caixa');
      ParamByName('caixa').Value := F_abrecaixa.Combocaixa.Text;
      dm.Qrycaixa.ExecSQL;
      dm.ds_caixa.DataSet.Open;
      dm.ds_caixa.DataSet.Refresh;
      F_caixa.DBG_pdv.DataSource.DataSet.Refresh;
      F_finaliza.Close;
      F_caixa.L_Total.Caption := '';
      F_caixa.Ldescricao.Caption := '';
      F_caixa.Lvalor.Caption := '';
    End;
end;

procedure TF_finaliza.CBBformaChange(Sender: TObject);
begin
   Total := F_caixa.Total;
   if (CBBforma.ItemIndex = 0)  then  //Opção dinheiro
   Begin
      lvalor1.Caption := '';
      Epago.Text := '';
      Epago.Enabled := True;
      Lvalor1.Visible := True;
      Epago.SetFocus;
      Lvalor1.Caption := 'R$' + ' ' + FormatFloat('#,##,0.00',Total);
//      Epago.Text := FloatToStrF(StrToFloat(Epago.Text),ffFixed, 15, 2);
   End
   else if (CBBforma.ItemIndex = 1)  then  // Opção Cartão débito
   Begin
      Lvalor1.Visible := True;
      Epago.Enabled := False;
      Lvalor1.Caption := 'R$' + ' ' + FormatFloat('#,##,0.00',Total);
      Epago.Text := Lvalor1.Caption;
      Etroco.Text := '0,00';
   End
   else if (CBBforma.ItemIndex = 2)  then  // Opção Cartão Crédito
   Begin
      Lvalor1.Visible := True;
      Epago.Enabled := False;
      Lvalor1.Caption := 'R$' + ' ' + FormatFloat('#,##,0.00',Total);
      Epago.Text := Lvalor1.Caption;
      Etroco.Text := '0,00';
   End
   else if (CBBforma.ItemIndex = 3)  then   //Opção Pix
   Begin
      Lvalor1.Visible := True;
      Epago.Enabled := False;
      Lvalor1.Caption := 'R$' + ' ' + FormatFloat('#,##,0.00',Total);
      Epago.Text := Lvalor1.Caption;
      Etroco.Text := '0,00';
   End;
end;

procedure TF_finaliza.EpagoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Begin
    if Epago.Text = '' then
      Begin
       Messagedlg('Atenção!!! Informar o Valor em Dinheiro ',mtInformation,[mbOk],0);
       exit;
      End;
      if (strtofloat(Epago.Text) < Total) then
        Begin
          Messagedlg('Atenção!!! Valor Pago não pode ser menor que o Total ',mtInformation,[mbOk],0);
          Epago.Text := '';
          Etroco.Text := '';
          exit;
        End;
        Soma := StrtoFloat(Epago.Text) - (total);
        Etroco.Text := FormatFloat('#,##,0.00',Soma);

    End;

end;

procedure TF_finaliza.GeraNFCe;
begin
   ACBrNFCe.NotasFiscais.Clear;
   With ACBrNFCe.NotasFiscais.Add.NFe do;
   Begin

   End;

end;

// Imprimir cupom não fiscal
procedure TF_finaliza.imprime;
begin
  frxCupomVendaPDV.LoadFromFile('C:\sistemas_pdv\Rel\CupomVendaPDV.fr3');
  Troco := 0;
  frxCupomVendaPDV.Variables['vTotal'] := Total;
  frxCupomVendaPDV.Variables['vFormaPagto'] := CBBforma.ItemIndex;
  if CBBforma.ItemIndex = 0 then
     frxCupomVendaPDV.Variables['vValorPago'] := Epago.Text
   else
     frxCupomVendaPDV.Variables['vValorPago'] := Total;
  if CBBforma.ItemIndex = 0 then
     frxCupomVendaPDV.Variables['vTroco'] := soma
   else
     frxCupomVendaPDV.Variables['vTroco'] := Troco;
  if CBBforma.ItemIndex = 0 then
     frxCupomVendaPDV.Variables['vTipoPgt'] := quotedStr(Trim('Dinheiro'))
  else if CBBforma.ItemIndex = 1 then
     frxCupomVendaPDV.Variables['vTipoPgt'] := quotedStr(Trim('Cartão de Débito'))
  else if CBBforma.ItemIndex = 2 then
     frxCupomVendaPDV.Variables['vTipoPgt'] := quotedStr(Trim('Cartão de Crédito'))
  else if CBBforma.ItemIndex = 3 then
     frxCupomVendaPDV.Variables['vTipoPgt'] := quotedStr(Trim('Pix'));
     frxCupomVendaPDV.ShowReport;
End;

procedure TF_finaliza.IniciarNFCE;
var
caminhoNFCE : String;
begin
caminhoNFCE :=  ExtractFilePath(Application.ExeName)+ 'Schemas\';
//Messagedlg(caminhoNFCE, mtInformation,[mbOk],0);
//NFCe.Configuracoes.Arquivos.PathSchemas := caminhoNFCE;
end;

procedure TF_Finaliza.EmitirCupomFiscal;
Var
item : Integer;
begin
  nfce.NotasFiscais.Clear;
  With nfce.NotasFiscais.Add.NFe do
  Begin
    ide.natOp     := 'Venda';
    ide.indPag    := ipVista;
    ide.modelo    := 65;
    ide.serie     := 1;
//    ide.nNF      := txtnumero_nfce (criar)
    ide.dEmi      := Now();
    ide.dSaiEnt   := Date;
    ide.hSaiEnt   := Now;
    ide.tpNF      := tnSaida;
    ide.tpEmis    := teNormal;
    ide.tpAmb     := taHomologacao; // Trocar quando estiquer em produção
    ide.verProc   := '1.0.0.0';// Versão do sistema
    ide.cUF       := 35;  //Adicinar a tabela
    ide.finNFe    := fnNormal;
    ide.tpImp     := tiNFCe;
    ide.indFinal  := cfConsumidorFinal;
    ide.indPres   := pcPresencial;

    //Dados emitente
    Emit.CNPJCPF           := RetiraCaracteres(Dm.Qryempresa.FieldByName('CNPJ').AsString,'.-/\');
    Emit.IE                := RetiraCaracteres(Dm.Qryempresa.FieldByName('IncrEstadual').AsString,'.-/\');
    Emit.xNome             := Dm.Qryempresa.FieldByName('RazaoSocial').AsString;
    Emit.xFant             := Dm.Qryempresa.FieldByName('NomeFantasia').AsString;
    Emit.EnderEmit.fone    := RetiraCaracteres(Dm.Qryempresa.FieldByName('Telefone').AsString,'-');
    Emit.EnderEmit.CEP     := Strtoint(RetiraCaracteres(Dm.Qryempresa.FieldByName('Cep').AsString,'-'));
    Emit.EnderEmit.xLgr    := Dm.Qryempresa.FieldByName('Endereco').AsString;
    Emit.EnderEmit.nro     := Dm.Qryempresa.FieldByName('Numero').AsString;
    Emit.EnderEmit.xCpl    := '';
    Emit.EnderEmit.xBairro := Dm.Qryempresa.FieldByName('Bairro').AsString;
    Emit.EnderEmit.cMun    := 3530706;
    Emit.EnderEmit.xMun    := Dm.Qryempresa.FieldByName('Cidade').AsString;
    Emit.EnderEmit.UF      := Dm.Qryempresa.FieldByName('UF').AsString;
    Emit.enderEmit.cPais   := 1058;
    Emit.enderEmit.xPais   := 'BRASIL';
    Emit.IEST := '';
    Emit.CRT  := crtSimplesNacional; // (1-crtSimplesNacional, 2-crtSimplesExcessoReceita, 3-crtRegimeNormal);
    // Dados do Destinatário
{    Dest.CNPJCPF           := 'informar o CPF do destinatário';
    Dest.ISUF              := '';
    Dest.xNome             := 'nome do destinatário';
    Dest.indIEDest         := inNaoContribuinte;
    Dest.EnderDest.Fone    := '1533243333';
    Dest.EnderDest.CEP     := 18270170;
    Dest.EnderDest.xLgr    := 'Rua Coronel Aureliano de Camargo';
    Dest.EnderDest.nro     := '973';
    Dest.EnderDest.xCpl    := '';
    Dest.EnderDest.xBairro := 'Centro';
    Dest.EnderDest.cMun    := 3554003;
    Dest.EnderDest.xMun    := 'Tatuí';
    Dest.EnderDest.UF      := 'SP';
    Dest.EnderDest.cPais   := 1058;
    Dest.EnderDest.xPais   := 'BRASIL';}
    // Inserindo os itens da NFCe
    item := 1;
    Dm.Qrycaixa.First;
    while not dm.Qrycaixa.Eof do
    Begin
      With Det.Add do
      Begin
        Qryprodutos.Close;
        Qryprodutos.SQL.Clear;
        Qryprodutos.SQL.Add('Select * from produto where Prod_id = :pCod');
        Qryprodutos.ParamByName('pCod').AsString := Dm.Qrycaixa.FieldByName('Ca_Prod_id').AsString;
        Qryprodutos.Open;
        Prod.nItem    := item; // Número sequencial, para cada item deve ser incrementado
        Prod.cProd    := Dm.Qrycaixa.FieldByName('Ca_Prod_id').AsString;
        Prod.cEAN     := Dm.Qrycaixa.FieldByName('Ca_barras').AsString;
        Prod.xProd    := Dm.Qrycaixa.FieldByName('Ca_Desc').AsString;
        Prod.NCM      := Qryprodutos.FieldByName('Prod_ncm').AsString;
        Prod.EXTIPI   := '';
        Prod.CFOP     := '5929';
        Prod.uCom     := Dm.Qrycaixa.FieldByName('Ca_unidade').AsString;
        Prod.qCom     := Dm.Qrycaixa.FieldByName('Ca_Quant').AsCurrency;
        Prod.vUnCom   := Dm.Qrycaixa.FieldByName('Ca_PrecUnit').AsFloat;
        Prod.vProd    := Dm.Qrycaixa.FieldByName('Ca_PrecTotal').AsFloat;

        Prod.uTrib    := Dm.Qrycaixa.FieldByName('Ca_unidade').AsString;
        Prod.qTrib    := Dm.Qrycaixa.FieldByName('Ca_Quant').AsCurrency;
        Prod.vUnTrib  := Dm.Qrycaixa.FieldByName('Ca_PrecUnit').AsFloat;

        Prod.vOutro   :=0;
        Prod.vFrete   :=0;
        Prod.vSeg     :=0;
        Prod.vDesc    :=0;
        Prod.CEST     :='';
      End;
      item := item + 1;
      Dm.Qrycaixa.Next;
    End;
    Transp.modFrete := mfSemFrete;
    if  (CBBforma.ItemIndex = 0) then
    Begin
      with pag.New do
      Begin
        tPag := fpDinheiro;
        vPag := F_finaliza.Total;
      End;
    End;
    if  (CBBforma.ItemIndex = 1) then
    Begin
      with pag.New do
      Begin
        tPag := fpCartaoDebito;
        vPag := F_finaliza.Total;
      End;
    End;
    if  (CBBforma.ItemIndex = 2) then
    Begin
      with pag.New do
      Begin
        tPag := fpCartaocredito;
        vPag := F_finaliza.Total;
      End;
    End;
 End;
 //nfce.NotasFiscais.Assinar;
  nfce.Enviar(Dm.Qrycaixa.FieldByName('Ca_codCupom').AsInteger);
end;

function TF_Finaliza.RetiraCaracteres(texto, caracteres: string): string;
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
end.

