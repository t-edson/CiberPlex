unit FormIngVentas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ButtonPanel, StdCtrls, Grids, ActnList, Menus, Buttons, LCLType,
  FrameFiltCampo, UtilsGrilla, MisUtils, CibFacturables, CibTabProductos, FormConfig;
type
  //Evento para agregar una venta
  TevAgregarVenta = procedure(CibFac: TCibFac; itBol: string) of object;

  { TfrmIngVentas }
  TfrmIngVentas = class(TForm)
    acGenActualiz: TAction;
    ActionList1: TActionList;
    btnMas: TBitBtn;
    btnMenos: TBitBtn;
    ButtonPanel1: TButtonPanel;
    fraFiltCampo: TfraFiltCampo;
    txtDescrip: TEdit;
    txtPrecUnit: TEdit;
    txtTotal: TEdit;
    txtCantidad: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    MenuItem1: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    grilla: TStringGrid;
    PopupMenu1: TPopupMenu;
    procedure acGenActualizExecute(Sender: TObject);
    procedure btnMasClick(Sender: TObject);
    procedure btnMenosClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure grillaSelection(Sender: TObject; aCol, aRow: Integer);
    procedure OKButtonClick(Sender: TObject);
    procedure txtCantidadChange(Sender: TObject);
    procedure txtPrecUnitChange(Sender: TObject);
  private
    CibFac: TCibFac;        //Objeto de trabajo (cabina, lcoutorio, ...)
    function ActualizarTotal(mostrarError: boolean): boolean;
    procedure fraUtilsGrilla1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure griKeyPress(Sender: TObject; var Key: char);
    procedure grillaEnter(Sender: TObject);
    function ProdSeleccionado: TCibRegProduc;
  public
    gri : TUtilGrilla;
    OnAgregarVenta: TevAgregarVenta;
    TabPro: TCibTabProduc;  //Tabla de productos
    procedure Exec(CibFac0: TCibFac; txtIni: string='');
    procedure LeerDatos;
  end;

var
  frmIngVentas: TfrmIngVentas;

implementation
{$R *.lfm}
{ TfrmIngVentas }
procedure TfrmIngVentas.txtCantidadChange(Sender: TObject);
begin
  ActualizarTotal(false);
end;
procedure TfrmIngVentas.txtPrecUnitChange(Sender: TObject);
begin
  ActualizarTotal(false);
end;
procedure TfrmIngVentas.Exec(CibFac0: TCibFac; txtIni: string = '');
{Abre, la ventana. Se supone que la propiedad "TabPro", ya debe haber sido fijada.}
begin
  if CibFac0 = nil then ButtonPanel1.OKButton.Enabled:=false
  else ButtonPanel1.OKButton.Enabled:=true;
  CibFac := CibFac0;   //referencia al objeto origen
//  TabPro := TabPro0;
  fraFiltCampo.Edit1.Clear;
  LeerDatos;  //Actualiza sus datos
  self.Show;
  if fraFiltCampo.Edit1.Visible then begin
    fraFiltCampo.Edit1.SetFocus;
    if txtIni<>'' then begin
      fraFiltCampo.Edit1.Text:=txtIni;
      fraFiltCampo.Edit1.SelStart:=length(txtIni);
    end;
  end;
end;
procedure TfrmIngVentas.LeerDatos;
var
  f: Integer;
  reg: TCibRegProduc;
begin
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  grilla.RowCount:= TabPro.Productos.Count+1;
  f := 1;
  for reg in TabPro.Productos do begin
    grilla.Cells[1,f] := reg.Cod;
    grilla.Cells[2,f] := reg.Categ;
    grilla.Cells[3,f] := reg.Subcat;
    grilla.Cells[4,f] := Config.CadMon(reg.PreVenta);
    grilla.Cells[5,f] := reg.Desc;
    grilla.Cells[6,f] := FloatToStr(reg.Stock);
    f := f + 1;
  end;
  grilla.EndUpdate();
//  Label1.Caption := IntToStr(grilla.RowCount-1) + ' registros visibles.';
end;
procedure TfrmIngVentas.FormCreate(Sender: TObject);
begin
  //Configura grilla
  gri := TUtilGrilla.Create(grilla);
  gri.IniEncab;
  gri.AgrEncab('N°'          , 0, -1, taRightJustify);
  gri.AgrEncab('CÓDIGO'      , 50);
  gri.AgrEncab('CATEGORÍA'   , 70);
  gri.AgrEncab('SUBCATEGORÍA', 70);
  gri.AgrEncab('PRC.UNITARIO', 55, -1, taRightJustify);
  gri.AgrEncab('DESCRIPCIÓN' , 180);
  gri.AgrEncab('STOCK'       , 40, -1, taRightJustify);
  gri.FinEncab;
  gri.OpAutoNumeracion:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  gri.OpResaltFilaSelec:=true;

  fraFiltCampo.Inic(gri, 4);
  fraFiltCampo.OnKeyDown:=@fraUtilsGrilla1KeyDown;
  gri.OnKeyPress:=@griKeyPress;

  gri.MenuCampos:=true;
  grilla.OnEnter:=@grillaEnter;
  //gri.OnMouseUpCell:=@griDBMouseUpCell;
  //fraFiltCampo.OnFiltrado:=@fraUtilsGrilla1Filtrado;
  gri.PopUpCells := PopupMenu1;
end;
procedure TfrmIngVentas.FormDestroy(Sender: TObject);
begin
  gri.Destroy;
end;
procedure TfrmIngVentas.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = '+' then begin
    btnMasClick(self);
    Key := #0;
  end;
  if Key = '-' then begin
    btnMenosClick(self);
    Key := #0;
  end;
end;
procedure TfrmIngVentas.fraUtilsGrilla1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DOWN then begin
    grilla.SetFocus;
  end;
end;
procedure TfrmIngVentas.griKeyPress(Sender: TObject; var Key: char);
begin
  if Key in ['a'..'z','A'..'Z'] then begin
    fraFiltCampo.Activar(Key);
  end;
end;
function TfrmIngVentas.ProdSeleccionado: TCibRegProduc;
{Devuelve el producto seleccionado. Si no hay ninguno seleccioando, devuelve NIL.}
begin
  if grilla.Row<1 then exit(nil);
  Result := TabPro.Productos[grilla.Row-1];  //funcioan porque se llena en orden
  //cod := grilla.Cells[1, grilla.Row];  //lee código de producto
end;
function TfrmIngVentas.ActualizarTotal(mostrarError: boolean): boolean;
{Actualiza el valor del campo TOTAL. Si encuentar error, devuelve FALSE.}
var
  ctdad, preUni: Double;
begin
  Result := true;
  try
    preUni := LeeMoneda(txtPrecUnit.Text);
  except
    if mostrarError then begin
      MsgErr('Error en precio unitario.');
      if txtPrecUnit.Visible then txtPrecUnit.SetFocus;
    end;
    txtTotal.Text:='0';
    txtTotal.Font.Color:=clRed;
    exit(false);
  end;
  try
    ctdad := StrToFloat(txtCantidad.Text);
  except
    if mostrarError then begin
      MsgErr('Error en cantidad.');
      if txtCantidad.Visible then txtCantidad.SetFocus;
    end;
    txtTotal.Text:='0';
    txtTotal.Font.Color:=clRed;
    exit(false);
  end;
  txtTotal.Text:=CadMoneda(ctdad * preUni);
  txtTotal.Font.Color:=clBlack;
end;
procedure TfrmIngVentas.grillaEnter(Sender: TObject);
begin
  grillaSelection(self, 0, 1);
end;
procedure TfrmIngVentas.grillaSelection(Sender: TObject; aCol, aRow: Integer);
begin
  txtDescrip.Text := grilla.Cells[5, grilla.row];
  txtPrecUnit.Text := grilla.Cells[4, grilla.row];
  txtCantidad.Text := '1';
  ActualizarTotal(false);
end;
procedure TfrmIngVentas.btnMasClick(Sender: TObject);
var
  ctdad: Extended;
begin
  try
    ctdad := StrToFloat(txtCantidad.Text);
  except
    ctdad := 0;
  end;
  ctdad := ctdad + 1;
  txtCantidad.Text := FloatToStr(ctdad);
end;
procedure TfrmIngVentas.btnMenosClick(Sender: TObject);
var
  ctdad: Extended;
begin
  try
    ctdad := StrToFloat(txtCantidad.Text);
  except
    ctdad := 0;
  end;
  if ctdad>0 then ctdad := ctdad - 1;
  txtCantidad.Text := FloatToStr(ctdad);
end;
procedure TfrmIngVentas.OKButtonClick(Sender: TObject);  //Aceptar
var
  itBol: TCibItemBoleta;
  pro: TCibRegProduc;
begin
  if not ActualizarTotal(true) then exit;
  if LeeMoneda(txtTotal.Text) = 0 then begin
    if MsgYesNo('¿Agregar venta con costo cero?') <> 1 then exit;
  end;
  if StrToFloat(txtCantidad.Text)<0 then begin
    MsgExc('No se permiten cantidades negativas.');
    exit;
  end;
  pro := ProdSeleccionado;
  if pro = nil then exit;

  //Crea ítem de boleta
  itBol := TCibItemBoleta.Create;   //crea elemento
//  iteMod.vser = nser;     //se asignará después
  itBol.Cant := StrToFloat(txtCantidad.Text);
  itBol.pUnit := LeeMoneda(txtPrecUnit.Text);
  itBol.subtot := LeeMoneda(txtTotal.Text);
  itBol.cat := pro.Categ;
  itBol.subcat := pro.Subcat;
  itBol.codPro := pro.Cod;
  itBol.descr := txtDescrip.Text;
  itBol.vfec := Date + Time;  //toma fecha actual
  itBol.estado := IT_EST_NORMAL;
  itBol.fragmen := 0;
  itBol.coment := '';
  //itBol.pven := PV;    //no se asigna aquì porque la boleta puede cambiar de punto de venta
  //información adicional
  itBol.stkIni := pro.Stock;
  itBol.pUnitR := pro.PreVenta;
  itBol.conStk := True;    //Maneja stock

  //Limpia campos
  txtDescrip.Text:='';
  txtPrecUnit.Text:='';
  txtCantidad.Text:='';
  txtTotal.Text:='';

  if OnAgregarVenta<>nil then OnAgregarVenta(CibFac, itBol.CadEstado);
  itBol.Destroy;
  self.Close;
end;
procedure TfrmIngVentas.CancelButtonClick(Sender: TObject);
begin
  self.Hide;
end;

///////////////////////// Acciones /////////////////////////
procedure TfrmIngVentas.acGenActualizExecute(Sender: TObject);
begin
  LeerDatos
end;

end.

