unit FormPrincipal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, ExtCtrls, LCLProc, ActnList, Menus,
  ComCtrls, Dialogs, MisUtils, ogDefObjGraf, FormIngVentas, FormConfig,
  frameCfgUsuarios, Globales, frameVisCPlex, ObjGraficos, FormFijTiempo,
  FormExplorCab, FormVisorMsjRed, FormBoleta, FormRepIngresos, FormBusProductos,
  FormInicio, CibRegistros, CibTramas, CibFacturables, CPProductos,
  CibGFacCabinas, CibGFacNiloM;
type
  { TfrmPrincipal }
  TfrmPrincipal = class(TForm)
  published
    acCabDetCta: TAction;
    acCabGraBol: TAction;
    acCabIniCta: TAction;
    acCabModTpo: TAction;
    acEnvCom: TAction;
    acEnvMjeTit: TAction;
    acRefPan: TAction;
    acSisConfig: TAction;
    acArcSalir: TAction;
    acGCabAdmCab: TAction;
    acGCabAdmTarCab: TAction;
    acCabPonMan: TAction;
    acCabPaus: TAction;
    acCabExplorArc: TAction;
    acCabMsjesRed: TAction;
    acCabPropied: TAction;
    acCabVerBol: TAction;
    acBusTarif: TAction;
    acBusRutas: TAction;
    acBusProduc: TAction;
    acBusGastos: TAction;
    acNilPropied: TAction;
    acEdiInsEnrut: TAction;
    acEdiInsGrCab: TAction;
    acEdiElimGru: TAction;
    acNilConex: TAction;
    acArcRutTrab: TAction;
    acLocConectar: TAction;
    acLocDesconec: TAction;
    acVerRepIng: TAction;
    ActionList1: TActionList;
    acVerPant: TAction;
    ImageList32: TImageList;
    ImageList16: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem47: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem9: TMenuItem;
    panLLam: TPanel;
    panBolet: TPanel;
    PopupLocutor: TPopupMenu;
    PopupCabina: TPopupMenu;
    PopupGCabina: TPopupMenu;
    PopupGNiloM: TPopupMenu;
    splPanLlam: TSplitter;
    splPanBolet: TSplitter;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure acArcRutTrabExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acBusGastosExecute(Sender: TObject);
    procedure acBusProducExecute(Sender: TObject);
    procedure acBusRutasExecute(Sender: TObject);
    procedure acBusTarifExecute(Sender: TObject);
    procedure acCabDetCtaExecute(Sender: TObject);
    procedure acCabExplorArcExecute(Sender: TObject);
    procedure acCabGraBolExecute(Sender: TObject);
    procedure acCabIniCtaExecute(Sender: TObject);
    procedure acCabModTpoExecute(Sender: TObject);
    procedure acCabMsjesRedExecute(Sender: TObject);
    procedure acCabPonManExecute(Sender: TObject);
    procedure acCabVerBolExecute(Sender: TObject);
    procedure acEdiElimGruExecute(Sender: TObject);
    procedure acEdiInsEnrutExecute(Sender: TObject);
    procedure acEdiInsGrCabExecute(Sender: TObject);
    procedure acLocConectarExecute(Sender: TObject);
    procedure acLocDesconecExecute(Sender: TObject);
    procedure acNilConexExecute(Sender: TObject);
    procedure acNilPropiedExecute(Sender: TObject);
    procedure acGCabAdmCabExecute(Sender: TObject);
    procedure acGCabAdmTarCabExecute(Sender: TObject);
    procedure acSisConfigExecute(Sender: TObject);
    procedure acVerRepIngExecute(Sender: TObject);
    procedure ConfigfcVistaUpdateChanges;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure VisorCabinas_ClickDer(xp, yp: integer);
    procedure grupos_CambiaPropied;
    procedure Timer1Timer(Sender: TObject);
  private
    log : TCibArcReg;
    tabPro: TCibTabProduc;
    Visor : TfraVisCPlex;     //Visor de cabinas
    TramaTmp    : TCPTrama;    //Trama temporal
//    fallasesion : boolean;  //indica si se cancela el inicio de sesión
    tic : integer;
    function BuscarExplorCab(nomCab: string; CrearNuevo: boolean=false
      ): TfrmExplorCab;
    function grupos_LogIngre(ident: char; msje: string; dCosto: Double
      ): integer;
    function grupos_LogError(msj: string): integer;
    function grupos_LogVenta(ident:char; msje:string; dCosto:Double): integer;
    procedure grupos_ActualizStock(const codPro: string;
      const Ctdad: double);
    procedure grupos_ReqConfigGen(var NombProg, NombLocal, Usuario: string);
    procedure frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
    procedure frmBoletaGrabarItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_DividirItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_ComentarItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_RecuperarItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_DesecharItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmBoleta_DevolverItem(CibFac: TCibFac; idItemtBol, coment: string);
    procedure frmIngVentas_AgregarVenta(CibFac: TCibFac; itBol: string);
    function grupos_LogInfo(msj: string): integer;
    procedure grupos_EstadoArchivo;
    procedure LeerEstadoDeArchivo;
    procedure NiloM_RegMsjError(NomObj: string; msj: string);
    procedure PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
    procedure VisorCabinasObjectsMoved;
    procedure VisorCabinas_DblClick(Sender: TObject);
  public
    { public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
{$R *.lfm}

procedure TfrmPrincipal.grupos_CambiaPropied;
{Se produjo un cambio en alguna de las propiedades de alguna de las cabinas.}
begin
  debugln('** Cambio de propiedades: ');
  Config.escribirArchivoIni;  //guarda cambios
  Visor.ActualizarPropiedades(Config.grupos.CadPropiedades);
end;
function TfrmPrincipal.grupos_LogInfo(msj: string): integer;
begin
  Result := log.PLogInf(usuario, msj);
end;
function TfrmPrincipal.grupos_LogVenta(ident: char; msje: string; dCosto: Double
  ): integer;
begin
  Result := log.PLogVenta(ident, msje, dCosto);
end;
function TfrmPrincipal.grupos_LogIngre(ident: char; msje: string;
  dCosto: Double): integer;
begin
  Result := log.PLogIngre(ident, msje, dCosto);
end;
function TfrmPrincipal.grupos_LogError(msj: string): integer;
begin
  Result := log.PLogErr(usuario, msj);
end;
procedure TfrmPrincipal.grupos_EstadoArchivo;
{Guarda el estado de los objetos al archivo de estado}
var
  lest: TStringList;
begin
  lest:= TSTringList.Create;
  lest.Text := Config.grupos.CadEstado;
  lest.SaveToFile(arcEstado);
  lest.Destroy;
end;
procedure TfrmPrincipal.grupos_ReqConfigGen(var NombProg, NombLocal,
  Usuario: string);
begin
  NombProg  := NOM_PROG;
  NombLocal := Config.Local;
  Usuario   := FormInicio.usuario;
end;
procedure TfrmPrincipal.grupos_ActualizStock(const codPro: string;
  const Ctdad: double);
{Se está solicitando actualizar el stock. Esta petición usualmente viene desde una
boleta.}
begin
  tabPro.ActualizarStock(arcProduc, codPro, Ctdad);
  if msjError <> '' Then begin
      //Se muestra aquí porque no se va a detener el flujo del programa por
      //un error, porque es prioritario registrar la venta.
      MsgBox(msjError);
  end;
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
  Visor.motEdi.OnClickDer:=@VisorCabinas_ClickDer;
  Visor.motEdi.OnDblClick:=@VisorCabinas_DblClick;
  Visor.OnObjectsMoved:=@VisorCabinasObjectsMoved;
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
  Config.grupos.OnCambiaPropied:= @grupos_CambiaPropied;
  Config.grupos.OnLogInfo      := @grupos_LogInfo;
  Config.grupos.OnLogVenta     := @grupos_LogVenta;
  Config.grupos.OnLogIngre     := @grupos_LogIngre;
  Config.grupos.OnLogError     := @grupos_LogError;
  Config.grupos.OnGuardarEstado:= @grupos_EstadoArchivo;
  Config.grupos.OnReqConfigGen := @grupos_ReqConfigGen;
  Config.grupos.OnReqCadMoneda := @Config.CadMon;
  Config.grupos.OnActualizStock:=@grupos_ActualizStock;
  //Crea los objetos gráficos de cabina de acuerdo.
  Visor.ActualizarPropiedades(config.grupos.CadPropiedades);
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
  frmBoleta.OnGrabarBoleta:=@frmBoleta_GrabarBoleta;
  frmBoleta.OnDevolverItem:=@frmBoleta_DevolverItem;
  frmBoleta.OnDesecharItem:=@frmBoleta_DesecharItem;
  frmBoleta.OnRecuperarItem:=@frmBoleta_RecuperarItem;
  frmBoleta.OnComentarItem:=@frmBoleta_ComentarItem;
  frmBoleta.OnDividirItem:=@frmBoleta_DividirItem;
  frmBoleta.OnGrabarItem:=@frmBoletaGrabarItem;
  log.PLogInf(usuario, IntToStr(tabPro.Productos.Count) + ' productos cargados');
  {frmInicio.edUsu.Text := 'admin';
  frmInicio.ShowModal;
  if frmInicio.cancelo then begin
    fallasesion := True;
    Close;
  end;}
usuario := 'admin';
perfil  := PER_ADMIN;
  self.Activate;
  self.SetFocus;
  //self.Show;
end;
procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Config.escribirArchivoIni;  //guarda la configuración actual
  grupos_EstadoArchivo;       //guarda estado
end;
procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  log.PLogInf(usuario, '----------------- Fin de Programa ---------------');
  Debugln('Terminando ... ');
  tabPro.Destroy;
  log.Destroy;
  TramaTmp.Destroy;
  //Matar a los hilos de ejecución, puede tomar tiempo
end;
procedure TfrmPrincipal.VisorCabinas_ClickDer(xp, yp: integer);
begin
  if Visor.Seleccionado = nil then exit;
  //hay objeto seleccionado
  if Visor.Seleccionado.Id = ID_CABINA then PopupCabina.PopUp;
  if Visor.Seleccionado.Id = ID_NILOM then PopupLocutor.PopUp;
  if Visor.Seleccionado.Id = ID_GCABINA then PopupGCabina.PopUp;
  if Visor.Seleccionado.Id = ID_GNILOM then PopupGNiloM.PopUp;
end;
procedure TfrmPrincipal.VisorCabinas_DblClick(Sender: TObject);
begin
  if Visor.Seleccionado = nil then exit;
  acCabExplorArcExecute(self);
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
    grupos_EstadoArchivo; //Por si ha habido cambios
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
procedure TfrmPrincipal.frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
{Graba el contenido de una boleta}
begin
  if MsgYesNo('Grabar Boleta de: ' + CibFac.Nombre + '?')<>1 then exit;
  PonerComando(C_ACC_BOLET, ACCBOL_GRA, 0, CibFac.IdFac);
end;
procedure TfrmPrincipal.frmIngVentas_AgregarVenta(CibFac: TCibFac; itBol: string
  );
{Este evento se genera cuando se solicita ingresar una venta a la boletad e un objeto.}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + itBol;
  PonerComando(C_ACC_BOLET, ACCITM_AGR, 0, txt);  //envía con tamaño en Y
end;
procedure TfrmPrincipal.frmBoleta_DevolverItem(CibFac: TCibFac; idItemtBol,
  coment: string);
{Evento que solicita eliminar un ítem de la boleta}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(C_ACC_BOLET, ACCITM_DEV, 0, txt);  //envía con tamaño en Y
end;
procedure TfrmPrincipal.frmBoleta_DesecharItem(CibFac: TCibFac; idItemtBol,
  coment: string);
{Evento que solicita desechar un ítem de una boleta}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(C_ACC_BOLET, ACCITM_DES, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_RecuperarItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(C_ACC_BOLET, ACCITM_REC, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_ComentarItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;
  PonerComando(C_ACC_BOLET, ACCITM_COM, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_DividirItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;  //aquí coment contiene un número
  PonerComando(C_ACC_BOLET, ACCITM_DIV, 0, txt);
end;
procedure TfrmPrincipal.frmBoletaGrabarItem(CibFac: TCibFac; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := CibFac.IdFac + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_ACC_BOLET, ACCITM_GRA, 0, txt);
end;
function TfrmPrincipal.BuscarExplorCab(nomCab: string; CrearNuevo: boolean = false): TfrmExplorCab;
{Busca si existe un formaulario de tipo "TfrmVisorMsjRed", que haya sido crreado para
un nombre de cabina en especial. }
var
  i: Integer;
  frm: TfrmExplorCab;
begin
  for i:=0 to ComponentCount-1 do begin
    if Components[i] is TfrmExplorCab then begin
      frm := TfrmExplorCab(Components[i]);
      if frm.nomCab = nomCab then
        exit(frm);   //coincide
    end;
  end;
  //No encontró
  if CrearNuevo then begin
    //debugln('Creando nuevo formulario.');
    Result := TfrmExplorCab.Create(self);
    {Los formularios los destruirá el formulario principal, ya que se han creado con
    este propietario.}
  end else begin
    Result := nil;
  end;
end;
procedure TfrmPrincipal.PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Envía un comando al modelo, de la misma forma a como si fuera un comando remoto.
}
begin
  TramaTmp.Inic(comando, ParamX, ParamY, cad); //usa trama temporal
  //Llama como evento, indicando que es una trama local.
  //No se incluye nombre del OF y GOF que geenran la trama, proque es local.
  Config.grupos.gof_TramaLista('', '', TramaTmp, true);
end;
procedure TfrmPrincipal.VisorCabinasObjectsMoved;
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
      Gfac := Config.grupos.BuscarPorNombre(TogFac(og).NomGrupo);  //ubica a su grupo
      if Gfac=nil then exit;
      fac := Gfac.ItemPorNombre(og.Nombre);
      fac.x := og.x;
      fac.y := og.y;
    end;
  end;
  Config.grupos.DeshabEven:=false;   //restaura estado
  Config.grupos.OnCambiaPropied;
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
begin
  grupNILOm := TCibGFacNiloM.Create('NILO-m', false);
  //Inicializa Nilo-m
  //grupNILOm.OnRegMsjError:=@NiloM_RegMsjError;
  //grupNILOm.Conectar;
  //if grupNILOm.MsjError<>'' then self.Close;  //Error grave
  Config.grupos.Agregar(grupNILOm);  //agrega el grupo
end;
procedure TfrmPrincipal.acEdiElimGruExecute(Sender: TObject);  //Eliminar grupo
var
  gcab: TCibGFac;
  og: TObjGraf;
  ogGCab: TogGCabinas;
begin
  og := Visor.Seleccionado;
  if og = nil then exit;
  if (og is TogGCabinas) then begin
    ogGCab := TogGCabinas(og);  //restaura objeto
    gcab := Config.grupos.BuscarPorNombre(ogGCab.GFac.Nombre);  //Busca grupo en el modelo
    Config.grupos.Eliminar(gcab);
  end;
  if (og is TogGNiloM) then begin
///    ogGCab := TogGCabinas(og);  //restaura objeto
//    gcab := Config.grupos.BuscarPorNombre(ogGCab.GFac.Nombre);  //Busca grupo en el modelo
//    Config.grupos.Eliminar(gcab);
  end;
end;
//Acciones Buscar
procedure TfrmPrincipal.acBusTarifExecute(Sender: TObject);
begin

end;
procedure TfrmPrincipal.acBusRutasExecute(Sender: TObject);
begin

end;
procedure TfrmPrincipal.acBusProducExecute(Sender: TObject);
begin
  frmBusProductos.Exec(tabPro);
end;
procedure TfrmPrincipal.acBusGastosExecute(Sender: TObject);
begin

end;
//Acciones de Grupos de Cabinas
procedure TfrmPrincipal.acGCabAdmTarCabExecute(Sender: TObject);
var
  ogGcab: TogGCabinas;
  gcab: TCibGFac;
begin
  ogGcab := Visor.GCabinasSeleccionado;
  if ogGcab = nil then exit;
  {Aquí sería fácil acceder a "ogGcab.gcab.frmAdminCabs", pero esta sería la ventana
  de administración de la copia, no del modelo original.}
  gcab := Config.grupos.BuscarPorNombre(ogGcab.GFac.Nombre);  //Busca grupo en el modelo
  TCibGFacCabinas(gcab).frmAdminTar.Show;
end;
procedure TfrmPrincipal.acGCabAdmCabExecute(Sender: TObject);
{Muestra la ventana de administración de cabinas.}
var
  ogGcab: TogGCabinas;
  gcab: TCibGFac;
begin
  ogGcab := Visor.GCabinasSeleccionado;
  if ogGcab = nil then exit;
  {Aquí sería fácil acceder a "ogGcab.gcab.frmAdminCabs", pero esta sería la ventana
  de administración de la copia, no del modelo original.}
  gcab := Config.grupos.BuscarPorNombre(ogGcab.GFac.Nombre);  //Busca grupo en el modelo
  TCibGFacCabinas(gcab).frmAdminCabs.Show;  //abre su ventana de administración
end;
//Acciones de Cabinas
procedure TfrmPrincipal.acCabIniCtaExecute(Sender: TObject);
//Inicia la cuenta de una cabina de internet
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  if ogCab.EnManten then begin
    if MsgYesNo('¿Sacar cabina de mantenimiento?') <> 1 then exit;
  end else if not ogCab.Detenida then begin
    msgExc('No se puede iniciar una cuenta en esta cabina.');
    exit;
  end;
  frmFijTiempo.MostrarIni(ogCab);  //modal
  if frmFijTiempo.cancelo then exit;  //canceló
  PonerComando(C_INI_CTAPC, 0, 0, frmFijTiempo.CadActivacion);
end;
procedure TfrmPrincipal.acCabModTpoExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  if ogCab.Detenida then begin
    acCabIniCtaExecute(self);  //está detenida, inicia la cuenta
  end else if ogCab.Contando then begin
    //está en medio de una cuenta
    frmFijTiempo.Mostrar(ogCab);  //modal
    if frmFijTiempo.cancelo then exit;  //canceló
    PonerComando(C_MOD_CTAPC, 0, 0, frmFijTiempo.CadActivacion);
  end;
end;
procedure TfrmPrincipal.acCabDetCtaExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  if MsgYesNo('¿Desconectar Computadora: ' + ogCab.nombre + '?') <> 1 then exit;
  PonerComando(C_DET_CTAPC, 0, 0, ogCab.Fac.IdFac);
end;
procedure TfrmPrincipal.acCabPonManExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  if not ogCab.Detenida then begin
    MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
    exit;
  end;
  PonerComando(C_DET_CTAPC, 1, 0, ogCab.nombre); //El mismo comando, pone en mantenimiento
end;
procedure TfrmPrincipal.acCabExplorArcExecute(Sender: TObject);
//Muestra la ventana explorador de archivo
var
  ogCab: TogCabina;
  frmExpArc: TfrmExplorCab;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  //Busca si ya existe ventana exploradora, creadas para esta cabina
  frmExpArc := BuscarExplorCab(ogCab.Nombre, true);
  frmExpArc.Exec(Visor, ogCab.Nombre);
end;
procedure TfrmPrincipal.acCabMsjesRedExecute(Sender: TObject);
var
  ogCab: TogCabina;
  frmMsjes: TfrmVisorMsjRed;
  gcab: TCibGFac;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  //Ubica a su grupo en el modelo
  gcab := Config.grupos.BuscarPorNombre(ogCab.Fac.Grupo.Nombre);  //Busca grupo en el modelo
  //Busca si ya existe ventana de mensajes, creadas para esta cabina
  frmMsjes := TCibGFacCabinas(gcab).BuscarVisorMensajes(ogCab.Nombre, true);
  frmMsjes.Exec(ogCab.Nombre);
end;
procedure TfrmPrincipal.acCabGraBolExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  frmBoleta_GrabarBoleta(ogCab.Fac,'');
end;
procedure TfrmPrincipal.acCabVerBolExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  frmBoleta.Exec(ogCab.Fac, tabPro);
end;
//Acciones de Grupo NILO-m
procedure TfrmPrincipal.acNilConexExecute(Sender: TObject);
var
  ogGnil: TogGNiloM;
  gnil: TCibGFac;
begin
  ogGnil := Visor.GNiloMSeleccionado;
  if ogGnil = nil then exit;
  {Aquí sería fácil acceder a "ogGnil.gcab.frmAdminCabs", pero esta sería la ventana
  de administración de la copia, no del modelo original.}
  gnil := Config.grupos.BuscarPorNombre(ogGnil.GFac.Nombre);  //Busca grupo en el modelo
  TCibGFacNiloM(gnil).frmNilomConex.Show;
end;
procedure TfrmPrincipal.acNilPropiedExecute(Sender: TObject);
var
  ogGnil: TogGNiloM;
  gnil: TCibGFac;
begin
  ogGnil := Visor.GNiloMSeleccionado;
  if ogGnil = nil then exit;
  {Aquí sería fácil acceder a "ogGnil.gcab.frmAdminCabs", pero esta sería la ventana
  de administración de la copia, no del modelo original.}
  gnil := Config.grupos.BuscarPorNombre(ogGnil.GFac.Nombre);  //Busca grupo en el modelo
  TCibGFacNiloM(gnil).frmNilomProp.Show;
end;
//Acciones de locutorio
procedure TfrmPrincipal.acLocConectarExecute(Sender: TObject);
var
  ogLoc: TogNiloM;
begin
  ogLoc := Visor.LocSeleccionado;
  if ogLoc = nil then exit;
  PonerComando(C_ACC_NILOM, ACCLOC_CONEC, 0, ogLoc.loc.IdFac);
end;
procedure TfrmPrincipal.acLocDesconecExecute(Sender: TObject);
var
  ogLoc: TogNiloM;
begin
  ogLoc := Visor.LocSeleccionado;
  if ogLoc = nil then exit;
  PonerComando(C_ACC_NILOM, ACCLOC_DESCO, 0, ogLoc.loc.IdFac);
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

end.

