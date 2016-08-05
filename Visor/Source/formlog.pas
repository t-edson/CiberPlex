unit FormLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Clipbrd;

type

  { TfrmLog }

  TfrmLog = class(TForm)
    btnLimpiar: TButton;
    btnCopiar: TButton;
    btnAgrSalto: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnCopiarClick(Sender: TObject);
    procedure btnAgrSaltoClick(Sender: TObject);
    procedure btnLimpiarClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmLog: TfrmLog;

implementation

{$R *.lfm}

{ TfrmLog }

procedure TfrmLog.btnLimpiarClick(Sender: TObject);
begin
  Memo1.Clear;
end;

procedure TfrmLog.btnCopiarClick(Sender: TObject);
begin
  Clipboard.AsText:=Memo1.Text;
end;

procedure TfrmLog.btnAgrSaltoClick(Sender: TObject);
begin
  Memo1.Lines.Add('');
end;

end.

