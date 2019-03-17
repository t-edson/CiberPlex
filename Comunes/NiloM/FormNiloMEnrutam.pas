unit FormNiloMEnrutam;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, strutils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, MisUtils, CibNiloMTarifRut;
type
  TEvOnEnviarCadena = procedure(cad: string) of object;

  { TfrmNiloMEnrutam }
  TfrmNiloMEnrutam = class(TForm)
    Command1: TButton;
    cmdActualizar: TButton;
    cmdGrabar: TButton;
    cmdEnrutar: TButton;
    txtBolsaPre: TEdit;
    txtBolsaDig: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure cmdActualizarClick(Sender: TObject);
    procedure cmdEnrutarClick(Sender: TObject);
    procedure cmdGrabarClick(Sender: TObject);
    procedure Command1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    comLec    : String;      //comando de lectura
    comLeeBolD: String;      //comando Leer Bolsa de dígitos
    comLeeBolP: String;      //comando Leer Bolsa de prefijos
    comAgrDig : String;      //comando agregar dígito
    comAgrPre : String;      //comando agregar prefijo
    comEnrut  : String;      //comando de enrutar
  public
    CanalEnt: Integer;
    OnEnviarCadena: TEvOnEnviarCadena;  {usado para enviar comandos, ya que no se tiene
                                         acceso directo al formulario frmNiloMConex}
    procedure MostrarBolsaDig(entrada: Integer; bolsa: String);
    procedure MostrarBolsaPre(entrada: Integer; bolsa: String);
  end;

var
  frmNiloMEnrutam: TfrmNiloMEnrutam;

implementation
{$R *.lfm}

procedure TfrmNiloMEnrutam.Command1Click(Sender: TObject);
begin
  Hide;
end;

procedure TfrmNiloMEnrutam.FormActivate(Sender: TObject);
begin
  Self.Caption := 'ENRUTAMIENTO ' + IntToStr(CanalEnt);
  //Actualiza los comandos de acuerdo al canal de trabajo
  if CanalEnt = 0 Then begin
      comLec := 'e90';
      comLeeBolD := 'ed0'; comAgrDig := 'e80';
      comLeeBolP := 'ep0'; comAgrPre := 'e84';
      comEnrut := 'e88';
  end else If CanalEnt = 1 Then begin
      comLec := 'e91';
      comLeeBolD := 'ed1'; comAgrDig := 'e81';
      comLeeBolP := 'ep1'; comAgrPre := 'e85';
      comEnrut := 'e89';
  end else If CanalEnt = 2 Then begin
      comLec := 'e92';
      comLeeBolD := 'ed2'; comAgrDig := 'e82';
      comLeeBolP := 'ep2'; comAgrPre := 'e86';
      comEnrut := 'e8A';
  end else if CanalEnt = 3 Then begin
      comLec := 'e93';
      comLeeBolD := 'ed3'; comAgrDig := 'e83';
      comLeeBolP := 'ep3'; comAgrPre := 'e87';
      comEnrut := 'e8B';
  End;
end;
procedure TfrmNiloMEnrutam.cmdActualizarClick(Sender: TObject);
//Actualiza Canal a enrutar y Bolsa de dígitos
begin
  cmdGrabar.Enabled := False;       //Para evitar saturación del NILO
  cmdEnrutar.Enabled := False;
  cmdActualizar.Enabled := False;
  //Lee CANAL A ENRUTAR
  OnEnviarCadena(comLec + LineEnding + 'e41');
  //Lee Bolsa de digitados
  OnEnviarCadena(comLeeBolD);
  //Lee bolsa de prefijos
  OnEnviarCadena(comLeeBolP);
  cmdGrabar.Enabled := True;
  cmdEnrutar.Enabled := True;
  cmdActualizar.Enabled := True;
end;

procedure TfrmNiloMEnrutam.cmdEnrutarClick(Sender: TObject);
begin
  cmdGrabar.Enabled := False;       //Para evitar saturación del NILO
  cmdEnrutar.Enabled := False;
  cmdActualizar.Enabled := False;
  OnEnviarCadena(comEnrut + LineEnding + 'e01');
  cmdGrabar.Enabled := True;
  cmdEnrutar.Enabled := True;
  cmdActualizar.Enabled := True;
end;

procedure TfrmNiloMEnrutam.cmdGrabarClick(Sender: TObject);
//Fija Bolsa de dígitos y de prefijos
var
  i : Integer;
  dig , Err: String;
  car: Char;
begin
    //Verifica validez de cadena de prefijos
    Err := VerificarCadCodpre(txtBolsaPre.Text);
    if Err <> '' Then begin
        MsgExc(Err);
        txtBolsaPre.SetFocus;
        Exit;
    end;
    //Graba
    cmdGrabar.Enabled := False;       //Para evitar saturación del NILO
    cmdEnrutar.Enabled := False;
    cmdActualizar.Enabled := False;
    OnEnviarCadena(comEnrut + LineEnding + 'e00');  //Comando para limpiar bolsas
    For i := 1 To Length(txtBolsaDig.Text) do begin
        car := Text[i];
//        If car = '*' Then car = 'A'
//        If car = '#' Then car = 'B'
        OnEnviarCadena(comAgrDig + LineEnding + 'e' + IntToHex(Ord(car),2));
        Sleep(50);
    end;
    For i := 1 To Length(txtBolsaPre.Text) div 2 do begin
        dig := MidStr(txtBolsaPre.Text, (2*i-1), 2);
        OnEnviarCadena(comAgrPre + LineEnding + 'e' + IntTOHex(CodifPref(dig, Err), 2));
        Sleep(50);
    end;
    cmdGrabar.Enabled := True;
    cmdEnrutar.Enabled := True;
    cmdActualizar.Enabled := True;
end;

procedure TfrmNiloMEnrutam.MostrarBolsaDig(entrada: Integer; bolsa: String);
//Muestra la inforamción sobre la bolsa de digitados
begin
  If entrada <> CanalEnt Then Exit;    //no corresponde
  txtBolsaDig.Text := bolsa;
end;

procedure TfrmNiloMEnrutam.MostrarBolsaPre(entrada: Integer; bolsa: String);
//Muestra la inforamción sobre la bolsa de digitados
var
  i  : Integer;
  tmp: String;
begin
  If entrada <> CanalEnt Then Exit;    //no corresponde
  tmp := '';
//    txtBolsaPre.Text = bolsa
  For i := 1 To Length(bolsa) do begin
      tmp := tmp + DecodPref(ord(bolsa[i]));
  end;
  txtBolsaPre.Text := tmp;
End;


end.

