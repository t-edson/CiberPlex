unit FormPropMesa;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, MisUtils, CibFacturables;

type

  { TfrmPropMesa }

  TfrmPropMesa = class(TForm)
    BitBtn1: TBitBtn;
    btnAceptar: TBitBtn;
    chkSilla1a: TCheckBox;
    chkSilla2a: TCheckBox;
    chkSilla3a: TCheckBox;
    chkSilla4a: TCheckBox;
    chkSilla1b: TCheckBox;
    chkSilla2b: TCheckBox;
    chkSilla3b: TCheckBox;
    chkSilla4b: TCheckBox;
    imgMesa: TImage;
    imgSilla1a: TImage;
    imgSilla2a: TImage;
    imgSilla3a: TImage;
    imgSilla4a: TImage;
    imgSilla1b: TImage;
    imgSilla2b: TImage;
    imgSilla3b: TImage;
    imgSilla4b: TImage;
    Panel1: TPanel;
    optMesa: TRadioGroup;
    procedure btnAceptarClick(Sender: TObject);
    procedure optMesaClick(Sender: TObject);
  private
    fac: TCibFac;
    rutIconos: string;
    procedure RefrescarSillas;
  public
    function Exec(fac0: TCibFac): TModalResult;
  end;

var
  frmPropMesa: TfrmPropMesa;

implementation
{$R *.lfm}
uses CibGFacMesas;

procedure TfrmPropMesa.optMesaClick(Sender: TObject);
begin
  case optMesa.ItemIndex of
  0: begin  //Mesa 1 X 1
//    imgMesa.Picture.LoadFromFile(rutIconos + 'mesaSimple.png');
    imgMesa.Picture.Bitmap.Assign(CibGFacMesas.imgMesaSimple.Picture.Bitmap);
    imgMesa.Width := imgMesa.Picture.Width;
    imgMesa.Height:= imgMesa.Picture.Height;
  end;
  1: begin
    imgMesa.Picture.Bitmap.Assign(CibGFacMesas.imgMesaDoble1.Picture.Bitmap);
    imgMesa.Width := imgMesa.Picture.Width;
    imgMesa.Height:= imgMesa.Picture.Height;
  end;
  2: begin
    imgMesa.Picture.Bitmap.Assign(CibGFacMesas.imgMesaDoble2.Picture.Bitmap);
    imgMesa.Width := imgMesa.Picture.Width;
    imgMesa.Height:= imgMesa.Picture.Height;
  end;
  3: begin
    imgMesa.Picture.Bitmap.Assign(CibGFacMesas.imgMesaDoble3.Picture.Bitmap);
    imgMesa.Width := imgMesa.Picture.Width;
    imgMesa.Height:= imgMesa.Picture.Height;
  end;
  end;
  RefrescarSillas;
end;
procedure TfrmPropMesa.RefrescarSillas;
{Refresca la existencia y psoición de las sillas, de acuerdo al tamaño de la mesa}
begin
  chkSilla1b.Visible:=true;
  imgSilla1b.Visible:=true;
  chkSilla2b.Visible:=true;
  imgSilla2b.Visible:=true;
  chkSilla3b.Visible:=true;
  imgSilla3b.Visible:=true;
  chkSilla4b.Visible:=true;
  imgSilla4b.Visible:=true;

  case optMesa.ItemIndex of
  0: begin  //Mesa 1 X 1
    chkSilla1b.Visible:=false;
    imgSilla1b.Visible:=false;
    chkSilla2b.Visible:=false;
    imgSilla2b.Visible:=false;
    chkSilla3b.Visible:=false;
    imgSilla3b.Visible:=false;
    chkSilla4b.Visible:=false;
    imgSilla4b.Visible:=false;
  end;
  1: begin
    chkSilla1b.Visible:=false;
    imgSilla1b.Visible:=false;
    chkSilla3b.Visible:=false;
    imgSilla3b.Visible:=false;
  end;
  2: begin
    chkSilla2b.Visible:=false;
    imgSilla2b.Visible:=false;
    chkSilla4b.Visible:=false;
    imgSilla4b.Visible:=false;
  end;
  3: begin
  end;
  end;
  //Posiciona las sillas de la derecha y abajo, de acuerdo al tamaño de la mesa
  chkSilla3a.left := imgMesa.Left + imgMesa.Width+10;
  imgSilla3a.left := imgMesa.Left + imgMesa.Width+10;
  chkSilla3b.left := imgMesa.Left + imgMesa.Width+10;
  imgSilla3b.left := imgMesa.Left + imgMesa.Width+10;

  chkSilla4a.top := imgMesa.top + imgMesa.Height+5;
  imgSilla4a.top := chkSilla4a.top + chkSilla4a.Height;
  chkSilla4b.top := imgMesa.top + imgMesa.Height+5;
  imgSilla4b.top := chkSilla4b.top + chkSilla4b.Height;
end;
function TfrmPropMesa.Exec(fac0: TCibFac): TModalResult;
{Inicializa y muestra el formulario de búsqueda de tarifas. Se necesita la
referencia a un NILO-m , ya que se ha diseñado para trabajar con este objeto
como fuente de datos.}
var
  facMesa: TCibFacMesa;
begin
  fac := fac0;
  rutIconos := CibGFacMesas.rutImag;
  facMesa := TCibFacMesa(fac);
  case facMesa.tipMesa of
  cmt1x1: optMesa.ItemIndex:=0;
  cmt1x2: optMesa.ItemIndex:=1;
  cmt2x1: optMesa.ItemIndex:=2;
  cmt2x2: optMesa.ItemIndex:=3;
  end;
  ShowModal;
  Result := self.ModalResult;
end;
procedure TfrmPropMesa.btnAceptarClick(Sender: TObject);  //Aceptar
var
  facMesa: TCibFacMesa;
begin
  facMesa := TCibFacMesa(fac);
  Case optMesa.ItemIndex of
  0: facMesa.tipMesa := cmt1x1;
  1: facMesa.tipMesa := cmt1x2;
  2: facMesa.tipMesa := cmt2x1;
  3: facMesa.tipMesa := cmt2x2;
  end;
end;

end.

