{                            CiberPlex Admin
Formulario principal de la aplicación.
El objeto principal de la palicación es "ServCab"
que representa a la conexión en modo servidor que se requiere para conectarse a
CIBERPLEX-Serv, como una cabina cliente.
                                                    Por tito Hinostroza  24/07/2014
}
unit FormPrincipal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ActnList,
  Menus, lclProc, LCLType, LCLIntf,
  MisUtils, FormPant, FormPantCli, FormLog, frameVisCPlex, ogDefObjGraf, ObjGraficos,
  FormFijTiempo, CibTramas, CibCabinaBase, FormExplorCab, CPServidorCab, Globales;
type
  { TForm1 }
  TForm1 = class(TForm)
    acAccRefPan: TAction;
    acAccEnvCom: TAction;
    acAccEnvMjeTit: TAction;
    acCabModTpo: TAction;
    acCabIniCta: TAction;
    acCabDetCta: TAction;
    acCabGraBol: TAction;
    acAccVerPan: TAction;
    acAccRefObj: TAction;
    acCabExplorArc: TAction;
    acCabPonMan: TAction;
    ActionList1: TActionList;
    MainMenu1: TMainMenu;
    Memo2: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PopupMenu1: TPopupMenu;
    procedure acAccRefObjExecute(Sender: TObject);
    procedure acCabDetCtaExecute(Sender: TObject);
    procedure acCabExplorArcExecute(Sender: TObject);
    procedure acCabGraBolExecute(Sender: TObject);
    procedure acCabIniCtaExecute(Sender: TObject);
    procedure acCabModTpoExecute(Sender: TObject);
    procedure acAccEnvComExecute(Sender: TObject);
    procedure acAccEnvMjeTitExecute(Sender: TObject);
    procedure acAccVerPanExecute(Sender: TObject);
    procedure acCabPonManExecute(Sender: TObject);
    procedure fraVisCPlex1ClickDer(xp, yp: integer);
    procedure PaintBox1Click(Sender: TObject);
    procedure procesoTramaLista(tram: TCPTrama);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    ServCab: TCabServidor;
    trama   : TCPTrama;  //referencia a la trama recibida.
    procedure EnviaPantalla;
    procedure PedirArchivoIni;
    procedure PedirEstadoPCs;
    procedure PedirPantalla;
    procedure PedirPantallaCli;
    procedure Plog(s: string);
    procedure ServCabRegMensaje(msj: string);

  public
    VisorCabinas: TfraVisCPlex;
  end;

var
  Form1: TForm1;

implementation
{$R *.lfm}
{ TForm1 }
//Comandos comunes
procedure TForm1.Plog(s: string);
//Escribe un mensaje de texto en la ventana de sesión
begin
  frmLog.Memo1.Lines.Add(TimeToStr(now) + ' ' + s);
end;
procedure TForm1.ServCabRegMensaje(msj: string);
begin
  Plog(msj);
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
procedure TForm1.PedirPantalla;
//Pide el archivo de configuración del servidor
begin
  ServCab.PonerComando(C_PAN_COMPL, 0, 0);
end;
procedure TForm1.PedirPantallaCli;
//Pide el archivo de configuración del servidor
var
  og: TObjGraf;
begin
  //solicita pantalla de una PC
  og := VisorCabinas.Seleccionado;
  if og = nil then begin
    MsgErr('Debe haber cabina seleccionada para este comando');
    exit;
  end;
  ServCab.PonerComando(C_SOL_PANPC, 0, 0, og.nombre);
end;
procedure TForm1.PedirArchivoIni;
//Pide el archivo de configuración del servidor
begin
  memo2.Clear;
  ServCab.PonerComando(C_ARC_SOLIC, 0, 0, 'niloter.ini');
end;
procedure TForm1.PedirEstadoPCs ;
begin
  memo2.Clear;
  ServCab.PonerComando(C_SOL_T_PCS, 0, 0);
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  VisorCabinas:= TfraVisCPlex.Create(self);
  VisorCabinas.Parent := self;
  VisorCabinas.Align:=alClient;
  VisorCabinas.motEdi.OnClickDer:=@fraVisCPlex1ClickDer;
  VisorCabinas.Left:=300;
  VisorCabinas.Top:=0;
  VisorCabinas.Width:=400;
  VisorCabinas.Height:=300;
  VisorCabinas.Visible:=true;

  ServCab := TCabServidor.create;
  //evento de llegada de trama
  ServCab.OnTramaLista:=@procesoTramaLista;
  ServCab.OnRegMensaje:=@ServCabRegMensaje;
end;
procedure TForm1.FormDestroy(Sender: TObject);
begin
  ServCab.OnTramaLista:=nil;  //para evitar eventos al morir
  ServCab.OnRegMensaje:=nil;  //para evitar eventos al morir
  ServCab.Terminate;
  ServCab.WaitFor;
  ServCab.Free;
  VisorCabinas.Destroy;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
  frmLog.show;
  frmLog.SetFocus;
  frmPant.OnRefrescar := @PedirPantalla;
  frmPantCli.OnRefrescar:=@PedirPantallaCli;
  acAccRefObjExecute(self);   //para refrescar los objetos
  PedirEstadoPCs;         //Para que se refresque el estado
end;
procedure TForm1.fraVisCPlex1ClickDer(xp,yp: integer);   //Evento Click Derecho
var
  og: TObjGraf;
begin
  og := VisorCabinas.Seleccionado;
  if og = nil then exit;
  //hay objeto seleccionado
  PopupMenu1.PopUp;
end;
procedure TForm1.procesoTramaLista(tram: TCPTrama);
begin
  //podemos procesar la trama
  trama := tram; //actualiza referencia
  Plog('>>Recibido: ' + trama.TipTraNom + ' - ' + IntToSTr(trama.tamDat) + ' bytes.');
  case trama.tipTra of
  C_MOS_TPO: begin  //pide mostrar tiempo
      if not ServCab.HayComando then
        PedirEstadoPCs;  //Solo pide si no hay otro comando en cola
    end;
  C_BLOQ_PC, C_DESB_PC: begin   //pide mostrar tiempo
      if not ServCab.HayComando then
        PedirEstadoPCs;  //Solo pide si no hay otro comando en cola
  end;
  C_PAN_COMPL: begin   //se pide una pantalla completa
    EnviaPantalla;
//    ServCab.PonerComando(C_SOL_T_PCS);
    Plog('  enviado: ' + IntToStr(length(trama.traDat)) );
//    StringToFile(traDat, 'd:\aaa.jpg');
  end;
  M_PAN_COMP: begin   //se recibe la imagen de pantalla completa
    StringToFile(trama.traDat, 'd:\aaa.jpg');
    if frmPant.Visible then begin
      frmPant.Image1.Picture.LoadFromFile('d:\aaa.jpg');
    end;
  end;
  M_SOL_PANPC: begin   //se recibe la imagen de pantalla de una PC cliente
    StringToFile(trama.traDat, 'd:\aaa.jpg');
    if frmPantCli.Visible then begin
      frmPantCli.Image1.Picture.LoadFromFile('d:\aaa.jpg');
    end;
  end;
  M_ARC_SOLIC: begin   //se recibe un archivo solictado
    memo2.Lines.Text:=trama.traDat;  //muestra el archivo
    //LeeEstado(trama.traDat)
  end;
  M_SOL_T_PCS: begin   //se recibe un archivo solictado
    memo2.Lines.Text:=trama.traDat;  //muestra el archivo
    VisorCabinas.ActualizarEstado(trama.traDat);
  end;
  M_SOL_ARINI: begin  //Se recibe archivo ini
    VisorCabinas.ActualizarPropiedades(trama.traDat);  //actualiza propeidades de objetos
    //StringToFile(trama.traDat, rutApp + '\CpxServer.ini');
  end;
  M_SOL_RUT_A: begin   //se recibe la ruta actual

  end;
  end;
end;
//Eventos de PaintBox1
procedure TForm1.PaintBox1Click(Sender: TObject);
begin
//  Application.MessageBox('Click en PaintBox','Caption',0);
end;
//Acciones
procedure TForm1.acAccVerPanExecute(Sender: TObject);
begin
   frmPant.show;
   PedirPantalla;
end;
procedure TForm1.acAccEnvComExecute(Sender: TObject);
var
  com : string;
  n: LongInt;
begin
  com := InputBox('','Ingrese comando','');
  if com = '' then exit;
  n := StrToInt(com);
  if TCPTipCom(n) = C_PAN_COMPL then begin
    frmPant.Show;
    PedirPantalla;
  end else if TCPTipCom(n) = C_SOL_PANPC then begin
    frmPantCli.Show;
    PedirPantallaCli;
  end else begin
    ServCab.PonerComando(TCPTipCom(n), 0, 0);
  end;

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
  ServCab.PonerComando(C_SOL_ARINI, 0, 0);
end;
procedure TForm1.acCabIniCtaExecute(Sender: TObject);
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
  //envía comando de inicio de cuenta
  ServCab.PonerComando(C_INI_CTAPC, 0, 0, frmFijTiempo.CadActivacion);
end;
procedure TForm1.acCabModTpoExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  frmFijTiempo.Mostrar(ogCab);
  if frmFijTiempo.cancelo then exit;  //canceló
  //envía comando de modificaicón de cuenta
  ServCab.PonerComando(C_MOD_CTAPC, 0, 0, frmFijTiempo.CadActivacion);
end;
procedure TForm1.acCabDetCtaExecute(Sender: TObject);  //Detener cuentea
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  if MsgYesNo('¿Desconectar Computadora: ' + ogCab.nombre + '?') <> 1 then exit;
  ServCab.PonerComando(C_DET_CTAPC, 0, 0, ogCab.nombre);
end;
procedure TForm1.acCabPonManExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  if not ogCab.Detenida then begin
    MsgExc('No se puede poner a mantenimiento una cabina con cuenta.');
    exit;
  end;
  ServCab.PonerComando(C_DET_CTAPC, 1, 0, ogCab.nombre); //El mismo comando, pone en mantenimiento
end;
procedure TForm1.acCabExplorArcExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  //Solo maneja una instancia
  frmExplorCab.Exec(VisorCabinas, ogCab.Nombre);
end;
procedure TForm1.acCabGraBolExecute(Sender: TObject);  //Graba la boleta
var
  ogCab: TogCabina;
begin
  ogCab := VisorCabinas.CabSeleccionada;
  if ogCab = nil then exit;
  if MsgYesNo('Grabar Boleta de: ' + ogCab.nombre + '?')<>1 then exit;
  ServCab.PonerComando(C_GRA_BOLPC, 0, 0, ogCab.nombre);
end;
end.

