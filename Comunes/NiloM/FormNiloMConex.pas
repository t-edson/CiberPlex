unit FormNiloMConex;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, Spin, MisUtils;
type
  TEvCibNiloMEnviarCom = procedure(com: string) of object;   //
  { TfrmNiloMConex }
  TfrmNiloMConex = class(TForm)
    btnAplicar: TBitBtn;
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    btnEnviar: TButton;
    btnConect: TButton;
    btnDescon: TButton;
    cmbPuerto: TComboBox;
    Timer1: TTimer;
    Label1: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    txtComando: TEdit;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnAceptarClick(Sender: TObject);
    procedure btnAplicarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnConectClick(Sender: TObject);
    procedure btnDesconClick(Sender: TObject);
    procedure btnEnviarClick(Sender: TObject);
    procedure cmbPuertoChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    HayError: boolean;
    function PuertoSeleccionado: string;
    procedure RefrescarEstado;
  public
    onEnviarCom: TEvCibNiloMEnviarCom;
    padre      : TObject;   //referecnia genérica a la clase TCibGFacNiloM
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
procedure TfrmNiloMConex.RefrescarEstado;
{Refresca los controles, de acuerdo al estado de la conexión}
begin
  case TCibGFacNiloM(padre).estadoCnx of
  cecConectado: begin
    Memo1.Enabled:=true;
    btnConect.Enabled:=false;
    btnDescon.Enabled:=true;
    cmbPuerto.Enabled:=false;
  end;
  cecConectando: begin
    Memo1.Enabled:=false;
    btnConect.Enabled:=false;
    btnDescon.Enabled:=true;
    cmbPuerto.Enabled:=false;
  end;
  cecDetenido, cecMuerto: begin
    Memo1.Enabled:=false;
    btnConect.Enabled:=true;
    btnDescon.Enabled:=false;
    cmbPuerto.Enabled:=true;
  end;
  end;
end;
procedure TfrmNiloMConex.btnEnviarClick(Sender: TObject);
begin
  TCibGFacNiloM(padre).EnvComando(txtComando.Text);
end;
procedure TfrmNiloMConex.cmbPuertoChange(Sender: TObject);
begin
  if TCibGFacNiloM(padre).PuertoN <> PuertoSeleccionado then begin
    //Se elije otro puerto del combo
    if TCibGFacNiloM(padre).estadoCnx in [cecConectado, cecConectando] then begin
      //El puerto actual está abierto
      MsgExc('Debe cerrar primero el puerto actual, antes de intentar cambiarlo.');
      cmbPuerto.Text:=TCibGFacNiloM(padre).PuertoN;  //retorna al puerto inicial
      exit;
    end;
  end;
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
end;
procedure TfrmNiloMConex.FormShow(Sender: TObject);
begin
  //Carga las propiedades
  cmbPuerto.Text    := TCibGFacNiloM(padre).PuertoN;
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
    if TCibGFacNiloM(padre).estadoCnx = cecConectado then begin
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
//Control del terminal
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
end;
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

end.

