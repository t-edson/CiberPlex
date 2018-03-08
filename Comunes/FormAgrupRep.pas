unit FormAgrupRep;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, dateutils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, StdCtrls, ExtCtrls, Grids, LCLProc, Buttons,
  RegistrosVentas, UtilsGrilla;
type
  TEvEjecReporte = procedure(Sender: TObject) of object;

  { TfrmAgrupRep }
  TfrmAgrupRep = class(TForm)
    BitBtn1: TBitBtn;
    btnReporte: TBitBtn;
    chkIncDia: TCheckBox;
    chkIncSemana1: TCheckBox;
    chkIncTotHoriz: TCheckBox;
    chkIncTotVert: TCheckBox;
    chkMesIncMes: TCheckBox;
    chkIncSemana: TCheckBox;
    chkIncMes: TCheckBox;
    chkMesIncAno: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    procedure btnReporteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    col_sem, col_mes, col_diasem, col_ano : word;
  public
    agrVert: TAgrVer;  //tipo de agrupamiento vertical
    OnExecReporte: TEvEjecReporte;
    catsHor: TStringList;   //valores de dispersión horizontal
    catsVer: TStringList;   //valores de dispersión vertical
    function VerifCamposAdic_Dia(griAgrupados: TUtilGrilla; colIni: integer): integer;
    function VerifCamposAdic_Mes(griAgrupados: TUtilGrilla; colIni: integer): integer;
    function VerifCamposAdic(griAgrupados: TUtilGrilla): integer;
    function EncabezadosHoriz(griAgrupados: TUtilGrilla; grilla: TStringGrid
      ): integer;
    function CamposHoriz(grilla: TStringGrid; fil: integer): TCPCellValues;
    procedure EscribirCamposAdic_Dia(const fecStr: string; grilla: TStringGrid;
      const fil: integer);
    procedure EscribirCamposAdic_Mes(const fecStr: string; grilla: TStringGrid;
      const fil: integer);
    procedure EscribirCamposAdic(const fecStr: string; grilla: TStringGrid;
      const fil: integer);
    function CreaCategoriaHoriz(const categ: string): integer;
    procedure LimpiarCategoriasVert;
    function UbicarFechaVertic(fec: TDateTime): TCPCellValues;
  end;

var
  frmAgrupRep: TfrmAgrupRep;



implementation
{$R *.lfm}
{ TfrmAgrupRep }
procedure TfrmAgrupRep.btnReporteClick(Sender: TObject);
begin
  if OnExecReporte<>nil then OnExecReporte(self);
end;
procedure TfrmAgrupRep.FormCreate(Sender: TObject);
begin
  catsHor:= TStringList.Create;   //valores de dispersión horizontal
  catsVer:= TStringList.Create;   //valores de dispersión vertical
  catsHor.Sorted:=false;   //Así trabaja CreaCategoriaHoriz()
  catsVer.Sorted:=true;
end;
procedure TfrmAgrupRep.FormDestroy(Sender: TObject);
begin
  catsHor.Destroy;
  catsVer.Destroy;
end;
function TfrmAgrupRep.VerifCamposAdic_Dia(griAgrupados: TUtilGrilla; colIni: integer): integer;
{Agrega los campos adicionales en "griAgrupados", cuando el agrupamiento es por días.
Devuelve la cantidad de campos adicionales agregados. "colIni", es la
columna inicial en donde deben agregarse los campos.}
begin
  Result := 0;
  griAgrupados.AgrEncabTxt('SEMANA', 50).visible := false;
  col_sem := colIni + Result;  //gaurda psoición de campo
  inc(Result);
  griAgrupados.AgrEncabTxt('MES', 50).visible := false;
  col_mes := colIni + Result;  //gaurda psoición de campo
  inc(Result);
  griAgrupados.AgrEncabTxt('DÍA SEMANA', 50).visible := false;
  col_diasem := colIni + Result;  //gaurda psoición de campo
  inc(Result);
end;
function TfrmAgrupRep.VerifCamposAdic_Mes(griAgrupados: TUtilGrilla; colIni: integer): integer;
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
function TfrmAgrupRep.VerifCamposAdic(griAgrupados: TUtilGrilla): integer;
{Agrega los campos de fecha adicionales, a la grilla, de acuerdo a lo que se haya
seleccionado en los controles.
Devuelve la primera columna libre, para agregar contadores.}
var
  colIni: Integer;
begin
  colIni := griAgrupados.cols.Count;  //apunta a la siguiente columna libre
  //Agrega encabezados, de acuerdo al tipo
  case agrVert of
  tavDia: Result := colIni + VerifCamposAdic_Dia(griAgrupados, colIni);
  tavSem: Result := colIni;  //no hay campos adicionales
  tavMes: Result := colIni + VerifCamposAdic_Mes(griAgrupados, colIni);
  tavTot: Result := colIni;  //no hay campos adicionales
  else  //No debería pasar
    Result := colIni;  //no hay campos adicionales
  end;
  //Agrega encabezados de
end;
procedure TfrmAgrupRep.EscribirCamposAdic_Dia(const fecStr: string; grilla: TStringGrid;
   const fil: integer);
{Escribe los campos adicionales indicados, en la grilla, en la fila "fil".
Debe llamarse después de haber fijado las columans adicionales con "VerifCamposAdic_Dia".}
var
  fec, fec2: TDateTime;
  numAno, numSem: Word;
  tmp: String;
begin
  fec := EncodeDate(StrToInt(copy(fecStr,1,4)), StrToInt(copy(fecStr,6,2)), StrToInt(copy(fecStr,9,2)));
  fec2 := fec-ComboBox1.ItemIndex+6;  //corrección de inicio de semana
  numSem := WeekOfTheYear(fec2, numAno);
  tmp := Format('%d-%.2d', [numAno, numSem]);
  grilla.Cells[col_sem, fil] := tmp;  //semana
  DateTimeToString(tmp, 'yyyy-mm', fec);  //agrupa por fecha
  grilla.Cells[col_mes, fil] := tmp;  //semana
  DateTimeToString(tmp, 'ddd', fec);  //agrupa por fecha
  grilla.Cells[col_diasem, fil] := tmp;  //semana
end;
procedure TfrmAgrupRep.EscribirCamposAdic_Mes(const fecStr: string; grilla: TStringGrid;
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
procedure TfrmAgrupRep.EscribirCamposAdic(const fecStr: string;
  grilla: TStringGrid; const fil: integer);
begin
  case agrVert of
  tavDia: EscribirCamposAdic_Dia(fecStr, grilla, fil);
  tavSem: ;  //no hay campos adicionales
  tavMes: EscribirCamposAdic_Mes(fecStr, grilla, fil);
  tavTot: ;  //no hay campos adicionales
  end;
end;
function TfrmAgrupRep.EncabezadosHoriz(griAgrupados: TUtilGrilla;
  grilla: TStringGrid): integer;
{Llena todos los encabezados horizontales de una grilla, considerando:
1. El primer campo es siempre un ordinal.
2. El segundo campo es una fecha.
3. Pueden haber campos adicionales de fecha despues.
4. Los campos de "catsHor0", se llenarán después.
5. Si corresponde, se agregará un campo de TOTAL.

          +------------------+-------------------------------+
          | Campos de Fecha  | Campos de "catsHor0"  |  Total |
          +------------------+-------------------------------+
                              ^
                              |
Result ------------------------

Devuelve la columna en donde empiezan los contadores.
}
var
  c: Integer;
begin
  griAgrupados.IniEncab;
  griAgrupados.AgrEncabNum('N°'       , 30);
  griAgrupados.AgrEncabTxt('FECHA'    , 70); //Campo Fecha
  Result := VerifCamposAdic(griAgrupados);
  //Dispersión horizontal de categorías horizontales
  for c:=0 to catsHor.Count-1 do begin
    griAgrupados.AgrEncabNum(catsHor[c], 55);
  end;
  if chkIncTotHoriz.Checked then begin
    griAgrupados.AgrEncabNum('TOTAL'    , 70); //campo final
  end;
  griAgrupados.FinEncab(false);  //sin actualizar aún
  griAgrupados.AsignarGrilla(grilla);  //actualiza
end;
function TfrmAgrupRep.CamposHoriz(grilla: TStringGrid; fil: integer): TCPCellValues;
{Agrega campos horizontales, en la fila indicada.}
var
  fecStr: String;
begin
  // cáculo de campos agrupados
  fecStr := catsVer[fil-1];
  grilla.Cells[1, fil] := fecStr;  //Campo Fecha
  EscribirCamposAdic(fecStr, grilla, fil);
  //Devuelve la referencia a la lista de valores.
  Result := TCPCellValues(catsVer.Objects[fil-1]);
end;
function TfrmAgrupRep.CreaCategoriaHoriz(const categ: string): integer;
{Busca un valor en catsHor0. Si no existe, lo agrega. Devuelve el índice de su
posición.
Se usa esta rutina en lugar de Find(), porque se probó que es más rápida (al menos para
pocos grupos) y a la vez facilita reusar el código. Sin embargo, a diferencia de Fins(),
no se ordenan los encabezados.}
var
  i: Integer;
begin
  //Busca campo
  for i:=0 to catsHor.Count-1 do begin
    if catsHor[i] = categ then begin
      //Ya existe campo, solo devuelve el índice.
      exit(i);
    end;
  end;
  //No existe
  catsHor.Add(categ);
  Result := catsHor.Count-1;
end;
procedure TfrmAgrupRep.LimpiarCategoriasVert;
{Limpia la lista de categorías verticales}
var
  i: Integer;
begin
  //Libera objetos de celdas
  for i:=0 to catsVer.Count-1 do begin
    catsVer.Objects[i].Destroy;
  end;
  catsVer.Clear;
end;
function TfrmAgrupRep.UbicarFechaVertic(fec: TDateTime): TCPCellValues;
{Recibe una fecha y la agrupa verticalmente en "catsVer0", de acuerdo a "agrVert".
Devuelve la referencia al objeto "TCPCellValues", de la fila usada para acomodar la fecha.
La idea es que los campos de fecha, se ubiquen siempre verticalmente, en el StringList
"agrVert".

  "catsVer0"
+-----------+
|           | -> objetos: TCPCellValues
|-----------|
|           | -> objetos: TCPCellValues
|-----------|
|           | -> objetos: TCPCellValues
|-----------|
|           | -> objetos: TCPCellValues
|-----------|
|           | -> objetos: TCPCellValues
+-----------+
Notar que los elementos de "catsVer0", están ordenados.
}
var
  fecAgrup: String;
  i, idx: Integer;
begin
  //Obtiene la cadena que representa al día, semana, mes o total
  fecAgrup := FechaACad(fec, agrVert, ComboBox2.ItemIndex);
   //Verifica si "fecAgrup" ya existe en alguna de las veldas verticales
  if catsVer.Find(fecAgrup, i) then begin
    //Ya existe en "i"
    Result := TCPCellValues(catsVer.Objects[i]);
  end else begin
    //Es nuevo, se debe crear
    idx := catsVer.Add(fecAgrup);   //Agrega y lee posición
    Result := TCPCellValues.Create(CatsHor.Count);  //crea objeto
    catsVer.Objects[idx] := Result;  //guarda la referencia
  end;
  //Actualiza la lista de fechas de "Result", para el cálculo del número de días.
  Result.RegistrarFecha(fec, agrVert, fecAgrup);
end;

end.

