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
  CibFacturables, CibGFacCabinas, CibGFacNiloM, CibModelo, CibTramas,
  CibGFacMesas, ogMotEdicion, MisUtils;
type
  TEvMouseFac = procedure(ogFac: TogFac; X, Y: Integer) of object;
  TEvMouseGFac = procedure(ogGFac: TogGFac; X, Y: Integer) of object;
  { TEditionMot2 }
  {Versión personalizada del motor de edición, para agregar características adicionales,
  como el arrastre de boletas.}
  TEditionMot2 = class(TEditionMot)
  public
    ObjBloqueados: boolean;    //bandera de bloqueo de objetos
    OnInicArrastreFac: TEvMouseFac;  //Se inicia el arrastre en un objeto facturable
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
    Image13: TImage;
    Image14: TImage;
    Image15: TImage;
    Image16: TImage;
    Image17: TImage;
    Image18: TImage;
    Image19: TImage;
    Image2: TImage;
    Image20: TImage;
    Image21: TImage;
    Image22: TImage;
    Image23: TImage;
    Image24: TImage;
    Image25: TImage;
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
    FModDiseno: boolean;
    decod: TCPDecodCadEstado;  //decodificador de cadenas de estado
    arrastEsBol: boolean;  //indica si el objeto arrastrado es una boleta.
    facArrastrado : TCibFac;  //Objeto facturable arrastrado
    procedure ActualizarOgGrupos(items: TCibGFact_list);
    function AgregarOgGrupo(GFac: TCibGFac): TogGFac;
    function gruposReqCadMoneda(valor: double): string;
    procedure gruposSolicEjecCom(comando: TCPTipCom; ParamX, ParamY: word;
      cad: string);
    procedure motEdi_MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure motEdi_ClickDer(Shift: TShiftState; x, y: integer);
    procedure motEdi_DblClick(Sender: TObject);
    procedure motEdi_InicArrastreFac(ogFac: TogFac; X, Y: Integer);
    procedure motEdi_ObjectsMoved;
    procedure SetModDiseno(AValue: boolean);
    procedure ActualizarOgFacturables(grupo: TCibGFac);
  public
    motEdi          : TEditionMot2;  //motor de edición
    OnObjectsMoved  : procedure of object;  //Los objetos se han movido
    OnSolicEjecCom  : TEvSolicEjecCom;  //Se solicita ejecutar una acción
    OnReqCadMoneda  : TevReqCadMoneda;  //Se requiere convertir a formato de moneda
    //OnMouseUp: TMouseEvent;          //se us el que está definido en el frame
    OnClickDer      : TEvMouse;      //Click derecho en el visor
    OnClickDerFac   : TEvMouseFac;      //Click derecho en un facturable del visor
    OnClickDerGFac  : TEvMouseGFac;     //Click derecho en un grupo del visor
    OnDobleClick    : TNotifyEvent;     //Doble click en el visor
    OnDobleClickFac : TEvMouseFac;      //Doble click en un facturable del visor
    OnDobleClickGFac: TEvMouseGFac;      //Doble click en un grupo del visor
    grupos: TCibModelo; {Esta lista de grupos facturables, será una copia
                                    de la lista que existe en el servidor.}
    function CoordPantallaDeFact(ogFac: TogFac): TPoint;
    function CoordPantallaDeFact2(ogFac: TogFac): TPoint;
    property ModDiseno: boolean read FModDiseno write SetModDiseno;
    function AgregOgFac(Fac: TCibFac): TogFac;
    function NumSelecionados: integer;
    function Seleccionado: TObjGraf;
    function SeleccionarGru(NomGFac: string): boolean;
    function SeleccionarFac(IdOgFac: string): boolean;
    function FacSeleccionado: TogFac;
    function GFacSeleccionado: TogGFac;
    function CabSeleccionada: TogCabina;
    function GCabinasSeleccionado: TogGCabinas;
    procedure ActualizarPropiedades(cadProp: string);
    procedure ActualizarEstado(cadEstado: string);
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
    procedure AlinearSelecHor;   //Alinea la selección
    procedure AlinearSelecVer;   //Alinea la selección
    procedure EspacirSelecHor;   //Espaciar la selección
    procedure EspacirSelecVer;   //Espaciar la selección
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public  //Constructor y destructor.
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  end;

implementation
{$R *.lfm}

{ TEditionMot2 }
procedure TEditionMot2.MouseMove(Sender: TObject; Shift: TShiftState; X,
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
      ScrollDesp(x_pulso - X, y_pulso - Y);
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
      Refrescar;
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
            s.MouseMove(x,y, seleccion.Count);
        Refrescar;
      end;
  end Else If EstPuntero = EP_DIMEN_OBJ Then begin
      //se está dimensionando un objeto
      CapturoEvento.MouseMove(X, Y, seleccion.Count);
      Refrescar;
  end Else
      If CapturoEvento <> NIL Then begin
         CapturoEvento.MouseMove(X, Y, seleccion.Count);
         Refrescar;
      end Else begin  //Movimiento simple
          s := VerifyMouseMove(X, Y);
          if s <> NIL then s.MouseOver(Sender, Shift, X, Y);  //pasa el evento
      end;
end;
procedure TfraVisCPlex.SetModDiseno(AValue: boolean);
var
  og :TObjGraf;
begin
  motEdi.ObjBloqueados:= not AValue;  //actualiza bandera
  for og in motEdi.objetos do begin
    og.PosLocked:=not AValue;
  end;
  FModDiseno:=AValue;
end;
function TfraVisCPlex.AgregOgFac(Fac: TCibFac): TogFac;
//Agrega un objeto gráfica asociado a un objeto facturable, al editor.
var
  ogCab: TogCabina;
  ogNil: TogNiloM;
  ogCli: TogCliente;
  ogMes: TogMesa;
begin
  Result := nil;
  case Fac.tipo of
  ctfClientes: begin
    ogCli := TogCliente.Create(motEdi.v2d, Fac);
    motEdi.AddGraphObject(ogCli, false);
    ogCli.icono := Image14.Picture.Graphic;   //asigna imagen
    ogCli.SizeLocked := true;
    ogCli.PosLocked := not FModDiseno;  //depende del estado actual
    Result := ogCli;
  end;
  ctfCabinas: begin
    ogCab := TogCabina.Create(motEdi.v2d, Fac);
    motEdi.AddGraphObject(ogCab, false);
    ogCab.icoPC    := Image5.Picture.Graphic;   //asigna imagen
    ogCab.icoPCdes := Image6.Picture.Graphic;   //asigna imagen
    ogCab.icoUSU   := Image2.Picture.Graphic;  //asigna imagen
    ogCab.icoComent := Image25.Picture.Graphic;
    ogCab.icoRedAct := Image3.Picture.Graphic;
    ogCab.icoRedDes := Image4.Picture.Graphic;
    ogCab.SizeLocked := true;
    ogCab.PosLocked := not FModDiseno;  //depende del estado actual
    Result := ogCab;
  end;
  ctfNiloM: begin
    ogNil := TogNiloM.Create(motEdi.v2d, Fac);
    motEdi.AddGraphObject(ogNil, false);
    ogNil.icoTelCol := Image9.Picture.Graphic;   //asigna imagen
    ogNil.icoTelDes := Image10.Picture.Graphic;
    ogNil.icoTelDes2:= Image11.Picture.Graphic;
    ogNil.SizeLocked := true;
    ogNil.PosLocked := not FModDiseno;  //depende del estado actual
    Result := ogNil;
  end;
  ctfMesas: begin
    ogMes := TogMesa.Create(motEdi.v2d, Fac);
    motEdi.AddGraphObject(ogMes, false);
    ogMes.icoMesaSim := Image17.Picture.Graphic;   //asigna imagen
    ogMes.icoMesaDob1:= Image18.Picture.Graphic;   //asigna imagen
    ogMes.icoMesaDob2:= Image19.Picture.Graphic;   //asigna imagen
    ogMes.icoMesaDob3:= Image24.Picture.Graphic;   //asigna imagen;
    ogMes.icoSilla1 := Image20.Picture.Graphic;
    ogMes.icoSilla2 := Image21.Picture.Graphic;
    ogMes.icoSilla3 := Image22.Picture.Graphic;
    ogMes.icoSilla4 := Image23.Picture.Graphic;
    ogMes.SizeLocked := true;
    ogMes.PosLocked := not FModDiseno;  //depende del estado actual
    Result := ogMes;
  end;
  end;
end;
function TfraVisCPlex.AgregarOgGrupo(GFac: TCibGFac): TogGFac;
{Agrega un objeto de tipo Grupo de Cabinas, al editor}
var
  ogGClies: TogGClientes;
  ogGCabs : TogGCabinas;
  ogGNiloM: TogGNiloM;
  ogGMes: TogGMesas;
begin
  Result := nil;   //valor por defecto
  case GFac.tipo of
  ctfClientes: begin
    ogGClies := TogGClientes.Create(motEdi.v2d, TCibGFacCabinas(GFac));
    motEdi.AddGraphObject(ogGClies, false);
    ogGClies.icono := Image13.Picture.Graphic;   //asigna imagen
    ogGClies.SizeLocked := true;
    ogGClies.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGClies;
  end;
  ctfCabinas : begin  //Es grupo de cabinas TCibGFacCabinas
    ogGCabs := TogGCabinas.Create(motEdi.v2d, TCibGFacCabinas(GFac));
    motEdi.AddGraphObject(ogGCabs, false);
    ogGCabs.icono := Image7.Picture.Graphic;   //asigna imagen
    ogGCabs.SizeLocked := true;
    ogGCabs.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGCabs;
  end;
  ctfNiloM: begin
    ogGNiloM := TogGNiloM.Create(motEdi.v2d, TCibGFacNiloM(GFac));
    motEdi.AddGraphObject(ogGNiloM, false);
    ogGNiloM.icoConec := Image8.Picture.Graphic;   //asigna imagen
    ogGNiloM.icoDesc  := Image12.Picture.Graphic;
    ogGNiloM.SizeLocked := true;
    ogGNiloM.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGNiloM;
  end;
  ctfMesas: begin
    ogGMes := TogGMesas.Create(motEdi.v2d, TCibGFacCabinas(GFac));
    motEdi.AddGraphObject(ogGMes, false);
    ogGMes.icono := Image16.Picture.Graphic;   //asigna imagen
    ogGMes.SizeLocked := true;
    ogGMes.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGMes;
  end;
  end;
end;
function TfraVisCPlex.gruposReqCadMoneda(valor: double): string;
begin
  if OnReqCadMoneda = nil then exit('');
  Result := OnReqCadMoneda(valor);   //pasa el evento
end;
procedure TfraVisCPlex.gruposSolicEjecCom(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
begin
  if OnSolicEjecCom<>nil then OnSolicEjecCom(comando, ParamX, ParamY, cad);
end;
function TfraVisCPlex.NumSelecionados: integer;   //atajo
begin
  Result := motEdi.seleccion.Count;
end;
function TfraVisCPlex.Seleccionado: TObjGraf;  //atajo
begin
  Result := motEdi.Selected;
end;
function TfraVisCPlex.SeleccionarGru(NomGFac: string): boolean;
var
  og :TObjGraf;
begin
  for og in motEdi.objetos do begin
    if og is TogGFac then begin
      if TogGFac(og).GFac.Nombre = NomGFac then begin
        //Ubico el objeto
        motEdi.UnselectAll;
        og.Selec;  //selecciona
        motEdi.Refrescar;  //refresca
        exit(true);
      end;
    end;
  end;
end;
function TfraVisCPlex.SeleccionarFac(IdOgFac: string): boolean;
{Selecciona un objeto gráfico, dado su ID. Si no lo logra ubicar, devuelve FALSE.}
var
  og :TObjGraf;
begin
  for og in motEdi.objetos do begin
    if og is TogFac then begin
      if TogFac(og).Fac.IdFac = IdOgFac then begin
        //Ubico el objeto
        motEdi.UnselectAll;
        og.Selec;  //selecciona
        motEdi.Refrescar;  //refresca
        exit(true);
      end;
    end;
  end;
  //No lo encontró
  exit(false);
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
function TfraVisCPlex.GFacSeleccionado: TogGFac;
var
  og: TObjGraf;
begin
  if NumSelecionados>1 then begin
    //MsgExc('Se debe seleccionar solo una cabina.');
    exit(nil);
  end;
  og := Seleccionado;
  if og = nil then exit(nil);
  if not (og is TogGFac) then exit(nil);
  Result := TogGFac(og);
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
      if (ogFac.NomGrupo = fac.Grupo.Nombre) and (ogFac.Name = fac.Nombre) then begin
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
      ogFac.Resize(ogFac.Width, ogFac.Height);
      ogFac.Data:='';  //Para que no se elimine.
    end;
  end;
end;
function TfraVisCPlex.CoordPantallaDeFact(ogFac: TogFac): TPoint;
{Devuelve las coordenadas de se pantalla del facturable.}
begin
  Result.x:= motEdi.v2d.XPant(ogFac.x);
  Result.y:= motEdi.v2d.YPant(ogFac.y);
end;
function TfraVisCPlex.CoordPantallaDeFact2(ogFac: TogFac): TPoint;
{Devuelve las coordenadas de se pantalla de la parte inferior facturable.}
begin
  Result.x:= motEdi.v2d.XPant(ogFac.x);
  Result.y:= motEdi.v2d.YPant(ogFac.y + ogFac.Height);
end;

procedure TfraVisCPlex.PaintBox1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  og: TObjGraf;
begin
  //Busca para ver si pasa por alguna boleta
  for og in motEdi.objetos do begin
    if og.IsSelectedBy(X,Y) and (og is TogFac) then begin
      //Pasa por un objeto facturable
      if arrastEsBol then begin
        //Se arrastra una boleta
        Accept := TogFac(og).Boleta.LoSelec(X,Y);
      end else begin
        //Se arrastra un Facturable Cabina
//        Accept := true;
        Accept := ((og is TogCabina) or (og is TogMesa)) and
                  not TogFac(og).Boleta.LoSelec(X,Y);
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
    if og.IsSelectedBy(X,Y) and (og is TogFac) then begin
      ogFac := TogFac(og);
      //Verifica si no se ha soltado en el mismo objeto
      if facArrastrado.IdFac = ogFac.Fac.IdFac then begin
//        MsgBox('Soltado sobre el mismo.');
        exit;
      end;
      //Se soltó sobre un objeto facturable
      if arrastEsBol then begin
        //Se soltó una boleta
        if TogFac(og).Boleta.LoSelec(X,Y) then begin
          //Se ha soltado sobre una boleta
          if OnSolicEjecCom<>nil then begin
            if MsgYesNo('¿Trasladar boleta de cabina ' + facArrastrado.IdFac + ' a ' +
                         ogFac.Fac.IdFac + '?') <> 1 then exit;
             //Solicita ejecutar el comando. No se indica el idVista, porque no se sabe
             //si esta vista es local o remota.
             OnSolicEjecCom(CVIS_ACBOLET, ACCBOL_TRA, 0, facArrastrado.IdFac + #9 + ogFac.Fac.IdFac);
          end;
        end;
      end else if facArrastrado.ClassType = TCibFacCabina then begin
        //Se soltó un Facturable Cabina
        if (og is TogCabina) and  not TogFac(og).Boleta.LoSelec(X,Y) then begin
          if MsgYesNo('¿Trasladar cabina: ' + facArrastrado.IdFac + ' a ' +
                       ogFac.Fac.IdFac + '?') <> 1 then exit;
          //Se traslada la cabina
          OnSolicEjecCom(CFAC_CABIN, C_CABIN_TRASLA, 0, facArrastrado.IdFac + #9 + ogFac.Fac.IdFac);
        end;
      end else if facArrastrado.ClassType = TCibFacMesa then begin
        //Se soltó un Facturable Mesa
        if (og is TogMesa) and  not TogFac(og).Boleta.LoSelec(X,Y) then begin
          if MsgYesNo('¿Trasladar mesa: ' + facArrastrado.IdFac + ' a ' +
                       ogFac.Fac.IdFac + '?') <> 1 then exit;
          //Se traslada la mesa
          OnSolicEjecCom(CFAC_MESA, C_MESA_TRASLA, 0, facArrastrado.IdFac + #9 + ogFac.Fac.IdFac);
        end;
      end;
      exit;
    end;
  end;
end;
procedure TfraVisCPlex.ActualizarOgGrupos(items: TCibGFact_list);
{Actualiza la lista de grupos facturables de tipo TCibGFacCabinas. Normalmente solo
habrá un grupo.}
  function ExisteObjGrafParaGFac(gfac: TCibGFac; out ogGFac: TogGFac): boolean;
  {Indica si en el visor existe un objeto gráfcio que represente al grupo
  indicado. De ser así devuelve la referencia en "ogGFac".}
  var
    og: TObjGraf;
  begin
    for og in Motedi.objetos do if og.Tipo = OBJ_GRUP then begin
      if TogGFac(og).Name = gfac.Nombre then begin
        //Hay. Porque no debería haber grupos con el mismo nombre.
        ogGFac := TogGFac(og);  //devuelve referencia
        exit(true);
      end;
    end;
    //No existe
    exit(false)
  end;
var
  ogGFac: TogGFac;
  GFac : TCibGFac;
begin
  for GFac in items do begin
    if ExisteObjGrafParaGFac(GFac, ogGFac) then begin
      //Ya existe un og para este grupo.
      ogGFac.GFac := gfac;   {Actualiza la referencia, ya que el gfac se ha
                              creado nuevamente, en la copia del Visor}
      ogGFac.Data:='';     //Para que no se elimine.
    end else begin   //No hay
      //No hay objeto gráfico que represente a este grupo. Debe ser nuevo.
      ogGFac := AgregarOgGrupo(gfac);  //Crea grupo ogGFac
      ogGFac.GFac := gfac;  //agrega la referencia
      ogGFac.Data := '';  //Para que no se elimine (no es necesario).
    end;
  end;
end;
procedure TfraVisCPlex.ActualizarPropiedades(cadProp: string);
{Recibe la cadena de propiedades del "TCibModelo" del servidor y actualiza
su copia local.}
var
  og : TObjGraf;
  gruFac: TCibGFac;
  i: Integer;
begin
  //Actualiza el contenido del TCibModelo local
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
    ActualizarOgFacturables(gruFac);
  end;
  //Verifica objetos no usados (no actualizados), para eliminarlos
  i:=0;  //Usamos WHILe, en lugar de FOR, porque vamos a eliminar elementos
  while i<motEdi.objetos.Count do begin
    og := motEdi.objetos[i];
    if og.Data = 'x' then begin
debugln('>Eliminando: ' + og.Name);
      motEdi.DeleteGraphObject(og);
    end else begin
      Inc(i);
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
procedure TfraVisCPlex.EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word;
  cad: string);
{Se envía una respuesta al visor. Debe ser la respuesta a un comando.}
begin
  case comando of
  RVIS_SOLESTA: begin   //se recibe cadena de estado
      ActualizarEstado(cad);
    end;
  RVIS_SOLPROP: begin  //Se recibe archivo ini
      ActualizarPropiedades(cad);  //actualiza propeidades de objetos
    end;
  CVIS_MSJEPC: begin  //Esto más que una respuesta, es un comando, pero se debe procesar
      MsgExc(cad);
    end;
  RFAC_CABIN: begin  //Es respuesta para una cabina
      //Envía a la vista
      grupos.EjecRespuesta(comando, ParamX, ParamY, cad);
    end;
  end;
end;
procedure TfraVisCPlex.AlinearSelecHor;
{Alinea la selección de modo que todas las coordenadas X centrales, de los objetos
seleccionados, sean iguales.}
var
  og : TObjGraf;
  xCen: Single;
begin
  if motEdi.seleccion.Count <= 1 then exit;
  xCen := motEdi.seleccion[0].XCent;
  for og in motEdi.seleccion do begin
    og.Xcent := xCen;
  end;
  if OnObjectsMoved<>nil then OnObjectsMoved;
//  motedi.Refrescar;
end;
procedure TfraVisCPlex.AlinearSelecVer;
{Alinea la selección de modo que todas las coordenadas Y centrales, de los objetos
seleccionados, sean iguales.}
var
  og : TObjGraf;
  yCen: Single;
begin
  if motEdi.seleccion.Count <= 1 then exit;
  yCen := motEdi.seleccion[0].YCent;
  for og in motEdi.seleccion do begin
    og.YCent := yCen;
  end;
  if OnObjectsMoved<>nil then OnObjectsMoved;
//  motedi.Refrescar;
end;
function OrdPorX(const Item1, Item2: TObjGraf): Integer;
begin
  if Item1.x < Item2.x then begin
    exit(1);
  end else if Item1.x > Item2.x then begin
    exit(-1)
  end else begin
    exit(0);
  end;
end;
function OrdPorY(const Item1, Item2: TObjGraf): Integer;
begin
  if Item1.y < Item2.y then begin
    exit(1);
  end else if Item1.y > Item2.y then begin
    exit(-1)
  end else begin
    exit(0);
  end;
end;
procedure TfraVisCPlex.EspacirSelecHor;
var
  dx , xNue: Single;
  sel: TlistObjGraf;
  i: Integer;
begin
  if motEdi.seleccion.Count <= 2 then exit;
  sel := motEdi.seleccion;
  sel.Sort(@OrdPorX);  //ordena por coordenada X
  //Separa homogéneamente
  dx := (sel[sel.Count-1].x - sel[0].x) / (sel.Count - 1);
  for i := 1 to sel.Count-1 do begin
    xNue := sel[i-1].x + dx;
    sel[i].Locate(xNue, sel[i].y);
  end;
  if OnObjectsMoved<>nil then OnObjectsMoved;
//  motedi.Refrescar;
end;
procedure TfraVisCPlex.EspacirSelecVer;
var
  dy , yNue: Single;
  sel: TlistObjGraf;
  i: Integer;
begin
  if motEdi.seleccion.Count <= 2 then exit;
  sel := motEdi.seleccion;
  sel.Sort(@OrdPorY);  //ordena por coordenada Y
  //Separa homogéneamente
  dy := (sel[sel.Count-1].y - sel[0].y) / (sel.Count - 1);
  for i := 1 to sel.Count-1 do begin
    yNue := sel[i-1].y + dy;
    sel[i].Locate(sel[i].x, yNue);
  end;
  if OnObjectsMoved<>nil then OnObjectsMoved;
//  motedi.Refrescar;
end;
procedure TfraVisCPlex.motEdi_ObjectsMoved;
//Se ha producido el movimiento de uno o más objetos
begin
  if not FModDiseno then exit;   //se supone que no se pueden mover en este estado
  if OnObjectsMoved<>nil then OnObjectsMoved;
end;
procedure TfraVisCPlex.motEdi_InicArrastreFac(ogFac: TogFac; X, Y: Integer);
{Se inicia el arrastre de un objeto gráfico facturable.}
begin
  //Aquí se puede inciar el arrastre del objeto o su boleta
  if ogFac.Boleta.LoSelec(X,Y) and (ogFac.Fac.Boleta.ItemCount>0)  then begin
    //Selecciona una boleta y está visible
    arrastEsBol:= true;  //Indica que el objeto, a arrastrar, es una boleta.
    facArrastrado := ogFac.Fac;   //
    PaintBox1.BeginDrag(true);
  end else if ogFac.IsSelectedBy(X,Y) then begin
    //Selecciona al facturable
    if ogFac is TogCabina then begin  //Es cabina
      arrastEsBol:= false;  //Indica que el objeto, a arrastrar, es una boleta.
      facArrastrado := ogFac.Fac;   //
      PaintBox1.BeginDrag(true);
    end;
    if ogFac is TogMesa then begin  //Es mesa
      arrastEsBol:= false;  //Indica que el objeto, a arrastrar, es una boleta.
      facArrastrado := ogFac.Fac;   //
      PaintBox1.BeginDrag(true);
    end;
  end;
end;
procedure TfraVisCPlex.motEdi_DblClick(Sender: TObject);
var
  ogFac: TogFac;
  ogGfac: TogGFac;
begin
  if OnDobleClick<>nil then OnDobleClick(Sender);
  if Seleccionado = nil then exit;
  if Seleccionado is TogFac then begin //Se ha seleccionado un facturable.
    ogFac := FacSeleccionado;
    if OnDobleClickFac<>nil then OnDobleClickFac(ogFac, Mouse.CursorPos.x, Mouse.CursorPos.y);
  end;
  if Seleccionado is TogGFac then begin
    ogGfac := GFacSeleccionado;
    if OnDobleClickGFac<>nil then OnDobleClickGFac(ogGFac, Mouse.CursorPos.x, Mouse.CursorPos.y);
  end;
end;
procedure TfraVisCPlex.motEdi_ClickDer(Shift: TShiftState; x, y: integer);
var
  ogFac: TogFac;
  ogGfac: TogGFac;
begin
  if OnClickDer<>nil then OnClickDer(Shift, x, y);
  if Seleccionado = nil then exit;
  if FacSeleccionado <> nil then begin //Se ha seleccionado un facturable.
    ogFac := FacSeleccionado;
    if OnClickDerFac<>nil then OnClickDerFac(ogFac, x, y);
  end;
  if GFacSeleccionado <> nil then begin
    ogGfac := GFacSeleccionado;
    if OnClickDerGFac<>nil then OnClickDerGFac(ogGFac, x, y);
  end;
end;
procedure TfraVisCPlex.motEdi_MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if OnMouseUp<>nil then OnMouseUp(Sender, Button, Shift, X, Y);
end;
procedure TfraVisCPlex.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{Rutina para procesar el evento KeyDown. No está automáticamente asociada a ningún,
evento de teclado en el frame, así que debe hacerse desde afuera.}
begin
  if Key = VK_DELETE then begin
    //Se pide eliminar algo
    //motEdi.ElimSeleccion;   No es conveniente eliminar el objeto desde aquí.
    Key := 0;
  end;
  motEdi.KeyDown(Sender, Key, Shift);
end;
constructor TfraVisCPlex.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  motEdi := TEditionMot2.Create(PaintBox1);
  motEdi.OnObjectsMoved   := @motEdi_ObjectsMoved;
  motEdi.OnInicArrastreFac:= @motEdi_InicArrastreFac;
  motEdi.OnMouseUpRight   := @motEdi_ClickDer;
  motEdi.OnDblClick       := @motEdi_DblClick;
  motEdi.OnMouseUp        := @motEdi_MouseUp;
  decod  := TCPDecodCadEstado.Create;
  grupos := TCibModelo.Create('GrupVis', true);  //Crea en modo copia
  grupos.OnReqCadMoneda   := @gruposReqCadMoneda;
  grupos.OnSolicEjecCom   := @gruposSolicEjecCom;
end;
destructor TfraVisCPlex.Destroy;
begin
  grupos.Destroy;
  decod.Destroy;
  motEdi.Destroy;
  inherited;
end;

end.

