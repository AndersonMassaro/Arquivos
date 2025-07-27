unit U_lerXML;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  Vcl.Grids, Vcl.DBGrids, Data.DB, Datasnap.DBClient, Vcl.Buttons, Vcl.StdCtrls,
  XML.XMLDoc, XML.XMLIntf;

type
  TFrm_lerXML = class(TForm)
    pnl_fundo: TPanel;
    StatusBar: TStatusBar;
    pnl_topo: TPanel;
    OpenDialog: TOpenDialog;
    Ecaminho: TEdit;
    btBuscar: TSpeedButton;
    cdsXML1: TClientDataSet;
    ds_XML: TDataSource;
    dbgXML: TDBGrid;
    btLerArquivo: TSpeedButton;
    QryXML: TFDQuery;
    btImportar: TSpeedButton;
    Label1: TLabel;
    Lpesquisa: TLabel;
    Memo: TMemo;
    chkSelecionarTodos: TCheckBox;
    cdsXML: TClientDataSet;
    Label3: TLabel;
    X: TPanel;
    QryBuscaFor: TFDQuery;
    QryBuscaProduto: TFDQuery;
    QryInsert: TFDQuery;
    QryLogErro: TFDQuery;
    LImportado: TLabel;
    LimportadoQTD: TLabel;
    Lerros: TLabel;
    LerrosQTD: TLabel;
    btLog: TSpeedButton;
    QryVerificaExistente: TFDQuery;
    dsLogErro: TDataSource;
    QryLogErrolog_id: TFDAutoIncField;
    QryLogErrodata_erro: TSQLTimeStampField;
    QryLogErrotipo_erro: TStringField;
    QryLogErrodescricao: TStringField;
    QryLogErronumero_nf: TStringField;
    QryLogErrocnpj_emitente: TStringField;
    QryLogErrocprod: TStringField;
    QryLogErrousuario: TStringField;
    pnl_logerro: TPanel;
    Memo_erros: TMemo;
    SpeedButton2: TSpeedButton;
    procedure btBuscarClick(Sender: TObject);
    procedure btLerArquivoClick(Sender: TObject);
    function FindNodeInsensitive(Parent: IXMLNode; const NodeName: string): IXMLNode;
    procedure dbgXMLDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure dbgXMLCellClick(Column: TColumn);
    procedure FormShow(Sender: TObject);
    procedure chkSelecionarTodosClick(Sender: TObject);
    procedure XClick(Sender: TObject);
    procedure btImportarClick(Sender: TObject);
    procedure LogErroImportacao(const TipoErro, Descricao, NumeroNF, CNPJ, cProd: string);
    procedure btLogClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);

  private
    { Private declarations }
    DataEntrada: Tdatetime;
    margem, ipiR, icms, frete, desp, desconto, custo, precoVenda: Double;
    codBarras: string;
  public
    { Public declarations }
  end;

var
  Frm_lerXML: TFrm_lerXML;

implementation

{$R *.dfm}

uses U_dm, U_entrada, U_Globais;

procedure TFrm_lerXML.btBuscarClick(Sender: TObject);
begin
  if OpenDialog.Execute then
     Ecaminho.Text := OpenDialog.FileName;

end;

procedure TFrm_lerXML.btImportarClick(Sender: TObject);
var
  QtdImportados, QtdErros: Integer;
  ProdutoEncontrado, FornecedorEncontrado: Boolean;
  ContadorImportado, ContadorErros: Integer;
begin
  QtdImportados := 0;
  QtdErros := 0;

  cdsXML.First;
  while not cdsXML.Eof do
  begin
    if not cdsXML.FieldByName('Selecionar').AsBoolean then
    begin
      cdsXML.Next;
      Continue;
    end;

    ProdutoEncontrado := False;
    FornecedorEncontrado := False;

    try
      // Verifica se o produto existe
      QryBuscaproduto.Close;
      QryBuscaproduto.SQL.Text := 'SELECT prod_id FROM produto WHERE prod_cod_barras = :barras';
      QryBuscaproduto.ParamByName('barras').AsString := cdsXML.FieldByName('cProd').AsString;
      QryBuscaproduto.Open;

      if not QryBuscaproduto.IsEmpty then
        ProdutoEncontrado := True;

      // Verifica se o fornecedor existe
      QryBuscaFor.Close;
      QryBuscaFor.SQL.Text := 'SELECT for_id FROM fornecedor WHERE for_cnpj = :cnpj';
      QryBuscaFor.ParamByName('cnpj').AsString := cdsXML.FieldByName('emit_CNPJ').AsString;
      QryBuscaFor.Open;

      if not QryBuscaFor.IsEmpty then
        FornecedorEncontrado := True;

      // Se algum não encontrado, registra erro e pula
      if not ProdutoEncontrado then
      begin
        Inc(QtdErros);
        LogErroImportacao('Produto não encontrado',
                          'Código de barras não cadastrado: ' + cdsXML.FieldByName('cProd').AsString,
                          cdsXML.FieldByName('Numero_NF').AsString,
                          cdsXML.FieldByName('emit_CNPJ').AsString,
                          cdsXML.FieldByName('cProd').AsString);
        cdsXML.Next;
        Continue;
      end;

      if not FornecedorEncontrado then
      begin
        Inc(QtdErros);
        LogErroImportacao('Fornecedor não encontrado',
                          'CNPJ não cadastrado: ' + cdsXML.FieldByName('emit_CNPJ').AsString,
                          cdsXML.FieldByName('Numero_NF').AsString,
                          cdsXML.FieldByName('emit_CNPJ').AsString,
                          cdsXML.FieldByName('cProd').AsString);
        cdsXML.Next;
        Continue;
      end;
      // Verifica se o produto já foi importado nessa NF
       QryVerificaExistente.Close;
       QryVerificaExistente.SQL.Text :=
         'SELECT 1 FROM movimentacao ' +
         'WHERE Mov_barras = :barras AND Mov_nf = :nf';
       QryVerificaExistente.ParamByName('barras').AsString := cdsXML.FieldByName('cProd').AsString;
       QryVerificaExistente.ParamByName('nf').AsString     := cdsXML.FieldByName('Numero_NF').AsString;
       QryVerificaExistente.Open;
       if not QryVerificaExistente.IsEmpty then
       begin
         Inc(QtdErros);
         LogErroImportacao('Produto já importado nessa NF',
                            'Código de barras já importado: ' + cdsXML.FieldByName('cProd').AsString,
                            cdsXML.FieldByName('Numero_NF').AsString,
                            cdsXML.FieldByName('emit_CNPJ').AsString,
                            cdsXML.FieldByName('cProd').AsString);
         cdsXML.Next;
         Continue;
       end;
       DataEntrada := Now;
      // Prepara e executa o INSERT
      QryInsert.Close;
      QryInsert.SQL.Clear;
      QryInsert.SQL.Add('INSERT INTO movimentacao');
      QryInsert.SQL.Add('(Mov_barras, Mov_produto, Mov_quantidade, Mov_custo, Mov_venda, Mov_lote, Mov_dtvalidade, Mov_nf,');
      QryInsert.SQL.Add(' Mov_dtentrada, Mov_status, Mov_prod_id, Mov_for_id)');
      QryInsert.SQL.Add('VALUES');
      QryInsert.SQL.Add('(:Mov_barras, :Mov_produto, :Mov_quantidade, :Mov_custo, :Mov_venda, :Mov_lote, :Mov_dtvalidade, :Mov_nf,');
      QryInsert.SQL.Add(' :Mov_dtentrada, :Mov_estatus, :Mov_prod_id, :Mov_for_id)');

      QryInsert.ParamByName('Mov_barras').AsString     := cdsXML.FieldByName('cProd').AsString;
      QryInsert.ParamByName('Mov_produto').AsString    := cdsXML.FieldByName('xProd').AsString;
      QryInsert.ParamByName('Mov_quantidade').AsFloat  := cdsXML.FieldByName('qCom').AsFloat;
      QryInsert.ParamByName('Mov_custo').AsFloat       := cdsXML.FieldByName('vUnCom').AsFloat;

      codBarras := cdsXML.FieldByName('cProd').AsString;

      // Localiza o produto correto
      with DM.QryProduto do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT * FROM produto WHERE Prod_cod_barras = :cb');
        ParamByName('cb').AsString := codBarras;
        Open;
      end;

       // Pegando valores do produto (você pode ajustar a origem dos campos se estiver diferente)
      custo := cdsXML.FieldByName('vUnCom').AsFloat;
      margem   := DM.QryProduto.FieldByName('Prod_margem').AsFloat;
      ipiR     := DM.QryProduto.FieldByName('Prod_ipiR').AsFloat;
      icms     := DM.QryProduto.FieldByName('Prod_icms').AsFloat;
      frete    := DM.QryProduto.FieldByName('Prod_frete').AsFloat;
      desp     := DM.QryProduto.FieldByName('Prod_desp').AsFloat;
      desconto := DM.QryProduto.FieldByName('Prod_descontov').AsFloat;


      // Corrige a ordem dos parâmetros
      precoVenda := CalcularPrecoVenda(custo, ipiR, icms, frete, desp, desconto, margem);

      // Aplica o valor correto
      QryInsert.ParamByName('Mov_venda').AsFloat := precoVenda;
      QryInsert.ParamByName('Mov_lote').AsString       := cdsXML.FieldByName('lote').AsString;

      if not cdsXML.FieldByName('Validade').IsNull then
        QryInsert.ParamByName('Mov_dtvalidade').AsDate := cdsXML.FieldByName('Validade').AsDateTime
      else
        QryInsert.ParamByName('Mov_dtvalidade').Clear;

      QryInsert.ParamByName('Mov_nf').AsString         := cdsXML.FieldByName('Numero_NF').AsString;
      QryInsert.ParamByName('Mov_dtentrada').AsDate    := DataEntrada;
      QryInsert.ParamByName('Mov_estatus').AsString    := 'E';

      QryInsert.ParamByName('Mov_prod_id').AsInteger := QryBuscaproduto.FieldByName('prod_id').AsInteger;
      QryInsert.ParamByName('Mov_for_id').AsInteger  := QryBuscaFor.FieldByName('for_id').AsInteger;

      QryInsert.ExecSQL;

      Inc(QtdImportados);

    except
      on E: Exception do
      begin
        Inc(QtdErros);
        LogErroImportacao('Erro ao importar item',
                          E.Message,
                          cdsXML.FieldByName('Numero_NF').AsString,
                          cdsXML.FieldByName('emit_CNPJ').AsString,
                          cdsXML.FieldByName('cProd').AsString);
      end;
    end;

    cdsXML.Next;
  end;

  // Atualiza labels
  LimportadoQTD.Caption := IntToStr(QtdImportados) + ' registro(s) importado(s)';
  LerrosQTD.Caption     := IntToStr(QtdErros) + ' erro(s) encontrado(s)';

  StatusBar.Panels[0].Text := Format(
  'Importação concluída: %s, %s ',
  [LimportadoQTD.Caption, LerrosQTD.Caption]
   );

  // Habilita visualização do log se houve erro
  btLog.Visible := QtdErros > 0;
end;

procedure TFrm_lerXML.btLerArquivoClick(Sender: TObject);
var
  i: Integer;
  XMLDoc: IXMLDocument;
  NodeNFe, InfNFeNode, NodeDet, NodeProd, emitNode, enderEmitNode: IXMLNode;
  NodeList: IXMLNodeList;
  NodeImposto, NodeICMS, NodeICMSTipo,ideNode: IXMLNode;  // declaradas aqui, não dentro do código
  emit_CNPJ, emit_xNome, emit_xFant, emit_IE, emit_fone, emit_endereco: string;
  cProd, xProd, cEAN, NCM, uCom, infAdProd, validade, lote, NumeroNota: string;
  qCom, vUnCom, vProd: Double;
begin
  Memo.Lines.Clear; // Limpa o memo antes de processar
  try
    if not FileExists(Ecaminho.Text) then
    begin
      Memo.Lines.Add('Arquivo não encontrado: ' + Ecaminho.Text);
      Exit;
    end;

    XMLDoc := LoadXMLDocument(Ecaminho.Text);
    XMLDoc.Active := True;

    if (XMLDoc.DocumentElement = nil) then
    begin
      Memo.Lines.Add('Erro: Elemento raiz não encontrado no XML.');
      Exit;
    end;

    NodeNFe := FindNodeInsensitive(XMLDoc.DocumentElement, 'NFe');
    if NodeNFe = nil then
      NodeNFe := XMLDoc.DocumentElement;

    InfNFeNode := FindNodeInsensitive(NodeNFe, 'infNFe');
    if InfNFeNode = nil then
    begin
      Memo.Lines.Add('Erro: nó infNFe não encontrado no XML.');
      Exit;
    end;
     // AQUI VEM A LEITURA DO NUMERO DA NOTA
    ideNode := FindNodeInsensitive(InfNFeNode, 'ide');
    if Assigned(ideNode) then
      NumeroNota := VarToStrDef(ideNode.ChildValues['nNF'], '')
    else
      Memo.Lines.Add('Aviso: nó ide ou campo nNF não encontrado.');
    NodeList := InfNFeNode.ChildNodes;
    if (NodeList = nil) or (NodeList.Count = 0) then
    begin
      Memo.Lines.Add('Erro: nó infNFe sem filhos.');
      Exit;
    end;

    // Leitura dados do fornecedor (emitente)
    emitNode := InfNFeNode.ChildNodes.FindNode('emit');
    if Assigned(emitNode) then
    begin
      emit_CNPJ  := VarToStrDef(emitNode.ChildValues['CNPJ'], '');
      emit_xNome := VarToStrDef(emitNode.ChildValues['xNome'], '');
      emit_xFant := VarToStrDef(emitNode.ChildValues['xFant'], '');
      emit_IE    := VarToStrDef(emitNode.ChildValues['IE'], '');

      enderEmitNode := emitNode.ChildNodes.FindNode('enderEmit');
      if Assigned(enderEmitNode) then
      begin
        emit_endereco := VarToStrDef(enderEmitNode.ChildValues['xLgr'], '') + ', ' +
                         VarToStrDef(enderEmitNode.ChildValues['nro'], '') + ' - ' +
                         VarToStrDef(enderEmitNode.ChildValues['xBairro'], '') + ' - ' +
                         VarToStrDef(enderEmitNode.ChildValues['xMun'], '') + '/' +
                         VarToStrDef(enderEmitNode.ChildValues['UF'], '');
        emit_fone := VarToStrDef(enderEmitNode.ChildValues['fone'], '');
      end;
    end else
      Memo.Lines.Add('Aviso: nó emit não encontrado.');

    if not cdsXML.Active then
      cdsXML.Open;
    cdsXML.EmptyDataSet;

    for i := 0 to InfNFeNode.ChildNodes.Count - 1 do
    begin
      NodeDet := InfNFeNode.ChildNodes[i];
      if (NodeDet.NodeName = 'det') and (NodeDet.HasChildNodes) then
      begin
        NodeProd := NodeDet.ChildNodes.FindNode('prod');
        if Assigned(NodeProd) then
        begin
          try
            // Campos básicos
            cProd := VarToStrDef(NodeProd.ChildValues['cProd'], '');
            xProd := VarToStrDef(NodeProd.ChildValues['xProd'], '');
            cEAN  := VarToStrDef(NodeProd.ChildValues['cEAN'], '');
            NCM   := VarToStrDef(NodeProd.ChildValues['NCM'], '');
            uCom  := VarToStrDef(NodeProd.ChildValues['uCom'], '');

            // Quantidade e valores
            qCom   := StrToFloatDef(StringReplace(VarToStr(NodeProd.ChildValues['qCom']), '.', ',', [rfReplaceAll]), 0);
            vUnCom := StrToFloatDef(StringReplace(VarToStr(NodeProd.ChildValues['vUnCom']), '.', ',', [rfReplaceAll]), 0);
            vProd  := StrToFloatDef(StringReplace(VarToStr(NodeProd.ChildValues['vProd']), '.', ',', [rfReplaceAll]), 0);

            // infAdProd (lote/validade)
            infAdProd := VarToStrDef(NodeDet.ChildValues['infAdProd'], '');
            lote := '';
            validade := '';
            if infAdProd <> '' then
            begin
              if Pos('Lote:', infAdProd) > 0 then
                lote := Trim(Copy(infAdProd, Pos('Lote:', infAdProd) + 5,
                                 Pos(' - Val:', infAdProd) - (Pos('Lote:', infAdProd) + 5)));
              if Pos('Val:', infAdProd) > 0 then
                validade := Trim(Copy(infAdProd, Pos('Val:', infAdProd) + 4, 11));
            end;

            cdsXML.Append;
            cdsXML.FieldByName('Selecionar').AsBoolean := False;
            cdsXML.FieldByName('cEAN').AsString := cEAN;
            cdsXML.FieldByName('cProd').AsString := cProd;
            cdsXML.FieldByName('xProd').AsString := xProd;
            cdsXML.FieldByName('NCM').AsString := NCM;
            cdsXML.FieldByName('qCom').AsFloat := qCom;
            cdsXML.FieldByName('uCom').AsString := uCom;
            cdsXML.FieldByName('vUnCom').AsFloat := vUnCom;
            cdsXML.FieldByName('vProd').AsFloat := vProd;
            cdsXML.FieldByName('lote').AsString := lote;
            cdsXML.FieldByName('Numero_NF').AsString := NumeroNota;
            cdsXML.FieldByName('validade').AsString := validade;

            // Leitura do CST ICMS (se existir)
            NodeImposto := NodeDet.ChildNodes.FindNode('imposto');
            if Assigned(NodeImposto) then
            begin
              NodeICMS := NodeImposto.ChildNodes.FindNode('ICMS');
              if Assigned(NodeICMS) and (NodeICMS.ChildNodes.Count > 0) then
              begin
                NodeICMSTipo := NodeICMS.ChildNodes[0]; // Pode ser ICMS00, ICMS10, etc.
                if NodeICMSTipo.HasChildNodes then
                  cdsXML.FieldByName('CST').AsString := VarToStrDef(NodeICMSTipo.ChildValues['CST'], '');
              end;
            end;

            // Dados do fornecedor (emitente)
            cdsXML.FieldByName('emit_CNPJ').AsString := emit_CNPJ;
            cdsXML.FieldByName('emit_xNome').AsString := emit_xNome;
            cdsXML.FieldByName('emit_xFant').AsString := emit_xFant;
            cdsXML.FieldByName('emit_IE').AsString := emit_IE;
            cdsXML.FieldByName('emit_fone').AsString := emit_fone;
            cdsXML.FieldByName('emit_endereco').AsString := emit_endereco;

            cdsXML.Post;
          except
            on E: Exception do
              Memo.Lines.Add('Erro ao processar produto: ' + E.Message);
          end;
        end
        else
          Memo.Lines.Add('Aviso: nó prod não encontrado em det.');
      end;
    end;

  except
    on E: Exception do
      Memo.Lines.Add('Erro geral: ' + E.Message);
  end;
end;

procedure TFrm_lerXML.btLogClick(Sender: TObject);
var
dData: TDateTime;
vTipo, vDescricao, vNumeronf, vCnpjemit, vBarras: String;
begin
  pnl_logerro.Visible := True;
	QryLogErro.Open;
  With QryLogErro do
  Begin
    close;
    SQL.Clear;
    SQL.Add('Select * from Log_erros_import order by data_erro desc');
    open;
  End;
  while not QryLogErro.Eof do
  Begin
    dData := QryLogErro.FieldByName('data_erro').AsDateTime;
    vTipo := QryLogErro.FieldByName('tipo_erro').AsString;
    vDescricao := QryLogErro.FieldByName('descricao').AsString;
    vNumeronf := QryLogErro.FieldByName('numero_nf').AsString;
    vCnpjemit := QryLogErro.FieldByName('cnpj_emitente').AsString;
    vBarras := QryLogErro.FieldByName('cprod').AsString;

    Memo_erros.Lines.add(FormatDateTime('dd/mm/yyyy hh:nn:ss', dData) + ' |  '+
       vTipo + vNumeronf + ' | ' + vBarras + ' | ' + vCnpjemit);
    Memo_erros.Lines.Add(Copy(vDescricao,76));
    Memo_erros.Lines.Add('');
    QryLogErro.Next;
  End;
end;

procedure TFrm_lerXML.chkSelecionarTodosClick(Sender: TObject);
var
  valor: Boolean;
begin
  valor := chkSelecionarTodos.Checked;

  cdsXML.DisableControls;
  try
    cdsXML.First;
    while not cdsXML.Eof do
    begin
      cdsXML.Edit;
      cdsXML.FieldByName('Selecionar').AsBoolean := valor;
      cdsXML.Post;
      cdsXML.Next;
    end;
  finally
    cdsXML.EnableControls;
  end;
end;


procedure TFrm_lerXML.dbgXMLCellClick(Column: TColumn);
begin
  if Column.Field.FieldName = 'Selecionar' then
  begin
    cdsXML.Edit;
    cdsXML.FieldByName('Selecionar').AsBoolean := not cdsXML.FieldByName('Selecionar').AsBoolean;
    cdsXML.Post;
  end;
end;

procedure TFrm_lerXML.dbgXMLDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  CheckRect: TRect;
  DrawStyle: Integer;
begin
  if Column.FieldName = 'Selecionar' then
  begin
    // Apaga o conteúdo da célula
    dbgXML.Canvas.FillRect(Rect);

    // Centraliza o checkbox na célula
    CheckRect.Left := Rect.Left + (Rect.Width div 2) - 8;
    CheckRect.Top := Rect.Top + (Rect.Height div 2) - 8;
    CheckRect.Right := CheckRect.Left + 16;
    CheckRect.Bottom := CheckRect.Top + 16;

    // Define estado do checkbox
    if Column.Field.AsBoolean then
      DrawStyle := DFCS_BUTTONCHECK or DFCS_CHECKED
    else
      DrawStyle := DFCS_BUTTONCHECK;

    // Desenha o checkbox
    DrawFrameControl(dbgXML.Canvas.Handle, CheckRect, DFC_BUTTON, DrawStyle);
  end
  else
    dbgXML.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

function TFrm_lerXML.FindNodeInsensitive(Parent: IXMLNode;
  const NodeName: string): IXMLNode;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Parent.ChildNodes.Count - 1 do
    if UpperCase(Parent.ChildNodes[i].NodeName) = UpperCase(NodeName) then
    begin
      Result := Parent.ChildNodes[i];
      Exit;
    end;
end;

procedure TFrm_lerXML.FormShow(Sender: TObject);
begin
  QryLogErro.Open;
  with cdsXML do
  begin
    Close;
    FieldDefs.Clear;
    FieldDefs.Add('Selecionar', ftBoolean);
    FieldDefs.Add('cEAN', ftString, 20);
    FieldDefs.Add('cProd', ftString, 20);
    FieldDefs.Add('xProd', ftString, 100);
    FieldDefs.Add('NCM', ftString, 10);
    FieldDefs.Add('qCom', ftFloat);
    FieldDefs.Add('uCom', ftString, 5);
    FieldDefs.Add('vUnCom', ftFloat);
    FieldDefs.Add('vProd', ftFloat);
    FieldDefs.Add('lote', ftString, 20);
    FieldDefs.Add('Numero_NF', ftString, 20);
    FieldDefs.Add('validade', ftString, 10);
    FieldDefs.Add('CST', ftString, 3);
    // --- Dados do Fornecedor (emitente)
    FieldDefs.Add('emit_CNPJ', ftString, 20);
    FieldDefs.Add('emit_xNome', ftString, 100);
    FieldDefs.Add('emit_xFant', ftString, 100);
    FieldDefs.Add('emit_IE', ftString, 20);
    FieldDefs.Add('emit_fone', ftString, 20);
    FieldDefs.Add('emit_endereco', ftString, 150);
    CreateDataSet;
    Open;
  end;
end;

procedure TFrm_lerXML.LogErroImportacao(const TipoErro, Descricao, NumeroNF,
  CNPJ, cProd: string);
begin
  QryLogErro.Close;
  QryLogErro.SQL.Text :=
    'INSERT INTO log_erros_import (tipo_erro, descricao, numero_nf, cnpj_emitente, cprod, usuario) ' +
    'VALUES (:tipo_erro, :descricao, :numero_nf, :cnpj_emitente, :cprod, :usuario)';

  QryLogErro.ParamByName('tipo_erro').AsString := TipoErro;
  QryLogErro.ParamByName('descricao').AsString := Descricao;
  QryLogErro.ParamByName('numero_nf').AsString := NumeroNF;
  QryLogErro.ParamByName('cnpj_emitente').AsString := CNPJ;
  QryLogErro.ParamByName('cprod').AsString := cProd;
  QryLogErro.ParamByName('usuario').AsString := 'Importador'; // Substitua se tiver login

  QryLogErro.ExecSQL;
end;

procedure TFrm_lerXML.SpeedButton2Click(Sender: TObject);
begin
	pnl_logerro.Visible := False;
end;

procedure TFrm_lerXML.XClick(Sender: TObject);
begin
   Frm_lerXML.Close;
end;

end.
