{Formualrio para la ediciónm de los productos}
unit FormBusProductos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, Buttons, Menus, ActnList, StdCtrls, UtilsGrilla, CibProductos,
  FormConfig, FrameUtilsGrilla;
type
  { TfrmBusProductos }
  TfrmBusProductos = class(TForm)
    acArcSalir: TAction;
    acEdiNuevo: TAction;
    acEdiModif: TAction;
    acEdiElimin: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    fraUtilsGrilla1: TfraUtilsGrilla;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    Panel1: TPanel;
    grilla: TStringGrid;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    gri : TUtilGrilla;
    TabPro: TCibTabProduc;
    procedure fraUtilsGrilla1Filtrado;
  public
    procedure Exec(TabPro0: TCibTabProduc);
  end;

var
  frmBusProductos: TfrmBusProductos;

implementation
{$R *.lfm}

{ TfrmBusProductos }
procedure TfrmBusProductos.FormCreate(Sender: TObject);
begin
  //Configura grilla
  gri := TUtilGrilla.Create(grilla);
  gri.IniEncab;
  gri.AgrEncab('N°'          , 25, -1, taRightJustify);
  gri.AgrEncab('CÓDIGO'      , 60);
  gri.AgrEncab('CATEGORÍA'   , 70);
  gri.AgrEncab('SUBCATEGORÍA', 80);
  gri.AgrEncab('PRC.UNITARIO', 55, -1, taRightJustify);
  gri.AgrEncab('DESCRIPCIÓN' , 180);
  gri.AgrEncab('STOCK'       , 40, -1, taRightJustify);
  gri.FinEncab;
  gri.OpAutoNumeracion:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  gri.UsarFrameUtils(fraUtilsGrilla1, nil);
  gri.UsarTodosCamposFiltro(4);
  gri.MenuCampos:=true;
  //gri.OnMouseUpCell:=@griDBMouseUpCell;
  fraUtilsGrilla1.OnFiltrado:=@fraUtilsGrilla1Filtrado;
end;
procedure TfrmBusProductos.fraUtilsGrilla1Filtrado;
begin
  Label1.Caption := IntToStr(fraUtilsGrilla1.filVisibles) + ' registros visibles.';
end;
procedure TfrmBusProductos.Exec(TabPro0: TCibTabProduc);
begin
  TabPro := TabPro0;
  self.Show;
end;
procedure TfrmBusProductos.FormDestroy(Sender: TObject);
begin
  gri.Destroy;
end;
procedure TfrmBusProductos.FormShow(Sender: TObject);
var
  f: Integer;
  reg: TregProdu;
  n: LongInt;
begin
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  n := TabPro.Productos.Count+1;
  grilla.RowCount:= n;
  f := 1;
  for reg in TabPro.Productos do begin
    grilla.Cells[1,f] := reg.cod;
    grilla.Cells[2,f] := reg.cat;
    grilla.Cells[3,f] := reg.subcat;
    grilla.Cells[4,f] := CadMoneda(reg.pUnit);
    grilla.Cells[5,f] := reg.desc;
    grilla.Cells[6,f] := FloatToStr(reg.stock);
    f := f + 1;
  end;
  grilla.EndUpdate();
  Label1.Caption := IntToStr(grilla.RowCount-1) + ' registros visibles.';
end;

end.

