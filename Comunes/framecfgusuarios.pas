{Frame de configuración par usuarios.}
unit frameCfgUsuarios;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, StdCtrls, Buttons, Grids,
  Graphics, FormInicio, MisUtils;

type

  { TFraUsuarios }

  TFraUsuarios = class(TFrame)
    btnAgregar: TBitBtn;
    btnEliminar: TBitBtn;
    ComboBox1: TComboBox;
    ImageList1: TImageList;
    StringGrid1: TStringGrid;
    procedure btnAgregarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure ComboBox1EditingDone(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1SelectEditor(Sender: TObject; aCol, aRow: Integer;
      var Editor: TWinControl);
  public
    //variables de propiedades
    numero  : integer;
    listaUsu: TStringList;
    MsjErr  : string;
    procedure FileToProperty;
    procedure PropertyToFile;
    procedure PropToWindow;
    procedure WindowToProp;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

function CreaUsuario(usuar, clave: String; perfil: TUsuPerfil = PER_OPER): TregUsuario;

implementation
{$R *.lfm}

procedure TFraUsuarios.FileToProperty;
var
  lin: String;
  u : TregUsuario;
begin
  //aquí aprovechamos para leer la lista de usuarios
  usuarios.Clear;
  for lin in listaUsu do begin
    u := TregUsuario.Create;
    u.CadObj:=lin;  //carga propiedades
    usuarios.Add(u);
  end;
end;
procedure TFraUsuarios.PropertyToFile;
var
  u : TregUsuario;
begin
  //antes de grabar actualiza lista
  listaUsu.Clear;
  for u in usuarios do begin
    listaUsu.Add(u.CadObj);
  end;
end;
procedure TFraUsuarios.PropToWindow;
var
  u : TregUsuario;
  f : Integer;
begin
  //Refresca la Grilla a partir de la lista de usuarios
  StringGrid1.RowCount:=usuarios.Count+1;
  f := 1;
  for u in usuarios do begin
    //agrega también refrencia al objeto usuario
    StringGrid1.Cells[0, f] := IntToStr(f);  //índice
    StringGrid1.Cells[1, f] := u.usu;
    StringGrid1.Cells[2, f] := u.cla;
    StringGrid1.Cells[3, f] := u.perStr;
    inc(f);
  end;
end;
procedure TFraUsuarios.WindowToProp;
var
  f: Integer;
  u: TregUsuario;
begin
  {Actualiza la lista de usuarios a partir de la Grilla}
  msjError := '';
  usuarios.Clear;
  for f:=1 to StringGrid1.RowCount-1 do begin
    u := CreaUsuario(StringGrid1.Cells[1, f],
                     StringGrid1.Cells[2, f]);
    if msjError<>'' then begin
      self.MsjErr:=msjError;
      exit;
    end;
    u.perStr := StringGrid1.Cells[3, f];
    if msjError<>'' then begin
      self.MsjErr:=msjError;
      exit;
    end;
  end;
end;

procedure TFraUsuarios.StringGrid1SelectEditor(Sender: TObject; aCol,
  aRow: Integer; var Editor: TWinControl);
begin
  if (aCol=3) and (aRow>0) then begin
    ComboBox1.BoundsRect:=StringGrid1.CellRect(aCol,aRow);
    ComboBox1.Text:=StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row];
    Editor:=ComboBox1;
  end;
end;
procedure TFraUsuarios.ComboBox1EditingDone(Sender: TObject);
begin
  StringGrid1.Cells[StringGrid1.Col,StringGrid1.Row]:=ComboBox1.Text;
end;
procedure TFraUsuarios.StringGrid1DrawCell(Sender: TObject; aCol,
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
    cv.Brush.Color := clWhite;  //fondo blanco
    cv.Font.Color := clBlack;
    cv.Font.Style := [];
    //escribe texto
    cv.FillRect(aRect);   //fondo
    if Acol=2 then begin
      //columna de contraseñas
      txt := StringOfChar('*', length(txt));  //oculta contraseña
      cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
    end else if ACol=1 then begin
      //columna de usuarios
      if UPcase(StringGrid1.Cells[3,ARow]) = 'ADMINISTRADOR' then
        ImageList1.Draw(cv, ARect.Left + 2, ARect.Top + 1, 1)
      else
        ImageList1.Draw(cv, ARect.Left + 2, ARect.Top + 1, 0);
      cv.TextOut(aRect.Left + 20, aRect.Top + 2, txt);
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

procedure TFraUsuarios.btnAgregarClick(Sender: TObject);
var
  f: Integer;
begin
  StringGrid1.RowCount := StringGrid1.RowCount + 1;
  f := StringGrid1.RowCount-1;
  StringGrid1.Cells[0, f] := IntToStr(f);  //índice
  StringGrid1.Cells[1, f] := 'nuevo';
  StringGrid1.Cells[2, f] := '';
  StringGrid1.Cells[3, f] := 'Operador';
end;
procedure TFraUsuarios.btnEliminarClick(Sender: TObject);
var
  f: Integer;
begin
  f := StringGrid1.Row;
  if f=-1 then exit;
  StringGrid1.DeleteRow(f);
end;

constructor TFraUsuarios.Create(TheOwner: TComponent);
var
  u : TregUsuario;
  per: TUsuPerfil;
begin
  inherited Create(TheOwner);
  listaUsu:= TStringList.Create;
  //configura grilla
  StringGrid1.Options:=StringGrid1.Options+[goEditing];
  StringGrid1.OnSelectEditor:=@StringGrid1SelectEditor;
  StringGrid1.DefaultDrawing:=false;
  StringGrid1.OnDrawCell:=@StringGrid1DrawCell;
  StringGrid1.ColWidths[0] := 20;
  StringGrid1.ColWidths[1] := 70;
  StringGrid1.ColWidths[3] := 110;
  StringGrid1.ColCount:=4;
  StringGrid1.Cells[1,0] := 'Usuario';
  StringGrid1.Cells[2,0] := 'Clave';
  StringGrid1.Cells[3,0] := 'Perfil';
  ComboBox1.OnEditingDone:=@ComboBox1EditingDone;
  //configura combo
  u := TregUsuario.Create;  //utiliza un TregUsuario, como ayuda para obtener el texto del perfil
  for per in TUsuPerfil do begin
    u.per:=per;
    ComboBox1.Items.Add(u.perStr);
  end;
  u.Destroy;
  ComboBox1.Text:='Operador';
end;
destructor TFraUsuarios.Destroy;
begin
  listaUsu.Destroy;
  inherited Destroy;
end;

//instrucciones de administración de usuarios
function CreaUsuario(usuar, clave: String; perfil: TUsuPerfil = PER_OPER): TregUsuario;
{Crea a un usuario nuevo. Devuelve la referencia.}
var
  u : TregUsuario;
begin
  msjError := '';
  If usuar = '' Then begin
      msjError := 'Nombre de usuario no puede ser nulo.';
      exit;
  end;
  //Verifica existencia de usuario
  for u in usuarios do begin
      If u.usu = usuar Then begin
          msjError := 'Usuario Ya existe.';
          exit;
      end;
  end;
  u := TregUsuario.Create;
  u.usu := usuar;
  u.cla := clave;
  u.per := perfil;
  usuarios.Add(u);
  Result := u;
end;
procedure ModificaUsuario(ant_usua: String; usuar, clave: String; perfil: TUsuPerfil);
//Modifica los datos de un usuario en la matriz de usuarios
var
  u  : TregUsuario;
  pos: TregUsuario;
begin
  msjError := '';
  //Busca usuar
  pos := nil;
  for u in usuarios do begin
    If u.usu = ant_usua Then begin
        pos := u;
        break;
    end;
  end;
  //Validación
  If pos = nil Then begin //No existe usuar
      msjError := 'No existe usuario: ' + usuar;
      exit;
  end;
  //Modifica
  pos.usu := usuar;
  pos.cla := clave;
  pos.per := perfil;
end;
procedure EliminaUsuario(usuar: string);
//ELimina un usuario en la matriz de usuarios
var
  u  : TregUsuario;
  pos: TregUsuario;
begin
  msjError := '';
  //Busca posición de usuario
  pos := nil;
  for u in usuarios do begin
    If u.usu = usuar Then begin
        pos := u;
        break;
    end;
  end;
  //Validación
  If pos = nil Then begin  //No existe usuario
      msjError := 'No existe usuario: ' + usuario;
      exit;
  end;
  If usuar = 'admin' Then begin
      msjError := 'No se puede eliminar usuario: admin';
      exit;
  end;
  If usuarios.Count = 1 Then begin
      msjError := 'No se puede eliminar todos los usuarios';
      exit;
  end;
  If usuar = usuario Then begin
      msjError := 'No se puede eliminar al usuario actual';
      exit;
  end;
  //Si hay usuario para eliminar en 'pos'
  usuarios.Remove(pos);
end;

end.

