unit FormPantCli;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LCLtype, Clipbrd;

type
  TEvRefPantallaCli = procedure of object;

  { TfrmPantCli }

  TfrmPantCli = class(TForm)
    Image1: TImage;
    ScrollBox1: TScrollBox;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollBox1StartDock(Sender: TObject;
      var DragObject: TDragDockObject);
  private
    //manejo del cuadro de selección
    x1Sel        : integer;
    y1Sel        : integer;
    x2Sel        : integer;
    y2Sel        : integer;
    x1Sel_a: integer;
    y1Sel_a: integer;
    x2Sel_a: integer;
    y2Sel_a: integer;
    pulsado: Boolean;
    procedure BorraRecSeleccion;
    procedure CopiarSelec;
    procedure DibujRecSeleccion;
    procedure InicRecSeleccion(X, Y: Integer);
    function RecSeleccionNulo: Boolean;

  public
    OnRefrescar: TEvRefPantallaCli;
    { public declarations }
  end;

var
  frmPantCli: TfrmPantCli;

implementation
{$R *.lfm}

procedure TfrmPantCli.BorraRecSeleccion();
//BORRA por métodos gráficos el rectángulo de selección en pantalla
begin
//    v2d.FijaLapiz(psDot, 1, clGreen);
    Image1.Canvas.Pen.Style := psDot;
    Image1.Canvas.pen.Width := 2;
    Image1.Canvas.pen.Color := clGreen;
//    v2d.FijaModoEscrit(pmNOTXOR);
    Image1.Canvas.Pen.Mode := pmNOTXOR;
//    v2d.rectang0(x1Sel_a, y1Sel_a, x2Sel_a, y2Sel_a);
    Image1.Canvas.Frame(x1Sel_a, y1Sel_a, x2Sel_a, y2Sel_a);
//    v2d.FijaModoEscrit(pmCopy);
    Image1.Canvas.Pen.Mode := pmCopy;
End;
procedure TfrmPantCli.DibujRecSeleccion();
//Dibuja por métodos gráficos el rectángulo de selección en pantalla
begin
//    v2d.FijaLapiz(psDot, 1, clGreen);
    Image1.Canvas.Pen.Style := psDot;
    Image1.Canvas.pen.Width := 2;
    Image1.Canvas.pen.Color := clGreen;
//    v2d.FijaModoEscrit(pmNOTXOR);
    Image1.Canvas.Pen.Mode := pmNOTXOR;
//    v2d.rectang0(x1Sel, y1Sel, x2Sel, y2Sel);
    Image1.Canvas.Frame(x1Sel, y1Sel, x2Sel, y2Sel);
//    v2d.FijaModoEscrit(pmCopy);
    Image1.Canvas.Pen.Mode := pmCopy;

    x1Sel_a := x1Sel; y1Sel_a := y1Sel;
    x2Sel_a := x2Sel; y2Sel_a := y2Sel;
End;
procedure TfrmPantCli.InicRecSeleccion(X, Y: Integer);
//Inicia el rectángulo de selección, con las coordenadas
begin
    x1Sel:= X; y1Sel := Y;
    x2Sel := X; y2Sel := Y;
    x1Sel_a := x1Sel;
    y1Sel_a := y1Sel;
    x2Sel_a := x2Sel;
    y2Sel_a := y2Sel;
    //Realiza el primer dibujo
    DibujRecSeleccion;
End;
Function TfrmPantCli.RecSeleccionNulo: Boolean;
 //Indica si el rectángulo de selección es de tamaño NULO o despreciable
begin
    If (x1Sel = x2Sel) And (y1Sel = y2Sel) Then
        RecSeleccionNulo := True
    Else
        RecSeleccionNulo := False;
End;
procedure TfrmPantCli.CopiarSelec;
//Copia el área seleccionada
var
  bmp: TBitmap;
  x1,y1,x2,y2: integer;
begin
  x1 := x1Sel; y1 := y1Sel; x2 := x2Sel; y2 := y2Sel;
  if (x2<=x1) or (y2<=y1) then begin
     showmessage('Coordenadas inválidas.');
  end;
  bmp := TBitmap.create;
  bmp.SetSize(x2-x1,y2-y1);
//  bmp.LoadFromFile('d:\aaa.bmp');
  bmp.Canvas.CopyRect(Rect(0,0,bmp.Width,bmp.Height),
                      TRasterImage(Image1.Picture.Graphic).Canvas, Rect(x1,y1,x2,y2));
  Clipboard.Assign(bmp);
  bmp.free;
end;
procedure TfrmPantCli.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then begin
    self.Image1.Picture := nil;
    if OnRefrescar <> nil then OnRefrescar;
  //    ShowMessage('asdsad');
  end else if Shift = [ssCtrl] then begin
    if Key = VK_C then begin  //Ctrl+C
      CopiarSelec;
    end;
  end;
end;
procedure TfrmPantCli.FormCreate(Sender: TObject);
begin
  pulsado := false;  //inicia bandera
end;

procedure TfrmPantCli.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
//   BorraRecSeleccion;
   pulsado := true;
   InicRecSeleccion(x, y - ScrollBox1.VertScrollBar.Position);
end;

procedure TfrmPantCli.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if pulsado then begin
    x2Sel := X;
    y2Sel := Y - ScrollBox1.VertScrollBar.Position;
    BorraRecSeleccion;
    DibujRecSeleccion;
  end;
end;

procedure TfrmPantCli.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  pulsado := false;
  BorraRecSeleccion;
  CopiarSelec;  //copra la selección
end;

procedure TfrmPantCli.ScrollBox1StartDock(Sender: TObject;
  var DragObject: TDragDockObject);
begin
  ShowMessage('asdsa');
end;

end.

