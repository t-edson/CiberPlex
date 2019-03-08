{                            CiberPlex Admin
Formulario principal de la aplicación.
El objeto principal de la aplicación es "ServCab"
que representa a la conexión en modo servidor que se requiere para conectarse a
CIBERPLEX-Serv, como una cabina cliente.
                                                    Por tito Hinostroza  24/07/2014
}
unit FormPrincipal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  Menus, lclProc, LCLType, LCLIntf, ExtCtrls, ComCtrls, Buttons, MisUtils,
  FormPant, FormLog, frameVisCPlex, ogDefObjGraf, ObjGraficos, CibTramas,
  FormBoleta, CibFacturables, CibServidorPC, FormInicio, Globales,
  FormSincronBD, FormExplorServ, FormReempProd, CibTabProductos,
  FormAdminProduc, FormAdminProvee, FormAdminInsum, CibBD, FormCalcul,
  FormRepIngresos, FormConfig, FormRepProducto, FrameSincroBD, FormRepEventos,
  FormIngCompras, CibTabInsumos, CibTabProvee, FormIngStock, FormValStock;
type
  { TForm1 }
  TForm1 = class(TForm)
    acAccEnvMjeTit: TAction;
    acCabModTpo: TAction;
    acCabIniCta: TAction;
    acCabDetCta: TAction;
    acFacGraBol: TAction;
    acAccVerPan: TAction;
    acAccRefObj: TAction;
    acCabExplorArc: TAction;
    acCabPonMan: TAction;
    acFacVerBol: TAction;
    acAyuCalc: TAction;
    acHerCamNomPro: TAction;
    acHerSincronizar: TAction;
    acSisIngStock: TAction;
    acSisValStock: TAction;
    acVerCarpApli: TAction;
    acVerIngCompras: TAction;
    acVerRepEve: TAction;
    acVerRepPro: TAction;
    acVerRepIng: TAction;
    acHerRegConex: TAction;
    acSisAdmProve: TAction;
    acSisAdmInsum: TAction;
    acSisAdmProd: TAction;
    acHerExpServ: TAction;
    ActionList1: TActionList;
    ImageList16: TImageList;
    ImageList32: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
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
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    PopupFac: TPopupMenu;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    procedure acAccRefObjExecute(Sender: TObject);
    procedure acAyuCalcExecute(Sender: TObject);
    procedure acCabExplorArcExecute(Sender: TObject);
    procedure acFacGraBolExecute(Sender: TObject);
    procedure acAccEnvMjeTitExecute(Sender: TObject);
    procedure acAccVerPanExecute(Sender: TObject);
    procedure acFacVerBolExecute(Sender: TObject);
    procedure acHerCamNomProExecute(Sender: TObject);
    procedure acHerSincronizarExecute(Sender: TObject);
    procedure acSisIngStockExecute(Sender: TObject);
    procedure acSisValStockExecute(Sender: TObject);
    procedure acSisAdmInsumExecute(Sender: TObject);
    procedure acSisAdmProdExecute(Sender: TObject);
    procedure acSisAdmProveExecute(Sender: TObject);
    procedure acHerExpServExecute(Sender: TObject);
    procedure acHerRegConexExecute(Sender: TObject);
    procedure acVerCarpApliExecute(Sender: TObject);
    procedure acVerIngComprasExecute(Sender: TObject);
    procedure acVerRepEveExecute(Sender: TObject);
    procedure acVerRepIngExecute(Sender: TObject);
    procedure acVerRepProExecute(Sender: TObject);
    procedure fraVisCPlex1ClickDer(Shift: TShiftState; xp, yp: integer);
    procedure MenuItem19Click(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure procesoTramaLista(NomPC: string; tram: TCPTrama);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ServCab : TCibServidorPC;  //Hilo que hace la conexión
    trama   : TCPTrama;        //Referencia a la trama recibida.
    tabPro  : TCibTabProduc;     //Tabla de productos
    tabPrv  : TCibTabProvee;
    tabIns  : TCibTabInsumo;
    tic     : integer;
    fraSincBD: TfraSincroBD;
    procedure EnviaPantalla;
    procedure frmAdminInsumGrabado;
    procedure frmAdminProduc_Grabar;
    procedure frmAdminProvee_Grabar;
    procedure frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
    procedure frmIngStock_Grabar(Manual: boolean);
    procedure PedirEstadoPCs;
    procedure PedirPantalla;
    procedure Plog(s: string);
    procedure ServCab_CambEstadoCnx(nuevoEstado: TCibEstadoConex);
    procedure ServCab_RegMensajeCnx(NomPC: string; msj: string);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Visor_SolicEjecCom(comando: TCPTipCom; ParamX,
      ParamY: word; cad: string);
    procedure Visor_ClickDer(Shift: TShiftState; x, y: integer);
    function CadMon(valor: double): string;
  public
    Visor: TfraVisCPlex;
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
{ TForm1 }
//Comandos comunes
procedure TForm1.Plog(s: string);
//Escribe un mensaje de texto en la ventana de sesión
var
  tmp: string;
begin
  DateTimeToString(tmp,'hh:mm:ss:zzz', now);
  frmLog.Memo1.Lines.Add(tmp + ' ' + s);
end;
procedure TForm1.ServCab_CambEstadoCnx(nuevoEstado: TCibEstadoConex);
begin
  StatusBar1.Panels[0].Text := ServCab.EstadoConexStr;
end;
procedure TForm1.ServCab_RegMensajeCnx(NomPC: string; msj: string);
//Se ha geenrado un mensaje de conexión.
begin
  frmSincronBD.RegMensaje(msj);
  Plog(msj);
end;
procedure TForm1.Visor_SolicEjecCom(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
begin
  //Envía el comando al servidor
  ServCab.PonerComando(comando, ParamX, ParamY, cad);
end;
procedure TForm1.Visor_ClickDer(Shift: TShiftState; x, y: integer);
var
  ogFac: TogFac;
  Nombre, nomFac: String;
  mn: TMenuItem;
  GFac: TCibGFac;
  fac: TCibFac;
begin
  if Visor.Seleccionado = nil then exit;
  //hay objeto seleccionado
  if Visor.Seleccionado is TogFac then begin
    //Se ha seleccionado un facturable
    ogFac := TogFac(Visor.Seleccionado);
    Nombre := ogFac.Fac.Nombre;
    nomFac := ogFac.Fac.Grupo.Nombre;
    //Ubica GFac en nuestro visor
    GFac := Visor.grupos.ItemPorNombre(nomFac);
    if GFac=nil then exit;
    //Deja que el facturable configure el menú contextual, con sus acciones
    PopupFac.Items.Clear;
    fac := Gfac.ItemPorNombre(Nombre);
    if fac=nil then exit;
    fac.MenuAccionesVista(PopupFac, -1);
    //Agrega los ítems del menú que son comunes a todos los facturables
    mn :=  TMenuItem.Create(nil);
    mn.Caption:='-';
    PopupFac.Items.Add(mn);

    mn :=  TMenuItem.Create(nil);
    mn.Action := acFacVerBol;
    PopupFac.Items.Add(mn);
{
    mn :=  TMenuItem.Create(nil);
    mn.Action := acFacAgrVen;
    PopupFac.Items.Add(mn);
}
    mn :=  TMenuItem.Create(nil);
    mn.Action := acFacGraBol;
    PopupFac.Items.Add(mn);

    PopupFac.PopUp;  //muestra
  end;

end;
function TForm1.CadMon(valor: double): string;
begin
  Result := 'S/' + ' ' + FloatToStrF(valor, ffNumber, 6, 2);
end;
procedure TForm1.EnviaPantalla;
//Captura el contenido de la pantalla, y lo envía como respuesta.
var
  bmp: TBitmap;
  ScreenDC: HDC;
  jpg: TJPEGImage;
  arch: String;
begin
  arch := ExtractFilePath(Application.ExeName) + '~00.tmp';
  bmp := TBitmap.Create;
  jpg := TJpegImage.Create;   //para manejar archivo de JPG
  ScreenDC := GetDC(0);
  bmp.LoadFromDevice(ScreenDC);
  jpg.Assign(bmp);
  jpg.SaveToFile(arch);
//  bmp.SaveToFile('d:\abc.bmp');
  ReleaseDC(0,ScreenDC);
  jpg.Free;
  bmp.Free;
  //envía archivo
  ServCab.EnviaArchivo(M_PAN_COMP, arch);
end;
procedure TForm1.frmAdminProduc_Grabar;
var
  tipModif: Integer;
begin
  //Graba localmente
  tabPro.ActualizarTabNoStock(frmAdminProduc.fraGri.GetString);
  //Graba en servidor
  if not ServCab.Conectado then exit;
  if MsgYesNo('¿Grabar en Servidor?') <> 1 then exit;
  frmAdminProduc.Habilitar(false);
  //Se debe grabar en el servidor
  tipModif := MODTAB_NOSTCK;   //tipo de modificación
  ServCab.PonerComando(CVIS_ACTPROD, 0, tipModif, StringFromFile(arcProduc));
end;
procedure TForm1.frmIngStock_Grabar(Manual: boolean);
var
  GetIngSTock, str, filName, getIngSTockInv: String;
  tipModif: Integer;
begin
  //Graba localmente
  GetIngSTock := frmIngStock.GetIngSTock;
  getIngSTockInv := frmIngStock.GetIngStock(True);
  tabPro.ActualizarTabIngStock(GetIngSTock);
  if tabPro.msjError <> '' then begin
    //Esto no debería pasar si se maneja bien la tabla
    MsgErr('Error actualizando tabla de productos.');
    MsgErr(tabPro.msjError);
  end;
  //Graba en el servidor
  if ServCab.Conectado then begin
    if MsgYesNo('¿Grabar en Servidor?') <> 1 then exit;
    frmIngStock.Habilitar(false);
    tipModif := MODTAB_INGSTCK;   //tipo de modificación
    ServCab.PonerComando(CVIS_ACTPROD, 0, tipModif, GetIngSTock);
  end else begin
    if MsgYesNo('¿Generar archivo de tarnsferencia?') <> 1 then exit;
    DateTimeToString(str, 'yyyy-mm-dd', now);
    SaveDialog1.FileName := 'productos.' + Config.Local + '.' + str + '.ing';
    if not SaveDialog1.Execute then exit;
    filName := SaveDialog1.FileName;
    if FileExists(filName) then begin
      if MsgYesNo('Archivo existe. ¿Sobreescribir?') <> 1 then exit;
    end;
    StringToFile(getIngSTockInv, filName);
  end;
end;
procedure TForm1.frmAdminProvee_Grabar;
var
  tipModif: Integer;
begin
  //Graba localmente
  tabPrv.UpdateAll(frmAdminProvee.fraGri.GetString);
  frmAdminProvee.Modificado := false;
  //Graba en servidor
  if not ServCab.Conectado then exit;
  if MsgYesNo('¿Grabar en Servidor?') <> 1 then exit;
  frmAdminProvee.Habilitar(false);
  //Se debe grabar en el servidor
  tipModif := MODTAB_TOTAL;   //tipo de modificación
  ServCab.PonerComando(CVIS_ACTPROV, 0, tipModif, StringFromFile(arcProvee));
end;
procedure TForm1.frmAdminInsumGrabado;
var
  tipModif: Integer;
begin
  //Graba localmente
  tabIns.UpdateAll(frmAdminInsum.fraGri.GetString);
  frmAdminInsum.Modificado := false;
  //Graba en servidor
  if not ServCab.Conectado then exit;
  if MsgYesNo('¿Grabar en Servidor?') <> 1 then exit;
  frmAdminInsum.Habilitar(false);
  //Se debe grabar en el servidor
  tipModif := MODTAB_TOTAL;   //tipo de modificación
  ServCab.PonerComando(CVIS_ACTINSU, 0, tipModif, StringFromFile(arcInsumo));
end;
procedure TForm1.frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
begin
  if MsgYesNo('Grabar Boleta de: ' + CibFac.Nombre + '?')<>1 then exit;
  ServCab.PonerComando(CVIS_ACBOLET, ACCBOL_GRA, 0, CibFac.IdFac);
end;
procedure TForm1.PedirPantalla;
//Pide el archivo de configuración del servidor
begin
  ServCab.PonerComando(CVIS_CAPPANT, 0, 0);
end;
procedure TForm1.PedirEstadoPCs ;
begin
  ServCab.PonerComando(CVIS_SOLESTA, 0, 0);
end;
procedure TForm1.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if panel.Index = 0 then begin
    if ServCab.Estado = cecConectando then begin
      if tic mod 2 = 0 then begin
//        StatusBar.Canvas.Font.Bold := true;
        StatusBar.Canvas.Font.Color:=clGreen;
        StatusBar.Canvas.Pen.Color := clWhite;
        StatusBar.Canvas.Brush.Color := clWhite;
        StatusBar.Canvas.Rectangle(Rect);
        StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, dic('Conectando...'));
      end else begin
//        StatusBar.Canvas.Font.Bold := true;
        StatusBar.Canvas.Font.Color:=clWhite;
        StatusBar.Canvas.Pen.Color := clGreen;
        StatusBar.Canvas.Brush.Color := clGreen;
        StatusBar.Canvas.Rectangle(Rect);
        StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, dic('Conectando...'));
      end;
    end else if ServCab.Estado = cecConectado then begin
      StatusBar.Canvas.Font.Color:=clWhite;
      StatusBar.Canvas.Pen.Color := clGreen;
      StatusBar.Canvas.Brush.Color := clGreen;
      StatusBar.Canvas.Rectangle(Rect);
      StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, dic('Conectado'));
    end else begin
      StatusBar.Canvas.Font.Color:=clBlack;
//      StatusBar.Canvas.Font.Bold := true;
      StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, StatusBar1.Panels[0].Text);
    end;
  end;
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  Visor:= TfraVisCPlex.Create(self);
  Visor.Parent := self;
  Visor.Align:=alClient;
  Visor.motEdi.OnMouseUpRight:=@fraVisCPlex1ClickDer;
  Visor.Left:=300;
  Visor.Top:=0;
  Visor.Width:=400;
  Visor.Height:=300;
  Visor.Visible:=true;
  Visor.motEdi.OnMouseUpRight:=@Visor_ClickDer;
  ServCab := TCibServidorPC.create;
  //evento de llegada de trama
  ServCab.OnTramaLista:=@procesoTramaLista;
  ServCab.OnRegMensaje:=@ServCab_RegMensajeCnx;
  ServCab.OnCambiaEstado:=@ServCab_CambEstadoCnx;
  tabPro := TCibTabProduc.Create;
  tabPrv := TCibTabProvee.Create;
  tabIns := TCibTabInsumo.Create;
  tabPro.SetTable(arcProduc);
  //Configura barra de estado
  StatusBar1.OnDrawPanel:=@StatusBar1DrawPanel;
  StatusBar1.Panels[0].Style := psOwnerDraw;
  //Configrua frame de sincronízación de BD
  fraSincBD := TfraSincroBD.Create(self);
  fraSincBD.Parent := self;
  fraSincBD.Align := alLeft;
  Splitter1.Align:= alLeft;
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  tabIns.Destroy;
  tabPrv.Destroy;
  tabPro.Destroy;
  ServCab.Free;
  Visor.Destroy;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
//  frmLog.show;
//  frmLog.SetFocus;
  frmPant.OnRefrescar := @PedirPantalla;

//  acAccRefObjExecute(self);   //Pide propiedades
//  PedirEstadoPCs;         //Pide estado
  Visor.grupos.OnSolicEjecCom:=@Visor_SolicEjecCom;
  frmBoleta.OnGrabarBoleta:=@frmBoleta_GrabarBoleta;
  //  frmBoleta.OnReqCadMoneda := @Config.CadMon;
  frmBoleta.OnReqCadMoneda := @CadMon;  { TODO : Esto es solo temporal }
//  if frmSincronBD.Exec(ServCab, @arcCfgServ) <> mrOK then begin
//    close;  //Se canceló la sincronización
//    exit;
//  end;
//  //Se logró sincronizar config.xml, con el servidor;
//  //Ahora usamos FormConfig como contenedor, para cargar los parámetros de la aplicación
//  Config.Iniciar(arcCfgServ);
  //Ahora que tenemos los datos de usuarios cargados, podemos iniciar sesión.
//  frmInicio.ShowModal;
//  if frmInicio.cancelo then begin
//    Close;
//  end;
  Config.Local:='CANADA';
  fraSincBD.Ini(ServCab, Config.Local);
  //Para permitir grabar remotamente
  frmAdminProduc.OnGrabado:=@frmAdminProduc_Grabar;
  frmAdminProvee.OnGrabado:=@frmAdminProvee_Grabar;
  frmAdminInsum.OnGrabado:=@frmAdminInsumGrabado;
  frmIngStock.OnGrabado := @frmIngStock_Grabar;
  Caption := NOM_PROG + ' ' + VER_PROG + ' Local: ' + Config.Local;
end;
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  tic := tic + 1;  //incrementa contador
  if ServCab.Estado = cecConectando then
    StatusBar1.InvalidatePanel(0,[ppText]);
  //Aprovecha para refrescar la ventana de boleta
  if (frmBoleta<>nil) and frmBoleta.Visible then
    frmBoleta.ActualizarDatos;

end;
procedure TForm1.fraVisCPlex1ClickDer(Shift: TShiftState; xp, yp: integer);   //Evento Click Derecho
var
  og: TObjGraf;
begin
  og := Visor.Seleccionado;
  if og = nil then exit;
  //hay objeto seleccionado
  PopupMenu1.PopUp;
end;
procedure TForm1.MenuItem19Click(Sender: TObject);
//Ver Pantalla del servidor.
begin
  frmPant.Show;
end;
procedure TForm1.procesoTramaLista(NomPC: string; tram: TCPTrama);
begin
  frmSincronBD.TramaLista(tram);
  fraSincBD.TramaLista(tram);
  //podemos procesar la trama
  trama := tram; //actualiza referencia
  Plog('>>Recibido: ' + trama.TipTraNom + ' - ' + IntToSTr(trama.tamDat) + ' bytes.');
  case trama.tipTra of
  C_MOS_TPO: begin  //pide mostrar tiempo
      if not ServCab.HayComando then
        PedirEstadoPCs;  //Solo pide si no hay otro comando en cola
    end;
  C_BLOQ_PC, C_DESB_PC: begin
      if not ServCab.HayComando then
        PedirEstadoPCs;  //Solo pide si no hay otro comando en cola
  end;
  C_MENS_PC: begin
    msgexc(trama.traDat);
    frmAdminProduc.Habilitar(true);  //Por si estaba deshabilitado
    frmAdminProvee.Habilitar(true);  //Por si estaba deshabilitado
    frmAdminInsum.Habilitar(true);   //Por si estaba deshabilitado
    frmIngStock.Habilitar(true);     //Por si estaba deshabilitado
  end;
  C_PAN_COMPL: begin   //se pide una pantalla completa
    EnviaPantalla;
//    ServCab.PonerComando(C_SOL_T_PCS);
    Plog('  enviado: ' + IntToStr(length(trama.traDat)) );
//    StringToFile(traDat, 'd:\aaa.jpg');
  end;
  RVIS_CAPPANT: begin  //se recibe la imagen de pantalla del servidor
    StringToFile(trama.traDat, 'd:\aaa.jpg');
    if frmPant.Visible then begin
      frmPant.Image1.Picture.LoadFromFile('d:\aaa.jpg');
    end;
  end;
  M_ARC_SOLIC: begin   //se recibe un archivo solictado
    //LeeEstado(trama.traDat)
  end;
  M_SOL_RUT_A: begin   //se recibe la ruta actual

  end;
  else  //Pasa el comando al Visor
    if tram.tipTra = RVIS_SOLESTA then begin
//      memo2.Lines.Text:=trama.traDat;   //para mostrar en pantalla
    end;
    Visor.EjecRespuesta(tram.tipTra, tram.posX, tram.posY, tram.traDat);
  end;
  if frmExplorServ.Visible then
    frmExplorServ.EjecRespuesta(tram.tipTra, tram.posX, tram.posY, tram.traDat);
end;
//Eventos de PaintBox1
procedure TForm1.PaintBox1Click(Sender: TObject);
begin
//  Application.MessageBox('Click en PaintBox','Caption',0);
end;
//////////////////// Acciones ///////////////////
procedure TForm1.acAccVerPanExecute(Sender: TObject);
begin
   frmPant.show;
   PedirPantalla;
end;
//Ver
procedure TForm1.acHerExpServExecute(Sender: TObject);  //Ver explorador del Servidor
begin
  frmExplorServ.Exec(ServCab);
end;
procedure TForm1.acHerRegConexExecute(Sender: TObject);
begin
  frmLog.Show;
end;
//Aciones VER
procedure TForm1.acVerCarpApliExecute(Sender: TObject);
begin
  Exec('explorer', rutApp);
end;
procedure TForm1.acVerIngComprasExecute(Sender: TObject);
begin
  tabPro.UpdateFromDisk;
  if tabPro.msjError<>'' then begin
    //Esto no debería pasar si se maneja bien la tabla
    MsgErr('Error cargando tabla de productos.');
    MsgErr(tabPro.msjError);
  end;
  frmIngCompras.Exec(tabPro);
end;
procedure TForm1.acVerRepIngExecute(Sender: TObject);
begin
  frmRepIngresos.Exec('CANADA');
end;
procedure TForm1.acVerRepProExecute(Sender: TObject);
begin
  tabPro.UpdateFromDisk;
  if tabPro.msjError<>'' then begin
    //Esto no debería pasar si se maneja bien la tabla
    MsgErr('Error cargando tabla de productos.');
    MsgErr(tabPro.msjError);
  end;
  frmRepProducto.Exec('CANADA', tabPro);
end;
procedure TForm1.acVerRepEveExecute(Sender: TObject);
begin
  frmRepEventos.Exec('CANADA');
end;
procedure TForm1.acAccEnvMjeTitExecute(Sender: TObject);
var
  msje: String;
begin
  msje := InputBox('','Ingrese mensaje:','');
  if msje = '' then exit;
  ServCab.PonerComando(C_MEN_TIT, 0, 0, msje);
end;
procedure TForm1.acAccRefObjExecute(Sender: TObject);
begin
  ServCab.PonerComando(CVIS_SOLPROP, 0, 0);
end;

procedure TForm1.acCabExplorArcExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  //Solo maneja una instancia
//  frmExplorCab.Exec(Visor, ogCab.Nombre);
end;
procedure TForm1.acFacGraBolExecute(Sender: TObject);  //Graba la boleta
var
  ogFac: TogFac;
begin
  ogFac := Visor.FacSeleccionado;
  if ogFac = nil then exit;
  frmBoleta_GrabarBoleta(ogFac.Fac,'');
end;
procedure TForm1.acFacVerBolExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  ogFac := Visor.FacSeleccionado;
  if ogFac = nil then exit;
  frmBoleta.Exec(ogFac.Fac);
end;
//Herramientas
procedure TForm1.acHerCamNomProExecute(Sender: TObject);
begin
  frmReempProd.Exec(Config.Local);
end;
procedure TForm1.acHerSincronizarExecute(Sender: TObject);
begin
  fraSincBD.btnSincronCfgClick(self);
end;
//Sistema
procedure TForm1.acSisAdmProdExecute(Sender: TObject);
begin
  tabPro.UpdateFromDisk;
  if tabPro.msjError<>'' then begin
    //Esto no debería pasar si se maneja bien la tabla
    MsgErr('Error cargando tabla de productos.');
    MsgErr(tabPro.msjError);
  end;
  frmAdminProduc.Exec(tabPro, '%.2f');
end;
procedure TForm1.acSisAdmProveExecute(Sender: TObject);
begin
  tabPrv.SetTable(arcProvee);
  tabPrv.UpdateFromDisk;
  if tabPrv.msjError<>'' then begin
    //Esto no debería pasar si se maneja bien la tabla
    MsgErr('Error cargando tabla de proveedores.');
    MsgErr(tabPrv.msjError);
  end;
  frmAdminProvee.Exec(tabPrv, '%.2f');
end;
procedure TForm1.acSisAdmInsumExecute(Sender: TObject);
begin
  tabIns.SetTable(arcInsumo);
  tabIns.UpdateFromDisk;
  if tabIns.msjError<>'' then begin
    //Esto no debería pasar si se maneja bien la tabla
    MsgErr('Error cargando tabla de insumos.');
    MsgErr(tabIns.msjError);
  end;
  frmAdminInsum.Exec(tabIns, '%.2f');
end;
procedure TForm1.acSisIngStockExecute(Sender: TObject);
begin
  tabPro.UpdateFromDisk(true);
  frmIngStock.Exec(tabPro, FormatMon);
end;
procedure TForm1.acSisValStockExecute(Sender: TObject);
begin
  tabPro.UpdateFromDisk(true);
  frmValStock.Exec(tabPro, FormatMon);
end;
//Ayuda
procedure TForm1.acAyuCalcExecute(Sender: TObject);
begin
  frmCalcul.Show;
end;

end.

