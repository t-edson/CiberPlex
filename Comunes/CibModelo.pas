{Unidad para definir al objeto TCPGruposFacturables.
Se define como una unidad separada de CPFacturables, porque se necesita incluir a las
unidades que dependen de CPFacturables, y se crearía una dependencia circular. }
unit CibModelo;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, LCLProc, Forms, CibFacturables,
  //Aquí se incluyen las unidades que definen clases descendientes de TCPFacturables
  CibGFacCabinas, CibGFacNiloM, MisUtils, CibTramas, CibUtils, CibBD,
  CibGFacMesas, CibGFacClientes;
type

  { TCibModelo }
  {Objeto que engloba a todos los grupos facturables. Debe haber solo una instancia para
   toda la aplicación, así que trabaja como un SINGLETON.}
  TCibModelo = class
  private
    FModoCopia: boolean;
    function GetCadEstado: string;
    function GetCadPropiedades: string;
    procedure gfac_BDinsert(sqlText: string);
    procedure gfac_ReqConfigUsu(out Usuario: string);
    procedure gfac_RespComando(idVista: string; comando: TCPTipCom; ParamX,
      ParamY: word; cad: string);
    procedure gfac_SolicEjecCom(comando: TCPTipCom; ParamX, ParamY: word;
      cad: string);
    function gfac_LogIngre(ident: char; msje: string; dCosto: Double): integer;
    function gfac_LogError(msj: string): integer;
    function gfac_LogVenta(ident: char; msje: string; dCosto: Double): integer;
    procedure gfac_ActualizStock(const codPro: string; const Ctdad: double);
    function gfac_ReqCadMoneda(valor: double): string;
    procedure gfac_CambiaPropied;
    function gfac_LogInfo(msj: string): integer;
    procedure SetCadEstado(const AValue: string);
    procedure SetCadPropiedades(AValue: string);
    procedure gfac_ReqConfigGen(out NombProg, NombLocal: string;
      out ModDiseno: boolean);
    procedure GCab_ArchCambRemot(ruta, nombre: string);
  public  //Eventos.
    {Cuando este objeto forma parte del modelo, necesita comunicarse con la aplicación,
    para leer información o ejecutar acciones. Para esto se usan los eventos.}
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad de algun grupo
    OnGuardarEstado: procedure of object;
    OnActualizStock: TEvBolActStock;   //Se requiere actualizar el stock
    OnRespComando  : TEvRespComando;   //Indica que tiene la respuesta de un comando
    OnModifTablaBD : TEvModifTablaBD;  //Indica que se desea modificar una tabla
    //Escritura a BD
    OnLogInfo      : TEvFacLogInfo;   //Se quiere registrar un mensaje en el registro
    OnLogVenta     : TEvBolLogVenta;  //Se quiere registrar una venta en el registro
    OnLogIngre     : TEvBolLogVenta;  //Se quiere registrar un ingreso en el registro
    OnLogError     : TEvFacLogError;  //Requiere escribir un Msje de error en el registro
    OnBDinsert     : TEvSQLexecute;   //Requiere insertar un registro a una tabla
    //Requerimiento de información
    OnReqConfigGen : TEvReqConfigGen;  //Se requiere información de configruación
    OnReqConfigUsu : TEvReqConfigUsu;  //Se requiere información general
    OnReqCadMoneda : TevReqCadMoneda;  //Se requiere convertir a formato de moneda
    //Estos eventos se generan cuando este objeto forma parte de un Visor.
    OnSolicEjecCom : TEvSolicEjecCom;  //Se solicita ejecutar una acción
    //Eventos de cabinas
    OnArchCambRemot: TEvArchCambRemot;
  public
    nombre : string;          //Es un identificador del grupo. Es útil solo para depuración.
    items  : TCibGFact_list;  //lista de grupos facturables
    DeshabEven: boolean;      //deshabilita los eventos
    property ModoCopia: boolean  {Indica si se quiere manejar al objeto sin conexión (como en un visor),
                                  debería hacerse antes de que se agreguen objetos a "items"}
             read FModoCopia;
    property CadPropiedades: string read GetCadPropiedades write SetCadPropiedades;
    property CadEstado: string read GetCadEstado write SetCadEstado;
    function NumGrupos: integer;
    function ItemPorNombre(nomb: string): TCibGFac;
    function BuscaNombreItem(StrBase: string): string;
    function BuscarPorID(idFac: string): TCibFac;
    procedure Agregar(gfac: TCibGFac);
    procedure Eliminar(gfac: TCibGFac);
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
    procedure EjecComando(idVista: string; tram: TCPTrama);
  public  //constructor y destructor
    constructor Create(nombre0: string; ModoCopia0: boolean=false);
    destructor Destroy; override;
  end;

  function CrearGFACdeTipo(tipGFac: TCibTipGFact; ModoCopia: boolean): TCibGFac;
  function ExtraerBloqueEstado(lisEstado: TStringList;
           out estGfac, nomGrup: string; out tipo: TCibTipGFact): boolean;
  function ExtraerBloquePropied(lisPropied: TStringList; out propGfac, nomGrup: string;
                                out tipGru: TCibTipGFact): boolean;

implementation

function CrearGFACdeTipo(tipGFac: TCibTipGFact; ModoCopia: boolean): TCibGFac;
{Crea un grupo facturable a partir de un identificador del tipo ed grupo.}
begin
  case tipGFac of
  ctfClientes: begin
    Result := TCibGFacClientes.Create('CliSinProp', ModoCopia);
  end;
  ctfCabinas: begin
    Result := TCibGFacCabinas.Create('CabsSinProp', ModoCopia);  //crea la instancia
  end;
  ctfNiloM: begin
    Result := TCibGFacNiloM.Create('NiloSinProp', ModoCopia);
  end;
  ctfMesas: begin
    Result := TCibGFacMesas.Create('MesSinProp', ModoCopia);
  end;
  else
    Result := nil;
  end;
end;
function ExtraerBloqueEstado(lisEstado: TStringList; out estGfac, nomGrup: string;
                              out tipo: TCibTipGFact): boolean;
{Extrae de la cadena de estado de la aplicación (guardada en lisEstado), el fragmento
que corresponde al estado de un grupo facturable. El estado se devuelve en "estado"
Normalmente lisEstado , tendrá la forma:
<0	Cabinas
cCab1	0	1899:12:30:00:00:00
cCab2	3	1899:12:30:00:00:00
...
>
<1      Locutor
...
>

Las líneas extraidas, serán eliminadas de la lista. Si encuentra error, muestra el
mensaje y devuelve FALSE.
}
var
  a: TStringDynArray;
  lin0: String;
begin
  estGfac := '';
  if lisEstado.Count=0 then begin
    estGfac := '';
    exit(false);   //está vacía
  end;
  lin0 := lisEstado[0];
  if (lin0='') or (lin0[1]<>'<') then begin
    MsgErr('Error en cadena de estado. Se esperaba "<".');
    exit(false);   //Sale con error
  end;
  while (lisEstado.Count>0) and (lisEstado[0]<>'>') do begin
    if estGfac='' then begin
      //Es la primera línea a agregar. Aprovechamos para capturar tipo y nomGrup de grupo
      a := Explode(#9, lisEstado[0]);
      delete(a[0], 1, 1);  //quita "<"
      tipo := TCibTipGFact(f2I(a[0]));
      nomGrup := a[1];
    end;
    estGfac := estGfac + lisEstado[0] + LineEnding;  //acumula
    lisEstado.Delete(0);  //elimina
  end;
  if (lisEstado.Count=0) then begin
    MsgErr('Error en cadena de estado. Se esperaba ">".');
    estGfac := '';
    exit(false);   //Sale con error
  end else begin
    //Lo esperado. Hay al menos una línea más.
    estGfac := estGfac + '>';  //acumula
    lisEstado.Delete(0);  //elimina la fila '>'
    exit(true);    //Sale sin error
  end;
end;
function ExtraerBloquePropied(lisPropied: TStringList; out propGfac, nomGrup: string;
                              out tipGru: TCibTipGFact): boolean;
{Recibe la cadena de propiedades del modelo y extrae en fragmentos correspondientes al
de un grupo. Algo como:
[[1
NILO-m	COUNTER	136	11	1	0.1	F	F	10
LOCUTORIO 1	0	0	0	15	371
LOCUTORIO 2	1	0	0	126	371
LOCUTORIO 3	2	0	0	237	371
LOCUTORIO 4	3	0	0	348	371
]]
Si no encuentra la propiedad para un grupo, devuelve false.
}
var
  lin, tmp: string;
  nTip: Integer;
begin
  propGfac := '';
  if lisPropied.Count=0 then begin
    exit(false);  //No encontró bloque
  end;
  while lisPropied.Count>0 do begin
    lin := lisPropied[0];
    if trim(lin) = '' then begin
      //Se ignora
    end else begin
      if copy(lin,1,2) = '[[' then begin  //Marca de inicio
        nTip := StrToInt(copy(lin, 3, length(lin)));
        tipGru := TCibTipGFact(nTip);
        tmp:='';  //inicia acumulación
      end else if lin = ']]' then begin  //Marca de fin,
        //Ya se tiene la cadena de propiedades para el nuevo grupo
        propGfac := tmp;
        lisPropied.Delete(0);
        exit(true);
      end else begin
        if tmp='' then begin
          //Es la primera línea del bloque
          nomGrup := copy(lin, 1, pos(#9, lin)-1);
        end;
        tmp := tmp + lin + LineEnding;
      end;
    end;
    lisPropied.Delete(0);
  end;
  MsgErr('No se encuentra bloque de propiedad.');
  exit(false);  //No encontró bloque
end;

{ TCibModelo }
//Respuesta a eventos
procedure TCibModelo.gfac_CambiaPropied;
begin
  if not DeshabEven and (OnCambiaPropied<>nil) then OnCambiaPropied;
end;
procedure TCibModelo.gfac_ActualizStock(const codPro: string;
  const Ctdad: double);
begin
  {Porpaga el evento, ya que se supone que no se tiene acceso al alamacén desde aquí}
  if not DeshabEven and (OnActualizStock<>nil) then OnActualizStock(codPro, Ctdad);
end;
procedure TCibModelo.gfac_RespComando(idVista: string;
  comando: TCPTipCom; ParamX, ParamY: word; cad: string);
begin
  if not DeshabEven and (OnRespComando<>nil) then
    OnRespComando(idVista, comando, ParamX, ParamY, cad);
end;
function TCibModelo.gfac_LogInfo(msj: string): integer;
begin
  if not DeshabEven and (OnLogInfo<>nil) then Result := OnLogInfo(msj);
end;
function TCibModelo.gfac_LogVenta(ident:char; msje:string; dCosto:Double): integer;
begin
  if not DeshabEven and (OnLogVenta<>nil) then
    Result := OnLogVenta(ident, msje, dCosto);
end;
function TCibModelo.gfac_LogIngre(ident: char; msje: string;
  dCosto: Double): integer;
begin
  if not DeshabEven and (OnLogIngre<>nil) then
    Result := OnLogIngre(ident, msje, dCosto);
end;
function TCibModelo.gfac_LogError(msj: string): integer;
begin
  if not DeshabEven and (OnLogError<>nil) then
    Result := OnLogError(msj);
end;
procedure TCibModelo.gfac_BDinsert(sqlText: string);
begin
  if not DeshabEven and (OnBDinsert<>nil) then
    OnBDinsert(sqlText);
end;
procedure TCibModelo.gfac_ReqConfigGen(out NombProg, NombLocal: string; out
  ModDiseno: boolean);
{Permite preguntar al modelo por parámetros de configuración general.
Notar que este evento siempre funciona. Auqnue no haya sido inicializado "OnReqConfigGen".
Una forma de saber se se ha incializado el evento es verificar el valor que devuelve, por
ejemplo, en el campo "NombProg", que siempre debe ser diferente de Nulo.}
begin
  if OnReqConfigGen<>nil then begin
    OnReqConfigGen(NombProg, NombLocal, ModDiseno);
  end else begin
    NombProg := '';
    NombLocal := '';
    ModDiseno := false;
  end;
end;
procedure TCibModelo.gfac_ReqConfigUsu(out Usuario: string);
begin
  if OnReqConfigUsu<>nil then begin
    OnReqConfigUsu(Usuario);
  end else begin
    Usuario := '';
  end;
end;
function TCibModelo.gfac_ReqCadMoneda(valor: double): string;
begin
  if OnReqCadMoneda=nil then
    Result := ''
  else
    Result := OnReqCadMoneda(valor);
end;
procedure TCibModelo.gfac_SolicEjecCom(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
{Un Gfac solicita ejecutar una acción, en uno de sus elementos.}
begin
  if not DeshabEven and (OnSolicEjecCom<>nil) then
    OnSolicEjecCom(comando, ParamX, ParamY, cad);
end;
function TCibModelo.ItemPorNombre(nomb: string): TCibGFac;
{Busca a uno de los grupos de facturables, por su nombre. Si no encuentra, devuelve NIL}
var
  gf : TCibGFac;
begin
//  debugln('-busc:'+nomb);
  for gf in items do begin
    if gf.Nombre = nomb then exit(gf);
  end;
  //no encontró
  exit(nil);
end;
procedure TCibModelo.EjecRespuesta(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
{Método que recibe la respuesta a un comando. Debe ejecutarse siempre en el Visor.}
var
  Grupo: String;
  GFac: TCibGFac;
  Err: boolean;
begin
  //Se supone que la respuesta debe tener, al menos el identificador del grupo
  Grupo := ExtraerHasta(cad, SEP_IDFAC, Err);  //El grupo viene en el primer campo
  GFac := ItemPorNombre(Grupo);  //Ubica al grupo facturable
  if GFac=nil then exit;
  //Notar que ya se estrajo el identificador de grupo  de "cad".
  Gfac.EjecRespuesta(comando, ParamX, ParamY, cad);
end;
procedure TCibModelo.EjecComando(idVista: string; tram: TCPTrama);
{Rutina que centraliza todas las acciones a realizar sobre el Modelo.
 Es llamada de las siguientes formas:
 1. Como respuesta al evento OnTramaLista de un Grupo de Cabinas (tramaLocal=FALSE).
    En este caso, las tramas pueden indicar respuesta a un comando enviado a una cabina
    o solicitudes de acciones sobre el modelo, como es el caso cuando la cabian remota es
    también un punto de Venta (CiberPlex-Visor).
 2. Como método para ejecutar acciones locales sobre el modelo de objetos (Fac, GFac).
    Estas llamadas, se ejecutarán desde esta misma aplicación (Visor local o la misma
    aplicación), no de PC remotas.
 3. Como repsuesta a comandos llegados desde la Web (NO IMPLEMENTADO AÚN)

 Parámetros:
 * idVista -> Identifica a la vista que genera la petición. Para comandos
              locales, debe valer '$'.
 * tram -> Es la trama que contiene el comando que debe ejecutarse.

Como este método ejecuta todos los comandos solicitados por la cabinas de Internet, o de
la aplicación, hace uso de eventos para acceder a información que no está en este ámbito.}
var
  arch: string;
  tmp, Grupo: string;
  Err: boolean;
  GFac: TCibGFac;
  Res: string;
begin
  case tram.tipTra of
  CVIS_SOLPROP: begin  //Se solicita el archivo INI (No está bien definido)
      tmp := CadPropiedades;
      if OnRespComando<>nil then OnRespComando(idVista, RVIS_SOLPROP, 0, 0, tmp);
    end;
  CVIS_SOLESTA: begin  //Se solicita el estado de todos los objetos del modelo
      //Identifica a la cabina origen para entregarle la información
      debugln(idVista+ ': Estado solicitado.');
      tmp := CadEstado;
      if OnRespComando<>nil then OnRespComando(idVista, RVIS_SOLESTA, 0, 0, tmp);
    end;
  CVIS_CAPPANT: begin  //se pide una captura de pantalla
      //Identifica a la cabina origen para entregarle la información
      debugln(idVista+ ': Pantalla completa solicitada.');
      arch := ExtractFilePath(Application.ExeName) + '~00.tmp';
      PantallaAArchivo(arch);
      if OnRespComando<>nil then OnRespComando(idVista, RVIS_CAPPANT, 0, 0, StringFromFile(arch));
    end;
  CVIS_ACTPROD: begin   //Se pide modificar la tabla de productos
    if OnModifTablaBD <> nil then begin
      Res := OnModifTablaBD('productos', tram.posY, tram.traDat);
      //La salida puede ser un mensaje de confirmación o error
      if OnRespComando<>nil then OnRespComando(idVista, C_MENS_PC, 0, 0, Res);
    end;
  end;
  CVIS_ACTPROV: begin   //Se pide modificar la tabla de proveedores
    if OnModifTablaBD<>nil then begin
      Res := OnModifTablaBD('proveedores', tram.posY, tram.traDat);
      //La salida puede ser un mensaje de confirmación o error
      if OnRespComando<>nil then OnRespComando(idVista, C_MENS_PC, 0, 0, Res);
    end;
  end;
  CVIS_ACTINSU: begin   //Se pide modificar la tabla de productos
    if OnModifTablaBD<>nil then begin
      Res := OnModifTablaBD('insumos', tram.posY, tram.traDat);
      //La salida puede ser un mensaje de confirmación o error
      if OnRespComando<>nil then OnRespComando(idVista, C_MENS_PC, 0, 0, Res);
    end;
  end;
  CVIS_ACBOLET: begin  //Acciones sobre Boletas
      //Identifica al facturable sobre el que se aplica
      Grupo := VerHasta(tram.traDat, SEP_IDFAC, Err);  //El grupo viene en el primer campo
      GFac := ItemPorNombre(Grupo);
      if GFac=nil then exit;
      Gfac.AccionesBoleta(tram);  //ejecuta la acción
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
  end;
  //Acciones sobre objetos facturables
  CFAC_CLIEN, CFAC_CABIN, CFAC_NILOM: begin   //Acciones sobre una cabina
      //Identifica a la cabina sobre la que aplica
      Grupo := VerHasta(tram.traDat, SEP_IDFAC, Err);  //El grupo viene en el primer campo
      GFac := ItemPorNombre(Grupo);
      if GFac=nil then exit;
      //Solicita al grupo ejecutar acción.
      Gfac.EjecAccion(idVista, tram);
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
      { TODO : Por lo que se ve aquí, no sería necesario guardar regularmente el archivo
      de estado, (como se hace actualmente con el Timer) , ya que se está detectando cada
      evento que genera cambios. Verificar si  eso es cierto, sobre todo en el caso de la
      desconexión automática, o algún otro evento similar que requiera guardar el estado.}
    end;
  C_BD_HISTOR: begin
    //Se pide una acción sobre la base de datos histórica.
    //Estas bases de datos son más que nada para agregar registros.
    { TODO : Tal vez haya que precisar mejor este comando, creando comandos adicionales o subcomandos }
    if OnBDinsert <> nil then begin
      OnBDinsert(tram.traDat);  //Ejecuta comando SQL
    end;
  end;
  else
    debugln('  ¡¡Comando no implementado!!');
  end;
end;
procedure TCibModelo.GCab_ArchCambRemot(ruta, nombre: string);
begin
  if not DeshabEven and (OnArchCambRemot<>nil) then begin
    OnArchCambRemot(ruta, nombre);
  end;
end;
function TCibModelo.BuscaNombreItem(StrBase: string): string;
{Genera un nombre de ítem que no exista en el grupo. Para ello se toma un nombre base
y se le va agregando un ordinal.}
var
  idx: Integer;
  nomb: String;
begin
  idx := items.Count+1;   //Inicia en 1
  nomb := StrBase + IntToStr(idx);
  while ItemPorNombre(nomb) <> nil do begin
    Inc(idx);
    nomb := StrBase + IntToStr(idx);
  end;
  Result := nomb;
end;
function TCibModelo.GetCadPropiedades: string;
var
  gf : TCibGFac;
  tmp: String;
begin
  tmp := '' + LineEnding;  //la primera línea contiene propiedades del grupo.
  for gf in items do begin
    tmp := tmp + '[[' + IntToStr(ord(gf.tipGFac)) + LineEnding +
                 gf.CadPropied + LineEnding +
                 ']]' + LineEnding;
  end;
  Result := tmp;
end;
procedure TCibModelo.SetCadPropiedades(AValue: string);
var
  tmp, nomGrup: string;
  lineas  : TStringList;
  gFac    : TCibGFac;
  tipGru  : TCibTipGFact;
begin
  if trim(AValue) = '' then exit;
  lineas := TStringList.Create;
  lineas.Text:=AValue;  //divide en líneas

  items.Clear;  //elimina todos para crearlos de nuevo
  lineas.Delete(0);   //elimina primera línea
  while ExtraerBloquePropied(lineas, tmp, nomGrup, tipGru) do begin
    //Crea al grupo, en el mismo modo (ModoCopia), con que se ha creado esre objeto.
    gFac := CrearGFACdeTipo(tipGru, ModoCopia);
    gFac.CadPropied:=tmp;
    Agregar(gFac);
  end;
  lineas.Destroy;
end;
function TCibModelo.GetCadEstado: string;
var
  gf : TCibGFac;
  primero: Boolean;
begin
  Result := '';
  primero := true;  //bandera para evitar poner el salto final
  {Simplemente junta las cadenas de estado de los grupos, sin delimitador porque tienen
  el formato adecuado para poder separarlas.}
  for gf in items do begin
    if primero then begin
      Result := gf.CadEstado;
      primero := false;
    end else begin
      Result := Result + LineEnding + gf.CadEstado;
    end;
  end;
end;
procedure TCibModelo.SetCadEstado(const AValue: string);
var
  lest: TStringList;
  res: Boolean;
  cad, nombGrup: string;
  tipo: TCibTipGFact;
  gfac: TCibGFac;
begin
//debugln('---');
//debugln(AValue);
  lest:= TStringList.Create;
  lest.Text := AValue;  //carga texto
  //Extrae los fragmentos correspondientes a cada Grupo facturable
  while lest.Count>0 do begin
    res := ExtraerBloqueEstado(lest, cad, nombGrup, tipo);
    if not res then break;  //se mostró mensaje de error
    gfac := ItemPorNombre(nombGrup);
    if gfac = nil then begin
      //Llegó el estado de un grupo que no existe.
      debugln('Grupo no existente: ' + nombGrup);   //WARNING
      break;
    end;
    gfac.CadEstado := cad;   //No importa de que tipo sea
  end;
  //Carga el contenido del archivo de estado.
  lest.Destroy;
end;
function TCibModelo.NumGrupos: integer;
begin
  Result := items.Count;
end;
function TCibModelo.BuscarPorID(idFac: string): TCibFac;
{Busca un facturable en todo este objeto. Si no encuentra devuelve NIL.}
var
  campos: TStringDynArray;
  nomGFac, nomFac: String;
  gfac: TCibGFac;
begin
  if idFac='' then exit(nil);
  //Extrae nombre de grupo y de facturable
  campos := Explode(SEP_IDFAC, idFac);
  if high(campos)<>1 then
    exit(nil);  //No hay 2 campos. Debe haber un errro
  nomGFac := campos[0];
  nomFac := campos[1];
  //Identifica al grupo.
  gfac := ItemPorNombre(nomGFac);   //asume que "cab.Grupo" es el objeto copia, no el del modelo
  if gfac = nil then
    exit(nil);
  Result := gfac.ItemPorNombre(nomFac);
end;
procedure TCibModelo.Agregar(gfac: TCibGFac);
{Agrega un grupo de facturables al objeto. Notar que esta rutina solo configura
los eventos, antes de agregar.}
begin
  //Configura eventos del grupo, que se direccionan al modelo
  gfac.OnCambiaPropied:= @gfac_CambiaPropied;
  gfac.OnActualizStock:= @gfac_ActualizStock;
  gfac.OnRespComando  := @gfac_RespComando;

  gfac.OnLogInfo      := @gfac_LogInfo;
  gfac.OnLogVenta     := @gfac_LogVenta;
  gfac.OnLogIngre     := @gfac_LogIngre;
  gfac.OnLogError     := @gfac_LogError;

  gfac.OnReqConfigGen := @gfac_ReqConfigGen;
  gfac.OnReqConfigUsu := @gfac_ReqConfigUsu;
  gfac.OnReqCadMoneda := @gfac_ReqCadMoneda;

  gfac.OnSolicEjecCom := @gfac_SolicEjecCom;
  //Eventos que se resuelven en el mismo modelo
  gfac.OnBuscarGFac   := @ItemPorNombre;
  case gfac.tipGFac of
  ctfCabinas: begin
    //Eventos propios de las cabinas
    TCibGFacCabinas(gfac).OnTramaLista:=@EjecComando;
    TCibGFacCabinas(gfac).OnArchCambRemot:=@GCab_ArchCambRemot;
  end;
  ctfNiloM: begin
    {Se aprovecha aquí para leer los archivos de configuración. No se encontró un mejor
    lugar, ya que lo que se desea, es que los archivos de configuración se carguen solo
    una vez, sea que el NILO-m se agrege por el  menú principal o se carge del archivo
    de configuración.}
    if not TCibGFacNiloM(gfac).ModoCopia then begin
      //En modo copia, no se cargan las configuraciones
      TCibGFacNiloM(gfac).LeerArchivosConfig;   //si genera error, muestra su mensaje
    end;
  end;
  end;
  //Agrega
  items.Add(gfac);
  if not DeshabEven and (OnCambiaPropied<>nil) then OnCambiaPropied;
end;
procedure TCibModelo.Eliminar(gfac: TCibGFac);
begin
  items.Remove(gfac);
  if not DeshabEven and (OnCambiaPropied<>nil) then OnCambiaPropied;
end;
//constructor y destructor
constructor TCibModelo.Create(nombre0: string; ModoCopia0: boolean = false);
begin
  nombre := nombre0;
  FModoCopia:=ModoCopia0;   //Define el modo de trabajo
  items := TCibGFact_list.Create(true);
end;
destructor TCibModelo.Destroy;
begin
  items.Destroy;
  inherited Destroy;
end;

end.

