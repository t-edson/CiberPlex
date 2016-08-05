{Unidad que define a la clase TCPGrupoCabinas, que es el objeto que se usa para controlar
a las cabinas de Internet.}
unit CPGrupoCabinas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, types, dateutils, math, LCLProc, ExtCtrls, MisUtils,
  CPCabinaBase, CPTramas, FormInicio, CPFacturables,
  CPCabinaTarifas;
const
  IDE_EST_CAB = 'c'; {Identificador de línea de estado de cabina. Debe ser de un caracter.
                      El formato de estado, para una cabina es:
                      c<Estado de cabina>
                       <Estado de boleta>
                      }

type
  TCPCabina = class;
  TCPGrupoCabinas = class;

  //TEvCabCambiaEstado = procedure(nuevoEstado: TCabEstadoConex) of object;
  TEvCabTramaLista = procedure(cab: TCPCabina; tram: TCPTrama; tramaLocal: boolean) of object;
  TEvCabRegMensaje = procedure(NomCab: string; msj: string) of object;
  TEvCabAccionCab = procedure(cab: TCPCabina) of object;
  TEvCabLogInfo = procedure(cab: TCPCabina; msj: string) of object;
//  TEvCabLogIBol = procedure(cab: TCPCabina; it: TCPItemBoleta; msj: string) of object;

  { TCPCabina }
  {Define al objeto Cabina de Ciberplex}
  TCPCabina = class(TCPFacturable)
    procedure cabCambiaEstadoConex(nuevoEstado: TCabEstadoConex);
  protected  //"Getter" and "Setter"
    FConConexion: boolean;
    FTransc: integer;   //Tiempo transcurrido en segundos.
    FCosto: double;     //Costo.
    procedure cabConexRegMensaje(NomCab: string; msj: string);
    procedure cabConexTramaLista(NomCab: string; tram: TCPTrama);
    function GetIP: string;
    procedure SetIP(AValue: string);
    procedure SetMac(AValue: string);
    procedure SetConConexion(AValue: boolean);
    function GetCadPropied: string;
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    procedure SetCadPropied(AValue: string);
    procedure SetNombrePC(AValue: string);
  private  //campos privados
    cabCuenta: TCabCuenta;    //campos de conteo de la cabina
    cabConex : TCabConexion;  //campos de conexión de la cabina
    FNombrePC: string;
    PausadS: integer;  {tiempo pausado en segundos (Contador de
                        tiempo que la cabina se encuentra en pausa)}
    tic    : integer;   //contador para temporización
    SinRed : boolean;  {Para usar al objeto, solamente como contenedor, sin conexión
                        por Socket.}
    function VerCorteAutomatico: boolean;
  public  //campos diversos
    OnTramaLista  : TEvCabTramaLista;   //indica que hay una trama lista esperando
    OnRegMensaje  : TEvCabRegMensaje;   //indica que se ha generado un mensaje de la conexión
    OnDetenConteo : TEVCabAccionCab;    //Cuando se detiene el conteo de una cabina
    OnLogInfo     : TEvCabLogInfo;      //Indica que se quiere registrar un mensaje en el registro
    //OnGrabBoleta  : TEvCabAccionCab;    //Indica que se ha grabado la boleta
    Grupo   : TCPGrupoCabinas;  //Referencia a su grupo, si es que pertenece a uno.
    tarif   : TCPTarifCabinas;  {Tarifa de cabina. Se podría acceder también a la "tarif"
                                 a través de la referencia "Grupo"}
    MsjError: string;         //para mensajes de error
    function RegVenta: string; //línea para registro de venta
    procedure Contar1seg;     //usado para temporización
  public  //campos de propiedades
    property NombrePC : string read FNombrePC write SetNombrePC;  //Nombre de Red que tiene la PC cliente
    property IP: string read GetIP write SetIP;
    property Mac: string read cabConex.mac write SetMac;
    property ConConexion: boolean read FConConexion write SetConConexion;
    //campos calculados
    property CadPropied: string read GetCadPropied write SetCadPropied;
  public  //campos de estado
    HoraPC : TDateTime;  //Fecha-hora que tiene la PC cliente, localmente.
    PantBloq: Boolean;   //Indica si la PC cliente tiene la pantalla bloqueada
    property EstadoCta: TcabEstadoCuenta read cabCuenta.estado;
    property hor_ini: TDateTime read cabCuenta.hor_ini;
    property tSolic: TDateTime read cabCuenta.tSolic;
    property tLibre: boolean read cabCuenta.tLibre;
    property horGra: boolean read cabCuenta.horGra;
    //campos calculados
    property TranscSeg: integer read FTransc; //Tiempo transcurrido en segundos. Se actualiza con ActualizaTranscYCosto()
    property Costo: double read FCosto;    //Costo. Se actualiza con ActualizaCosto()
    function Faltante: integer;    //Tiempo faltante en segundos
    function EstadoCtaStr: string;
    function tSolicSeg: integer;
    function tSolicMin: integer;
    function TranscDat: TTime;   //Tiempo transcurrido, como fecha.
    function TranscSegTol: integer;   //Tiempo transcurrido, considerando la Tolerancia.
  private //rutinas de actualización de campos de estado
    procedure ActualizaTranscYCosto;
  public  //campos de conexión
    function EstadoConex: TCabEstadoConex;
    function EstadoConexN: integer;
    function EstadoConexStr: string;
    function Conectado: boolean;
    procedure Desconectar;
  public //control de la cabina
    function Contando: boolean;  //indica que la cabina está contando el tiempo
    function Detenida: boolean;  //indica que la cabina está detenida
    procedure SincTiempo;        //sincroniza el tiempo con la cabina cliente
    procedure SincBloqueo;       //sicroniza el bloqueo de la pantalla
    procedure TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string=
      '');
    procedure InicConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
    procedure ModifConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
    procedure DetenConteo;
    procedure PonerManten;     //pone cabina en mantenimiento
    procedure SacarManten;     //pone cabina en mantenimiento
  public  //constructor y destructor
    constructor Create(nombre0: string; ip0: string);
    constructor CreateSinRed;  //Crea objeto sin red
    destructor Destroy; override;
  end;
//  TCPCabina_list = specialize TFPGObjectList<TCPCabina>;   //lista de bloques

  { TCPDecodCadEstado }
  {Objeto sencillo que permite decodificar una cadena de estado de un grupo facturable. }
  { TODO : Ver si solo es aplicable a las cabinas, y de ser así, se deberái incluir dentro de la clase  TCPGrupoCabina }
  TCPDecodCadEstado = class
    private
      lineas: TStringList;
      pos1, pos2: Integer;
    public
      procedure Inic(const cad: string);
      function ExtraerNombre(const lin: string): string;
      function Extraer(var car: char; var nombre, cadena: string): boolean;
    public  //constructor y destructor
      constructor Create;
      destructor Destroy; override;
  end;


  { TCPGrupoCabinas }
  { Clase que define al conjunto de las PC clientes. Se juntan todas las
  cabinas en un objeto único, porque la arquitectura se define para centralizar el
  control en un solo objeto, con la posibilidad de tener múltiples interfaces
  (pantallas) de la aplicación. }
  TCPGrupoCabinas = class(TCPGrupoFacturable)
    procedure cab_CambiaPropied;
    procedure timer1Timer(Sender: TObject);
  private
    timer1 : TTimer;
    decod: TCPDecodCadEstado;  //Para decodificar las cadenas de estado
    procedure cab_LogInfo(cab: TCPCabina; msj: string);
    procedure cab_DetenConteo(cab: TCPCabina);
    procedure cab_RegMensaje(NomCab: string; msj: string);
    procedure cab_TramaLista(cab: TCPCabina; tram: TCPTrama; tramaLocal: boolean);
  public  //Eventos.
    {Acciones que se pueden disparar automáticamente. Sin intrevención del usuario}
    OnCambiaPropied: procedure of object;  //cambio de propiedades
    OnTramaLista   : TEvCabTramaLista; //indica que hay una trama lista esperando
    OnRegMensaje   : TEvCabRegMensaje; //indica que se ha geenrado un mensaje de la conexión
    OnDetenConteo  : TEVCabAccionCab;  //indica que se ha detenido la cuenta en alguna cabina
    OnLogInfo      : TEvCabLogInfo;    //Indica que se quiere registrar un mensaje en el registro
  protected //Getters and Setters
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    procedure SetModoCopia(AValue: boolean); override;
  public
    CategCabi: string;   //categoría de Venta para cabinas de internet.
    tarif: TCPTarifCabinas; //tarifas de cabina
    GrupTarAlquiler: TGrupoTarAlquiler;  //Grupo de tarifas de alquiler
    function Agregar(nombre0: string; ip0: string): TCPCabina;
    function Eliminar(nombre0: string): boolean;
    procedure Conectar;
    function ListaCabinas: string;
    function CabPorNombre(nom: string): TCPCabina;
    function Toleran: TDateTime;   //acceso a la tolerancia
  public  //operaciones con cabinas
    procedure TCP_envComando(nom: string; comando: TCPTipCom; ParamX, ParamY: word;
      cad: string='');
  public  //constructor y destructor
    procedure MuestraConexionCabina;
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;



  function VarCampoNombreCP(const cad: string): string;

implementation
function VarCampoNombreCP(const cad: string): string;
{Devuelve el campo nombre de una lista de campos separados por tabulaciones.}
var
  p: Integer;
begin
  p := pos(#9, cad);  //busca delimitador
  if p=0 then begin
    //no hay delimitador, toma todo
    Result := cad;
  end else begin
    Result := copy(cad, 1, p-1);
  end;
end;
function ExtraerCampoCP(var cad: string): string;
{Extrae un campo de una lista de campos separados por tabulaciones. Elimina la
 tabulación al final del campo.}
var
  p: Integer;
begin
  p := pos(#9, cad);  //busca delimitador
  if p=0 then begin
    //no hay delimitador, toma todo
    Result := cad;
    cad := '';  //recorta
  end else begin
    Result := copy(cad, 1, p-1);
    cad := copy(cad, p+1, length(cad));  //recorta nombre
  end;
end;
{ TCPCabina }
procedure TCPCabina.cabCambiaEstadoConex(nuevoEstado: TCabEstadoConex);
{Evento de cambio de estado de la conexión}
begin
  //Se considera un cambio de estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
end;
procedure TCPCabina.cabConexTramaLista(NomCab: string; tram: TCPTrama);
begin
  if OnTramaLista<>nil then OnTramaLista(self, tram, false);
end;
procedure TCPCabina.cabConexRegMensaje(NomCab: string; msj: string);
begin
  if OnRegMensaje<>nil then OnRegMensaje(Nombre, msj);
end;
function TCPCabina.GetIP: string;
begin
  Result := cabConex.IP;
end;
procedure TCPCabina.SetIP(AValue: string);
begin
  if cabConex.IP = AValue then exit;
  cabConex.MsjError:='';
  cabConex.IP := AValue;
  if cabConex.MsjError<>'' then begin
    self.MsjError := cabConex.MsjError;
    exit;
  end;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCPCabina.SetMac(AValue: string);
begin
  if cabConex.mac = AValue then exit;
  cabConex.mac := AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCPCabina.GetCadPropied: string;
{Las propiedades son los compos que definen la configuración de una cabina. Se fijan al
inicio, y no es común cambiarlos luego}
begin
  Result := Nombre + #9 +
            IP + #9 +
            mac + #9 +
            N2f(x) + #9 +
            N2f(y) + #9 +
            B2f(ConConexion) + #9 +
            NombrePC + #9 +
            #9 + #9 + #9;
end;
procedure TCPCabina.SetCadPropied(AValue: string);
var
  campos: TStringDynArray;
begin
   campos := Explode(#9, Avalue);
   Nombre := campos[0];
   IP := campos[1];
   mac := campos[2];
   x := f2N(campos[3]);
   y := f2N(campos[4]);
   ConConexion := f2B(campos[5]);  //si es TRUE (y SinRed=FALSE), inicia la conexión
   NombrePC := campos[6];
   if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCPCabina.SetNombrePC(AValue: string);
begin
  if FNombrePC=AValue then Exit;
  FNombrePC:=AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCPCabina.RegVenta: string;
{Devuelve la línea que debe escribirse en el registro de venta al desactivarse la cabina}
var
  estConex: String;
  categ: String;
begin
  if cabCuenta.horGra Then  { TODO : Esta conversión a cadena no es precisa }
      categ := 'HOR_GRA'
  else if cabCuenta.tLibre Then
      categ := 'HOR_LIB'
  else
      categ := 'NORMAL';
  estConex := IntToStr(EstadoConexN);
  Result := usuario + #9 + 'INT01' + #9 +
           'INTERNET' + #9 +
           IntToStr(TranscSegTol) + #9 +
           N2f(FCosto) + #9 + N2f(FCosto) + #9 +
           D2f(cabCuenta.hor_ini) + #9 + categ + #9 +
           I2f(Round(cabCuenta.tSolic * 24 * 60)) + #9 +
           'ALQUILER DE CABINA' + #9 + D2f(FTransc) + #9 +
           Nombre + #9 + estConex + #9 +
           I2f(PausadS) + #9 + D2f(TranscSegTol) + #9 +
           D2f(cabCuenta.tSolic) + #9 + Grupo.CategCabi +
           #9 + #9 + #9
end;
function TCPCabina.VerCorteAutomatico: boolean;
{Verifica si se debe hacer un corte automático, y lo hace, siemrpec y cuando haya
 conexión remota. Si no lo logra devuelve FALSE}
var
  atraso: TDateTime;
begin
  Result := false;
  If Conectado And (tSolicSeg <= TranscSegTol) Then begin
{     Terminó el tiempo con tolerancia
          Transcur = Date + Time - hor_ini - toleran / 60 / 60 / 24
      Puede que se haya detectado un poco tarde por problemas de
      colgada de PC o de falla en la temporización de Windows.
      verificamos atraso}
      If tSolic < TranscSegTol Then begin
          //hay atraso, ¿de cuanto?
          atraso := (TranscSegTol - tSolic);
//Debugln('====================================');
//Debugln('atraso de ' + atraso * 24 * 60 * 60);
          if atraso < 5 / 24 / 60 / 60 then begin //menos de 5 segundos
//Debug.Print "corregido"
              //es aceptable. Corregir "Transcur" para no incrementar
              //el Costo final del alquiler por menos de 5 segundos
              cabCuenta.hor_ini := cabCuenta.hor_ini + atraso;
          end
      end else begin
//Debug.Print "sin atraso "
      end;
      //Call PlaySound(CarpetaSnd & "\desconectada.wav", ByVal 0&, SND_FILENAME Or SND_ASYNC Or SND_NODEFAULT Or SND_NOSTOP)
      DetenConteo;    //se desconecta
      Result := True;
      exit;
  end;
end;
procedure TCPCabina.Contar1seg;
{Rutina de temporización. Se encarga de actualizar los campos FTransc y FCosto.
 Es recomendabla llamarla cada segundo.}
begin
  ActualizaTranscYCosto ; //para tener a "TranscSeg" y "Costo" actualizados
  //Generación de mensajes se sincronía de tiempo y bloqueo
  Inc(tic);
  if tic mod 60 = 0 then
    SincBloqueo       //Sincroniza el bloqueo
  else
    if tic mod 5 = 0 then SincTiempo;  //sincroniza el tiempo
  //Procedimiento de Temporización
  If cabCuenta.estado = EST_MANTEN Then exit;     //en mantenimiento
  If cabCuenta.estado in [EST_CONTAN,EST_PAUSAD] Then begin
      If cabCuenta.estado = EST_PAUSAD Then begin //corrige tiempo de fin para mantener cuenta
        cabCuenta.hor_ini := cabCuenta.hor_ini + 1 / 24 / 60 / 60;
        PausadS := PausadS + 1;   //incrementa el contador
      end;
      if Not cabCuenta.tlibre Then begin
        If FTransc < cabCuenta.tSolic Then begin
          //Aún se está dentro del tiempo

        end else begin
          If VerCorteAutomatico Then exit;
          //Tiempo vencido, pero no se puede hacer corte automático
          //...
        end;
      end;
  end else begin
    //Estado Normal o en mantenimiento
  end;
end;
function TCPCabina.Faltante: integer;
//Tiempo faltante en segundos
begin
  Result := cabCuenta.tSolicSeg - FTransc;
  if Result<0 then Result := 0;
end;
function TCPCabina.EstadoCtaStr: string;
begin
  Result := cabCuenta.estadoStr
end;
function TCPCabina.tSolicSeg: integer;
begin
  Result := cabCuenta.tSolicSeg;
end;
function TCPCabina.tSolicMin: integer;
begin
  Result := cabCuenta.tSolicSeg div 60;
end;
function TCPCabina.TranscDat: TTime;
begin
  Result := FTransc / SecsPerDay;
//  EncodeTime(0,0,FTransc,0);
end;
function TCPCabina.TranscSegTol: integer;
{Tiempo transcurrido, considerando la Tolerancia.}
begin
  if tarif = nil then exit(0);
  Result := FTransc - tarif.toler;
  If Result < 0 Then Result := 0;
end;
function TCPCabina.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := IDE_EST_CAB + {se omite la coma para reducir tamaño}
         Nombre + #9 +    {el nombre es obligatorio para identificar unívocamente a la cabina}
         I2f(cabConex.estadoN)+ #9 + {se coloca primero el Estado de la conexión, porque
             es el campo que siempre debe actualizarse, cuando hay conexión remota activada}
         D2f(HoraPC);  //Este campo no tiene significado si no hay conexión
  if cabCuenta.estado <> EST_NORMAL then begin
    // En el estado EST_NORMAL, no es necesario enviar los demás campos
    Result += #9 +
         I2f(cabCuenta.estadoN) + #9 +
         D2f(cabCuenta.hor_ini) + #9 +
         D2f(cabCuenta.tSolic) + #9 +
         B2f(cabCuenta.tLibre) + #9 +
         B2f(cabCuenta.horGra) + #9 +
       { Estos campos son calculados, pero se devuelven como ayuda, para la implementación
         de otros puntos de venta (conectados a este servidor), de modo que no necesiten
         hacer nuevamente el cálculo (con posibilidad de obtener un resultado diferente) }
         I2f(FTransc) + #9 +
         N2f(FCosto);
  end;
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCPCabina.SetCadEstado(AValue: string);
{Fija los campos de estado. Solo debería usarse cuando se trabaja la cabina sin Red,
 o al inicio para fijar las propiedades.}
var
  lin: String;
  campos, lineas: TStringDynArray;
  i: Integer;
  it: TCPItemBoleta;
begin
  lineas := Explode(LineEnding, AValue);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  //aquí aseguramos que no hay red
  delete(lin, 1, 1);  //recorta identificador
  campos := Explode(#9, lin);
  if SinRed then begin  //Cuando hay red, esta propiedad se actualiza sola
    cabConex.estadoN  := f2I(campos[1]);
  end;
  HoraPC := f2D(campos[2]);
  if high(campos)>=3 then begin
    //Hay información de campos adicionaleas
    cabCuenta.estadoN := f2I(campos[3]);
    cabCuenta.hor_ini := f2D(campos[4]);
    cabCuenta.tSolic  := f2D(campos[5]);
    cabCuenta.tLibre  := f2B(campos[6]);
    cabCuenta.horGra  := f2B(campos[7]);
    FTransc           := f2I(campos[8]);   //el tiempo transcurrido se lee directamente
    FCosto            := f2N(campos[9]);   //el costo se lee directamente en el campo FCosto
  end else begin
    //No hay información adicional, se asumen valores por defecto
    cabCuenta.estado := EST_NORMAL;
    cabCuenta.hor_ini := trunc(now);  //para que no hay errores en el cálculo
    cabCuenta.tSolic  := 0;
    cabCuenta.tLibre  := false;
    cabCuenta.horGra  := false;
    FTransc           := 0;   //el tiempo transcurrido se lee directamente
    FCosto            := 0;   //el costo se lee directamente en el campo FCosto
  end;
  //Agrega información de boletas
  boleta.ItemClear;    {se pensó en evitar limpiar toda la lista (por eficiencia)
                        cambiando "Count", pero esto dejaba los nodos en NIL }
  for i:=1 to high(lineas) do begin
    lin := lineas[i];
    if trim(lin) = '' then continue;
    //Actualiza
    it := TCPItemBoleta.Create;
    delete(lin, 1, 1);  //quita espacio
    it.CadEstado := lin;
    boleta.ItemAdd(it, false);  //sin calculo, por eficiencia
  end;
  ///////////////// Actualizar
  boleta.Recalcula;
end;
//rutinas de actualización de campos de estado
procedure TCPCabina.ActualizaTranscYCosto;
{Actualiza las variables "FTransc" y "FCosto", usando la hora actual. Este método se debe
 ejecutar antes de leer "Transc", "Costo" o "TranscTol". Se define así, esta función para
 que se ejecute solo una vez y disponer de los valores de tiempo y costo sincronizados}
begin
  FTransc := SecondsBetween(now, cabCuenta.hor_ini); //actualiza FTransc
  //actualiza costo
  if tarif = nil then begin
    FCosto := 0;
    exit;
  end;
  If cabCuenta.horGra Or ((cabCuenta.tSolic = 0) And Not cabCuenta.tlibre) Then
    FCosto := 0
  Else
    FCosto := tarif.CostoAlq(cabCuenta.hor_ini, FTransc);
end;
// Campos de conexión
procedure TCPCabina.SetConConexion(AValue: boolean);
begin
  if SinRed then begin
    //Solo como contenedor. No se debe llamar a cabConex.Conectar o a cabConex.Desconectar
    FConConexion := AValue;
    exit;
  end;
  if FConConexion=AValue then exit;
  if AValue=true then begin  // Se pide iniciar la conexión
    cabConex.Conectar; //Si la conexión ya estaba iniciada, se ignorará
    FConConexion:=true;
  end else begin     // Se pide terminar la conexión.
    cabConex.Desconectar;  // Puede tardar en detener el proceso
    FConConexion:=False;
  end;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCPCabina.EstadoConex: TCabEstadoConex;
begin
  Result := cabConex.estado;
end;
function TCPCabina.EstadoConexN: integer;
begin
  Result := cabConex.estadoN;
end;
function TCPCabina.EstadoConexStr: string;
begin
  Result := cabConex.estadoStr;
end;
function TCPCabina.Conectado: boolean;
begin
  Result := cabConex.estado = cecConectado;
end;
procedure TCPCabina.Desconectar;
begin
  if SinRed then exit;
  cabConex.Desconectar;  // Puede tardar en detener el proceso
end;
//control de la cabina
function TCPCabina.Contando: boolean;
begin
  Result := cabCuenta.estado in [EST_CONTAN, EST_PAUSAD];
end;
function TCPCabina.Detenida: boolean;
begin
  Result := cabCuenta.estado = EST_NORMAL;
end;
procedure TCPCabina.SincTiempo;
//Sincroniza el tiempo con la cabina cliente.
var
  hh, mm, ss: byte;
  bfalt: byte;
begin
  //Usa FTransc, que es la única referencia de tiempo transcurrido
  if (cabCuenta.estado = EST_CONTAN) Or (cabCuenta.estado = EST_PAUSAD) Then begin
      if FTransc > 3600*255 then FTransc := 3600*255 + 59*60 + 59;  //limita si hay exceso
      hh := FTransc div 3600;
      mm := FTransc div 60 mod 60;
      ss := FTransc mod 60;
      bfalt := min((Faltante div 60)+1, 255);       //faltante en minutos
  end else begin
      hh := 0; mm := 0; ss := 0; bfalt := 0;
  end;
  cabConex.TCP_envComando(C_MOS_TPO, 256*hh + mm, 256* ss + bfalt);
end;
procedure TCPCabina.SincBloqueo;
{Sicroniza el bloqueo de la pantalla de la PC cliente, con el estado de la cabina.}
begin
  if (cabCuenta.estado = EST_CONTAN) Or (cabCuenta.estado = EST_PAUSAD) Then begin
    cabConex.TCP_envComando(C_DESB_PC, 0, 0);  //desbloques si hay conexión
  end else begin
    cabConex.TCP_envComando(C_BLOQ_PC, 0, 0);   //bloquea, si hay conexión
  end;
end;
procedure TCPCabina.TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string='');
{Rutina general, para enviar comando a una cabina cliente}
begin
  cabConex.TCP_envComando(comando, ParamX, ParamY, cad);    //desbloquea, si hay conexión
end;
procedure TCPCabina.InicConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
begin
  if Contando then
    exit;   //No se puede iniciar cuenta en este Estado
  //If conectando Then Exit Sub     'Protege para evitar múltiples eventos
  //conectando = True
  cabCuenta.hor_ini:=Now;
  cabCuenta.tSolic:=tSolic0;
  cabCuenta.tLibre:=tLibre0;
  cabCuenta.horGra:=horGra0;
  cabCuenta.estado:=EST_CONTAN;
  ActualizaTranscYCosto;  //para inciar FTransc y FCosto
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
  cabConex.TCP_envComando(C_DESB_PC, 0, 0);    //desbloquea, si hay conexión
end;
procedure TCPCabina.ModifConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
begin
  if not Contando then
    exit;   //No se puede modificar, porque no hay cuenta
  cabCuenta.tSolic:=tSolic0;
  cabCuenta.tLibre:=tLibre0;
  cabCuenta.horGra:=horGra0;
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
end;
procedure TCPCabina.DetenConteo;
begin
  if not Contando then
    exit;   //No se puede detener cuenta en este Estado
  //cabCuenta.hor_ini:=Now;
  cabCuenta.tSolic:=0;
  cabCuenta.tLibre:=false;
  cabCuenta.horGra:=false;
  cabCuenta.estado:=EST_NORMAL;
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
  cabConex.TCP_envComando(C_BLOQ_PC, 0, 0);    //bloquea, si hay conexión
  if OnDetenConteo<>nil then OnDetenConteo(self);
end;
procedure TCPCabina.PonerManten;
{Pone a la cabina en mantenimiento. }
begin
  if cabCuenta.estado = EST_MANTEN then
    exit;  //ya está en mantenimiento
  //pone a mantenimiento
  if (cabCuenta.estado = EST_CONTAN) Or (cabCuenta.estado = EST_PAUSAD) then begin
    msjError := 'Debe detener primero la cuenta antes de pasar a mantenimiento';
    exit;
  end else begin
    cabCuenta.estado := EST_MANTEN;
    //Se considera un cambio de Estado
    if OnCambiaEstado<>nil then OnCambiaEstado();
    //cabConex.TCP_envComando(C_BLOQ_PC, 0, 0);    //bloquea, si hay conexión
    if OnLogInfo<>nil then OnLogInfo(self, 'Pone cabina: ' + self.Nombre + ' a mantenimiento.');
  end;
end;
procedure TCPCabina.SacarManten;
{Saca a la cabina del estado de mantenimiento}
begin
  if cabCuenta.estado <> EST_MANTEN then
    exit;
  //Está en mantenimiento
  cabCuenta.estado := EST_NORMAL;
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
end;
//constructor y destructor
constructor TCPCabina.Create(nombre0: string; ip0: string);
begin
  inherited Create;
  FNombre := nombre0;
  cabCuenta:= TCabCuenta.Create;  //Estado de cabina
  cabConex := TCabConexion.Create(ip0);  //conexión
  cabConex.OnCambiaEstado:=@cabCambiaEstadoConex;
  cabConex.OnTramaLista:=@cabConexTramaLista;
  cabConex.OnRegMensaje:=@cabConexRegMensaje;
  //cabConex
  cabCuenta.estado := EST_NORMAL;  //inicia en este estado
  ConConexion := false;
  SinRed := false;
end;
constructor TCPCabina.CreateSinRed;
{Crea al objeto para usarlo solo como contenedor de propiedades.}
begin
  Create('','');
  SinRed := true;
end;
destructor TCPCabina.Destroy;
begin
  cabConex.Destroy;
  cabCuenta.Destroy;
  inherited Destroy;
end;
{ TCPGrupoCabinas }
procedure TCPGrupoCabinas.timer1Timer(Sender: TObject);
{Temporiza a las cabinas para que actualicen sus porpiedades internas.
Se ejecuta cada segundo.}
var
  cab : TCPFacturable;
begin
  if self.ModoCopia then exit;  //no se debe contar en este modo
  for cab in items do begin
    TCPCabina(cab).Contar1seg;
  end;
end;
procedure TCPGrupoCabinas.cab_CambiaPropied;
begin
  //dispara evento
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCPGrupoCabinas.cab_TramaLista(cab: TCPCabina; tram: TCPTrama;
  tramaLocal: boolean);
begin
  if OnTramaLista<>nil then OnTramaLista(cab, tram, tramaLocal);
end;
procedure TCPGrupoCabinas.cab_RegMensaje(NomCab: string; msj: string);
begin
  //dispara evento
  if OnRegMensaje<>nil then OnRegMensaje(NomCab, msj);
end;
procedure TCPGrupoCabinas.cab_DetenConteo(cab: TCPCabina);
{Se ha detenido la cuenta de la cabina.}
begin
  if OnDetenConteo<>nil then OnDetenConteo(cab);
end;
procedure TCPGrupoCabinas.cab_LogInfo(cab: TCPCabina; msj: string);
begin
  if OnLogInfo<>nil then OnLogInfo(cab, msj);
end;
function TCPGrupoCabinas.Agregar(nombre0: string; ip0: string): TCPCabina;
var
  cab: TCPCabina;
begin
  if ModoCopia then begin  //Si estamos en modo copia
    //creamos la cabina sin conexión
    cab := TCPCabina.CreateSinRed;
    cab.Nombre := nombre0;
    cab.IP := ip0;
  end else begin  //Se crean normalmente
    cab := TCPCabina.Create(nombre0, ip0);
  end;
  cab.OnCambiaPropied:=@cab_CambiaPropied;
  cab.OnTramaLista :=@cab_TramaLista;
  cab.OnRegMensaje :=@cab_RegMensaje;
  cab.OnDetenConteo:=@cab_DetenConteo;
  cab.OnLogInfo    :=@cab_LogInfo;
  cab.Grupo := self;
  cab.tarif := tarif;
  items.Add(cab);
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := cab;
end;
function TCPGrupoCabinas.Eliminar(nombre0: string): boolean;
{Elimina una cabina, dado el nombre. Si no tiene éxito devuelve FALSE}
var
  cab: TCPCabina;
begin
  cab := CabPorNombre(nombre0);
  if cab = nil then exit(false);
  items.Remove(cab);  //puede tomar tiempo, por la destrucción del hilo
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := true;
end;
procedure TCPGrupoCabinas.Conectar;
{Inicia la conexión de todas las cabinas}
var
  cab : TCPFacturable;
begin
  for cab in items do begin
    TCPCabina(cab).ConConexion:=true;
  end;
end;
function TCPGrupoCabinas.GetCadPropied: string;
var
  c : TCPFacturable;
  primer: Boolean;
begin
  Result := '';
  primer := true;
  for c in items do begin
    if primer then begin
      Result := TCPCabina(c).CadPropied;
      primer := false;
    end else begin
      Result := Result + LineEnding + TCPCabina(c).CadPropied ;
    end;
  end;
end;
procedure TCPGrupoCabinas.SetCadPropied(AValue: string);
var
  lineas: TStringList;
  cab: TCPCabina;
  lin: String;
begin
  lineas := TStringList.Create;
  lineas.Text := AValue;
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    cab := Agregar('','');
    cab.CadPropied := lin;
  end;
  lineas.Destroy;
end;
function TCPGrupoCabinas.GetCadEstado: string;
{Devuelve el estado de las cabinas creadas, en una cadena. La idea es que esta información
 se lea frecuéntemente, porque contiene propiedades que cambian frecuéntemente. }
var
  c : TCPFacturable;
begin
  //Delimitador inicial y propiedades de objeto.
  Result := '<' + I2f(ord(self.tipo)) + #9 + Nombre + LineEnding;
  for c in items do begin
    Result += c.CadEstado + LineEnding;
  end;
  Result += '>' + LineEnding;  //delimitador final.
end;
procedure TCPGrupoCabinas.SetCadEstado(AValue: string);
{Fija el estado de las cabinas, a partir de una lista de cadenas}
var
  nomb, cad: string;
  cab: TCPCabina;
  car: char;
begin
  decod.Inic(AValue);
  while decod.Extraer(car, nomb, cad) do begin
    if cad = '' then continue;
    cab := CabPorNombre(nomb);
    if cab<>nil then cab.SetCadEstado(cad);
  end;
end;
procedure TCPGrupoCabinas.SetModoCopia(AValue: boolean);
{Fija el modo de las cabina. El ModoCopia, debería fijarse antes de crear a los objetos,
pero se implementa este método por si se hace después, cuando ya hay ítems.}
var
  c : TCPFacturable;
begin
  inherited SetModoCopia(AValue);
  for c in items do begin
    TCPCabina(c).SinRed := ModoCopia;
  end;
end;
function TCPGrupoCabinas.ListaCabinas: string;
{Devuelve la lista de cabinas creadas. La idea es leer con poca frecuencia, esta
 información ya que no es muy cambiante. }
var
  c : TCPFacturable;
begin
  Result := '';
  for c in items do begin
    Result += TCPCabina(c).CadPropied + LineEnding;
  end;
end;
function TCPGrupoCabinas.CabPorNombre(nom: string): TCPCabina;
{Devuelve la referencia a una cabina, ubicándola por su nombre. Si no la enuentra
 devuelve NIL.}
var
  c : TCPFacturable;
begin
  for c in items do begin
    if TCPCabina(c).Nombre = nom then exit(TCPCabina(c));
  end;
  exit(nil);
end;
function TCPGrupoCabinas.Toleran: TDateTime;
begin
  Result := tarif.toler;
end;
//operaciones con cabinas
procedure TCPGrupoCabinas.TCP_envComando(nom: string; comando: TCPTipCom; ParamX,
  ParamY: word; cad: string = '');
var
  cab: TCPCabina;
begin
  cab := CabPorNombre(nom);
  if cab = nil then exit;
  cab.TCP_envComando(comando, ParamX, ParamY, cad);
end;
//constructor y destructor
procedure TCPGrupoCabinas.MuestraConexionCabina;  //para depuración
var
  c : TCPFacturable;
begin
  for c in items do begin
    debugln('  Nomb:' + c.Nombre + ' SinRed:' + B2f(TCPCabina(c).SinRed));
  end;
end;
constructor TCPGrupoCabinas.Create(nombre0: string);
begin
  inherited Create(nombre0, tgfCabinas);
  //Se incluye un objeto TGrupoTarAlquiler para la tarificación
  GrupTarAlquiler := TGrupoTarAlquiler.Create;
  if GrupTarAlquiler.items.Count=0 then begin
    //agrega una tarifa de alquiler por defecto
//    frmAdminTarCab.IniciarPorDefecto;  { TODO : Ver si es necesario }
//    frmAdminTarCab.BitAplicarClick(nil);
  end;
  tarif := TCPTarifCabinas.Create(GrupTarAlquiler);
  timer1 := TTimer.Create(nil);
  decod := TCPDecodCadEstado.Create;
  timer1.Interval:=1000;
  timer1.OnTimer:=@timer1Timer;
  CategCabi := 'COUNTER';
end;
destructor TCPGrupoCabinas.Destroy;
var
  c : TCPFacturable;
begin
  OnCambiaPropied:= nil;  //para evitar refrescar controles en este estado
  OnTramaLista   := nil;   { TODO : Tal vez estas rutinas de limpieza se deban hacer en directamente en TCPCabina }
  OnRegMensaje   := nil;
  OnDetenConteo  := nil;
  OnLogInfo      := nil;
  decod.Destroy;
  timer1.Destroy;
  tarif.Destroy;
  {Envía la señal de desconexión a todas las cabinas de golpe, para que la destrucción
  de la lista, no se haga muy lenta}
  for c in items do begin
    TCPCabina(c).Desconectar;
  end;
  GrupTarAlquiler.Destroy;
  inherited Destroy;  {Aquí se hace items.Destroy, que puede demorar por los hilos}
end;

{ TCPDecodCadEstado }
procedure TCPDecodCadEstado.Inic(const cad: string);
{Inicia la exploración de la cadenas}
begin
  lineas.Text := cad;
  pos1 := 0;  //posición inicial alta
  pos2 := -1;
  if lineas.Count<2 then begin
    MsgErr('Error en formato de cadena de estado: ' + cad);
    exit;
  end;
  lineas.Delete(0);              //elimina la línea: "<0,   Cabinas"
  lineas.Delete(lineas.Count-1); //elimina la línea: ">"
end;
function TCPDecodCadEstado.ExtraerNombre(const lin: string): string;
var
  p: integer;
begin
  p := pos(#9, lin);  //busca delimitador
  if p=0 then begin
    //no hay delimitador, toma todo
    Result := lin;
  end else begin
    Result := copy(lin, 2, p-2);
  end;
end;
function TCPDecodCadEstado.Extraer(var car: char; var nombre, cadena: string): boolean;
{Extrae una subcadena (de una o varias líneas) de la cadena de estado, que corresponden a
los datos de una cabina). Si no encuentra más datos, devuelve FALSE}
var
  linea: String;
begin
  if lineas.Count=0 then exit(false);
  cadena := '';
  while (lineas.Count>0) do begin
    linea := lineas[0];
//    res := TCPGrupoFacturable.ExtraerEstado(lest, cad, nombre, tipo);
    if trim(linea) = '' then begin
      lineas.Delete(0);  //elimina línea
      continue;  //filtra líneas vacías
    end;
    if cadena = '' then begin
      //Primera línea.
      car := linea[1];   //Aprovecha para capturar el caracter identificador.
      nombre := ExtraerNombre(linea);  //Aprovecha para capturar el nombre.
      cadena := linea;   //Copia la primera línea
    end else begin
      //Líneas adicionales
      cadena := cadena + LineEnding + linea;
    end;
    lineas.Delete(0);  //elimina línea leída
    if (lineas.Count>0) and  //hay más líneas
       (lineas[0][1]<>' ') then begin //y sigue una línea de datos
      break;
    end;
  end;
  exit(true);   //sale, pero hay mas datos
end;
constructor TCPDecodCadEstado.Create;
begin
  lineas := TStringList.Create;
end;
destructor TCPDecodCadEstado.Destroy;
begin
  lineas.Destroy;
  inherited Destroy;
end;

end.

