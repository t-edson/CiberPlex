{Contiene las definiciones básicas que se necesitan para el objeto TCPNiloM.
Contiene la definición de las siguientes clases:

* TSocketNilo -> Es un hilo, que se se usa para abrir una conexión serial al enrutador.
                 A TSocketNilo no debe accederse directamente. Tiene su propia temporización
                 y rutinas de reconexión para mantener la conexión activa.

* TNiloConexion -> Es como una envoltura para el hilo TSocketNilo. Facilita el manejo de
                 la conexión serial, ya que administrar directamente al hilo, requiere
                 un cuidado mayor.

La comunicación serial se implementa usando un hilo, porque la librería usada, solo
ofrece coenxiones con bloqueo, y lo que se desea es manejar la conexión por eventos.
La única clase que debe usarse desde el exterior es "TNiloConexion".

TSocketNilo-+
            |
            +- TNiloConexion (accesible desde el exterior)

TNiloConexion se usa también (siguiendo el esquema de CPCabinaBase), como un contenedor
de las propiedades de la conexión serial.

La conexión serial se implementa usando la librería "Synaser" y sigue el mismo esquema
de manejo de hilos que se usa en la unidad CPCabinaBase.

                                  Por Tito Hinostroza  03/07/2016
}
unit CibNiloMConex;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, fgl, strutils, synaser, MisUtils;
type

  //Define la instancia de llamada para la ventana frmCabina
  regLlamada = class
    //Campos que genera el CDR del NILO
    serie    : String;  //Número de serie de la llamada
    canal    : String;  //Canal de entrada de llamada
    durac    : String;
    Costo    : String;
    costoA   : String;  //Costo Global
    canalS   : String;  //Canal de salida de la llamada
    digitado : String;
    descripc : String;  //Descripción de llamada
    //datos generales de la llamada (campos calculados)
    //Son necesarios para el correcto procesamiento en frmCabina
    //Se sugiere no cambiar los nombres para evitar que VB cambie el "case"
    HORA_INI : TDateTime; //Hora de inicio de llamada
    HORA_CON : TDateTime; //hora de inicio de contestación
    NUM_DIG : String;     //numero digitado
    CONTES  : Boolean;    //Bandera de contestación
    DESCR_  : String ;    //descripción de llamada
    DURAC_  : String ;    //duración de la llamada hh:nn:ss
    PASO_   : String ;    //paso de llamada
    COSTOP_ : String;     //costo por paso
    COST_NTER: Double;    //costo de una llamada (visto por el NILOTER)
    CATEG_  : String;     //tipo o categoria de la llamada
  end;
  regLlamada_list = specialize TFPGObjectList<regLlamada>;   //lista de bloques

  // Estados de la conexión de la cabina.
  TNilEstadoConex = (
    cecConectando,    //conectando
    cecConectado,     //conectado con socket
    cecDetenido,      //el proceso se detuvo (no hay control)
    cecMuerto         //proceso detenido
  );
  TEvCambiaEstado = procedure(nuevoEstado: TNilEstadoConex) of object;
  TEvRegMensaje = procedure(NomObj: string; msj: string) of object;
  TEvProcesarCad = procedure(cad: string) of object;
  TEvTermWriteLn = procedure(const subcad: string; const lin: string) of object;

  { TSocketNilo }
  {Esta clase es la conexión al enrutador NILO-m. Es un hilo para manejar las conexiones
   de manera asíncrona, ya que las conexiones seriales usando Synaser, son con bloqueo.
   El ciclo de conexión normal de TSocketNilo es:
   cecConectando -> cecConectado }
  TSocketNilo = class(TThread)
  private
    Festado: TNilEstadoConex;
    puerto : string;
    ser    : TBlockSerial;
    regMsje: string;   //Usada como para pasar parámetro a EventoMensaje()
    cadRec : string;
//    ProcTrama: TCPProcTrama; //Para procesar tramas
    procedure AbrirConexion;
    procedure Abrir;
    procedure EventoProcesarCad;
    procedure EventoCambiaEstado;
    procedure EventoRegMensaje;
  protected
    //Acciones sincronizadas
    procedure ProcesarCad(s: string);
    procedure Setestado(AValue: TNilEstadoConex);
    procedure RegMensaje(msje: string);
    procedure Execute; override;
  public
    //Eventos. Se ejecutan de forma sincronizada.
    OnProcesarCad : TEvProcesarCad;  //indica que hay un caracter listo
    OnCambiaEstado: TEvCambiaEstado;
    OnRegMensaje  : TEvRegMensaje;
    property estado: TNilEstadoConex read Festado write Setestado;
    procedure EnvComando(com: string);
    constructor Create(puerto0: string);
    Destructor Destroy; override;
  end;

  { TNiloConexion }
  {Se usa esta clase como una envoltura para administrar la conexión TSocketNilo,
   ya que es un hilo, y el manejo directo se hace problemático, por las peculiaridades
   que tienen los hilos.
******* POR REVISAR **********
   El ciclo de conexión normal de TCabConexion es:
   cecMuerto -> cecConectando -> cecConectado -> cecMuerto
   Cuando se pierde la conexión puede ser:
   cecMuerto -> cecConectando -> cecConectado -> cecConectando -> cecConectado -> ...
*******************************
   }
  TNiloConexion = class
  private
    hilo    : TSocketNilo; //hilo para manejar la comunicación serial
    Fpuerto : string;
    Festado : TNilEstadoConex;
    ultLinea: string;     //acumula los datos recibidos hasta completar la línea
    procedure hilo_CambiaEstado(nuevoEstado: TNilEstadoConex);
    procedure hilo_RegMensaje(NomCab: string; msj: string);
    procedure hilo_Terminate(Sender: TObject);
    procedure hilo_ProcesarCad(cad: string);
    function GetPuertoN: string;
    procedure SetPuertoN(AValue: string);
  public
    MsjesCnx : TstringList;  //Almanena los últimos mensajes de la conexión.
    property estado: TNilEstadoConex read Festado
             write Festado; {"estado" es una propiedad de solo lectura, pero se habilita
                             la escritura, para cuando se usa CabConexión sin Red}
    property puerto: string read Fpuerto write Fpuerto;  //nombre puerto serial: "COM1", "COM2", ...
    property puertoN: string read GetPuertoN write SetPuertoN; //Puerto como número: "1", "2", ...
    procedure Conectar;
    procedure Desconectar;
    procedure EnvComando(com: string; IncluirSalto: boolean = true);
  public  //Eventos. Si se agregan o eliminan, actualizar Destroy().
    OnCambiaEstado: TEvCambiaEstado;
    OnRegMensaje  : TEvRegMensaje;  //Indica que ha llegado un mensaje de la conexión
    OnProcesarCad : TEvProcesarCad; {Se ha recibido una cadena por el puerto serial. La
                                     cadena puede contener cualquier caracter incluyendo
                                     saltos. Es útil para mostrar datos en un terminal.}
    OnProcesarLin : TEvProcesarCad;  {Se ha recibido una línea completa, es decir un texto hasta
                                     el delimitador #10. Trabaja con "ultLinea". Es útil
                                     para procesar comandos.}
    OnGenError    : TEvRegMensaje;  //Se ha generado un error
    //Lo siguientes eventos están pensados para su uso conjunto, en un terminal.
    OnTermWrite   : TEvProcesarCad; {Se debe escribir cadena en la última línea. Se debe
                                     agregarla al final de la última línea del terminal.}
    OnTermWriteLn : TEvTermWriteLn; {Similar a OnTermWrite, pero debe agregarse un salto
                                     de línea. Incluye en los parámetros, el fragmento
                                     final de la línea (subcad) y la línea compelta (lin).}
  public  //constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

implementation
const
  MAX_LIN_MSJ_CNX = 10;  //Cantidad máxima de líneas que se guardarán de los msjes de conexión.

{ TSocketNilo }
procedure TSocketNilo.Abrir;
{Intenta abrir la conexión serial}
begin
  estado := cecConectando;
  ser.Connect(puerto); //ComPort
  Sleep(500);
  ser.config(9600, 8, 'N', SB1, False, False);
  if ser.LastError <> 0 then begin
    RegMensaje('Error:' + ser.LastErrorDesc);
    { Genera temproización por si "ser.Connect", sale inmediátamente. Esto suele suceder
     cuando hay un error de red. }
    sleep(1000);
    exit;          //falló
  end;
  estado := cecConectado;
end;
procedure TSocketNilo.AbrirConexion;
begin
  RegMensaje('Abriendo puerto ...');
  repeat
    Abrir;  //puede tomar unos segundos
  until (estado = cecConectado) or Terminated;
end;
procedure TSocketNilo.EventoProcesarCad;
begin
  if OnProcesarCad<>nil then begin
    OnProcesarCad(cadRec);
  end;
end;
procedure TSocketNilo.EventoCambiaEstado;
begin
  if OnCambiaEstado<>nil then begin
    OnCambiaEstado(Festado);
  end;
end;
procedure TSocketNilo.EventoRegMensaje;
begin
  if OnRegMensaje<>nil then begin
    OnRegMensaje('', regMsje);
  end;
end;
//Acciones sincronizadas
procedure TSocketNilo.ProcesarCad(s: string);
begin
  cadRec := s;
  Synchronize(@EventoProcesarCad);
end;
procedure TSocketNilo.Setestado(AValue: TNilEstadoConex);
begin
  if Festado=AValue then Exit;
  Festado:=AValue;
  Synchronize(@EventoCambiaEstado); //dispara evento sicnronizando
end;
procedure TSocketNilo.RegMensaje(msje: string);
begin
  regMsje := msje;
  Synchronize(@EventoRegMensaje);
end;
procedure TSocketNilo.Execute;
var
  tics: Integer;
  ticsSinRecibir: Integer;
  s: String;
begin
  AbrirConexion;
  if terminated then exit;  //por si se canceló
  //Aquí ya logró abrir conexion serial
  tics := 0;   //inicia cuenta
  ticsSinRecibir := 0;   //inicia cuenta
  RegMensaje('Enviando Presencia.');
  ser.SendString('|');
  RegMensaje('Esperando respuesta ...');
  while not terminated do begin
{    d := ser.RecvByte(100);  //Espera 100mseg
    if ser.LastError=0 then begin
      //Hubo datos recibidos
      //n := length(d);
      //RegMensaje(IntToStr(n) +  ' bytes leídos.');
      tics := 0;
      ticsSinRecibir := 0;
      ProcesarCar(Chr(d));  //Genera evento
    end;}
    s := ser.RecvPacket(100);  //Es más rápido que recibir byte por byte
    if ser.LastError=0 then begin
      //Hubo datos recibidos
      //RegMensaje(IntToStr(length(s)) +  ' bytes leídos.');
      tics := 0;
      ticsSinRecibir := 0;
      ProcesarCad(s);  //Genera evento
    end else if ser.LastError=9997 then begin
      //Timeout, es lo común, y lo que determina la temporización
      //RegMensaje(' Timeout.');
    end else begin
      //Error
      RegMensaje('Error conexión: ' + Inttostr(ser.LastError) + '-' + ser.LastErrorDesc);
    end;
    Inc(tics);
    Inc(ticsSinRecibir);
//    if tics mod 10 = 0 then RegMensaje('  tic=' + IntToStr(tics));
    if tics>300 then begin
      //No se ha enviado ningún comando en 30 segundos. Genera uno propio.
      //RegMensaje('Enviando Presencia.');
      ser.SendString('|');
      tics := 0;
    end;
    if ticsSinRecibir>400 then begin
      //probablemente se cortó la conexión
      RegMensaje('Conexión perdida.');
      ser.CloseSocket;  //cierra conexión
      AbrirConexion;
      ticsSinRecibir := 0;
    end;
    sleep(5);  //periodo del lazo
  end;
end;
procedure TSocketNilo.EnvComando(com: string);
{Envía una cadena al puerto serial. }
begin
  if estado <> cecConectado then
    exit;
  //Se debe enviar una cadena
//  RegMensaje('   Enviado: ' + com);
  //Envía
  ser.SendString(com);
end;
constructor TSocketNilo.Create(puerto0: string);
begin
  puerto := puerto0;
  Festado := cecConectando; {Estado inicial. Aún no está conectando, pero se asume que
                             está en proceso de conexión. Además, no existe estado cecDetenido.
                             Notar que esta asignación de estado, no generará el evento de
                             cambio de estado, porque estamos en el constructor}
  ser := TBlockSerial.Create;
  FreeOnTerminate := False;  //para controlar el fin
//  ProcTrama:= TCPProcTrama.Create;
  inherited Create(true);  //crea suspendido
end;
destructor TSocketNilo.Destroy;
begin
//  ProcTrama.Destroy;
  ser.Destroy;
  RegMensaje('Proceso terminado.');
  //estado := cecMuerto;  //No es útil fijar el estado aquí, porque el objeto será destruido
  inherited Destroy;
end;
{ TNiloConexion }
procedure TNiloConexion.hilo_CambiaEstado(nuevoEstado: TNilEstadoConex);
begin
  if Festado = nuevoEstado then exit;
  Festado := nuevoEstado;
  if OnCambiaEstado<>nil then OnCambiaEstado(Festado);
end;
procedure TNiloConexion.hilo_RegMensaje(NomCab: string; msj: string);
begin
  //debugln(nombre + ': '+ msj);
  MsjesCnx.Add(msj);  //Agrega mensaje
  //Mantiene tamaño, eliminando los más antiguos
  while MsjesCnx.Count>MAX_LIN_MSJ_CNX do begin
    MsjesCnx.Delete(0);
  end;
  if OnRegMensaje<>nil then OnRegMensaje('', msj);
end;
procedure TNiloConexion.hilo_Terminate(Sender: TObject);
begin
  { Se ha salido del Execute() y el hilo ya no procesa la conexión. El hilo pasa a un
  estado suspendido, pero aún existe el objeto en memoria, porque no se le define con
  auto-destrucción.}
 hilo_CambiaEstado(cecDetenido);
end;
procedure TNiloConexion.hilo_ProcesarCad(cad: string);
var
  i: Integer;
  tmp: String;
begin
// debugln(nombre + ': Cadena recibida: '+ IntToStr(length(s)));
  //Genera evento para procesar la cadena
  if OnProcesarCad<>nil then OnProcesarCad(cad);
  //Extrae líneas
  tmp := '';
  for i:=1 to length(cad) do begin
    case cad[i] of
    '|': ;   //ignora este caracter
    #13: ;   //ignora este caracter
    #10: begin  //es salto
        //Escribe lo acumulado
        ultLinea := ultLinea + tmp; //completa la línea
        if OnProcesarLin<>nil then OnProcesarLin(ultLinea);
        if OnTermWriteLn<>nil then OnTermWriteLn(tmp, ultLinea);  //envía fin de la línea
        ultLinea := '';             //limpia para acumular de nuevo
        tmp := '';
      end;
    else
      tmp := tmp + cad[i];   //acumula caracter
    end;
  end;
  if tmp<>'' then begin
    //Termina de volcar los caracteres
    ultLinea := ultLinea + tmp;
    if OnTermWrite<>nil then OnTermWrite(tmp);   //envía lo que queda de la línea
  end;
end;
function TNiloConexion.GetPuertoN: string;
begin
  Result := StringReplace(Fpuerto, 'COM','',[rfIgnoreCase]);
end;
procedure TNiloConexion.SetPuertoN(AValue: string);
begin
  Fpuerto:='COM'+AValue;
end;
procedure TNiloConexion.Conectar;
{Crea el hilo con el puerto actual e inicia la conexión}
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
  if estado = cecDetenido then begin
    // El proceso fue terminado, tal vez porque dio error.
    hilo.Destroy;   //libera referencia
    hilo := nil;
    //Festado := cecMuerto;  //No es muy útil, fijar este estado, porque seguidamente se cambiará
  end;
  hilo := TSocketNilo.Create(Fpuerto);
  hilo.OnCambiaEstado:=@hilo_CambiaEstado; //para detectar cambios de estado
  hilo.OnCambiaEstado(hilo.estado);       //genera el primer evento de estado
  hilo.OnTerminate:=@hilo_Terminate;       //para detectar que ha muerto
  hilo.OnRegMensaje:=@hilo_RegMensaje;     //Para recibir mensajes
  hilo.OnProcesarCad:=@hilo_ProcesarCad;
  // Inicia el hilo. Aquí empezará con el estado "Conectando"
  hilo.Start;
end;
procedure TNiloConexion.Desconectar;
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
procedure TNiloConexion.EnvComando(com: string; IncluirSalto: boolean);
begin
  if estado<>cecConectado then
    exit;
  if IncluirSalto then
    hilo.EnvComando(com + #13)  //el salto de línea en el NILO-m es solo #13
  else
    hilo.EnvComando(com);
end;
constructor TNiloConexion.Create;
begin
  MsjesCnx:= TstringList.Create;
  Fpuerto := '1';        //Puerto por deefcto
  Festado := cecMuerto;  //este es el estado inicial, porque no se ha creado el hilo
  //Conectar;  //No inicia la conexión
end;
destructor TNiloConexion.Destroy;
begin
  //Se limpian los eventos para evitar disparos mientras se destruye al objeto
  OnCambiaEstado:= nil;  { TODO : Notar que esta limpieza se hace en TNiloConexion.Destroy. Esto se hace como prueba y porque es un mejor diseño. Si trabaja bien, debería hacerse también con TCabConexion }
  OnRegMensaje  := nil;
  OnProcesarCad := nil;
  OnGenError    := nil;
  OnProcesarLin := nil;
  OnTermWrite   := nil;
  OnTermWriteLn := nil;
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

