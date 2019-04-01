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
  Menus, Dialogs, Controls, MisUtils, CibTramas, CibFacturables, CibCabinaBase,
  CibCabinaTarifas, FormVisorMsjRed, CibUtils, CibBD, Globales, FormAdminTarCab,
  FormAdminCabinas, FormFijTiempo, FormExplorCab;
const //Acciones sobre las PC
  /////// Comandos que se ejecutan en el modelo y no requieren conexión. ////////
  C_CABIN_INICTA = 01;  //Solicita iniciar la cuenta de una PC
  C_CABIN_DETCTA = 02;  //Solicita detener la cuenta de una PC
  C_CABIN_MODCTA = 03;  //Solicita modificar la cuenta de una PC
  C_CABIN_PONMAN = 04;  //Solicita poner en mantenimiento a una PC
  C_CABIN_TRASLA = 05;  //Solicita trasladar cabina
  C_CABIN_FIJCTA = 06;  //Fija el tiempo de una cabina.
  C_CABIN_PONPAU = 07;  //Pone una cabina en pausa
  C_CABIN_QUIPAU = 08;  //Quita a una cabina, el estado de pausa
  C_CABIN_EDICOM = 09;  //Edita un comentario
  C_CABIN_SACMAN = 10;  //Solicita sacar de mantenimiento a una PC
  C_CABIN_MSJRED = 11;  //Solicita abrir ventana de mensajes de Red
  //Comandos para Grupo de cabinas
  C_GCAB_ACTTAR = 15;  //Solicita actualizar tarifas de un Grupo de Cabinas
  C_GCAB_ADMEQU = 16;  //Solicita abrir ventana para administrar equipos

  /////// Comandos que se ejecutan remótamente ////////
  //Se ha tratado de respetar el nombre de los comandos del NILOTER-m
  //Comandos cortos que no devuelven mensajes
  C_CABIN_BLOQ_PC = 20;  //Solicita bloquear una cabina
  C_CABIN_DESB_PC = 21;  //Solicita desbloquear una cabina
//  C_CABIN_FIJ_RAT = 22; //Fija coordenadas de ratón
  C_CABIN_REIN_PC = 23;  //Comando para reiniciar PC
//  CCABIN_MOS_TPO = 24;
  C_CABIN_APAG_PC = 25;  //Comando para apagar PC
  C_CABIN_ENCEPC  = 26;  //Encender PC
//  C_CABIN_MENS_PC = 27;  //Comando de envío de mensaje a PC
//  C_CABIN_GEN_TEC = 28;  //Comando de generar tecla pulsada
//  C_CABIN_DE_SCSV = 29;  //Comando para desactivar protector de pantalla
//  C_CABIN_CER_PRO = 30;  //Comando para cerrar todos los programas
//  C_CABIN_MIN_VEN = 32;  //Comando para minimizar todas las ventanas
//  C_CABIN_MAX_VEN = 33;  //Comando para maximizar todas las ventanas
//  C_CABIN_MEN_TIT = 34;  //Comando para mostrar mensaje en al barra de título

  //Otros comandos
  C_CABIN_PAN_COMP = 40;  //Solicita captura de pantalla
  R_CABIN_PAN_COMP = 41;  //Respuesta de captura de pantalla
//  C_CABIN_COORD_RAT = 42;
//  R_CABIN_COORD_RAT = 43;
//  C_CABIN_PRESENCIA = 44;  //Comando de solicitud de presencia
//  C_CABIN_PRESENCIA = 45;  //Comando de solicitud de presencia
//  C_CABIN_ESTAD_CLI = 46;  //Solicitud de estado del cliente.(APLICABLE A PC CLIENTE)
//  C_CABIN_ESTAD_CLI = 47;  //Solicitud de estado del cliente.(APLICABLE A PC CLIENTE)
//  C_CABIN_FIJ_ESCRI = 48;,  //Comando para cambiar el escritorio (APLICABLE A PC CLIENTE)

  C_CABIN_ARC_SOLIC = 50;  //Traer archivo
  R_CABIN_ARC_SOLIC = 51;  //Archivo recibido
  C_CABIN_ARC_ENVIA = 52;   //Enviar archivo

  C_CABIN_FIJ_ARSAL = 53;  //Fijar nombre de archivo

  C_CABIN_SOL_L_ARC = 60; //Commando pedir Lista de archivos (directorio actual)
  R_CABIN_SOL_L_ARC = 61; //Respuesta pedir Lista de archivos (directorio actual)
  C_CABIN_SOL_RUT_A = 62;  //Solicitar ruta actual
  R_CABIN_SOL_RUT_A = 63; //Respuesta ruta actual de la cabina
  C_CABIN_FIJ_RUT_A = 64; //Comando Fija la ruta de la cabina
  C_CABIN_ELI_ARCHI = 65;  //Elimina archivo
  C_CABIN_EJE_ARCHI = 66;  //Ejecutar archivo en PC cliente
//  C_CABIN_CAN_TRANS = 67;  //Cancela una transferencia en curso
  C_CABIN_ARC_SOLIP = 68;  //Archivo solicitado parcialmente
  R_CABIN_ARC_SOLIP = 69;  //Archivo solicitado parcialmente
//  C_CABIN_CRECARPE = 70;  //Crea carpeta
//  C_CABIN_ELICARPE = 71;  //Elimina carpeta
//  C_CABIN_NOMARCHI = 72;  //Cambia nombre a archivo

  //Mensaje que no existen en NILOTER
  R_CABIN_DAT_RECIB = 80;  //Se usa para indicar al visor que están llegando datos remotos

const
  //Identificadores para los registros de este grupo
  IDE_INT_GRA = 'q';     //Registro de alquiler de cabina - hora gratis
  IDE_INT_NOR = 'p';     //Registro de alquiler de cabina normal

type
  TCibFacCabina = class;
  TCibGFacCabinas = class;

  //TEvCabCambiaEstado = procedure(nuevoEstado: TCabEstadoConex) of object;
  TEvCabRegMensaje = procedure(NomCab: string; msj: string) of object;
  TEvCabAccionCab = procedure(cab: TCibFacCabina) of object;
//  TEvCabLogIBol = procedure(cab: TCPCabina; it: TCPItemBoleta; msj: string) of object;

  { TCibFacCabina }
  {Define al objeto Cabina de Ciberplex}
  TCibFacCabina = class(TCibFac)
  public //Métodos estáticos para codificar/decodificar cadenas
    class function CodCadEstado(sNombre: String; estadoConex: TCibEstadoConex;
      HoraPC: TDateTime; PantBloq: Boolean; estado: TcabEstadoCuenta;
  hor_ini: TDateTime; tSolic: TDateTime; tLibre: boolean; horGra: boolean;
  FTransc: integer; FCosto: double): string;
    class procedure DecodCadEstado(str: String; out sNombre: String; out
      estadoConex: TCibEstadoConex; out HoraPC: TDateTime; out PantBloq: Boolean; out
  estadoCta: TcabEstadoCuenta; out hor_ini: TDateTime; out tSolic: TDateTime; out
  tLibre, horGra: boolean; out FTransc: integer; out FCosto: double);
    class function CodCadPropied(_Nombre, _IP, _mac: string; _x, _y: Single;
      _ConConexion: boolean; _NombrePC, _Coment: string): string;
    class procedure DecodCadPropied(str: String; out _Nombre, _IP, _mac: string; out
      _x, _y: Single; out _ConConexion: boolean; out _NombrePC, _Coment: string);
  private  //campos privados
    cabCuenta: TCabCuenta;    //campos de conteo de la cabina
    cabConex : TCabConexion;  //campos de conexión de la cabina
    FNombrePC: string;
    PausadS: integer;   {tiempo pausado en segundos (Contador de
                         tiempo que la cabina se encuentra en pausa)}
    tic    : integer;   //contador para temporización
    SinRed : boolean;   {Para usar al objeto, solamente como contenedor, sin conexión
                         por Socket.}
    //VaRiables temporales
    ResponderA: string;   //Id de vista, a dónde se debe responder el mensaje
    DatPaqRecib: Boolean; //Bandera para saber cuándo llegan paquetes parciales de la PC remota
    DatPaqMsje: string;  //Último mensaje recibido cuando se activa DatPaqRecib
    arcSal    : string;   //Variable para procesar el comando C_FIJ_ARSAL
    RutaActual: string;   //Ruta de trabajo actual de la cabina
    procedure LimpiarCabina;
    procedure mnEditComent(Sender: TObject);
    procedure mnDetenCuenta(Sender: TObject);
    procedure mnEncenderPC(Sender: TObject);
    procedure mnFijTiempoIni(Sender: TObject);
    procedure mnInicCuenta(Sender: TObject);
    procedure mnModifCuenta(Sender: TObject);
    procedure mnPausarCuent(Sender: TObject);
    procedure mnPonerManten(Sender: TObject);
    procedure mnSacarManten(Sender: TObject);
    procedure mnReinicCuent(Sender: TObject);
    procedure mnVerMsjesRed(Sender: TObject);
    function VerCorteAutomatico: boolean;
    procedure cabCambiaEstadoConex(nuevoEstado: TCibEstadoConex);
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
    procedure SetNombrePC(AValue: string);
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public  //Campos de propiedades
    property NombrePC : string read FNombrePC write SetNombrePC;  //Nombre de Red que tiene la PC cliente
    property IP: string read GetIP write SetIP;
    property Mac: string read cabConex.mac write SetMac;
    property ConConexion: boolean read FConConexion write SetConConexion;
  public  //campos diversos
    OnTramaLista  : TEvTramaLista;   //indica que hay una trama lista esperando
    //OnGrabBoleta  : TEvCabAccionCab;    //Indica que se ha grabado la boleta
    function tarif: TCPTarifCabinas;  {Referencia a la Tarifa }
    function RegVenta(usu: string): string; override; //línea para registro de venta
    procedure Contar1seg;      //usado para temporización
    procedure mnVerExplorad(Sender: TObject);
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
    function EstadoConex: TCibEstadoConex;
    function EstadoConexN: integer;
    function EstadoConexStr: string;
    function Conectado: boolean;
    procedure Desconectar;
  public //control de la cabina
    frmExpArc: TfrmExplorCab;    //Explorador de archivos
    frmVisMsj: TfrmVisorMsjRed;  //Visor de mensajes de red
    function Contando: boolean;  //indica que la cabina está contando el tiempo
    function Detenida: boolean;  //indica que la cabina está detenida
    procedure SincTiempo;        //sincroniza el tiempo con la cabina cliente
    procedure SincBloqueo;       //sicroniza el bloqueo de la pantalla
    procedure TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string=
      '');
    procedure InicConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
    procedure InicConteo(cadConteo: string);
    procedure ModifConteo(tSolic0: TDateTime; tLibre0, horGra0: boolean);
    procedure ModifConteo(cadConteo: string);
    procedure DetenConteo;
    procedure PonerManten;     //Pone cabina en mantenimiento
    procedure SacarManten;     //Saca cabina en mantenimiento
    procedure TrasladarA(cab2: TCibFacCabina);  //Traslada a otra cabina
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
      override;
    procedure EjecAccion(idVista: string; tram: TCPTrama; traDat: string); override;
    procedure MenuAccionesVista(MenuPopup: TPopupMenu; nShortCut: integer); override;
    procedure MenuAccionesModelo(MenuPopup: TPopupMenu); override;
  public  //Inicialización
    constructor Create(nombre0: string; ip0: string);
    constructor CreateSinRed;  //Crea objeto sin red
    destructor Destroy; override;
  end;

  TEvArchCambRemot = procedure(ruta, nombre: string) of object;

  { TCibGFacCabinas }
  { Clase que define al conjunto de las PC clientes. Se juntan todas las
  cabinas en un objeto único, porque la arquitectura se define para centralizar el
  control en un solo objeto, con la posibilidad de tener múltiples interfaces
  (pantallas) de la aplicación. }
  TCibGFacCabinas = class(TCibGFac)
    class function CodCadEstado(_Nombre: string): string;
    class procedure DecodCadEstado(str: String; out _Nombre: string);
    class function CodCadPropied(_Nombre, _CategVenta: string; _x, _y: Single;
      strTarAlquiler, strTarif: string): string;
    class procedure DecodCadPropied(lineas: TStringList; out _Nombre,
      _CategVenta: string; out _x, _y: Single; out strGrupTar,
  strTarif: string);
  private
    arcLog : TCibTablaHist;  //Tabla de registros para cabinas
    timer1 : TTimer;
    frmTiempos: TfrmFijTiempo;  //Formulario para fijar tiempos
    procedure cab_TramaLista(idFacOrig: string; tram: TCPTrama);
    procedure mnAdminEquipos(Sender: TObject);
    procedure mnAdminTarifas(Sender: TObject);
    procedure timer1Timer(Sender: TObject);
  public  //Eventos.
    {EjecAccion que se pueden disparar automáticamente. Sin intervención del usuario}
    OnTramaLista   : TEvTramaLista; //indica que hay una trama lista esperando
    OnArchCambRemot: TEvArchCambRemot; //indica que se ha cambiado algún archivo de forma remota
  protected //Getters and Setters
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public
    grupTar: TGrupoTarAlquiler;  //Grupo de tarifas de alquiler
    tarif: TCPTarifCabinas; //tarifas de cabina
    frmAdminTar: TfrmAdminTarCab;
    frmAdminCabs: TfrmAdminCabinas;
    function Agregar(nombre0: string; ip0: string): TCibFacCabina;
    function Eliminar(nombre0: string): boolean;
    procedure Conectar;
    function CabPorNombre(nom: string): TCibFacCabina;  { TODO : ¿Será necesario, si ya existe ItemPorNombre en el ancestro? }
    function Toleran: TDateTime;   //acceso a la tolerancia
    procedure MuestraConexionCabina;
  public  //Operaciones con cabinas
    function EscribeLog(identif: char; mensaje: String): integer;
    procedure TCP_envComando(nom: string; comando: TCPTipCom; ParamX, ParamY: word;
      cad: string='');
  public  //Campos para manejo de acciones
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string); override;
    procedure EjecAccion(idFacOrig: string; tram: TCPTrama); override;
    procedure MenuAccionesVista(MenuPopup: TPopupMenu); override;
    procedure MenuAccionesModelo(MenuPopup: TPopupMenu); override;
  public  //Inicialización
    constructor Create(nombre0: string; ModoCopia0: boolean);
    destructor Destroy; override;
  end;

  function VarCampoNombreCP(const cad: string): string;

implementation
var
  icoModifCuenta: integer;
  icoDetenCuenta: integer;
  icoPonerManten: integer;
  icoAgregComent: integer;
  icoPausarCuent: integer;
  icoReinicCuent: integer;
  icoVerExplorad: integer;
  icoVerMsjesRed: integer;
  icoAdminTarifas: integer;
  icoAdminEquipos: integer;
  icoPropiedades: integer;

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
procedure TCibFacCabina.cabCambiaEstadoConex(nuevoEstado: TCibEstadoConex);
{Evento de cambio de estado de la conexión}
begin
  //Se considera un cambio de estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
end;
procedure TCibFacCabina.cabConexTramaLista(NomCab: string; tram: TCPTrama);
{Este es el punto de llegada de las tramas de una PC cliente, que puede ser un Punto
de Venta, o una PC de alquiler. Aquí se discrimina para ver, qué tipo de trama es.
Esto corre en el modelo.}
var
  NombPC, arc, tmp, archivo: string;
  HorPC: TDateTime;
begin
  if tram.tipTra>=CVIS_SOLPROP then begin
    //Como son comandos de un punto de venta, los propaga hasta el modelo.
    OnTramaLista(IdFac, tram);
    exit;
  end;
  //Estos mensajes son de una PC cliente. Hay que procesarlos
  frmVisMsj.PonerMsje('    <<Recibido: ' + tram.TipTraNom);  //Envía mensaje a su formulario
  case tram.tipTra of
  M_ESTAD_CLI : begin
    if tram.traDat = '' then exit;   //protección
    //Este mensaje se procesa aquí sin propagarlo
    Decodificar_M_ESTAD_CLI(tram.traDat, NombPC, HorPC);
    NombrePC:= NombPC;
    HoraPC  := HorPC;
    PantBloq:= (tram.posX = 1);
  end;
  M_PRESENCIA : begin
    //Recibido mensaje de presencia
  end;
  M_PAN_COMP  : begin
    //Llego una captura de pantalla
    if ResponderA='' then exit;   //no hay a quien reponder
    //Genera la trama de respuesta.
    //Incluye en los datos al ID de la cabina a la que debe llegar la respuesta
    OnRespComando(ResponderA, RFAC_CABIN, R_CABIN_PAN_COMP, length(IdFac),
                  IdFac + #9 + tram.traDat);
//    ResponderA := '';  //Para que no acepte més respuestas
  end;
  M_SOL_RUT_A : begin
    //Llego la ruta actual
    if ResponderA='' then exit;   //no hay a quien reponder
    OnRespComando(ResponderA, RFAC_CABIN, R_CABIN_SOL_RUT_A, 0,
                  IdFac + #9 + tram.traDat);
//    ResponderA := '';  //Para que no acepte més respuestas
  end;
  M_SOL_L_ARC : begin
    //Llego la ruta actual
    if ResponderA='' then exit;   //no hay a quien reponder
    OnRespComando(ResponderA, RFAC_CABIN, R_CABIN_SOL_L_ARC, 0,
                    IdFac + #9 + tram.traDat);
//      ResponderA := '';  //Para que no acepte més respuestas
  end;
  M_ARC_SOLIC : begin
    //Llego un archivo
    if ResponderA='' then exit;   //no hay a quien reponder
    OnRespComando(ResponderA, RFAC_CABIN, R_CABIN_ARC_SOLIC, 0,
                  IdFac + #9 + tram.traDat);
//    ResponderA := '';  //Para que no acepte més respuestas
  //Comandos
  end;
  {Notar que los siguientes identifiacdores, son comandos generado por una PC remota
  (algún punto de venta de la red), no local. No es que sea la respuesta a un comando
   anterior.
   Estos comandos podrían agruparse en un solo comando de tipGFac "Manejo de archivos", y
   se podría manejar con un objeto especializado. Se mantiene así por compatibilidad.}
  C_PAN_COMPL : begin
    arc := ExtractFilePath(Application.ExeName) + '~00.tmp';
    PantallaAArchivo(arc);
    TCP_envComando(M_PAN_COMP, 0, 0, StringFromFile(arc));
  end;
  C_MENS_PC   : begin  //Llegó un mensaje de la PC remota
    {Este mensaje se podría mostrar aquí mismo con un MsgBox(), pero formalmente,
    habría que enviarlo a la vista que solicitó el mensaje}
    if ResponderA='' then exit;   //no hay a quien reponder
    //Notar que este comando va dirigido a la vista, no a un facturable específico,
    //por eso no incluye el ID del facturable.
    OnRespComando(ResponderA, CVIS_MSJEPC, 0, 0,
                  tram.traDat);
  end;
  C_GEN_TEC: ;
  C_ARC_SOLIC : begin  //Se está pidiendo un archivo
    {Se pide un archivo. }
    if RutaActual = '' then       //No se tiene definida la ruta de trabajo.
      CambiaDir(ExtractFilePath(Application.ExeName))  //se asume
    else  //Normalmente, se debe haber definido primero una ruta de trabajo
      CambiaDir(RutaActual);
    if not FileExists(tram.traDat) then begin
      frmVisMsj.PonerMsje('      !!Archivo no existe: ' + tram.traDat);  //Envía mensaje a su formulario
      TCP_envComando(C_MENS_PC, 0, 0, 'Archivo no existe.');  //Responde a la PC
      exit;
    end;
    arc := StringFromFile(tram.traDat);
    if tram.posY = 1 then begin
      //Esto es nuevo en CIBERPLEX. Se usa "posY" para indicar que debe usarse C_FIJ_ARSAL
      //antes de enviar el archivo.
      TCP_envComando(C_FIJ_ARSAL, 0, 0, tram.traDat);
    end;
    TCP_envComando(M_ARC_SOLIC, 0, 0, arc);
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
  end;
  C_ARC_SOLIP: ;
  C_ARC_ENVIA: begin
    CambiaDir(RutaActual);
    if length(tram.traDat) = 0 then exit;  //protección
    //Genera archivo físico en el escritorio.
    archivo := arcSal;  //archivo a generar
    If FileExists(archivo) Then DeleteFile(archivo);
    StringToFile(tram.traDat, archivo);
    //Envía lista actualizada
    msjError := '';
    tmp := ListarArchivosD;
    TCP_envComando(M_SOL_LD_AR, 0, 0, tmp);
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
    //Avisa que se ha modificado un archivo
    TCibGFacCabinas(grupo).OnArchCambRemot(RutaActual, arcSal);
  end;
  C_FIJ_ARSAL : begin  //Se está pidiendo fijar el nombre
    arcSal := tram.traDat;
  end;
  C_SOL_L_ARC: begin
    CambiaDir(RutaActual);
    //envìa lista detallada de archivos
    tmp := ListarArchivos();
    TCP_envComando(M_SOL_L_ARC, 0, 0, tmp);
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
  end;
  C_SOL_RUT_A: begin
    TCP_envComando(M_SOL_RUT_A, 0, 0, RutaActual);
  end;
  C_FIJ_RUT_A : begin  //Se está pidiendo fijar la ruta actual
    tmp := tram.traDat;
    if tmp = '' Then tmp := RutaEscritorio; //sin ruta se asume el escritorio
    if (tmp<>'') and (tmp[1] = '-') Then  //'-' representa a la ruta de la aplicación
      tmp := ExtractFilePath(Application.ExeName) + copy(tmp, 2, length(tmp));
    if not StringLike(tmp, '?:*') then begin  //la ruta es relativa
        //la vuelve ansoluta
        if StringLike(RutaActual, '*\') then begin
            tmp := RutaActual + tmp + '\';
        end else begin
            tmp := RutaActual + '\' + tmp + '\';
        end;
    end;
    if CambiaDir(tmp) Then begin
      RutaActual := GetCurrentDir;    //actualiza ruta
      TCP_envComando(M_SOL_RUT_A, 0, 0, RutaActual);
      //Envìa lista de archivos (no es bueno enviar siempre la lsita de archivos)
      if tram.posY = 1 then begin
        //Esto es nuevo en Ciberplex
        tmp := ListarArchivosD();
        TCP_envComando(M_SOL_LD_AR, 0, 0, tmp)
      end else begin
        tmp := ListarArchivos();
        TCP_envComando(M_SOL_L_ARC, 0, 0, tmp)
      end;
    end else  begin   //No lo logró
      msjError := 'Error fijando ruta actual';
      TCP_envComando(C_MENS_PC, 0, 0, msjError);
    end;
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
  end;
  C_ELI_ARCHI : begin
    CambiaDir(RutaActual);
    msjError := '';
    try
      DeleteFile(tram.traDat);
      tmp := ListarArchivosD();
      TCP_envComando(M_SOL_LD_AR, 0, 0, tmp);
    except
      TCP_envComando(C_MENS_PC, 0, 0, 'No se puede eliminar: ' + tram.traDat);
    end;
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
  end;
  C_EJE_ARCHI : begin
    CambiaDir(RutaActual);
    msjError := '';
    if not MisUtils.Exec('CMD', '/C start "TITULO" "' + tram.traDat + '"') then begin
      TCP_envComando(C_MENS_PC, 0, 0, 'Error ejecutando: ' +  tram.traDat);
    end;
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
  end;
  C_CAN_TRANS : ;
  C_CRE_CARPE : ;
  C_ELI_CARPE : ;
  C_SOL_LD_AR : begin
    CambiaDir(RutaActual);
    //envìa lista detallada de archivos
    tmp := ListarArchivosD();
    TCP_envComando(M_SOL_LD_AR, 0, 0, tmp);
    CambiaDir(ExtractFilePath(Application.ExeName));  //devuelve la ruta
  end;
  else
    frmVisMsj.PonerMsje('      !!Trama desconocida: ' + tram.TipTraNom);  //Envía mensaje a su formulario
  end;
end;
procedure TCibFacCabina.cabConexRegMensaje(NomCab: string; msj: string);
begin
  //pasa mensaje a Visor de mensaje, si está abierto
  frmVisMsj.PonerMsje(msj);  //Envía mensaje a su formaulario
  if (msj<>'') and (msj[1]='-') then begin
    //LLegaron mensajes de pedazos de tramas recibidas.
    DatPaqRecib := true;  //Actualiza bandera
    DatPaqMsje  := msj;   //CAptura último mensaje
  end;
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
class function TCibFacCabina.CodCadPropied(_Nombre, _IP, _mac: string; _x,
  _y: Single; _ConConexion: boolean; _NombrePC, _Coment: string): string;
{Codifica la cadena de estado, a partir de las variables indicadas. Se pone fuera de
TCibFacCabina para poder usarse sin crear instancias de TCibFacCabina}
begin
  Result := _Nombre + #9 +
            _IP + #9 +
            _mac + #9 +
            N2f(_x) + #9 +
            N2f(_y) + #9 +
            B2f(_ConConexion) + #9 +
            _NombrePC + #9 +
            _Coment + #9 + #9 + #9;
end;
class procedure TCibFacCabina.DecodCadPropied(str: String; out _Nombre, _IP,
  _mac: string; out _x, _y: Single; out _ConConexion: boolean; out _NombrePC,
  _Coment: string);
{Decodifica la cadena de propiedades, en las variables indicadas. Se pone fuera de
TCibFacCabina para poder usarse sin crear instancias de TCibFacCabina}
var
  campos: TStringDynArray;
begin
  campos := Explode(#9, str);
  _Nombre := campos[0];
  _IP := campos[1];
  _mac := campos[2];
  _x := f2N(campos[3]);
  _y := f2N(campos[4]);
  _ConConexion := f2B(campos[5]);  //si es TRUE (y SinRed=FALSE), inicia la conexión
  _NombrePC := campos[6];
  _Coment := campos[7];
end;
function TCibFacCabina.GetCadPropied: string;
{Las propiedades son los compos que definen la configuración de una cabina. Se fijan al
inicio, y no es común cambiarlos luego}
begin
  Result := CodCadPropied(Nombre, IP, mac, x, y, ConConexion, NombrePC, Coment);
end;
procedure TCibFacCabina.SetCadPropied(AValue: string);
var
  _Coment, _NombrePC, _IP, _Mac, _Nombre: string;
  _ConConexion: boolean;
  _y, _x: Single;
begin
  DecodCadPropied(AValue, _Nombre, _IP, _Mac, _x, _y, _ConConexion, _NombrePC, _Coment);
  Nombre := _Nombre;
  IP := _IP;
  Mac := _Mac;
  x := _x; y := _y;
  ConConexion := _ConConexion;
  NombrePC := _NombrePC;
  Coment := _Coment;
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
           I2f(Round(cabCuenta.tSolic * 24 * 60)) + #9 + 'ALQUILER DE CABINA' + #9 +
           D2f(FTransc/3600/24) + #9 + Nombre + #9 + estConex + #9 + I2f(PausadS) + #9 +
           D2f(TranscSegTol/3600/24) + #9 +
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
 Es recomendabla llamarla cada segundo. Solo se aplica al Modelo.}
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
  {Genera mensajes a cliente. Se temporiza a un segundo, para evitar mandar demasiados
  mensajes, a los Visores. }
  if DatPaqRecib then begin
    //Hubo datos recibidos en este intervalo
    //Este mensaje es útil para ver el estado, cuando se piden archivos grandes y
    //no hay manera de saber, en el Visor, si los datos están llegando.
    OnRespComando(ResponderA, RFAC_CABIN, R_CABIN_DAT_RECIB, 0, IdFac + #9 + DatPaqMsje);
    DatPaqRecib := false;
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
class function TCibFacCabina.CodCadEstado(
  //Campos principales
  sNombre: String;
  estadoConex: TCibEstadoConex;
  HoraPC: TDateTime;
  PantBloq: Boolean;
  //Campos de la cuenta
  estado      : TcabEstadoCuenta;
  hor_ini     : TDateTime;
  tSolic      : TDateTime;
  tLibre      : boolean;
  horGra      : boolean;
  //Campos adicionales
  FTransc     : integer;
  FCosto      : double): string;
{Codifica la cadena de estado, a partir de las variables indicadas. Se pone fuera de
TCibFacCabina para poder usarse sin crear instancias de TCibFacCabina}
begin
  Result := '.' + {Caracter identificador de facturable, se omite la coma por espacio.}
         sNombre + #9 +    {el nombre es obligatorio para identificar unívocamente a la cabina}
         I2f(Ord(estadoConex))+ #9 + {se coloca primero el Estado de la conexión, porque
             es el campo que siempre debe actualizarse, cuando hay conexión remota activada}
         T2f(HoraPC) + #9 +  //Este campo no tiene significado si no hay conexión
         B2f(PantBloq);  //Este campo no tiene significado si no hay conexión
  if estado <> EST_NORMAL then begin
    // En el estado EST_NORMAL, no es necesario enviar los demás campos
    Result += #9 +
         I2f(Ord(estado)) + #9 +
         T2f(hor_ini) + #9 +
         T2f(tSolic)  + #9 +
         B2f(tLibre)  + #9 +
         B2f(horGra)  + #9 +
         I2f(FTransc) + #9 +
         N2f(FCosto);
  end;
end;
class procedure TCibFacCabina.DecodCadEstado(str: String; out sNombre: String;
  out estadoConex: TCibEstadoConex; out HoraPC: TDateTime; out
  PantBloq: Boolean; out estadoCta: TcabEstadoCuenta; out hor_ini: TDateTime; out
  tSolic: TDateTime; out tLibre, horGra: boolean; out FTransc: integer; out
  FCosto: double);
{Decodifica la cadena de estado, en las variables indicadas. Se pone fuera de
TCibFacCabina para poder usarse sin crear instancias de TCibFacCabina}
var
  campos: TStringDynArray;
begin
  delete(str, 1, 1);  //recorta identificador
  campos := Explode(#9, str);
  //Extrae Campos
  estadoConex := TCibEstadoConex(f2I(campos[1]));
  HoraPC := f2T(campos[2]);
  PantBloq := f2B(campos[3]);
  if high(campos)>=4 then begin
    //Hay información de campos adicionaleas
    estadoCta   := TcabEstadoCuenta(f2I(campos[4]));
    hor_ini  := f2T(campos[5]);
    tSolic   := f2T(campos[6]);
    tLibre   := f2B(campos[7]);
    horGra   := f2B(campos[8]);
    FTransc  := f2I(campos[9]);   //el tiempo transcurrido se lee directamente
    FCosto   := f2N(campos[10]);   //el costo se lee directamente en el campo FCosto
  end else begin
    //No hay información adicional, se asumen valores por defecto
    estadoCta   := EST_NORMAL;
    hor_ini  := trunc(now);  //para que no hay errores en el cálculo
    tSolic   := 0;
    tLibre   := false;
    horGra   := false;
    FTransc  := 0;   //el tiempo transcurrido se lee directamente
    FCosto   := 0;   //el costo se lee directamente en el campo FCosto
  end;
end;
function TCibFacCabina.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := CodCadEstado(
         Nombre, cabConex.estado, HoraPC, PantBloq,
         cabCuenta.estado,
         cabCuenta.hor_ini,
         cabCuenta.tSolic,
         cabCuenta.tLibre,
         cabCuenta.horGra,
       { Estos campos son calculados, pero se devuelven como ayuda, para la implementación
         de otros puntos de venta (conectados a este servidor), de modo que no necesiten
         hacer nuevamente el cálculo (con posibilidad de obtener un resultado diferente) }
         FTransc,
         FCosto);
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCibFacCabina.SetCadEstado(AValue: string);
{Fija los campos de estado. Solo debería usarse cuando se trabaja la cabina sin Red,
 o al inicio para fijar las propiedades.}
var
  lin, sNombre: String;
  lineas: TStringDynArray;
  tmp: TCibEstadoConex;
begin
  lineas := Explode(LineEnding, AValue);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  DecodCadEstado(lin, sNombre,  //sNombre, se lee pero no actualiza nada
    tmp,
    HoraPC, PantBloq, cabCuenta.estado, cabCuenta.hor_ini,
    cabCuenta.tSolic, cabCuenta.tLibre, cabCuenta.horGra, FTransc, FCosto);
  if SinRed then begin  //Cuando hay red, esta propiedad se actualiza sola
      cabConex.estado := tmp;  //Solo en modo "SinRed" se lee este campo
      //"cabConex.estado" debe ser realmente de solo lectura.
  end;
  //Agrega información de boletas
  LeerEstadoBoleta(Boleta, lineas);
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
function TCibFacCabina.EstadoConex: TCibEstadoConex;
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
  PausadS:=0;     //reinicia contador de tiempo pausado
  ActualizaTranscYCosto;  //para inciar FTransc y FCosto
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
  cabConex.TCP_envComando(C_DESB_PC, 0, 0);    //desbloquea, si hay conexión
end;
procedure TCibFacCabina.InicConteo(cadConteo: string);
{Versión de InicConteo(), que recibe una "cadena de conteo".}
var
  tSolic0: TDateTime;
  tLibre0, horGra0: boolean;
begin
  DecodCadConteo(cadConteo, tSolic0, tLibre0, horGra0);
  InicConteo(tSolic0, tLibre0, horGra0);
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
procedure TCibFacCabina.ModifConteo(cadConteo: string);
{Versión de ModifConteo(), que recibe una "cadena de conteo".}
var
  tSolic0: TDateTime;
  tLibre0, horGra0: boolean;
begin
  DecodCadConteo(cadConteo, tSolic0, tLibre0, horGra0);
  ModifConteo(tSolic0, tLibre0, horGra0);
end;
procedure TCibFacCabina.DetenConteo;
var
  nser: integer;
  r: TCibItemBoleta;
  Usuario, tSolicCad: string;
begin
  if not Contando then
    exit;   //No se puede detener cuenta en este Estado
  //Pide información global, porque se va a usar
  if Grupo.OnReqConfigGen<>nil then
      Grupo.OnReqConfigUsu(Usuario);
  //Registra la venta en el archivo de registro
  if horGra then begin
//    nser := OnLogVenta(IDE_INT_GRA, RegVenta(Usuario), Costo);
    nser := TCibGFacCabinas(Grupo).EscribeLog(IDE_INT_GRA, RegVenta(Usuario));
  end else begin
    nser := TCibGFacCabinas(Grupo).EscribeLog(IDE_INT_NOR, RegVenta(Usuario));
  end;
  tSolicCad := IntToStr(tSolicMin) + 'm';
  //Si hubo error, ya se mostró en OnLogVenta()
  //Limpia cuenta. Se hace después de registrar la venta para no alterar el estado
  cabCuenta.tSolic:=0;
  cabCuenta.tLibre:=false;
  cabCuenta.horGra:=false;
  cabCuenta.estado:=EST_NORMAL;
  //Se considera un cambio de Estado
  if OnCambiaEstado<>nil then OnCambiaEstado();
  cabConex.TCP_envComando(C_BLOQ_PC, 0, 0);    //bloquea, si hay conexión

  //agrega item a boleta
  r := TCibItemBoleta.Create;   //crea elemento
  r.vser := nser;
  r.Cant := 1;
  r.pUnit := Costo;
  r.subtot := Costo;
  r.descr := 'Alquiler PC: ' + tSolicCad + '(' + TimeToStr(TranscDat) + ')';
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
procedure TCibFacCabina.TrasladarA(cab2: TCibFacCabina);
{Traslada la cabina a otra cabina.}
begin
  //Verifica si se puede trasladar libre la cabina
  If cab2.EstadoCta in [EST_CONTAN, EST_PAUSAD] then begin
      MsgExc('Cabina ocupada.');
      exit;
  end else if cab2.EstadoCta = EST_MANTEN then begin
      MsgExc('Cabina en mantenimiento.');
      exit;
  end else if cab2.Boleta.items.Count > 0 then begin
      MsgExc('Cabina con boleta pendiente');
      exit;
  end;
  //Copia variables de estado, incluyendo la boleta.
  cab2.CadEstado := CadEstado;
  cab2.Coment := Coment;  //Copia el comentario también
  //Limpia cabina fuente
  LimpiarCabina;
  LimpiarBol;
  Coment := '';
  //Envía comandos para restablecer estado
  TCP_envComando(C_BLOQ_PC, 0, 0);
  Application.ProcessMessages;    //Para darle tiempo a enviar
  Sleep(200);
  Application.ProcessMessages;    //Para darle tiempo a enviar
  if cab2.EstadoCta = EST_CONTAN Then begin
      cab2.TCP_envComando(C_DESB_PC, 0, 0)
  end;
end;
procedure TCibFacCabina.EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Ejecuta la respuesta a un comando envíado, supuestamente,  desde el Visor.
Este método se debe ejecutar siempre en el lado Visor.}
begin
  {Distribuye la respuesta en lo smódulos que corresponda. En este caso, lo envía al
  formulario explorador, que es el único, por el momento, que genera respuestas tardías.}
  frmExpArc.EjecRespuesta(comando, ParamX, ParamY, cad);
end;
procedure TCibFacCabina.EjecAccion(idVista: string; tram: TCPTrama;
  traDat: string);
{Ejecuta la acción solicitada sobre este facturable.
Se ejecuta siempre en el Modelo.}
var
  Err: boolean;
  nom, gru: String;
  facDest2: TCibFac;
  cab2: TCibFacCabina;
  Gfac2: TCibGFac;
begin
  case tram.posX of  //Se usa el parámetro para ver la acción
  //Comandos locales. No llegan directamente hasta la PC remota
  C_CABIN_INICTA: begin   //Se pide iniciar la cuenta de una PC
      InicConteo(traDat);
    end;
  C_CABIN_DETCTA: begin  //Se pide detener la cuenta de las PC
    DetenConteo;
    end;
  C_CABIN_MODCTA: begin   //Se pide modificar la cuenta de una PC
    ModifConteo(traDat);
    end;
  C_CABIN_PONMAN: begin  //Se pide detener la cuenta de las PC
    PonerManten;
    end;
  C_CABIN_SACMAN: begin
    SacarManten;
    end;
  C_CABIN_TRASLA: begin  //Se pide trasladar desde una cabina a otra
    //Se supone que la cabina se moverá a "cab2"
    //Ubica el facturable a donde se moverá
    gru := ExtraerHasta(traDat, SEP_IDFAC, Err);  //Extrae nombre de grupo
    nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto
    //Identifica de acuerdo al grupo
    if grupo.Nombre = gru then begin
      //Es el mismo grupo
      facDest2 := grupo.ItemPorNombre(nom);
    end else begin
      //Es otro grupo
      Gfac2 := grupo.OnBuscarGFac(gru);   //consulta
      if Gfac2 = nil then exit;
      facDest2 := Gfac2.ItemPorNombre(nom);
    end;
    if facDest2=nil then exit;
    cab2 := TCibFacCabina(facDest2);
    //Ahora ya se puede mover la cabina
    TrasladarA(cab2);
    end;
  C_CABIN_FIJCTA: begin
      InicConteo(0, true, false);
      cabCuenta.hor_ini:=Now - tram.posY/60/24;
    end;
  C_CABIN_PONPAU: begin
    if cabCuenta.estado <> EST_CONTAN then exit;
    cabCuenta.estado := EST_PAUSAD;
  end;
  C_CABIN_QUIPAU: begin
    if cabCuenta.estado <> EST_PAUSAD then exit;
    cabCuenta.estado := EST_CONTAN;
  end;
  C_CABIN_EDICOM: begin
    Coment := traDat;
  end;
  C_CABIN_MSJRED: begin
    frmVisMsj.Exec(self.Nombre);
  end;
  //Comandos remotos
  C_CABIN_BLOQ_PC: begin
    TCP_envComando(C_BLOQ_PC, 0, 0);
  end;
  C_CABIN_DESB_PC: begin
    TCP_envComando(C_DESB_PC, 0, 0);
  end;
  C_CABIN_REIN_PC: begin   //Comando para reiniciar PC
      TCP_envComando(C_REIN_PC, 0, 0);
    end;
  C_CABIN_APAG_PC: begin   //Comando para apagar PC
      TCP_envComando(C_APAG_PC, 0, 0);
    end;
  C_CABIN_ENCEPC : begin
    //TCP_envComando(C_ENCE_PC, 0, 0);
    cabConex.SendWakeOnLan;  //Envía comando
  end;
  C_CABIN_PAN_COMP: begin  //Solicitar captura de pantalla
      //Guarda el id de quien pidió la pantalla, para poder devolverla adecuadamente
  debugln('+Solicitando imagen desde: '+ self.IdFac);
      ResponderA := idVista;
      TCP_envComando(C_PAN_COMPL, 0, 0);   //Este comando va a la PC remota
    end;
  C_CABIN_FIJ_RUT_A: begin
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_FIJ_RUT_A, 0, 0, traDat);
    end;
  C_CABIN_SOL_RUT_A: begin  //Solicita ruta actual
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_SOL_RUT_A, 0, 0);
    end;
  C_CABIN_SOL_L_ARC: begin   //Solicita lista de archivos
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_SOL_L_ARC, 0, 0);
    end;
  C_CABIN_ARC_SOLIC: begin  //Solicita traer un archivo
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_ARC_SOLIC, 0, 0, traDat);
    end;
  C_CABIN_FIJ_ARSAL: begin  //Fija nombre de archivo
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_FIJ_ARSAL, 0, 0, traDat);
    end;
  C_CABIN_ARC_ENVIA: begin  //Enviar archivo
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_ARC_ENVIA, 0, 0, traDat);
    end;
  C_CABIN_ELI_ARCHI:  begin  //Elimina archivo
      ResponderA := idVista;   //Porque es comando de respuesta tardía
      TCP_envComando(C_ELI_ARCHI, 0, 0, traDat);
    end;
  C_CABIN_EJE_ARCHI: begin  //Ejecutar un archivo remótamente
      TCP_envComando(C_EJE_ARCHI, 0, 0, traDat);
    end;
  end;
end;
procedure TCibFacCabina.MenuAccionesVista(MenuPopup: TPopupMenu;
  nShortCut: integer);
{Configura las acciones del modelo. Lo ideal sería que todas las acciones se ejecuten
desde aquí.}
begin
  InicLlenadoAcciones(MenuPopup);
  //Se ha visto que  la acción "Iniciar Cuenta" se puede reemplazar con "Modificar Tiempo".
  if EstadoCta in [EST_CONTAN, EST_PAUSAD] then begin
    AgregarAccion(nShortCut, '&Modificar Tiempo'      , @mnModifCuenta, icoModifCuenta);
  end else begin
    AgregarAccion(nShortCut, '&Iniciar Cuenta'      , @mnModifCuenta, icoModifCuenta);
  end;
  AgregarAccion(nShortCut, '&Detener Cuenta'        , @mnDetenCuenta, icoDetenCuenta);
  AgregarAccion(nShortCut, '&Ver Explorador'       , @mnVerExplorad, icoVerExplorad);
  AgregarAccion(nShortCut, 'Editar &Comentario'    , @mnEditComent, icoAgregComent);
  if cabCuenta.estado = EST_MANTEN then begin
    AgregarAccion(nShortCut, 'Sacar de &Mantenimiento', @mnSacarManten, icoPonerManten);
  end else begin
    AgregarAccion(nShortCut, 'Poner en &Mantenimiento', @mnPonerManten, icoPonerManten);
  end;
  if cabCuenta.estado = EST_CONTAN then begin
    AgregarAccion(nShortCut, 'Pausar Cuenta'         , @mnPausarCuent, icoPausarCuent);
  end else if cabCuenta.estado = EST_PAUSAD then begin
    AgregarAccion(nShortCut, 'Reiniciar Cuenta'      , @mnReinicCuent, icoReinicCuent);
  end else begin
    //Agrega siempre un ítem, aunque sea desactivado, para no perder la secuencia de
    //acciones (Que siempre haya la misma cantidad).
    AgregarAccion(nShortCut, 'Pausar Cuenta'         , @mnPausarCuent, icoPausarCuent).Enabled:=false;
  end;
  AgregarAccion(nShortCut, '&Encender PC.'           , @mnEncenderPC, -1);
  AgregarAccion(nShortCut, '&Fijar Tiempo Inic.'     , @mnFijTiempoIni, -1);
//  AgregarAccion(nShortCut, 'Propiedades' , @mnVerMsjesRed, -1););
end;
procedure TCibFacCabina.MenuAccionesModelo(MenuPopup: TPopupMenu);
{Configura acciones que solo correran en el Modelo}
var
  nShortCut: integer;
begin
  InicLlenadoAcciones(MenuPopup);
  nShortCut := -1;
  AgregarAccion(nShortCut, 'Ver Mensajes de &Red' , @mnVerMsjesRed, icoVerMsjesRed);
end;
procedure TCibFacCabina.mnInicCuenta(Sender: TObject);
begin
  if EstadoCta = EST_MANTEN then begin
    if MsgYesNo('¿Sacar cabina de mantenimiento?') <> 1 then exit;
  end else if not Detenida then begin
    msgExc('No se puede iniciar una cuenta en esta cabina.');
    exit;
  end;
  frmFijTiempo.MostrarIni(cabCuenta, nombre);  //modal
  if frmFijTiempo.cancelo then exit;  //canceló
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_INICTA, 0, IdFac + #9 + frmFijTiempo.CadActivacion);
end;
procedure TCibFacCabina.mnModifCuenta(Sender: TObject);
begin
  if Detenida then begin
    mnInicCuenta(self);  //está detenida, inicia la cuenta
  end else if Contando then begin
    //Está en medio de una cuenta
    frmFijTiempo.Mostrar(cabCuenta, nombre);  //modal
    if frmFijTiempo.cancelo then exit;  //canceló
    OnSolicEjecCom(CFAC_CABIN, C_CABIN_MODCTA, 0, IdFac + #9 + frmFijTiempo.CadActivacion);
  end;
end;
procedure TCibFacCabina.mnDetenCuenta(Sender: TObject);
begin
  if MsgYesNo('¿Desconectar Computadora: ' + nombre + '?') <> 1 then exit;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_DETCTA, 0, IdFac);
end;
procedure TCibFacCabina.mnPonerManten(Sender: TObject);
begin
  if not Detenida then begin
    MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
    exit;
  end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_PONMAN, 0, IdFac);
end;
procedure TCibFacCabina.mnSacarManten(Sender: TObject);
begin
  //if not Detenida then begin
  //  MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
  //  exit;
  //end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_SACMAN, 0, IdFac);
end;
procedure TCibFacCabina.mnEditComent(Sender: TObject);
var
  tmp: String;
begin
  tmp := InputBox('','Ingrese Comentario: ', Coment);
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_EDICOM, 0, IdFac + #9 + tmp);
end;
procedure TCibFacCabina.mnPausarCuent(Sender: TObject);
begin
  if cabCuenta.estado <> EST_CONTAN then begin
    MsgExc('No se puede pausar una cabina en este estado.');
    exit;
  end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_PONPAU, 0, IdFac);
end;
procedure TCibFacCabina.mnReinicCuent(Sender: TObject);
begin
  if cabCuenta.estado <> EST_PAUSAD then begin
    MsgExc('La cabina no está en pausa.');
    exit;
  end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_QUIPAU, 0, IdFac);
end;
procedure TCibFacCabina.mnVerExplorad(Sender: TObject);
{Muestra el explorador de archivos}
begin
  frmExpArc.rutArchivos := rutArchivos;  //Actualiza ruta de archivos de descarga
  frmExpArc.Exec(self);
end;
procedure TCibFacCabina.mnVerMsjesRed(Sender: TObject);
{Muestra el formulario para ver los mensajes de red.}
begin
  frmVisMsj.Exec(Nombre);
end;
procedure TCibFacCabina.mnEncenderPC(Sender: TObject);
{Fija el tiempo inicial de una cabina.}
begin
  if EstadoCta = EST_MANTEN then begin
    if MsgYesNo('Cabina en mantenimiento. ¿Encender?') <> 1 then exit;
  end;
  MsgBox('Encendiendo');
  //Fija minutos
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_ENCEPC, 0, IdFac);
end;
procedure TCibFacCabina.mnFijTiempoIni(Sender: TObject);
{Fija el tiempo inicial de una cabina.}
var
  nnStr: String;
  nn: Longint;
begin
  if EstadoCta = EST_MANTEN then begin
    if MsgYesNo('¿Sacar cabina de mantenimiento?') <> 1 then exit;
//  end else if not Detenida then begin
//    msgExc('No se puede iniciar una cuenta en esta cabina.');
//    exit;
  end;
  //Lee número de minutos
  nnStr := InputBox('', 'Número de minutos:', '');
  if nnStr='' then exit;
  if not TryStrToInt(nnStr, nn) then begin
    MsgExc('Error en número');
    exit;
  end;
  //Fija minutos
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJCTA, nn, IdFac);
end;
procedure TCibFacCabina.LimpiarCabina;
//Pone la cabina limpia sin tiempos ni cuentas
begin
  cabCuenta.Limpiar;
end;
//Constructor y destructor
constructor TCibFacCabina.Create(nombre0: string; ip0: string);
begin
  inherited Create;
  tipGFac := ctfCabinas;  //se identifica
  FNombre := nombre0;
  //Crea objetos de cuenta y conexión
  cabCuenta:= TCabCuenta.Create;  //Estado de cabina
  cabConex := TCabConexion.Create(ip0);  //conexión
  cabConex.OnCambiaEstado:=@cabCambiaEstadoConex;
  cabConex.OnTramaLista:=@cabConexTramaLista;
  cabConex.OnRegMensaje:=@cabConexRegMensaje;
  cabCuenta.estado := EST_NORMAL;  //inicia en este estado
  ConConexion := false;
  SinRed := false;
  //Crea formulario explorador de archivos y visor de mensajes
  frmExpArc := TfrmExplorCab.Create(nil);
  frmVisMsj := TfrmVisorMsjRed.Create(nil);
end;
constructor TCibFacCabina.CreateSinRed;
{Crea al objeto para usarlo solo como contenedor de propiedades.}
begin
  Create('','');
  SinRed := true;
end;
destructor TCibFacCabina.Destroy;
begin
  frmExpArc.Destroy;
  cabConex.Destroy;
  cabCuenta.Destroy;
  inherited Destroy;
  FreeAndNil(frmVisMsj);  //destruye al final porque pueden aparecer nuevos mensajes
end;
{ TCibGFacCabinas }
procedure TCibGFacCabinas.timer1Timer(Sender: TObject);
{Temporiza a las cabinas para que actualicen sus prOpiedades internas.
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
class function TCibGFacCabinas.CodCadEstado(_Nombre: string): string;
{Codifica la cadena de estado, a partir de las variables indicadas. Se pone como
método de clase para poder usarse sin crear instancias,}
begin
  Result := _Nombre + #9 + #9 + LineEnding;
end;
class procedure TCibGFacCabinas.DecodCadEstado(str: String; out _Nombre: string);
{Decodifica la cadena de estado, a partir de las variables indicadas. Se pone como
método de clase para poder usarse sin crear instancias,}
var
  a: TStringDynArray;
begin
  a := Explode(#9, str);     //separa campos
  _Nombre := a[0];
end;
function TCibGFacCabinas.GetCadEstado: string;
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
procedure TCibGFacCabinas.SetCadEstado(AValue: string);
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
procedure TCibGFacCabinas.cab_TramaLista(idFacOrig: string; tram: TCPTrama);
begin
  if OnTramaLista<>nil then OnTramaLista(idFacOrig, tram);
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
class function TCibGFacCabinas.CodCadPropied(_Nombre, _CategVenta: string; _x,
  _y: Single; strTarAlquiler, strTarif: string): string;
begin
  Result := _Nombre + #9 + _CategVenta + #9 + N2f(_x) + #9 + N2f(_y) + #9 + #9 + LineEnding +
  //Información de las tarifas de alquiler
            strTarAlquiler + LineEnding +
            strTarif;
end;
class procedure TCibGFacCabinas.DecodCadPropied(lineas: TStringList; out
  _Nombre, _CategVenta: string; out _x, _y: Single; out strGrupTar,
  strTarif: string);
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
  //Busca líneas con información de Grupos de Tarifas de Alquiler
  strGrupTar := '';
  while lineas[0][1] = '+' do begin
    //Acumula
    strGrupTar := strGrupTar + lineas[0] + LineEnding;
    lineas.Delete(0);  //elimima línea
  end;
  TrimEndLine(strGrupTar);
  //Busca líneas con información de Tarifas de Alquiler
  strTarif := '';
  while (lineas.Count>0) and (lineas[0][1] = '*') do begin
    //Acumula
    strTarif := strTarif + lineas[0] + LineEnding;
    lineas.Delete(0);  //elimima línea
  end;
  TrimEndLine(strTarif);
end;
function TCibGFacCabinas.GetCadPropied: string;
var
  c : TCibFac;
begin
  //Información del grupo en la primera línea
  Result := CodCadPropied(Nombre, CategVenta, Fx, Fy, grupTar.StrObj, tarif.StrObj);
  //Información de las cabinas en las demás líneas
  for c in items do begin
    Result := Result + LineEnding + c.CadPropied ;
  end;
end;
procedure TCibGFacCabinas.SetCadPropied(AValue: string);
var
  lineas: TStringList;
  cab: TCibFacCabina;
  lin, strGrupTar, strTarif: String;
begin
  if AValue = '' then exit;
  lineas := TStringList.Create;
  lineas.Text := AValue;

  DecodCadPropied(lineas, Nombre, CategVenta, Fx, Fy, strGrupTar, strTarif);
  grupTar.StrObj := strGrupTar;
  tarif.StrObj := strTarif;

  //Procesa líneas con información de las cabinas
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    cab := Agregar('','');
    cab.CadPropied := lin;
  end;
  lineas.Destroy;
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
procedure TCibGFacCabinas.MuestraConexionCabina;  //para depuración
var
  c : TCibFac;
begin
  for c in items do begin
    debugln('  Nomb:' + c.Nombre + ' SinRed:' + B2f(TCibFacCabina(c).SinRed));
  end;
end;
//Operaciones con cabinas
function TCibGFacCabinas.EscribeLog(identif: char; mensaje : String): integer;
{Escribe en la tabla histórica de este grupo.}
var
  NombProg, NombLocal: string;
  ModDiseno: boolean;
begin
  if ModoCopia then exit;  //En modo copia, no genera registro
  if arclog.arclog = '' then begin
    //No se ha abierto aún, el registro
    if OnReqConfigGen<>nil then  //Pide información global
        OnReqConfigGen(NombProg, NombLocal, ModDiseno);
    //Abre archivo de rgeistro para este enrutador
    arcLog.AbrirPLog(rutDatos, NombLocal, Nombre);
    //Puede generar error
    If arcLog.msjError <> '' Then MsgErr(arcLog.msjError);
  end;
  //Escribe en registro
  Result := arcLog.PLogVenta(identif, mensaje, 0);
end;
procedure TCibGFacCabinas.TCP_envComando(nom: string; comando: TCPTipCom; ParamX,
  ParamY: word; cad: string = '');
var
  cab: TCibFacCabina;
begin
  cab := CabPorNombre(nom);
  if cab = nil then exit;
  cab.TCP_envComando(comando, ParamX, ParamY, cad);
end;
procedure TCibGFacCabinas.EjecRespuesta(comando: TCPTipCom; ParamX,
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
procedure TCibGFacCabinas.EjecAccion(idFacOrig: string; tram: TCPTrama);
{Ejecuta la acción sibre este grupo. Si la acción es para uno de sus facturables, le
pasa la trama, para su ejecución.}
var
  traDat, nom, strGrupTar, strTarif: String;
  facDest: TCibFac;
  Err: boolean;
  lineas: TStringList;
begin
debugln('Acción solicitada a GFacCabinas:' + tram.TipTraNom);
  if tram.tipTra = CFAC_GCABIN then begin
    //Es una acción dirigida a este grupo
    case tram.posX of  //Se usa el parámetro para ver la acción
    //Comandos locales. No llegan directamente hasta la PC remota
    C_GCAB_ACTTAR: begin   //Actualizar las tarifas del grupo
        //Extrae la cadena de tarifas y grupos de tarifas
        traDat := tram.traDat;
        ExtraerHasta(traDat, #9, Err);  //Extrae nombre de grupo
        //Prepara extración
        lineas := TStringList.Create;
        lineas.Text :=traDat;
        //Extrae texto de las líneas
        strGrupTar := '';
        while lineas[0][1] = '+' do begin
          //Acumula
          strGrupTar := strGrupTar + lineas[0] + LineEnding;
          lineas.Delete(0);  //elimima línea
        end;
        TrimEndLine(strGrupTar);
        strTarif := '';
        while (lineas.Count>0) and (lineas[0][1] = '*') do begin
          //Acumula
          strTarif := strTarif + lineas[0] + LineEnding;
          lineas.Delete(0);  //elimima línea
        end;
        TrimEndLine(strTarif);
        //Actualiza objetos
        grupTar.StrObj := strGrupTar;
        tarif.StrObj := strTarif;
        //Termina
        lineas.Destroy;
      end;
    C_GCAB_ADMEQU: begin
      frmAdminCabs.Show;
    end;
    end;
  end else begin
    //Es una acción dirigida a un Facturables
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
procedure TCibGFacCabinas.MenuAccionesVista(MenuPopup: TPopupMenu);
begin
  InicLlenadoAcciones(MenuPopup);
  //No hay acciones, aún, para el Grupo Cabinas
end;
procedure TCibGFacCabinas.MenuAccionesModelo(MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  InicLlenadoAcciones(MenuPopup);
  nShortCut := -1;
  AgregarAccion(nShortCut, 'Administrador de &Tarifas', @mnAdminTarifas, icoAdminTarifas);
  AgregarAccion(nShortCut, 'Administrador de &Equipos', @mnAdminEquipos, icoAdminEquipos);
  AgregarAccion(nShortCut, '&Propiedades', @mnPropiedades, icoPropiedades);
end;
procedure TCibGFacCabinas.mnAdminTarifas(Sender: TObject);
begin
  frmAdminTar.Show;
end;
procedure TCibGFacCabinas.mnAdminEquipos(Sender: TObject);
begin
  frmAdminCabs.Show;
end;
//constructor y destructor
constructor TCibGFacCabinas.Create(nombre0: string; ModoCopia0: boolean);
begin
  inherited Create(nombre0, ctfCabinas);
  FModoCopia := ModoCopia0;    //Asigna al inicio para saber el modo de trabajo
//debugln('-Creando: '+ nombre0);
//Se incluye un objeto TGrupoTarAlquiler para la tarificación
  grupTar := TGrupoTarAlquiler.Create;
  tarif := TCPTarifCabinas.Create(grupTar);
  timer1 := TTimer.Create(nil);
  timer1.Interval:=1000;
  timer1.OnTimer:=@timer1Timer;
  CategVenta := 'COUNTER';
  //Crea ventana de configuración de tarifas
  frmAdminTar:= TfrmAdminTarCab.Create(nil);
  frmAdminTar.grpTarAlq := grupTar;
  frmAdminTar.tarCabinas := tarif;
  frmAdminTar.OnModificado:=@fac_CambiaPropied;  //para actualizar cambios
  if grupTar.items.Count=0 then begin
    //agrega una tarifa de alquiler por defecto
    frmAdminTar.IniciarPorDefecto;  { TODO : Ver si es necesario }
    frmAdminTar.BitAplicarClick(nil);
  end;
  //Crea ventana de administración de cabinas
  frmAdminCabs:= TfrmAdminCabinas.Create(nil);
  frmAdminCabs.grpCab := self;  //inicia admin. de cabinas
  //Crea archivo de registro
  arcLog := TCibTablaHist.Create;
end;
destructor TCibGFacCabinas.Destroy;
var
  c : TCibFac;
begin
  arcLog.Destroy;
//debugln('-destruyendo: '+ Nombre + ','+IntToStr(Ord(tipGFac))+','+
//                          CategVenta+','+IntTostr(items.Count));
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
  timer1.OnTimer:=nil;
  timer1.Destroy;
  tarif.Destroy;
  {Envía la señal de desconexión a todas las cabinas de golpe, para que la destrucción
  de la lista, no se haga muy lenta}
  for c in items do begin
    TCibFacCabina(c).Desconectar;
  end;
  grupTar.Destroy;
  inherited Destroy;  {Aquí se hace items.Destroy, que puede demorar por los hilos}
end;

end.

