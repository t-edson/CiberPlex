unit FormIngCompras;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, DateTimePicker, Forms, Controls, Graphics,
  Dialogs, EditBtn, StdCtrls, Grids, ButtonPanel, CibTabProductos, UtilsGrilla;
type

  { TfrmIngCompras }
  TfrmIngCompras = class(TForm)
    ButtonPanel1: TButtonPanel;
    chkIncIGV: TCheckBox;
    DateTimePicker1: TDateTimePicker;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    grilla: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    gri: TUtilGrilla;
    TabPro: TCibTabProduc;  //Tabla de productos
  public
    procedure Exec(TabPro0: TCibTabProduc);
  end;

var
  frmIngCompras: TfrmIngCompras;

implementation
{$R *.lfm}

procedure TfrmIngCompras.FormCreate(Sender: TObject);
begin
  //Configura grilla
  gri := TUtilGrilla.Create(grilla);
  gri.IniEncab;
  gri.AgrEncabNum('N°'           , 15);
  gri.AgrEncabTxt('CANTIDAD'     , 45);
  gri.AgrEncabTxt('DESCRIPCIÓN'  , 150);
  gri.AgrEncabTxt('PRC.UNITARIO' , 60);
  gri.AgrEncabNum('SUBTOTAL'     , 80);
  gri.FinEncab;
  gri.OpAutoNumeracion:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  gri.OpResaltFilaSelec:=true;

//  gri.OnKeyPress:=@griKeyPress;
  gri.MenuCampos:=true;
  grilla.RowCount := 2;  //deja fila en blanco
//  grilla.OnEnter:=@grillaEnter;
end;

procedure TfrmIngCompras.FormDestroy(Sender: TObject);
begin
  gri.Destroy;
end;

{ TfrmIngCompras }
procedure TfrmIngCompras.Exec(TabPro0: TCibTabProduc);
begin
  TabPro := TabPro0;
  Show;
end;

end.

