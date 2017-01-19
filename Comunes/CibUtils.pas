{Unidad con rutinas útiles para el trabajo de Ciberplex.}
unit CibUtils;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, dateutils, Graphics, LCLType, LCLIntf, Menus,
  MisUtils;

  procedure PantallaAArchivo(arch: String);
  procedure Decodificar_M_ESTAD_CLI(cad: string; var nombrePC: string; var HoraPC: TDateTime;
    var bloqueado: boolean);
  function VerHasta(const cad: string; car: char; out Err: boolean): string;
  function ExtraerHasta(var cad: string; car: char; out Err: boolean): string;
  function MenuAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;

implementation
procedure PantallaAArchivo(arch: String);
//Captura el contenido de la pantalla, y lo guarda en el archivo indicado
var
  bmp: TBitmap;
  ScreenDC: HDC;
  jpg: TJPEGImage;
begin
  //arch := ExtractFilePath(Application.ExeName) + '~00.tmp';
  bmp := TBitmap.Create;
  jpg := TJpegImage.Create;   //para manejar archivo de JPG
  ScreenDC := GetDC(0);
  bmp.LoadFromDevice(ScreenDC);
  jpg.Assign(bmp);
  jpg.SaveToFile(arch);
//  bmp.SaveToFile('d:\abc.bmp');
  ReleaseDC(0,ScreenDC);
  jpg.Free;
  bmp.Free;
end;
procedure Decodificar_M_ESTAD_CLI(cad: string; var nombrePC: string; var HoraPC: TDateTime;
  var bloqueado: boolean);
var
  a: TStringDynArray;
  fec: string;
  yy, mm, dd, hh, nn, ss: word;
begin
  a := Explode(#9, cad);
  nombrePC := a[0];
  fec := a[2];
  yy := StrToInt(copy(fec,1,4));
  mm := StrToInt(copy(fec,5,2));
  dd := StrToInt(copy(fec,7,2));
  hh := StrToInt(copy(fec,9,2));
  nn := StrToInt(copy(fec,11,2));
  ss := StrToInt(copy(fec,13,2));
  HoraPC := EncodeDateTime(yy, mm, dd, hh, nn, ss, 0);
  if a[5] = '0' then bloqueado:=false else bloqueado:=true;
end;

function VerHasta(const cad: string; car: char; out Err: boolean): string;
{Extrae una parte de una cadena, hasta encontrar el delimitador "car" , o hasta el final
de la cadena. Si no encuentra el delimitador devuelve Err con TRUE.}
var
  p: SizeInt;
begin
  Err := false;
  p := Pos(car, cad);
  if p=0 then begin
    //no encontró delimitador
    Result := cad;  //toma hasta el final
    Err := true;
    exit;
  end;
  //Si encontró delimitador
  Result := copy(cad, 1, p-1);  //toma hasta el final
  Err := false;
end;
function ExtraerHasta(var cad: string; car: char; out Err: boolean): string;
{Extrae una parte de una cadena, hasta encontrar el delimitador "car" , o hasta el final
de la cadena. Si no encuentra el delimitador devuelve Err con TRUE.}
var
  p: SizeInt;
begin
  Err := false;
  p := Pos(car, cad);
  if p=0 then begin
    //no encontró delimitador
    Result := cad;  //toma hasta el final
    cad := '';      //limpira cadena
    Err := true;
    exit;
  end;
  //Si encontró delimitador
  Result := copy(cad, 1, p-1);  //toma hasta el final
  delete(cad, 1, p);    //extrae
  Err := false;
end;

function MenuAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
{Devuelve la referencia a un ítemd e menú, para poder agregarla a un menú.}
var
  nuevMen: TMenuItem;
begin
  nuevMen:= TMenuItem.Create(nil);
  nuevMen.Caption:=etiq;
  nuevMen.OnClick:=accion;
  {Notar que la referencia "nuevMen", no ha sido destruida porque se supone que se usará
  para agregarla a un menú, de modo que será el propieo menú el encargdao de destruirla.}
  Result := nuevMen;
end;

end.

