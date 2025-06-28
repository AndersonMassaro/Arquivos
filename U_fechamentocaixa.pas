unit U_fechamentocaixa;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Mask, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TF_fechamentocaixa = class(TForm)
    StatusBar1: TStatusBar;
    Pfcaixa: TPanel;
    Lcaixa: TLabel;
    Ecaixa: TEdit;
    GroupBox1: TGroupBox;
    Ldinheiro: TLabel;
    Lcredito: TLabel;
    Ldebito: TLabel;
    Lpix: TLabel;
    Ltotal: TLabel;
    GroupBox2: TGroupBox;
    Labertura: TLabel;
    Lsangria: TLabel;
    Eaberturacaixa: TMaskEdit;
    Edinheiro: TMaskEdit;
    Ecredito: TMaskEdit;
    Edebito: TMaskEdit;
    Epix: TMaskEdit;
    Etotalentrada: TMaskEdit;
    Esangria: TMaskEdit;
    Loperador: TLabel;
    Eoperador: TEdit;
    GroupBox3: TGroupBox;
    Lvalor: TLabel;
    Evalor: TMaskEdit;
    Qryfechacaixa: TFDQuery;
    QryfechacaixaValor: TCurrencyField;
    QryfechacaixaTipo: TStringField;
    QryabreCaixa: TFDQuery;
    QryabreCaixaAValor: TCurrencyField;
    QrysangriaCaixa: TFDQuery;
    QrysangriaCaixaSValor: TCurrencyField;
    QryresumoCaixa: TFDQuery;
    QryresumoCaixaRe_id: TFDAutoIncField;
    QryresumoCaixaRe_Total: TFloatField;
    QryresumoCaixaRe_emCaixa: TFloatField;
    QryresumoCaixaRe_diferenca: TFloatField;
    QryresumoCaixaRe_caixa: TStringField;
    QryresumoCaixaRe_dtFechamento: TSQLTimeStampField;
    QryresumoCaixaRe_obs: TMemoField;
    Lmsg: TLabel;
    Lresult: TLabel;
    procedure FormShow(Sender: TObject);
    procedure EvalorKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    Tipo,CValor,Valor,AValor,SValor,TGeral,Result : currency;
    DateI,DateF : String;
    HoraI,HoraF : Ttime;
    Caixa : String;
    procedure banco;
  public
    { Public declarations }
  end;

var
  F_fechamentocaixa: TF_fechamentocaixa;

implementation

{$R *.dfm}

uses U_dm, U_pdv, U_abrecaixa, U_usuarios, U_login;


procedure TF_fechamentocaixa.banco;
Var Alt : integer;
    Obs,Obs1, data : String;
begin
  data := datetostr(Now);
  Alt := 1;
  Obs := '';
  Obs1:=  data+'-' + 'Caixa ficou com uma Diferença de:'+' '+(formatfloat('#0.00', Result));
  Caixa := F_abrecaixa.Combocaixa.Text;
  // Altera campo Status para 1 tabela Caixafechado
  With Qryfechacaixa do
  Begin
    Close;
    SQL.Clear;
    Sql.Add('UPDATE Caixafechado SET Cxf_status= :vAlt where Cxf_dtvenda between :DateI and :DateF and Cxf_caixa = :vCaixa');
    ParamByName('vAlt').AsInteger := Alt;
    ParamByName('vCaixa').AsString := Caixa;
    ParamByName('DateI').Value := DateI;
    ParamByName('DateF').Value := DateF;
    Qryfechacaixa.ExecSQL;
  End;
  Alt := 1;
  // Altera campo Status para 1 tabela Sangria
  With QrysangriaCaixa do
  Begin
    Close;
    SQL.Clear;
    Sql.Add('UPDATE Sangria SET Sa_baixado = :vAlt where Sa_data between :DateI and :DateF and Sa_Caixa = :vCaixa');
    ParamByName('vAlt').AsInteger := Alt;
    ParamByName('vCaixa').AsString := Caixa;
    ParamByName('DateI').Value := DateI;
    ParamByName('DateF').Value := DateF;
    QrysangriaCaixa.ExecSQL;
  End;
  // Altera campo Status para 1 tabela Abertua de caixa
  With QryabreCaixa do
  Begin
    Close;
    SQL.Clear;
    Sql.Add('UPDATE Aberturacaixa SET Abertura_Status = :vAlt where Abertura_abredata between :DateI and :DateF and Abertura_Caixa = :vCaixa');
    ParamByName('vAlt').AsInteger := Alt;
    ParamByName('vCaixa').AsString := Caixa;
    ParamByName('DateI').Value := DateI;
    ParamByName('DateF').Value := DateF;
    QryabreCaixa.ExecSQL;
  End;
  With QryresumoCaixa do
     Begin
      Close;
      SQL.Clear;
      Sql.Add('Insert into Resumocaixa (Re_Total,Re_emCaixa,Re_Diferenca,Re_Caixa,Re_dtFechamento,Re_obs)');
      Sql.Add('VALUES (:vTotal,:vEmCaixa,:vDif,:vCaixa,:vDtFecha,:vObs)');
      ParamByName('vTotal').AsCurrency       := StrtoFloat(Etotalentrada.Text);
      ParamByName('vEmCaixa').AsCurrency     := StrtoFloat(Evalor.Text);
      ParamByName('vDif').AsCurrency         := Result;
      ParamByName('vCaixa').AsString         := Caixa;
      ParamByName('vDtFecha').AsDateTime     := Now;
      if Result = 0 then
        ParamByName('vObs').AsString           := Obs
      Else
        ParamByName('vObs').AsString           := Obs1;
      QryresumoCaixa.ExecSQL;
     End;
end;

procedure TF_fechamentocaixa.EvalorKeyPress(Sender: TObject; var Key: Char);
begin
if Key = #13 then
Begin
  Evalor.SetFocus;
  Tgeral := 0;
  Tgeral := (CValor+AValor)-SValor;
  Result := strtoFloat(Evalor.Text)-TGeral;
  if (strtoFloat(Evalor.Text) = TGeral)  then
    Begin
    banco;
    F_fechamentocaixa.Close;
    F_caixa.close;
  End Else
  Lmsg.Visible := True;
  Lresult.Visible := True;
  Lresult.Caption := 'R$'+(formatfloat('#0.00', Result));
  if (strtoFloat(Evalor.Text) <> TGeral) then
  If Application.MessageBox('Fecha o caixa assim mesmo?','Aviso !!!',MB_YESNO +
                           MB_ICONQUESTION + MB_DEFBUTTON2) = IDYES Then
      banco;
      F_fechamentocaixa.Close;
      F_caixa.close;
//     Messagedlg('Verifique...  ,mtInformation,[mbOk],0);
  end;

end;

procedure TF_fechamentocaixa.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key = VK_ESCAPE then
 Begin
   F_fechamentocaixa.Close;
 End
end;

procedure TF_fechamentocaixa.FormShow(Sender: TObject);
Var IArray : Array[0..3] of String;
begin
 HoraI := StrtoTime('00:00:00');
 HoraF := StrtoTime('23:00:00');
 DateI := Datetostr(Now)+' '+TimetoStr(HoraI);
 DateF := Datetostr(Now)+' '+TimetoStr(HoraF);
 Caixa := F_abrecaixa.Combocaixa.Text;
 with Qryfechacaixa do
 Begin
     Ecaixa.Text := caixa;
     Eoperador.Text := F_login.usuario;
     close;
     SQL.Clear;
     SQL.Add('select sum(Cxf_vltotal) as Valor, Cxf_fpagto as Tipo from CaixaFechado');
     SQL.Add('where Cxf_caixa = :Caixa and Cxf_dtvenda between :DateI and :DateF and Cxf_status is null');
     SQL.Add('Group by  Cxf_fpagto');
     ParamByName('Caixa').Value := caixa;
     ParamByName('DateI').Value := DateI;
     ParamByName('DateF').Value := DateF;
     Open;
     while not Qryfechacaixa.Eof do
     begin
     Tipo        := Qryfechacaixa.FieldByName('Tipo').AsCurrency;
     Valor       := Qryfechacaixa.FieldByName('Valor').AsCurrency;
     IArray[0] := 'Diheiro';
     IArray[1] := 'Credito';
     IArray[2] := 'Debito';
     IArray[3] := 'Pix';
     if Edinheiro.Text = '0,00' then
     if Tipo = 0 then
      Begin
        Edinheiro.Text := '';
        Edinheiro.Text := Edinheiro.Text + (formatfloat('#0.00', Valor));
     End;
     if Ecredito.Text = '0,00' then
     if Tipo = 1 then
     Begin
        Ecredito.Text := '';
        Ecredito.Text := Ecredito.Text + (formatfloat('#0.00', Valor));
     End;
     if Edebito.Text = '0,00' then
     if Tipo = 2 then
     Begin
        Edebito.Text := '';
        Edebito.Text := Edebito.Text + (formatfloat('#0.00', Valor));
     end;
     if Epix.Text = '0,00' then
     if Tipo = 3 then
     Begin
        Epix.Text := '';
        Epix.Text := Epix.Text + (formatfloat('#0.00', Valor));
      end;
     Qryfechacaixa.Next;
   End;
   CValor := (strtoFloat(Edinheiro.Text)+strtoFloat(Ecredito.Text)+strtoFloat(Edebito.Text)+strtoFloat(Epix.Text));
   Etotalentrada.Text := (formatfloat('#0.00', CValor));
   with QryabreCaixa do
   Begin
     close;
     SQL.Clear;
     SQL.Add('select sum(Abertura_valor) as AValor from AberturaCaixa ');
     SQL.Add('where Abertura_caixa = :Caixa and Abertura_abredata between :DateI and :DateF and Abertura_status is null');
     ParamByName('Caixa').Value := caixa;
     ParamByName('DateI').Value := DateI;
     ParamByName('DateF').Value := DateF;
     Open;
     AValor       := QryabreCaixa.FieldByName('AValor').AsCurrency;
     Eaberturacaixa.Text := (formatfloat('#0.00', AValor));
   End;
   with QrysangriaCaixa do
   Begin
     close;
     SQL.Clear;
     SQL.Add('select sum(Sa_valor) as SValor from Sangria ');
     SQL.Add('where Sa_caixa = :Caixa and Sa_data between :DateI and :DateF and Sa_baixado is null');
     ParamByName('Caixa').Value := caixa;
     ParamByName('DateI').Value := DateI;
     ParamByName('DateF').Value := DateF;
     Open;
     SValor        := QrysangriaCaixa.FieldByName('SValor').AsCurrency;
     Esangria.Text := (formatfloat('#0.00', SValor));
   End;
   End;
end;

end.
