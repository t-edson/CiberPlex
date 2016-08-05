{Unidad con rutinas útiles para el trabajo de Ciberplex.}
unit CPUtils;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, dateutils, Graphics, LCLType, LCLIntf, MisUtils;

  procedure PantallaAArchivo(arch: String);
  procedure Decodificar_M_ESTAD_CLI(cad: string; var nombrePC: string; var HoraPC: TDateTime;
    var bloqueado: boolean);
  function CodifActivCabina(Nombre: string; tSolic: Double; tLibre, horGra: boolean): string;
  procedure DecodActivCabina(cad: string; var Nombre: string; var tSolic: Double; var tLibre, horGra: boolean);

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
function CodifActivCabina(Nombre: string; tSolic: Double; tLibre, horGra: boolean): string;
begin
  Result := Nombre + #9 +
            D2f(tSolic)+ #9 +
            B2f(tLibre)+ #9 +
            B2f(horGra);
end;
procedure DecodActivCabina(cad: string; var Nombre: string; var tSolic: Double;
                           var tLibre, horGra: boolean);
var
  campos: TStringDynArray;
begin
  campos := Explode(#9, cad);
  if high(campos) < 3 then begin
    Nombre := '';
    exit;
  end;
  Nombre := campos[0];
  tSolic := f2D(campos[1]);
  tLibre := f2B(campos[2]);
  horGra := f2B(campos[3]);
end;

end.

