{Formulario para traer el archivo "config.xml" del Servidor de CIBERPLEX.
Se debe usar para los puntos de venta o cualquier otro aplicativo que desea conectarse
inicialmente al servidor de CIBERPLEX.
}
unit FormSincronBD;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, Buttons, LCLProc, MisUtils, CibTramas,
  CibServidorPC;
const
  ARC_CFG_SERV = 'config.xml';   //Archivo de configuración en el servidor

type
  { TfrmSincronBD }
  TfrmSincronBD = class(TForm)
    btnCancelar: TBitBtn;
    Image1: TImage;
    lblEstConexion: TLabel;
    Timer1: TTimer;
    procedure btnCancelarClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ServCab: TCibServidorPC;
    arcSal: String;
  public
    conectado: boolean;
    procedure RegMensaje(txt: string);
    procedure TramaLista(tram: TCPTrama);
    function Exec(ServCab0: TCibServidorPC): integer;
  end;

var
  frmSincronBD: TfrmSincronBD;

implementation
{$R *.lfm}

procedure TfrmSincronBD.btnCancelarClick(Sender: TObject);
begin
//  cancelado := true;
//  hide;
end;
procedure TfrmSincronBD.Timer1Timer(Sender: TObject);
begin
  if conectado then begin

  end else begin
    //Genera un aanimación en el texto
    lblEstConexion.Caption := lblEstConexion.Caption + ' .';
  end;
end;

{ TfrmSincronBD }
procedure TfrmSincronBD.RegMensaje(txt: string);
begin
  if not Visible then exit; //Se supone que ya terminó su trabajo.
  if conectado then begin
    //Ya está conectado
    if txt = MSJ_REINIC_CONEX then begin
      //Se perdió la conexión
      conectado := false;
    end;
  end else begin
     //Sin coenxión
    lblEstConexion.Caption:=txt;
  end;
end;
procedure TfrmSincronBD.TramaLista(tram: TCPTrama);
begin
  if not Visible then exit; //Se supone que ya terminó su trabajo.
  if conectado then begin   ///Conectado
    case tram.tipTra of
      C_FIJ_ARSAL: begin  //Llegó el nombre de un archivo
          arcSal := tram.traDat;
        end;
      M_ARC_SOLIC: begin  //Llego el archivo
          lblEstConexion.Caption:='Archivo recibido: ' + arcSal;
          StringToFile(tram.traDat, arcSal);
          if arcSal = ARC_CFG_SERV then begin
            //LLegó el archivo esperado.
            self.ModalResult:=mrOK;
            exit;
          end;
        end;
      end;
  end else begin            //Desconecatdo
    //Si llega una trama, se asume que ya hay conexión
    conectado := true;
    lblEstConexion.Caption:='Conectado. Leyendo configuración.';
    ServCab.PonerComando(C_FIJ_RUT_A, 0, 0, '-');   //Fija ruta actual
    ServCab.PonerComando(C_ARC_SOLIC, 0, 1, ARC_CFG_SERV);  //El parámetro en "1", hará que llegue primero el nombre del archivo
  end;
end;

function TfrmSincronBD.Exec(ServCab0: TCibServidorPC): integer;
{Inicia mostrando el formulario.}
begin
  ServCab := ServCab0;
  Result := self.ShowModal;
end;

end.

