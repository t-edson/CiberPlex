{Unidad con definiciones y funciones para el tratamiento de los enrutadores
'Nilo-M.
Define a la clase TCPNiloM, que es el objeto que se usa para controlar
a los locutorios usando el enrutador NILO-m.
Notar que el objeto TCPNiloM, maneja su propio archivo de registro, que es independiente
del archivo de registro de la aplicación. Esto se ha diseñado así, previendo el uso de
diversos objetos TCPNiloM, cada uno escribiendo en su propio archivo de registro.}
unit CibGFacNiloM;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, LCLProc, MisUtils, crt, strutils, CibFacturables,
  CibNiloMConex, CibRegistros, FormNiloMConex, FormNiloMProp,
  CibNiloMTarifRut, Globales;
const
  IDE_EST_LOC = 'l';   //identificador de estado de cabina
  MAX_TAM_LIN_LOG = 300;  //Lóngitud máxima de línea recibida que se considera válida
type
  TCibGFacNiloM = class;

  { TCibFacLocutor }

  TCibFacLocutor = class(TCibFac)
  public  //Campos de Propiedades (No cambian frecuentemente)
    num_can : char;     //canal del NILO asociado a este locutorio '0', '1', '2', '3'
    //variables de control de limitacion
    tpoLimitado : integer; //Bandera de Tiempo limitado
    ctoLimitado : Double;  //costo limitado
  private //Variables actualizadas automáticamente
    trm     : TCibGFacNiloM;  //Referencia al enrutador.
    //variables de acumulación
    costo_tot: Double;  //costo acumulado de todas las llamadas
    num_llam : Double;  //número de llamadas acumuladas
  protected
    descolg : Boolean;    //Bandera de descolgado
    llam    : regLlamada; //llamada en curso
    llamadas: regLlamada_list;  //lista de llamadas
    PosLlam : integer;
    tic_con : Integer;    //Contador para contestación automática
    procedure LeeListaLlamadas;
    procedure ProcesaColgado;
    procedure ProcesaDescolgado;
    procedure ProcesaDigitado(dig: String; tarif: TNiloMTabTar);
    procedure ProcesarContestada(cansal: String);
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
  Public
    col_costo: Integer;  //indica cual es la columna que contiene el costo
    r       : regTarifa;
    trama_tmp: String;    //bolsa temporal para la trama
    fBol    : TCibBoleta;
    function AgregarFila: integer;
    procedure EscribeDatosAdicionales;
    procedure ProcesarLinea(linea: string; facCmoneda: double; usuario: string;
      CategLocu: string; tarif: TNiloMTabTar);
  public  //constructor y destructor
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
    lin_serial: string;     //acumula los datos recibidos hasta completar la línea
    //Funciones para manejo del registro
    procedure AbrirRegistro;
    procedure CerrarRegistro;
    procedure frmNilomProp_CambiaProp;
    procedure loc_CambiaPropied;
    procedure ErrorLog(mensaje: string);
  private //Funciones para escribir en los archivos de registros
    procedure VolcarErrorLog;
    procedure EscribeLog(mensaje: string);
    procedure EscribeLogPrompt;
    procedure EscribeTer(mensaje: string);
    procedure EscribeTerPrompt;
  protected //Getters and Setters
    function GetPuertoN: string;
    procedure SetPuertoN(AValue: string);
    function GetCadPropied: string; override;
    procedure SetCadPropied(AValue: string); override;
    function GetCadEstado: string; override;
    procedure SetCadEstado(AValue: string); override;
  public
    ArcReg    : string;  //Archivo de registro para el registr propio del enrutador
    ArcTarif  : string;  //Archivo de configuración de tarifas
    ArcRutas  : string;  //Archivo de configuración de rutas
    MsjError  : string;  //Bandera - Mensaje de error
    facCmoneda: Double;
    frmNilomConex: TfrmNiloMConex;
    frmNilomProp: TfrmNiloMProp;
    tarif     : TNiloMTabTar;      //Contenedor de tarifas
    rutas     : TNiloMTabRut;      //Contenedor de rutas
    property estadoCnx: TNilEstadoConex read FestadoCnx
             write FestadoCnx;   {"estadoCnx" es una propiedad de solo lectura, pero se
                                   habilita la escritura, para cuando se usa sin Red}
//    property Puerto: string read nilConex.puerto;
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
    OnCambiaEstadoCnx: TEvCambiaEstado;  //Cambia el estado de la conexión
    OnRegMensaje  : TEvRegMensaje;  //Indica que ha llegado un mensaje de la conexión
    OnProcesarCad : TEvProcesarCad; //indica que hay una cadena lista esperando
    OnProcesarLin : TEvRegMensaje;  //Se genera una línea para registrar mensaje
    //Manejo del terminal
    OnTermWrite   : TEvProcesarCad;
    OnTermWriteLn : TEvProcesarCad;
    //Eventos propios de la clase
    OnRegMsjError : TEvRegMensaje;   //Se solicita registrar un mensaje de error
    procedure Conectar;
    procedure Desconectar;
    procedure EnvComando(com: string; IncluirSalto: boolean = true);
    function Agregar(nomLoc: string; num_can: char): TCibFacLocutor;
  public  //constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;

var
  tamano_buffer   : Integer;
  mostrar_recibido: Boolean;  //Bandera para mostrar el texto recibido
  grabando_nilo   : Boolean;  //Bandera para indicar que se está grabando
  cancelar_envio  : Boolean;  //Bandera para cancelar el envío de un archivo CNL
  bloquear_rx     : Boolean;  //Bandera para detener la escritura en el log
  simular         : Boolean;  //Bandera de simulación

implementation
const
  MAX_ERROR_LOG_LLAM = 200; //Máximo número de errores permitidos en una llamada

Function duracN(cad: String): Integer;
//Devuelve la duración en segundos
var
  min : Integer;
  seg : Integer;
begin
  if (length(cad) = 6) and (cad[1] in ['0'..'9']) and
                           (cad[2] in ['0'..'9']) and
                           (cad[3] in ['0'..'9']) and
                           (cad[4] = ':') and
                           (cad[5] in ['0'..'9']) and
                           (cad[6] in ['0'..'9']) then begin

      min := StrToInt(MidStr(cad, 1, 3));
      seg := StrToInt(MidStr(cad, 5, 2));
      Result := min * 60 + seg;
  End else begin
    Result := 0;
  end;
end;
Function verTiempo(cad: String): String;
//Recibe cadena de duración del NILO: MMMSS y devuelve tiempo en formato hh:nn:ss.
//Si hay error devuelve en MsjError
var
  min : Integer;
  hor : Integer;
begin
    msjError := '';
    if cad = '' Then begin
      Result := '';
      exit;   //Un caso válido de llamada colgada
    end;
    if (length(cad) = 5) and (cad[1] in ['0'..'9']) and
                             (cad[2] in ['0'..'9']) and
                             (cad[3] in ['0'..'9']) and
                             (cad[4] in ['0'..'9']) and
                             (cad[5] in ['0'..'9']) then begin
        min := StrToInt(MidStr(cad, 1, 3));
        hor := min div 60;
        min := min Mod 60;
        Result := FormatFloat('00', hor) + ':' +
                  FormatFloat('00', min) + ':' +
                  MidStr(cad, 4,2);
    end else begin
        Result := cad;
        msjError := 'Cadena de duración no cumple formato (' + cad + ')';
    end;
End;
Function verPasos(cad : String; paso : Integer; var seg_restantes: Integer): Integer;
{Recibe cadena de duración del NILO: MMMSS y devuelve la cantidad de pasos redondeado al
máximo entero superior.
También devuelve la cantidad de segundos excedentes que se redondearon}
var
  min : Integer;
  seg : Integer;
  nseg : Integer;
begin
    msjError := '';
    If paso = 0 Then
      msjError := '"paso" de llamada es 0. No se puede calcular num.pasos"';
    if (length(cad) = 5) and (cad[1] in ['0'..'9']) and
                             (cad[2] in ['0'..'9']) and
                             (cad[3] in ['0'..'9']) and
                             (cad[4] in ['0'..'9']) and
                             (cad[5] in ['0'..'9']) then begin
        min := StrToInt(MidStr(cad, 1, 3));
        seg := StrToInt(MidStr(cad, 4, 2));
        nseg := min * 60 + seg;
        If nseg Mod paso = 0 Then begin
            Result := nseg div paso;
        end Else begin
            Result := (nseg div paso) + 1;
            seg_restantes := nseg Mod paso;
        End;
    end Else begin
        msjError := 'Cadena de duración no cumple formato (' + cad + ')';
    End;
End;
Function verCosto(const cad, CPaso : String; ccosto : String) : Double;
//Devuelve el costo de la llamada analizando la duración, el paso y el costo
//SE PUEDE OPTIMIZAR ????????????????????????????????????
var
  npasos : Integer;
  paso : Integer;
  subpaso : Integer;
  Costo : Double;
  subcosto : Double;
  restantes : Integer;    //segundos restantes
  costopaso1 : Double;
  tmp : Double;
  a: TStringDynArray;
begin
    msjError := '';
    If cad = '' Then begin   //No hay duración. El Nilo no dio tiempo, t=0
        Result := 0; Exit;
    End;
    If CPaso = '' Then begin
        msjError := ' variable //cpaso// nula. No se puede calcular costo ';
        Exit;
    End;
    If ccosto = '' Then begin
        msjError := ' variable //ccosto// nula. No se puede calcular costo ';
        Exit;
    End;
    If pos('/', CPaso)<>0 Then begin   //Hay subpaso
        a := Explode('/', CPaso);
        paso := StrToInt(a[0]);
        subpaso := StrToInt(a[1]);
    end Else begin
        paso := StrToInt(CPaso);
        subpaso := 0;
    End;
    //Verifica existencia de Costo de Paso 1
    If pos(':', ccosto)<>0 Then begin //Hay costo de paso 1
        a := Explode(':', ccosto);
        costopaso1 := StrToFloat(a[0]);  //Hay
        ccosto := a[1];   //recorta
    end Else begin
        costopaso1 := -1;     //Indica que no hay
    End;

    If pos('/', ccosto)<>0 Then begin   //Hay subpaso
        a := Explode('/', ccosto);
        Costo := StrToFloat(a[0]);
        subcosto := StrToFloat(a[1]);
    end Else begin
        Costo := StrToFloat(ccosto);
        subcosto := 0;
    End;

    npasos := verPasos(cad, paso, restantes);
    If npasos = 0 Then begin
      Result := 0; exit;
    end;

    If costopaso1 <> -1 Then npasos := npasos - 1;

    //Puede generar error, no importa... If MsjError <> '' Then
    If subpaso = 0 Then begin //Si no hay subpaso, el cálculo es normal
        tmp := npasos * Costo;
    end else begin        //Si hay subpaso
        //ver si aplica el subpaso
        If (restantes > 0) And (restantes <= subpaso) Then begin //aplica
            npasos := npasos - 1;
            tmp := npasos * Costo + subcosto;
        end else begin                   //no aplica
            tmp := npasos * Costo;
        end;
    end;
    If costopaso1 <> -1 Then tmp := tmp + costopaso1;    //Había
    Result := tmp;
End;
function TCibFacLocutor.AgregarFila: integer;
{Agrega un registro, a la lista de llamadas. Devuelve índice al último registro.}
var
  l : regLlamada;
begin
  l := regLlamada.Create;
  llamadas.Add(l);
  Result := llamadas.Count-1;
end;
procedure ActualizaLista();
//Actualiza la fila del listbox que representa a la llamada
begin
  //No se implementa la parte visual aquí
end;

{ TCibFacLocutor }
procedure TCibFacLocutor.LeeListaLlamadas();
//Actualiza las variables "costo_tot" y "num_llam"
var
  l: regLlamada;
  Costo : String;
begin
    //Calcula el costo total de llamadas
    costo_tot := 0;
    num_llam := 0;
    For l in Llamadas do begin  //no toma encabezado
        Costo := l.Costo;
//        If costo Like "##*" Then
            num_llam := num_llam + 1;
            //convierte a punto, por si lo cambió la config.regional.
            Costo := StringReplace(Costo, ',', '.', []);
            costo_tot := costo_tot + StrToFloat(Costo);   //val() sólo reconoce punto
//        End If
    end;
End;
function TCibFacLocutor.GetCadEstado: string;
{Los estados son campos que pueden variar periódicamente. La idea es incluir aquí, solo
los campos que deban ser actualizados}
begin
  Result := IDE_EST_LOC + {se omite la coma para reducir tamaño}
         nombre + #9 +    {el nombre es obligatorio para identificarLO unívocamente}
         B2f(descolg);
  //Agrega información sobre los ítems de la boleta
  if boleta.ItemCount>0 then
    Result := Result + LineEnding + boleta.CadEstado;
end;
procedure TCibFacLocutor.SetCadEstado(AValue: string);
begin

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
procedure TCibFacLocutor.EscribeDatosAdicionales;
//Escribe datos en el registro y en el terminal
var
  linea: string;
begin
    linea := FormatDateTime('yyyy/mm/dd hh:nn:ss', now) +
             ' COST:' + FormatFloat('000.00', llam.COST_NTER) +
             ' DESC:' + llam.DESCR_ +
             ' CAT:' + llam.CATEG_;
    trm.EscribeTer(linea);
    trm.EscribeTerPrompt;      //Se escribe prompt para no alterar el formato de log
    trm.EscribeLog(linea);
    trm.VolcarErrorLog;        //Vuelca también los mensajes de error
    trm.EscribeLogPrompt;      //Se escribe prompt para no alterar el formato de log
end;
procedure TCibFacLocutor.ProcesaDigitado(dig : String; tarif: TNiloMTabTar);
var
  rr : regTarifa;
begin
    tic_con := 0;     //reinicia contador
    llam.NUM_DIG := llam.NUM_DIG + dig;    //Acumula número digitado
    if Length(llam.NUM_DIG) = 1 Then begin     //Inicio de llamada
        if PosLlam = 0 Then begin  //si es que no tiene asignada una posición en la lista
            PosLlam := AgregarFila;
            llam.HORA_INI := now;
            llam.DURAC_ := '';
        end;
    end;
    //actualiza datos de llamada
//    llam.descrip = ""                //Actualiza descripción
//    llam.paso = ""                   //Actualiza paso
//    llam.costop = ""                 //Actualiza costo por paso
//    llam.costo = 0
//    i = frmConsTar.HayTarifa(llam.numdig)
    rr := tarif.BuscaTarifa(llam.NUM_DIG);      //Si no encuentra devuelve campos nulos
    llam.DESCR_ := rr.descripcion;     //Actualiza descripción
    llam.PASO_ := rr.paso;               //Actualiza paso
    llam.COSTOP_ := rr.costop;           //Actualiza costo por paso
    llam.COST_NTER := 0;
    llam.CATEG_ := rr.categoria;         //Lee la categoría

    ActualizaLista();
End;
procedure TCibFacLocutor.ProcesaColgado;
begin
    descolg := False;     //La llamada está colgada
    if llam.CONTES Then begin   //estaba contestada, se asume fin de llamada
        //No se generó el cdr '#'
        //Ha terminado la llamada, se aprovecha para registrar datos adicionales
        //de la llamada antes de que venga otro flujo de caracteres por el serial
        bloquear_rx := True;  //para evitar que se escriban datos en el log, mientras escribimos los datos adicionales
        EscribeDatosAdicionales;
        //Genera sonido para llamadas con tiempo
        if (llam.DURAC_ <> '') And (llam.DURAC_ <> '00:00:00') Then begin
            //PlaySound(CarpetaSnd + '\colgado.wav', ByVal 0&, SND_FILENAME Or SND_ASYNC Or SND_NODEFAULT)
        end;
        bloquear_rx := False;  //libera el bloqueo
        llam.CONTES := False;
//        costo_tot = costo_tot + llam.costo //acumula costo
        LeeListaLlamadas;
    end;
    if llam.NUM_DIG <> '' Then begin  //sólo cuando se ha generado un registro
        ActualizaLista();
//        frmPrincipal.MiLista1.Resize    //fuerza actualización
        llam.NUM_DIG := '';    //inicia número digitado
    end;
    PosLlam := 0;    //Límpia bandera de posición de llamada
end;
procedure TCibFacLocutor.ProcesaDescolgado();
begin
    PosLlam := -1;    //Límpia bandera de posición de llamada
    descolg := True;     //La llamada está colgada
    tic_con := 0;        //Inicia contador
end;

procedure TCibFacLocutor.ProcesarContestada(cansal: String);
//Procesa una llamada contestada. "cansal" es el canal de salida actual de la
//llamada
begin
    If Length(llam.NUM_DIG) = 0 Then begin   //¿No hubo digitado?. Puede pasar
        If PosLlam = 0 Then begin   //si es que no tiene asignada una posición en la lista
            PosLlam := AgregarFila;
            llam.HORA_INI := now;
        End;
        //Se debe limpiar los parámetros para evitar problemas
        llam.DESCR_    := '';      //Actualiza descripción
        llam.PASO_     := '';      //Actualiza paso
        llam.COSTOP_   := '';      //Actualiza costo por paso
        llam.COST_NTER := 0;
    End;
    llam.CONTES := True;
    descolg := True;     //La llamada está descolgada
    llam.HORA_CON := now;      //toma hora de contestación
end;
procedure TCibFacLocutor.ProcesarLinea(linea: string; facCmoneda: double; usuario: string;
  CategLocu{categoría de venta para lcoutorios}: string; tarif: TNiloMTabTar);
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
  tmp : String;
  nser : Integer;
  rr : TCibItemBoleta;
  L : regTarifa;
begin
    If linea = 'Ctda' + num_can then begin
        //Se ha cortado la llamada
        descolg:= False;     //La llamada está colgada
        tpoLimitado := 0;     //al terminar una llamada en el NILO-m se reinicia el límite
        exit;
    end else if linea = 'Rtda' + num_can then begin   //Habilitada
        descolg := False;     //La llamada está colgada
        exit;
    end else if EsLineaCDR then begin
        //----Llegó el cdr   #001;0;00016;00002;00002;4;450;LOCAL----
        //Lee los campos del cdr original
        LeeCdrNilo(linea, llam.serie, llam.canal, llam.durac, llam.Costo,
                   llam.costoA, llam.canalS, llam.digitado, llam.descripc);
        llam.CONTES := False;
        //Calcula costos en campos calculados
        if llam.NUM_DIG = '' then begin
            //No se ha registrado el inicio de la llamada
            //Puede que haya estado cerrado el SW
            if trm.OnRegMsjError<>nil then
              trm.OnRegMsjError(trm.Nombre, 'Llamada registrada sin datos de inicio');
            PosLlam := AgregarFila;       //agrega fila
//            MiLista1.Refrescar;           //fuerza actualización
            llam.HORA_INI := now;         //asume la hora de inicio
            llam.NUM_DIG := llam.digitado;   //toma del CDR
            L := tarif.BuscaTarifa(llam.NUM_DIG);  //Si no encuentra devuelve campos nulos
            llam.DESCR_ := L.descripcion;    //Actualiza descripción
            llam.PASO_ := L.paso;            //Actualiza paso
            llam.COSTOP_ := L.costop;        //Actualiza costo por paso
            llam.CATEG_ := L.categoria;      //Lee la categoría
        end;
        tmp := MidStr(linea, 8, 5);     //tmp = 'MMMSS'
        llam.DURAC_ := verTiempo(tmp);     //Sincroniza tiempo, sobreescribe.
        If msjError <> '' then trm.ErrorLog(msjError);
        llam.COST_NTER := verCosto(tmp, llam.PASO_, llam.COSTOP_);    //Sincroniza costo
        If msjError <> '' then trm.ErrorLog(msjError);

        bloquear_rx := True;  //para evitar que se escriban datos en el log, mientras escribimos los datos adicionales
        EscribeDatosAdicionales;
        //Genera sonido para llamadas con tiempo
        if (llam.DURAC_ <> '') And (llam.DURAC_ <> '00:00:00') then begin
            { TODO : Falta implementar rutinas de sonido }
            //PlaySound(CarpetaSnd + '\colgado.wav', ByVal 0+, SND_FILENAME Or SND_ASYNC Or SND_NODEFAULT)
        end;
        bloquear_rx := False;  //libera el bloqueo
        ActualizaLista();  //Actualiza lista
        LeeListaLlamadas;               //Actualiza costo
//        lblCosto := ForCosto(costo_tot);      //Actualiza costo
//        lblNumLlam := MiLista1.ListCount + ' LLAMADAS';

        //Registra en el registro del programa
        tmp := llam.serie + #9 + FormatDateTime('dd/mm/yyyy', now) + #9 +
              FormatDateTime('hh:nn:ss', now) + #9 + llam.digitado + #9 +
              llam.durac + #9 + I2F(duracN(llam.durac)) + #9 +
              N2f(StrToFloat(llam.Costo) * facCmoneda) + #9 + N2f(llam.COST_NTER) + #9 +
              llam.canal + #9 + llam.canalS + #9 +
              llam.descripc + #9 + llam.CATEG_ + #9 + USUARIO + #9 +
              nombre + #9 + trm.PuertoN + #9 + CategLocu + #9 + #9 + #9 + #9; //campos ampliados
        { TODO : Ver si es corrrecto acceder al registro desde aquí }
        nser := PLogLlam(tmp, llam.COST_NTER);    //toma serie
        If msjError <> '' Then MsgErr(msjError);
        //agrega item a boleta
        rr.vser := nser;
        rr.descr := 'Llam: ' + llam.NUM_DIG + '(' + llam.descripc + ')';
        rr.pUnit := llam.COST_NTER;
        rr.subtot := llam.COST_NTER;
        rr.cat := CategLocu;
        rr.subcat := 'LLAMADA';
        rr.vfec := now;
        rr.estado := IT_EST_NORMAL;
        rr.fragmen := 0;
        rr.conStk := False;    //no se maneja stock
        fBol.VentaItem(rr, False);
    end;

    if copy(linea, 1, 2)  = 'n' + num_can then  //Procesamiento de número digitado
        ProcesaDigitado(Copy(linea, 3, 1), tarif)
    else if copy(linea, 1, 2)  = 'c' + num_can then  //Llamada colgada
        ProcesaColgado
    else if copy(linea, 1, 2)  = 'y' + num_can then     //Llamada contestada
        ProcesarContestada(MidStr(linea, 3, 1))  //indica canal de salida
    else if copy(linea, 1, 2)  = 'd' + num_can then   //Llamada descolgada
        ProcesaDescolgado;
end;

constructor TCibFacLocutor.Create;
begin
  inherited Create;
  tipo := ctfNiloM;   //se identifica
  llamadas:= regLlamada_list.Create(true);
  llam  := regLlamada.Create;
end;
destructor TCibFacLocutor.Destroy;
begin
  llam.Destroy;
  llamadas.Destroy;
  inherited Destroy;
end;

{ TCibGFacNiloM }
//Funcione para manejo del registro
procedure TCibGFacNiloM.AbrirRegistro();
{Actualiza nombre final de arhcivo de registro}
var
  NombProg, NombLocal, Usuario: string;
begin
  if OnReqConfigGen<>nil then  //Pide información global
      OnReqConfigGen(NombProg, NombLocal, Usuario);
  ArcReg := NombFinal(rutDatos, NombLocal + '.' + nilConex.puertoN, '.dat');
  if msjError <> '' then exit;
  EscribeLog('');
  EscribeLog(NombProg);
  EscribeLog('Inicio CIBERPX --- ' + FormatDateTime('yyyy/mm/dd hh:nn:ss', now));
end;
procedure TCibGFacNiloM.CerrarRegistro();
begin
    EscribeLog('Fin CIBERPX    --- ' + FormatDateTime('yyyy/mm/dd hh:nn:ss', now));
    EscribeLog('');
end;
procedure TCibGFacNiloM.frmNilomProp_CambiaProp;
{Se produjo un cambio en las propiedades del NILO-m.}
begin
  if OnCambiaPropied<>nil then OnCambiaPropied;
end;
procedure TCibGFacNiloM.loc_CambiaPropied;
begin
  //dispara evento
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibGFacNiloM.ErrorLog(mensaje: string);
{Escribe un mensaje de error en el archivo de registro de llamadas.
En realidad los guarda en una lista hasta que se vuelcan de golpe}
begin
    //Acumula los mensajes, no los guarda directamente para no malograr el formato del "log"
    //Se vuelca al archivo en el momento apropiado
    mens_error.Add('ERROR: ' + TimeToStr(Time) + '-' + mensaje);
end;
function TCibGFacNiloM.tarif_LogErr(mensaje: string): integer;
//Se solicita registrar un mensaje de error
var
  NombProg, NombLocal, Usuario: string;
begin
  if OnReqConfigGen<>nil then  //Pide información global
      OnReqConfigGen(NombProg, NombLocal, Usuario);
  Result := PLogErr(usuario, mensaje);
end;
function TCibGFacNiloM.tarif_LogInf(mensaje: string): integer;
//Se solicita registrar un mensaje informativo
var
  NombProg, NombLocal, Usuario: string;
begin
  if OnReqConfigGen<>nil then  //Pide información global
      OnReqConfigGen(NombProg, NombLocal, Usuario);
  Result := PLogInf(usuario, mensaje);
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
    EscribReg(ArcReg, lin_serial + '---CIBERPX: ' + mensaje);
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
  Result := nilConex.puertoN;
end;
procedure TCibGFacNiloM.SetPuertoN(AValue: string);
begin
  nilConex.puertoN:=AValue;
end;
function TCibGFacNiloM.GetCadPropied: string;
var
  c : TCibFac;
begin
  //Información del grupo en la primera línea
  Result := Nombre + #9 + CategVenta + #9 + N2f(Fx) + #9 +
            N2f(Fy) + #9 + PuertoN + #9 + N2f(facCmoneda) + #9 + #9;
  //Información de las cabinas en las demás líneas
  for c in items do begin
    Result := Result + LineEnding + TCibFacLocutor(c).CadPropied;
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
  facCmoneda:=f2N(a[5]);
  lineas.Delete(0);  //elimima línea
  //Procesa líneas con información de las cabinas
  items.Clear;
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    loc := Agregar('','0');
    loc.CadPropied := lin;
  end;
  lineas.Destroy;
end;
function TCibGFacNiloM.GetCadEstado: string;
{Devuelve el estado del enrutador y de los locutorios que contiene, en una cadena. La
idea es que esta información se lea frecuéntemente, porque contiene propiedades que
cambian frecuéntemente. }
var
  loc : TCibFac;
begin
  {No se incluye el estadoCnx del enrutador, por ahora. Se asume que no tene variables que
  cambien continuamente, aunque se puede asumir que las llamadas cursadas alteran el
  estadoCnx del enrtador, pudiendo generar un efecto gráfico como en CIBERPLEX de VB.}
  //Delimitador inicial y propiedades de objeto.
  Result := '<' + I2f(ord(self.tipo)) + #9 + Nombre + LineEnding;
  for loc in items do begin
    Result += loc.CadEstado + LineEnding;  //estadoCnx de locutorio
  end;
  Result += '>';  //delimitador final.
end;
procedure TCibGFacNiloM.SetCadEstado(AValue: string);
begin

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
end;
procedure TCibGFacNiloM.nilConex_TermWriteLn(const subcad: string; const lin: string
  );
{Se usa para refrescar al terminal y escribir en el registro.}
var
  fac: TCibFac;
  NombProg, NombLocal, Usuario: string;
begin
  lin_serial := lin_serial + subcad;
  msjError := EscribReg(ArcReg, lin_serial);  //en el registro, escibe la línea completa.
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
        OnReqConfigGen(NombProg, NombLocal, Usuario);
    //Pasa el mensaje a las cabinas.
    for fac in items do begin
      //Aquí se puede escribir datos adicionales en el terminal y el registro
      TCibFacLocutor(fac).ProcesarLinea(lin, facCmoneda, Usuario, CategVenta, tarif);
    end;
  end;
  DebugLn('linea:'+lin);

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
  nilConex.Desconectar;
  CerrarRegistro;
end;
procedure TCibGFacNiloM.EnvComando(com: string; IncluirSalto: boolean);
begin
  nilConex.EnvComando(com, IncluirSalto);
end;
function TCibGFacNiloM.Agregar(nomLoc: string; num_can: char): TCibFacLocutor;

var
  loc: TCibFacLocutor;
begin
  loc := TCibFacLocutor.Create;   //crea cabina
  loc.Nombre:= nomLoc;
  loc.num_can:=num_can;
  loc.trm := self;
  loc.OnCambiaPropied:=@loc_CambiaPropied;
  loc.Grupo := self;
  items.Add(loc);  //agrega
  if OnCambiaPropied<>nil then OnCambiaPropied();
  Result := loc;
end;
//constructor y destructor
constructor TCibGFacNiloM.Create(nombre0: string);
begin
  inherited Create(nombre0, ctfNiloM);
debugln('-Creando: '+ nombre0);
  tipo       := ctfNiloM;
  frmNilomConex:= TfrmNiloMConex.Create(nil);   //crea vent. de conexiones de forma dinámica
  frmNilomProp:= TfrmNiloMProp.Create(nil);
  frmNilomProp.onCambiaProp:=@frmNilomProp_CambiaProp;
  nilConex    := TNiloConexion.Create;  //Crea la conexión serial
  //Configuración de tarifas y rutas
  tarif       := TNiloMTabTar.Create;    //crea tarifas
  tarif.OnLogErr:=@tarif_LogErr;
  tarif.OnLogInf:=@tarif_LogInf;
  rutas       := TNiloMTabRut.Create;
  rutas.OnLogErr:=@tarif_LogErr;
  rutas.OnLogInf:=@tarif_LogInf;

  ArcTarif := rutApp + DirectorySeparator + 'tarifario.txt';  //valor fijo por ahora
  ArcRutas := rutApp + DirectorySeparator + 'rutas.txt';  //valor fijo por ahora
  facCmoneda  := 0.1;  //valor por defecto
  FestadoCnx  := cecMuerto;  //este es el estadoCnx inicial, porque no se ha creado el hilo
  //Conectar;  //No inicia la conexión
  mens_error:= TStringList.Create;
  nilConex.OnCambiaEstado:= @nilConex_CambiaEstado;
  nilConex.OnProcesarCad := @nilConex_ProcesarCad;
  nilConex.OnProcesarLin := @nilConex_ProcesarLin;
  nilConex.OnRegMensaje  := @nilConex_RegMensaje;
  nilConex.OnTermWrite   := @nilConex_TermWrite;
  nilConex.OnTermWriteLn := @nilConex_TermWriteLn;
  Agregar('LOC1','0');
  Agregar('LOC2','1');
  Agregar('LOC3','2');
  Agregar('LOC4','3');
  CategVenta := 'LLAMADAS';
  //Configura terminal
  frmNilomConex.padre := self;  //referencia a la clase
  frmNilomProp.padre := self;
  //GFacNiloM.OnProcesarCad:=@frmNilomConex.ProcesarCad;
  OnTermWrite:=@frmNilomConex.TermWrite;
  OnTermWriteLn:=@frmNilomConex.TermWriteLn;
  OnRegMensaje :=@frmNilomConex.RegMensaje;
end;
destructor TCibGFacNiloM.Destroy;
begin
debugln('-destruyendo: '+ self.Nombre);
  mens_error.Destroy;
  rutas.Destroy;
  tarif.Destroy;
  nilConex.Destroy;
  frmNilomProp.Destroy;
  frmNilomConex.Destroy;
  inherited Destroy;
end;

end.

