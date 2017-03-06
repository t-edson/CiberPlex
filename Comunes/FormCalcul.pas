{Accesorio de calculadora.}
unit FormCalcul;
{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, fpexprpars, FileUtil, Forms, Controls, Graphics, Dialogs,
  Buttons, ExtCtrls, StdCtrls, LCLType, CibUtils, MisUtils;

type

  { TfrmCalcul }

  TfrmCalcul = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    btnCalc: TSpeedButton;
    btnLimp: TSpeedButton;
    procedure btnCalcClick(Sender: TObject);
    procedure btnLimpClick(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    idxLin: integer;  //índice para explorar líneas del historial
  public
    txtIni: string;   //Texto inicial que se mostrará al hacer visible el formulario
  end;

var
  frmCalcul: TfrmCalcul;

implementation

{$R *.lfm}

{ TfrmCalcul }

procedure TfrmCalcul.btnCalcClick(Sender: TObject);
var
  Err: string;
  Res: Double;
begin
  Res := EvaluarExp(Edit1.Text, Err);
  if Err = '' then begin
    memo1.Lines.Add(Edit1.Text + ' = ' + FloatToStr(Res));
    Edit1.Text := FloatToStr(Res);
  end else begin
    MsgExc('Error en expresión.');
  end;
end;

procedure TfrmCalcul.btnLimpClick(Sender: TObject);
begin
  Edit1.Text:='';
end;
procedure TfrmCalcul.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  function ExtraerFormula(txt: string): string;
  begin
    if pos('=', txt) <>0 then begin
      Result := trim(copy(txt, 1, pos('=', txt)-1));
    end else begin
      Result := txt
    end;
  end;
var
  tmp: String;
begin
  if Key = VK_RETURN then begin
    if Edit1.Text = Edit1.SelText then begin
      self.Close;   //Atajo para cerrar la calculadora.
      exit;
    end;
    btnCalcClick(Self);
    idxLin := Memo1.Lines.Count;   //deja apuntando al final
  end;
  if Key = VK_ESCAPE then begin
    self.Close;
  end;
  if Key = VK_UP then begin
    dec(idxLin);
    if idxLin<=0 then idxLin:=0;
    tmp := Memo1.Lines[idxLin];
    Edit1.Text:= ExtraerFormula(tmp);
    Key := 0;
  end;
  if Key = VK_DOWN then begin
    inc(idxLin);
    if idxLin>Memo1.Lines.Count-1 then idxLin:=Memo1.Lines.Count-1;
    tmp := Memo1.Lines[idxLin];
    Edit1.Text:= ExtraerFormula(tmp);
    Key := 0;
  end;
end;

procedure TfrmCalcul.FormShow(Sender: TObject);
begin
  if txtIni<>'' then begin
    Edit1.SetFocus;
    Edit1.Text:=txtIni;
    Edit1.SelStart:=1;
    Edit1.SelLength:=0;
  end;
  txtIni := '';
end;

end.

