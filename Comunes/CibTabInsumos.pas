{Define a la tabla de insumos}
unit CibTabInsumos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, LConvEncoding, MisUtils, LCLProc, CibBD;
type
  { TCibRegInsumo }
  {Registro que representa a un producto.}
  TCibRegInsumo = class(TCibRegistro)
    class var NCOLS         : integer;  //Número de columnas
    class var COL_Cod      : integer;
    class var COL_Categ    : integer;
    class var COL_Subcat   : integer;
    class var COL_Nombre   : integer;
    class var COL_Desc     : integer;
    class var COL_Marca    : integer;
    class var COL_UnidComp : integer;
    class var COL_PreCosto : integer;
    class var COL_Uso      : integer;
    class var COL_Stock    : integer;
    class var COL_provee   : integer;
    class var COL_ultCom   : integer;
    class var COL_Coment   : integer;
  private
    function GetCateg: string;
    function GetCod: string;
    function GetComent: string;
    function GetDesc: string;
    function GetMarca: string;
    function GetNombre: string;
    function GetPreCosto: Double;
    function Getprovee: string;
    function GetStock: Double;
    function GetSubcat: string;
    function GetultCom: TDateTime;
    function GetUnidComp: string;
    function GetUso: string;
    procedure SetCateg(AValue: string);
    procedure SetCod(AValue: string);
    procedure SetComent(AValue: string);
    procedure SetDesc(AValue: string);
    procedure SetMarca(AValue: string);
    procedure SetNombre(AValue: string);
    procedure SetPreCosto(AValue: Double);
    procedure Setprovee(AValue: string);
    procedure SetStock(AValue: Double);
    procedure SetSubcat(AValue: string);
    procedure SetultCom(AValue: TDateTime);
    procedure SetUnidComp(AValue: string);
    procedure SetUso(AValue: string);
  public  //campos temporales
    estReg  : char;   //estado del registro
  public
    property Cod     : string    read GetCod      write SetCod     ; //Código de producto
    property Categ   : string    read GetCateg    write SetCateg   ; //Categoría de producto
    property Subcat  : string    read GetSubcat   write SetSubcat  ; //Sub-categoría
    property Nombre  : string    read GetNombre   write SetNombre  ; //Nombre
    property Desc    : string    read GetDesc     write SetDesc    ; //Descripción
    property Marca   : string    read GetMarca    write SetMarca   ; //Indica la marca o marcas que se compran.
    property UnidComp: string    read GetUnidComp write SetUnidComp; //Unidad en que se compra el insumo (docena, bolsa de ...).
    property PreCosto: Double    read GetPreCosto write SetPreCosto; //Precio al qie se compra el producto
    property Uso     : string    read GetUso      write SetUso     ; //En qué se usa el insumo
    property Stock   : Double    read GetStock    write SetStock   ; //Stock de producto
    property provee  : string    read Getprovee   write Setprovee  ; //proveedor
    property ultCom  : TDateTime read GetultCom   write SetultCom  ; //Fecha de última compra
    property Coment  : string    read GetComent   write SetComent  ; //Comentario
  public
    constructor Create;
  end;
  TCibRegInsumo_list = specialize TFPGObjectList<TCibRegInsumo>;   //lista de ítems

  { TCibTabInsumo }
  {Define a una tabla de insumos.}
  TCibTabInsumo = class(TCibTablaMaest)
  protected
    function BuscarInsum(codigo: String): TCibRegInsumo;
  public
    Insumos: TCibRegInsumo_list;  //Almacena los productos
    function AddNewRecord: TCibRegistro; override;
    //Rutinas que modifican la tabla
    procedure ActualizarStock(codPro: string; Cant: Double);
  public  //Inicialización
    procedure SetCols(linHeader: string); override;
    constructor Create; override;
  end;

implementation

{ TCibRegInsumo }
function TCibRegInsumo.GetCod: string;
begin
  Result := values[COL_Cod];
end;
procedure TCibRegInsumo.SetCod(AValue: string);
begin
  values[COL_Cod] := AValue;
end;
function TCibRegInsumo.GetCateg: string;
begin
  Result := values[COL_Categ];
end;
procedure TCibRegInsumo.SetCateg(AValue: string);
begin
  values[COL_Categ] := AValue;
end;
function TCibRegInsumo.GetComent: string;
begin
  Result := values[COL_Coment];
end;
procedure TCibRegInsumo.SetComent(AValue: string);
begin
  values[COL_Coment] := AValue;
end;
function TCibRegInsumo.GetDesc: string;
begin
  Result := values[COL_Desc];
end;
procedure TCibRegInsumo.SetDesc(AValue: string);
begin
  values[COL_Desc] := AValue;
end;
function TCibRegInsumo.GetMarca: string;
begin
  Result := values[COL_Marca];
end;
procedure TCibRegInsumo.SetMarca(AValue: string);
begin
  values[COL_Marca] := AValue;
end;
function TCibRegInsumo.GetNombre: string;
begin
  Result := values[COL_Nombre];
end;
procedure TCibRegInsumo.SetNombre(AValue: string);
begin
  values[COL_Nombre] := AValue;
end;
function TCibRegInsumo.GetPreCosto: Double;
begin
  Result := f2N(values[COL_PreCosto]);
end;
procedure TCibRegInsumo.SetPreCosto(AValue: Double);
begin
  values[COL_PreCosto] := N2f(AValue);
end;
function TCibRegInsumo.Getprovee: string;
begin
  Result := values[COL_provee];
end;
procedure TCibRegInsumo.Setprovee(AValue: string);
begin
  values[COL_provee] := AValue;
end;
function TCibRegInsumo.GetStock: Double;
begin
  Result := f2N(values[COL_Stock]);
end;
procedure TCibRegInsumo.SetStock(AValue: Double);
begin
  values[COL_Stock] := N2f(AValue);
end;
function TCibRegInsumo.GetSubcat: string;
begin
  Result := values[COL_Subcat];
end;
procedure TCibRegInsumo.SetSubcat(AValue: string);
begin
  values[COL_Subcat] := AValue;
end;
function TCibRegInsumo.GetultCom: TDateTime;
begin
  Result := f2D(values[COL_ultCom]);
end;
procedure TCibRegInsumo.SetultCom(AValue: TDateTime);
begin
  values[COL_ultCom] := D2f(AValue);
end;
function TCibRegInsumo.GetUnidComp: string;
begin
  Result := values[COL_UnidComp];
end;
procedure TCibRegInsumo.SetUnidComp(AValue: string);
begin
  values[COL_UnidComp] := AValue;
end;
function TCibRegInsumo.GetUso: string;
begin
  Result := values[COL_Uso];
end;
procedure TCibRegInsumo.SetUso(AValue: string);
begin
  values[COL_Uso] := AValue;
end;
constructor TCibRegInsumo.Create;
begin
  setlength(values, TCibRegInsumo.NCOLS);
  //Para mayor explicación ver el comentario de TCibRegProduc.Create;
end;
{ TCibTabInsumo }
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
//Inicialización
procedure TCibTabInsumo.SetCols(linHeader: string);
begin
  inherited;
  if msjError<>'' then exit;
  //Inicializa índices de las columnas de la tabla
  TCibRegInsumo.NCOLS        := high(fields)+1;  //Número de columnas leídas
  TCibRegInsumo.COL_Cod      := FindColPos('ID_INSUM');
  TCibRegInsumo.COL_Categ    := FindColPos('CATEGORIA');
  TCibRegInsumo.COL_Subcat   := FindColPos('SUBCATEGORIA');
  TCibRegInsumo.COL_Nombre   := FindColPos('NOMBRE');
  TCibRegInsumo.COL_Desc     := FindColPos('DESCRIPCION');
  TCibRegInsumo.COL_Marca    := FindColPos('MARCA');
  TCibRegInsumo.COL_UnidComp := FindColPos('UNIDCOMP');
  TCibRegInsumo.COL_PreCosto := FindColPos('PRECOSTO');
  TCibRegInsumo.COL_Uso      := FindColPos('USO');
  TCibRegInsumo.COL_Stock    := FindColPos('STOCK');
  TCibRegInsumo.COL_provee   := FindColPos('PROVEE');
  TCibRegInsumo.COL_ultCom   := FindColPos('ULTCOM');
  TCibRegInsumo.COL_Coment   := FindColPos('COMENT');
  //Puede salir con error en "msjError".
end;
constructor TCibTabInsumo.Create;
begin
  inherited;
  Insumos:= TCibRegInsumo_list.Create(true);
  items := {%H-}TCibRegistro_list(Insumos);
end;

end.

