{Unidad que contiene al formulario para iniciar sesión, a las definiciones de
 usuario, y al contenedor de usuarios}
unit FormInicio;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, types, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, fgl, MisUtils;

type
  TUsuPerfil = (
    PER_ADMIN = 0,     //administrador
    PER_OPER = 1       //operador
  );

  { TregUsuario }
  TregUsuario = class     //Registro de usuarios
  private
    function GetCadObj: string;
    procedure SetCadObj(AValue: string);
    function GetPerStr: string;
    procedure SetPerStr(AValue: string);
  public
    usu: string;     //usuario
    cla: string;     //clave
    per: TUsuPerfil;  //perfil
    //perfil como cadena
    property perStr: string read GetPerStr write SetPerStr;
    //Cadena que representa al objeto (codificada)
    property CadObj: string read GetCadObj write SetCadObj;
  end;

  TregUsuarios = specialize TFPGObjectList<TregUsuario>;   //lista de bloques

  { TfrmInicio }
  TfrmInicio = class(TForm)
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    edUsu: TEdit;
    edCla: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure btnAceptarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    cancelo: boolean;
    { public declarations }
  end;

var
  frmInicio: TfrmInicio;
  usuarios: TregUsuarios;
  //datos del usuario actual
  usuario  : string;      //Usuario actual
  clave    : string;      //Clave actual
  perfil   : TUsuPerfil;   //Perfil actual

implementation
{$R *.lfm}

{ TregUsuario }

function TregUsuario.GetCadObj: string;
//Codifica la información de usuarios
var
  codigo: Integer;
  function CodifCad(cad: string; codigo: integer): string;
  //Codifica una palabra en base a un código dado
  var
    tmp: string;
    i: integer;
    car: char;
  begin
    //pone primer y segundo byte aleatorio
    tmp := Format('%.3d', [Random(1000)]);
    tmp += Format('%.3d', [Random(1000)]);
    //pone código
    tmp += Format('%.3d', [codigo]);
    //codifica demás caracteres
    for i := 1 to Length(cad) do begin
        car := cad[i];
        tmp += Format('%.3d', [ord(car) + codigo]);
    end;
    //reemplaza
    tmp := StringReplace(tmp, '00', 'Z', [rfReplaceAll]);
    tmp := StringReplace(tmp, '23', 'Y', [rfReplaceAll]);
    tmp := StringReplace(tmp, '45', 'X', [rfReplaceAll]);
    tmp := StringReplace(tmp, '67', 'W', [rfReplaceAll]);
    tmp := StringReplace(tmp, '89', 'V', [rfReplaceAll]);
    Result := tmp;
  end;
begin
  Randomize;
  codigo := Random(300);
  Result := CodifCad(usu + ',' + cla + ',' + IntTostr(ord(per)),
                     codigo);
end;

function TregUsuario.GetPerStr: string;
begin
  case per of
  PER_ADMIN: Result := 'Administrador';
  PER_OPER: Result := 'Operador';
  end;
end;
procedure TregUsuario.SetPerStr(AValue: string);
begin
  case Avalue of
  'Administrador': per := PER_ADMIN;
  'Operador': per := PER_OPER;
  else
   per := PER_OPER;  //asume
   msjError := 'Perfil inexistente.';
  end;
end;
procedure TregUsuario.SetCadObj(AValue: string);
//Codifica la información de usuarios
var
  tmp: string;
  codigo: Integer;
  i: Integer;
  cad: String;
  num:Integer;
  a: TStringDynArray;
begin
  If AValue = '' Then exit;
  tmp := AValue;
  //reemplaza
  tmp := StringReplace(tmp, 'V', '89', [rfReplaceAll]);
  tmp := StringReplace(tmp, 'W', '67', [rfReplaceAll]);
  tmp := StringReplace(tmp, 'X', '45', [rfReplaceAll]);
  tmp := StringReplace(tmp, 'Y', '23', [rfReplaceAll]);
  tmp := StringReplace(tmp, 'Z', '00', [rfReplaceAll]);
  //toma código
  codigo := StrToInt(copy(tmp, 7, 3));
  //quita caracteres no válidos
  tmp := copy(tmp, 10, 1000);
  //decodifica cadena
  cad := '';
  For i := 1 To Length(tmp) div 3 do begin
      num := StrToInt(copy(tmp, i*3-2, 3));
      If num < codigo Then begin
          msjError := 'Error en información de clave de usuario';
          exit;
      end;
      cad := cad + Chr(num - codigo);
  end;
  //toma campos
  a := explode(',',cad);
  If high(a) <> 2 Then begin
      msjError := 'Error en información de clave de usuario';
      exit;
  end;
  usu := a[0];
  cla := a[1];
  per := TUsuPerfil(StrToInt(a[2]));
end;

{ TfrmInicio }
procedure TfrmInicio.FormShow(Sender: TObject);
begin
  cancelo:=false;
end;
procedure TfrmInicio.btnCancelarClick(Sender: TObject);
//Cancelar
begin
  cancelo := true;
end;
procedure TfrmInicio.btnAceptarClick(Sender: TObject);
//Aceptar
var
  u: TregUsuario;
begin
  //verifica usuario
  for u in usuarios do begin
    if u.usu = edUsu.Text then begin
      //encontró usuario
      if u.cla = edCla.Text then begin
        //coincode contraseña
        cancelo := false;
        self.Hide;
        //asigan variables globales
        usuario := u.usu;
        clave := u.cla;
        perfil := u.per;
        exit;
      end;
    end;
  end;
  //no encontró usuario
  MsgErr('Usuario o clave inválida.');
end;

initialization
  usuarios:= TregUsuarios.Create(true);

finalization
  usuarios.Destroy;

end.

