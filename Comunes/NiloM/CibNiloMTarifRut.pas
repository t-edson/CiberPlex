{Unidad con definiciones básicas para la tarificación y el enrutamiento. Incluye:
* Definiciones de los registros de tarifas y rutas.
* La definición de los contenedores para las tablas de tarifas y rutas: TNiloMTabTar y
TNiloMTabRut.
* Rutinas para el pre-procesamiento del tarifario y tabla de rutas.
}
unit CibNiloMTarifRut;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, Types, math, LCLProc, Graphics, SynEditHighlighter,
  strutils, MisUtils, SynFacilHighlighter, XpresBas;
Const
  MAX_DEFINICIONES = 50;
  MAX_NIV_ARRUT = 10;   //Máximo nivel del arbol de rutas
  MAX_TAM_CODPR = 20;   {Tamaño máximo de la cadena de los códigos de prefijos
                         para guardar en EEPROM. 10 códigos por 2 caracteres.}

type
  {Fomato del CDR del NILO-m: #001;0;00016;00002;00002;4;450;LOCAL}

  { TRegCDRNiloM }

  TRegCDRNiloM = object
  public  //Campos del CDR
    serie   : string;
    canal   : string;
    durac   : string;
    Costo   : string;
    costoA  : string;
    canalS  : string;
    digitado: string;
    descripc: string;
  public //Campos adicionales
    msjErr : string;
    duracSeg: integer;  //duración en segundos
    procedure LeeCdrNilo(linea: String);
  end;

  { TRegTarifa }
  //Define el tipo que almacena una tarifa (Una línea del archivo tarifario)
  TRegTarifa = class
    //Campos leidos directamente del archivo tarifario
    serie   : String;     //serie de la tarifa
    categoria : string;   //categoría de llamada
    descripcion: String;  //Descripción de la serie
    //Campos calculados
    HaySubPaso : Boolean;  //Indica si hay subpaso (y por lo tanto subcosto)
    nPaso      : Integer;  //Valor del paso en segundos
    nSubpaso   : Integer;  //Valor del subpaso en segundos
    nCtoPaso   : Double;   //Valor del costo del paso en flotante
    nCtoSubPaso: Double;   //Valor del subcosto del paso en flotante
    HayCtoPaso1: Boolean;  //Indica si hay costo de paso 1
    nCtoPaso1  : Double;   //Costo del Paso 1 en flotante
    function paso: String;  //Paso como cadena
    function costop: string;  //Costo como cadena
    procedure assign(reg: TRegTarifa);   //para copia
  end;
  regTarifa_list = specialize TFPGObjectList<TRegTarifa>;

  //Define el tipo que almacena una ruta (Una línea del archivo de rutas)

  { TRegRuta }

  TRegRuta = class
    serie : string;    //Serie digitada
    numdig: integer;   //Número de digitos
    codPre: string;    //Cósigos de Prefijos
    indNT : integer;   //índice a colección. Solo se usa en "rutasA"
    procedure assign(reg: TRegRuta);   //para copia
  end;
  regRuta_list = specialize TFPGObjectList<TRegRuta>;




  //Tipo de evento para mensajes
  TEvLogInfo = function(mensaje: string): integer of object;

type   //Tipos para manejo de definiciones
  TNilDefinicion = class  //estructura de definicion
    con : String;   //contenido de la definicion
    nom : String;   //nombre de la definicion
    nlin : Integer; //número de línea donde se encuentra la definición
  end;
  TNilDefinicion_list = specialize TFPGObjectList<TNilDefinicion>;

  { TContextTar }
  {Contexto ampliado para manejar el tarifario}
  TContextTar = class(TContext)
  private
    xLex : TSynFacilSyn;
    procedure ProcesaLinea2(var linea: string; var fil: Integer; recMoneda: boolean=
      true);
  public
    msjError: string;
    tkPrepro: TSynHighlighterAttributes;  //atributo para procesar definiciones
    definiciones: TNilDefinicion_list;
    function ExisteDefinicion(def: String): TNilDefinicion;
    function CogerCad: string;
    function CogerInt: integer;
    function CogerFloat: double;
  private //Funciones de identificación del token actual
    function EsDEFINIR: boolean;
    function EsCOMO: boolean;
    function EsFINDEFINIR: boolean;
    function EsMoneda: boolean;
    function EsNumero: boolean;
    function EsCadena: boolean;
    function EsIdentif: boolean;
    function EsDefinicion(var def: TNilDefinicion): boolean;
    procedure AgregaDefinicion(const nom, con: string; numlin: integer);
  public //Constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

type
  { TNiloMTab }
  {Clase padre para los contenedores de tabla de tarifas y de rutas}
  TNiloMTab = class
  private //funciones para registrar mensajes
    function PLogErr(mensaje: string): integer;
    function PLogInf(mensaje: String): integer;
  public  //Eventos para registrar mensajes
    OnLogErr: TEvLogInfo;
    OnLogInf: TEvLogInfo;
  public
    msjError: string;    //mensaje de error
    filError, colError: integer;  //posición del error
  end;

  { TNiloMTabTar }
  {Contenedor para la tabla de tarifas}
  TNiloMTabTar = class(TNiloMTab)
  private
    nlin : integer;
    ctx  : TContextTar;   //contexto para procesar el tarifario
    procedure ActualizarMinMax;
    function BuscaTarifaI(num: String): TRegTarifa;
    function regTarif_DeEdi(r: TRegTarifa; cad: string; facCmoneda: double): string;
    procedure VerificFinal(var numlin: Integer);
  public
    monNil : string;   //símbolo de moneda a grabar en el NILO-m
    tarifasTmp: regTarifa_list;
    tarifas: regTarifa_list;
    tarNula: TRegTarifa;  //tarifa con valores nulos
    minCostop, maxCostop: Double;   //costo mínimo y máximo
    function BuscaTarifa(num: String): TRegTarifa;
    procedure CargarTarifas(lins: TStrings; facCmoneda: double);
//    function CargarTarifas(archivo: String; facCmoneda: double): Integer;
  public  //Constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

  { TNiloMTabRut }
  {Contenedor para la tabla de rutas}
  TNiloMTabRut = class(TNiloMTab)
  private
    nlin : integer;
    ctx  : TContextTar;   //contexto para procesar el tarifario
    function CodifPref(codStr: string): byte;
    function regRuta_DeEdi(r: TRegRuta; cad: string): string;
  public
    rutasTmp: regRuta_list;
    rutas: regRuta_list;
    procedure CargarRutas(lins: TStrings);
  public  //Constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

  procedure ConfigurarSintaxisTarif(hl: TSynFacilSyn; var attPrepro: TSynHighlighterAttributes);
  procedure ConfigurarSintaxisRutas(hl: TSynFacilSyn; var attPrepro: TSynHighlighterAttributes);

  function VerificarCadCodpre(cad : String): string;
  Function CodifPref(codStr: string; var Err: string): Byte;
  Function DecodPref(codPre: Byte): String;

implementation
Function SeriesIguales(ser1, ser2 : string): Boolean;
//Compara dos series considerando que "ser2" puede tener el comodín "?"
var
  i : Integer;
begin
    if Length(ser1) <> Length(ser2) Then exit(false);
    if Length(ser1) = 0 Then exit(true);
    For i := 1 To Length(ser1) do begin
        If MidStr(ser2, i, 1) <> '?' Then  begin //el comodín coincide con cualquier cosa
            If MidStr(ser1, i, 1) <> MidStr(ser2, i, 1) Then
                exit(false);
        End;
    end;
    Result := True;   //concidieron
End;
procedure ConfigurarSintaxisTarif(hl: TSynFacilSyn; var attPrepro: TSynHighlighterAttributes);
{Configura la sintaxis de un resaltador, para que reconozca la sintaxis de un tarifario
para un NILO-mC/D/E}
begin
  hl.ClearSpecials;               //para empezar a definir tokens
  hl.CreateAttributes;            //Limpia atributos
  hl.ClearMethodTables;           //limpìa tabla de métodos
  attPrepro := hl.NewTokType('preprocesador');
  attPrepro.Foreground:=clRed;        //color de texto
  attPrepro.Style:=[fsBold];
  hl.tkKeyword.Style:=[fsBold];
  //Define tokens. Notar que la definición de número es particular
  hl.DefTokIdentif('[$A-Za-z_]', '[A-Za-z0-9_]*');
  hl.DefTokContent('[0-9#*]', '[0-9#*.]*', hl.tkNumber);
  hl.DefTokDelim('"','"', hl.tkString);
  hl.DefTokDelim('//','',hl.tkComment);
  hl.tkComment.Style:=[];
  //define palabras claves
  hl.AddIdentSpecList('DEFINIR COMO FINDEFINIR', attPrepro);
  hl.AddIdentSpecList('MONEDA', hl.tkKeyword);
  hl.Rebuild;  //reconstruye
end;
procedure ConfigurarSintaxisRutas(hl: TSynFacilSyn; var attPrepro: TSynHighlighterAttributes);
{Configura la sintaxis de un resaltador, para que reconozca la sintaxis de una tabla de
rutas para un NILO-mC/D/E}
begin
  hl.ClearSpecials;               //para empezar a definir tokens
  hl.CreateAttributes;            //Limpia atributos
  hl.ClearMethodTables;           //limpìa tabla de métodos
  attPrepro := hl.NewTokType('preprocesador');
  attPrepro.Foreground:=clRed;        //color de texto
  attPrepro.Style:=[fsBold];
  hl.tkKeyword.Style:=[fsBold];
  //Define tokens. Notar que la definición de número es particular
  hl.DefTokIdentif('[$A-Za-z_]', '[A-Za-z0-9_]*');
  hl.DefTokContent('[0-9#*]', '[0-9#*.]*', hl.tkNumber);
  hl.DefTokDelim('"','"', hl.tkString);
  hl.DefTokDelim('//','',hl.tkComment);
  hl.tkComment.Style:=[];
  //define palabras claves
  hl.AddIdentSpecList('DEFINIR COMO FINDEFINIR', attPrepro);
  hl.Rebuild;  //reconstruye
end;
function VerificarCadCodpre(cad : String): string;
{Analiza una cadena de código de prefijos para ver si es válida.
Si hay error, actualiza devuelve mensaje de error.}
var
  i : Integer;
  Err: string;
begin
  Result := '';
  If Length(cad) > MAX_TAM_CODPR Then begin
      exit('Códigos de prefijo muy largo.');  //sale con error
  End;
  If Length(cad) Mod 2 <> 0 Then begin
      exit('Falta caracter en Códigos de prefijo');   //sale con error
  End;
  For i := 1 To Length(cad) div 2 do begin
      CodifPref(MidStr(cad, (2*i)-1, 2), Err);
      If Err <> '' Then exit(Err);
  end;
End;
Function CodifPref(codStr: string; var Err: string): Byte;
//Codifica una cadena de 2 bytes en un código de prefijo de un byte
//Si encuentra error, devuelve mensaje en "Err".
var
  com : char;
  num : char;
  arg : Byte;  //argumento
begin
    Err := '';
    If Length(codStr) <> 2 Then begin
        Err := 'Error en código de prefijo: ' + codStr;
        Exit;
    end;
    com := codStr[1];
    num := codStr[2];
    If num = '*' Then
        arg := 10
    Else If num = '#' Then
        arg := 11
    Else If num = 'p' Then
        arg := 12
    Else If num = '?' Then
        arg := 15
    Else
        arg := StrToInt(num);
    If com = 'c' Then
        CodifPref := $30 + arg
    Else If com = 'i' Then
        CodifPref := $20 + arg
    Else If com = 'q' Then
        CodifPref := $40 + arg
    Else If com = 'a' Then
        CodifPref := $50 + arg
    Else begin
        Err := 'Error en código de prefijo. Comando desconocido: ' + codStr;
        Exit;
    End;
end;
Function DecodPref(codPre: Byte): String;
//Decodifica un código de prefijo en su cadena indicadora
var
  com : Byte;
  num : Byte;
  car : String;
begin
  com := codPre div 16;
  num := codPre mod 16;
  if num = 10 Then
    car := '*'
  else If num = 11 Then
    car := '#'
  else If num = 12 Then
    car := 'p'
  else If num = 15 Then
    car := '?'
  else
    car := IntToStr(num);
  case com of
  3: Result := 'c' + car;
  2: Result := 'i' + car;
  4: Result := 'q' + car;
  5: Result := 'a' + car;
  end;
End;

{ TRegCDRNiloM }
procedure TRegCDRNiloM.LeeCdrNilo(linea: String);
{Lee el CDR del NILO-m. Si hay error, devuelve cadena con mensaje en "msjErr".}
var
  a: TStringDynArray;
  min, seg: integer;
begin
  //Lee sólo los campos generados por el NILO-m
  msjErr := '';
  a := Explode(';', linea);
  If High(a) < 7 then begin
      msjErr := 'Error leyendo CDR. Faltan campos: ' + linea;
      exit;
  end;
  serie   := copy(a[0], 2, 3);    //toma serie
  canal   := a[1];
  durac   := a[2];
  Costo   := a[3];
  costoA  := a[4];     //costo acumulado
  canalS  := a[5];
  digitado:= a[6];
  descripc:= a[7];
  //Actualiza campso adicionales
  if length(durac)<>5 then begin
    msjErr := 'Error leyendo CDR. Duración errónea.';
    duracSeg := 0;
    exit;
  end;
  if not TryStrToInt(MidStr(durac, 1, 3), min) then begin
    msjErr := 'Error leyendo CDR. Duración errónea.';
    duracSeg := 0;
    exit;
  end;
  if not TryStrToInt(MidStr(durac, 4, 2), seg) then begin
    msjErr := 'Error leyendo CDR. Duración errónea.';
    duracSeg := 0;
    exit;
  end;
  duracSeg:= min * 60 + seg;
end;

{ TRegTarifa }
function TRegTarifa.paso: String;
{Valor del paso en segundos tal y como se leería del archivo tarifario}
begin
  if HaySubPaso then Result:=IntToStr(nPaso)+'/'+IntToStr(nSubpaso)
  else Result:=IntToStr(nPaso);
end;

function TRegTarifa.costop: string;
{Costo del paso tal y como se leería del tarifario  (puede incluir sintaxis de SubCosto
o costo de paso 1)}
begin
  Result := FLoatToStr(nCtoPaso);
  if HaySubPaso then Result := Result + '/' + FLoatToStr(nCtoSubPaso);
  if HayCtoPaso1  then Result := FLoatToStr(nCtoPaso1) + ':' + Result;
end;

procedure TRegTarifa.assign(reg: TRegTarifa);
begin
  serie       := reg.serie;
  categoria   := reg.categoria;
  descripcion := reg.descripcion;
  //Campos calculados
  HaySubPaso  := reg.HaySubPaso;
  nPaso       := reg.nPaso;
  nSubpaso    := reg.nSubpaso;
  nCtoPaso      := reg.nCtoPaso;
  nCtoSubPaso   := reg.nCtoSubPaso;
  HayCtoPaso1   := reg.HayCtoPaso1;
  nCtoPaso1     := reg.nCtoPaso1;
end;
{ TRegRuta }
procedure TRegRuta.assign(reg: TRegRuta);
begin
  serie  := reg.serie;
  numdig := reg.numdig;
  codPre := reg.codPre;
  indNT  := reg.indNT;
end;
{ TContextTar }
function TContextTar.ExisteDefinicion(def: String): TNilDefinicion;
//Si una variable está definida devuelve su referencia, sino, devuelve NIL.
var
  d : TNilDefinicion;
  defM: string;
begin
  defM := upcase(def);
  for d in definiciones do begin
    if Upcase(d.nom) = defM Then exit(d);
  end;
  exit(nil);
end;
function TContextTar.CogerCad: string;
{Devuelve el token actual, como cadena y pasa al siguiente token.}
begin
  Result := Token;
  Next;   //pasa al siguiente
end;
function TContextTar.CogerInt: integer;
{Devuelve el token actual, como entero y pasa al siguiente token. Si no puede convertir
al token en entero, devuelve "MaxInt"}
begin
  if not TryStrToInt(Token, Result) then Result := MaxInt;
  Next;
end;
function TContextTar.CogerFloat: double;
{Devuelve el token actual, como entero y pasa al siguiente token. Si no puede convertir
al token en entero, devuelve "MaxFloat"}
begin
  if not TryStrToFloat(Token, Result) then Result := MaxFloat;
  Next;
end;

//Funciones de identificación del token actual
function TContextTar.EsDEFINIR: boolean;
{Indica si el identificador actual es la directiva DEFINIR}
begin
  Result := (TokenType = tkPrepro) and (upcase(Token) = 'DEFINIR') ;
end;
function TContextTar.EsCOMO: boolean;
begin
  Result := (TokenType = tkPrepro) and (upcase(Token) = 'COMO') ;
end;
function TContextTar.EsFINDEFINIR: boolean;
begin
  Result := (TokenType = tkPrepro) and (upcase(Token) = 'FINDEFINIR') ;
end;
function TContextTar.EsMoneda: boolean;
begin
  Result := (TokenType = lex.tkKeyword) and (upcase(Token) = 'MONEDA') ;
end;
function TContextTar.EsNumero: boolean;
begin
  Result := TokenType = lex.tkNumber;
end;
function TContextTar.EsCadena: boolean;
begin
  Result := TokenType = lex.tkString;
end;
function TContextTar.EsIdentif: boolean;
begin
  Result := TokenType = lex.tkIdentif;
end;
function TContextTar.EsDefinicion(var def: TNilDefinicion): boolean;
{Indica si el token actual es una definición. De ser así, devuelve TRUE y actualiza la
referencia.}
begin
  if TokenType<>lex.tkIdentif then exit(false);  //no es identificador
  def := ExisteDefinicion(token);  //busca el identificador
  Result := def<>nil;
end;
procedure TContextTar.AgregaDefinicion(const nom, con: string; numlin: integer);
{Agrega una definición a la lista}
var
  def: TNilDefinicion;
begin
  def := TNilDefinicion.Create;
  def.nom:=nom;
  def.con:=con;
  def.nlin:=numlin;
  definiciones.Add(def);
end;
procedure TContextTar.ProcesaLinea2(var linea : string; var fil : Integer;
    recMoneda: boolean = true);
{Hace la limpieza de una línea que va a ser leida del tarifario o del
archivo de rutas.
Los archivos a leer se procesan por líneas, por eso esta rutina solo trabaja con
una línea.
"recMoneda" indica que se debe reconocer la definición de MONEDA.}
var
  ident, conten : string;
  mon, lintmp, tok: string;
  def: TNilDefinicion;
begin
  SetSource(linea);
  lintmp := '';  //limpia para acumular
  msjError := '';
  while not Eof do begin
//    debugln(TokenType.Name + ':' + Token);
    if recMoneda and EsMoneda then begin
      Next;  //coge identificador
      SkipWhites;
      if Token<>'=' then begin
        msjError := 'Se esperaba "="'; exit;
      end;
      //Se toma el símbolo de moneda
      Next;
      SkipWhites;
      mon := '';  //toma símbolo hasta el final
      while not EsFINDEFINIR and not eof do begin
        mon := mon + token;
        next;
      end;
      AgregaDefinicion('MONEDA', mon, fil);
      linea := '';  //indica que ya lo procesó
      exit;         //sale
    end else if EsDEFINIR then begin
      Next;  //coge identificador
      SkipWhites;
      if TokenType<> lex.tkIdentif then begin
        msjError := 'Se esperaba identificador.'; exit;
      end;
      ident := token;  //toma identificador
      Next;  //coge identificador
      SkipWhites;
      if EsCOMO then begin
        //Forma DEFINIR xxx COMO ... FINDEFINIR
        Next;
        //toma hasta encontrar FINDEFINIR
        conten := '';
        while not EsFINDEFINIR and not eof do begin
          conten := conten + token;
          next;
        end;
        if eof then begin
          msjError := 'Se esperaba "FINDEFINIR".'; exit;
        end;
        AgregaDefinicion(ident, conten, fil);
        linea := '';  //indica que ya lo procesó
        exit;         //sale
      end else if Token = '=' then begin
        //Forma DEFINIR xxx = ...
        Next;
        //toma hasta fin de línea
        conten := '';
        while not eof do begin
          if TokenType <> lex.tkComment then conten := conten + token;
          next;
        end;
        AgregaDefinicion(ident, conten, fil);
        linea := '';  //indica que ya lo procesó
        exit;
      end else begin
        msjError := 'Se esperaba "COMO".';
        exit;
      end;
    end else if EsDefinicion(def) then begin
      //hay una definición que hay que reemplazar
      tok := def.con;   //reemplaza con su contenido
    end else if TokenType = lex.tkComment then begin
      //es un comentario
      tok := '';   //elimina
    end else begin  //es un token común
      tok := Token;
    end;
    lintmp := lintmp + tok;  //acumula
    Next;
  end;
  //Terminó de procesar. Devuelve la línea procesada
  linea := lintmp;
end;
constructor TContextTar.Create;
begin
  inherited Create;
  xLex := TSynFacilSyn.Create(nil);
  DefSyn(xLex);
  definiciones:= TNilDefinicion_list.Create(true);
end;
destructor TContextTar.Destroy;
begin
  definiciones.Destroy;
  xLex.Destroy;
  inherited Destroy;
end;
{ TNiloMTab }
function TNiloMTab.PLogErr(mensaje: string): integer;
begin
  Result := 0;
  if OnLogErr<>nil then Result := OnLogErr(mensaje);
end;
function TNiloMTab.PLogInf(mensaje: String): integer;
begin
  Result := 0;
  if OnLogInf<>nil then Result := OnLogInf(mensaje);
end;
{ TNiloMTabTar }
procedure TNiloMTabTar.ActualizarMinMax;
//Actualiza valores máximo y mínimo
var
  tar: TRegTarifa;
  cp: Double;
begin
  For tar in tarifas  do begin
    cp := tar.nCtoPaso;
    If cp < minCostop Then minCostop := cp;
    If cp > maxCostop Then maxCostop := cp;
    If tar.HaySubPaso Then begin
        cp := tar.nCtoPaso1;
        If cp < minCostop Then minCostop := cp;
        If cp > maxCostop Then maxCostop := cp;
    End;
  end;
end;
function TNiloMTabTar.BuscaTarifaI(num: String): TRegTarifa;
{Devuelve la referencia a una Tarifa para la serie indicada. Si no
encuentra una concidencia, devuelve NIL.
Cuando hay pocos dígitos, no es preciso en ubicar la tarifa.}
var
  clave : string;
  tar: TRegTarifa;
begin
  clave := num;
  While Length(clave) > 0 do begin
      for tar in Tarifas do begin
          if SeriesIguales(clave, tar.serie) Then exit(tar);
      end;
      clave := LeftStr(num, Length(clave) - 1);
  end;
  //No encuentra concidencia
  Result := nil;
end;
function TNiloMTabTar.regTarif_DeEdi(r: TRegTarifa; cad: string; facCmoneda: double): string;
{Convierte cadena de texto en registro. Se usa para leer del editor
Se asume que el editor sólo tiene espacios como separadores. Las tabulaciones
deben haberse reemplazado previamente. Si hay error, devuelve mensaje como cadena.}
var
  dif: ValReal;
begin
  Result := '';   //por defecto no hay error
  ctx.SetSource(cad);  //carga lexer
  //Coge SERIE
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsNumero then exit('Se esperaba número (0..9,#,*) en campo SERIE.');
  r.serie := ctx.CogerCad;  //lee y pasa al siguiente

  //Coge PASO
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  r.nPaso := ctx.CogerInt;  //lee y pasa al siguiente
  if r.nPaso = MaxInt then exit('Se esperaba número (0..9) en campo PASO.');
  if ctx.Token='/' then begin
    //Hay subpaso
    r.HaySubPaso:=true;
    ctx.Next;  //pasa al siguiente
    if ctx.Eof then exit('Campos insuficientes');
    r.nSubpaso := ctx.CogerInt;  //coge subpaso
    if r.nSubpaso = MaxInt then exit('Se esperaba número después de "/".');
  end;

  //Coge COSTO
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsNumero then exit('Se esperaba número.');
  r.nCtoPaso := ctx.CogerFloat;  //lee y pasa al siguiente (Se asume que es costo)
  if r.nCtoPaso = MaxFloat then exit('Se esperaba número en campo COSTO.');
  //Verifica si se trata de Costo de Paso1
  if ctx.Token=':' then begin
    //Es costo de paso 1
    r.HayCtoPaso1:=true;
    ctx.Next;
    r.nCtoPaso1:=r.nCtoPaso;   //copia el valor leído
    //ahora sí lee el costo
    r.nCtoPaso:= ctx.CogerFloat;
    if r.nCtoPaso= MaxFloat then exit('Se esperaba número en campo COSTO.');
  end;
  if r.HaySubPaso then begin
    //Hay subpaso, se espera un SubCosto
    if ctx.Token<>'/' then exit('Se esperaba SubCosto.');
    ctx.Next;   //coge "/"
    if ctx.Eof then exit('Campos insuficientes');
    r.nCtoSubPaso := ctx.CogerFloat;  //coge subpaso
    if r.nCtoSubPaso = MaxFloat then exit('Se esperaba número después de "/".');
  end;
  //Valida si es posible la codificación de este costo
  dif := frac(r.nCtoPaso / facCmoneda);
  dif := round(dif * 1000000)/1000000;  //redondea por posible error de decimales
  if (dif <> 0) and (dif<>1) Then begin
      exit('Costo de paso: ' + FloatToStr(r.nCtoPaso) +
           ' no se puede codificar con Factor de corrección de moneda: ' +
           FloatToStr(facCmoneda));
  end;
  if r.nCtoPaso>facCmoneda*255 then exit('Costo muy alto para ' +
            'Factor de corrección de moneda actual');  //Valida costo máximo
  if r.nCtoSubPaso>facCmoneda*255 then exit('SubCosto muy alto para ' +
            'Factor de corrección de moneda actual');  //Valida costo máximo
  if r.nCtoPaso1>facCmoneda*255 then exit('Costo de Paso 1 muy alto para ' +
            'Factor de corrección de moneda actual');  //Valida costo máximo

  //Coge CATEGORÍA
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsCadena and not ctx.EsIdentif then exit('Se esperaba cadena o identificador en CATEGORÍA.');
  r.categoria := ctx.CogerCad;  //lee y pasa al siguiente

  //Coge DESCRIPCIÓN
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsCadena then exit('Se esperaba cadena en campo DESCRIPCIÓN.');
  r.descripcion := ctx.CogerCad;  //lee y pasa al siguiente

  ctx.SkipWhites;
  if not ctx.Eof then exit('Demasiados campos');
end;
procedure TNiloMTabTar.VerificFinal(var numlin: Integer);
//Hace las verificaciones de símbolo de moneda
var
  tmp : String;
  def: TNilDefinicion;
begin
    def := ctx.ExisteDefinicion('MONEDA');
    If def <> nil Then begin //Se definio la moneda
        tmp := Trim(def.con);    //lee moneda
        If Length(tmp) > 2 Then begin
            msjError := 'Símbolo de moneda muy largo. Solo se permiten 2 caracteres.';
            numlin := def.nlin;     //posiciona en la definición
        end Else begin
            monNil := LeftStr(tmp + '  ', 2)   //completa con espacios
        End;
    end Else begin           //no se definió la moneda
        msjError := 'No se encontró definición de moneda (MONEDA = XX)';
        numlin := 1;    //posicion al inicio
    End;
end;
function TNiloMTabTar.BuscaTarifa(num: String): TRegTarifa;
{Devuelve un registro de tipo Tarifa para la serie indicada. Si no
encuentra una concidencia, devuelve un registro con sus campos vacios.
Cuando hay pocos dígitos, no es preciso en ubicar la tarifa.}
begin
  Result := BuscaTarifaI(num);
  if Result = nil then Result := tarNula;
end;
procedure TNiloMTabTar.CargarTarifas(lins: TStrings; facCmoneda: double);
{Carga las tarifas del TStrings indicado.
En condiciones normales actualiza el tarifario.
Si encuentra error, termina la carga y actualiza "msjError", "filError" y "colError".
En ese caso no modifica el tarifario actual.}
var
  linea , l: String;
  i : Integer;
  tar, tar2: TRegTarifa;
begin
  debugln('Cargando tarifas.');
  nlin := 0;
  minCostop := 1000000;
  maxCostop := 0;    //inicia máximo y mínimo
  ctx.definiciones.Clear;   //inicia preprocesador
  tarifasTmp.Clear;
  for l in lins do begin
      linea := l;
      nlin := nlin + 1;
      ctx.ProcesaLinea2(linea, nlin);     //Quita caracteres no válidos
      if ctx.msjError <> '' Then begin
          msjError := ctx.msjError + ' Línea: ' + IntToStr(nlin);
          break;
      end;
      if trim(linea) <> '' then  begin //tiene datos
          tar := TRegTarifa.Create;
          tarifasTmp.Add(tar);  //agrega nueva tarifa
          msjError := regTarif_DeEdi(tar, linea, facCmoneda);
          If msjError <> '' Then begin
            msjError := msjError + ' Línea: ' + IntToStr(nlin);
            break;
          end;
          //Verifica si hay duplicidad de serie
          for i:=0 to tarifasTmp.Count-2 do begin  //menos el último
            if tarifasTmp[i].serie = tar.serie then begin
              msjError := 'Serie duplicada: ' + tar.serie + ' Línea: ' + IntToStr(nlin);
              break;
            end;
          end;
      end;
  end;
  if msjError='' then VerificFinal(nlin);  //verificación final
  //verifica si hubo errores
  if msjError <> '' then begin
    //Salió por error
    PLogErr(msjError);
    filError := nlin;
    colError := ctx.col;  //en donde se quedó la exploración
    exit;    //sale con error y sin actualizar tarifas()
  end;
  //terminó la lectura sin errores
  tarifas.Clear;       //elimina objetos
  for tar in tarifasTmp do begin  //copia las tarifas
    tar2 := TRegTarifa.Create;  //crea copia para no interferir con objetos administrados
    tar2.assign(tar);    //crea copia
    tarifas.Add(tar2);    //copia tarifas
  end;
  tarifasTmp.Clear;     //libera objetos
  PLogInf(IntToStr(tarifas.Count) + ' tarifas cargadas.');
  ActualizarMinMax;
end;
//Constructor y destructor
constructor TNiloMTabTar.Create;
begin
  tarifasTmp:= regTarifa_list.Create(true);
  tarifas:= regTarifa_list.Create(true);
  tarNula:= TRegTarifa.Create;  //crea tarifa con campos en blanco
  ctx := TContextTar.Create;
  ConfigurarSintaxisTarif(ctx.xLex, ctx.tkPrepro);  //usa la misma sintaxis que el resaltador
end;
destructor TNiloMTabTar.Destroy;
begin
  ctx.Destroy;
  tarNula.Destroy;
  tarifas.Destroy;
  tarifasTmp.Destroy;
  inherited Destroy;
end;
{ TNiloMTabRut }
function TNiloMTabRut.regRuta_DeEdi(r: TRegRuta; cad: string): string;
{Convierte cadena de texto en registro. Se usa para leer del editor
Se asume que el editor sólo tiene espacios o tabulaciones como separadores.
Si hay error devuelve mensaje como cadena.}
var
  tmp, codStr: String;
begin
  Result := '';
  ctx.SetSource(cad);
  //Coge SERIE
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsNumero then exit('Se esperaba número (0..9,#,*) en campo SERIE.');
  r.serie := ctx.CogerCad;  //lee y pasa al siguiente

  //Coge NUMDIG
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsNumero then exit('Se esperaba número (0..9,#,*) en campo NUMDIG.');
  r.numdig:=ctx.CogerInt;  //toma como número
  if r.numdig = MaxInt then  exit('Campo NUMDIG debe ser valor numérico.');
  if r.numdig < 0 then exit('Campo NUMDIG debe ser mayor o igual a cero.');
  if r.numdig > 15 then exit('Campo NUMDIG debe ser menor o igual a 15.');

  //Coge CODPRE
  ctx.SkipWhites;
  if ctx.Eof then exit('Campos insuficientes');
  if not ctx.EsCadena then exit('Se esperaba cadena en campo CODPRE.');
  r.codPre := ctx.CogerCad;  //lee y pasa al siguiente
  r.codPre := copy(r.codPre,2,length(r.codPre)-2);  //quita comillas laterales
  //Valida CODPRE
  if length(r.codPre) > 20 then  //Solo se permiten hasta 20 caracteres en el NILO-mC/D/E
    exit('Códigos de prefijo muy largo.');
  tmp := r.codPre;
  while tmp<>'' do begin
    codStr := copy(tmp,1,2);  //toma caracteres
    if length(codStr)<2 then begin
      exit('Código de prefijo incompleto: "'+codStr+'"');
    end;
    Delete(tmp,1,2);          //elimina
    CodifPref(codStr);
    if msjError<>'' then exit(msjError);
  end;
  /////////// Procesamiento final /////////////
  ctx.SkipWhites;
  if not ctx.Eof then exit('Demasiados campos');
end;
function TNiloMTabRut.CodifPref(codStr: string): byte;
//Codifica una cadena de 2 bytes en un código de prefijo de un byte
var
  com, num: char;
  arg: byte;   //argumento
begin
  if length(codStr) <> 2 Then begin
    msjError := 'Error en código de prefijo: ' + codStr;
    exit;
  end;
  com := codStr[1];
  num := codStr[2];
  case num of
  '*': arg := 10;
  '#': arg := 11;
  'p': arg := 12;
  '?': arg := 15;
  '0'..'9': arg := ord(num)-48;  //convierte
  else
    msjError := 'Error en código de prefijo. Dígito inválido en "' + codStr + '"';
    exit;
  end;
  case com of
  'c': Result := $30 + arg;
  'i': Result := $20 + arg;
  'q': Result := $40 + arg;
  'a': Result := $50 + arg;
  else
    msjError := 'Error en código de prefijo. Comando desconocido: "' + codStr + '"';
    exit;
  end;
end;
procedure TNiloMTabRut.CargarRutas(lins: TStrings);
{Carga las rutas del TStrings indicado.
En condiciones normales actualiza la tabla de rutas.
Si encuentra error, termina la carga y actualiza "msjError", "filError" y "colError".
En ese caso no modifica la tabla de rutas actual.}
var
  linea , l: String;
  i : Integer;
  rut, rut2: TRegRuta;
begin
  debugln('Cargando rutas.');
  nlin := 0;
  ctx.definiciones.Clear;   //inicia preprocesador
  rutasTmp.Clear;
  for l in lins do begin
      linea := l;
      nlin := nlin + 1;
      ctx.ProcesaLinea2(linea, nlin, false);     //Quita caracteres no válidos
      if ctx.msjError <> '' Then begin
          msjError := ctx.msjError + ' Línea: ' + IntToStr(nlin);
          break;
      end;
      if trim(linea) <> '' then  begin //tiene datos
          rut := TRegRuta.Create;
          rutasTmp.Add(rut);  //agrega nueva tarifa
          msjError := regRuta_DeEdi(rut, linea);
          If msjError <> '' Then break;
          //Verifica si hay duplicidad de serie
          for i:=0 to rutasTmp.Count-2 do begin  //menos el último
            if rutasTmp[i].serie = rut.serie then begin
              msjError := 'Serie duplicada: ' + rut.serie + '. Línea: ' + IntToStr(nlin);
              break;
            end;
          end;
      end;
  end;
  //verifica si hubo errores
  if msjError <> '' then begin
    //Salió por error
    PLogErr(msjError);
    filError := nlin;
    colError := ctx.col;  //en donde se quedó la exploración
    exit;    //sale con error y sin actualizar rutas()
  end;
  //terminó la lectura sin errores
  rutas.Clear;       //elimina objetos
  for rut in rutasTmp do begin  //copia las rutas
    rut2 := TRegRuta.Create;  //crea copia para no interferir con objetos administrados
    rut2.assign(rut);    //crea copia
    rutas.Add(rut2);    //copia rutas
  end;
  rutasTmp.Clear;     //libera objetos
  PLogInf(IntToStr(rutas.Count) + ' rutas cargadas.');
end;
//Constructor y destructor
constructor TNiloMTabRut.Create;
begin
  rutasTmp:= regRuta_list.Create(true);
  rutas:= regRuta_list.Create(true);
  ctx := TContextTar.Create;
  ConfigurarSintaxisRutas(ctx.xLex, ctx.tkPrepro);  //usa la misma sintaxis que el resaltador
end;
destructor TNiloMTabRut.Destroy;
begin
  ctx.Destroy;
  rutasTmp.Destroy;
  rutas.Destroy;
  inherited Destroy;
end;

end.

