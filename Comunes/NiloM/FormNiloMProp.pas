unit FormNiloMProp;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, SynEdit, SynEditHighlighter, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, Spin, ComCtrls, EditBtn,
  LCLType, MisUtils, CibNiloMTarifRut, CibFacturables, SynFacilUtils;
type
  TEvCibNiloMEnviarCom = procedure(com: string) of object;   //
  { TfrmNiloMProp }
  TfrmNiloMProp = class(TForm)
  published
    btnAplicar: TBitBtn;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    btnCfgConex: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    filTarif: TFileNameEdit;
    filRut: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    SpinEdit1: TSpinEdit;
    spnX: TFloatSpinEdit;
    spnY: TFloatSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    editTarif: TSynEdit;
    editRutas: TSynEdit;
    tabGenerales: TTabSheet;
    tabMoneda: TTabSheet;
    tabTarif: TTabSheet;
    tabRutas: TTabSheet;
    txtEstConex: TStaticText;
    Timer1: TTimer;
    txtNombre: TEdit;
    txtFacMon: TEdit;
    Label2: TLabel;
    Panel2: TPanel;
    txtCategVenta: TEdit;
    procedure btnAceptarClick(Sender: TObject);
    procedure btnAplicarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure txtFacMonChange(Sender: TObject);
  private
    HayError: boolean;
    edTarif: TSynFacilEditor;
    edRutas: TSynFacilEditor;
  public
    onEnviarCom: TEvCibNiloMEnviarCom;
    padre      : TObject;   //referencia genérica a la clase TCibGFacNiloM
    onCambiaProp: procedure of object;  //indica que se han cambiado propiedades
    procedure CargarArchivosConfig;
    function ValidarTarifario: boolean;
    function ValidarRutas: boolean;
  end;


var
  frmNiloMProp: TfrmNiloMProp;

implementation
{$R *.lfm}
uses CibGFacNiloM, CibNiloMConex;

{ TfrmNiloMProp }
procedure TfrmNiloMProp.CargarArchivosConfig;
{Carga en los editores, los archivos de configuración}
begin
  edTarif.LoadFile(TCibGFacNiloM(padre).ArcTarif);  //carga reconociendo la codificación
  edRutas.LoadFile(TCibGFacNiloM(padre).ArcRutas);  //carga reconociendo la codificación
end;
function TfrmNiloMProp.ValidarTarifario: boolean;
{Valida el contenido del tarifario, que debe estar cargado en el editor.
Si encuentra error -> Hace visible el formulario, activa la ventana del tarifario,
                      posiciona el cursor, en donde se detectó el error, muestra el
                      mensaje en pantalla, y devuelve FALSE.
Si no encuentra error -> devuelve TRUE y sale.
}
var
  GFacNiloM: TCibGFacNiloM;
begin
  GFacNiloM := TCibGFacNiloM(padre);
  GFacNiloM.tarif.msjError := '';
  GFacNiloM.tarif.CargarTarifas(editTarif.Lines, GFacNiloM.facCmoneda);
  if GFacNiloM.tarif.msjError<>'' then begin
    self.Show;   //muestra el formulario
    PageControl1.ActivePage := tabTarif;
    editTarif.CaretY := GFacNiloM.tarif.filError;  //marca línea con error
    editTarif.CaretX := GFacNiloM.tarif.colError;  //posiciona columna del error
    editTarif.CaretX := editTarif.LogicalToPhysicalPos(editTarif.CaretXY).x;  //corrige

    MsgErr('Error en tarifario: ' + GFacNiloM.tarif.msjError);  //muestra mensaje
    editTarif.SetFocus;
    exit(false);  //sale con error
  end;
  exit(true);  //Sale sin error
end;
function TfrmNiloMProp.ValidarRutas: boolean;
{Valida el contenido de la tabla de rutas, que debe estar cargado en el editor.
Si encuentra error -> Hace visible el formulario, activa la ventana del tarifario,
                      posiciona el cursor, en donde se detectó el error, muestra el
                      mensaje en pantalla, y devuelve FALSE.
Si no encuentra error -> devuelve TRUE y sale.
}
var
  GFacNiloM: TCibGFacNiloM;
begin
  GFacNiloM := TCibGFacNiloM(padre);
  GFacNiloM.rutas.msjError := '';
  GFacNiloM.rutas.CargarRutas(editRutas.Lines);
  if GFacNiloM.rutas.msjError<>'' then begin
    self.Show;   //muestra el formulario
    PageControl1.ActivePage := tabRutas;
    editRutas.CaretY := GFacNiloM.rutas.filError;  //marca línea con error
    editRutas.CaretX := GFacNiloM.rutas.colError;  //posiciona columna del error
    editRutas.CaretX := editRutas.LogicalToPhysicalPos(editRutas.CaretXY).x;  //corrige

    MsgErr('Error en tabla de rutas: ' + GFacNiloM.rutas.msjError);  //muestra mensaje
    editRutas.SetFocus;
    exit(false);  //sale con error
  end;
  exit(true);  //Sale sin error
end;
procedure TfrmNiloMProp.btnAceptarClick(Sender: TObject);
begin
  btnAplicarClick(self);
  if HayError then exit;  //no cierra
  if onCambiaProp<>nil then onCambiaProp;   //indica cambio de propiedades
  self.Hide;  //cierra diálogo
end;
procedure TfrmNiloMProp.btnAplicarClick(Sender: TObject);
var
  fc: Double;
  GFacNiloM: TCibGFacNiloM;
begin
  GFacNiloM := TCibGFacNiloM(padre);
  HayError := true;
  //Valida factor de corrección de moneda
  if not TryStrToFloat(txtFacMon.Text, fc) then begin
    MsgErr('Error en factor de corrección de moneda');
    exit;
  end;
  GFacNiloM.facCmoneda:=fc;   //asigna antes de validar el tarifario, porque influye en él
  if not ValidarTarifario then exit;
  if not ValidarRutas then exit;
  ///////////////  Asigna  //////////////////////
  GFacNiloM.x := spnX.Value;
  GFacNiloM.y := spnY.Value;
  GFacNiloM.CategVenta := txtCategVenta.Text;
  //Procesa los archivos de rutas y tarifario
  edTarif.SaveFile;
  if edTarif.Error<>'' then MsgErr(edTarif.Error);


  edRutas.SaveFile;
  if edRutas.Error<>'' then MsgErr(edRutas.Error);
  //sale sin error
  HayError := false;
end;
procedure TfrmNiloMProp.btnCancelarClick(Sender: TObject);
begin
  self.Hide;
end;
procedure TfrmNiloMProp.FormCreate(Sender: TObject);
var
  attPrepro: TSynHighlighterAttributes;
begin
  edTarif := TSynFacilEditor.Create(editTarif,'tarifario','txt');
  edRutas := TSynFacilEditor.Create(editRutas,'rutas','txt');
  editTarif.LineHighlightColor.Background:=Tcolor($FFE0E0);
  editRutas.LineHighlightColor.Background:=Tcolor($FFE0E0);
  //Configura la sintaxis del editor de tarifas y de rutas
  ConfigurarSintaxisTarif(edTarif.hl, attPrepro);
  ConfigurarSintaxisRutas(edRutas.hl, attPrepro);
end;
procedure TfrmNiloMProp.FormShow(Sender: TObject);
begin
  //Carga las propiedades
  txtNombre.Text    := TCibGFacNiloM(padre).Nombre;
  spnX.Value        := TCibGFacNiloM(padre).x;
  spnY.Value        := TCibGFacNiloM(padre).y;
  filTarif.Text     := TCibGFacNiloM(padre).ArcTarif;
  filRut.Text       := TCibGFacNiloM(padre).ArcRutas;

  txtCategVenta.Text:= TCibGFacNiloM(padre).CategVenta;
  txtFacMon.Text    := FloatToStr(TCibGFacNiloM(padre).facCmoneda);
  //Carga contenido de los archivos de configuración
  CargarArchivosConfig;
end;
procedure TfrmNiloMProp.FormDestroy(Sender: TObject);
begin
  edRutas.Destroy;
  edTarif.Destroy;
end;
procedure TfrmNiloMProp.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Shift = []) then begin
    if Key = VK_F2 then btnAplicarClick(self);
  end;
  if (Shift = [ssCtrl]) and (Key = VK_TAB) then begin
    PageControl1.SelectNextPage(true);
  end;
  if (Shift = [ssCtrl, ssShift]) and (Key = VK_TAB) then begin
    PageControl1.SelectNextPage(false);
  end;
end;
procedure TfrmNiloMProp.Timer1Timer(Sender: TObject);
begin
  if self.Visible then begin
    //Refresca estado de la conexión
    case TCibGFacNiloM(padre).estadoCnx of
    cecConectado: begin
      txtEstConex.Caption:='Conectado';
    end;
    cecConectando: begin
      txtEstConex.Caption:='Conectando...';
    end;
    cecDetenido, cecMuerto: begin
      txtEstConex.Caption:='Desconectado';
    end;
    end;
  end;
end;
procedure TfrmNiloMProp.txtFacMonChange(Sender: TObject);
{Cambia el factor de corrección de moneda}
var
  fc, IGV: Double;
  SimbMon: string;
  numDec: integer;
  OnReqCadMoneda: TevReqCadMoneda;
begin
  //Obtiene función para conversión de moneda
  OnReqCadMoneda := TCibGFacNiloM(padre).OnReqCadMoneda;
  //Actualiza información
  if OnReqCadMoneda=nil then begin
    //No se tiene acceso
    Memo1.Text:='ERROR accediendo a función de conversión de moneda.';
  end else if TryStrToFloat(txtFacMon.Text, fc) then begin
    //Conversión sin error
    Memo1.Text:='Costo de paso mínimo: ' + OnReqCadMoneda(0) + LineEnding +
                'Intervalo Mínimo: '     + OnReqCadMoneda(1 * fc)+ LineEnding +
                'Costo de paso máximo: ' + OnReqCadMoneda(255 * fc)+ LineEnding +
                '' + LineEnding +
                'TARIFARIO CONSISTENTE' + LineEnding +
                '=================' + LineEnding +
                'Mínimo costo =' + LineEnding +
                'Máximo Costo =' + LineEnding +
                '';
  end else begin
    //Hubo error en la conversión
    Memo1.Text:='ERROR en factor de conversión de moneda.';
  end;
end;

end.

