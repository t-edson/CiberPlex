{Unidad que pernmite trabajar con el archivo de productos.}
unit CibProductos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, LConvEncoding, MisUtils, LCLProc, CibBD;
const
  MODTAB_NOSTCK = 5;  //Modificación de tabla de productos sin tocar el stock

type

  { TCibRegProduc }
  {Registro que representa a un producto.}
  TCibRegProduc = class(TCibRegistro)
    Cod     : string;   //Código de producto
    Categ   : string;   //Categoría de producto
    Subcat  : string;   //Sub-categoría
    Nombre  : string;   //Nombre
    Desc    : string;   //Descripción
    Marca   : string;   //Indica la marca o marcas que se compran.
    UnidComp: string;   //Unidad en que se compra el insumo (docena, bolsa de ...).
    PreCosto: Double;   //Precio al qie se compra el producto
    preVenta: Double;   //Precio unitario
    Stock   : Double;   //Stock de producto
    tPre    : Double;   //NUMÉRICO. Tiempo de preparación
    fecCre  : TDateTime; //Fecha de creación
    fecMod  : TDateTime; //Fecha de modificación.
//    est     : Boolean  'BOLEAN. Estado: Activado o desactivado
//    img     : String   'CADENA. Archivo de imagen
  public  //campos temporales
    estReg: char;   //estado del registro
  end;
  TCibRegProduc_list = specialize TFPGObjectList<TCibRegProduc>;   //lista de ítems

  { TCibRegProvee }
  {Registro que representa a un proveedor.}
  TCibRegProvee = class(TCibRegistro)
    Cod       : string;    //Código único
    Categ     : string;
    Subcat    : string;
    NomEmpresa: string;
    Productos : string;
    Contacto  : string;
    Telefono  : string;
    Envio     : string;
    Direccion : string;
    Notas     : string;     //Notas sobre el proveedor
    UltCompra : TDateTime;  //Fecha de última compra
    Estado    : string;       //Estado
  end;
  TCibRegProvee_list = specialize TFPGObjectList<TCibRegProvee>;   //lista de ítems

  { TCibRegProduc }
  {Registro que representa a un producto.}
  TCibRegInsumo = class(TCibRegistro)
    Cod     : string;   //Código de producto
    Categ   : string;   //Categoría de producto
    Subcat  : string;   //Sub-categoría
    Nombre  : string;   //Nombre
    Desc    : string;   //Descripción
    Marca   : string;   //Indica la marca o marcas que se compran.
    UnidComp: string;   //Unidad en que se compra el insumo (docena, bolsa de ...).
    PreCosto: Double;   //Precio al qie se compra el producto
    Uso     : string;   //En qué se usa el insumo
    Stock   : Double;   //Stock de producto
    provee  : string;    //proveedor
    ultCom  : TDateTime; //Fecha de última compra
    Coment  : string;    //Comentario
  public  //campos temporales
    estReg  : char;   //estado del registro
  end;
  TCibRegInsumo_list = specialize TFPGObjectList<TCibRegInsumo>;   //lista de ítems

  { TCibTabProduc }
  {Define a una tabla de productos.}
  TCibTabProduc = class(TCibTabla)
  private
    function GetStr00: string;
    function GetStr09: Double;
    function GetStr11: Double;
    function GetStr01: string;
    function GetStr02: string;
    function GetStr03: string;
    function GetStr04: string;
    function GetStr05: string;
    function GetStr06: string;
    function GetStr07: Double;
    function GetStr08: Double;
    function GetStr12: TDateTime;
    function GetStr13: TDateTime;
    procedure SetStr01(AValue: string);
    procedure SetStr10(AValue: Double);
    procedure SetStr11(AValue: Double);
    procedure SetStr02(AValue: string);
    procedure SetStr03(AValue: string);
    procedure SetStr04(AValue: string);
    procedure SetStr05(AValue: string);
    procedure SetStr06(AValue: string);
    procedure SetStr07(AValue: string);
    procedure SetStr08(AValue: Double);
    procedure SetStr09(AValue: Double);
    procedure SetStr12(AValue: TDateTime);
    procedure SetStr13(AValue: TDateTime);
  protected
    function BuscarProd(codigo: String): TCibRegProduc;
    function AddNewRecord: TCibRegistro; override;
  public
    Productos: TCibRegProduc_list;  //Almacena los productos
    //Rutinas que modifican la tabla
    procedure ActualizarStock(codPro: string; Cant: Double);
    function ActualizarTabNoStock(nuevDatos: string): string;
  public  //Inicialización
    constructor Create; override;
  end;

  { TCibTabProvee }
  TCibTabProvee = class(TCibTabla)
  private
    function GetStr00: string;
    function GetStr01: string;
    function GetStr02: string;
    function GetStr03: string;
    function GetStr04: string;
    function GetStr05: string;
    function GetStr06: string;
    function GetStr07: string;
    function GetStr08: string;
    function GetStr09: string;
    function GetStr10: TDateTime;
    function GetStr11: string;
    procedure SetStr00(AValue: string);
    procedure SetStr01(AValue: string);
    procedure SetStr02(AValue: string);
    procedure SetStr03(AValue: string);
    procedure SetStr04(AValue: string);
    procedure SetStr05(AValue: string);
    procedure SetStr06(AValue: string);
    procedure SetStr07(AValue: string);
    procedure SetStr08(AValue: string);
    procedure SetStr09(AValue: string);
    procedure SetStr10(AValue: TDateTime);
    procedure SetStr11(AValue: string);
  protected
    function AddNewRecord: TCibRegistro; override;
  public
    Proveedores: TCibRegProvee_list;  //Almacena los productos
    //Rutinas que modifican la tabla
  public  //Inicialización
    constructor Create; override;
  end;

  { TCibTabInsumo }
  {Define a una tabla de insumos.}
  TCibTabInsumo = class(TCibTabla)
  private
    function GetStr00: string;
    function GetStr01: string;
    function GetStr02: string;
    function GetStr03: string;
    function GetStr04: string;
    function GetStr05: string;
    function GetStr06: string;
    function GetStr07: Double;
    function GetStr08: string;
    function GetStr09: Double;
    function GetStr10: string;
    function GetStr11: TDateTime;
    function GetStr12: string;
    procedure SetStr00(AValue: string);
    procedure SetStr01(AValue: string);
    procedure SetStr02(AValue: string);
    procedure SetStr03(AValue: string);
    procedure SetStr04(AValue: string);
    procedure SetStr05(AValue: string);
    procedure SetStr06(AValue: string);
    procedure SetStr07(AValue: Double);
    procedure SetStr08(AValue: string);
    procedure SetStr09(AValue: Double);
    procedure SetStr10(AValue: string);
    procedure SetStr11(AValue: TDateTime);
    procedure SetStr12(AValue: string);
  protected
    function BuscarInsum(codigo: String): TCibRegInsumo;
    function AddNewRecord: TCibRegistro; override;
  public
    Insumos: TCibRegInsumo_list;  //Almacena los productos
    //Rutinas que modifican la tabla
    procedure ActualizarStock(codPro: string; Cant: Double);
  public  //Inicialización
    constructor Create; override;
  end;

implementation
{ TCibRegProvee }
function TCibTabProduc.GetStr00: string; begin Result := Productos[idx].Cod; end;
function TCibTabProduc.GetStr01: string; begin Result := Productos[idx].Categ; end;
function TCibTabProduc.GetStr02: string; begin Result := Productos[idx].Subcat; end;
function TCibTabProduc.GetStr03: string; begin Result := Productos[idx].Nombre; end;
function TCibTabProduc.GetStr04: string; begin Result := Productos[idx].Desc; end;
function TCibTabProduc.GetStr05: string; begin Result := Productos[idx].Marca; end;
function TCibTabProduc.GetStr06: string; begin Result := Productos[idx].UnidComp; end;
function TCibTabProduc.GetStr07: Double; begin Result := Productos[idx].PreCosto; end;
function TCibTabProduc.GetStr08: Double; begin Result := Productos[idx].preVenta; end;
function TCibTabProduc.GetStr09: Double; begin Result := Productos[idx].Stock; end;
function TCibTabProduc.GetStr11: Double; begin Result := Productos[idx].tPre; end;
function TCibTabProduc.GetStr12: TDateTime; begin Result := Productos[idx].fecCre; end;
function TCibTabProduc.GetStr13: TDateTime; begin Result := Productos[idx].fecMod; end;

procedure TCibTabProduc.SetStr01(AValue: string); begin Productos[idx].Cod:=AValue; end;
procedure TCibTabProduc.SetStr02(AValue: string); begin Productos[idx].Categ:=AValue; end;
procedure TCibTabProduc.SetStr03(AValue: string); begin Productos[idx].Subcat:=AValue; end;
procedure TCibTabProduc.SetStr04(AValue: string); begin Productos[idx].Nombre:=AValue; end;
procedure TCibTabProduc.SetStr05(AValue: string); begin Productos[idx].Desc:=AValue; end;
procedure TCibTabProduc.SetStr06(AValue: string); begin Productos[idx].Marca:=AValue; end;
procedure TCibTabProduc.SetStr07(AValue: string); begin Productos[idx].UnidComp:=AValue; end;
procedure TCibTabProduc.SetStr08(AValue: Double); begin Productos[idx].PreCosto:=AValue; end;
procedure TCibTabProduc.SetStr09(AValue: Double); begin Productos[idx].preVenta:=AValue; end;
procedure TCibTabProduc.SetStr10(AValue: Double); begin Productos[idx].Stock:=AValue; end;
procedure TCibTabProduc.SetStr11(AValue: Double); begin Productos[idx].tPre:=AValue; end;
procedure TCibTabProduc.SetStr12(AValue: TDateTime); begin Productos[idx].fecCre:=AValue; end;
procedure TCibTabProduc.SetStr13(AValue: TDateTime); begin Productos[idx].fecMod:=AValue; end;

{ TCibTabProduc }
function TCibTabProduc.BuscarProd(codigo: String): TCibRegProduc;
{Busca un producto por el código. Si no encuentra devuelve un
registro en blanco.}
var
  p: TCibRegProduc;
begin
  codigo := UpCase(codigo);
  for p in Productos do begin
    if UpCase(p.Cod) = codigo Then begin
      exit(p);
    end;
  end;
  //No encontró
  exit(nil);
end;
function TCibTabProduc.AddNewRecord: TCibRegistro;
begin
  Result := TCibRegProduc.Create; //crea registro de producto
end;
procedure TCibTabProduc.ActualizarStock(codPro: string; Cant: Double);
{Actualiza el stock del producto indicado en el archivo de productos
Se crea una copia actualizada y luego se reemplaza la anterior}
var
  stock: Single;
  pro: TCibRegProduc;
begin
  debugln('Actualizando stock');
  pro := BuscarProd(codPro);
  if pro = nil Then begin
      MsgBox('Error en Código de producto');
      exit;
  end;
  msjError := '';
  //Verifica cambio de stock
  stock := pro.Stock;
  stock := stock - Cant;   //actualiza
  if stock < 0 Then begin
      //Se genera mensaje de error
      msjError := 'No hay disponibilidad de stock: ' + pro.Cod;
      if OnLogError<>nil then OnLogError(msjError);
  end;
  pro.Stock := stock;     //actualiza estado en memoria
  SaveToDisk;
end;
function TCibTabProduc.ActualizarTabNoStock(nuevDatos: string): string;
{Se pide actualizar la tabla, sin modificar el stock. Es normal porque pueden
haberse realizado ventas. Devuelve un resumen de los cambios.
"nuevDatos" es la nueva tabla en formato binario.
Si encuentra error, actualiza "MsjError".}
var
  pro, protmp: TCibRegProduc;
  tabtmp: TCibTabProduc;
  nProNuevos, nProElimin: Integer;
begin
  //Carga nuevos datos para la búsqueda
  tabtmp := TCibTabProduc.Create;
  tabtmp.LoadFromString(nuevDatos);
  if tabtmp.msjError<>'' then begin
    msjError:= 'Error modificando tabla de productos.';
    Result := msjError;
    exit;
  end;
  {La estrategia, es tomar como base la nueva tabla y solo actualizar el stock.
   De esa forma se conserva el orden}
  nProNuevos := 0;
  for pro in Productos do pro.estReg:='n';  //marca inicial
  for protmp in tabtmp.Productos do begin
    //busca el producto
    pro := BuscarProd(protmp.Cod);
    if pro = nil then begin
      inc(nProNuevos); //Es producto nuevo. No se tiene stock
    end else begin  //restaura el stock
      pro.estReg:='u';   //marca como usado
      protmp.Stock:= pro.Stock;
    end;
  end;
  //ya se actualizó el stock. Ahora contamos los que no se usaron
  nProElimin := 0;
  for pro in productos do begin
    if pro.estReg = 'n' then inc(nProElimin);
  end;
  //Volcamos a disco y actualizamos "Productos"
  tabtmp.archivo:=archivo;
  tabtmp.SaveToDisk;
  tabtmp.Destroy;
  LoadFromDisk;  //Puede generar error
  if msjError<>'' then begin
    Result := 'Error modificando tabla de productos.';
    exit;
  end;
  //Generamos mensaje de resumen
  Result := 'Tabla de productos actualizada, sin Stock (' +
                 IntToStr(items.Count) + ' registros)' + LineEnding +
            IntToStr(nProNuevos) + ' registros nuevos.' + LineEnding +
            IntToStr(nProElimin) + ' registros eliminados.';
end;
constructor TCibTabProduc.Create;
begin
  inherited;
  Productos:= TCibRegProduc_list.Create(true);
  items := {%H-}TCibRegistro_list(Productos);
  FieldAddStr('COD'     , @GetStr00, @SetStr01);
  FieldAddStr('CATEG'   , @GetStr01, @SetStr02);
  FieldAddStr('SUBCAT'  , @GetStr02, @SetStr03);
  FieldAddStr('NOMBRE'  , @GetStr03, @SetStr04);
  FieldAddStr('DESC'    , @GetStr04, @SetStr05);
  FieldAddStr('MARCA'   , @GetStr05, @SetStr06);
  FieldAddStr('UNIDCOMP', @GetStr06, @SetStr07);
  FieldAddFlt('PRECOSTO', @GetStr07, @SetStr08);
  FieldAddFlt('PREVENTA', @GetStr08, @SetStr09);
  FieldAddFlt('STOCK'   , @GetStr09, @SetStr10);
  FieldAddFlt('TPRE'    , @GetStr11, @SetStr11);
  FieldAddDatTim('FECCRE',@GetStr12, @SetStr12);
  FieldAddDatTim('FECMOD',@GetStr13, @SetStr13);
end;
{ TCibTabProvee }
function TCibTabProvee.GetStr00: string; begin Result := Proveedores[idx].Cod; end;
function TCibTabProvee.GetStr01: string; begin Result := Proveedores[idx].Categ; end;
function TCibTabProvee.GetStr02: string; begin Result := Proveedores[idx].Subcat; end;
function TCibTabProvee.GetStr03: string; begin Result := Proveedores[idx].NomEmpresa; end;
function TCibTabProvee.GetStr04: string; begin Result := Proveedores[idx].Productos; end;
function TCibTabProvee.GetStr05: string; begin Result := Proveedores[idx].Contacto; end;
function TCibTabProvee.GetStr06: string; begin Result := Proveedores[idx].Telefono; end;
function TCibTabProvee.GetStr07: string; begin Result := Proveedores[idx].Envio; end;
function TCibTabProvee.GetStr08: string; begin Result := Proveedores[idx].Direccion; end;
function TCibTabProvee.GetStr09: string; begin Result := Proveedores[idx].Notas; end;
function TCibTabProvee.GetStr10: TDateTime; begin Result := Proveedores[idx].UltCompra; end;
function TCibTabProvee.GetStr11: string; begin Result := Proveedores[idx].Estado; end;

procedure TCibTabProvee.SetStr00(AValue: string); begin Proveedores[idx].Cod := AValue; end;
procedure TCibTabProvee.SetStr01(AValue: string); begin Proveedores[idx].Categ:= AValue; end;
procedure TCibTabProvee.SetStr02(AValue: string); begin Proveedores[idx].Subcat:= AValue; end;
procedure TCibTabProvee.SetStr03(AValue: string); begin Proveedores[idx].NomEmpresa:= AValue; end;
procedure TCibTabProvee.SetStr04(AValue: string); begin Proveedores[idx].Productos:= AValue; end;
procedure TCibTabProvee.SetStr05(AValue: string); begin Proveedores[idx].Contacto:= AValue; end;
procedure TCibTabProvee.SetStr06(AValue: string); begin Proveedores[idx].Telefono:= AValue; end;
procedure TCibTabProvee.SetStr07(AValue: string); begin Proveedores[idx].Envio:= AValue; end;
procedure TCibTabProvee.SetStr08(AValue: string); begin Proveedores[idx].Direccion:= AValue; end;
procedure TCibTabProvee.SetStr09(AValue: string); begin Proveedores[idx].Notas:= AValue; end;
procedure TCibTabProvee.SetStr10(AValue: TDateTime); begin Proveedores[idx].UltCompra:= AValue; end;
procedure TCibTabProvee.SetStr11(AValue: string); begin Proveedores[idx].Estado:= AValue; end;

function TCibTabProvee.AddNewRecord: TCibRegistro;
begin
  Result := TCibRegProvee.Create; //crea registro de producto
end;
constructor TCibTabProvee.Create;
begin
  inherited;
  Proveedores:= TCibRegProvee_list.Create(true);
  items := {%H-}TCibRegistro_list(Proveedores);
  FieldAddStr('COD',       @GetStr00, @SetStr00);
  FieldAddStr('CATEG',     @GetStr01, @SetStr01);
  FieldAddStr('SUBCAT',    @GetStr02, @SetStr02);
  FieldAddStr('NOMEMPRESA',@GetStr03, @SetStr03);
  FieldAddStr('PRODUCTOS', @GetStr04, @SetStr04);
  FieldAddStr('CONTACTO',  @GetStr05, @SetStr05);
  FieldAddStr('TELEFONO',  @GetStr06, @SetStr06);
  FieldAddStr('ENVIO',     @GetStr07, @SetStr07);
  FieldAddStr('DIRECCION', @GetStr08, @SetStr08);
  FieldAddStr('NOTAS',     @GetStr09, @SetStr09);
  FieldAddDatTim('ULTCOMPRA',@GetStr10, @SetStr10);
  FieldAddStr('ESTADO',    @GetStr11, @SetStr11);
end;
{ TCibTabInsumo }
function TCibTabInsumo.GetStr00: string; begin Result := Insumos[idx].Cod; end;
function TCibTabInsumo.GetStr01: string; begin Result := Insumos[idx].Categ; end;
function TCibTabInsumo.GetStr02: string; begin Result := Insumos[idx].Subcat; end;
function TCibTabInsumo.GetStr03: string; begin Result := Insumos[idx].Nombre; end;
function TCibTabInsumo.GetStr04: string; begin Result := Insumos[idx].Desc; end;
function TCibTabInsumo.GetStr05: string; begin Result := Insumos[idx].Marca; end;
function TCibTabInsumo.GetStr06: string; begin Result := Insumos[idx].UnidComp; end;
function TCibTabInsumo.GetStr07: Double; begin Result := Insumos[idx].PreCosto; end;
function TCibTabInsumo.GetStr08: string; begin Result := Insumos[idx].Uso; end;
function TCibTabInsumo.GetStr09: Double; begin Result := Insumos[idx].Stock; end;
function TCibTabInsumo.GetStr10: string; begin Result := Insumos[idx].provee; end;
function TCibTabInsumo.GetStr11: TDateTime; begin Result := Insumos[idx].ultCom; end;
function TCibTabInsumo.GetStr12: string; begin Result := Insumos[idx].Coment; end;

procedure TCibTabInsumo.SetStr00(AValue: string); begin Insumos[idx].Cod:=AValue; end;
procedure TCibTabInsumo.SetStr01(AValue: string); begin Insumos[idx].Categ:=AValue; end;
procedure TCibTabInsumo.SetStr02(AValue: string); begin Insumos[idx].Subcat:=AValue; end;
procedure TCibTabInsumo.SetStr03(AValue: string); begin Insumos[idx].Nombre:=AValue; end;
procedure TCibTabInsumo.SetStr04(AValue: string); begin Insumos[idx].Desc:=AValue; end;
procedure TCibTabInsumo.SetStr05(AValue: string); begin Insumos[idx].Marca:=AValue; end;
procedure TCibTabInsumo.SetStr06(AValue: string); begin Insumos[idx].UnidComp:=AValue; end;
procedure TCibTabInsumo.SetStr07(AValue: Double); begin Insumos[idx].PreCosto:=AValue; end;
procedure TCibTabInsumo.SetStr08(AValue: string); begin Insumos[idx].Uso:=AValue; end;
procedure TCibTabInsumo.SetStr09(AValue: Double); begin Insumos[idx].Stock:=AValue; end;
procedure TCibTabInsumo.SetStr10(AValue: string); begin Insumos[idx].provee:=AValue; end;
procedure TCibTabInsumo.SetStr11(AValue: TDateTime); begin Insumos[idx].ultCom:=AValue; end;
procedure TCibTabInsumo.SetStr12(AValue: string); begin Insumos[idx].Coment:=AValue; end;

function TCibTabInsumo.BuscarInsum(codigo: String): TCibRegInsumo;
{Busca un producto por el código. Si no encuentra devuelve un
registro en blanco.}
var
  p: TCibRegInsumo;
begin
  codigo := UpCase(codigo);
  for p in Insumos do begin
    if UpCase(p.Cod) = codigo Then begin
      exit(p);
    end;
  end;
  //No encontró
  exit(nil);
end;
function TCibTabInsumo.AddNewRecord: TCibRegistro;
begin
  Result := TCibRegInsumo.Create; //crea registro de producto
end;
procedure TCibTabInsumo.ActualizarStock(codPro: string; Cant: Double);
{Actualiza el stock del producto indicado en el archivo de productos
Se crea una copia actualizada y luego se reemplaza la anterior}
var
  stock: Single;
  pro: TCibRegInsumo;
begin
  debugln('Actualizando stock');
  pro := BuscarInsum(codPro);
  if pro = nil Then begin
      MsgBox('Error en Código de producto');
      exit;
  end;
  msjError := '';
  //Verifica cambio de stock
  stock := pro.Stock;
  stock := stock - Cant;   //actualiza
  if stock < 0 Then begin
      //Se genera mensaje de error
      msjError := 'No hay disponibilidad de stock: ' + pro.Cod;
      if OnLogError<>nil then OnLogError(msjError);
  end;
  pro.Stock := stock;     //actualiza estado en memoria
  SaveToDisk;
end;
constructor TCibTabInsumo.Create;
begin
  inherited;
  Insumos:= TCibRegInsumo_list.Create(true);
  items := TCibRegistro_list(Insumos);
  FieldAddStr('COD',      @GetStr00, @SetStr00);
  FieldAddStr('CATEG',    @GetStr01, @SetStr01);
  FieldAddStr('SUBCAT',   @GetStr02, @SetStr02);
  FieldAddStr('NOMBRE',   @GetStr03, @SetStr03);
  FieldAddStr('DESC',     @GetStr04, @SetStr04);
  FieldAddStr('MARCA',    @GetStr05, @SetStr05);
  FieldAddStr('UNIDCOMP', @GetStr06, @SetStr06);
  FieldAddFlt('PRECOSTO', @GetStr07, @SetStr07);
  FieldAddStr('USO',      @GetStr08, @SetStr08);
  FieldAddFlt('STOCK',    @GetStr09, @SetStr09);
  FieldAddStr('PROVEE',   @GetStr10, @SetStr10);
  FieldAddDatTim('ULTCOM',@GetStr11, @SetStr11);
  FieldAddStr('COMENT',   @GetStr12, @SetStr12);
end;

end.
//606
