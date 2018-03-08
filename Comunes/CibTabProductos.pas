{Define a la tabla de productos}
unit CibTabProductos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, Types, LConvEncoding, MisUtils, LCLProc, CibBD;
type
  { TCibRegProduc }
  {Registro que representa a un producto.}
  TCibRegProduc = class(TCibRegistro)
  public
    class var NCOLS         : integer;  //Número de columnas
    class var COL_Cod       : integer;
    class var COL_Categ     : integer;
    class var COL_Subcat    : integer;
    class var COL_Nombre    : integer;
    class var COL_Desc      : integer;
    class var COL_Marca     : integer;
    class var COL_UnidComp  : integer;
    class var COL_PreCosto  : integer;
    class var COL_preVenta  : integer;
    class var COL_Stock     : integer;
    class var COL_tPre      : integer;
    class var COL_fecCre    : integer;
    class var COL_fecMod    : integer;
  private
    function GetCateg: string;
    function GetCod: string;
    function GetDesc: string;
    function GetfecCre: TDateTime;
    function GetfecMod: TDateTime;
    function GetMarca: string;
    function GetNombre: string;
    function GetPreCosto: Double;
    function GetpreVenta: Double;
    function GetStock: Double;
    function GetSubcat: string;
    function GettPre: Double;
    function GetUnidComp: string;
    procedure SetCateg(AValue: string);
    procedure SetCod(AValue: string);
    procedure SetDesc(AValue: string);
    procedure SetfecCre(AValue: TDateTime);
    procedure SetfecMod(AValue: TDateTime);
    procedure SetMarca(AValue: string);
    procedure SetNombre(AValue: string);
    procedure SetPreCosto(AValue: Double);
    procedure SetpreVenta(AValue: Double);
    procedure SetStock(AValue: Double);
    procedure SetSubcat(AValue: string);
    procedure SettPre(AValue: Double);
    procedure SetUnidComp(AValue: string);
  public  //campos temporales
    estReg: char;   //estado del registro
  public
    property Cod     : string    read GetCod      write SetCod     ; //Código de producto
    property Categ   : string    read GetCateg    write SetCateg   ; //Categoría de producto
    property Subcat  : string    read GetSubcat   write SetSubcat  ; //Sub-categoría
    property Nombre  : string    read GetNombre   write SetNombre  ; //Nombre
    property Desc    : string    read GetDesc     write SetDesc    ; //Descripción
    property Marca   : string    read GetMarca    write SetMarca   ; //Indica la marca o marcas que se compran.
    property UnidComp: string    read GetUnidComp write SetUnidComp; //Unidad en que se compra el insumo (docena, bolsa de ...).
    property PreCosto: Double    read GetPreCosto write SetPreCosto; //Precio al qie se compra el producto
    property preVenta: Double    read GetpreVenta write SetpreVenta; //Precio unitario
    property Stock   : Double    read GetStock    write SetStock   ; //Stock de producto
    property tPre    : Double    read GettPre     write SettPre    ; //NUMÉRICO. Tiempo de preparación
    property fecCre  : TDateTime read GetfecCre   write SetfecCre  ; //Fecha de creación
    property fecMod  : TDateTime read GetfecMod   write SetfecMod  ; //Fecha de modificación.
  public
    constructor Create;
  end;
  TCibRegProduc_list = specialize TFPGObjectList<TCibRegProduc>;   //lista de ítems

  { TCibTabProduc }
  {Define a una tabla de productos.}
  TCibTabProduc = class(TCibTablaMaest)
  protected
    function AddNewRecord: TCibRegistro; override;
  public
    Productos: TCibRegProduc_list;  //Almacena los productos
    function BuscarProd(codigo: String): TCibRegProduc;
    //Rutinas que modifican la tabla
    procedure IncrementarStock(codPro: string; Cant: Double);
    function ActualizarTabNoStock(nuevDatos: string): string;
    function ActualizarTabIngStock(nuevDatos: string): string;
  public  //Inicialización
    procedure SetCols(linHeader: string); override;
    constructor Create; override;
  end;

implementation
{ TCibRegProduc }
function TCibRegProduc.GetCod: string;
begin
  Result := values[COL_Cod];
end;
procedure TCibRegProduc.SetCod(AValue: string);
begin
  values[COL_Cod] := AValue;
end;
function TCibRegProduc.GetCateg: string;
begin
  Result := values[COL_Categ];
end;
procedure TCibRegProduc.SetCateg(AValue: string);
begin
  values[COL_Categ] := AValue;
end;
function TCibRegProduc.GetSubcat: string;
begin
  Result := values[COL_Subcat];
end;
procedure TCibRegProduc.SetSubcat(AValue: string);
begin
  values[COL_Subcat] := AValue;
end;
function TCibRegProduc.GetNombre: string;
begin
  Result := values[COL_Nombre];
end;
procedure TCibRegProduc.SetNombre(AValue: string);
begin
  values[COL_Nombre] := AValue;
end;
function TCibRegProduc.GetDesc: string;
begin
  Result := values[COL_Desc];
end;
procedure TCibRegProduc.SetDesc(AValue: string);
begin
  values[COL_Desc] := AValue;
end;
function TCibRegProduc.GetMarca: string;
begin
  Result := values[COL_Marca];
end;
procedure TCibRegProduc.SetMarca(AValue: string);
begin
  values[COL_Marca] := AValue;
end;
function TCibRegProduc.GetUnidComp: string;
begin
  Result := values[COL_UnidComp];
end;
procedure TCibRegProduc.SetUnidComp(AValue: string);
begin
  values[COL_UnidComp] := AValue;
end;
function TCibRegProduc.GetPreCosto: Double;
begin
  Result := f2N(values[COL_PreCosto]);
end;
procedure TCibRegProduc.SetPreCosto(AValue: Double);
begin
  values[COL_PreCosto] := N2f(AValue);
end;
function TCibRegProduc.GetpreVenta: Double;
begin
  Result := f2N(values[COL_preVenta])
end;
procedure TCibRegProduc.SetpreVenta(AValue: Double);
begin
  values[COL_preVenta] := N2f(AValue);
end;
function TCibRegProduc.GetStock: Double;
begin
  Result := f2N(values[COL_Stock])
end;
procedure TCibRegProduc.SetStock(AValue: Double);
begin
  values[COL_Stock] := N2f(AValue);
end;
function TCibRegProduc.GettPre: Double;
begin
  Result := f2N(values[COL_tPre])
end;
procedure TCibRegProduc.SettPre(AValue: Double);
begin
  values[COL_tPre] := N2f(AValue);
end;
function TCibRegProduc.GetfecCre: TDateTime;
begin
  Result := f2D(values[COL_fecCre])
end;
procedure TCibRegProduc.SetfecCre(AValue: TDateTime);
begin
  values[COL_fecCre] := D2f(AValue);
end;
function TCibRegProduc.GetfecMod: TDateTime;
begin
  Result := f2D(values[COL_fecMod])
end;
procedure TCibRegProduc.SetfecMod(AValue: TDateTime);
begin
  values[COL_fecMod] := D2f(AValue);
end;
constructor TCibRegProduc.Create;
begin
  {Se crea el registro dimensionando "values", para que pueda contener todas las
  columnas de la tabla.
  Se supone que se debe haber inicailizado primero NCOLS.}
  setlength(values, TCibRegProduc.NCOLS);
end;
{ TCibTabProduc }
function TCibTabProduc.BuscarProd(codigo: String): TCibRegProduc;
{Busca un producto por el código. Si no encuentra devuelve NIL.}
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
procedure TCibTabProduc.IncrementarStock(codPro: string; Cant: Double);
{Actualiza el stock de la tabla de productos.}
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
    //Realmente debería ser una alarma
  end;
  pro.Stock := stock;     //actualiza estado en memoria
  SaveToDisk;
end;
function TCibTabProduc.ActualizarTabIngStock(nuevDatos: string): string;
{Se pide actualizar el stock de la tabla, sin modificar los demás campos.
"nuevDatos" es la nueva tabla en formato de texto, cuyas líneas deberían tener el
formato:
<ID de prod.> #9 <Increento de stock o nuevo stock>
Si encuentra error, actualiza "MsjError".}
var
  lineas: TStringList;
  lin, id: String;
  a: TStringDynArray;
  incStock: Double;
  nProModif: Integer;
begin
  try
    lineas := TStringList.Create;
    lineas.Text := nuevDatos;
    nProModif := 0;
    for lin in lineas do begin
      if trim(lin) = '' then continue;
      //Obtiene campos
      a := Explode(#9, lin);
      try
        id := a[0];
        if a[1] = '' then continue;  //no hay ingreso de stock
        incStock := StrToFloat(a[1]);
      except
        msjError:= 'Error modificando tabla de productos.';
        Result := msjError;
        LoadFromDisk;   //Ignora cambios
        exit;
      end;
      //Actualiza stock
      inc(nProModif);
      IncrementarStock(id, -incStock);  //es incremento
      if msjError<>'' then begin
        Result := msjError;
        LoadFromDisk;
        exit;
      end;
    end;
  finally
    lineas.Destroy;
  end;
  SaveToDisk;   //Actualiza disco
  //Generamos mensaje de resumen
  Result := 'Tabla de productos actualizada, en Stock (' +
            IntToStr(nProModif) + ' registros modificados).';
end;
function TCibTabProduc.ActualizarTabNoStock(nuevDatos: string): string;
{Se pide actualizar la tabla, sin modificar el stock. Es normal porque pueden
haberse realizado ventas. Devuelve un resumen de los cambios.
"nuevDatos" es la nueva tabla en formato de texto.
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

//Inicialización
procedure TCibTabProduc.SetCols(linHeader: string);
begin
  inherited;
  if msjError<>'' then exit;
  //Inicializa índices de las columnas de la tabla
  TCibRegProduc.NCOLS        := high(fields)+1;  //Número de columnas leídas
  TCibRegProduc.COL_Cod      := FindColPos('ID_PROD');
  TCibRegProduc.COL_CATEG    := FindColPos('CATEGORIA');
  TCibRegProduc.COL_SUBCAT   := FindColPos('SUBCATEGORIA');
  TCibRegProduc.COL_NOMBRE   := FindColPos('NOMBRE');
  TCibRegProduc.COL_DESC     := FindColPos('DESCRIPCION');
  TCibRegProduc.COL_MARCA    := FindColPos('MARCA');
  TCibRegProduc.COL_UNIDCOMP := FindColPos('UNIDCOMP');
  TCibRegProduc.COL_PRECOSTO := FindColPos('PRECOSTO');
  TCibRegProduc.COL_PREVENTA := FindColPos('PREVENTA');
  TCibRegProduc.COL_STOCK    := FindColPos('STOCK');
  TCibRegProduc.COL_TPRE     := FindColPos('TPREPAR');
  TCibRegProduc.COL_FECCRE   := FindColPos('FECCRE');
  TCibRegProduc.COL_FECMOD   := FindColPos('FECMOD');
  //Puede salir con error en "msjError".
end;
constructor TCibTabProduc.Create;
begin
  inherited;
  Productos:= TCibRegProduc_list.Create(true);
  items := {%H-}TCibRegistro_list(Productos);
end;

end.

