unit FormNiloMProp;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Spin, ComCtrls, MisUtils, CibNiloMTarifRut;
type
  TEvCibNiloMEnviarCom = procedure(com: string) of object;   //
  { TfrmNiloMProp }
  TfrmNiloMProp = class(TForm)
    btnAplicar: TBitBtn;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    btnCfgConex: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    SpinEdit1: TSpinEdit;
    spnX: TFloatSpinEdit;
    spnY: TFloatSpinEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SynEdit1: TSynEdit;
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
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    HayError: boolean;
  public
    onEnviarCom: TEvCibNiloMEnviarCom;
    padre      : TObject;   //referecnia genérica a la clase TCibGFacNiloM
  end;


var
  frmNiloMProp: TfrmNiloMProp;

implementation
{$R *.lfm}
uses CibGFacNiloM, CibNiloMConex;

{ TfrmNiloMProp }
procedure TfrmNiloMProp.FormShow(Sender: TObject);
begin
  //Carga las propiedades
  txtNombre.Text    := TCibGFacNiloM(padre).Nombre;
  spnX.Value        := TCibGFacNiloM(padre).x;
  spnY.Value        := TCibGFacNiloM(padre).y;
  txtCategVenta.Text:= TCibGFacNiloM(padre).CategVenta;
  txtFacMon.Text    := FloatToStr(TCibGFacNiloM(padre).facCmoneda);
end;
procedure TfrmNiloMProp.btnAceptarClick(Sender: TObject);
begin
  btnAplicarClick(self);
  if HayError then exit;  //no cierra
  self.Hide;  //cierra diálogo
end;
procedure TfrmNiloMProp.btnAplicarClick(Sender: TObject);
var
  n: Longint;
  fc: Double;
begin
  HayError := true;
  //Valida factor de corrección de moneda
  if not TryStrToFloat(txtFacMon.Text, fc) then begin
    MsgErr('Error en factor de corrección de moneda');
    exit;
  end;
  ///////////////  Asigna  //////////////////////
  TCibGFacNiloM(padre).x := spnX.Value;
  TCibGFacNiloM(padre).y := spnY.Value;
  TCibGFacNiloM(padre).CategVenta := txtCategVenta.Text;
  TCibGFacNiloM(padre).facCmoneda:=fc;
  HayError := false;   //salió sin error;
end;
procedure TfrmNiloMProp.btnCancelarClick(Sender: TObject);
begin
  self.Hide;
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

end.

