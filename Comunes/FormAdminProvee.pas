unit FormAdminProvee;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ComCtrls, ActnList, Grids, Menus, LCLType, LCLProc,
  FrameFiltCampo, UtilsGrilla, FrameFiltArbol, MisUtils, CibProductos, CibUtils;
type
  { TfrmAdminProvee }
  TfrmAdminProvee = class(TForm)
    acArcAplicar: TAction;
    acArcSalir: TAction;
    acArcValidar: TAction;
    acEdiCopCel: TAction;
    acEdiCopFil: TAction;
    acEdiElimin: TAction;
    acEdiNuevo: TAction;
    acEdiPegar: TAction;
    acHerMostRentab: TAction;
    ActionList1: TActionList;
    acVerArbCat: TAction;
    btnAplicar: TBitBtn;
    btnCerrar: TBitBtn;
    btnMostCateg: TBitBtn;
    btnValidar: TBitBtn;
    chkMostInac: TCheckBox;
    fraFiltCampo: TfraFiltCampo;
    grilla: TStringGrid;
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
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    procedure acArcSalirExecute(Sender: TObject);
    procedure SolicCerrarArbol;
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acArcAplicarExecute(Sender: TObject);
    procedure acArcValidarExecute(Sender: TObject);
    procedure acEdiCopCelExecute(Sender: TObject);
    procedure acEdiCopFilExecute(Sender: TObject);
    procedure acEdiEliminExecute(Sender: TObject);
    procedure acEdiNuevoExecute(Sender: TObject);
    procedure acEdiPegarExecute(Sender: TObject);
    procedure acVerArbCatExecute(Sender: TObject);
  private  //Referencias a columnas
    colCodigo: TugGrillaCol;
    colCateg: TugGrillaCol;
    colSubcat: TugGrillaCol;
    colNomEmp: TugGrillaCol;
    colProductos: TugGrillaCol;
    colContacto: TugGrillaCol;
    colTelefono: TugGrillaCol;
    colEnvio   : TugGrillaCol;
    colDirecc  : TugGrillaCol;
    colNotas   : TugGrillaCol;
    colUltComp : TugGrillaCol;
    colEstado  : TugGrillaCol;
    procedure GrillaAReg(f: integer; reg: TCibRegProvee);
    procedure ListaAGrilla;
    procedure RegAGrilla(reg: TCibRegProvee; f: integer);
  private
    gri : TGrillaEdicFor;
    TabPro: TCibTabProvee;
    Modificado : boolean;
    regAux: TCibRegProvee;   //registro auxiliar
    fraFiltArbol1: TfraFiltArbol;
    procedure FiltroCambiaFiltro;
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function griLeerColorFondo(col, fil: integer): TColor;
    procedure gri_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gri_FinEditarCelda(var eveSal: TEvSalida; col, fil: integer;
                                ValorAnter, ValorNuev: string);
    procedure RefrescarFiltros;
    procedure gri_MouseUp(Sender: TObject; Button: TMouseButton;
                          Shift: TShiftState; X, Y: Integer);
    function GrillaALista: boolean;
  public
  public
    procedure Exec(TabPro0: TCibTabProvee);
  end;

var
  frmAdminProvee: TfrmAdminProvee;

implementation

{$R *.lfm}

{ TfrmAdminProvee }
procedure TfrmAdminProvee.RefrescarFiltros;
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
procedure TfrmAdminProvee.gri_MouseUp(Sender: TObject; Button: TMouseButton;
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
procedure TfrmAdminProvee.RegAGrilla(reg: TCibRegProvee; f: integer);
{Mueve un registro de la tabla de productos, a una fila de la grilla}
begin
  colCodigo.ValStr[f]   := reg.Cod;
  colCateg.ValStr[f]    := reg.Categ;
  colSubcat.ValStr[f]   := reg.Subcat;
  colNomEmp.ValStr[f]   := reg.NomEmpresa;
  colProductos.ValStr[f]:= reg.Productos;
  colContacto.ValStr[f] := reg.Contacto;
  colTelefono.ValStr[f] := reg.Telefono;
  colEnvio.ValBool[f]   := reg.Envio;
  colDirecc.ValStr[f]   := reg.Direccion;
  colNotas.ValStr[f]    := reg.Notas;
  colUltComp.ValDatTim[f]:=reg.UltCompra;
  colEstado.ValChr[f]   := reg.Estado;
end;
procedure TfrmAdminProvee.GrillaAReg(f: integer; reg: TCibRegProvee);
begin
  reg.Cod       := colCodigo.ValStr[f];
  reg.Categ     := colCateg.ValStr[f];
  reg.Subcat    := colSubcat.ValStr[f];
  reg.NomEmpresa:= colNomEmp.ValStr[f];
  reg.Productos := colProductos.ValStr[f];
  reg.Contacto  := colContacto.ValStr[f];
  reg.Telefono  := colTelefono.ValStr[f];
  reg.Envio     := colEnvio.ValBool[f];
  reg.Direccion := colDirecc.ValStr[f];
  reg.Notas     := colNotas.ValStr[f];
  reg.UltCompra := colUltComp.ValDatTim[f];
  reg.Estado    := colEstado.ValChr[f];
end;
procedure TfrmAdminProvee.ListaAGrilla;
{Mueve datos de la lista a la grills}
var
  f: Integer;
  reg: TCibRegProvee;
  n: LongInt;
begin
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  n := TabPro.Proveedores.Count+1;
  grilla.RowCount:= n;
  f := 1;
  for reg in TabPro.Proveedores do begin
    grilla.Cells[0, f] := IntToStr(f);
    RegAGrilla(reg, f);
    f := f + 1;
  end;
  grilla.EndUpdate();
end;
function TfrmAdminProvee.GrillaALista: boolean;
var
  f: Integer;
  reg: TCibRegProvee;
begin
  //Mueve datos a la lista. Si se ah ehcho la validación, no debería fallar.
  TabPro.Proveedores.Clear;
  for f:=1 to grilla.RowCount-1 do begin
    reg := TCibRegProvee.Create;
    GrillaAReg(f, reg);
    TabPro.Proveedores.Add(reg);
  end;
  exit(true);
end;
procedure TfrmAdminProvee.SolicCerrarArbol;
begin
  acVerArbCatExecute(self);
end;
procedure TfrmAdminProvee.btnMostCategClick(Sender: TObject);
{Se hace esta llamada por código, porque no se puede asoicar fácilmente un TBitBtn
a un acción, mostrando solo el ícono.}
begin
  acVerArbCatExecute(self);
end;
procedure TfrmAdminProvee.FormCreate(Sender: TObject);
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
                 gri.AgrEncabNum   ('N°'          , 25);
  colCodigo   := gri.AgrEncabTxt   ('CÓDIGO'      , 60);
  colCateg    := gri.AgrEncabTxt   ('CATEGORÍA'   , 70);
  colSubcat   := gri.AgrEncabTxt   ('SUBCATEGORÍA', 80);
  colNomEmp   := gri.AgrEncabTxt   ('NOMB.EMPRESA', 80);
  colProductos:= gri.AgrEncabTxt   ('PRODUCTOS'   , 60);
  colContacto := gri.AgrEncabTxt   ('CONTACTOS'   , 60);
  colTelefono := gri.AgrEncabTxt   ('TELÉFONO'    , 60);
  colEnvio    := gri.AgrEncabBool  ('ENVÍO'       , 60);
  colDirecc   := gri.AgrEncabTxt   ('DIRECCIÓN'   , 60);
  colNotas    := gri.AgrEncabTxt   ('NOTAS'       , 60);
  colUltComp  := gri.AgrEncabDatTim('FEC. ÚLTIMA COMPRA', 60);
  colEstado   := gri.AgrEncabChr   ('ESTADO', 20);
  gri.FinEncab;
  //Define restricciones a los campos
  colCodigo.restric:= [ucrNotNull, ucrUnique];
  colCateg.restric:=[ucrNotNull];   //no nulo
  colSubcat.restric:=[ucrNotNull];   //no nulo

  fraFiltCampo.Inic(gri, 3);
  fraFiltCampo.OnCambiaFiltro:= @FiltroCambiaFiltro;
  fraFiltCampo.OnKeyDown:=@fraFiltCampoKeyDown;

  fraFiltArbol1.Inic(gri, colCateg, colSubcat, 'Proveedores');
  fraFiltArbol1.OnCambiaFiltro:= @FiltroCambiaFiltro;
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

  regAux:= TCibRegProvee.Create;  //registro auxiliar
end;
procedure TfrmAdminProvee.FormDestroy(Sender: TObject);
begin
  regAux.Destroy;
  gri.Destroy;
end;
procedure TfrmAdminProvee.FiltroCambiaFiltro;
begin
  RefrescarFiltros;
end;
procedure TfrmAdminProvee.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    grilla.SetFocus;
  end;
end;
function TfrmAdminProvee.griLeerColorFondo(col, fil: integer): TColor;
begin
  Result := clWhite;
end;
procedure TfrmAdminProvee.gri_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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
procedure TfrmAdminProvee.gri_FinEditarCelda(var eveSal: TEvSalida; col,
  fil: integer; ValorAnter, ValorNuev: string);
begin
  if eveSal in [evsTecEnter, evsTecTab, evsEnfoque] then begin
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
procedure TfrmAdminProvee.Exec(TabPro0: TCibTabProvee);
begin
  TabPro := TabPro0;
  ListaAGrilla;  //Hace el llenado inicial de productos
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
end;
///////////////////////// Acciones ////////////////////////////////
procedure TfrmAdminProvee.acArcSalirExecute(Sender: TObject);
begin

end;
procedure TfrmAdminProvee.acArcAplicarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
begin
  acArcValidarExecute(self);
  if gri.MsjError<>'' then exit;
  GrillaALista; //ya no debería fallar
  //Ya está actualizado "TabPro.Proveedores", ahora solo falta actualizar en disco.
  TabPro.GrabarADisco;  //Podría generar error en "TabPro.MsjError"
  Modificado := false;
  fraFiltArbol1.LeerCategorias;
  self.ActiveControl := nil;
end;
procedure TfrmAdminProvee.acArcValidarExecute(Sender: TObject);
{Realiza la validación de los campos de la grilla. Esto implica ver si los valores de
cadena, contenidos en todos los campos, se pueden traducir a los valores netivos del
tipo TCibRegProduc, y si son valores legales.}
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
procedure TfrmAdminProvee.acEdiCopCelExecute(Sender: TObject);
begin
  gri.CopiarCampo;
end;
procedure TfrmAdminProvee.acEdiCopFilExecute(Sender: TObject);
begin
  gri.CopiarFila;
end;
procedure TfrmAdminProvee.acEdiPegarExecute(Sender: TObject);
begin
  gri.PegarACampo;
end;
procedure TfrmAdminProvee.acEdiNuevoExecute(Sender: TObject);
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
  colEstado.ValChr[f] := ' ';
  //Ubica fila seleccionada
  grilla.Row := f;
  //Actualiza
  gri.NumerarFilas;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
  Modificado := true;
end;
procedure TfrmAdminProvee.acEdiEliminExecute(Sender: TObject);
{Elimina el registro seleccionado.}
var
  tmp: String;
begin
  if grilla.Row<1 then exit;;
  tmp := colNomEmp.ValStr[grilla.Row];
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
procedure TfrmAdminProvee.acVerArbCatExecute(Sender: TObject);
begin
  fraFiltArbol1.Visible := not fraFiltArbol1.Visible;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;

end.

