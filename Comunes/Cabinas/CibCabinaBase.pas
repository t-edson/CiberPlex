{Contiene las definiciones básicas que se necesitan para el objeto TCibFacCabina.
Contiene la definición de las siguientes clases:

* TThreadSockCabina-> Es un hilo, que se se usa para abrir una conexión Ethernet a la cabina.
                 A TThreadSockCabina no debe accederse directamente. Tiene su propia temporización
                 y rutinas de reconexión para mantener el enlace con la cabina remota.

* TCabConexion -> Es como una envoltura para el hilo TThreadSockCabina. Facilita el manejo
                 de la conexión por red, ya que administrar directamente al hilo, requiere
                 un cuidado mayor.
* TCabCuenta -> Contiene los parámetros de la cuenta de la cabina.

La conexión por red se implementa usando un hilo, porque la librería usada, solo
ofrece coenxiones con bloqueo, y lo que se desea es manejar la conexión por eventos.
Las únicas clases que debe usarse desde el exterior son "TCabConexion" y "TCabCuenta".

La conexión por Red se implementa usando sockets con la librería "Synapse".

                                  Por Tito Hinostroza  27/09/2015
}
unit CibCabinaBase;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, LCLProc, MisUtils, blcksock, CibTramas, synamisc;
type
  //Estado de conteo de las cabinas.
  TcabEstadoCuenta = (
    EST_NORMAL = 0,     //estado normal, sin contéo
    EST_CONTAN = 1,     //estado contando
    EST_PAUSAD = 2,     //estado pausado
    EST_MANTEN = 3      //estado en mantenimiento
  );

  { TCabCuenta }
  {Agrupa a las propiedades que definen el estado de cuenta de la cabina}
  TCabCuenta = class
  private
    FCadConteo: string;
    function GetCadConteo: string;
    function GetEstadoN: integer;
    procedure SetCadConteo(AValue: string);
    procedure SetEstadoN(AValue: integer);
  public
    estado      : TcabEstadoCuenta;  //estado de la cabina
    hor_ini     : TDateTime;   //hora de inicio de alquiler
    tSolic      : TDateTime;   //tiempo solicitado
    tLibre      : boolean;     //Indica si tiene tiempo libre
    horGra      : boolean;     //Indica si tiene hora gratis
    //campos calculados
    property estadoN: integer read GetEstadoN write SetEstadoN;   //estado como entero
    function estadoStr: string;  //estado en texto
    function tSolicSeg: integer; //tiempo solicitado en segundos
    procedure Limpiar;
    property CadConteo: string read GetCadConteo write SetCadConteo;
  public
    constructor Create;
  end;

type

  { TThreadSockCabina }
  {Esta clase es la conexión a la cabina. Es un hilo para manejar las conexiones de
   manera asíncrona. Está pensada para ser usada solo por TCabConexion.
   El ciclo de conexión normal de TThreadSockCabina es:
   cecConectando -> cecConectado }
  TThreadSockCabina = class(TCibConexBase)
  private
    ip: string;
    procedure AbrirConexion;
    procedure Abrir;
  protected
    procedure Execute; override;
  public
    //Eventos. Se ejecutan de forma sincronizada.
    procedure TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string=
      '');
    constructor Create(ip0: string);
    Destructor Destroy; override;
  end;

  { TCabConexion }
  {Se usa esta clase como una envoltura para administrar la conexión TThreadSockCabina,
   ya que es un hilo, y el manejo directo se hace problemático, por las peculiaridades
   que tienen los hilos.
   El ciclo de conexión normal de TCabConexion es:
   cecMuerto -> cecConectando -> cecConectado -> cecMuerto
   Cuando se pierde la conexión puede ser:
   cecMuerto -> cecConectando -> cecConectado -> cecConectando -> cecConectado -> ...
   }
  TCabConexion = class
    procedure hiloCambiaEstado(nuevoEstado: TCibEstadoConex);
    procedure hiloRegMensaje(NomCab: string; msj: string);
    procedure hiloTerminate(Sender: TObject);
    procedure hiloTramaLista(NomCab: string; tram: TCPTrama);
  private
    FIP: string;
    Festado: TCibEstadoConex;
    hilo: TThreadSockCabina;
    function GetEstadoN: integer;
    procedure SetEstadoN(AValue: integer);
    procedure SetIP(AValue: string);
  public
    mac : string;   //Dirección Física
    property estado: TCibEstadoConex read Festado
             write Festado;   {"estado" es una propiedad de solo lectura, pero se habilita
                               la escritura, para cuando se usa CabConexión sin Red}
    property estadoN: integer read GetEstadoN write SetEstadoN;
    function estadoStr: string;
    property IP: string read FIP write SetIP;
    procedure SendWakeOnLan;
  public
    OnCambiaEstado: TEvCambiaEstado;
    OnRegMensaje  : TEvRegMensaje;  //Indica que ha llegado un mensaje de la conexión
    OnTramaLista  : TEvTramaLista;  //Indica que hay una trama lista esperando
    MsjError: string;       //Mensajes de error producidos.
    MsjesCnx: TstringList;  //Almanena los últimos mensajes de la conexión.
    procedure Conectar;
    procedure Desconectar;
    procedure TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string = '');
    constructor Create(ip0: string);
    destructor Destroy; override;
  end;

  function CodCadConteo(const tSolic0: TDateTime; const tLibre0, horGra0: boolean): string;
  procedure DecodCadConteo(const cadConteo: string;
                         out tSolic0: TDateTime; out tLibre0, horGra0: boolean);

implementation
const
  MAX_LIN_MSJ_CNX = 10;  //Cantidad máxima de líneas que se guardarán de los msjes de conexión.

  function CodCadConteo(const tSolic0: TDateTime; const tLibre0, horGra0: boolean): string;
  {Codifica los campos usuales, para iniciar o modificar el conteo de la cabina.}
  begin
    Result := D2f(tSolic0)+ #9 +
              B2f(tLibre0)+ #9 +
              B2f(horGra0);
  end;
  procedure DecodCadConteo(const cadConteo: string;
                           out tSolic0: TDateTime; out tLibre0, horGra0: boolean);
  var
    campos: TStringDynArray;
  begin
    campos := Explode(#9, cadConteo);
    tSolic0 := f2D(campos[0]);
    tLibre0 := f2B(campos[1]);
    horGra0 := f2B(campos[2]);
  end;

{ TCabCuenta }
function TCabCuenta.tSolicSeg: integer;
begin
  Result := round(tSolic*86400)
end;
procedure TCabCuenta.Limpiar;
begin
 estado := EST_NORMAL;

 horgra := False;
 tlibre := False;
end;
function TCabCuenta.GetEstadoN: integer;
begin
  Result := Ord(estado);
end;
function TCabCuenta.GetCadConteo: string;
begin
 Result := CodCadConteo(tSolic, tLibre, horGra);
end;
procedure TCabCuenta.SetCadConteo(AValue: string);
var
  campos: TStringDynArray;
begin
  DecodCadConteo(AValue, tSolic, tLibre, horGra);
end;
procedure TCabCuenta.SetEstadoN(AValue: integer);
begin
  estado := TcabEstadoCuenta(AValue);
end;
function TCabCuenta.estadoStr: string;
begin
  case estado of
  EST_NORMAL: Result := 'Normal';
  EST_CONTAN: Result := 'Contando';
  EST_MANTEN: Result := 'En Mantenimiento';
  EST_PAUSAD: Result := 'Pausado';
  end;
end;
constructor TCabCuenta.Create;
begin
  estado := EST_NORMAL;
  {Inicia una fecha actual para que no cuente desde el año 1900, y desborde la variable
   entera de segundso transcurridos}
  hor_ini := date;
end;

{ TThreadSockCabina }
procedure TThreadSockCabina.Abrir;
{Intenta abrir una conexión}
begin
  estado := cecConectando;
  sock.Connect(ip, '80');  {Se bloquea unos segundo si no logra la conexión. No hay forma
                           directa de fijar un "Timeout", ya que depende de la implementación
                           del Sistema Operativo}
  if sock.LastError <> 0 then begin
    RegMensaje('Error de conexion.');
    { Genera temporización por si "sock.Connect", sale inmediátamente. Esto suele suceder
     cuando hay un error de red. }
    sleep(1000);
    exit;          //falló
  end;
  estado := cecConectado;
end;
procedure TThreadSockCabina.AbrirConexion;
begin
 RegMensaje('Abriendo puerto ...');
 repeat
   Abrir;  //puede tomar unos segundos
 until (estado = cecConectado) or Terminated;
end;
//Acciones sincronizadas
procedure TThreadSockCabina.Execute;
var
  buffer: String = '';
  tics: Integer;
  ticsSinRecibir: Integer;
begin
  AbrirConexion;
  if terminated then exit;  //por si se canceló
  //Aquí ya logró AbrirConexion el socket con el destino, debería haber control
  tics := 0;   //inicia cuenta
  ticsSinRecibir := 0;   //inicia cuenta
  RegMensaje('Enviando C_PRESENCIA.');
  sock.SendString(GenEncabez(0, C_PRESENCIA)); //tal vez debe verificarse primero si se puede enviar
  RegMensaje('Esperando respuesta ...');
  while not terminated do begin
    buffer := sock.RecvPacket(0);
    if buffer <> '' then begin
      // Hubo datos
      //n := length(buffer);
      //RegMensaje(IntToStr(n) +  ' bytes leídos.');
      tics := 0;
      ticsSinRecibir := 0;
      ProcTrama.DatosRecibidos(buffer, @ProcesarTrama);
    end;
    Inc(tics);
    Inc(ticsSinRecibir);
//    if tics mod 10 = 0 then RegMensaje('  tic=' + IntToStr(tics));
    if tics>60 then begin
      //No se ha enviado ningún comando en 6 segundos. Genera uno propio.
      RegMensaje('Enviando C_PRESENCIA.');
      sock.SendString(GenEncabez(0, C_PRESENCIA));
      tics := 0;
    end;
    if ticsSinRecibir>100 then begin
      //probablemente se cortó la conexión
      RegMensaje('Conexión perdida.');
      sock.CloseSocket;  //cierra conexión
      AbrirConexion;
      ticsSinRecibir := 0;
    end;
    sleep(100);  //periodo del lazo
  end;
end;
procedure TThreadSockCabina.TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word;
  cad: string='');
{Envía una trama sencilla de datos, al socket. }
var
  s: string;
begin
  if estado <> cecConectado then
    exit;
  //Se debe enviar una trama
  writestr(s, comando);
  RegMensaje('  >>Enviado: ' + s + ' ');
  //ENvía
  if cad='' then begin
    //es una ProcTrama simple
    sock.SendString(GenEncabez(0, comando, ParamX, ParamY ));
  end else begin
    sock.SendString(GenEncabez(length(cad), comando, ParamX, ParamY ));
    sock.SendString(cad);
  end;
end;
constructor TThreadSockCabina.Create(ip0: string);
begin
  ip := ip0;
  Festado := cecConectando; {Estado inicial. Aún no está conectando, pero se asume que
                             está en proceso de conexión. Además, no existe estado
                             "cecDetenido" para TThreadSockCabina.
                             Notar que esta asignación de estado, no generará el evento de
                             cambio de estado, porque estamos en el constructor}
  inherited Create(true);  //crea suspendido
end;
destructor TThreadSockCabina.Destroy;
begin
  inherited Destroy;
end;

{ TCabConexion }
procedure TCabConexion.hiloCambiaEstado(nuevoEstado: TCibEstadoConex);
begin
  if Festado = nuevoEstado then exit;
  Festado := nuevoEstado;
  if OnCambiaEstado<>nil then OnCambiaEstado(Festado);
end;
procedure TCabConexion.hiloRegMensaje(NomCab: string; msj: string);
begin
  //debugln(nombre + ': '+ msj);
  MsjesCnx.Add(msj);  //Agrega mensaje
  //Mantiene tamaño, eliminando los más antiguos
  while MsjesCnx.Count>MAX_LIN_MSJ_CNX do begin
    MsjesCnx.Delete(0);
  end;
  if OnRegMensaje<>nil then OnRegMensaje('', msj);
end;
procedure TCabConexion.hiloTramaLista(NomCab: string; tram: TCPTrama);
begin
  //debugln(nombre + ': Trama recibida: '+ IntToStr(tram.tipTra));
  if OnTramaLista<>nil then OnTramaLista('', tram);
end;
procedure TCabConexion.hiloTerminate(Sender: TObject);
begin
  { Se ha salido del Execute() y el hilo ya no procesa la conexión. El hilo pasa a un
  estado suspendido, pero aún existe el objeto en memoria, porque no se le define con
  auto-destrucción.}
 hiloCambiaEstado(cecDetenido);
end;
function TCabConexion.estadoStr: string;
{Convierte TCibEstadoConex a cadena}
begin
 Result := EstadoConexACadena(Festado);
end;
procedure TCabConexion.SendWakeOnLan;
{Enciende remotamente una cabina}
begin
  WakeOnLan(mac, '');
end;
procedure TCabConexion.SetIP(AValue: string);
begin
  //solo se puede cambiar la IP cuando no hay conexión
  if estado in [cecMuerto, cecDetenido] then begin
    FIP:=AValue;
  end else begin
    self.MsjError := 'No se puede cambiar la IP de una cabina con conexión.';
  end;
end;
function TCabConexion.GetEstadoN: integer;
begin
  Result := ord(Festado);
end;
procedure TCabConexion.SetEstadoN(AValue: integer);
begin
 Festado := TCibEstadoConex(AValue);
end;
procedure TCabConexion.Conectar;
{Crea el hilo con la IP actual e inicia la conexión}
begin
  if Festado in [cecConectando, cecConectado] then begin
    // El hilo ya existe, y esta conectado o en proceso de conexión.
    { TODO : Para ser más precisos se debería ver si se le ha dado la orden de terminar
    el hilo mirando hilo.Terminated. De ser así, la muerte del hilo es solo cuestion
    de tiempo, (milisegundos si está en estado cecConectado o segundos si está en
    estado cecConectando)
    }
    exit;
  end;
  if Festado = cecDetenido then begin
    // El proceso fue terminado, tal vez porque dio error.
    hilo.Destroy;   //libera referencia
    hilo := nil;
    //Festado := cecMuerto;  //No es muy útil, fijar este estado, porque seguidamente se cambiará
  end;
  hilo := TThreadSockCabina.Create(FIP);
  hilo.OnCambiaEstado := @hiloCambiaEstado; //Para detectar cambios de estado
  hilo.OnCambiaEstado(hilo.estado);         //Genera el primer evento de estado
  hilo.OnTerminate    := @hiloTerminate;    //Para detectar que ha muerto
  hilo.OnRegMensaje   := @hiloRegMensaje;   //Para recibir mensajes
  hilo.OnTramaLista   := @hiloTramaLista;
  // Inicia el hilo. Aquí empezará con el estado "Conectando"
  hilo.Start;
end;
procedure TCabConexion.Desconectar;
begin
  if Festado = cecMuerto then begin
    exit;  //Ya está muerto el proceso, o está a punto de morir
  end;
  // La única forma de matar al proceso es dándole la señal
  hilo.Terminate;
  {puede tomar unos segundos hasta que el hilo pase a estado suspendido (milisegundos si está
  en estado cecConectado o segundos si está en  estado cecConectando)
  }
end;
procedure TCabConexion.TCP_envComando(comando: TCPTipCom; ParamX, ParamY: word;
  cad: string = '');
begin
  if estado<>cecConectado then
    exit;
  hilo.TCP_envComando(comando, ParamX, ParamY, cad);
end;
constructor TCabConexion.Create(ip0: string);
begin
  MsjesCnx:= TstringList.Create;
  FIP := ip0;
  Festado := cecMuerto;  //este es el estado inicial, porque no se ha creado el hilo
  //Conectar;  //No inicia la conexión
end;
destructor TCabConexion.Destroy;
begin
  //Verifica si debe detener el hilo
  if Festado<>cecMuerto then begin
    if hilo = nil then begin
      {Este es un caso especial, cuando no se llegó a conectar nunca al hilo o cuando se
       usa a TCabConexion, sin red. Por los tanto no se crea nunca el hilo}
    end else begin
      //Caso normal en que se ha creado el hilo
      hilo.Terminate;
      hilo.WaitFor;  //Si no espera a que muera, puede dejarlo "zombie"
      hilo.Destroy;
      //estado := cecMuerto;  //No es útil fijar el estado aquí, porque el objeto será destruido
    end;
  end;
  MsjesCnx.Destroy;
  inherited Destroy;
end;

end.
//470
