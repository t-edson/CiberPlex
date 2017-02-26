{Unidad con rutinas útiles para el trabajo de Ciberplex.}
unit CibUtils;
{$mode objfpc}{$H+}
interface
uses
  Classes, windows, SysUtils, Types, dateutils, Graphics, LCLType, LCLIntf,
  Menus, Controls, Forms, ExtCtrls, StdCtrls, Grids, LCLProc, MisUtils,
  ShellApi, UtilsGrilla, BasicGrilla;

type
  //Evento que genera el fin de la edición de una celda
  TEvSalida = (
    evsNulo,       //USado para cancelar el fin de la edición
    evsTecEnter,   //sale por tecla <Enter>
    evsTecTab,     //sale por tecla <Tab>
    evsTecDer,    //Direccional derecha
    evsTecEscape,  //sale por tecla <Escape>
    evsEnfoque     //sale porque se pierde el enfoque
  );

  TEvIniEditarCelda = procedure(col, fil: integer; txtInic: string) of object;
  TEvFinEditarCelda = procedure(var eveSal:TEvSalida; col, fil: integer;
                                ValorAnter, ValorNuev: string) of object;
  TEvLeerColorFondo = function(col, fil: integer): TColor of object;

  { TGrillaEdic }
  {Define a una grilla de tipo "TUtilGrillaFil" que facilita la edición de los campos
  de la grilla asociada. Esta clase maneja un TEdit, como control para la edición del
  contenido de una celda, permitiendo cancelar la edición (sin modificar la celda),
  pulsando simplemente <Escape>. También se incluye un control de lista, para que pueda
  servir a modo de menú contextual, al momento de realizar la edición de la celda.
  Para interactuar con al edición, se incluyen los eventos:
   * OnIniEditarCelda;
   * OnFinEditarCelda;
  TGrillaEdic, no usa las opciones de edición, de TStringGRid (con los eventos
  OnGetEditText y OnEditingDone), sino que implementa sus propias rutinas de edición.
  Se diseño así porque se ha detectado muchos porblemas en las rutinas
  OnGetEditText() y OnEditingDone() de TStringGrid, como que sus parámetros no son
  apropiados y sobre todo, que se generan llamadas múltiples a estos eventos, cuando se
  usaba EditingDone().
  }
  TGrillaEdic = class(TUtilGrilla)
  private
    ColClick, RowClick: Longint;
    colIniCelda, filIniCelda: Integer;
    procedure edGrillaExit(Sender: TObject);
    procedure grillaSelection(Sender: TObject; aCol, aRow: Integer);
    procedure UbicarControles(r: TRect);
  protected
    edGrilla : TEdit;  //Editor para los campos de tipo texto
    lstGrilla: TListBox;  //Lista para la selección de valores
    valIniCelda: string;
    procedure edGrillaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure edGrillaKeyPress(Sender: TObject; var Key: char);
    procedure grillaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure grillaKeyPress(Sender: TObject; var Key: char); override;
    procedure grillaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure grillaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
  public
    OnIniEditarCelda : TEvIniEditarCelda;  //Inicia la edición de una celda
    OnFinEditarCelda : TEvFinEditarCelda;  //Finaliza la edición de una celda
    procedure IniciarEdicion(txtInic: string); virtual;
    procedure TerminarEdicion(eventSalida: TEvSalida; ValorAnter, ValorNuev: string
      ); virtual;
    function EnEdicion: boolean;
    procedure NumerarFilas;
    procedure ValidaFilaGrilla(f: integer);
  public //Inicialización
    constructor Create(grilla0: TStringGrid); override;
    destructor Destroy; override;
  end;

  { TGrillaEdicFor }
  {Agrega a TGrillaEdic capacidades para colorear las filas, en base a una condición
   de alguna(s) celdas.}
  TGrillaEdicFor = class(TGrillaEdic)
  private
    FOpSelMultiFila: boolean;
    procedure DibCeldaIcono(aCol, aRow: Integer; const aRect: TRect);
    procedure DibCeldaTexto(aCol, aRow: Integer; const aRect: TRect);
    procedure DibCeldaTextoEncab(aCol, aRow: Integer; const aRect: TRect);
    function EsFilaSeleccionada(const f: integer): boolean;
    procedure grillaDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure SetOpSelMultiFila(AValue: boolean);
  public
    ImageList: TImageList;   //referecnia a un TInageList, para los íconos
    OnLeerColorFondo: TEvLeerColorFondo;
    property OpSelMultiFila: boolean  //activa el dimensionamiento de columnas
             read FOpSelMultiFila write SetOpSelMultiFila;
    constructor Create(grilla0: TStringGrid); override;
  end;

  procedure PantallaAArchivo(arch: String);
  procedure Decodificar_M_ESTAD_CLI(cad: string; out nombrePC: string; out HoraPC: TDateTime);
  function VerHasta(const cad: string; car: char; out Err: boolean): string;
  function ExtraerHasta(var cad: string; car: char; out Err: boolean): string;
  //Funciones para control de menú
  procedure InicLlenadoAcciones(MenuPopup0: TPopupMenu );
  function MenuAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
  function AgregarAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
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
function AgregarAccion(etiq: string; accion: TNotifyEvent; id_icon: integer = -1): TMenuItem;
{Agrega una acción sobre el menú PopUp indicado. Debe llamarse desoués de llamar a
InicLlenadoAcciones. El ítem del menú se agrega, justo después del último ítem agregado.}
var
  mn: TMenuItem;
begin
  mn := MenuAccion(etiq, accion, id_icon);
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

{ TGrillaEdic }
procedure TGrillaEdic.UbicarControles(r: TRect);
begin
  //Ubica editor
  edGrilla.Left   := grilla.Left + r.left + 1;
  edGrilla.Top    := grilla.Top + r.Top + 1;
  edGrilla.Width  := r.Right - r.Left;;
  edGrilla.Visible:= true;
  //Ubica lista, por si se le desse usar
  lstGrilla.Left := edGrilla.Left;
  lstGrilla.Top := edGrilla.Top+ edGrilla.Height;
  lstGrilla.Width := r.Right - r.Left + 50;
  lstGrilla.Height := 120; //r.Bottom - r.Top;
end;
procedure TGrillaEdic.edGrillaKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #27 then begin
    TerminarEdicion(evsTecEscape, valIniCelda, edGrilla.Text);   //termina edición
  end else if Key = #13 then begin
//    Key := #0;
    TerminarEdicion(evsTecEnter, valIniCelda, edGrilla.Text);   //termina edición
  end;
end;
procedure TGrillaEdic.edGrillaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_TAB then begin
    TerminarEdicion(evsTecTab, valIniCelda, edGrilla.Text);   //termina edición
  end;
  if Key = VK_RIGHT then begin
    if edGrilla.SelStart = length(edGrilla.Text) then begin
      TerminarEdicion(evsTecDer, valIniCelda, edGrilla.Text);   //termina edición
    end;
  end;
end;
procedure TGrillaEdic.edGrillaExit(Sender: TObject);
begin
  {En general, el enfoque se puede perder por diversos motivos, pero lo más común
   es que se haya hecho "click" en alguna otra parte de la grilla. }
  TerminarEdicion(evsEnfoque, valIniCelda, edGrilla.Text);   //termina edición
end;
procedure TGrillaEdic.grillaSelection(Sender: TObject; aCol, aRow: Integer);
begin
  if not EnEdicion then exit;  //no está en modo edición
  TerminarEdicion(evsTecEscape, valIniCelda, edGrilla.Text);   //termina edición
end;
procedure TGrillaEdic.IniciarEdicion(txtInic: string);
{Inicia la edición del valor de una celda}
begin
debugln('IniciarEdicion');
  if not cols[grilla.Col].editable then exit;
  valIniCelda := grilla.Cells[grilla.Col, grilla.Row];
  colIniCelda := grilla.Col;   //guarda coordenadas de edición
  filIniCelda := grilla.Row;   //guarda coordenadas de edición
  edGrilla.Text := txtInic;
  UbicarControles(grilla.CellRect(grilla.Col, grilla.Row));
  edGrilla.OnExit:=@edGrillaExit;   {Para evitar que el editor quede visible al cambiar el
                                     enfoque.}
  if cols[grilla.Col].tipo = ugTipNum then edGrilla.Alignment := taRightJustify
  else edGrilla.Alignment := taLeftJustify;
  edGrilla.Visible:=true;
  if edGrilla.Visible then edGrilla.SetFocus;
  edGrilla.SelStart:=length(edGrilla.Text);  //quita la selección
  if OnIniEditarCelda<>nil then
    OnIniEditarCelda(grilla.Col, grilla.Row, txtInic);
end;
procedure TGrillaEdic.TerminarEdicion(eventSalida: TEvSalida; ValorAnter, ValorNuev: string);
begin
debugln('---TerminarEdicion');
  if OnFinEditarCelda<>nil then begin
    OnFinEditarCelda(eventSalida, colIniCelda, filIniCelda, ValorAnter, ValorNuev);
    if eventSalida = evsNulo then exit;   //Se canceló el fin de la edición
  end;
  //Se porcede a terminar la edición
  edGrilla.OnExit := nil;  {Para evitar llamada recursiva de este evento. Se debe hacer
                            antes de ocultarlo.}
  edGrilla.Visible:=false;
  lstGrilla.Visible:=false;
  if grilla.Visible then grilla.SetFocus;    //retorna enfoque a la grilla
  case eventSalida of
  evsTecEnter: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    AdelantarAFilaVis(grilla);   //para a siguiente línea
  end;
  evsTecTab: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    SiguienteColVis(grilla);   //para a siguiente columna
  end;
  evsTecDer: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    SiguienteColVis(grilla);   //para a siguiente columna
  end;
  evsEnfoque: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
  end;
  end;
end;
function TGrillaEdic.EnEdicion: boolean;
{Indica si la grilla está en mod de edición.}
begin
  Result := edGrilla.Visible;
end;
procedure TGrillaEdic.NumerarFilas;
var
  f: Integer;
begin
  grilla.BeginUpdate;
  f := 1;
  for f := 1 to grilla.RowCount-1 do begin
    grilla.Cells[0, f] := IntToStr(f);
  end;
  grilla.EndUpdate();
end;
procedure TGrillaEdic.ValidaFilaGrilla(f: integer);
{Valida una fila de la grilla, para ver si es consistente, para ser ingresado como
registro nuevo a la grilla.}
var
  col: TugGrillaCol;
begin
  MsjError := '';
  for col in cols do begin
    colError:=col.idx;  {Se asigna primero la columna de error, para dar posibilidad a la
                        rutina de validación, el poder cambiarla en caso de que lo crea
                        conveniente.}
    col.ValidateStr(f);
    if MsjError <> '' then exit;
  end;
end;
//Estas rutinas de teclado, determinan cuando se inicia o no la edición de una celda.
procedure TGrillaEdic.grillaKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited grillaKeyDown(Sender, Key, Shift);
  //Se filtran las teclas que permitirán la edición.
  if (Key = VK_DELETE) and (Shift = []) then begin
    IniciarEdicion('');
  end else if Key = VK_F2 then begin
    IniciarEdicion(grilla.Cells[grilla.Col, grilla.Row]);
  end else begin
    //Estas teclas no se reconcoen aquí, pero puede que grillaKeyPress(), si lo haga.
  end;
end;
procedure TGrillaEdic.grillaKeyPress(Sender: TObject; var Key: char);
begin
  inherited grillaKeyPress(Sender, Key);
  if Key in ['0'..'9','a'..'z','A'..'Z'] then begin
    IniciarEdicion(Key);
    Key := #0;  //Para no dejar pasar accesos directos Botones.  Se detectó un error en unas pruebas
  end else begin
    Key := #0;   //para no entrar en modo de edición.
  end;
end;
procedure TGrillaEdic.grillaMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Longint;
begin
  inherited grillaMouseDown(Sender, Button, Shift, X, Y);
  grilla.MouseToCell(X, Y, ACol, ARow );
  if ACol = 0 then begin
    //En la columna fija, selecciona la fila.
    if ARow >= grilla.FixedRows then begin
      grilla.Row:=ARow;
    end;
  end;
  //Guarda coordenadas de la celda pulsad
  ColClick := grilla.Col;
  RowClick := grilla.Row;
end;
procedure TGrillaEdic.grillaMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ACol, ARow: Longint;
begin
  inherited grillaMouseUp(Sender, Button, Shift, X, Y);
  //También se puede iniciar la edición con el Mouse
  if Button = mbLeft then begin
    grilla.MouseToCell(X, Y, ACol, ARow );
    if ARow<grilla.FixedRows then exit;   //no en el encabezado
    if ACol<grilla.FixedCols then exit;   //no en el encabezado
    if (ColClick = ACol) and (RowClick = ARow) then begin
      //Click en la celda seleccionada.
      IniciarEdicion(grilla.Cells[grilla.Col, grilla.Row]);
    end;
  end;
end;
constructor TGrillaEdic.Create(grilla0: TStringGrid);
begin
  inherited Create(grilla0);
  //Crea el control de edición
  edGrilla := TEdit.Create(nil);
  edGrilla.Parent := grilla.Parent;  //Ubica como contenedor al mismo contnedor de la grilla
  edGrilla.Color:=TColor($40FFFF);
  edGrilla.Visible:=false;
  edGrilla.TabStop:=false;
  //Crea la lista contextual para mostrar opciones
  //Por defecto la lista no se mostrará. Debe controlarse por la aplicaicón.
  lstGrilla := TListBox.Create(nil);
  lstGrilla.Parent := grilla.Parent;  //Ubica como contenedor al mismo contnedor de la grilla
  lstGrilla.Color:=TColor($40FFFF);
  lstGrilla.Visible:=false;
  //La opción de edición, l amanejamos aquí
  grilla.Options:=grilla.Options-[goEditing];
  grilla.OnSelection:=@grillaSelection;
  //Configura eventos
  edGrilla.OnKeyPress:=@edGrillaKeyPress;
  edGrilla.OnKeyDown:=@edGrillaKeyDown;
end;
destructor TGrillaEdic.Destroy;
begin
  lstGrilla.Destroy;
  edGrilla.Destroy;
  inherited Destroy;
end;
{ TGrillaEdicFor }
procedure TGrillaEdicFor.SetOpSelMultiFila(AValue: boolean);
begin
  FOpSelMultiFila:=AValue;
  if grilla<>nil then begin
    //Ya tiene asignada una grilla
    if AValue then grilla.RangeSelectMode := rsmMulti
    else grilla.RangeSelectMode := rsmSingle;
  end;
end;
procedure TGrillaEdicFor.DibCeldaIcono(aCol, aRow: Integer; const aRect: TRect);
{Dibuja un ícono alineado en la celda "aRect" de la grilla "Self.grilla", usando el
alineamiento de Self.cols[].}
var
  cv: TCanvas;
  txt: String;
  ancTxt: Integer;
  icoIdx: Integer;
begin
  cv := grilla.Canvas;  //referencia al Lienzo
  if ImageList = nil then exit;
  //Es una celda de tipo ícono
  txt := grilla.Cells[ACol,ARow];
  if not TryStrToInt(txt, icoIdx) then begin //obtiene índice
    icoIdx := -1
  end;
  case cols[aCol].alineam of
    taLeftJustify: begin
      ImageList.Draw(cv, aRect.Left+2, aRect.Top+2, icoIdx);
    end;
    taCenter: begin
      ancTxt := ImageList.Width;
      ImageList.Draw(cv, aRect.Left + ((aRect.Right - aRect.Left) - ancTxt) div 2,
                   aRect.Top + 2, icoIdx);
    end;
    taRightJustify: begin
      ancTxt := ImageList.Width;
      ImageList.Draw(cv, aRect.Right - ancTxt - 2, aRect.Top+2, icoIdx);
    end;
  end;
end;
procedure TGrillaEdicFor.DibCeldaTextoEncab(aCol, aRow: Integer; const aRect: TRect);
{Dibuja un texto para una celda en el encabezado.}
var
  cv: TCanvas;
  txt: String;
begin
  cv := grilla.Canvas;  //referencia al Lienzo
  txt := grilla.Cells[ACol,ARow];
  cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
end;
procedure TGrillaEdicFor.DibCeldaTexto(aCol, aRow: Integer; const aRect: TRect);
{Dibuja un texto alineado en la celda "aRect" de la grilla "Self.grilla", usando el
alineamiento de Self.cols[].}
var
  cv: TCanvas;
  txt: String;
  ancTxt: Integer;
  colum: TugGrillaCol;
begin
  cv := grilla.Canvas;  //referencia al Lienzo
  txt := grilla.Cells[ACol,ARow];
  colum := cols[aCol];
  if (colum.tipo = ugTipNum) and (colum.formato<>'') then begin   //Hay formato
    try
       txt := Format(colum.formato, [f2N(txt)]);
    except
       txt := '###';
    end;
  end;
  //escribe texto con alineación
  case colum.alineam of
    taLeftJustify: begin
      cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
    end;
    taCenter: begin
      ancTxt := cv.TextWidth(txt);
      cv.TextOut(aRect.Left + ((aRect.Right - aRect.Left) - ancTxt) div 2,
                 aRect.Top + 2, txt );
    end;
    taRightJustify: begin
      ancTxt := cv.TextWidth(txt);
      cv.TextOut(aRect.Right - ancTxt - 3, aRect.Top + 2, txt);
    end;
  end;
end;
function TGrillaEdicFor.EsFilaSeleccionada(const f: integer): boolean;
{Indica si la fila "f", está seleccionada.
Se puede usar esta función para determinar las filas seleccionadas de la grilla (en el
caso de que la selección múltiple esté activada), porque hasta la versión actual,
SelectedRange[], puede contener rangos duplicados, si se hace click dos veces en la misma
fila, así que podría dar problemas si se usa SelectedRange[], para hallar las filas
seleccionadas.}
var
  i: Integer;
  sel: TGridRect;
begin
  if not FOpSelMultiFila then begin
    //Caso de selección simple
    exit(f = grilla.Row);
  end;
  //Selección múltiple
  for i:=0 to grilla.SelectedRangeCount-1 do begin
    sel := grilla.SelectedRange[i];
    if (f >= sel.Top) and (f <= sel.Bottom) then exit(true);
  end;
  //No está en ningún rango de selección
  exit(false);
end;
procedure TGrillaEdicFor.grillaDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
{Rutina personalziad para el dibujo de la celda}
var
  cv: TCanvas;           //referencia al lienzo
  atrib: integer;
begin
  cv := grilla.Canvas;  //referencia al Lienzo
  if gdFixed in aState then begin
    //Es una celda fija
    cv.Font.Color := clBlack;
    cv.Font.Style := [];
    cv.Brush.Color := clBtnFace;
    cv.FillRect(aRect);   //fondo
    DibCeldaTextoEncab(aCol, aRow, aRect);
  end else begin
    //Es una celda común
    cv.Font.Color := TColor(PtrUInt(grilla.Objects[1, aRow]));
    if grilla.Objects[2, aRow]=nil then begin
      //Sin atributos
      cv.Font.Style := [];
    end  else begin
      //Hay atributos de texto
      atrib := PtrUInt(grilla.Objects[2, aRow]);
      if (atrib and 1) = 1 then cv.Font.Style := cv.Font.Style + [fsUnderline];
      if (atrib and 2) = 2 then cv.Font.Style := cv.Font.Style + [fsItalic];
      if (atrib and 4) = 4 then cv.Font.Style := cv.Font.Style + [fsBold];
    end;
    if OpResaltFilaSelec and EsFilaSeleccionada(aRow) then begin
      //Fila seleccionada. (Debe estar activada la opción "goRowHighligh", para que esto funcione bien.)
      cv.Brush.Color := clBtnFace;
    end else begin
      if OnLeerColorFondo<>nil then
        cv.Brush.Color := OnLeerColorFondo(aCol, aRow)
      else
        cv.Brush.Color := clWhite;
    end;
    cv.FillRect(aRect);   //fondo
    if cols[aCol].tipo = ugTipIco then
      DibCeldaIcono(aCol, aRow, aRect)
    else
      DibCeldaTexto(aCol, aRow, aRect);
    // Dibuja ícono
{    if (aCol=0) and (aRow>0) then
      ImageList16.Draw(grilla.Canvas, aRect.Left, aRect.Top, 19);}
    //Dibuja borde en celda seleccionada
    if gdFocused in aState then begin
      cv.Pen.Color := clRed;
      cv.Pen.Style := psDot;
      cv.Frame(aRect.Left, aRect.Top, aRect.Right-1, aRect.Bottom-1);  //dibuja borde
    end;
  end;
end;
constructor TGrillaEdicFor.Create(grilla0: TStringGrid);
begin
  inherited Create(grilla0);
  grilla.DefaultDrawing := false;
  grilla.OnDrawCell := @grillaDrawCell;
end;

end.

