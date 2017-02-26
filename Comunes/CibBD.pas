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
  Classes, SysUtils, fgl;
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

  //Prototipo de registro para las tablas
  TCibRegistro = class
  public
    OnLogError     : TEvProLogError;   //Requiere escribir un Msje de error en el registro
    function ToString: String; virtual; abstract;
    procedure FromString(cad: String); virtual; abstract;
  end;
  TCibRegistro_list = specialize TFPGObjectList<TCibRegistro>;   //lista de ítems

  { TCibTabla }
  //Prototipo de tablas
  TCibTabla = class
  protected
    archivo : string;
    procedure AgregarItemText(txt: string); virtual; abstract;
    procedure SaveToDisk(items: TCibRegistro_list);
    procedure LoadFromDisk(items: TCibRegistro_list);
    procedure LoadFromString(items: TCibRegistro_list; str: string);
  public
    msjError   : string;
    OnDiskSaved: procedure of object;
    OnDiskRead : procedure of object;
    OnLogError : TEvProLogError;    //Requiere escribir un Msje de error en el registro
    OnLoading  : procedure of object;
    procedure FijarTabla(archivo0: string); virtual;
  end;

implementation

{ TCibTabla }
procedure TCibTabla.SaveToDisk(items: TCibRegistro_list);
{Escribe los datos en disco. Usa un archivo temporal para proteger los datos del archivo
original. Actualiza la bandera "msjError".}
var
  arc: TextFile;    //manejador de archivo
  reg: TCibRegistro;
  tmp_produc : string;
begin
  msjError := '';
  //Abre archivo de entrada y salida
  try
    tmp_produc := archivo + '.tmp';
    AssignFile(arc, tmp_produc);
    rewrite(arc);
    for reg in items do begin
      writeLn(arc, reg.ToString);
    end;
    CloseFile(arc);
    //Actualiza archivo de productos
    DeleteFile(archivo);     //Borra anterior
    RenameFile(tmp_produc, archivo); //Renombra nuevo
  except
    on e: Exception do begin
      msjError := 'Error actualizando productos: ' + e.Message;
      if OnLogError<>nil then OnLogError(msjError);
      CloseFile(arc);
    end;
  end;
  if OnDiskSaved<>nil then OnDiskSaved();
end;
procedure TCibTabla.LoadFromDisk(items: TCibRegistro_list);
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con mensaje de error en "MsjError".}
var
  narc: text;
  linea: String;
  n , nlin: Integer;        //Número de productos leidas
begin
  msjError := '';
  try
    AssignFile(narc , archivo);
    reset(narc);
    n := 1;
    nlin := 0;
    items.Clear;
    while not eof(narc) do begin
        nlin := nlin + 1;
        readln(narc, linea);
        if linea <> '' then begin  //tiene datos
            AgregarItemText(linea);
            //actualiza contador y estado de carga
            n := n + 1;
            if (n Mod 50 = 0) and (OnLoading<>nil) then OnLoading;
        end;
    end;
    Close(narc);
    exit;  //Puede salir con mensaje de error en "Result".
  except
    on e:Exception do begin
      msjError := 'Error leyendo: ' + archivo + ' - ' + e.Message;
      //Close(narc);  No cierra ya que si falló al abrir, (lo más común) genera error al intentar cerralo.
    end;
  end;
  if OnDiskRead<>nil then OnDiskRead();
end;
procedure TCibTabla.LoadFromString(items: TCibRegistro_list; str: string);
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con mensaje de error en "MsjError".}
var
  lineas: TStringList;
  linea: String;
  n , nlin: Integer;        //Número de productos leidos
begin
  msjError := '';
  try
    try
      lineas := TStringList.Create;
      lineas.Text:=str;   //carga líneas
      n := 1;
      nlin := 0;
      items.Clear;
      for linea in lineas do begin
          nlin := nlin + 1;
          if linea <> '' then begin  //tiene datos
              AgregarItemText(linea);
              //actualiza contador y estado de carga
              n := n + 1;
              if (n Mod 50 = 0) and (OnLoading<>nil) then OnLoading;
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
  if OnDiskRead<>nil then OnDiskRead();
end;
procedure TCibTabla.FijarTabla(archivo0: string);
{Asocia al TCibTabProduc, con un archivo  físico en disco}
begin
  archivo := archivo0;  //guarda archivo de dónde se carga
end;

end.

