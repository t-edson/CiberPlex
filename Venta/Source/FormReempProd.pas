unit FormReempProd;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Globales, MisUtils;
type

  { TfrmReempProd }

  TfrmReempProd = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    txtNomAnt: TEdit;
    txtNombNuevo: TEdit;
    txtNombre: TEdit;
    txtRuta: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    local: string;
  public
    msjError: string;
    procedure Exec(Alocal: string);
  end;

var
  frmReempProd: TfrmReempProd;

implementation
{$R *.lfm}
{ TfrmReempProd }
procedure TfrmReempProd.Button1Click(Sender: TObject);
var
  arcRes, arcLog: string;
  fArcRes, fArcLog: text;
  linea: string;
  p: SizeInt;
  a: TStringDynArray;
  c, nReemp: Integer;
  hay: Boolean;
begin

  arcLog := txtRuta.Text + DirectorySeparator + txtNombre.Text;
  arcRes := arcLog + '.bak';  //archivo de respaldo
  if FileExists(arcRes) then DeleteFile(arcRes);     //Borra anterior
  RenameFile(arcLog, arcRes);    //Cambia de nombre para que quede como respaldo

  if not FileExists(arcRes) then begin
    MsgExc('No se encuentra archivo: ' + arcRes);
    exit;
  end;
  AssignFile(fArcRes , arcRes);
  AssignFile(fArcLog , arcLog);
  reset(fArcRes);
  rewrite(fArcLog);
  nReemp := 0;
  while Not EOF(fArcRes) do begin
    readln(fArcRes, linea);
    if linea = '' then continue;
    //inicio de registro de venta (venta, internet o llamada)
    If linea[1] in ['b','v','y','x'] Then begin
        //Esta línea puede incluir el nombre del producto
        p := pos(#9, linea);
        If p = 0 Then begin
            msjError := 'Error en estructura de Registro de Ingreso';
            exit;
        end;
//        fec := FechaLOG(copy(linea,p+1,19));
//        if (fec >= f1) And (fec <= f2) Then begin
          a := Explode(#9, linea);
          //Verifica coincidencia, para reemplazar
          hay := false;  //indica si hay reemplazo
          for c := 0 to high(a) do begin
            if a[c] = txtNomAnt.Text then begin
                a[c] := txtNombNuevo.Text;
                inc(nReemp);
                hay := true;
            end;
          end;
          //Reconstruye
          if hay then writeln(fArcLog, Join(#9, a))
          else writeln(fArcLog, linea);
//        end;
    end else begin
      //No hay cambios
      writeln(fArcLog, linea);
    end;
  end;
  CloseFile(fArcLog);
  CloseFile(fArcRes);

  msgbox(IntToStr(nReemp) + ' reemplazos realizados.');
//}
end;

procedure TfrmReempProd.Exec(Alocal: string);
begin
  local := Alocal;
  txtRuta.Text := rutDatos;
  Show;
end;

end.

