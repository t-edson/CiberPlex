{Formualrio para la ediciónm de los productos}
unit FormAdminProduc;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons, Menus, ActnList, StdCtrls, ComCtrls, LCLProc, LCLType, Clipbrd,
  UtilsGrilla, CibProductos, FormConfig, CibUtils, FrameFiltCampo,
  FrameFiltArbol, MisUtils;
type
  { TfrmAdminProduc }
  TfrmAdminProduc = class(TForm)
  published
    acArcSalir: TAction;
    acEdiNuevo: TAction;
    acEdiElimin: TAction;
    acArcGrabar: TAction;
    acArcValidar: TAction;
    acEdiCopFil: TAction;
    acEdiCopCel: TAction;
    acEdiPegar: TAction;
    acHerMostRentab: TAction;
    acVerArbCat: TAction;
    ActionList1: TActionList;
    btnValidar: TBitBtn;
    btnMostCateg: TBitBtn;
    btnCerrar: TBitBtn;
    btnGrabar: TBitBtn;
    chkMostInac: TCheckBox;
    fraFiltCampo: TfraFiltCampo;
    ImageList1: TImageList;
    lblFiltCateg: TLabel;
    lblNumRegist: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    grilla: TStringGrid;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    procedure acArcGrabarExecute(Sender: TObject);
    procedure acArcValidarExecute(Sender: TObject);
    procedure acEdiCopCelExecute(Sender: TObject);
    procedure acEdiCopFilExecute(Sender: TObject);
    procedure acEdiEliminExecute(Sender: TObject);
    procedure acEdiNuevoExecute(Sender: TObject);
    procedure acEdiPegarExecute(Sender: TObject);
    procedure acHerMostRentabExecute(Sender: TObject);
    procedure acVerArbCatExecute(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SolicCerrarArbol;
    procedure FormShow(Sender: TObject);
  private  //Referencias a columnas
    colRentab: TugGrillaCol;
    colCodigo: TugGrillaCol;
    colCateg: TugGrillaCol;
    colSubcat: TugGrillaCol;
    colPreUni: TugGrillaCol;
    colDescri: TugGrillaCol;
    colStock : TugGrillaCol;
    colMarca : TugGrillaCol;
    colUniCom: TugGrillaCol;
    colPreCos: TugGrillaCol;
    colFecCre: TugGrillaCol;
    colFecMod: TugGrillaCol;
  private
    gri : TGrillaEdicFor;
    TabPro: TCibTabProduc;
    regAux: TCibRegProduc;   //registro auxiliar
    fraFiltArbol1: TfraFiltArbol;
    procedure fraFiltCampoCambiaFiltro;
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function griLeerColorFondo(col, fil: integer): TColor;
    procedure gri_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gri_FinEditarCelda(var eveSal: TEvSalida; col, fil: integer;
                                ValorAnter, ValorNuev: string);
    procedure RefrescarFiltros;
    procedure gri_MouseUp(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
    procedure RegAGrilla(reg: TCibRegProduc; f: integer);
    procedure GrillaAReg(f: integer; reg: TCibRegProduc);
    procedure ListaAGrilla;
  public
    Modificado:  boolean;
    OnGrabado : procedure of object;
    function GrillaALista: boolean;
    procedure Exec(TabPro0: TCibTabProduc);
    procedure Habilitar(estado: boolean);
  end;

var
  frmAdminProduc: TfrmAdminProduc;

implementation
{$R *.lfm}
{ TfrmAdminProduc }
procedure TfrmAdminProduc.RefrescarFiltros;
{Configura los filtros que aplican, y muestra información sobre ellos.}
var
  txtBusc: string;
  hayFiltro: Boolean;
begin
  gri.LimpiarFiltros;
  lblFiltCateg.Caption:='';
  hayFiltro := false;
  //Verifica filtro de Árbol de categoría
  txtBusc := fraFiltArbol1.FiltroArbolCat;
  if txtBusc<>'' then begin
    hayFiltro := true;
    gri.AgregarFiltro(@fraFiltArbol1.Filtro);
    lblFiltCateg.Caption := 'Filtro de categ.: ' + txtBusc;
  end;
  //Verifica filtro de "fraFiltCampo"
  txtBusc := fraFiltCampo.txtBusq;
  if txtBusc<>'' then begin
    hayFiltro := true;
    gri.AgregarFiltro(@fraFiltCampo.Filtro);
    lblFiltCateg.Caption := lblFiltCateg.Caption + ', Texto de búsqueda: ' + txtBusc;
  end;
  gri.Filtrar;   //Filtra con todos los filtros agregados
  if hayFiltro then begin
    lblFiltCateg.Visible:=true;
    MensajeVisibles(lblNumRegist, grilla.RowCount-1, gri.filVisibles, clBlue);
  end else begin
    MensajeVisibles(lblNumRegist, grilla.RowCount-1, grilla.RowCount-1);
  end;
end;
procedure TfrmAdminProduc.RegAGrilla(reg: TCibRegProduc; f: integer);
{Mueve un registro de la tabla de productos, a una fila de la grilla}
begin
  colCodigo.ValStr[f]   := reg.Cod;
  colCateg.ValStr[f]    := reg.Categ;
  colSubcat.ValStr[f]   := reg.Subcat;
  colPreUni.ValNum[f]   := reg.preVenta;
  colDescri.ValStr[f]   := reg.Desc;
  colStock.ValNum[f]    := reg.Stock;
  colMarca.ValStr[f]    := reg.Marca;
  colUniCom.ValStr[f]   := reg.UnidComp;
  colPreCos.ValNum[f]   := reg.PreCosto;
  colFecCre.ValDatTim[f]:= reg.fecCre;
  colFecMod.ValDatTim[f]:= reg.fecMod;
end;
procedure TfrmAdminProduc.GrillaAReg(f: integer; reg: TCibRegProduc);
begin
  reg.Cod       := colCodigo.ValStr[f];
  reg.Categ     := colCateg.ValStr[f];
  reg.Subcat    := colSubcat.ValStr[f];
  reg.preVenta  := colPreUni.ValNum[f];
  reg.Desc      := colDescri.ValStr[f];
  reg.Stock     := colStock.ValNum[f];
  reg.Marca     := colMarca.ValStr[f];
  reg.UnidComp  := colUniCom.ValStr[f];
  reg.PreCosto  := colPreCos.ValNum[f];
  reg.fecCre    := colFecCre.ValDatTim[f];
  reg.fecMod    := colFecMod.ValDatTim[f];
end;
procedure TfrmAdminProduc.ListaAGrilla;
{Mueve datos de la lista a la grills}
var
  f: Integer;
  reg: TCibRegProduc;
  n: LongInt;
begin
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  n := TabPro.Productos.Count+1;
  grilla.RowCount:= n;
  f := 1;
  for reg in TabPro.Productos do begin
    grilla.Cells[0, f] := IntToStr(f);
    RegAGrilla(reg, f);
    f := f + 1;
  end;
  grilla.EndUpdate();
end;
function TfrmAdminProduc.GrillaALista: boolean;
{Mueve datos de la grills a la lista. Si enuenctra error, devuelve FALSE}
var
  f: Integer;
  reg: TCibRegProduc;
begin
  //Mueve datos a la lista. Si se ah ehcho la validación, no debería fallar.
  TabPro.Productos.Clear;
  for f:=1 to grilla.RowCount-1 do begin
    reg := TCibRegProduc.Create;
    GrillaAReg(f, reg);
    TabPro.Productos.Add(reg);
  end;
  exit(true);
end;
procedure TfrmAdminProduc.gri_MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Longint;
begin
  if Button = mbRight then begin
    grilla.MouseToCell(X, Y, ACol, ARow );
    if ARow<1 then exit;   //protección
    if ACol = 0 then begin
      //Columna fija
      PopupMenu1.PopUp;
    end else begin
      PopupMenu1.PopUp;
    end;
  end;
end;
procedure TfrmAdminProduc.gri_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{COnfigura los accesos de teclado de la grilla. Se configuran aquí, y no con atajos de las
acciones, porque se quiere qie estos accesos solo funciones cuando la grilal tiene
el enfoque.}
begin
  if Key = VK_APPS then begin  //Menú contextual
    PopupMenu1.PopUp;
  end;
  if (Shift = [ssCtrl]) and (Key = VK_C) then begin
    acEdiCopCelExecute(self);
  end;
  if (Shift = [ssCtrl]) and (Key = VK_INSERT) then begin
    acEdiCopCelExecute(self);
  end;
  if (Shift = [ssCtrl]) and (Key = VK_V) then begin
    acEdiPegarExecute(self);
  end;
  if (Shift = [ssShift]) and (Key = VK_INSERT) then begin
    acEdiPegarExecute(self);
  end;
end;
procedure TfrmAdminProduc.Exec(TabPro0: TCibTabProduc);
begin
  TabPro := TabPro0;
  ListaAGrilla;  //Hace el llenado inicial de productos
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
end;
procedure TfrmAdminProduc.Habilitar(estado: boolean);
{Configura el estado de los botones}
begin
  btnGrabar.Enabled:=estado;
end;
procedure TfrmAdminProduc.FormCreate(Sender: TObject);
begin
  fraFiltArbol1:= TfraFiltArbol.Create(self);
  fraFiltArbol1.Parent := self;
  fraFiltArbol1.Align := alLeft;
  Splitter1.Align := alLeft;
  grilla.Align := alClient;
  fraFiltArbol1.Visible:=false;
  //Configura grilla
  gri := TGrillaEdicFor.Create(grilla);
  gri.IniEncab;
               gri.AgrEncabNum   ('N°'            , 25);
  colCodigo := gri.AgrEncabTxt   ('CÓDIGO'        , 60);
  colCateg  := gri.AgrEncabTxt   ('CATEGORÍA'     , 70);
  colSubcat := gri.AgrEncabTxt   ('SUBCATEGORÍA'  , 80);
  colPreUni := gri.AgrEncabNum   ('PRC.UNITARIO'  , 55);
  colDescri := gri.AgrEncabTxt   ('DESCRIPCIÓN'   ,180);
  colStock  := gri.AgrEncabNum   ('STOCK'         , 40);
  colStock.editable:=false;   //Los cambios de stock, son otro proceso
  colMarca  := gri.AgrEncabTxt   ('MARCA'         , 50);
  colUniCom := gri.AgrEncabTxt   ('UNID. DE COMPRA',70);
  colPreCos := gri.AgrEncabNum   ('PRECIO COSTO'  , 55);
  colFecCre := gri.AgrEncabDatTim('FECHA CREACION', 70);
  colFecMod := gri.AgrEncabDatTim('FECHA MODIFIC.', 70);
  gri.FinEncab;
  //Define restricciones a los campos
  colCodigo.restric:= [ucrNotNull, ucrUnique];
  colCateg.restric:=[ucrNotNull];   //no nulo
  colSubcat.restric:=[ucrNotNull];   //no nulo
  colDescri.restric:=[ucrNotNull];   //no nulo

  fraFiltCampo.Inic(gri, 4);
  fraFiltCampo.OnCambiaFiltro:=@fraFiltCampoCambiaFiltro;
  fraFiltCampo.OnKeyDown:=@fraFiltCampoKeyDown;

  fraFiltArbol1.Inic(gri, colCateg, colSubcat, 'Productos');
  fraFiltArbol1.OnCambiaFiltro:= @fraFiltCampoCambiaFiltro;
  fraFiltArbol1.OnSoliCerrar:=@SolicCerrarArbol;

  //Configura opciones en la grilla
  gri.MenuCampos:=true;
  gri.OpResaltFilaSelec:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  //Configura eventos
  gri.OnMouseUp       := @gri_MouseUp;
  gri.OnKeyDown       := @gri_KeyDown;
  gri.OnFinEditarCelda:= @gri_FinEditarCelda;
  gri.OnLeerColorFondo:= @griLeerColorFondo;

  regAux:= TCibRegProduc.Create;  //registro auxiliar
end;
procedure TfrmAdminProduc.FormShow(Sender: TObject);
begin
  //Se configura aquí (En OnShow), proque se necesita que se haya cargado la
  //configuración.
  colPreUni.formato := FormatMon;
  colPreCos.formato := FormatMon;
end;
function TfrmAdminProduc.griLeerColorFondo(col, fil: integer): TColor;
begin
  Result := clWhite;
end;
procedure TfrmAdminProduc.gri_FinEditarCelda(var eveSal: TEvSalida; col,
  fil: integer; ValorAnter, ValorNuev: string);
{Termina la edición de una celda. Validamos, la celda.}
begin
  if eveSal in [evsTecEnter, evsTecTab, evsTecDer, evsEnfoque] then begin
    //Puede haber cambio
//    if ValorAnter = ValorNuev then exit;  //no es cambio
    gri.MsjError := '';
    gri.cols[col].ValidateStr(fil, ValorNuev);
    if gri.MsjError<>'' then begin
      //Hay rutina de validación
      MsgExc(gri.MsjError);
      eveSal := evsNulo;
    end;
  end;
end;
procedure TfrmAdminProduc.fraFiltCampoCambiaFiltro;
begin
  RefrescarFiltros;
end;
procedure TfrmAdminProduc.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    grilla.SetFocus;
  end;
end;
procedure TfrmAdminProduc.FormDestroy(Sender: TObject);
begin
  regAux.Destroy;
  gri.Destroy;
end;

procedure TfrmAdminProduc.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_F3 then fraFiltCampo.SetFocus;
end;

procedure TfrmAdminProduc.SolicCerrarArbol;
begin
  acVerArbCatExecute(self);
end;
procedure TfrmAdminProduc.btnCerrarClick(Sender: TObject);
begin
  Self.Close;
end;
procedure TfrmAdminProduc.btnMostCategClick(Sender: TObject);
{Se hace esta llamada por código, porque no se puede asoicar fácilmente un TBitBtn
a un acción, mostrando solo el ícono.}
begin
  acVerArbCatExecute(self);
end;

///////////////////////// Acciones ////////////////////////////////
procedure TfrmAdminProduc.acArcGrabarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
begin
  acArcValidarExecute(self);
  if gri.MsjError<>'' then exit;
  if OnGrabado<>nil then OnGrabado();  //El evento es quien grabará
  fraFiltArbol1.LeerCategorias;
  self.ActiveControl := nil;   //Para no quedarse copn el enfoque
end;
procedure TfrmAdminProduc.acArcValidarExecute(Sender: TObject);
{Realiza la validación de los campos de la grilla. Esto implica ver si los valores de
cadena, contenidos en todos los campos, se pueden traducir a los valores netivos del
tipo TRegProdu, y si son valores legales.}
var
  f: Integer;
begin
  for f:=1 to grilla.RowCount-1 do begin
    gri.ValidaFilaGrilla(f);
    if gri.MsjError<>'' then begin
      //Hubo error
      MsgExc(gri.MsjError);
      grilla.Row:=f;  //fila del error
      grilla.Col:=gri.colError;  //columna del error
      exit;
    end;
  end;
end;
//Acciones de edición
procedure TfrmAdminProduc.acEdiCopCelExecute(Sender: TObject);
begin
  gri.CopiarCampo;
end;
procedure TfrmAdminProduc.acEdiCopFilExecute(Sender: TObject);
begin
  gri.CopiarFila;
end;
procedure TfrmAdminProduc.acEdiPegarExecute(Sender: TObject);
begin
  gri.PegarACampo;
end;
procedure TfrmAdminProduc.acEdiNuevoExecute(Sender: TObject);
var
  f: Integer;
begin
debugln('celda sel en fil=%d, col=%d', [grilla.Row, grilla.Col]);
  if grilla.Row = 0 then begin
    grilla.InsertColRow(false, 1);
    f := 1;  //fila insertada
  end else begin
    grilla.InsertColRow(false, grilla.Row);
    f := grilla.Row - 1;  //fila insertada
  end;
  //Llena los campos por defecto.
  colCodigo.ValStr[f] := '##'+IntToStr(grilla.RowCount);
  colPreUni.ValNum[f] := 0;
  colStock.ValNum[f] := 0;
  colPreCos.ValNum[f] := 0;
  colFecCre.ValDatTim[f] := now;
  colFecMod.ValDatTim[f] := now;
  //Ubica fila seleccionada
  grilla.Row := f;
  //Actualiza
  gri.NumerarFilas;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
  Modificado := true;
end;
procedure TfrmAdminProduc.acEdiEliminExecute(Sender: TObject);
{Elimina el registro seleccionado.}
var
  tmp: String;
begin
  if grilla.Row<1 then exit;;
  tmp := colDescri.ValStr[grilla.Row];
  if MsgYesNo('¿Eliminar registro: "' + tmp + '?') <> 1 then exit ;
  //Se debe eliminar el registro seleccionado
  grilla.DeleteRow(grilla.Row);
  //Actualiza
  gri.NumerarFilas;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
  Modificado := true;
end;
//Acciones Ver
procedure TfrmAdminProduc.acVerArbCatExecute(Sender: TObject);
begin
  fraFiltArbol1.Visible := not fraFiltArbol1.Visible;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;
procedure TfrmAdminProduc.acHerMostRentabExecute(Sender: TObject);
{Muestra una columna de rentabilidad}
var
  f: Integer;
  rent: Double;
begin
  //Aegura que exista la columna
  colRentab := gri.BuscarColumna('RENTABILIDAD');
  if colRentab = nil then begin
    colRentab := gri.AgrEncabNum('RENTABILIDAD', 50);
  end;
  grilla.ColCount:=gri.cols.Count;   //Hace espacio
  gri.DimensColumnas;   //actualiza anchos
  fraFiltCampo.AgregarColumnaFiltro('Por RENTABILIDAD', colRentab.idx);
  //Calcula la rentabilidad
  for f := 1 to grilla.RowCount-1 do begin
    try
      GrillaAReg(f, regAux);
      if regAux.PreCosto = 0 then begin
        grilla.Cells[colRentab.idx, f] := '0';
      end else begin
        //Se está usando una fórmula modificada. Realmente sería el Margen Sobre las Compras.
        rent := (regAux.PreVenta-regAux.PreCosto)/regAux.PreCosto;
        grilla.Cells[colRentab.idx, f] := Format('%.2f', [rent]);
      end;
    except
    end;
  end;
end;

end.

