{Unidad para implementar un servior TCP/IP usando la librería Synapse. Este servidor
 representará al servidoe que debe residir en las cabinas cliente, ya que en el esquema
 de conexión de CiberPlex, a las cabinas cliente se les conecta como si fueran servidores.
                                               Por Tito Hinostroza   05/2015.     }
unit CPServidorCab;  {$mode objfpc}{$H+}
interface
uses
  Classes, blcksock, synsock, lclproc, dialogs, sysutils, MisUtils, CPTramas;
type
  TEvRegMensaje = procedure(msj: string) of object;
  TEvTramaLista = procedure(tram: TCPTrama) of object;

  { TCabServidor }
  TCabServidor = class(TThread)
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
    OnTramaLista : TEvTramaLista;  //indica que hay una trama lista esperando
    OnRegMensaje : TEvRegMensaje;
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
procedure TCabServidor.EnviaArchivo(tipCom: TCPTipCom; archivo : String);
//Envía una archivo como parte de la trama. Debe indicarse un comando
//que incluya un archivo como datos.
//var tam: Long;
//    nar: Integer;
//    datos() As Byte;
begin
  if estad_tra <> EST_ESPERANDO then exit;
  PonerComando(tipCom, 0, 0, StringFromFile(archivo));
End;

{ TCabServidor }
procedure TCabServidor.Execute;
var
  ClientSock:TSocket;
begin
  try
    sock.CreateSocket;
    sock.setLinger(true,10000);
    sock.bind('0.0.0.0','80');  //0.0.0.0 hace que se escuche en todas las interfaces
    sock.listen;
    while not terminated do begin
      if sock.canread(1000) then
        begin
          ClientSock:=sock.accept;
          if sock.lastError=0 then ProcConex(ClientSock);
        end;
    end;
  except

  end;
end;
procedure TCabServidor.ProcConex(Hsock:TSocket);
//Procesa una trama recibida. Si hay comando esperando en "sEncRpta" y "sDatRpta", lo
//envía como respuesta.
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
      s := sock2.RecvPacket(60000);
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
procedure TCabServidor.EventoTramaLista;
begin
  if OnTramaLista <> nil then OnTramaLista(ProcTrama.trama);
end;
procedure TCabServidor.EventoRegMensaje;
begin
  if OnRegMensaje<>nil then begin
    OnRegMensaje(regMsje);
  end;
end;
procedure TCabServidor.ProcesarTrama;
//Llegó una trama y hay que hacer algo. La trama está en "Encab" y "traDat"
begin
  //Dispara evento sincronizando con proceso padre. Esto puede hacer que deba
  //esperar hasta que haya terminado algún procesamiento.
  Synchronize(@EventoTramaLista);
End;
procedure TCabServidor.RegMensaje(msje: string);
{Procedimiento para generar un mensaje dentro del hilo.}
begin
  regMsje := msje;
  Synchronize(@EventoRegMensaje);
end;
//Manejo de Comandos
procedure TCabServidor.PonerComando(tipCom: TCPTipCom; ParamX, ParamY: word; const datos: string = '');
//Similar pero solo envía un comando, con datos
begin
  pilaCmds.PonerComando(tipCom, ParamX, ParamY, datos);
end;
function TCabServidor.HayComando: boolean;
begin
  Result := pilaCmds.HayComando;
end;
//Constructor y destructor
constructor TCabServidor.Create;
begin
  sock := TTCPBlockSocket.create;
  ProcTrama:= TCPProcTrama.Create;
  pilaCmds := TPilaCom.Create;
  FreeOnTerminate:=false;
  inherited Create(false);
end;
destructor TCabServidor.Destroy;
begin
  pilaCmds.Destroy;
  ProcTrama.Destroy;
  Sock.free;
  inherited Destroy;
end;
end.
