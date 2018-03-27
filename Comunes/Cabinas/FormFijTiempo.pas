unit FormFijTiempo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, MisUtils, DateUtils, LCLType,
  CibCabinaBase, CibFacturables;

type
  { TfrmFijTiempo }
  TfrmFijTiempo = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    cmd30: TBitBtn;
    cmd15: TBitBtn;
    cmdLim: TBitBtn;
    chkLibre: TCheckBox;
    chkHorGra: TCheckBox;
    chkManten: TCheckBox;
    txtHH: TEdit;
    txtMM: TEdit;
    txtSS: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure chkLibreChange(Sender: TObject);
    procedure chkMantenChange(Sender: TObject);
    procedure cmd15Click(Sender: TObject);
    procedure cmd30Click(Sender: TObject);
    procedure cmdLimClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure Mostrar(fac0: TCibFac);
    procedure MostrarIni(fac0: TCibFac);
    procedure txtHHKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure txtMMKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure txtSSKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    fac: TCibFac;      //referencia a objeto
    //tpoInic: integer;    //variable de tiempo limitado inicial
    tpoLimi: integer;      //variable de tiempo limitado
    procedure RefrescarTextos;
  public
    //variables de cuenta
    tSolic: TDateTime;
    tlibre: Boolean;
    horgra: Boolean;
    //bandera de botón "Cancelar" pulsado
    cancelo: Boolean;
    function CadActivacion: string;
  end;

var
  frmFijTiempo: TfrmFijTiempo;

implementation
{$R *.lfm}
uses CibGFacCabinas;   //Declarada aquí para evitar referecnia circular

{ TfrmFijTiempo }
procedure TfrmFijTiempo.Mostrar(fac0: TCibFac);
//Muestra el formulario con información de la cabina indicada
begin
  fac := fac0;  //guarda referencia
  Caption := 'MODIFICAR TIEMPO: ' + fac.nombre;
  tpoLimi:= TCibFacCabina(fac).tSolicSeg;  //tiempo solicitado en segundos

  //  cmbHorIni.Text := Format(fac.hor_ini, "yyyy/mm/dd hh:nn:ss");

    If tpoLimi = 0 Then begin
        txtHH.Text := '00';
        txtMM.Text := '00';
        txtSS.Text := '00';
    end Else begin   //hay tiempo prefijado
        RefrescarTextos;
    End;
    txtHH.SelectAll;
    chkHorGra.Checked := TCibFacCabina(fac).horgra;
    chkLibre.Checked := TCibFacCabina(fac).tlibre;
    chkManten.Checked := (TCibFacCabina(fac).EstadoCta = EST_MANTEN);

    cancelo := True;  //para salir sin acción cuando se cierra la ventana con "X"
//    Show;  //se muestra
    ShowModal;
end;
procedure TfrmFijTiempo.MostrarIni(fac0: TCibFac);
//Muestra el formulario para fijar el inicio de la cuenta
begin
  fac := fac0;  //guarda referencia
  Caption := 'FIJAR TIEMPO: ' + fac.nombre;
  tpoLimi:= 0;
  //  cmbHorIni.Text := Format(fac.hor_ini, "yyyy/mm/dd hh:nn:ss");
    txtHH.Text := '00';
    txtMM.Text := '00';
    txtSS.Text := '00';

    txtHH.SelectAll;
    chkHorGra.Checked := false;
    chkLibre.Checked := false;
    chkManten.Checked := false;

    cancelo := True;  //para salir sin acción cuando se cierra la ventana con "X"
//    Show;  //se muestra
    ShowModal;
end;
procedure TfrmFijTiempo.txtHHKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DECIMAL then begin
  end;
end;
procedure TfrmFijTiempo.txtMMKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DECIMAL then begin
  end;
end;
procedure TfrmFijTiempo.txtSSKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DECIMAL then begin
  end;
end;
procedure TfrmFijTiempo.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//Manejo de los atajos por teclado para el formulario
  function TextSeleccionado: boolean;
  begin
    Result := txtHH.Focused or txtMM.Focused or txtSS.Focused;
  end;
begin
  if Key = VK_DECIMAL then begin
    //Punto decimal
    if txtHH.Focused then begin
      txtMM.SetFocus;
      Key := 0;
    end else if txtMM.Focused then begin
      txtSS.SetFocus;
      Key := 0;
    end else if txtSS.Focused then begin
      cmd30.SetFocus;
      Key := 0;
    end else if cmd30.Focused then begin
      cmd15.SetFocus;
      Key := 0;
    end else if cmd15.Focused then begin
      cmdLim.SetFocus;
      Key := 0;
    end;
  end else if Key = VK_0 then begin
    //Tecla cero
    txtHH.SetFocus;
  end else if (Key = VK_NUMPAD1) and not TextSeleccionado then begin
    cmd30Click(self);
  end else if (Key = VK_NUMPAD2) and not TextSeleccionado then begin
    cmd15Click(self);
  end else if (Key = VK_NUMPAD3) and not TextSeleccionado then begin
    cmdLimClick(self);
  end else if (Key = VK_NUMPAD4) and not TextSeleccionado then begin
    chkLibre.Checked := not chkLibre.Checked;
  end else if (Key = VK_NUMPAD5) and not TextSeleccionado then begin
    chkHorGra.Checked := not chkHorGra.Checked;
  end else if (Key = VK_SUBTRACT) and not TextSeleccionado then begin
    BitBtn2Click(self);
  end;
end;

procedure TfrmFijTiempo.FormShow(Sender: TObject);
begin
  //Inicia siempre con este control seleccionado
  BitBtn1.SetFocus;
end;

procedure TfrmFijTiempo.BitBtn1Click(Sender: TObject);
//Aceptar
var
  hh, mm, ss: Integer;
begin
    hh := StrToInt(txtHH.Text);
    mm := StrToInt(txtMM.Text);
    ss := StrToInt(txtSS.Text);
    //Validación de datos
    If (hh < 0) Or (hh > 23) Then begin
        MsgErr('Error en hora');
        Exit;
    End;
    If (mm < 0) Or (mm > 59) Then begin
        MsgErr('Error en minutos');
        Exit;
    End;
    If (ss < 0) Or (ss > 59) Then begin
        MsgErr('Error en segundos');
        Exit;
    End;
    //Verificación de seguridad
    If hh > 10 Then begin
        if Application.MessageBox(PChar('¿Está seguro de que desea limitar con este tiempo?'),'',
            MB_OKCANCEL + MB_ICONQUESTION ) = IDCANCEL then exit;
    End;

    //Toma tiempo
    tpoLimi := hh * 3600 + mm * 60 + ss;
    If (tpoLimi = 0) And (not chkLibre.Checked) And (not chkManten.Checked) Then begin
        If MsgBox('¿Limitar a Tiempo Cero?', '', MB_OKCANCEL + MB_ICONQUESTION) = IDCANCEL Then
            Exit;
    End;
    tSolic := tpoLimi / 60 / 60 / 24;    //fija tiempo
    tlibre := chkLibre.Checked;
    horgra := chkHorGra.Checked;
    cancelo := False;
    Self.Hide;
end;

procedure TfrmFijTiempo.BitBtn2Click(Sender: TObject);
//Cancelar
begin
  cancelo := True;
  Self.Hide;
  Self.Close;
end;

procedure TfrmFijTiempo.chkLibreChange(Sender: TObject);
begin
  If chkLibre.Checked Then begin
      txtHH.Text := '00';
      txtMM.Text := '00';
      txtSS.Text := '00';
      txtHH.Enabled := False;
      txtMM.Enabled := False;
      txtSS.Enabled := False;
  end Else begin
      RefrescarTextos;
      txtHH.Enabled := True;
      txtMM.Enabled := True;
      txtSS.Enabled := True;
  End;
end;

procedure TfrmFijTiempo.chkMantenChange(Sender: TObject);
begin
  If chkManten.Checked Then begin
      txtHH.Text := '00';
      txtMM.Text := '00';
      txtSS.Text := '00';
      txtHH.Enabled := False;
      txtMM.Enabled := False;
      txtSS.Enabled := False;

      chkHorGra.Enabled := False;
      chkLibre.Enabled := False;
  end Else begin
      RefrescarTextos;
      txtHH.Enabled := True;
      txtMM.Enabled := True;
      txtSS.Enabled := True;

      chkHorGra.Enabled := True;
      chkLibre.Enabled := True;
  End;
end;

procedure TfrmFijTiempo.cmd15Click(Sender: TObject);
begin
  If Not txtHH.Enabled Or Not txtMM.Enabled Or Not txtSS.Enabled Then Exit;
  tpoLimi := tpoLimi + 15 * 60;
  RefrescarTextos;
end;

procedure TfrmFijTiempo.cmd30Click(Sender: TObject);
begin
  If Not txtHH.Enabled Or Not txtMM.Enabled Or Not txtSS.Enabled Then Exit;
  tpoLimi := tpoLimi + 30 * 60;
  RefrescarTextos;
end;

procedure TfrmFijTiempo.cmdLimClick(Sender: TObject);
begin
  If Not txtHH.Enabled Or Not txtMM.Enabled Or Not txtSS.Enabled Then Exit;
  tpoLimi := 0;
  RefrescarTextos;
end;
procedure TfrmFijTiempo.RefrescarTextos;
begin
  txtHH.Text := Format('%.*d', [2,tpoLimi div 3600]);
  txtMM.Text := Format('%.*d', [2,(tpoLimi Mod 3600) div 60]);
  txtSS.Text := Format('%.*d', [2,tpoLimi Mod 60]);
End;

function TfrmFijTiempo.CadActivacion: string;
{Devuelve una cadena con información sobre la activación de la cabina}
begin
  Result := TCibFacCabina(fac).CodCadConteo(tSolic, tLibre, horGra );
end;


end.

