{Formulario con propiedades generales para Grupos facturables}
unit FormPropGFac;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, typinfo, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Spin, Buttons, EditBtn;

type

  { TfrmPropGFac }

  TfrmPropGFac = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    txtTipo: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    spnX: TFloatSpinEdit;
    spnY: TFloatSpinEdit;
    txtCategVenta: TEdit;
    txtNombre: TEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    obj: TObject;
  public
    cancel: boolean;
    procedure Exec(gfac0: TObject);
  end;

var
  frmPropGFac: TfrmPropGFac;

implementation
uses CibFacturables, ObjGraficos;
{$R *.lfm}

procedure TfrmPropGFac.BitBtn2Click(Sender: TObject);
var
  gfac: TogGFac;
begin
  gfac := TogGFac(obj);
  if txtNombre.Text <> gfac.Name then begin
    //Cambio de nombre
    gfac.Name := txtNombre.Text;
  end;
  if spnX.Value <> gfac.x then begin
    gfac.x := spnX.Value;
  end;
  if spnY.Value <> gfac.y then begin
    gfac.y := spnY.Value;
  end;
  if txtCategVenta.Text <> gfac.CategVenta then begin
    gfac.CategVenta := txtCategVenta.Text;
  end;
//  gfac.OnCambiaPropied;  //para que actualice las propiedades
end;
procedure TfrmPropGFac.BitBtn1Click(Sender: TObject);
begin
  cancel := true;
end;
procedure TfrmPropGFac.Exec(gfac0: TObject);
{Inicializa y muestra el formulario de búsqueda de tarifas. Se necesita la
referencia a un NILO-m , ya que se ha diseñado para trabajar con este objeto
como fuente de datos.}
var
  gfac: TogGFac;
begin
  obj := gfac0;
  gfac := TogGFac(obj);
  txtNombre.Text    := gfac.Name;
  spnX.Value        := gfac.x;
  spnY.Value        := gfac.y;
  txtCategVenta.Text:= gfac.CategVenta;
  txtTipo.Text      := gfac.tipoStr;
  cancel := false;
  ShowModal;
end;

end.

