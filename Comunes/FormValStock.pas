{Formulario para el ingreso de stock}
unit FormValStock;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, StdCtrls, LCLType, ActnList, UtilsGrilla, FrameFiltCampo,
  FrameFiltArbol, BasicGrilla, MisUtils, CibTabProductos, FrameEditGrilla,
  CibUtils;
type

  { TfrmValStock }

  TfrmValStock = class(TForm)
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
    lblResumFalt: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Timer1: TTimer;
    procedure acArcGrabarExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acVerArbCatExecute(Sender: TObject);
    procedure btnMostCategClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    TabPro: TCibTabProduc;
    colStock: TugGrillaCol;
    colNueStk: TugGrillaCol;
    colDifStk: TugGrillaCol;
    colTipDif: TugGrillaCol;
    colMonDif: TugGrillaCol;
    colCodigo: TugGrillaCol;
    colCateg : TugGrillaCol;
    colSubcat: TugGrillaCol;
    colDescri: TugGrillaCol;
    colMarca : TugGrillaCol;
    colUniCom: TugGrillaCol;
    FormatMon: string;
    procedure ActualizarFila(f: integer);
    procedure fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure fraGriGrillaModif(TipModif: TugTipModif; filAfec: integer);
    procedure fraGriKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function fraGriLeerColorFondo(col, fil: integer; EsSelec: boolean): TColor;
    procedure RefrescarFiltros;
  public
    fraGri     : TfraEditGrilla;
    OnGrabado : procedure of object;
    function TabValStock(var difMonto: double): string;
    procedure Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
  end;

var
  frmValStock: TfrmValStock;

implementation
{$R *.lfm}
procedure TfrmValStock.RefrescarFiltros;
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
function TfrmValStock.TabValStock(var difMonto: double): string;
{Actualiza las columnas calculadas de la grilla y devuelve en texto, una tabla con
la estructura:
<ID>#9<Validación de stock>#9<Diferencia en unidades>#9<diferecnia en costo>
Solo incluye a los ID de productos que tienen Validación de stock.
En "difMonto" devuelve la diferencia en monto de dinero.
}
var
  f: Integer;
  id, nueStk, difStk, MonDif, Stock: String;
begin
  Result := '';
  difMonto := 0;
  fraGri.grilla.BeginUpdate;
  for f:=1 to fraGri.grilla.RowCount-1 do begin
    ActualizarFila(f);   //Actualiza columnas adicionales
    id := fraGri.grilla.Cells[colCodigo.idx, f];
    Stock := fraGri.grilla.Cells[colStock.idx, f];
    nueStk := fraGri.grilla.Cells[colNueStk.idx, f];
    if trim(nueStk) = '' then continue;
    DifStk  := fraGri.grilla.Cells[colDifStk.idx, f];
    MonDif := fraGri.grilla.Cells[colMonDif.idx, f];
    //Construye línea
    if Result = '' then begin
      Result += id  + #9 + difStk + #9 + Stock + #9 + nueStk + #9 + MonDif;
    end else begin
      Result += LineEnding + id  + #9 + difStk + #9 + Stock + #9 + nueStk + #9 + MonDif;
    end;
    difMonto += colMonDif.ValNum[f];   //acumula
  end;
  fraGri.grilla.EndUpdate;
  //Actualiza resumen en el formulario
  if difMonto = 0 then begin
    lblResumFalt.Font.Color := clBlack;
    lblResumFalt.Caption := 'Sin faltantes.';
  end else if difMonto >0 then begin
    lblResumFalt.Font.Color := clGreen;
    lblResumFalt.Caption := 'Monto Sobrante: ' + FloatToStr(difMonto);
  end else begin
    lblResumFalt.Font.Color := clRed;
    lblResumFalt.Caption := 'Monto Faltante: ' + FloatToStr(difMonto);
  end;
end;
procedure TfrmValStock.FormCreate(Sender: TObject);
begin
  //Configura Frame de grilla
  fraGri        := TfraEditGrilla.Create(self);
  fraGri.Parent := self;
  fraGri.Align  := alClient;
//  fraGri.OnGrillaModif:=@fraGri_Modificado;
//  fraGri.OnReqNuevoReg:=@fraGri_ReqNuevoReg;
end;
procedure TfrmValStock.FormDestroy(Sender: TObject);
begin
  fraGri.Destroy;
end;
procedure TfrmValStock.fraFiltCampoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    fraGri.SetFocus;
  end;
end;
procedure TfrmValStock.ActualizarFila(f: integer);
var
  difer: double;
  prod: TCibRegProduc;
  nueStk: String;
begin
  nueStk := fraGri.grilla.Cells[colNueStk.idx, f];
  if nueStk = '' then begin
    fraGri.grilla.Cells[colDifStk.idx, f] := '';
    fraGri.grilla.Cells[colMonDif.idx, f] := '';
    fraGri.grilla.Cells[colTipDif.idx, f] := '';
    exit;
  end;
  //Es una fila con nuevo stock
  difer :=  colNueStk.ValNum[f] - colStock.ValNum[f];
  colDifStk.ValNum[f] := difer;  //Diferencia enunidades
  prod := TabPro.BuscarProd(colCodigo.ValStr[f]);
  if prod <> nil then begin
    colMonDif.ValNum[f] := difer * prod.preVenta;     //Diferecnia en costo
  end;
  if difer < 0 then begin
    colTipDif.ValStr[f] := 'Faltante';
  end else if difer > 0 then begin
    colTipDif.ValStr[f] := 'Sobrante';
  end else begin
    colTipDif.ValStr[f] := '';
  end;
end;
procedure TfrmValStock.fraGriGrillaModif(TipModif: TugTipModif; filAfec: integer);
//Se modifica una fila
var
  difMonto: double;
begin
  //Actualiza los campos DIFERENCIA, TIPO DE DIFERENCIA y MONTO
  TabValStock(difMonto);
  //La única celda modificada debería ser la de la clñumna HAY
  if fraGri.grilla.col = colNueStk.idx +1  then begin
    fraGri.grilla.col := colNueStk.idx;  //mantiene columna
    MovASiguienteFilVis(fraGri.grilla);  //baja a siguienet visible
    //fraGri.grilla. Row := fraGri.grilla.Row + 1;
  end;
end;
procedure TfrmValStock.fraGriKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Col, Fil: Integer;
begin
  if (Shift = []) and (Key = VK_DELETE) then begin
    //Lee seleción
    Col := fraGri.grilla.Col;
    Fil := fraGri.grilla.Row;
    if (Col = -1) or (Fil = -1) then exit;
    fraGri.grilla.Cells[Col, Fil] := '';  //limpia
    Key := 0;
  end;
end;
function TfrmValStock.fraGriLeerColorFondo(col, fil: integer; EsSelec: boolean
  ): TColor;
const
  COL_SEL = $D0D0D0;
var
  difer: Double;
begin
  if EsSelec then begin
    Result := COL_SEL;
  end else begin
    Result := clWhite;
  end;
  //Pinta la última columna
  difer := colDifStk.ValNum[fil];
  if (col = colTipDif.idx) then begin
    if difer < 0 then begin
      Result := clRed;  //Falatnte
    end else if difer > 0 then begin
      Result := clGreen;  //Sobrante
    end else begin

    end;
  end;
end;
procedure TfrmValStock.Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
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
  colDescri := fraGri.AgrEncabTxt  ('DESCRIPCIÓN'   ,180, 'DESCRIPCION');
  colDescri.editable:=false;
  colStock  := fraGri.AgrEncabNum  ('STOCK'         , 45, 'STOCK');
  colStock.editable := false;
  colNueStk  := fraGri.AgrEncabNum ('HAY'    , 55);
  colNueStk.editable := true;
  colDifStk  := fraGri.AgrEncabNum ('Diferencia'    , 50);
  colDifStk.editable := false;
  colTipDif  := fraGri.AgrEncabTxt ('Tipo de Diferencia'    , 50);
  colTipDif.editable := false;
  colMonDif  := fraGri.AgrEncabNum ('Monto'    , 50);
  colMonDif.editable := false;
  colDifStk.restric := [];
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
  fraGri.OnGrillaModif   := @fraGriGrillaModif;
  fraGri.OnGrillaKeyDown := @fraGriKeyDown;
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
  fraGri.ReadFromTable;

  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
end;
procedure TfrmValStock.btnMostCategClick(Sender: TObject);
begin
  acVerArbCatExecute(self);
end;
procedure TfrmValStock.Timer1Timer(Sender: TObject);
{Actualiza el valor de la columna de stock, por si hubo alguna venta.}
var
  id: String;
  prod: TCibRegProduc;
  f: Integer;
  difMonto: double;
begin
  if not Visible then exit;
  for f:=1 to fraGri.grilla.RowCount-1 do begin
    id :=  colCodigo.ValStr[f];
    prod := TabPro.BuscarProd(id);
    if prod = nil then continue;
    colStock.ValNum[f] := prod.Stock;
  end;
  //Actualiza las columnas adicionales de stock y el mensaje inferior
  TabValStock(difMonto);
end;
///////////////////////// Acciones ////////////////////////////////
procedure TfrmValStock.acArcGrabarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
var
  difMonto: double;
  tmp: String;
begin
  if MsgYesNo('¿Corregir Stock y registrar diferencias?') <> 1 then exit;
  //acArcValidarExecute(self);
  if fraGri.MsjError<>'' then exit;
  if OnGrabado<>nil then OnGrabado();  //El evento es quien grabará
  fraFiltArbol1.LeerCategorias;
//  self.ActiveControl := nil;   //Para no quedarse con el enfoque
  self.ActiveControl := fraGri;
  //Lee de disco y se limpia la columna de incrementos
  fraGri.ReadFromTable;
//  //Lee cadena de incrementos
  tmp := TabValStock(difMonto);  //tambien actualiza etiqueta de "Faltantes"
//  //Pone cero en la columna de incrementos como indicador de que se modificó
//  lineas := TStringList.Create;
//  lineas.Text := tmp;  //Usa los datos leídos antes de actualziar la tabla
//  for lin in lineas do begin
//    //La línea es de tipo: <ID><#9><Ingreso de stock>
//    a := Explode(#9, lin);
//    id := a[0];
//    f := fraGri.BuscarTxt(id, colCodigo.idx);
//    if f =-1 then continue;  //no debería pasar
//    colNueStk.ValNum[f] := 0;
//  end;
//  lineas.Destroy;
end;
procedure TfrmValStock.acArcSalirExecute(Sender: TObject);
begin

end;

procedure TfrmValStock.acVerArbCatExecute(Sender: TObject);
begin
  fraFiltArbol1.Visible := not fraFiltArbol1.Visible;
  fraFiltArbol1.LeerCategorias;
  RefrescarFiltros;
end;

end.

