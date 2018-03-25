unit FormAdminInsum;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, Menus, ActnList, StdCtrls, LCLProc, LCLType, Clipbrd,
  UtilsGrilla, CibTabInsumos, CibUtils, FrameFiltCampo,
  FrameFiltArbol, FrameEditGrilla, FormCalcul, MisUtils;
type
  { TfrmAdminInsum }
  TfrmAdminInsum = class(TForm)
    acArcGrabar: TAction;
    acArcSalir: TAction;
    acArcValidar: TAction;
    acVerCalcul: TAction;
    ActionList1: TActionList;
    acVerArbCat: TAction;
    btnGrabar: TBitBtn;
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
    procedure acArcGrabarExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acArcValidarExecute(Sender: TObject);
    procedure acVerArbCatExecute(Sender: TObject);
    procedure acVerCalculExecute(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private  //Referencias a columnas
    colCodigo: TugGrillaCol;
    colCateg: TugGrillaCol;
    colSubcat: TugGrillaCol;
    colDescri: TugGrillaCol;
    colUso   : TugGrillaCol;
    colStock : TugGrillaCol;
    colMarca : TugGrillaCol;
    colUniCom: TugGrillaCol;
    colPreCos: TugGrillaCol;
    colProvee: TugGrillaCol;
    colUltCom: TugGrillaCol;
    colComent: TugGrillaCol;
    procedure fraFiltCampoCambiaFiltro;
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fraGri_Modificado(TipModif: TugTipModif; filAfec: integer);
    procedure fraGri_ReqNuevoReg(fil: integer);
    function griLeerColorFondo(col, fil: integer): TColor;
  private
    TabIns: TCibTabInsumo;
    fraFiltArbol1: TfraFiltArbol;
    FormatMon: string;
    procedure RefrescarFiltros;
  public
    fraGri     : TfraEditGrilla;
    Modificado : boolean;
    OnGrabado : procedure of object;
    procedure Exec(TabPro0: TCibTabInsumo; FormatMoneda: string);
    procedure Habilitar(estado: boolean);
  end;

var
  frmAdminInsum: TfrmAdminInsum;

implementation

{$R *.lfm}

{ TfrmAdminInsum }

procedure TfrmAdminInsum.RefrescarFiltros;
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
procedure TfrmAdminInsum.Exec(TabPro0: TCibTabInsumo; FormatMoneda: string);
begin
  TabIns := TabPro0;
  //Configura frame
  fraGri.IniEncab(TabIns);
  colCodigo := fraGri.AgrEncabTxt   ('CÓDIGO'          , 50, 'ID_INSUM');
  colCateg  := fraGri.AgrEncabTxt   ('CATEGORÍA'       , 60, 'CATEGORIA');
  colSubcat := fraGri.AgrEncabTxt   ('SUBCATEGORÍA'    , 60, 'SUBCATEGORIA');
  colDescri := fraGri.AgrEncabTxt   ('DESCRIPCIÓN'     ,180, 'DESCRIPCION');
  colUso    := fraGri.AgrEncabTxt   ('USO'             , 70, 'USO');
  colStock  := fraGri.AgrEncabNum   ('STOCK'           , 40, 'STOCK');
  colMarca  := fraGri.AgrEncabTxt   ('MARCA RECOMENDADA',70, 'MARCA');
  colUniCom := fraGri.AgrEncabTxt   ('UNID. DE COMPRA' , 80, 'UNIDCOMP');
  colPreCos := fraGri.AgrEncabNum   ('PRECIO COSTO'    , 55, 'PRECOSTO');
  colProvee := fraGri.AgrEncabTxt   ('PROVEEDOR'       ,100, 'PROVEE');
  colUltCom := fraGri.AgrEncabDatTim('FECHA ULT. COMPRA',70, 'ULTCOM');
  colComent := fraGri.AgrEncabTxt   ('COMENTARIO'      ,100, 'COMENT');
  fraGri.FinEncab;
  if fraGri.MsjError<>'' then begin
    //Muestra posible mensaje de error, pero deja seguir.
    MsgErr(fraGri.MsjError);
  end;
  //Define restricciones a los campos
  colCodigo.restric:= [ucrNotNull, ucrUnique];
  colCateg.restric:=[ucrNotNull];   //no nulo
  colSubcat.restric:=[ucrNotNull];   //no nulo
  colDescri.restric:=[ucrNotNull];   //no nulo

  fraFiltCampo.Inic(fraGri.gri, 4);
  fraFiltCampo.OnCambiaFiltro:=@fraFiltCampoCambiaFiltro;
  fraFiltCampo.OnKeyDown:=@fraFiltCampoKeyDown;

  fraFiltArbol1.Inic(fraGri.gri, colCateg, colSubcat, 'Productos');
  fraFiltArbol1.OnCambiaFiltro:= @fraFiltCampoCambiaFiltro;
  fraFiltArbol1.OnSoliCerrar:=@acVerArbCatExecute;
  //////////////////////////////////////////
  FormatMon := FormatMoneda;
  fraGri.ReadFromTable;

  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
end;
procedure TfrmAdminInsum.Habilitar(estado: boolean);
{Configura el estado de los botones}
begin
  btnGrabar.Enabled:=estado;
end;
procedure TfrmAdminInsum.FormCreate(Sender: TObject);
begin
  fraFiltArbol1:= TfraFiltArbol.Create(self);
  fraFiltArbol1.Parent := self;
  fraFiltArbol1.Align := alLeft;
  Splitter1.Align := alLeft;
  fraFiltArbol1.Visible:=false;

  fraGri        := TfraEditGrilla.Create(self);
  fraGri.Parent := self;
  fraGri.Align  := alClient;
  fraGri.OnGrillaModif:=@fraGri_Modificado;
  fraGri.OnReqNuevoReg:=@fraGri_ReqNuevoReg;
end;
procedure TfrmAdminInsum.FormShow(Sender: TObject);
begin
  //Se configura aquí (En OnShow), proque se necesita que se haya cargado la
  //configuración.
  colPreCos.formato := FormatMon;
end;
function TfrmAdminInsum.griLeerColorFondo(col, fil: integer): TColor;
begin
  Result := clWhite;
end;
procedure TfrmAdminInsum.fraFiltCampoCambiaFiltro;
begin
  RefrescarFiltros;
end;
procedure TfrmAdminInsum.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    fraGri.SetFocus;
  end;
end;
procedure TfrmAdminInsum.fraGri_Modificado(TipModif: TugTipModif;
  filAfec: integer);
begin
  fraFiltArbol1.LeerCategorias;
//  RefrescarFiltros;
end;
procedure TfrmAdminInsum.fraGri_ReqNuevoReg(fil: integer);
begin
  //Llena los campos por defecto.
  colCodigo.ValStr[fil] := '#'+IntToStr(fraGri.RowCount);
  colStock.ValNum[fil] := 0;
  colPreCos.ValNum[fil] := 0;
  colUltCom.ValDatTim[fil] := now;
end;
procedure TfrmAdminInsum.FormDestroy(Sender: TObject);
begin
  fraGri.Destroy;
end;
procedure TfrmAdminInsum.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F3 then fraFiltCampo.SetFocus;
  if (Key = VK_ESCAPE) and (btnCerrar.Focused or
                            btnGrabar.Focused or
                            btnValidar.Focused or
                            btnMostCateg.Focused) then fraGri.SetFocus;
end;
procedure TfrmAdminInsum.btnCerrarClick(Sender: TObject);
begin
  Self.Close;
end;
procedure TfrmAdminInsum.btnMostCategClick(Sender: TObject);
{Se hace esta llamada por código, porque no se puede asoicar fácilmente un TBitBtn
a un acción, mostrando solo el ícono.}
begin
  acVerArbCatExecute(self);
end;

///////////////////////// Acciones ////////////////////////////////
procedure TfrmAdminInsum.acArcSalirExecute(Sender: TObject);
begin
  Close;
end;
procedure TfrmAdminInsum.acArcGrabarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
begin
  fraGri.ValidarGrilla;  //Puede mostrar mensaje de error
  if fraGri.MsjError<>'' then exit;
  if OnGrabado<>nil then OnGrabado();  //El evento es quien grabará
  fraFiltArbol1.LeerCategorias;
  self.ActiveControl := nil;   //Para no quedarse copn el enfoque
end;
procedure TfrmAdminInsum.acArcValidarExecute(Sender: TObject);
{Realiza la validación de los campos de la grilla. Esto implica ver si los valores de
cadena, contenidos en todos los campos, se pueden traducir a los valores nativos del
tipo TRegProdu, y si son valores legales.}
begin
  fraGri.ValidarGrilla;  //Puede mostrar mensaje de error
  if fraGri.MsjError='' then begin
    MsgBox('Validación Exitosa.');
  end;
end;
//Acciones Ver
procedure TfrmAdminInsum.acVerArbCatExecute(Sender: TObject);
begin
  fraFiltArbol1.Visible := not fraFiltArbol1.Visible;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;
procedure TfrmAdminInsum.acVerCalculExecute(Sender: TObject);
begin
  frmCalcul.Show;
end;

end.
//354
