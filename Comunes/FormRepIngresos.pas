unit FormRepIngresos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, TAGraph, TASeries, Forms, Controls, Graphics, ExtCtrls,
  StdCtrls, EditBtn, Grids, Menus, ActnList, LCLProc, ComCtrls, Clipbrd,
  Buttons, Globales, RegistrosVentas, FormAgrupRep,
  UtilsGrilla, FrameFiltCampo, BasicGrilla, MisUtils;
type

  { TfrmRepIngresos }
  TfrmRepIngresos = class(TForm)
  published
    acGenCopTod: TAction;
    acGraBarras: TAction;
    acGraCurvas: TAction;
    ActionList1: TActionList;
    btnReporte: TBitBtn;
    btnConfig: TButton;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    ComboBox1: TComboBox;
    fraFiltCampo1: TfraFiltCampo;
    fraFiltCampo2: TfraFiltCampo;
    grilla: TStringGrid;
    GroupBox1: TGroupBox;
    ImageList1: TImageList;
    Label4: TLabel;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    optDia: TRadioButton;
    optTot: TRadioButton;
    optSem: TRadioButton;
    optMes: TRadioButton;
    optsDatos: TRadioGroup;
    PageControl1: TPageControl;
    PopupGrilla: TPopupMenu;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TipoReg: TCheckGroup;
    dat1: TDateEdit;
    dat2: TDateEdit;
    Label1: TLabel;
    Label2: TLabel;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    procedure acGenCopTodExecute(Sender: TObject);
    procedure acGraBarrasExecute(Sender: TObject);
    procedure acGraCurvasExecute(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure btnReporteClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure optDiaChange(Sender: TObject);
    procedure optMesChange(Sender: TObject);
    procedure optSemChange(Sender: TObject);
    procedure optTotChange(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
  private
    regs: regIng_list;
    griRegistros : TUtilGrilla;
    griAgrupados : TUtilGrilla;
    tipGraf: integer;       //tipo de gráfica
    frmAgrup: TfrmAgrupRep; //formualrio de agrupación
    procedure CreaCategoriasHoriz(campo: integer);
    procedure DibujarCurva;
    function DoReqCadMoneda(valor: double): string;
    function FilaComoTexto(f: integer): string;
    procedure griAgrupadosMouseUpCell(Button: TMouseButton; row, col: integer);
    procedure grillaSelection(Sender: TObject; aCol, aRow: Integer);
    procedure LLenarGrilla;
    procedure LlenarRegistro(f: integer; reg: regIng);
    procedure ReporteAgrupado;
    procedure ReporteRegistros;
  public
    local: string;
    OnReqCadMoneda: TevReqCadMoneda;
    procedure Exec(Alocal: string);
  end;
const
  TXT_REGISTROS = 'Registros';
  TXT_POR_CATEG = 'Por categoría';
  TXT_POR_SUBCA = 'Por Subcategoría';
  TXT_POR_USUAR = 'Por Usuario';
var
  frmRepIngresos: TfrmRepIngresos;

implementation
{$R *.lfm}
{ TfrmRepIngresos }
procedure TfrmRepIngresos.LlenarRegistro(f: integer; reg: regIng);
{Llena los datos de un registro en una fila de la grilla}
begin
  grilla.Cells[1, f] := reg.ident;
  grilla.Cells[2, f] := reg.serie;
  grilla.Cells[3, f] := reg.FECHA_LOG_str;
  //grilla.Cells[4, f] := reg.FECHA_LOG_str;
  grilla.Cells[5, f] := reg.USUARIO;
  grilla.Cells[6, f] := reg.vser;
  grilla.Cells[7, f] := reg.vfec_str;
  grilla.Cells[8, f] := reg.cat;
  grilla.Cells[9, f] := reg.subcat;
  grilla.Cells[10, f] := FloatToStr(reg.Cant);
  grilla.Cells[11, f] := reg.pUnit;
  grilla.Cells[12, f] := OnReqCadMoneda(reg.total);
  grilla.Cells[13, f] := reg.estado;
  grilla.Cells[14, f] := reg.descrip;
  grilla.Cells[15, f] := reg.coment;
  grilla.Cells[16, f] := reg.fragment;
  grilla.Cells[17, f] := reg.codPro;
  grilla.Cells[18, f] := reg.pVen;
end;
procedure TfrmRepIngresos.ReporteRegistros;
{Genera el reporte detallado, usando la lista de registros "regs".}
var
  f: Integer;
  reg: regIng;
  tot: Double;

begin
  //LLena grilla
  //DbgOut('Llenando grilla...');
  griRegistros.AsignarGrilla(grilla);
  fraFiltCampo1.Inic(griRegistros, 13);  //inicia filtro
  fraFiltCampo2.Inic(griRegistros, 8);  //inicia filtro
  fraFiltCampo1.Visible := true;
  fraFiltCampo2.Visible := true;

  grilla.BeginUpdate;
  grilla.RowCount:=1+regs.Count;  //hace espacio
  f := 1;
  tot := 0.0;
  for reg in regs do begin
    LlenarRegistro(f, reg);
    inc(f);
    tot := tot + reg.total;
  end;
  grilla.EndUpdate();
  //consoleTickCount('');
  StatusBar1.Panels[1].Text:='Num. Registros = ' + IntToSTr(regs.Count) +
                             ', Total Ingresos = ' + OnReqCadMoneda(tot);
end;
procedure TfrmRepIngresos.CreaCategoriasHoriz(campo: integer);
var
  reg: regIng;
begin
  frmAgrup.catsHor.Clear;
  case campo of
  1: begin
       for reg in regs do begin
         reg.posHor := frmAgrup.CreaCategoriaHoriz(reg.cat);
       end;
     end;
  2: begin
       for reg in regs do begin
         reg.posHor := frmAgrup.CreaCategoriaHoriz(reg.subcat);
       end;
     end;
  3: begin
       for reg in regs do begin
         reg.posHor := frmAgrup.CreaCategoriaHoriz(reg.USUARIO);
       end;
     end;
  end;
end;
function TfrmRepIngresos.DoReqCadMoneda(valor: double): string;
begin
  Result := FloatToStr(valor);
end;
procedure TfrmRepIngresos.ReporteAgrupado;
{Genera el reporte agrupado, usando la lista de archivos "regs".}
var
  reg: regIng;
  grpFecha: TCPCellValues;
  tot: double;
  i, c: Integer;
begin
  frmAgrup.catsVer.Clear;
  // Crea dispersión vertical y acumula contador
  tot := 0.0;
  for reg in regs do begin
    grpFecha := frmAgrup.UbicarFechaVertic(reg.vfec);
    //Acumula totales
    if optsDatos.ItemIndex = 0 then begin
      //Suma el total de los ingresos
      grpFecha.items[reg.posHor] += reg.total;  //acumula en la celda que corresponde
    end else if optsDatos.ItemIndex = 1 then begin
      //Suma la cantidad de productos
      grpFecha.items[reg.posHor] += reg.Cant; //acumula en la celda que corresponde
    end else if optsDatos.ItemIndex = 2 then begin
      //Suma la cantidad de registros
      grpFecha.items[reg.posHor] += 1; //acumula en la celda que corresponde
    end else if optsDatos.ItemIndex = 3 then begin
      //Cantidad de días que hay en la fecha
      //Despues se llenará
    end else if optsDatos.ItemIndex = 4 then begin
      //Ingreso por día
      grpFecha.items[reg.posHor] += reg.total;  //acumula ingresos, y después dividirá
    end;
    tot := tot + reg.total;
  end;
  //Completa el caso de los reportes agrupados por "Nº de días"
  if optsDatos.ItemIndex = 3 then begin
    //Pone la cantidad de días que hay en cada fecha
    for i:=0 to frmAgrup.catsVer.Count-1 do begin
      grpFecha := TCPCellValues(frmAgrup.catsVer.Objects[i]);
      //Pone la misma cantidad de días para todas las columnas
      for c:=0 to high(grpFecha.items) do begin
        grpFecha.items[c] := grpFecha.dias.Count;
      end;
    end;
  end;
  //Completa el caso de los reportes agrupados por "Ingreso/día"
  if optsDatos.ItemIndex = 4 then begin
    //Pone la cantidad de días que hay en cada fecha
    for i:=0 to frmAgrup.catsVer.Count-1 do begin
      grpFecha := TCPCellValues(frmAgrup.catsVer.Objects[i]);
      //Pone la misma cantidad de días para todas las columnas
      for c:=0 to high(grpFecha.items) do begin
        //if grpFecha.dias.Count = 0 then continue; //No debría pasar
        grpFecha.items[c] := grpFecha.items[c] / grpFecha.dias.Count;
      end;
    end;
  end;
  StatusBar1.Panels[1].Text:='Num. Registros = ' + IntToSTr(regs.Count) +
                             ', Total Ingresos = ' + OnReqCadMoneda(tot);
end;
procedure TfrmRepIngresos.LLenarGrilla;
{Llena la grilla con datos de las listas catsHor y catsVer.}
var
  c, fil, colIniCont: Integer;
  valores: TCPCellValues;
  tot : Double;
begin
  grilla.BeginUpdate;
  //////// Crea las columnas
  colIniCont := frmAgrup.EncabezadosHoriz(griAgrupados, grilla);
  fraFiltCampo1.Visible := false;
  fraFiltCampo2.Visible := false;
  /////// Llema las filas
  grilla.RowCount := 1 + frmAgrup.catsVer.Count;  //hace espacio
  for fil:=1 to frmAgrup.catsVer.Count do begin
    valores := frmAgrup.CamposHoriz(grilla, fil);
    tot := 0;  //para acumular
    //campos de datos
    for c := 0 to frmAgrup.catsHor.Count-1 do begin
      grilla.Cells[colIniCont+c, fil] := FloatToStr(valores.items[c]);
      tot += valores.items[c];
    end;
    //llena columna total
    if frmAgrup.chkIncTotHoriz.Checked then begin
      grilla.Cells[grilla.ColCount-1, fil] := FloatToStr(tot);
    end;
  end;
  grilla.EndUpdate();
  frmAgrup.LimpiarCategoriasVert;
end;
procedure TfrmRepIngresos.btnReporteClick(Sender: TObject);
begin
  //Genera lista de archivos
  consoleTickStart;
  DbgOut('Llenando lista de registros...');
  LeerIngresos(regs, dat1.Date, dat2.Date, Local, TipoReg.Checked[0],  //llena "regs"
               TipoReg.Checked[1], TipoReg.Checked[2], rutApp + '\datos');
  consoleTickCount('');
  DbgOut('Creando reporte...');
  //Genera el rpeorte
  case ComboBox1.Text of
  TXT_REGISTROS: begin
      ReporteRegistros;
    end;
  TXT_POR_CATEG: begin
      CreaCategoriasHoriz(1);
      ReporteAgrupado;
      LLenarGrilla;   //Escribe datos en grilla
      if TabSheet2.Visible then DibujarCurva;
    end;
  TXT_POR_SUBCA: begin
      CreaCategoriasHoriz(2);
      ReporteAgrupado;
      LLenarGrilla;   //Escribe datos en grilla
      if TabSheet2.Visible then DibujarCurva;
    end;
  TXT_POR_USUAR: begin
      CreaCategoriasHoriz(3);
      ReporteAgrupado;
      LLenarGrilla;  //Escribe datos en grilla
      if TabSheet2.Visible then DibujarCurva;
    end;
  end;
  consoleTickCount('');
  debugln('');
end;
procedure TfrmRepIngresos.ComboBox1Change(Sender: TObject);
begin
  GroupBox1.Visible := ComboBox1.ItemIndex > 0;
  optsDatos.Visible := ComboBox1.ItemIndex > 0;
end;
procedure TfrmRepIngresos.FormCreate(Sender: TObject);
begin
  frmAgrup := TfrmAgrupRep.Create(self);
  frmAgrup.OnExecReporte := @btnReporteClick;
  regs:= regIng_list.Create(true);
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
  griRegistros.AgrEncabNum('VSERIE'      , 30);
  griRegistros.AgrEncabTxt('VFECHA'      , 110);
  griRegistros.AgrEncabTxt('CATEGORÍA'   , 60);
  griRegistros.AgrEncabTxt('SUBCATEGORÍA', 70);
  griRegistros.AgrEncabNum('CANTIDAD'    , 30);
  griRegistros.AgrEncabNum('PRC.UNITARIO', 50);
  griRegistros.AgrEncabNum('TOTAL'       , 60);
  griRegistros.AgrEncabNum('ESTADO'      , 30);
  griRegistros.AgrEncabTxt('DESCRIPCIÓN' , 140);
  griRegistros.AgrEncabTxt('COMENTARIO'  , 80);
  griRegistros.AgrEncabNum('FRAGMENTO'   , 30);
  griRegistros.AgrEncabTxt('CODPRO'      , 80);
  griRegistros.AgrEncabTxt('PTO.VENTA'   , 70);
  griRegistros.FinEncab;
  griRegistros.OpAutoNumeracion:=true;
  griRegistros.OpDimensColumnas:=true;
  griRegistros.OpEncabezPulsable:=true;
  griRegistros.OpResaltarEncabez:=true;
  griRegistros.OpResaltFilaSelec:=true;
  griRegistros.MenuCampos:=true;
  griRegistros.OnMouseUpCell := @griAgrupadosMouseUpCell;
  //Configura grilla de reporte agrupado
  griAgrupados := TUtilGrilla.Create(nil);
  griAgrupados.OpAutoNumeracion:=true;
  griAgrupados.OpDimensColumnas:=true;
  griAgrupados.OpEncabezPulsable:=true;
  griAgrupados.OpResaltarEncabez:=true;
  griAgrupados.OpResaltFilaSelec:=true;
  griAgrupados.MenuCampos := true;
  griAgrupados.OnMouseUpCell := @griAgrupadosMouseUpCell;

  grilla.OnSelection := @grillaSelection;
  //Llena lista de reportes
  ComboBox1.Clear;
  ComboBox1.AddItem(TXT_REGISTROS, nil);
  ComboBox1.AddItem(TXT_POR_CATEG, nil);
  ComboBox1.AddItem(TXT_POR_SUBCA, nil);
  ComboBox1.AddItem(TXT_POR_USUAR, nil);
  ComboBox1.ItemIndex:=0;  //selecciona el primero

  //Actuliza interfaz
  ComboBox1Change(self);
  optDia.Checked:=true;  //inicializa opción
  optsDatos.ItemIndex:=0; //inicializa tipo de dato
  //Define un formato, por defecto, de moneda.
  OnReqCadMoneda:=@DoReqCadMoneda;
end;
procedure TfrmRepIngresos.griAgrupadosMouseUpCell(Button: TMouseButton; row,
  col: integer);
begin
  if Button = mbRight then PopupGrilla.PopUp;
end;
procedure TfrmRepIngresos.grillaSelection(Sender: TObject; aCol, aRow: Integer);
begin
  StatusBar1.Panels[2].Text := InformSeleccionGrilla(grilla);
end;

procedure TfrmRepIngresos.FormDestroy(Sender: TObject);
begin
  griAgrupados.Destroy;
  griRegistros.Destroy;
  //reportes.Destroy;
  regs.Destroy;
end;
procedure TfrmRepIngresos.Exec(Alocal: string);
begin
  local := Alocal;
  Show;
end;
procedure TfrmRepIngresos.optDiaChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavDia;
end;
procedure TfrmRepIngresos.optSemChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavSem;
end;
procedure TfrmRepIngresos.optTotChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavTot;
end;

procedure TfrmRepIngresos.optMesChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavMes;
end;
function TfrmRepIngresos.FilaComoTexto(f: integer): string;
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
procedure TfrmRepIngresos.btnConfigClick(Sender: TObject);
begin
  if optDia.Checked then frmAgrup.PageControl1.PageIndex:=0;
  if optSem.Checked then frmAgrup.PageControl1.PageIndex:=1;
  if optMes.Checked then frmAgrup.PageControl1.PageIndex:=2;
  frmAgrup.Show;
end;
procedure TfrmRepIngresos.TabSheet2Show(Sender: TObject);
//Se activa la pestaña de la gráfica.
begin
  if ComboBox1.Text <> TXT_REGISTROS then DibujarCurva;
end;
procedure TfrmRepIngresos.DibujarCurva;
  function TextoLimitado(txt: string): string;
  {Recorta un texto pro el número de caracteres.}
  const max = 24;
  begin
    if length(txt) > max then
      Result := copy(txt,1,max) + '..'
    else
      Result := txt;
  end;
var
  fil, cIni, c, nSeries, porcIni, dPorcen: Integer;
  FBar : TBarSeries;
  FLine: TLineSeries;
  y: Single;
begin
//  FArea := TAreaSeries.Create(Chart1);
  if griAgrupados.cols.Count = 0 then exit;
  //Busca inicio de columnas de tipo "contadores"
  for cIni:=1 to grilla.ColCount-1 do begin
    if griAgrupados.cols[cIni].tipo = ugTipNum then
      break;  //Se asume que es la primera columna numérica, que no sea la 0
  end;
  //Crea series
  Chart1.ClearSeries;
  nSeries := grilla.ColCount - cIni;
  if nSeries > 70 then begin
    {No se puede dibujar muchas series, porque las posiciones de las barras se ajustan
     en procentajes enteros.}
    exit;
  end;
  dPorcen := 98 div nSeries;
  porcIni := 1;
  if tipGraf = 0 then begin   //Barras
    for c:=cIni to cIni + nSeries -1 do begin
      if grilla.ColWidths[c] = 0 then continue;   //columna oculta
      FBar := TBarSeries.Create(Chart1);
      FBar.BarWidthStyle := bwPercent;
      FBar.BarOffsetPercent:= porcIni;
      FBar.BarWidthPercent := dPorcen;
      porcIni := porcIni + dPorcen;
  //    FBar.SeriesColor := clFuchsia;
      FBar.SeriesColor := RGBToColor(Random(256),Random(256),Random(256));
      FBar.Title := TextoLimitado(grilla.Cells[c, 0]);
      Chart1.AddSeries(FBar);
//      FBar.Clear;
      for fil:=1 to grilla.RowCount-1 do begin
        y := StrToFloat(grilla.Cells[c, fil]);
        FBar.AddXY(fil, y);
      end;
    end;
  end else begin  //Curvas
    for c:=cIni to cIni + nSeries -1 do begin
      if grilla.ColWidths[c] = 0 then continue;   //columna oculta
      FLine := TLineSeries.Create(Chart1);
      FLine.ShowLines := true;
//      FLine.ShowPoints := true;
//      FLine.Pointer.Style := psRectangle;
//      FLine.Pointer.Brush.Color := clRed;
      FLine.LinePen.Width := 2;
      FLine.SeriesColor := RGBToColor(Random(256),Random(256),Random(256));
      FLine.Title := TextoLimitado(grilla.Cells[c, 0]);;
      Chart1.AddSeries(FLine);
//      FLine.Clear;
      for fil:=1 to grilla.RowCount-1 do begin
        y := StrToFloat(grilla.Cells[c, fil]);
        FLine.AddXY(fil, y);
      end;
    end;
  end;
  Chart1.Legend.Visible:=true;
end;
//////////////////// Acciones /////////////////////
procedure TfrmRepIngresos.acGenCopTodExecute(Sender: TObject);  //Copia toda la grilla
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
procedure TfrmRepIngresos.acGraBarrasExecute(Sender: TObject);
begin
  if tipGraf = 0 then exit;  //ya tiene el tipo
  tipGraf := 0;
  DibujarCurva;
end;
procedure TfrmRepIngresos.acGraCurvasExecute(Sender: TObject);
begin
  if tipGraf = 1 then exit;  //ya tiene el tipo
  tipGraf := 1;
  DibujarCurva;
end;

end.

