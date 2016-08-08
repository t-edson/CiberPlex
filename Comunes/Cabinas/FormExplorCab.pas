{Implementa el formulario explorador de la cabina}
unit FormExplorCab;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ShellCtrls, ActnList, Menus,
  frameVisCPlex, ObjGraficos;

type

  { TfrmExplorCab }

  TfrmExplorCab = class(TForm)
    acGenVerPanMsj: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Button1: TButton;
    lblNomPC1: TStaticText;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    picPant: TImage;
    lblNomPC: TStaticText;
    ShellTreeView1: TShellTreeView;
    Timer1: TTimer;
    txtFec: TStaticText;
    procedure picPantClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    VisorCabinas: TfraVisCPlex;
  public
    nomCab: string;
    procedure Exec(VisorCabinas0: TfraVisCPlex; nomCab0: string);
  end;

var
  frmExplorCab: TfrmExplorCab;

implementation
{$R *.lfm}
{ TfrmExplorCab }
procedure TfrmExplorCab.Timer1Timer(Sender: TObject);
var
  cab: TogCabina;
begin
  if not self.Visible then exit;
  cab := VisorCabinas.BuscarOgCabina(nomCab);
  //Actualiza campos
  lblNomPC.Caption:=cab.cab.NombrePC;
  txtFec.Caption:= DateToStr(cab.cab.HoraPC) + LineEnding +
                   TimeToStr(cab.cab.HoraPC);
  if cab.cab.PantBloq then Button1.Caption:='Desbloquear'
  else Button1.Caption:='Bloquear';
end;
procedure TfrmExplorCab.picPantClick(Sender: TObject);
begin

end;
procedure TfrmExplorCab.Exec(VisorCabinas0: TfraVisCPlex; nomCab0: string);
{Inicializa y muestra el formulario de Exploración de archivos. Se necesita la referencia
a un Visor de Cabinas, ya que se ha diseñado para trabajar con este objeto como fuente,
de modo que se pueda usar tanto en el CIBERPLEX-Server como en CIBERPLEX-Visor}
begin
  VisorCabinas := VisorCabinas0;
  nomCab:= nomCab0;
  Caption := 'Explorador de Archivos - ' + nomCab;
  self.Show;
end;

end.

