unit U_conexao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IniFiles, Vcl.Buttons,
  Vcl.ComCtrls;

type
  TF_conexao = class(TForm)
    Ecaminho: TEdit;
    Lcaminho: TLabel;
    Lnomebanco: TLabel;
    Enome: TEdit;
    Eusuario: TEdit;
    Lusuario: TLabel;
    Esenha: TEdit;
    Lsenha: TLabel;
    Btncriar: TBitBtn;
    StatusBar1: TStatusBar;
    Memo: TMemo;
    Lstatus: TLabel;
    btnAbrir: TBitBtn;
    procedure BtncriarClick(Sender: TObject);
    procedure btnAbrirClick(Sender: TObject);
  private
    { Private declarations }
  public
  Arq : TiniFile;
  User_Name,Database,Password,Server,DriverID : String;
    { Public declarations }
  end;

var
  F_conexao: TF_conexao;

implementation

{$R *.dfm}

uses U_dm, U_login;

procedure TF_conexao.btnAbrirClick(Sender: TObject);
begin
  F_login:=TF_login.Create(nil);
  Try
    F_conexao.Close;
    F_login.ShowModal;
  Finally
    FreeAndNil(F_login);
  End;
end;

procedure TF_conexao.BtncriarClick(Sender: TObject);
begin
   DriverID := 'MSSQL';
   Arq := Tinifile.Create(ExtractFilePath(Application.ExeName)+'Config.ini');
   // Escreve no arquivo
   try
     Arq.WriteString('Dados','Server',Ecaminho.Text +'');
     Arq.WriteString('Dados','Database',Enome.Text +'');
     Arq.WriteString('Dados','User_Name',Eusuario.Text +'');
     Arq.WriteString('Dados','Password',Esenha.Text +'');
     Arq.WriteString('Dados','DriverID',DriverID+'');
   finally
     Arq.Free;
   end;
   //Lendo Arquivo INI
   Arq := TiniFIle.Create(ExtractFilePath(Application.ExeName)+'Config.ini');
   try
     Server      := Arq.ReadString('Dados','Server','');
     Database    := Arq.ReadString('Dados','Database','');
     User_Name   := Arq.ReadString('Dados','User_Name','');
     Password    := Arq.ReadString('Dados','Password','');
     DriverID    := Arq.ReadString('Dados','DriverID','');
     dm.Conexao.DriverName := DriverID;
     Dm.Conexao.Params.LoadFromFile('Config.ini');
     Dm.Conexao.LoginPrompt := False;
     Dm.Conexao.Open;
   finally
      FreeAndNil(Arq);
   end;
   if Dm.Conexao.Connected = True then
   Begin
      Memo.Lines.Add('Conectado ao Banco de Dados');
      Btncriar.Visible := False;
      Btnabrir.Visible := True ;
   end Else
      Memo.Lines.Add('Conexão Falhou Verifique as Configurações');
end;

end.
