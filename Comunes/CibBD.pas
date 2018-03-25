{Unidad que almacena las definiciones y rutinas de la base de datos.
Esta unidad sería lo más cercano a un manejador de Base de datos.
No se usa una base de datos estándar porque no se encontró ninguna que cumpliera con
los requerimientos de la aplicación:
* Embebida, sin dependencias externas.
* Portable, sin necesidad de instalación.
* Multiplataforma.
* Ligera, con tablas de pequeño tamaño.
* Capaz de particionar sus archivos históricos en periodos de meses.
* Segura, en el sentido de evitar pérdidas de datos.
* Capaz de separar sus tablas en archivos independientes para mandarlos por la red.
* Posibilidad de cambiar el orden de las filas alamcenadas en las tablas (sin necesidad
de usar índices), debido a que se requiere que las consultas arrojen resultados en un
orden específico.

Además la idea de la base de datos, del servidor es que sea solo una base de datos local,
ya que la base de datos Central, debería estar en la nube.
Sin embargo, sería posible usar alguna otra base de datos, sacrificando alguna de las
funcionalidades.
De las que se evaluó, la que más se adaptaba era probablemente FoxPro (el formato de
tablas), solo que no es fácil cambiar el orden en que aparecen los resultados de las
consultas, y he visto problemas de pérdida de información, además FoxPro o Visual
FoxPro, ya es anticuada.

La idea de este manejador es que se puedan manejar dos tipos de tablas: Tablas Maestras
y tablas Históricas.

Para más informacción revisar la documentación técnica.
}
unit CibBD;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, Types, LCLProc, LConvEncoding, FileUtil, Dos,
  MisUtils, CibFacturables;
const
  //Tipo de modificación a realizar en una tabla
  MODTAB_TOTAL = 0;   //Reemplazar completamente la tabla
  MODTAB_BYIDX = 1;   //Modifica las tablas por índice (puede agreagr o eliminar filas
  MODTAB_INDEX = 2;   //Modifica los índices
  //los dem´sa valores pueden personalizarse
type

  //Evento para solicitar la modficación de una tabla
  TEvModifTablaBD = function(NombTabla: string; tipModif: integer;
                             const datos: string): string of object;
  //Evento para registrar un mensje de error
  TEvProLogError = function(msj: string): integer of object;

  //Tipos de datos aceptados
  TCibColType = (
    ctText,     //columna de tipo texto
    ctFloat,    //columna de tipo numérico
    ctDatTim    //Columna de tipo Fecha
  );

  TCibEvGetStr = function(): string of object;
  TCibEvSetStr = procedure(AValue: string) of object;
  TCibEvGetFloat = function(): Double of object;
  TCibEvSetFloat = procedure(AValue: Double) of object;
  TCibEvGetDatTim = function(): TDateTime of object;
  TCibEvSetDatTim = procedure(AValue: TDateTime) of object;
  { TCibFieldInfo }
  {Se define para almacenar información sobre un campo de la tabla. También se usa
  como forma de acceder a los valores de los campos:  AsString(), AsFloat()}
  TCibFieldInfo = object  {<-- Evaluar si conviene mejor, usar una clase}
    Name   : string;
    colType: TCibColType;
    idxCol : word;   //índice a campo
  end;

  { TCibRegistro }
  {Clase que sirve como base para derivar las clases que representarán a las filas de una
  tabla maestra. Se define como una clase genérica para poder crear la lista
  "TCibTablaMaest.items"}
  TCibRegistro = class
  private
    function GetValuesStr: string;
    procedure SetValuesStr(AValue: string);
  public
    values     : array of string;  //Contendor principal para los valores de las columnas
    {Notar que TCibRegistro contiene todo el contenido de la fila leída del archivo}
    property valuesStr: string read GetValuesStr write SetValuesStr;
  end;
  TCibRegistro_list = specialize TFPGObjectList<TCibRegistro>;   //lista de ítems

  { TCibTablaMaest }
  {Define a una tabla maestra. Esta clase es un contenedor, en memoria, de los datos
  que se encuentran en disco. Por eso debe grabarse a disco, cuando se hagan
  modificaciones.}
  TCibTablaMaest = class
  private
    idx    : integer;   //posición actual ¿Se usa realmente?
    FmsjError: string;
    procedure SetMsjError(AValue: string);
  protected
    archivo: string;
    //Rutinas de modificación de bajo nivel. Protegidas
    procedure LoadFromStringList(strList: TStringList);
    procedure LoadFromString(const str: string);
    procedure LoadFromDisk;
    procedure SaveToDisk;
  public  //Manejo de columnas y exploración de filas
    Fields: array of TCibFieldInfo;
    items  : TCibRegistro_list;  //referencia a lista de registros
    function AddNewRecord: TCibRegistro; virtual; abstract;
    function FieldDefsAdd(AName: string; ADataType: TCibColType): integer;
    function TableHeader: string;
    function FindColPos(colName: string): integer;
    procedure First;
    procedure Next;
    function EOF: boolean;
  public
    msgUpdate  : string;  //Mensaje de actualziación
    property msjError: string read FmsjError write SetMsjError;  //Mensaje de error
    procedure SaveToString(out str: string);
//    function FindReg(str: string; idxCol: word): integer;
  public  //Eventos
    OnLogError : TEvProLogError;    //Requiere escribir un Msje de error en el registro
    OnDiskSaved: procedure of object;
    OnDiskRead : procedure of object;
    OnLoading  : procedure of object;
  public //Rutinas de modificación de la tabla
    {Estas rutinas deberían ser las únicas que, pueden realmente modificar el contenido
     de las tablas. Actualizan la bandera "MsgUpdate", con información de la
    actualización.}
    procedure UpdateFromDisk(showError: boolean=false);
    procedure UpdateAll(newData: string; showError: boolean=false);
  public  //Inicialización
    procedure SetCols(linHeader: string); virtual;
    procedure SetTable(archivo0: string); virtual;
    constructor Create; virtual;
    destructor Destroy; override;
  end;

  { TCibTablaHist }
  //Define a una tabla histórica. Más parecida a un archivo de registro.
  TCibTablaHist = class
  private
    function PLogEscr(identif: String; lin: String): integer;
    function NombDifArc(nomBase: String): String;
  public
    ArcLog   : string;      //Archivo de registro arctual (*.log)
    nSerV    : integer;     //número de serie de rergitro en "log"
    msjError : string;      //Mensaje de error. { TODO : Debería evitarse usar variables globales }
    //contadores internos
    CVniloter: double;      //valor del contador de Ventas de Ciberplex
    CIniloter: Double;      //valor del contador de Ingresos de CiberPlex
    function EscribReg(archivo: String; lin: String): string;
    function EscribReg(lin: String): string;
    procedure AbrirPLog(rutDatos, local, tabla: string);
    function PLogVenta(identif: char; mensaje : String; dCosto : Double): integer;
    function PLogIngre(identif: char; mensaje: String; dCosto: Double): integer;
    function PLogInf(usu, mensaje: String): integer;
    function PLogErr(usu, mensaje: string): integer;
  end;

implementation

{ TCibRegistro }
function TCibRegistro.GetValuesStr: string;
begin
  Result := join(#9, values);  //Habría que optimizar mejor esta rutina join()
end;
procedure TCibRegistro.SetValuesStr(AValue: string);
begin
  values := Explode(#9, AValue);  //Esta rutina Explode() se debe optimizr mejor
end;
{ TCibTablaMaest }
procedure TCibTablaMaest.SaveToString(out str: string);
{Guarda a disco}
var
  lineas: TStringList;
  i: Integer;
begin
  msjError := '';
  try
    try
      lineas := TStringList.Create;
      First;
      for i := 0 to items.Count-1 do begin
        lineas.Add(items[i].valuesStr);
        Next;
      end;
      str := lineas.Text;
    finally
      lineas.Destroy;
    end;
  except
    on e:Exception do begin
      msjError := 'Error grabando: ' + archivo + ' - ' + e.Message;
    end;
  end;
end;
procedure TCibTablaMaest.SetMsjError(AValue: string);
begin
  if FmsjError = AValue then exit;
  FmsjError:=AValue;
  if AValue = '' then exit;
  if OnLogError <> nil then OnLogError(FmsjError);
end;
procedure TCibTablaMaest.LoadFromStringList(strList: TStringList);
var
  linea, encab: string;
  reg: TCibRegistro;
  i : integer;
begin
  if strList.Count = 0 then begin
    msjError := 'No hay información de columnas';
    exit;
  end;
  items.Clear;
  i := 0;   //índice de registro
  encab := strList[0];  //Lee encabezado
  SetCols(encab);  //Puede generar error, pero deja seguir
  //Lee siguientes líneas
  for i := 1 to strList.Count-1 do begin
      linea := strList[i];
      if linea <> '' then begin  //tiene datos
          reg := AddNewRecord;
          items.Add(reg);
          //Carga campos en texto
          reg.valuesStr := linea;  //Esta rutina no está muy optimizada
          //actualiza contador y estado de carga
          if (i Mod 1000 = 0) and (OnLoading<>nil) then OnLoading;
      end;
  end;
end;
procedure TCibTablaMaest.LoadFromString(const str: string);
{Carga la tabla, con datos a partir de una cadena de texto.
Si encuentra error, devuelve una cadena con mensaje de error en "MsjError".}
var
  lineas: TStringList;
begin
  msjError := '';
  try
    lineas := TStringList.Create;
    lineas.Text:=str;   //carga líneas
    LoadFromStringList(lineas);
    //Puede salir con error.
    lineas.Destroy;
  except
    on e:Exception do begin
      msjError := 'Error cargando: ' + archivo + ' - ' + e.Message;
    end;
  end;
end;
procedure TCibTablaMaest.LoadFromDisk;
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con mensaje de error en "MsjError".}
var
  lineas: TStringList;
begin
consoleTickStart;
  msjError := '';
  if not FileExists(archivo) then begin
    msjError := 'No se encuentra archivo: ' + archivo;
    exit;
  end;
  try
    lineas := TStringList.Create;
    lineas.LoadFromFile(archivo);
    LoadFromStringList(lineas);
    lineas.Destroy;
  except
    on e:Exception do begin
      msjError := 'Error leyendo: ' + archivo + ' - ' + e.Message;
    end;
  end;
  if OnDiskRead<>nil then OnDiskRead();
consoleTickCount('--');
end;
procedure TCibTablaMaest.SaveToDisk;
{Escribe los datos en disco. Usa un archivo temporal para proteger los datos del archivo
original. Actualiza la bandera "msjError".}
var
  arc: TextFile;    //manejador de archivo
  tmp_produc , lin: string;
  i: integer;
begin
  msjError := '';
  //Abre archivo de entrada y salida
  try
    tmp_produc := archivo + '.tmp';
    AssignFile(arc, tmp_produc);
    rewrite(arc);
    //Escribe encabezado
    writeln(arc, TableHeader);
    First;
    for i := 0 to items.Count-1 do begin
//      writeLn(arc, RecToString);
      lin := items[i].valuesStr;
      writeln(arc, lin);
      Next;
    end;
    CloseFile(arc);
    //Actualiza archivo de productos
    DeleteFile(archivo);     //Borra anterior
    RenameFile(tmp_produc, archivo); //Renombra nuevo
    //CopyFile(tmp_produc, archivo);  //Mantiene la copia
  except
    on e: Exception do begin
      msjError := 'Error grabando: ' + archivo + ' - ' + e.Message;
      CloseFile(arc);
    end;
  end;
  if OnDiskSaved<>nil then OnDiskSaved();
end;
//function TCibTablaMaest.FindReg(str: string; idxCol: word): integer;
//{Busca dentro de un campo, un valor de cadena. Devuelve el índice.}
//begin
//  idx := 0;
//  while idx<items.Count do begin
//    if Fields[idxCol].OnGetStr() = str then exit(idx);
//    inc(idx);
//  end;
//  exit(-1);
//end;
function TCibTablaMaest.FieldDefsAdd(AName: string; ADataType: TCibColType): integer;
{Agrega una columna a la tabla. Devuelve el número de índice de la columna.}
var
  n: Integer;
begin
  n := high(Fields) + 1;  //Número de elementos
  setlength(Fields, n + 1);
  Fields[n].Name := AName;
  Fields[n].colType:= ADataType;
  Fields[n].idxCol:=n;  //para que sepa a qué número de campo representa
  Result := n;
end;
function TCibTablaMaest.TableHeader: string;
{Devuelve el encabezado a escribir en el archivo de la tabla}
var
  i: Integer;
  idColTyp: Char;
begin
  Result := '';
  for i:=0 to high(Fields) do begin
    case Fields[i].colType of
    ctText  : idColTyp := '0';
    ctFloat : idColTyp := '1';
    ctDatTim: idColTyp := '2';
    end;
    Result += '"' + Fields[i].Name + '",'+idColTyp + #9;
  end;
  //Quita tabulación final
  if Result<>'' then delete(Result, length(Result), 1);
end;
function TCibTablaMaest.FindColPos(colName: string): integer;
{Busca la posición de una columna en Fields[], por su nombre. Ignora mayúsculas/minúsculas.
Si no encuentra la columna, devuelve -1 y actualiza msjError.}
var
  i: Integer;
begin
  Result := -1;
  colName := UpCase(colName);
  for i:=0 to high(Fields) do begin
    if UpCase(Fields[i].Name) = colName then begin
        exit(i);
    end;
  end;
  msjError := 'Columna "' + colName + '" no existe.';
end;
procedure TCibTablaMaest.First;
begin
  idx := 0;
end;
procedure TCibTablaMaest.Next;
begin
  inc(idx);
end;
function TCibTablaMaest.EOF: boolean;
begin
  Result := idx >= items.Count;
end;
//Rutinas de modificación de la tabla
procedure TCibTablaMaest.UpdateFromDisk(showError: boolean = false);
{Esta actualización, lee todo el contenido desde archivo.
Actualiza "MsjError".}
begin
  LoadFromDisk;
  if msjError <> '' then begin
    msgUpdate := msjError;
    if showError then MsgErr(msjError);
  end else begin
    msgUpdate := 'Tabla ' + ExtractFileName(archivo) + ' actualizada íntegramente.' + LineEnding +
                 IntToStr(items.Count) + ' registros.';
  end;
end;
procedure TCibTablaMaest.UpdateAll(newData: string; showError: boolean = false);
{Se pide actualizar completamente la tabla, a partir de "newData".
Actualiza "MsjError".}
begin
  try
    StringToFile(newData, archivo);
  except
    msjError := 'Error de escritura en: ' + archivo;
    if showError then MsgErr(msjError);
    exit;
  end;
  UpdateFromDisk;
end;
procedure TCibTablaMaest.SetCols(linHeader: string);
{Lee información sobre los capos de la tabla.}
var
  c, colName: String;
  campos, a: TStringDynArray;
  colType: TCibColType;
begin
  //Lee primera línea de la tabla que debe tener información de los campos
  msjError := '';
  //Verifica validez de la línea de canpos
  if linHeader='' then begin
    msjError := 'Error leyendo información de columnas de: ' + archivo;
    exit;
  end;
  //Carga información de columnas
  setlength(fields, 0);
  campos := Explode(#9, linHeader);  //Esta rutina no está muy optimizada
  for c in campos do begin
    //Los campos vienen en la estructura "CAMPO1",0
    a := explode(',', c);
    if high(a)<>1 then begin
      msjError := 'Error leyendo información de columnas de: ' + archivo;
      exit;
    end;
    colName := copy(a[0],2,length(a[0])-2);
    case a[1] of
    '0': colType.:= ctText;
    '1': colType := ctFloat;
    '2': colType := ctDatTim;
    else
      msjError := 'Error leyendo información de columnas de: ' + archivo;
      exit;
    end;
    FieldDefsAdd(colName, colType);
  end;
end;
//Inicialización
procedure TCibTablaMaest.SetTable(archivo0: string);
{Asocia al TCibTabProduc, con un archivo  físico en disco.}
begin
  archivo := archivo0;  //guarda archivo de dónde se carga
end;
constructor TCibTablaMaest.Create;
begin
  setlength(Fields, 0);
end;
destructor TCibTablaMaest.Destroy;
begin
  if items<>nil then items.Destroy;
end;
{ TCibTablaHist }
function TCibTablaHist.NombDifArc(nomBase: String): String;
{Genera un nombre diferente de archivo, tomando el nombre dado como raiz.}
const MAX_ARCH = 10;
var i : Integer;    //Número de intentos con el nombre de archivo de salida
    cadBase : String;   //Cadena base del nombre base
    extArc: string;    //extensión

  function NombArchivo(i: integer): string;
  begin
    Result := cadBase + '-' + IntToStr(i) + extArc;
  end;

begin
   Result := nomBase;  //nombre por defecto
   extArc := ExtractFileExt(nomBase);
   if ExtractFilePath(nomBase) = '' then exit;  //protección
   //quita ruta y cambia extensión
   cadBase := ChangeFileExt(nomBase,'');
   //busca archivo libre
   for i := 0 to MAX_ARCH-1 do begin
      If not FileExists(NombArchivo(i)) then begin
        //Se encontró nombre libre
        Exit(NombArchivo(i));  //Sale con nombre
      end;
   end;
   //todos los nombres estaban ocupados. Sale con el mismo nombre
End;
function TCibTablaHist.EscribReg(archivo: String; lin: String): string;
{Escribe una línea en un archivo de registro. Si encuentra error, devuelve una cadena
con el mensaje.} { TODO : No se ha implementado, toda la protección que implementa NILOTER-m
en esta función }
var
  arc: TextFile;
begin
  {$IFDEF Windows}
    lin := UTF8ToCP1252(lin);
  {$ENDIF}
  try
    AssignFile(arc, archivo);
    Append(arc);
    writeLn(arc, lin);
    CloseFile(arc);
    Result := '';
  except
    Result := 'Error abriendo: ' + archivo;
    CloseFile(arc);
  end;
end;
function TCibTablaHist.EscribReg(lin: String): string;
{Versión corta que escribe directamente en "ArcLog"}
begin
  Result := EscribReg(ArcLog, lin);
end;

procedure TCibTablaHist.AbrirPLog(rutDatos, local, tabla: string);
{Actualiza "ArcLog", con el nombre actual del archivo al que se debe escribir.
Notar que si se cambia el local o la ruta de datos, se debe llamar nuevamente a este
procedimiento.}
var
  arc : TextFile;
  Attr: word;
  mes: String;
begin
  msjError := '';
  mes := FormatDateTime('yyyy_mm', now);  //año-mes
  ArcLog := rutDatos + '\' + local + '.' + mes + '.' + tabla + '.log';
  //Verifica disponibilidad de archivo
  try
    if FileExists(ArcLog) then begin   //ve si existe
      //Abre y cierra para probar si hay problemas
      AssignFile(arc, ArcLog);
      GetFAttr(arc, Attr);  //verifica atributos
      if (Attr and readonly)<>0 then begin
        msjError := 'El archivo de registro: ' + ArcLog + ' es de sólo lectura';
        exit;
      end;
      Append(arc);    //intenta abrir para agregar
      CloseFile(arc);
    end else begin
      //No existe aún, lo crea
      StringToFile('',ArcLog);
    end;
  except
    on E : Exception do
    begin
      msjError := 'Error accediendo a: ' + ArcLog + ' (' + E.Message + ')';
    end;
  end;
end;
function TCibTablaHist.PLogEscr(identif: String; lin: String): integer;
{Rutina básica de escritura en el registro del programa. Devuelve el número de serie
 escrito. Debe haberse llamado primero a AbrirPLog}
begin
  msjError := '';
  if ArcLog = '' then exit;
  EscribReg(ArcLog, identif + ':' + IntToStr(nSerV) + #9 +
                    FormatDateTime('yyyy/mm/dd hh:nn:ss', now) + #9 +
                    lin);
  Result := nSerV;    //devuelve el número de serie escrito
  inc(nSerV);   //incrementa número de serie
  if msjError <> '' Then begin
    //Error escribiendo archivo de ventas
    MsgErr('Error escribiendo en archivo de registro:' + msjError);
  end
end;
function TCibTablaHist.PLogVenta(identif: char; mensaje: String; dCosto: Double): integer;
{Escribe una línea de venta en el registro del programa. Se considera un registro de
venta, a aquel que puede incrementar "CVniloter".
"dCosto" es el incremento de costo para actualizar ingreso}
begin
    Result := PLogEscr(identif, mensaje);
    CVniloter := CVniloter + dCosto;  //actualiza venta
end;
function TCibTablaHist.PLogIngre(identif: char; mensaje: String; dCosto: Double): integer;
{Escribe una línea de ingreso en el registro del programa. Se considera un registro de
ingreso, a aquel que puede incrementar "CIniloter".
"dCosto" es el incremento de costo para actualizar ingreso}
begin
    Result := PLogEscr(identif, mensaje);
    CIniloter := CIniloter + dCosto;      //actualiza ingresos
end;
function TCibTablaHist.PLogInf(usu, mensaje: String): integer;
//Escribe una línea de información en el registro del programa.
begin
  PLogInf := PLogEscr(IDE_REG_INF, usu + #9+ mensaje);
end;
function TCibTablaHist.PLogErr(usu, mensaje: string): integer;
//Escribe una línea de error en el registro del programa. No modifica "MsjError"
var
  tmp: string;
begin
  tmp := msjError;  //salva mensaje de error
  //Escribe mensaje. Si hubo error, ya se ha mostrado com MsgBox()
  PLogErr := PLogEscr(IDE_REG_ERR, usu + #9+ mensaje);
  msjError := tmp;  //restaura
end;


end.

