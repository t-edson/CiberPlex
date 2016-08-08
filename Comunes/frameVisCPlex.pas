{                                frameVisCplex
Frame, que implementa un editor/visor de objetos gráficos de trabajo de CiberPlex.
La idea es encapsular en este Frame, el complicado motor de edición de objetos en pantalla.

                                              Por Tito Hinostroza  11/03/2014}
unit frameVisCPlex;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, FileUtil, Forms, Controls, ExtCtrls, Graphics,
  GraphType, lclType, dialogs, lclProc, ogDefObjGraf, ObjGraficos,
  CibGFacCabinas, CibFacturables, CPGrupFacturables, ogMotEdicion;
const
  ID_CABINA = 1;  //Cabinas
  ID_GCABINA =2;  //Grupo de cabinas


type
  { TfraVisCPlex }
  TfraVisCPlex = class(TFrame)
  published
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    PaintBox1: TPaintBox;
  private
    FObjBloqueados: boolean;
    procedure ActualizarGruposCabinas(items: TCibGFact_list);
    function AgregGrupCabinas(gcab: TCibGFacCabinas): TogGCabinas;
    procedure SetObjBloqueados(AValue: boolean);
    procedure ActualizarCabinas(items: TCibFac_list);
  public
    motEdi: TModEdicion;  //motor de edición
    property ObjBloqueados: boolean read FObjBloqueados write SetObjBloqueados;
    function AgregCabina(cab: TCibFacCabina): TogCabina;
    function BuscarOgCabina(const nom: string): TogCabina;
    function NumSelecionados: integer;
    function Seleccionado: TObjGraf;
    function CabSeleccionada: TogCabina;
    procedure ActualizarPropiedades(cadProp: string);
    procedure ActualizarEstado(cadEstado: string);
  private
    decod: TCPDecodCadEstado;  //decodificador de cadenas de estado
    grupos: TCPGruposFacturables;   {Esta lista de grupos facturables, será una copia
                                        de la lista que existe en el servidor.}
  public
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  end;

implementation
{$R *.lfm}
procedure TfraVisCPlex.SetObjBloqueados(AValue: boolean);
var
  og :TObjGraf;
begin
  if FObjBloqueados=AValue then Exit;
  for og in motEdi.objetos do begin
    og.PosLocked:=AValue;
  end;
  FObjBloqueados:=AValue;
end;
function TfraVisCPlex.AgregCabina(cab: TCibFacCabina): TogCabina;
//Agrega un objeto de tipo Cabina, al editor
var
  og: TogCabina;
begin
  og := TogCabina.Create(motEdi.v2d, cab);
  motEdi.AgregarObjGrafico(og);
  og.icoPC := Image5.Picture.Graphic;   //asigna imagen
  og.icoPCdes:= Image6.Picture.Graphic;   //asigna imagen
  og.icoUSU := Image2.Picture.Graphic;  //asigna imagen
  og.icoRedAct := Image3.Picture.Graphic;
  og.icoRedDes := Image4.Picture.Graphic;
  og.Id := ID_CABINA;
  og.SizeLocked := true;
  og.PosLocked := FObjBloqueados;  //depende del esatdo actual
  Result := og;
end;
function TfraVisCPlex.AgregGrupCabinas(gcab: TCibGFacCabinas): TogGCabinas;
//Agrega un objeto de tipo Grupo de Cabinas, al editor
var
  og: TogGCabinas;
begin
  og := TogGCabinas.Create(motEdi.v2d, gcab);
  motEdi.AgregarObjGrafico(og);
  og.icoPC := Image5.Picture.Graphic;   //asigna imagen
  og.icoRedAct := Image3.Picture.Graphic;
  og.icoRedDes := Image4.Picture.Graphic;
  og.Id := ID_GCABINA;
  og.SizeLocked := true;
  og.PosLocked := FObjBloqueados;  //depende del esatdo actual
  Result := og;
end;
function TfraVisCPlex.BuscarOgCabina(const nom: string): TogCabina;
{Devuelve la referencia a una cabina. Si no encuentra devuelve NIL}
var
  og: TObjGraf;
  cab : TogCabina;
begin
  for og in motEdi.objetos do begin
    if og.Id = ID_CABINA then begin
      if og.nombre = nom then begin
        cab := TogCabina(og);
        exit(cab);
      end;
    end;
  end;
  exit(nil);
end;
function TfraVisCPlex.NumSelecionados: integer;   //atajo
begin
  Result := motEdi.seleccion.Count;
end;
function TfraVisCPlex.Seleccionado: TObjGraf;  //atajo
begin
  Result := motEdi.Seleccionado;
end;
function TfraVisCPlex.CabSeleccionada: TogCabina;
{Devuelve la cabina seleccionada. Si no hay ninguna, devuelve NIL.}
var
  og: TObjGraf;
begin
  if NumSelecionados>1 then begin
    //MsgExc('Se debe seleccionar solo una cabina.');
    exit(nil);
  end;
  og := Seleccionado;
  if og = nil then exit;
  if not (og is TogCabina) then exit(nil);
  Result := TogCabina(og);
end;
procedure TfraVisCPlex.ActualizarGruposCabinas(items: TCibGFact_list);
{Actualiza la lista de grupos facturables de tipo TCibGFacCabinas. Normalmente solo
habrá un grupo.}
var
  lista: TogGCabinas_list;   //almacenamiento temporal de las referencias a las cabinas
  procedure InicListaCabinas;
  {Llena "lista", con la lista de referencias a cabinas, y limpia su bandera
   "usado". }
  var
    og: TObjGraf;
  begin
    lista.Clear;
    for og in motEdi.objetos do begin
      if og.Id = ID_GCABINA then begin
        TogGCabinas(og).Usado:=false;
        lista.Add(TogGCabinas(og));
      end;
    end;
  end;
  function AgregarSiNoHay(gcab: TCibGFacCabinas): TogGCabinas;
  {Devuelve la referencia a una cabina. Si no existe la crea.
   Debe haberse llenado "lista", previamente}
  var
    c: TogGCabinas;
  begin
    for c in lista do begin
      if c.nombre = gcab.Nombre then begin
        //hay, devuelve la referencia
        Result := c;
        Result.gcab := gcab;   //actualiza la referencia
        exit;
      end;
    end;
    //no hay
    Result := AgregGrupCabinas(gcab);  //crea cabina
  end;
var
  ogGCab: TogGCabinas;
  gfac : TCibGFac;
  cab : TCibGFacCabinas;
begin
  lista := TogGCabinas_list.Create(false);
  InicListaCabinas;   //crea lista y marca "Usado"
  for gfac in items do begin
    cab := TCibGFacCabinas(gfac);
    ogGCab := AgregarSiNoHay(cab);
    ogGCab.CadPropied := cab.CadPropied;  //actualiza propiedades
    ogGCab.Usado:=true;

  end;
  //verifica cabinas no usadas
  for ogGCab in lista do begin
    if Not ogGCab.Usado then
      motEdi.EliminarObjGrafico(ogGCab);
  end;
  motEdi.Refrescar;
  lista.Destroy;
end;
procedure TfraVisCPlex.ActualizarCabinas(items: TCibFac_list);
{Actualiza las propiedades de los objetos y a los objetos mismos, porque aquí se define
que objetos deben existir}
var
  lista: TOgCabina_list;   //almacenamiento temporal de las referencias a las cabinas
  procedure InicListaCabinas;
  {Llena "lista", con la lista de referencias a cabinas, y limpia su bandera
   "usado". }
  var
    og: TObjGraf;
  begin
    lista.Clear;
    for og in motEdi.objetos do begin
      if og.Id = ID_CABINA then begin
        TogCabina(og).Usado:=false;
        lista.Add(TogCabina(og));
      end;
    end;
  end;
  function AgregarSiNoHay(cab: TCibFacCabina): TogCabina;
  {Devuelve la referencia a una cabina. Si no existe la crea.
   Debe haberse llenado "lista", previamente}
  var
    c: TogCabina;
  begin
    for c in lista do begin
      if c.nombre = cab.Nombre then begin
        //hay, devuelve la referencia
        Result := c;
        Result.cab := cab;   //actualiza la referencia
        exit;
      end;
    end;
    //no hay
    Result := AgregCabina(cab);  //crea cabina
  end;
var
  ogCab: TogCabina;
  fac : TCibFac;
  cab : TCibFacCabina;
begin
  lista := TOgCabina_list.Create(false);
  InicListaCabinas;   //crea lista y marca "Usado"
  for fac in items do begin
    cab := TCibFacCabina(fac);
    ogCab := AgregarSiNoHay(cab);
    ogCab.CadPropied := cab.CadPropied;  //actualiza propiedades
    ogCab.Usado:=true;

  end;
  //verifica cabinas no usadas
  for ogCab in lista do begin
    if Not ogCab.Usado then
      motEdi.EliminarObjGrafico(ogCab);
  end;
  motEdi.Refrescar;
  lista.Destroy;
end;

procedure TfraVisCPlex.ActualizarPropiedades(cadProp: string);
{Recibe la cadena de propiedades del "TCPGruposFacturables" del servidor y actualiza
su copia local.}
var
  gruFac: TCibGFac;
begin
  grupos.items.Clear;  {Para empezar a crear los objetos en ModoCopia TRUE}
  grupos.ModoCopia := true;   //para que cree sus objetos sin conexión
  grupos.CadPropiedades := cadProp;  //copia propiedades de todos los grupos
  {Crea o elimina objetos de acuerdo al contenido de "grupos".
  La opción más sencilla sería crear todos de nuevo de acuerdo al estado de "grupos",
  pero se evita este método, para mejorar el rendimiento y para no realizar cambios
  innecesarios en los objetos, que adem´s serían una molestia para la interacción con
  el usuario.}
  for gruFac in grupos.items do begin
    if gruFac.tipo = tgfCabinas then begin
      ActualizarCabinas(gruFac.items);
    end;
  end;
end;
procedure TfraVisCPlex.ActualizarEstado(cadEstado: string);
{Actualiza el estado de los objetos existentes. No se cambian las propiedades ni se
 crean o eliminan objetos. La cadena de estado tiene la forma:
 <0	Cabinas
 cCab1	0	1899:12:30:00:00:00
 cCab2	3	1899:12:30:00:00:00
 ...
 >
 <1      Locutor
 ...
 >
 }
var
  ogCab : TogCabina;
  gruFac: TCibGFac;
  it    : TCibFac;
begin
  if cadEstado='' then exit;
  grupos.CadEstado := cadEstado;
  //Realiza la actualización de los objetos gráficos, sin crear o eliminar
  for gruFac in grupos.items do begin
    if gruFac.tipo = tgfCabinas then begin
      for it in gruFac.items do begin
        ogCab := BuscarOgCabina(it.Nombre);
        if ogCab <> nil then  //puede que no la encuentre
          ogCab.CadEstado := it.CadEstado;  { TODO : Realmente solo se deberái actualizar las referencias, porque ya hay instancias creadas }
      end;
      continue;  //solo actualiza un grupo de cabinas
    end;
  end;
  motEdi.Refrescar;
end;
constructor TfraVisCPlex.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  motEdi := TModEdicion.Create(PaintBox1);
  decod := TCPDecodCadEstado.Create;
  grupos:= TCPGruposFacturables.Create('GrupVis');
end;
destructor TfraVisCPlex.Destroy;
begin
  grupos.Destroy;
  decod.Destroy;
  motEdi.Destroy;
  inherited;
end;

end.

