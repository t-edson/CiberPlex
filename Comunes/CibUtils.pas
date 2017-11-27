{Unidad con rutinas útiles para el trabajo de Ciberplex.}
unit CibUtils;
{$mode objfpc}{$H+}
interface
uses
  Classes, windows, SysUtils, Types, dateutils, Graphics, LCLType, LCLIntf,
  Menus, Controls, Forms, ExtCtrls, StdCtrls, LCLProc, MisUtils,
  ShellApi, fpexprpars;

  procedure PantallaAArchivo(arch: String);
  procedure Decodificar_M_ESTAD_CLI(cad: string; out nombrePC: string; out HoraPC: TDateTime);
  function VerHasta(const cad: string; car: char; out Err: boolean): string;
  function ExtraerHasta(var cad: string; car: char; out Err: boolean): string;
  function EvaluarExp(txt: string; out Err: string): Double;
  //Funciones para control de menú
  procedure InicLlenadoAcciones(MenuPopup0: TPopupMenu );
  function MenuAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
  function AgregarAccion(var ordShortCut: integer; etiq: string;
                         accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
  function CreaYCargaImagen(arcPNG: string): TImage;
  function CargaPNG(imagList16, imagList32: TImageList; rut, nombPNG: string): integer;
  function ListarArchivos(): String;
  function ListarArchivosD(): string;
  Function CambiaDir(direct: string): Boolean;
  function RutaEscritorio(): string;
  procedure MensajeVisibles(lblNreg: TLabel; nReg, nVis: Integer; col: TColor = clBlack);

implementation
var  //variables para el lleado de acciones de facturables
  idxMenu: Integer;
  MenuPopup: TPopupMenu;
function CreaYCargaImagen(arcPNG: string): TImage;
{Crea un objeto TImage, y carga una archivo PNG en él. Devuelve la referencia.}
begin
  Result := TImage.Create(nil);
  if not FileExists(arcPNG) then exit;
  Result.Picture.LoadFromFile(arcPNG);
end;
function CargaPNG(imagList16, imagList32: TImageList; rut, nombPNG: string): integer;
{Carga archivos PNG, de 16 y 32 pixeles, a un TImageList. Al nombre de lso archivos
se les añadirá el sufijo "_16.png" y "_32.png", para obteenr el nombre final.
Devuelve el índice de la imagen cargada.}
begin
  if nombPNG = '' then exit(-1);   //protección
  Result := LoadPNGToImageList(imagList16, rut + nombPNG + '_16.png');
  Result := LoadPNGToImageList(imagList32, rut + nombPNG + '_32.png');
end;
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
procedure Decodificar_M_ESTAD_CLI(cad: string; out nombrePC: string; out HoraPC: TDateTime);
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
function EvaluarExp(txt: string; out Err: string): Double;
{Evalua una expresión matemática de tipo: 1+1, 2+3*5, ...
 Si Hay error, devuelve mensaje en en "Err".}
var
  FParser: TFPExpressionParser;
begin
  Err := '';
  FParser := TFPExpressionParser.Create(nil);
  try
    FParser.BuiltIns := [bcMath];
    FParser.Expression := txt;
    Result := ArgToFloat(FParser.Evaluate);
    FParser.Free;
  except
    Err := 'Error en expresión.';
    FParser.Free;
  end;
end;
procedure InicLlenadoAcciones(MenuPopup0: TPopupMenu);
{Se usa para empezar a llenar acciones sobre un menú PopUp}
begin
  idxMenu := MenuPopup0.Items.Count;   //empieza a agregar desde el final
  MenuPopup := MenuPopup0;
end;
function MenuAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
{Devuelve la referencia a un ítemd e menú, para poder agregarla a un menú.}
var
  nuevMen: TMenuItem;
begin
  nuevMen:= TMenuItem.Create(nil);
  nuevMen.Caption:=etiq;
  nuevMen.OnClick:=accion;
  nuevMen.ImageIndex:=id_icon;
  {Notar que la referencia "nuevMen", no ha sido destruida porque se supone que se usará
  para agregarla a un menú, de modo que será el propieo menú el encargado de destruirla.}
  Result := nuevMen;
end;
function AgregarAccion(var ordShortCut: integer; etiq: string;
                       accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
{Agrega una acción sobre el menú PopUp indicado. Debe llamarse desoués de llamar a
InicLlenadoAcciones. El ítem del menú se agrega, justo después del último ítem agregado.
Si "ordShortCut"<>-1 , se usa su valor para crear un atajo del teclado al menú, y se va
incrementando su valor. }
var
  mn: TMenuItem;
  atajo: String;
begin
  if (ordShortCut<>-1) and (ordShortCut<10) then begin
    atajo := '&' + IntToStr(ordShortCut) + '. ';  //crea atajo
    etiq := StringReplace(etiq,'&','', [rfReplaceAll]);  //quita los otros atajos
    inc(ordShortCut);   //incrmeenta
  end else begin
    atajo := '';
  end;
  mn := MenuAccion(atajo + etiq, accion, id_icon);
  MenuPopup.Items.Insert(idxMenu, mn);  //Agrega al inicio
  inc(idxMenu);
  Result := mn;
end;
function ListarArchivos(): string;
//Lista los directorios y archivos de la carpeta actual
var
  sPath, tmp: String;
  SR: TSearchRec;
begin
  tmp := '';
  sPath := GetCurrentDir;
  if sPath[Length(sPath)]<>'\' then sPath := sPath+'\';
  //Lee primero directorios
  if FindFirst(sPath+'*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Attr AND faDirectory) <> 0 then begin
        if (SR.Name = '.') or (SR.Name = '..') then continue;
        tmp := tmp + '[' + SR.Name + ']'  + LineEnding;
      end;
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
  //Lee archivos
  if FindFirst(sPath+'*.*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Attr AND faDirectory) = 0 then begin
        tmp := tmp + SR.Name + LineEnding;
      end;
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
  TrimEndLine(tmp);  //quita salto final
  Result := tmp;
end;
function ListarArchivosD(): string;
//Lista los directorios y archivos de la carpeta actual incluyendo tamaño y fecha.
var
  sPath, tmp: String;
  SR: TSearchRec;
begin
  tmp := '';
  sPath := GetCurrentDir;
  if sPath[Length(sPath)]<>'\' then sPath := sPath+'\';
  //Lee primero directorios
  if FindFirst(sPath+'*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Attr AND faDirectory) <> 0 then begin
        if (SR.Name = '.') or (SR.Name = '..') then continue;
        tmp := tmp + '[' + SR.Name + ']' + #9 + #9 + LineEnding;
      end;
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
  //Lee archivos
  if FindFirst(sPath+'*.*', faAnyFile, SR) = 0 then begin
    repeat
      if (SR.Attr AND faDirectory) = 0 then begin
        tmp := tmp + SR.Name + #9 + IntToStr(SR.Size) + #9 + IntToStr(SR.Time) + LineEnding;
      end;
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
  TrimEndLine(tmp);  //quita salto final
  Result := tmp;
end;
Function CambiaDir(direct: string): boolean;
//Mueve la ruta actual al directorio actual. Si lo logra devuelve TRUE
begin
  Result := SetCurrentDir(direct);
//    On Error GoTo errCMBD
//    If direct Like "?:*" Then
//        ChDrive Left(direct, 1)
//    End If
//    If direct <> "" Then
//        ChDir direct
//    End If
end;
function RutaEscritorio(): string;
//Devuelve la ruta del escritorio de Windows
var
  SFolder: LPITEMIDLIST;
  SpecialPath : Array[0..MAX_PATH] Of Char;
begin
  SHGetSpecialFolderLocation(Application.MainForm.Handle, CSIDL_DESKTOP, SFolder);
  SHGetPathFromIDList(SFolder, SpecialPath);
  Result := SpecialPath;
end;
procedure MensajeVisibles(lblNreg: TLabel; nReg, nVis: Integer; col: TColor = clBlack);
{Muestra un mensaje con los ítems visibles en una etiqueta.}
begin
  lblNreg.Font.Color:= col;
  if nVis = 0 then begin
    lblNreg.Caption := 'Sin registros visibles. ';
  end else if nVis = 1 then begin
    if nVis=nReg then begin
      lblNreg.Caption := '1 registro visible. ';
    end else begin
      lblNreg.Caption := '1 de ' + IntToStr(nReg) + ' registro visible. ';
    end;
  end else begin
    if nVis=nReg then begin
      lblNreg.Caption := IntToStr(nVis) + ' registros visibles. ';
    end else begin
      lblNreg.Caption := IntToStr(nVis) + ' de ' + IntToStr(nReg) + ' registros visibles. ';
    end;
  end;
end;

end.

