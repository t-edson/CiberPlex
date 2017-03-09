unit FormRepEventos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, dateutils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, EditBtn, Grids, Menus, ActnList, LCLProc, ComCtrls,
  Clipbrd, Globales, RegistrosVentas, FormAgrupVert,
  UtilsGrilla, MisUtils;
type

  { TfrmRepEventos }
  TfrmRepEventos = class(TForm)
  published
    acGenCopTod: TAction;
    ActionList1: TActionList;
    Button1: TButton;
    btnConfig: TButton;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    optDia: TRadioButton;
    optSem: TRadioButton;
    optMes: TRadioButton;
    StatusBar1: TStatusBar;
    TipoReg: TCheckGroup;
    dat1: TDateEdit;
    dat2: TDateEdit;
    grilla: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    procedure acGenCopTodExecute(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure optDiaChange(Sender: TObject);
    procedure optMesChange(Sender: TObject);
    procedure optSemChange(Sender: TObject);
  private
    regs: regEven_list;
    agrVert: TAgrVer;  //agrupamiento vertical
    griRegistros : TUtilGrilla;
    griAgrupados : TUtilGrilla;
    catsHor: TStringList;   //valores de dispersión horizontal
    catsVer: TStringList;   //valores de dispersión vertical
    procedure CreaCategoriasHoriz(campo: integer);
    function DoReqCadMoneda(valor: double): string;
    function FilaComoTexto(f: integer): string;
    procedure LimpiarCategoriasVert;
    procedure LLenarGrilla(conColSem: boolean);
    procedure LlenarRegistro(f: integer; reg: regEven);
    procedure ReporteAgrupado(agrupVert: TAgrVer);
    procedure ReporteRegistros;
  public
    local: string;
    OnReqCadMoneda: TevReqCadMoneda;
    procedure Exec(Alocal: string);
  end;

var
  frmRepEventos: TfrmRepEventos;

implementation
{$R *.lfm}
{ TfrmRepEventos }
procedure TfrmRepEventos.LlenarRegistro(f: integer; reg: regEven);
{Llena los datos de un registro en una fila de la grilla}
begin
  grilla.Cells[1, f] := reg.ident;
  grilla.Cells[2, f] := reg.serie;
  grilla.Cells[3, f] := reg.FECHA_LOG_str;
  //grilla.Cells[4, f] := reg.FECHA_LOG_str;
  grilla.Cells[5, f] := reg.USUARIO;
  grilla.Cells[6, f] := reg.descrip;
end;
procedure TfrmRepEventos.ReporteRegistros;
{Genera el reporte detallado, usando la lista de registros "regs".}
var
  f: Integer;
  reg: regEven;

begin
  //LLena grilla
  //DbgOut('Llenando grilla...');
  griRegistros.AsignarGrilla(grilla);
  grilla.BeginUpdate;
  grilla.RowCount:=1+regs.Count;  //hace espacio
  f := 1;
  for reg in regs do begin
    LlenarRegistro(f, reg);
    inc(f);
  end;
  grilla.EndUpdate();
  //consoleTickCount('');
  StatusBar1.Panels[1].Text:='Num. Registros= ' + IntToSTr(regs.Count);
end;
procedure TfrmRepEventos.CreaCategoriasHoriz(campo: integer);
  function CreaCategoriaHoriz(const categ: string): integer;
  {Busca un valor en catsHor. Si no existe, lo agrega. Devuelve el índice de su
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
var
  reg: regEven;
begin
  catsHor.Sorted := false;  //CreaCategoriaHoriz() trabaja así.
  catsHor.Clear;
  case campo of
  1: begin
       for reg in regs do begin
         reg.posHor := CreaCategoriaHoriz(reg.USUARIO);
       end;
     end;
  end;
end;
function TfrmRepEventos.DoReqCadMoneda(valor: double): string;
begin
  Result := FloatToStr(valor);
end;
procedure TfrmRepEventos.ReporteAgrupado(agrupVert: TAgrVer);
{Genera el reporte argupado, usando la lista de archivos "regs".}
var
  i  : Integer;
  reg: regEven;
  tmp: String;
  valores: TCPCellValues;
begin
  catsVer.Clear;
  //////// Crea dispersión vertical y acumula contador
  for reg in regs do begin
    tmp := FechaACad(reg.FECHA_LOG, agrupVert, frmAgrupVert.ComboBox2.ItemIndex);
    if catsVer.Find(tmp, i) then begin
      //Ya existe en "i"
      valores := TCPCellValues(catsVer.Objects[i]);
    end else begin
      //Es nuevo, se debe crear
      catsVer.Add(tmp);
      valores := TCPCellValues.Create(catsHor.Count);  //crea objeto
      catsVer.Objects[catsVer.Count-1] := valores;  //guarda la referencia
    end;
    valores.items[reg.posHor] += 1; //acumula en la celda que corresponde
  end;
  StatusBar1.Panels[1].Text:='Num. Registros = ' + IntToSTr(regs.Count);
end;
procedure TfrmRepEventos.LLenarGrilla(conColSem: boolean);
{Llena la grilla con datos de las listas catsHor y catsVer.}
var
  c, i, desplazCol: Integer;
  valores: TCPCellValues;
  tot : Double;
  fecStr: String;
begin
  //DbgOut('Llenando grilla...');
  grilla.BeginUpdate;
  //////// Crea las columnas
  griAgrupados.IniEncab;
  griAgrupados.AgrEncabNum('N°'       , 30);
  griAgrupados.AgrEncabTxt('FECHA'    , 70); //Campo Fecha
  if agrVert = tavDia then  //Campos adicionales de reporte por día
    desplazCol := frmAgrupVert.VerifCamposAdic_Dia(griAgrupados, 2);
  if agrVert = tavMes then  //Campos adicionales de reporte por día
    desplazCol := frmAgrupVert.VerifCamposAdic_Mes(griAgrupados, 2);
  for c:=0 to catsHor.Count-1 do begin
    griAgrupados.AgrEncabNum(catsHor[c], 55);
  end;
  griAgrupados.AgrEncabNum('TOTAL'    , 70); //campo final
  griAgrupados.FinEncab(false);  //sin actualizar aún
  griAgrupados.AsignarGrilla(grilla);  //actualiza
  /////// Llema las filas
  grilla.RowCount:=1+catsVer.Count;  //hace espacio
  for i:=0 to catsVer.Count-1 do begin
    //columna de categoría
    valores := TCPCellValues(catsVer.Objects[i]);
    tot := 0;  //para acumular
    // cáculo de campos agrupados /////////
    fecStr := catsVer[i];
    grilla.Cells[1, i+1] := fecStr;  //Campo Fecha
    if agrVert = tavDia then begin  //Campos adicionales de reporte por día
      frmAgrupVert.EscribirCamposAdic_Dia(fecStr, grilla, i+1);
    end else if agrVert = tavMes then begin
      frmAgrupVert.EscribirCamposAdic_Mes(fecStr, grilla, i+1);
    end;
    //campos de datos
    for c := 0 to catsHor.Count-1 do begin
      grilla.Cells[c+2+desplazCol, i+1] := FloatToStr(valores.items[c]);
      tot += valores.items[c];
    end;
    //llena columna total
    grilla.Cells[grilla.ColCount-1, i+1] := FloatToStr(tot);
  end;
  grilla.EndUpdate();
  //consoleTickCount('');
end;
procedure TfrmRepEventos.LimpiarCategoriasVert;
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
procedure TfrmRepEventos.Button1Click(Sender: TObject);
begin
  //Genera lista de archivos
  consoleTickStart;
  DbgOut('Llenando lista de registros...');
  LeerEventos(regs, dat1.Date, dat2.Date, Local, true, //llena "regs"
               true, rutApp + '\datos');
  consoleTickCount('');
  DbgOut('Creando reporte...');
  //Genera el rpeorte
  case ComboBox1.Text of
  'Registros': begin
      ReporteRegistros;
    end;
  'Por Usuario': begin
      CreaCategoriasHoriz(1);
      ReporteAgrupado(agrVert);
      LLenarGrilla(true);  //Escribe datos en grilla
      LimpiarCategoriasVert;
    end;
  end;
  consoleTickCount('');
  debugln('');
end;
procedure TfrmRepEventos.ComboBox1Change(Sender: TObject);
begin
  GroupBox1.Visible := ComboBox1.ItemIndex > 0;
end;
procedure TfrmRepEventos.FormCreate(Sender: TObject);
begin
  catsHor:= TStringList.Create;
  catsHor.Sorted:=true;
  catsVer:= TStringList.Create;
  catsVer.Sorted:=true;
  regs:= regEven_list.Create(true);
  //reportes:= TCenReporte_list.Create(true);
  dat1.Date:=now;
  dat2.Date:=now;
  //Configura grilla de reporte de registros
  griRegistros := TUtilGrilla.Create(nil);
  griRegistros.IniEncab;
  griRegistros.AgrEncabNum('N°'          , 35);
  griRegistros.AgrEncabTxt('_IDEN'       , 20);
  griRegistros.AgrEncabNum('SERIE'       , 30);
  griRegistros.AgrEncabTxt('COL_FECHA'   , 110);
  griRegistros.AgrEncabTxt('MES'         , 40);
  griRegistros.AgrEncabTxt('USUARIO'     , 50);
  griRegistros.AgrEncabTxt('DESCRIPCIÓN' , 250);
  griRegistros.FinEncab;
  griRegistros.OpAutoNumeracion:=true;
  griRegistros.OpDimensColumnas:=true;
  griRegistros.OpEncabezPulsable:=true;
  griRegistros.OpResaltarEncabez:=true;
  griRegistros.OpResaltFilaSelec:=true;
  griRegistros.MenuCampos:=true;
  //Configura grilla de reporte agrupado
  griAgrupados := TUtilGrilla.Create(nil);
  griAgrupados.OpAutoNumeracion:=true;
  griAgrupados.OpDimensColumnas:=true;
  griAgrupados.OpEncabezPulsable:=true;
  griAgrupados.OpResaltarEncabez:=true;
  griAgrupados.OpResaltFilaSelec:=true;

  //Llena lista de reportes
  ComboBox1.Clear;
  ComboBox1.AddItem('Registros', nil);
  ComboBox1.AddItem('Por Usuario', nil);
  ComboBox1.ItemIndex:=0;  //selecciona el primero

  //Actuliza interfaz
  ComboBox1Change(self);
  optDia.Checked:=true;  //inicializa opción
  //Define un formato, por defecto, de moneda.
  OnReqCadMoneda:=@DoReqCadMoneda;
end;
procedure TfrmRepEventos.FormDestroy(Sender: TObject);
begin
  griAgrupados.Destroy;
  griRegistros.Destroy;
  //reportes.Destroy;
  regs.Destroy;
  catsVer.Destroy;
  catsHor.Destroy;
end;
procedure TfrmRepEventos.Exec(Alocal: string);
begin
  local := Alocal;
  frmAgrupVert.chkIncSemana.Checked := false;
  frmAgrupVert.chkIncMes.Checked := false;
  frmAgrupVert.chkIncDia.Checked := true;
  frmAgrupVert.chkMesIncMes.Checked := true;
  frmAgrupVert.chkMesIncAno.Checked := false;
  Show;
end;
procedure TfrmRepEventos.optDiaChange(Sender: TObject);
begin
  agrVert := tavDia;
end;
procedure TfrmRepEventos.optSemChange(Sender: TObject);
begin
  agrVert := tavSem;
end;
procedure TfrmRepEventos.optMesChange(Sender: TObject);
begin
  agrVert := tavMes;
end;
function TfrmRepEventos.FilaComoTexto(f: integer): string;
{Devuelve los campos de una fila como texto separado por tabulaciones}
const
  COL_INI = 1;
var
  c: Integer;
begin
  Result := '';
  for c:=COL_INI to grilla.ColCount-1 do begin
    if c=COL_INI then Result := grilla.Cells[c,f]
    else Result := Result + #9 + grilla.Cells[c,f];
  end;
end;
procedure TfrmRepEventos.acGenCopTodExecute(Sender: TObject);  //Copia toda la grilla
var
  f: Integer;
  tmp: String;
begin
  tmp := '';
  for f:=0 to grilla.RowCount-1 do begin
    tmp := tmp + FilaComoTexto(f) + LineEnding;
  end;
  Clipboard.AsText:=tmp;
end;
procedure TfrmRepEventos.btnConfigClick(Sender: TObject);
begin
  if optDia.Checked then frmAgrupVert.PageControl1.PageIndex:=0;
  if optSem.Checked then frmAgrupVert.PageControl1.PageIndex:=1;
  if optMes.Checked then frmAgrupVert.PageControl1.PageIndex:=2;
  frmAgrupVert.Show;
end;

end.
