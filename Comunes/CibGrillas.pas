{Unidad con clases para mejorar las que presenta "UtilsGrilla", agregando opciones de
edición más seguras y completas, a las grillas.
Tal vez deban incluirse estas clases en la unidad Utilsgrilla, ya que son bastante
genéricas y personalizables.}
unit CibGrillas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, LCLIntf, Graphics, Controls, StdCtrls, fpexprpars, Grids,
  LCLType, BasicGrilla, UtilsGrilla, MisUtils;
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
                                var ValorAnter, ValorNuev: string) of object;
  TEvLeerColorFondo = function(col, fil: integer; EsSelec: boolean): TColor of object;
  TEvLlenarLista    = procedure(lstGrilla: TListBox; fil, col: integer;
                                editTxt: string) of object;


  { TGrillaEdic }
  {Define a una grilla de tipo "UtilsGrilla.TUtilGrilla" pero agrega facilidades de
  edición de los campos de la grilla asociada. Esta clase maneja un TEdit, como control
  para la edición del contenido de una celda, permitiendo cancelar la edición (sin
  modificar la celda), pulsando simplemente <Escape>. También se incluye un control de
  lista, para que pueda servir a modo de menú contextual, al momento de realizar la
  edición de la celda. Para interactuar con la edición, se incluyen los eventos:
   * OnIniEditarCelda;
   * OnFinEditarCelda;
  TGrillaEdic, no usa las opciones de edición que vienen con TStringGrid (con los eventos
  OnGetEditText y OnEditingDone), sino que implementa sus propias rutinas de edición.
  Se diseñó así porque se ha detectado muchos problemas en las rutinas OnGetEditText() y
  OnEditingDone() de TStringGrid, como que sus parámetros no son apropiados y sobre todo,
  que se generan llamadas múltiples a estos eventos, cuando se usaba EditingDone().
  }
  TGrillaEdic = class(TUtilGrilla)
  private
    ColClick, RowClick: Longint;
    colIniCelda, filIniCelda: Integer;
    procedure edGrilla_Change(Sender: TObject);
    procedure edGrilla_Exit(Sender: TObject);
    procedure grillaSelection(Sender: TObject; aCol, aRow: Integer);
    procedure lstGrilla_KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lstGrilla_KeyPress(Sender: TObject; var Key: char);
    procedure lstGrilla_Exit(Sender: TObject);
    procedure lstGrilla_SelectionChange(Sender: TObject; User: boolean);
    procedure UbicarControles(r: TRect);
    procedure RefreshEdGrillaText;
  protected
    edGrilla : TEdit;  //Editor para los campos de tipo texto
    lstGrilla: TListBox;  //Lista para la selección de valores
    valIniCelda: string;
    procedure TestForCompletionList(fil, col: integer; txt: string);
    procedure edGrilla_KeyPress(Sender: TObject; var Key: char);
    procedure edGrilla_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure grillaKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); override;
    procedure grillaKeyPress(Sender: TObject; var Key: char); override;
    procedure grillaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure grillaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
  public
    OnIniEditarCelda : TEvIniEditarCelda;  //Inicia la edición de una celda
    OnFinEditarCelda : TEvFinEditarCelda;  //Antes de finalizar la edición de una celda
    OnFinEditarCelda2: TEvFinEditarCelda;  //Al Finalizar la edición de una celda
    OnLlenarLista    : TEvLlenarLista;     //Se pide llenar la lista de completado
    OnModificado     : procedure of object;
    procedure IniciarEdicion(txtInic: string); virtual;
    procedure OcultContrEdicion;
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

implementation

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
procedure TGrillaEdic.RefreshEdGrillaText;
{Fija el texto del control "edGrilla", a partir del elemento seleccionado en "lstGrilla"
El texto se fija en "edGrilla", sin disparar el evento OnChange, para evitar que se
active el filtro en "lstGrilla".}
var
  tmp: TNotifyEvent;
begin
  if lstGrilla.ItemIndex<>-1 then begin      //toma el elemento selecionado
    tmp := edGrilla.OnChange;
    edGrilla.OnChange := nil;  //Desactiva temporalmente, para no modificar la lista
    edGrilla.Text := lstGrilla.Items[lstGrilla.ItemIndex];
    edGrilla.OnChange := tmp; //restaura
  end;
end;
procedure TGrillaEdic.TestForCompletionList(fil, col: integer; txt: string);
begin
  //Muestra la lista de completado
  if OnLlenarLista<>nil then begin
    OnLlenarLista(lstGrilla, fil, col, txt);
    if lstGrilla.Count>0 then begin
      lstGrilla.Visible:=true;
    end;
  end else begin
    //No se definió el manejador de evento

  end;
end;
procedure TGrillaEdic.edGrilla_KeyPress(Sender: TObject; var Key: char);
begin
  if Key = #27 then begin
    TerminarEdicion(evsTecEscape, valIniCelda, edGrilla.Text);   //termina edición
  end else if Key = #13 then begin
//    Key := #0;
    TerminarEdicion(evsTecEnter, valIniCelda, edGrilla.Text);   //termina edición
  end else begin
    //Debe ser una tecla común
  end;
end;
procedure TGrillaEdic.edGrilla_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_TAB then begin
    TerminarEdicion(evsTecTab, valIniCelda, edGrilla.Text);   //termina edición
  end else if Key = VK_RIGHT then begin
    if edGrilla.SelStart = length(edGrilla.Text) then begin
      TerminarEdicion(evsTecDer, valIniCelda, edGrilla.Text);   //termina edición
    end;
  end else if Key = VK_DOWN then begin
    if lstGrilla.Visible then lstGrilla.SetFocus;  //pasa enfoque
    if lstGrilla.ItemIndex < lstGrilla.Count-1 then begin
      lstGrilla.ItemIndex := lstGrilla.ItemIndex + 1;   //baja la selección
    end;
    RefreshEdGrillaText;
  end;
end;
procedure TGrillaEdic.edGrilla_Change(Sender: TObject);
begin
  TestForCompletionList(filIniCelda, colIniCelda, edGrilla.Text);
end;
procedure TGrillaEdic.edGrilla_Exit(Sender: TObject);
begin
  {En general, el enfoque se puede perder por diversos motivos, pero lo más común
   es que se haya hecho "click" en alguna otra parte de la grilla. }
  if lstGrilla.Focused then begin
    //El enfoque pasó a la lista de completado
  end else begin
    TerminarEdicion(evsEnfoque, valIniCelda, edGrilla.Text);   //termina edición
  end;
end;
procedure TGrillaEdic.lstGrilla_SelectionChange(Sender: TObject; User: boolean);
begin
  RefreshEdGrillaText;
end;
procedure TGrillaEdic.lstGrilla_KeyPress(Sender: TObject; var Key: char);
begin
  if Key in ['a'..'z','A'..'A','0'..'9',' ','_'] then begin
    //Se asume que estas teclas indican que se quiere escribir un nuevo texto en el editor
    edGrilla.SetFocus;   //le devolvemos el enfoque
    edGrilla.Text := Key;
  end;
end;
procedure TGrillaEdic.lstGrilla_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_TAB then begin
    //Toma el control de esta tecla, porque se usa para indicar que se acpeta la selección
    TerminarEdicion(evsTecTab, valIniCelda, edGrilla.Text);   //termina edición
    Key := 0;  //Para que no ejecute acciones por defecto, (como pasar el enfoque
  end else if Key = VK_RETURN then begin
    //Toma el control de esta tecla, porque se usa para indicar que se acpeta la selección
    TerminarEdicion(evsTecEnter, valIniCelda, edGrilla.Text);   //termina edición
    Key := 0;  //Para que no ejecute acciones por defecto, (como pasar el enfoque
  end else if Key = VK_ESCAPE then begin
    //Toma el control de esta tecla
    TerminarEdicion(evsTecEscape, valIniCelda, edGrilla.Text);   //termina edición
    Key := 0;  //Para que no ejecute acciones por defecto, (como pasar el enfoque
  end;
end;
procedure TGrillaEdic.lstGrilla_Exit(Sender: TObject);
{Si la lista pierde el enfoque es porque estaba en modo de edición y se estaba
seleccionando desde la lista.}
begin
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
//debugln('IniciarEdicion');
  if not cols[grilla.Col].editable then exit;
  valIniCelda := grilla.Cells[grilla.Col, grilla.Row];
  colIniCelda := grilla.Col;   //guarda coordenadas de edición
  filIniCelda := grilla.Row;   //guarda coordenadas de edición
  edGrilla.Text := txtInic;
  UbicarControles(grilla.CellRect(grilla.Col, grilla.Row));
  edGrilla.OnExit:=@edGrilla_Exit;   {Para evitar que el editor quede visible al cambiar el
                                     enfoque.}
  if cols[grilla.Col].tipo = ugTipNum then edGrilla.Alignment := taRightJustify
  else edGrilla.Alignment := taLeftJustify;
  edGrilla.Visible:=true;
  if edGrilla.Visible then edGrilla.SetFocus;
  edGrilla.SelStart:=length(edGrilla.Text);  //quita la selección
  if OnIniEditarCelda<>nil then
    OnIniEditarCelda(grilla.Col, grilla.Row, txtInic);
  //Muestra la lista de completado
  TestForCompletionList(filIniCelda, colIniCelda, txtInic);
end;
procedure TGrillaEdic.OcultContrEdicion;
{Oculta los controles usados para la edición de contenido.}
begin
  edGrilla.OnExit := nil;  {Para evitar llamada recursiva de este evento. Se debe hacer
                            antes de ocultarlo.}
  edGrilla.Visible:=false;
  lstGrilla.Visible:=false;
  if grilla.Visible then grilla.SetFocus;    //retorna enfoque a la grilla
end;
procedure TGrillaEdic.TerminarEdicion(eventSalida: TEvSalida; ValorAnter, ValorNuev: string);
begin
//debugln('---TerminarEdicion');
  if OnFinEditarCelda<>nil then begin
    OnFinEditarCelda(eventSalida, colIniCelda, filIniCelda, ValorAnter, ValorNuev);
    if eventSalida = evsNulo then begin
      exit;   //Se canceló el fin de la edición
      //Notar que no llama a OnModificado.
    end;
  end;
  //Se procede a terminar la edición
  OcultContrEdicion;
  case eventSalida of
  evsTecEnter: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    MovASiguienteColVis(grilla);   //pasa a siguiente columna
    if OnModificado<>nil then OnModificado();
  end;
  evsTecTab: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    MovASiguienteColVis(grilla);   //pasa a siguiente columna
    if OnModificado<>nil then OnModificado();
  end;
  evsTecDer: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    MovASiguienteColVis(grilla);   //pasa a siguiente columna
    if OnModificado<>nil then OnModificado();
  end;
  evsEnfoque: begin
    grilla.Cells[colIniCelda, filIniCelda] := ValorNuev;  //acepta valor
    if OnModificado<>nil then OnModificado();
  end;
  evsTecEscape: begin
    //No cambia el valor
    //grilla.Cells[colIniCelda, filIniCelda] := ValorAnter;  //acepta valor
  end;
  end;
  if OnFinEditarCelda2<>nil then begin
    OnFinEditarCelda2(eventSalida, grilla.Col, grilla.Row, ValorAnter, ValorNuev);
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
  if Key in ['0'..'9','a'..'z','A'..'Z','+'] then begin
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
  lstGrilla.OnSelectionChange := @lstGrilla_SelectionChange;
  lstGrilla.OnExit := @lstGrilla_Exit;
  lstGrilla.OnKeyPress := @lstGrilla_KeyPress;
  lstGrilla.OnKeyDown := @lstGrilla_KeyDown;
  //La opción de edición, l amanejamos aquí
  grilla.Options:=grilla.Options-[goEditing];
  grilla.OnSelection:=@grillaSelection;
  //Configura eventos
  edGrilla.OnKeyPress := @edGrilla_KeyPress;
  edGrilla.OnKeyDown  := @edGrilla_KeyDown;
  edGrilla.OnChange   := @edGrilla_Change;
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
      if OnLeerColorFondo<>nil then begin
        cv.Brush.Color := OnLeerColorFondo(aCol, aRow, true);
      end else begin
        cv.Brush.Color := clBtnFace;
      end;
    end else begin
      if OnLeerColorFondo<>nil then begin
        cv.Brush.Color := OnLeerColorFondo(aCol, aRow, false);
      end else begin
        cv.Brush.Color := clWhite;
      end;
    end;
    cv.FillRect(aRect);   //fondo
    if aCol<cols.Count then begin
      if cols[aCol].tipo = ugTipIco then
        DibCeldaIcono(aCol, aRow, aRect)
      else
        DibCeldaTexto(aCol, aRow, aRect);
    end;
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

