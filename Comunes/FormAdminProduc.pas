{Formualrio para la ediciónm de los productos}
unit FormAdminProduc;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, Menus, ActnList, StdCtrls, LCLProc, LCLType, Clipbrd,
  UtilsGrilla, CibTabProductos, CibUtils, FrameFiltCampo,
  FrameFiltArbol, FrameEditGrilla, MisUtils;
type
  { TfrmAdminProduc }
  TfrmAdminProduc = class(TForm)
  published
    acArcSalir: TAction;
    acArcGrabar: TAction;
    acArcValidar: TAction;
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
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    procedure acArcGrabarExecute(Sender: TObject);
    procedure acArcValidarExecute(Sender: TObject);
    procedure acHerMostRentabExecute(Sender: TObject);
    procedure acVerArbCatExecute(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure fraGri_Modificado(TipModif: TugTipModif; filAfec: integer);
    procedure fraGri_ReqNuevoReg(fil: integer);
  private
    TabPro: TCibTabProduc;
    fraFiltArbol1: TfraFiltArbol;
    FormatMon: string;
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function griLeerColorFondo(col, fil: integer): TColor;
    procedure RefrescarFiltros;
  public
    fraGri     : TfraEditGrilla;
    Modificado:  boolean;
    OnGrabado : procedure of object;
    procedure Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
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
procedure TfrmAdminProduc.Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
begin
  TabPro := TabPro0;
  //Configura frame
  fraGri.IniEncab(TabPro);
  colCodigo := fraGri.AgrEncabTxt   ('CÓDIGO'        , 60, 'ID_PROD');
  colCateg  := fraGri.AgrEncabTxt   ('CATEGORÍA'     , 70, 'CATEGORIA');
  colSubcat := fraGri.AgrEncabTxt   ('SUBCATEGORÍA'  , 80, 'SUBCATEGORIA');
  colPreUni := fraGri.AgrEncabNum   ('PRC.UNITARIO'  , 55, 'PREVENTA');
  colDescri := fraGri.AgrEncabTxt   ('DESCRIPCIÓN'   ,180, 'DESCRIPCION');
  colStock  := fraGri.AgrEncabNum   ('STOCK'         , 40, 'STOCK');
  colStock.editable:=false;   //Los cambios de stock, son otro proceso
  colMarca  := fraGri.AgrEncabTxt   ('MARCA'         , 50, 'MARCA');
  colUniCom := fraGri.AgrEncabTxt   ('UNID. DE COMPRA',70, 'UNIDCOMP');
  colPreCos := fraGri.AgrEncabNum   ('PRECIO COSTO'  , 55, 'PRECOSTO');
  colFecCre := fraGri.AgrEncabDatTim('FECHA CREACION', 70, 'FECCRE');
  colFecMod := fraGri.AgrEncabDatTim('FECHA MODIFIC.', 70, 'FECMOD');
  fraGri.FinEncab;
  fraGri.AddRowEnter := true;  //Para que se puedan agregar nuevas filas
  if fraGri.MsjError<>'' then begin
    //Muestra posible mensaje de error, pero deja seguir.
    MsgErr(fraGri.MsjError);
  end;
  //Define restricciones a los campos
  colCodigo.restric:= [ucrNotNull, ucrUnique];
  colCateg.restric:=[ucrNotNull];   //no nulo
  colSubcat.restric:=[ucrNotNull];   //no nulo
  colDescri.restric:=[ucrNotNull];   //no nulo

  fraFiltCampo.Inic(fraGri.gri, 5);
  fraFiltCampo.OnCambiaFiltro:=@RefrescarFiltros;
  fraFiltCampo.OnKeyDown:=@fraFiltCampoKeyDown;

  fraFiltArbol1.Inic(fraGri.gri, colCateg, colSubcat, 'Productos');
  fraFiltArbol1.OnCambiaFiltro:= @RefrescarFiltros;
  fraFiltArbol1.OnSoliCerrar:=@acVerArbCatExecute;
  ///////////////////////////
  FormatMon := FormatMoneda;
  fraGri.ReadFromTable;

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
  fraFiltArbol1.Visible:=false;
  //Configura Frame de grilla
  fraGri        := TfraEditGrilla.Create(self);
  fraGri.Parent := self;
  fraGri.Align  := alClient;
  fraGri.OnGrillaModif:=@fraGri_Modificado;
  fraGri.OnReqNuevoReg:=@fraGri_ReqNuevoReg;

end;
procedure TfrmAdminProduc.FormShow(Sender: TObject);
begin
  //Se configura aquí (En OnShow), proque se necesita que se haya cargado la
  //configuración.
  colPreUni.formato := FormatMon;
  colPreCos.formato := FormatMon;
end;
procedure TfrmAdminProduc.fraGri_Modificado(TipModif: TugTipModif;
  filAfec: integer);
begin
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;
procedure TfrmAdminProduc.fraGri_ReqNuevoReg(fil: integer);
begin
  //Llena los campos por defecto.
  colCodigo.ValStr[fil] := '#'+IntToStr(fraGri.RowCount);
  colPreUni.ValNum[fil] := 0;
  colStock.ValNum[fil] := 0;
  colPreCos.ValNum[fil] := 0;
  colFecCre.ValDatTim[fil] := now;
  colFecMod.ValDatTim[fil] := now;
end;
function TfrmAdminProduc.griLeerColorFondo(col, fil: integer): TColor;
begin
  Result := clWhite;
end;
procedure TfrmAdminProduc.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    fraGri.SetFocus;
  end;
end;
procedure TfrmAdminProduc.FormDestroy(Sender: TObject);
begin
  fraGri.Destroy;
end;

procedure TfrmAdminProduc.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    if Key = VK_F3 then fraFiltCampo.SetFocus;
    if (Key = VK_ESCAPE) and (btnCerrar.Focused or
                              btnGrabar.Focused or
                              btnValidar.Focused or
                              btnMostCateg.Focused) then fraGri.SetFocus;
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
  if fraGri.MsjError<>'' then exit;
  if OnGrabado<>nil then OnGrabado();  //El evento es quien grabará
  fraFiltArbol1.LeerCategorias;
  self.ActiveControl := nil;   //Para no quedarse copn el enfoque
end;
procedure TfrmAdminProduc.acArcValidarExecute(Sender: TObject);
{Realiza la validación de los campos de la grilla. Esto implica ver si los valores de
cadena, contenidos en todos los campos, se pueden traducir a los valores nativos del
tipo TRegProdu, y si son valores legales.}
begin
  fraGri.ValidarGrilla;  //Puede mostrar mensaje de error
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
  regAux: TCibRegProduc;   //registro auxiliar
begin
  regAux:= TCibRegProduc.Create;  //registro auxiliar
  colRentab := fraGri.BuscAgreEncabNum('RENTABILIDAD', 50);  //agrega si no existe
  colRentab.formato:='%.2f';
  fraFiltCampo.AgregarColumnaFiltro('Por RENTABILIDAD', colRentab.idx);
  //Calcula la rentabilidad
  for f := 1 to fraGri.RowCount-1 do begin
    try
      fraGri.GrillaAReg(f, regAux);
      if regAux.PreCosto = 0 then begin
        colRentab.ValNum[f] := 0;
      end else begin
        //Se está usando una fórmula modificada. Realmente sería el Margen Sobre las Compras.
        colRentab.ValNum[f] := (regAux.PreVenta-regAux.PreCosto)/regAux.PreCosto;
      end;
    except
    end;
  end;
  regAux.Destroy;
end;

end.
//304
