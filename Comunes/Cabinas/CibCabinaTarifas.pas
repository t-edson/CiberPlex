{Definiciones para el manejo de la tarificación en las cabinas. Se adapta a partir
 del modulo de traifiación del NILOTER-m.

Áquí se definen 2 objetos principales:

Tarifas de Alquiler y
Tarifario de Cabinas

Por Tito Hinostroza
}
unit CibCabinaTarifas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, dateutils, math, types, fgl, MisUtils;
const
  MAX_NUM_CAB_INT = 50;        //máximo número de cabinas de internet
  MAX_TOLE_CAB_INT = 10;       //tolerancia en minutos para tiempos de cabina
  INTER_SON_CAB_VENC = 60 * 1; //intervalo en segundos para generar sonido
                               //de cabina vencida.
const
  MAX_NPASOS_TARC = 5;   //Máximo número de pasos para tarifas de cabinas
                         //Si se cambia, se debe también cambiar CuentaPasosTarC()
type  //Definición de Tarifas de alquiler

  { TTarPaso }
  TTarPaso = class
  private
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
  public
   //Define el tipo Paso de Tarifa de Cabina
    paso : integer;   //pasos en minutos
    cost : Single;    //valor del costo para los pasos
    cosP : Single;    //Costo Parcial, campo auxiliar para el proceso del costeo
    function pasoSeg: integer;  //paso en segundos
    property StrObj: string read GetStrObj write SetStrObj;  //Objeto como cadena
  end;
  TTarPaso_list = specialize TFPGObjectList<TTarPaso>;

  { TTarAlquiler }
  TTarAlquiler = class   //Tipo tarifas de alquiler
  private
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
    procedure CuentaPasosTarC(var nseg: integer);
  public
    nombre : string;      //Nombre de la tarifa
    pasos  : TTarPaso_list;
    msjError: string;
    OnCambia: procedure of object;  //cambio de propiedades
    property StrObj: string read GetStrObj write SetStrObj;  //Objeto como cadena
    function AgregaPaso(paso: integer; cost: single): TTarPaso;  //Agrega paso
    function CostoAlq(transc: integer): double;
    constructor Create;
    destructor Destroy; override;
  end;
  TTarAlquiler_list = specialize TFPGObjectList<TTarAlquiler>;

  { TGrupoTarAlquiler }
  TGrupoTarAlquiler = class
    procedure taCambia;
  private
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
  public
    items: TTarAlquiler_list;  //Lista de Tarifas de alquiler
    msjError: string;
    OnCambia: procedure of object;  //cambio de propiedades
    property StrObj: string read GetStrObj write SetStrObj;  //Objeto como cadena
    function TarAlqPorNombre(nom: string): TTarAlquiler;  //busca tarifa de alquiler
    function Agregar(nombre0: string): TTarAlquiler;  //Agrega una tarifa de alquiler
    function Eliminar(nombre0: string): boolean;
    constructor Create;
    destructor Destroy; override;
  end;

type  //Definiicón de franjas y tarifas diarias

  { TCPFranja }
  {Franja horaria}
  TCPFranja = class
  private
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
  public
    {Las horas se expresan en segundos para facilidad de cálculo, cuando se use
    esta clase para edición de las franjas}
    hor1: integer;  //hora inicial de la franja
    hor2: integer;  //hora final de la franja
    tarAlq: string;  //nombre de la tarifa de alquiler que corresponde a la franja
    property StrObj: string read GetStrObj write SetStrObj;  //Objeto como cadena
  end;
  TCPFranja_list = specialize TFPGObjectList<TCPFranja>;

  { TCPTarifaDia }
  TCPTarifaDia = class
  private
    nombre : string;     //nombre del día
    Franjas  : TCPFranja_list;  //lista de franjas
    function BuscaFranja(hor: TDateTime): TCPFranja;
    function CostoAlq(hor_ini: TDateTime; transc: integer;
                      GrpTarAlq: TGrupoTarAlquiler): double;
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
  public
    msjError  : string;
    OnCambia: procedure of object;
    property StrObj: string read GetStrObj write SetStrObj;  //Objeto como cadena
    constructor Create(nomb: string);
    destructor Destroy; override;
  end;

  { TCPTarifCabinas }
  {Define al objeto Tarifa de Cabina. }
  TCPTarifCabinas = class
  private
    tarAlq: TGrupoTarAlquiler;  //ref. al grupo de tarifas de alquiler que usará
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
    function GetTolerMin: integer;
    procedure SetTolerMin(AValue: integer);
  public
    horLunes: TCPTarifaDia;
    horMartes: TCPTarifaDia;
    horMiercol: TCPTarifaDia;
    horJueves: TCPTarifaDia;
    horViernes: TCPTarifaDia;
    horSabado: TCPTarifaDia;
    horDomingo: TCPTarifaDia;
    horFeriado: TCPTarifaDia;
    toler: integer;  //tolerancia en segundos
    msjError: string;
    property StrObj: string read GetStrObj write SetStrObj;  //Objeto como cadena
    property tolerMin: integer read GetTolerMin write SetTolerMin;  //"toler" en mintuos
    function CostoAlq(hor_ini: TDateTime; trans: integer): double;
    procedure Validar;  //valida las tarifas diarias
    constructor Create(tarAlq0: TGrupoTarAlquiler);
    destructor Destroy; override;
  end;

implementation
function CompararPasos(const p1, p2: TTarPaso): Integer;
{Función de comparación para el ordenamiento de los pasos}
begin
   if p1.paso = p2.paso then
     CompararPasos := 0
   else
     if p1.paso<p2.paso then
       CompararPasos := 1
     else
       CompararPasos := -1;
end;

{ TCPFranja }
function TCPFranja.GetStrObj: string;
begin
  Result :=
    I2f(hor1) + '|' +
    I2f(hor2) + '|' +
    tarAlq;
end;
procedure TCPFranja.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
begin
   campos := explode('|',AVAlue);
   hor1 := f2I(campos[0]);
   hor2 := f2I(campos[1]);
   tarAlq := campos[2];
end;

{ TTarPaso }
function TTarPaso.GetStrObj: string;
begin
  Result := I2f(paso) + '|' + N2f(cost);
end;
procedure TTarPaso.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
begin
  campos := explode('|', Avalue);
  paso := f2I(campos[0]);
  cost := f2N(campos[1]);
end;
function TTarPaso.pasoSeg: integer;
begin
  Result := paso * 60;
end;

{ TTarAlquiler }
function TTarAlquiler.GetStrObj: string;
var
  pas: TTarPaso;
begin
  Result := nombre;
  //agrega información de los pasos
  for pas in pasos do begin
    Result += #9 + pas.StrObj;
  end;
end;
procedure TTarAlquiler.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
  pas: TTarPaso;
  i: Integer;
begin
  campos := explode(#9, AValue);
  nombre := campos[0];
  //agrega los pasos
  pasos.Clear;
  for i:=1 to high(campos) do begin
    pas:= TTarPaso.Create;
    pas.StrObj:=campos[i];
    pasos.Add(pas);
  end;
  if OnCambia<>nil then OnCambia();
end;
function TTarAlquiler.AgregaPaso(paso: integer; cost: single): TTarPaso;
{El paso se da en minutos}
var
  pas: TTarPaso;
begin
  //Verifica si ya hay paso
  for pas in pasos do begin
    if pas.paso = paso Then begin
      msjError := 'Ya existe este paso.';
      exit;
    end;
  end;
  //agrega nuevo paso
  pas:= TTarPaso.Create;
  pas.paso:=paso;
  pas.cost:=cost;
  pasos.Add(pas);
  //ordena pasos de mayor a menor, para poder facilitar el costeo
  pasos.Sort(@CompararPasos);
  if OnCambia<>nil then OnCambia();
  AgregaPaso := pas;
end;
procedure TTarAlquiler.CuentaPasosTarC(var nseg: integer);
{Calcula los costos parciales que hay en un tiempo dado. Actualiza el
campo "cosP" de los pasos de la tarifa de alquiler.
Se usa para facilitar la tarificación. Actualiza el campo "nseg"}
var
  pas: TTarPaso;
  npas : Integer;     //número de pasos
begin
  {Se supone que los pasos están ordenados de mayor a menor, así que la exploración
  se hace desde los pasos más grandes a los más pequeños. La idea es usar primero
  múltiplos de los pasos mayores y luego ir completando con múltiplos de los pasos
  menores. Por ejemplo, si el tiempo es de 02:45:00, y se tienen dos pasos: de 1h y
  30m, entonces se obtienen dos pasos de 1h y 1 paso de 30m.}
  for pas in pasos do begin
    npas := nseg div pas.pasoSeg;  //división entera
    //calcula costo parcial
    pas.cosP := npas * pas.cost;
    nseg := nseg - pas.pasoSeg * npas;
  end;
end;
function TTarAlquiler.CostoAlq(transc: integer): double;
{Devuelve el costo de alquiler para un tiempo transcurrido en segundos.}
var
  Costo: double;
  i: Integer;
  minPaso: integer;
begin
  transc := transc - 1;  //se quita 1 segundo para cambiar el costo  1 seg. después del paso
  minPaso := pasos.Last.pasoSeg;   //Toma paso mínimo
  transc := transc + minPaso;      //sigue método de tarificaión
  if transc<0 then transc:=0;      //protección
  CuentaPasosTarC(transc);
  //Calcula costo desde los pasos más pequeños
  Costo := 0;
  for i := pasos.Count-1 downto 0 do begin
    if pasos[i].cosP <> 0 Then begin
      if i > 1 then    //hay paso anterior
        Costo := min(Costo + pasos[i].cosP, pasos[i - 1].cost)
      else
        Costo := Costo + pasos[i].cosP;
    end;
  end;
  Result := Costo;
end;
constructor TTarAlquiler.Create;
begin
  pasos := TTarPaso_list.Create(true);
end;
destructor TTarAlquiler.Destroy;
begin
  pasos.Destroy;
  inherited Destroy;
end;

{ TGrupoTarAlquiler }
procedure TGrupoTarAlquiler.taCambia;
begin
  if OnCambia<>nil then OnCambia();
end;
function TGrupoTarAlquiler.GetStrObj: string;
var
  ta: TTarAlquiler;
begin
  Result := '';
  for ta in items do begin
    Result+=ta.StrObj + LineEnding;
  end;
end;
procedure TGrupoTarAlquiler.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
  ta: TTarAlquiler;
  lin: String;
begin
  campos := Explode(lineending, Avalue);
  items.Clear;
  for lin in campos do begin
    if lin = '' then continue;
    ta := TTarAlquiler.Create;
    ta.StrObj := lin;
    ta.OnCambia:=@taCambia;
    items.Add(ta);
  end;
  if OnCambia<>nil then OnCambia();
end;
function TGrupoTarAlquiler.TarAlqPorNombre(nom: string): TTarAlquiler;
{Devuelve la referencia a una tarifa de alquiler, ubicándola por su nombre. Si no la
enuentra devuelve NIL.}
var
  ta : TTarAlquiler;
begin
  for ta in items do begin
    if ta.Nombre = nom then exit(ta);
  end;
  exit(nil);
end;
function TGrupoTarAlquiler.Agregar(nombre0: string): TTarAlquiler;
{Agrega una tarifa de alquiler}
var
  ta: TTarAlquiler;
begin
  //valida nombre
  for ta in items do begin
    if Upcase(ta.nombre) = UpCase(nombre0) then begin
      self.msjError:='Nombre de Tarifa de Alquiler, duplicado.';
      exit;
    end;
  end;
  ta := TTarAlquiler.Create;
  ta.nombre:=nombre0;
  ta.OnCambia:=@taCambia;
  items.Add(ta);
  if OnCambia<>nil then OnCambia();
  Result := ta;
end;
function TGrupoTarAlquiler.Eliminar(nombre0: string): boolean;
{Elimina una tarifa de alquiler, dado el nombre. Si no tiene éxito devuelve FALSE}
var
  ta: TTarAlquiler;
begin
  ta := TarAlqPorNombre(nombre0);
  if ta = nil then exit(false);
  items.Remove(ta);  //puede tomar tiempo, por la destrucción del hilo
  if OnCambia<>nil then OnCambia();
  Result := true;
end;
constructor TGrupoTarAlquiler.Create;
begin
  items:= TTarAlquiler_list.Create(true);
end;
destructor TGrupoTarAlquiler.Destroy;
begin
  items.Destroy;
  inherited Destroy;
end;

{ TCPTarifaDia }
function TCPTarifaDia.GetStrObj: string;
var
  fra: TCPFranja;
begin
  Result := nombre;
  for fra in Franjas do begin
    Result += #9 + fra.StrObj;
  end;
end;
procedure TCPTarifaDia.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
  fra: TCPFranja;
  i: Integer;
begin
  campos := explode(#9, AValue);
  nombre := campos[0];
  //agrega los pasos
  franjas.Clear;
  for i:=1 to high(campos) do begin
    fra := TCPFranja.Create;
    fra.StrObj:=campos[i];
    franjas.Add(fra);
  end;
  if OnCambia<>nil then OnCambia();
end;
function TCPTarifaDia.BuscaFranja(hor: TDateTime): TCPFranja;
{Busca una tarifa de cabina de acuerdo a la franja horaria La coincidencia en el intervalo
es inclusiva.
Si no encuentra devuelve NIL}
var
  fra: TCPFranja;
  horSeg: integer;  //"hor" en segundos
begin
  //Convierte a segundos
  horSeg := HourOf(hor)*3600+MinuteOf(hor)*60+SecondOf(hor);
  for fra in Franjas do begin
    if (horSeg >= fra.hor1) And (horSeg <= fra.hor2) Then begin
      Result:= fra;
      exit;    //encontró la tarifa
    end;
  end;
  Result := nil;
end;
function TCPTarifaDia.CostoAlq(hor_ini: TDateTime; transc: integer;
  GrpTarAlq: TGrupoTarAlquiler): double;
{Calcula el costo del alquiler.
 "transc" es el tiempo transcurrido.}

var
  franja: TCPFranja;
  ta : TTarAlquiler;
begin
  msjError := '';
  //ubica franja horaria, que corresponde
  if Franjas.Count = 0 Then begin
     msjError := 'No hay franja horaria para el día: ' + nombre;
     exit(0);
  end else begin
     franja := BuscaFranja(hor_ini);
     if franja = nil then begin
       msjError := 'Error encontrando tarifa de cabina por franja horaria';
       exit(0);
     end;
  end;
  //Ubica la Tarifa de alquiler
  ta := GrpTarAlq.TarAlqPorNombre(franja.tarAlq);
  if ta = nil then begin   //no hay tarifa asignada
    msjError := 'No se encuentra tarifa de alquiler: ' +  franja.tarAlq +
                ' para el día ' + nombre;
    exit(0);
  end;
  if ta.pasos.Count = 0 Then begin
    exit(0); //No hay pasos definidos
  end;
  //finalmente calcula el costo
  Result := ta.CostoAlq(transc);
end;
constructor TCPTarifaDia.Create(nomb: string);
begin
  Franjas  := TCPFranja_list.Create(true);
  nombre := nomb;
end;
destructor TCPTarifaDia.Destroy;
begin
  Franjas.Destroy;
  inherited Destroy;
end;

{ TCPTarifCabinas }
function TCPTarifCabinas.GetStrObj: string;
begin
  Result :=  I2f(toler) + LineEnding +
             horLunes.StrObj + LineEnding +
             horMartes.StrObj + LineEnding +
             horMiercol.StrObj + LineEnding +
             horJueves.StrObj + LineEnding +
             horViernes.StrObj + LineEnding +
             horSabado.StrObj + LineEnding +
             horDomingo.StrObj + LineEnding +
             horFeriado.StrObj;
end;
function TCPTarifCabinas.GetTolerMin: integer;
begin
  Result := toler div 60;
end;
procedure TCPTarifCabinas.SetTolerMin(AValue: integer);
begin
  toler := AValue * 60;
end;
procedure TCPTarifCabinas.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
begin
  if AValue='' then exit;
  campos := explode(lineending, AValue);
  toler := f2I(campos[0]);
  horLunes.StrObj  := campos[1];
  horMartes.StrObj := campos[2];
  horMiercol.StrObj:= campos[3];
  horJueves.StrObj := campos[4];
  horViernes.StrObj:= campos[5];
  horSabado.StrObj := campos[6];
  horDomingo.StrObj:= campos[7];
  horFeriado.StrObj:= campos[8];
end;
function TCPTarifCabinas.CostoAlq(hor_ini: TDateTime; trans: integer): double;
var
  transc: Integer;
begin
  //Verifica periodos cortos
  if trans <= toler Then begin
      //dentro de la tolerancia
      Result := 0;
      exit;
  end;
  //Cálculo normal, aquí se supone que seg_trans > toler
  transc := trans - toler;
  Case DayOfTheWeek(date) of    //busca día de la semana
  1:  //lunes
      Result := horLunes.CostoAlq(hor_ini, transc, tarAlq);
  2:  //martes
      Result := horMartes.CostoAlq(hor_ini, transc, tarAlq);
  3:  //miércoles
      Result := horMiercol.CostoAlq(hor_ini, transc, tarAlq);
  4:  //jueves
      Result := horJueves.CostoAlq(hor_ini, transc, tarAlq);
  5:  //viernes
      Result := horViernes.CostoAlq(hor_ini, transc, tarAlq);
  6:  //sábado
      Result := horSabado.CostoAlq(hor_ini, transc, tarAlq);
  7:  //domingo
      Result := horDomingo.CostoAlq(hor_ini, transc, tarAlq);
  end;
  //Puede devolver error en "msjError"
  //Result := transc;
end;
procedure TCPTarifCabinas.Validar;
{Valida que las tarifas diarias apunten a tarifas de aqluiler que realmente existan}
  function ValidarDia(dia: TCPTarifaDia): boolean;
  //Valida intentando calcular el costo para ese día. Si hay error devuelve FALSE
  begin
    dia.CostoAlq(now,3600, tarAlq);
    if dia.msjError<>'' then begin
      self.msjError := dia.msjError;
      exit(false);
    end;
    exit(true);
  end;
begin
  self.msjError := '';
  if tarAlq= nil then begin
    self.msjError := 'No se ha asignado tarifas de alquiler.';
    exit;
  end;
  if tarAlq.items.Count = 0 then begin
    self.msjError := 'No se han creado tarifas de alquiler.';
    exit;
  end;
  //Valida las tarifas diarias.
  if not ValidarDia(horLunes) then exit;
  if not ValidarDia(horMartes) then exit;
  if not ValidarDia(horMiercol) then exit;
  if not ValidarDia(horJueves) then exit;
  if not ValidarDia(horViernes) then exit;
  if not ValidarDia(horSabado) then exit;
  if not ValidarDia(horDomingo) then exit;
  if not ValidarDia(horFeriado) then exit;
end;
constructor TCPTarifCabinas.Create(tarAlq0: TGrupoTarAlquiler);
begin
  tarAlq := tarAlq0;
  horLunes  := TCPTarifaDia.Create('Lunes');
  horMartes := TCPTarifaDia.Create('Martes');
  horMiercol:= TCPTarifaDia.Create('Miércoles');
  horJueves := TCPTarifaDia.Create('Jueves');
  horViernes:= TCPTarifaDia.Create('Viernes');
  horSabado := TCPTarifaDia.Create('Sábado');
  horDomingo:= TCPTarifaDia.Create('Domingo');
  horFeriado:= TCPTarifaDia.Create('Feriado');
end;
destructor TCPTarifCabinas.Destroy;
begin
  horLunes.Destroy;
  horMartes.Destroy;
  horMiercol.Destroy;
  horJueves.Destroy;
  horViernes.Destroy;
  horSabado.Destroy;
  horDomingo.Destroy;
  horFeriado.Destroy;
  inherited Destroy;
end;

end.

