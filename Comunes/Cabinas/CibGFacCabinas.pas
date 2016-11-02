{Unidad que define a las clases principales:
 * TCibFacCabina -> Facturable que representa a una cabina de internet
 * TCibGFacCabinas -> Grupo facturable que agrupa a las cabinas.
Estos objeto se usan para controlar a las cabinas de Internet.
Adicionalmente la clase TCibGFacCabinas, puede crear dinámicamente lso siguientes
formularios:
 * Un Formulario para configuración de tarifas de alquiler de cabinas.
 * Un Formulario de administración de cabinas (agregar, eliminar o modificar)
 * Varios Formualarios para mostrar los mensajes de conexión de red de las cabinas.
}
unit CibGFacCabinas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, types, dateutils, math, fgl, LCLProc, ExtCtrls, Forms,
  Menus, MisUtils, CibTramas, CibFacturables, CibCabinaBase, CibCabinaTarifas,
  FormVisorMsjRed, CibUtils, FormAdminTarCab, FormAdminCabinas, FormFijTiempo;
const //Acciones
  C_INI_CTAPC = 1;  //Solicita iniciar la cuenta de una PC
  C_DET_CTAPC = 2;  //Solicita detener la cuenta de una PC
  C_MOD_CTAPC = 3;  //Solicita modificar la cuenta de una PC
  C_PON_MANTN = 4;  //Solicita poner en mantenimiento a una PC

type
  TCibFacCabina = class;
  TCibGFacCabinas = class;

  //TEvCabCambiaEstado = procedure(nuevoEstado: TCabEstadoConex) of object;
  {El evento TEvCabTramaLista, se define con el primer parámetro como TCibFac, en lugar
  de TCibFacCabina, porque el manejador de este evento se usará como rutina general para
  el procesamiento de la mayoría de comandos de la aplicación.}
  TEvCabTramaLista = procedure(nomOForig, nomGOForig: string; tram: TCPTrama;
                               tramaLocal: boolean) of object;
  TEvCabRegMensaje = procedure(NomCab: string; msj: string) of object;
  TEvCabAccionCab = procedure(cab: TCibFacCabina) of object;
//  TEvCabLogIBol = procedure(cab: TCPCabina; it: TCPItemBoleta; msj: string) of object;

  { TCibFacCabina }
  {Define al objeto Cabina de Ciberplex}
  TCibFacCabina = class(TCibFac)
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
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
    procedure SetNombrePC(AValue: string);
  public  //Campos de propiedades
    property NombrePC : string read FNombrePC write SetNombrePC;  //Nombre de Red que tiene la PC cliente
    property IP: string read GetIP write SetIP;
    property Mac: string read cabConex.mac write SetMac;
    property ConConexion: boolean read FConConexion write SetConConexion;
  public  //campos diversos
    OnTramaLista  : TEvCabTramaLista;   //indica que hay una trama lista esperando
    OnRegMensaje  : TEvCabRegMensaje;   //indica que se ha generado un mensaje de la conexión
    //OnGrabBoleta  : TEvCabAccionCab;    //Indica que se ha grabado la boleta
    function tarif: TCPTarifCabinas;  {Referencia a la Tarifa }
    function RegVenta(usu: string): string; override; //línea para registro de venta
    procedure Contar1seg;      //usado para temporización
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
    function CadActivacion(tSolic0: TDateTime; tLibre0, horGra0: boolean): string;
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

  TForm_list = specialize TFPGObjectList<TfrmVisorMsjRed>;
  { TCibGFacCabinas }
  { Clase que define al conjunto de las PC clientes. Se juntan todas las
  cabinas en un objeto único, porque la arquitectura se define para centralizar el
  control en un solo objeto, con la posibilidad de tener múltiples interfaces
  (pantallas) de la aplicación. }
  TCibGFacCabinas = class(TCibGFac)
    procedure timer1Timer(Sender: TObject);
  private
    timer1 : TTimer;
    ventMsjes: TForm_list;     //Ventanas de mensajes de red
    frmTiempos: TfrmFijTiempo;  //Formulario para fijar tiempos
    procedure cab_RegMensaje(NomCab: string; msj: string);
    procedure cab_TramaLista(nomOForig, nomGOForig: string; tram: TCPTrama;
      tramaLocal: boolean);
  public  //Eventos.
    {EjecAccion que se pueden disparar automáticamente. Sin intervención del usuario}
    OnTramaLista   : TEvCabTramaLista; //indica que hay una trama lista esperando
    OnRegMensaje   : TEvCabRegMensaje; //indica que se ha generado un mensaje de la conexión
  protected //Getters and Setters
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public
    tarif: TCPTarifCabinas; //tarifas de cabina
    GrupTarAlquiler: TGrupoTarAlquiler;  //Grupo de tarifas de alquiler
    frmAdminTar: TfrmAdminTarCab;
    frmAdminCabs: TfrmAdminCabinas;
    function Agregar(nombre0: string; ip0: string): TCibFacCabina;
    function Eliminar(nombre0: string): boolean;
    procedure Conectar;
    function ListaCabinas: string;
    function CabPorNombre(nom: string): TCibFacCabina;  { TODO : ¿Será necesario, si ya existe ItemPorNombre en el ancestro? }
    function Toleran: TDateTime;   //acceso a la tolerancia
    function BuscarVisorMensajes(nomCab: string; CrearNuevo: boolean=false
      ): TfrmVisorMsjRed;
    procedure MuestraConexionCabina;
  public  //Operaciones con cabinas
    procedure TCP_envComando(nom: string; comando: TCPTipCom; ParamX, ParamY: word;
      cad: string='');
  public  //Campos para manejo de acciones
    procedure EjecAccion(tram: TCPTrama); override;
    procedure MenuAcciones(MenuPopup: TPopupMenu; NomFac: string); override;
    procedure mnInicCuenta(Sender: TObject);
    procedure mnModifCuenta(Sender: TObject);
    procedure mnDetenCuenta(Sender: TObject);
    procedure mnPonerManten(Sender: TObject);
  public  //Constructor y destructor
    constructor Create(nombre0: string; ModoCopia0: boolean);
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
{ TCibFacCabina }
procedure TCibFacCabina.cabCambiaEstadoConex(nuevoEstado: TCabEstadoConex);
{Evento de cambio de estado de la conexión}
begin
  //Se considera un cambio de estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
end;
procedure TCibFacCabina.cabConexTramaLista(NomCab: string; tram: TCPTrama);
begin
  if OnTramaLista<>nil then OnTramaLista(Nombre, Grupo.Nombre , tram, false);
end;
procedure TCibFacCabina.cabConexRegMensaje(NomCab: string; msj: string);
begin
  if OnRegMensaje<>nil then OnRegMensaje(Nombre, msj);
end;
function TCibFacCabina.GetIP: string;
begin
  Result := cabConex.IP;
end;
procedure TCibFacCabina.SetIP(AValue: string);
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
procedure TCibFacCabina.SetMac(AValue: string);
begin
  if cabConex.mac = AValue then exit;
  cabConex.mac := AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCibFacCabina.GetCadPropied: string;
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
procedure TCibFacCabina.SetCadPropied(AValue: string);
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
procedure TCibFacCabina.SetNombrePC(AValue: string);
begin
  if FNombrePC=AValue then Exit;
  FNombrePC:=AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCibFacCabina.RegVenta(usu: string): string;
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
  Result := usu + #9 + 'INT01' + #9 +
           'INTERNET' + #9 +
           IntToStr(TranscSegTol) + #9 +
           N2f(FCosto) + #9 + N2f(FCosto) + #9 +
           D2f(cabCuenta.hor_ini) + #9 + categ + #9 +
           I2f(Round(cabCuenta.tSolic * 24 * 60)) + #9 +
           'ALQUILER DE CABINA' + #9 + D2f(FTransc) + #9 +
           Nombre + #9 + estConex + #9 +
           I2f(PausadS) + #9 + D2f(TranscSegTol) + #9 +
           D2f(cabCuenta.tSolic) + #9 + Grupo.CategVenta +
           #9 + #9 + #9
end;
function TCibFacCabina.VerCorteAutomatico: boolean;
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
function TCibFacCabina.tarif: TCPTarifCabinas;
begin
  Result := TCibGFacCabinas(Grupo).tarif;
end;
procedure TCibFacCabina.Contar1seg;
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
function TCibFacCabina.Faltante: integer;
//Tiempo faltante en segundos
begin
  Result := cabCuenta.tSolicSeg - FTransc;
  if Result<0 then Result := 0;
end;
function TCibFacCabina.EstadoCtaStr: string;
begin
  Result := cabCuenta.estadoStr
end;
function TCibFacCabina.tSolicSeg: integer;
begin
  Result := cabCuenta.tSolicSeg;
end;
function TCibFacCabina.tSolicMin: integer;
begin
  Result := cabCuenta.tSolicSeg div 60;
end;
function TCibFacCabina.TranscDat: TTime;
begin
  Result := FTransc / SecsPerDay;
//  EncodeTime(0,0,FTransc,0);
end;
function TCibFacCabina.TranscSegTol: integer;
{Tiempo transcurrido, considerando la Tolerancia.}
begin
  if tarif = nil then exit(0);
  Result := FTransc - tarif.toler;
  If Result < 0 Then Result := 0;
end;
function TCibFacCabina.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := '.' + {Caracter identificador de facturable, se omite la coma por espacio.}
         Nombre + #9 +    {el nombre es obligatorio para identificar unívocamente a la cabina}
         I2f(cabConex.estadoN)+ #9 + {se coloca primero el Estado de la conexión, porque
             es el campo que siempre debe actualizarse, cuando hay conexión remota activada}
         T2f(HoraPC);  //Este campo no tiene significado si no hay conexión
  if cabCuenta.estado <> EST_NORMAL then begin
    // En el estado EST_NORMAL, no es necesario enviar los demás campos
    Result += #9 +
         I2f(cabCuenta.estadoN) + #9 +
         T2f(cabCuenta.hor_ini) + #9 +
         T2f(cabCuenta.tSolic) + #9 +
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
procedure TCibFacCabina.SetCadEstado(AValue: string);
{Fija los campos de estado. Solo debería usarse cuando se trabaja la cabina sin Red,
 o al inicio para fijar las propiedades.}
var
  lin: String;
  campos, lineas: TStringDynArray;
begin
  lineas := Explode(LineEnding, AValue);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  //aquí aseguramos que no hay red
  delete(lin, 1, 1);  //recorta identificador
  campos := Explode(#9, lin);
  if SinRed then begin  //Cuando hay red, esta propiedad se actualiza sola
    cabConex.estadoN  := f2I(campos[1]);
  end;
  HoraPC := f2T(campos[2]);
  if high(campos)>=3 then begin
    //Hay información de campos adicionaleas
    cabCuenta.estadoN := f2I(campos[3]);
    cabCuenta.hor_ini := f2T(campos[4]);
    cabCuenta.tSolic  := f2T(campos[5]);
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
  LeerEstadoBoleta(lineas);
end;
//rutinas de actualización de campos de estado
procedure TCibFacCabina.ActualizaTranscYCosto;
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
procedure TCibFacCabina.SetConConexion(AValue: boolean);
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
function TCibFacCabina.EstadoConex: TCabEstadoConex;
begin
  Result := cabConex.estado;
end;
function TCibFacCabina.EstadoConexN: integer;
begin
  Result := cabConex.estadoN;
end;
function TCibFacCabina.EstadoConexStr: string;
begin
  Result := cabConex.estadoStr;
end;
function TCibFacCabina.Conectado: boolean;
begin
  Result := cabConex.estado = cecConectado;
end;
procedure TCibFacCabina.Desconectar;
begin
  if SinRed then exit;
  cabConex.Desconectar;  // Puede tardar en detener el proceso
end;
//control de la cabina
function TCibFacCabina.Contando: boolean;
begin
  Result := cabCuenta.estado in [EST_CONTAN, EST_PAUSAD];
end;
function TCibFacCabina.Detenida: boolean;
begin
  Result := cabCuenta.estado = EST_NORMAL;
end;
procedure TCibFacCabina.SincTiempo;
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
procedure TCibFacCabina.SincBloqueo;
{Sicroniza el bloqueo de la pantalla de la PC cliente, con el estado de la cabina.}
begin
  if (cabCuenta.estado = EST_CONTAN) Or (cabCuenta.estado = EST_PAUSAD) Then begin
    cabConex.TCP_envComando(C_DESB_PC, 0, 0);  //desbloques si hay conexión
  end else begin
    cabConex.TCP_envComando(C_BLOQ_PC, 0, 0);   //bloquea, si hay conexión
  end;
end;
procedure TCibFacCabina.TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string='');
{Rutina general, para enviar comando a una cabina cliente}
begin
  cabConex.TCP_envComando(comando, ParamX, ParamY, cad);    //desbloquea, si hay conexión
end;
function TCibFacCabina.CadActivacion(tSolic0: TDateTime; tLibre0,
  horGra0: boolean): string;
{Devuelve cadena con información de los campos usuales, para la activación o
 desactivación de la cabina.}
begin
  Result := Grupo.Nombre + #9 + Nombre + #9 +
            D2f(tSolic0)+ #9 +
            B2f(tLibre0)+ #9 +
            B2f(horGra0);
end;
procedure TCibFacCabina.InicConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
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
procedure TCibFacCabina.ModifConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
begin
  if not Contando then
    exit;   //No se puede modificar, porque no hay cuenta
  cabCuenta.tSolic:=tSolic0;
  cabCuenta.tLibre:=tLibre0;
  cabCuenta.horGra:=horGra0;
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
end;
procedure TCibFacCabina.DetenConteo;
var
  nser: integer;
  r: TCibItemBoleta;
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

  //Registra la venta en el archivo de registro
  if horGra then begin
    nser := OnLogVenta(IDE_INT_GRA, RegVenta('XXX'), Costo);
  end else begin
    nser := OnLogVenta(IDE_INT_NOR, RegVenta('XXX'), Costo);
  end;
  //Si hubo error, ya se mostró en OnLogVenta()

  //agrega item a boleta
  r := TCibItemBoleta.Create;   //crea elemento
  r.vser := nser;
  r.Cant := 1;
  r.pUnit := Costo;
  r.subtot := Costo;
  r.descr := 'Alquiler PC: ' + IntToStr(tSolicMin) + 'm(' +
             TimeToStr(TranscDat) + ')';
  r.cat := Grupo.CategVenta;
  r.subcat := 'INTERNET';
  r.vfec := date + Time;
  r.estado := IT_EST_NORMAL;
  r.fragmen := 0;
  r.conStk := False;     //No se descuenta stock
  Boleta.VentaItem(r, False);
end;
procedure TCibFacCabina.PonerManten;
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
    if OnLogInfo<>nil then OnLogInfo('Pone cabina: ' + Nombre + ' a mantenimiento.');
  end;
end;
procedure TCibFacCabina.SacarManten;
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
constructor TCibFacCabina.Create(nombre0: string; ip0: string);
begin
  inherited Create;
  tipo := ctfCabinas;  //se identifica
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
constructor TCibFacCabina.CreateSinRed;
{Crea al objeto para usarlo solo como contenedor de propiedades.}
begin
  Create('','');
  SinRed := true;
end;
destructor TCibFacCabina.Destroy;
begin
  cabConex.Destroy;
  cabCuenta.Destroy;
  inherited Destroy;
end;
{ TCibGFacCabinas }
procedure TCibGFacCabinas.timer1Timer(Sender: TObject);
{Temporiza a las cabinas para que actualicen sus porpiedades internas.
Se ejecuta cada segundo.}
var
  cab : TCibFac;
begin
  if self.ModoCopia then exit;  //no se debe contar en este modo
  for cab in items do begin
    TCibFacCabina(cab).Contar1seg;
  end;
  //Se aprovecha para actualizar la ventana de administarción
  if (frmAdminCabs<>nil) and frmAdminCabs.Visible then
    frmAdminCabs.RefrescarGrilla;  //actualiza
end;
procedure TCibGFacCabinas.cab_TramaLista(nomOForig, nomGOForig: string; tram: TCPTrama;
  tramaLocal: boolean);
begin
  if OnTramaLista<>nil then OnTramaLista(nomOForig, nomGOForig, tram, tramaLocal);
end;
procedure TCibGFacCabinas.cab_RegMensaje(NomCab: string; msj: string);
var
  frm: TfrmVisorMsjRed;
begin
  //dispara evento
  if OnRegMensaje<>nil then OnRegMensaje(NomCab, msj);
  //pasa mensaje a Visor de mensaje, si está abierto
  frm := BuscarVisorMensajes(NomCab);  //Ve si hay un formulario de mensajes para esta cabina
  if frm<>nil then frm.PonerMsje(msj);  //Envía mensaje a su formaulario
end;
function TCibGFacCabinas.Agregar(nombre0: string; ip0: string): TCibFacCabina;
var
  cab: TCibFacCabina;
begin
  if ModoCopia then begin  //Si estamos en modo copia
    //creamos la cabina sin conexión
    cab := TCibFacCabina.CreateSinRed;
    cab.Nombre := nombre0;
    cab.IP := ip0;
  end else begin  //Se crean normalmente
    cab := TCibFacCabina.Create(nombre0, ip0);
  end;
  cab.OnTramaLista :=@cab_TramaLista;
  cab.OnRegMensaje :=@cab_RegMensaje;
  AgregarItem(cab);   //aquí se configuran algunos  eventos
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := cab;
end;
function TCibGFacCabinas.Eliminar(nombre0: string): boolean;
{Elimina una cabina, dado el nombre. Si no tiene éxito devuelve FALSE}
var
  cab: TCibFacCabina;
begin
  cab := CabPorNombre(nombre0);
  if cab = nil then exit(false);
  items.Remove(cab);  //puede tomar tiempo, por la destrucción del hilo
  if OnCambiaPropied<>nil then begin
    OnCambiaPropied;
  end;
  Result := true;
end;
procedure TCibGFacCabinas.Conectar;
{Inicia la conexión de todas las cabinas}
var
  cab : TCibFac;
begin
  for cab in items do begin
    TCibFacCabina(cab).ConConexion:=true;
  end;
end;
function TCibGFacCabinas.GetCadPropied: string;
var
  c : TCibFac;
begin
  //Información del grupo en la primera línea
  Result := Nombre + #9 + CategVenta + #9 + N2f(Fx) + #9 + N2f(Fy) + #9 +
            #9 ;
  //Información de las cabinas en las demás líneas
  for c in items do begin
    Result := Result + LineEnding + c.CadPropied ;
  end;
end;
procedure TCibGFacCabinas.SetCadPropied(AValue: string);
var
  lineas: TStringList;
  cab: TCibFacCabina;
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
  //Procesa líneas con información de las cabinas
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    cab := Agregar('','');
    cab.CadPropied := lin;
  end;
  lineas.Destroy;
end;
function TCibGFacCabinas.ListaCabinas: string;
{Devuelve la lista de cabinas creadas. La idea es leer con poca frecuencia, esta
 información ya que no es muy cambiante. }
var
  c : TCibFac;
begin
  Result := '';
  for c in items do begin
    Result += TCibFacCabina(c).CadPropied + LineEnding;
  end;
end;
function TCibGFacCabinas.CabPorNombre(nom: string): TCibFacCabina;
{Devuelve la referencia a una cabina, ubicándola por su nombre. Si no la enuentra
 devuelve NIL.}
var
  c : TCibFac;
begin
  for c in items do begin
    if TCibFacCabina(c).Nombre = nom then exit(TCibFacCabina(c));
  end;
  exit(nil);
end;
function TCibGFacCabinas.Toleran: TDateTime;
begin
  Result := tarif.toler;
end;
function TCibGFacCabinas.BuscarVisorMensajes(nomCab: string; CrearNuevo: boolean = false): TfrmVisorMsjRed;
{Busca si existe un formulario de tipo "TfrmVisorMsjRed", que haya sido crreado para
un nombre de cabina en especial. }
var
  frm: TfrmVisorMsjRed;
begin
  for frm in ventMsjes do begin
    if frm.nomCab = nomCab then begin
      //Encontró
      exit(frm);   //devuelve refrecnia
    end;
  end;
  //No encontró
  if CrearNuevo then begin
    //debugln('Creando nuevo formulario.');
    Result := TfrmVisorMsjRed.Create(nil);
    ventMsjes.Add(Result);  //El formulario será destruido con la lista
  end else begin
    Result := nil;
  end;
end;
procedure TCibGFacCabinas.MuestraConexionCabina;  //para depuración
var
  c : TCibFac;
begin
  for c in items do begin
    debugln('  Nomb:' + c.Nombre + ' SinRed:' + B2f(TCibFacCabina(c).SinRed));
  end;
end;
//operaciones con cabinas
procedure TCibGFacCabinas.TCP_envComando(nom: string; comando: TCPTipCom; ParamX,
  ParamY: word; cad: string = '');
var
  cab: TCibFacCabina;
begin
  cab := CabPorNombre(nom);
  if cab = nil then exit;
  cab.TCP_envComando(comando, ParamX, ParamY, cad);
end;
procedure TCibGFacCabinas.EjecAccion(tram: TCPTrama);
var
  traDat, nom: String;
  facDest: TCibFac;
  Err, tLibre0, horGra0: boolean;
  cab: TCibFacCabina;
  campos: TStringDynArray;
  tSolic0: TDateTime;
begin
debugln('Acción solicitada a GFacCabinas:' + tram.traDat);
  traDat := tram.traDat;  //crea copia para modificar
  ExtraerHasta(traDat, #9, Err);  //Extrae nombre de grupo
  nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto
  facDest := ItemPorNombre(nom);
  if facDest=nil then exit;
  cab := TCibFacCabina(facDest);
  case tram.posX of  //Se usa el parámetro para ver la acción
  C_INI_CTAPC: begin   //Se pide iniciar la cuenta de una PC
    campos := Explode(#9, traDat);
    tSolic0 := f2D(campos[0]);
    tLibre0 := f2B(campos[1]);
    horGra0 := f2B(campos[2]);
    cab.InicConteo(tSolic0, tLibre0, horGra0);
    end;
  C_MOD_CTAPC: begin   //Se pide modificar la cuenta de una PC
    campos := Explode(#9, traDat);
    tSolic0 := f2D(campos[0]);
    tLibre0 := f2B(campos[1]);
    horGra0 := f2B(campos[2]);
    cab.ModifConteo(tSolic0, tLibre0, horGra0);
    end;
  C_DET_CTAPC: begin  //Se pide detener la cuenta de las PC
    cab.DetenConteo;
    end;
  C_PON_MANTN: begin  //Se pide detener la cuenta de las PC
    cab.PonerManten;
    end;
  end;
end;
procedure TCibGFacCabinas.MenuAcciones(MenuPopup: TPopupMenu; NomFac: string);
var
  mn: TMenuItem;
begin
  facSelec := ItemPorNombre(NomFac);  //Busca facturable seleccionado en el modelo y lo guarda.
  if facSelec=nil then exit;
  mn := MenuAccion('Poner en &Mantenimiento',@mnPonerManten);
  MenuPopup.Items.Insert(0, mn);  //Agrega al inicio
  mn := MenuAccion('&Detener Cuenta',@mnDetenCuenta);
  MenuPopup.Items.Insert(0, mn);  //Agrega al inicio
  mn := MenuAccion('&Modif. Tiempo',@mnModifCuenta);
  MenuPopup.Items.Insert(0, mn);  //Agrega al inicio
  mn := MenuAccion('&Iniciar Cuenta',@mnInicCuenta);
  MenuPopup.Items.Insert(0, mn);  //Agrega al inicio
end;
procedure TCibGFacCabinas.mnInicCuenta(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(facSelec);
  if cab.EstadoCta = EST_MANTEN then begin
    if MsgYesNo('¿Sacar cabina de mantenimiento?') <> 1 then exit;
  end else if not cab.Detenida then begin
    msgExc('No se puede iniciar una cuenta en esta cabina.');
    exit;
  end;
  frmTiempos.MostrarIni(cab);  //modal
  if frmTiempos.cancelo then exit;  //canceló
  if OnSolicEjecAcc<>nil then  //ejecuta evento
    OnSolicEjecAcc(C_ACC_CABIN, C_INI_CTAPC, 0, frmTiempos.CadActivacion);
end;
procedure TCibGFacCabinas.mnModifCuenta(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(facSelec);
  if cab.Detenida then begin
    mnInicCuenta(self);  //está detenida, inicia la cuenta
  end else if cab.Contando then begin
    //Está en medio de una cuenta
    frmTiempos.Mostrar(cab);  //modal
    if frmTiempos.cancelo then exit;  //canceló
    OnSolicEjecAcc(C_ACC_CABIN, C_MOD_CTAPC, 0, frmTiempos.CadActivacion);
  end;
end;
procedure TCibGFacCabinas.mnDetenCuenta(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(facSelec);
  if MsgYesNo('¿Desconectar Computadora: ' + cab.nombre + '?') <> 1 then exit;
  OnSolicEjecAcc(C_ACC_CABIN, C_DET_CTAPC, 0, cab.IdFac);
end;
procedure TCibGFacCabinas.mnPonerManten(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(facSelec);
  if not cab.Detenida then begin
    MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
    exit;
  end;
  OnSolicEjecAcc(C_ACC_CABIN, C_PON_MANTN, 0, cab.IdFac); //El mismo comando, pone en mantenimiento
end;
//constructor y destructor
constructor TCibGFacCabinas.Create(nombre0: string; ModoCopia0: boolean);
begin
  inherited Create(nombre0, ctfCabinas);
  FModoCopia := ModoCopia0;    //Asigna al inicio para saber el modo de trabajo
//debugln('-Creando: '+ nombre0);
  frmTiempos:= TfrmFijTiempo.Create(nil);   //formulario para fijar tiempos
//Se incluye un objeto TGrupoTarAlquiler para la tarificación
  GrupTarAlquiler := TGrupoTarAlquiler.Create;
  tarif := TCPTarifCabinas.Create(GrupTarAlquiler);
  timer1 := TTimer.Create(nil);
  timer1.Interval:=1000;
  timer1.OnTimer:=@timer1Timer;
  CategVenta := 'COUNTER';
  //Crea ventana de configuración de tarifas
  frmAdminTar:= TfrmAdminTarCab.Create(nil);
  frmAdminTar.grpTarAlq := GrupTarAlquiler;
  frmAdminTar.tarCabinas := tarif;
  frmAdminTar.OnModificado:=@fac_CambiaPropied;  //para actualizar cambios
  if GrupTarAlquiler.items.Count=0 then begin
    //agrega una tarifa de alquiler por defecto
    frmAdminTar.IniciarPorDefecto;  { TODO : Ver si es necesario }
    frmAdminTar.BitAplicarClick(nil);
  end;
  //Crea ventana de administración de cabinas
  frmAdminCabs:= TfrmAdminCabinas.Create(nil);
  frmAdminCabs.grpCab := self;  //inicia admin. de cabinas
  //Ventanas de mensajes de red
  ventMsjes := TForm_list.Create;
end;
destructor TCibGFacCabinas.Destroy;
var
  c : TCibFac;
begin
//debugln('-destruyendo: '+ Nombre + ','+IntToStr(Ord(tipo))+','+
//                          CategVenta+','+IntTostr(items.Count));
  ventMsjes.Destroy;
  frmAdminCabs.Destroy;
  frmAdminTar.Destroy;
  //Detiene eventos
  OnCambiaPropied:= nil;  //para evitar refrescar controles en este estado
  OnReqConfigGen := nil;
  OnReqConfigMon := nil;
  OnReqCadMoneda := nil;
  OnLogInfo      := nil;
  OnLogVenta     := nil;
  OnActualizStock:= nil;
  OnTramaLista   := nil;   { TODO : Tal vez estas rutinas de limpieza se deban hacer en directamente en TCibFacCabina }
  OnRegMensaje   := nil;
  timer1.OnTimer:=nil;
  timer1.Destroy;
  tarif.Destroy;
  {Envía la señal de desconexión a todas las cabinas de golpe, para que la destrucción
  de la lista, no se haga muy lenta}
  for c in items do begin
    TCibFacCabina(c).Desconectar;
  end;
  GrupTarAlquiler.Destroy;
  frmTiempos.Destroy;
  inherited Destroy;  {Aquí se hace items.Destroy, que puede demorar por los hilos}
end;

end.

