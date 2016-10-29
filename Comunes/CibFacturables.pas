{Define estructuras que se usarán para manejar Boletas y objetos facturables.
 Define a la clase TCPBoleta y sus clases asociadas, que se usará para representar a una
 boleta en CiberPlex.
 También se define al objeto TCPFacturable que es el objeto base de todos los objetos que
 pueeden manejar boletas.
}
unit CibFacturables;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, types, LCLProc, CibTramas, CibUtils, dateutils,
  MisUtils;
type
  //Tipos de objetos Grupos Facturables
  TCibTipFact = (
    ctfCabinas = 0,   //Grupo de Cabinas
    ctfNiloM = 1      //Grupo de locutorios de enrutador NILO-m
  );
const  //Caracteres identificadores para el archivo registros
  {Estos identificadores se usan para poder facilitar rápidamente el tipo de registro
   escrito, en el archivo de registro. Esta es la forma como trabaja el NILOTER-m y por
   eso se ha mantenido, pero Ciberplex, bien podría decidir usar base de datos.}
  IDE_REG_ERR = 'e';     //registro de error
  IDE_REG_INF = 'i';     //registro de información
  //Identificadores para ventas e ingresos
  IDE_REG_VEN = 'v';     //registro de venta común
  IDE_REG_VEND= 'y';     //registro de venta descartada
  IDE_CIB_IBO = 'b';     //registro de ítem de boleta
  IDE_CIB_IBOD= 'x';     //registro de ítem de boleta descartado
  IDE_CIB_BOL = 'B';     //registro de boleta
  //Identificadores para cabinas
  IDE_INT_GRA = 'q';     //registro de alquiler de cabina - hora gratis
  IDE_INT_NOR = 'p';     //registro de alquiler de cabina normal
  //Identificadores para llamadas
  IDE_NIL_LLA = 'l';     //registro de llamada de NILO-m
const  //Acciones sobre boletas
  //Acciones sobre la boleta
  ACCBOL_GRA = 1;
  //Acciones sobre los ítems de la boleta
  ACCITM_AGR = 2;
  ACCITM_DEV = 3;
  ACCITM_DES = 4;
  ACCITM_REC = 5;
  ACCITM_COM = 6;
  ACCITM_DIV = 7;
  ACCITM_GRA = 8;

type
  TItemBoletaEstado = (
    IT_EST_NORMAL = 0,    //Item en estado normal
    IT_EST_DESECH = 1    //Item desechado (perdido)
  );

  { TCibItemBoleta }
  TCibItemBoleta = class { TODO : Lo ideal serái crearle un índice a los ítems, para evitar errores por accesos concurrentes a las boletas. }
    Index  : Integer;   //índice del item dentro de su lista
    vfec   : TDateTime; //fecha-hora en que se crea el item (de venta)
    vser   : Integer;   //num. serie del item de venta asociado
    cat    : String;    //Categoría de ítem
    subcat : String;    //Sub Categ. de item (llamada, alq.cabina, venta, etc)
    codPro : String;    //código del producto de donde proviene el item
    descr  : String;    //descripción de ítem
    Cant   : Double;    //cantidad
    pUnit  : Double;    //precio unitario (el precio con que se vendió)
    pUnitR : Double;    //precio unitario Real (aún no se guarda en disco, solo se usa para registrar Ventas)
    subtot : Double;    //subtotal
    stkIni : Double;    //stock inicial (aún no se guarda en disco, solo se usa para registrar Ventas)
    estado : TItemBoletaEstado;  //estado
    fragmen: Integer;   //bandera para indicar item fragmentado o fusionado
    conStk : Boolean;   //bandera para indicar que este ítem maneja stock
    coment : String;    //comentario del item
    pVen   : String;    //punto de venta de donde se sacó el producto
  private
    function GetCadEstado: string;
    procedure SetCadEstado(AValue: string);
    function GetEstadoN: integer;
    procedure SetEstadoN(AValue: integer);
  public  //campos calculados
    property estadoN: integer read GetEstadoN write SetEstadoN;  //estado como número
    function Id: string;
  public
    procedure Assign(src: TCibItemBoleta);
    property CadEstado: string read GetCadEstado write SetCadEstado;
    function RegVenta: string;
    function RegIngres: string;
  end;
  TCibItemBoleta_list = specialize TFPGObjectList<TCibItemBoleta>;   //lista de ítems

  TCibFac = class;
  { TCibBoleta }
  {Modela a una boleta de venta, que debe pertenecer siempre a un OF.
  Notar que TCibBoleta no maneja eventos propios para acceder a información global,
  sino que hace uso de los eventos del OF que lo contiene.}
  TCibBoleta = class
    //propiedades del formulario
    nBole  : Integer;    //Número de Serie de la Boleta
    fec_bol: String;     //fecha de boleta
    nombre : String;     //nombre o razón social
    direc  : String;
    RUC    : String;
    subtot : Single;     //subtotal a pagar
    TotPag : Single;     //total a pagar
    usarIGV: Boolean;    //bandera de uso de IGV
    Pventa : String;     //Punto de venta de la Boleta
    fec_grab: TDateTime;  //fecha de grabación en registro de ventas
  private
    //lista de ítems
    Fitems  : TCibItemBoleta_list;
    procedure AgregarItemR(r: TCibItemBoleta);
    function GetCadEstado: string;
  public
    msjError : string;
    padre    : TCibFac;   //referencia al facturable que lo contiene
    property items: TCibItemBoleta_list read Fitems;
    procedure Recalcula;
    function RegVenta: string;
    property CadEstado: string read GetCadEstado;
  public  //Información y Operaciones con ítems
    function BuscaItem(const id: string): TCibItemBoleta;
    procedure VentaItem(it: TCibItemBoleta; RegisVenta: Boolean);
    procedure DevolItem(it: TCibItemBoleta);
    procedure IngresItem(it: TCibItemBoleta; recalcular: boolean=true);
    procedure ItemClear;
    procedure ItemAdd(it: TCibItemBoleta; recalcular: boolean=true);
    procedure ItemDelete(id: string; recalcular: boolean=true);
    function ItemCount: integer;
  public  //constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

  TEvBolLogVenta = function(ident:char; msje:string; dCosto:Double): integer of object;
  TEvBolActStock = procedure(const codPro: string; const Ctdad: double) of object;
  TEvFacLogInfo = function(msj: string): integer of object;
  TevFacLogError = function(msj: string): integer of object;

  TCibGFac = class;
  { TCibFac }
  { Define a la clase abstracta que sirve de base a objetos que pueden generar consumo
   (boletas), como puede ser una cabina de internet, o un locutorio.}
  TCibFac = class
  protected
    FNombre: string;
    Fx: double;
    Fy: double;
    procedure SetNombre(AValue: string); virtual;
    function GetCadEstado: string;          virtual; abstract;
    procedure SetCadEstado(AValue: string); virtual; abstract;
    function GetCadPropied: string;         virtual; abstract;
    procedure SetCadPropied(AValue: string);virtual; abstract;
    procedure Setx(AValue: double);
    procedure Sety(AValue: double);
    procedure LeerEstadoBoleta(var lineas: TStringDynArray);
  public  //eventos generales
    OnCambiaEstado : procedure of object; //cuando cambia alguna variable de estado
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad
    OnLogInfo      : TEvFacLogInfo;      //Indica que se quiere registrar un mensaje en el registro
    OnLogVenta     : TEvBolLogVenta;      //Requiere escribir una venta en registro
    OnLogIngre     : TEvBolLogVenta;      //Requiere escribir un ingreso en registro
    OnLogError     : TevFacLogError;    //Requiere escribir un Msje de error en el registro
    OnActualizStock: TEvBolActStock;      //cuando se requiere actualizar el stock
  public
    tipo    : TCibTipFact; //tipo de grupo facturable
    Boleta  : TCibBoleta;  //se considera campo de estado, porque cambia frecuentemente
    MsjError: string;      //para mensajes de error
    Grupo   : TCibGFac;    //Referencia a su grupo.
    property Nombre: string read FNombre write SetNombre;  //Nombre del objeto
    property CadEstado: string read GetCadEstado write SetCadEstado;
    property CadPropied: string read GetCadPropied write SetCadPropied;
    function IdFac: string;  //Identificador del Facturable
    //Posición en pantalla. Se usan cuando se representa al facturable como un objeto gráfico.
    property x: double read Fx write Setx;   //coordenada X
    property y: double read Fy write Sety;  //coordenada Y
    procedure LimpiarBol;      //Limpia la boleta
    function RegVenta(usu: string): string; virtual;
  public //Constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;
  TCibFac_list = specialize TFPGObjectList<TCibFac>;   //lista de ítems

  //Para requerir información de configuración general a la aplicaicón
  TEvReqConfigGen = procedure(var NombProg, NombLocal, Usuario: string) of object;
  //Para requerir información de configuración de moneda a la aplicaicón
  TEvReqConfigMon = procedure(var SimbMon: string; var numDec: integer; var IGV: Double) of object;
  //Requiere convertir a formato de moneda, usando el formato de la aplicación
  TevReqCadMoneda = function(valor: double): string of object;

  { TCPDecodCadEstado }
  {Objeto sencillo que permite decodificar una cadena de estado de un grupo facturable. }
  TCPDecodCadEstado = class
    private
      pos1, pos2: Integer;
    public
      lineas: TStringList;
      procedure Inic(const cad: string; var lin0: string);
      function ExtraerNombre(const lin: string): string;
      function Extraer(var car: char; var nombre, cadena: string): boolean;
    public  //constructor y destructor
      constructor Create;
      destructor Destroy; override;
  end;

  { TCibGFac }
  {Define a la clase base de donde se derivarán los objetos Grupo de Facturables o Grupo
   Facturbale. Un grupo facturable es un objeto que contiene un conjunto (lista) de
   objetos facturables.}
  TCibGFac = class
  private
    function fac_LogError(msj: string): integer;
    function fac_LogIngre(ident: char; msje: string; dCosto: Double): integer;
    procedure fac_ActualizStock(const codPro: string; const Ctdad: double);
    function fac_LogVenta(ident: char; msje: string; dCosto: Double): integer;
    function fac_LogInfo(msj: string): integer;
  protected
    Fx: double;
    Fy: double;
    FModoCopia: boolean;
    decod: TCPDecodCadEstado;  //Para decodificar las cadenas de estado
    function GetCadPropied: string; virtual; abstract;
    procedure SetCadPropied(AValue: string); virtual; abstract;
    function GetCadEstado: string; virtual;
    procedure SetCadEstado(AValue: string); virtual;
    procedure Setx(AValue: double);
    procedure Sety(AValue: double);
    procedure AgregarItem(fac: TCibFac);
    procedure fac_CambiaPropied;
  public
    Nombre : string;          //Nombre de grupo facturable
    tipo   : TCibTipFact;   //tipo de grupo facturable
    CategVenta: string;       //categoría de Venta para este grupo
    items  : TCibFac_list;   //lista de objetos facturables
    {El campo ModoCopia indica si se quiere trabajar sin conexión (como en un visor).
    Debería fijarse justo después de crear el objeto, para que los ítems a crear, se
    creen con la conexión configurada desde el inicio. No todos los objetos descendientes
    de TCibGFac, tienen que usar este campo. Solo les será útil a los que
    manejan conexión. Crear objetos facturables sin conexión es útil para los objetos
    creados en el visor, ya que estos, solo deben funcionar como objetos-copia.}
    property ModoCopia: boolean read FModoCopia;
    property CadEstado: string read GetCadEstado write SetCadEstado;  //cadena de estado
    property CadPropied: string read GetCadPropied write SetCadPropied;  //cadena de propiedades
    //Posición en pantalla. Se usan cuando se representa al facturable como un objeto gráfico.
    property x: double read Fx write Setx;   //coordenada X
    property y: double read Fy write Sety;  //coordenada Y
    procedure SetXY(x0, y0: double);
    function ItemPorNombre(nom: string): TCibFac;  //Busca ítem por nombre
    procedure AccionesBoleta(tram: TCPTrama);  //Ejecuta acción en boleta
    procedure Acciones(tram: TCPTrama); virtual;  //Ejecuta acción en el objeto
  public  //Eventos para que el grupo se comunique con la apliación principal
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad
    OnReqConfigGen : TEvReqConfigGen;   //Se requiere información general
    OnReqConfigMon : TEvReqConfigMon;   //Se requiere información de moneda
    OnReqCadMoneda : TevReqCadMoneda;   //Se requiere convertir a foramto de moneda
    OnLogInfo      : TEvFacLogInfo;     //se quiere registrar un mensaje en el registro
    OnLogVenta     : TEvBolLogVenta;    //Requiere escribir una venta en el registro
    OnLogIngre     : TEvBolLogVenta;    //Requiere escribir un ingreso en el registro
    OnLogError     : TevFacLogError;    //Requiere escribir un Msje de error en el registro
    OnActualizStock: TEvBolActStock;    //cuando se requiere actualizar el stock
  public  //Constructor y destructor
    constructor Create(nombre0: string; tipo0: TCibTipFact);
    destructor Destroy; override;
  end;
  //Lista de grupos facturables
  TCibGFact_list = specialize TFPGObjectList<TCibGFac>;

implementation
//Funciones especiales de conversión
function DD2f(d: TDateTime): String;
begin
  DateTimeToString(Result,'yyyymmddhhnnsszzz',d);
End;
function f2DD(s: String): TDateTime;
begin
  Result := EncodeDateTime(StrToInt(copy(s,1,4)),
                           StrToInt(copy(s,5,2)),
                           StrToInt(copy(s,7,2)),
                           StrToInt(copy(s,9,2)),
                           StrToInt(copy(s,11,2)),
                           StrToInt(copy(s,13,2)),
                           StrToInt(copy(s,15,3)));
End;

{ TCibItemBoleta }
function TCibItemBoleta.GetEstadoN: integer;
begin
  Result := Ord(estado);
end;
procedure TCibItemBoleta.SetEstadoN(AValue: integer);
begin
  estado := TItemBoletaEstado(AValue);
end;
function TCibItemBoleta.Id: string;
{Devuelve índice de unicidad. En realidad no se garantiza que sea único si es que se
agregan más de un ítem en menos de 1 mseg, ya que se usa la fecha de venta como índice,
pero en la práctica funciona bien.}
begin
  {En realidad }
  Result := DD2f(self.vfec);
end;
procedure TCibItemBoleta.Assign(src: TCibItemBoleta);
begin
  Index  :=src.Index;
  vfec   :=src.vfec;
  vser   :=src.vser;
  cat    :=src.cat;
  subcat :=src.subcat;
  codPro :=src.codPro;
  descr  :=src.descr;
  Cant   :=src.Cant;
  pUnit  :=src.pUnit;
  pUnitR :=src.pUnitR;
  subtot :=src.subtot;
  stkIni :=src.stkIni;
  estado :=src.estado;
  fragmen:=src.fragmen;
  conStk :=src.conStk;
  coment :=src.coment;
  pVen   :=src.pVen;
end;
function TCibItemBoleta.RegVenta: string;
{Devuelve cadena, para escribir en el archivo de registro, como un registro de Venta.
Se ha tratado de uniformizar con "regIBol_AReg".}
begin
  Result := '' + #9 + subcat + #9 +
          N2f(Cant) + #9 + N2f(pUnit) + #9 + N2f(subtot) + #9 +
          D2f(vfec) + #9 + '' + #9 + '' + #9 +
          S2f(descr) + #9 + S2f(coment) + #9 + #9 +
          cat + #9 + codPro + #9 + '' + #9 +
          '' + #9 + N2f(stkIni) + #9 + N2f(pUnitR) + #9 + #9 + #9 + #9;
end;
function TCibItemBoleta.RegIngres: string;
{Devuelve cadena para escribir en el archivo de registro como registro de Ingreso.
Se mantiene estructura base del registro para mantener la compatibilidad
con el NILOTER-m.}
begin
  Result := I2f(vser) + #9 + subcat + #9 +
        N2f(Cant) + #9 + N2f(pUnit) + #9 + N2f(subtot) + #9 +
        D2f(vfec) + #9 + I2f(estadoN) + #9 + I2f(Index) + #9 +
        S2f(descr) + #9 + S2f(coment) + #9 + I2f(fragmen) + #9 +
        cat + #9 + codPro + #9 + pVen + #9 +
        B2f(conStk) + #9 + #9 + N2f(pUnitR) + #9 + #9 + #9;
end;
function TCibItemBoleta.GetCadEstado: string;
begin
  Result := '[b]' + I2f(Index) + #9 + DD2f(vfec) + #9 + I2f(vser) + #9 +
          cat + #9 + subcat + #9 + codPro + #9 +
          descr + #9 + N2f(Cant) + #9 + N2f(pUnit) + #9 +
          N2f(subtot) + #9 + I2f(estadoN) + #9 + I2f(fragmen) + #9 +
          S2f(coment) + #9 + B2f(conStk) + #9 + #9 + #9
end;
procedure TCibItemBoleta.SetCadEstado(AValue: string);
var
  b: TStringDynArray;
begin
  AValue := copy(AValue, 4, length(AValue));
  b := Explode(#9, AValue);     //!!!!!!!No es el separador apropiado
  Index := f2I(b[0]);
  vfec := f2DD(b[1]);
  vser := f2I(b[2]);

  cat := b[3];
  subcat := b[4];
  codPro := b[5];

  descr := b[6];
  Cant := f2N(b[7]);
  pUnit := f2N(b[8]);

  subtot := f2N(b[9]);
  estadoN := f2I(b[10]);
  fragmen := f2I(b[11]);

  coment := f2S(b[12]);
  //regBol_DeDisco.pven = b[12)
  conStk := f2b(b[13]);
end;
{ TCibBoleta }
procedure TCibBoleta.AgregarItemR(r: TCibItemBoleta); { TODO : Pareceira que no es necesario esta función }
//Agrega un ítem a la boleta. Se le debe pasar el registro
begin
  Fitems.Add(r);   //No está creando al objeto
  r.Index := Fitems.Count-1;
end;
procedure TCibBoleta.Recalcula;
{Recalcula los campos "SubTot" y "TotPag" de la boleta. Además actualiza el campo Index
 de todos los ítems.}
var
  ibol: TCibItemBoleta;
  sTot: Double;
  sum : Double;
  i: Integer;
begin
  //otros elementos
  sum := 0;
  for i:=0 to Fitems.Count-1 do begin
    ibol := FItems[i];
    ibol.Index:=i;  //actualiza índice
    sTot := ibol.subtot;
    If ibol.estado = IT_EST_DESECH Then begin
        sTot := 0;   //no se cuenta en el total
    end;
    sum += sTot;     //Suma subtotales
  end;
  TotPag := sum;
//  If usarIGV Then begin  //Hay que considerar IGV
//     subtot := TotPag / (1 + igv/100);
//  end Else begin
     subtot := TotPag;     //Es lo mismo
//  end;
end;
function TCibBoleta.BuscaItem(const id: string): TCibItemBoleta;
{Devuelve la referenCia a un item, indicando su ID.}
var
  it: TCibItemBoleta;
begin
  for it in items do begin
    if it.Id = id then exit(it);
  end;
  exit(nil);
end;
procedure TCibBoleta.VentaItem(it: TCibItemBoleta; RegisVenta: Boolean);
{Realiza la venta de un ítem agregándolo a la boleta.
Este debe ser el punto de entrada único para agregar una venta a la boleta.}
var
  nser: integer;
  NombProg, NombLocal, Usuario: string;
begin
    //Actualiza stock
    if it.conStk then begin
      {Se debe actualizar stcok, pero desde aquí no se tiene acceso a la maquinaria de
       almacén, así que usamos este evento (que se supone, debe estar siempre definido)
       que se propagará, hasta llegar a la aplicación principal.}
      padre.OnActualizStock(it.codPro, it.Cant);  //Debería mostrar mensaje de error si amerita
    end;
    //Recupera información de configuración
    padre.Grupo.OnReqConfigGen(NombProg, NombLocal, Usuario);
    //Guarda registro de la Venta, si se indica
    {Notar que el registro de la venta se agrega siempre, independientemente de si se
    grabará o no. El ítem también se podrá devolver, pero el registro se mantiene.}
    if RegisVenta Then begin
        nser := padre.OnLogVenta(IDE_REG_VEN, Usuario+ #9 + it.RegVenta, it.subtot);
        it.vser := nser;   //actualiza referencia a la venta
    end;
    //Agrega a la Boleta
    AgregarItemR(it);
    Recalcula;  //Actualiza subtotales
//    if OnVentaAgregada<>nil then OnVentaAgregada;
    If msjError <> '' then exit;
end;
procedure TCibBoleta.DevolItem(it: TCibItemBoleta);
{Realiza la devolución de un ítem. Básicamente lo que se hace es quitar el ítem de la
lista y escribir en el registro, el ítem con costo y cantidad negativos.}
var
  NombProg, NombLocal, Usuario: string;
begin
  it.Cant   := -it.Cant;   //pone cantidad negativa
  it.subtot := -it.subtot; //pone total negativo
  //Recupera información de configuración
  padre.Grupo.OnReqConfigGen(NombProg, NombLocal, Usuario);
  //registra mensaje
  padre.OnLogVenta(IDE_REG_VEND, Usuario + #9 + it.RegVenta, -it.subtot);
  ItemDelete(it.Id);  //quita de la lista
end;
procedure TCibBoleta.IngresItem(it: TCibItemBoleta; recalcular: boolean=true);
{Realiza el ingreso del ítem de la boleta, eliminándolo de la boleta. Esto se hace cada
vez que se pide grabar un ítem de la boleta o cuando se graban todos los ítems.}
var
  NombProg, NombLocal, Usuario: string;
begin
  //Recupera información de configuración
  padre.Grupo.OnReqConfigGen(NombProg, NombLocal, Usuario);
  //Registra el ingreso en el archivo de registro
  If it.estado = IT_EST_NORMAL Then begin
    //Ítem normal
    padre.OnLogIngre(IDE_CIB_IBO, Usuario + #9 + it.RegIngres, 0);
  end else begin
    //Ítem descartado
    padre.OnLogIngre(IDE_CIB_IBOD, Usuario + #9 + it.RegIngres, 0);
  end;
  ItemDelete(it.Id, recalcular);  //quita el ítem de la boleta
end;
procedure TCibBoleta.ItemClear;
begin
  Fitems.Clear;
  Recalcula;  //Es rápido este cálculo, así que no hay problema en hacerlo siempre
end;
procedure TCibBoleta.ItemAdd(it: TCibItemBoleta; recalcular: boolean=true);
begin
  Fitems.Add(it);
  if recalcular then Recalcula;
end;
procedure TCibBoleta.ItemDelete(id: string; recalcular: boolean=true);
var
  it: TCibItemBoleta;
begin
  it := self.BuscaItem(id);
  if it = nil then exit;
  //Fitems.Delete(index);  //quita de la lista
  Fitems.Remove(it);
  if recalcular then Recalcula;  //importante porque al eliminar se pierde la secuencia de los índices
end;
function TCibBoleta.ItemCount: integer;
begin
  Result := Fitems.Count;
end;
function TCibBoleta.RegVenta: string;
{Devuelve la cadena que debe ser grabada en el registro. Se define para que sea
 compatible con el NILOTER-m}
var
  NombProg, NombLocal, Usuario: string;
begin
  //Recupera información de configuración
  padre.Grupo.OnReqConfigGen(NombProg, NombLocal, Usuario);
  Result := usuario + #9 +
         B2f(usarIGV) + #9 + N2f(subtot) + #9 +
         N2f(TotPag) + #9 + nombre + #9 +
         direc + #9 + RUC + #9 +
         I2f(nBole) + #9 + I2f(0) + #9 +
         D2f(fec_grab) + #9 + fec_bol + #9 +
         '' + #9 + '';
end;
function TCibBoleta.GetCadEstado: string;
{Devuelve una cadena, con información de los ítems}
var
  i: Integer;
begin
  Result := '';
  for i:=0 to Fitems.Count-1 do begin
    if i=0 then
      Result := ' ' + Fitems[i].CadEstado
    else
      Result := Result + LineEnding + ' ' + Fitems[i].CadEstado;
  end;
end;

constructor TCibBoleta.Create;
begin
  Fitems := TCibItemBoleta_list.Create(true);
end;
destructor TCibBoleta.Destroy;
begin
  Fitems.Destroy;
  inherited Destroy;
end;
{ TCibFac }
procedure TCibFac.SetNombre(AValue: string);
begin
  if FNombre = AValue then exit;
  FNombre := AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibFac.Setx(AValue: double);
begin
  if Fx=AValue then exit;
  Fx:=AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibFac.Sety(AValue: double);
begin
  if Fy=AValue then exit;
  Fy:=AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibFac.LeerEstadoBoleta(var lineas: TStringDynArray);
{Recibe un arreglo de líneas, con información de la boleta (a partir de la segunda línea).
 La decodifica y carga las propiedades de la boleta ahí guardada. En otras palabras,
 decodifica lo que ha generado, TCibBoleta.GetCadEstado(), pero de un arreglo. }
var
  i: Integer;
  it: TCibItemBoleta;
  lin: String;
begin
  boleta.ItemClear;    {se pensó en evitar limpiar toda la lista (por eficiencia)
                        cambiando "Count", pero esto dejaba los nodos en NIL }
  for i:=1 to high(lineas) do begin
    lin := lineas[i];
    if trim(lin) = '' then continue;
    //Actualiza
    it := TCibItemBoleta.Create;
    delete(lin, 1, 1);  //quita espacio
    it.CadEstado := lin;
    boleta.ItemAdd(it, false);  //sin calculo, por eficiencia
  end;
  ///////////////// Actualizar
  boleta.Recalcula;
end;
function TCibFac.IdFac: string;
{Genera el identificador, a partir del nombre y del grupo.}
begin
  Result := Grupo.Nombre + #9 + Nombre;
end;
procedure TCibFac.LimpiarBol;
begin
  boleta.ItemClear;
  //nBole = 0   'No se inicia el número de boleta
  //fec_bol = date   'No se actualiaz fecha
  boleta.usarIGV := False;

  boleta.nombre := '';
  boleta.direc := '';
  boleta.RUC := '';
  boleta.subtot := 0;   //totales a cero
  boleta.TotPag := 0;   //totales a cero
  boleta.Recalcula;     //Actualiza totales
end;
function TCibFac.RegVenta(usu: string): string;
{Debe devolver la cadena (registro de ventas) que se debe escribir en el registro.
Cada tipo de facturable puede generar su formato de cadena, pero debe tratar de
uniformizarse. "usu" se incluye como parámetro, para indicar al Usuario actual, del
sistema, ya que es un campo usado comúnmente para generar el registro de ventas.}
begin
  Result := '<sin información>'
end;
//Constructor y destructor
constructor TCibFac.Create;
begin
  Boleta := TCibBoleta.Create;
  Boleta.padre    :=self;
end;
destructor TCibFac.Destroy;
begin
  Boleta.Destroy;
  inherited Destroy;
end;
{ TCibGFac }
procedure TCibGFac.fac_CambiaPropied;
begin
  if OnCambiaPropied<>nil then OnCambiaPropied;
end;
procedure TCibGFac.fac_ActualizStock(const codPro: string; const Ctdad: double);
begin
  OnActualizStock(codPro, Ctdad);
end;
function TCibGFac.fac_LogInfo(msj: string): integer;
begin
  Result := OnLogInfo(msj);
end;
function TCibGFac.fac_LogVenta(ident:char; msje:string; dCosto:Double): integer;
begin
  Result := OnLogVenta(ident, msje, dCosto);
end;
function TCibGFac.fac_LogIngre(ident: char; msje: string; dCosto: Double): integer;
begin
  Result := OnLogIngre(ident, msje, dCosto);
end;
function TCibGFac.fac_LogError(msj: string): integer;
begin
  Result := OnLogError(msj);
end;
function TCibGFac.GetCadEstado: string;
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
  Result := '<' + I2f(ord(self.tipo)) + #9 + Nombre + LineEnding;
  for c in items do begin
    Result += c.CadEstado + LineEnding;
  end;
  Result += '>';  //delimitador final.
end;
procedure TCibGFac.SetCadEstado(AValue: string);
{Hace el trabajo inverso de GetCadEstado(). De la misma forma, no lee campos de estado,
adicionales. De hecho no lee ninguno, ya que los campos Tipo y Nombre, ya fueron usados
para identificar a este GFac.}
var
  nomb, cad, lin1: string;
  car: char;
  it: TCibFac;
begin
  decod.Inic(AValue, lin1);
  while decod.Extraer(car, nomb, cad) do begin
    if cad = '' then continue;
    it := ItemPorNombre(nomb);
    if it<>nil then it.CadEstado := cad;
  end;
end;
procedure TCibGFac.AgregarItem(fac: TCibFac);
{Agrega un ítem, a la lista de facturables. Esta función debe ser usada siempre que se
requiere agregar un ítem nuevo a la lista, para que se realicen las configuraciones
necesarias, en el ítem a agregar}
begin
  fac.Grupo := self;
//  fac.OnCambiaEstado :=@fac_CambiaEstado;  No se intercepta
  fac.OnLogInfo      := @fac_LogInfo;
  fac.OnLogVenta     := @fac_LogVenta;
  fac.OnLogIngre     := @fac_LogIngre;
  fac.OnLogError     := @fac_LogError;
  fac.OnCambiaPropied:= @fac_CambiaPropied;
  fac.OnActualizStock:= @fac_ActualizStock;
  items.Add(fac);
end;
procedure TCibGFac.Setx(AValue: double);
begin
  if Fx=AValue then exit;
  Fx:=AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibGFac.Sety(AValue: double);
begin
  if Fy=AValue then exit;
  Fy:=AValue;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
procedure TCibGFac.SetXY(x0,y0: double);
begin
  if (Fx=x0) and (Fy=y0) then exit;
  Fx:=x0;
  Fy:=y0;
  if OnCambiaPropied<>nil then OnCambiaPropied();
end;
function TCibGFac.ItemPorNombre(nom: string): TCibFac;
{Devuelve la referencia a un ítem, ubicándola por su nombre. Si no lo enuentra
 devuelve NIL.}
var
  c : TCibFac;
begin
  for c in items do begin
    if c.Nombre = nom then exit(c);
  end;
  exit(nil);
end;
procedure TCibGFac.AccionesBoleta(tram: TCPTrama);
{Ejecuta acciones sobre la boleta}
var
  a: TStringDynArray;
  facDest: TCibFac;
  itBol, itBol2: TCibItemBoleta;
  traDat, nom: String;
  parte: Extended;
  idx, idx2: LongInt;
  Err: boolean;
begin
  traDat := tram.traDat;  //crea copia para modificar
  ExtraerHasta(traDat, #9, Err);  //Extrae nombre de grupo
  nom := ExtraerHasta(traDat, #9, Err);  //Extrae nombre de objeto
  facDest := ItemPorNombre(nom);
  if facDest=nil then exit;
  case tram.posX of  //Se usa el parámetro para ver la acción
  //Acciones sobre la boleta
  ACCBOL_GRA: begin  //Se pide grabar la boleta de una PC
      for itBol in facDest.boleta.items do begin
    {    If Pventa = '' Then //toma valor por defecto
            itBol.pVen = PVentaDef
        else    //escribe con punto de venta
            itBol.pVen = Me.Pventa
        end;}
        facDest.boleta.IngresItem(itBol);   //ingresa el ítem
      end;
      //Graba los campos de la boleta
      facDest.boleta.fec_grab := now;  //fecha de grabación
      if OnLogIngre<>nil then
        OnLogIngre(IDE_CIB_BOL, facDest.Boleta.RegVenta, facDest.boleta.TotPag);
      //Config.escribirArchivoIni;
      facDest.LimpiarBol;          //Limpia los items
    end;
  //Acciones sobre los ítems de la boleta
  ACCITM_AGR: begin  //Se pide agregar una venta
      itBol := TCibItemBoleta.Create;
      itBol.CadEstado := traDat;  //recupera ítem
      facDest.Boleta.VentaItem(itBol, true);
    end;
  ACCITM_DEV: begin  //Devolver ítem
      a := Explode(#9, traDat);
      itBol := facDest.Boleta.BuscaItem(a[0]);
      IF itBol=nil then exit;
      itBol.coment := a[1];         //escribe comentario
      facDest.Boleta.DevolItem(itBol);
    end;
  ACCITM_DES: begin  //Desechar ítem
      a := Explode(#9, traDat);
      itBol := facDest.Boleta.BuscaItem(a[0]);
      IF itBol=nil then exit;
      itBol.coment := a[1];         //escribe comentario
      itBol.estado := IT_EST_DESECH;
    end;
  ACCITM_REC: begin  //Recuperar ítem
      a := Explode(#9, traDat);
      itBol := facDest.Boleta.BuscaItem(a[0]);
      IF itBol=nil then exit;
      itBol.coment := '';         //escribe comentario
      itBol.estado := IT_EST_NORMAL;
    end;
  ACCITM_COM: begin  //Comentar ítem
      a := Explode(#9, traDat);
      itBol := facDest.Boleta.BuscaItem(a[0]);
      if itBol=nil then exit;
      itBol.coment := a[1];         //escribe comentario
    end;
  ACCITM_DIV: begin
      a := Explode(#9, traDat);
      itBol := facDest.Boleta.BuscaItem(a[0]);
      if itBol=nil then exit;
      //actualiza ítem inicial
      parte := StrToFloat(a[1]);
      itBol.subtot:= itBol.subtot - parte;
      itBol.fragmen += 1;  //lleva cuenta
      //agrega elemento separado
      itBol2 := TCibItemBoleta.Create;
      itBol2.Assign(itBol);  //crea copia
      //actualiza separación
      itBol2.vfec:=now;   //El ítem debe tener otro ID
      itBol2.subtot := parte;
      itBol2.fragmen := 1;      //marca como separado
      itBol2.conStk := false;   //para que no descuente
      facDest.Boleta.VentaItem(itBol2, true);  //agrega nuevo ítem
      //Reubica ítem
      idx := facDest.Boleta.items.IndexOf(itBol);
      idx2 := facDest.Boleta.items.IndexOf(itBol2);
      facDest.Boleta.items.Move(idx2, idx+1);  //acomoda posición
      facDest.Boleta.Recalcula;
    end;
  ACCITM_GRA: begin
      a := Explode(#9, traDat);
      itBol := facDest.Boleta.BuscaItem(a[0]);
      if itBol=nil then exit;
      facDest.boleta.IngresItem(itBol);   //ingresa el ítem
    end;
  end;
end;
procedure TCibGFac.Acciones(tram: TCPTrama);
{Ejecuta alguna acción en el objeto.}
begin

end;
////Constructor y destructor
constructor TCibGFac.Create(nombre0: string; tipo0: TCibTipFact
  );
begin
  items  := TCibFac_list.Create(true);
  nombre := nombre0;
  tipo   := tipo0;
  decod := TCPDecodCadEstado.Create;
end;
destructor TCibGFac.Destroy;
begin
  decod.Destroy;
  items.Destroy;
  inherited Destroy;
end;
{ TCPDecodCadEstado }
procedure TCPDecodCadEstado.Inic(const cad: string; var lin0: string);
{Inicia la exploración de la cadenas. Devuelve la primera línea de la cadena en
"lin0".}
begin
  lineas.Text := cad;
  pos1 := 0;  //posición inicial alta
  pos2 := -1;
  if lineas.Count<2 then begin
    MsgErr('Error en formato de cadena de estado: ' + cad);
    exit;
  end;
  lin0 := lineas[0];
  lineas.Delete(0);              //elimina la línea: "<0,   Cabinas"
  lineas.Delete(lineas.Count-1); //elimina la línea: ">"
end;
function TCPDecodCadEstado.ExtraerNombre(const lin: string): string;
var
  p: integer;
begin
  p := pos(#9, lin);  //busca delimitador
  if p=0 then begin
    //no hay delimitador, toma todo
    Result := lin;
  end else begin
    Result := copy(lin, 2, p-2);
  end;
end;
function TCPDecodCadEstado.Extraer(var car: char; var nombre, cadena: string): boolean;
{Extrae una subcadena (de una o varias líneas) de la cadena de estado, que corresponden a
los datos de un facturable. Si no encuentra más datos, devuelve FALSE.
La cadena de estado, tiene la forma:

cCab1	0	1899:12:30:00:00:00	1	2016:10:03:22:04:23	1899:12:30:00:15:00	F	F	1833	1.5
 [b]0	20161003215656872	2	COUNTER	INTERNET		Alquiler PC: 0m(01:07:12)	1	50.5	50.5	0	0		F
cCab2	3	1899:12:30:00:00:00	1	2016:10:03:16:48:23	1899:12:30:00:15:00	F	F	20793	12
cCab3	3	1899:12:30:00:00:00	1	2016:10:03:22:04:27	1899:12:30:00:15:00	F	F	1829	1.5

En este caso, se tienen 3 cadenas de estado de facturables. La primera tiene 2 líneas
miestras que las otras dos, son de solo una línea.
}
var
  linea: String;
begin
  if lineas.Count=0 then exit(false);
  cadena := '';
  while (lineas.Count>0) do begin
    linea := lineas[0];
//    res := TCPGrupoFacturable.ExtraerEstado(lest, cad, nombre, tipo);
    if trim(linea) = '' then begin
      lineas.Delete(0);  //elimina línea
      continue;  //filtra líneas vacías
    end;
    if cadena = '' then begin
      //Primera línea.
      car := linea[1];   //Aprovecha para capturar el caracter identificador.
      nombre := ExtraerNombre(linea);  //Aprovecha para capturar el nombre.
      cadena := linea;   //Copia la primera línea
    end else begin
      //Líneas adicionales
      cadena := cadena + LineEnding + linea;
    end;
    lineas.Delete(0);  //elimina línea leída
    if (lineas.Count>0) and  //hay más líneas
       (lineas[0][1]<>' ') then begin //y sigue una línea de datos
      break;
    end;
  end;
  exit(true);   //sale, pero hay mas datos
end;
constructor TCPDecodCadEstado.Create;
begin
  lineas := TStringList.Create;
end;
destructor TCPDecodCadEstado.Destroy;
begin
  lineas.Destroy;
  inherited Destroy;
end;
end.
