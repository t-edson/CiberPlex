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
  Menus, lclProc, LCLType, LCLIntf, ExtCtrls, MisUtils, FormPant, FormPantCli,
  FormLog, frameVisCPlex, ogDefObjGraf, ObjGraficos, CibTramas, FormBoleta,
  CibFacturables, FormExplorCab, CPServidorCab, Globales;
type
  { TForm1 }
  TForm1 = class(TForm)
    acAccRefPan: TAction;
    acAccEnvCom: TAction;
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
    MenuItem61: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    PopupFac: TPopupMenu;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    procedure acAccRefObjExecute(Sender: TObject);
    procedure acCabExplorArcExecute(Sender: TObject);
    procedure acFacGraBolExecute(Sender: TObject);
    procedure acAccEnvComExecute(Sender: TObject);
    procedure acAccEnvMjeTitExecute(Sender: TObject);
    procedure acAccVerPanExecute(Sender: TObject);
    procedure acFacVerBolExecute(Sender: TObject);
    procedure fraVisCPlex1ClickDer(xp, yp: integer);
    procedure PaintBox1Click(Sender: TObject);
    procedure procesoTramaLista(tram: TCPTrama);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    ServCab: TCabServidor;
    trama   : TCPTrama;  //referencia a la trama recibida.
    procedure EnviaPantalla;
    procedure frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
    procedure PedirArchivoIni;
    procedure PedirEstadoPCs;
    procedure PedirPantalla;
    procedure PedirPantallaCli;
    procedure Plog(s: string);
    procedure ServCabRegMensaje(msj: string);
    procedure Visor_SolicEjecAcc(comando: TCPTipCom; ParamX,
      ParamY: word; cad: string);
    procedure Visor_ClickDer(x, y: integer);
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
begin
  frmLog.Memo1.Lines.Add(TimeToStr(now) + ' ' + s);
end;
procedure TForm1.ServCabRegMensaje(msj: string);
begin
  Plog(msj);
end;
procedure TForm1.Visor_SolicEjecAcc(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
begin
  //Envía el comando al servidor
  ServCab.PonerComando(comando, ParamX, ParamY, cad);
end;
procedure TForm1.Visor_ClickDer(x, y: integer);
var
  ogFac: TogFac;
  Nombre, nomFac: String;
  mn: TMenuItem;
  GFac: TCibGFac;
begin
  if Visor.Seleccionado = nil then exit;
  //hay objeto seleccionado
  if Visor.Seleccionado is TogFac then begin
    //Se ha seleccionado un facturable
    ogFac := TogFac(Visor.Seleccionado);
    Nombre := ogFac.Fac.Nombre;
    nomFac := ogFac.Fac.Grupo.Nombre;
    //Ubica GFac en el modelo original, no en la copia del visor
    GFac := Visor.grupos.BuscarPorNombre(nomFac);
    if GFac=nil then exit;
    //Deja que el facturable configure el menú contextual, con sus acciones
    PopupFac.Items.Clear;
    GFac.MenuAcciones(PopupFac, Nombre);
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
procedure TForm1.frmBoleta_GrabarBoleta(CibFac: TCibFac; coment: string);
begin
  if MsgYesNo('Grabar Boleta de: ' + CibFac.Nombre + '?')<>1 then exit;
  ServCab.PonerComando(C_ACC_BOLET, ACCBOL_GRA, 0, CibFac.IdFac);
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
  og := Visor.Seleccionado;
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
  ServCab.PonerComando(C_SOL_ESTAD, 0, 0);
end;
procedure TForm1.FormCreate(Sender: TObject);
begin
  Visor:= TfraVisCPlex.Create(self);
  Visor.Parent := self;
  Visor.Align:=alClient;
  Visor.motEdi.OnClickDer:=@fraVisCPlex1ClickDer;
  Visor.Left:=300;
  Visor.Top:=0;
  Visor.Width:=400;
  Visor.Height:=300;
  Visor.Visible:=true;
  Visor.motEdi.OnClickDer:=@Visor_ClickDer;

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
  Visor.Destroy;
end;
procedure TForm1.FormShow(Sender: TObject);
begin
  frmLog.show;
  frmLog.SetFocus;
  frmPant.OnRefrescar := @PedirPantalla;
  frmPantCli.OnRefrescar:=@PedirPantallaCli;
  acAccRefObjExecute(self);   //para refrescar los objetos
  PedirEstadoPCs;         //Para que se refresque el estado
  Visor.grupos.OnSolicEjecAcc:=@Visor_SolicEjecAcc;
  frmBoleta.OnGrabarBoleta:=@frmBoleta_GrabarBoleta;
  //  frmBoleta.OnReqCadMoneda := @Config.CadMon;
  frmBoleta.OnReqCadMoneda := @CadMon;  { TODO : Esto es solo temporal }
end;
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  //Aprovecha para refrescar la ventana de boleta
  if (frmBoleta<>nil) and frmBoleta.Visible then
    frmBoleta.ActualizarDatos;

end;
procedure TForm1.fraVisCPlex1ClickDer(xp,yp: integer);   //Evento Click Derecho
var
  og: TObjGraf;
begin
  og := Visor.Seleccionado;
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
  M_SOL_ESTAD: begin   //se recibe un archivo solictado
    memo2.Lines.Text:=trama.traDat;  //muestra el archivo
    Visor.ActualizarEstado(trama.traDat);
  end;
  M_SOL_ARINI: begin  //Se recibe archivo ini
    Visor.ActualizarPropiedades(trama.traDat);  //actualiza propeidades de objetos
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
procedure TForm1.acCabExplorArcExecute(Sender: TObject);
var
  ogCab: TogCabina;
begin
  ogCab := Visor.CabSeleccionada;
  if ogCab = nil then exit;
  //Solo maneja una instancia
  frmExplorCab.Exec(Visor, ogCab.Nombre);
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
end.

