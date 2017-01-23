{Implementa el formulario explorador de la cabina}
unit FormExplorCab;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons, ShellCtrls, ActnList, Menus, CibFacturables;

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
    fac: TCibFac;
  public
    procedure Exec(fac0: TCibFac);
  end;

var
  frmExplorCab: TfrmExplorCab;

implementation
uses CibGFacCabinas;
{$R *.lfm}
{ TfrmExplorCab }
procedure TfrmExplorCab.Timer1Timer(Sender: TObject);
var
  cab : TCibFacCabina;
begin
  if not self.Visible then exit;
  cab := TCibFacCabina(fac);
  //Actualiza campos
  lblNomPC.Caption:=cab.NombrePC;
  txtFec.Caption:= DateToStr(cab.HoraPC) + LineEnding +
                   TimeToStr(cab.HoraPC);
  if cab.PantBloq then Button1.Caption:='Desbloquear'
  else Button1.Caption:='Bloquear';
end;
procedure TfrmExplorCab.picPantClick(Sender: TObject);
begin

end;
procedure TfrmExplorCab.Exec(fac0: TCibFac);
{Inicializa y muestra el formulario de Exploración de archivos. Se necesita la referencia
a un Visor de Cabinas, ya que se ha diseñado para trabajar con este objeto como fuente,
de modo que se pueda usar tanto en el CIBERPLEX-Server como en CIBERPLEX-Visor}
begin
  fac := fac0;
  Caption := 'Explorador de Archivos - ' + fac.Nombre;
  self.Show;
end;

end.

