{Unidad con funciones para manejo el manejo de los archivos de registros}
unit CibRegistros;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, dos, MisUtils, CibFacturables;
type

  { TCibArcReg }
  //Define a un archivo de registro
  TCibArcReg = class
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
    Function NombFinal(camino : string; nom_loc: string; extension : String): String;
    function EscribReg(archivo: String; lin: String): string;
    procedure AbrirPLog(rutDatos, local: string);
    function PLogVenta(identif: char; mensaje : String; dCosto : Double): integer;
    function PLogIngre(identif: char; mensaje: String; dCosto: Double): integer;
    function PLogInf(usu, mensaje: String): integer;
    function PLogErr(usu, mensaje: string): integer;
  end;

implementation

function TCibArcReg.NombDifArc(nomBase: String): String;
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
Function TCibArcReg.NombFinal(camino : string; nom_loc: string; extension : String): String;
{Devuelve el nombre final con el que se genera un archivo de registro.
El nombre final depende del mes actual y del local.
También se verifica si es accesible el archivo para escritura.
Si hay problemas se devolverá el error en la variable "MsjError"}
var
  mes : String;
  arc : TextFile;
  tmp : String;
  Attr: word;
begin
    msjError := '';
    mes := FormatDateTime('_yyyy_mm', now);  //año-mes
    tmp := camino + '\' + nom_loc + mes + extension;
    //Verifica disponibilidad de archivo
    try
      if FileExists(tmp) then begin   //ve si existe
        //Abre y cierra para probar si hay problemas
        AssignFile(arc, tmp);
        GetFAttr(arc, Attr);  //verifica atributos
        if (Attr and readonly)<>0 then begin
          msjError := 'El archivo de registro: ' + tmp + ' es de sólo lectura';
          exit;
        end;
        Append(arc);    //intenta abrir para agregar
        CloseFile(arc);
      end else begin
        //No existe aún, lo crea
        StringToFile('',tmp);
      end;
      //toma el nombre final y sale
      NombFinal := tmp;
    except
      on E : Exception do
      begin
        msjError := 'Error accediendo a: ' + tmp + ' (' + E.Message + ')';
      end;
    end;
end;
function TCibArcReg.EscribReg(archivo: String; lin: String): string;
{Escribe una línea en un archivo de registro. Si encuentra error, devuelve una cadena
con el mensaje.} { TODO : No se ha implementado, toda la protección que implementa NILOTER-m
en esta función }
var
  arc: TextFile;
begin
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
procedure TCibArcReg.AbrirPLog(rutDatos, local: string);
{Notar que si se cambia el local o la ruta de datos, se debe llamar nuevamente a este
procedimiento. }
begin
  ArcLog := NombFinal(rutDatos, local + '.0', '.log');
  // Esta operación es crítica, para la aplicación
  If msjError <> '' then exit;
end;
Function TCibArcReg.PLogEscr(identif: String; lin: String): integer;
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
function TCibArcReg.PLogVenta(identif: char; mensaje: String; dCosto: Double): integer;
{Escribe una línea de venta en el registro del programa. Se considera un registro de
venta, a aquel que puede incrementar "CVniloter".
"dCosto" es el incremento de costo para actualizar ingreso}
begin
    Result := PLogEscr(identif, mensaje);
    CVniloter := CVniloter + dCosto;  //actualiza venta
end;
function TCibArcReg.PLogIngre(identif: char; mensaje: String; dCosto: Double): integer;
{Escribe una línea de ingreso en el registro del programa. Se considera un registro de
ingreso, a aquel que puede incrementar "CIniloter".
"dCosto" es el incremento de costo para actualizar ingreso}
begin
    Result := PLogEscr(identif, mensaje);
    CIniloter := CIniloter + dCosto;      //actualiza ingresos
end;
function TCibArcReg.PLogInf(usu, mensaje: string): integer;
//Escribe una línea de información en el registro del programa.
begin
  PLogInf := PLogEscr(IDE_REG_INF, usu + #9+ mensaje);
end;
function TCibArcReg.PLogErr(usu, mensaje: string): integer;
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

