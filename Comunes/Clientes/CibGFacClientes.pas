{Unidad que define aal grupo "GFacClientes" y su facturables. Este grupo
contiene a los facturables más simples.
}
unit CibGFacClientes;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, types, dateutils, fgl, LCLProc, ExtCtrls, Forms, Menus,
  Dialogs, Controls, Graphics, MisUtils, CibTramas, CibFacturables,
  CibUtils
  ;
const //Acciones sobre los clientes
  ACCCLI_ELIM = 1;
  ACCCLI_AGRE = 2;
type
  TCibFacCliente = class;
  TCibGFacClientes = class;

  { TCibFacCliente }
  {Define al objeto Cliente de Ciberplex}
  TCibFacCliente = class(TCibFac)
  public //Métodos estáticos para codificar/decodificar cadenas
    class function CodCadEstado(_Nombre: String): string;
    class procedure DecodCadEstado(str: String; out _Nombre: String);
    class function CodCadPropied(sNombre: string; sx, sy: Single): string;
    class procedure DecodCadPropied(str: String; out _Nombre: string; out _x,
      _y: Single);
  protected  //"Getter" and "Setter"
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public  //campos diversos
    function RegVenta(usu: string): string; override; //línea para registro de venta
  public //control del cliente
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
      override;
    procedure EjecAccion(idVista: string; tram: TCPTrama; traDat: string); override;
  public  //constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;

  { TCibGFacClientes }
  { Clase que define al conjunto de Clientes.}
  TCibGFacClientes = class(TCibGFac)
  public
    class function CodCadPropied(_Nombre, _CategVenta: string; _x, _y: Single
      ): string;
    class procedure DecodCadPropied(lineas: TStringList; out _Nombre,
      _CategVenta: string; out _x, _y: Single);
  private
    class function CodCadEstado(_Nombre: string): string;
    class procedure DecodCadEstado(str: String; out _Nombre: string);
  protected //Getters and Setters
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public
    function Agregar(nombre0: string): TCibFacCliente;
    function Eliminar(nombre0: string): boolean;
    function CliPorNombre(nom: string): TCibFacCliente;  { TODO : ¿Será necesario, si ya existe ItemPorNombre en el ancestro? }
  public  //Campos para manejo de acciones
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string); override;
    procedure EjecAccion(idFacOrig: string; tram: TCPTrama); override;
  public  //Constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;


implementation

{ TCibFacCliente }
class function TCibFacCliente.CodCadEstado(_Nombre: String): string;
begin
  Result := '.' + {Caracter identificador de facturable, se omite la coma por espacio.}
         _Nombre + #9 +  {el nombre es obligatorio para identificar unívocamente}
         #9;
end;
class procedure TCibFacCliente.DecodCadEstado(str: String; out _Nombre: String);
var
  campos: TStringDynArray;
begin
  delete(str, 1, 1);  //recorta identificador
  campos := Explode(#9, str);
  _Nombre := campos[0];
end;
class function TCibFacCliente.CodCadPropied(sNombre: string; sx, sy: Single
  ): string;
begin
  Result := sNombre + #9 +
            N2f(sx) + #9 +
            N2f(sy) + #9 +
            #9 + #9;
end;
class procedure TCibFacCliente.DecodCadPropied(str: String; out
  _Nombre: string; out _x, _y: Single);
var
  campos: TStringDynArray;
begin
  campos := Explode(#9, str);
  _Nombre := campos[0];
  _x := f2N(campos[1]);
  _y := f2N(campos[2]);
end;
function TCibFacCliente.GetCadPropied: string;
{Las propiedades son los compos que definen la configuración de un cliente. Se
fijan al inicio, y no es común cambiarlos luego.}
begin
  Result := CodCadPropied(Nombre, x, y);
end;
procedure TCibFacCliente.SetCadPropied(AValue: string);
begin
  DecodCadPropied(AValue, FNombre, Fx, Fy);
 if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCibFacCliente.RegVenta(usu: string): string;
{Devuelve la línea que debe escribirse en el registro de venta al registrarse
una venta.}
begin
  Result := usu + #9 + 'CLI01' + #9 +
           'Cliente' + #9 +
           Nombre + #9 +
           Grupo.CategVenta + #9 + #9 + #9
end;
function TCibFacCliente.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := CodCadEstado(Nombre);
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCibFacCliente.SetCadEstado(AValue: string);
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
//control del objeto
procedure TCibFacCliente.EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Ejecuta la respuesta a un comando envíado, supuestamente,  desde el Visor.
Este método se debe ejecutar siempre en el lado Visor.}
begin
  {Distribuye la respuesta en lo smódulos que corresponda. En este caso, lo envía al
  formulario explorador, que es el único, por el momento, que genera respuestas tardías.}
//  frmExpArc.EjecRespuesta(comando, ParamX, ParamY, cad);
end;
procedure TCibFacCliente.EjecAccion(idVista: string; tram: TCPTrama;
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
//Constructor y destructor
constructor TCibFacCliente.Create(nombre0: string);
begin
  inherited Create;
  tipGFac := ctfClientes;  //se identifica
  FNombre := nombre0;
end;
destructor TCibFacCliente.Destroy;
begin
  inherited Destroy;
end;
{ TCibGFacClientes }
function TCibGFacClientes.Agregar(nombre0: string): TCibFacCliente;
var
  cab: TCibFacCliente;
begin
  cab := TCibFacCliente.Create(nombre0);
  AgregarItem(cab);   //aquí se configuran algunos  eventos
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := cab;
end;
function TCibGFacClientes.Eliminar(nombre0: string): boolean;
{Elimina un cliente, dado el nombre. Si no tiene éxito devuelve FALSE}
var
  cab: TCibFacCliente;
begin
  cab := CliPorNombre(nombre0);
  if cab = nil then exit(false);
  items.Remove(cab);  //puede tomar tiempo, por la destrucción del hilo
  if OnCambiaPropied<>nil then begin
    OnCambiaPropied;
  end;
  Result := true;
end;
class function TCibGFacClientes.CodCadPropied(_Nombre, _CategVenta: string; _x,
  _y: Single): string;
begin
  Result := _Nombre + #9 + _CategVenta + #9 + N2f(_x) + #9 + N2f(_y) + #9 + #9;
end;
class procedure TCibGFacClientes.DecodCadPropied(lineas: TStringList; out
  _Nombre, _CategVenta: string; out _x, _y: Single);
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
//Getters and Setters
class function TCibGFacClientes.CodCadEstado(_Nombre: string): string;
{Codifica la cadena de estado, a partir de las variables indicadas. Se pone como
método de clase para poder usarse sin crear instancias,}
begin
  Result := _Nombre + #9 + #9 + LineEnding;
end;
class procedure TCibGFacClientes.DecodCadEstado(str: String; out _Nombre: string);
{Decodifica la cadena de estado, a partir de las variables indicadas. Se pone como
método de clase para poder usarse sin crear instancias,}
var
  a: TStringDynArray;
begin
  a := Explode(#9, str);
  _Nombre := a[0];
end;
function TCibGFacClientes.GetCadEstado: string;
{Se sobreescribe esta propiedad para incluir campos adicionales}
var
  c : TCibFac;
begin
  //Delimitador inicial y propiedades de objeto.
  Result := CodCadEstado(Nombre);
  for c in items do begin
    Result += c.CadEstado + LineEnding;
  end;
end;
procedure TCibGFacClientes.SetCadEstado(AValue: string);
{Se sobreescribe esta propiedad para incluir campos adicionales}
var
  cad, nomb, lin1, _Nombre: string;
  car: char;
  it: TCibFac;
begin
  decodEst.Inic(AValue, lin1);  //inicia la decodificación
  DecodCadEstado(lin1, _Nombre);
  while decodEst.Extraer(car, nomb, cad) do begin
    if cad = '' then continue;
    it := ItemPorNombre(nomb);
    if it<>nil then it.CadEstado := cad;
  end;
end;
function TCibGFacClientes.GetCadPropied: string;
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
procedure TCibGFacClientes.SetCadPropied(AValue: string);
var
  lineas: TStringList;
  cab: TCibFacCliente;
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
function TCibGFacClientes.CliPorNombre(nom: string): TCibFacCliente;
{Devuelve la referencia a un cliente, ubicándola por su nombre. Si no la enuentra
 devuelve NIL.}
var
  c : TCibFac;
begin
  for c in items do begin
    if TCibFacCliente(c).Nombre = nom then exit(TCibFacCliente(c));
  end;
  exit(nil);
end;
//Operaciones con clientes
procedure TCibGFacClientes.EjecRespuesta(comando: TCPTipCom; ParamX,
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
procedure TCibGFacClientes.EjecAccion(idFacOrig: string; tram: TCPTrama);
{Ejecuta la acción sibre este grupo. Si la acción es para uno de sus facturables, le
pasa la trama, para su ejecución.}
var
  traDat, nom: String;
  facDest: TCibFac;
  Err: boolean;
  facCli: TCibFacCliente;
begin
debugln('Acción solicitada a GFacClientes:' + tram.TipTraNom);
  if tram.tipTra = CFAC_GCLIEN then begin
    //Es una acción dirigida a este grupo
    case tram.posX of  //Se usa el parámetro para ver la acción
    //Comandos locales. No llegan directamente hasta la PC remota
    ACCCLI_AGRE: begin   //Agregar una mesa
        nom := BuscaNombreItem('Cliente');
        facCli := Agregar(nom);
        facCli.x := x + items.Count*20;
        facCli.y := y + 20 + items.Count*10;
      end;
    ACCCLI_ELIM: begin
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
constructor TCibGFacClientes.Create(nombre0: string);
begin
  inherited Create(nombre0, ctfClientes);
  CategVenta := 'COUNTER';
end;
destructor TCibGFacClientes.Destroy;
begin
  inherited Destroy;  {Aquí se hace items.Destroy, que puede demorar por los hilos}
end;
end.

