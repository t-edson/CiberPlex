unit FormPrincipal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, LCLProc, ActnList, Menus,
  ComCtrls, Dialogs, MisUtils, ogDefObjGraf, FormIngVentas, FormConfig,
  frameCfgUsuarios, Globales, frameVisCPlex, ObjGraficos, FormBoleta,
  FormRepIngresos, FormBusProductos, FormAcercaDe, FormCalcul, FormContDinero,
  FormInicio, CibRegistros, CibTramas, CibFacturables, CibProductos,
  CibGFacCabinas, CibGFacNiloM;
type
  { TfrmPrincipal }
  TfrmPrincipal = class(TForm)
  published
    acFacGraBol: TAction;
    acEnvCom: TAction;
    acEnvMjeTit: TAction;
    acRefPan: TAction;
    acSisConfig: TAction;
    acArcSalir: TAction;
    acFacVerBol: TAction;
    acBusProduc: TAction;
    acBusGastos: TAction;
    acEdiInsEnrut: TAction;
    acEdiInsGrCab: TAction;
    acEdiElimGru: TAction;
    acArcRutTrab: TAction;
    acFacAgrVen: TAction;
    acFacMovBol: TAction;
    acAyuAcerca: TAction;
    acAyuCalcul: TAction;
    acAyuBlocNot: TAction;
    acAyuContDin: TAction;
    acVerRepIng: TAction;
    ActionList1: TActionList;
    acVerPant: TAction;
    ImageList32: TImageList;
    ImageList16: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    panLLam: TPanel;
    panBolet: TPanel;
    PopupFac: TPopupMenu;
    splPanLlam: TSplitter;
    splPanBolet: TSplitter;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    procedure acArcRutTrabExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acAyuAcercaExecute(Sender: TObject);
    procedure acAyuBlocNotExecute(Sender: TObject);
    procedure acAyuCalculExecute(Sender: TObject);
    procedure acAyuContDinExecute(Sender: TObject);
    procedure acBusGastosExecute(Sender: TObject);
    procedure acBusProducExecute(Sender: TObject);
    procedure acFacAgrVenExecute(Sender: TObject);
    procedure acFacGraBolExecute(Sender: TObject);
    procedure acFacMovBolExecute(Sender: TObject);
    procedure acFacVerBolExecute(Sender: TObject);
    procedure acEdiElimGruExecute(Sender: TObject);
    procedure acEdiInsEnrutExecute(Sender: TObject);
    procedure acEdiInsGrCabExecute(Sender: TObject);
    procedure acSisConfigExecute(Sender: TObject);
    procedure acVerRepIngExecute(Sender: TObject);
    procedure ConfigfcVistaUpdateChanges;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure Visor_ClickDerFac(ogFac: TogFac; X, Y: Integer);
    procedure Modelo_CambiaPropied;
    procedure Timer1Timer(Sender: TObject);
  private
    log : TCibArcReg;
    tabPro: TCibTabProduc;
    Visor : TfraVisCPlex;     //Visor de cabinas
    TramaTmp    : TCPTrama;    //Trama temporal
    fallasesion : boolean;  //indica si se cancela el inicio de sesión
    tic : integer;
    procedure Modelo_RespComando(idVista: string; comando: TCPTipCom;
      ParamX, ParamY: word; cad: string);
    procedure frmBoleta_AgregarItem(CibFac: TCibFac; coment: string);
    procedure Visor_ClickDerGFac(ogGFac: TogGFac; X, Y: Integer);
    procedure Visor_DobleClickFac(ogFac: TogFac; X, Y: Integer);
    procedure Visor_DobleClickGFac(ogGFac: TogGFac; X, Y: Integer);
    procedure Visor_SolicEjecCom(comando: TCPTipCom; ParamX,
      ParamY: word; cad: string);
    function Modelo_LogIngre(ident: char; msje: string; dCosto: Double
      ): integer;
    function Modelo_LogError(msj: string): integer;
    function Modelo_LogVenta(ident:char; msje:string; dCosto:Double): integer;
    procedure Modelo_ActualizStock(const codPro: string;
      const Ctdad: double);
    procedure Modelo_ReqConfigGen(var NombProg, NombLocal, Usuario: string);
    procedure frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
    procedure frmBoletaGrabarItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_DividirItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_ComentarItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_RecuperarItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_DesecharItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_DevolverItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmIngVentas_AgregarVenta(CibFac: TCibFac; itBol: string);
    function Modelo_LogInfo(msj: string): integer;
    procedure Modelo_EstadoArchivo;
    procedure LeerEstadoDeArchivo;
    procedure NiloM_RegMsjError(NomObj: string; msj: string);
    procedure PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
    procedure Visor_ObjectsMoved;
  public
    { public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
{$R *.lfm}

procedure TfrmPrincipal.Modelo_CambiaPropied;
{Se produjo un cambio en alguna de las propiedades de alguna de las cabinas.}
begin
  debugln('** Cambio de propiedades: ');
  Config.escribirArchivoIni;  //guarda cambios
  Visor.ActualizarPropiedades(Config.grupos.CadPropiedades);
end;
function TfrmPrincipal.Modelo_LogInfo(msj: string): integer;
begin
  Result := log.PLogInf(usuario, msj);
end;
function TfrmPrincipal.Modelo_LogVenta(ident: char; msje: string; dCosto: Double
  ): integer;
begin
  Result := log.PLogVenta(ident, msje, dCosto);
end;
function TfrmPrincipal.Modelo_LogIngre(ident: char; msje: string;
  dCosto: Double): integer;
begin
  Result := log.PLogIngre(ident, msje, dCosto);
end;
function TfrmPrincipal.Modelo_LogError(msj: string): integer;
begin
  Result := log.PLogErr(usuario, msj);
end;
procedure TfrmPrincipal.Modelo_EstadoArchivo;
{Guarda el estado de los objetos al archivo de estado}
var
  lest: TStringList;
begin
  lest:= TSTringList.Create;
  lest.Text := Config.grupos.CadEstado;
  lest.SaveToFile(arcEstado);
  lest.Destroy;
end;
procedure TfrmPrincipal.Modelo_ReqConfigGen(var NombProg, NombLocal,
  Usuario: string);
begin
  NombProg  := NOM_PROG;
  NombLocal := Config.Local;
  Usuario   := FormInicio.usuario;
end;
procedure TfrmPrincipal.Modelo_ActualizStock(const codPro: string;
  const Ctdad: double);
{Se está solicitando actualizar el stock. Esta petición usualmente viene desde una
boleta.}
begin
  tabPro.ActualizarStock(arcProduc, codPro, Ctdad);
  if msjError <> '' Then begin
      //Se muestra aquí porque no se va acAyuCalcul detener el flujo del programa por
      //un error, porque es prioritario registrar la venta.
      MsgBox(msjError);
  end;
end;
procedure TfrmPrincipal.Modelo_RespComando(idVista: string; comando: TCPTipCom;
  ParamX, ParamY: word; cad: string);
{El modelo está solitando responder un comando, acAyuCalcul una vista}
var
  fac: TCibFac;
  cab: TCibFacCabina;
begin
  if idVista = '$' then begin
    //La respuesta es para la vista local
    Visor.EjecRespuesta(comando, ParamX, ParamY, cad);
  end else begin
    //La respuesta es para una vista en una PC de la red.
    //Para enviar acAyuCalcul una PC remota, se debe hacer acAyuCalcul través del propio modelo
    fac := Modelo.BuscarPorID(idVista);  //Se ubica acAyuCalcul quien responder, con "idVista".
    if fac = nil then
      exit;  //No deberíacAyuCalcul pasar. ¿Habrá desaparecido?
    if not (fac is TCibFacCabina) then begin
      exit;  {No es PC. ¿Qué raro?. Se supone que, por ahora, solo las PC
              CIBERPLEX-PVenta, CIBERPLEX-Admin), son capaces de generar comandos.}
    end;
    cab := TCibFacCabina(FAC);
    cab.TCP_envComando(comando, ParamX, ParamY, cad);
  end;
end;
procedure TfrmPrincipal.Visor_SolicEjecCom(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
{Aquí se llega por dos vías, ambas de tipo local (ya que los comandos remotos no llegan
por aquí):
1. Un GFac ha solicitado ejecutar un comando. Estos comandos son los que los objetos
facturables generan acAyuCalcul través de su método TCibGFac.EjecAccion.
2. El visor ha generado un evento, como el arrastre de objetos, que requiere ejecutar
una acción sobre el modelo.
Observar que este método es similar acAyuCalcul PonerComando(), pero allí llegan los comandos
que se generan con acciones de FormPrincipal.}
begin
  TramaTmp.Inic(comando, ParamX, ParamY, cad); //usa trama temporal
  //Llama como evento, indicando que vista solicitante es la local '$'.
  Config.grupos.EjecComando('$', TramaTmp);
end;
procedure TfrmPrincipal.Visor_ClickDerFac(ogFac: TogFac; X, Y: Integer);
{Se ha hecho click derecho en un facturable del visor.
Aunque se podría incluir este código en el mismo Visor, se pone aquí porque se
quiere dar a la aplicación la libertad de manejar estos eventos.}
var
  mn: TMenuItem;
  fac: TCibFac;
begin
  //Se ha seleccionado un facturable. Configura acciones.
  PopupFac.Items.Clear;
  ogFac.fac.MenuAccionesVista(PopupFac);
  //Agrega acciones que solo correrán en el Servidor, en Modelo
  fac := Modelo.BuscarPorID(ogFac.fac.IdFac);  //ubica facturable en el modelo
  if fac = nil then exit;   //no deberíacAyuCalcul pasar
  fac.MenuAccionesModelo(PopupFac);
  //Agrega los ítems del menú que son comunes acAyuCalcul todos los facturables
  mn :=  TMenuItem.Create(nil);
  mn.Caption:='-';
  PopupFac.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacVerBol;
  PopupFac.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacAgrVen;
  PopupFac.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacGraBol;
  PopupFac.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacMovBol;
  PopupFac.Items.Add(mn);

  PopupFac.PopUp;  //muestra
end;
procedure TfrmPrincipal.Visor_ClickDerGFac(ogGFac: TogGFac; X, Y: Integer);
{Se ha hecho click derecho en un grupo del visor.}
var
  gfac: TCibGFac;
  mn: TMenuItem;
begin
  PopupFac.Items.Clear;   //reusamos el PopUp
  ogGFac.GFac.MenuAccionesVista(PopupFac);
  gfac := Modelo.BuscarPorNombre(ogGFac.GFac.Nombre);
  if gfac = nil then exit;
  gfac.MenuAccionesModelo(PopupFac);

  //Agrega acciones comunes
  mn :=  TMenuItem.Create(nil);
  mn.Caption:='-';
  PopupFac.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acEdiElimGru;
  PopupFac.Items.Add(mn);

  PopupFac.PopUp;  //muestra
end;
procedure TfrmPrincipal.Visor_DobleClickFac(ogFac: TogFac; X, Y: Integer);
{Se ha hecho doble click en un fcaturable. Se debe seguir el mismo esquema que
Visor_ClickDer}
begin
  //Hay objeto seleccionado
  if ogFac.Fac is TCibFacCabina then begin
    //Abre explorador
    TCibFacCabina(ogFac.Fac).mnVerExplorad(self);
  end;
end;
procedure TfrmPrincipal.Visor_DobleClickGFac(ogGFac: TogGFac; X, Y: Integer);
begin

end;
procedure TfrmPrincipal.Visor_ObjectsMoved;
{Se ha producido el movimiento de objetos en el editor. Se actualiza en el modelo.}
var
  og: TObjGraf;
  Gfac: TCibGFac;
  fac: TCibFac;
begin
  //Se supone que se han movido los objetos seleccionados
  Config.grupos.DeshabEven:=true;   //para evitar interferencia
  for og in Visor.motEdi.seleccion do begin
    if og.Tipo = OBJ_GRUP then begin
      //Es un grupo. Ubica el obejto
      Gfac := Config.grupos.BuscarPorNombre(og.Nombre);
      if Gfac=nil then exit;
      Gfac.x := og.x;
      Gfac.y := og.y;
    end else if og.Tipo = OBJ_FACT then begin
      //Es un facturable
      Gfac := Config.grupos.BuscarPorNombre(TogFac(og).NomGrupo);  //ubica acAyuCalcul su grupo
      if Gfac=nil then exit;
      fac := Gfac.ItemPorNombre(og.Nombre);
      fac.x := og.x;
      fac.y := og.y;
    end;
  end;
  Config.grupos.DeshabEven:=false;   //restaura estado
  Config.grupos.OnCambiaPropied;
end;
procedure TfrmPrincipal.NiloM_RegMsjError(NomObj: string; msj: string);
begin
  log.PLogErr(usuario, msj);
end;
procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  Caption := NOM_PROG + ' ' + VER_PROG;
  //Crea un grupo de cabinas
  TramaTmp := TCPTrama.Create;
  log := TCibArcReg.Create;
  tabPro:= TCibTabProduc.Create;
  {Crea un visor aquí, para que el Servidor pueda servir tambien como Punto de Venta}
  Visor := TfraVisCPlex.Create(self);
  Visor.Parent := self;
  Visor.Align := alClient;
  tic := 0;   //inicia contador
end;
procedure TfrmPrincipal.FormShow(Sender: TObject);
var
  Err: String;
begin
  Config.Iniciar;  //lee configuración
  Config.OnPropertiesChanges:=@ConfigfcVistaUpdateChanges;
  LeerEstadoDeArchivo;   //Lee después de leer la configuración
  //Inicializa Grupos
  Modelo.OnCambiaPropied:= @Modelo_CambiaPropied;
  Modelo.OnLogInfo      := @Modelo_LogInfo;
  Modelo.OnLogVenta     := @Modelo_LogVenta;
  Modelo.OnLogIngre     := @Modelo_LogIngre;
  Modelo.OnLogError     := @Modelo_LogError;
  Modelo.OnGuardarEstado:= @Modelo_EstadoArchivo;
  Modelo.OnReqConfigGen := @Modelo_ReqConfigGen;
  Modelo.OnReqCadMoneda := @Config.CadMon;
  Modelo.OnActualizStock:= @Modelo_ActualizStock;
  Modelo.OnRespComando  := @Modelo_RespComando;
//  Modelo.OnSolicEjecCom := @Visor_SolicEjecCom;  {Se habilita para que las acciones
//                            puedan responderse desde el mismo modelo (ver Visor_ClickDerFac)}
  //Configura Visor para comunicar sus eventos
  Visor.OnClickDerFac   := @Visor_ClickDerFac;
  Visor.OnClickDerGFac  := @Visor_ClickDerGFac;
  Visor.OnDobleClickFac := @Visor_DobleClickFac;
  Visor.OnDobleClickGFac:= @Visor_DobleClickGFac;
  Visor.OnObjectsMoved  := @Visor_ObjectsMoved;
  Visor.OnSolicEjecCom  := @Visor_SolicEjecCom;  //Necesario para procesar las acciones de movimiento de boletas
  Visor.OnReqCadMoneda  := @Config.CadMon;   //Para que pueda mostrar monedas
  //Crea los objetos gráficos del visor de acuerdo al archivo INI.
  Visor.ActualizarPropiedades(Modelo.CadPropiedades);
  {Actualzar Vista. Se debe hacer después de agregar los objetos, porque dependiendo
   de "ModoDiseño" se debe cambiar el modo de bloqueo de lso objetos existentes}
  ConfigfcVistaUpdateChanges;
  //Verifica si se puede abrir el archivo de registro principal
  log.AbrirPLog(rutDatos, Config.Local);
  If msjError <> '' then begin
     MsgErr(msjError);
     //No tiene sentido seguir, si no se puede abrir registro
     Close;
  end;

  //verifica si hay información de usuarios
  if usuarios.Count = 0 Then begin
    //crea usuarios por defecto
    CreaUsuario('admin', '', PER_ADMIN);  //Usuario por defecto
    CreaUsuario('oper', '', PER_OPER);    //Usuario por defecto
  end;

  log.PLogInf(usuario, '----------------- Inicio de Programa ---------------');
  Err := tabPro.CargarProductos(arcProduc);
  if Err<>'' then begin
    log.PLogErr(usuario, Err);
    MsgErr(Err);
  end;
  //Configura formulario de ingreso de ventas
  frmIngVentas.TabPro := tabPro;
  frmIngVentas.LeerDatos;
  frmIngVentas.OnAgregarVenta:=@frmIngVentas_AgregarVenta;
  //Configrua formulario de boleta
  frmBoleta.OnAgregarItem  := @frmBoleta_AgregarItem;
  frmBoleta.OnGrabarBoleta := @frmBoleta_GrabarBoleta;
  frmBoleta.OnDevolverItem := @frmBoleta_DevolverItem;
  frmBoleta.OnDesecharItem := @frmBoleta_DesecharItem;
  frmBoleta.OnRecuperarItem:= @frmBoleta_RecuperarItem;
  frmBoleta.OnComentarItem := @frmBoleta_ComentarItem;
  frmBoleta.OnDividirItem  := @frmBoleta_DividirItem;
  frmBoleta.OnGrabarItem   := @frmBoletaGrabarItem;
  frmBoleta.OnReqCadMoneda := @Config.CadMon;
  log.PLogInf(usuario, IntToStr(tabPro.Productos.Count) + ' productos cargados');
  frmInicio.edUsu.Text := 'admin';
  frmInicio.ShowModal;
  if frmInicio.cancelo then begin
    fallasesion := True;
    Close;
  end;
  log.PLogInf(usuario, 'Sesión iniciada: ' + usuario);
//usuario := 'admin';
//perfil  := PER_ADMIN;
  self.Activate;
  self.SetFocus;
  //self.Show;
end;
procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  log.PLogInf(usuario, 'Sesión terminada: ' + usuario);
  Config.escribirArchivoIni;  //guarda la configuración actual
  Modelo_EstadoArchivo;       //guarda estado
end;
procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  log.PLogInf(usuario, '----------------- Fin de Programa ---------------');
  Debugln('Terminando ... ');
  tabPro.Destroy;
  log.Destroy;
  TramaTmp.Destroy;
  //Matar acAyuCalcul los hilos de ejecución, puede tomar tiempo
end;
procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: char);
{El formulario, intercepta el teclado}
begin
  if Key in ['0'..'9'] then begin
    if frmCalcul.Visible then begin
      //Si ya es visible, solo actualizamos
      frmCalcul.Edit1.Text:=Key;
      frmCalcul.Edit1.SelStart:=1;
      frmCalcul.Edit1.SelLength:=0;
      frmCalcul.Show;   //por si estaba sin enfoque
    end else begin
      frmCalcul.txtIni:=Key;
      frmCalcul.Show;
    end;
  end;
end;
procedure TfrmPrincipal.LeerEstadoDeArchivo;
{Lee el estado de los objetos del archivo de estado}
var
  cad: string;
begin
  if not FileExists(arcEstado) then begin
    msgErr('No se encuentra archivo de estado: ' + arcEstado);
    exit;
  end;
  cad := StringFromFile(arcEstado);
  Config.grupos.CadEstado := cad;
end;
procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
{Como esta rutina se ejecuta cada 0.5 segundos, no es necesario actualizarla por eventos.}
begin
//  debugln(tmp);
  Visor.ActualizarEstado(Config.grupos.CadEstado);
  //Aprovecha para refrescar la ventana de boleta
  if (frmBoleta<>nil) and frmBoleta.Visible then
    frmBoleta.ActualizarDatos;
  //Aprovecha para refrescar los exploradores de archivos
  Inc(tic);
//  if tic mod 2 = 0 then begin  //cada 1 seg
//    for
//  end;
  //Guarda en disco, por si acaso.
  if tic mod 60 = 0 then begin  //para evitar escribir muchas veces en disco
    Modelo_EstadoArchivo; //Por si ha habido cambios
  end;
end;
procedure TfrmPrincipal.ConfigfcVistaUpdateChanges;
//Cambios en vista
begin
  panLLam.Visible := Config.verPanLlam;
  panBolet.Visible:= Config.verPanBol;
  Visor.ObjBloqueados := not Config.modDiseno;
  case Config.StyleToolbar of
  stb_SmallIcon: begin
    ToolBar1.ButtonHeight:=22;
    ToolBar1.ButtonWidth:=22;
    ToolBar1.Height:=26;
    ToolBar1.Images:=ImageList16;
  end;
  stb_BigIcon: begin
    ToolBar1.ButtonHeight:=38;
    ToolBar1.ButtonWidth:=38;
    ToolBar1.Height:=40;
    ToolBar1.Images:=ImageList32;
  end;
  end;
end;
procedure TfrmPrincipal.frmIngVentas_AgregarVenta(CibFac: TCibFac; itBol: string
  );
{Este evento se genera cuando se solicita ingresar una venta acAyuCalcul la boleta de un objeto.}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + itBol;
  PonerComando(CVIS_ACBOLET, ACCITM_AGR, 0, txt);  //envíacAyuCalcul con tamaño en Y
end;
procedure TfrmPrincipal.frmBoleta_AgregarItem(CibFac: TCibFac; coment: string);
begin
  frmIngVentas.Exec(CibFac);
end;
procedure TfrmPrincipal.frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
{Graba el contenido de una boleta}
begin
  if MsgYesNo('Grabar Boleta de: ' + CibFac.Nombre + '?')<>1 then exit;
  PonerComando(CVIS_ACBOLET, ACCBOL_GRA, 0, CibFac.IdFac);
end;
procedure TfrmPrincipal.frmBoleta_DevolverItem(CibFac: TCibFac; idItemtBol,
  coment: string);
{Evento que solicita eliminar un ítem de la boleta}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(CVIS_ACBOLET, ACCITM_DEV, 0, txt);  //envíacAyuCalcul con tamaño en Y
end;
procedure TfrmPrincipal.frmBoleta_DesecharItem(CibFac: TCibFac; idItemtBol,
  coment: string);
{Evento que solicita desechar un ítem de una boleta}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(CVIS_ACBOLET, ACCITM_DES, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_RecuperarItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(CVIS_ACBOLET, ACCITM_REC, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_ComentarItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(CVIS_ACBOLET, ACCITM_COM, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_DividirItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;  //aquí coment contiene un número
  PonerComando(CVIS_ACBOLET, ACCITM_DIV, 0, txt);
end;
procedure TfrmPrincipal.frmBoletaGrabarItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(CVIS_ACBOLET, ACCITM_GRA, 0, txt);
end;
procedure TfrmPrincipal.PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{EnvíacAyuCalcul un comando al modelo, de la misma forma acAyuCalcul como si fuera un comando remoto.
}
begin
  TramaTmp.Inic(comando, ParamX, ParamY, cad); //usa trama temporal
  //Llama como evento, indicando que es una trama local.
  //No se incluye nombre del OF y GOF que geenran la trama, proque es local.
  Config.grupos.EjecComando('', TramaTmp);
end;
//////////////// Acciones //////////////////////
procedure TfrmPrincipal.acArcRutTrabExecute(Sender: TObject);
begin
  Exec('explorer', rutApp);
end;
procedure TfrmPrincipal.acArcSalirExecute(Sender: TObject);   //Salir
begin
  Close;
end;
//Acciones Editar
procedure TfrmPrincipal.acEdiInsGrCabExecute(Sender: TObject);  //Inserta Grupo de cabinas
var
  ncabTxt, nom: String;
  ncab: Longint;
  grupCabinas: TCibGFacCabinas;
begin
  ncabTxt := InputBox('', 'Número de cabinas', '5');
  if not TryStrToInt(ncabTxt, ncab) then exit;
  nom := 'Cabinas'+IntToStr(Config.grupos.NumGrupos+1);   //nombre
  grupCabinas := TCibGFacCabinas.Create(nom, false);  //crea grupo
  Config.grupos.Agregar(grupCabinas);  //agrega el grupo}
end;
procedure TfrmPrincipal.acEdiInsEnrutExecute(Sender: TObject); //Inserta Enrutador
var
  grupNILOm: TCibGFacNiloM;
  nom: String;
begin
  nom := InputBox('', 'Nombre: ', 'NILO-m');
  if trim(nom)='' then begin
    msgExc('Nombre no válido.');
    exit;
  end;
  if Config.grupos.BuscarPorNombre(nom) <> nil then begin
    msgExc('Nombre ya existe.');
    exit;
  end;
  grupNILOm := TCibGFacNiloM.Create(nom, false);
  //Inicializa Nilo-m
  //grupNILOm.OnRegMsjError:=@NiloM_RegMsjError;
  //grupNILOm.Conectar;
  //if grupNILOm.MsjError<>'' then self.Close;  //Error grave
  Config.grupos.Agregar(grupNILOm);  //agrega el grupo
end;
procedure TfrmPrincipal.acEdiElimGruExecute(Sender: TObject);  //Eliminar grupo
var
  gFac: TCibGFac;
  og: TObjGraf;
  ogGCab: TogGCabinas;
  ogGNil: TogGNiloM;
begin
  og := Visor.Seleccionado;
  if og = nil then exit;
  if (og is TogGCabinas) then begin
    ogGCab := TogGCabinas(og);
    gFac := Config.grupos.BuscarPorNombre(ogGCab.GFac.Nombre);  //Busca grupo en el modelo
    Config.grupos.Eliminar(gFac);
  end;
  if (og is TogGNiloM) then begin
    ogGNil := TogGNiloM(og);
    gFac := Config.grupos.BuscarPorNombre(ogGNil.GFac.Nombre);  //Busca grupo en el modelo
    Config.grupos.Eliminar(gFac);
  end;
end;
//Acciones Buscar
procedure TfrmPrincipal.acBusProducExecute(Sender: TObject);
begin
  frmBusProductos.Exec(tabPro);
end;
procedure TfrmPrincipal.acBusGastosExecute(Sender: TObject);
begin

end;
//Acciones sobre Facturables
procedure TfrmPrincipal.acFacGraBolExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  ogFac := Visor.FacSeleccionado;
  if ogFac = nil then exit;
  frmBoleta_GrabarBoleta(ogFac.Fac,'');
end;
procedure TfrmPrincipal.acFacAgrVenExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  ogFac := Visor.FacSeleccionado;
  if ogFac = nil then exit;
  frmIngVentas.Exec(ogFac.Fac);
end;
procedure TfrmPrincipal.acFacVerBolExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  ogFac := Visor.FacSeleccionado;
  if ogFac = nil then exit;
  frmBoleta.Exec(ogFac.Fac);
end;
procedure TfrmPrincipal.acFacMovBolExecute(Sender: TObject);
var
  cabDest: String;
  ogFac: TogFac;
  Fac2: TCibFac;
begin
  ogFac := Visor.FacSeleccionado;
  if ogFac = nil then exit;
//  if MsgYesNo('Trasladar Boleta de: ' + CibFac.Nombre + '?')<>1 then exit;
  cabDest := InputBox('','Indique la cabina destino: ','');
  if cabDest='' then exit;
  Fac2 := ogFac.gru.ItemPorNombre(cabDest);
  if Fac2 = nil then exit;
  PonerComando(CVIS_ACBOLET, ACCBOL_TRA, 0, ogFac.Fac.IdFac + #9 + Fac2.idFac);
end;
// Acciones Ver
procedure TfrmPrincipal.acVerRepIngExecute(Sender: TObject);
begin
  frmRepIngresos.Show;
end;
// Acciones del sistema
procedure TfrmPrincipal.acSisConfigExecute(Sender: TObject);
begin
  Config.Mostrar;
end;
//Acciones de Ayuda
procedure TfrmPrincipal.acAyuCalculExecute(Sender: TObject);
begin
  frmCalcul.Show;
end;

procedure TfrmPrincipal.acAyuContDinExecute(Sender: TObject);
begin
  frmContDinero.Show;
end;

procedure TfrmPrincipal.acAyuAcercaExecute(Sender: TObject);
begin
  frmAcercaDe.ShowModal;
end;
procedure TfrmPrincipal.acAyuBlocNotExecute(Sender: TObject);
begin
  MisUtils.Exec('CMD', '/C start "TITULO" "notepad"');
end;

end.

