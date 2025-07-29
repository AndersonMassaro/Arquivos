unit U_CurvaABC;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, ComObj, FireDAC.Comp.Client,
  Vcl.Imaging.pngimage;

type
  TFrm_RelatorioABC = class(TForm)
    pnl_fundo: TPanel;
    dtInicial: TDateTimePicker;
    dtFinal: TDateTimePicker;
    btVisualizar: TSpeedButton;
    DBGrid1: TDBGrid;
    pnltopo: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog: TSaveDialog;
    btImprimir: TSpeedButton;
    btExportarExcel: TSpeedButton;
    Label3: TLabel;
    X: TPanel;
    btDuvidaApaga: TSpeedButton;
    Image: TImage;
    btDuvidaAcende: TSpeedButton;
    procedure btVisualizarClick(Sender: TObject);
    procedure PrepararConsulta;
    procedure ExportarCurvaABCParaExcel(QryCurvaABC: TFDQuery);
    procedure btExportarExcelClick(Sender: TObject);
    function ColToLetter(Col: Integer): string;
    procedure XClick(Sender: TObject);
    procedure btDuvidaApagaClick(Sender: TObject);
    procedure btDuvidaAcendeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Frm_RelatorioABC: TFrm_RelatorioABC;

implementation

{$R *.dfm}

uses U_dm;


procedure TFrm_RelatorioABC.ExportarCurvaABCParaExcel(QryCurvaABC: TFDQuery);
var
  Excel, Workbook, Worksheet: Variant;
  i, j: Integer;
  SaveDialog: TSaveDialog;
  Classe, StartCell, EndCell: string;
  LastCol: Integer;
begin
  if QryCurvaABC.IsEmpty then
  begin
    ShowMessage('Nenhum dado para exportar.');
    Exit;
  end;

  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.Filter := 'Arquivo Excel (*.xlsx)|*.xlsx';
    SaveDialog.DefaultExt := 'xlsx';
    SaveDialog.FileName := 'Curva_ABC_' + FormatDateTime('yyyymmdd_hhnn', Now) + '.xlsx';

    if not SaveDialog.Execute then
      Exit;

    Excel := CreateOleObject('Excel.Application');
    Workbook := Excel.Workbooks.Add;
    Worksheet := Workbook.Worksheets[1];

    // Escreve cabeçalhos
    for i := 0 to QryCurvaABC.FieldCount - 1 do
      Worksheet.Cells[1, i + 1] := QryCurvaABC.Fields[i].DisplayLabel;

    LastCol := QryCurvaABC.FieldCount;

    // Escreve dados e aplica cor por classe
    QryCurvaABC.First;
    j := 2;
    while not QryCurvaABC.Eof do
    begin
      for i := 0 to QryCurvaABC.FieldCount - 1 do
        Worksheet.Cells[j, i + 1] := QryCurvaABC.Fields[i].AsString;

      Classe := UpperCase(QryCurvaABC.FieldByName('ClasseABC').AsString);

      StartCell := 'A' + IntToStr(j);
      EndCell := ColToLetter(LastCol) + IntToStr(j);

      if Classe = 'A' then
        Worksheet.Range[StartCell + ':' + EndCell].Interior.Color := $CCFFCC  // verde claro
      else if Classe = 'B' then
        Worksheet.Range[StartCell + ':' + EndCell].Interior.Color := $FFFFCC  // amarelo claro
      else if Classe = 'C' then
        Worksheet.Range[StartCell + ':' + EndCell].Interior.Color := $FFCCCC; // vermelho claro

      Inc(j);
      QryCurvaABC.Next;
    end;

    Worksheet.Columns.AutoFit;

    Workbook.SaveAs(SaveDialog.FileName);
    Workbook.Close(False);
    Excel.Quit;

    ShowMessage('Exportação para Excel concluída com sucesso: ' + SaveDialog.FileName);

  finally
    SaveDialog.Free;
  end;
end;
procedure TFrm_RelatorioABC.PrepararConsulta;
begin
  Dm.QryCurvaABC.Close;
  Dm.QryCurvaABC.SQL.Clear;
  Dm.QryCurvaABC.SQL.Text :=
  'WITH Vendas AS ( ' +
  '  SELECT ' +
  '    P.Prod_cod_barras AS Cxf_barras, ' +  // Código de barras
  '    Cxf_prodid, ' +
  '    P.Prod_desc_prod, ' +
  '    SUM(Cxf_quant) AS Quantidade, ' +
  '    SUM(Cxf_vltotal) AS TotalVendido, ' +
  '    SUM(Cxf_vltotal - (Cxf_custo * Cxf_quant)) AS LucroBruto ' +
  '  FROM CaixaFechado CF ' +
  '  JOIN Produto P ON CF.Cxf_prodid = P.Prod_id ' +
  '  WHERE Cxf_status = ''1'' ' +
  '    AND CF.Cxf_dtvenda BETWEEN :DataInicial AND :DataFinal ' +
  '  GROUP BY Cxf_prodid, P.Prod_desc_prod, P.Prod_cod_barras ' +
  '), ' +
  'Totais AS ( ' +
  '  SELECT SUM(TotalVendido) AS SomaTotal FROM Vendas ' +
  '), ' +
  'CurvaABC AS ( ' +
  '  SELECT *, ' +
  '    (TotalVendido / T.SomaTotal) * 100.0 AS Percentual, ' +
  '    SUM((TotalVendido / T.SomaTotal) * 100.0) OVER (ORDER BY TotalVendido DESC) AS PercentualAcumulado ' +
  '  FROM Vendas ' +
  '  CROSS JOIN Totais T ' +
  ') ' +
  'SELECT ' +
  '  Cxf_prodid AS Codigo, ' +
  '  Cxf_barras AS CodigoBarras, ' + // Mostra o código de barras
  '  Prod_desc_prod AS Produto, ' +
  '  Quantidade, ' +
  '  TotalVendido, ' +
  '  LucroBruto, ' +
  '  PercentualAcumulado, ' +
  '  CASE ' +
  '    WHEN PercentualAcumulado <= 70 THEN ''A'' ' +
  '    WHEN PercentualAcumulado <= 90 THEN ''B'' ' +
  '    ELSE ''C'' ' +
  '  END AS ClasseABC ' +
  'FROM CurvaABC ' +
  'ORDER BY TotalVendido DESC';

  Dm.QryCurvaABC.ParamByName('DataInicial').AsDate := dtInicial.Date;
  Dm.QryCurvaABC.ParamByName('DataFinal').AsDate := dtFinal.Date;
  Dm.QryCurvaABC.Open;
end;

procedure TFrm_RelatorioABC.XClick(Sender: TObject);
begin
  Frm_RelatorioABC.Close;
end;

procedure TFrm_RelatorioABC.btDuvidaAcendeClick(Sender: TObject);
begin
	image.Visible := False;
  dbgrid1.Visible := True;
  btDuvidaApaga.Visible := True;
  btDuvidaAcende.Visible := False;

end;

procedure TFrm_RelatorioABC.btDuvidaApagaClick(Sender: TObject);
begin
  dbgrid1.Visible := False;
	image.Visible := True;
  btDuvidaApaga.Visible := False;
  btDuvidaAcende.Visible := True;
end;

procedure TFrm_RelatorioABC.btExportarExcelClick(Sender: TObject);
begin
   ExportarCurvaABCParaExcel(Dm.QryCurvaABC);
end;

procedure TFrm_RelatorioABC.btVisualizarClick(Sender: TObject);
begin
  PrepararConsulta;
//  Dm.frxReportABC.LoadFromFile('E:\sistemas_pdv\Rel\Relatorio_CurvaABC.fr3');
//  Dm.frxReportABC.ShowReport;
end;

function TFrm_RelatorioABC.ColToLetter(Col: Integer): string;
var
  Remainder: Integer;
begin
  Result := '';
  while Col > 0 do
  begin
    Remainder := (Col - 1) mod 26;
    Result := Chr(65 + Remainder) + Result;
    Col := (Col - 1) div 26;
  end;
end;

end.
