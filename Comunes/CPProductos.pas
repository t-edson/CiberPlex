{Unidad que pernmite trabajar con el archivo de productos.}
unit CPProductos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, types, MisUtils, CibRegistros, FormInicio;
type
  //Define el tipo que almacena un producto (Una línea del archivo de productos)

  { regProdu }
  TregProdu = class
      cod     : String;   //ALFANUMÉRICO. Código de producto
      cat     : String;   //ALFANUMÉRICO. Categoría de producto
      subcat  : String;   //ALFANUMÉRICO. Sub-categoría
      //nom    : String   'CADENA. Nombre
      desc    : String;   //CADENA. Descripción
  //    est     : Boolean  'BOLEAN. Estado: Activado o desactivado
  //    not:   : String   'CADENA. Comentarios
  //    img     : String   'CADENA. Archivo de imagen
      pUnit   : Double;   //Precio unitario
      stock   : Double;   //Stock de producto
  //    stockMin : String   'Stock mínimo de producto
  //    rec     : String   'CADENA. Receta para stock de almacén
      tPre    : Double;   //NUMÉRICO. Tiempo de preparación
      //fCre  : date      'FECHA. fecha de creación
      //fMod  : date      'FECHA. fecha de modificación.
      ind     : Integer;  //NUMÉRICO. Posición dentro de la matriz
  public
    function regProd_ADisco: String;
    procedure regProd_DeDisco(cad: String);
  end;
  TregProdu_list = specialize TFPGObjectList<TregProdu>;   //lista de ítems

var
  Productos: TregProdu_list;  //Almacena los productos

  procedure ActualizarStock(arcProduc, codPro: string; Cant: Double);
  function CargarProductos(archivo: string): string;

implementation

//******************* FUNCIONES DE BÚSQUEDA *********************
function BuscarProd(codigo: String): TregProdu;
{Busca un producto por el código. Si no encuentra devuelve un
registro en blanco.}
var
  p: TregProdu;
begin
  codigo := UpCase(codigo);
  for p in Productos do begin
    if UpCase(p.cod) = codigo Then begin
      exit(p);
    end;
  end;
  //No encontró
  exit(nil);
end;
procedure ProdADisco(arcProduc: string);
{Vuelca la información de la tabla de productos a disco. Usa un archivo
temporal para proteger los datos del archivo original.
Actualiza la bandera "msjeError".}
var
  arc: TextFile;    //manejador de archivo
  pro: TRegProdu;
  //linea : string;
  tmp_produc : string;
begin
  //Abre archivo de entrada y salida
  try
    tmp_produc := arcProduc + '.tmp';
    AssignFile(arc, tmp_produc);
    rewrite(arc);
    for pro in Productos do begin
      writeLn(arc, pro.regProd_ADisco);
    end;
    CloseFile(arc);
    //Actualiza archivo de productos
    DeleteFile(arcProduc);     //Borra anterior
    RenameFile(tmp_produc, arcProduc); //Renombra nuevo
  except
    on e: Exception do begin
      msjError := 'Error actualizando productos: ' + e.Message;
      PLogErr(usuario, msjError);
      CloseFile(arc);
    end;
  end;
end;
procedure ActualizarStock(arcProduc, codPro: string; Cant: Double);
{Actualiza el stock del producto indicado en el archivo de productos
Se crea una copia actualizada y luego se reemplaza la anterior}
var
  stock: Single;
  pro: TregProdu;
begin
    pro := BuscarProd(codPro);
    if pro = nil Then begin
        MsgBox('Error en Código de producto');
        exit;
    end;
    msjError := '';
    //Verifica cambio de stock
    stock := pro.stock;
    stock := stock - Cant;   //actualiza
    if stock < 0 Then begin
        //Se genera mensaje de error
        PLogErr(usuario, 'No hay disponibilidad de stock: ' + pro.cod);
    end;
    pro.stock := stock;     //actualiza estado en memoria
    ProdADisco(arcProduc);     //Actualiza msjError
end;
Function VerificaProducto(r: TregProdu): string;
{Verifica si el registro de producto cumple con la definición.
El error se devuelve como cadena.}
var
  reg: TregProdu;
begin
    Result  := '';   //Inicia mensaje
    //------------------ Verifica Código --------------------
    if r.cod = '' then begin    //Verificación de Código
        Result  := 'No se ha especificado código para: ' + r.desc;
        Exit;       //sale con error
    end;
    //------------------- Verifica Descripción ------------------------
    if r.desc = '' then begin   //Verificación de descripción
        Result  := 'No se ha especificado descripción para CÓDIGO: ' + r.cod;
        Exit;    //sale con error
    end;
    //------------------- Verifica Unicidad de Código ----------------------
    for reg in Productos do begin
        If reg.cod = r.cod then begin
            Result  := 'Código duplicado. (' + r.cod + ')';
            exit;
        end;
    end;
end;
Function CargarProductos(archivo: string): string;
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con el mensaje de error.}
var
  narc: text;
  linea : String;
  n , nlin: Integer;        //Número de productos leidas
  reg: TregProdu;
  a: TStringDynArray;
begin
  Result := '';
  try
    AssignFile(narc , archivo);
    reset(narc);
    n := 1;
    nlin := 0;
    Productos.Clear;
    while not eof(narc) do begin
        nlin := nlin + 1;
        readln(narc, linea);
        if linea <> '' then begin  //tiene datos
            a := Explode(#9, linea);
            if High(a) <> 17 Then begin      //Verifica cantidad de campos
                Result := 'Error de estructura de producto. Línea: ' + IntToStr(nlin);
                break;
            end;
            reg:= TregProdu.Create;  //crea registro de producto
            reg.regProd_DeDisco(linea);
            reg.ind := n;        //Carga ubicación
            Result := VerificaProducto(reg);  //Verifica consistencia
            Productos.Add(reg);
            If Result <> '' Then break;
            //actualiza contador y estado de carga
            n := n + 1;
            if n Mod 50 = 0 Then begin   //va actualizando estado
                //nProd = n - 1
                //Call MDIPrincipal.RefrescarEstado
                //frmEstado.lblMensaje = nRutas & " productos cargados."
                //DoEvents
            end;
        end;
    end;
    Close(narc);
    exit;  //Puede salir con mensaje de error en "Result".
  except
    on e:Exception do begin
      Result := 'Error cargando productos (' + archivo + '): ' + e.Message;
      //Close(narc);  No cierra ya que si falló al abrir, (lo más común) genera error al intentar cerralo.
    end;
  end;
end;

Function TRegProdu.regProd_ADisco: String;
begin
    Result := cod + #9 +
              cat + #9 +
              subcat + #9 + #9 +
              S2f(desc) + #9 + #9 + #9 + #9 +
              N2f(pUnit) + #9 +
              N2f(stock) + #9 + #9 + #9 +
              N2f(tPre) + #9 +
              D2f(Time) + #9 + D2f(Time) + #9 + #9 + #9;
end;
procedure TRegProdu.regProd_DeDisco(cad: String);
//Convierte cadena de texto en registro
var
  a: TStringDynArray;
begin
    a :=  explode(#9, cad);
    cod := a[0];      //Carga código
    cat := a[1];      //Carga categoría
    subcat := a[2];   //Carga sub-categoría

    desc := f2S(a[4]);   //Carga descripción

    pUnit := f2N(a[8]);  //Carga precio unitario
    stock := f2N(a[9]);  //Carga stock
end;

initialization
  Productos:= TregProdu_list.Create(true);

finalization
  Productos.Destroy;

end.

