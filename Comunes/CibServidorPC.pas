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
  TEvRegMensaje = procedure(msj: string) of object;
  TEvTramaLista = procedure(tram: TCPTrama) of object;

  { TCibServidorPC }
  TCibServidorPC = class(TThread)
  private
    Sock   : TTCPBlockSocket;
    pilaCmds : TPilaCom;  //pila de comandos
    regMsje: string;   //Usada como para pasar parámetro a EventoMensaje()
    ProcTrama: TCPProcTrama; //Para procesar tramas
    procedure EventoTramaLista;
    procedure EventoRegMensaje;
    procedure ProcConex(Hsock: TSocket);
    procedure ProcesarTrama;
  protected
    procedure RegMensaje(msje: string);
  public
    estad_tra: integer;
    OnTramaLista : TEvTramaLista;  //Indica que hay una trama lista esperando
    OnRegMensaje : TEvRegMensaje;  //Indica quue desea registrar un mensaje
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


implementation
procedure TCibServidorPC.EnviaArchivo(tipCom: TCPTipCom; archivo : String);
//Envía una archivo como parte de la trama. Debe indicarse un comando
//que incluya un archivo como datos.
//var tam: Long;
//    nar: Integer;
//    datos() As Byte;
begin
  if estad_tra <> EST_ESPERANDO then exit;
  PonerComando(tipCom, 0, 0, StringFromFile(archivo));
End;

{ TCibServidorPC }
procedure TCibServidorPC.Execute;
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
procedure TCibServidorPC.ProcConex(Hsock:TSocket);
{Rutina de lazo del servidor, para procesar los paquetes recibidos.
 Se .}
var
  s: string;
  sock2: TTCPBlockSocket;
begin
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
procedure TCibServidorPC.EventoTramaLista;
begin
  if OnTramaLista <> nil then OnTramaLista(ProcTrama.trama);
end;
procedure TCibServidorPC.EventoRegMensaje;
begin
  if OnRegMensaje<>nil then begin
    OnRegMensaje(regMsje);
  end;
end;
procedure TCibServidorPC.ProcesarTrama;
//Llegó una trama y hay que hacer algo. La trama está en "Encab" y "traDat"
begin
  //Dispara evento sincronizando con proceso padre. Esto puede hacer que deba
  //esperar hasta que haya terminado algún procesamiento.
  Synchronize(@EventoTramaLista);
End;
procedure TCibServidorPC.RegMensaje(msje: string);
{Procedimiento para generar un mensaje dentro del hilo.}
begin
  regMsje := msje;
  Synchronize(@EventoRegMensaje);
end;
//Manejo de Comandos
procedure TCibServidorPC.PonerComando(tipCom: TCPTipCom; ParamX, ParamY: word; const datos: string = '');
//Similar pero solo envía un comando, con datos
begin
  pilaCmds.PonerComando(tipCom, ParamX, ParamY, datos);
end;
function TCibServidorPC.HayComando: boolean;
begin
  Result := pilaCmds.HayComando;
end;
//Constructor y destructor
constructor TCibServidorPC.Create;
begin
  sock := TTCPBlockSocket.create;
  ProcTrama:= TCPProcTrama.Create;
  pilaCmds := TPilaCom.Create;
  FreeOnTerminate:=false;
  inherited Create(false);
end;
destructor TCibServidorPC.Destroy;
begin
  pilaCmds.Destroy;
  ProcTrama.Destroy;
  Sock.free;
  inherited Destroy;
end;
end.
