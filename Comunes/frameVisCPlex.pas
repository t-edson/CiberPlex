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
    Image7: TImage;
    PaintBox1: TPaintBox;
  private
    FObjBloqueados: boolean;
    procedure ActualizarGruposCabinas(items: TCibGFact_list);
    function AgregGrupCabinas(gcab: TCibGFacCabinas): TogGCabinas;
    procedure motEdiObjectsMoved;
    procedure SetObjBloqueados(AValue: boolean);
    procedure ActualizarCabinas(grupo: TCibGFac);
  public
    motEdi: TModEdicion;  //motor de edición
    OnObjectsMoved: procedure of object;
    property ObjBloqueados: boolean read FObjBloqueados write SetObjBloqueados;
    function AgregCabina(cab: TCibFacCabina): TogCabina;
    function BuscarOgCabina(const nom: string): TogCabina;
    function NumSelecionados: integer;
    function Seleccionado: TObjGraf;
    function CabSeleccionada: TogCabina;
    function GCabSeleccionada: TogGCabinas;
    procedure ActualizarPropiedades(cadProp: string);
    procedure ActualizarEstado(cadEstado: string);
  private
    decod: TCPDecodCadEstado;  //decodificador de cadenas de estado
    grupos: TCibGruposFacturables;   {Esta lista de grupos facturables, será una copia
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
  og.icono := Image7.Picture.Graphic;   //asigna imagen
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
  if og = nil then exit(nil);
  if not (og is TogCabina) then exit(nil);
  Result := TogCabina(og);
end;
function TfraVisCPlex.GCabSeleccionada: TogGCabinas;
var
  og: TObjGraf;
begin
  if NumSelecionados>1 then begin
    //MsgExc('Se debe seleccionar solo una cabina.');
    exit(nil);
  end;
  og := Seleccionado;
  if og = nil then exit(nil);
  if og is TogGCabinas then begin
    //Grupo seleccionado directamente
    Result := TogGCabinas(og);
  end else begin
    //Otro obejto seleccionado
    exit(nil);
  end;
end;

procedure TfraVisCPlex.ActualizarCabinas(grupo: TCibGFac);
{Actualiza las propiedades de los objetos y a los objetos mismos, porque aquí se define
que objetos deben existir}
  function AgregarSiNoHay(cab: TCibFacCabina): TogCabina;
  {Devuelve la referencia a un objeto gráfico TogCabina, del motor de edición, que tenga
   el nombre de la cabina indicada. Si no existe el objeto, lo crea y devuelve la
   referencia. }
  var
    og: TObjGraf;
    ogFac: TogFac;
  begin
debugln('>Buscando:' + cab.Nombre);
    for og in Motedi.objetos do if og.Tipo = OBJ_FACT then begin
      ogFac := TogFac(og);  //restaura tipo
      if (ogFac.NomGrupo = cab.Grupo.Nombre) and (ogFac.Nombre = cab.Nombre) then begin
        //hay, devuelve la referencia
        Result := TogCabina(ogFac);  //restaura tipo
        Result.fac := cab;   //actualiza la referencia
        exit;
      end;
    end;
    //no hay
debugln('>Agregando.');
    Result := AgregCabina(cab);  //crea cabina
  end;
var
  ogCab: TogCabina;
  fac : TCibFac;
  cab : TCibFacCabina;
begin
  for fac in grupo.items do begin
    cab := TCibFacCabina(fac);
    ogCab := AgregarSiNoHay(cab);
    ogCab.CadPropied := cab.CadPropied;  //actualiza propiedades
    ogCab.Data:='';  //Para que no se elimine.
  end;
end;
procedure TfraVisCPlex.ActualizarGruposCabinas(items: TCibGFact_list);
{Actualiza la lista de grupos facturables de tipo TCibGFacCabinas. Normalmente solo
habrá un grupo.}
  function AgregarSiNoHay(gcab: TCibGFacCabinas): TogGCabinas;
  {Devuelve la referencia a una cabina. Si no existe la crea.
   Debe haberse llenado "lista", previamente}
  var
    og: TObjGraf;
    ogGFac: TogGFac;
  begin
    for og in Motedi.objetos do if og.Tipo = OBJ_GRUP then begin
      ogGFac := TogGFac(og);  //restaura tipo
      if ogGFac.nombre = gcab.Nombre then begin
        //hay, devuelve la referencia
        Result := TogGCabinas(ogGFac);
        Result.gfac := gcab;   //actualiza la referencia
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
  for gfac in items do begin
    cab := TCibGFacCabinas(gfac);
    ogGCab := AgregarSiNoHay(cab);
    ogGCab.CadPropied := cab.CadPropied;  //actualiza propiedades
    ogGCab.Data:='';  //Para que no se elimine.
  end;
end;

procedure TfraVisCPlex.ActualizarPropiedades(cadProp: string);
{Recibe la cadena de propiedades del "TCibGruposFacturables" del servidor y actualiza
su copia local.}
var
  og : TObjGraf;
  gruFac: TCibGFac;
begin
  //Actualiza el contenido del TCibGruposFacturables local
  grupos.items.Clear;  {Para empezar a crear los objetos en ModoCopia TRUE}
  grupos.ModoCopia := true;   //para que cree sus objetos sin conexión
  grupos.CadPropiedades := cadProp;  //copia propiedades de todos los grupos
  {Crea o elimina objetos gráficos (que representan a objetos TCibGFac) de acuerdo al
  contenido de "grupos".}
  for og in motEdi.objetos do og.Data:='x';  //marca todos para eliminación
  ActualizarGruposCabinas(grupos.items);
  {Crea o elimina objetos gráficos (que representan a objetos TCibFac) de acuerdo al
  contenido de "grupos".
  La opción más sencilla sería crear todos de nuevo de acuerdo al estado de "grupos",
  pero se evita este método, para mejorar el rendimiento y para no realizar cambios
  innecesarios en los objetos, que adem´s serían una molestia para la interacción con
  el usuario.}
  for gruFac in grupos.items do begin
    if gruFac.tipo = tgfCabinas then begin
      ActualizarCabinas(gruFac);
    end;
  end;
  //Verifica objetos no usados (no actualizados), para eliminarlos
  for og in motEdi.objetos do begin
    if og.Data = 'x' then begin
debugln('>Eliminando: ' + og.Nombre);
      motEdi.EliminarObjGrafico(og);
    end;
  end;
  motEdi.Refrescar;
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
procedure TfraVisCPlex.motEdiObjectsMoved;
//Se ha producido el movimiento de uno o más objetos
begin
  if OnObjectsMoved<>nil then OnObjectsMoved;
end;
constructor TfraVisCPlex.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  motEdi := TModEdicion.Create(PaintBox1);
  motEdi.OnObjectsMoved:=@motEdiObjectsMoved;
  decod := TCPDecodCadEstado.Create;
  grupos:= TCibGruposFacturables.Create('GrupVis');
end;
destructor TfraVisCPlex.Destroy;
begin
  grupos.Destroy;
  decod.Destroy;
  motEdi.Destroy;
  inherited;
end;

end.

