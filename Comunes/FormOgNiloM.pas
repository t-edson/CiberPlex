unit FormOgNiloM;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  ogMotGraf2D, MisUtils, CibFacturables, CibUtils, ObjGraficos, CibTramas,
  FormPropGFac, CibGFacNiloM, CibNiloMConex;
type

  { TogNiloM }
  {Objeto gráfico que representa a los elementos TCibFacLocutor}
  TogNiloM = class(TogFac)
  private
    procedure ProcDesac(estado0: Boolean);
  public
    procedure DibujarDatosLlam;
    procedure Draw; override;  //Dibuja el objeto gráfico
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
  { TogGNiloM }
  {Objeto gráfico que representa a los elementos TCibGFacNiloM}
  TogGNiloM = class(TogGFac)
  private
  public
    icoConec: TGraphic;    //NiloM conectado
    icoDesc : TGraphic;    //NiloM desconectado
    procedure Draw; override;  //Dibuja el objeto gráfico
  public  //Estados reflejo del GFAC al que representa
    estadoCnx: TNilEstadoConex;
    procedure SetCadEstado(txt: string); override;
  public  //Propiedades reflejo del GFAC al que representa
    PuertoN: string;
    facCmoneda: Double;
    IniLLamMan, IniLLamTemp: boolean;
    PerLLamTemp: integer;
    procedure SetCadPropied(lineas: TSTringList); override;
  protected
  public  //constructor y detsructor
    constructor Create(mGraf: TMotGraf); reintroduce;
  end;

  { TfrmOgNiloM }
  TfrmOgNiloM = class(TForm)
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image8: TImage;
    Image9: TImage;
    ImageList16: TImageList;
    ImageList32: TImageList;
  public
    OnSolicEjecCom : TEvSolicEjecCom;     //Cuando solicita ejecutar un comando
    OnCambiaPropied: procedure of object; //Cuando cambia alguna variable de propiedad
  public //Manejo de facturables
    ogFacNil: TogNiloM;
    procedure MenuAccionesFac(ogFacNil0: TogNiloM; modDiseno: boolean; MenuPopup: TPopupMenu;
      nShortCut: integer);
    procedure mnConectarClick(Sender: TObject);
    procedure mnDesconecClick(Sender: TObject);
  public //Manejo de Grupos
    ogGFacNil: TogGNiloM;
    procedure MenuAccionesGru(ogGFacNil0: TogGNiloM; modDiseno: boolean;
      MenuPopup: TPopupMenu);
    procedure mnBuscarTarif(Sender: TObject);
    procedure mnPropiedadesGFac(Sender: TObject);
    procedure mnVerConexiones(Sender: TObject);
  end;

var
  frmOgNiloM: TfrmOgNiloM;
var
  icoConexi: integer;   //índice de imagen
  icoBusTar: integer;   //índice de imagen
  icoPropie: integer;   //índice de imagen

procedure CargarIconos(imgList16, imgList32: TImageList);

implementation
{$R *.lfm}

procedure CargarIconos(imgList16, imgList32: TImageList);
{Carga los íconos que necesita esta unida }
begin
  icoConexi := CargaPNG(frmOgNiloM.ImageList16, frmOgNiloM.ImageList32, 1, imgList16, imgList32);
  icoBusTar := CargaPNG(frmOgNiloM.ImageList16, frmOgNiloM.ImageList32, 2, imgList16, imgList32);
  icoPropie := CargaPNG(frmOgNiloM.ImageList16, frmOgNiloM.ImageList32, 3, imgList16, imgList32);
end;
//Manejo de grupos
procedure TfrmOgNiloM.MenuAccionesGru(ogGFacNil0: TogGNiloM; modDiseno: boolean;
  MenuPopup: TPopupMenu);
var
  nShortCut: Integer;
begin
  ogGFacNil := ogGFacNil0;
  InicLlenadoAcciones(MenuPopup);
  nShortCut := -1;
  AgregarAccion(nShortCut, 'Cone&xiones' , @mnVerConexiones, icoConexi);
  AgregarAccion(nShortCut, 'B&uscar Tarifas', @mnBuscarTarif, icoBusTar);
  AgregarAccion(nShortCut, '&Propiedades' , @mnPropiedadesGFac, icoPropie);
end;
procedure TfrmOgNiloM.mnVerConexiones(Sender: TObject);
begin
  //frmNilomConex.Show;
  OnSolicEjecCom(CFAC_GNILOM, C_GNIL_CONEXI, 0, ogGFacNil.IdFac + #9);
end;
procedure TfrmOgNiloM.mnBuscarTarif(Sender: TObject);
begin
  //frmBusTar.Exec(self);
  OnSolicEjecCom(CFAC_GNILOM, C_GNIL_BUSTAR, 0, ogGFacNil.IdFac + #9);
end;
procedure TfrmOgNiloM.mnPropiedadesGFac(Sender: TObject);
begin
  frmPropGFac.Exec(ogGFacNil);
end;
//Manejo de facturables
procedure TfrmOgNiloM.MenuAccionesFac(ogFacNil0: TogNiloM; modDiseno: boolean;
  MenuPopup: TPopupMenu; nShortCut: integer);
begin
  ogFacNil := ogFacNil0;
  InicLlenadoAcciones(MenuPopup);
  AgregarAccion(nShortCut, '&Desconectar'   , @mnDesconecClick);
  AgregarAccion(nShortCut, '&Conectar'      , @mnConectarClick);
end;
procedure TfrmOgNiloM.mnConectarClick(Sender: TObject);
begin
  if OnSolicEjecCom<>nil then  //ejecuta evento
    OnSolicEjecCom(CFAC_NILOM, ACCLOC_CONEC, 0, ogFacNil.IdFac);
end;
procedure TfrmOgNiloM.mnDesconecClick(Sender: TObject);
begin
  if OnSolicEjecCom<>nil then  //ejecuta evento
    OnSolicEjecCom(CFAC_NILOM, ACCLOC_DESCO, 0, ogFacNil.IdFac);
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
  icoTelCol, icoTelDes, icoTelDes2: TGraphic;
begin
  icoTelCol := frmOgNiloM.Image9.Picture.Graphic;   //asigna imagen
  icoTelDes := frmOgNiloM.Image10.Picture.Graphic;
  icoTelDes2:= frmOgNiloM.Image11.Picture.Graphic;
  x2 := x + width;
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
  //muestra ogBoleta
  if Boleta.ItemCount>0 then ogBoleta.Dibujar;  //dibuja ogBoleta
  inherited;
end;
procedure TogNiloM.SetCadEstado(str: string);
var
  tmp, LlamActEstado, lin: string;
  lineas: TStringDynArray;
begin
  lineas := Explode(LineEnding, str);
  lin := lineas[0];  //primera línea´, debe haber al menos una
  TCibFacLocutor.DecodCadEstado(lin, tmp, descolg, descon, costo_tot, num_llam,
                                LlamActEstado);
  if LlamActEstado <> '' then begin
    HayllamAct := true;
    llamAct.CadEstado := LlamActEstado;
  end else begin
    HayllamAct := false;
  end;
  //Agrega información de boletas
  LeerEstadoBoleta(Boleta, lineas);
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

{ TogGNiloM }
procedure TogGNiloM.Draw;
begin
  icoConec := frmOgNiloM.Image8.Picture.Graphic;   //asigna imagen
  icoDesc  := frmOgNiloM.Image12.Picture.Graphic;
  //--------------Dibuja encabezado
  v2d.SetPen(psSolid, 1, COL_GRIS);
  //Dibuja íconos
  if estadoCnx = necConectado then begin  //**** Aún no se ve estados
    v2d.DrawImageN(icoConec, x, y-2);
  end else begin
    v2d.DrawImageN(icoDesc, x, y-2);
  end;
  //Muestra Nombre
  v2d.SetText(clBlack, 11,'', true);
  v2d.Texto(x + 33, y+3, Name);
  inherited Draw;
end;
procedure TogGNiloM.SetCadEstado(txt: string);
var _Nombre: string;
begin
  TCibGFacNiloM.DecodCadEstado(txt, _Nombre, estadoCnx);
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

end.

