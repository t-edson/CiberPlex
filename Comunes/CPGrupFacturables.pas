{Unidad para definir al objeto TCPGruposFacturables.
Se define como una unidad separada de CPFacturables, porque se necesita incluir a las
unidades que dependen de CPFacturables, y se crearía una dependencia circular. }
unit CPGrupFacturables;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, LCLProc, CPFacturables,
  //Aquí se incluyen las unidades que definen clases descendientes de TCPFacturables
  CPGrupoCabinas, CPNiloM, MisUtils;
type
  { TCPGruposFacturables }
  {Objeto que engloba a todos los grupos facturables. Debe haber solo una instancia para
   toda la aplicación, así que trabaja ccomo un SINGLETON.}
  TCPGruposFacturables = class
  private
    FModoCopia: boolean;
    function GetCadEstado: string;
    function GetCadPropiedades: string;
    procedure SetCadEstado(const AValue: string);
    procedure SetCadPropiedades(AValue: string);
    procedure SetModoCopia(AValue: boolean);
  public
    nombre: string;      //Es un identificador del grupo. Es útil solo para depuración.
    items: TCPGrupoFacturable_list;  //lista de grupos facturables
    property ModoCopia: boolean  {Indica si se quiere manejar al objeto sin conexión (como en un visor),
                                  debería hacerse antes de que se agreguen objetos a "items"}
             read FModoCopia write SetModoCopia;
    property CadPropiedades: string read GetCadPropiedades write SetCadPropiedades;
    property CadEstado: string read GetCadEstado write SetCadEstado;
    function ExtraerEstado(lisEstado: TStringList; var estado, nomGrup: string;
      var tipo: TCPTipGrupoFactur): boolean;
    function NumGrupos: integer;
    function BuscarPorNombre(nomb: string): TCPGrupoFacturable;
  public  //constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;

implementation

{ TCPGruposFacturables }
function TCPGruposFacturables.GetCadPropiedades: string;
var
  gf : TCPGrupoFacturable;
  tmp: String;
begin
  tmp := '' + LineEnding;  //la primera línea contiene propiedades del grupo.
  for gf in items do begin
    tmp := tmp + '[[' + IntToStr(ord(gf.tipo)) + LineEnding +
                 gf.CadPropied + LineEnding +
                 ']]' + LineEnding;
  end;
  Result := tmp;
end;
procedure TCPGruposFacturables.SetCadPropiedades(AValue: string);
var
  lin, tmp: string;
  lineas: TStringList;
  tipGru: LongInt;
  grupCab: TCPGrupoCabinas;
begin
  if trim(AValue) = '' then exit;
  lineas := TStringList.Create;
  lineas.Text:=AValue;  //divide en líneas

  items.Clear;  //elimina todos para crearlos de nuevo
  lin := lineas[0];  //toma primera línea
  //
  lineas.Delete(0);   //elimina primera línea
  for lin in lineas do begin
    if copy(lin,1,2) = '[[' then begin
      tipGru := StrToInt(copy(lin, 3, length(lin)));
      tmp:='';  //inicia acumulación
    end else if lin = ']]' then begin
      //marca de fin, termina acumulación
      case TCPTipGrupoFactur(tipGru) of
      tgfCabinas: begin
        grupCab := TCPGrupoCabinas.Create('');  //crea la instancia
debugln('');
debugln('Asignando propiedades a grupCab en :' + nombre);
        grupCab.ModoCopia := FModoCopia;   //fija modo de creación, antes de crear objetos
        grupCab.CadPropied:=tmp;    //asigna propiedades
debugln('Después de asignar propiedades:');
grupCab.MuestraConexionCabina;
        items.Add(grupCab);         //agrega a la lista
      end;
      tgfLocutNilo: begin

      end;
      end;
    end else begin
      tmp := tmp + lin + LineEnding;
    end;
  end;
  lineas.Destroy;
end;

procedure TCPGruposFacturables.SetModoCopia(AValue: boolean);
var
  gf : TCPGrupoFacturable;
begin
//  if FModoCopia=AValue then Exit;
  FModoCopia:=AValue;   //Fija modo
  for gf in items do begin   {Transfiere a todos los posibles objetos creados, aunque lo
                           normal sería que se asigne el modo, cuando no hay ítems}
    gf.ModoCopia:= AValue
  end;
end;
function TCPGruposFacturables.GetCadEstado: string;
var
  gf : TCPGrupoFacturable;
  primero: Boolean;
begin
  Result := '';
  primero := true;  //bandera para evitar poner el salto final
  {Simplemente junta las cadenas de estado de los grupos, sin delimitador porque tienen
  el formato adecuado para poder separarlas.}
  for gf in items do begin
    if primero then begin
      Result := gf.CadEstado;
      primero := false;
    end else begin
      Result := Result + LineEnding + gf.CadEstado;
    end;
  end;
end;
procedure TCPGruposFacturables.SetCadEstado(const AValue: string);
var
  lest: TStringList;
  res: Boolean;
  cad, nombGrup: string;
  tipo: TCPTipGrupoFactur;
  gf: TCPGrupoFacturable;
begin
  lest:= TStringList.Create;
  lest.Text := AValue;  //carga texto
  //Extrae los fragmentos correspondientes a cada Grupo facturable
  while lest.Count>0 do begin
    res := ExtraerEstado(lest, cad, nombGrup, tipo);
    if not res then break;  //se mostró mensaje de error
    gf := BuscarPorNombre(nombGrup);
    if gf = nil then begin
      //Llegó el estado de un grupo que no existe.
      debugln('Grupo no existente.');   //WARNING
      break;
    end;
    gf.CadEstado := cad;   //No importa de que tipo sea-
  end;
  //carga el cobtendio del archivo de estado
  lest.Destroy;
end;
function TCPGruposFacturables.ExtraerEstado(lisEstado: TStringList;
  var estado, nomGrup: string; var tipo: TCPTipGrupoFactur): boolean;
{Extrae de la cadena de estado de la aplicación (guardada en lisEstado), el fragmento
que corresponde al estado de un grupo facturable. El estado se devuelve en "estado"
Normalmente lisEstado , tendrá la forma:
<0	Cabinas
cCab1	0	1899:12:30:00:00:00
cCab2	3	1899:12:30:00:00:00
...
>
<1      Locutor
...
>

Las líneas extraidas, serán eliminadas de la lista. Si encuentra error, muestra el
mensaje y devuelve FALSE.
}
var
  a: TStringDynArray;
  lin0: String;
begin
  estado := '';
  if lisEstado.Count=0 then exit;   //está vacía
  lin0 := lisEstado[0];
  if (lin0='') or (lin0[1]<>'<') then begin
    MsgErr('Error en cadena de estado. Se esperaba "<".');
    exit(false);   //Sale con error
  end;
  while (lisEstado.Count>0) and (lisEstado[0]<>'>') do begin
    if estado='' then begin
      //Es la primera línea a agregar. Aprovechamos para capturar tipo y nomGrup de grupo
      a := Explode(#9, lisEstado[0]);
      delete(a[0], 1, 1);  //quita "<"
      tipo := TCPTipGrupoFactur(f2I(a[0]));
      nomGrup := a[1];
    end;
    estado := estado + lisEstado[0] + LineEnding;  //acumula
    lisEstado.Delete(0);  //elimina
  end;
  if (lisEstado.Count=0) then begin
    MsgErr('Error en cadena de estado. Se esperaba ">".');
    estado := '';
    exit(false);   //Sale con error
  end else begin
    //Lo esperado. Hay al menos una línea más.
    estado := estado + '>';  //acumula
    lisEstado.Delete(0);  //elimina la fila '>'
    exit(true);    //Sale sin error
  end;
end;
function TCPGruposFacturables.NumGrupos: integer;
begin
  Result := items.Count;
end;
function TCPGruposFacturables.BuscarPorNombre(nomb: string): TCPGrupoFacturable;
{Busca a uno de los grupos de facturables, por su nombre. Si no encuentra, devuelve NIL}
var
  gf : TCPGrupoFacturable;
begin
  for gf in items do begin
    if gf.Nombre = nomb then exit(gf);
  end;
  //no encontró
  exit(nil);
end;
//constructor y destructor
constructor TCPGruposFacturables.Create(nombre0: string);
begin
  nombre := nombre0;
  items := TCPGrupoFacturable_list.Create(true);
end;
destructor TCPGruposFacturables.Destroy;
begin
  items.Destroy;
  inherited Destroy;
end;

end.

