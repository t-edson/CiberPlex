unit FormAdminProvee;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ActnList, Grids, Menus, LCLType, LCLProc,
  FrameFiltCampo, UtilsGrilla, FrameFiltArbol, FrameEditGrilla, MisUtils,
  CibProductos, CibUtils;
type
  { TfrmAdminProvee }
  TfrmAdminProvee = class(TForm)
    acArcGrabar: TAction;
    acArcSalir: TAction;
    acArcValidar: TAction;
    ActionList1: TActionList;
    acVerArbCat: TAction;
    btnAplicar: TBitBtn;
    btnCerrar: TBitBtn;
    btnMostCateg: TBitBtn;
    btnValidar: TBitBtn;
    chkMostInac: TCheckBox;
    fraFiltCampo: TfraFiltCampo;
    ImageList1: TImageList;
    lblFiltCateg: TLabel;
    lblNumRegist: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    procedure acArcSalirExecute(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SolicCerrarArbol;
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acArcGrabarExecute(Sender: TObject);
    procedure acArcValidarExecute(Sender: TObject);
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
    procedure fraGri_Modificado(TipModif: TugTipModif);
    procedure fraGri_ReqNuevoReg(fil: integer);
    procedure GrillaAReg(f: integer; reg: TCibRegProvee);
    procedure RegAGrilla(reg: TCibRegProvee; f: integer);
  private
    TabPro: TCibTabProvee;
    fraFiltArbol1: TfraFiltArbol;
    FormatMon  : string;
    procedure FiltroCambiaFiltro;
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure RefrescarFiltros;
  public
    Modificado : boolean;
    OnGrabado : procedure of object;
    fraGri     : TfraEditGrilla;
    procedure ListaAGrilla;
    function GrillaATabString: string;
    procedure Exec(TabPro0: TCibTabProvee; FormatMoneda: string);
    procedure Habilitar(estado: boolean);
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
  fraGri.LimpiarFiltros;
  lblFiltCateg.Caption:='';
  hayFiltro := false;
  //Verifica filtro de Árbol de categoría
  txtBusc := fraFiltArbol1.FiltroArbolCat;
  if txtBusc<>'' then begin
    hayFiltro := true;
    fraGri.AgregarFiltro(@fraFiltArbol1.Filtro);
    lblFiltCateg.Caption := 'Filtro de categ.: ' + txtBusc;
  end;
  //Verifica filtro de "fraFiltCampo"
  txtBusc := fraFiltCampo.txtBusq;
  if txtBusc<>'' then begin
    hayFiltro := true;
    fraGri.AgregarFiltro(@fraFiltCampo.Filtro);
    lblFiltCateg.Caption := lblFiltCateg.Caption + ', Texto de búsqueda: ' + txtBusc;
  end;
  fraGri.Filtrar;   //Filtra con todos los filtros agregados
  if hayFiltro then begin
    lblFiltCateg.Visible:=true;
    MensajeVisibles(lblNumRegist, fraGri.RowCount-1, fraGri.filVisibles, clBlue);
  end else begin
    MensajeVisibles(lblNumRegist, fraGri.RowCount-1, fraGri.RowCount-1);
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
  colEnvio.ValStr[f]   := reg.Envio;
  colDirecc.ValStr[f]   := reg.Direccion;
  colNotas.ValStr[f]    := reg.Notas;
  colUltComp.ValDatTim[f]:=reg.UltCompra;
  colEstado.ValStr[f]   := reg.Estado;
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
  reg.Envio     := colEnvio.ValStr[f];
  reg.Direccion := colDirecc.ValStr[f];
  reg.Notas     := colNotas.ValStr[f];
  reg.UltCompra := colUltComp.ValDatTim[f];
  reg.Estado    := colEstado.ValStr[f];
end;
procedure TfrmAdminProvee.fraGri_Modificado(TipModif: TugTipModif);
begin
  fraFiltArbol1.LeerCategorias;
//  RefrescarFiltros;
  MensajeVisibles(lblNumRegist, fraGri.RowCount-1, fraGri.RowCount-1);
end;
procedure TfrmAdminProvee.fraGri_ReqNuevoReg(fil: integer);
begin
  colCodigo.ValStr[fil] := '#'+IntToStr(fraGri.RowCount-1);
//  colEstado.ValChr[fil] := ' ';
end;
procedure TfrmAdminProvee.ListaAGrilla;
{Mueve datos de la lista a la grills}
var
  f: Integer;
  reg: TCibRegProvee;
  n: LongInt;
  grilla: TStringGrid;
begin
  grilla := fraGri.grilla;
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  n := TabPro.Proveedores.Count+1;
  grilla.RowCount:= n;
  f := 1;
  for reg in TabPro.Proveedores do begin
    grilla.Cells[0, f] := IntToStr(f);  //ïnidce
    RegAGrilla(reg, f);
    f := f + 1;
  end;
  grilla.EndUpdate();
end;
function TfrmAdminProvee.GrillaATabString: string;
var
  TabTmp: TCibTabProvee;
  f: Integer;
  reg: TCibRegProvee;
begin
  //Mueve datos a lista temporal. Si se ha hecho la validación, no debería fallar.
  TabTmp:= TCibTabProvee.Create;   //lista temporal
  for f:=1 to fraGri.RowCount-1 do begin
    reg := TCibRegProvee.Create;
    GrillaAReg(f, reg);
    TabTmp.Proveedores.Add(reg);
  end;
  //Convierte lista a cadena
  TabTmp.SaveToString(Result);
  TabTmp.Destroy;
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
  fraFiltArbol1.Visible:=false;

  fraGri        := TfraEditGrilla.Create(self);
  fraGri.Parent := self;
  fraGri.Align  := alClient;
  //Configura grilla.
  //!!!!!!!!!!!!OJO: Deben agregarse todos los campso para que puedan preservarse en la edición.
  fraGri.IniEncab;
                 fraGri.AgrEncabNum   ('N°'          , 25);
  colCodigo   := fraGri.AgrEncabTxt   ('CÓDIGO'      , 30);
  colCateg    := fraGri.AgrEncabTxt   ('CATEGORÍA'   , 60);
  colSubcat   := fraGri.AgrEncabTxt   ('SUBCATEGORÍA', 70);
  colNomEmp   := fraGri.AgrEncabTxt   ('NOMB.EMPRESA', 90);
  colProductos:= fraGri.AgrEncabTxt   ('PRODUCTOS'   , 100);
  colContacto := fraGri.AgrEncabTxt   ('CONTACTOS'   , 80);
  colTelefono := fraGri.AgrEncabTxt   ('TELÉFONO'    , 80);
  colEnvio    := fraGri.AgrEncabTxt   ('ENVÍO'       , 40);
  colDirecc   := fraGri.AgrEncabTxt   ('DIRECCIÓN'   , 120);
  colNotas    := fraGri.AgrEncabTxt   ('NOTAS'       , 80);
  colUltComp  := fraGri.AgrEncabDatTim('FEC. ÚLTIMA COMPRA', 60);
  colEstado   := fraGri.AgrEncabTxt   ('ESTADO', 40);
  fraGri.FinEncab;
  fraGri.OnGrillaModif:=@fraGri_Modificado;
  fraGri.OnReqNuevoReg:=@fraGri_ReqNuevoReg;

  //Define restricciones a los campos
  colCodigo.restric:= [ucrNotNull, ucrUnique];
  colCateg.restric:=[ucrNotNull];   //no nulo
  colSubcat.restric:=[ucrNotNull];   //no nulo

  fraFiltCampo.Inic(fraGri.gri, 3);
  fraFiltCampo.OnCambiaFiltro:= @FiltroCambiaFiltro;
  fraFiltCampo.OnKeyDown:=@fraFiltCampoKeyDown;

  fraFiltArbol1.Inic(fraGri.gri, colCateg, colSubcat, 'Proveedores');
  fraFiltArbol1.OnCambiaFiltro:= @FiltroCambiaFiltro;
  fraFiltArbol1.OnSoliCerrar:=@SolicCerrarArbol;

end;
procedure TfrmAdminProvee.FormDestroy(Sender: TObject);
begin
  fraGri.Destroy;
end;
procedure TfrmAdminProvee.FiltroCambiaFiltro;
begin
  RefrescarFiltros;
end;
procedure TfrmAdminProvee.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    fraGri.SetFocus;
  end;
end;
procedure TfrmAdminProvee.Exec(TabPro0: TCibTabProvee; FormatMoneda: string);
begin
  TabPro := TabPro0;
  FormatMon := FormatMoneda;
  ListaAGrilla;  //Hace el llenado inicial de productos
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
end;
procedure TfrmAdminProvee.Habilitar(estado: boolean);
begin
  btnAplicar.Enabled:=estado;
end;
///////////////////////// Acciones ////////////////////////////////
procedure TfrmAdminProvee.acArcSalirExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmAdminProvee.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F3 then fraFiltCampo.SetFocus;
  if (Key = VK_ESCAPE) and (btnCerrar.Focused or
                            btnAplicar.Focused or
                            btnValidar.Focused or
                            btnMostCateg.Focused) then fraGri.SetFocus;
end;

procedure TfrmAdminProvee.acArcGrabarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
begin
  acArcValidarExecute(self);
  if fraGri.MsjError<>'' then exit;
  if OnGrabado<>nil then OnGrabado();  //El evento es quien grabará
  fraFiltArbol1.LeerCategorias;
  self.ActiveControl := nil;
end;
procedure TfrmAdminProvee.acArcValidarExecute(Sender: TObject);
{Realiza la validación de los campos de la grilla. Esto implica ver si los valores de
cadena, contenidos en todos los campos, se pueden traducir a los valores netivos del
tipo TCibRegProduc, y si son valores legales.}
begin
  fraGri.ValidarGrilla;  //Puede mostrar mensaje de error
end;
//Acciones Ver
procedure TfrmAdminProvee.acVerArbCatExecute(Sender: TObject);
begin
  fraFiltArbol1.Visible := not fraFiltArbol1.Visible;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;

end.
//312
