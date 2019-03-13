{Modelo de formulario de configuración que usa dos Frame de configuración}
unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Buttons, StdCtrls, ComCtrls, ExtCtrls,
  Spin, MiConfigBasic, MiConfigXML, frameCfgUsuarios, Globales, MisUtils,
  CibModelo;

type
  TStyleToolbar = (stb_SmallIcon, stb_BigIcon);

  { TConfig }
  TConfig = class(TForm)
  published
    BitAplicar: TBitBtn;
    BitCancel: TBitBtn;
    BitAceptar: TBitBtn;
    chkModDiseno: TCheckBox;
    chkPanBoletas: TCheckBox;
    chkPanLLamadas: TCheckBox;
    edUsuDefecto: TEdit;
    edGrupo: TEdit;
    edImpVen: TEdit;
    edInform: TEdit;
    edLocal: TEdit;
    edPVenDef: TEdit;
    edFactDefec: TEdit;
    edSimbMon: TEdit;
    FraUsuarios1: TFraUsuarios;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    PageControl1: TPageControl;
    RadioGroup1: TRadioGroup;
    spnNumDec: TSpinEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    procedure BitAceptarClick(Sender: TObject);
    procedure BitAplicarClick(Sender: TObject);
    procedure edSimbMonChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spnNumDecChange(Sender: TObject);
  private
    xmlFile: TMiConfigXML;
    version: String;
    procedure cfgFilePropertiesChanges;
  public
    msjError: string;    //para los mensajes de error
    arIni   : String;      //Archivo de configuración
    OnPropertiesChanges: procedure of object;
    ////// propiedades generales
    Local : string;   //Nombre del local
    Grupo : string;   //Nombre del grupo
    Inform: string;
    PVenDef: string;
    FactDef: string;
    UsuaDef: string;
    ////// Propiedades de Moneda
    SimbMon: string;   //Sïmbolo de moneda
    NumDec : integer;  //Número de decimales
    ImpVen : double;   //Impuesto a las ventas
    ////// propiedades vista
    verPanLlam: boolean;
    verPanBol: boolean;
    modDiseno: Boolean;
    StyleToolbar: TStyleToolbar;
    ////// propiedad de grupos
    ModeloStr: string;   //Cadena para guardar el modelo
    ////// propiedades usuarios
    listaUsu: TStringList;

    procedure escribirArchivoIni;
    procedure Iniciar(nombXML: string = '');
    procedure Mostrar;
  public //Funciones de moneda
    function ReqCadMon(valor: double): string;
    function LeeMon(txt: string): double;
  end;

var
  Config: TConfig;
  //Funciones de acceso rápido
  function CadMoneda(valor: double): string; inline;
  function LeeMoneda(txt: string): double;
  function FormatMon: string;   //formato de moneda

implementation
{$R *.lfm}
{ TConfig }
function CadMoneda(valor: double): string; inline;
begin
  Result := Config.ReqCadMon(valor);
end;
function LeeMoneda(txt: string): double;
begin
  Result := Config.LeeMon(txt);
end;
function FormatMon: string;
{Devuelve el formato que se debe aplicar a un valor para mostrarlo como moneda usando
la función Format().}
begin
  Result := Config.SimbMon + ' %.' + IntToStr(Config.NumDec) + 'f';
end;
procedure TConfig.FormCreate(Sender: TObject);
begin
  listaUsu:= TStringList.Create;
end;
procedure TConfig.FormDestroy(Sender: TObject);
begin
  FreeAndNil(xmlFile);
  listaUsu.Destroy;
end;
procedure TConfig.BitAceptarClick(Sender: TObject);
begin
  bitAplicarClick(Self);
  if xmlFile.MsjErr<>'' then exit;  //hubo error
  self.Close;  //sale si no hay error
end;
procedure TConfig.BitAplicarClick(Sender: TObject);
begin
  xmlFile.WindowToProperties;
  if xmlFile.MsjErr<>'' then begin
    MsgErr(xmlFile.MsjErr);
    exit;
  end;
  escribirArchivoIni;   //guarda propiedades en disco
end;
procedure TConfig.spnNumDecChange(Sender: TObject);
begin
  //Refresca muestra
  Label9.Caption := edSimbMon.Text + ' ' + FloatToStrF(0, ffNumber, 6, spnNumDec.Value);
end;
procedure TConfig.edSimbMonChange(Sender: TObject);
begin
  spnNumDecChange(self);     //Refresca muestra
end;
procedure TConfig.Iniciar(nombXML: string = '');
{Inicia el formulario de configuración. Debe llamarse antes de usar el formulario y
después de haber cargado todos los frames.}
var
  asocGF: TParElem;
  asocUs: TParElem;
  nom: string;
begin
  //Define nombre de XML
  if nombXML='' then
    nom := ChangeFileExt(Application.ExeName,'.xml')
  else
    nom := nombXML;
  xmlFile := TMiConfigXML.Create(nom);  //Crea archivo de configuración
  xmlFile.VerifyFile;
  xmlFile.OnPropertiesChanges:=@cfgFilePropertiesChanges;
  /////////////////////////////////
  version := NOM_PROG;
  xmlFile.Asoc_Str('version', @version, version);  //
  //Propiedades generales
  xmlFile.Asoc_Str('local',  @Local,  edLocal, 'LOCAL1');
  xmlFile.Asoc_Str('grupo',  @Grupo,  edGrupo, 'GRUPO1');
  xmlFile.Asoc_Str('inform', @Inform, edInform,'');
  xmlFile.Asoc_Str('PVenDef',@PVenDef,edPVenDef,'COUNTER');
  xmlFile.Asoc_Str('FactDef', @FactDef, edFactDefec, '');
  xmlFile.Asoc_Str('UsuaDef', @UsuaDef, edUsuDefecto, '');
  //Propiedades de Moneda
  xmlFile.Asoc_Str('SimbMon',@SimbMon,edSimbMon,'S/.');
  xmlFile.Asoc_Int('NumDec', @NumDec, spnNumDec, 2);
  xmlFile.Asoc_Dbl('ImpVen', @ImpVen, edImpVen, 18, 0, 50);
  //propiedades de vista
  xmlFile.Asoc_Bol('PanLlamadas', @verPanLlam, chkPanLLamadas, true);
  xmlFile.Asoc_Bol('PanBoletas' , @verPanBol,  chkPanBoletas, true);
  xmlFile.Asoc_Bol('ModDiseno'  , @modDiseno,  chkModDiseno, false);
  xmlFile.Asoc_Enum('StateStatusbar', @StyleToolbar, SizeOf(TStyleToolbar),
                    RadioGroup1, 1);
  //propiedades de grupos
  asocGF := xmlFile.Asoc_Str('GrpsFact', @ModeloStr, '');  //crea asociación sin variable
  //propiedades de usuario
  asocUs := xmlFile.Asoc_StrList('usuarios', @FraUsuarios1.listaUsu);
  asocUs.OnFileToProperty := @FraUsuarios1.FiletoProperty;
  asocUs.OnPropertyToFile := @FraUsuarios1.PropertyToFile;
  asocUs.OnWindowToProperty := @FraUsuarios1.WindowToProp;
  asocUs.OnPropertyToWindow := @FraUsuarios1.PropToWindow;

  if not xmlFile.FileToProperties then begin
    MsgErr(xmlFile.MsjErr);
  end;
end;
procedure TConfig.FormShow(Sender: TObject);
begin
  if not xmlFile.PropertiesToWindow then begin
    MsgErr(xmlFile.MsjErr);
  end;
end;
procedure TConfig.cfgFilePropertiesChanges;
begin
  if OnPropertiesChanges<>nil then OnPropertiesChanges;
end;

procedure TConfig.Mostrar;
//Muestra el formulario para configurarlo
begin
  PageControl1.PageIndex := 0;
  Showmodal;
end;
function TConfig.ReqCadMon(valor: double): string;
{Función que devuelve un valor, en el formato de moneda usado para toda la aplicación.
 Inicialmenet se trabajaba con "CurrencyString", pero eso limitaba la implementación del
 spnNumDecChange(), para simular cómo quedaría un cantidad en moneda.}
begin
  Result := SimbMon + ' ' + FloatToStrF(valor, ffNumber, 6, NumDec);
end;
function TConfig.LeeMon(txt: string): double;
{Lee una cadena que incluye el símbolo de moneda y la convierte a número.}
var
  tmp: String;
begin
  tmp := StringReplace(txt, SimbMon, '', []);
  Result := StrToFloat(tmp);
end;

procedure TConfig.escribirArchivoIni;
//Escribe el archivo de configuración
begin
  if not xmlFile.PropertiesToFile then begin
    MsgErr(xmlFile.MsjErr);
  end;
end;

end.

