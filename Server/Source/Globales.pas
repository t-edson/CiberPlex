{
Unidad con declaraciones globales del proyecto.
}
unit Globales;
{$mode objfpc}{$H+}
interface
uses  Classes, SysUtils, dos, Forms,
      MisUtils, FormInicio;
const
  //VER_PROG = '0.2b';
  {$I ..\..\version.txt}
  NOM_PROG = 'CiberPlex Server';   //nombre de programa

var
   //Variables globales
   MsjError    : String;    //Bandera - Mensaje de error

   rutApp     : string;     //ruta de la aplicación (sin "\" final)
   rutTemp    : string;     //ruta de la carpeta de scripts (sin "\" final)
   rutDatos   : string;     //ruta de la carpeta de datos (sin "\" final)
   rutArchivos: string;     //ruta para descargar de archivos (sin "\" final)
   rutSonidos : string;     //ruta para los archivos de sonidos (sin "\" final)
   //archivos de configuración
   arcProduc : string;     //archivo de productos
   arcGastos : string;     //archivo de gastos
   //archivo de estado
   arcEstado : string;

   CVniloter: Double;      //valor del contador de Ventas del CiberPlex
   CVfec_act: TDateTime;   //Fecha de actualización del contador de ventas del CiberPlex
   CIfec_act: TDateTime;   //Fecha de actualización del contador de Ingresos del CiberPlex

procedure QuitarSaltoFinal(var cad: string);

implementation

procedure QuitarSaltoFinal(var cad: string);
{Verifica si la cadena incluye un salto de línea al final y de ser así, lo quita}
var
  lSalto: Integer;
begin
  lSalto := length(LineEnding);
  if length(cad)<lSalto then exit;  //no puede contener salto
  if RightStr(cad, lSalto) = LineEnding then begin
    //Contiene el salto
    delete(cad, length(cad)-lSalto +1 ,lSalto);
  end;
end;

initialization
  //inicia directorios de la aplicación
  rutApp :=  ExtractFilePath(Application.ExeName);
  rutApp :=  copy(rutApp, 1, length(rutApp)-1);  //no incluye el '\' final
  rutTemp := rutApp + '\temp';
  rutDatos := rutApp + '\datos';
  rutArchivos := rutApp + '\archivos';
  rutSonidos := rutApp + '\sonidos';
  //verifica existencia de carpetas de trabajo
  try
    if not DirectoryExists(rutTemp) then begin
      msgexc('No se encuentra carpeta: ' + rutTemp + '. Se creará.');
      CreateDir(rutTemp);
    end;
    if not DirectoryExists(rutDatos) then begin
      msgexc('No se encuentra carpeta: ' + rutDatos + '. Se creará.');
      CreateDir(rutDatos);
    end;
    if not DirectoryExists(rutArchivos) then begin
      msgexc('No se encuentra carpeta: ' + rutArchivos + '. Se creará.');
      CreateDir(rutArchivos);
    end;
    if not DirectoryExists(rutSonidos) then begin
      msgexc('No se encuentra carpeta: ' + rutSonidos + '. Se creará.');
      CreateDir(rutSonidos);
    end;
  except
    msgErr('Error. No se puede leer o crear directorios.');
  end;
  //inicia archivos de configuración
  arcProduc := rutApp + '\productos.txt';    //archivo de productos
  arcGastos := rutApp + '\gastos.txt';       //archivo de gastos
  arcEstado := rutApp + '\estado.ini';         //archivo de estado

finalization
  //Por algún motivo, la unidad HeapTrc indica que hay gotera de memoria si no se liberan
  //estas cadenas:
  rutApp :=  '';
  rutDatos := '';
  rutTemp := '';
  rutArchivos := '';
  rutSonidos := '';

  arcProduc := '';
  arcGastos := '';
  arcEstado := '';
end.

