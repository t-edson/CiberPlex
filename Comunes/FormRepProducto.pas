unit FormRepProducto;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, StdCtrls, EditBtn, LCLProc, Grids, ComCtrls, Menus,
  ActnList, Buttons, RegistrosVentas, FormAgrupRep, CibTabProductos, Globales,
  MisUtils, UtilsGrilla, dateutils;
const
  MSJ_TODASCATEG  = '<<Todas las Categorías>>';
  MSJ_TODASSUBCAT = '<<Todas las Subcateg.>>';
  MSJ_TODOSPRODUC = '<<Todos las Productos>>';
  MSJ_NOEXIPRODUC = '<<Productos no existentes>>';
type

  { TfrmRepProducto }
  TfrmRepProducto = class(TForm)
    acGraBarras: TAction;
    acGraCurvas: TAction;
    ActionList1: TActionList;
    btnConfig: TButton;
    btnReporte: TBitBtn;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    cmbCateg: TComboBox;
    cmbSubcat: TComboBox;
    cmbProduc: TComboBox;
    dat1: TDateEdit;
    dat2: TDateEdit;
    grilla: TStringGrid;
    GroupBox1: TGroupBox;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    optDia: TRadioButton;
    optMes: TRadioButton;
    optTot: TRadioButton;
    optsDatos: TRadioGroup;
    optSem: TRadioButton;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure acGraBarrasExecute(Sender: TObject);
    procedure acGraCurvasExecute(Sender: TObject);
    procedure btnReporteClick(Sender: TObject);
    procedure cmbCategChange(Sender: TObject);
    procedure cmbSubcatChange(Sender: TObject);
    procedure optDiaChange(Sender: TObject);
    procedure optMesChange(Sender: TObject);
    procedure optSemChange(Sender: TObject);
    procedure btnConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure optTotChange(Sender: TObject);
    procedure TabSheet2Show(Sender: TObject);
  private
    regs: regIng_list;
    griAgrupados : TUtilGrilla;
    tipGraf: integer;       //tipo de gráfica
    frmAgrup: TfrmAgrupRep; //formualrio de agrupación
    procedure CreaCategoriasHoriz(campo: integer);
    procedure DibujarCurva;
    procedure griAgrupadosMouseUpCell(Button: TMouseButton; row, col: integer);
    procedure LLenarGrilla;
    function DoReqCadMoneda(valor: double): string;
    procedure ReporteAgrupado;
  public
    local: string;
    tabPro: TCibTabProduc;
    OnReqCadMoneda: TevReqCadMoneda;
    procedure Exec(Alocal: string; AtabPro: TCibTabProduc);
  end;

var
  frmRepProducto: TfrmRepProducto;

implementation
{$R *.lfm}
{ TfrmRepProducto }
function TfrmRepProducto.DoReqCadMoneda(valor: double): string;
begin
  Result := FloatToStr(valor);
end;
procedure TfrmRepProducto.CreaCategoriasHoriz(campo: integer);
var
  reg: regIng;
  p: SizeInt;
begin
  frmAgrup.catsHor.Sorted := false;  //CreaCategoriaHoriz() trabaja así.
  frmAgrup.catsHor.Clear;
  case campo of
  1: begin
       for reg in regs do begin
         if reg.subcat = 'INTERNET' then begin   //Simplifica descripción
           p := pos('(', reg.descrip);
           reg.posHor := frmAgrup.CreaCategoriaHoriz(copy(reg.descrip, 1, p-1));
         end else if reg.subcat = 'LLAMADA' then begin //Simplifica descripción
           reg.posHor := frmAgrup.CreaCategoriaHoriz('Llamada');
         end else begin
           reg.posHor := frmAgrup.CreaCategoriaHoriz(reg.descrip);
         end;
       end;
     end;
  2: begin
       for reg in regs do begin
         reg.posHor := frmAgrup.CreaCategoriaHoriz(reg.subcat);
       end;
     end;
  end;
end;
procedure TfrmRepProducto.ReporteAgrupado;
{Genera el reporte agrupado, usando la lista de archivos "regs". El reporte no se genera
 en la grilla sino en el objeto "catsVer", a quien le va añadiendo una fila (por cada
 categoría vertical que se encuentre) y una isntancia de "TCPCellValues" que representa
 a las columnas de contadores..
 Debe haberse llenado previamente "catsHor"}
var
  reg: regIng;
  valores: TCPCellValues;
  tot: double;
begin
  frmAgrup.catsVer.Clear;
  //////// Crea dispersión vertical y acumula contador
  tot := 0.0;
  for reg in regs do begin
    valores := frmAgrup.UbicarFechaVertic(reg.vfec);
    //Acumula totales
    if optsDatos.ItemIndex = 0 then
      valores.items[reg.posHor] += reg.total  //acumula en la celda que corresponde
    else
      valores.items[reg.posHor] += reg.Cant; //acumula en la celda que corresponde
    tot := tot + reg.total;
  end;
  StatusBar1.Panels[1].Text:='Nº Ventas= ' + IntToSTr(regs.Count) +
                             ',  Tot. Ingresos= ' + OnReqCadMoneda(tot) +
                             ',  Nº Categor.=' +
                             IntToStr(frmAgrup.catsHor.Count);
end;
procedure TfrmRepProducto.LLenarGrilla;
{Llena la grilla con datos de las listas catsHor y catsVer.}
var
  c, fil, colIniCont: Integer;
  valores: TCPCellValues;
  tot : Double;
begin
  grilla.BeginUpdate;
  //////// Crea las columnas
  colIniCont := frmAgrup.EncabezadosHoriz(griAgrupados, grilla);
  /////// Llema las filas
  grilla.RowCount := 1 + frmAgrup.catsVer.Count;  //hace espacio
  for fil:=1 to frmAgrup.catsVer.Count do begin
    valores := frmAgrup.CamposHoriz(grilla, fil);
    tot := 0;  //para acumular
    //campos de datos
    for c := 0 to frmAgrup.catsHor.Count-1 do begin
      if optsDatos.ItemIndex = 0 then  //por Ingresos totales
        grilla.Cells[colIniCont+c, fil] := OnReqCadMoneda(valores.items[c])
      else                             //por cantidad
        grilla.Cells[colIniCont+c, fil] := FloatToStr(valores.items[c]);
      tot += valores.items[c];
    end;
    //llena columna total
    if frmAgrup.chkIncTotHoriz.Checked then begin
      if optsDatos.ItemIndex = 0 then  //por Ingresos totales
        grilla.Cells[grilla.ColCount-1, fil] := OnReqCadMoneda(tot)
      else
        grilla.Cells[grilla.ColCount-1, fil] := FloatToStr(tot);
    end;
  end;
  grilla.EndUpdate();
  frmAgrup.LimpiarCategoriasVert;
end;
procedure TfrmRepProducto.btnReporteClick(Sender: TObject);
begin
  //Genera lista de archivos
  consoleTickStart;
  DbgOut('Llenando lista de registros...');
  //Genera el reporte
  if cmbCateg.Text = MSJ_TODASCATEG then begin
    //Pasan todos
    LeerIngresosCatSub(regs, dat1.Date, dat2.Date, local, '', '', '',
                       rutApp + '\datos');  //llena "regs"
  end else begin
    //Hay categoría seleccionada
    if cmbSubcat.Text = MSJ_TODASSUBCAT then begin
      //Pasan todas las subcategorías
      LeerIngresosCatSub(regs, dat1.Date, dat2.Date, local, cmbCateg.Text, '',
                         '', rutApp + '\datos');  //llena "regs"
    end else begin
      //Hay subcategoría
      if cmbProduc.Text = MSJ_TODOSPRODUC then begin
        //Pasan todos los productos
        LeerIngresosCatSub(regs, dat1.Date, dat2.Date, local, cmbCateg.Text, cmbSubcat.Text,
                           '', rutApp + '\datos');  //llena "regs"
      end else if cmbProduc.Text = MSJ_NOEXIPRODUC then begin
        //Productos no existentes en la tabla de productos (Se busca por descripción)
        LeerIngresosCatSubExc(regs, dat1.Date, dat2.Date, local, cmbCateg.Text, cmbSubcat.Text,
                           cmbProduc.Items, rutApp + '\datos');  //llena "regs"
      end else begin
        //Hay producto seleccionado
        LeerIngresosCatSub(regs, dat1.Date, dat2.Date, local, cmbCateg.Text, cmbSubcat.Text,
                           cmbProduc.Text, rutApp + '\datos');  //llena "regs"
      end;
    end;
  end;
  CreaCategoriasHoriz(1);
  ReporteAgrupado;
  LLenarGrilla;  //Escribe datos en grilla
  consoleTickCount('');
  debugln('');
  if TabSheet2.Visible then DibujarCurva;
end;
procedure TfrmRepProducto.btnConfigClick(Sender: TObject);
begin
  if optDia.Checked then frmAgrup.PageControl1.PageIndex:=0;
  if optSem.Checked then frmAgrup.PageControl1.PageIndex:=1;
  if optMes.Checked then frmAgrup.PageControl1.PageIndex:=2;
  frmAgrup.Show;
end;
procedure TfrmRepProducto.cmbCategChange(Sender: TObject);
  function ExisteSubCateg(subcat: string): boolean;
  var
    it: String;
  begin
    for it in cmbSubcat.Items do begin
      if (it = subcat) then
        exit(true);
    end;
    exit(false);
  end;
var
  reg : TCibRegProduc;
  categ: TCaption;
begin
  if cmbCateg.Text = MSJ_TODASCATEG then begin
    cmbSubcat.Visible:=false;
    cmbProduc.Visible:=false;
  end else begin
    categ := cmbCateg.Text;
    //Se seleeccionó una categoría
    //Hay que llenar Subcategorías
    cmbSubcat.Clear;
    cmbSubcat.AddItem(MSJ_TODASSUBCAT, nil);  //siempre existe
    for reg in tabPro.Productos do begin
      if (reg.Categ = categ) and not ExisteSubCateg(reg.Subcat) then begin
        cmbSubcat.AddItem(reg.Subcat, nil);
      end;
    end;
    cmbSubcat.ItemIndex:=0;  //selecciona el primero
    cmbSubcat.Visible:=true;
  end;
end;
procedure TfrmRepProducto.cmbSubcatChange(Sender: TObject);
  function ExisteProduc(produc: string): boolean;
  var
    it: String;
  begin
    for it in cmbProduc.Items do begin
      if (it = produc) then
        exit(true);
    end;
    exit(false);
  end;
var
  reg : TCibRegProduc;
  subcateg, categ: TCaption;
begin
  if cmbSubcat.Text = MSJ_TODASSUBCAT then begin
    cmbProduc.Visible:=false;
  end else begin
    categ := cmbCateg.Text;
    subcateg := cmbSubcat.Text;
    //Se seleeccionó una subcategoría
    //Hay que llenar los productos
    cmbProduc.Clear;
    cmbProduc.AddItem(MSJ_TODOSPRODUC, nil);  //siempre existe
    cmbProduc.AddItem(MSJ_NOEXIPRODUC, nil);   //siempre existe
    for reg in tabPro.Productos do begin
      if (reg.Categ = categ) and (reg.Subcat = subcateg) and
         not ExisteProduc(reg.Desc) then begin
        cmbProduc.AddItem(reg.Desc, nil);
      end;
    end;
    cmbProduc.ItemIndex:=0;
    cmbProduc.Visible:=true;
  end;
end;
procedure TfrmRepProducto.optDiaChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavDia;
end;
procedure TfrmRepProducto.optSemChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavSem;
end;
procedure TfrmRepProducto.optMesChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavMes;
end;
procedure TfrmRepProducto.optTotChange(Sender: TObject);
begin
  frmAgrup.agrVert := tavTot;
end;
procedure TfrmRepProducto.FormCreate(Sender: TObject);
begin
  frmAgrup := TfrmAgrupRep.Create(self);
  regs:= regIng_list.Create(true);
  //reportes:= TCenReporte_list.Create(true);
  dat1.Date:=now;
  dat2.Date:=now;
  //Configura grilla de reporte agrupado
  griAgrupados := TUtilGrilla.Create(nil);
  griAgrupados.OpAutoNumeracion:=true;
  griAgrupados.OpDimensColumnas:=true;
  griAgrupados.OpEncabezPulsable:=true;
  griAgrupados.OpResaltarEncabez:=true;
  griAgrupados.OpResaltFilaSelec:=true;
  griAgrupados.MenuCampos := true;
  griAgrupados.OnMouseUpCell := @griAgrupadosMouseUpCell;

  optDia.Checked:=true;  //inicializa opción
  optsDatos.ItemIndex:=0; //inicializa tipo de dato
  //Define un formato, por defecto, de moneda.
  OnReqCadMoneda:=@DoReqCadMoneda;
end;
procedure TfrmRepProducto.griAgrupadosMouseUpCell(Button: TMouseButton; row,
  col: integer);
begin

end;
procedure TfrmRepProducto.FormDestroy(Sender: TObject);
begin
  griAgrupados.Destroy;
  //reportes.Destroy;
  regs.Destroy;
end;
procedure TfrmRepProducto.Exec(Alocal: string; AtabPro: TCibTabProduc);
  function ExisteCateg(cat: string): boolean;
  var
    it: String;
  begin
    for it in cmbCateg.Items do begin
      if (it = cat) then
        exit(true);
    end;
    exit(false);
  end;
var
  reg : TCibRegProduc;
begin
  local := Alocal;
  //Llena Categorías
  //Llena lista de reportes
  cmbCateg.Clear;
  cmbCateg.AddItem(MSJ_TODASCATEG, nil);  //siempre existe
  tabPro := AtabPro;
  for reg in tabPro.Productos do begin
    if not ExisteCateg(reg.Categ) then begin
      cmbCateg.AddItem(reg.Categ, nil);
    end;
  end;
  if cmbCateg.Items.Count>1 then
    cmbCateg.ItemIndex:=1  //primera categoría
  else
    cmbCateg.ItemIndex:=0;  //selecciona el primero
  cmbCategChange(self);   //actualiza
  Show;
end;
procedure TfrmRepProducto.TabSheet2Show(Sender: TObject);
//Se activa la pestaña de la gráfica.
begin
  DibujarCurva;
end;
procedure TfrmRepProducto.DibujarCurva;
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
  end else begin
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
procedure TfrmRepProducto.acGraBarrasExecute(Sender: TObject);
begin
  if tipGraf = 0 then exit;  //ya tiene el tipo
  tipGraf := 0;
  DibujarCurva;
end;
procedure TfrmRepProducto.acGraCurvasExecute(Sender: TObject);
begin
  if tipGraf = 1 then exit;  //ya tiene el tipo
  tipGraf := 1;
  DibujarCurva;
end;

end.

