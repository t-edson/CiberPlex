unit FormNiloMProp;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, SynEdit, SynEditHighlighter, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, Spin, ComCtrls, EditBtn,
  LCLType, ActnList, Menus, MisUtils, CibNiloMTarifRut, CibFacturables,
  SynFacilUtils;
type
  TEvCibNiloMEnviarCom = procedure(com: string) of object;   //
  { TfrmNiloMProp }
  TfrmNiloMProp = class(TForm)
  published
    acTarVerEstad: TAction;
    acRutTrans: TAction;
    acTarTrans: TAction;
    ActionList1: TActionList;
    btnAplicar: TBitBtn;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    btnCfgConex: TButton;
    btnTarTransf: TButton;
    btnActCI: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    cmbFacMon: TComboBox;
    Edit1: TEdit;
    filTarif: TFileNameEdit;
    filRut: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem4: TMenuItem;
    PageControl1: TPageControl;
    PopupTar: TPopupMenu;
    PopupRut: TPopupMenu;
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
    Label2: TLabel;
    Panel2: TPanel;
    txtCategVenta: TEdit;
    procedure acRutTransExecute(Sender: TObject);
    procedure acTarTransExecute(Sender: TObject);
    procedure acTarVerEstadExecute(Sender: TObject);
    procedure btnAceptarClick(Sender: TObject);
    procedure btnAplicarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnCfgConexClick(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure cmbFacMonChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
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
  if not TryStrToFloat(cmbFacMon.Text, fc) then begin
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
  GFacNiloM.IniLLamMan  := CheckBox2.Checked;
  GFacNiloM.IniLLamTemp := CheckBox3.Checked;
  GFacNiloM.PerLLamTemp := SpinEdit1.Value;

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
procedure TfrmNiloMProp.btnCfgConexClick(Sender: TObject);
begin
  TCibGFacNiloM(padre).frmNilomConex.Show;
end;
procedure TfrmNiloMProp.CheckBox3Change(Sender: TObject);
begin
  SpinEdit1.Enabled:=CheckBox3.Checked;
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
var
  GFacNiloM: TCibGFacNiloM;
begin
  GFacNiloM := TCibGFacNiloM(padre);
  //Carga las propiedades
  txtNombre.Text    := GFacNiloM.Nombre;
  spnX.Value        := GFacNiloM.x;
  spnY.Value        := GFacNiloM.y;
  filTarif.Text     := GFacNiloM.ArcTarif;
  filRut.Text       := GFacNiloM.ArcRutas;

  txtCategVenta.Text:= GFacNiloM.CategVenta;
  cmbFacMon.Text    := FloatToStr(GFacNiloM.facCmoneda);
  CheckBox2.Checked := GFacNiloM.IniLLamMan;
  CheckBox3.Checked := GFacNiloM.IniLLamTemp;
  SpinEdit1.Value   := GFacNiloM.PerLLamTemp;


  //Carga contenido de los archivos de configuración
  CargarArchivosConfig;
  cmbFacMonChange(self); //actualiza combo
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
    necConectado: begin
      txtEstConex.Caption:='Conectado';
    end;
    necConectando: begin
      txtEstConex.Caption:='Conectando...';
    end;
    necDetenido, necMuerto: begin
      txtEstConex.Caption:='Desconectado';
    end;
    end;
  end;
end;
procedure TfrmNiloMProp.cmbFacMonChange(Sender: TObject);
{Cambia el factor de corrección de moneda}
var
  fc: Double;
  OnReqCadMoneda: TevReqCadMoneda;
begin
  //Obtiene función para conversión de moneda
  OnReqCadMoneda := TCibGFacNiloM(padre).OnReqCadMoneda;
  //Actualiza información
  if OnReqCadMoneda=nil then begin
    //No se tiene acceso
    Memo1.Text:='ERROR accediendo a función de conversión de moneda.';
  end else if TryStrToFloat(cmbFacMon.Text, fc) then begin
    //Conversión sin error
    Memo1.Text:='Costo de paso mínimo: ' + OnReqCadMoneda(0) + LineEnding +
                'Intervalo Mínimo    : ' + OnReqCadMoneda(1 * fc)+ LineEnding +
                'Costo de paso máximo: ' + OnReqCadMoneda(255 * fc)+ LineEnding +
                '' + LineEnding;
  end else begin
    //Hubo error en la conversión
    Memo1.Text:='ERROR en factor de conversión de moneda.';
  end;
end;
///////////////////// Acciones ///////////////////////
procedure TfrmNiloMProp.acTarVerEstadExecute(Sender: TObject);
var
  tarif: TNiloMTabTar;
  OnReqCadMoneda: TevReqCadMoneda;
begin
  OnReqCadMoneda := TCibGFacNiloM(padre).OnReqCadMoneda;
  if OnReqCadMoneda=nil then exit;
  if ValidarTarifario then begin
    tarif := TCibGFacNiloM(padre).tarif;
    MsgBox('Número de tarifas =' + IntToStr(tarif.tarifas.Count) + LineEnding +
           'Mínimo costo =' + OnReqCadMoneda(tarif.minCostop) + LineEnding +
           'Máximo Costo =' + OnReqCadMoneda(tarif.maxCostop));
  end else begin  //si hay error
    MsgErr('Error en tarifario.');  //muestra y sale
  end;
end;
procedure TfrmNiloMProp.acTarTransExecute(Sender: TObject);  //Trasnfiere Tarifario
begin
  if MsgYesNo('¿Tranferir tarifario al enrutador?')<>1 then exit;

end;

procedure TfrmNiloMProp.acRutTransExecute(Sender: TObject);
begin
  if MsgYesNo('¿Tranferir tabla de rutas al enrutador?')<>1 then exit;

end;

end.

