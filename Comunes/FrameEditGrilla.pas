{Implementa un frame con una grilla para la edición de tablas.
Internamente usa un objeto TGrillaEdicFor, de la unidad CibGrillas, y crea
la grilla dinámicamente.
Permite asociar el frame a una tabla de tipo "TCibTablaMaest", para leer campos
automáticmente.
Además permite el autocompletado por columnas, que implementa CibGrillas.

USO:
====
Primero se debe incluir este frame en un formulario y tratarlo como un frame común.
Luego se debe pasar a definir lso campos de la grilla. Para esto se puede trabajar en
dos formas:

1. CONFIGURACIÓN SIN TABLA ASOCIADA:
las columnas de la grilla, se definen (y se trabajan) en la forma normal en que se haría
en la librería "UtilsGrilla":

fraGri.IniEncab;
             fraGri.AgrEncabNum   ('N°'          , 25);
colCodigo := fraGri.AgrEncabTxt   ('CÓDIGO'      , 60);
colCateg  := fraGri.AgrEncabTxt   ('CATEGORÍA'   , 70);
colPreUni := fraGri.AgrEncabTxt   ('PREC.UNIT.'  , 80);
fraGri.FinEncab;

Por defecto todos los campos agregados a la grilla, se definen como editables. Para
proteger un campo de la edición, se debe hacer:

  colCateg.editable:=false;   //Los cambios de stock, son otro proceso

Las celdas que se han definido como números, aceptan además, definir el formato en que
se presentarán los valores en las celdas de la grilla:

  colPreUni.formato := 'S/. %.2f ';

Considerar además, que se pueden agregar restricciones a los campos:

  colCodigo.restric:= [ucrNotNull, ucrUnique];

El llenado y grabado de los datos de la grilla debe implementarse por código, como se
hace normalmente con "UtilsGrilla"

2. CONFIGURACIÓN CON TABLA ASOCIADA:
En esta forma se usa una tabla de datos de la clase TCibTablaMaest, como fuente de
datos, de forma que el llenado y modifiación se hace de forma simple.

La configuración inicial de la tabla se hace de la siguiente forma:

fraGri.IniEncab(TabPro);
colCodigo := fraGri.AgrEncabTxt   ('CÓDIGO'        , 60, 'ID_PROD');
colCateg  := fraGri.AgrEncabTxt   ('CATEGORÍA'     , 70, 'CATEGORIA');
colSubcat := fraGri.AgrEncabTxt   ('SUBCATEGORÍA'  , 80, 'SUBCATEGORIA');
colPreUni := fraGri.AgrEncabNum   ('PRC.UNITARIO'  , 55, 'PREVENTA');
fraGri.FinEncab;
if fraGri.MsjError<>'' then begin
  ...
end;

Un detalle importante al usar IniEncab() en esta forma, es que automáticamente se
crean dos columnas en la grilla:

* Columna 0 -> Columna fija y oculta, almacena los datos completos de una fila de la tabla.
* Columna 1 -> Columna fija, muestra el número de fila.

Ambas columnas son accesibles mediante los campos colData y colNumber, respectivamente.

El primer parámetro de AgrEncabXXX(), es el título que se la le pone a la grilla,
el segundo parámetro es el ancho en pixeles, y el tercer parámetro es el nombre de
la columna asociada de la tabla que se usará para llenar la grilla.

La verificación de errores es necesaria para ver si se ha podido leer la tabla  y si se
ubicaron las columnas.

Una vez asociada la grilla a la tabla. El llenado se hace solamente llamando a la
función:

fraGri.ReadFromTable;

}
unit FrameEditGrilla;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, ActnList, Menus, Grids, LCLType,
  Graphics, LCLProc, StdCtrls, MisUtils, BasicGrilla, UtilsGrilla, CibGrillas,
  CibUtils, CibBD;
type
  //Tipos de modificaciones
  TugTipModif = (
    umdFilAgre,  //Fila agregada
    umdFilModif,  //Fila modificada
    umdFilElim,   //Fila eliminada
    umdFilMovid   //Fila movida
  );
  TEvReqNuevoReg = procedure(fil: integer) of object;
  TEvGrillaModif = procedure(TipModif: TugTipModif; filAfec: integer) of object;

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
    function gri_LeerColorFondo(col, fil: integer; EsSelec: boolean): TColor;
    procedure griMouseUpFixedCol(Button: TMouseButton; row, col: integer);
    procedure griMouseUpNoCell(Button: TMouseButton; row, col: integer);
    procedure gri_FinEditarCelda(var eveSal: TEvSalida; col, fil: integer;
      var ValorAnter, ValorNuev: string);
    procedure gri_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure gri_MouseUpCell(Button: TMouseButton; row, col: integer);
    procedure NumerarFilas;
    function GetFilaSelecc: integer;
    procedure SetFilaSelecc(AValue: integer);
  public  //Campos generales
    gri          : TGrillaEdicFor;  //Objeto grilla editable
    AddRowEnd    : boolean;         //Se agrega una fila vacía con FinEncab()
    AddRowEnter  : boolean;         //Se agrega una fila vacía cuando se pulsa <enter>
    Modificado   : boolean;         //Indica si se ah modificado
    MsjError     : string;
    procedure ValidarGrilla;
    function BuscAgreEncabNum(titulo: string; ancho: integer): TugGrillaCol;
    procedure SetFocus; override;
    function BuscarTxt(txt: string; col: integer): integer;
  public  //Eventos
    OnLeerColorFondo: TEvLeerColorFondo;
    OnReqNuevoReg   : TEvReqNuevoReg;
    OnGrillaModif   : TEvGrillaModif;
    OnLlenarLista   : TEvLlenarLista; //Se pide llenar la lista de completado
    OnGrillaKeyDown : TKeyEvent;
    OnCeldaEditada  : TEvFinEditarCelda; //Se termina de editar una celda
  public  //Funciones para definir columnas a mostrar
    procedure IniEncab;
    function AgrEncabTxt(titulo: string; ancho: integer; ColDat: string=''
      ): TugGrillaCol;
    function AgrEncabChr(titulo: string; ancho: integer; ColDat: string=''
      ): TugGrillaCol;
    function AgrEncabNum(titulo: string; ancho: integer; ColDat: string=''
      ): TugGrillaCol;
    function AgrEncabBool(titulo: string; ancho: integer; ColDat: string=''
      ): TugGrillaCol;
    function AgrEncabDatTim(titulo: string; ancho: integer; ColDat: string=''
      ): TugGrillaCol;
    procedure FinEncab(actualizarGrilla: boolean=true);
    function RowCount: integer;
  public //Manejo de filtros
    procedure LimpiarFiltros;
    function AgregarFiltro(proc: TUtilProcFiltro): integer;
    procedure Filtrar;
    function FilVisibles: integer;
    function FilaVacia(f: integer): boolean;
    procedure MostrarFila(f: integer);
    procedure OcultarFila(f: integer);
    property FilaSelecc: integer read GetFilaSelecc write SetFilaSelecc;
    procedure SeleccFila(f: integer);
    function UltimaFilaVisible: integer;
  public  //Trabajo con tablas de datos TCibTablaMaest
    Table    : TCibTablaMaest;  //Referencia a tabla de datos
    colData: TugGrillaCol;  //Columna con la fila completa de la tabla
    colNumber: TugGrillaCol;  //Columna de la numeración
    procedure IniEncab(tabFuente: TCibTablaMaest);
    procedure ReadFromTable;
    procedure GrillaAReg(f: integer; reg: TCibRegistro);
    procedure UpdateColData(UpdateTable: boolean = false);
    procedure WriteToTable;
    function TableAsString: string;
  public  //Inicialización
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
  ColDat: string): TugGrillaCol;
var
  indColDat: Integer;
begin
  if (Table=nil) or (ColDat='') then begin
    indColDat := -1
  end else begin
    indColDat := Table.FindColPos(ColDat);
    if indColDat = -1 then MsjError := 'No se encuentra columna: ' + ColDat;
  end;
  Result := gri.AgrEncabTxt(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabChr(titulo: string; ancho: integer;
  ColDat: string): TugGrillaCol;
var
  indColDat: Integer;
begin
  if (Table=nil) or (ColDat='') then begin
    indColDat := -1
  end else begin
    indColDat := Table.FindColPos(ColDat);
    if indColDat = -1 then MsjError := 'No se encuentra columna: ' + ColDat;
  end;
  Result := gri.AgrEncabChr(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabNum(titulo: string; ancho: integer;
  ColDat: string): TugGrillaCol;
var
  indColDat: Integer;
begin
  if (Table=nil) or (ColDat='') then begin
    indColDat := -1
  end else begin
    indColDat := Table.FindColPos(ColDat);
    if indColDat = -1 then MsjError := 'No se encuentra columna: ' + ColDat;
  end;
  Result := gri.AgrEncabNum(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabBool(titulo: string; ancho: integer;
  ColDat: string): TugGrillaCol;
var
  indColDat: Integer;
begin
  if (Table=nil) or (ColDat='') then begin
    indColDat := -1
  end else begin
    indColDat := Table.FindColPos(ColDat);
    if indColDat = -1 then MsjError := 'No se encuentra columna: ' + ColDat;
  end;
  Result := gri.AgrEncabBool(titulo, ancho, indColDat);
end;
function TfraEditGrilla.AgrEncabDatTim(titulo: string; ancho: integer;
  ColDat: string): TugGrillaCol;
var
  indColDat: Integer;
begin
  if (Table=nil) or (ColDat='') then begin
    indColDat := -1
  end else begin
    indColDat := Table.FindColPos(ColDat);
    if indColDat = -1 then MsjError := 'No se encuentra columna: ' + ColDat;
  end;
  Result := gri.AgrEncabDatTim(titulo, ancho, indColDat);
end;
procedure TfraEditGrilla.FinEncab(actualizarGrilla: boolean);
begin
  gri.FinEncab(actualizarGrilla);
  if AddRowEnd then begin
    if grilla.RowCount <= 1 then begin
      //Solo hay fila de encabezado
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
procedure TfraEditGrilla.MostrarFila(f: integer);
{Hace visible la fila indicada.}
begin
  if f<0 then exit;
  if f>gri.grilla.RowCount-1 then exit;
  gri.grilla.RowHeights[f] := ALT_FILA_DEF;
end;
procedure TfraEditGrilla.OcultarFila(f: integer);
begin
  if f<0 then exit;
  if f>gri.grilla.RowCount-1 then exit;
  gri.grilla.RowHeights[f] := 0;
end;
function TfraEditGrilla.GetFilaSelecc: integer;
begin
  Result := gri.grilla.Row;
end;
procedure TfraEditGrilla.SetFilaSelecc(AValue: integer);
begin
  if AValue<0 then exit;
  if AValue>gri.grilla.RowCount-1 then exit;
  gri.grilla.Row := AValue;
end;
procedure TfraEditGrilla.SeleccFila(f: integer);
{Selecciona la fila indicada}
begin
  if f<0 then exit;
  if f>gri.grilla.RowCount-1 then exit;
  gri.grilla.Row := f;
end;
function TfraEditGrilla.UltimaFilaVisible: integer;
{Devuelve la última fila visible de la grilla. Si no encuentra ninguna, devuelve -1.}
begin
  Result := UltimaFilaVis(gri.grilla);
end;
//Trabajo con tablas de datos TCibTablaMaest
procedure TfraEditGrilla.IniEncab(tabFuente: TCibTablaMaest);
{Rutina de inicio para definri encabezados, cuando se trabaja con Tablas}
begin
  MsjError := '';
  Table := tabFuente;
  gri.IniEncab;
  colData := AgrEncabTxt('_data' , 250);
  colData.visible := false;
  colNumber := AgrEncabNum('N°' , 25);
  colNumber.editable := false;
end;
procedure TfraEditGrilla.ReadFromTable;
{Llena la grilla, con datos de la tabla de datos. Para que esto funciones se supone
 que la grilla debe estar asoicada a una tabla.
Notar que se guardan datos de todas ls columnas en la columna "colData", en realidad
de toda la tabla, en la grilla, a pesar de que solamente se puedan mostrar solo unas
pocas columnas en la grilla.
Esto es necesario para las opciones de edición, para que funciones aún en tablas sin
clvaes primarias, a pesar de que no es muy óptimo en memoria (y CPU), pero como se aplica
solo a tablas maestras, el tamaño de las tablas es reducido.}
var
  f, c, nCol: Integer;
  n: LongInt;
  reg: TCibRegistro;
begin
  if Table = nil then exit;
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  n := Table.items.Count+1;
  grilla.RowCount:= n;
  f := 1;
  grilla.Cells[colData.idx, 0] := Table.TableHeader;  //Guarda encabezado
  for reg in Table.items do begin
    grilla.Cells[colData.idx, f] := reg.valuesStr;
    //Columna de numeración
    grilla.Cells[colNumber.idx, f] := IntToStr(f);
    //LLena las columnas adicionales de la fila
    for c:=0 to gri.cols.Count-1 do begin
      nCol := gri.cols[c].iEncab;   //Columna de donde se lee el dato
      if nCol = -1 then continue;   //No está asociada a la tabla
      //Escribe valor en la grilla
      case gri.cols[c].tipo of
      ugTipText  : gri.cols[c].ValStr[f]   := reg.values[nCol];
      ugTipBol   : gri.cols[c].ValBool[f]  := f2B(reg.values[nCol]);
      ugTipNum   : gri.cols[c].ValNum[f]   := f2N(reg.values[nCol]);
      ugTipDatTim: gri.cols[c].ValDatTim[f]:= f2D(reg.values[nCol]);
      else
        //Faltan otros tipos
        grilla.Cells[c, f] := reg.values[nCol];
      end;
    end;
    f := f + 1;
  end;
  grilla.EndUpdate();
end;
procedure TfraEditGrilla.GrillaAReg(f: integer; reg: TCibRegistro);
{Convierte una fila de la grilla a un registro de tabla. El objeto "reg", ya debe
estar creado.}
var
  c: Integer;
  strData: String;
  nCol: LongInt;
begin
  //Esta cadena contiene los valores de todas las columnas de la tabla
  strData := grilla.Cells[colData.idx, f];
  if strData = '' then begin
    //Esto puede pasar para cuando se agregan filas nuevas
    //Se deja "reg" con sus columnas vacías
  end else begin
    //Convierte "colData" a "reg"
    reg.valuesStr := strData;  //separa campos
  end;
  //Hasta aquí ya se tiene "reg" con sus columnas actualizadas
  for c:=0 to gri.cols.Count-1 do begin
    nCol := gri.cols[c].iEncab;   //Columna de donde se lee el dato
    if nCol = -1 then continue;   //No está asociada a la tabla
    //reg.values[nCol] := grilla.Cells[c, f];  //actualiza esta columna
    case gri.cols[c].tipo of
    ugTipText  : reg.values[nCol] := gri.cols[c].ValStr[f];
    ugTipBol   : reg.values[nCol] := B2f(gri.cols[c].ValBool[f]);
    ugTipNum   : reg.values[nCol] := N2f(gri.cols[c].ValNum[f]);
    ugTipDatTim: reg.values[nCol] := D2f(gri.cols[c].ValDatTim[f]);
    else
      //Faltan otros tipos
      reg.values[nCol] := grilla.Cells[c, f];
    end;

  end;
end;
procedure TfraEditGrilla.UpdateColData(UpdateTable: boolean = false);
{Actualiza la columan colData, a partir de los valores editados en la grilla.
Este proceso se hace necesario para actualizar los cambios realizados, porque el
proceso de actualización de tablas con TfraEditGrilla, implica que se sobreescribe el
contenido completo de la tabla.
Opcionalmente peude actualizar también la tabla fuente}
var
  f: Integer;
  reg: TCibRegistro;
begin
  if UpdateTable then begin
    Table.items.Clear;  //limpia porque se crearán todos los ítems
    //Se supone que no se cambia la estructura de la tabla, solo los datos.
  end;
  //Este proceso asume que la primera fila es la de los encabezados
  for f:=1 to grilla.RowCount-1 do begin
    {Crea con la cantidad de campos ya definido. Otra opción hubiera sido usar
      reg := TCibRegistro.Create;
    pero esto nos hubiera creado values[] de tamaño cero, y no nos aydua para cuando se
    han crreado filas nuevas en la grilla.}
    reg := Table.AddNewRecord;
    try
      GrillaAReg(f, reg);
      {Hasta aquí ya se actualizaron las columnas que la grilla usa. Las demás quedan
      sin modificar o en blanco (para las filas nuevas)}
      grilla.Cells[colData.idx, f] := reg.valuesStr;  //Cadena actualizda en colData
      if UpdateTable then begin
        //En este modo se agrega el registro
        Table.items.Add(reg);
      end;
    finally
      if not UpdateTable then reg.Destroy;
    end;
  end;
end;
procedure TfraEditGrilla.WriteToTable;
{Actualiza la tabla con el contenido de la grilla}
begin
  UpdateColData(true);
end;
function TfraEditGrilla.TableAsString: string;
{Devuelve el contenido de la tabla modificada, como una cadena.}
var
  lineas: TStringList;
  f: Integer;
begin
  UpdateColData(false);
  //Junta los valores de "colData", usando un StringList, porque se espera que sea más
  //eficiente que concatenar cadenas.
  try
    lineas := TStringList.Create;
    //Notar que se incluye también el encabezado
    for f := 0 to grilla.RowCount-1 do begin
      lineas.Add(grilla.Cells[colData.idx, f]);
    end;
    Result := lineas.Text;
  finally
    lineas.Destroy;
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
  if OnGrillaModif<>nil then OnGrillaModif(umdFilModif, grilla.Row);
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
procedure TfraEditGrilla.NumerarFilas;
//Pone el ordinal en la columna colNum
var
  f: Integer;
begin
  //gri.NumerarFilas;  No se usa porque nuestra columna de numeración no es la cero
  grilla.BeginUpdate;
  for f:=1 to grilla.RowCount-1 do begin
    grilla.Cells[colNumber.idx, f] := IntToStr(f);
  end;
  grilla.EndUpdate;
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
function TfraEditGrilla.BuscarTxt(txt: string; col: integer): integer;
{Realiza la búsqueda de un texto, de forma literal, en la columna indicada. devuelve el
número de fila donde se encuentra. SI no encuentra, devuelve -1.}
begin
  Result := gri.BuscarTxt(txt, col);
end;
procedure TfraEditGrilla.gri_KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{Configura los accesos de teclado de la grilla. Se configuran aquí, y no con atajos de las
acciones, porque se quiere que estos accesos solo funciones cuando la grilla tiene
el enfoque.}
var
  filAct, uFil, f: Integer;
begin
  if OnGrillaKeyDown<>nil then OnGrillaKeyDown(Sender, Key, Shift);
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
    if (grilla.Row = uFil) and AddRowEnter then begin
      //Está en la última fila. Agrega una fila al final.
      grilla.InsertColRow(false, grilla.RowCount);
      f := grilla.RowCount-1;  //fila agregada
      //Llena los campos por defecto.
      if OnReqNuevoReg<>nil then OnReqNuevoReg(f);
      //Ubica fila seleccionada
      grilla.Row := f;
      grilla.Col := 1;
      //Actualiza
      NumerarFilas;
      Modificado := true;
      if OnGrillaModif<>nil then OnGrillaModif(umdFilAgre, grilla.Row);
    end;
  end;
  if (Shift = [ssCtrl]) and (Key = VK_DELETE) then begin
    acEdiEliminExecute(Self);
  end;
end;
procedure TfraEditGrilla.gri_FinEditarCelda(var eveSal: TEvSalida; col,
  fil: integer; var ValorAnter, ValorNuev: string);
{Se va a terminar la edición de una celda. Aprovechamos para implementar el
manejo de fórmulas.}
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
      //Hubo error en la validación
      MsgExc(gri.MsjError);
    end else begin
      //No se produjo error
      if OnCeldaEditada<>nil then OnCeldaEditada(eveSal, col, fil, ValorAnter, ValorNuev);
      //Continúa con la edición
      //Se procede a terminar la edición
      gri.OcultContrEdicion;
      grilla.Cells[col, fil] := ValorNuev;  //acepta valor
      if eveSal in [evsTecEnter, evsTecTab, evsTecDer] then begin
        MovASiguienteColVis(grilla);   //pasa a siguiente columna
      end;
      if gri.OnModificado<>nil then gri.OnModificado();
    end;
    eveSal := evsNulo;   //Con esto se cancela el procesamiento posterior
  end;
end;
function TfraEditGrilla.gri_LeerColorFondo(col, fil: integer; EsSelec: boolean): TColor;
begin
  if OnLeerColorFondo<>nil then Result := OnLeerColorFondo(col, fil, EsSelec)
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
  gri.OnMouseUpNoCell :=@griMouseUpNoCell;
  gri.OnKeyDown       := @gri_KeyDown;
  gri.OnFinEditarCelda:= @gri_FinEditarCelda;
  gri.OnLeerColorFondo:= @gri_LeerColorFondo;
  gri.OnLlenarLista   := @gri_LlenarLista;
  gri.OnModificado    := @griModificado;
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
  NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilMovid, grilla.Row);
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
  NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilMovid, grilla.Row);
end;
procedure TfraEditGrilla.acEdiCopFilExecute(Sender: TObject);
begin
  gri.CopiarFila;
end;
procedure TfraEditGrilla.acEdiPegarExecute(Sender: TObject);
begin
  gri.PegarACampo;
  //Habría que ver. si en realida lo modifica
  if OnGrillaModif<>nil then OnGrillaModif(umdFilModif, grilla.Row);
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
  NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilAgre, grilla.Row);
end;
procedure TfraEditGrilla.acEdiEliminExecute(Sender: TObject);
{Elimina el registro seleccionado.}
var
  tmp: String;
begin
  if grilla.Row<1 then exit;;
//  tmp := colDescri.ValStr[grilla.Row];
  tmp := grilla.Cells[colNumber.idx, grilla.Row];
  if MsgYesNo('¿Eliminar registro: ' + tmp + '?') <> 1 then exit ;
  //Se debe eliminar el registro seleccionado
  grilla.DeleteRow(grilla.Row);
  //Actualiza
  NumerarFilas;
  Modificado := true;
  if OnGrillaModif<>nil then OnGrillaModif(umdFilElim, grilla.Row);
end;
end.

