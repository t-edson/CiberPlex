{Modelo de formulario de configuración que usa dos Frame de configuración}
unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Buttons, StdCtrls, ComCtrls, ExtCtrls,
  MiConfigBasic, MiConfigXML, frameCfgUsuarios,
  Globales, MisUtils, CPGrupFacturables;

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
    edGrupo: TEdit;
    edImpVen: TEdit;
    edInform: TEdit;
    edLocal: TEdit;
    edNumDec: TEdit;
    edPVenDef: TEdit;
    edSimbMon: TEdit;
    FraUsuarios1: TFraUsuarios;
    Label1: TLabel;
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
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    procedure BitAceptarClick(Sender: TObject);
    procedure BitAplicarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    version: String;
    procedure asocGFFileToProperty;
    procedure asocGFPropertyToFile;
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
    SimbMon: string;
    NumDec : integer;
    ImpVen : integer;
    ////// propiedades vista
    verPanLlam: boolean;
    verPanBol: boolean;
    modDiseno: Boolean;
    StyleToolbar: TStyleToolbar;
    ////// propiedad de grupos
    grupos: TCibGruposFacturables;  //objeto principal
    GrpsFact: string;   //cadena "espejo" para las propiedades
    ////// propiedades usuarios
    listaUsu: TStringList;

    procedure escribirArchivoIni;
    procedure Iniciar;
    procedure Mostrar;
  end;

var
  Config: TConfig;

  function CadMoneda(valor: double): string; inline;
  function LeeMoneda(txt: string): double;

implementation
{$R *.lfm}
{ TConfig }

function CadMoneda(valor: double): string; inline;
{Genera el formato de moneda usado para toda la aplicación.}
begin
  Result := FloatToStrF(valor, ffCurrency, 6, Config.NumDec);
end;
function LeeMoneda(txt: string): double;
{Lee una cadena que incluye el símbolo de moneda y la convierte a número.}
var
  tmp: String;
begin
  tmp := StringReplace(txt, DefaultFormatSettings.CurrencyString, '', []);
  Result := StrToFloat(tmp);
end;

procedure TConfig.FormCreate(Sender: TObject);
begin
  grupos := TCibGruposFacturables.Create('GrupServ');
  cfgFile.VerifyFile;
  cfgFile.OnPropertiesChanges:=@cfgFilePropertiesChanges;
end;
procedure TConfig.FormDestroy(Sender: TObject);
begin
  grupos.Destroy;
  listaUsu.Destroy;
end;

procedure TConfig.BitAceptarClick(Sender: TObject);
begin
  bitAplicarClick(Self);
  if cfgFile.MsjErr<>'' then exit;  //hubo error
  self.Close;  //sale si no hay error
end;

procedure TConfig.BitAplicarClick(Sender: TObject);
begin
  cfgFile.WindowToProperties;
  if cfgFile.MsjErr<>'' then begin
    MsgErr(cfgFile.MsjErr);
    exit;
  end;
  escribirArchivoIni;   //guarda propiedades en disco
end;

procedure TConfig.Iniciar;
//Inicia el formulario de configuración. Debe llamarse antes de usar el formulario y
//después de haber cargado todos los frames.
var
  asocGF: TParElem;
  asocUs: TParElem;
begin
  listaUsu:= TStringList.Create;
  /////////////////////////////////
  version := NOM_PROG;
  cfgFile.Asoc_Str('version', @version, version);  //
  //propiedades generales
  cfgFile.Asoc_Str('local',  @Local,  edLocal, 'LOCAL1');
  cfgFile.Asoc_Str('grupo',  @Grupo,  edGrupo, 'GRUPO1');
  cfgFile.Asoc_Str('inform', @Inform, edInform,'');
  cfgFile.Asoc_Str('PVenDef',@PVenDef,edPVenDef,'COUNTER');
  cfgFile.Asoc_Str('SimbMon',@SimbMon,edSimbMon,'S/.');
  cfgFile.Asoc_Int('NumDec', @NumDec, edNumDec, 2, 0, 4);
  cfgFile.Asoc_Int('ImpVen', @ImpVen, edImpVen, 18, 0, 50);
  //propiedades de vista
  cfgFile.Asoc_Bol('PanLlamadas', @verPanLlam, chkPanLLamadas, true);
  cfgFile.Asoc_Bol('PanBoletas' , @verPanBol,  chkPanBoletas, true);
  cfgFile.Asoc_Bol('ModDiseno'  , @modDiseno,  chkModDiseno, false);
  cfgFile.Asoc_Enum('StateStatusbar', @StyleToolbar, SizeOf(TStyleToolbar),
                    RadioGroup1, 1);
  //propiedades de grupos
  asocGF := cfgFile.Asoc_Str('GrpsFact', @GrpsFact, '');  //crea asociación sin variable
  asocGF.OnPropertyToFile:=@asocGFPropertyToFile;  //usamos sus eventos
  asocGF.OnFileToProperty:=@asocGFFileToProperty;
  //propiedades de usuario
  asocUs := cfgFile.Asoc_StrList('usuarios', @FraUsuarios1.listaUsu);
  asocUs.OnFileToProperty := @FraUsuarios1.FiletoProperty;
  asocUs.OnPropertyToFile := @FraUsuarios1.PropertyToFile;
  asocUs.OnWindowToProperty := @FraUsuarios1.WindowToProp;
  asocUs.OnPropertyToWindow := @FraUsuarios1.PropToWindow;

  if not cfgFile.FileToProperties then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;

procedure TConfig.FormShow(Sender: TObject);
begin
  if not cfgFile.PropertiesToWindow then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;
procedure TConfig.cfgFilePropertiesChanges;
begin
  if OnPropertiesChanges<>nil then OnPropertiesChanges;
end;
procedure TConfig.asocGFPropertyToFile;
begin
  GrpsFact := grupos.CadPropiedades;    //actualiza antes de guardar
end;
procedure TConfig.asocGFFileToProperty;
begin
  grupos.CadPropiedades := GrpsFact;   //actualiza después de leer
end;

procedure TConfig.Mostrar;
//Muestra el formulario para configurarlo
begin
  PageControl1.PageIndex := 0;
  Showmodal;
end;
procedure TConfig.escribirArchivoIni;
//Escribe el archivo de configuración
begin
  if not cfgFile.PropertiesToFile then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;

end.

