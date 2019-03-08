{Formulario que implementa un Visor para el servidor, de modo que se pueda trabajar
también en el servidor como si fuera un punto de Venta.}
unit FormVista;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, frameVista;
type
  { TfrmVisor }
  TfrmVisor = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Visor: TfraVista;
  public
    procedure ActualizarPropiedades(cadProp: string);
    procedure ActualizarEstado(cadEstado: string);
  end;

var
  frmVisor: TfrmVisor;

implementation
{$R *.lfm}
{ TfrmVisor }
procedure TfrmVisor.FormCreate(Sender: TObject);
begin
  Visor:= TfraVista.Create(self);
  Visor.Parent := self;
  Visor.Align:=alClient;
  //Visor.motEdi.OnMouseUpRight:=@fraVisCPlex1ClickDer;
  Visor.Left:=300;
  Visor.Top:=0;
  Visor.Width:=400;
  Visor.Height:=300;
  Visor.Visible:=true;
  //Visor.motEdi.OnMouseUpRight:=@Visor_ClickDer;

end;

procedure TfrmVisor.FormDestroy(Sender: TObject);
begin
  //Visor.Destroy;
end;

procedure TfrmVisor.ActualizarPropiedades(cadProp: string);
begin
  Visor.ActualizarPropiedades(cadProp);
end;

procedure TfrmVisor.ActualizarEstado(cadEstado: string);
begin
  Visor.ActualizarEstado(cadEstado);
end;

end.

