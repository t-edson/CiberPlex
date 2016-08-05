unit FormAgrupVert;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, dateutils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, StdCtrls, ButtonPanel, ExtCtrls, Grids, LCLProc, UtilsGrilla;
type

  { TfrmAgrupVert }

  TfrmAgrupVert = class(TForm)
    ButtonPanel1: TButtonPanel;
    chkIncDia: TCheckBox;
    chkMesIncMes: TCheckBox;
    chkIncSemana: TCheckBox;
    chkIncMes: TCheckBox;
    chkMesIncAno: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
  private
    col_sem, col_mes, col_diasem, col_ano : word;
  public
    function VerifCamposAdic_Dia(griAgrupados: TUtilGrilla; colIni: integer
      ): integer;
    procedure EscribirCamposAdic_Dia(const fecStr: string; grilla: TStringGrid;
      const fil: integer);
    function VerifCamposAdic_Mes(griAgrupados: TUtilGrilla; colIni: integer
      ): integer;
    procedure EscribirCamposAdic_Mes(const fecStr: string; grilla: TStringGrid;
      const fil: integer);
  end;

var
  frmAgrupVert: TfrmAgrupVert;

implementation

{$R *.lfm}
{ TfrmAgrupVert }
function TfrmAgrupVert.VerifCamposAdic_Dia(griAgrupados: TUtilGrilla; colIni: integer): integer;
{Verifica si se han seleccionado campos adicionales a la fecha para agregarlos a la
grilla. Si se seleccionan campos adicionales, crea los encabezados respectivos en
"griAgrupados". Devuelve la cantidad de campos adicionales agregados. "colIni", es la
columna inicial en donde deben agregarse los campos.}
begin
  Result := 0;
  if chkIncSemana.Checked then begin
    griAgrupados.AgrEncabTxt('SEMANA', 50);
    col_sem := colIni + Result;  //gaurda psoición de campo
    inc(Result);
  end;
  if chkIncMes.Checked then begin
    griAgrupados.AgrEncabTxt('MES', 50);
    col_mes := colIni + Result;  //gaurda psoición de campo
    inc(Result);
  end;
  if chkIncDia.Checked then begin
    griAgrupados.AgrEncabTxt('DÍA SEMANA', 50);
    col_diasem := colIni + Result;  //gaurda psoición de campo
    inc(Result);
  end;
end;

procedure TfrmAgrupVert.EscribirCamposAdic_Dia(const fecStr: string; grilla: TStringGrid;
   const fil: integer);
{Escribe los campos adicionales indicados, en la grilla, en la fila "fil".
Debe llamarse después de haber fijado las columans adicionales con "VerifCamposAdic_Dia".}
var
  fec, fec2: TDateTime;
  numAno, numSem: Word;
  tmp: String;
begin
  fec := EncodeDate(StrToInt(copy(fecStr,1,4)),
                    StrToInt(copy(fecStr,6,2)),
                    StrToInt(copy(fecStr,9,2)));
  if chkIncSemana.Checked then begin
    fec2 := fec-ComboBox1.ItemIndex+6;  //corrección de inicio de semana
    numSem := WeekOfTheYear(fec2, numAno);
    tmp := Format('%d-%.2d', [numAno, numSem]);
    grilla.Cells[col_sem, fil] := tmp;  //semana
  end;
  if chkIncMes.Checked then begin
    DateTimeToString(tmp, 'yyyy-mm', fec);  //agrupa por fecha
    grilla.Cells[col_mes, fil] := tmp;  //semana
  end;
  if chkIncDia.Checked then begin
    DateTimeToString(tmp, 'ddd', fec);  //agrupa por fecha
    grilla.Cells[col_diasem, fil] := tmp;  //semana
  end;
end;

function TfrmAgrupVert.VerifCamposAdic_Mes(griAgrupados: TUtilGrilla; colIni: integer): integer;
{Verifica si se han seleccionado campos adicionales a la fecha para agregarlos a la
grilla. Si se seleccionan campos adicionales, crea los encabezados respectivos en
"griAgrupados". Devuelve la cantidad de campos adicionales agregados. "colIni", es la
columna inicial en donde deben agregarse los campos.}
begin
  Result := 0;
  if chkMesIncAno.Checked then begin
    griAgrupados.AgrEncabTxt('AÑO', 50);
    col_ano := colIni + Result;  //gaurda psoición de campo
    inc(Result);
  end;
  if chkMesIncMes.Checked then begin
    griAgrupados.AgrEncabTxt('MES', 50);
    col_mes := colIni + Result;  //gaurda psoición de campo
    inc(Result);
  end;
end;

procedure TfrmAgrupVert.EscribirCamposAdic_Mes(const fecStr: string; grilla: TStringGrid;
   const fil: integer);
{Escribe los campos adicionales indicados, en la grilla, en la fila "fil".
Debe llamarse después de haber fijado las columans adicionales con "VerifCamposAdic_Mes".}
var
  fec: TDateTime;
  tmp: String;
begin
  fec := EncodeDate(StrToInt(copy(fecStr,1,4)),
                    StrToInt(copy(fecStr,6,2)), 1);
  if chkMesIncAno.Checked then begin
    DateTimeToString(tmp, 'yyyy', fec);  //agrupa por fecha
    grilla.Cells[col_ano, fil] := tmp;  //semana
  end;
  if chkIncMes.Checked then begin
    DateTimeToString(tmp, 'mm', fec);  //agrupa por fecha
    grilla.Cells[col_mes, fil] := tmp;  //semana
  end;
end;
end.

