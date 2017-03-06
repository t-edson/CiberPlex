unit FormCambClave;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, FormInicio, frameCfgUsuarios, MisUtils;

type

  { TfrmCambClave }

  TfrmCambClave = class(TForm)
    ButtonPanel1: TButtonPanel;
    txtClaveAct: TEdit;
    txtClaveNue: TEdit;
    txtClaveNue2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmCambClave: TfrmCambClave;

implementation

{$R *.lfm}

{ TfrmCambClave }

procedure TfrmCambClave.OKButtonClick(Sender: TObject);
begin
  if txtClaveAct.Text <> clave then begin
    MsgExc('La contraseña actual no coincide.');
    ModalResult := mrCancel;
  end;
  if txtClaveNue.Text <> txtClaveNue2.Text then begin
    MsgExc('Las contraseñas nuevas no coinciden.');
    ModalResult := mrCancel;
  end;
  //Realiza el cambio
  frameCfgUsuarios.ModificaUsuario(usuario, usuario, txtClaveNue.Text, perfil);
end;

procedure TfrmCambClave.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  if ModalResult = mrCancel then CloseAction:= caNone;
end;

procedure TfrmCambClave.CancelButtonClick(Sender: TObject);
begin
  ModalResult:=mrClose;
end;

end.

