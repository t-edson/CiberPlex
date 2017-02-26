{Unidad que define aal grupo "GFacClientes" y su facturables. Este grupo
contiene a los facturables más simples.
}
unit CibGFacMesas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, types, dateutils, fgl, LCLProc, ExtCtrls, Forms, Menus,
  Dialogs, Controls, Graphics, MisUtils, CibTramas, CibFacturables,
  CibUtils, FormPropMesa
  ;
const //Acciones sobre los clientes
  ACCCLI_ELIM = 1;
  C_MESA_TRASLA = 05;  //Solicita trasladar cabina

type
  //Tipo de mesa
  TCibMesaTip = (
    cmt1x1,  //Mesa de 1*1
    cmt1x2,  //Mesa de 1*2
    cmt2x1,  //Mesa de 2*1
    cmt2x2   //Mesa de 2*2
  );
  TCibFacMesa = class;
  TCibGFacMesas = class;

  { TCibFacMesa }
  {Define al objeto Cliente de Ciberplex}
  TCibFacMesa = class(TCibFac)
  private
    frmConfig: TfrmPropMesa;
    procedure mnConfigurar(Sender: TObject);
  protected  //"Getter" and "Setter"
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public  //campos diversos
    tipMesa  : TCibMesaTip;
    function RegVenta(usu: string): string; override; //línea para registro de venta
  public //control del cliente
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
      override;
    procedure EjecAccion(idVista: string; tram: TCPTrama; traDat: string); override;
    procedure MenuAccionesVista(MenuPopup: TPopupMenu); override;
    procedure MenuAccionesModelo(MenuPopup: TPopupMenu); override;
  public  //Constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;

  { TCibGFacMesas }
  { Clase que define al conjunto de Clientes.}
  TCibGFacMesas = class(TCibGFac)
  private
    proAccion : string;   {Nombre de objeto que ejecuta la acción. }
    procedure mnAgregObjMesa(Sender: TObject);
  protected //Getters and Setters
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public
    //Existencia de sillas
    si1a, si2a, si3a, si4a: boolean;
    procedure mnEliminar(Sender: TObject);
    function Agregar(nombre0: string): TCibFacMesa;
    function Eliminar(nombre0: string): boolean;
    function CliPorNombre(nom: string): TCibFacMesa;  { TODO : ¿Será necesario, si ya existe ItemPorNombre en el ancestro? }
  public  //Campos para manejo de acciones
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string); override;
    procedure EjecAccion(idFacOrig: string; tram: TCPTrama); override;
    procedure MenuAccionesVista(MenuPopup: TPopupMenu); override;
    procedure MenuAccionesModelo(MenuPopup: TPopupMenu); override;
  public  //Constructor y destructor
    constructor Create(nombre0: string; ModoCopia0: boolean);
    destructor Destroy; override;
  end;

  procedure CargarIconos(imagList16, imagList32: TImageList);

var
  imgMesaSimple: TImage;
  imgMesaDoble1: TImage;
  imgMesaDoble2: TImage;
  imgMesaDoble3: TImage;
  rutImag: string;

implementation
const
  RUT_ICONOS = '..\Iconos\Mesas';
var
  icoMesa: integer;   //índice de imagen
  icoConfig: integer;
  icoProp: integer;
  icoElim: integer;

procedure CargarIconos(imagList16, imagList32: TImageList);
{Carga los íconos que necesita esta unida }
var
  rutImag: String;
begin
  rutImag := ExtractFilePath(Application.ExeName) + RUT_ICONOS + DirectorySeparator;
  icoMesa:= CargaPNG(imagList16, imagList32, rutImag, 'table');
  icoConfig:= CargaPNG(imagList16, imagList32, rutImag, 'config');
  icoProp  := CargaPNG(imagList16, imagList32, rutImag, 'properties');
  icoElim  := CargaPNG(imagList16, imagList32, rutImag, 'delete');
end;

{ TCibFacMesa }
function TCibFacMesa.GetCadPropied: string;
{Las propiedades son los compos que definen la configuración de un cliente. Se
fijan al inicio, y no es común cambiarlos luego.}
begin
  Result := Nombre + #9 +
            N2f(x) + #9 +
            N2f(y) + #9 +
            I2f(ord(tipMesa)) + #9 + #9;
end;
procedure TCibFacMesa.SetCadPropied(AValue: string);
var
  campos: TStringDynArray;
begin
   campos := Explode(#9, Avalue);
   Nombre := campos[0];
   x := f2N(campos[1]);
   y := f2N(campos[2]);
   tipMesa := TCibMesaTip(f2I(campos[3]));
   if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCibFacMesa.RegVenta(usu: string): string;
{Devuelve la línea que debe escribirse en el registro de venta al registrarse
una venta.}
begin
  Result := usu + #9 + 'CLI01' + #9 +
           'Cliente' + #9 +
           Nombre + #9 +
           Grupo.CategVenta + #9 + #9 + #9
end;
function TCibFacMesa.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := '.' + {Caracter identificador de facturable, se omite la coma por espacio.}
         Nombre + #9 +  {el nombre es obligatorio para identificar unívocamente}
         #9;
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCibFacMesa.SetCadEstado(AValue: string);
{Fija los campos de estado.}
var
  lin: String;
  lineas: TStringDynArray;
begin
  lineas := Explode(LineEnding, AValue);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  //aquí aseguramos que no hay red
  delete(lin, 1, 1);  //recorta identificador
//  campos := Explode(#9, lin);
  //Agrega información de boletas
  LeerEstadoBoleta(lineas);
end;
//control del objeto
procedure TCibFacMesa.EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Ejecuta la respuesta a un comando envíado, supuestamente,  desde el Visor.
Este método se debe ejecutar siempre en el lado Visor.}
begin
  {Distribuye la respuesta en lo smódulos que corresponda. En este caso, lo envía al
  formulario explorador, que es el único, por el momento, que genera respuestas tardías.}
//  frmExpArc.EjecRespuesta(comando, ParamX, ParamY, cad);
end;
procedure TCibFacMesa.EjecAccion(idVista: string; tram: TCPTrama;
  traDat: string);
{Ejecuta la acción solicitada sobre este facturable.
Se ejecuta siempre en el Modelo.}
begin
//  case tram.posX of  //Se usa el parámetro para ver la acción
//  //Comandos locales
//  C_CABIN_INICTA: begin   //Se pide iniciar la cuenta de una PC
//      InicConteo(traDat);
//    end;
//  end;
end;
procedure TCibFacMesa.MenuAccionesVista(MenuPopup: TPopupMenu);
{Configura las acciones del modelo. Lo ideal sería que todas las acciones se ejcuten
desde aquí.}
begin
  InicLlenadoAcciones(MenuPopup);
end;
procedure TCibFacMesa.MenuAccionesModelo(MenuPopup: TPopupMenu);
var
  NombProg, NombLocal: string;
  ModDiseno: boolean;
begin
  grupo.OnReqConfigGen(NombProg, NombLocal, ModDiseno);
  InicLlenadoAcciones(MenuPopup);
  if ModDiseno then begin
    AgregarAccion('&Configurar', @mnConfigurar, icoConfig);
    {Notar que la acción de "Eliminar" se define en el grupo, para que sea el grupo quien
    elimine al facturable, ya que no es factible que el facturable se elimine a sí mismo.
    Otra opción es usar una bandera de tipo "por eliminar" y un Timer, que verifique esta
    bandera, y elimine a las que esteán marcadas.}
    TCibGFacMesas(grupo).proAccion := Nombre;   //nombre de objeto que solicita la acción
    AgregarAccion('&Eliminar', @TCibGFacMesas(grupo).mnEliminar, icoElim);
  end;
end;
procedure TCibFacMesa.mnConfigurar(Sender: TObject);
{Muestra el formulario para ver los mensajes de red.}
begin
  if frmConfig.Exec(self) = mrOK then begin
    //Para que actualice a la vista
    if OnCambiaPropied<>nil then OnCambiaPropied();
  end;
end;
//Constructor y destructor
constructor TCibFacMesa.Create(nombre0: string);
begin
  inherited Create;
  tipo := ctfMesas;  //se identifica
  FNombre := nombre0;
  frmConfig := TfrmPropMesa.Create(nil);
  tipMesa := cmt1x1;
end;
destructor TCibFacMesa.Destroy;
begin
  frmConfig.Destroy;
  inherited Destroy;
end;
{ TCibGFacMesas }
function TCibGFacMesas.Agregar(nombre0: string): TCibFacMesa;
var
  cab: TCibFacMesa;
begin
  cab := TCibFacMesa.Create(nombre0);
  AgregarItem(cab);   //aquí se configuran algunos  eventos
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := cab;
end;
function TCibGFacMesas.Eliminar(nombre0: string): boolean;
{Elimina un cliente, dado el nombre. Si no tiene éxito devuelve FALSE}
var
  cab: TCibFacMesa;
begin
  cab := CliPorNombre(nombre0);
  if cab = nil then exit(false);
  items.Remove(cab);  //puede tomar tiempo, por la destrucción del hilo
  if OnCambiaPropied<>nil then begin
    OnCambiaPropied;
  end;
  Result := true;
end;
function TCibGFacMesas.GetCadPropied: string;
var
  c : TCibFac;
begin
  //Información del grupo en la primera línea
  Result := Nombre + #9 + CategVenta + #9 + N2f(Fx) + #9 + N2f(Fy) + #9 +
            #9 ;
  //Información de los clientes en las demás líneas
  for c in items do begin
    Result := Result + LineEnding + c.CadPropied ;
  end;
end;
procedure TCibGFacMesas.SetCadPropied(AValue: string);
var
  lineas: TStringList;
  cab: TCibFacMesa;
  lin: String;
  a: TStringDynArray;
begin
  if AValue = '' then exit;
  lineas := TStringList.Create;
  lineas.Text := AValue;
  //La primera línea tiene información del grupo
  a := Explode(#9, lineas[0]);
  Nombre:=a[0];
  CategVenta:=a[1];
  Fx := f2N(a[2]);
  Fy := f2N(a[3]);
  lineas.Delete(0);  //elimima línea
  //Procesa líneas con información de los clientes
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    cab := Agregar('');
    cab.CadPropied := lin;
  end;
  lineas.Destroy;
end;
function TCibGFacMesas.CliPorNombre(nom: string): TCibFacMesa;
{Devuelve la referencia a un cliente, ubicándola por su nombre. Si no la enuentra
 devuelve NIL.}
var
  c : TCibFac;
begin
  for c in items do begin
    if TCibFacMesa(c).Nombre = nom then exit(TCibFacMesa(c));
  end;
  exit(nil);
end;
//operaciones con clientes
procedure TCibGFacMesas.EjecRespuesta(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
var
  Err: boolean;
  facDest: TCibFac;
  nom: String;
begin
  //Extrae el nombre, porque se supone que sya se extrajo el grupo
  nom := ExtraerHasta(cad, #9, Err);
  facDest := ItemPorNombre(nom);
  if facDest=nil then exit;
  //Pasa el comando. Notar que yas e quitó de "cad", el ID completo.
  facDest.EjecRespuesta(comando, ParamX, ParamY, cad);
end;
procedure TCibGFacMesas.EjecAccion(idFacOrig: string; tram: TCPTrama);
{Ejecuta la acción sibre este grupo. Si la acción es para uno de sus facturables, le
pasa la trama, para su ejecución.}
var
  traDat, nom: String;
  facDest: TCibFac;
  Err: boolean;
begin
debugln('Acción solicitada a GFacClientes:' + tram.TipTraNom);
  traDat := tram.traDat;  {Crea copia para modificar. En tramas grandes, modificar puede
                           deteriorar el rendimiento. Habría que verificar.}
  ExtraerHasta(traDat, SEP_IDFAC, Err);  //Extrae nombre de grupo
  nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto.
  facDest := ItemPorNombre(nom);
  if facDest=nil then exit;
  //Pasa el comando, incluyendo el origen, por si lo necesita
  facDest.EjecAccion(idFacOrig, tram, traDat);
end;
procedure TCibGFacMesas.MenuAccionesVista(MenuPopup: TPopupMenu);
begin
  InicLlenadoAcciones(MenuPopup);
  //No hay acciones, aún, para el Grupo Clientes
end;
procedure TCibGFacMesas.MenuAccionesModelo(MenuPopup: TPopupMenu);
var
  NombProg, NombLocal: string;
  ModDiseno: boolean;
begin
  OnReqConfigGen(NombProg, NombLocal, ModDiseno);
  InicLlenadoAcciones(MenuPopup);
  if ModDiseno then begin
    AgregarAccion('&Agregar Mesa', @mnAgregObjMesa, icoMesa);
  end;
  AgregarAccion('&Propiedades', @mnPropiedades, icoProp);
end;
procedure TCibGFacMesas.mnAgregObjMesa(Sender: TObject);
var
  nom: String;
  facMesa: TCibFacMesa;
begin
  nom := BuscaNombreItem('Mesa');
  facMesa := Agregar(nom);
  facMesa.x := x + items.Count*20;
  facMesa.y := y + 20 + items.Count*10;
end;
procedure TCibGFacMesas.mnEliminar(Sender: TObject);
//Elimina al facturable. Notra que este método es asignado por el facturable, no por
//el grupo, porque un facturable no puede eliminarse a sí mismo.
begin
//  MsgBox('Eliminando ' + proAccion);
  Eliminar(proAccion);  //Se ahce aquí mismo, poruqe esta acción se ejecuta en elmodelo.
end;
//constructor y destructor
constructor TCibGFacMesas.Create(nombre0: string; ModoCopia0: boolean);
begin
  inherited Create(nombre0, ctfMesas);
  FModoCopia := ModoCopia0;    //Asigna al inicio para saber el modo de trabajo
  CategVenta := 'COUNTER';
  si1a := true;
  si2a := true;
  si3a := true;
  si4a := true;
end;
destructor TCibGFacMesas.Destroy;
begin
  inherited Destroy;  {Aquí se hace items.Destroy, que puede demorar por los hilos}
end;
initialization
  {Crea y carga las imágenes que se van a usar en este grupo
   Como una opción, para prevenir errores de archivo, se puede crear un frame estático,
   con imágenes ya caragadas por defecto y que se pueda definir, como una opción, si se
   usa la opción pro defecto o se cara dinámicamente las imágenes.}
  rutImag := ExtractFilePath(Application.ExeName) + RUT_ICONOS + DirectorySeparator;
  imgMesaSimple := CreaYCargaImagen(rutImag + 'mesaSimple.png');
  imgMesaDoble1 := CreaYCargaImagen(rutImag + 'mesaDoble1.png');
  imgMesaDoble2 := CreaYCargaImagen(rutImag + 'mesaDoble2.png');
  imgMesaDoble3 := CreaYCargaImagen(rutImag + 'mesaDoble3.png');

finalization
  imgMesaSimple.Destroy;
  imgMesaDoble1.Destroy;
  imgMesaDoble2.Destroy;
  imgMesaDoble3.Destroy;

end.

