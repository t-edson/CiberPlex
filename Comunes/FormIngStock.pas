{Formulario para el ingreso de stock}
unit FormIngStock;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, LCLType, ActnList, UtilsGrilla, FrameFiltCampo,
  FrameFiltArbol, MisUtils, CibTabProductos, FrameEditGrilla, CibUtils,
  CibGrillas;
type

  { TfrmIngStock }

  TfrmIngStock = class(TForm)
    acArcGrabar: TAction;
    acArcSalir: TAction;
    acArcValidar: TAction;
    ActionList1: TActionList;
    acVerArbCat: TAction;
    btnCerrar: TBitBtn;
    btnClose: TSpeedButton;
    btnFind: TSpeedButton;
    btnGrabar: TBitBtn;
    btnMostCateg: TBitBtn;
    chkMostInac: TCheckBox;
    ComboBox2: TComboBox;
    Edit1: TEdit;
    fraFiltArbol1: TfraFiltArbol;
    fraFiltCampo: TfraFiltCampo;
    ImageList1: TImageList;
    lblFiltCateg: TLabel;
    lblNumRegist: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    procedure acArcGrabarExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acVerArbCatExecute(Sender: TObject);
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    TabPro: TCibTabProduc;
    colStock: TugGrillaCol;
    colAgrStk: TugGrillaCol;
    colCodigo: TugGrillaCol;
    colCateg : TugGrillaCol;
    colSubcat: TugGrillaCol;
    colPreUni: TugGrillaCol;
    colDescri: TugGrillaCol;
    colMarca : TugGrillaCol;
    colUniCom: TugGrillaCol;
    FormatMon: string;
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fraGriCeldaEditada(var eveSal: TEvSalida; col, fil: integer;
      var ValorAnter, ValorNuev: string);
    function fraGriLeerColorFondo(col, fil: integer; EsSelec: boolean): TColor;
    procedure RefrescarFiltros;
  public
    fraGri     : TfraEditGrilla;
    OnGrabado : procedure of object;
    function TabIngStock: string;
    procedure Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
  end;

var
  frmIngStock: TfrmIngStock;

implementation
{$R *.lfm}
procedure TfrmIngStock.RefrescarFiltros;
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
function TfrmIngStock.TabIngStock: string;
{Devuelve en texto, una tabla con la estructura:
<ID><#9><Ingreso de stock>
Solo incluye a los ID de productos que tienen Incremento de stock <> 0.
}
var
  f: Integer;
  id, agrStk: String;
begin
  Result := '';
  for f:=1 to fraGri.grilla.RowCount-1 do begin
    id := fraGri.grilla.Cells[colCodigo.idx, f];
    agrStk := fraGri.grilla.Cells[colAgrStk.idx, f];
    if trim(agrStk) = '' then continue;
    if colAgrStk.ValNum[f] = 0 then continue;
    if Result = '' then begin
      Result += id  + #9 + agrStk;
    end else begin
      Result += LineEnding + id  + #9 + agrStk;
    end;
  end;
end;
procedure TfrmIngStock.FormCreate(Sender: TObject);
begin
  //Configura Frame de grilla
  fraGri        := TfraEditGrilla.Create(self);
  fraGri.Parent := self;
  fraGri.Align  := alClient;
//  fraGri.OnGrillaModif:=@fraGri_Modificado;
//  fraGri.OnReqNuevoReg:=@fraGri_ReqNuevoReg;
end;
procedure TfrmIngStock.FormDestroy(Sender: TObject);
begin
  fraGri.Destroy;
end;
procedure TfrmIngStock.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F3 then begin
    fraFiltCampo.SetFocus;
  end;
end;
procedure TfrmIngStock.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    fraGri.SetFocus;
  end;
end;
procedure TfrmIngStock.fraGriCeldaEditada(var eveSal: TEvSalida; col,
  fil: integer; var ValorAnter, ValorNuev: string);
begin
  if eveSal = evsTecEnter then begin
     //Se pulsó <enter>
    if col = colAgrStk.idx then begin
      //En la columna "AGREGAR"
      fraGri.grilla.Col := col;   //Por si se ha movido
      if fraGri.grilla.Row < fraGri.grilla.RowCount-1 then begin
        //Pasa a la siguienet fila
        fraGri.grilla.Row := fraGri.grilla.Row + 1;
      end;
    end;
  end;
end;
function TfrmIngStock.fraGriLeerColorFondo(col, fil: integer; EsSelec: boolean
  ): TColor;
const
  COL_SEL = $D0D0D0;
begin
  if colStock.ValNum[fil] < 0 then begin
    //Stock negativo
    if EsSelec then begin
      Result := COL_SEL + $000010;
    end else begin
      Result := $C0C0E0;
    end;
  end else begin
    if EsSelec then begin
      Result := COL_SEL;
    end else begin
      Result := clWhite;
    end;
  end;
end;
procedure TfrmIngStock.Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
begin
  TabPro := TabPro0;
  //Configura frame
  fraGri.IniEncab(TabPro);
  colCodigo := fraGri.AgrEncabTxt  ('CÓDIGO'        , 60, 'ID_PROD');
  colCodigo.visible := false;
  colCodigo.editable:=false;
  colCateg  := fraGri.AgrEncabTxt  ('CATEGORÍA'     , 70, 'CATEGORIA');
  colCateg.editable:=false;
  colSubcat := fraGri.AgrEncabTxt  ('SUBCATEGORÍA'  , 80, 'SUBCATEGORIA');
  colSubcat.editable:=false;
  colPreUni := fraGri.AgrEncabNum   ('PRC.UNITARIO'  , 55, 'PREVENTA');
  colPreUni.editable := false;
  colPreUni.visible := false;
  colDescri := fraGri.AgrEncabTxt  ('DESCRIPCIÓN'   ,180, 'DESCRIPCION');
  colDescri.editable:=false;
  colStock  := fraGri.AgrEncabNum  ('STOCK'         , 40, 'STOCK');
  colStock.editable := false;
  colAgrStk  := fraGri.AgrEncabNum ('AGREGAR'       , 45);
  colAgrStk.editable := true;
  colMarca := fraGri.AgrEncabTxt   ('MARCA'         , 50, 'MARCA');
  colMarca.visible := false;
  colUniCom := fraGri.AgrEncabTxt  ('UNID. DE COMPRA',70, 'UNIDCOMP');
  colUniCom.visible := false;
  fraGri.FinEncab;
  if fraGri.MsjError<>'' then begin
    //Muestra posible mensaje de error, pero deja seguir.
    MsgErr(fraGri.MsjError);
  end;
  fraGri.OnLeerColorFondo := @fraGriLeerColorFondo;
  fraGri.OnCeldaEditada := @fraGriCeldaEditada;
  //Define restricciones a los campos
  colCodigo.restric:= [ucrNotNull, ucrUnique];
  colCateg.restric:=[ucrNotNull];   //no nulo
  colSubcat.restric:=[ucrNotNull];   //no nulo
  colDescri.restric:=[ucrNotNull];   //no nulo

  fraFiltCampo.Inic(fraGri.gri, 4);
  fraFiltCampo.OnCambiaFiltro := @RefrescarFiltros;
  fraFiltCampo.OnKeyDown := @fraFiltCampoKeyDown;

  fraFiltArbol1.Inic(fraGri.gri, colCateg, colSubcat, 'Productos');
  fraFiltArbol1.OnCambiaFiltro:= @RefrescarFiltros;
  fraFiltArbol1.OnSoliCerrar:=@acVerArbCatExecute;
  ///////////////////////////
  FormatMon := FormatMoneda;
  fraGri.acEdiNuevo.Visible := False;
  fraGri.acEdiElimin.Visible := False;
  fraGri.acEdiBajar.Visible := False;
  fraGri.acEdiSubir.Visible := False;
  fraGri.ReadFromTable;

  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
end;
procedure TfrmIngStock.btnMostCategClick(Sender: TObject);
begin
  acVerArbCatExecute(self);
end;
///////////////////////// Acciones ////////////////////////////////
procedure TfrmIngStock.acArcGrabarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
var
  tmp, lin, id: String;
  f: Integer;
  lineas: TStringList;
  a: TStringDynArray;
begin
  if MsgYesNo('¿Ingresar Stock?') <> 1 then exit;
  //acArcValidarExecute(self);
  if fraGri.MsjError<>'' then exit;
  if OnGrabado<>nil then OnGrabado();  //El evento es quien grabará
  fraFiltArbol1.LeerCategorias;
//  self.ActiveControl := nil;   //Para no quedarse con el enfoque
  self.ActiveControl := fraGri;
  //Lee cadena de incrementos
  tmp := TabIngStock;
  //Lee de disco y se limpia la columna de incrementos
  fraGri.ReadFromTable;
  //Pone cero en la columna de incrementos como indicador de que se modificó
  lineas := TStringList.Create;
  lineas.Text := tmp;  //Usa los datos leídos antes de actualziar la tabla
  for lin in lineas do begin
    //La línea es de tipo: <ID><#9><Ingreso de stock>
    a := Explode(#9, lin);
    id := a[0];
    f := fraGri.BuscarTxt(id, colCodigo.idx);
    if f =-1 then continue;  //no debería pasar
    colAgrStk.ValNum[f] := 0;
  end;
  lineas.Destroy;

end;
procedure TfrmIngStock.acArcSalirExecute(Sender: TObject);
begin

end;
procedure TfrmIngStock.acVerArbCatExecute(Sender: TObject);
begin
  fraFiltArbol1.Visible := not fraFiltArbol1.Visible;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;

end.

