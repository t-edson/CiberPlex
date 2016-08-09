unit FormVisorMsjRed;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Clipbrd, CibGFacCabinas;
type

  { TfrmVisorMsjRed }

  TfrmVisorMsjRed = class(TForm)
    btnCopiar: TButton;
    btnLimpiar: TButton;
    btnAgrSalto: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnCopiarClick(Sender: TObject);
    procedure btnAgrSaltoClick(Sender: TObject);
    procedure btnLimpiarClick(Sender: TObject);
  public
    nomCab: string;  //Para saber a qué cabina está monitoreando
    procedure Exec(nomCab0: string);
    procedure PonerMsje(msj: string);
  end;

var
  frmVisorMsjRed: TfrmVisorMsjRed;

implementation
{$R *.lfm}
procedure TfrmVisorMsjRed.btnLimpiarClick(Sender: TObject);
begin
  Memo1.Clear;
end;
procedure TfrmVisorMsjRed.btnCopiarClick(Sender: TObject);
begin
  Clipboard.AsText:=Memo1.Text;
end;
procedure TfrmVisorMsjRed.btnAgrSaltoClick(Sender: TObject);
begin
  Memo1.Lines.Add('');
end;
procedure TfrmVisorMsjRed.Exec(nomCab0: string);
begin
  nomCab:= nomCab0;
  Caption := 'Mensajes de Red - ' + nomCab;
  self.Show;
end;
procedure TfrmVisorMsjRed.PonerMsje(msj: string);
begin
  while Memo1.Lines.Count>100 do begin
    Memo1.Lines.Delete(0);  //limita el tamaño
  end;
  Memo1.Lines.Add(msj);
end;

end.

