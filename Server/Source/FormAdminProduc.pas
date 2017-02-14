{Formualrio para la ediciónm de los productos}
unit FormAdminProduc;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  ExtCtrls, Buttons, Menus, ActnList, StdCtrls, ComCtrls, LCLProc, LCLType,
  UtilsGrilla, CibProductos, FormConfig, FrameUtilsGrilla, MisUtils;
type
  { TfrmAdminProduc }
  TfrmAdminProduc = class(TForm)
    acArcSalir: TAction;
    acEdiNuevo: TAction;
    acEdiModif: TAction;
    acEdiElimin: TAction;
    acArcAplicar: TAction;
    ActionList1: TActionList;
    btnCerrar: TBitBtn;
    btnAplicar: TBitBtn;
    fraUtilsGrilla1: TfraUtilsGrilla;
    ImageList1: TImageList;
    lblFiltCateg: TLabel;
    lblNumRegist: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    Panel1: TPanel;
    grilla: TStringGrid;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    btnCerrPanel: TSpeedButton;
    btnArbolCat: TSpeedButton;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    procedure acArcAplicarExecute(Sender: TObject);
    procedure acEdiEliminExecute(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnCerrPanelClick(Sender: TObject);
    procedure btnArbolCatClick(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    gri : TUtilGrilla;
    TabPro: TCibTabProduc;
    Modificado : boolean;
    FiltroPorTxt: Boolean;
    procedure AplicarFiltroArbolCat(var pasan: integer; out DescFilt: string);
    procedure fraUtilsGrilla1Filtrado;
    function GrillaALista: boolean;
    procedure gri_MouseUpCell(Button: TMouseButton; row, col: integer);
    function HayFiltroArbolCat: boolean;
    procedure LeerCategorias;
    procedure ListaAGrilla;
    procedure MensajeRegistros(numRegist: integer);
    procedure MensajeVisibles(n: Integer; textAdic: string; col: TColor=clBlack);
  public
    procedure Exec(TabPro0: TCibTabProduc);
  end;

var
  frmAdminProduc: TfrmAdminProduc;

implementation
{$R *.lfm}

{ TfrmAdminProduc }
procedure TfrmAdminProduc.MensajeVisibles(n: Integer; textAdic: string;
          col: TColor = clBlack);
{Muestra un mensje con los ítems visibles en "lblNumRegist".}
var
  tot: Integer;
begin
  tot := grilla.RowCount-1;  //total de elementos
  lblNumRegist.Font.Color:= col;
  if n = 0 then begin
    lblNumRegist.Caption := 'Sin registros visibles. ' + textAdic;
  end else if n = 1 then begin
    if n=tot then begin
      lblNumRegist.Caption := '1 registro visible. ' + textAdic
    end else begin
      lblNumRegist.Caption := '1 de ' + IntToStr(tot) + ' registro visible. ' +textAdic
    end;
  end else begin
    if n=tot then begin
      lblNumRegist.Caption := IntToStr(n) + ' registros visibles. ' + textAdic
    end else begin
      lblNumRegist.Caption := IntToStr(n) + ' de ' + IntToStr(tot) + ' registros visibles. ' + textAdic;
    end;
  end;
end;
procedure TfrmAdminProduc.MensajeRegistros(numRegist: integer);
{ACtualiza el mensaje a poner en "lblNumregist". Para ello, Se leen las variables:
FiltroPorTxt, FiltroPorCat, y la cantidad de filas indicadas en "numRegist".
Si "numRegist" es -1, se procede a realizar un conteo de las filas visibles.}
var
  f: Integer;
begin
  if numRegist=-1 then begin
    //Se cuenta las filas que están visibles.
    numRegist := 0;
    for f:=1 to grilla.RowCount-1 do begin
      //Verifica si está filtrada
      if grilla.RowHeights[f]>0 then Inc(numRegist);
    end;
  end;
  if FiltroPorTxt then
    MensajeVisibles(numRegist, 'Filtrado por: "' + fraUtilsGrilla1.Edit1.Text + '"', clBlue)
  else  //Sin filtros.
    MensajeVisibles(numRegist, '');
end;
procedure TfrmAdminProduc.fraUtilsGrilla1Filtrado;
var
  pasan: integer;
  DescFilt: string;
begin
  FiltroPorTxt := true;
  if fraUtilsGrilla1.SinTexto then begin
    FiltroPorTxt := false;
  end;
  pasan := fraUtilsGrilla1.filVisibles;  //cantidad de filas que pasaan el filtro
  //Ya se filtró por combo, ahora filtra por Árbol.
  if HayFiltroArbolCat then begin
    AplicarFiltroArbolCat(pasan, DescFilt);
    lblFiltCateg.Visible:=true;
    lblFiltCateg.Caption:=DescFilt;
  end else begin
    lblFiltCateg.Visible:=false;
  end;
  //Ya actualizó FiltroPorTxt y FiltroPorCat.
  MensajeRegistros(pasan);
end;
procedure TfrmAdminProduc.LeerCategorias;
  function ExisteCategEnArbol(cat: string): boolean;
  var
    it : TTreeNode;
  begin
    for it in TreeView1.Items do begin
      if (it.Level = 1) and (it.Text = cat) then
        exit(true);
    end;
    exit(false);
  end;
  function ExisteSubCateg(cat, subcat: string): boolean;
  var
    it : TTreeNode;
  begin
    for it in TreeView1.Items do begin
      if (it.Level = 2) and (it.Text = subcat) and (it.Parent.Text = cat) then
        exit(true);
    end;
    exit(false);
  end;
var
  reg, reg2: TregProdu;
  nodRaiz, nodCat, nodSub: TTreeNode;
begin
  //Configura árbol de categorías
  TreeView1.Items.BeginUpdate;
  TreeView1.Items.Clear;
  nodRaiz := TreeView1.Items.AddChild(nil,'Productos');
  nodRaiz.ImageIndex := 0;
  nodRaiz.SelectedIndex := 0;
  for reg in TabPro.Productos do begin
    if not ExisteCategEnArbol(reg.cat) then begin
      //No existe, crea un nuevo nodo
      nodCat := TreeView1.Items.AddChild(nodRaiz, reg.cat);
      nodCat.ImageIndex := 1;
      nodCat.SelectedIndex := 1;
      //Llena de subcategorías
      for reg2 in TabPro.Productos do begin
        if (reg2.cat = reg.cat) and not ExisteSubCateg(reg2.cat, reg2.subcat) then begin
          nodSub := TreeView1.Items.AddChild(nodCat, reg2.subcat);
          nodSub.ImageIndex := 2;
          nodSub.SelectedIndex := 2;
        end;
      end;
    end;
  end;
  nodRaiz.Expanded:=true;
  nodRaiz.Selected:=true;
  TreeView1.Items.EndUpdate;
end;
procedure TfrmAdminProduc.ListaAGrilla;
{Mueve datos de la lista a la grills}
var
  f: Integer;
  reg: TregProdu;
  n: LongInt;
begin
  grilla.BeginUpdate;
  grilla.RowCount:=1;  //limpia datos
  n := TabPro.Productos.Count+1;
  grilla.RowCount:= n;
  f := 1;
  for reg in TabPro.Productos do begin
    grilla.Cells[1,f] := reg.cod;
    grilla.Cells[2,f] := reg.cat;
    grilla.Cells[3,f] := reg.subcat;
    grilla.Cells[4,f] := CadMoneda(reg.pUnit);
    grilla.Cells[5,f] := reg.desc;
    grilla.Cells[6,f] := FloatToStr(reg.stock);
    grilla.Cells[7,f] := reg.Marca;
    grilla.Cells[8,f] := reg.UnidComp;
    f := f + 1;
  end;
  grilla.EndUpdate();
end;
function TfrmAdminProduc.GrillaALista: boolean;
{Mueve datos de la grills a la lista. Si enuenctra error, devuelve FALSE}
var
  f: Integer;
  reg: TregProdu;
  tmp: Double;
begin
  //Hace una verificación, antes de grabar
  try
    for f:=1 to grilla.RowCount-1 do begin
      tmp  := LeeMoneda(grilla.Cells[4,f]);
      tmp  := StrToFloat(grilla.Cells[6,f]);
    end;
  except
    MsgExc('Error en datos de file');
    grilla.Row:=f;
    grilla.SetFocus;
    exit(false);
  end;
  //Mueve datos a la lista. Ya no debería fallar esta parte
  TabPro.Productos.Clear;
  for f:=1 to grilla.RowCount-1 do begin
    reg := TregProdu.Create;
    reg.cod       := grilla.Cells[1,f];
    reg.cat       := grilla.Cells[2,f];
    reg.subcat    := grilla.Cells[3,f];
    reg.pUnit     := LeeMoneda(grilla.Cells[4,f]);
    reg.desc      := grilla.Cells[5,f];
    reg.stock     := StrToFloat(grilla.Cells[6,f]);
    reg.Marca     := grilla.Cells[7, f];
    reg.UnidComp  := grilla.Cells[8, f];
    TabPro.Productos.Add(reg);
  end;
  exit(true);
end;
procedure TfrmAdminProduc.gri_MouseUpCell(Button: TMouseButton; row, col: integer);
begin
  if Button = mbRight then begin
    PopupMenu1.PopUp;
  end;
end;
procedure TfrmAdminProduc.Exec(TabPro0: TCibTabProduc);
begin
  TabPro := TabPro0;
  LeerCategorias;
  ListaAGrilla;  //Hace el llenaado inicial de productos
  fraUtilsGrilla1.AplicarFiltro; //Para actualizar mensajaes y variables de estado.
  self.Show;
end;
procedure TfrmAdminProduc.FormCreate(Sender: TObject);
begin
  //Configura grilla
  gri := TUtilGrilla.Create(grilla);
  gri.IniEncab;
  gri.AgrEncabNum('N°'           , 25);
  gri.AgrEncabTxt('CÓDIGO'       , 60);
  gri.AgrEncabTxt('CATEGORÍA'    , 70);
  gri.AgrEncabTxt('SUBCATEGORÍA' , 80);
  gri.AgrEncabNum('PRC.UNITARIO' , 55);
  gri.AgrEncabTxt('DESCRIPCIÓN'  ,180);
  gri.AgrEncabNum('STOCK'        , 40);
  gri.AgrEncabTxt('MARCA'        , 50).visible:=false;
  gri.AgrEncabTxt('UNID. DE COMPRA', 70).visible:=false;
  gri.FinEncab;
  gri.OpAutoNumeracion:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  gri.UsarFrameUtils(fraUtilsGrilla1, nil);
  gri.UsarTodosCamposFiltro(4);
  gri.MenuCampos:=true;
  gri.OpResaltFilaSelec:=true;
  gri.OnMouseUpCell:=@gri_MouseUpCell;
  fraUtilsGrilla1.OnFiltrado:=@fraUtilsGrilla1Filtrado;
end;
procedure TfrmAdminProduc.FormDestroy(Sender: TObject);
begin
  gri.Destroy;
end;
procedure TfrmAdminProduc.btnCerrPanelClick(Sender: TObject);
begin
  Panel3.Visible:=false;
  btnArbolCat.Down := false;
  fraUtilsGrilla1.AplicarFiltro;
end;
procedure TfrmAdminProduc.btnArbolCatClick(Sender: TObject);
begin
  Panel3.Visible := btnArbolCat.Down;
  fraUtilsGrilla1.AplicarFiltro;
end;
function TfrmAdminProduc.HayFiltroArbolCat: boolean;
{Indica si el árbol de categorías, está en modo de filtro. }
begin
  if Panel3.Visible and (TreeView1.Selected<>nil) then begin
    exit(true);
  end;
  exit(false);
end;
procedure TfrmAdminProduc.AplicarFiltroArbolCat(var pasan: integer; out
  DescFilt: string);
{Aplica el filtro de acuerdo al nodo seleccionado en el árbol de categorías.
 Este filtro no reinicia, las filas ocultas previamente, sino que oculta las filas
 adicionales que no cumplan con el criterio.}
var
  f: Integer;
  nodSel, nodPad: String;
begin
  //Aplica siguiente filtro, de categoría
  DescFilt := '';
  if TreeView1.Selected = nil then exit;   //no hay seleccionado
  nodSel := TreeView1.Selected.Text;  //nombre de nodo actual
  if TreeView1.Selected.Level = 0 then begin   //Almacén seleccionado.
    //Pasan todos
  end else if TreeView1.Selected.Level = 1 then begin  //Categoría seleccionada
    DescFilt := 'Filtrado por Categoría: "' + nodSel + '"';
    pasan := 0;
    for f:=1 to grilla.RowCount-1 do begin
      if grilla.Cells[2, f] = nodSel then begin
      end else begin
        grilla.RowHeights[f] := 0;
      end;
      //Verifica si está filtrada
      if grilla.RowHeights[f]>0 then Inc(pasan);
    end;
  end else if TreeView1.Selected.Level = 2 then begin  //Categoría seleccionada
    nodPad := TreeView1.Selected.Parent.Text;  //nombre de nodo padre
    DescFilt := 'Filtrado por: "' + nodPad + '-' + nodSel + '"';
    pasan := 0;
    for f:=1 to grilla.RowCount-1 do begin
      if (grilla.Cells[2, f] = nodPad) and
         (grilla.Cells[3, f] = nodSel) then begin
      end else begin
        grilla.RowHeights[f] := 0;
      end;
      //Verifica si está filtrada
      if grilla.RowHeights[f]>0 then Inc(pasan);
    end;
  end;
end;
procedure TfrmAdminProduc.TreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    fraUtilsGrilla1.AplicarFiltro;  //aplica filtro de combo
  end;
end;
procedure TfrmAdminProduc.TreeView1DblClick(Sender: TObject);
begin
  fraUtilsGrilla1.AplicarFiltro;  //aplica filtro de combo
end;
procedure TfrmAdminProduc.acEdiEliminExecute(Sender: TObject);
{Elimina el registro seleccionado.}
begin
  if grilla.Row<1 then exit;;
  if MsgYesNo('¿Eliminar registro?') <> 1 then exit ;
  //Se debe eliminar el registro seleccionado
  grilla.DeleteRow(grilla.Row);
  MensajeRegistros(-1);
  Modificado := true;
end;
procedure TfrmAdminProduc.btnCerrarClick(Sender: TObject);
begin
  Self.Close;
end;
procedure TfrmAdminProduc.acArcAplicarExecute(Sender: TObject);
{Aplica los cambios a la tabla}
begin
  if not GrillaALista then exit;
  TabPro.GrabarProductos;
  Modificado := false;
end;


end.

