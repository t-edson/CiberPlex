{                       Clase OG
Define los objetos gráficos de la aplicación CiberPlex.                                                       }
unit ObjGraficos;
{$mode objfpc}{$H+}
interface
uses
  Controls, Classes, SysUtils, Graphics, GraphType, LCLIntf, fgl, MisUtils,
  ogMotGraf2d, ogDefObjGraf, CibCabinaBase, CibNiloMConex, CibTramas,
  CibGFacClientes, CibGFacCabinas, CibCabinaTarifas, CibGFacNiloM,
  CibFacturables, CibGFacMesas;
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
  NomGrupo : string;  //nombre del grupo al que pertenece.
  facBoleta: TCibBoleta;  //Objeto boleta
  Boleta   : TogBoleta;   //La boleta
  grupo    : TogGFac;     //referencia al grupo
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
public
  tipGFac: TCibTipGFact;   //Tipo de Grupo de Facturables
  OnReqCadMoneda: TevReqCadMoneda;
public
  {SetCadPropied() es utilizado para leer de una StringList, la parte que corresponde a
  las propiedades del ogGFac. Deja en el StringList, las líneas que corresponderían a
  propiedades de los ogFac.}
  procedure SetCadPropied(lineas: TSTringList); virtual; abstract;

  constructor Create(mGraf: TMotGraf); override;
  destructor Destroy; override;
end;
////////////////// FACTURABLES ///////////////////
{ TogCliente }
{Objeto gráfico que representa a los elementos TCibFacCliente}
TogCliente = class(TogFac)
private
public
  icono      : TGraphic;    //PC con control
  procedure Draw; override;  //Dibuja el objeto gráfico
protected
  procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true); override;
public  //Propiedades reflejo del FAC al que representa
  procedure SetCadPropied(str: string); override;
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
end;
{ TogCabina }
{Objeto gráfico que representa a los elementos TCibFacCabina}
TogCabina = class(TogFac)
private
public
  icoPC      : TGraphic;    //Referencia a ícono de PC con control
  icoPCdes   : TGraphic;    //Referencia a ícono de PC sin control
  icoUSU     : TGraphic;    //Referencia a ícono de usuario
  icoComent  : TGraphic;    //Referencia a ícono
  icoRedAct  : TGraphic;    //Referencia a ícono
  icoRedDes  : TGraphic;    //Referencia a ícono
  procedure DibujarTiempo;
  procedure Draw; override;  //Dibuja el objeto gráfico
  procedure ProcDesac(estado0: Boolean);   //Para responder evento de Habilitar/Deshabilitar
  function Contando: boolean;
  function Detenida: boolean;
  function EnManten: boolean;
protected
  procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true); override;
private
  //BotDes   : TogButton;          //Refrencia global al botón de Desactivar
public  //Estado reflejo del GFAC al que representa
  estadoConex: TCibEstadoConex;
  HoraPC, hor_ini, tSolic: TDateTime;
  PantBloq, tLibre, horGra: Boolean;
  estadoCta: TcabEstadoCuenta;
  FTransc: integer;
  FCosto: double;
  function tSolicSeg: integer;
  function Faltante: integer;
  function TranscDat: TTime;
  procedure SetCadEstado(str: string); override;
public  //Propiedades reflejo del FAC al que representa
  IP, Mac, NombrePC, Coment: string;
  ConConexion: boolean;
  procedure SetCadPropied(str: string); override;
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
end;
{ TogNiloM }
{Objeto gráfico que representa a los elementos TCibFacLocutor}
TogNiloM = class(TogFac)
private
  procedure ProcDesac(estado0: Boolean);
public
  icoTelCol   : TGraphic;    //Teléfono colgado
  icoTelDes   : TGraphic;    //Teléfono descolgado
  icoTelDes2  : TGraphic;    //Teléfono descolgado con llamada contestada
  procedure DibujarDatosLlam;
  procedure Draw; override;  //Dibuja el objeto gráfico
protected
  procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true);
public  //Estado reflejo del GFAC al que representa
  llamAct  : TRegLlamada; //llamada en curso
  descolg, descon: boolean;
  costo_tot: Double;
  num_llam: integer;
  HayllamAct: Boolean;  {Bandera para indicar la existencia de llamada actual (Notar que
                         aquí se trabaja un poco distinto a como se hace en TCibFacLocutor. )}
  procedure SetCadEstado(str: string); override;
public  //Propiedades reflejo del FAC al que representa
  num_can: char;
  tpoLimitado: integer;
  ctoLimitado: double;
  procedure SetCadPropied(str: string); override;
public  //Constructor y destructor
  constructor Create(mGraf: TMotGraf); reintroduce;
  destructor Destroy; override;
end;
{ TogMesa }
{Objeto gráfico que representa a los elementos TCibFacMesa}
TogMesa = class(TogFac)
private
public
  icoMesaSim    : TGraphic;    //Mesa simple
  icoMesaDob1   : TGraphic;    //Mesa doble 1
  icoMesaDob2   : TGraphic;    //Mesa doble 2
  icoMesaDob3   : TGraphic;    //Mesa doble 2
  icoSilla1   : TGraphic;    //Silla
  icoSilla2   : TGraphic;    //Silla
  icoSilla3   : TGraphic;    //Silla
  icoSilla4   : TGraphic;    //Silla
  procedure ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean=true); override;
  procedure Draw; override;  //Dibuja el objeto gráfico
protected
  procedure ReLocate(newX, newY: Single; UpdatePCtrls: boolean=true); override;
public  //Propiedades reflejo del FAC al que representa
  tipMesa: TCibMesaTip;
  procedure SetCadPropied(str: string); override;
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
end;

/////////////////// GRUPOS ////////////////////////
{ TogGClientes }
TogGClientes = class(TogGFac)
private
public
  icono  : TGraphic;    //PC con control
  procedure Draw; override;  //Dibuja el objeto gráfico
public  //Propiedades reflejo del GFAC al que representa
  CategVenta: string;
  procedure SetCadPropied(lineas: TSTringList); override;
protected
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
end;
{ TogGCabinas }
{Objeto gráfico que representa a los elementos TCibGFacCabinas}
TogGCabinas = class(TogGFac)
private
public
  icono  : TGraphic;    //PC con control
  procedure Draw; override;  //Dibuja el objeto gráfico
public  //Propiedades reflejo del GFAC al que representa
  CategVenta: string;
  //También se guarda información de tarifas en el objeto
  grupTar: TGrupoTarAlquiler;  //Grupo de tarifas de alquiler
  tarif  : TCPTarifCabinas; //tarifas de cabina
  procedure SetCadPropied(lineas: TSTringList); override;
protected
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
  destructor Destroy; override;
end;
{ TogGNiloM }
{Objeto gráfico que representa a los elementos TCibGFacNiloM}
TogGNiloM = class(TogGFac)
private
public
  icoConec: TGraphic;    //NiloM conectado
  icoDesc : TGraphic;    //NiloM desconectado
  procedure Draw; override;  //Dibuja el objeto gráfico
public  //Propiedades reflejo del GFAC al que representa
  CategVenta, PuertoN: string;
  facCmoneda: Double;
  IniLLamMan, IniLLamTemp: boolean;
  PerLLamTemp: integer;
  procedure SetCadPropied(lineas: TSTringList); override;
protected
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
end;
{ TogGMesas }
{Objeto gráfico que representa a los elementos TCibGFacMesas}
TogGMesas = class(TogGFac)
private
public
  icono  : TGraphic;    //PC con control
  procedure Draw; override;  //Dibuja el objeto gráfico
public  //Propiedades reflejo del GFAC al que representa
  CategVenta: string;
  procedure SetCadPropied(lineas: TSTringList); override;
protected
public  //constructor y detsructor
  constructor Create(mGraf: TMotGraf); reintroduce;
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
  Boleta := TogBoleta.Create(v2d, nil);  //crea boleta
  facBoleta  := TCibBoleta.Create;
end;
destructor TogFac.Destroy;
begin
  facBoleta.Destroy;
  Boleta.Destroy;
  //if FFac<>nil then Ffac.Destroy;
  inherited Destroy;
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

//////////////////////////////////////////////////////////////////////
///////////////////////////  FACTURABLES /////////////////////////////
//////////////////////////////////////////////////////////////////////
{ TogCliente }
procedure TogCliente.Draw;
begin
  //--------------Dibuja cuerpo de tabla
//  x2 := x + width;
  //y2 := y + height;
  //Frente
//  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
//  v2d.FijaRelleno(clWhite);
//  v2d.RectRedonR(x, y, x2, y2);
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X, Y -20, name);
  //dibuja ícono
  v2d.DrawImageN(icono, x, y);
  //muestra boleta
  if facBoleta.ItemCount>0 then Boleta.Dibujar;  //dibuja boleta
  inherited;
end;
procedure TogCliente.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
begin
  inherited;
  //ubica boleta
  Boleta.Locate(x-8,y+45);
end;
procedure TogCliente.SetCadPropied(str: string);
begin
  TCibFacCliente.DecodCadPropied(str, Name, Fx, Fy);
end;
//constructor y detsructor
constructor TogCliente.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  boleta.Width:=67;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Cliente';
  Self.Locate(100,100);
  Resize(50, 65);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;
{ TogCabina }
function TogCabina.tSolicSeg: integer;
begin
  Result := round(tSolic*86400)
end;
function TogCabina.Faltante: integer;
//Tiempo faltante en segundos
begin
  Result := tSolicSeg - FTransc;
  if Result<0 then Result := 0;
end;
function TogCabina.TranscDat: TTime;
begin
  Result := FTransc / SecsPerDay;
end;
procedure TogCabina.DibujarTiempo;
var
  tmp: string;
begin
  //dibuja cuadro de estadoCta
  v2d.SetText(clBlack, 10,'',false);
  if tLibre then begin
    v2d.SetBrush(COL_VERD_CLARO);   //siempre verde
  end else if estadoCta = EST_PAUSAD then begin
    //Esta pausado. Parpadea en amarillo
    if trunc(now*86400) mod 2 = 0 then begin
      v2d.SetBrush(COL_AMAR_OSCUR);
    end else begin
      v2d.SetBrush(COL_AMAR_CLARO);
    end;
  end else begin
     //Hay tiempo, verificar si falta poco
     if Faltante <= 0 then begin
       //Genera parpadeo
       if FTransc mod 2 = 0 then
         v2d.SetBrush(COL_ROJO_CLARO)
       else
         v2d.SetBrush(COL_AMAR_CLARO);
     end else if Faltante < 5*60 then begin
       v2d.SetBrush(COL_AMAR_CLARO);
     end else begin
       v2d.SetBrush(COL_VERD_CLARO);
     end;
  end;
  v2d.RectangR(x, y, x+60, y+36);
  //muestra tiempo transcurrido
//  DateTimeToString(tmp, 'hh:mm:ss', now-Fac.hor_ini);  //convierte
  DateTimeToString(tmp, 'hh:mm:ss', TranscDat);  //convierte
  v2d.Texto(x+4,y+1,tmp);
  //muestra tiempo total
  if tLibre then   //pidió tiempo libre
    v2d.SetText(clBlue, 10,'',true);
  //Genera Tiempo solicitado en texto descriptivo.
  if tLibre then begin  //pidió tiempo libre
    tmp := '<libre>'
  end else if Abs(tSolic - 1/24) < 0.0001 then
    tmp := '1 hora'
  else if Abs(tSolic - 1/48) < 0.0001 then
    tmp := '1/2 hora'
  else if Abs(tSolic - 1/96) < 0.0001 then
    tmp := '1/4 hora'
  else   //no es tiempo conocido
    DateTimeToString(tmp, 'hh:mm:ss', tSolic);  //convierte
  //escribe tiempo
  v2d.Texto(x+4,y+17,tmp);
end;
procedure TogCabina.Draw;
var
  x2:Single;
  s: String;
begin
  //--------------Dibuja cuerpo de tabla
  x2 := x + width;
  //y2 := y + height;
  //Frente
//  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
//  v2d.FijaRelleno(clWhite);
//  v2d.RectRedonR(x, y, x2, y2);
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, Name);
  //Dibuja íconos de PC y de conexión
  if ConConexion then begin
    if EstadoConex = cecConectado then begin
      v2d.DrawImageN(icoRedAct, x+38, y+30);
      v2d.DrawImageN(icoPC, x+12, y+20);
    end else begin
      v2d.DrawImageN(icoRedDes, x+38, y+30);
      v2d.DrawImageN(icoPCdes, x+12, y+20);
    end;
  end else begin
    v2d.DrawImageN(icoPCdes, x+12, y+20);
  end;
  if estadoCta in [EST_CONTAN, EST_PAUSAD] then begin
     //muestra ícono de persona
     if icoUSU<>NIL then v2d.DrawImageN(icoUSU, x, y+35);
     DibujarTiempo;
  end;
  //Dibuja íconos de Comentario
  if Coment<>'' then begin
     if icoComent<>NIL then v2d.DrawImageN(icoComent, x+50, y+50);
  end;
  //Muestra consumo
  v2d.SetPen(psSolid, 1, clBlack);
  v2d.SetBrush(TColor($D5D5D5));
  v2d.RectangR(x, y+88, x2, y+110);
  if estadoCta in [EST_CONTAN, EST_PAUSAD] then begin
    //solo muestra tiempo, en conteo
    s := grupo.OnReqCadMoneda(FCosto);  //convierte a moneda
    v2d.SetText(clBlue, 11,'',false);
    v2d.TextoR(x+2, y+88, width-4, 22, s);
    if horGra then begin  //hora gratis
       v2d.SetText(clRed, 10, '', true);
       v2d.Texto(x+25, y+40, 'GRATIS');
    end;
    //BotDes.estado:= true;
  end else begin
    //BotDes.estado:= false;
  end;
  //muestra boleta
  if facBoleta.ItemCount>0 then Boleta.Dibujar;  //dibuja boleta
  if estadoCta = EST_MANTEN then begin
    //dibuja aspa roja
    v2d.SetPen(psSolid, 3, clred);
    v2d.Line(x,y,x2,y+90);
    v2d.Line(x2,y,x,y+90);
  end;
  inherited;
end;
procedure TogCabina.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
begin
  inherited;
//  x2 := x + width;
//  Buttons[0].Ubicar(x2 - 24, y + 1);
  //ubica boleta
  Boleta.Locate(x+5,y+110);
end;
procedure TogCabina.SetCadEstado(str: string);
var
  _Nombre: String;
begin
  TCibFacCabina.DecodCadEstado(str, _Nombre, estadoConex, HoraPC, PantBloq,
    estadoCta, hor_ini, tSolic, tLibre, horGra, FTransc, FCosto);
end;
procedure TogCabina.SetCadPropied(str: string);
begin
  TCibFacCabina.DecodCadPropied(str, Name, IP, Mac, Fx, Fy, ConConexion, NombrePC, Coment);
end;
function TogCabina.Contando: boolean;
begin
  Result := estadoCta in [EST_CONTAN, EST_PAUSAD];
end;
function TogCabina.Detenida: boolean;
begin
  Result := estadoCta = EST_NORMAL;
end;
function TogCabina.EnManten: boolean;
begin
  Result := estadoCta = EST_MANTEN;
end;
procedure TogCabina.ProcDesac(estado0: Boolean);
begin
//   Desactivado := estado0;
//   BotDes.estado := estado0;      //Cambia estado0 por si no estaba sincronizado
end;
//constructor y detsructor
constructor TogCabina.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  //BotDes := AddButton(24, 24, BOT_REPROD, @ProcDesac);
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Cabina';
  Self.Locate(100,100);
  Resize(85, 130);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
  ProcDesac(False);   //Desactivado := False
end;
{ TogNiloM }
procedure TogNiloM.DibujarDatosLlam;
  procedure MensajeNllamadas;
  {Muestar el mensaje tres líneea, que indica que está esperando llamadas }
  begin
    v2d.SetBrush(TColor($D0D0D0));
//    v2d.SetBrush(clBlue);
    v2d.RectangR(x-3, y-2, x+97, y+50);
    v2d.Texto(x+1,y   , 'Esperando');
    v2d.Texto(x+1,y+16, 'marcación...');
    if num_llam= 1 then v2d.Texto(x+1,y+32, '<1 llamada.>')
    else v2d.Texto(x+1,y+32, '<'+ IntToStr(num_llam) +' llamadas>');
//    DateTimeToString(tmp, 'hh:mm:ss', 0);  //convierte
//    v2d.Texto(x+1,y+16,tmp);
  end;
begin
  //dibuja cuadro de estado
  if descolg then begin    //Está descolgado
    if HayllamAct then begin  //Hay llamadas, Al menos la actual.
      if llamAct.CONTEST then v2d.SetText(clRed, 10,'',false)
      else v2d.SetText(clBlack, 10,'',false);
      v2d.SetBrush(TColor($D0D0D0));
      v2d.RectangR(x-3, y-2, x+97, y+50);
      //muestra tiempo transcurrido
      v2d.Texto(x+1,y   , llamAct.digitado);
      v2d.Texto(x+1,y+16, llamAct.tarDesrip);
      if llamAct.CONTEST then begin
        v2d.Texto(x+1,y+32, llamAct.duracStr + ' ' + Grupo.OnReqCadMoneda(llamAct.COST_NTER))
      end else begin
        v2d.Texto(x+1,y+32, 'Cto.Paso=' + llamAct.tarCtoPaso);
      end;

    end else begin  //Hay llamadas
      v2d.SetText(clBlack, 10,'',false);
      MensajeNllamadas;
    end;
  end else begin    //Está colgado
    //No muestra cuadro
  end;
end;
procedure TogNiloM.Draw;
var
  x2:Single;
  s: String;
begin
  //--------------Dibuja cuerpo de tabla
  x2 := x + width;
  //y2 := y + height;
  //Dibuja fondo rectangular
  v2d.SetPen(psSolid, 1, COL_GRIS);
  if descon then v2d.SetBrush(COL_GRIS_CLARO)
  else v2d.SetBrush(TColor($BCF5A9));
  v2d.RectangR(x, y, x2, y + height);
  //Dibuja visor
  v2d.SetBrush(clBlack);
  v2d.RectangR(x+16, y+10, x2-16, y + 40);
  if descon then v2d.SetBrush(COL_GRIS_CLARO)
  else v2d.SetBrush(clBlue);
  v2d.RectangR(x+22, y+16, x2-22, y + 30);

  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X + 2, Y -20, name);  //Nombre de objeto
  //dibuja ícono de teléfono
  if descolg then begin
    v2d.DrawImageN(icoTelDes, x+28, y+52);
  end else begin
     v2d.DrawImageN(icoTelCol, x+28, y+52);
  end;
  //Dibuja datos de llamada
  DibujarDatosLlam;
  //muestra consumo en moneda
  v2d.SetPen(psSolid, 1, clBlack);
  v2d.SetBrush(TColor($D5D5D5));
  v2d.RectangR(x, y+88, x2, y+110);
  s := Grupo.OnReqCadMoneda(costo_tot);  //costo en formato de moneda
  v2d.SetText(clBlue, 11,'',false);
  v2d.TextoR(x+2, y+88, width-4, 22, s);
  //muestra boleta
  if facBoleta.ItemCount>0 then Boleta.Dibujar;  //dibuja boleta
  inherited;
end;
procedure TogNiloM.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
begin
  inherited;
  //ubica boleta
  Boleta.Locate(x+5,y+110);
end;
procedure TogNiloM.SetCadEstado(str: string);
var
  tmp, LlamActEstado: string;
begin
  TCibFacLocutor.DecodCadEstado(str, tmp, descolg, descon, costo_tot, num_llam,
                                LlamActEstado);
  if LlamActEstado = '' then begin
    HayllamAct := true;
    llamAct.CadEstado := LlamActEstado;
  end else begin
    HayllamAct := false;
  end;
end;
procedure TogNiloM.SetCadPropied(str: string);
begin
  TCibFacLocutor.DecodCadPropied(str, Name, num_can, tpoLimitado, ctoLimitado, Fx, Fy);
end;
procedure TogNiloM.ProcDesac(estado0: Boolean);
begin
//   Desactivado := estado0;
end;
//constructor y detsructor
constructor TogNiloM.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  llamAct  := TRegLlamada.Create;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Locutorio';
  Self.Locate(100,100);
  Resize(94, 130);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;
destructor TogNiloM.Destroy;
begin
  llamAct.Destroy;
  inherited Destroy;
end;

{ TogMesa }
procedure TogMesa.Draw;
begin
  //--------------Dibuja cuerpo de tabla
//  x2 := x + width;
  //y2 := y + height;
  //Frente
//  v2d.FijaLapiz(psSolid, 1, COL_GRIS);
//  v2d.SetBrush(clWhite);
//  v2d.RectRedonR(x, y, x2, y2);
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(X, Y -20, Name);
  //Dibuja mesa
  //dibuja ícono de sillas
  v2d.DrawImageN(icoSilla1, x , y + 38);
  v2d.DrawImageN(icoSilla2, x + 37, y);
  //dibuja ícono de mesa
  case tipMesa of
  cmt1x1: begin
      v2d.DrawImageN(icoSilla3, x + 70, y + 38);
      v2d.DrawImageN(icoSilla4, x + 37, y + 70);
      v2d.DrawImageN(icoMesaSim, x + 26, y + 26);
  end;
  cmt1x2: begin
      v2d.DrawImageN(icoSilla2, x + 73, y);
      v2d.DrawImageN(icoSilla3, x + 105, y + 38);
      v2d.DrawImageN(icoSilla4, x + 37, y + 70);
      v2d.DrawImageN(icoSilla4, x + 73, y + 70);
      v2d.DrawImageN(icoMesaDob1, x + 26, y + 26);
  end;
  cmt2x1: begin
      v2d.DrawImageN(icoSilla1, x , y + 74);
      v2d.DrawImageN(icoSilla3, x + 70, y + 38);
      v2d.DrawImageN(icoSilla3, x + 70, y + 74);
      v2d.DrawImageN(icoSilla4, x + 37, y + 105);
      v2d.DrawImageN(icoMesaDob2, x + 26, y + 26);
  end;
  cmt2x2: begin
      v2d.DrawImageN(icoSilla1, x , y + 74);
      v2d.DrawImageN(icoSilla2, x + 73, y);
      v2d.DrawImageN(icoSilla3, x + 105, y + 38);
      v2d.DrawImageN(icoSilla3, x + 105, y + 74);
      v2d.DrawImageN(icoSilla4, x + 37, y + 105);
      v2d.DrawImageN(icoSilla4, x + 73, y + 105);
      v2d.DrawImageN(icoMesaDob3, x + 26, y + 26);
  end;
  end;
  //muestra boleta
  if facBoleta.ItemCount>0 then Boleta.Dibujar;  //dibuja boleta
  inherited;
end;
procedure TogMesa.ReLocate(newX, newY: Single; UpdatePCtrls: boolean);
//Reubica elementos, del objeto. Se le debe llamar cuando se cambia la posición del objeto, sin
//cambiar las dimensiones.
begin
  inherited;
  //ubica boleta
  Boleta.Locate(x + width/2 - 40, y + height - 20);
end;
procedure TogMesa.SetCadPropied(str: string);
begin
  TCibFacMesa.DecodCadPropied(str, Name, Fx, Fy, tipMesa);
end;
procedure TogMesa.ReSize(newWidth, newHeight: Single; UpdatePCtrls: boolean);
begin
  case tipMesa of
  cmt1x1: begin
      newWidth := 105;
      newHeight := 110;
  end;
  cmt1x2: begin
      newWidth := 140;
      newHeight := 110;
  end;
  cmt2x1: begin
      newWidth := 105;
      newHeight := 145;
  end;
  cmt2x2: begin
      newWidth := 140;
      newHeight := 145;
  end;
  end;
  inherited Resize(newWidth, newHeight);
end;
//constructor y detsructor
constructor TogMesa.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  boleta.Width:=80;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Cliente';
  Locate(100,100);
  Resize(105, 110);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;
//////////////////////////////////////////////////////////////////////
///////////////////////////  GRUPOS /////////////////////////////////
//////////////////////////////////////////////////////////////////////
{ TogGClientes }
procedure TogGClientes.Draw;
begin
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DrawImageN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited;
end;
procedure TogGClientes.SetCadPropied(lineas: TSTringList);
begin
  TCibGFacClientes.DecodCadPropied(lineas, Name, CategVenta, Fx, Fy);
  ReLocate(x, y);  //Porque ha habido cambios en X,Y
end;
constructor TogGClientes.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipGFac := ctfClientes;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Locate(100,100);
  Name := 'Grupo Clientes';
  Resize(100, 29);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;
{ TogGCabinas }
procedure TogGCabinas.Draw;
begin
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DrawImageN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited;
end;
procedure TogGCabinas.SetCadPropied(lineas: TSTringList);
var
  strGrupTar, strTarif: string;
begin
  TCibGFacCabinas.DecodCadPropied(lineas, Name, CategVenta, Fx, Fy, strGrupTar, strTarif);
  grupTar.StrObj := strGrupTar;
  tarif.StrObj := strTarif;
  ReLocate(x, y);  //Porque ha habido cambios en X,Y
end;
constructor TogGCabinas.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipGFac := ctfCabinas;
  grupTar:= TGrupoTarAlquiler.Create;  //Grupo de tarifas de alquiler
  tarif  := TCPTarifCabinas.Create(grupTar); //tarifas de cabina

  pcTOP_CEN.visible:=false;  //oculta punto de control
  Locate(100,100);
  Name := 'Grupo Cabinas';
  Resize(100, 29);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;
destructor TogGCabinas.Destroy;
begin
  grupTar.Destroy;
  tarif.Destroy;
  inherited Destroy;
end;

{ TogGNiloM }
procedure TogGNiloM.Draw;
begin
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //Dibuja íconos
//  if TCibGFacNiloM(GFac).estadoCnx = necConectado then begin  //**** Aún no se ve estados
    v2d.DrawImageN(icoConec, x, y-2);
//  end else begin
//    v2d.DrawImageN(icoDesc, x, y-2);
//  end;
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited Draw;
end;
procedure TogGNiloM.SetCadPropied(lineas: TSTringList);
begin
  TCibGFacNiloM.DecodCadPropied(lineas, Name, CategVenta, Fx, Fy, PuertoN,
    facCmoneda, IniLLamMan, IniLLamTemp, PerLLamTemp);
  ReLocate(x, y);  //Porque ha habido cambios en X,Y
end;
constructor TogGNiloM.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipGFac := ctfNiloM;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Self.Locate(100,100);
  Name := 'Grupo NiloM';
  Resize(100, 29);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;
{ TogGMesas }
procedure TogGMesas.Draw;
begin
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DrawImageN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited;
end;
procedure TogGMesas.SetCadPropied(lineas: TSTringList);
begin
  TCibGFacMesas.DecodCadPropied(lineas, Name, CategVenta, Fx, Fy);
  ReLocate(x, y);  //Porque ha habido cambios en X,Y
end;
constructor TogGMesas.Create(mGraf: TMotGraf);
begin
  inherited Create(mGraf);
  tipGFac := ctfMesas;
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Self.Locate(100,100);
  Name := 'Grupo Clientes';
  Resize(100, 29);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
end;

end.

