{Unidad que define a la tabla de Proveedores.}
unit CibTabProvee;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, LConvEncoding, MisUtils, LCLProc, CibBD;
const
  MODTAB_NOSTCK = 5;   //Modificación de tabla de productos sin tocar el stock
  MODTAB_INGSTCK = 6;  //Modificación de tabla de productos, para ingresar stock

type

  { TCibRegProvee }
  {Registro que representa a un proveedor.}
  TCibRegProvee = class(TCibRegistro)
  public
    class var NCOLS         : integer;  //Número de columnas
    class var COL_Cod       : integer;
    class var COL_Categ     : integer;
    class var COL_Subcat    : integer;
    class var COL_NomEmpresa: integer;
    class var COL_Productos : integer;
    class var COL_Contacto  : integer;
    class var COL_Telefono  : integer;
    class var COL_Envio     : integer;
    class var COL_Direccion : integer;
    class var COL_Notas     : integer;
    class var COL_UltCompra : integer;
    class var COL_Estado    : integer;
  private
    function GetCateg: string;
    function GetCod: string;
    function GetContacto: string;
    function GetDireccion: string;
    function GetEnvio: string;
    function GetEstado: string;
    function GetNomEmpresa: string;
    function GetNotas: string;
    function GetProductos: string;
    function GetSubcat: string;
    function GetTelefono: string;
    function GetUltCompra: TDateTime;
    procedure SetCateg(AValue: string);
    procedure SetCod(AValue: string);
    procedure SetContacto(AValue: string);
    procedure SetDireccion(AValue: string);
    procedure SetEnvio(AValue: string);
    procedure SetEstado(AValue: string);
    procedure SetNomEmpresa(AValue: string);
    procedure SetNotas(AValue: string);
    procedure SetProductos(AValue: string);
    procedure SetSubcat(AValue: string);
    procedure SetTelefono(AValue: string);
    procedure SetUltCompra(AValue: TDateTime);
  public
    property Cod       : string    read GetCod        write SetCod        ;    //Código único
    property Categ     : string    read GetCateg      write SetCateg      ;
    property Subcat    : string    read GetSubcat     write SetSubcat     ;
    property NomEmpresa: string    read GetNomEmpresa write SetNomEmpresa ;
    property Productos : string    read GetProductos  write SetProductos  ;
    property Contacto  : string    read GetContacto   write SetContacto   ;
    property Telefono  : string    read GetTelefono   write SetTelefono   ;
    property Envio     : string    read GetEnvio      write SetEnvio      ;
    property Direccion : string    read GetDireccion  write SetDireccion  ;
    property Notas     : string    read GetNotas      write SetNotas      ;     //Notas sobre el proveedor
    property UltCompra : TDateTime read GetUltCompra  write SetUltCompra  ;  //Fecha de última compra
    property Estado    : string    read GetEstado     write SetEstado     ;       //Estado
  public
    constructor Create;
  end;
  TCibRegProvee_list = specialize TFPGObjectList<TCibRegProvee>;   //lista de ítems

  { TCibTabProvee }
  TCibTabProvee = class(TCibTablaMaest)
  public
    Proveedores: TCibRegProvee_list;  //Almacena los productos
    function AddNewRecord: TCibRegistro; override;
  public  //Inicialización
    procedure SetCols(linHeader: string); override;
    constructor Create; override;
  end;

implementation

{ TCibRegProvee }
function TCibRegProvee.GetCod: string;
begin
  Result := values[COL_Cod];
end;
procedure TCibRegProvee.SetCod(AValue: string);
begin
  values[COL_Cod] := AValue;
end;
function TCibRegProvee.GetCateg: string;
begin
  Result := values[COL_Categ];
end;
procedure TCibRegProvee.SetCateg(AValue: string);
begin
  values[COL_Categ] := AValue;
end;
function TCibRegProvee.GetContacto: string;
begin
  Result := values[COL_Contacto];
end;
procedure TCibRegProvee.SetContacto(AValue: string);
begin
  values[COL_Contacto] := AValue;
end;
function TCibRegProvee.GetDireccion: string;
begin
  Result := values[COL_Direccion];
end;
procedure TCibRegProvee.SetDireccion(AValue: string);
begin
  values[COL_Direccion] := AValue;
end;
function TCibRegProvee.GetEnvio: string;
begin
  Result := values[COL_Envio];
end;
procedure TCibRegProvee.SetEnvio(AValue: string);
begin
  values[COL_Envio] := AValue;
end;
function TCibRegProvee.GetEstado: string;
begin
  Result := values[COL_Estado];
end;
procedure TCibRegProvee.SetEstado(AValue: string);
begin
  values[COL_Estado] := AValue;
end;
function TCibRegProvee.GetNomEmpresa: string;
begin
  Result := values[COL_NomEmpresa];
end;
procedure TCibRegProvee.SetNomEmpresa(AValue: string);
begin
  values[COL_NomEmpresa] := AValue;
end;
function TCibRegProvee.GetNotas: string;
begin
  Result := values[COL_Notas];
end;
procedure TCibRegProvee.SetNotas(AValue: string);
begin
  values[COL_Notas] := AValue;
end;
function TCibRegProvee.GetProductos: string;
begin
  Result := values[COL_Productos];
end;
procedure TCibRegProvee.SetProductos(AValue: string);
begin
  values[COL_Productos] := AValue;
end;
function TCibRegProvee.GetSubcat: string;
begin
  Result := values[COL_Subcat];
end;
procedure TCibRegProvee.SetSubcat(AValue: string);
begin
  values[COL_Subcat] := AValue;
end;
function TCibRegProvee.GetTelefono: string;
begin
  Result := values[COL_Telefono];
end;
procedure TCibRegProvee.SetTelefono(AValue: string);
begin
  values[COL_Telefono] := AValue;
end;
function TCibRegProvee.GetUltCompra: TDateTime;
begin
  Result := f2D(values[COL_UltCompra]);
end;
procedure TCibRegProvee.SetUltCompra(AValue: TDateTime);
begin
  values[COL_UltCompra] := D2f(AValue);
end;
constructor TCibRegProvee.Create;
begin
  setlength(values, TCibRegProvee.NCOLS);
end;
{ TCibTabProvee }
function TCibTabProvee.AddNewRecord: TCibRegistro;
begin
  Result := TCibRegProvee.Create; //crea registro de producto
end;
procedure TCibTabProvee.SetCols(linHeader: string);
begin
  inherited;
  if msjError<>'' then exit;
  //Inicializa índices de las columnas de la tabla
  TCibRegProvee.NCOLS         := high(fields)+1;  //Número de columnas leídas
  TCibRegProvee.COL_Cod       := FindColPos('ID_PROV');
  TCibRegProvee.COL_Categ     := FindColPos('CATEGORIA');
  TCibRegProvee.COL_Subcat    := FindColPos('SUBCATEGORIA');
  TCibRegProvee.COL_NomEmpresa:= FindColPos('NOMEMPRESA');
  TCibRegProvee.COL_Productos := FindColPos('PRODUCTOS');
  TCibRegProvee.COL_Contacto  := FindColPos('CONTACTO');
  TCibRegProvee.COL_Telefono  := FindColPos('TELEFONO');
  TCibRegProvee.COL_Envio     := FindColPos('ENVIO');
  TCibRegProvee.COL_Direccion := FindColPos('DIRECCION');
  TCibRegProvee.COL_Notas     := FindColPos('NOTAS');
  TCibRegProvee.COL_UltCompra := FindColPos('ULTCOMPRA');
  TCibRegProvee.COL_Estado    := FindColPos('ESTADO');
  //Puede salir con error en "msjError".
end;
constructor TCibTabProvee.Create;
begin
  inherited;
  Proveedores:= TCibRegProvee_list.Create(true);
  items := {%H-}TCibRegistro_list(Proveedores);
end;

end.
//606
