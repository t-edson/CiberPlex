unit FormNiloMConex;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, strutils, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls,
  FormNiloMEnrutam, MisUtils;
type
  TEvCibNiloMEnviarCom = procedure(com: string) of object;   //
  { TfrmNiloMConex }
  TfrmNiloMConex = class(TForm)
  published
    btnAplicar: TBitBtn;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    btnEnviar: TButton;
    btnConect: TButton;
    btnDescon: TButton;
    btnLimpTerm: TButton;
    btnRefres: TButton;
    cmdD1: TButton;
    cmdD2: TButton;
    cmdD3: TButton;
    cmdD4: TButton;
    cmdD5: TButton;
    cmdD6: TButton;
    cmdD7: TButton;
    cmdD8: TButton;
    cmdD9: TButton;
    cmdDA: TButton;
    cmdD0: TButton;
    cmdDB: TButton;
    cmdMarcNum: TButton;
    enrut3: TButton;
    enrut2: TButton;
    enrut1: TButton;
    enrut0: TButton;
    cmbPuerto: TComboBox;
    E2L5: TStaticText;
    E2L4: TStaticText;
    E2L3: TStaticText;
    E2L2: TStaticText;
    E2L1: TStaticText;
    E2L0: TStaticText;
    E1L7: TStaticText;
    E1L6: TStaticText;
    E1L5: TStaticText;
    E1L4: TStaticText;
    E1L3: TStaticText;
    E1L2: TStaticText;
    E1L1: TStaticText;
    E1L0: TStaticText;
    E0L7: TStaticText;
    E0L6: TStaticText;
    E0L5: TStaticText;
    E0L4: TStaticText;
    E0L3: TStaticText;
    E0L2: TStaticText;
    E0L1: TStaticText;
    E0L0: TStaticText;
    E2L7: TStaticText;
    E2L6: TStaticText;
    txtDigitados: TEdit;
    lblE3: TEdit;
    lblE2: TEdit;
    lblE1: TEdit;
    lblE0: TEdit;
    E3L5: TStaticText;
    E3L4: TStaticText;
    E3L3: TStaticText;
    E3L2: TStaticText;
    E3L1: TStaticText;
    E3L0: TStaticText;
    ESL4: TStaticText;
    ESL3: TStaticText;
    ESL2: TStaticText;
    ESL1: TStaticText;
    ESL0: TStaticText;
    ESL7: TStaticText;
    ESL6: TStaticText;
    ESL5: TStaticText;
    E3L7: TStaticText;
    E3L6: TStaticText;
    cmdSEN: TStaticText;
    txtDig3: TEdit;
    txtDig2: TEdit;
    txtDig1: TEdit;
    txtDig0: TEdit;
    txtMarcNum: TEdit;
    lbl7: TEdit;
    lbl6: TEdit;
    lbl1: TEdit;
    lbl2: TEdit;
    lbl3: TEdit;
    lbl4: TEdit;
    lbl5: TEdit;
    lblSensor: TMemo;
    PageControl1: TPageControl;
    Shape1: TShape;
    cmdD5a: TShape;
    Shape11: TShape;
    Shape12: TShape;
    Shape13: TShape;
    Shape14: TShape;
    Shape15: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    cmdVerEstado: TSpeedButton;
    tabSerial: TTabSheet;
    tabConexiones: TTabSheet;
    Timer1: TTimer;
    Label1: TLabel;
    Panel2: TPanel;
    txtComando: TEdit;
    Memo1: TMemo;
    procedure btnAceptarClick(Sender: TObject);
    procedure btnAplicarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConectClick(Sender: TObject);
    procedure btnDesconClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure btnLimpTermClick(Sender: TObject);
    procedure btnRefresClick(Sender: TObject);
    procedure cmbPuertoChange(Sender: TObject);
    procedure cmdD0Click(Sender: TObject);
    procedure cmdD1Click(Sender: TObject);
    procedure cmdD2Click(Sender: TObject);
    procedure cmdD3Click(Sender: TObject);
    procedure cmdD4Click(Sender: TObject);
    procedure cmdD5Click(Sender: TObject);
    procedure cmdD6Click(Sender: TObject);
    procedure cmdD7Click(Sender: TObject);
    procedure cmdD8Click(Sender: TObject);
    procedure cmdD9Click(Sender: TObject);
    procedure cmdDAClick(Sender: TObject);
    procedure cmdDBClick(Sender: TObject);
    procedure cmdMarcNumClick(Sender: TObject);
    procedure cmdSENClick(Sender: TObject);
    procedure cmdVerEstadoClick(Sender: TObject);
    procedure E0L0Click(Sender: TObject);
    procedure E0L1Click(Sender: TObject);
    procedure E0L2Click(Sender: TObject);
    procedure E0L3Click(Sender: TObject);
    procedure E0L4Click(Sender: TObject);
    procedure E0L5Click(Sender: TObject);
    procedure E0L6Click(Sender: TObject);
    procedure E0L7Click(Sender: TObject);
    procedure E1L0Click(Sender: TObject);
    procedure E1L1Click(Sender: TObject);
    procedure E1L2Click(Sender: TObject);
    procedure E1L3Click(Sender: TObject);
    procedure E1L4Click(Sender: TObject);
    procedure E1L5Click(Sender: TObject);
    procedure E1L6Click(Sender: TObject);
    procedure E1L7Click(Sender: TObject);
    procedure E2L0Click(Sender: TObject);
    procedure E2L1Click(Sender: TObject);
    procedure E2L2Click(Sender: TObject);
    procedure E2L3Click(Sender: TObject);
    procedure E2L4Click(Sender: TObject);
    procedure E2L5Click(Sender: TObject);
    procedure E2L6Click(Sender: TObject);
    procedure E2L7Click(Sender: TObject);
    procedure E3L0Click(Sender: TObject);
    procedure E3L1Click(Sender: TObject);
    procedure E3L2Click(Sender: TObject);
    procedure E3L3Click(Sender: TObject);
    procedure E3L4Click(Sender: TObject);
    procedure E3L5Click(Sender: TObject);
    procedure E3L6Click(Sender: TObject);
    procedure E3L7Click(Sender: TObject);
    procedure enrut0Click(Sender: TObject);
    procedure enrut1Click(Sender: TObject);
    procedure enrut2Click(Sender: TObject);
    procedure enrut3Click(Sender: TObject);
    procedure ESL0Click(Sender: TObject);
    procedure ESL1Click(Sender: TObject);
    procedure ESL2Click(Sender: TObject);
    procedure ESL3Click(Sender: TObject);
    procedure ESL4Click(Sender: TObject);
    procedure ESL5Click(Sender: TObject);
    procedure ESL6Click(Sender: TObject);
    procedure ESL7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure lblE0MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblE1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblE2MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblE3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblSensorClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure txtMarcNumDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure txtMarcNumDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    HayError: boolean;
    function PuertoSeleccionado: string;
  private  //Campos para la ventana de conexiones
    entrada: integer;
    leyendo_can_Act: boolean;
    leyendo_est_Sen: boolean;
    canal_actual: integer;
    estad_sensor: integer;
    frmEnrutamiento: TfrmNiloMEnrutam;
    procedure Marcado(digito: string);
    procedure EnviarCadena(cad:string);
    procedure RefrescarEstado;
    procedure decodificarDigitados(linea: string);
    procedure ProcesarLinea(linea: string);
    procedure conectar(cmd: TStaticText);
    Function conectado(cmd: TStaticText): Boolean;
    procedure desconectar(cmd: TStaticText);
    procedure refrescar_etiq(lbl: TEdit; activo: Boolean; polaridad: String;
                                            colgado:String);
    procedure refrescar_sensor(canal_sal: Integer; activo: Boolean;
                                              polaridad, colgado: string);
    procedure refrescar_entrada0(canal_sal: Integer);
    procedure refrescar_entrada1(canal_sal: Integer);
    procedure refrescar_entrada2(canal_sal: Integer);
    procedure refrescar_entrada3(canal_sal: Integer);

    procedure refrescar_matriz(canal_ent: Integer; canal_sal: Integer);
    procedure refrescar_csensor(estado: integer);
  public //Control del terminal
    onEnviarCom: TEvCibNiloMEnviarCom;
    padre      : TObject;   //referencia genérica a la clase TCibGFacNiloM
    procedure ProcesarCad(cad: string);
    procedure RegMensaje(NomCab: string; msj: string);
    procedure TermWrite(cad: string);
    procedure TermWriteLn(cad: string);
  end;

var
  frmNiloMConex: TfrmNiloMConex;

implementation
{$R *.lfm}
uses CibGFacNiloM, CibNiloMConex;

{ TfrmNiloMConex }
function TfrmNiloMConex.PuertoSeleccionado: string;
{Devuelve el puerto seleccionado actualmente, en el combo del diálogo.}
begin
  Result := trim(cmbPuerto.Text);
end;
procedure TfrmNiloMConex.btnEnviarClick(Sender: TObject);
begin
  TCibGFacNiloM(padre).EnvComando(txtComando.Text);
end;
procedure TfrmNiloMConex.btnLimpTermClick(Sender: TObject);
begin
  Memo1.Clear;
end;
procedure TfrmNiloMConex.btnRefresClick(Sender: TObject);
begin
  //Actualiza la matriz de conexiones
  EnviarCadena('e90' + LineEnding + 'e40');  //Para actualizar el estado del canal 0
  EnviarCadena('e91' + LineEnding + 'e40');  //Para actualizar el estado del canal 1
  EnviarCadena('e92' + LineEnding + 'e40');  //Para actualizar el estado del canal 2
  EnviarCadena('e93' + LineEnding + 'e40');  //Para actualizar el estado del canal 3
  EnviarCadena('e97' + LineEnding + 'e50');  //Para actualizar el estado del sensor
end;
procedure TfrmNiloMConex.cmbPuertoChange(Sender: TObject);
begin
  if TCibGFacNiloM(padre).PuertoN <> PuertoSeleccionado then begin
    //Se elije otro puerto del combo
    if TCibGFacNiloM(padre).estadoCnx in [necConectado, necConectando] then begin
      //El puerto actual está abierto
      MsgExc('Debe cerrar primero el puerto actual, antes de intentar cambiarlo.');
      cmbPuerto.Text:=TCibGFacNiloM(padre).PuertoN;  //retorna al puerto inicial
      exit;
    end;
  end;
end;

procedure TfrmNiloMConex.cmdD0Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e30'); Sleep(150); Marcado('0');
end;
procedure TfrmNiloMConex.cmdD1Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e31'); Sleep(150); Marcado('1');
end;
procedure TfrmNiloMConex.cmdD2Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e32'); Sleep(150); Marcado('2');
end;
procedure TfrmNiloMConex.cmdD3Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e33'); Sleep(150); Marcado('3');
end;
procedure TfrmNiloMConex.cmdD4Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e34'); Sleep(150); Marcado('4');
end;
procedure TfrmNiloMConex.cmdD5Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e35'); Sleep(150); Marcado('5');
end;
procedure TfrmNiloMConex.cmdD6Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e36'); Sleep(150); Marcado('6');
end;
procedure TfrmNiloMConex.cmdD7Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e37'); Sleep(150); Marcado('7');
end;
procedure TfrmNiloMConex.cmdD8Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e38'); Sleep(150); Marcado('8');
end;
procedure TfrmNiloMConex.cmdD9Click(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e39'); Sleep(150); Marcado('9');
end;
procedure TfrmNiloMConex.cmdDAClick(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e2A'); Sleep(150); Marcado('A');
end;
procedure TfrmNiloMConex.cmdDBClick(Sender: TObject);
begin
  EnviarCadena('e96' + LineEnding + 'e23'); Sleep(150); Marcado('B');
end;

procedure TfrmNiloMConex.cmdMarcNumClick(Sender: TObject);
//Inicia la remarcación del número indicado
var
  i  : Integer;
  dig: char;
begin
  If txtMarcNum.Text = '' Then Exit;
  For i := 1 To Length(txtMarcNum.Text) do begin
      dig := txtMarcNum.Text[i];
      If dig = '*' Then dig := 'A';
      If dig = '#' Then dig := 'B';
      Case dig of
      '0': cmdD0Click(Self);
      '1': cmdD1Click(Self);
      '2': cmdD2Click(Self);
      '3': cmdD3Click(Self);
      '4': cmdD4Click(Self);
      '5': cmdD5Click(Self);
      '6': cmdD6Click(Self);
      '7': cmdD7Click(Self);
      '8': cmdD8Click(Self);
      '9': cmdD9Click(Self);
      'A': cmdDAClick(Self);
      'B': cmdDBClick(Self);
      End;
      Sleep(50);
  end;
end;

procedure TfrmNiloMConex.cmdSENClick(Sender: TObject);
begin
  If conectado(cmdSEN) Then begin
      //Ya está conectado hay que desconectar
      EnviarCadena('e94' + LineEnding + 'e00' + LineEnding + 'e97' + LineEnding + 'e50');
      txtDigitados.Text := '';
  end Else begin
      //Está desconectado hay que conectar
      EnviarCadena('e94' + LineEnding + 'e01' + LineEnding + 'e97' + LineEnding + 'e50');
      txtDigitados.Text := '';
  End;
end;

procedure TfrmNiloMConex.cmdVerEstadoClick(Sender: TObject);
begin
  ESL0Click(Self);
  ESL1Click(Self);
  ESL2Click(Self);
  ESL3Click(Self);
  ESL4Click(Self);
  ESL5Click(Self);
  ESL6Click(Self);
  ESL7Click(Self);
end;

procedure TfrmNiloMConex.E0L0Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e00' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L1Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e01' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L2Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e02' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L3Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e03' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L4Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e04' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L5Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e05' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L6Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e06' + LineEnding + 'e90' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E0L7Click(Sender: TObject); begin EnviarCadena('e98' + LineEnding + 'e07' + LineEnding + 'e90' + LineEnding + 'e40'); End;

procedure TfrmNiloMConex.E1L0Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e00' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L1Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e01' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L2Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e02' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L3Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e03' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L4Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e04' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L5Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e05' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L6Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e06' + LineEnding + 'e91' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E1L7Click(Sender: TObject); begin EnviarCadena('e99' + LineEnding + 'e07' + LineEnding + 'e91' + LineEnding + 'e40'); End;

procedure TfrmNiloMConex.E2L0Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e00' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L1Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e01' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L2Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e02' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L3Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e03' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L4Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e04' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L5Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e05' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L6Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e06' + LineEnding + 'e92' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E2L7Click(Sender: TObject); begin EnviarCadena('e9A' + LineEnding + 'e07' + LineEnding + 'e92' + LineEnding + 'e40'); End;

procedure TfrmNiloMConex.E3L0Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e00' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L1Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e01' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L2Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e02' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L3Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e03' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L4Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e04' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L5Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e05' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L6Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e06' + LineEnding + 'e93' + LineEnding + 'e40'); End;
procedure TfrmNiloMConex.E3L7Click(Sender: TObject); begin EnviarCadena('e9B' + LineEnding + 'e07' + LineEnding + 'e93' + LineEnding + 'e40'); End;

procedure TfrmNiloMConex.enrut0Click(Sender: TObject);
begin
  frmEnrutamiento.CanalEnt := 0; frmEnrutamiento.Show;
end;
procedure TfrmNiloMConex.enrut1Click(Sender: TObject);
begin
  frmEnrutamiento.CanalEnt := 1; frmEnrutamiento.Show;
end;
procedure TfrmNiloMConex.enrut2Click(Sender: TObject);
begin
  frmEnrutamiento.CanalEnt := 2; frmEnrutamiento.Show;
end;
procedure TfrmNiloMConex.enrut3Click(Sender: TObject);
begin
  frmEnrutamiento.CanalEnt := 3; frmEnrutamiento.Show;
end;

procedure TfrmNiloMConex.ESL0Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e00'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL1Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e01'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL2Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e02'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL3Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e03'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL4Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e04'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL5Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e05'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL6Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e06'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;
procedure TfrmNiloMConex.ESL7Click(Sender: TObject);
begin
  EnviarCadena('e95' + LineEnding + 'e07'); Sleep(300); EnviarCadena('e97' + LineEnding + 'e50');
end;

procedure TfrmNiloMConex.FormCreate(Sender: TObject);
begin
  cmdVerEstado.Caption:='Ver Estado'+LineEnding+'de Salidas';
  frmEnrutamiento:= TfrmNiloMEnrutam.Create(nil);  //maneja su propio formulario
  frmEnrutamiento.OnEnviarCadena := @EnviarCadena;
end;
procedure TfrmNiloMConex.btnConectClick(Sender: TObject);
begin
  if TCibGFacNiloM(padre).PuertoN <> PuertoSeleccionado then begin
    MsgExc('Debe aplicar primero los cambios para abrir el puerto seleccionado.');
    exit;
  end;
  TCibGFacNiloM(padre).Conectar;
end;
procedure TfrmNiloMConex.btnDesconClick(Sender: TObject);
begin
  if TCibGFacNiloM(padre).PuertoN <> PuertoSeleccionado then begin
    MsgExc('Debe aplicar primero los cambios para abrir el puerto seleccionado.');
    exit;
  end;
  TCibGFacNiloM(padre).Desconectar;
end;
procedure TfrmNiloMConex.FormDestroy(Sender: TObject);
begin
  frmEnrutamiento.Destroy;
end;
procedure TfrmNiloMConex.FormKeyPress(Sender: TObject; var Key: char);
{Intercepta los eventos del teclado}
begin
  if tabConexiones.Visible then begin
    //Estamos en la ventana de conexiones
    //Hay que ver si no se está escribiendo en los textBox
    if txtDigitados.Focused then exit;
    if txtMarcNum.Focused then exit;
    if txtDig0.Focused then exit;
    if txtDig1.Focused then exit;
    if txtDig2.Focused then exit;
    if txtDig3.Focused then exit;
    //El enfoque está en cualquiera de los otros controles
    Case Key of
    '0': cmdD0Click(self);
    '1': cmdD1Click(self);
    '2': cmdD2Click(self);
    '3': cmdD3Click(self);
    '4': cmdD4Click(self);
    '5': cmdD5Click(self);
    '6': cmdD6Click(self);
    '7': cmdD7Click(self);
    '8': cmdD8Click(self);
    '9': cmdD9Click(self);
    '*': cmdDAClick(self);   //tecla "*" del teclado numérico
    '/': cmdDBClick(self);   //tecla "/" del teclado numérico
    end
  end;
end;
procedure TfrmNiloMConex.FormShow(Sender: TObject);
begin
  //Carga las propiedades
  cmbPuerto.Text    := TCibGFacNiloM(padre).PuertoN;
end;

procedure TfrmNiloMConex.lblE0MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [] Then begin
      EnviarCadena('e90' + LineEnding + 'e40');
  end else If Shift = [ssCtrl] Then begin   //con Control
      EnviarCadena('e98' + LineEnding + 'e00' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e01' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e02' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e03' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e04' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e05' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e06' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e07' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e06' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e05' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e04' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e03' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e02' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e01' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e98' + LineEnding + 'e00' + LineEnding + 'e90' + LineEnding + 'e40'); Sleep(300);
  end;
end;
procedure TfrmNiloMConex.lblE1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [] Then begin
      EnviarCadena('e91' + LineEnding + 'e40');
  end else If Shift = [ssCtrl] Then begin   //con Control
      EnviarCadena('e99' + LineEnding + 'e00' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e01' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e02' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e03' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e04' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e05' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e06' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e07' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e06' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e05' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e04' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e03' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e02' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e01' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e99' + LineEnding + 'e00' + LineEnding + 'e91' + LineEnding + 'e40'); Sleep(300);
  end;
end;
procedure TfrmNiloMConex.lblE2MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [] Then begin
      EnviarCadena('e92' + LineEnding + 'e40');
  end else If Shift = [ssCtrl] Then begin   //con Control
      EnviarCadena('e9A' + LineEnding + 'e00' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e01' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e02' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e03' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e04' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e05' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e06' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e07' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e06' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e05' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e04' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e03' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e02' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e01' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9A' + LineEnding + 'e00' + LineEnding + 'e92' + LineEnding + 'e40'); Sleep(300);
  end;
end;
procedure TfrmNiloMConex.lblE3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Shift = [] Then begin
      EnviarCadena('e93' + LineEnding + 'e40');
  end else If Shift = [ssCtrl] Then begin   //con Control
      EnviarCadena('e9B' + LineEnding + 'e00' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e01' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e02' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e03' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e04' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e05' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e06' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e07' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e06' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e05' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e04' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e03' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e02' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e01' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
      EnviarCadena('e9B' + LineEnding + 'e00' + LineEnding + 'e93' + LineEnding + 'e40'); Sleep(300);
  end;
end;

procedure TfrmNiloMConex.lblSensorClick(Sender: TObject);
begin
  EnviarCadena('e97' + LineEnding + 'e50'); //Para actualizar el estado del sensor
end;

procedure TfrmNiloMConex.btnAceptarClick(Sender: TObject);
begin
  btnAplicarClick(self);
  if HayError then exit;  //no cierra
  self.Hide;  //cierra diálogo
end;
procedure TfrmNiloMConex.btnAplicarClick(Sender: TObject);
var
  n: Longint;
begin
  HayError := true;
  //Valida puerto
  if not TryStrToInt(PuertoSeleccionado, n) then begin
    MsgErr('Error en número de puerto');
    exit;
  end;
  ///////////////  Asigna  //////////////////////
  if (TCibGFacNiloM(padre).PuertoN <> PuertoSeleccionado) then begin
    //Hay que cambiar el puerto
    if TCibGFacNiloM(padre).estadoCnx = necConectado then begin
     //estaba abierto
     TCibGFacNiloM(padre).Desconectar;   //lo cierra primero
    end;
    TCibGFacNiloM(padre).PuertoN := PuertoSeleccionado;
  end;
  HayError := false;   //salió sin error;
end;
procedure TfrmNiloMConex.btnCancelarClick(Sender: TObject);
begin
  self.Hide;
end;
procedure TfrmNiloMConex.Timer1Timer(Sender: TObject);
begin
  if self.Visible then RefrescarEstado;
end;

procedure TfrmNiloMConex.txtMarcNumDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  edit: TEdit;
begin
  if Source = Sender then exit;  //no nos soltamos a nosotros mismos
  if Source is TEdit  then begin
    edit := TEdit(Source);
    txtMarcNum.Text:= edit.Text;
  end;
end;

procedure TfrmNiloMConex.txtMarcNumDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  iF sender is TEdit then Accept := true;
end;

//Campos para la entana de conexiones
procedure TfrmNiloMConex.Marcado(digito: string);
//Va agregando un dígito a la ventana de Números Digitados
begin
  txtDigitados.Text := txtDigitados.Text + digito;
end;
procedure TfrmNiloMConex.EnviarCadena(cad: string);
begin
  TCibGFacNiloM(padre).EnvCadena(cad);
end;
procedure TfrmNiloMConex.RefrescarEstado;
{Refresca los controles, de acuerdo al estado de la conexión}
begin
  case TCibGFacNiloM(padre).estadoCnx of
  necConectado: begin
    Memo1.Enabled:=true;
    btnConect.Enabled:=false;
    btnDescon.Enabled:=true;
    cmbPuerto.Enabled:=false;
  end;
  necConectando: begin
    Memo1.Enabled:=false;
    btnConect.Enabled:=false;
    btnDescon.Enabled:=true;
    cmbPuerto.Enabled:=false;
  end;
  necDetenido, necMuerto: begin
    Memo1.Enabled:=false;
    btnConect.Enabled:=true;
    btnDescon.Enabled:=false;
    cmbPuerto.Enabled:=true;
  end;
  end;
end;
procedure TfrmNiloMConex.decodificarDigitados(linea: string);
begin
  If Length(linea) <> 3 Then
      exit
  else If MidStr(linea, 1, 2) = 'n0' Then
      txtDig0.Text := txtDig0.Text + MidStr(linea, 3, 1)
  else If MidStr(linea, 1, 2) = 'n1' Then
      txtDig1.Text := txtDig1.Text + MidStr(linea, 3, 1)
  else If MidStr(linea, 1, 2) = 'n2' Then
      txtDig2.Text := txtDig2.Text + MidStr(linea, 3, 1)
  else If MidStr(linea, 1, 2) = 'n3' Then
      txtDig3.Text := txtDig3.Text + MidStr(linea, 3, 1);
end;
procedure TfrmNiloMConex.ProcesarLinea(linea: string);
{Si detecta comando de leer entrada, toma la entrada}
begin
  if      (linea = '>e90') Or (linea = '>ed0') then
      entrada := 0
  else if (linea = '>e91') Or (linea = '>ed1') then
      entrada := 1
  else if (linea = '>e92') Or (linea = '>ed2') then
      entrada := 2
  else if (linea = '>e93') Or (linea = '>ed3') then
      entrada := 3
  else if (linea = '>ed4') Then
      entrada := 4
  else if (linea = 'c0') Then
      txtDig0.Caption := '' //Limpia digitados
  else if (linea = 'c1') Then
      txtDig1.Caption := '' //Limpia digitados
  else if (linea = 'c2') Then
      txtDig2.Caption := '' //Limpia digitados
  else if (linea = 'c3') Then
      txtDig3.Caption := '' //Limpia digitados
  else if StringLike(linea, 'n##') Then
      decodificarDigitados(linea);
  //Si detecta respuesta lo guarda y actualiza
  if leyendo_can_Act And StringLike(linea,'###') Then begin
      //Es el valor leido del comando
      canal_actual := StrToInt(linea);
      refrescar_matriz(entrada, canal_actual);
      leyendo_can_Act := False;
  end;
  if leyendo_est_Sen And StringLike(linea,'###') Then begin
      //Es el valor leido del comando
      estad_sensor := StrToInt(linea);
      refrescar_csensor(estad_sensor);
      leyendo_est_Sen := False;
  end;

  If linea = '>e40' Then begin
      //se ha detectado comando de lectura de canal actual
      leyendo_can_Act := True;
  end;
  If linea = '>e50' Then begin
      //se ha detectado comando de lectura de sensor
      leyendo_est_Sen := True;
  end;
  If StringLike(linea, '-*') Then begin //listado de bolsa de digitados
      //Pasa valor a la ventana de enrutamiento para actualizar bolsa
      delete(linea,1,1);
      frmEnrutamiento.MostrarBolsaDig(entrada, linea);
  end else if StringLike(linea, '=*') Then begin //listado de bolsa de prefijos
      //Pasa valor a la ventana de enrutamiento para actualizar bolsa
      delete(linea,1,1);
      frmEnrutamiento.MostrarBolsaPre(entrada, linea);
  end;
end;
procedure TfrmNiloMConex.conectar(cmd: TStaticText);
begin
  //Se usa TStaticText porque los botones responden al tema de Windows y no permiten
  //cambiar el color.
  cmd.Color := clYellow;
  cmd.Caption := 'ON';
End;
function TfrmNiloMConex.conectado(cmd: TStaticText): Boolean;
begin
  If cmd.Caption = 'ON' Then Result := True Else Result := False;
End;
procedure TfrmNiloMConex.desconectar(cmd: TStaticText);
begin
    cmd.Color := clBlack;
    cmd.Caption := 'OFF';
End;
procedure TfrmNiloMConex.refrescar_etiq(lbl: TEdit; activo: Boolean;
  polaridad: String; colgado: String);
begin
    If activo Then begin
        If polaridad = '+' Then begin
            If colgado = 'colgado' Then begin
                lbl.Color := clRed;
            end Else begin
                //lbl.Color = RGB(255, 100, 32)
                lbl.Color := clYellow;    //No hace caso a la polaridad porque en el NILO-mB
            End;
        end Else begin    //polaridad negativa
            If colgado = 'colgado' Then begin
                lbl.Color := clGreen;
            end Else begin
                lbl.Color := clYellow;
            End;
        End;
    end Else begin
      lbl.Color := $808080;
    End;
End;
procedure TfrmNiloMConex.refrescar_sensor(canal_sal: Integer; activo: Boolean;
                                          polaridad, colgado: string);
begin
    desconectar(ESL0);
    desconectar(ESL1);
    desconectar(ESL2);
    desconectar(ESL3);
    desconectar(ESL4);
    desconectar(ESL5);
    desconectar(ESL6);
    desconectar(ESL7);
    Case canal_sal of
    0: begin conectar(ESL0); end;
    1: begin conectar(ESL1); refrescar_etiq(lbl1, activo, polaridad, colgado); end;
    2: begin conectar(ESL2); refrescar_etiq(lbl2, activo, polaridad, colgado); end;
    3: begin conectar(ESL3); refrescar_etiq(lbl3, activo, polaridad, colgado); end;
    4: begin conectar(ESL4); refrescar_etiq(lbl4, activo, polaridad, colgado); end;
    5: begin conectar(ESL5); refrescar_etiq(lbl5, activo, polaridad, colgado); end;
    6: begin conectar(ESL6); refrescar_etiq(lbl6, activo, polaridad, colgado); end;
    7: begin conectar(ESL7); refrescar_etiq(lbl7, activo, polaridad, colgado); end;
    End;
End;
procedure TfrmNiloMConex.refrescar_entrada0(canal_sal: Integer);
begin
    desconectar(E0L0);
    desconectar(E0L1);
    desconectar(E0L2);
    desconectar(E0L3);
    desconectar(E0L4);
    desconectar(E0L5);
    desconectar(E0L6);
    desconectar(E0L7);
    If canal_sal = 0 Then conectar(E0L0);
    If canal_sal = 1 Then conectar(E0L1);
    If canal_sal = 2 Then conectar(E0L2);
    If canal_sal = 3 Then conectar(E0L3);
    If canal_sal = 4 Then conectar(E0L4);
    If canal_sal = 5 Then conectar(E0L5);
    If canal_sal = 6 Then conectar(E0L6);
    If canal_sal = 7 Then conectar(E0L7);
End;
procedure TfrmNiloMConex.refrescar_entrada1(canal_sal: Integer);
begin
    desconectar(E1L0);
    desconectar(E1L1);
    desconectar(E1L2);
    desconectar(E1L3);
    desconectar(E1L4);
    desconectar(E1L5);
    desconectar(E1L6);
    desconectar(E1L7);
    If canal_sal = 0 Then conectar(E1L0);
    If canal_sal = 1 Then conectar(E1L1);
    If canal_sal = 2 Then conectar(E1L2);
    If canal_sal = 3 Then conectar(E1L3);
    If canal_sal = 4 Then conectar(E1L4);
    If canal_sal = 5 Then conectar(E1L5);
    If canal_sal = 6 Then conectar(E1L6);
    If canal_sal = 7 Then conectar(E1L7);
End;
procedure TfrmNiloMConex.refrescar_entrada2(canal_sal: Integer);
begin
    desconectar(E2L0);
    desconectar(E2L1);
    desconectar(E2L2);
    desconectar(E2L3);
    desconectar(E2L4);
    desconectar(E2L5);
    desconectar(E2L6);
    desconectar(E2L7);
    If canal_sal = 0 Then conectar(E2L0);
    If canal_sal = 1 Then conectar(E2L1);
    If canal_sal = 2 Then conectar(E2L2);
    If canal_sal = 3 Then conectar(E2L3);
    If canal_sal = 4 Then conectar(E2L4);
    If canal_sal = 5 Then conectar(E2L5);
    If canal_sal = 6 Then conectar(E2L6);
    If canal_sal = 7 Then conectar(E2L7);
End;
procedure TfrmNiloMConex.refrescar_entrada3(canal_sal: Integer);
begin
    desconectar(E3L0);
    desconectar(E3L1);
    desconectar(E3L2);
    desconectar(E3L3);
    desconectar(E3L4);
    desconectar(E3L5);
    desconectar(E3L6);
    desconectar(E3L7);
    If canal_sal = 0 Then conectar(E3L0);
    If canal_sal = 1 Then conectar(E3L1);
    If canal_sal = 2 Then conectar(E3L2);
    If canal_sal = 3 Then conectar(E3L3);
    If canal_sal = 4 Then conectar(E3L4);
    If canal_sal = 5 Then conectar(E3L5);
    If canal_sal = 6 Then conectar(E3L6);
    If canal_sal = 7 Then conectar(E3L7);
End;
procedure TfrmNiloMConex.refrescar_matriz(canal_ent: Integer; canal_sal: Integer);
//Refresca el gráfico con información sobre la conexion
begin
    if canal_ent = 0 Then
      refrescar_entrada0(canal_sal)
    else If canal_ent = 1 Then
      refrescar_entrada1(canal_sal)
    else If canal_ent = 2 Then
      refrescar_entrada2(canal_sal)
    else If canal_ent = 3 Then
      refrescar_entrada3(canal_sal);
End;
procedure TfrmNiloMConex.refrescar_csensor(estado: integer);
//Interpreta el Byte de estado del sensor
var
  binario   : String;
  activo    : Boolean;
  polaridad : String;
  colgado   : String;
  canal     : Integer;
  cargaRemar: Boolean;
begin
//    binario := RightStr('00000000' + decTObin(CLng(estado)), 8);
    binario := IntToBin(estado, 8);
    If MidStr(binario, 8, 1) = '1' Then polaridad := '-' Else polaridad := '+';
    If MidStr(binario, 7, 1) = '1' Then colgado := 'colgado' Else colgado := 'descolg.';
    If MidStr(binario, 6, 1) = '1' Then activo := True Else activo := False;

    If activo Then begin
        lblSensor.Color := $008000;
        lblSensor.Caption := 'Activo: SI' + LineEnding +
                        'Estado: ' + colgado + LineEnding +
                        'Polaridad: ' + polaridad;
    end Else begin
        lblSensor.Color := clRed;
        lblSensor.Caption := 'Activo: NO' + LineEnding +
                        'Estado: ' + colgado;
    End;

    canal := StrToInt('%'+(MidStr(binario, 2, 3)));
    refrescar_sensor(canal, activo, polaridad, colgado);
    //Lee estado de la carga de remarcado
    If MidStr(binario, 1, 1) = '1' Then cargaRemar := True Else cargaRemar := False;
    If cargaRemar Then begin
        conectar(cmdSEN);
    end Else begin
        desconectar(cmdSEN);
    end;
end;
//Control del terminal
procedure TfrmNiloMConex.ProcesarCad(cad: string);
var
  tmp, ultLin: String;
  i: Integer;
begin
  //Los datos llegan por blqoues de caracteres. No necesariamente pro líneas
  memo1.Lines.BeginUpdate;
  tmp := '';
  for i:=1 to length(cad) do begin
    case cad[i] of
    #13: ;   //ignora este caracter
    #10: begin  //es salto
        //Escribe lo acumulado
        ultLin := memo1.Lines[memo1.Lines.Count-1];
        memo1.Lines[memo1.Lines.Count-1] := ultLin + tmp;
        memo1.Lines.Add('');  //argega salto
        tmp := '';            //limpia para acumular de nuevo
      end;
    else
      tmp := tmp + cad[i];   //acumula caracter
    end;
  end;
  if tmp<>'' then begin
    //Termina de volcar los caracteres
    ultLin := memo1.Lines[memo1.Lines.Count-1];
    memo1.Lines[memo1.Lines.Count-1] := ultLin + tmp;
  end;
  memo1.Lines.EndUpdate;
  //memo1.Lines.Add(cad);
end;
procedure TfrmNiloMConex.RegMensaje(NomCab: string; msj: string);
begin
  memo1.Lines.Add('[Msje]:' + msj);
end;
procedure TfrmNiloMConex.TermWrite(cad: string);
var
  ultLin: String;
begin
  ultLin := memo1.Lines[memo1.Lines.Count-1];
  memo1.Lines[memo1.Lines.Count-1] := ultLin + cad;
end;
procedure TfrmNiloMConex.TermWriteLn(cad: string);
var
  ultLin: String;
begin
  ultLin := memo1.Lines[memo1.Lines.Count-1];
  memo1.Lines[memo1.Lines.Count-1] := ultLin + cad;
  memo1.Lines.Add('');
  //Procesa la línea porque ya está completa
  ProcesarLinea(ultLin + cad);
end;

end.

