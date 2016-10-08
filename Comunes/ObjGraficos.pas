{                       Clase OG
Define los objetos gráficos de la aplicación CiberPlex.                                                       }
unit ObjGraficos;
{$mode objfpc}{$H+}
interface
uses
  Controls, Classes, SysUtils, Graphics, GraphType, LCLIntf, fgl,
  MisUtils, ogMotGraf2d, ogDefObjGraf, CibCabinaBase,
  CibGFacCabinas, CibGFacNiloM, CibFacturables, FormConfig;
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
  constructor Create(mGraf: TMotGraf; bol0: TCibBoleta);
  destructor Destroy; override;
end;

const //Constantes a usar en el "TObjGraf.tipo", para catgeorizar a los objetos gráficos.
  OBJ_FACT = 1;
  OBJ_GRUP = 2;
type
{TogFac, es el objeto intermedio usado para modelar a todos los objetos facturables.}
TogFac = class(TObjGraf)
private
  Ffac: TCibFac;
  procedure Setfac(AValue: TCibFac);
public
  NomGrupo   : string;  //nombre del grupo al que pertenece.
  Boleta     : TogBoleta;   //La boleta
  property Fac: TCibFac read Ffac write Setfac;   //contenedor de propiedades
  function gru: TCibGFac;  //referecnia al grupo
  constructor Create(mGraf: TMotGraf); override;
end;

{ TogGFac }
{TogFac, es el objeto intermedio usado para modelar a todos los objetos Grupos de
facturables.}
TogGFac = class(TObjGraf)
protected
  FGFac: TCibGFac;
  procedure SetGFac(AValue: TCibGFac); virtual;
public
  property GFac: TCibGFac read FGFac write SetGFac;   //referencia a su objeto grupo
  constructor Create(mGraf: TMotGraf); override;
end;

{ TogCabina }
{Objeto gráfico que representa a los elementos TCibFacCabina}
TogCabina = class(TogFac)
private
public
  icoPC      : TGraphic;    //PC con control
  icoPCdes   : TGraphic;    //PC sin control
  icoUSU     : TGraphic;    //referencia a ícono
  icoRedAct  : TGraphic;    //referencia a ícono
  icoRedDes  : TGraphic;    //referencia a ícono
  procedure DibujarTiempo;
  procedure Dibujar; override;  //Dibuja el objeto gráfico
  procedure ProcDesac(estado0: Boolean);   //Para responder evento de Habilitar/Deshabilitar
  function Contando: boolean;
  function Detenida: boolean;
  function EnManten: boolean;
  function cab: TCibFacCabina; inline;  //acceso a la cabina
protected
  procedure ReubicElemen; override;
private
  BotDes   : TogButton;          //Refrencia global al botón de Desactivar
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf; cab0: TCibFacCabina);
  destructor Destroy; override;
end;
{ TogNiloM }
{Objeto gráfico que representa a los elementos TCibFacCabina}
TogNiloM = class(TogFac)
private
  procedure ProcDesac(estado0: Boolean);
public
  icoTelCol   : TGraphic;    //Teléfono colgado
  icoTelDes   : TGraphic;    //Teléfono descolgado
  icoTelDes2  : TGraphic;    //Teléfono descolgado con llamada contestada
  procedure DibujarDatosLlam;
  procedure Dibujar; override;  //Dibuja el objeto gráfico
  function loc: TCibFacLocutor; inline;  //acceso a la cabina
protected
  procedure ReubicElemen; override;
private
  BotDes   : TogButton;          //Refrencia global al botón de Desactivar
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf; loc0: TCibFacLocutor);
  destructor Destroy; override;
end;

{ TogGCabinas }
{Objeto gráfico que representa a los elementos TCibGFacCabinas}
TogGCabinas = class(TogGFac)
private
public
  icono  : TGraphic;    //PC con control
  procedure Dibujar; override;  //Dibuja el objeto gráfico
protected
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf; cab0: TCibGFacCabinas);
end;

{Objeto gráfico que representa a los elementos TCibGFacNiloM}

{ TogGNiloM }

TogGNiloM = class(TogGFac)
private
public
  icono  : TGraphic;    //PC con control
  procedure Dibujar; override;  //Dibuja el objeto gráfico
protected
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf; nil0: TCibGFacNiloM);
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
{ TogFac }
procedure TogFac.Setfac(AValue: TCibFac);
begin
  Ffac:=AValue;             //Referencia al objeto
  Boleta.bol := Avalue.Boleta;   //y también el de la boleta
  //Al actualizar la referencia, se debte también actualizar las variables copia
  nombre := Ffac.Nombre;         //Referencia al objeto como cadena
  NomGrupo := Ffac.Grupo.Nombre;  {Se guarda la referencia al NomGrupo como cadena, porque una
                                cadena es una referencia segura, ya que la referencia
                                Fcab, puede quedar apuntando a objetos liberados.}
  fx := Ffac.x;
  fy := Ffac.y;
  {No necesita actualizar alguna otra propiedad porque, el acceso a las propiedades
   adicionales, se hace a través de la referencia "Fac".}
  ReubicElemen;
end;
function TogFac.gru: TCibGFac;
begin
  Result := Ffac.Grupo;
end;
constructor TogFac.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipo := OBJ_FACT;   //Usa el campo tipo, para identificar a los facturables
end;
{ TogGFac }
procedure TogGFac.SetGFac(AValue: TCibGFac);
begin
  FGFac:=AValue;            //Referencia al objeto
  //Se ha cambiado la referencia, actualizamos las propiedades que son copia
  nombre := GFac.Nombre;         //Referencia al objeto como cadena
  fx := GFac.x;
  fy := GFac.y;
  {No necesita actualizar alguna otra propiedad porque, el acceso a las propiedades
   adicionales, se hace a través de la referencia "GFac".}
  ReubicElemen;
end;
constructor TogGFac.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipo := OBJ_GRUP;   //Usa el campo tipo, para identificar a los grupos facturables
end;
{ TogCabina }
procedure TogCabina.DibujarTiempo;
var
  tmp: string;
begin
  //dibuja cuadro de estado
  v2d.SetText(clBlack, 10,'',false);
  v2d.FijaRelleno(TColor($80ff80));
  v2d.RectangR(x, y, x+60, y+36);
  //muestra tiempo transcurrido
//  DateTimeToString(tmp, 'hh:mm:ss', now-Fac.hor_ini);  //convierte
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
procedure TogCabina.Dibujar();
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
    s := CadMoneda(cab.Costo);
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
procedure TogCabina.ReubicElemen;
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
function TogCabina.Contando: boolean;
begin
  Result := cab.EstadoCta in [EST_CONTAN, EST_PAUSAD];
end;
function TogCabina.Detenida: boolean;
begin
  Result := cab.EstadoCta = EST_NORMAL;
end;
function TogCabina.EnManten: boolean;
begin
  Result := cab.EstadoCta = EST_MANTEN;
end;
function TogCabina.cab: TCibFacCabina; inline;
{Función de acceso pro comodidad}
begin
  Result := TCibFacCabina(Fac);
end;
procedure TogCabina.ProcDesac(estado0: Boolean);
begin
//   Desactivado := estado0;
   BotDes.estado := estado0;      //Cambia estado0 por si no estaba sincronizado
end;
//constructor y detsructor
constructor TogCabina.Create(mGraf: TMotGraf; cab0: TCibFacCabina);
begin
  inherited Create(mGraf);
  Boleta := TogBoleta.Create(v2d, nil);  //crea boleta
  BotDes := AddButton(24, 24, BOT_REPROD, @ProcDesac);
  pc_SUP_CEN.visible:=false;  //oculta punto de control
  nombre := 'Cabina';
  Self.Ubicar(100,100);
  width := 85;
  height := 130;
  ReConstGeom;     //Se debe llamar después de crear los puntos de control para poder ubicarlos

  Fac := cab0;   {Actualiza referencia, a través de la propiedad, para que se actualicen
                  tambiém, las variables necesarias}
  ProcDesac(False);   //Desactivado := False
end;
destructor TogCabina.Destroy;
begin
  Boleta.Free;
  inherited;
end;
{ TogNiloM }
procedure TogNiloM.DibujarDatosLlam;
  procedure MensajeNllamadas;
  {Muestar el mensaje tres líneea, que indica que está esperando llamadas }
  begin
    v2d.FijaRelleno(TColor($D0D0D0));
//    v2d.FijaRelleno(TColor($80ff80));
    v2d.RectangR(x-3, y-2, x+97, y+50);
    v2d.Texto(x+1,y   , 'Esperando');
    v2d.Texto(x+1,y+16, 'marcación...');
    if loc.llamadas.Count = 1 then v2d.Texto(x+1,y+32, '<1 llamada.>')
    else v2d.Texto(x+1,y+32, '<'+ IntToStr(loc.llamadas.Count) +' llamadas>');
//    DateTimeToString(tmp, 'hh:mm:ss', 0);  //convierte
//    v2d.Texto(x+1,y+16,tmp);
  end;
begin
  //dibuja cuadro de estado
  if loc.descolg then begin    //Está descolgado
    if loc.llam.NUM_DIG<> '' then begin  //Hay llamadas
      if loc.llam.CONTES then v2d.SetText(clRed, 10,'',false)
      else v2d.SetText(clBlack, 10,'',false);
      v2d.FijaRelleno(TColor($D0D0D0));
      v2d.RectangR(x-3, y-2, x+97, y+50);
      //muestra tiempo transcurrido
      v2d.Texto(x+1,y   , loc.llam.NUM_DIG);
      v2d.Texto(x+1,y+16, loc.llam.DESCR_);
      if loc.llam.CONTES then
        v2d.Texto(x+1,y+32, loc.llam.DURAC_ + ' ' + CadMoneda(loc.llam.COST_NTER))
      else
        v2d.Texto(x+1,y+32, 'Cto.Paso=' + loc.llam.COSTOP_);
    end else begin  //Hay llamadas
      v2d.SetText(clBlack, 10,'',false);
      MensajeNllamadas;
    end;
  end else begin    //Está colgado
    //No muestra cuadro
  end;
end;
procedure TogNiloM.Dibujar();
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
  v2d.FijaRelleno(TColor($BCF5A9));
  v2d.RectangR(x, y, x2, y+height);
//  If Desactivado Then v2d.FijaRelleno(COL_BARTIT_DES) Else v2d.FijaRelleno(COL_BARTIT_ACT);
//  v2d.RectRedonR(x, y, x2, y + ALT_ENCAB_DEF);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, nombre);
  //dibuja íconos de teléfono
  if loc.descolg then begin
    v2d.DibujarImagenN(icoTelDes, x+28, y+52);
  end else begin
     v2d.DibujarImagenN(icoTelCol, x+28, y+52);
  end;
  //Dibuja datos de llamada
  DibujarDatosLlam;
  //muestra consumo
  v2d.FijaLapiz(psSolid, 1, clBlack);
  v2d.FijaRelleno(TColor($D5D5D5));
  v2d.RectangR(x, y+88, x2, y+110);
  //solo muestra tiempo, en conteo
  s := CadMoneda(0.1);
  v2d.SetText(clBlue, 11,'',false);
  v2d.TextoR(x+2, y+88, width-4, 22, s);
  BotDes.estado:= true;
  //muestra boleta
  if loc.Boleta.ItemCount>0 then Boleta.Dibujar;  //dibuja boleta
  inherited;
end;
procedure TogNiloM.ReubicElemen;
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
var
  x2: Single;
begin
  inherited;
  x2 := x + width;
  Buttons[0].Ubicar(x + 64, y + 60);
//   Botones[2].Ubicar(x2 - 20, y + 3);  //Botón Cerrar
  //ubica boleta
  Boleta.Ubicar(x+5,y+110);
end;
function TogNiloM.loc: TCibFacLocutor;
begin
  Result := TCibFacLocutor(Fac);
end;
procedure TogNiloM.ProcDesac(estado0: Boolean);
begin
//   Desactivado := estado0;
   BotDes.estado := estado0;      //Cambia estado0 por si no estaba sincronizado
end;
//constructor y detsructor
constructor TogNiloM.Create(mGraf: TMotGraf; loc0: TCibFacLocutor);
begin
  inherited Create(mGraf);
  Boleta := TogBoleta.Create(v2d, nil);  //crea boleta
  BotDes := AddButton(24, 24, BOT_REPROD, @ProcDesac);
  pc_SUP_CEN.visible:=false;  //oculta punto de control
  nombre := 'Locutorio';
  Self.Ubicar(100,100);
  width := 94;
  height := 130;
  ReConstGeom;     //Se debe llamar después de crear los puntos de control para poder ubicarlos

  Fac := loc0;   {Actualiza referencia, a través de la propiedad, para que se actualicen
                  tambiém, las variables necesarias}
end;
destructor TogNiloM.Destroy;
begin
  Boleta.Free;
  inherited;
end;
{ TogGCabinas }
procedure TogGCabinas.Dibujar;
var
  x2:Single;
begin
  //--------------Dibuja cuerpo de tabla
  x2 := x + width;
  //--------------Dibuja encabezado
  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DibujarImagenN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, nombre);
  inherited;
end;
constructor TogGCabinas.Create(mGraf: TMotGraf; cab0: TCibGFacCabinas);
begin
  inherited Create(mGraf);
  pc_SUP_CEN.visible:=false;  //oculta punto de control
  Self.Ubicar(100,100);
  width := 100;
  height := 29;
  ReConstGeom;     //Se debe llamar después de crear los puntos de control para poder ubicarlos
  nombre := 'Grupo Cabinas';
  GFac := cab0;   //guarda referencia y actualiza propiedades que son copia
end;
{ TogGNiloM }
procedure TogGNiloM.Dibujar;
var
  x2:Single;
begin
  //--------------Dibuja cuerpo de tabla
  x2 := x + width;
  //--------------Dibuja encabezado
  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DibujarImagenN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, nombre);
  inherited Dibujar;
end;
constructor TogGNiloM.Create(mGraf: TMotGraf; nil0: TCibGFacNiloM);
begin
  inherited Create(mGraf);
  pc_SUP_CEN.visible:=false;  //oculta punto de control
  Self.Ubicar(100,100);
  width := 100;
  height := 29;
  ReConstGeom;     //Se debe llamar después de crear los puntos de control para poder ubicarlos
  nombre := 'Grupo NiloM';
  GFac := nil0;   //guarda referencia y actualiza propiedades que son copia
end;

end.

