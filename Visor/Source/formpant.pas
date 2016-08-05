unit FormPant;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LCLtype;

type
  TEvRefPantalla = procedure of object;
  { TfrmPant }

  TfrmPant = class(TForm)
    Image1: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { private declarations }
  public
    OnRefrescar: TEvRefPantalla;
    { public declarations }
  end;

var
  frmPant: TfrmPant;

implementation

{$R *.lfm}

{ TfrmPant }

procedure TfrmPant.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F5 then begin
    self.Image1.Picture := nil;
    if OnRefrescar <> nil then OnRefrescar;
//    ShowMessage('asdsad');
  end;
end;

end.

