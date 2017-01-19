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
  CibFacturables, CibGFacCabinas, CibGFacNiloM, CPGrupFacturables, CibTramas,
  ogMotEdicion, MisUtils;
const
  ID_CABINA  = 1;  //Cabinas
  ID_GCABINA = 2;  //Grupo de cabinas
  ID_NILOM   = 4;  //Locutorio
  ID_GNILOM  = 3;  //Grupo NiloM

type
  TEvArrstreFac = procedure(fac: TogFac; X, Y: Integer) of object;
  { TModEdicion2 }
  {Versión personalizada del motro de edición, para agregar características adicionales,
  como el arrastre de boletas.}
  TModEdicion2 = class(TModEdicion)
  public
    ObjBloqueados: boolean;    //bandera de bloqueo de objetos
    OnInicArrastreFac: TEvArrstreFac;  //Se inicia el arrastre en un objeto facturable
  protected
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,  Y: Integer); override;
  end;


  { TfraVisCPlex }
  TfraVisCPlex = class(TFrame)
  published
    Image1: TImage;
    Image10: TImage;
    Image11: TImage;
    Image12: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    PaintBox1: TPaintBox;
    procedure PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
  private
    FObjBloqueados: boolean;
    decod: TCPDecodCadEstado;  //decodificador de cadenas de estado
    arrastEsBol: boolean;  //indica si el objeto arrastrado es una boleta.
    arrastFuente : string;  //Id de objeto facturable arrastrado
    procedure ActualizarOgGrupos(items: TCibGFact_list);
    function AgregarOgGrupo(GFac: TCibGFac): TogGFac;
    function gruposReqCadMoneda(valor: double): string;
    procedure motEdiInicArrastreFac(ogFac: TogFac; X, Y: Integer);
    procedure motEdiObjectsMoved;
    procedure SetObjBloqueados(AValue: boolean);
    procedure ActualizarOgFacturables(grupo: TCibGFac);
  public
    motEdi: TModEdicion2;  //motor de edición
    OnObjectsMoved: procedure of object;  //Los objetos se han movido
    OnSolicEjecAcc : TEvSolicEjecAcc;  //Se solicita ejecutar una acción
    OnReqCadMoneda : TevReqCadMoneda;  //Se requiere convertir a formato de moneda
    grupos: TCibGruposFacturables; {Esta lista de grupos facturables, será una copia
                                    de la lista que existe en el servidor.}
    property ObjBloqueados: boolean read FObjBloqueados write SetObjBloqueados;
    function AgregOgFac(Fac: TCibFac): TogFac;
    function BuscarOgCabina(const nom: string): TogCabina;
    function NumSelecionados: integer;
    function Seleccionado: TObjGraf;
    function FacSeleccionado: TogFac;
    function CabSeleccionada: TogCabina;
    function GCabinasSeleccionado: TogGCabinas;
    function LocSeleccionado: TogNiloM;
    function GNiloMSeleccionado: TogGNiloM;
    procedure ActualizarPropiedades(cadProp: string);
    procedure ActualizarEstado(cadEstado: string);
  public  //Constructor y destructor.
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  end;

implementation
{$R *.lfm}

{ TModEdicion2 }
procedure TModEdicion2.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  s: TObjGraf;
  ogFac: TogFac;
begin
  if Mouse.IsDragging then exit;   //previene la ejecución de este evento
  if OnMouseMove<>nil then OnMouseMove(Sender, Shift, X, Y);
  If Shift = [ssCtrl, ssShift, ssRight] Then  //<Shift>+<Ctrl> + <Botón derecho>
     begin
      EstPuntero := EP_DESP_PANT;
      MoverDesp(x_pulso - X, y_pulso - Y);
      Refrescar;
      Exit;
     End;
  If ParaMover = True Then VerificarParaMover(X, Y);
  If EstPuntero = EP_SELECMULT Then begin  //modo seleccionando multiples formas
      x2Sel := X;
      y2Sel := Y;
      //verifica los que se encuentran seleccionados
      if objetos.Count < 100 Then begin//sólo anima para pocos objetos
          for s In objetos do begin
            if s.SelLocked then continue;
            if enRecSeleccion(s.XCent, s.YCent) And Not s.Selected Then begin
              s.Selec;
            End;
            if Not enRecSeleccion(s.XCent, s.YCent) And s.Selected Then begin
              s.Deselec;
            end;
          end;
      End;
      Refrescar
  end Else If EstPuntero = EP_MOV_OBJS Then begin  //mueve la selección
//        If perfil = PER_OPER Then Exit;  //No permite mover
      if ObjBloqueados then begin
        //Objetos bloqueados -> Modo Vita. Aquí se pueden trasladar boletas
        if (seleccion.Count=1) and (seleccion[0] is TogFac) then begin
          //Solo es válido para un objeto gráfico, de tipo facturable
          ogFac := TogFac(seleccion[0]);   //obtiene objeto
          if OnInicArrastreFac<>nil then OnInicArrastreFac(ogFac, X, Y);
        end;
      end else begin
        //movimiento normal
        Modif := True;
        for s in seleccion do
            s.Mover(x,y, seleccion.Count);
        Refrescar;
      end;
  end Else If EstPuntero = EP_DIMEN_OBJ Then begin
      //se está dimensionando un objeto
      CapturoEvento.Mover(X, Y, seleccion.Count);
      Refrescar;
  end Else
      If CapturoEvento <> NIL Then begin
         CapturoEvento.Mover(X, Y, seleccion.Count);
         Refrescar;
      end Else begin  //Movimiento simple
          s := VerificarMovimientoRaton(X, Y);
          if s <> NIL then s.MouseMove(Sender, Shift, X, Y);  //pasa el evento
      end;
end;
procedure TfraVisCPlex.SetObjBloqueados(AValue: boolean);
var
  og :TObjGraf;
begin
  if FObjBloqueados=AValue then Exit;
  motEdi.ObjBloqueados:=AValue;  //actualiza bandera
  for og in motEdi.objetos do begin
    og.PosLocked:=AValue;
  end;
  FObjBloqueados:=AValue;
end;
function TfraVisCPlex.AgregOgFac(Fac: TCibFac): TogFac;
//Agrega un objeto gráfica asociado a un objeto facturable, al editor.
var
  ogCab: TogCabina;
  ogNil: TogNiloM;
begin
  Result := nil;
  case Fac.tipo of
  ctfCabinas: begin
    ogCab := TogCabina.Create(motEdi.v2d, TCibFacCabina(Fac));
    motEdi.AgregarObjGrafico(ogCab, false);
    ogCab.icoPC := Image5.Picture.Graphic;   //asigna imagen
    ogCab.icoPCdes:= Image6.Picture.Graphic;   //asigna imagen
    ogCab.icoUSU := Image2.Picture.Graphic;  //asigna imagen
    ogCab.icoRedAct := Image3.Picture.Graphic;
    ogCab.icoRedDes := Image4.Picture.Graphic;
    ogCab.Id := ID_CABINA;
    ogCab.SizeLocked := true;
    ogCab.PosLocked := FObjBloqueados;  //depende del esatdo actual
    Result := ogCab;
  end;
  ctfNiloM: begin
    ogNil := TogNiloM.Create(motEdi.v2d, TCibFacLocutor(Fac));
    motEdi.AgregarObjGrafico(ogNil, false);
    ogNil.icoTelCol := Image9.Picture.Graphic;   //asigna imagen
    ogNil.icoTelDes := Image10.Picture.Graphic;
    ogNil.icoTelDes2:= Image11.Picture.Graphic;
    ogNil.Id := ID_NILOM;
    ogNil.SizeLocked := true;
    ogNil.PosLocked := FObjBloqueados;  //depende del esatdo actual
    Result := ogNil;
  end;
  //}
  end;
end;
function TfraVisCPlex.AgregarOgGrupo(GFac: TCibGFac): TogGFac;
{Agrega un objeto de tipo Grupo de Cabinas, al editor}
var
  ogGCabs: TogGCabinas;
  ogGNiloM: TogGNiloM;
begin
  Result := nil;   //valor por defecto
  case GFac.tipo of
  ctfCabinas : begin  //Es grupo de cabinas TCibGFacCabinas
    ogGCabs := TogGCabinas.Create(motEdi.v2d, TCibGFacCabinas(GFac));
    motEdi.AgregarObjGrafico(ogGCabs, false);
    ogGCabs.icono := Image7.Picture.Graphic;   //asigna imagen
    ogGCabs.Id := ID_GCABINA;
    ogGCabs.SizeLocked := true;
    ogGCabs.PosLocked := FObjBloqueados;  //depende del esatdo actual
    Result := ogGCabs;
  end;
  ctfNiloM: begin
    ogGNiloM := TogGNiloM.Create(motEdi.v2d, TCibGFacNiloM(GFac));
    motEdi.AgregarObjGrafico(ogGNiloM, false);
    ogGNiloM.icoConec := Image8.Picture.Graphic;   //asigna imagen
    ogGNiloM.icoDesc  := Image12.Picture.Graphic;
    ogGNiloM.Id := ID_GNILOM;
    ogGNiloM.SizeLocked := true;
    ogGNiloM.PosLocked := FObjBloqueados;  //depende del esatdo actual
    Result := ogGNiloM;
  end;
  end;
end;
function TfraVisCPlex.gruposReqCadMoneda(valor: double): string;
begin
  if OnReqCadMoneda = nil then exit('');
  Result := OnReqCadMoneda(valor);   //pasa el evento
end;
procedure TfraVisCPlex.motEdiInicArrastreFac(ogFac: TogFac; X, Y: Integer);
{Se inicia el arrastre de un objeto gráfico facturable.}
begin
  //Aquí se puede inciar el arrastre del objeto o su boleta
  if ogFac.Boleta.LoSelec(X,Y) and (ogFac.Fac.Boleta.ItemCount>0)  then begin
    //Selecciona una boleta y está visible
    arrastEsBol:= true;  //Indica que el objeto, a arrastrar, es una boleta.
    arrastFuente := ogFac.Fac.IdFac;   //
    PaintBox1.BeginDrag(true);
  end else if ogFac.LoSelecciona(X,Y) then begin
    //Selecciona al facturable
    if  ogFac is TogCabina then begin  //Es cabina
      arrastEsBol:= false;  //Indica que el objeto, a arrastrar, es una boleta.
      arrastFuente := ogFac.Fac.IdFac;   //
      PaintBox1.BeginDrag(true);
    end;
  end;
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
function TfraVisCPlex.FacSeleccionado: TogFac;
{Devuelve el ogFac seleccionado. Si no hay ninguna, devuelve NIL.}
var
  og: TObjGraf;
begin
  if NumSelecionados>1 then begin
    //MsgExc('Se debe seleccionar solo una cabina.');
    exit(nil);
  end;
  og := Seleccionado;
  if og = nil then exit(nil);
  if not (og is TogFac) then exit(nil);
  Result := TogFac(og);
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
function TfraVisCPlex.GCabinasSeleccionado: TogGCabinas;
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
function TfraVisCPlex.LocSeleccionado: TogNiloM;
{Devuelve el locutorio seleccionado. Si no hay ninguno, devuelve NIL.}
var
  og: TObjGraf;
begin
  if NumSelecionados>1 then begin
    //MsgExc('Se debe seleccionar solo un locutorio.');
    exit(nil);
  end;
  og := Seleccionado;
  if og = nil then exit(nil);
  if not (og is TogNiloM) then exit(nil);
  Result := TogNiloM(og);
end;

function TfraVisCPlex.GNiloMSeleccionado: TogGNiloM;
var
  og: TObjGraf;
begin
  if NumSelecionados>1 then begin
    //MsgExc('Se debe seleccionar solo una cabina.');
    exit(nil);
  end;
  og := Seleccionado;
  if og = nil then exit(nil);
  if og is TogGNiloM then begin
    //Grupo seleccionado directamente
    Result := TogGNiloM(og);
  end else begin
    //Otro obejto seleccionado
    exit(nil);
  end;
end;
procedure TfraVisCPlex.ActualizarOgFacturables(grupo: TCibGFac);
{Actualiza las propiedades de los objetos y a los objetos mismos, porque aquí se define
que objetos deben existir}
  function AgregarSiNoHay(fac: TCibFac): TogFac;
  {Devuelve la referencia a un objeto gráfico facturable, del motor de edición, que tenga
   el nombre del facturable indicado y que pertenezca al mismo grupo. Si no existe el
   objeto, lo crea y devuelve la referencia. }
  var
    og: TObjGraf;
    ogFac: TogFac;
  begin
//debugln('>Buscando:' + fac.Nombre);
    for og in Motedi.objetos do if og.Tipo = OBJ_FACT then begin
      ogFac := TogFac(og);  //restaura tipo
      if (ogFac.NomGrupo = fac.Grupo.Nombre) and (ogFac.Nombre = fac.Nombre) then begin
        //hay, devuelve la referencia
        Result := ogFac;  //restaura tipo
        Result.Fac := fac;   //actualiza la referencia
        exit;
      end;
    end;
    //no hay
//debugln('>Agregando.');
    Result := AgregOgFac(fac);  //crea cabina
  end;
var
  ogFac: TogFac;
  fac : TCibFac;
begin
  for fac in grupo.items do begin
    ogFac := AgregarSiNoHay(fac);
    if ogFac<>nil then begin
      ogFac.Data:='';  //Para que no se elimine.
    end;
  end;
end;
procedure TfraVisCPlex.PaintBox1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  og: TObjGraf;
begin
  //Busca para ver si pasa por alguna boleta
  for og in motEdi.objetos do begin
    if og.LoSelecciona(X,Y) and (og is TogFac) then begin
      //Pasa por un objeto facturable
      if arrastEsBol then begin
        //Se arrastra una boleta
        Accept := TogFac(og).Boleta.LoSelec(X,Y);
      end else begin
        //Se arrastra un Facturable Cabina
//        Accept := true;
        Accept := (og is TogCabina) and  not TogFac(og).Boleta.LoSelec(X,Y);
      end;
      exit;
    end;
  end;
  //No lo selecciona
  Accept := false;
end;
procedure TfraVisCPlex.PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer
  );
var
  og: TObjGraf;
  ogFac: TogFac;
begin
  for og in motEdi.objetos do begin
    if og.LoSelecciona(X,Y) and (og is TogFac) then begin
      ogFac := TogFac(og);
      //Verifica si no se ha soltado en el mismo objeto
      if arrastFuente = ogFac.Fac.IdFac then begin
//        MsgBox('Soltado sobre el mismo.');
        exit;
      end;
      //Se soltó sobre un objeto facturable
      if arrastEsBol then begin
        //Se soltó una boleta
        if TogFac(og).Boleta.LoSelec(X,Y) then begin
          //Se ha soltado sobre una boleta
          if OnSolicEjecAcc<>nil then begin
            if MsgYesNo('¿Trasladar boleta de cabina ' + arrastFuente + ' a ' +
                         ogFac.Fac.IdFac + '?') <> 1 then exit;
             OnSolicEjecAcc(C_ACC_BOLET, ACCBOL_TRA, 0, arrastFuente + #9 + ogFac.Fac.IdFac);
          end;
        end;
      end else begin
        //Se soltó un Facturable Cabina
        if (og is TogCabina) and  not TogFac(og).Boleta.LoSelec(X,Y) then begin
          if MsgYesNo('¿Trasladar cabina: ' + arrastFuente + ' a ' +
                       ogFac.Fac.IdFac + '?') <> 1 then exit;
          //Se traslada la cabina
          OnSolicEjecAcc(C_ACC_CABIN, C_TRA_CABIN, 0, arrastFuente + #9 + ogFac.Fac.IdFac);
        end;
      end;
      exit;
    end;
  end;
end;

procedure TfraVisCPlex.ActualizarOgGrupos(items: TCibGFact_list);
{Actualiza la lista de grupos facturables de tipo TCibGFacCabinas. Normalmente solo
habrá un grupo.}
  function AgregarSiNoHay(gfac: TCibGFac): TogGFac;
  {Devuelve la referencia a una cabina. Si no existe la crea.
   Debe haberse llenado "lista", previamente}
  var
    og: TObjGraf;
    ogGFac: TogGFac;
  begin
    for og in Motedi.objetos do if og.Tipo = OBJ_GRUP then begin
      ogGFac := TogGFac(og);  //restaura tipo
      if ogGFac.nombre = gfac.Nombre then begin
        //Hay. Porque no debería haber grupos con el mismo nombre.
        Result := ogGFac;    //devuelve la referencia
        Result.gfac := gfac;   //actualiza la referencia
        exit;
      end;
    end;
    //no hay
    Result := AgregarOgGrupo(gfac);  //crea grupo ogGFac
  end;
var
  ogGFac: TogGFac;
  GFac : TCibGFac;
begin
  for GFac in items do begin
    ogGFac := AgregarSiNoHay(GFac);
    if ogGFac<>nil then begin
      ogGFac.Data:='';  //Para que no se elimine.
    end;
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
  grupos.CadPropiedades := cadProp;  //copia propiedades de todos los grupos
  {Crea o elimina objetos gráficos (que representan a objetos TCibGFac) de acuerdo al
  contenido de "grupos".}
  for og in motEdi.objetos do og.Data:='x';  //marca todos para eliminación
  ActualizarOgGrupos(grupos.items);  //Actualiza los objetos TogGFac
  {Crea o elimina objetos gráficos (que representan a objetos TCibFac) de acuerdo al
  contenido de "grupos".
  La opción más sencilla sería crear todos de nuevo de acuerdo al estado de "grupos",
  pero se evita este método, para mejorar el rendimiento y para no realizar cambios
  innecesarios en los objetos, que además serían una molestia para la interacción con
  el usuario.}
  for gruFac in grupos.items do begin
//    if gruFac.tipo = ctfCabinas then begin
      ActualizarOgFacturables(gruFac);
//    end;
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
begin
  if cadEstado='' then exit;
  grupos.CadEstado := cadEstado;  //solo cambia las variables de estado de "grupos"
  //Los objetos gráficos "verán" los cambios, porque tienen referencias a sus objetos fuente
  motEdi.Refrescar;
end;
procedure TfraVisCPlex.motEdiObjectsMoved;
//Se ha producido el movimiento de uno o más objetos
begin
  if FObjBloqueados then exit;   //se supone que no se pueden mover en este estado
  if OnObjectsMoved<>nil then OnObjectsMoved;
end;
constructor TfraVisCPlex.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  motEdi := TModEdicion2.Create(PaintBox1);
  motEdi.OnObjectsMoved:=@motEdiObjectsMoved;
  motEdi.OnInicArrastreFac:=@motEdiInicArrastreFac;
  decod := TCPDecodCadEstado.Create;
  grupos:= TCibGruposFacturables.Create('GrupVis', true);  //Crea en modo copia
  grupos.OnReqCadMoneda:=@gruposReqCadMoneda;
   //Para el evento
end;
destructor TfraVisCPlex.Destroy;
begin
  grupos.Destroy;
  decod.Destroy;
  motEdi.Destroy;
  inherited;
end;

end.

