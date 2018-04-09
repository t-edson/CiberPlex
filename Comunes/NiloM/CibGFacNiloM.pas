{Unidad con definiciones y funciones para el tratamiento de los enrutadores Nilo-M.
Define a la clase TCibGFacNiloM, que es el objeto que se usa para controlar a los
locutorios usando el enrutador NILO-m.
Notar que el objeto TCibGFacNiloM, maneja su propio archivo de registro, que es
independiente del archivo de registro de la aplicación. Esto se ha diseñado así, previendo
el uso de diversos objetos TCibGFacNiloM, cada uno escribiendo en su propio archivo de
registro.}
unit CibGFacNiloM;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, dos, Types, fgl, LCLProc, ExtCtrls, Menus, Forms, Controls,
  Graphics, MisUtils, crt, strutils, CibFacturables, CibNiloMConex,
  FormNiloMConex, FormNiloMProp, CibNiloMTarifRut, FormBuscTarif, Globales,
  CibTramas, CibBD, CibUtils;
const
  MAX_TAM_LIN_LOG = 300;  //Lóngitud máxima de línea recibida que se considera válida
const //Acciones
  ACCLOC_CONEC = 1;
  ACCLOC_DESCO = 2;
type
  //Define la instancia de llamada para la ventana frmCabina

  { TRegLlamada }

  TRegLlamada = class
  private
    fDigitado  : string;     //Numero digitado actualmente
    procedure SetDigitado(AValue: string);
  public  //Campos que se leen del CDR del NILO-m:
    serie    : string;  //Número de serie de la llamada
    canal    : string;  //Canal de entrada de llamada
    durac    : integer; //Duración de la llamada en segundos. Se actualiza periódicamente.
    Costo    : string;  //Costo de la llamada. Se usa para alamcenar el costo del NILO-m.
    costoA   : string;  //Costo Global
    canalS   : string;  //Canal de salida de la llamada
    descripc : string;  //Descripción de llamada
    property digitado: string //Numero digitado actualmente. Se actualiza con cada dígito recibido
      read fDigitado write SetDigitado;
  public   //Campos calculados o referencias.
    tabTar   : TNiloMTabTar; //Referencia a la tabla de tarifas. Se define al inicio.
    regTar   : TRegTarifa;   //Referencia a la tarifa.  Se actualiza con "digitado".
    {Campos estáticos que se obtienen de "regTar". Se usan para que el visor pueda acceder
    a esta información}
    tarCtoPaso: string;   //Costo de paso de la llamada actual. Se actualiza con "digitado".
    tarDesrip: string;    //Descripción de la lamada actual. Se actualiza con "digitado".
    function duracStr: string;  //Duración en formato hh:mm:ss
    function verCosto: Double;  //Calcula el costo de una llamada
  public   //Campos adicionales
    HORA_INI : TDateTime;  //Hora de inicio de llamada
    HORA_CON : TDateTime;  //Hora de inicio de contestación
    CONTEST  : Boolean;    //Bandera de contestación
    COST_NTER: Double;     //Costo de una llamada, calculado por el NILOTER.
  protected
    const SEP = '|';  //separador de campos
    function GetCadEstado: string;
    procedure SetCadEstado(AValue: string);
  public
    property CadEstado: string read GetCadEstado write SetCadEstado;
    constructor Create;
  end;
  regLlamada_list = specialize TFPGObjectList<TRegLlamada>;   //lista de bloques

  TCibGFacNiloM = class;

  { TCibFacLocutor }
  TCibFacLocutor = class(TCibFac)
  private
    procedure ActualizaLlamadaContestada;
    procedure ConectarLlamada;
    procedure DesconectarLlamada;
    procedure InicioConteo;
    procedure mnConectarClick(Sender: TObject);
    procedure mnDesconecClick(Sender: TObject);
  protected  //"Getter" and "Setter"
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public  //Campos de Propiedades (No cambian frecuentemente)
    num_can : char;     //canal del NILO asociado a este locutorio '0', '1', '2', '3'
    //variables de control de limitacion
    tpoLimitado : integer; //Bandera de Tiempo limitado
    ctoLimitado : Double;  //costo limitado
  protected
    tabTar  : TNiloMTabTar; //Referencia a la tabla de tarifas. Se actualiza al inicio.
    tic_con : Integer;    //Contador para contestación automática
    procedure ProcesaColgado(usuario: string; CategLocu: string);
    procedure ProcesaDescolgado;
    procedure ProcesaDigitado(dig: String);
    procedure ProcesarContestada(cansal: String);
  Public
    descolg   :Boolean;    //Bandera de descolgado
    listLLamadas: regLlamada_list;  //lista de llamadas
    costo_tot : Double;     //costo acumulado de todas las llamadas
    num_llam  : integer;    //número de llamadas acumuladas
    col_costo : Integer;    //indica cual es la columna que contiene el costo
    descon    : Boolean;    //Cabina desconectada (sin energía).
    llamAct   : TRegLlamada; //llamada en curso
    trama_tmp : string;     //bolsa temporal para la trama
    procedure CalcularCostoTotNumLLam;  //Actualiza "costo_tot" y "num_llam"
    function RegVenta(usu: string): string; override; //línea para registro de venta
    function AgregarFila: TRegLlamada;
    procedure TerminarLlamada(usuario: string; CategLocu: string);
    procedure ProcesarLinea(linea: string; facCmoneda: double; usuario: string;
      CategLocu: string);
    procedure EjecAccion(idFacOrig: string; tram: TCPTrama; traDat: string); override;
    procedure MenuAccionesVista(MenuPopup: TPopupMenu; nShortCut: integer); override;
  public  //Constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

  { TCibGFacNiloM }
  TCibGFacNiloM = class(TCibGFac)
  private
    nilConex : TNiloConexion;   {Objeto para la conexión al enrutador. A diferencia de
                                 TCPGrupoCabinas, aquí solo se maneja una conexión.}
    FestadoCnx: TNilEstadoConex;
    mens_error: TStringList;  //acumula los mensajes de error
    lin_serial: string;      //acumula los datos recibidos hasta completar la línea
    arcLog    : TCibTablaHist;
    timer1    : TTimer;      //temporizador
    tic       : integer;     //contador
    llego_prompt: boolean; //bandera para indicar la llegada del prompt del NILO
    frmBusTar : TfrmBuscTarif;
    //Funciones para manejo del registro
    procedure AbrirRegistro;
    procedure CerrarRegistro;
    procedure frmNilomProp_CambiaProp;
    procedure ErrorLog(mensaje: string);
    procedure mnBuscarTarif(Sender: TObject);
    procedure mnPropiedades(Sender: TObject);
    procedure mnVerConexiones(Sender: TObject);
    procedure timer1Timer(Sender: TObject);
  private //Funciones para escribir en los archivos de registros
    procedure VolcarErrorLog;
    procedure EscribeLog(mensaje: string);
    procedure EscribeLogPrompt;
    procedure EscribeTer(mensaje: string);
    procedure EscribeTerPrompt;
  protected //Getters and Setters
    function GetPuertoN: string;
    procedure SetPuertoN(AValue: string);
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  public
    ArcTarif  : string;   //Archivo de configuración de tarifas
    ArcRutas  : string;   //Archivo de configuración de rutas
    MsjError  : string;   //Bandera - Mensaje de error
    facCmoneda: Double;

    IniLLamMan : Boolean;  //Bandera de Inicio de llamada Manual
    IniLLamTemp: Boolean;  //Bandera de Inicio de llamada Temporizado
    PerLLamTemp: Integer;  //Periodo de Inicio de llamada Temporizado

    frmNilomConex: TfrmNiloMConex;
    frmNilomProp: TfrmNiloMProp;
    tarif     : TNiloMTabTar;      //Contenedor de tarifas
    rutas     : TNiloMTabRut;      //Contenedor de rutas
    property estadoCnx: TNilEstadoConex read FestadoCnx
             write FestadoCnx;   {"estadoCnx" es una propiedad de solo lectura, pero se
                                   habilita la escritura, para cuando se usa sin Red}
    property PuertoN: string read GetPuertoN write SetPuertoN;
    //Rutinas para leer archivos de configuración
    procedure LeerArchivosConfig;  //Lee archivos de tarifas y rutas
  private //servicio de eventos
    procedure nilConex_CambiaEstado(nuevoEstado: TNilEstadoConex);
    procedure nilConex_RegMensaje(NomObj: string; msj: string);
    procedure nilConex_ProcesarCad(cad: string);
    procedure nilConex_ProcesarLin(cad: string);
    procedure nilConex_TermWrite(cad: string);
    procedure nilConex_TermWriteLn(const subcad: string; const lin: string);
    function tarif_LogErr(mensaje: string): integer;
    function tarif_LogInf(mensaje: string): integer;
  public  //Eventos que se pueden generar de forma automática
    //Eventos reflejo de "TNiloConexion"
    OnCambiaEstadoCnx: TEvNilCambiaEstado;  //Cambia el estado de la conexión
    OnRegMensaje  : TEvRegMensaje;  //Indica que ha llegado un mensaje de la conexión
    OnProcesarCad : TEvProcesarCad; //indica que hay una cadena lista esperando
    OnProcesarLin : TEvRegMensaje;  //Se genera una línea para registrar mensaje
    //Manejo del terminal
    OnTermWrite   : TEvProcesarCad;
    OnTermWriteLn : TEvProcesarCad;
    procedure Conectar;
    procedure Desconectar;
    procedure EnvComando(com: string; IncluirSalto: boolean = true);
    procedure EnviaComEspPr(cad: string);
    procedure EnvCadena(cadena: string);
    function Agregar(nomLoc: string; num_can: char; tabTar0: TNiloMTabTar
      ): TCibFacLocutor;
  public  //Campos para manejo de acciones
    procedure EjecAccion(idFacOrig: string; tram: TCPTrama); override;
    procedure MenuAccionesVista(MenuPopup: TPopupMenu); override;
    procedure MenuAccionesModelo(MenuPopup: TPopupMenu); override;
  public  //constructor y destructor
    constructor Create(nombre0: string; ModoCopia0: boolean);
    destructor Destroy; override;
  end;

var
  grabando_nilo   : Boolean;  //Bandera para indicar que se está grabando
  cancelar_envio  : Boolean;  //Bandera para cancelar el envío de un archivo CNL

  procedure CargarIconos(imagList16, imagList32: TImageList);

implementation
const
  RUT_ICONOS = '..\Iconos\NiloM';
  MAX_ERROR_LOG_LLAM = 200; //Máximo número de errores permitidos en una llamada

var
  icoConexi: integer;   //índice de imagen
  icoBusTar: integer;   //índice de imagen
  icoPropie: integer;   //índice de imagen

procedure CargarIconos(imagList16, imagList32: TImageList);
{Carga los íconos que necesita esta unida }
var
  rutImag: RawByteString;
begin
  rutImag := ExtractFilePath(Application.ExeName) + RUT_ICONOS + DirectorySeparator;
  icoConexi := CargaPNG(imagList16, imagList32, rutImag, 'terminal');
  icoBusTar := CargaPNG(imagList16, imagList32, rutImag, 'search');
  icoPropie := CargaPNG(imagList16, imagList32, rutImag, 'properties');
end;

{ TRegLlamada }
procedure TRegLlamada.SetDigitado(AValue: string);
begin
  if fDigitado=AValue then Exit;
  fDigitado:=AValue;
  regTar  := tabTar.BuscaTarifa(digitado);  //siempre devuelve tarifa
  tarCtoPaso := regTar.costop;
  tarDesrip := regTar.descripcion;
end;
function TRegLlamada.duracStr: string;
//Duración en formato hh:mm:ss
begin
  DateTimeToString(Result, 'hh:mm:ss', durac/3600/24);
end;
function TRegLlamada.verCosto: Double;
//Devuelve el costo de la llamada analizando la duración, y la tarifa
  Function verPasos(durSeg: integer; paso : Integer; var seg_restantes: Integer): Integer;
  {Recibe la duración en segundos  y devuelve la cantidad de pasos redondeado al
  máximo entero superior.
  También devuelve la cantidad de segundos excedentes que se redondearon}
  begin
      msjError := '';
      if paso = 0 Then begin
        msjError := '"paso" de llamada es 0. No se puede calcular num.pasos"';
        exit;
      end;
      if durSeg Mod paso = 0 Then begin
          Result := durSeg div paso;
      end else begin
          Result := (durSeg div paso) + 1;
          seg_restantes := durSeg Mod paso;
      end;
  end;
var
  npasos : Integer;
  paso, subpaso : Integer;
  ctoPaso, ctoSubpaso : Double;
  restantes : Integer;    //segundos restantes
  tmp : Double;
begin
    msjError := '';
    if regtar.paso = '' Then begin
        msjError := ' variable "cpaso" nula. No se puede calcular costo ';
        exit;
    End;
    if regtar.costop = '' Then begin
        msjError := ' variable "ccosto" nula. No se puede calcular costo ';
        exit;
    End;
    paso      := regtar.nPaso;
    subpaso   := regtar.nSubpaso;
    ctoPaso   := regtar.nCtoPaso;
    ctoSubpaso:= regtar.nCtoSubPaso;

    npasos := verPasos(durac, paso, restantes);
    If npasos = 0 Then begin
      Result := 0; exit;
    end;

    If regtar.HayCtoPaso1 Then npasos := npasos - 1;

    //Puede generar error, no importa... If MsjError <> '' Then
    If not regtar.HaySubPaso Then begin //Si no hay subpaso, el cálculo es normal
        tmp := npasos * ctoPaso;
    end else begin        //Si hay subpaso
        //ver si aplica el subpaso
        If (restantes > 0) And (restantes <= subpaso) Then begin //aplica
            npasos := npasos - 1;
            tmp := npasos * ctoPaso + ctoSubpaso;
        end else begin                   //no aplica
            tmp := npasos * ctoPaso;
        end;
    end;
    If regtar.HayCtoPaso1 Then tmp := tmp + regtar.nCtoPaso1;    //Había
    Result := tmp;
end;
function TRegLlamada.GetCadEstado: string;
{Notar que no se guarda la refererncia "tarif", ya que se puede obtener de NUM_DIG}
begin
  Result :=
    serie        + SEP +
    canal        + SEP +
    Costo        + SEP +
    costoA       + SEP +
    canalS       + SEP +
    descripc     + SEP +
    T2f(HORA_INI)+ SEP +
    T2f(HORA_CON)+ SEP +
    fDigitado    + SEP +
    B2f(CONTEST)  + SEP +
    I2f(durac)   + SEP +
    tarCtoPaso   + SEP +
    tarDesrip    + SEP +
    N2f(COST_NTER);
end;
procedure TRegLlamada.SetCadEstado(AValue: string);
var
  a: TStringDynArray;
begin
  a := explode(SEP, AValue);
  try
    serie     := a[0];
    canal     := a[1];
    Costo     := a[2];
    costoA    := a[3];
    canalS    := a[4];
    descripc  := a[5];
    HORA_INI  := f2T(a[6]);
    HORA_CON  := f2T(a[7]);
    fDigitado := a[8];
    CONTEST    := f2B(a[9]);
    durac     := f2I(a[10]);
    tarCtoPaso:= a[11];
    tarDesrip := a[12];
    COST_NTER := f2N(a[13]);
  except
    MsgErr('Error leyendo registro de llamadas .');
  end;
end;
constructor TRegLlamada.Create;
begin
  HORA_INI := now;
end;
{ TCibFacLocutor }
procedure TCibFacLocutor.CalcularCostoTotNumLLam();
{Calcula el costo total de las llamadas en "costo_tot" y el número de llamadas en
 "num_llam". Este esquema de trabajo (usar una función para actualizar campos) se hace
 considerando que si se decide no envíar al visor, toda la  lista "listLLamadas", se
 podría enviar solamente los campos "costo_tot" y "num_llam",  para que el visor pueda
 saber al menos lo mínimo sobre las llamadas.}
var
  l: TRegLlamada;
begin
    //Calcula el costo total de listLLamadas
    costo_tot := 0;
    For l in listLLamadas do begin  //no toma encabezado
        costo_tot := costo_tot + l.COST_NTER;
    end;
    num_llam := listLLamadas.Count;
End;
function TCibFacLocutor.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
var
  llamActEstado: String;
begin
  if llamAct=nil then
    llamActEstado := ''
  else
    llamActEstado := llamAct.CadEstado;
  Result := '.' + {Caracter identificador de facturable, se omite la coma por espacio.}
         nombre + #9 +    {el nombre es obligatorio para identificarlo unívocamente}
         B2f(descolg) + #9 + B2f(descon) + #9 +
         N2f(costo_tot) + #9 + I2f(num_llam) + #9 +
         llamActEstado + #9;
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCibFacLocutor.SetCadEstado(AValue: string);
{Notar que no se está recibiendo la lista de llamadas, sino que, solo se está
recibiendo la llamada actual. Por ello la lista de llamadas en el visor no es
oonsistente con la lista de llamadas del modelo.}
var
  lineas, campos: TStringDynArray;
  lin: String;
begin
  lineas := Explode(LineEnding, AValue);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  delete(lin, 1, 1);  //recorta identificador
  campos    := Explode(#9, lin);
  descolg   := f2B(campos[1]);
  descon    := f2B(campos[2]);
  costo_tot := f2N(campos[3]);
  num_llam  := f2I(campos[4]);
  if campos[5]='' then begin  //No hay llamada actual
    llamAct := nil;
  end else begin  //Hay llamada actual
    if llamAct=nil then  //Si no hay llamada actual, la creamos, sino reusamos.
      llamAct := AgregarFila();
    llamAct.CadEstado:=campos[5];
  end;
  //Agrega información de boletas
  LeerEstadoBoleta(lineas);
end;
function TCibFacLocutor.GetCadPropied: string;
begin
  Result := Nombre + #9 +
            num_can + #9 +
            I2f(tpoLimitado) + #9 +
            N2f(ctoLimitado) + #9 +
            N2f(x) + #9 +
            N2f(y) + #9 +
            #9 + #9 + #9;;
end;
procedure TCibFacLocutor.SetCadPropied(AValue: string);
var
  campos: TStringDynArray;
begin
  campos := Explode(#9, Avalue);
  Nombre := campos[0];
  num_can := campos[1][1];
  tpoLimitado := f2I(campos[2]);
  ctoLimitado := f2N(campos[3]);
  x := f2N(campos[4]);
  y := f2N(campos[5]);
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibFacLocutor.ProcesaDigitado(dig: String);
begin
    tic_con := 0;     //reinicia contador
    if llamAct=nil then begin
      //Es llamada nueva
      llamAct := AgregarFila;
      llamAct.HORA_INI := now;
      llamAct.durac := 0;
    end;
    //Acumula número digitado, y actualiza tarifa y costo de paso
    llamAct.digitado := llamAct.digitado + dig;
end;
procedure TCibFacLocutor.ProcesaColgado(usuario: string; CategLocu: string);
begin
  descolg := False;     //La llamada está colgada
  if llamAct=nil then exit;  //protección
  if llamAct.CONTEST Then begin   //Estaba aún en este estado
      {Esto no debería pasar, porque las llamadas contestadas, generan su CDR antes de
      generar la indicación de "colgado" (haciendo que lo procese ProcesarLinea(), quien
      pone CONTEST = false.). Si pasa, es probable que no se haya detectado la llegada
      del CDR corectamente, tal vez por problemas de comunicación.}
      TCibGFacNiloM(grupo).ErrorLog('Recibido el estado de colgado sin recibir CDR.');
      {Para salvar la situación, generamos el registro de venta y el ítem de la boleta,
      para evitar perder el cobro. Pero hay que notar que no tenemos la información que nos
      da el CDR, así que usaremos los campos que tenemos}
      llamAct.serie    := '000';
      llamAct.canal    := '?';
      //llamAct.durac  //Usamos la duración de CIBERPLEX
      llamAct.Costo    := '00000';
      llamAct.costoA   := '00000';
      llamAct.canalS   := '?';
      //llamAct.digitado //Usamos el digitado de CIBERPLEX
      llamAct.descripc := llamAct.regTar.descripcion; //Usamos la descripción de CIBERPLEX

      llamAct.CONTEST := False;
      //Notar que comop no tenemos el CDR,
      //Calcula costo en campo calculados
      llamAct.COST_NTER := llamAct.verCosto;  //Costo con duración CIBERPLEX
      If msjError <> '' then TCibGFacNiloM(grupo).ErrorLog(msjError);
      //Termina la llamada normalmente, registrando datos adicionales.
      TerminarLlamada(usuario, CategLocu);
  end;
  llamAct := nil;    //Termina la llamada actual.
end;
procedure TCibFacLocutor.ProcesaDescolgado();
begin
    llamAct := nil;    //Límpia bandera de llamada
    descolg := True;   //La llamada está descolgada
    descon := false;   //Se supone que si se descuelga debe tener conexión
    tic_con := 0;      //Inicia contador
end;
procedure TCibFacLocutor.ProcesarContestada(cansal: String);
//Procesa una llamada contestada. "cansal" es el canal de salida actual de la
//llamada
begin
  if llamAct = nil Then begin   //Crea si no existe llamada
      llamAct := AgregarFila;
      llamAct.HORA_INI := now;
  end;
  llamAct.CONTEST := True;
  llamAct.HORA_CON := now;      //toma hora de contestación
  descolg := True;     //La llamada está descolgada
end;
function TCibFacLocutor.AgregarFila: TRegLlamada;
{Agrega un registro, a la lista de llamadas. Devuelve referencia al último registro.}
var
  rllam : TRegLlamada;
begin
  rllam := TRegLlamada.Create; //Los campos de costos inician en Cero.
  rLLam.tabTar := tabTar;      //actualiza su referencia
  if tabTar<>nil then          //Si hay tabla de tarifas
    rLlam.regTar := tabTar.tarNula;  //inicia a tarifa nula
  listLLamadas.Add(rllam);     //Agrega
  Result := rllam;
//debugln('>llamada agregada.');
end;
procedure TCibFacLocutor.ActualizaLlamadaContestada;
var
  GFacNiloM: TCibGFacNiloM;
begin
  if llamAct = nil then exit;
  GFacNiloM := TCibGFacNiloM(Grupo);
  //Procesa el conteo de la temporización
  if descolg And GFacNiloM.IniLLamMan And (llamAct.digitado <> '') then begin
      tic_con := tic_con + 1;   //Lleva la cuenta
      If (tic_con >= GFacNiloM.PerLLamTemp) And Not llamAct.CONTEST Then begin
          InicioConteo;
      End;
  End;
  if llamAct.CONTEST Then begin    //LLamada en curso
      llamAct.durac := Round(((date + Time) - llamAct.HORA_CON) * 24 * 60 * 60);   //en segundos
      llamAct.COST_NTER := llamAct.verCosto;  //Estima costo
      If msjError <> '' Then GFacNiloM.ErrorLog(msjError);
      If tpoLimitado > 0 Then begin //hay tiempo limitado
          //transc = transc & '(<' & tpoLimitado & ')'
          If llamAct.durac >= tpoLimitado Then begin
              GFacNiloM.EnvComando('x' + num_can);
              If msjError <> '' Then MsgBox(msjError); Exit;
//                cmdTiempo.Picture = picRelojApa.Picture;
              tpoLimitado := 0;
          End;
      End;
      //Actualiza registro de llamada cada segundo
      CalcularCostoTotNumLLam;
  end;
end;
procedure TCibFacLocutor.TerminarLlamada(usuario: string; CategLocu: string);
//Escribe datos en el registro y en el terminal
var
  linea: string;
  nilo: TCibGFacNiloM;
  nser : Integer;
  r : TCibItemBoleta;
begin
  //Escribe datos adicionales en el registro del NILO-m
  nilo := TCibGFacNiloM(self.Grupo);
  linea := FormatDateTime('yyyy/mm/dd hh:nn:ss', now) +
           ' COST:' + FormatFloat('000.00', llamAct.COST_NTER) +
           ' DESC:' + llamAct.regTar.descripcion +
           ' CAT:' + llamAct.regTar.categoria;
  nilo.EscribeTer(linea);
  nilo.EscribeTerPrompt;      //Se escribe prompt para no alterar el formato de log
  nilo.EscribeLog(linea);
  nilo.VolcarErrorLog;        //Vuelca también los mensajes de error
  nilo.EscribeLogPrompt;      //Se escribe prompt para no alterar el formato de log
  //Genera sonido para listLLamadas con tiempo
  if llamAct.durac >0 then begin
{ Por algún motivo, esta rutina produce que las siguientes instrucciones no se ejecuten,
generando diversos errores.
    sndPlaySound(PChar(rutSonidos + '\colgado.wav'), SND_ASYNC Or SND_NODEFAULT)
}
  end;
//  costo_tot = costo_tot + llamAct.costo //acumula costo
  CalcularCostoTotNumLLam;               //Actualiza costo
  //Registra la venta en el archivo de registro
  { TODO : Para ser consistente, este registro debería escribirse en el archivo del grupo:
   CANADA.2017_10.NILO-m.log (como se hace en el grupo de cabinas) y no en el registro
   de ventas }
  nser := OnLogVenta(IDE_NIL_LLA, RegVenta(usuario), llamAct.COST_NTER);    //toma serie
  //Si hubo error, ya se mostró en OnLogVenta()

  //agrega item a boleta
  r := TCibItemBoleta.Create;   //crea elemento
  r.vser := nser;
  r.Cant := 1;
  r.pUnit := llamAct.COST_NTER;
  r.subtot := llamAct.COST_NTER;
  r.descr := 'Llamada: ' + llamAct.digitado + '(' + llamAct.descripc + ') ' +
            llamAct.duracStr;
  r.cat := CategLocu;
  r.subcat := 'LLAMADA';
  r.vfec := now;
  r.estado := IT_EST_NORMAL;
  r.fragmen := 0;
  r.conStk := False;    //no se maneja stock
  Boleta.VentaItem(r, False);
end;
procedure TCibFacLocutor.ConectarLlamada;
begin
  If grabando_nilo Then begin  //Protección
      MsgExc('No se puede usar locutorios en medio de una llamada');
      exit;
  End;
  //Envía comando
  TcibGFacNiloM(grupo).EnvComando('u' + num_can);
  If msjError <> '' Then MsgErr(msjError);
  Sleep(500);   //espera a que el NILO termine de procesar la orden
  //Me.MiLista1.Clear;
  listLLamadas.Clear;   //se aprovecha para limpiar la lista
  llamAct := nil;
  CalcularCostoTotNumLLam;
End;
procedure TCibFacLocutor.DesconectarLlamada;
begin
    //Envía comando
    TcibGFacNiloM(grupo).EnvComando('x' + num_can);
    If msjError <> '' Then MsgBox(msjError);
    Sleep(500);   //espera a que el NILO termine de procesar la orden
End;
procedure TCibFacLocutor.InicioConteo;
//Inicia contéo manual del tiempo en el locutorio
begin
    TcibGFacNiloM(grupo).EnvComando('k' + num_can);
    If msjError <> '' Then MsgBox(msjError);
    Sleep(500);   //espera a que el NILO termine de procesar la orden
End;
function TCibFacLocutor.RegVenta(usu: string): string;
var
  nilo: TCibGFacNiloM;
  function durMS(dur: integer): string;
  {Devuelve la duración en formto de MMM:SS, necesario para generar registro de Venta}
  var
    min, seg: Integer;
  begin
    min := dur div 60;
    seg := dur mod 60;
    Result := format('%.3d', [min]) + ':' + format('%.2d', [seg]);
  end;
begin
  nilo := TCibGFacNiloM(self.Grupo);
  Result  := llamAct.serie + #9 + FormatDateTime('dd/mm/yyyy', now) + #9 +
             FormatDateTime('hh:nn:ss', now) + #9 + llamAct.digitado + #9 +
             durMS(llamAct.durac) + #9 + I2F(llamAct.durac) + #9 +
             N2f(StrToFloat(llamAct.Costo) * nilo.facCmoneda) + #9 +
             N2f(llamAct.COST_NTER) + #9 +
             llamAct.canal + #9 + llamAct.canalS + #9 +
             llamAct.descripc + #9 + llamAct.regTar.categoria + #9 + usu + #9 +
             nombre + #9 + nilo.PuertoN + #9 + nilo.CategVenta + #9 +
             #9 + #9 + #9; //campos ampliados
end;
procedure TCibFacLocutor.ProcesarLinea(linea: string; facCmoneda: double;
  usuario: string; CategLocu: string);
  function EsLineaCDR: boolean;
  {Indica si la línea recibida es de un CDR de este locutorio:
     '[#]###;' + num_can + '*'}
  begin
    Result := (length(linea)>8) and
              (linea[1] = '#') and
              (linea[2] in ['0'..'9']) and
              (linea[3] in ['0'..'9']) and
              (linea[4] in ['0'..'9']) and
              (linea[5] = ';') and
              (linea[6] = num_can);
  end;
var
  cdr: TRegCDRNiloM;
begin
    If linea = 'Ctda' + num_can then begin
        //Se ha cortado la llamada
        descolg:= False;     //La llamada está colgada
        tpoLimitado := 0;     //al terminar una llamada en el NILO-m se reinicia el límite
        descon:=true;     //actualiza estado
        exit;
    end else if linea = 'Rtda' + num_can then begin   //Habilitada
        descolg := False;     //La llamada está colgada
        descon:=false;    //actualiza estado
        exit;
    end else if EsLineaCDR then begin
        //----Llegó el cdr   #001;0;00016;00002;00002;4;450;LOCAL----
        //Lee los campos del cdr original
        if llamAct = nil then begin
            //No se ha registrado el inicio de la llamada
            //Puede que haya estado cerrado el SW
            OnLogError('Llamada registrada sin datos de inicio');
            llamAct := AgregarFila;       //agrega fila
            llamAct.HORA_INI := now;      //asume la hora de inicio
        end;
        cdr.LeeCdrNilo(linea);
        if cdr.msjErr<>'' then begin
          OnLogError('Error en formato de CDR: ' + linea);
        end;
        llamAct.serie    := cdr.serie;
        llamAct.canal    := cdr.canal;
        llamAct.durac    := cdr.duracSeg;  //Sincroniza con el CDR.
        llamAct.Costo    := cdr.Costo;
        llamAct.costoA   := cdr.costoA;
        llamAct.canalS   := cdr.canalS;
        llamAct.digitado := cdr.digitado;  //Sincroniza con el CDR
        llamAct.descripc := cdr.descripc;
        //Campos adicionales
        llamAct.CONTEST  := False;
        //Calcula costo en campo calculados
        llamAct.COST_NTER := llamAct.verCosto;  //Costo con duración sincronizada
        If msjError <> '' then TCibGFacNiloM(grupo).ErrorLog(msjError);
        //Termina la llamada, registrando la venta y creando íten de boleta.
        TerminarLlamada(usuario, CategLocu);
    end;
    if copy(linea, 1, 2)  = 'n' + num_can then  //Procesamiento de número digitado
        ProcesaDigitado(Copy(linea, 3, 1))
    else if copy(linea, 1, 2)  = 'c' + num_can then  //Llamada colgada
        ProcesaColgado(usuario, CategLocu)
    else if copy(linea, 1, 2)  = 'y' + num_can then     //Llamada contestada
        ProcesarContestada(MidStr(linea, 3, 1))  //indica canal de salida
    else if copy(linea, 1, 2)  = 'd' + num_can then   //Llamada descolgada
        ProcesaDescolgado;
end;
procedure TCibFacLocutor.EjecAccion(idFacOrig: string; tram: TCPTrama;
  traDat: string);
begin
  case tram.posX of  //Se usa el parámetro para ver la acción
  ACCLOC_CONEC: begin
    ConectarLlamada;
    end;
  ACCLOC_DESCO: begin
    DesconectarLlamada;
    end;
  end;
end;
procedure TCibFacLocutor.MenuAccionesVista(MenuPopup: TPopupMenu;
  nShortCut: integer);
begin
  InicLlenadoAcciones(MenuPopup);
  AgregarAccion(nShortCut, '&Desconectar'   , @mnDesconecClick);
  AgregarAccion(nShortCut, '&Conectar'      , @mnConectarClick);
end;
procedure TCibFacLocutor.mnConectarClick(Sender: TObject);
begin
  if OnSolicEjecCom<>nil then  //ejecuta evento
    OnSolicEjecCom(CFAC_NILOM, ACCLOC_CONEC, 0, IdFac);
end;
procedure TCibFacLocutor.mnDesconecClick(Sender: TObject);
begin
  if OnSolicEjecCom<>nil then  //ejecuta evento
    OnSolicEjecCom(CFAC_NILOM, ACCLOC_DESCO, 0, IdFac);
end;
//Constructor y destructor
constructor TCibFacLocutor.Create;
begin
  inherited Create;
  tipo := ctfNiloM;   //se identifica
  listLLamadas:= regLlamada_list.Create(true);
end;
destructor TCibFacLocutor.Destroy;
begin
  listLLamadas.Destroy;
  inherited Destroy;
end;
{ TCibGFacNiloM }
//Funcione para manejo del registro
procedure TCibGFacNiloM.AbrirRegistro();
{Inicia al archivo de registro}
var
  NombProg, NombLocal: string;
  ModDiseno: boolean;
begin
  if ModoCopia then exit;
  if OnReqConfigGen<>nil then  //Pide información global
      OnReqConfigGen(NombProg, NombLocal, ModDiseno);
  //Abre archivo de rgeistro para este enrutador
  arcLog.AbrirPLog(rutDatos, NombLocal, Nombre);
  if msjError <> '' then exit;
  EscribeLog('');
  EscribeLog(NombProg);
  EscribeLog('Inicio CIBERPX --- ' + FormatDateTime('yyyy/mm/dd hh:nn:ss', now));
end;
procedure TCibGFacNiloM.CerrarRegistro();
begin
  if ModoCopia then exit;
  EscribeLog('Fin CIBERPX    --- ' + FormatDateTime('yyyy/mm/dd hh:nn:ss', now));
  EscribeLog('');
end;
procedure TCibGFacNiloM.frmNilomProp_CambiaProp;
{Se produjo un cambio en las propiedades del NILO-m.}
begin
  if OnCambiaPropied<>nil then OnCambiaPropied;
end;
procedure TCibGFacNiloM.ErrorLog(mensaje: string);
{Escribe un mensaje de error en el archivo de registro de llamadas.
En realidad los guarda en una lista hasta que se vuelcan de golpe}
begin
    //Acumula los mensajes, no los guarda directamente para no malograr el formato del "log"
    //Se vuelca al archivo en el momento apropiado
    mens_error.Add('ERROR: ' + TimeToStr(Time) + '-' + mensaje);
end;
procedure TCibGFacNiloM.timer1Timer(Sender: TObject);
{Temporiza el objeto, cada segundo}
var
  it : TCibFac;
begin
  tic := tic + 1;
  //Temporiza a todos los locutorios, para su funcionamiento interno
  for it in items do  begin
    TCibFacLocutor(it).ActualizaLlamadaContestada;
  end;
  //Cödigo para la conexión automática por el puerto serial
//  if (tic+3) mod 5 = 0 then begin   //se suma 3 para que la primera vez se ejecute antes
  if tic = 3 then begin   //intenta una conexión al iniciar
    if estadoCnx in [necMuerto, necDetenido] then begin
      //Intenta conectarse
      Conectar;
    end;
  end;
end;
function TCibGFacNiloM.tarif_LogErr(mensaje: string): integer;
//Se solicita registrar un mensaje de error
begin
  Result := OnLogError(mensaje);
end;
function TCibGFacNiloM.tarif_LogInf(mensaje: string): integer;
//Se solicita registrar un mensaje informativo
begin
  Result := OnLogInfo(mensaje);
end;
//Funciones para escribir en los archivos de registros
procedure TCibGFacNiloM.VolcarErrorLog;
{Vuelca los mensajes de error en el archivo de registro
Se debe llamar al final de cada llamada para escribir los errores}
var
  i       : Integer;
  nerrores: Integer;
begin
  If mens_error.Count >0 Then begin   //Verifica si hay
      nerrores := mens_error.Count;    //la última es una simple salto de línea
      //Limita número de errores
      if nerrores > MAX_ERROR_LOG_LLAM then nerrores := MAX_ERROR_LOG_LLAM;
      for i := 0 To nerrores - 1 do begin //escribe los mensajes de error
        EscribeLog(mens_error[i]);
      end;
      if nerrores = MAX_ERROR_LOG_LLAM then begin  //Indica que siguen más errores
        EscribeLog('ERROR: ...');
      end;
  end;
  mens_error.Clear;     //Limpia los errores volcados
end;
procedure TCibGFacNiloM.EscribeLog(mensaje: string);
{Escribe una línea, solamente en el registro. El mensaje debe ser de una sola línea.
Aprovecha también para volcar lo que haya quedado en "lin_serial"}
begin
    arcLog.EscribReg(lin_serial + '---CIBERPX: ' + mensaje);
    If msjError <> '' Then MsgErr(msjError);
    lin_serial := '';     //inicia nueva línea
end;
procedure TCibGFacNiloM.EscribeLogPrompt;
{Escribe una línea, solamente en el registro. El mensaje debe ser de una sola línea.
Aprovecha también para volcar lo que haya quedado en "lin_serial"}
begin
  lin_serial := lin_serial + '>';  //no incluye salto de línea. Deja para completar línea
  {Aquí hay una diferencia con el NILOTER-m, ya que este escribe siempre el prompt, y un
  salto de línea en el registro. Aquí se ha querido ser más consistente con la forma de
  trabajo de "EscribeTerPrompt".}
end;
procedure TCibGFacNiloM.EscribeTer(mensaje: string);
{Escribe una línea, solamente en el terminal. El mensaje debe ser de una sola línea.}
begin
  //El terminal ya incluye a la parte inicial de la última línea que puede haber.
  if OnTermWriteLn<>nil then OnTermWriteLn('---CIBERPX: ' + mensaje);
end;
procedure TCibGFacNiloM.EscribeTerPrompt;
{Escribe una línea, solamente en el terminal. El mensaje debe ser de una sola línea.}
begin
  //El terminal ya incluye a la parte inicial de la última línea que puede haber.
  if OnTermWrite<>nil then OnTermWrite('>');  //no incluye salto
end;
function TCibGFacNiloM.GetPuertoN: string;
begin
  if ModoCopia then exit('');
  Result := nilConex.puertoN;
end;
procedure TCibGFacNiloM.SetPuertoN(AValue: string);
begin
  if ModoCopia then exit;
  nilConex.puertoN:=AValue;
end;
function TCibGFacNiloM.GetCadEstado: string;
{Se sobreescribe esta propiedad para incluir campos adicionales}
var
  c : TCibFac;
begin
  //Delimitador inicial y propiedades de objeto.
  Result := '<' + I2f(ord(tipo)) + #9 + Nombre + #9 +
                  I2f(ord(estadoCnx)) + #9 + LineEnding;
  for c in items do begin
    Result += c.CadEstado + LineEnding;
  end;
  Result += '>';  //delimitador final.
end;
procedure TCibGFacNiloM.SetCadEstado(AValue: string);
{Se sobreescribe esta propiedad para incluir campos adicionales}
var
  cad, nomb, lin1: string;
  car: char;
  it: TCibFac;
  a: TStringDynArray;
begin
  decod.Inic(AValue, lin1);  //iniica la decodificación
  a := Explode(#9, lin1);     //separa campos
  if ModoCopia then begin
    //Solo cuando está en modo copia, se lee esta variable
    estadoCnx := TNilEstadoConex(f2I(a[2]));
  end;
  while decod.Extraer(car, nomb, cad) do begin
    if cad = '' then continue;
    it := ItemPorNombre(nomb);
    if it<>nil then it.CadEstado := cad;
  end;
end;
function TCibGFacNiloM.GetCadPropied: string;
var
  c : TCibFac;
begin
  //Información del grupo en la primera línea
  Result := Nombre + #9 + CategVenta + #9 + N2f(Fx) + #9 + N2f(Fy) + #9 +
            PuertoN + #9 + N2f(facCmoneda) + #9 +
            B2f(IniLLamMan) + #9 +
            B2f(IniLLamTemp) + #9 +
            I2f(PerLLamTemp) + #9 + #9;
  //Información de las cabinas en las demás líneas
  for c in items do begin
    Result := Result + LineEnding + c.CadPropied;
  end;
end;
procedure TCibGFacNiloM.SetCadPropied(AValue: string);
var
  lineas: TStringList;
  loc: TCibFacLocutor;
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
  PuertoN:=a[4];
  facCmoneda := f2N(a[5]);
  IniLLamMan := f2B(a[6]);
  IniLLamTemp:= f2B(a[7]);
  PerLLamTemp:= f2I(a[8]);

  lineas.Delete(0);  //elimima línea
  //Procesa líneas con información de las cabinas
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    loc := Agregar('','0', tarif);
    loc.CadPropied := lin;
  end;
  lineas.Destroy;
end;
procedure TCibGFacNiloM.LeerArchivosConfig;
{Lee el contenido de los archivos de tarifas y rutas y los carga en "tarif" y "rutas".
 Formalmente esto debería ser parte las propiedades, pero como es una rutina  pesada, y
 los archivos de tarifas y rutas son grandes, el proceso de carga se maneja como una
 rutina separada.
 Se debería ejecutar solo una vez al inicio.}
begin
  frmNilomProp.CargarArchivosConfig;
  frmNilomProp.ValidarTarifario;  //puede mostrar mensaje de error
  frmNilomProp.ValidarRutas;      //puede mostrar mensaje de error
end;
//Rutinas para escribir en el terminal y en el registro
procedure TCibGFacNiloM.nilConex_TermWrite(cad: string);
{Se usa para refrescar al terminal}
begin
  if OnTermWrite<>nil then OnTermWrite(cad);
  lin_serial := lin_serial + cad;  //acumula última línea
  //Se aproceha este evento para actualizar "llego_prompt"
  if cad = '>' then  llego_prompt := true;
end;
procedure TCibGFacNiloM.nilConex_TermWriteLn(const subcad: string; const lin: string
  );
{Se usa para refrescar al terminal y escribir en el registro.}
var
  fac: TCibFac;
  Usuario: string;
begin
  lin_serial := lin_serial + subcad;
  msjError := arcLog.EscribReg(lin_serial);  //en el registro, escibe la línea completa.
  lin_serial := '';   //limpia para acumular de nuevo
  if msjError<>'' then MsgErr(msjError);
  if OnTermWriteLn<>nil then OnTermWriteLn(subcad);  //al terminal envía lo que falta
  //////////// Se procesa la línea completa recibida //////////////
  {Notar que se usa "lin", en lugar de "lin_serial", y que el procesamiento de la
  línea se hace después de refrescar el terminal y el registro.}
  if length(lin) > MAX_TAM_LIN_LOG then begin  //validación
    ErrorLog('Tamaño de línea recibida muy larga');
    exit;
  end;
  if (length(lin)=6) and (lin[1] = '$') then begin
    //Costo Global: '$#####'
    { TODO : Revisar si se va a implementar esta característica.
De ser así, conviene generar un evento para no tener
que acceder a objetos fuera del alcance de esta librería. }
    {tmp := ForCosto(val(Mid$(lin, 2)) * facCmoneda)
    frmContadorI.txtContNilo = tmp
    frmContadorI.txtHistNilo = "Actualizado a las " & Time}
  end else begin
    if OnReqConfigGen<>nil then  //Pide información global
        OnReqConfigUsu(Usuario);
    //Pasa el mensaje a las cabinas.
    for fac in items do begin
      //Aquí se puede escribir datos adicionales en el terminal y el registro
      TCibFacLocutor(fac).ProcesarLinea(lin, facCmoneda, Usuario, CategVenta);
    end;
  end;
//  DebugLn('linea:'+lin);
end;
procedure TCibGFacNiloM.nilConex_CambiaEstado(nuevoEstado: TNilEstadoConex);
begin
  FestadoCnx := nuevoEstado;
  if OnCambiaEstadoCnx<>nil then OnCambiaEstadoCnx(FestadoCnx);
//DebugLn('estado:'+lin);
end;
procedure TCibGFacNiloM.nilConex_RegMensaje(NomObj: string; msj: string);
begin
  if OnRegMensaje<>nil then OnRegMensaje(Nombre, msj);
end;
procedure TCibGFacNiloM.nilConex_ProcesarCad(cad: string);
begin
  if OnProcesarCad<>nil then OnProcesarCad(cad);
end;
procedure TCibGFacNiloM.nilConex_ProcesarLin(cad: string);
begin
  if OnProcesarLin<>nil then OnProcesarLin('', cad);  //evento
end;
procedure TCibGFacNiloM.Conectar;
{Inicia la conexión}
begin
  if ModoCopia then exit;
  AbrirRegistro;
  if MsjError<>'' then begin
    //No poder escribir en el registro es un error grave. Se debe terminar el programa.
    MsgErr(MsjError);
    exit;
  end;
  nilConex.Conectar;
  nilConex.EnvComando('$');
end;
procedure TCibGFacNiloM.Desconectar;
begin
  if ModoCopia then exit;
  nilConex.Desconectar;
  CerrarRegistro;
end;
procedure TCibGFacNiloM.EnvComando(com: string; IncluirSalto: boolean);
begin
  if ModoCopia then exit;
  nilConex.EnvComando(com, IncluirSalto);
  { TODO : Tal vez se debería incluir algún medio para determinar
  si se produce error con el envío }
end;
procedure TCibGFacNiloM.EnviaComEspPr(cad: string);
{Envia comando esperando el prompt antes de seguir. Debe recibir sólo
una línea de texto.}
var
  cont: integer;
begin
  msjError := '';
  llego_prompt := false;    //inicia bandera
  EnvComando(cad);
  if msjError <> '' Then exit;
  //Espera respuesta
  cont := 0;
  while Not llego_prompt And (cont < 400) do begin
      sleep(5);
      Application.ProcessMessages;  //para no congelar el aplicativo
      cont := cont + 1;
  end;
  if cont = 400 Then begin
      msjError := 'Falla al enviar comando al NILO. Tiempo de respuesta agotado. ';
//      PLogErr msjError    //Escribe error en registro
  end;
end;
procedure TCibGFacNiloM.EnvCadena(cadena: string);
{Envia una cadena de comandos al NILO. Pueden haber varias líneas. Se espera
a que salga el prompt antes de enviar la siguiente línea. Reconoce el
caracter de control "\n".
Si hay error muestra el mensaje.}
var
  i: Integer;
  a: TStringDynArray;
begin
   msjError := '';
   if cadena = '' then begin
       EnviaComEspPr('');
       exit;
   end;
   //Convierte salto de línea y divide
   cadena := StringReplace(cadena, '\n', LineEnding, [rfReplaceAll]);
   a := explode(LineEnding, cadena);
   for i := 0 To High(a) do begin
       if a[i] = '\p' Then begin //comando de pausa
           sleep(500);
       end else begin
           EnviaComEspPr(a[i]);
           If msjError <> '' Then begin
               MsgErr(msjError);  //Muestra mensaje
               exit;
           end;
       end;
   end;
end;
function TCibGFacNiloM.Agregar(nomLoc: string; num_can: char; tabTar0: TNiloMTabTar): TCibFacLocutor;

var
  loc: TCibFacLocutor;
begin
  loc := TCibFacLocutor.Create;   //crea cabina
  loc.Nombre:= nomLoc;
  loc.num_can:=num_can;
  loc.TabTar := tabTar0;
  AgregarItem(loc);   //aquí se configuran algunos eventos
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := loc;
end;
procedure TCibGFacNiloM.EjecAccion(idFacOrig: string; tram: TCPTrama);
var
  traDat, nom : String;
  facDest: TCibFac;
  Err: boolean;
begin
  traDat := tram.traDat;  //crea copia para modificar
  ExtraerHasta(traDat, SEP_IDFAC, Err);  //Extrae nombre de grupo
  nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto
  facDest := ItemPorNombre(nom);
  if facDest=nil then exit;
  facDest.EjecAccion(idFacOrig, tram, '');
  {¿No és este código similar para todos los facturables?. AL menos para comandos
   destinados a los facturables y no a los grupos.}
end;
procedure TCibGFacNiloM.MenuAccionesVista(MenuPopup: TPopupMenu);
{Configura las acciones para ejecutarse en la vista}
begin
  InicLlenadoAcciones(MenuPopup);
  //No hay acciones, aún, para el Grupo NiloM
end;
procedure TCibGFacNiloM.MenuAccionesModelo(MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  InicLlenadoAcciones(MenuPopup);
  nShortCut := -1;
  AgregarAccion(nShortCut, 'Cone&xiones' , @mnVerConexiones, icoConexi);
  AgregarAccion(nShortCut, 'B&uscar Tarifas', @mnBuscarTarif, icoBusTar);
  AgregarAccion(nShortCut, '&Propiedades' , @mnPropiedades, icoPropie);
end;
procedure TCibGFacNiloM.mnVerConexiones(Sender: TObject);
begin
  frmNilomConex.Show;
end;
procedure TCibGFacNiloM.mnPropiedades(Sender: TObject);
begin
  frmNilomProp.Exec(self);
end;
procedure TCibGFacNiloM.mnBuscarTarif(Sender: TObject);
begin
  frmBusTar.Exec(self);
end;
//Constructor y destructor
constructor TCibGFacNiloM.Create(nombre0: string; ModoCopia0: boolean);
begin
  inherited Create(nombre0, ctfNiloM);
  timer1 := TTimer.Create(nil);
  timer1.Interval:=1000;
  arcLog    := TCibTablaHist.Create;  //crea su propio archivo de registro
  FModoCopia := ModoCopia0;    //Asigna al inicio para saber el modo de trabajo
debugln('-Creando: '+ nombre0);
  tipo       := ctfNiloM;
  if not FModoCopia then begin
    timer1.OnTimer:=@timer1Timer;
    //Configura ventana de conexiones
    frmNilomConex:= TfrmNiloMConex.Create(nil);   //crea vent. de conexiones de forma dinámica
    frmNilomConex.padre := self;  //referencia a la clase
    OnTermWrite:=@frmNilomConex.TermWrite;
    OnTermWriteLn:=@frmNilomConex.TermWriteLn;
    OnRegMensaje :=@frmNilomConex.RegMensaje;
    //Configura ventaba de propiedades
    frmNilomProp:= TfrmNiloMProp.Create(nil);
    frmNilomProp.onCambiaProp:=@frmNilomProp_CambiaProp;
    frmNilomProp.gfac := self;  {Este formulario requiere que se asigne esta referecncia,
                                 desde el principio, porque necesita procesar las tarifas
                                 y rutas, tempranamente.}
    //COnfigura la conexión serial
    nilConex    := TNiloConexion.Create;
    nilConex.OnCambiaEstado:= @nilConex_CambiaEstado;
    nilConex.OnProcesarCad := @nilConex_ProcesarCad;
    nilConex.OnProcesarLin := @nilConex_ProcesarLin;
    nilConex.OnRegMensaje  := @nilConex_RegMensaje;
    nilConex.OnTermWrite   := @nilConex_TermWrite;
    nilConex.OnTermWriteLn := @nilConex_TermWriteLn;
  end;
  //Configuración de tarifas y rutas
  tarif         := TNiloMTabTar.Create;    //crea tarifas
  tarif.OnLogErr:=@tarif_LogErr;
  tarif.OnLogInf:=@tarif_LogInf;
  rutas         := TNiloMTabRut.Create;
  rutas.OnLogErr:=@tarif_LogErr;
  rutas.OnLogInf:=@tarif_LogInf;

  ArcTarif := rutApp + DirectorySeparator + 'tarifario.txt';  //valor fijo por ahora
  ArcRutas := rutApp + DirectorySeparator + 'rutas.txt';  //valor fijo por ahora
  facCmoneda  := 0.1;  //valor por defecto
  FestadoCnx  := necMuerto;  //este es el estadoCnx inicial, porque no se ha creado el hilo
  //Conectar;  //No inicia la conexión
  mens_error:= TStringList.Create;
  Agregar('LOCUTORIO 1','0', tarif);
  Agregar('LOCUTORIO 2','1', tarif);
  Agregar('LOCUTORIO 3','2', tarif);
  Agregar('LOCUTORIO 4','3', tarif);
  CategVenta := 'COUNTER';
  //Configura parámetros de control de inicio de llamadas
  IniLLamMan  := false;
  IniLLamTemp := false;
  PerLLamTemp := 10;   //inicia
  //Formulario para búsqueda de tarifas
  frmBusTar := TfrmBuscTarif.Create(nil);
end;
destructor TCibGFacNiloM.Destroy;
begin
//debugln('-destruyendo: '+ self.Nombre);
  frmBusTar.Destroy;
  mens_error.Destroy;
  rutas.Destroy;
  tarif.Destroy;
  if not FModoCopia then begin
    nilConex.Destroy;
    frmNilomProp.Destroy;
    frmNilomConex.Destroy;
  end;
  arcLog.Destroy;
  timer1.OnTimer:=nil;
  timer1.Destroy;
  inherited Destroy;
end;

end.

