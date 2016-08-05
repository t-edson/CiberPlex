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

   rutApp     : string;     //ruta de la aplicación
   rutTemp    : string;     //ruta de la carpeta de scripts
   rutDatos   : string;     //ruta de la carpeta de datos
   rutArchivos: string;     //ruta para descargar de archivos
   //archivos de configuración
   arcProduc : string;     //archivo de productos
   arcGastos : string;     //archivo de gastos
   arcTarifas: string;     //archivo de tarifas
   arcRutas  : string;     //archivo de rutas
   //archivo de estado
   arcEstado : string;

   CVniloter: Double;      //valor del contador de Ventas del CiberPlex
   CVfec_act: TDateTime;   //Fecha de actualización del contador de ventas del CiberPlex
   CIfec_act: TDateTime;   //Fecha de actualización del contador de Ingresos del CiberPlex

implementation


initialization
  //inicia directorios de la aplicación
  rutApp :=  ExtractFilePath(Application.ExeName);
  rutApp :=  copy(rutApp, 1, length(rutApp)-1);  //no incluye el '\' final
  rutTemp := rutApp + '\temp';
  rutDatos := rutApp + '\datos';
  rutArchivos := rutApp + '\archivos';
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
{    if not FileExists(rutApp+'plink.exe') then begin
      msgErr('No se encuentra archivo plink.exe');
    end;}
  except
    msgErr('Error. No se puede leer o crear directorios.');
  end;
  //inicia archivos de configuración
  arcProduc := rutApp + '\productos.txt';    //archivo de productos
  arcGastos := rutApp + '\gastos.txt';       //archivo de gastos
  arcTarifas := rutApp + '\tarifario.txt';   //archivo de tarifas
  arcRutas := rutApp + '\rutas.txt';         //archivo de rutas
  arcEstado := rutApp + '\estado.ini';         //archivo de estado

finalization
  //Por algún motivo, la unidad HeapTrc indica que hay gotera de memoria si no se liberan
  //estas cadenas:
  rutApp :=  '';
  rutDatos := '';
  rutTemp := '';
  rutArchivos := '';

  arcProduc := '';
  arcGastos := '';
  arcTarifas := '';
  arcRutas := '';
  arcEstado := '';
end.

