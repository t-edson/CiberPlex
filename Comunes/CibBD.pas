{Unidad que almacena las definiciones y rutinas de la base de datos.
Esta unidad sería lo más cercano a un manejador de Base de datos.
No se usa una base de datos estándar porque no se encontró ninguna que cumpliera con
los requerimientos de la aplicación:
* Embebida, sin dependencias externas.
* Portable, sin necesidad de instalación.
* Multiplataforma.
* Ligera, con tablas de peqeuño tamaño.
* Capaz de particionar sus archivos históricos en periodos de meses.
* Segura, en el sentido de evitar pérdidas de datos.
* Capaz de separar sus tablas en archivos independientes pra mandarlos pro la red.
* Posibilidad de cambiar el orden de las filas alamcenadas en las tablas (sin necesidad
de usar índices), debido a que se requiere que las consultas arrojen resultados en un
orden específico.

Además la idea de la base de datos, del servidor es que sea solo una base de datos local,
ya que la base de datos Central, debería estar en la nube.
Sin embargo, sería posible usar alguna otra base de datos, sacrificando alguna de las
funcionalidades.
De las que se evaluó, la que más se adaptaba era probablemente FoxPro (el formato de
tablas), solo que no es fácil cambiar el orden en que aparecen los resultados de las
consultas, y he visto problemas de pérdida de información,  además FoxPoo o Visual
FoxPro, ya es anticuada.
}
unit CibBD;
{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, fgl, Types, LCLProc, LConvEncoding, MisUtils;
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
  //Evento para resgitrar un mensje de error
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
  private
    function GetAsString: string;
    procedure SetAsString(AValue: string);
    function GetAsFloat: double;
    procedure SetAsFloat(AValue: double);
    function GetAsDatTim: Double;
    procedure SetAsDatTim(AValue: Double);
  public
    OnGetStr: TCibEvGetStr;   //Evento para pedir un valor String
    OnSetStr: TCibEvSetStr;   //Evento para fijar un valor String
    OnGetFloat: TCibEvGetFloat;   //Evento para pedir un valor Float
    OnSetFloat: TCibEvSetFloat;   //Evento para fijar un valor Float
    OnGetDatTim: TCibEvGetDatTim;   //Evento para pedir un valor fecha
    OnSetDatTim: TCibEvSetDatTim;   //Evento para fijar un valor fecha
    property AsString: string read GetAsString write SetAsString;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsDatTim: Double read GetAsDatTim write SetAsDatTim;
  end;

  { TCibRegistro }
  TCibRegistro = class
  public
    OnLogError     : TEvProLogError;   //Requiere escribir un Msje de error en el registro
  end;
  TCibRegistro_list = specialize TFPGObjectList<TCibRegistro>;   //lista de ítems

  { TCibTabla }
  //Prototipo de tablas
  TCibTabla = class
  private
    FmsjError: string;
    procedure SetmsjError(AValue: string);
  protected
    archivo : string;
    idx : integer;   //posición actual
    items: TCibRegistro_list;  //referecnia a lista de registros
    function AddNewRecord: TCibRegistro; virtual; abstract;
    //Rutinas de modificación de bajo nivel. Protegidas
    procedure LoadFromDisk;
    procedure SaveToDisk;
    procedure LoadFromString(const str: string);
    function RecToString: string;   //Tal vez se deba usar "Stream" u optimizarse de otra forma.
    procedure StringToRec(AValue: string);
  public  //Manejo de columnas y exploración de filas
    Fields: array of TCibFieldInfo;
    function FieldDefsAdd(AName: string; ADataType: TCibColType): integer;
    function FieldAddStr(AName: string; procGet: TCibEvGetStr; procSet: TCibEvSetStr
      ): integer;
    function FieldAddFlt(AName: string; procGet: TCibEvGetFloat; procSet: TCibEvSetFloat
      ): integer;
    function FieldAddDatTim(AName: string; procGet: TCibEvGetDatTim; procSet: TCibEvSetDatTim
      ): integer;
    procedure First;
    procedure Next;
    function EOF: boolean;
  public
    msgUpdate  : string;  //Mensaje de actualziación
    property msjError: string read FmsjError write SetmsjError;  //Mensaje de error
    procedure SaveToString(out str: string);
    function FindReg(str: string; idxCol: word): integer;
  public  //Eventos
    OnLogError : TEvProLogError;    //Requiere escribir un Msje de error en el registro
    OnDiskSaved: procedure of object;
    OnDiskRead : procedure of object;
    OnLoading  : procedure of object;
  public //Rutinas de modificación de la tabla
    {Estas rutinas deberían ser las únicas que, pueden realmente modificar el contenido
     de las tablas. Actualizan la bandera "MsgUpdate", con infromación de la
    actualización.}
    procedure UpdateFromDisk(showError: boolean=false);
    procedure UpdateAll(newData: string; showError: boolean=false);
  public  //Inicialización
    procedure SetTable(archivo0: string);
    constructor Create; virtual;
    destructor Destroy; override;
  end;

implementation

{ TCibFieldInfo }
function TCibFieldInfo.GetAsString: string;
begin
  Result := OnGetStr();
end;
procedure TCibFieldInfo.SetAsString(AValue: string);
begin
  OnSetStr(AValue);
end;
function TCibFieldInfo.GetAsFloat: double;
begin
  Result := OnGetFloat();
end;
procedure TCibFieldInfo.SetAsFloat(AValue: double);
begin
  OnSetFloat(AValue);
end;
function TCibFieldInfo.GetAsDatTim: Double;
begin
  Result := OnGetDatTim();
end;
procedure TCibFieldInfo.SetAsDatTim(AValue: Double);
begin
  OnSetDatTim(AValue);
end;

{ TCibTabla }
procedure TCibTabla.SaveToDisk;
{Escribe los datos en disco. Usa un archivo temporal para proteger los datos del archivo
original. Actualiza la bandera "msjError".}
var
  arc: TextFile;    //manejador de archivo
  tmp_produc : string;
  i: integer;
begin
  msjError := '';
  //Abre archivo de entrada y salida
  try
    tmp_produc := archivo + '.tmp';
    AssignFile(arc, tmp_produc);
    rewrite(arc);
    First;
    for i := 0 to items.Count-1 do begin
      writeLn(arc, RecToString);
      Next;
    end;
    CloseFile(arc);
    //Actualiza archivo de productos
    DeleteFile(archivo);     //Borra anterior
    RenameFile(tmp_produc, archivo); //Renombra nuevo
  except
    on e: Exception do begin
      msjError := 'Error grabando: ' + archivo + ' - ' + e.Message;
      CloseFile(arc);
    end;
  end;
  if OnDiskSaved<>nil then OnDiskSaved();
end;
procedure TCibTabla.SaveToString(out str: string);
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
        lineas.Add(RecToString);
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

procedure TCibTabla.SetmsjError(AValue: string);
begin
  if FmsjError = AValue then exit;
  FmsjError:=AValue;
  if AValue = '' then exit;
  if OnLogError <> nil then OnLogError(FmsjError);
end;

procedure TCibTabla.LoadFromDisk;
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con mensaje de error en "MsjError".}
var
  narc: text;
  linea: String;
begin
consoleTickStart;
  msjError := '';
  if not FileExists(archivo) then begin
    msjError := 'No se encuentra archivo: ' + archivo;
    exit;
  end;
  try
    AssignFile(narc , archivo);
    reset(narc);
    try
      idx := 0;   //índice de registro
      items.Clear;
      while not System.EOF(narc) do begin
        readln(narc, linea);
        if trim(linea) <> '' then begin  //tiene datos
//            AgregarItemText(linea);
            items.Add(AddNewRecord);
            StringToRec(linea);  //actualiza en "idx"
            //Aprovechamos para generar evento
            idx := idx+ 1;
            if (idx Mod 1000 = 0) and (OnLoading<>nil) then OnLoading;
        end;
      end;
    finally
      Close(narc);
    end;
  except
    on e:Exception do begin
      msjError := 'Error leyendo: ' + archivo + ' - ' + e.Message;
    end;
  end;
  if OnDiskRead<>nil then OnDiskRead();
consoleTickCount('--');
end;
procedure TCibTabla.LoadFromString(const str: string);
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con mensaje de error en "MsjError".}
var
  lineas: TStringList;
  linea: String;
begin
  msjError := '';
  try
    try
      lineas := TStringList.Create;
      lineas.Text:=str;   //carga líneas
      idx := 0;
      items.Clear;
      for linea in lineas do begin
          if linea <> '' then begin  //tiene datos
//              AgregarItemText(linea);
              items.Add(AddNewRecord);
              StringToRec(linea);  //actualzia en "idx"
              //actualiza contador y estado de carga
              idx := idx + 1;
              if (idx Mod 1000 = 0) and (OnLoading<>nil) then OnLoading;
          end;
      end;
    finally
      lineas.Destroy;
    end;
  except
    on e:Exception do begin
      msjError := 'Error cargando: ' + archivo + ' - ' + e.Message;
    end;
  end;
end;
function TCibTabla.FindReg(str: string; idxCol: word): integer;
{Busca dentro de un campo, un valor de cadena. Devuelve el índice.}
begin
  idx := 0;
  while idx<items.Count do begin
    if Fields[idxCol].OnGetStr() = str then exit(idx);
    inc(idx);
  end;
  exit(-1);
end;
function TCibTabla.FieldDefsAdd(AName: string; ADataType: TCibColType): integer;
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
function TCibTabla.FieldAddStr(AName: string; procGet: TCibEvGetStr;
  procSet: TCibEvSetStr): integer;
{Agrega un campo, de tipo STring}
begin
  Result := FieldDefsAdd(AName, ctText);
  Fields[Result].OnGetStr:=procGet;
  Fields[Result].OnSetStr:=procSet;
end;
function TCibTabla.FieldAddFlt(AName: string; procGet: TCibEvGetFloat;
  procSet: TCibEvSetFloat): integer;
{Agrega un campo, de tipo Float}
begin
  Result := FieldDefsAdd(AName, ctFloat);
  Fields[Result].OnGetFloat:=procGet;
  Fields[Result].OnSetFloat:=procSet;
end;
function TCibTabla.FieldAddDatTim(AName: string; procGet: TCibEvGetDatTim;
  procSet: TCibEvSetDatTim): integer;
begin
  Result := FieldDefsAdd(AName, ctDatTim);
  Fields[Result].OnGetDatTim:=procGet;
  Fields[Result].OnSetDatTim:=procSet;
end;
procedure TCibTabla.First;
begin
  idx := 0;
end;
procedure TCibTabla.Next;
begin
  inc(idx);
end;
function TCibTabla.EOF: boolean;
begin
  Result := idx >= items.Count;
end;
function TCibTabla.RecToString: string;
{Convierte el registro actual a una representación de cadena.
Incluye siempre un delimitador al final. Esto es por tres motivos:
1. Porque es más fácil hacerlo así.
2. Porque no estorba.
3. Porque facilita cuando se quiere agregar un campos más. }
var
  c: Integer;
  colStr: string;
begin
  Result := '';
  for c := 0 to High(Fields) do begin
    case Fields[c].colType of
    ctText: begin
      colStr := UTF8ToCP1252(Fields[c].OnGetStr());  {Se podría guardar y leer
       directamente sin convertir, aunque no se ha detectado deterioro en el rendimiento.}
      colStr := StringReplace(colStr, #10, #2, [rfReplaceAll]);
      colStr := StringReplace(colStr, #13, #3, [rfReplaceAll]);
    end;
    ctFloat:  colStr := N2f(Fields[c].OnGetFloat());
    ctDatTim: colStr := D2f(Fields[c].OnGetDatTim());
    end;
    Result := Result + colStr + #9;
  end;
end;
procedure TCibTabla.StringToRec(AValue: string);
{Actualiza el registro actual, con el valor de una cadena. Es complementario a
RecToString().}
var
  c: Integer;
  a: TStringDynArray;
  tmp: String;
begin
  a := Explode(#9, AValue);
  for c := 0 to High(Fields) do begin
    case Fields[c].colType of
    ctText  : begin
      tmp := CP1252ToUTF8(a[c]);
      tmp := StringReplace(tmp, #2, #10, [rfReplaceAll]);
      tmp := StringReplace(tmp, #3, #13, [rfReplaceAll]);
      Fields[c].OnSetStr(tmp );
    end;
    ctFloat : Fields[c].OnSetFloat(f2N(a[c]));
    ctDatTim: Fields[c].OnSetDatTim(f2D(a[c]));
    end;
  end;
end;
//Rutinas de modificación de la tabla
procedure TCibTabla.UpdateFromDisk(showError: boolean = false);
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
procedure TCibTabla.UpdateAll(newData: string; showError: boolean = false);
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
//Inicialización
procedure TCibTabla.SetTable(archivo0: string);
{Asocia al TCibTabProduc, con un archivo  físico en disco}
begin
  archivo := archivo0;  //guarda archivo de dónde se carga
end;
constructor TCibTabla.Create;
begin
  setlength(Fields, 0);
end;
destructor TCibTabla.Destroy;
begin
  if items<>nil then items.Destroy;
end;

end.

