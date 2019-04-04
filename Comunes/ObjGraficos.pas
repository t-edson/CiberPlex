{                       Clase OG
Define los objetos gráficos de la aplicación CiberPlex.                                                       }
unit ObjGraficos;
{$mode objfpc}{$H+}
interface
uses
  Controls, Classes, SysUtils, Graphics, GraphType, LCLIntf, fgl,
  MisUtils, ogMotGraf2d, ogDefObjGraf, CibFacturables;
const
  //Constantes de Colores
 COL_ROJO_CLARO = $8080FF;          //gris
 COL_GRIS = $808080;          //gris
 COL_GRIS_CLARO = $D0D0D0;    //gris claro
 COL_VERD_CLARO = $80FF80;   //RGB(200, 255, 200)
 COL_VERDE = $B0FFB0;        //RGB(200, 255, 200)
 COL_AMAR_OSCUR = $00CFCF;   //RGB(255, 255, 180)
 COL_AMAR_CLARO = $80FFFF;   //RGB(255, 255, 180)

type
{TipTTab = (   //tipo de tabla normal
  TBOL_NORM,  //Tipo de boleta normal.
  TBOL_XXX    //Otro tipo
 );}
idIcono = (     //Identifica a los íconos
  icoNULL,      //ícono Nulo
  icoTabla,     //ícono de tabla
  icoDimen,     //ícono de dimensión
  icoLlave      //ícono de llave Primaria
);

TFilaOQ = Class
  idIcon  : idIcono;       //ícono de la fila
  txt     : String;        //almacena los campos
  selecc  : Boolean;       //bandera que indica fila seleccionada
  marcad  : Boolean;       //bandera que indica fila marcada
  TxtCol  : TGraphicsColor;//color de texto
  FonCol  : TGraphicsColor;//color de fondo
//    Visib   : Boolean;       //Indica si la fila es visible
  alto    : Single;        //alto de la fila
  PosY    : Single ;       //posición vertcal de dibujo
  TipCam  : Integer;       //tipo de fila   0 -> campo común
                           //               1 -> campo *
                           //               2 -> campo calculado
  Indice  : Integer;       //indica si el campo es índice (<>0)
end;
TLisFilaOQ = specialize TFPGList<TFilaOQ>;

{ TogBoleta }

TogBoleta = class(TObjVsible)      //Se maneja como objeto
private
  //tipo     : TipTTab;  //No usado
  bol      : TCibBoleta;
  filas    : TLisFilaOQ;
  xCheck   : single;
  procedure ReConstGeom;
public
  subtot : double;         //subtotal a pagar

  procedure Dibujar;
//   procedure Mover(xr, yr: Integer);  //Dimensiona las variables indicadas
  procedure MouseUp(Button: TMouseButton; Shift: TShiftState; xp, yp: Integer);
  procedure Agregar(txt: string);  //Agrega una fila al cuadro
public  //Constructor y destructor
  constructor Create(mGraf: TMotGraf; bol0: TCibBoleta); reintroduce;
  destructor Destroy; override;
end;

const //Constantes a usar en el "TObjGraf.tipo", para categorizar a los objetos gráficos.
  OBJ_FACT = 1;
  OBJ_GRUP = 2;
type
TogGFac = class;
{TogFac, es el objeto intermedio usado para modelar a todos los objetos facturables.}
TogFac = class(TObjGraf)
private
public
  tipGFac  : TCibTipGFact; //Tipo de Facturable (Se asigna al crearse)
  Boleta   : TCibBoleta;   //Objeto boleta
  ogBoleta : TogBoleta;    //La boleta
  grupo    : TogGFac;      //referencia al grupo
  procedure ReLocate(newX, newY: Single; UpdatePCtrls: boolean=true); override;
  procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true); override; //Hace público este método

  function IdFac: string;
  {SetCadPropied() es utilizado para leer las propiedades de un texto.}
  procedure SetCadEstado(txt: string); virtual; abstract;
  procedure SetCadPropied(txt: string); virtual; abstract;

  constructor Create(mGraf: TMotGraf); override ;
  destructor Destroy; override;
end;

{ TogGFac }
{TogFac, es el objeto intermedio usado para modelar a todos los objetos Grupos de
facturables.}
TogGFac = class(TObjGraf)
public  //Eventos
  OnReqCadMoneda: TevReqCadMoneda;
public  //Propiedades
  CategVenta: string;      //Categoría de ventas.
  tipGFac: TCibTipGFact;   //Tipo de Grupo de Facturables
  function tipoStr: string;
public
  function IdFac: string;
  {SetCadPropied() es utilizado para leer de una StringList, la parte que corresponde a
  las propiedades del ogGFac. Deja en el StringList, las líneas que corresponderían a
  propiedades de los ogFac.}
  procedure SetCadPropied(lineas: TSTringList); virtual; abstract;
  {SetCadEstado() es utilizado para leer de una StringList, la parte que corresponde al
  estado del ogGFac. Deja en el StringList, las líneas que corresponderían al
  estado de los ogFac.}
  procedure SetCadEstado(txt: string); virtual; abstract;
  constructor Create(mGraf: TMotGraf); override;
  destructor Destroy; override;
end;

implementation

//Const ANCHO_MIN = 20;    //Ancho mínimo de objetos gráficos en pixels (Coord Virtuales)
//Const ALTO_MIN = 20;     //Alto mínimo de objetos gráficos en Twips (Coord Virtuales)
//////////////////////////////  TogBoleta  //////////////////////////////
constructor TogBoleta.Create(mGraf: TMotGraf; bol0: TCibBoleta);
begin
   inherited Crear(mGraf, 80, 22);    //crea
   //tipo := tipo0;
   bol := bol0;   //esta referencia no es fija, puede ser cambiada en la ejecución
   filas := TLisFilaOQ.Create;  //Crea filas
   ReConstGeom;
end;
destructor TogBoleta.Destroy;
begin
  filas.Free;   //libera lista y objetos
end;
procedure TogBoleta.Dibujar;
var s: string;
begin
//    v2d.Barra(x, y, x + width, y + height, clYellow);  //siempre de tamaño fijo
    v2d.SetBrush(clYellow);
    v2d.RectRedonR(x, y, x + width, y + height);  //siempre de tamaño fijo
    s := Format('S/ %f',[bol.TotPag]);
//    v2d.Texto(x+2, y+1, s);
    v2d.SetText(clGreen, 11,'',false);
    v2d.TextoR(x+2, y, width-2, height, s);

{     if filas.Count = 0 then begin   //no hay datos
       v2d.Texto(x,y,'<Sin datos>');
       exit;
    end;
    //dibuja las filas
    xCheck := x + ancho - ANC_ZON_CHECK;  //posición X del check
    posy := y;
    for f in filas do begin
       if f.alto > 0 then begin  //¿es visible?
          v2d.Texto(x, posy,f.txt);
          If VerCheck Then begin   //incluye Check
             v2d.DibFonBoton(xCheck, posy+1, 15, 15);
             if f.marcad then v2d.DibCheck(xCheck+2, posy+3, 10, 8);
          end;
          posy += f.alto;
       end;
    end;}
end;
procedure TogBoleta.MouseUp(Button: TMouseButton; Shift: TShiftState; xp,
  yp: Integer);
var f: TFilaOQ;
    posy: single;
begin
    posy := y;
    for f in filas do begin
       if f.alto > 0 then begin  //¿es visible?
          If (xp > xCheck) and (yp>=posy) and (yp<=posy + f.alto) Then begin
             f.marcad := not f.marcad;   //cambia estado
          end;
          posy += f.alto;
       end;
    end;
end;
procedure TogBoleta.ReConstGeom;
//Reconstruye la geometría
begin
{   if filas.Count = 0 then begin    //no hay filas
      alto := ALT_MIN_TAB;
   end else begin        //hay que calcular el alto
      for f in filas do dy+=f.alto;
      alto := dy;    //fija
   end;}
end;
procedure TogBoleta.Agregar(txt: string);
//Agrega una fila al cuadro
var f: TFilaOQ;
begin
   f := TFilaOQ.Create;  //Crea fila
   f.alto := 17;        //fija alto
   f.txt := txt;        //pone texto
   f.marcad:= true;    //maracdo por defecto
   filas.Add(f);
   ReConstGeom;      //reconstruye
end;
procedure TogFac.ReLocate(newX, newY: Single; UpdatePCtrls: boolean);
begin
  inherited ReLocate(newX, newY, UpdatePCtrls);
  ogBoleta.Locate(x+5,y+110);
end;
{ TogFac }
procedure TogFac.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
begin
  inherited;
end;
function TogFac.IdFac: string;
{Genera el identificador, a partir del nombre y del grupo.}
begin
  Result := Grupo.Name + SEP_IDFAC + Name;
end;
constructor TogFac.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipo := OBJ_FACT;   //Usa el campo tipo, para identificar a los facturables
  ogBoleta := TogBoleta.Create(v2d, nil);  //crea ogBoleta
  Boleta  := TCibBoleta.Create;
  ogBoleta.bol := Boleta;   //ACtualzia referencia
end;
destructor TogFac.Destroy;
begin
  Boleta.Destroy;
  ogBoleta.Destroy;
  //if FFac<>nil then Ffac.Destroy;
  inherited Destroy;
end;
function TogGFac.tipoStr: string;
begin
  try
    writestr(Result, tipGFac);
  except
    Result := '<<Descon.>>'
  end;
end;
function TogGFac.IdFac: string;
begin
  Result := Name;
end;
{ TogGFac }
constructor TogGFac.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipo := OBJ_GRUP;   //Usa el campo tipo, para identificar a los grupos facturables
end;
destructor TogGFac.Destroy;
begin
  inherited Destroy;
end;

end.

