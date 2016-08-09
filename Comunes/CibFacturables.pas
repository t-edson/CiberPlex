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
  Classes, SysUtils, fgl, types, LCLProc, dateutils, CPProductos, MisUtils,
  CPRegistros, FormInicio;
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
    function regIBol_AReg: string;
    function regIBol_ARegVen: string;
  end;
  TCibItemBoleta_list = specialize TFPGObjectList<TCibItemBoleta>;   //lista de ítems

  { TCibBoleta }
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
    arcProduc: string;     //Archivo de producto.
    procedure AgregarItemR(r: TCibItemBoleta);
    function GetCadEstado: string;
  public
    OnVentaAgregada: procedure of object;  //evento de venta agregada
    property items: TCibItemBoleta_list read Fitems;
    procedure Recalcula;
    function RegVenta: string;
    property CadEstado: string read GetCadEstado;
  public  //Información y Operaciones con ítems
    function BuscaItem(const id: string): TCibItemBoleta;
    procedure VentaItem(r: TCibItemBoleta; RegisVenta: Boolean);
    procedure ItemClear;
    procedure ItemAdd(it: TCibItemBoleta; recalcular: boolean=true);
    procedure ItemDelete(id: string; recalcular: boolean=true);
    function ItemCount: integer;
  public  //constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;

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
  public  //eventos generales
    OnCambiaEstado: procedure of object;  //cuando cambia alguna variable de estado
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad
  public
    Boleta : TCibBoleta;  //se considera campo de estado, porque cambia frecuentemente
    MsjError: string;          //para mensajes de error
    property Nombre: string read FNombre write SetNombre;  //Nombre del objeto
    property CadEstado: string read GetCadEstado write SetCadEstado;
    property CadPropied: string read GetCadPropied write SetCadPropied;
    //Posición en pantalla. Se usan cuando se representa al facturable como un objeto gráfico.
    property x: double read Fx write Setx;   //coordenada X
    property y: double read Fy write Sety;  //coordenada Y
    procedure LimpiarBol;      //Limpia la boleta
  public //Constructor y destructor
    constructor Create;
    destructor Destroy; override;
  end;
  TCibFac_list = specialize TFPGObjectList<TCibFac>;   //lista de ítems

  //Tipos de objetos Grupos Facturables
  TCibTipGFact = (
    tgfCabinas = 0,     //Grupo de Cabinas
    tgfLocutNilo = 1    //Grupo de locutorios de enrutador NILO-m
  );

  { TCibGFac }
  {Define a la clase base de donde se derivarán los objetos Grupo de Facturables o Grupo
   Facturbale. Un grupo facturable es un objeto que contiene un conjunto (lista) de
   objetos facturables.}
  TCibGFac = class
  protected
    Fx: double;
    Fy: double;
    FModoCopia: boolean;
    procedure SetModoCopia(AValue: boolean); virtual;
    function GetCadPropied: string; virtual; abstract;
    procedure SetCadPropied(AValue: string); virtual; abstract;
    function GetCadEstado: string; virtual; abstract;
    procedure SetCadEstado(AValue: string); virtual; abstract;
    procedure Setx(AValue: double);
    procedure Sety(AValue: double);
  public
    Nombre: string;           //Nombre de grupo facturable
    tipo  : TCibTipGFact;  //tipo de grupo facturable
    CategVenta: string;       //categoría de Venta para este grupo
    items : TCibFac_list; //lista de objetos facturables
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad
    {El campo ModoCopia indica si se quiere trabajar sin conexión (como en un visor).
    Debería fijarse justo después de crear el objeto, para que los ítems a crear, se
    creen con la conexión configurada desde el inicio. No todos los objetos descendientes
    de TCibGFac, tienen que usar este campo. Solo les será útil a los que
    manejan conexión. Crear objetos facturables sin conexión es útil para los objetos
    creados en el visor, ya que estos, solo deben funcionar como objetos-copia.}
    property ModoCopia: boolean read FModoCopia write SetModoCopia;
    property CadEstado: string read GetCadEstado write SetCadEstado;  //cadena de estado
    property CadPropied: string read GetCadPropied write SetCadPropied;  //cadena de propiedades
    //Posición en pantalla. Se usan cuando se representa al facturable como un objeto gráfico.
    property x: double read Fx write Setx;   //coordenada X
    property y: double read Fy write Sety;  //coordenada Y
    function ItemPorNombre(nom: string): TCibFac;  //Busca ítem por nombre
  public  //constructor y destructor
    constructor Create(nombre0: string; tipo0: TCibTipGFact);
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
function TCibItemBoleta.regIBol_AReg: string;
{Convierte registro IBol en cadena, para escribir en el archivo de registro.
Se mantiene estructura base del registro para mantener la compatibilidad
con las versiones anteriores. En esta versión solo se han agregado nuevos
campos y se ha aplciado las funciones de conversión para guardar datoa a
archivo.}
begin
  Result := USUARIO + #9 + I2f(vser) + #9 + subcat + #9 +
        N2f(Cant) + #9 + N2f(pUnit) + #9 + N2f(subtot) + #9 +
        D2f(vfec) + #9 + I2f(estadoN) + #9 + I2f(Index) + #9 +
        S2f(descr) + #9 + S2f(coment) + #9 + I2f(fragmen) + #9 +
        cat + #9 + codPro + #9 + pVen + #9 +
        B2f(conStk) + #9 + #9 + N2f(pUnitR) + #9 + #9 + #9;
end;
function TCibItemBoleta.regIBol_ARegVen: string;
{Convierte registro IBol en cadena, para escribir en el archivo de registro,
como un registro de Venta. Se ha tratado de uniformizar con "regIBol_AReg"
Hay un cambio an la posición del campo "stckIni" con respecto a las versiones
NILOTER-m 1.X. En su lugar ahora se pone "vFec" y "stckIni" se desplaza. Además
aparecen nuevos campos.}
begin
  Result := USUARIO + #9 + '' + #9 + subcat + #9 +
          N2f(Cant) + #9 + N2f(pUnit) + #9 + N2f(subtot) + #9 +
          D2f(vfec) + #9 + '' + #9 + '' + #9 +
          S2f(descr) + #9 + S2f(coment) + #9 + #9 +
          cat + #9 + codPro + #9 + '' + #9 +
          '' + #9 + N2f(stkIni) + #9 + N2f(pUnitR) + #9 + #9 + #9 + #9;
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
procedure TCibBoleta.VentaItem(r: TCibItemBoleta; RegisVenta: Boolean);
{Realiza la venta de un ítem agregándolo a la boleta.
Este debe ser el punto de entrada único para agregar una venta a la boleta.}
var
  nser: integer;
begin
    //Actualiza stock
    if r.conStk Then ActualizarStock(arcProduc, r.codPro, r.Cant);
    //Puede devolver error después de ActualizarStock()
    if msjError <> '' Then begin
        //Se muestra aquí porque no se va a detener el flujo del programa por
        //un error, porque es prioritario registrar la venta.
        MsgBox(msjError);
    end;
    //Guarda registro de la Venta, si se indica
    if RegisVenta Then begin
        nser := PLogVen(r.regIBol_ARegVen, r.subtot);
        r.vser := nser;   //actualiza referencia a la venta
    end;
    //Agrega a la Boleta
    AgregarItemR(r);
    Recalcula;  //Actualiza subtotales
    if OnVentaAgregada<>nil then OnVentaAgregada;
    If msjError <> '' then exit;
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
begin
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
//Constructor y destructor
constructor TCibFac.Create;
begin
  Boleta := TCibBoleta.Create;
end;
destructor TCibFac.Destroy;
begin
  Boleta.Destroy;
  inherited Destroy;
end;
{ TCibGFac }
procedure TCibGFac.SetModoCopia(AValue: boolean);
begin
  //if FModoCopia=AValue then Exit;
  FModoCopia:=AValue;
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
constructor TCibGFac.Create(nombre0: string; tipo0: TCibTipGFact
  );
begin
  items  := TCibFac_list.Create(true);
  nombre := nombre0;
  tipo   := tipo0;
end;
destructor TCibGFac.Destroy;
begin
  items.Destroy;
  inherited Destroy;
end;

end.
