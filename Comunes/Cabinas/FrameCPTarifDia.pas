{Frame para implementar el control de tarfia Diaria para las Cabinas de Internet}
unit FrameCPTarifDia;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, FileUtil, Forms, Controls, StdCtrls, Graphics,
  LCLProc, ComCtrls, MisUtils, types, CibCabinaTarifas;
type

  { TfraFranja }
  {Se crea la franja a partir de "TCPFranja", para no duplicar los campos base
   y reutilizar la propiedad "StrObj" }
  TfraFranja = class(TCPFranja)
  private  //variables de clase
    class var
   //coordenadas físicas del frame donde se va a dibujar
    yFis1: integer;   //en pixles
    yFis2: integer;   //en pixles
    dyFis: Double;  //altura disponible para el dibujo
    var
  public //métodos de clase
    class procedure fijarGeometria(yf1, yf2: integer);
  private
    function Gety1: integer;
    function Gety2: integer;
    function GetyCen: integer;
    procedure Sety1(AValue: integer);
    procedure Sety2(AValue: integer);
  public  //Propiedades de conversión a pixeles, usadas para el dibujo
    colorFondo: TColor;  //color de fondo
    property y1: integer read Gety1 write Sety1;  //coordernada física superior
    property y2: integer read Gety2 write Sety2;  //coordernada física inferior
    property yCen:integer read GetyCen; //coordernada física central
  end;
  TfraFranja_list = specialize TFPGObjectList<TfraFranja>;

  { TfraCPTarifDia }
  TfraCPTarifDia = class(TFrame)
    Label1: TLabel;
    lblTitulo: TLabel;
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FrameMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure FrameMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure frmCPTarifDiaPaint(Sender: TObject);
  private
    franjas: TfraFranja_list;
    function GetNombre: string;
    procedure SetNombre(AValue: string);
    function GetStrObj: string;
    procedure SetStrObj(AValue: string);
    function CursorEnLimite(Ycur: integer; var iFraSup: integer): boolean;
    procedure ReubicarFranjas;
  private  //variables para el dimensionamiento
    dimensionando: boolean;
    fra1: TfraFranja;
    fra2: TfraFranja;
  public
    tarDia: TCPTarifaDia;  //referencia a la tarifa del día que representa
    OnClickDerecho: TMouseEvent;  //evento
    msjError: string;
    property nombre: string read GetNombre write SetNombre;  //se mostrará como etiqueta en el frame
    {La propiedad "strObj" se crea para poder leer/escribir datos de un TCPTarifaDia.
     Notar que su definición debe ser compatible con TCPTarifaDia.strObj }
    property strObj: string read GetStrObj write SetStrObj;
    function AgregarFranja(tarAlq: string): TfraFranja;
    procedure EliminarFranjas;
    function ReporteTarifas: string;
    procedure ActualizColorFranjas(ArbolTarAlq: TTreeView);
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

  function BuscaNodoTarAlquiler(ArbolTarAlq: TTreeView; nomb: string): TTreeNode;
implementation
{$R *.lfm}
const
  SEG_POR_DIA = 86400;  //cantidad de segundos en el día
  MAX_FRANJAS = 5;

function BuscaNodoTarAlquiler(ArbolTarAlq: TTreeView; nomb: string): TTreeNode;
{Indica si el nombre indicado, existe en un arbol como nombre de tarifa de alquiler.
 Si existe, devuelve la referencia al nodo, sino devuelve NIL.}
var
  nod: TTreeNode;
begin
  for nod in ArbolTarAlq.Items do begin
    if nod.Level = 0 then begin
      if Upcase(nod.Text) = Upcase(nomb) then
        exit(nod);
    end;
  end;
  exit(nil);
end;

{ TfraFranja }
class procedure TfraFranja.fijarGeometria(yf1, yf2: integer);
{Define las coordenadas físicas de la franja. Se debe hacer para poder
 realizar las transformaciones.}
begin
  yFis1 := yf1;
  yFis2 := yf2;
  dyFis := (yFis2-yFis1)/SEG_POR_DIA;
end;
function TfraFranja.Gety1: integer;
{Devuelve la coordenada Física Superior}
begin
  Result := trunc(yFis1 + dyFis * hor1);
end;
function TfraFranja.Gety2: integer;
begin
  Result := trunc(yFis1 + dyFis * hor2);
end;
function TfraFranja.GetyCen: integer;
begin
  Result := trunc(yFis1 + dyFis * (hor1 + hor2) / 2);
end;
procedure TfraFranja.Sety1(AValue: integer);
//cambia min1, de acuerdo a la nueva coordenada física
begin
  hor1 := trunc((AValue - yFis1)/dyFis);
  //protección
  if hor1 < 0 then hor1 := 0;
  if hor1 > hor2-1 then hor1 := hor2-1;
end;
procedure TfraFranja.Sety2(AValue: integer);
//cambia min2, de acuerdo a la nueva coordenada física
begin
  hor2 := trunc((AValue - yFis1)/dyFis);
  //protección
  if hor2 <= hor1+1 then hor2 := hor1 + 1;
  if hor2 > SEG_POR_DIA-1 then hor2 := SEG_POR_DIA-1;
end;
{ TfraCPTarifDia }
procedure TfraCPTarifDia.frmCPTarifDiaPaint(Sender: TObject);
var
  x1, x2: Integer;
  y1, y2: Integer;
  fra: TfraFranja;
  yFraTxt: Integer;
begin
  Canvas.Pen.Color := clBlack;
  x1 := 0;
  x2 := width-1;
  y1 := lblTitulo.Height;
  y2 := height;
  TfraFranja.fijarGeometria(y1, y2);
  //dibuja franjas
  if franjas.Count=0 then begin
    //no hay franjas
    yFraTxt := (y1+y2) div 2;
    canvas.Brush.Color:= clWhite;
    canvas.TextOut(x1,yFraTxt-8, '<Sin Tarifas>');
  end else begin
    for fra in franjas do begin
      canvas.Brush.Color:= fra.colorFondo;
      canvas.Rectangle(x1, fra.y1, x2, fra.y2);
      canvas.TextOut(x1, fra.yCen - 8, fra.tarAlq);
    end;
  end;
  //dibuja borde
  Canvas.Frame(x1, y1, x2, y2);
end;
function TfraCPTarifDia.CursorEnLimite(Ycur: integer; var iFraSup: integer): boolean;
{Indica si la coordenada pasa por un límite entre 2 franjas. Si es así, devuelve en
"fraSup" el índice a la franja superior}
var
  fra: TfraFranja;
  y1, y2: Integer;
  i: Integer;
begin
  y1 := lblTitulo.Height;
  y2 := height;
  TfraFranja.fijarGeometria(y1, y2);
  for i:=0 to franjas.Count-2 do begin  //no considera el último
    fra := franjas[i];
    if abs(fra.y2 - Ycur)<3 then begin
      iFraSup := i;
      exit(true);
    end;
  end;
  exit(false);
end;
procedure TfraCPTarifDia.FrameMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  ifra: integer;
  procedure MostrarHoraInic(fran: TfraFranja);
  { Muestra la hora inicial de una franja en la etiqueta, y en la posición superior
  de la franja, si es posible}
  begin
    label1.Caption := FormatDateTime('hh:nn:ss', fran.hor1/SEG_POR_DIA);
    label1.Left:=(Width-label1.Width) div 2;
    if fran.y1 + 2 + label1.Height > self.Height then begin
      //excede ´rea visible, lo muestra arriba
      label1.Top:=fran.y1 - label1.Height - 2;
    end else begin
      //lo muestra abajo
      label1.Top:=fran.y1+2;
    end;
  end;
begin
  if dimensionando then begin
    //En modo de dimensionamiento, mueve límite.
    fra1.y2 := Y;  //desplaza límite
    //ajusta a pasos de 1/2hora
    fra1.hor2 := 1800 * (fra1.hor2 div 1800) - 1;
    if fra1.hor2 = -1 then fra1.hor2 := 1800-1;
    //verifica que no aplaste a la franja siguiente
    if fra1.hor2 > fra2.hor2-2 then begin
      fra1.hor2 := fra2.hor2-2;
      fra1.hor2 := 1800 * (fra1.hor2 div 1800) - 1;
    end;
    fra2.hor1:=fra1.hor2+1;
    MostrarHoraInic(fra2);
    Invalidate;  //para refrescar
    exit;
  end;
  if CursorEnLimite(y, ifra) then begin
    self.Cursor := crSizeNS;  //cambia cursor
    fra1 := franjas[ifra];    //franja superior
    fra2 := franjas[ifra+1];  //franja inferior
    label1.Visible:=true;
    MostrarHoraInic(fra2);
  end else begin
    self.Cursor := crDefault;
    label1.Visible:=false;
  end;
end;
procedure TfraCPTarifDia.FrameMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
    if self.Cursor = crSizeNS then
//      debugln('dimensionando := true');
      dimensionando := true;
  end;
end;
procedure TfraCPTarifDia.FrameMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then begin
//    debugln('dimensionando := false');
    dimensionando := false;
  end;
  if Button = mbRight then begin
    //genera evento
    if OnClickDerecho<>nil then OnClickDerecho(Self, Button, Shift, X, Y);
  end;
end;
procedure TfraCPTarifDia.ReubicarFranjas;
var
  fra: TfraFranja;
  min: Integer;
  tamFranja: integer;
begin
  if franjas.Count=0 then
    exit;  //no hay franjas aún
  //reubica tamaño de franjas
  tamFranja := SEG_POR_DIA div franjas.Count;
  min := 0;
  for fra in franjas do begin
    fra.hor1 := min;
    fra.hor2 := min + tamFranja - 1;
    min := min + tamFranja;
  end;
  //corrige el segundo final por si hay problemas de redondeo
  fra.hor2 := SEG_POR_DIA-1;
end;
function TfraCPTarifDia.GetNombre: string;
begin
  Result := lblTitulo.Caption;
end;
procedure TfraCPTarifDia.SetNombre(AValue: string);
begin
  lblTitulo.Caption := AValue;
end;
function TfraCPTarifDia.GetStrObj: string;
var
  fra: TCPFranja;
begin
  Result := nombre;
  for fra in Franjas do begin
    Result += #9 + fra.StrObj;
  end;
end;
procedure TfraCPTarifDia.SetStrObj(AValue: string);
var
  campos: TStringDynArray;
  fra: TfraFranja;
  i: Integer;
begin
  campos := explode(#9, AValue);
  nombre := campos[0];
  //agrega los pasos
  franjas.Clear;
  for i:=1 to high(campos) do begin
    fra := TfraFranja.Create;
    fra.StrObj:=campos[i];
    franjas.Add(fra);
  end;
  //ReubicarFranjas;
  Invalidate;
end;
function TfraCPTarifDia.AgregarFranja(tarAlq: string): TfraFranja;
{Agrega una franja a la tarifa de día}
var
  fran: TfraFranja;
begin
  fran := TfraFranja.Create;
  fran.tarAlq := tarAlq;
  if franjas.Count >= MAX_FRANJAS then begin
    msjError := 'No se puede agregar más franjas.';
    exit;
  end;
  franjas.Add(fran);
  ReubicarFranjas;
  Result := fran;
  Invalidate;
end;
procedure TfraCPTarifDia.EliminarFranjas;
begin
  franjas.Clear;
  Invalidate;
end;
function TfraCPTarifDia.ReporteTarifas: string;
var
  fra: TfraFranja;
begin
  if franjas.Count=0 then begin
    Result := 'No hay tarifas asignadas a este día.'
  end;
  Result := '';
  for fra in franjas do begin
    Result += fra.tarAlq +
           ': De ' + FormatDateTime('hh:nn:ss', fra.hor1/SEG_POR_DIA) +
             ' a ' + FormatDateTime('hh:nn:ss', fra.hor2/SEG_POR_DIA) + LineEnding;

  end;
end;
procedure TfraCPTarifDia.ActualizColorFranjas(ArbolTarAlq: TTreeView);
{Actualiza los colores de las franjas de acuerdo al arbol que representa a las
 tarifas de alquileres}
var
  fra: TfraFranja;
  nod: TTreeNode;
begin
  for fra in franjas do begin
    nod := BuscaNodoTarAlquiler(ArbolTarAlq, fra.tarAlq);
    if nod= nil then begin
      fra.colorFondo := clWhite;
    end else begin
      fra.colorFondo := TColor(PtrUInt(nod.Data));
    end;
  end;
end;
constructor TfraCPTarifDia.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  franjas:= TfraFranja_list.Create();
  self.OnPaint:=@frmCPTarifDiaPaint;
end;
destructor TfraCPTarifDia.Destroy;
begin
  franjas.Destroy;
  inherited Destroy;
end;

end.

