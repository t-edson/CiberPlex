{Implementa un frame con una grilla para la edición de tablas.
Internamente usa un objeto TGrillaEdicFor, de la unidad CibGrillas, y crea
la grilla dinámicamente.
Además permite el autocompletado por columnas, que implementa CibGrillas.}
unit FrameEditGrilla;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, ActnList, Menus, Grids, LCLType,
  Graphics, LCLProc, StdCtrls, MisUtils, BasicGrilla, UtilsGrilla, CibGrillas,
  CibUtils;
type
  //Tipos de modificaciones
  TugTipModif = (
    umdFilAgre,  //Fila agregada
    umdFilModif,  //Fila modificada
    umdFilElim,   //Fila eliminada
    umdFilMovid   //Fila movida
  );
  TEvReqNuevoReg = procedure(fil: integer) of object;
  TEvGrillaModif = procedure(TipModif: TugTipModif) of object;

  { TfraEditGrilla }
  TfraEditGrilla = class(TFrame)
  published
    acEdiCopCel: TAction;
    acEdiCopFil: TAction;
    acEdiElimin: TAction;
    acEdiNuevo: TAction;
    acEdiPegar: TAction;
    acEdiSubir: TAction;
    acEdiBajar: TAction;
    ActionList1: TActionList;
    grilla: TStringGrid;
    ImageList1: TImageList;
    MenuItem1: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    PopupMenu1: TPopupMenu;
    procedure acEdiBajarExecute(Sender: TObject);
    procedure acEdiCopCelExecute(Sender: TObject);
    procedure acEdiCopFilExecute(Sender: TObject);
    procedure acEdiEliminExecute(Sender: TObject);
    procedure acEdiNuevoExecute(Sender: TObject);
    procedure acEdiPegarExecute(Sender: TObject);
    procedure acEdiSubirExecute(Sender: TObject);
  private
    procedure EstadoAcciones(estado: boolean);
    procedure griModificado;
    procedure gri_LlenarLista(lstGrilla: TListBox; fil, col: integer;
      editTxt: string);
    function gri_LeerColorFondo(col, fil: integer): TColor;
    procedure griMouseUpFixedCol(Button: TMouseButton; row, col: integer);
    procedure griMouseUpNoCell(Button: TMouseButton; row, col: integer);
    procedure gri_FinEditarCelda(var eveSal: TEvSalida; col, fil: integer;
      var ValorAnter, ValorNuev: string);
    procedure gri_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gri_MouseUpCell(Button: TMouseButton; row, col: integer);
  public
    gri             : TGrillaEdicFor;
    AutoAdd         : boolean;       //Se agregan filas con el cursor
    Modificado      : boolean;
    OnLeerColorFondo: TEvLeerColorFondo;
    OnReqNuevoReg   : TEvReqNuevoReg;
    OnGrillaModif   : TEvGrillaModif;
    OnLlenarLista   : TEvLlenarLista; //Se pide llenar la lista de completado
    MsjError: string;
    procedure ValidarGrilla;
    function BuscAgreEncabNum(titulo: string; ancho: integer): TugGrillaCol;
    procedure SetFocus; override;
  public  //Funciones espejo
    procedure IniEncab;
    function AgrEncabTxt(titulo: string; ancho: integer; indColDat: int16=-1
      ): TugGrillaCol;
    function AgrEncabChr(titulo: string; ancho: integer; indColDat: int16=-1
      ): TugGrillaCol;
    function AgrEncabNum(titulo: string; ancho: integer; indColDat: int16=-1
      ): TugGrillaCol;
    function AgrEncabBool(titulo: string; ancho: integer; indColDat: int16=-1
      ): TugGrillaCol;
    function AgrEncabDatTim(titulo: string; ancho: integer; indColDat: int16=-1
      ): TugGrillaCol;
    procedure FinEncab(actualizarGrilla: boolean=true);
    function RowCount: integer;
    procedure LimpiarFiltros;
    function AgregarFiltro(proc: TUtilProcFiltro): integer;
    procedure Filtrar;
    function FilVisibles: integer;
    function FilaVacia(f: integer): boolean;
  public  //Constructor y destructor.
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  end;

implementation
{$R *.lfm}

{ TfraEditGrilla }
//Funciones espejo
procedure TfraEditGrilla.IniEncab;
begin
  gri.IniEncab;
end;
function TfraEditGrilla.AgrEncabTxt(titulo: string; ancho: integer;
  indColDat: int16): TugGrillaCol;
begin
  Result := gri.AgrEncabTxt(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabChr(titulo: string; ancho: integer;
  indColDat: int16): TugGrillaCol;
begin
  Result := gri.AgrEncabChr(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabNum(titulo: string; ancho: integer;
  indColDat: int16): TugGrillaCol;
begin
  Result := gri.AgrEncabNum(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabBool(titulo: string; ancho: integer;
  indColDat: int16): TugGrillaCol;
begin
  Result := gri.AgrEncabBool(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabDatTim(titulo: string; ancho: integer;
  indColDat: int16): TugGrillaCol;
begin
  Result := gri.AgrEncabDatTim(titulo, ancho, indColDat);
end;
procedure TfraEditGrilla.FinEncab(actualizarGrilla: boolean);
begin
  gri.FinEncab(actualizarGrilla);
  if AutoAdd then begin
    if grilla.RowCount <= 1 then begin
      //Solo hay fila de encambezado
      grilla.RowCount := 2;
    end;
  end;
end;
function TfraEditGrilla.RowCount: integer;
begin
  Result := grilla.RowCount;
end;
procedure TfraEditGrilla.LimpiarFiltros;
begin
  gri.LimpiarFiltros;
end;
function TfraEditGrilla.AgregarFiltro(proc: TUtilProcFiltro): integer;
begin
  Result := gri.AgregarFiltro(proc);
end;
procedure TfraEditGrilla.Filtrar;
begin
  gri.Filtrar;
end;
function TfraEditGrilla.FilVisibles: integer;
begin
  Result := gri.filVisibles;
end;
function TfraEditGrilla.FilaVacia(f: integer): boolean;
{Indica si la fila indicada está vacía. Solo considera las columnas no fijas}
var
  c: Integer;
begin
  Result := true;   //Se asume que sí
  for c := grilla.FixedCols to grilla.ColCount-1 do begin
    if trim(grilla.Cells[c, f])<>'' then exit(false);
  end;
end;
procedure TfraEditGrilla.EstadoAcciones(estado: boolean);
begin
//  for i:=0 to ActionList1.ActionCount-1 do begin
//    ActionList1.Actions[i].Enabled := estado;
//  end;
  acEdiCopCel.Enabled:=estado;
  acEdiCopFil.Enabled:=estado;
  acEdiPegar.Enabled:=estado;
  acEdiNuevo.Enabled:=estado;
  acEdiElimin.Enabled:=estado;
  acEdiSubir.Enabled:=estado;
  acEdiBajar.Enabled:=estado;
end;
procedure TfraEditGrilla.griModificado;
begin
  if OnGrillaModif<>nil then OnGrillaModif(umdFilModif);
end;
//Manejo de eventos
procedure TfraEditGrilla.gri_MouseUpCell(Button: TMouseButton; row, col: integer);
begin
  if Button = mbRight then begin
    EstadoAcciones(true);
    acEdiCopFil.Enabled:=false;
    PopupMenu1.PopUp;
  end;
end;
procedure TfraEditGrilla.griMouseUpFixedCol(Button: TMouseButton; row,
  col: integer);
begin
  if Button = mbRight then begin
    EstadoAcciones(true);
    acEdiCopCel.Enabled:=false;
    PopupMenu1.PopUp;
  end;
end;
procedure TfraEditGrilla.griMouseUpNoCell(Button: TMouseButton; row,
  col: integer);
begin
  if Button = mbRight then begin
    EstadoAcciones(false);
    acEdiNuevo.Enabled:=true;
    PopupMenu1.PopUp;
  end;
end;
procedure TfraEditGrilla.gri_LlenarLista(lstGrilla: TListBox; fil, col: integer;
                                editTxt: string);
begin
  if OnLlenarLista<>nil then OnLlenarLista(lstGrilla, fil, col, editTxt);
end;
procedure TfraEditGrilla.ValidarGrilla;
{Valida el contenido de las celdas de las grilla. Si encuentra error, muestra el mensaje
y devuelve el mensaje en "MsjError".}
var
  f: Integer;
begin
  MsjError := '';
  for f:=1 to grilla.RowCount-1 do begin
    gri.ValidaFilaGrilla(f);
    if gri.MsjError<>'' then begin
      //Hubo error
      MsjError := gri.MsjError;  //copia mensaje
      MsgExc(MsjError);
      //Selecciona la celda
      grilla.Row:=f;  //fila del error
      grilla.Col:=gri.colError;  //columna del error
      exit;
    end;
  end;
end;
function TfraEditGrilla.BuscAgreEncabNum(titulo: string; ancho: integer): TugGrillaCol;
{Busca o agrega una columna, a la grilla, sin modificar los datos ya ingresados.}
begin
  //Asegura que exista la columna
  Result := gri.BuscarColumna(titulo);
  if Result = nil then begin
    Result := gri.AgrEncabNum(titulo, ancho);
  end;
  grilla.ColCount:=gri.cols.Count;   //Hace espacio
  gri.DimensColumnas;   //actualiza anchos
end;
procedure TfraEditGrilla.SetFocus;
//Manejamos nuestra propia versión se SetFocus
begin
//  inherited SetFocus;
  if not Visible then exit;
  if not grilla.Visible then exit;
  try
    grilla.SetFocus;
  except
  end;
end;
procedure TfraEditGrilla.gri_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{Configura los accesos de teclado de la grilla. Se configuran aquí, y no con atajos de las
acciones, porque se quiere qie estos accesos solo funciones cuando la grilla tiene
el enfoque.}
var
  filAct, uFil, f: Integer;
begin
  if Key = VK_APPS then begin  //Menú contextual
    PopupMenu1.PopUp;
  end else if Key = VK_DOWN then begin

  end;
  if (Shift = [ssCtrl]) and (Key = VK_C) then begin
    acEdiCopCelExecute(self);
  end;
  if (Shift = [ssCtrl]) and (Key = VK_INSERT) then begin
    acEdiCopCelExecute(self);
  end;
  if (Shift = [ssCtrl]) and (Key = VK_V) then begin
    acEdiPegarExecute(self);
  end;
  if (Shift = [ssShift]) and (Key = VK_INSERT) then begin
    acEdiPegarExecute(self);
  end;
  if (Shift = [ssCtrl]) and (Key = VK_J) then begin
    filAct := grilla.Row;  //guarda fila actual
    RetrocederAFilaVis(grilla);    //sube a fila anterior
    gri.CopiarCampo;
    grilla.Row := filAct;  //retorna fila
    gri.PegarACampo;
  end;
  if (Shift = [ssAlt]) and (Key = VK_UP) then begin
    acEdiSubirExecute(self);
    Key := 0;  //para que no desplaze
  end;
  if (Shift = [ssAlt]) and (Key = VK_DOWN) then begin
    acEdiBajarExecute(self);
    Key := 0;  //para que no desplaze
  end;
  if (Shift = []) and (Key = VK_RETURN) then begin
    uFil := UltimaFilaVis(grilla);
    if grilla.Row = uFil  then begin
      //Está en la última fila. Agrega una fila al final.
      grilla.InsertColRow(false, grilla.RowCount);
      f := grilla.RowCount-1;  //fila agregada
      //Llena los campos por defecto.
      if OnReqNuevoReg<>nil then OnReqNuevoReg(f);
      //Ubica fila seleccionada
      grilla.Row := f;
      grilla.Col := 1;
      //Actualiza
      gri.NumerarFilas;
      Modificado := true;
      if OnGrillaModif<>nil then OnGrillaModif(umdFilAgre);
    end;
  end;
  if (Shift = [ssCtrl]) and (Key = VK_DELETE) then begin
    acEdiEliminExecute(Self);
  end;
end;
procedure TfraEditGrilla.gri_FinEditarCelda(var eveSal: TEvSalida; col,
  fil: integer; var ValorAnter, ValorNuev: string);
{Termina la edición de una celda. Validamos, la celda.}
var
  n: Double;
  Err: string;
begin
  if eveSal in [evsTecEnter, evsTecTab, evsTecDer, evsEnfoque] then begin
    //Puede haber cambio
//    if ValorAnter = ValorNuev then exit;  //no es cambio
    gri.MsjError := '';
    if gri.cols[col].tipo = ugTipNum then begin
      //Es numérico, vemos si es fórmula.
      if (ValorNuev <> '') and (ValorNuev[1]='+')  then begin
        //Puede ser expresión, hacemos el favor de evaluarla
        n := EvaluarExp(ValorNuev, Err);
        if Err='' then begin
          //Se puede evaluar
          ValorNuev := FloatToStr(n);
        end;
      end;
    end;
    gri.cols[col].ValidateStr(fil, ValorNuev);
    if gri.MsjError<>'' then begin
      //Hay rutina de validación
      MsgExc(gri.MsjError);
      eveSal := evsNulo;
    end;
  end;
end;
function TfraEditGrilla.gri_LeerColorFondo(col, fil: integer): TColor;
begin
  if OnLeerColorFondo<>nil then Result := OnLeerColorFondo(col, fil)
  else Result := clWhite;
end;
constructor TfraEditGrilla.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  gri := TGrillaEdicFor.Create(grilla);
  //Configura opciones en la grilla
  gri.MenuCampos:=true;
  gri.OpResaltFilaSelec:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  //Configura eventos
  gri.OnMouseUpCell   := @gri_MouseUpCell;
  gri.OnMouseUpFixedCol:=@griMouseUpFixedCol;
  gri.OnMouseUpNoCell:=@griMouseUpNoCell;
  gri.OnKeyDown       := @gri_KeyDown;
  gri.OnFinEditarCelda:= @gri_FinEditarCelda;
  gri.OnLeerColorFondo:= @gri_LeerColorFondo;
  gri.OnLlenarLista   := @gri_LlenarLista;
  gri.OnModificado := @griModificado;
end;
destructor TfraEditGrilla.Destroy;
begin
  gri.Destroy;
  inherited Destroy;
end;
///////////////////////// Acciones ////////////////////////////////
//Acciones de edición
procedure TfraEditGrilla.acEdiCopCelExecute(Sender: TObject);
begin
  gri.CopiarCampo;
end;
procedure TfraEditGrilla.acEdiSubirExecute(Sender: TObject);
var
  filAnt, filAct: Integer;
begin
  filAnt := FilaVisAnterior(grilla);
  if filAnt = -1 then exit;
  filAct := grilla.Row;
  grilla.ExchangeColRow(false, filAnt, filAct);
  grilla.Row := filAnt;
  //Actualiza
  gri.NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilMovid);
end;
procedure TfraEditGrilla.acEdiBajarExecute(Sender: TObject);
var
  filSig, filAct: Integer;
begin
  filSig := FilaVisSiguiente(grilla);
  if filSig = -1 then exit;
  filAct := grilla.Row;
  grilla.ExchangeColRow(false, filSig, filAct);
  grilla.Row := filSig;
  //Actualiza
  gri.NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilMovid);
end;
procedure TfraEditGrilla.acEdiCopFilExecute(Sender: TObject);
begin
  gri.CopiarFila;
end;
procedure TfraEditGrilla.acEdiPegarExecute(Sender: TObject);
begin
  gri.PegarACampo;
  //Habría que ver. si en realida lo modifica
  if OnGrillaModif<>nil then OnGrillaModif(umdFilModif);
end;
procedure TfraEditGrilla.acEdiNuevoExecute(Sender: TObject);
var
  f: Integer;
begin
  if grilla.Row = 0 then begin
    grilla.InsertColRow(false, 1);
    f := 1;  //fila insertada
  end else begin
    grilla.InsertColRow(false, grilla.Row);
    f := grilla.Row - 1;  //fila insertada
  end;
  //Llena los campos por defecto.
  if OnReqNuevoReg<>nil then OnReqNuevoReg(f);
  //Ubica fila seleccionada
  grilla.Row := f;
  //Actualiza
  gri.NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilAgre);
end;
procedure TfraEditGrilla.acEdiEliminExecute(Sender: TObject);
{Elimina el registro seleccionado.}
var
  tmp: String;
begin
  if grilla.Row<1 then exit;;
//  tmp := colDescri.ValStr[grilla.Row];
  tmp := grilla.Cells[0, grilla.Row];
  if MsgYesNo('¿Eliminar registro: ' + tmp + '?') <> 1 then exit ;
  //Se debe eliminar el registro seleccionado
  grilla.DeleteRow(grilla.Row);
  //Actualiza
  gri.NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilElim);
end;
end.

