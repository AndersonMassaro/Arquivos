unit U_importXML;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, ACBrBase, ACBrDFe, ACBrNFe, pcnConversao,
  Vcl.Buttons;

type
  TF_importXML = class(TForm)
    QryCabNFE: TFDQuery;
    QryItensNFE: TFDQuery;
    dsCabNFE: TDataSource;
    dsItensNFE: TDataSource;
    QryCabNFENroNFE: TIntegerField;
    QryCabNFENatOperacao: TStringField;
    QryCabNFEEmissao: TDateField;
    QryCabNFEStatus: TStringField;
    QryCabNFEEmi_Nome: TStringField;
    QryCabNFEEmi_CNPJ: TStringField;
    QryCabNFEEmi_End: TStringField;
    QryCabNFEEmi_Bairro: TStringField;
    QryCabNFEEmi_Cidade: TStringField;
    QryCabNFEEmi_UF: TStringField;
    QryCabNFEDest_Nome: TStringField;
    QryCabNFEDest_CNPJ: TStringField;
    QryCabNFEDest_End: TStringField;
    QryCabNFEDest_Bairro: TStringField;
    QryCabNFEDest_Cidade: TStringField;
    QryCabNFEDest_UF: TStringField;
    QryItensNFENroNFE: TIntegerField;
    QryItensNFEItem: TIntegerField;
    QryItensNFEBarras: TStringField;
    QryItensNFECodProd: TStringField;
    QryItensNFEDescProd: TStringField;
    QryItensNFECFOP_Prod: TStringField;
    QryItensNFENCM_Prod: TWideStringField;
    QryItensNFEUnidade_Prod: TStringField;
    QryItensNFEValUnit_Prod: TBCDField;
    QryItensNFEQuant_Prod: TBCDField;
    QryItensNFEDesc_Prod: TBCDField;
    QryItensNFETotItens_Prod: TBCDField;
    QryItensNFEICMS_CST: TStringField;
    QryItensNFEICMS_CSOSN: TStringField;
    QryItensNFEICMS_PER: TBCDField;
    QryItensNFEICMS_VAL: TBCDField;
    QryItensNFEPIS_CST: TStringField;
    QryItensNFEPIS_PER: TBCDField;
    QryItensNFEPIS_VAL: TBCDField;
    QryItensNFECOFINS_CST: TStringField;
    QryItensNFECOFINS_PER: TBCDField;
    QryItensNFECOFINS_VAL: TBCDField;
    NFE: TACBrNFe;
    StatusBar1: TStatusBar;
    Pcabecario: TPanel;
    Pitens: TPanel;
    DBGrid2: TDBGrid;
    Litens: TLabel;
    UpCabNFE: TFDUpdateSQL;
    UpItensNFE: TFDUpdateSQL;
    Lcabecario: TLabel;
    DBGrid1: TDBGrid;
    Larquivo: TLabel;
    edtXML: TEdit;
    btCarregar: TBitBtn;
    OpenDialog: TOpenDialog;
    btImportar: TBitBtn;
    QryItensNFEStatus: TStringField;
    tbcabnfe: TFDTable;
    tbcabnfeNroNFE: TIntegerField;
    tbcabnfeNatOperacao: TStringField;
    tbcabnfeEmissao: TDateField;
    tbcabnfeStatus: TStringField;
    tbcabnfeEmi_Nome: TStringField;
    tbcabnfeEmi_CNPJ: TStringField;
    tbcabnfeEmi_End: TStringField;
    tbcabnfeEmi_Bairro: TStringField;
    tbcabnfeEmi_Cidade: TStringField;
    tbcabnfeEmi_UF: TStringField;
    tbcabnfeDest_Nome: TStringField;
    tbcabnfeDest_CNPJ: TStringField;
    tbcabnfeDest_End: TStringField;
    tbcabnfeDest_Bairro: TStringField;
    tbcabnfeDest_Cidade: TStringField;
    tbcabnfeDest_UF: TStringField;
    procedure btCarregarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btImportarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  F_importXML: TF_importXML;

implementation

{$R *.dfm}

uses U_dm;

procedure TF_importXML.btCarregarClick(Sender: TObject);
Var
nX : Integer;
Numero : Integer;
begin
   if edtXML.Text <> '' then
   Begin
     if not FileExists(edtXML.Text) then
     begin
       Opendialog.Execute;
       edtXML.Text := Opendialog.FileName
     end;
   End
   Else
   Begin
     Opendialog.Execute;
     edtXML.Text := Opendialog.FileName
   End;
   // Abrir arquivo xml
   NFE.NotasFiscais.Clear;
   NFE.NotasFiscais.LoadFromFile(edtXML.Text);

   QryCabNFE.Close;
   QryCabNFE.SQL.Clear;
   QryCabNFE.SQL.Add('Select * from ImportCABNFE where NroNFE = :nNumero');
   QryCabNFE.ParamByName('nNumero').AsInteger := NFE.NotasFiscais.Items[0].NFe.Ide.cNF;
   QryCabNFE.Open;
   Numero := QryCabNFE.FieldByName('NroNFE').AsInteger;
   if Numero = NFE.NotasFiscais.Items[0].NFe.Ide.cNF    then
   Begin
     showmessage('Nota' +' '+ 'Nro '+ InttoStr(Numero) +' '+' já foi importada ');
     edtXML.Text := '';
     QryCabNFE.close;
     QryItensNFE.close;
     QryCabNFE.open;
     QryItensNFE.open;
     exit;
   End;
   // Importar cabeçario
   QryCabNFE.Insert;
   QryCabNFENroNFE.Value      := NFE.NotasFiscais.Items[0].NFe.Ide.cNF;
   QryCabNFEEmissao.Value     := NFE.NotasFiscais.Items[0].NFe.Ide.dEmi;
   QryCabNFENatOperacao.Value := NFE.NotasFiscais.Items[0].NFe.Ide.natOp;
   QryCabNFEStatus.Value      := NFE.NotasFiscais.Items[0].NFe.procNFe.xMotivo;
   //dados emitente
   QryCabNFEEmi_Nome.Value    := NFE.NotasFiscais.Items[0].NFe.Emit.xNome;
   QryCabNFEEmi_CNPJ.Value    := NFE.NotasFiscais.Items[0].NFe.Emit.CNPJCPF;
   QryCabNFEEmi_End.Value     := NFE.NotasFiscais.Items[0].NFe.Emit.EnderEmit.xLgr;
   QryCabNFEEmi_Bairro.Value  := NFE.NotasFiscais.Items[0].NFe.Emit.EnderEmit.xBairro;
   QryCabNFEEmi_Cidade.Value  := NFE.NotasFiscais.Items[0].NFe.Emit.EnderEmit.xMun;
   QryCabNFEEmi_UF.Value      := NFE.NotasFiscais.Items[0].NFe.Emit.EnderEmit.UF;
   // dados destinatario
   QryCabNFEDest_Nome.Value   := NFE.NotasFiscais.Items[0].NFe.Dest.xNome;
   QryCabNFEDest_CNPJ.Value   := NFE.NotasFiscais.Items[0].NFe.Dest.CNPJCPF;
   QryCabNFEDest_End.Value    := NFE.NotasFiscais.Items[0].NFe.Dest.EnderDest.xLgr;
   QryCabNFEDest_Bairro.Value := NFE.NotasFiscais.Items[0].NFe.Dest.EnderDest.xBairro;
   QryCabNFEDest_Cidade.Value := NFE.NotasFiscais.Items[0].NFe.Dest.EnderDest.xMun;
   QryCabNFEDest_UF.Value     := NFE.NotasFiscais.Items[0].NFe.Dest.EnderDest.UF;
   QryCabNFE.Post;
   edtXML.Text := '';
   // Imortaritens da NF
   for nX := 0 to NFE.NotasFiscais.Items[0].NFe.Det.Count -1 do
   Begin
     QryItensNFE.Insert;
     QryItensNFENroNFE.Value       := NFE.NotasFiscais.Items[0].NFe.Ide.cNF;
     QryItensNFEItem.Value         := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.nItem;
     QryItensNFEBarras.Value       := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.cEAN;
     QryItensNFECodProd.Value      := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.cProd;
     QryItensNFEDescProd.Value     := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.xProd;
     QryItensNFECFOP_Prod.Value    := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.CFOP;
     QryItensNFEUnidade_Prod.Value := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.uTrib;
     QryItensNFEValUnit_Prod.Value := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.vUnCom;
     QryItensNFEQuant_Prod.Value   := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.qCom;
     QryItensNFEDesc_Prod.Value    := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.vDesc;
     QryItensNFETotItens_Prod.Value:= (NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.vUnCom * NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Prod.qCom);
     // Tributos icms
     QryItensNFEICMS_CSOSN.Value   := CSOSNIcmsToStr(NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.ICMS.CSOSN);
     QryItensNFEICMS_CST.Value     := CSTICMSToStr(NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.ICMS.CST);
     QryItensNFEICMS_PER.Value     := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.ICMS.pICMS;
     QryItensNFEICMS_VAL.Value     := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.ICMS.vICMS;
     // Tributos pis
     QryItensNFEPIS_CST.Value      := CSTPISToStr(NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.PIS.CST);
     QryItensNFEPIS_PER.Value      := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.PIS.pPIS;
     QryItensNFEPIS_VAL.Value      := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.PIS.vPIS;
     // Tributos cofins
     QryItensNFECOFINS_CST.Value      := CSTCOFINSToStr(NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.COFINS.CST);
     QryItensNFECOFINS_PER.Value      := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.COFINS.pCOFINS;
     QryItensNFECOFINS_VAL.Value      := NFE.NotasFiscais.Items[0].NFe.Det.Items[nX].Imposto.COFINS.vCOFINS;
      QryItensNFE.Post;
   End;

end;

procedure TF_importXML.btImportarClick(Sender: TObject);
Var
nCod : Integer;
nCodFor : Integer;
begin
  while not QryItensNFE.Eof do
  Begin
    Dm.Qrymovimentacao.Open;
    Dm.Qrymovimentacao.Append;
    if QryItensNFEStatus.Value = '' then
    Begin
      if QryItensNFEBarras.Value <> '' then
      Begin
       Dm.Qrymovimentacao.FieldByName('Mov_barras').AsString     := QryItensNFEBarras.AsString;
       Dm.Qrymovimentacao.FieldByName('Mov_produto').AsString    := QryItensNFEDescProd.AsString;
       Dm.Qrymovimentacao.FieldByName('Mov_quantidade').AsString := QryItensNFEQuant_Prod.AsString;
       Dm.Qrymovimentacao.FieldByName('Mov_custo').AsCurrency    := QryItensNFEValUnit_Prod.AsCurrency;
       Dm.QrymovimentacaoMov_id.IdentityInsert;
       Dm.Qryproduto.Close;
       Dm.Qryproduto.SQL.Clear;
       Dm.Qryproduto.SQL.Add('Select * from produto where Prod_cod_barras = :nBarras');
       Dm.Qryproduto.ParamByName('nBarras').AsString := QryItensNFEBarras.AsString;
       Dm.Qryproduto.Open;
       nCod := Dm.Qryproduto.FieldByName('Prod_id').AsInteger;
       Dm.Qrymovimentacao.FieldByName('Mov_prod_id').AsInteger := nCod;

       Dm.Qryfornecedor.Close;
       Dm.Qryfornecedor.SQL.Clear;
       Dm.Qryfornecedor.SQL.Add('Select * from Fornecedor where For_Cnpj = :nForcnj');
       Dm.Qryfornecedor.ParamByName('nForcnj').AsString := QryCabNFEEmi_CNPJ.AsString;
       Dm.Qryfornecedor.Open;
       nCodFor := Dm.Qryfornecedor.FieldByName('For_id').AsInteger;
       Dm.Qrymovimentacao.FieldByName('Mov_for_id').AsInteger := nCodFor;

       Dm.Qrymovimentacao.Post;
       QryItensNFE.Next
      End;
    End;

  End;
end;

procedure TF_importXML.FormShow(Sender: TObject);
begin
QryCabNFE.Open;
QryItensNFE.Open;
tbcabnfe.Open;
end;

end.
