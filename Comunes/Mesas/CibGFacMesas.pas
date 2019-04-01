{Unidad que define aal grupo "GFacClientes" y su facturables. Este grupo
contiene a los facturables más simples.
}
unit CibGFacMesas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, types, dateutils, fgl, LCLProc, ExtCtrls, Forms, Menus,
  Dialogs, Controls, Graphics, MisUtils, CibTramas, CibFacturables,
  CibUtils;
const //Acciones sobre los clientes
  ACCMES_ELIM = 1;
  ACCMES_AGRE = 2;
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
  public //Métodos estáticos para codificar/decodificar cadenas
    class function CodCadEstado(sNombre: String): string;
    class procedure DecodCadEstado(str: String; out sNombre: String);
    class function CodCadPropied(sNombre: string; sx, sy: Single;
      tipMesa: TCibMesaTip): string;
    class procedure DecodCadPropied(str: String; out sNombre: string; out sx,
      sy: Single; out tipMesa: TCibMesaTip);
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
  public  //Constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;

  { TCibGFacMesas }
  { Clase que define al conjunto de Clientes.}
  TCibGFacMesas = class(TCibGFac)
  public
    class function CodCadEstado(_Nombre: string): string;
    class procedure DecodCadEstado(str: String; out _Nombre: string);
    class function CodCadPropied(_Nombre, _CategVenta: string; _x, _y: Single
      ): string;
    class procedure DecodCadPropied(lineas: TStringList; out _Nombre,
      _CategVenta: string; out _x, _y: Single);
  private
    proAccion : string;   {Nombre de objeto que ejecuta la acción. }
  protected //Getters and Setters
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public
    //Existencia de sillas
    si1a, si2a, si3a, si4a: boolean;
    function Agregar(nombre0: string): TCibFacMesa;
    function Eliminar(nombre0: string): boolean;
    function MesaPorNombre(nom: string): TCibFacMesa;  { TODO : ¿Será necesario, si ya existe ItemPorNombre en el ancestro? }
  public  //Campos para manejo de acciones
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string); override;
    procedure EjecAccion(idFacOrig: string; tram: TCPTrama); override;
  public  //Constructor y destructor
    constructor Create(nombre0: string; ModoCopia0: boolean);
    destructor Destroy; override;
  end;


var
  imgMesaSimple: TImage;
  imgMesaDoble1: TImage;
  imgMesaDoble2: TImage;
  imgMesaDoble3: TImage;
  rutImag: string;

implementation

{ TCibFacMesa }
class function TCibFacMesa.CodCadPropied(sNombre: string; sx, sy: Single;
  tipMesa: TCibMesaTip): string;
begin
  Result := sNombre + #9 +
            N2f(sx) + #9 +
            N2f(sy) + #9 +
            I2f(ord(tipMesa)) + #9 + #9;
end;
class procedure TCibFacMesa.DecodCadPropied(str: String; out sNombre: string;
  out sx, sy: Single; out tipMesa: TCibMesaTip);
var
  campos: TStringDynArray;
begin
  campos := Explode(#9, str);
  SNombre := campos[0];
  sx := f2N(campos[1]);
  sy := f2N(campos[2]);
  tipMesa := TCibMesaTip(f2I(campos[3]));
end;
function TCibFacMesa.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := CodCadEstado(Nombre);
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCibFacMesa.SetCadEstado(AValue: string);
{Fija los campos de estado.}
var
  lin, tmp: String;
  lineas: TStringDynArray;
begin
  lineas := Explode(LineEnding, AValue);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  DecodCadEstado(lin, tmp);
  //Agrega información de boletas
  LeerEstadoBoleta(Boleta, lineas);
end;
function TCibFacMesa.GetCadPropied: string;
{Las propiedades son los compos que definen la configuración de un cliente. Se
fijan al inicio, y no es común cambiarlos luego.}
begin
  Result := CodCadPropied(Nombre, x, y, tipMesa);
end;
procedure TCibFacMesa.SetCadPropied(AValue: string);
var
  _Nombre: string;
begin
   DecodCadPropied(AValue, _Nombre, Fx, Fy, tipMesa);
   Nombre := _Nombre;
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
class function TCibFacMesa.CodCadEstado(sNombre: String): string;
begin
  Result := '.' + {Caracter identificador de facturable, se omite la coma por espacio.}
         sNombre + #9 +  {el nombre es obligatorio para identificar unívocamente}
         #9;
end;
class procedure TCibFacMesa.DecodCadEstado(str: String; out sNombre: String);
var
  campos: TStringDynArray;
begin
  delete(str, 1, 1);  //recorta identificador
  campos := Explode(#9, str);
  sNombre := campos[0];
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
//  ACCMES_ELIM: begin   //Se pide iniciar la cuenta de una PC
//      InicConteo(traDat);
//    end;
//  end;
end;
//Constructor y destructor
constructor TCibFacMesa.Create(nombre0: string);
begin
  inherited Create;
  tipGFac := ctfMesas;  //se identifica
  FNombre := nombre0;
  tipMesa := cmt1x1;
end;
destructor TCibFacMesa.Destroy;
begin
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
{Elimina una mesa, dado el nombre. Si no tiene éxito devuelve FALSE}
var
  cab: TCibFacMesa;
begin
  cab := MesaPorNombre(nombre0);
  if cab = nil then exit(false);
  items.Remove(cab);  //puede tomar tiempo, por la destrucción del hilo
  if OnCambiaPropied<>nil then begin
    OnCambiaPropied;
  end;
  Result := true;
end;
class function TCibGFacMesas.CodCadPropied(_Nombre, _CategVenta: string; _x,
  _y: Single): string;
begin
  Result := _Nombre + #9 + _CategVenta + #9 + N2f(_x) + #9 + N2f(_y) + #9 + #9;
end;
class procedure TCibGFacMesas.DecodCadPropied(lineas: TStringList; out _Nombre,
  _CategVenta: string; out _x, _y: Single);
var
  a: TStringDynArray;
begin
  //La primera línea tiene información del grupo
  a := Explode(#9, lineas[0]);
  _Nombre:=a[0];
  _CategVenta:=a[1];
  _x := f2N(a[2]);
  _y := f2N(a[3]);
  lineas.Delete(0);  //elimima línea
end;
class function TCibGFacMesas.CodCadEstado(_Nombre: string): string;
{Codifica la cadena de estado, a partir de las variables indicadas. Se pone como
método de clase para poder usarse sin crear instancias,}
begin
  Result := _Nombre + #9 + #9 + LineEnding;
end;
class procedure TCibGFacMesas.DecodCadEstado(str: String; out _Nombre: string);
{Decodifica la cadena de estado, a partir de las variables indicadas. Se pone como
método de clase para poder usarse sin crear instancias,}
var
  a: TStringDynArray;
begin
  a := Explode(#9, str);     //separa campos
  _Nombre := a[0];
end;
function TCibGFacMesas.GetCadEstado: string;
{Devuelve la cadena de estado. Esta es una implementación general. Notar que no se
guardan campos de estado del GFac, excepto el Tipo y Nombre, que son necesarios para la
identificación. De requerir guardar campos adicionales del GFac, no se podría usar este
código directamente.
La cadena de estado tiene el siguiente formato:
<1	NILO-m            <----- Línea inicial. Campos de estado del GFac
.LOC1	F                 <----- Líneas siguiente. Estado de objeto facturables.
.LOC2	F                 <----- Estado de objeto facturables (dos líneas).
 [b]0	1003220344996..
.LOC3	F
.LOC4	F
>                         <----- Línea final.
}
var
  c : TCibFac;
begin
  //Delimitador inicial y propiedades de objeto.
  Result := CodCadEstado(Nombre);
  for c in items do begin
    Result += c.CadEstado + LineEnding;
  end;
end;
procedure TCibGFacMesas.SetCadEstado(AValue: string);
{Hace el trabajo inverso de GetCadEstado(). De la misma forma, no lee campos de estado,
adicionales. De hecho no lee ninguno, ya que los campos Tipo y Nombre, ya fueron usados
para identificar a este GFac.}
var
  nomb, cad, lin1, _Nombre: string;
  car: char;
  it: TCibFac;
begin
  decodEst.Inic(AValue, lin1);
  DecodCadEstado(lin1, _Nombre);
  while decodEst.Extraer(car, nomb, cad) do begin
    if cad = '' then continue;
    it := ItemPorNombre(nomb);
    if it<>nil then it.CadEstado := cad;
  end;
end;
function TCibGFacMesas.GetCadPropied: string;
var
  c : TCibFac;
begin
  //Información del grupo en la primera línea
  Result := CodCadPropied(Nombre, CategVenta, Fx, Fy);
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
begin
  if AValue = '' then exit;
  lineas := TStringList.Create;
  lineas.Text := AValue;
  DecodCadPropied(lineas, Nombre, CategVenta, Fx, Fy);
  //Procesa líneas con información de los clientes
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    cab := Agregar('');
    cab.CadPropied := lin;
  end;
  lineas.Destroy;
end;
function TCibGFacMesas.MesaPorNombre(nom: string): TCibFacMesa;
{Devuelve la referencia a una mesa, ubicándola por su nombre. Si no la enuentra
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
  facMesa: TCibFacMesa;
begin
debugln('Acción solicitada a GFacMesas:' + tram.TipTraNom);
  if tram.tipTra = CFAC_GMESAS then begin
    //Es una acción dirigida a este grupo
    case tram.posX of  //Se usa el parámetro para ver la acción
    //Comandos locales. No llegan directamente hasta la PC remota
    ACCMES_AGRE: begin   //Agregar una mesa
        nom := BuscaNombreItem('Mesa');
        facMesa := Agregar(nom);
        facMesa.x := x + items.Count*20;
        facMesa.y := y + 20 + items.Count*10;
      end;
    ACCMES_ELIM: begin
        traDat := tram.traDat;
        ExtraerHasta(traDat, #9, Err);  //Extrae nombre de grupo
        nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto.
        Eliminar(nom);
      end;
    end;
  end else begin
    //Es una acción para un facturable
    traDat := tram.traDat;  {Crea copia para modificar. En tramas grandes, modificar puede
                             deteriorar el rendimiento. Habría que verificar.}
    ExtraerHasta(traDat, SEP_IDFAC, Err);  //Extrae nombre de grupo
    nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto.
    facDest := ItemPorNombre(nom);
    if facDest=nil then exit;
    //Pasa el comando, incluyendo el origen, por si lo necesita
    facDest.EjecAccion(idFacOrig, tram, traDat);
  end;
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

end.

