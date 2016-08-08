unit FormIngVentas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ButtonPanel, StdCtrls, Grids, ActnList, Menus, Buttons,
  FrameUtilsGrilla, UtilsGrilla, MisUtils, CibFacturables, CPProductos, FormConfig;

type
  //Evento para agregar una venta
  TevAgregarVenta = procedure(nombreObj: string; itBol: string) of object;

  { TfrmIngVentas }
  TfrmIngVentas = class(TForm)
    acGenActualiz: TAction;
    ActionList1: TActionList;
    btnMas: TBitBtn;
    btnMenos: TBitBtn;
    ButtonPanel1: TButtonPanel;
    txtDescrip: TEdit;
    txtPrecUnit: TEdit;
    txtTotal: TEdit;
    txtCantidad: TEdit;
    fraUtilsGrilla1: TfraUtilsGrilla;
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
    nombreObj: string;   //nombre del objeto de trabajo (cabina, lcoutorio, ...)
    function ActualizarTotal(mostrarError: boolean): boolean;
    procedure grillaEnter(Sender: TObject);
    function ProdSeleccionado: TregProdu;
  public
    gri : TUtilGrilla;
    OnAgregarVenta: TevAgregarVenta;
    procedure Exec(nombreObj0: string);
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
procedure TfrmIngVentas.Exec(nombreObj0: string);
begin
  nombreObj := nombreObj0;
  fraUtilsGrilla1.Edit1.Clear;
  self.Show;
  if fraUtilsGrilla1.Edit1.Visible then fraUtilsGrilla1.Edit1.SetFocus;
end;
procedure TfrmIngVentas.LeerDatos;
var
  f: Integer;
  reg: TregProdu;
begin
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  grilla.RowCount:=Productos.Count+1;
  f := 1;
  for reg in Productos do begin
    grilla.Cells[1,f] := reg.cod;
    grilla.Cells[2,f] := reg.cat;
    grilla.Cells[3,f] := reg.subcat;
    grilla.Cells[4,f] := CadMoneda(reg.pUnit);
    grilla.Cells[5,f] := reg.desc;
    grilla.Cells[6,f] := FloatToStr(reg.stock);
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
  gri.UsarFrameUtils(fraUtilsGrilla1, nil);
  gri.UsarTodosCamposFiltro(4);
  gri.MenuCampos:=true;
  grilla.OnEnter:=@grillaEnter;
  //gri.OnMouseUpCell:=@griDBMouseUpCell;
  //fraUtilsGrilla1.OnFiltrado:=@fraUtilsGrilla1Filtrado;
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
function TfrmIngVentas.ProdSeleccionado: TregProdu;
{Devuelve el producto seleccionado. Si no hay ninguno seleccioando, devuelve NIL.}
begin
  if grilla.Row<1 then exit(nil);
  Result := Productos[grilla.Row-1];  //funcioan porque se llena en orden
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
  pro: TregProdu;
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
  itBol.cat := pro.cat;
  itBol.subcat := pro.subcat;
  itBol.codPro := pro.cod;
  itBol.descr := txtDescrip.Text;
  itBol.vfec := Date + Time;  //toma fecha actual
  itBol.estado := IT_EST_NORMAL;
  itBol.fragmen := 0;
  itBol.coment := '';
  //itBol.pven := PV;    //no se asigna aquì porque la boleta puede cambiar de punto de venta
  //información adicional
  itBol.stkIni := pro.stock;
  itBol.pUnitR := pro.pUnit;
  itBol.conStk := True;    //Maneja stock

  //Limpia campos
  txtDescrip.Text:='';
  txtPrecUnit.Text:='';
  txtCantidad.Text:='';
  txtTotal.Text:='';

  if OnAgregarVenta<>nil then OnAgregarVenta(nombreObj, itBol.CadEstado);
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

