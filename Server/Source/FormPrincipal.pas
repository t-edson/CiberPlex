unit FormPrincipal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, Forms, Controls, ExtCtrls, LCLProc, ActnList, Menus, ComCtrls,
  MisUtils, FormIngVentas, FormConfig, frameCfgUsuarios, Globales,
  frameVisCPlex, ObjGraficos, FormFijTiempo, FormAdminCabinas, FormExplorCab,
  FormVisorMsjRed, FormBoleta, FormRepIngresos, FormBusProductos, FormInicio,
  CPRegistros, CPTramas, CPUtils, CibFacturables, CPProductos,
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
    acArcTarifas: TAction;
    acArcRutas: TAction;
    acBusTarif: TAction;
    acBusRutas: TAction;
    acBusProduc: TAction;
    acBusGastos: TAction;
    acNilVerTerm: TAction;
    acEdiInsEnrut: TAction;
    acEdiInsGrCab: TAction;
    acVerRepIng: TAction;
    ActionList1: TActionList;
    acVerPant: TAction;
    ImageList32: TImageList;
    ImageList16: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
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
    MenuItem4: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    panLLam: TPanel;
    panBolet: TPanel;
    PopupCabina: TPopupMenu;
    PopupGCabina: TPopupMenu;
    splPanLlam: TSplitter;
    splPanBolet: TSplitter;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure acArcRutasExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acArcTarifasExecute(Sender: TObject);
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
    procedure acEdiInsEnrutExecute(Sender: TObject);
    procedure acEdiInsGrCabExecute(Sender: TObject);
    procedure acNilVerTermExecute(Sender: TObject);
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
    GFacCabinas : TCibGFacCabinas;  //Grupo de cabinas
    VisorCabinas: TfraVisCPlex;     //Visor de cabinas
    TramaTmp    : TCPTrama;    //Trama temporal
//    fallasesion : boolean;  //indica si se cancela el inicio de sesión
    tic : integer;
    function BuscarExplorCab(nomCab: string; CrearNuevo: boolean=false
      ): TfrmExplorCab;
    function BuscarVisorMensajes(nomCab: string; CrearNuevo: boolean=false
      ): TfrmVisorMsjRed;
    procedure frmBoleta_GrabarBoleta(const nombreObj, coment: string);
    procedure frmBoletaGrabarItem(const nombreObj, idItemtBol, coment: string);
    procedure frmBoleta_DividirItem(const nombreObj, idItemtBol, coment: string);
    procedure frmBoleta_ComentarItem(const nombreObj, idItemtBol, coment: string
      );
    procedure frmBoleta_RecuperarItem(const nombreObj, idItemtBol, coment: string
      );
    procedure frmBoleta_DesecharItem(const nombreObj, idItemtBol, coment: string);
    procedure frmBoleta_DevolverItem(const nombreObj, idItemtBol, coment: string);
    procedure frmIngVentas_AgregarVenta(nombreObj: string; itBol: string);
    procedure GFacCabinas_LogInfo(cab: TCibFacCabina; msj: string);
    procedure GFacCabinas_DetenConteo(cab: TCibFacCabina);
    procedure GFacCabinas_RegMensaje(NomCab: string; msj: string);
    procedure GFacCabinas_TramaLista(cabOrig: TCibFacCabina; tram: TCPTrama; tramaLocal: boolean);
    procedure GuardarEstadoArchivo;
    procedure LeerEstadoDeArchivo;
    procedure NiloM_RegMsjError(NomObj: string; msj: string);
    procedure PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
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
  VisorCabinas.ActualizarPropiedades(Config.grupos.CadPropiedades);
end;
procedure TfrmPrincipal.GFacCabinas_TramaLista(cabOrig: TCibFacCabina;
  tram: TCPTrama; tramaLocal: boolean);
{Rutina de respuesta al mensaje OnTramaListade GrupoCabinas. También se usa para ejecutar
comandos del visor local. Los parámetros son:
"cabOrig" -> Es la cabina origen, de donde llega la trama. Para comandos locales es NIL
"tram" -> Es la trama que contiene el comando que debe ejecutarse.}
var
  frm: TfrmVisorMsjRed;
  arch: RawByteString;
  HoraPC, tSolic: TDateTime;
  NombrePC, Nombre, tmp: string;
  bloqueado: boolean;
  cabDest: TCibFacCabina;
  tLibre, horGra: boolean;
  itBol, itBol2: TCibItemBoleta;
  a: TStringDynArray;
  parte: Double;
  idx, idx2: LongInt;
begin
  //debugln(NomCab + ': Trama recibida: '+ tram.TipTraHex);
  if not tramaLocal then begin  //Ignora los mensajes locales
     frm := BuscarVisorMensajes(cabOrig.Nombre);  //Ve si hay un formulario de mensajes para esta cabina
     {Aunque no se ha detectado consumo de CPU adicional, la búqsqueda regular con
     BuscarVisorMensajes() puede significar una carga innecesaria de CPU, considerando que
     se hace para todos los mensjaes que llegan.
     }
     if frm<>nil then frm.PonerMsje('>>Recibido: ' + tram.TipTraNom);  //Envía mensaje a su formulario
  end;
  case tram.tipTra of
  M_ESTAD_CLI: begin  //Se recibió el estado remoto del clente
      Decodificar_M_ESTAD_CLI(tram.traDat, NombrePC, HoraPC, bloqueado);
      cabOrig.NombrePC:= NombrePC;
      cabOrig.HoraPC  := HoraPC;
      cabOrig.PantBloq:= bloqueado;
    end;
  C_SOL_T_PCS: begin  //Se solicita la lista de tiempos de las PC cliente
      debugln(cabOrig.Nombre + ': Tiempos de PC solicitado.');
      GFacCabinas.TCP_envComando(cabOrig.Nombre, M_SOL_T_PCS, 0, 0,
         GFacCabinas.CadEstado);
    end;
  C_SOL_ARINI: begin  //Se solicita el archivo INI (No está bien definido)
      GFacCabinas.TCP_envComando(cabOrig.Nombre, M_SOL_ARINI, 0, 0, config.grupos.CadPropiedades);
    end;
  C_PAN_COMPL: begin  //se pide una captura de pantalla
      debugln(cabOrig.Nombre+ ': Pantalla completa solicitada.');
      if tram.posX = 0 then begin  //se pide de la PC local
        arch := ExtractFilePath(Application.ExeName) + '~00.tmp';
        PantallaAArchivo(arch);
        GFacCabinas.TCP_envComando(cabOrig.Nombre, M_PAN_COMP, 0, 0, StringFromFile(arch));
      end else begin

      end;
    end;
  C_INI_CTAPC: begin   //Se pide iniciar la cuenta de una PC
      DecodActivCabina(tram.traDat, Nombre, tSolic, tLibre, horGra );
      if Nombre='' then exit; //protección
      cabDest := GFacCabinas.CabPorNombre(Nombre);
      cabDest.InicConteo(tSolic, tLibre, horGra);
      GuardarEstadoArchivo;        //Para salvar cambios
    end;
  C_MOD_CTAPC: begin   //Se pide modificar la cuenta de una PC
      DecodActivCabina(tram.traDat, Nombre, tSolic, tLibre, horGra );
      if Nombre='' then exit; //protección
      cabDest := GFacCabinas.CabPorNombre(Nombre);
      cabDest.ModifConteo(tSolic, tLibre, horGra);
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_DET_CTAPC: begin  //Se pide detener la cuenta de las PC
      cabDest := GFacCabinas.CabPorNombre(tram.traDat);
      if cabDest=nil then exit;
      if tram.posX = 1 then begin  //Indica que se quiere poner en mantenimiento.
        cabDest.PonerManten();
      end else begin
        cabDest.DetenConteo();
      end;
      GuardarEstadoArchivo;        //Para salvar la grabación de boleta
      { TODO : Por lo que se ve aquí, no sería necesario guardar regularmente el archivo
      de estado, (como se hace actualmente con el timer) , ya que se está detectando cada
      evento que geenra cambios. Verificar si  eso es cierto, sobre todo en el caso de la
      desconexión automático, o algún otro evento similar que requiera guardar el estado.}
    end;
  C_GRA_BOLPC: begin  //Se pide grabar la boleta de una PC
      cabDest := GFacCabinas.CabPorNombre(tram.traDat);
      if cabDest=nil then exit;
      for itBol in cabDest.boleta.items do begin
    {    If Pventa = '' Then //toma valor por defecto
            itBol.pVen = PVentaDef
        else    //escribe con punto de venta
            itBol.pVen = Me.Pventa
        end;}
        tmp := itBol.regIBol_AReg;
        If itBol.estado = IT_EST_NORMAL Then PLogIBol(tmp)        //item normal
        else PLogIBolD(tmp);       //item descartado
      end;
      //Graba los campos de la boleta
      cabDest.boleta.fec_grab := now;  //fecha de grabación
      PLogBol(cabDest.Boleta.RegVenta, cabDest.boleta.TotPag);
      //Config.escribirArchivoIni;
      GuardarEstadoArchivo;        //Para salvar la grabación de boleta
      cabDest.LimpiarBol;          //Limpia los items
    end;
  C_AGR_ITBOL: begin  //Se pide agregar una venta
      tmp := tram.traDat;
      cabDest := GFacCabinas.CabPorNombre(copy(tmp,1,tram.posY));
      if cabDest=nil then exit;
      delete(tmp, 1, tram.posY);  //quita nombre, deja cadena de estado
      itBol := TCibItemBoleta.Create;
      itBol.CadEstado := tmp;  //recupera ítem
      cabDest.Boleta.VentaItem(itBol, true);
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_DEV_ITBOL: begin  //Devolver ítem
      a := Explode(#9, tram.traDat);
      cabDest := GFacCabinas.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      itBol.Cant   := -itBol.Cant;   //pone cantidad negativa
      itBol.subtot := -itBol.subtot; //pone total negativo
      PLogVenD(ItBol.regIBol_AReg, itBol.subtot);  //registra mensaje
      cabDest.Boleta.ItemDelete(a[1]);  //quita de la lista
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_DES_ITBOL: begin  //Desechar ítem
      a := Explode(#9, tram.traDat);
      cabDest := GFacCabinas.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      itBol.estado := IT_EST_DESECH;
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_REC_ITBOL: begin  //Recuperar ítem
      a := Explode(#9, tram.traDat);
      cabDest := GFacCabinas.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := '';         //escribe comentario
      itBol.estado := IT_EST_NORMAL;
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_COM_ITBOL: begin  //Comentar ítem
      a := Explode(#9, tram.traDat);
      cabDest := GFacCabinas.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_DIV_ITBOL: begin
      a := Explode(#9, tram.traDat);
      cabDest := GFacCabinas.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      //actualiza ítem inicial
      parte := StrToFloat(a[2]);
      itBol.subtot:= itBol.subtot - parte;
      itBol.fragmen += 1;  //lleva cuenta
      //agrega elemento separado
      itBol2 := TCibItemBoleta.Create;
      itBol2.Assign(itBol);  //crea copia
      //actualiza separación
      itBol2.vfec:=now;   //El ítem debe tener otro ID
      itBol2.subtot := parte;
      itBol2.fragmen := 1;      //marca como separado
      itBol2.conStk := false;   //para que no descuente
      cabDest.Boleta.VentaItem(itBol2, true);  //agrega nuevo ítem
      //Reubica ítem
      idx := cabDest.Boleta.items.IndexOf(itBol);
      idx2 := cabDest.Boleta.items.IndexOf(itBol2);
      cabDest.Boleta.items.Move(idx2, idx+1);  //acomoda posición
      cabDest.Boleta.Recalcula;
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  C_GRA_ITBOL: begin
      a := Explode(#9, tram.traDat);
      cabDest := GFacCabinas.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      If itBol.estado = IT_EST_NORMAL Then PLogIBol(tmp)        //item normal
      else PLogIBolD(tmp);       //item descartado
      cabDest.Boleta.ItemDelete(a[1]);
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      GuardarEstadoArchivo;        //Para salvar cambios en la boleta
    end;
  else
    if frm<>nil then frm.PonerMsje('  ¡¡Comando no implementado!!');  //Envía mensaje a su formaulario
  end;
end;
//}
procedure TfrmPrincipal.GFacCabinas_RegMensaje(NomCab: string; msj: string);
var
  frm: TfrmVisorMsjRed;
begin
  frm := BuscarVisorMensajes(NomCab);  //Ve si hay un formulario de mensajes para esta cabina
  if frm<>nil then frm.PonerMsje(msj);  //Envía mensaje a su formaulario
end;
procedure TfrmPrincipal.GFacCabinas_DetenConteo(cab: TCibFacCabina);
{Se usa este evento para guardar información en el registro, y actualizar la boleta.
Se hace desde fuera de CPGrupoCabinas, porque para estas acciones se requiere acceso a
campos de configuración propios de esta aplicación, que no corresponden a CPGRupoCabinas
que es usada también en el Ciberplex-Visor.}
var
  nser: Integer;
  r: TCibItemBoleta;
begin
  //Registra la venta en el archivo de registro
  if cab.horGra Then { TODO : Revisar si este código se puede uniformizar con las otras llamadas a VentaItem() }
    nser := PLogIntD(cab.RegVenta, cab.Costo)
  else
    nser := PLogInt(cab.RegVenta, cab.Costo);
  If msjError <> '' Then MsgErr(msjError);
  //agrega item a boleta
  r := TCibItemBoleta.Create;   //crea elemento
  r.vser := nser;
  r.Cant := 1;
  r.pUnit := cab.Costo;
  r.subtot := cab.Costo;
  r.cat := cab.Grupo.CategVenta;
  r.subcat := 'INTERNET';
  r.descr := 'Alquiler PC: ' + IntToStr(cab.tSolicMin) + 'm(' +
             TimeToStr(cab.TranscDat) + ')';
  r.vfec := date + Time;
  r.estado := IT_EST_NORMAL;
  r.fragmen := 0;
  r.conStk := False;     //No se descuenta stock
  cab.Boleta.VentaItem(r, False);
  //fBol.actConBoleta;   //Actualiza la boleta porque se hace "VentaItem" sin mostrar
end;
procedure TfrmPrincipal.GFacCabinas_LogInfo(cab: TCibFacCabina; msj: string);
begin
  PLogInf(usuario, msj);
end;
procedure TfrmPrincipal.NiloM_RegMsjError(NomObj: string; msj: string);
begin
  PLogErr(usuario, msj);
end;
procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  Caption := NOM_PROG + ' ' + VER_PROG;
  //Crea un grupo de cabinas
  GFacCabinas := TCibGFacCabinas.Create('Cabinas');
  TramaTmp := TCPTrama.Create;
  {Crea un visor aquí, para que el Servidor pueda servir tambien como Punto de Venta}
  VisorCabinas := TfraVisCPlex.Create(self);
  VisorCabinas.Parent := self;
  VisorCabinas.Align := alClient;
  VisorCabinas.motEdi.OnClickDer:=@VisorCabinas_ClickDer;
  VisorCabinas.motEdi.OnDblClick:=@VisorCabinas_DblClick;
  tic := 0;   //inicia contador
end;
procedure TfrmPrincipal.FormShow(Sender: TObject);
var
  Err: String;
begin
  Config.grupos.Agregar(GFacCabinas);  //agrega el grupo de cabinas por defecto
  Config.Iniciar(GFacCabinas);  //lee configuración
  Config.OnPropertiesChanges:=@ConfigfcVistaUpdateChanges;
  LeerEstadoDeArchivo;   //Lee después de leer la configuración
  //Inicializa GFacCabinas
  Config.grupos.OnCambiaPropied:=@grupos_CambiaPropied;
  GFacCabinas.OnTramaLista   :=@GFacCabinas_TramaLista;
  GFacCabinas.OnRegMensaje   :=@GFacCabinas_RegMensaje;
  GFacCabinas.OnDetenConteo  :=@GFacCabinas_DetenConteo;
  GFacCabinas.OnLogInfo      :=@GFacCabinas_LogInfo;

  //Crea los objetos gráficos de cabina de acuerdo a GFacCabinas
  VisorCabinas.ActualizarPropiedades(config.grupos.CadPropiedades);
  {Actualzar Vista. Se debe hacer después de agregar los objetos, porque dependiendo
   de "ModoDiseño" se debe cambiar el modo de bloqueo de lso objetos existentes}
  ConfigfcVistaUpdateChanges;
  //Verifica si se puede abrir el archivo de registro principal
  AbrirPLog(rutDatos, Config.Local);
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

  PLogInf(usuario, '----------------- Inicio de Programa ---------------');
  Err := CargarProductos(arcProduc);
  if Err<>'' then begin
    PLogErr(usuario, Err);
    MsgErr(Err);
  end;
  frmIngVentas.LeerDatos;
  frmIngVentas.OnAgregarVenta:=@frmIngVentas_AgregarVenta;
  frmBoleta.OnGrabarBoleta:=@frmBoleta_GrabarBoleta;
  frmBoleta.OnDevolverItem:=@frmBoleta_DevolverItem;
  frmBoleta.OnDesecharItem:=@frmBoleta_DesecharItem;
  frmBoleta.OnRecuperarItem:=@frmBoleta_RecuperarItem;
  frmBoleta.OnComentarItem:=@frmBoleta_ComentarItem;
  frmBoleta.OnDividirItem:=@frmBoleta_DividirItem;
  frmBoleta.OnGrabarItem:=@frmBoletaGrabarItem;
  PLogInf(usuario, IntToStr(Productos.Count) + ' productos cargados');
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
  GuardarEstadoArchivo;       //guarda estado
end;
procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  PLogInf(usuario, '----------------- Fin de Programa ---------------');
  Debugln('Terminando ... ');
  TramaTmp.Destroy;
  //Matar a los hilos de ejecución, puede tomar tiempo
end;
procedure TfrmPrincipal.VisorCabinas_ClickDer(xp, yp: integer);
begin
  if VisorCabinas.Seleccionado = nil then exit;
  //hay objeto seleccionado
  if VisorCabinas.Seleccionado.Id = ID_CABINA then PopupCabina.PopUp;
  if VisorCabinas.Seleccionado.Id = ID_GCABINA then PopupGCabina.PopUp;
end;
procedure TfrmPrincipal.VisorCabinas_DblClick(Sender: TObject);
begin
  if VisorCabinas.Seleccionado = nil then exit;
  acCabExplorArcExecute(self);
end;
procedure TfrmPrincipal.GuardarEstadoArchivo;
{Guarda el estado de los objetos al archivo de estado}
var
  lest: TStringList;
begin
  lest:= TSTringList.Create;
  lest.Text := Config.grupos.CadEstado;
  lest.SaveToFile(arcEstado);
  lest.Destroy;
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
  VisorCabinas.ActualizarEstado(Config.grupos.CadEstado);
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
    GuardarEstadoArchivo; //Por si ha habido cambios
  end;
end;
procedure TfrmPrincipal.ConfigfcVistaUpdateChanges;
//Cambios en vista
begin
  panLLam.Visible := Config.verPanLlam;
  panBolet.Visible:= Config.verPanBol;
  VisorCabinas.ObjBloqueados := not Config.modDiseno;
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
function TfrmPrincipal.BuscarVisorMensajes(nomCab: string; CrearNuevo: boolean = false): TfrmVisorMsjRed;
{Busca si existe un formaulario de tipo "TfrmVisorMsjRed", que haya sido crreado para
un nombre de cabina en especial. }
var
  i: Integer;
  frm: TfrmVisorMsjRed;
begin
  for i:=0 to ComponentCount-1 do begin
    if Components[i] is TfrmVisorMsjRed then begin
      frm := TfrmVisorMsjRed(Components[i]);
      if frm.nomCab = nomCab then
        exit(frm);   //coincide
    end;
  end;
  //No encontró
  if CrearNuevo then begin
    //debugln('Creando nuevo formulario.');
    Result := TfrmVisorMsjRed.Create(self);
    {Los formularios los destruirá el formulario principal, ya que se han creado con
    este propietario.}
  end else begin
    Result := nil;
  end;
end;
procedure TfrmPrincipal.frmIngVentas_AgregarVenta(nombreObj: string;
  itBol: string);
{Este evento se genera cuando se solicita ingresar una venta a la boletad e un objeto.}
var
  txt: string;
begin
  txt := nombreObj + itBol;  //junta nombre de objeto con cadena de estado
  PonerComando(C_AGR_ITBOL, 0, length(nombreObj), txt);  //envía con tamaño en Y
end;
procedure TfrmPrincipal.frmBoleta_GrabarBoleta(const nombreObj, coment: string);
{Graba el contenido de una boleta}
begin
  if MsgYesNo('Grabar Boleta de: ' + nombreObj + '?')<>1 then exit;
  PonerComando(C_GRA_BOLPC, 0, 0, nombreObj);
end;
procedure TfrmPrincipal.frmBoleta_DevolverItem(const nombreObj, idItemtBol,
  coment: string);
{Evento que solicita eliminar un ítem de la boleta}
var
  txt: string;
begin
  txt := nombreObj + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_DEV_ITBOL, 0, 0, txt);  //envía con tamaño en Y
end;
procedure TfrmPrincipal.frmBoleta_DesecharItem(const nombreObj, idItemtBol,
  coment: string);
{Evento que solicita desechar un ítem de una boleta}
var
  txt: string;
begin
  txt := nombreObj + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_DES_ITBOL, 0, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_RecuperarItem(const nombreObj, idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := nombreObj + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_REC_ITBOL, 0, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_ComentarItem(const nombreObj, idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := nombreObj + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_COM_ITBOL, 0, 0, txt);
end;
procedure TfrmPrincipal.frmBoleta_DividirItem(const nombreObj, idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := nombreObj + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_DIV_ITBOL, 0, 0, txt);
end;
procedure TfrmPrincipal.frmBoletaGrabarItem(const nombreObj, idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := nombreObj + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  PonerComando(C_GRA_ITBOL, 0, 0, txt);
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
{procedure TfrmPrincipal.ChangeAppearance;
begin
  StatusBar1.Visible := Config.fcIDE.ViewStatusbar;
  acVerBarEst.Checked := Config.fcIDE.ViewStatusbar;
  ToolBar1.Visible := Config.fcIDE.ViewToolbar;
  acVerBarHer.Checked:= Config.fcIDE.ViewToolbar;

  panMessages.Visible:= Config.fcIDE.ViewPanMsg;
  Splitter2.Visible := Config.fcIDE.ViewPanMsg;
  acVerPanMsj.Checked:= Config.fcIDE.ViewPanMsg;
end;
}
procedure TfrmPrincipal.PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Envía un comando, llamando directamente a GrupoCabinas_TramaLista()}
begin
  TramaTmp.Inic(comando, ParamX, ParamY, cad); //usa trama temporal
  GFacCabinas_TramaLista(nil, TramaTmp, true);
end;
//////////////// Acciones //////////////////////
procedure TfrmPrincipal.acArcTarifasExecute(Sender: TObject);  //Tarifas
begin

end;
procedure TfrmPrincipal.acArcRutasExecute(Sender: TObject);   //Rutas
begin

end;
procedure TfrmPrincipal.acArcSalirExecute(Sender: TObject);   //Salir
begin
  Close;
end;
procedure TfrmPrincipal.acEdiInsGrCabExecute(Sender: TObject);  //Inserta Grupo de cabinas
{var
  ncabTxt, nom: String;
  ncab: Longint;
  grupCabinas: TCPGrupoCabinas;}
begin
{  ncabTxt := InputBox('', 'Número de cabinas', '10');
  if not TryStrToInt(ncabTxt, ncab) then exit;
  nom := 'Cabinas'+IntToStr(Config.grupos.NumGrupos+1);   //nombre
  grupCabinas := TCPGrupoCabinas.Create(nom);  //crea grupo
  Config.grupos.Agregar(grupCabinas);  //agrega el grupo}
end;
procedure TfrmPrincipal.acEdiInsEnrutExecute(Sender: TObject); //Inserta Enrutador
var
  grupNILOm: TCibGFacNiloM;
begin
  grupNILOm := TCibGFacNiloM.Create('NILO-m','12',Config.Local, NOM_PROG, 0.1,
                               usuario, 'LLAMADAS');
  //Inicializa Nilo-m
  //grupNILOm.OnRegMsjError:=@NiloM_RegMsjError;
  //grupNILOm.Conectar;
  //if grupNILOm.MsjError<>'' then self.Close;  //Error grave
  Config.grupos.Agregar(grupNILOm);  //agrega el grupo
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
  frmBusProductos.Show;
end;
procedure TfrmPrincipal.acBusGastosExecute(Sender: TObject);
begin

end;
//Acciones de Grupos de Cabinas
procedure TfrmPrincipal.acGCabAdmTarCabExecute(Sender: TObject);
var
  ogGcab: TogGCabinas;
begin
  ogGcab := VisorCabinas.GCabSeleccionada;
  if ogGcab = nil then exit;
  ogGcab.gcab.frmAdminTar.Show;
end;
procedure TfrmPrincipal.acGCabAdmCabExecute(Sender: TObject);
var
  ogGcab: TogGCabinas;
begin
  ogGcab := VisorCabinas.GCabSeleccionada;
  if ogGcab = nil then exit;
  ogGcab.gcab.frmAdminCabs.Show;
end;
//Acciones de Cabinas
procedure TfrmPrincipal.acCabIniCtaExecute(Sender: TObject);
//Inicia la cuenta de una cabina de internet
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
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
  ogCab := VisorCabinas.CabSeleccionada;
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
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  if MsgYesNo('¿Desconectar Computadora: ' + ogCab.nombre + '?') <> 1 then exit;
  PonerComando(C_DET_CTAPC, 0, 0, ogCab.nombre);
end;
procedure TfrmPrincipal.acCabPonManExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
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
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  //Busca si ya existe ventana exploradora, creadas para esta cabina
  frmExpArc := BuscarExplorCab(ogCab.Nombre, true);
  frmExpArc.Exec(VisorCabinas, ogCab.Nombre);
end;
procedure TfrmPrincipal.acCabMsjesRedExecute(Sender: TObject);
var
  ogCab: TogCabina;
  frmMsjes: TfrmVisorMsjRed;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  //Busca si ya existe ventana de mensajes, creadas para esta cabina
  frmMsjes := BuscarVisorMensajes(ogCab.Nombre, true);
  frmMsjes.Exec(ogCab.Nombre);
end;
procedure TfrmPrincipal.acCabGraBolExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  if MsgYesNo('Grabar Boleta de: ' + ogCab.nombre + '?')<>1 then exit;
  PonerComando(C_GRA_BOLPC, 0, 0, ogCab.nombre);
end;
procedure TfrmPrincipal.acCabVerBolExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  frmBoleta.Exec(ogCab.cab);
end;
procedure TfrmPrincipal.acNilVerTermExecute(Sender: TObject);
begin
  //escuchar;
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

