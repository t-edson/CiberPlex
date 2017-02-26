{Unidad que pernmite trabajar con el archivo de productos.}
unit CibProductos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, types, MisUtils, LCLProc, CibBD;
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
//    stockMin : String   'Stock mínimo de producto
//    rec     : String   'CADENA. Receta para stock de almacén
    tPre    : Double;   //NUMÉRICO. Tiempo de preparación
    fecCre  : TDateTime; //Fecha de creación
    fecMod  : TDateTime; //Fecha de modificación.
//    est     : Boolean  'BOLEAN. Estado: Activado o desactivado
//    img     : String   'CADENA. Archivo de imagen
  public  //campos temporales
    estReg: char;   //estado del registro
  public
    function ToString: String; override;
    procedure FromString(cad: String); override;
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
    Envio     : boolean;
    Direccion : string;
    Notas     : string;     //Notas sobre el proveedor
    UltCompra : TDateTime;  //Fecha de última compra
    Estado    : char;       //Estado
  public
    function ToString: String; override;
    procedure FromString(cad: String); override;
  end;
  TCibRegProvee_list = specialize TFPGObjectList<TCibRegProvee>;   //lista de ítems

  { TCibTabProduc }
  {Define a una tabla de productos.}
  TCibTabProduc = class(TCibTabla)
  protected
    function BuscarProd(codigo: String): TCibRegProduc;
    procedure AgregarItemText(txt: string); override;
  public
    Productos: TCibRegProduc_list;  //Almacena los productos
    procedure LeerDeDisco;
    procedure GrabarADisco;
    procedure ActualizarStock(codPro: string; Cant: Double);
    function ActualizarNoStock(nuevDatos: string): string;
  public  //Inicialización
    constructor Create;
    destructor Destroy; override;
  end;

  { TCibTabProvee }
  TCibTabProvee = class(TCibTabla)
  protected
    function BuscarProv(codigo: String): TCibRegProvee;
    procedure AgregarItemText(txt: string); override;
  public
    Proveedores: TCibRegProvee_list;  //Almacena los productos
    procedure LeerDeDisco;
    procedure GrabarADisco;
  public  //Inicialización
    constructor Create;
    destructor Destroy; override;
  end;

implementation
uses LConvEncoding;
{ TCibRegProduc }
function TCibRegProduc.ToString: String;
{Devuelve una cadena para guardar a disco.}
var
  desc0: RawByteString;
begin
  {$IFDEF Windows}
    desc0 := UTF8ToCP1252(Desc);
  {$ELSE}
    desc0 := descr;
  {$ENDIF}
  Result := Cod + #9 +
            Categ + #9 +
            Subcat + #9 + Nombre + #9 +
            S2f(desc0) + #9 +
            Marca + #9 +
            UnidComp + #9 +
            N2f(PreCosto) + #9 +
            N2f(preVenta) + #9 +
            N2f(Stock) + #9 +
            #9 + #9 +
            N2f(tPre) + #9 +
            D2f(fecCre) + #9 +
            D2f(fecMod) + #9 + #9 + #9;
end;
procedure TCibRegProduc.FromString(cad: String);
//Convierte cadena de texto en registro
var
  a: TStringDynArray;
begin
    a :=  explode(#9, cad);
    Cod     := a[0];      //Carga código
    Categ   := a[1];      //Carga categoría
    Subcat  := a[2];   //Carga sub-categoría
    Nombre  := a[3];
    Desc    := f2S(a[4]);   //Carga descripción
    Marca   := a[5];
    UnidComp:= a[6];
    PreCosto:= f2N(a[7]);  //Carga precio unitario
    preVenta:= f2N(a[8]);  //Carga precio unitario
    Stock   := f2N(a[9]);  //Carga Stock
    tPre    := f2N(a[12]);
    fecCre  := f2D(a[13]);
    fecCre  := f2D(a[14]);
    {$IFDEF Windows}
    Desc := CP1252ToUTF8(Desc);
    {$ELSE}
    desc := descr;
    {$ENDIF}
end;
{ TCibRegProvee }
function TCibRegProvee.ToString: String;
begin
  Result := Cod + #9 +
            Categ + #9 +
            Subcat + #9 +
            NomEmpresa + #9 +
            Productos + #9 +
            Contacto + #9 +
            Telefono+ #9 +
            B2f(Envio) + #9 +
            Direccion + #9 +
            Notas + #9 +
            D2f(UltCompra) + #9 +
            Estado + #9 + #9;
end;
procedure TCibRegProvee.FromString(cad: String);
var
  a: TStringDynArray;
begin
  a := explode(#9, cad);
  Cod       := a[0];      //Carga código
  Categ     := a[1];      //Carga categoría
  Subcat    := a[2];   //Carga sub-categoría
  NomEmpresa:= a[3];
  Productos := a[4];
  Contacto  := a[5];
  Telefono  := a[6];
  Envio     := f2B(a[7]);
  Direccion := a[8];
  Notas     := a[9];
  UltCompra := f2D(a[10]);
  Estado    := a[11][1];
end;
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
procedure TCibTabProduc.AgregarItemText(txt: string);
{Agrega un ítem, a partir de una cadena de texto.}
var
  reg: TCibRegProduc;
begin
  reg:= TCibRegProduc.Create; //crea registro de producto
  reg.FromString(txt);    //puede generar error si
  Productos.Add(reg);
end;
procedure TCibTabProduc.LeerDeDisco;
{Carga la tabla de productos de disco. Si encuentra error, actualiza "MsjError".}
begin
  LoadFromDisk(TCibRegistro_list(Productos));   //Casting "algo inseguro".
  //Puede devolver error en "MsjError"
end;
procedure TCibTabProduc.GrabarADisco;
{Graba la tabla de productos a disco. Si encuentra error, actualiza "MsjError".}
begin
  SaveToDisk(TCibRegistro_list(Productos));   //Casting "dudoso".
  //Puede devolver error en "MsjError"
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
  SaveToDisk(TCibRegistro_list(Productos));   //Casting "dudoso".
end;
function TCibTabProduc.ActualizarNoStock(nuevDatos: string): string;
{Se pide actualizar la tabla, sin modificar el stock. Es normal porque pueden
haberse realizado ventas. Devuelve un resumen de los cambios.
Si encuentra error, actualiza "MsjError".}
var
  pro, protmp: TCibRegProduc;
  tabtmp: TCibTabProduc;
  nProNuevos, nProElimin: Integer;
begin
  //Carga nuevos datos para la búsqueda
  tabtmp := TCibTabProduc.Create;
  tabtmp.LoadFromString(TCibRegistro_list(tabtmp.Productos), nuevDatos);
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
  tabtmp.GrabarADisco;
  tabtmp.Destroy;
  LoadFromDisk(TCibRegistro_list(Productos));  //Puede generar error
  if msjError<>'' then begin
    Result := 'Error modificando tabla de productos.';
    exit;
  end;
  //Generamos mensaje de resumen
  Result := 'Tabla de productos actualizada, sin Stock.' + LineEnding +
            IntToStr(nProNuevos) + ' registros nuevos.' + LineEnding +
            IntToStr(nProElimin) + ' registros eliminados.';
end;
constructor TCibTabProduc.Create;
begin
  Productos:= TCibRegProduc_list.Create(true);
end;
destructor TCibTabProduc.Destroy;
begin
  Productos.Destroy;
  inherited Destroy;
end;
{ TCibTabProvee }
function TCibTabProvee.BuscarProv(codigo: String): TCibRegProvee;
{Busca un producto por el código. Si no encuentra devuelve un
registro en blanco.}
var
  p: TCibRegProvee;
begin
  codigo := UpCase(codigo);
  for p in Proveedores do begin
    if UpCase(p.Cod) = codigo Then begin
      exit(p);
    end;
  end;
  //No encontró
  exit(nil);
end;
procedure TCibTabProvee.AgregarItemText(txt: string);
{Agrega un ítem, a partir de una cadena de texto.}
var
  reg: TCibRegProvee;
begin
  reg:= TCibRegProvee.Create; //crea registro de producto
  reg.FromString(txt);    //puede generar error si
  Proveedores.Add(reg);
end;
procedure TCibTabProvee.LeerDeDisco;
{Carga el archivo de productos indicado. Si encuentra error, actualiza "MsjError".}
begin
  LoadFromDisk(TCibRegistro_list(Proveedores));   //Casting "algo inseguro".
end;
procedure TCibTabProvee.GrabarADisco;
begin
  SaveToDisk(TCibRegistro_list(Proveedores));   //Casting "dudoso".
end;
constructor TCibTabProvee.Create;
begin
  Proveedores:= TCibRegProvee_list.Create(true);
end;
destructor TCibTabProvee.Destroy;
begin
  Proveedores.Destroy;
  inherited Destroy;
end;

end.

