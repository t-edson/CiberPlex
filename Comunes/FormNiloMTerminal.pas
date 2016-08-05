unit FormNiloMTerminal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, CPNiloM;
type

  { TfrmNiloMTerminal }

  TfrmNiloMTerminal = class(TForm)
    btnEnviar: TButton;
    txtComando: TEdit;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnEnviarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    nilo: TCPNiloM;
    procedure ProcesarCad(cad: string);
    procedure RegMensaje(NomCab: string; msj: string);
    procedure TermWrite(cad: string);
    procedure TermWriteLn(cad: string);
  end;

var
  frmNiloMTerminal: TfrmNiloMTerminal;

implementation

{$R *.lfm}

{ TfrmNiloMTerminal }

procedure TfrmNiloMTerminal.FormCreate(Sender: TObject);
begin
end;

procedure TfrmNiloMTerminal.btnEnviarClick(Sender: TObject);
begin
  nilo.EnvComando(txtComando.Text);
end;

procedure TfrmNiloMTerminal.FormDestroy(Sender: TObject);
begin
end;
procedure TfrmNiloMTerminal.RegMensaje(NomCab: string; msj: string);
begin
  memo1.Lines.Add('[Msje]:' + msj);
end;

procedure TfrmNiloMTerminal.TermWrite(cad: string);
var
  ultLin: String;
begin
  ultLin := memo1.Lines[memo1.Lines.Count-1];
  memo1.Lines[memo1.Lines.Count-1] := ultLin + cad;
end;

procedure TfrmNiloMTerminal.TermWriteLn(cad: string);
var
  ultLin: String;
begin
  ultLin := memo1.Lines[memo1.Lines.Count-1];
  memo1.Lines[memo1.Lines.Count-1] := ultLin + cad;
  memo1.Lines.Add('');
end;

procedure TfrmNiloMTerminal.ProcesarCad(cad: string);
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

