{Implementa el formulario explorador de la cabina}
unit FormExplorCab;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, LazFileUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, ActnList, Menus, ComCtrls, Grids, CibFacturables,
  CibTramas, UtilsGrilla, MisUtils;

type

  { TfrmExplorCab }

  TfrmExplorCab = class(TForm)
    acArcTraer: TAction;
    acPCVerPant: TAction;
    acPCReinic: TAction;
    acPCApag: TAction;
    acPCBloquear: TAction;
    acPCDesbloq: TAction;
    acArcPoner: TAction;
    acArcElim: TAction;
    acArcAbrir: TAction;
    acVerRefresc: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    btnReinic: TBitBtn;
    btnApagar: TBitBtn;
    BitBtn5: TBitBtn;
    btnBloqDesb: TButton;
    Edit1: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    lblNomPC1: TStaticText;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    picPant: TImage;
    lblNomPC: TStaticText;
    PopupMenu1: TPopupMenu;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    TreeView1: TTreeView;
    txtFec: TStaticText;
    procedure acArcAbrirExecute(Sender: TObject);
    procedure acArcElimExecute(Sender: TObject);
    procedure acArcPonerExecute(Sender: TObject);
    procedure acArcTraerExecute(Sender: TObject);
    procedure acPCApagExecute(Sender: TObject);
    procedure acPCBloquearExecute(Sender: TObject);
    procedure acPCDesbloqExecute(Sender: TObject);
    procedure acPCReinicExecute(Sender: TObject);
    procedure acPCVerPantExecute(Sender: TObject);
    procedure acVerRefrescExecute(Sender: TObject);
    procedure btnApagarClick(Sender: TObject);
    procedure btnReinicClick(Sender: TObject);
    procedure btnBloqDesbClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure picPantClick(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
  private
    fac: TCibFac;
    UtilGrilla: TUtilGrilla;
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  public
    procedure EstadoControles(estad: boolean);
    procedure LlenarLista(lista: string);
    procedure Exec(fac0: TCibFac);
  end;

var
  frmExplorCab: TfrmExplorCab;

implementation
uses CibGFacCabinas;
{$R *.lfm}
{ TfrmExplorCab }
procedure TfrmExplorCab.Timer1Timer(Sender: TObject);
var
  cab : TCibFacCabina;
begin
  if not self.Visible then exit;
  cab := TCibFacCabina(fac);
  //Actualiza campos
  lblNomPC.Caption:=cab.NombrePC;
  txtFec.Caption:= DateToStr(cab.HoraPC) + LineEnding +
                   TimeToStr(cab.HoraPC);
  if cab.PantBloq then btnBloqDesb.Caption:='Desbloquear'
  else btnBloqDesb.Caption:='Bloquear';
end;
procedure TfrmExplorCab.picPantClick(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  acPCVerPantExecute(self);
end;
procedure TfrmExplorCab.StringGrid1DblClick(Sender: TObject);
begin
  acArcAbrirExecute(self);
end;
procedure TfrmExplorCab.btnBloqDesbClick(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  if btnBloqDesb.Caption='Bloquear' then begin
    acPCBloquearExecute(self);//Manda comando de bloqueo
  end else begin
    acPCDesbloqExecute(self);
  end;
end;
procedure TfrmExplorCab.btnReinicClick(Sender: TObject);
begin
  acPCReinicExecute(self);
end;
procedure TfrmExplorCab.btnApagarClick(Sender: TObject);
begin
  acPCApagExecute(self);
end;
procedure TfrmExplorCab.TreeView1DblClick(Sender: TObject);
var
  cab: TCibFacCabina;
  rut: String;
begin
  if TreeView1.Selected=nil then exit;
  cab := TCibFacCabina(fac);
  rut := TreeView1.Selected.Text;
  EstadoControles(false);
  case rut of
  'Escritorio': cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJRUT, 0, cab.IdFac);
  'C:\'       : cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJRUT, 0, cab.IdFac + #9 + rut);
  'D:\'       : cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJRUT, 0, cab.IdFac + #9 + rut);
  end;
  StatusBar1.Panels[0].Text:='Leyendo directorio...';
end;
procedure TfrmExplorCab.LlenarLista(lista: string);
{Recibe la lista de archivos y la llena en la grilla}
var
  archivos: TStringList;
  fil: Integer;
  lin: String;
begin
  archivos := TStringList.Create;
  archivos.Text:=lista;   //divide en filas
  StringGrid1.RowCount:=archivos.Count+2;  //considera la entrada '..'
  //Agrega entrada al directoprio padre
  fil := 1;
  StringGrid1.Cells[1,fil] := '..';
  StringGrid1.Cells[2,fil] := 'Folder';
  Inc(fil);
  //Agrega el resto de archivos
  for lin in archivos do begin
    if lin='' then begin
      StringGrid1.Cells[1,fil] := '';
      StringGrid1.Cells[2,fil] := '???';
    end;
    if lin[1] = '[' then begin  //Es carpeta
      StringGrid1.Cells[1,fil] := copy(lin,2,length(lin)-2);
      StringGrid1.Cells[2,fil] := 'Folder';
    end else begin   //Es archivo
      StringGrid1.Cells[1,fil] := lin;
      StringGrid1.Cells[2,fil] := ExtractFileExt(lin);
    end;
    Inc(fil);
  end;
  StatusBar1.Panels[1].Text:= IntToStr(archivos.Count) + ' elementos.';
  archivos.Destroy;
end;
procedure TfrmExplorCab.StringGrid1DrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  txt: String;           // texto de la celda
  cv: TCanvas;           //referencia al lienzo
begin
  cv := StringGrid1.Canvas;  //referencia al Lienzo
  txt := StringGrid1.Cells[ACol,ARow];
  //cv.Font.Color := clBlack;
  //cv.Font.Style := [];
  if gdFixed in aState then begin
    //Es una celda fija
    cv.Brush.Color := clBtnFace;
    cv.FillRect(aRect);   //fondo
    cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
  end else begin
    //Es una celda común
    if aRow = StringGrid1.Row then begin
      cv.Brush.Color := clBtnFace;
    end else begin
      cv.Brush.Color := clWhite;  //fondo blanco
    end;
    cv.FillRect(aRect);   //fondo
    cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
    // Dibuja ícono
    if (aCol=0) and (aRow>0) then begin
      case StringGrid1.Cells[2,ARow] of
      'Folder': ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 4);
      else
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 5);
      end;
    end;
    //Dibuja borde en celda seleccionada
//    if gdFocused in aState then begin
//      cv.Pen.Color:=clGray;
//      cv.Frame(aRect);  //dibuja borde
//    end;
  end;
end;
procedure TfrmExplorCab.FormCreate(Sender: TObject);
var
  Item: TTreeNode;
begin
  UtilGrilla := TUtilGrilla.Create(StringGrid1);
  UtilGrilla.IniEncab;
  UtilGrilla.AgrEncabTxt('', 20);
  UtilGrilla.AgrEncabTxt('Nombre', 160);
  UtilGrilla.AgrEncabTxt('Tipo'  , 60);
  UtilGrilla.AgrEncabNum('Tamaño', 60).visible:=false;
  UtilGrilla.AgrEncabNum('Fecha' , 70).visible:=false;
  UtilGrilla.FinEncab;
  UtilGrilla.OpDimensColumnas:=true;
  UtilGrilla.OpEncabezPulsable:=true;
  UtilGrilla.OpOrdenarConClick:=true;
  UtilGrilla.MenuCampos:=true;

  StringGrid1.FixedCols:=0;
  StringGrid1.DefaultDrawing:=false;
  StringGrid1.OnDrawCell:=@StringGrid1DrawCell;
  StringGrid1.Options:=StringGrid1.Options+[goRowHighlight];
  StringGrid1.Options:=StringGrid1.Options-[goVertLine];
  StringGrid1.Options:=StringGrid1.Options-[goHorzLine];

  Item := TreeView1.Items.AddChild(nil, 'Escritorio');
  Item.ImageIndex:=0;    //cambia ícono del nodo
  Item.SelectedIndex := 0;
//  Item := TreeView1.Items.AddChild(nil, 'Equipo');
//  Item.ImageIndex:=1;    //cambia ícono del nodo
//  Item.SelectedIndex := 1;
//  Item := TreeView1.Items.AddChild(nil, 'Documentos');
//  Item.ImageIndex:=2;    //cambia ícono del nodo
//  Item.SelectedIndex := 2;
  Item := TreeView1.Items.AddChild(nil, 'C:\');
  Item.ImageIndex:=3;    //cambia ícono del nodo
  Item.SelectedIndex := 3;
  Item := TreeView1.Items.AddChild(nil, 'D:\');
  Item.ImageIndex:=3;    //cambia ícono del nodo
  Item.SelectedIndex := 3;
end;
procedure TfrmExplorCab.FormDestroy(Sender: TObject);
begin
  UtilGrilla.Destroy;
end;
procedure TfrmExplorCab.Exec(fac0: TCibFac);
{Inicializa y muestra el formulario de Exploración de archivos. Se necesita la referencia
a un Visor de Cabinas, ya que se ha diseñado para trabajar con este objeto como fuente,
de modo que se pueda usar tanto en el CIBERPLEX-Server como en CIBERPLEX-Visor}
begin
  fac := fac0;
  Caption := 'Explorador de Archivos - ' + fac.Nombre;
  self.Show;
end;
procedure TfrmExplorCab.EstadoControles(estad: boolean);
begin
  acArcAbrir.Enabled:=estad;
  acArcTraer.Enabled:=estad;
  acArcPoner.Enabled:=estad;
  acArcElim.Enabled :=estad;
  StringGrid1.Enabled:=estad;
  Invalidate;
end;
// Acciones de archivo
procedure TfrmExplorCab.acArcTraerExecute(Sender: TObject);
var
  cab: TCibFacCabina;
  fil: Integer;
  arc: String;
begin
  cab := TCibFacCabina(fac);
  fil := StringGrid1.Row;
  if fil = -1 then exit;   //Verifica archivo seleccionado
  arc := StringGrid1.Cells[1, fil];
  //Envía solicitud de listar archivos a la PC cliente
  EstadoControles(false);
  cab.arcSal := arc;    {Fija nombre de archivo para cuando llegue, porque la trama no
                         incluye el nombre de archivo (Ojo que estamos en el visor).
}
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_ARCSOL, 0, cab.IdFac + #9 + arc);
  StatusBar1.Panels[0].Text:='Trayendo archivo ...';
end;
procedure TfrmExplorCab.acArcPonerExecute(Sender: TObject);
var
  cab: TCibFacCabina;
  arc, cad: String;
begin
  if not OpenDialog1.Execute then exit;
  cab := TCibFacCabina(fac);
  arc := OpenDialog1.FileName;
  if not FileExistsUTF8(arc) then exit;
  //Fija nombre
  cad := ExtractFileName(arc);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJARSAL, 0, cab.IdFac + #9 + cad);
  //Envía contenido
  cad := StringFromFile(arc);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_ARCENV, 0, cab.IdFac + #9 + cad);
  StatusBar1.Panels[0].Text:='Enviando archivo ...';
end;
procedure TfrmExplorCab.acArcElimExecute(Sender: TObject);
var
  cab: TCibFacCabina;
  fil: Integer;
  arc: String;
begin
  cab := TCibFacCabina(fac);
  fil := StringGrid1.Row;
  if fil = -1 then exit;   //Verifica archivo seleccionado
  arc := StringGrid1.Cells[1, fil];
  //Envía solicitud de listar archivos a la PC cliente
  cab.arcSal := arc;    {Fija nombre de archivo para cuando llegue, porque la trama no
                         incluye el nombre de archivo (Ojo que estamos en el visor).
}
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_ELIARCHI, 0, cab.IdFac + #9 + arc);
  StatusBar1.Panels[0].Text:='Eliminando archivo ...';
end;
procedure TfrmExplorCab.acArcAbrirExecute(Sender: TObject);
var
  fil: Integer;
  arc: String;
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  fil := StringGrid1.Row;
  if fil = -1 then exit;
  //Verifica si es carpeta
  arc := StringGrid1.Cells[1, fil];
  if StringGrid1.Cells[2,fil] = 'Folder' then begin
    //Doble Click en Folder Envía comando de cambio de ruta
    cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJRUT, 0, cab.IdFac + #9 + arc);
    StatusBar1.Panels[0].Text:='Accediendo directorio...';
    exit;
  end;
  //Es acrhivo
  acArcTraerExecute(self);
  //Espera a que llegue
{  Me.mnEliminar.Enabled = False
  Me.mnAbrirRem.Enabled = False
  Me.mnEliminar.Enabled = False
  Me.mnRefres.Enabled = False
  Me.mnTraer.Enabled = False
  Me.mnPoner.Enabled = False
  nesp = 0
  CancelEsp = False
  ArcRecib = False
  While Not ArcRecib And nesp < 300 And Not CancelEsp
      Sleep 100
      DoEvents
      nesp = nesp + 1
  Wend
  Me.mnEliminar.Enabled = True
  Me.mnAbrirRem.Enabled = True
  Me.mnEliminar.Enabled = True
  Me.mnRefres.Enabled = True
  Me.mnTraer.Enabled = True
  Me.mnPoner.Enabled = True
  If nesp >= 300 Then
      'Se desbordó
      lblEstado = "Tiempo de espera excedido."
  ElseIf CancelEsp Then
      'se canceló la transferencia
      lblEstado = "Transferencia cancelada."
  Else
      CambiaDir CarpetaArc    'nos movemos
      'luego lo ejecuta
      Shell "CMD /C start ""TITULO"" """ & arcSal & """"
  End If
  On Error GoTo 0
  Exit Sub
ErrCEL:
  MsgBox "Error abriendo archivo: " & arc, vbExclamation
  On Error GoTo 0
}
end;
// Acciones Ver
procedure TfrmExplorCab.acVerRefrescExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  StringGrid1.RowCount:=1;
  cab := TCibFacCabina(fac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_SOLRUT_A, 0, cab.IdFac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_LISARC, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Refrescando ...';
end;
procedure TfrmExplorCab.acPCVerPantExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  //Solicita captura de pantalla
  picPant.Picture := nil;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_PANTA, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Leyendo pantalla...';
end;
procedure TfrmExplorCab.acPCReinicExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  if MsgYesNo('¿Desea reiniciar PC: ' + cab.Nombre + '?')<>1 then exit;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_REINPC, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Reiniciando PC ...';
end;
procedure TfrmExplorCab.acPCApagExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  if MsgYesNo('¿Desea apagar PC: ' + cab.Nombre + '?')<>1 then exit;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_APAGPC, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Apagando PC ...';
end;
procedure TfrmExplorCab.acPCBloquearExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_BLOQU, 0, cab.IdFac);
end;
procedure TfrmExplorCab.acPCDesbloqExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_DESBL, 0, cab.IdFac);
end;

end.

