unit U_fornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.StdCtrls, Vcl.Mask,
  Vcl.DBCtrls, Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.Imaging.pngimage;

type
  Tfrm_Fornecedor = class(TForm)
    Panel: TPanel;
    LID: TLabel;
    LRazaoSocial: TLabel;
    LFantasia: TLabel;
    LCNPJ: TLabel;
    LIE: TLabel;
    LAbertura: TLabel;
    LEndereco: TLabel;
    LNumero: TLabel;
    LCompl: TLabel;
    LBairro: TLabel;
    LCidade: TLabel;
    LUF: TLabel;
    LCadastro: TLabel;
    LCep: TLabel;
    LContato: TLabel;
    LDepto: TLabel;
    LEmail: TLabel;
    LContato1: TLabel;
    LDepto1: TLabel;
    LEmail1: TLabel;
    Label23: TLabel;
    DBEditID: TDBEdit;
    DBEditRazao: TDBEdit;
    DBEditFantasia: TDBEdit;
    DBEditCNPJ: TDBEdit;
    DBEditIE: TDBEdit;
    DateTimeAbertura: TDateTimePicker;
    DBEditEndereco: TDBEdit;
    DBEditNumero: TDBEdit;
    DBEditComplemento: TDBEdit;
    DBEditBairro: TDBEdit;
    DBEditCidade: TDBEdit;
    DateTimeCadastro: TDateTimePicker;
    DBEditCep: TDBEdit;
    DBEditContato: TDBEdit;
    DBEditDepto: TDBEdit;
    DBEditEmail: TDBEdit;
    DBEditContato1: TDBEdit;
    DBEditDepto1: TDBEdit;
    DBEditEmail1: TDBEdit;
    DBMemo: TDBMemo;
    DBComboBoxUF: TDBComboBox;
    btnNovoAtivo: TBitBtn;
    btnNovoInativo: TBitBtn;
    btnEditarAtivo: TBitBtn;
    btnEditarInativo: TBitBtn;
    btnSalvarAtivo: TBitBtn;
    btnSalvarInativo: TBitBtn;
    btnCancelarAtivo: TBitBtn;
    btnCancelarInativo: TBitBtn;
    Lfone: TLabel;
    LFone1: TLabel;
    DBEdittel: TDBEdit;
    DBEdittel1: TDBEdit;
    btnSalvarEdicaoAtivo: TBitBtn;
    Epesquisa: TEdit;
    Lpesquisa: TLabel;
    DSFor: TDataSource;
    DBGridnome: TDBGrid;
    Panel1: TPanel;
    Label3: TLabel;
    X: TPanel;
    procedure btnNovoAtivoClick(Sender: TObject);
    procedure btnSalvarAtivoClick(Sender: TObject);
    procedure btnEditarAtivoClick(Sender: TObject);
    procedure btnSalvarEdicaoAtivoClick(Sender: TObject);
    procedure btnCancelarAtivoClick(Sender: TObject);
    procedure EpesquisaChange(Sender: TObject);

  private
    codigo : integer;
    { Private declarations }
  public

    { Public declarations }
  end;

var
  frm_Fornecedor: Tfrm_Fornecedor;

implementation

{$R *.dfm}
Uses U_DM;

procedure Tfrm_Fornecedor.btnCancelarAtivoClick(Sender: TObject);
Var I :integer;
begin
// Habilita de desabilita botões
  btnNovoAtivo.Visible          := True;
  btnNovoInativo.Visible        := False;
  BtnEditarAtivo.Visible        := True;
  btnEditarInativo.Visible      := False;
  btnSalvarAtivo.Visible        := False;
  btnSalvarEdicaoAtivo.Visible  := False;
  btnSalvarinativo.Visible      := True;
  btnCancelarAtivo.Visible      := False;
  btnCancelarInativo.Visible    := True;
  for I := 0 to frm_Fornecedor.ComponentCount - 1 do
  begin
  // Limpa edits
    if frm_Fornecedor.Components[I] is TDBEdit then
     TDBEdit(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDateTimePicker then
     TDateTimePicker(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDBCombobox then
     TDBCombobox(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDBMemo then
     TDBMemo(frm_Fornecedor.Components[i]).Enabled := True;
  end;
    DSFor.DataSet.Cancel;
end;

procedure Tfrm_Fornecedor.btnEditarAtivoClick(Sender: TObject);
 Var I :integer;
begin
// Habilita de desabilita botões
  btnNovoAtivo.Visible          := False;
  btnNovoInativo.Visible        := True;
  BtnEditarAtivo.Visible        := False;
  btnEditarInativo.Visible      := True;
  btnSalvarAtivo.Visible        := False;
  btnSalvarEdicaoAtivo.Visible  := True;
  btnSalvarinativo.Visible      := False;
  btnCancelarAtivo.Visible      := True;
  btnCancelarInativo.Visible    := False;
  for I := 0 to frm_Fornecedor.ComponentCount - 1 do
  begin
  // Limpa edits
    if frm_Fornecedor.Components[I] is TDBEdit then
     TDBEdit(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDateTimePicker then
     TDateTimePicker(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDBCombobox then
     TDBCombobox(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDBMemo then
     TDBMemo(frm_Fornecedor.Components[i]).Enabled := True;
  end;
 // DSFor.DataSet.Append;

end;

procedure Tfrm_Fornecedor.btnNovoAtivoClick(Sender: TObject);
 Var I :integer;
begin
//// Habilita de desabilita botões
  btnNovoAtivo.Visible          := False;
  btnNovoInativo.Visible        := True;
  BtnEditarAtivo.Visible        := False;
  btnEditarInativo.Visible      := True;
  btnSalvarAtivo.Visible        := True;
  btnSalvarEdicaoAtivo.Visible  := False;
  btnSalvarinativo.Visible      := False;
  btnCancelarAtivo.Visible      := True;
  btnCancelarInativo.Visible    := False;
  for I := 0 to frm_Fornecedor.ComponentCount - 1 do
  begin
  // Limpa edits
    if frm_Fornecedor.Components[I] is TDBEdit then
     TDBEdit(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDateTimePicker then
     TDateTimePicker(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDBCombobox then
     TDBCombobox(frm_Fornecedor.Components[i]).Enabled := True;
    if frm_Fornecedor.Components[I] is TDBMemo then
     TDBMemo(frm_Fornecedor.Components[i]).Enabled := True;
  end;
  DSFor.DataSet.Append;
end;

procedure Tfrm_Fornecedor.btnSalvarAtivoClick(Sender: TObject);
 Var I :integer;
begin
// Habilita de desabilita botões
  btnNovoAtivo.Visible          := True;
  btnNovoInativo.Visible        := False;
  BtnEditarAtivo.Visible        := True;
  btnEditarInativo.Visible      := False;
  btnSalvarAtivo.Visible        := False;
  btnSalvarinativo.Visible      := True;
  btnCancelarAtivo.Visible      := False;
  btnCancelarInativo.Visible    := True;
  // Insere dadosno banco SQL Server
  With dm.Qryfornecedor do
     Begin
      Close;
      SQL.Clear;
      Sql.Add('Insert into fornecedor');
      Sql.add('(For_Razaosocial,For_Fantasia,For_Cnpj,For_Ie,For_dtAbertura,');
      Sql.Add('For_endereco,For_Numero,For_Compl,For_Bairro,For_cidade,For_UF,For_Cep,For_Tel,For_Tel1,');
      Sql.Add('For_Contato,For_Contato1,For_Depto,For_depto1,For_Email,For_Email1,For_Obs, For_DtCadastro)');
      Sql.Add('VALUES (:razao,:fantasia,:cnpj,:ie,:dtabertura,:endereco,:numero,:compl,');
      Sql.Add('        :bairro,:cidade,:UF,:cep,:tel,:tel1,:contato,:contato1,:depto,:depto1,');
      Sql.Add('        :email,:email1,:obs,:dtcadastro)');
      ParamByName('razao').AsString         := DBEditRazao.text;
      ParamByName('fantasia').AsString      := DBEditfantasia.Text;
      ParamByName('cnpj').AsString          := DBEditcnpj.Text;
      ParamByName('ie').AsString            := DBEditie.Text;
      ParamByName('dtabertura').AsDateTime  := DateTimeAbertura.DateTime;
      ParamByName('endereco').AsString      := DBEditendereco.Text;
      ParamByName('numero').AsString        := DBEditnumero.Text;
      ParamByName('compl').AsString         := DBEditcomplemento.Text;
      ParamByName('bairro').AsString        := DBEditbairro.Text;
      ParamByName('cidade').AsString        := DBEditcidade.Text;
      ParamByName('UF').AsString            := DBComboBoxUF.Text;
      ParamByName('cep').AsString           := DBEditcep.Text;
      ParamByName('tel').AsString           := DBEdittel.Text;
      ParamByName('tel1').AsString          := DBEdittel1.Text;
      ParamByName('contato').AsString       := DBEditcontato.Text;
      ParamByName('contato1').AsString      := DBEditcontato1.Text;
      ParamByName('depto').AsString         := DBEditdepto.Text;
      ParamByName('depto1').AsString        := DBEditdepto1.Text;
      ParamByName('email').AsString         := DBEditemail.Text;
      ParamByName('email1').AsString        := DBEditemail1.Text;
      ParamByName('obs').AsString           := DBMemo.Text;
      ParamByName('dtcadastro').AsDateTime  := Now;
      dm.Qryfornecedor.ExecSQL;
      dm.TB_fornecedor.Close;
      dm.TB_fornecedor.Open;
     End;
     // Limpa edits
       for I := 0 to frm_Fornecedor.ComponentCount - 1 do
        begin
          if frm_Fornecedor.Components[I] is TDBEdit then
           TDBEdit(frm_Fornecedor.Components[i]).Enabled := False;
          if frm_Fornecedor.Components[I] is TDateTimePicker then
           TDateTimePicker(frm_Fornecedor.Components[i]).Enabled := False;
          if frm_Fornecedor.Components[I] is TDBCombobox then
           TDBCombobox(frm_Fornecedor.Components[i]).Enabled := False;
          if frm_Fornecedor.Components[I] is TDBMemo then
           TDBMemo(frm_Fornecedor.Components[i]).Enabled := False;
        end;
end;

procedure Tfrm_Fornecedor.btnSalvarEdicaoAtivoClick(Sender: TObject);
Var I :integer;
begin
// Habilita de desabilita botões
  btnNovoAtivo.Visible          := True;
  btnNovoInativo.Visible        := False;
  BtnEditarAtivo.Visible        := True;
  btnEditarInativo.Visible      := False;
  btnSalvarAtivo.Visible        := False;
  btnSalvarEdicaoAtivo.Visible  := False;
  btnSalvarinativo.Visible      := True;
  btnCancelarAtivo.Visible      := False;
  btnCancelarInativo.Visible    := True;
  With dm.Qryfornecedor do
   Begin
   // Altera dados do cadastro SQL Server
     Close;
     SQL.Clear;
     codigo := DBGridnome.Fields[0].Value;
     Sql.Add('UPDATE fornecedor SET For_Razaosocial=:razao,For_Fantasia=:fantasia,For_Cnpj=:cnpj,For_Ie=:ie,For_dtAbertura=:dtabertura where For_ID =:codigo');
     Sql.Add('UPDATE fornecedor SET For_endereco=:endereco,For_Numero=:numero,For_Compl=:compl,For_Bairro=:bairro,For_cidade=:cidade where For_ID =:codigo');
     Sql.Add('UPDATE fornecedor SET For_UF=:UF,For_Cep=:cep,For_Tel=:tel,For_Tel1=:tel1,For_Contato=:contato,For_Contato1=:contato1 where For_ID =:codigo');
     Sql.Add('UPDATE fornecedor SET For_Depto=:depto,For_depto1=:depto1,For_Email=:email,For_Email1=:email1,For_Obs=:obs,For_DtCadastro=:dtcadastro where For_ID =:codigo');
     ParamByName('codigo').AsInteger          := codigo;
     ParamByName('razao').AsString            := DBEditRazao.text;
     ParamByName('fantasia').AsString         := DBEditfantasia.Text;
     ParamByName('cnpj').AsString             := DBEditcnpj.Text;
     ParamByName('ie').AsString               := DBEditie.Text;
     ParamByName('dtabertura').AsDateTime     := DateTimeAbertura.DateTime;
     ParamByName('endereco').AsString         := DBEditendereco.Text;
     ParamByName('numero').AsString           := DBEditnumero.Text;
     ParamByName('compl').AsString            := DBEditcomplemento.Text;
     ParamByName('bairro').AsString           := DBEditbairro.Text;
     ParamByName('cidade').AsString           := DBEditcidade.Text;
     ParamByName('UF').AsString               := DBComboBoxUF.Text;
     ParamByName('cep').AsString              := DBEditcep.Text;
     ParamByName('tel').AsString              := DBEdittel.Text;
     ParamByName('tel1').AsString             := DBEdittel1.Text;
     ParamByName('contato').AsString          := DBEditcontato.Text;
     ParamByName('contato1').AsString         := DBEditcontato1.Text;
     ParamByName('depto').AsString            := DBEditdepto.Text;
     ParamByName('depto1').AsString           := DBEditdepto1.Text;
     ParamByName('email').AsString            := DBEditemail.Text;
     ParamByName('email1').AsString           := DBEditemail1.Text;
     ParamByName('obs').AsString              := DBMemo.Text;
     ParamByName('dtcadastro').AsDateTime     := Now;
     dm.Qryfornecedor.ExecSQL;
     DSFor.DataSet.Close;
     DSFor.DataSet.Open;
  end;
  // Limpa edits
     for I := 0 to frm_Fornecedor.ComponentCount - 1 do
      begin
        if frm_Fornecedor.Components[I] is TDBEdit then
         TDBEdit(frm_Fornecedor.Components[i]).Enabled := False;
        if frm_Fornecedor.Components[I] is TDateTimePicker then
         TDateTimePicker(frm_Fornecedor.Components[i]).Enabled := False;
        if frm_Fornecedor.Components[I] is TDBCombobox then
         TDBCombobox(frm_Fornecedor.Components[i]).Enabled := False;
        if frm_Fornecedor.Components[I] is TDBMemo then
         TDBMemo(frm_Fornecedor.Components[i]).Enabled := False;
      end;
end;

procedure Tfrm_Fornecedor.EpesquisaChange(Sender: TObject);
begin
  dm.ds_fornecedor.DataSet.Filtered := false;
  dm.ds_fornecedor.DataSet.Filter := ' UPPER(For_fantasia) like ' +
  UpperCase(QuotedStr('%' + Epesquisa.Text + '%'));
  dm.ds_fornecedor.DataSet.Filtered := True;
end;

end.
