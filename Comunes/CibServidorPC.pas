{Unidad para implementar un servior TCP/IP usando la librería Synapse. Este servidor
 representará al servidor que debe residir en las cabinas cliente, ya que en el esquema
 de conexión de CiberPlex, a las cabinas cliente se les conecta como si fueran servidores.
 También se usa para conectar los Puntos de Venta adicionales y el módulo Admin, al
 servidor de CIBERPLEX.
 La clase principal es TCibServidorPC, que es un hilo, que hace la comunicación con el
 exterior, usando eventos sincronizados.


                                               Por Tito Hinostroza   05/2015.     }
unit CibServidorPC;  {$mode objfpc}{$H+}
interface
uses
  Classes, blcksock, synsock, lclproc, dialogs, sysutils, MisUtils, CibTramas;
const
  MSJ_CONEX_DETECTADA = 'Conexión detectada...';
  MSJ_REINIC_CONEX = 'Reiniciando conexión...';
type

  TThreadSockServer = class(TCibConexBase)
  private
    pilaCmds: TPilaCom;          //Pila de comandos
    procedure ProcConex(Hsock: TSocket);
  public
    estad_tra: integer;
    procedure EnviaArchivo(tipCom: TCPTipCom; archivo: String);
    procedure Execute; override;
    //Manejo de Comandos
    procedure PonerComando(tipCom: TCPTipCom; ParamX, ParamY: word;
      const datos: string='');
    function HayComando: boolean;
  public //Constructor y destructor
    Constructor Create;
    Destructor Destroy; override;
  end;

  { TCibServidorPC }
  {Esta clase se usa como una envoltura para administrar la conexión con
   TThreadSockServer, ya que es un hilo, y el manejo directo se hace problemático, por
   las peculiaridades que tienen los hilos.
   }
  TCibServidorPC = class
  private
    function GetEstado: TCibEstadoConex;
    procedure hiloCambiaEstado(nuevoEstado: TCibEstadoConex);
    procedure hiloRegMensaje(NomPC: string; msj: string);
    procedure hiloTramaLista(NomPC: string; tram: TCPTrama);
    procedure SetEstado(AValue: TCibEstadoConex);
  public
    hilo : TThreadSockServer;
    OnCambiaEstado: TEvCambiaEstado;
    OnRegMensaje  : TEvRegMensaje;  //Indica que ha llegado un mensaje de la conexión
    OnTramaLista  : TEvTramaLista;  //Indica que hay una trama lista esperando
    procedure PonerComando(tipCom: TCPTipCom; ParamX, ParamY: word;
      const datos: string='');
    function Conectado: boolean;
    function EstadoConexStr: string;
    procedure EnviaArchivo(tipCom: TCPTipCom; archivo: String);
    property Estado: TCibEstadoConex read GetEstado write SetEstado;
    function HayComando: boolean;
  public
    constructor Create;
    destructor Destroy; override;
  end;


implementation

function TCibServidorPC.GetEstado: TCibEstadoConex;
begin
  Result := hilo.Estado;
end;

procedure TCibServidorPC.hiloCambiaEstado(nuevoEstado: TCibEstadoConex);
begin
  if OnCambiaEstado<>nil then OnCambiaEstado(nuevoEstado);
end;

procedure TCibServidorPC.hiloRegMensaje(NomPC: string; msj: string);
begin
  if OnRegMensaje<>nil then OnRegMensaje(NomPC, msj);
end;

procedure TCibServidorPC.hiloTramaLista(NomPC: string; tram: TCPTrama);
begin
  if OnTramaLista<>nil then OnTramaLista(NomPC, tram);
end;

procedure TCibServidorPC.SetEstado(AValue: TCibEstadoConex);
begin
  hilo.Estado := AValue;
end;

{ TCibServidorPC }
procedure TCibServidorPC.PonerComando(tipCom: TCPTipCom; ParamX, ParamY: word;
  const datos: string);
begin
  hilo.PonerComando(tipCom, ParamX, ParamY, datos);
end;

function TCibServidorPC.Conectado: boolean;
begin
  Result := hilo.Conectado;
end;

function TCibServidorPC.EstadoConexStr: string;
begin
  Result := hilo.EstadoConexStr;
end;

procedure TCibServidorPC.EnviaArchivo(tipCom: TCPTipCom; archivo: String);
begin
  hilo.EnviaArchivo(tipCom, archivo);
end;

function TCibServidorPC.HayComando: boolean;
begin
  Result := hilo.HayComando;
end;

constructor TCibServidorPC.Create;
begin
  hilo := TThreadSockServer.Create;
  hilo.OnCambiaEstado := @hiloCambiaEstado; //para detectar cambios de estado
  hilo.OnRegMensaje := @hiloRegMensaje;     //Para recibir mensajes
  hilo.OnTramaLista := @hiloTramaLista;
end;
destructor TCibServidorPC.Destroy;
begin
  hilo.OnTramaLista:=nil;  //para evitar eventos al morir
  hilo.OnRegMensaje:=nil;  //para evitar eventos al morir
  hilo.Terminate;
  hilo.WaitFor;
  hilo.Destroy;
  inherited Destroy;
end;

procedure TThreadSockServer.EnviaArchivo(tipCom: TCPTipCom; archivo : String);
//Envía una archivo como parte de la trama. Debe indicarse un comando
//que incluya un archivo como datos.
begin
  if estad_tra <> EST_ESPERANDO then exit;
  PonerComando(tipCom, 0, 0, StringFromFile(archivo));
End;

{ TThreadSockServer }
procedure TThreadSockServer.Execute;
var
  ClientSock:TSocket;
  nIntentos: Integer;
begin
  try
    sock.CreateSocket;
    sock.setLinger(true,10000);
    sock.bind('0.0.0.0','80');  //0.0.0.0 hace que se escuche en todas las interfaces
    sock.listen;
    nIntentos := 0;
    while not terminated do begin
      Estado := cecConectando;
      if sock.canread(100) then begin
          RegMensaje(MSJ_CONEX_DETECTADA);  //Conexión detectada
          ClientSock := sock.accept;
          if sock.lastError=0 then ProcConex(ClientSock);
      end else begin
//         RegMensaje('Conexión fallida.');
         inc(nIntentos);
         if nIntentos > 50 then begin
           nIntentos := 0;
           RegMensaje(MSJ_REINIC_CONEX);  //Reiniciando coenxión
           //Intenta reabrir la conexión
           sock.CloseSocket;
           sock.CreateSocket;
           sock.setLinger(true,10000);
           sock.bind('0.0.0.0','80');  //0.0.0.0 hace que se escuche en todas las interfaces
           sock.listen;
         end;
      end;
    end;
  except

  end;
end;
procedure TThreadSockServer.ProcConex(Hsock:TSocket);
{Rutina de lazo del servidor, para procesar los paquetes recibidos.
 Se supone que si entra aquí, es porque ya se tiene conexión.}
var
  s: string;
  sock2: TTCPBlockSocket;
begin
  Estado := cecConectado;
  RegMensaje('Procesando conexión...');
  sock2:=TTCPBlockSocket.create;
  try
    sock2.socket:=Hsock;
    sock2.GetSins;
    while not terminated do begin
      s := sock2.RecvPacket(6000);   //Si no hay datos, espera hasta que llegen
      if sock2.lastError<>0 then break;
      //------------procesa los datos------------
      ProcTrama.DatosRecibidos(s, @ProcesarTrama);
      //verifica si hay trama de respuesta
      if Not pilaCmds.HayComando then begin //no hay respuesta
        RegMensaje('   Enviado: M_PRESENCIA...');  {En realidad no es necesario, que se
                       envíe, un mensaje cada vez que se reciben datos, ya que en tramas
                       largas, que vienen en varios bloques, se está respondiendo con
                       múltiples mensajes.}
        sock2.SendString(GenEncabez(0, M_PRESENCIA));  //envía solo presencia
      end else begin  //Envía el comando más antiguo
        RegMensaje('   Enviado: ' + pilaCmds.PrimerComando.TipTraNom);
        sock2.SendString(pilaCmds.PrimerComando.Encab);
        sock2.SendString(pilaCmds.PrimerComando.traDat);
        pilaCmds.QuitarComando;  //quita de la pila
      end;
      if sock2.lastError<>0 then break;
      //-----------------------------------------
    end;
  finally
    sock2.Free;
  end;
end;
//Manejo de Comandos
procedure TThreadSockServer.PonerComando(tipCom: TCPTipCom; ParamX, ParamY: word; const datos: string = '');
//Similar pero solo envía un comando, con datos
begin
  pilaCmds.PonerComando(tipCom, ParamX, ParamY, datos);
end;
function TThreadSockServer.HayComando: boolean;
begin
  Result := pilaCmds.HayComando;
end;
//Constructor y destructor
constructor TThreadSockServer.Create;
begin
  FEstado := cecDetenido; {Estado inicial. Este estado es solo temporal, se fija
              así para que se genere el evento OnCambiaEstado, al pasar al estado de
              "conectando", en el Execute(). Notar que esta asignación de estado, no
              generará el evento de cambio de estado.}
  pilaCmds := TPilaCom.Create;
  inherited Create(false);
end;
destructor TThreadSockServer.Destroy;
begin
  pilaCmds.Destroy;
  inherited Destroy;
end;
end.
