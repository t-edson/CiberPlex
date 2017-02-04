{Formulario para la búsqeuda rápida de tarifas.}
unit FormBuscTarif;
{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Grids, ExtCtrls, Buttons, CibFacturables, UtilsGrilla, MisUtils;

type

  { TfrmBuscTarif }

  TfrmBuscTarif = class(TForm)
    BitBtn1: TBitBtn;
    Image1: TImage;
    Label2: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    StringGrid1: TStringGrid;
    txtSerDes: TEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure txtSerDesChange(Sender: TObject);
  private
    gfac: TCibGFac;
    UtilGrilla: TUtilGrilla;
    procedure Filtrar(cad: string);
  public
    procedure Exec(gfac0: TCibGFac);
  end;

var
  frmBuscTarif: TfrmBuscTarif;

implementation
uses
  CibGFacNiloM, CibNiloMTarifRut;
{$R *.lfm}
{ TfrmBuscTarif }

procedure TfrmBuscTarif.Filtrar(cad: string);
{LLena la grilla de usando el texto como palabra clave para la búsqueda}
var
  tar : TRegTarifa;
  gfacNilo: TCibGFacNiloM;
  f: Integer;
begin
  gfacNilo := TCibGFacNiloM(gfac);
  if cad = '' then begin  //Sin filtro
    StringGrid1.BeginUpdate;
    StringGrid1.RowCount:=1+gfacNilo.tarif.tarifas.Count;
    f := 1;
    for tar in gfacNilo.tarif.tarifas do begin
        StringGrid1.Cells[1, f] := tar.serie;
        StringGrid1.Cells[2, f] := tar.descripcion;
        StringGrid1.Cells[3, f] := tar.costop;
        StringGrid1.Cells[4, f] := tar.categoria;
        StringGrid1.Cells[5, f] := tar.paso;
        f := f + 1;
    end;
    StringGrid1.EndUpdate();
  end else begin
    StringGrid1.BeginUpdate;
    StringGrid1.RowCount:=1;
    f := 1;
    for tar in gfacNilo.tarif.tarifas do begin
       if StringLike(tar.serie, cad + '*') or
          StringLike(tar.descripcion, '*' + cad + '*')then begin
         StringGrid1.RowCount:=StringGrid1.RowCount + 1;
         StringGrid1.Cells[1, f] := tar.serie;
         StringGrid1.Cells[2, f] := tar.descripcion;
         StringGrid1.Cells[3, f] := tar.costop;
         StringGrid1.Cells[4, f] := tar.categoria;
         StringGrid1.Cells[5, f] := tar.paso;
         f := f + 1;
       end;
    end;
    StringGrid1.EndUpdate();
  end;
  case f of
  1: label2.Caption := 'No se encuentran tarifas.';
  2: label2.Caption := '1 tarifa encontrada.';
  else
    label2.Caption := IntToStr(f-1) + ' tarifas encontradas.';
  end;
end;
procedure TfrmBuscTarif.txtSerDesChange(Sender: TObject);
begin
  Filtrar(txtSerDes.Text);
end;
procedure TfrmBuscTarif.Exec(gfac0: TCibGFac);
{Inicializa y muestra el formulario de búsqueda de tarifas. Se necesita la
referencia a un NILO-m , ya que se ha diseñado para trabajar con este objeto
como fuente de datos.}
begin
  gfac := gfac0;
  self.Show;
  Filtrar('');
end;
procedure TfrmBuscTarif.FormCreate(Sender: TObject);
begin
  UtilGrilla := TUtilGrilla.Create(StringGrid1);
  UtilGrilla.IniEncab;
  UtilGrilla.AgrEncabNum('Nº' , 30);
  UtilGrilla.AgrEncabTxt('SERIE' , 55);
  UtilGrilla.AgrEncabTxt('DESCRIPCIÓN' , 140);
  UtilGrilla.AgrEncabNum('COSTO' , 50);
  UtilGrilla.AgrEncabTxt('CATEGORÍA' , 50);
  UtilGrilla.AgrEncabNum('PASO' , 50);
  UtilGrilla.FinEncab;
  UtilGrilla.OpAutoNumeracion:=true;
  UtilGrilla.OpDimensColumnas:=true;
  UtilGrilla.OpEncabezPulsable:=true;
  UtilGrilla.OpOrdenarConClick:=true;
  UtilGrilla.OpResaltarEncabez:=true;
end;
procedure TfrmBuscTarif.FormDestroy(Sender: TObject);
begin
  UtilGrilla.Destroy;
end;

procedure TfrmBuscTarif.FormKeyPress(Sender: TObject; var Key: char);
begin
  if not txtSerDes.Focused and (Key in ['a'..'z','A'..'Z','0'..'9']) then begin
    txtSerDes.SetFocus;
    txtSerDes.Text:=Key;
    txtSerDes.SelStart:=1;
    txtSerDes.SelLength:=0;
  end;
end;

end.

