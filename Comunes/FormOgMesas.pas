unit FormOgMesas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  ogMotGraf2D, MisUtils, CibUtils, ObjGraficos, CibFacturables, CibTramas,
  FormPropGFac, CibGFacClientes, CibGFacMesas;
type

  { TogMesa }
  {Objeto gráfico que representa a los elementos TCibFacMesa}
  TogMesa = class(TogFac)
  private
  public
    procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true); override;
    procedure Draw; override;  //Dibuja el objeto gráfico
    procedure ReLocate(newX, newY: Single; UpdatePCtrls: boolean=true); override;
  public //Estado reflejo del FAC al que representa
    procedure SetCadEstado(txt: string); override;
  public  //Propiedades reflejo del FAC al que representa
    tipMesa: TCibMesaTip;
    procedure SetCadPropied(str: string); override;
  public  //constructor y detsructor
    constructor Create(mGraf: TMotGraf); reintroduce;
  end;

  { TogGMesas }
  {Objeto gráfico que representa a los elementos TCibGFacMesas}
  TogGMesas = class(TogGFac)
  private
  public
    icono  : TGraphic;    //PC con control
    procedure Draw; override;  //Dibuja el objeto gráfico
  public  //Estados reflejo del GFAC al que representa
    procedure SetCadEstado(txt: string); override;
  public  //Propiedades reflejo del GFAC al que representa
    procedure SetCadPropied(lineas: TSTringList); override;
  protected
  public  //constructor y detsructor
    constructor Create(mGraf: TMotGraf); reintroduce;
  end;

  { TfrmOgMesas }
  TfrmOgMesas = class(TForm)
    Image16: TImage;
    ImageList16: TImageList;
    ImageList32: TImageList;
    imgMesaDoble1: TImage;
    imgMesaDoble2: TImage;
    imgMesaDoble3: TImage;
    imgMesaSimple: TImage;
    imgSilla1: TImage;
    imgSilla2: TImage;
    imgSilla3: TImage;
    imgSilla4: TImage;
  public
    OnSolicEjecCom : TEvSolicEjecCom;     //Cuando solicita ejecutar un comando
    OnCambiaPropied: procedure of object; //Cuando cambia alguna variable de propiedad
  public   //Manejo de Grupos
    ogGFacMes: TogGMesas;
    procedure MenuAccionesGru(ogGFacMes0: TogGMesas; ModDiseno: boolean; MenuPopup: TPopupMenu);
    procedure mnAgregObjMesa(Sender: TObject);
    procedure mnPropiedadesGru(Sender: TObject);
  public  //Manejo de Facturables
    ogFacMes: TogMesa;
    procedure MenuAccionesFac(ogFacMes0: TogMesa; modDiseno: boolean; MenuPopup: TPopupMenu);
    procedure mnConfigurar(Sender: TObject);
    procedure mnEliminarFac(Sender: TObject);
  public

  end;

var
  icoMesa: integer;   //índice de imagen
  icoConfig: integer;
  icoProp: integer;
  icoElim: integer;

procedure CargarIconos(imagList16, imagList32: TImageList);

var
  frmOgMesas: TfrmOgMesas;

implementation
{$R *.lfm}
procedure CargarIconos(imagList16, imagList32: TImageList);
{Carga los íconos que necesita esta unida }
begin
  icoMesa  := CargaPNG(frmOgMesas.ImageList16, frmOgMesas.ImageList32, 0, imagList16, imagList32);
  icoConfig:= CargaPNG(frmOgMesas.ImageList16, frmOgMesas.ImageList32, 1, imagList16, imagList32);
  icoProp  := CargaPNG(frmOgMesas.ImageList16, frmOgMesas.ImageList32, 2, imagList16, imagList32);
  icoElim  := CargaPNG(frmOgMesas.ImageList16, frmOgMesas.ImageList32, 3, imagList16, imagList32);
end;
//Manejo de Grupos
procedure TfrmOgMesas.MenuAccionesGru(ogGFacMes0: TogGMesas;
  ModDiseno: boolean; MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  ogGFacMes := ogGFacMes0;
  nShortCut := -1;
  InicLlenadoAcciones(MenuPopup);
  if ModDiseno then begin
    AgregarAccion(nShortCut, '&Agregar Mesa', @mnAgregObjMesa, icoMesa);
  end;
  AgregarAccion(nShortCut, '&Propiedades', @mnPropiedadesGru, icoProp);
end;
procedure TfrmOgMesas.mnAgregObjMesa(Sender: TObject);
begin
  OnSolicEjecCom(CFAC_GMESAS, ACCMES_AGRE, 0, ogGFacMes.IdFac);
end;
procedure TfrmOgMesas.mnPropiedadesGru(Sender: TObject);
begin
  frmPropGFac.Exec(ogGFacMes);
end;
//Manejo de Facturables
procedure TfrmOgMesas.MenuAccionesFac(ogFacMes0: TogMesa; modDiseno: boolean;
  MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  ogFacMes := ogFacMes0;
  InicLlenadoAcciones(MenuPopup);
  if ModDiseno then begin
    nShortCut := -1;
    AgregarAccion(nShortCut, '&Configurar', @mnConfigurar, icoConfig);
    {Notar que la acción de "Eliminar" se define en el grupo, para que sea el grupo quien
    elimine al facturable, ya que no es factible que el facturable se elimine a sí mismo.
    Otra opción es usar una bandera de tipGFac "por eliminar" y un Timer, que verifique esta
    bandera, y elimine a las que esteán marcadas.}
    AgregarAccion(nShortCut, '&Eliminar', @mnEliminarFac, icoElim);
  end;
end;
procedure TfrmOgMesas.mnConfigurar(Sender: TObject);
{Muestra el formulario para ver los mensajes de red.}
begin
  {Sería conveniente modificar le formulario frmPropMesa, para que acepte modificar
  un TogMesa y luego implementar la opción de actualizar propiedades. }
  //if frmPropMesa.Exec(self) = mrOK then begin
  //  //Para que actualice a la vista
  //  //if OnCambiaPropied<>nil then OnCambiaPropied();
  //end;
end;
procedure TfrmOgMesas.mnEliminarFac(Sender: TObject);
begin
  //Se envía un comando pero al grupo, para que elimine a una mesa
  OnSolicEjecCom(CFAC_GMESAS, ACCMES_ELIM, 0, ogFacMes.grupo.IdFac + #9 + ogFacMes.Name);
end;

{ TogMesa }
procedure TogMesa.Draw;
var
  icoSilla1, icoSilla2, icoSilla3, icoSilla4, icoMesaSimple,
    icoMesaDoble1, icoMesaDoble2, icoMesaDoble3: TGraphic;
begin
  icoMesaSimple := frmOgMesas.imgMesaSimple.Picture.Graphic;
  icoMesaDoble1 := frmOgMesas.imgMesaDoble1.Picture.Graphic;
  icoMesaDoble2 := frmOgMesas.imgMesaDoble2.Picture.Graphic;
  icoMesaDoble3 := frmOgMesas.imgMesaDoble3.Picture.Graphic;
  icoSilla1 := frmOgMesas.imgSilla1.Picture.Graphic;
  icoSilla2 := frmOgMesas.imgSilla2.Picture.Graphic;
  icoSilla3 := frmOgMesas.imgSilla3.Picture.Graphic;
  icoSilla4 := frmOgMesas.imgSilla4.Picture.Graphic;
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X, Y -20, Name);
  //Dibuja mesa
  //dibuja ícono de sillas
  v2d.DrawImageN(icoSilla1, x , y + 38);
  v2d.DrawImageN(icoSilla2, x + 37, y);
  //dibuja ícono de mesa
  case tipMesa of
  cmt1x1: begin
      v2d.DrawImageN(icoSilla3, x + 70, y + 38);
      v2d.DrawImageN(icoSilla4, x + 37, y + 70);
      v2d.DrawImageN(icoMesaSimple, x + 26, y + 26);
  end;
  cmt1x2: begin
      v2d.DrawImageN(icoSilla2, x + 73, y);
      v2d.DrawImageN(icoSilla3, x + 105, y + 38);
      v2d.DrawImageN(icoSilla4, x + 37, y + 70);
      v2d.DrawImageN(icoSilla4, x + 73, y + 70);
      v2d.DrawImageN(icoMesaDoble1, x + 26, y + 26);
  end;
  cmt2x1: begin
      v2d.DrawImageN(icoSilla1, x , y + 74);
      v2d.DrawImageN(icoSilla3, x + 70, y + 38);
      v2d.DrawImageN(icoSilla3, x + 70, y + 74);
      v2d.DrawImageN(icoSilla4, x + 37, y + 105);
      v2d.DrawImageN(icoMesaDoble2, x + 26, y + 26);
  end;
  cmt2x2: begin
      v2d.DrawImageN(icoSilla1, x , y + 74);
      v2d.DrawImageN(icoSilla2, x + 73, y);
      v2d.DrawImageN(icoSilla3, x + 105, y + 38);
      v2d.DrawImageN(icoSilla3, x + 105, y + 74);
      v2d.DrawImageN(icoSilla4, x + 37, y + 105);
      v2d.DrawImageN(icoSilla4, x + 73, y + 105);
      v2d.DrawImageN(icoMesaDoble3, x + 26, y + 26);
  end;
  end;
  //muestra ogBoleta
  if Boleta.ItemCount>0 then ogBoleta.Dibujar;  //dibuja ogBoleta
  inherited;
end;
procedure TogMesa.ReLocate(newX, newY: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
begin
  inherited;
  //ubica ogBoleta
  ogBoleta.Locate(x + width/2 - 40, y + height - 20);
end;
procedure TogMesa.SetCadEstado(txt: string);
var
  lineas: TStringDynArray;
  lin, _Nombre: String;
begin
  lineas := Explode(LineEnding, txt);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  TCibFacCliente.DecodCadEstado(lin, _Nombre);
  //Agrega información de boletas
  LeerEstadoBoleta(Boleta, lineas);
end;
procedure TogMesa.SetCadPropied(str: string);
begin
  TCibFacMesa.DecodCadPropied(str, Name, Fx, Fy, tipMesa);
end;
procedure TogMesa.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
begin
  case tipMesa of
  cmt1x1: begin
      newWidth := 105;
      newHeight := 110;
  end;
  cmt1x2: begin
      newWidth := 140;
      newHeight := 110;
  end;
  cmt2x1: begin
      newWidth := 105;
      newHeight := 145;
  end;
  cmt2x2: begin
      newWidth := 140;
      newHeight := 145;
  end;
  end;
  inherited Resize(newWidth, newHeight);
end;
//constructor y detsructor
constructor TogMesa.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  ogBoleta.Width:=80;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Cliente';
  Locate(100,100);
  Resize(105, 110);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;

{ TogGMesas }
procedure TogGMesas.Draw;
begin
  icono := frmOgMesas.Image16.Picture.Graphic;   //asigna imagen
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DrawImageN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited;
end;
procedure TogGMesas.SetCadEstado(txt: string);
begin
  //No hay estado para este grupo.
end;
procedure TogGMesas.SetCadPropied(lineas: TSTringList);
begin
  TCibGFacMesas.DecodCadPropied(lineas, Name, CategVenta, Fx, Fy);
  ReLocate(x, y);  //Porque ha habido cambios en X,Y
end;
constructor TogGMesas.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipGFac := ctfMesas;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Self.Locate(100,100);
  Name := 'Grupo Clientes';
  Resize(100, 29);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;

end.

