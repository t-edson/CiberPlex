{Formulario para adiministración de Cabinas. No es un visor de cabinas, sino que
 es más como una ventana de configuración que permite crear y eliminar cabinas.
 No se incluye directamente en como Frame de configuración, porque el espacio
 de ventana ahí es muy grande y porque la eliminación de cabinas puede tomar
 cierto tiempo, y se complica el uso de los botones "Aplicar" o "Aceptar"}
unit FormAdminCabinas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Grids,
  Buttons, ExtCtrls, StdCtrls, Menus, LCLProc, LCLType, MisUtils,
  CPGrupoCabinas, CPFacturables;

type

  { TfrmAdminCabinas }

  TfrmAdminCabinas = class(TForm)
    btnAgregar: TBitBtn;
    btnEliminar: TBitBtn;
    btnRefrescar: TBitBtn;
    ComboBox1: TComboBox;
    ImageList1: TImageList;
    Label1: TLabel;
    MenuItem1: TMenuItem;
    mnActConex: TMenuItem;
    mnDesConex: TMenuItem;
    mnRefres: TMenuItem;
    mnConecTod: TMenuItem;
    mnDesconTod: TMenuItem;
    MenuItem2: TMenuItem;
    mnAgregCab: TMenuItem;
    mnElimCab: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    StringGrid1: TStringGrid;
    procedure btnAgregarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnRefrescarClick(Sender: TObject);
    procedure ComboBox1EditingDone(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnActConexClick(Sender: TObject);
    procedure mnDesConexClick(Sender: TObject);
    procedure mnAgregCabClick(Sender: TObject);
    procedure mnConecTodClick(Sender: TObject);
    procedure mnDesconTodClick(Sender: TObject);
    procedure mnElimCabClick(Sender: TObject);
    procedure mnRefresClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1EditingDone(Sender: TObject);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  private
    valAntCel : string;     //valor aterior de la celda en edición
    cabEnEdic : TCPCabina;  //cabina que se está editando
    DesactRefresco: boolean; //desacttiva el refresco de la grilla
    function CabinaSeleccionada: TCPCabina;
    function CeldaSeleccionada: string;
    procedure ModificarCeldaActual;
  public
    grpCab: TCPGrupoCabinas;  //referencia al grupo de cabinas
    procedure RefrescarGrilla;
  end;

var
  frmAdminCabinas: TfrmAdminCabinas;

implementation
{$R *.lfm}

{ TfrmAdminCabinas }
function TfrmAdminCabinas.CeldaSeleccionada: string;
var
  fsel, csel: Integer;
begin
  fsel := StringGrid1.Row;
  csel := StringGrid1.Col;
  Result := StringGrid1.Cells[csel, fsel];
end;
function TfrmAdminCabinas.CabinaSeleccionada: TCPCabina;
{Devuelve una referecnia a la cabina seleccionada en la grilla. }
var
  fsel: Integer;
  nomb: String;
begin
  fsel := StringGrid1.Row;
  nomb := StringGrid1.Cells[0, fsel];
  if grpCab= nil then exit(nil);
  Result := grpCab.CabPorNombre(nomb);
end;
procedure TfrmAdminCabinas.ModificarCeldaActual;
var
  fsel: Integer;
  n: Double;
begin
  if cabEnEdic = nil then exit;
  debugln('-Modificando cabina: ' + cabEnEdic.Nombre);
  //Modifica a la cabina seleccionada
  fsel := StringGrid1.Row;
  cabEnEdic.MsjError:='';  //prepara para ver errores
  cabEnEdic.Nombre:= StringGrid1.Cells[0, fsel];
  if cabEnEdic.MsjError<>'' then begin
    MsgErr(cabEnEdic.MsjError);
    RefrescarGrilla;   //porque no se refresca cuando hay diálogo modal
    exit;
  end;
  cabEnEdic.IP    := StringGrid1.Cells[1, fsel];
  if cabEnEdic.MsjError<>'' then begin
    MsgErr(cabEnEdic.MsjError);
    RefrescarGrilla;   //porque no se refresca cuando hay diálogo modal
    exit;
  end;
  cabEnEdic.Mac   := StringGrid1.Cells[2, fsel];
  if not TryStrToFloat(StringGrid1.Cells[3, fsel], n) then begin
    MsgErr('Error en número.');
    RefrescarGrilla;   //porque no se refresca cuando hay diálogo modal
    exit;
  end;
  cabEnEdic.x     := n;
  if not TryStrToFloat(StringGrid1.Cells[4, fsel], n) then begin
    MsgErr('Error en número.');
    RefrescarGrilla;   //porque no se refresca cuando hay diálogo modal
    exit;
  end;
  cabEnEdic.y     := n;
  cabEnEdic.ConConexion := UpCase(StringGrid1.Cells[5, fsel]) = 'V';
  if cabEnEdic.MsjError<>'' then begin
    MsgErr(cabEnEdic.MsjError);
    RefrescarGrilla;   //porque no se refresca cuando hay diálogo modal
    exit;
  end;
end;
procedure TfrmAdminCabinas.btnAgregarClick(Sender: TObject);
var
  nomb: String;
  idx: Integer;
  cab: TCPCabina;
begin
  if grpCab= nil then exit;
  //Genera nombre distinto
  idx := grpCab.items.Count+1;
  nomb := 'Cab' + IntToStr(idx);
  while grpCab.CabPorNombre(nomb) <> nil do begin
    Inc(idx);
    nomb := 'Cab' + IntToStr(idx);
  end;
  //agrega
  DesactRefresco := true;  //para evitar muchos refrescos
  cab := grpCab.Agregar(nomb,'');
  //calcula coordenadas iniciales
  Dec(idx);
  cab.x:= 10 + (idx mod 5) * 95;
  cab.y:= 20 + (idx div 5) * 160;
  DesactRefresco := false;
  RefrescarGrilla;
end;
procedure TfrmAdminCabinas.btnEliminarClick(Sender: TObject);
var
  f: Integer;
  nom : string;
  res: Boolean;
begin
  if grpCab= nil then exit;
  f := StringGrid1.Row;
  if f=-1 then exit;
  nom := StringGrid1.Cells[0,f];
  if MsgYesNo('¿Eliminar cabina ' + nom + '?') = 2 then exit;
  res := grpCab.Eliminar(nom);
  if not res then
    MsgErr('Error eliminando cabina.');
end;
procedure TfrmAdminCabinas.btnRefrescarClick(Sender: TObject);
begin
  RefrescarGrilla;
end;
procedure TfrmAdminCabinas.FormShow(Sender: TObject);
begin
  RefrescarGrilla;
end;
procedure TfrmAdminCabinas.mnActConexClick(Sender: TObject);
var
  cab: TCPCabina;
begin
  cab := CabinaSeleccionada;
  if cab = nil then exit;
  cab.ConConexion:=true;
end;
procedure TfrmAdminCabinas.mnDesConexClick(Sender: TObject);
var
  cab: TCPCabina;
begin
  cab := CabinaSeleccionada;
  if cab = nil then exit;
  cab.ConConexion:=false;
end;
procedure TfrmAdminCabinas.mnAgregCabClick(Sender: TObject);
begin
   btnAgregarClick(nil);
end;
procedure TfrmAdminCabinas.mnElimCabClick(Sender: TObject);
begin
  btnEliminarClick(nil);
end;
procedure TfrmAdminCabinas.mnRefresClick(Sender: TObject);
begin
  RefrescarGrilla;
end;
procedure TfrmAdminCabinas.mnConecTodClick(Sender: TObject);
var
  c : TCPFacturable;
begin
  DesactRefresco := true;  //para evitar muchos refrescos
  for c in grpCab.items do begin
    TCPCabina(c).ConConexion:=true;
  end;
  DesactRefresco := false;
  RefrescarGrilla;
end;
procedure TfrmAdminCabinas.mnDesconTodClick(Sender: TObject);
var
  c : TCPFacturable;
begin
  DesactRefresco := true;  //para evitar muchos refrescos
  for c in grpCab.items do begin
    TCPCabina(c).ConConexion:=false;
  end;
  DesactRefresco := false;
  RefrescarGrilla;
end;
procedure TfrmAdminCabinas.RefrescarGrilla;
var
  c : TCPFacturable;
  f : Integer;
  cab: TCPCabina;
begin
  if StringGrid1.EditorMode then exit;
  if grpCab = nil then exit;
  if DesactRefresco then exit;
  //Refresca la Grilla a partir de la lista de cabinas
  if not StringGrid1.Visible then exit;
  StringGrid1.BeginUpdate;
  StringGrid1.RowCount:=grpCab.items.Count+1;
  f := 1;
  for c in grpCab.items do begin
    cab := TCPCabina(c);
    //agrega también refrencia al objeto usuario
    StringGrid1.Cells[0, f] := cab.Nombre;
    StringGrid1.Cells[1, f] := cab.IP;
    StringGrid1.Cells[2, f] := cab.Mac;
    StringGrid1.Cells[3, f] := FloatToStr(cab.x);
    StringGrid1.Cells[4, f] := FloatToStr(cab.y);
    StringGrid1.Cells[5, f] := B2f(cab.ConConexion);
    StringGrid1.Cells[6, f] := cab.EstadoConexStr;
    inc(f);
  end;
  StringGrid1.EndUpdate(true);
  if grpCab.items.Count = 1 then
    Label1.Caption:= '1 cabina.'
  else
    Label1.Caption:= IntToStr(grpCab.items.Count) + ' cabinas.';
end;
procedure TfrmAdminCabinas.StringGrid1DrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  txt: String;           // texto de la celda
  ancTxt: Integer;       // ancho del texto
  cv: TCanvas;           //referencia al lienzo
begin
  cv := StringGrid1.Canvas;  //referencia al Lienzo
  txt := StringGrid1.Cells[ACol,ARow];
  ancTxt := cv.TextWidth(txt);
  if gdFixed in aState then begin
    //Es una celda fija
    cv.Brush.Color := clBtnFace;
    cv.Font.Color := clBlack;      // fuente blanca
    if aRow = 0 then cv.Font.Style := [fsBold]
    else cv.Font.Style := [];
    //escribe texto centrado
    cv.FillRect(aRect);   //fondo
    cv.TextOut(aRect.Left + ((aRect.Right - aRect.Left) - ancTxt) div 2,
                 aRect.Top + 2, txt );
  end else begin
    //Es una celda común
    if StringGrid1.Cells[6,ARow] = 'Conectado' then begin
      cv.Brush.Color := TColor($E0FFE0);
    end else if StringGrid1.Cells[6,ARow] = 'Conectando' then begin
      cv.Brush.Color := TColor($D0FFFF);
    end else begin
      cv.Brush.Color := clWhite;  //fondo blanco
    end;
    cv.Font.Color := clBlack;
    cv.Font.Style := [];
    //escribe texto
    cv.FillRect(aRect);   //fondo
    if ACol=0 then begin
      //columna de nombre
      ImageList1.Draw(cv, ARect.Left + 2, ARect.Top + 1, 0);
      cv.TextOut(aRect.Left + 20, aRect.Top + 2, txt);
    end else if (Acol=3) or (Acol=4) or (Acol=5) then begin
      //justifica a la derecha
      cv.TextOut(aRect.Right - ancTxt - 2, aRect.Top + 2, txt);
    end else begin
      cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
    end;
    //marca la selección
    if gdFocused in aState then begin
      cv.Pen.Color:= clBlue;
      dec(aRect.Right);
      dec(aRect.Bottom);
      cv.Frame(aRect);
    end;
  end;
end;
procedure TfrmAdminCabinas.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  valAntCel := CeldaSeleccionada;
  cabEnEdic := CabinaSeleccionada;
  {se deactivo el combo para edición de Coenxión porque dificaultaba la edición
  en vez de ayudar}
{  if (aCol=5) and (aRow>0) then begin
    ComboBox1.BoundsRect:=StringGrid1.CellRect(aCol,aRow);
    ComboBox1.Text:=StringGrid1.Cells[aCol, aRow];
    Editor:=ComboBox1;
  end;}
end;
procedure TfrmAdminCabinas.StringGrid1EditingDone(Sender: TObject);
begin
  if valAntCel <> CeldaSeleccionada then begin
    //debugln('-Grilla Modificada: =' + CeldaSeleccionada);
    ModificarCeldaActual;
  end;
end;
procedure TfrmAdminCabinas.ComboBox1EditingDone(Sender: TObject);
begin
  StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:=ComboBox1.Text;
  if valAntCel <> CeldaSeleccionada then begin
    //debugln('-Grilla Modificada: =' + CeldaSeleccionada);
    ModificarCeldaActual;
  end;
end;
procedure TfrmAdminCabinas.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  IF key = VK_ESCAPE then begin
    //restaura valor anterior y termina la edición
    StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:= valAntCel;
    StringGrid1.EditorMode:=false;
  end else if key = VK_F5 then begin
    mnRefresClick(nil);
  end;
end;
procedure TfrmAdminCabinas.FormCreate(Sender: TObject);
begin
  //configura grilla
  StringGrid1.Align:= alClient;
  StringGrid1.Options:=StringGrid1.Options+[goEditing];
  StringGrid1.OnSelectEditor:=@StringGrid1SelectEditor;
  StringGrid1.OnEditingDone:=@StringGrid1EditingDone;
  StringGrid1.OnKeyDown:=@StringGrid1KeyDown;
  StringGrid1.DefaultDrawing:=false;
  StringGrid1.OnDrawCell:=@StringGrid1DrawCell;
  StringGrid1.FixedCols:=0;
  StringGrid1.ColCount:=7;
  StringGrid1.ColWidths[0] := 70;
  StringGrid1.ColWidths[1] := 80;
  StringGrid1.ColWidths[2] := 100;
  StringGrid1.ColWidths[3] := 50;
  StringGrid1.ColWidths[4] := 50;
  StringGrid1.ColWidths[5] := 60;
  StringGrid1.ColWidths[6] := 70;
  StringGrid1.Cells[0,0] := 'Nombre';
  StringGrid1.Cells[1,0] := 'IP';
  StringGrid1.Cells[2,0] := 'Dir.Física';
  StringGrid1.Cells[3,0] := 'X';
  StringGrid1.Cells[4,0] := 'Y';
  StringGrid1.Cells[5,0] := 'Con Conex.';
  StringGrid1.Cells[6,0] := 'Estad.Conex';
  //configura ComboBox
  ComboBox1.AddItem('V', nil);
  ComboBox1.AddItem('F', nil);
  ComboBox1.OnEditingDone:=@ComboBox1EditingDone;
end;

end.

