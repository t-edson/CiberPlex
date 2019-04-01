unit FormOgClientes;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls,
  ogMotGraf2D, MisUtils, CibUtils, CibTramas, CibFacturables, ObjGraficos,
  FormPropGFac, CibGFacClientes;
type

  { TogCliente }
  {Objeto gráfico que representa a los elementos TCibFacCliente}
  TogCliente = class(TogFac)
  private
  public
    icono      : TGraphic;    //PC con control
    procedure Draw; override;  //Dibuja el objeto gráfico
    procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true); override;
    procedure ReLocate(newX, newY: Single; UpdatePCtrls: boolean=true); override;
  public //Estado reflejo del FAC al que representa
    procedure SetCadEstado(txt: string); override;
  public  //Propiedades reflejo del FAC al que representa
    procedure SetCadPropied(str: string); override;
  public  //constructor y detsructor
    constructor Create(mGraf: TMotGraf); reintroduce;
  end;

  { TogGClientes }
  TogGClientes = class(TogGFac)
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

  { TfrmOgClientes }
  TfrmOgClientes = class(TForm)
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    ImageList16: TImageList;
    ImageList32: TImageList;
  public
    OnSolicEjecCom : TEvSolicEjecCom;     //Cuando solicita ejecutar un comando
    OnCambiaPropied: procedure of object; //Cuando cambia alguna variable de propiedad
  public  //Manejo de grupos
    ogGFacCli : TogGClientes;
    procedure MenuAccionesGru(ogGFacCli0 : TogGClientes; ModDiseno: boolean; MenuPopup: TPopupMenu);
    procedure mnAgregObjCliente(Sender: TObject);
    procedure mnPropiedadesGru(Sender: TObject);
  public  //Manejo de Facturables
    ogFacCli : TogCliente;
    procedure MenuAccionesFac(ogFacCli0: TogCliente; ModDiseno: boolean; MenuPopup: TPopupMenu);
    procedure mnEliminarFac(Sender: TObject);
  public

  end;

var
  icoClient: integer;   //índice de imagen
  icoElim: integer;
  icoProp: integer;

procedure CargarIconos(imagList16, imagList32: TImageList);

var
  frmOgClientes: TfrmOgClientes;

implementation
{$R *.lfm}

procedure CargarIconos(imagList16, imagList32: TImageList);
{Carga los íconos que necesita esta unida }
begin
  icoClient := CargaPNG(frmOgClientes.ImageList16, frmOgClientes.ImageList32, 0, imagList16, imagList32);
  icoElim   := CargaPNG(frmOgClientes.ImageList16, frmOgClientes.ImageList32, 1, imagList16, imagList32);
  icoProp   := CargaPNG(frmOgClientes.ImageList16, frmOgClientes.ImageList32, 2, imagList16, imagList32);
end;

//Manejo de Grupos
procedure TfrmOgClientes.MenuAccionesGru(ogGFacCli0: TogGClientes;
  ModDiseno: boolean; MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  ogGFacCli := ogGFacCli0;
  nShortCut := -1;
  InicLlenadoAcciones(MenuPopup);
  if ModDiseno then begin
    AgregarAccion(nShortCut, '&Agregar Objeto Cliente', @mnAgregObjCliente, icoClient);
  end;
  AgregarAccion(nShortCut, '&Propiedades', @mnPropiedadesGru, icoProp);
end;
procedure TfrmOgClientes.mnAgregObjCliente(Sender: TObject);
begin
  OnSolicEjecCom(CFAC_GCLIEN, ACCCLI_AGRE, 0, ogGFacCli.IdFac);
end;
procedure TfrmOgClientes.mnPropiedadesGru(Sender: TObject);
begin
  frmPropGFac.Exec(ogGFacCli);
end;
//Manejo de Facturables
procedure TfrmOgClientes.MenuAccionesFac(ogFacCli0: TogCliente;
  ModDiseno: boolean; MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  ogFacCli := ogFacCli0;
  nShortCut := -1;
  InicLlenadoAcciones(MenuPopup);
  if ModDiseno then begin
    AgregarAccion(nShortCut, '&Eliminar', @mnEliminarFac, icoElim);
  end;
end;
procedure TfrmOgClientes.mnEliminarFac(Sender: TObject);
begin
  OnSolicEjecCom(CFAC_GCLIEN, ACCCLI_ELIM, 0, ogFacCli.grupo.IdFac + #9 + ogFacCli.Name);
end;

{ TogCliente }
procedure TogCliente.Draw;
begin
  icono := frmOgClientes.Image14.Picture.Graphic;   //asigna imagen
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X, Y -20, name);
  //dibuja ícono
  v2d.DrawImageN(icono, x, y);
  //muestra ogBoleta
  if Boleta.ItemCount>0 then ogBoleta.Dibujar;  //dibuja ogBoleta
  inherited;
end;
procedure TogCliente.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
begin
  inherited;
  //ubica ogBoleta
  //ogBoleta.Locate(x-8,y+45);
end;
procedure TogCliente.ReLocate(newX, newY: Single; UpdatePCtrls: boolean);
begin
  inherited ReLocate(newX, newY, UpdatePCtrls);
  //ubica ogBoleta
  ogBoleta.Locate(x-8,y+45);
end;

procedure TogCliente.SetCadEstado(txt: string);
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
procedure TogCliente.SetCadPropied(str: string);
begin
  TCibFacCliente.DecodCadPropied(str, Name, Fx, Fy);
end;
//constructor y detsructor
constructor TogCliente.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  ogBoleta.Width:=67;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Cliente';
  Self.Locate(100,100);
  Resize(50, 65);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;

{ TogGClientes }
procedure TogGClientes.Draw;
begin
  icono := frmOgClientes.Image13.Picture.Graphic;   //asigna imagen
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DrawImageN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited;
end;
procedure TogGClientes.SetCadEstado(txt: string);
begin
  //No hay estado para este grupo.
end;
procedure TogGClientes.SetCadPropied(lineas: TSTringList);
begin
  TCibGFacClientes.DecodCadPropied(lineas, Name, CategVenta, Fx, Fy);
  ReLocate(x, y);  //Porque ha habido cambios en X,Y
end;
constructor TogGClientes.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipGFac := ctfClientes;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Locate(100,100);
  Name := 'Grupo Clientes';
  Resize(100, 29);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;

end.

