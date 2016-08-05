{                       Clase OG
Define los objetos gráficos de la aplicación CiberPlex.                                                       }
unit ObjGraficos;
{$mode objfpc}{$H+}
interface
uses
  Controls, Classes, SysUtils, Graphics, GraphType, LCLIntf, fgl,
  MisUtils, ogMotGraf2d, ogDefObjGraf, CPCabinaBase,
  CPGrupoCabinas, CPFacturables;
const
  //Constantes de Colores
 COL_AZUL_CLARO = 230 * 256 *256 + 255 *256 + 255;
 COL_AZUL_CLARO2 = $FFA8A8;
 COL_GRIS_CLARO = $C0C0C0;     //gris claro
 COL_GRIS = $808080;          //gris
 COL_VERD_CLARO = $C0FFC0;   //RGB(200, 255, 200)
 COL_VERDE = $B0FFB0;        //RGB(200, 255, 200)
 COL_AMAR_CLARO = $B4FFFF;   //RGB(255, 255, 180)

  //Constantes de Colores para CEdGrafOQ
  COL_BARTIT_ACT = COL_AZUL_CLARO2;   //Fondo para barra de título
  COL_BARTIT_DES = COL_GRIS_CLARO;   //Fondo barra de títulos desactivada
  COL_FON_TABLAS = clWhite;  //Fondo para las tablas

  //Constantes geométricas para CEdGrafOQ
  ALT_ENCAB_DEF = 22 ;   //Espacio que se deja al inicio
  ALT_FILA_DEF = 17  ;   //Alto de las filas por defecto
  ANC_ZON_CHECK = 24 ;   //ancho del área del check
  ALT_MIN_TABLA = 40 ;   //Alto mínimo de una tabla
  ALT_MIN_FILTRO = 44;   //Alto mínimo de una tabla

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
  bol      : TCPBoleta;
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
  constructor Create(mGraf: TMotGraf; bol0: TCPBoleta);
  destructor Destroy; override;
end;

{ TObjGrafCabina }
TObjGrafCabina = class(TObjGraf)
private
  Fcab: TCPCabina;
  procedure Setcab(AValue: TCPCabina);
  procedure SetCadEstado(AValue: string);
  procedure SetCadPropied(AValue: string);
public
  Usado      : boolean;
  icoPC      : TGraphic;    //PC con control
  icoPCdes   : TGraphic;    //PC sin control
  icoUSU     : TGraphic;    //referencia a ícono
  icoRedAct  : TGraphic;    //referencia a ícono
  icoRedDes  : TGraphic;    //referencia a ícono
  Boleta     : TogBoleta;   //La boleta
  property cab: TCPCabina read Fcab write Setcab;   //contenedor de propiedades
  procedure DibujarTiempo;
  procedure Dibujar; override;  //Dibuja el objeto gráfico
//   Function EsVisibleEnPantalla() : Boolean;
   //Da un indicio sobre si el objeto es completamente visible en pantalla y en las capas
  procedure ProcDesac(estado0: Boolean);   //Para responder evento de Habilitar/Deshabilitar
//  procedure LeePropiedades(cad: string; grabar_ini: boolean=true); override;
  function Contando: boolean;
  function Detenida: boolean;
  function EnManten: boolean;
  property CadPropied: string write SetCadPropied;
  property CadEstado: string write SetCadEstado;
protected
  procedure ReubicElemen; override;
private
  BotDes   : TogButton;          //Refrencia global al botón de Desactivar
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf; cab0: TCPCabina);
  destructor Destroy; override;
end;

implementation

//Const ANCHO_MIN = 20;    //Ancho mínimo de objetos gráficos en pixels (Coord Virtuales)
//Const ALTO_MIN = 20;     //Alto mínimo de objetos gráficos en Twips (Coord Virtuales)

//////////////////////////////  TogBoleta  //////////////////////////////
constructor TogBoleta.Create(mGraf: TMotGraf; bol0: TCPBoleta);
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
    v2d.FijaRelleno(clYellow);
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
procedure TObjGrafCabina.SetCadPropied(AValue: string);
begin
  //carg1 propiedades
  cab.CadPropied := Avalue;
  //actualiza las propiedades locales
  nombre := cab.Nombre;
  fx := cab.x;
  fy := cab.y;
  ReubicElemen;
end;
procedure TObjGrafCabina.Setcab(AValue: TCPCabina);
begin
  Fcab:=AValue;   //actualiza referencia
  Boleta.bol := Avalue.Boleta;   //y también el de la boleta
end;

procedure TObjGrafCabina.SetCadEstado(AValue: string);
begin
  cab.CadEstado := AValue;
end;
procedure TObjGrafCabina.DibujarTiempo;
var
  tmp: string;
begin
  //dibuja cuadro de estado
  v2d.SetText(clBlack, 10,'',false);
  v2d.FijaRelleno(TColor($80ff80));
  v2d.RectangR(x, y, x+60, y+36);
  //muestra tiempo transcurrido
//  DateTimeToString(tmp, 'hh:mm:ss', now-cab.hor_ini);  //convierte
  DateTimeToString(tmp, 'hh:mm:ss', cab.TranscDat);  //convierte
  v2d.Texto(x+4,y+1,tmp);
  //muestra tiempo total
  if cab.tLibre then   //pidió tiempo libre
    v2d.SetText(clBlue, 10,'',true);
  //Genera Tiempo solicitado en texto descriptivo.
  if cab.tLibre then begin  //pidió tiempo libre
    tmp := '<libre>'
  end else if Abs(cab.tSolic - 1/24) < 0.0001 then
    tmp := '1 hora'
  else if Abs(cab.tSolic - 1/48) < 0.0001 then
    tmp := '1/2 hora'
  else if Abs(cab.tSolic - 1/96) < 0.0001 then
    tmp := '1/4 hora'
  else   //no es tiempo conocido
    DateTimeToString(tmp, 'hh:mm:ss', cab.tSolic);  //convierte
  //escribe tiempo
  v2d.Texto(x+4,y+17,tmp);
end;
procedure TObjGrafCabina.Dibujar();
var
  x2:Single;
  s: String;
begin
  //--------------Dibuja cuerpo de tabla
  x2 := x + width;
  //y2 := y + height;
  //Sombra
//    Call v2d.FijaLapiz(0, 3, COL_GRIS_CLARO)
//    Call v2d.FijaRellenoTransparente
//    v2d.RectRedonR mX + 2, mY + 2, x2 + 2, y2 + 2
  //Frente
//  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
//  v2d.FijaRelleno(clWhite);
//  v2d.RectRedonR(x, y, x2, y2);
  //--------------Dibuja encabezado
  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
//  If Desactivado Then v2d.FijaRelleno(COL_BARTIT_DES) Else v2d.FijaRelleno(COL_BARTIT_ACT);
//  v2d.RectRedonR(x, y, x2, y + ALT_ENCAB_DEF);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, nombre);
  //dibuja íconos de PC y de conexión
  if cab.ConConexion then begin
    if cab.EstadoConex = cecConectado then begin
      v2d.DibujarImagenN(icoRedAct, x+38, y+30);
      v2d.DibujarImagenN(icoPC, x+12, y+20);
    end else begin
      v2d.DibujarImagenN(icoRedDes, x+38, y+30);
      v2d.DibujarImagenN(icoPCdes, x+12, y+20);
    end;
  end else begin
    v2d.DibujarImagenN(icoPCdes, x+12, y+20);
  end;
  if cab.EstadoCta in [EST_CONTAN, EST_PAUSAD] then begin
     //muestra ícono de persona
     if icoUSU<>NIL then v2d.DibujarImagenN(icoUSU, x, y+35);
     DibujarTiempo;
  end;
  //muestra consumo
  v2d.FijaLapiz(psSolid, 1, clBlack);
  v2d.FijaRelleno(TColor($D5D5D5));
  v2d.RectangR(x, y+88, x2, y+110);
  if cab.EstadoCta in [EST_CONTAN, EST_PAUSAD] then begin
    //solo muestra tiempo, en conteo
    s := Format('S/ %f',[cab.Costo]);
    v2d.SetText(clBlue, 11,'',false);
    v2d.TextoR(x+2, y+88, width-4, 22, s);
    if cab.horGra then begin  //hora gratis
       v2d.SetText(clRed, 10, '', true);
       v2d.Texto(x+25, y+40, 'GRATIS');
    end;
    BotDes.estado:= true;
  end else begin
    BotDes.estado:= false;
  end;
  //muestra boleta
  if cab.Boleta.ItemCount>0 then Boleta.Dibujar;  //dibuja boleta
  if cab.EstadoCta = EST_MANTEN then begin
    //dibuja aspa roja
    v2d.FijaLapiz(psSolid, 3, clred);
    v2d.Linea(x,y,x2,y+90);
    v2d.Linea(x2,y,x,y+90);
  end;
  inherited;
end;
procedure TObjGrafCabina.ReubicElemen;
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
var
  x2: Single;
begin
  inherited;
  x2 := x + width;
  Buttons[0].Ubicar(x2 - 24, y + 1);
//   Botones[2].Ubicar(x2 - 20, y + 3);  //Botón Cerrar
  //ubica boleta
  Boleta.Ubicar(x+5,y+110);
end;
function TObjGrafCabina.Contando: boolean;
begin
  Result := cab.EstadoCta in [EST_CONTAN, EST_PAUSAD];
end;
function TObjGrafCabina.Detenida: boolean;
begin
  Result := cab.EstadoCta = EST_NORMAL;
end;

function TObjGrafCabina.EnManten: boolean;
begin
  Result := cab.EstadoCta = EST_MANTEN;
end;

procedure TObjGrafCabina.ProcDesac(estado0: Boolean);
begin
//   Desactivado := estado0;
   BotDes.estado := estado0;      //Cambia estado0 por si no estaba sincronizado
end;
//constructor y detsructor
constructor TObjGrafCabina.Create(mGraf: TMotGraf; cab0: TCPCabina);
begin
  inherited Create(mGraf);
  Fcab := cab0;   //guarda referencia
  BotDes := AddButton(24,24,BOT_REPROD, @ProcDesac);
  pc_SUP_CEN.visible:=false;  //oculta punto de control
  Boleta := TogBoleta.Create(v2d, cab.Boleta);  //crea boleta

  Self.Ubicar(100,100);
  width := 85;
  height := 130;

  ReConstGeom;     //Se debe llamar después de crear los puntos de control para poder ubicarlos

  ProcDesac(False);   //Desactivado := False
  nombre := 'Cabina';
end;
destructor TObjGrafCabina.Destroy;
begin
  Boleta.Free;
  inherited;
end;

end.

