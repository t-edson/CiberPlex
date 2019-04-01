unit FormOgCabinas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ActnList, Menus, MisUtils, ogMotGraf2D, CibUtils, ObjGraficos, CibFacturables,
  CibTramas, FormPropGFac, CibCabinaBase, FormFijTiempo, CibGFacCabinas,
  CibCabinaTarifas, FormAdminTarCab;
type

  { TogCabina }
  {Objeto gráfico que representa a los elementos TCibFacCabina}
  TogCabina = class(TogFac)
  private
  public
    procedure DibujarTiempo;
    procedure Draw; override;  //Dibuja el objeto gráfico
    procedure ProcDesac(estado0: Boolean);   //Para responder evento de Habilitar/Deshabilitar
    function Contando: boolean;
    function Detenida: boolean;
    function EnManten: boolean;
  private
    //BotDes   : TogButton;          //Refrencia global al botón de Desactivar
  public  //Estado reflejo del FAC al que representa
    cuenta  : TCabCuenta;
    estadoConex: TCibEstadoConex;
    HoraPC  : TDateTime;
    PantBloq: Boolean;
    FTransc : integer;
    FCosto  : double;
    function tSolicSeg: integer;
    function Faltante: integer;
    function TranscDat: TTime;
    property EstadoCta: TcabEstadoCuenta read cuenta.estado;
  public //Estado reflejo del FAC al que representa
    procedure SetCadEstado(str: string); override;
  public  //Propiedades reflejo del FAC al que representa
    IP, Mac, NombrePC, Coment: string;
    ConConexion: boolean;
    procedure SetCadPropied(str: string); override;
  public  //constructor y destructor
    constructor Create(mGraf: TMotGraf); reintroduce;
    destructor Destroy; override;
  end;

  { TogGCabinas }
  {Objeto gráfico que representa a los elementos TCibGFacCabinas}
  TogGCabinas = class(TogGFac)
  private
  public
    icono  : TGraphic;    //PC con control
    procedure Draw; override;  //Dibuja el objeto gráfico
  public  //Estados reflejo del GFAC al que representa
    procedure SetCadEstado(txt: string); override;
  public  //Propiedades reflejo del GFAC al que representa
    //También se guarda información de tarifas en el objeto
    grupTar: TGrupoTarAlquiler;  //Grupo de tarifas de alquiler
    tarif  : TCPTarifCabinas; //tarifas de cabina
    procedure SetCadPropied(lineas: TSTringList); override;
  protected
  public  //constructor y detsructor
    constructor Create(mGraf: TMotGraf); reintroduce;
    destructor Destroy; override;
  end;

type  //Formulario
  { TfrmOgCabinas }
  TfrmOgCabinas = class(TForm)
    ActionList1: TActionList;
    Image1: TImage;
    Image2: TImage;
    Image25: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    ImageList16: TImageList;
    ImageList32: TImageList;
  private
    procedure frmAdminTarCabModificado;
  public
    OnSolicEjecCom : TEvSolicEjecCom;     //Cuando solicita ejecutar un comando
    OnCambiaPropied: procedure of object; //Cuando cambia alguna variable de propiedad
  public  //Manejo de Grupos
    ogGFacCab: TogGCabinas;
    procedure MenuAccionesGru(ogGFacCab0: TogGCabinas; modDiseno: boolean;
                              MenuPopup: TPopupMenu);
    procedure mnAdminEquipos(Sender: TObject);
    procedure mnAdminTarifas(Sender: TObject);
    procedure mnPropiedadesGFac(Sender: TObject);
  public  //Manejo de Facturables
    ogFacCab : TogCabina;
    procedure MenuAccionesFac(ogFacCab0: TogCabina; modDiseno: boolean;
      MenuPopup: TPopupMenu; nShortCut: integer);
    procedure mnDetenCuenta(Sender: TObject);
    procedure mnEditComent(Sender: TObject);
    procedure mnEncenderPC(Sender: TObject);
    procedure mnFijTiempoIni(Sender: TObject);
    procedure mnInicCuenta(Sender: TObject);
    procedure mnModifCuenta(Sender: TObject);
    procedure mnPausarCuent(Sender: TObject);
    procedure mnPonerManten(Sender: TObject);
    procedure mnReinicCuent(Sender: TObject);
    procedure mnSacarManten(Sender: TObject);
    procedure mnVerExplorad(Sender: TObject);
    procedure mnVerMsjesRed(Sender: TObject);
  public
  end;

var
  frmOgCabinas: TfrmOgCabinas;
var
  icoModifCuenta: integer;
  icoDetenCuenta: integer;
  icoPonerManten: integer;
  icoAgregComent: integer;
  icoPausarCuent: integer;
  icoReinicCuent: integer;
  icoVerExplorad: integer;
  icoVerMsjesRed: integer;
  icoAdminTarifas: integer;
  icoAdminEquipos: integer;
  icoPropiedades: integer;
procedure CargarIconos(imgList16, imgList32: TImageList);

implementation
{$R *.lfm}
procedure CargarIconos(imgList16, imgList32: TImageList);
{Carga los íconos que necesita esta unida }
begin
  //Iconos del facturable
  icoModifCuenta := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 0, imgList16, imgList32);
  icoDetenCuenta := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 1, imgList16, imgList32);
  icoVerExplorad := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 2, imgList16, imgList32);
  icoAgregComent := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 3, imgList16, imgList32);
  icoPonerManten := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 4, imgList16, imgList32);
  icoPausarCuent := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 5, imgList16, imgList32);
  icoReinicCuent := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 11,imgList16, imgList32);
  icoVerMsjesRed := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 6, imgList16, imgList32);

  //Íconos del grupo
  icoAdminTarifas := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 7, imgList16, imgList32);
  icoAdminEquipos := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 8, imgList16, imgList32);
  icoPropiedades  := CargaPNG(frmOgCabinas.ImageList16, frmOgCabinas.ImageList32, 9, imgList16, imgList32);
end;
procedure TfrmOgCabinas.MenuAccionesFac(ogFacCab0: TogCabina; modDiseno: boolean;
                                        MenuPopup: TPopupMenu; nShortCut: integer);
{Configura las acciones del modelo. Lo ideal sería que todas las acciones se ejecuten
desde aquí.}
begin
  ogFacCab := ogFacCab0;
  InicLlenadoAcciones(MenuPopup);
  //Se ha visto que  la acción "Iniciar Cuenta" se puede reemplazar con "Modificar Tiempo".
  if ogFacCab.EstadoCta in [EST_CONTAN, EST_PAUSAD] then begin
    AgregarAccion(nShortCut, '&Modificar Tiempo'      , @mnModifCuenta, icoModifCuenta);
  end else begin
    AgregarAccion(nShortCut, '&Iniciar Cuenta'      , @mnModifCuenta, icoModifCuenta);
  end;
  AgregarAccion(nShortCut, '&Detener Cuenta'        , @mnDetenCuenta, icoDetenCuenta);
  AgregarAccion(nShortCut, '&Ver Explorador'       , @mnVerExplorad, icoVerExplorad);
  AgregarAccion(nShortCut, 'Editar &Comentario'    , @mnEditComent, icoAgregComent);
  if ogFacCab.EstadoCta = EST_MANTEN then begin
    AgregarAccion(nShortCut, 'Sacar de &Mantenimiento', @mnSacarManten, icoPonerManten);
  end else begin
    AgregarAccion(nShortCut, 'Poner en &Mantenimiento', @mnPonerManten, icoPonerManten);
  end;
  if ogFacCab.EstadoCta = EST_CONTAN then begin
    AgregarAccion(nShortCut, 'Pausar Cuenta'         , @mnPausarCuent, icoPausarCuent);
  end else if ogFacCab.EstadoCta = EST_PAUSAD then begin
    AgregarAccion(nShortCut, 'Reiniciar Cuenta'      , @mnReinicCuent, icoReinicCuent);
  end else begin
    //Agrega siempre un ítem, aunque sea desactivado, para no perder la secuencia de
    //acciones (Que siempre haya la misma cantidad).
    AgregarAccion(nShortCut, 'Pausar Cuenta'         , @mnPausarCuent, icoPausarCuent).Enabled:=false;
  end;
  AgregarAccion(nShortCut, '&Encender PC.'           , @mnEncenderPC, -1);
  AgregarAccion(nShortCut, '&Fijar Tiempo Inic.'     , @mnFijTiempoIni, -1);
//  AgregarAccion(nShortCut, 'Propiedades' , @mnVerMsjesRed, -1););
  AgregarAccion(nShortCut, 'Ver Mensajes de &Red' , @mnVerMsjesRed, icoVerMsjesRed);
end;
procedure TfrmOgCabinas.mnInicCuenta(Sender: TObject);
begin
  if ogFacCab.EstadoCta = EST_MANTEN then begin
    if MsgYesNo('¿Sacar cabina de mantenimiento?') <> 1 then exit;
  end else if not ogFacCab.Detenida then begin
    msgExc('No se puede iniciar una cuenta en esta cabina.');
    exit;
  end;
  frmFijTiempo.MostrarIni(ogFacCab.cuenta, ogFacCab.Name);  //modal
  if frmFijTiempo.cancelo then exit;  //canceló
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_INICTA, 0, ogFacCab.IdFac + #9 + frmFijTiempo.CadActivacion);
end;
procedure TfrmOgCabinas.mnModifCuenta(Sender: TObject);
begin
  if ogFacCab.Detenida then begin
    mnInicCuenta(self);  //está detenida, inicia la cuenta
  end else if ogFacCab.Contando then begin
    //Está en medio de una cuenta
    frmFijTiempo.Mostrar(ogFacCab.cuenta, ogFacCab.Name);  //modal
    if frmFijTiempo.cancelo then exit;  //canceló
    OnSolicEjecCom(CFAC_CABIN, C_CABIN_MODCTA, 0, ogFacCab.IdFac + #9 + frmFijTiempo.CadActivacion);
  end;
end;
procedure TfrmOgCabinas.mnDetenCuenta(Sender: TObject);
begin
  if MsgYesNo('¿Desconectar Computadora: ' + ogFacCab.Name+ '?') <> 1 then exit;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_DETCTA, 0, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnPonerManten(Sender: TObject);
begin
  if not ogFacCab.Detenida then begin
    MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
    exit;
  end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_PONMAN, 0, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnSacarManten(Sender: TObject);
begin
  //if not Detenida then begin
  //  MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
  //  exit;
  //end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_SACMAN, 0, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnEditComent(Sender: TObject);
var
  tmp: String;
begin
  tmp := InputBox('','Ingrese Comentario: ', ogFacCab.Coment);
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_EDICOM, 0, ogFacCab.IdFac + #9 + tmp);
end;
procedure TfrmOgCabinas.mnPausarCuent(Sender: TObject);
begin
  if ogFacCab.EstadoCta <> EST_CONTAN then begin
    MsgExc('No se puede pausar una cabina en este estado.');
    exit;
  end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_PONPAU, 0, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnReinicCuent(Sender: TObject);
begin
  if ogFacCab.EstadoCta <> EST_PAUSAD then begin
    MsgExc('La cabina no está en pausa.');
    exit;
  end;
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_QUIPAU, 0, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnVerExplorad(Sender: TObject);
{Muestra el explorador de archivos}
begin
  //frmExpArc.rutArchivos := rutArchivos;  //Actualiza ruta de archivos de descarga
  //frmExpArc.Exec(self);
end;
procedure TfrmOgCabinas.mnEncenderPC(Sender: TObject);
{Fija el tiempo inicial de una cabina.}
begin
  if ogFacCab.EstadoCta = EST_MANTEN then begin
    if MsgYesNo('Cabina en mantenimiento. ¿Encender?') <> 1 then exit;
  end;
  MsgBox('Encendiendo');
  //Fija minutos
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_ENCEPC, 0, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnFijTiempoIni(Sender: TObject);
{Fija el tiempo inicial de una cabina.}
var
  nnStr: String;
  nn: Longint;
begin
  if ogFacCab.EstadoCta = EST_MANTEN then begin
    if MsgYesNo('¿Sacar cabina de mantenimiento?') <> 1 then exit;
//  end else if not Detenida then begin
//    msgExc('No se puede iniciar una cuenta en esta cabina.');
//    exit;
  end;
  //Lee número de minutos
  nnStr := InputBox('', 'Número de minutos:', '');
  if nnStr='' then exit;
  if not TryStrToInt(nnStr, nn) then begin
    MsgExc('Error en número');
    exit;
  end;
  //Fija minutos
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJCTA, nn, ogFacCab.IdFac);
end;
procedure TfrmOgCabinas.mnVerMsjesRed(Sender: TObject);
{Muestra el formulario para ver los mensajes de red.}
begin
  //frmVisMsj.Exec(Nombre);
  {Manda comando para abrir le ventana de mensajes de Red.
  Notar que este comando no debería enviarse desde una vista remota, porque la ventana
  se abrirá siempre en el servidor.}
  OnSolicEjecCom(CFAC_CABIN, C_CABIN_MSJRED, 0, ogFacCab.IdFac);
end;
//Manejo de Grupos
procedure TfrmOgCabinas.frmAdminTarCabModificado;
{Se han cambiado las tarifas del facturable}
var
  tmp: String;
begin
  tmp := ogGFacCab.grupTar.StrObj + LineEnding + ogGFacCab.tarif.StrObj;
  OnSolicEjecCom(CFAC_GCABIN, C_GCAB_ACTTAR, 0, ogGFacCab.IdFac + #9 + tmp);
end;
procedure TfrmOgCabinas.MenuAccionesGru(ogGFacCab0: TogGCabinas;
  modDiseno: boolean; MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  ogGFacCab:= ogGFacCab0;
  InicLlenadoAcciones(MenuPopup);
  nShortCut := -1;
  AgregarAccion(nShortCut, 'Administrador de &Tarifas', @mnAdminTarifas, icoAdminTarifas);
  AgregarAccion(nShortCut, 'Administrador de &Equipos', @mnAdminEquipos, icoAdminEquipos);
  AgregarAccion(nShortCut, '&Propiedades', @mnPropiedadesGFac, icoPropiedades);
end;
procedure TfrmOgCabinas.mnAdminTarifas(Sender: TObject);
begin
  frmAdminTarCab.grpTarAlq := ogGFacCab.grupTar;
  frmAdminTarCab.tarCabinas := ogGFacCab.tarif;
  frmAdminTarCab.OnModificado := @frmAdminTarCabModificado;
  frmAdminTarCab.Show;
end;
procedure TfrmOgCabinas.mnAdminEquipos(Sender: TObject);
begin
  {Manda comando para abrir le ventana de administración de equipos.
  Notar que este comando no debería enviarse desde una vista remota, porque la ventana
  de administración se abrirá siempre en el servidor.}
  OnSolicEjecCom(CFAC_GCABIN, C_GCAB_ADMEQU, 0, ogGFacCab.IdFac + #9);
end;
procedure TfrmOgCabinas.mnPropiedadesGFac(Sender: TObject);
begin
  frmPropGFac.Exec(ogGFacCab);
  //Es modal, entonces aquí se puede actualizar sus propiedades
  if frmPropGFac.cancel then exit;
  {Faltaría implementar la actualziaicón de propiedades por comandos. Pero eso implica
  implmentar el método ogGFacCab.GetCadPropied (Virtual), y para eso comvendría imcluir
  uan forma de acceso de los og a sus og hijos, tal como se hace en el modelo, de forma
  que se uniformice la asignación de propiedades en el visor y en el modelo.}
  //OnSolicEjecCom(CFAC_G_PROP, 0, 0, ogGFacCab.IdFac + #9 + ogGFacCab.GetCadPropied);
end;
{ TogCabina }
function TogCabina.tSolicSeg: integer;
begin
  Result := round(cuenta.tSolic*86400)
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
  if cuenta.tLibre then begin
    v2d.SetBrush(COL_VERD_CLARO);   //siempre verde
  end else if cuenta.estado = EST_PAUSAD then begin
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
  if cuenta.tLibre then   //pidió tiempo libre
    v2d.SetText(clBlue, 10,'',true);
  //Genera Tiempo solicitado en texto descriptivo.
  if cuenta.tLibre then begin  //pidió tiempo libre
    tmp := '<libre>'
  end else if Abs(cuenta.tSolic - 1/24) < 0.0001 then
    tmp := '1 hora'
  else if Abs(cuenta.tSolic - 1/48) < 0.0001 then
    tmp := '1/2 hora'
  else if Abs(cuenta.tSolic - 1/96) < 0.0001 then
    tmp := '1/4 hora'
  else   //no es tiempo conocido
    DateTimeToString(tmp, 'hh:mm:ss', cuenta.tSolic);  //convierte
  //escribe tiempo
  v2d.Texto(x+4,y+17,tmp);
end;
procedure TogCabina.Draw;
var
  x2:Single;
  s: String;
  icoPC, icoPCdes, icoUSU, icoComent, icoRedAct, icoRedDes: TGraphic;
begin
  icoPC    := frmOgCabinas.Image5.Picture.Graphic;   //asigna imagen
  icoPCdes := frmOgCabinas.Image6.Picture.Graphic;   //asigna imagen
  icoUSU   := frmOgCabinas.Image2.Picture.Graphic;  //asigna imagen
  icoComent := frmOgCabinas.Image25.Picture.Graphic;
  icoRedAct := frmOgCabinas.Image3.Picture.Graphic;
  icoRedDes := frmOgCabinas.Image4.Picture.Graphic;
  x2 := x + width;
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
  if cuenta.estado in [EST_CONTAN, EST_PAUSAD] then begin
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
  if cuenta.estado in [EST_CONTAN, EST_PAUSAD] then begin
    //solo muestra tiempo, en conteo
    s := grupo.OnReqCadMoneda(FCosto);  //convierte a moneda
    v2d.SetText(clBlue, 11,'',false);
    v2d.TextoR(x+2, y+88, width-4, 22, s);
    if cuenta.horGra then begin  //hora gratis
       v2d.SetText(clRed, 10, '', true);
       v2d.Texto(x+25, y+40, 'GRATIS');
    end;
    //BotDes.estado:= true;
  end else begin
    //BotDes.estado:= false;
  end;
  //muestra ogBoleta
  if Boleta.ItemCount>0 then ogBoleta.Dibujar;  //dibuja ogBoleta
  if cuenta.estado = EST_MANTEN then begin
    //dibuja aspa roja
    v2d.SetPen(psSolid, 3, clred);
    v2d.Line(x,y,x2,y+90);
    v2d.Line(x2,y,x,y+90);
  end;
  inherited;
end;
procedure TogCabina.SetCadEstado(str: string);
var
  _Nombre, lin: String;
  lineas: TStringDynArray;
begin
  lineas := Explode(LineEnding, str);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  TCibFacCabina.DecodCadEstado(lin, _Nombre, estadoConex, HoraPC, PantBloq,
    cuenta.estado, cuenta.hor_ini, cuenta.tSolic, cuenta.tLibre, cuenta.horGra, FTransc, FCosto);
  //Agrega información de boletas
  LeerEstadoBoleta(Boleta, lineas);
end;
procedure TogCabina.SetCadPropied(str: string);
begin
  TCibFacCabina.DecodCadPropied(str, Name, IP, Mac, Fx, Fy, ConConexion, NombrePC, Coment);
//  ReLocate(Fx, Fy);   //para actualizar.
end;
function TogCabina.Contando: boolean;
begin
  Result := cuenta.estado in [EST_CONTAN, EST_PAUSAD];
end;
function TogCabina.Detenida: boolean;
begin
  Result := cuenta.estado = EST_NORMAL;
end;
function TogCabina.EnManten: boolean;
begin
  Result := cuenta.estado = EST_MANTEN;
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
  cuenta:= TCabCuenta.Create;
  //BotDes := AddButton(24, 24, BOT_REPROD, @ProcDesac);
  pcTOP_CEN.visible:=false;  //oculta punto de control
  Name := 'Cabina';
  Self.Locate(100,100);
  Resize(85, 130);     //Se debe llamar después de crear los puntos de control para poder ubicarlos
  ProcDesac(False);   //Desactivado := False
end;
destructor TogCabina.Destroy;
begin
  cuenta.Destroy;
  inherited Destroy;
end;

{ TogGCabinas }
procedure TogGCabinas.Draw;
begin
  icono := frmOgCabinas.Image7.Picture.Graphic;   //asigna imagen
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //dibuja íconos
  v2d.DrawImageN(icono, x, y-2);
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited;
end;
procedure TogGCabinas.SetCadEstado(txt: string);
begin
  //No hay estado para este grupo.
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

end.

