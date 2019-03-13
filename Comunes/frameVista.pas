{                                frameVista
Frame, que implementa un editor/visor de objetos gráficos de trabajo de CiberPlex.
La idea es encapsular en este Frame, el complicado motor de edición de objetos en pantalla.

                                              Por Tito Hinostroza  11/03/2014}
unit frameVista;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, FileUtil, Forms, Controls, ExtCtrls, Graphics,
  GraphType, lclType, dialogs, lclProc, ogDefObjGraf, ObjGraficos,
  CibFacturables, CibGFacCabinas, CibGFacMesas,
  CibModelo, CibTramas, ogEditionMot, MisUtils;
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


  { TfraVista }
  TfraVista = class(TFrame)
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
    decod     : TCPDecodCadEstado; //Decodificador de cadenas de estado
    arrastEsBol: boolean;     //Indica si el objeto arrastrado es una boleta.
    facArrastrado : TogFac;  //Objeto facturable arrastrado
    decodEst  : TCPDecodCadEstado;
    function AgregarOgGrupo(tipGFac: TCibTipGFact): TogGFac;
    function BuscarOgGFac(nomGrup: string): TogGFac;
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
    procedure ActualizarOgFacturables(lineas: TStringList; ogGFac: TOgGFac);
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
    function CoordPantallaDeFact(ogFac: TogFac): TPoint;
    function CoordPantallaDeFact2(ogFac: TogFac): TPoint;
    property ModDiseno: boolean read FModDiseno write SetModDiseno;
    function AgregOgFac(tipFac: TCibTipGFact): TogFac;
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
      Refresh;
      Exit;
     End;
  If ParaMover = True Then VerifyForMove(X, Y);
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
      Refresh;
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
        Refresh;
      end;
  end Else If EstPuntero = EP_DIMEN_OBJ Then begin
      //se está dimensionando un objeto
      CapturoEvento.MouseMove(X, Y, seleccion.Count);
      Refresh;
  end Else
      If CapturoEvento <> NIL Then begin
         CapturoEvento.MouseMove(X, Y, seleccion.Count);
         Refresh;
      end Else begin  //Movimiento simple
          s := VerifyMouseMove(X, Y);
          if s <> NIL then s.MouseOver(Sender, Shift, X, Y);  //pasa el evento
      end;
end;
procedure TfraVista.SetModDiseno(AValue: boolean);
var
  og :TObjGraf;
begin
  motEdi.ObjBloqueados:= not AValue;  //actualiza bandera
  for og in motEdi.objetos do begin
    og.PosLocked:=not AValue;
  end;
  FModDiseno:=AValue;
end;
function TfraVista.AgregOgFac(tipFac: TCibTipGFact): TogFac;
//Agrega un objeto gráfica asociado a un objeto facturable, al editor.
var
  ogCab: TogCabina;
  ogNil: TogNiloM;
  ogCli: TogCliente;
  ogMes: TogMesa;
begin
  Result := nil;
  case tipFac of
  ctfClientes: begin
    ogCli := TogCliente.Create(motEdi.v2d);
    motEdi.AddGraphObject(ogCli, false);
    ogCli.icono := Image14.Picture.Graphic;   //asigna imagen
    ogCli.SizeLocked := true;
    ogCli.PosLocked := not FModDiseno;  //depende del estado actual
    Result := ogCli;
  end;
  ctfCabinas: begin
    ogCab := TogCabina.Create(motEdi.v2d);
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
    ogNil := TogNiloM.Create(motEdi.v2d);
    motEdi.AddGraphObject(ogNil, false);
    ogNil.icoTelCol := Image9.Picture.Graphic;   //asigna imagen
    ogNil.icoTelDes := Image10.Picture.Graphic;
    ogNil.icoTelDes2:= Image11.Picture.Graphic;
    ogNil.SizeLocked := true;
    ogNil.PosLocked := not FModDiseno;  //depende del estado actual
    Result := ogNil;
  end;
  ctfMesas: begin
    ogMes := TogMesa.Create(motEdi.v2d);
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
function TfraVista.AgregarOgGrupo(tipGFac: TCibTipGFact): TogGFac;
{Agrega un objeto de tipo Grupo de Cabinas, al editor. Notar que parte de este código
existe también en la función CrearGFACdeTipo() en la unidad CibModelo.}
var
  ogGClies: TogGClientes;
  ogGCabs : TogGCabinas;
  ogGNiloM: TogGNiloM;
  ogGMes: TogGMesas;
begin
  Result := nil;   //valor por defecto
  case tipGFac of
  ctfClientes: begin
    ogGClies := TogGClientes.Create(motEdi.v2d);
    motEdi.AddGraphObject(ogGClies, false);
    ogGClies.icono := Image13.Picture.Graphic;   //asigna imagen
    ogGClies.SizeLocked := true;
    ogGClies.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGClies;
  end;
  ctfCabinas : begin  //Es grupo de cabinas TCibGFacCabinas
    ogGCabs := TogGCabinas.Create(motEdi.v2d);
    motEdi.AddGraphObject(ogGCabs, false);
    ogGCabs.icono := Image7.Picture.Graphic;   //asigna imagen
    ogGCabs.SizeLocked := true;
    ogGCabs.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGCabs;
  end;
  ctfNiloM: begin
    ogGNiloM := TogGNiloM.Create(motEdi.v2d);
    motEdi.AddGraphObject(ogGNiloM, false);
    ogGNiloM.icoConec := Image8.Picture.Graphic;   //asigna imagen
    ogGNiloM.icoDesc  := Image12.Picture.Graphic;
    ogGNiloM.SizeLocked := true;
    ogGNiloM.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGNiloM;
  end;
  ctfMesas: begin
    ogGMes := TogGMesas.Create(motEdi.v2d);
    motEdi.AddGraphObject(ogGMes, false);
    ogGMes.icono := Image16.Picture.Graphic;   //asigna imagen
    ogGMes.SizeLocked := true;
    ogGMes.PosLocked := not FModDiseno;  //depende del esatdo actual
    Result := ogGMes;
  end;
  end;
end;
function TfraVista.gruposReqCadMoneda(valor: double): string;
begin
  if OnReqCadMoneda = nil then exit('');
  Result := OnReqCadMoneda(valor);   //pasa el evento
end;
procedure TfraVista.gruposSolicEjecCom(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
begin
  if OnSolicEjecCom<>nil then OnSolicEjecCom(comando, ParamX, ParamY, cad);
end;
function TfraVista.NumSelecionados: integer;   //atajo
begin
  Result := motEdi.seleccion.Count;
end;
function TfraVista.Seleccionado: TObjGraf;  //atajo
begin
  Result := motEdi.Selected;
end;
function TfraVista.SeleccionarGru(NomGFac: string): boolean;
var
  og :TObjGraf;
begin
  for og in motEdi.objetos do begin
    if og is TogGFac then begin
      if TogGFac(og).Name = NomGFac then begin
        //Ubico el objeto
        motEdi.UnselectAll;
        og.Selec;  //selecciona
        motEdi.Refresh;  //refresca
        exit(true);
      end;
    end;
  end;
end;
function TfraVista.SeleccionarFac(IdOgFac: string): boolean;
{Selecciona un objeto gráfico, dado su ID. Si no lo logra ubicar, devuelve FALSE.}
var
  og :TObjGraf;
begin
  for og in motEdi.objetos do begin
    if og is TogFac then begin
      if TogFac(og).IdFac = IdOgFac then begin
        //Ubico el objeto
        motEdi.UnselectAll;
        og.Selec;  //selecciona
        motEdi.Refresh;  //refresca
        exit(true);
      end;
    end;
  end;
  //No lo encontró
  exit(false);
end;
function TfraVista.FacSeleccionado: TogFac;
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
function TfraVista.GFacSeleccionado: TogGFac;
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

function TfraVista.CabSeleccionada: TogCabina;
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
function TfraVista.GCabinasSeleccionado: TogGCabinas;
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
procedure TfraVista.ActualizarOgFacturables(lineas: TStringList; ogGFac: TOgGFac);
{Actualiza las propiedades de los objetos y a los objetos mismos, porque aquí se define
que objetos deben existir}
  function BuscarOgFac(facNombre, gFacNombre: string): TogFac;
  {Devuelve la referencia a un objeto gráfico facturable, del motor de edición, que tenga
   el nombre del facturable indicado y que pertenezca al mismo grupo. Si no existe
   devuelve NIL. }
  var
    og: TObjGraf;
    ogFac: TogFac;
  begin
    for og in Motedi.objetos do if og.Tipo = OBJ_FACT then begin
      ogFac := TogFac(og);  //restaura tipo
      if (ogFac.NomGrupo = gFacNombre) and (ogFac.Name = facNombre) then begin
        //hay, devuelve la referencia
        Result := ogFac;  //restaura tipo
        exit;
      end;
    end;
    Result := nil;
  end;
var
  ogFac: TogFac;
  lin, nombFac: string;
begin
  for lin in lineas do begin
    if trim(lin) = '' then continue;
    nombFac := copy(lin, 1, pos(#9, lin)-1);
    ogFac := BuscarOgFac(nombFac, ogGFac.Name);
    if ogFac = nil then begin
      ogFac := AgregOgFac(ogGFac.tipGFac);  //Crea FAC del tipo indicado.
      ogFac.tipGFac := ogGFac.tipGFac;  //Asigna tipo de grupo
      ogFac.grupo := ogGFac;   //Guarda refrencia a su grupo
    end;
    //Ya se tiene la referencia
    ogFac.SetCadPropied(lin);
    ogFac.ReLocate(ogFac.x, ogFac.y);  //Por si cambia su posición
    //ogFac.Resize(ogFac.Width, ogFac.Height);
    ogFac.Data:='';  //Para que no se elimine.
  end;
end;
function TfraVista.CoordPantallaDeFact(ogFac: TogFac): TPoint;
{Devuelve las coordenadas de se pantalla del facturable.}
begin
  Result.x:= motEdi.v2d.XPant(ogFac.x);
  Result.y:= motEdi.v2d.YPant(ogFac.y);
end;
function TfraVista.CoordPantallaDeFact2(ogFac: TogFac): TPoint;
{Devuelve las coordenadas de se pantalla de la parte inferior facturable.}
begin
  Result.x:= motEdi.v2d.XPant(ogFac.x);
  Result.y:= motEdi.v2d.YPant(ogFac.y + ogFac.Height);
end;

procedure TfraVista.PaintBox1DragOver(Sender, Source: TObject; X,
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
procedure TfraVista.PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer
  );
var
  og: TObjGraf;
  ogFac: TogFac;
begin
  for og in motEdi.objetos do begin
    if og.IsSelectedBy(X,Y) and (og is TogFac) then begin
      ogFac := TogFac(og);
      //Verifica si no se ha soltado en el mismo objeto
      if facArrastrado.IdFac = ogFac.IdFac then begin
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
                         ogFac.IdFac + '?') <> 1 then exit;
             //Solicita ejecutar el comando. No se indica el idVista, porque no se sabe
             //si esta vista es local o remota.
             OnSolicEjecCom(CVIS_ACBOLET, ACCBOL_TRA, 0, facArrastrado.IdFac + #9 + ogFac.IdFac);
          end;
        end;
      end else if facArrastrado.tipGFac = ctfCabinas then begin
        //Se soltó un Facturable Cabina
        if (og is TogCabina) and  not TogFac(og).Boleta.LoSelec(X,Y) then begin
          if MsgYesNo('¿Trasladar cabina: ' + facArrastrado.IdFac + ' a ' +
                       ogFac.IdFac + '?') <> 1 then exit;
          //Se traslada la cabina
          OnSolicEjecCom(CFAC_CABIN, C_CABIN_TRASLA, 0, facArrastrado.IdFac + #9 + ogFac.IdFac);
        end;
      end else if facArrastrado.tipGFac = ctfMesas then begin
        //Se soltó un Facturable Mesa
        if (og is TogMesa) and  not TogFac(og).Boleta.LoSelec(X,Y) then begin
          if MsgYesNo('¿Trasladar mesa: ' + facArrastrado.IdFac + ' a ' +
                       ogFac.IdFac + '?') <> 1 then exit;
          //Se traslada la mesa
          OnSolicEjecCom(CFAC_MESA, C_MESA_TRASLA, 0, facArrastrado.IdFac + #9 + ogFac.IdFac);
        end;
      end;
      exit;
    end;
  end;
end;
function TfraVista.BuscarOgGFac(nomGrup: string): TogGFac;
{Busca un objeto gráfico Grupo facturable, del motor de edición, que tenga
 el nombre del grupo indicado. Si no existe devuelve NIL. }
var
  og: TObjGraf;
  ogGFac: TogGFac;
begin
  for og in Motedi.objetos do if og.Tipo = OBJ_GRUP then begin
    ogGFac := TogGFac(og);  //restaura tipo
    if ogGFac.Name = nomGrup then begin
      //hay, devuelve la referencia
      Result := ogGFac;  //restaura tipo
      exit;
    end;
  end;
  Result := nil;  //No encontró
end;
procedure TfraVista.ActualizarPropiedades(cadProp: string);
{Recibe la cadena de propiedades del "TCibModelo" del servidor y actualiza
su copia local.}
var
  og: TObjGraf;
  ogGfac: TogGFac;
  i: Integer;
  lineas: TStringList;
  linGru: TStringList;
  nomGrup, tmp: string;
  tipGru: TCibTipGFact;
begin
  if trim(cadProp) = '' then exit;
  lineas := TStringList.Create;
  linGru := TStringList.Create;

  lineas.Text:=cadProp;  //divide en líneas
  lineas.Delete(0);   //Elimina primera línea ( No tiene información.)
  for og in motEdi.objetos do og.Data:='x';  //marca todos para eliminación
  while ExtraerBloquePropied(lineas, tmp, nomGrup, tipGru) do begin
    ogGFac := BuscarOgGFac(nomGrup);
    if ogGFac=nil then begin
      //Es un objeto nuevo
      ogGFac := AgregarOgGrupo(tipGru);  //Crea grupo ogGFac
      ogGFac.OnReqCadMoneda := @gruposReqCadMoneda;
    end;
    ogGFac.Data := '';  //Para que no se elimine
    //Ya se tiene el ogGFac accesible, actualizamos sus propiedades
    linGru.Text := tmp;
    ogGfac.SetCadPropied(linGru);
    //Ya se tiene el ogGFac actualizado, ahora actualizamos sus ogFac
    ActualizarOgFacturables(linGru, ogGfac);
  end;
  linGru.Destroy;
  lineas.Destroy;
  //Verifica objetos no usados (no actualizados), para eliminarlos
  i:=0;  //Usamos WHILE, en lugar de FOR, porque vamos a eliminar elementos
  while i<motEdi.objetos.Count do begin
    og := motEdi.objetos[i];
    if (og.Tipo = OBJ_FACT) and (og.Data = 'x') then begin
debugln('>Eliminando: ' + og.Name);
      motEdi.DeleteGraphObject(og);
    end else begin
      Inc(i);
    end;
  end;
  //Eliminamos los restantes
  i:=0;
  while i<motEdi.objetos.Count do begin
    og := motEdi.objetos[i];
    if og.Data = 'x' then begin
debugln('>Eliminando: ' + og.Name);
      motEdi.DeleteGraphObject(og);
    end else begin
      Inc(i);
    end;
  end;
  motEdi.Refresh;
end;
procedure TfraVista.ActualizarEstado(cadEstado: string);
{Actualiza el estado de los objetos existentes. No se cambian las propiedades ni se
 crean o eliminan objetos. La cadena de estado tiene la forma:
 <0	Cabinas
 .Cab1	0	1899:12:30:00:00:00
 .Cab2	3	1899:12:30:00:00:00
 ...
 >
 <1      Locutor
 ...
 >
 }
var
  lest: TStringList;
  res: Boolean;
  cad, nombGrup, lin1, nomb: string;
  tipo: TCibTipGFact;
  ogGfac: TObjGraf;
  ogFac: TObjGraf;
  car: char;
  gfac: TCibGFac;
begin
  if cadEstado='' then exit;

  //-------- Refresca los facturables de los objetos gráficos -------
  //grupos.CadEstado := cadEstado;  //solo cambia las variables de estado de "grupos"
  lest := TStringList.Create;
  lest.Text := cadEstado;  //carga texto
  //Extrae los fragmentos correspondientes a cada Grupo facturable
  while lest.Count>0 do begin
    res := ExtraerBloqueEstado(lest, cad, nombGrup, tipo);
    if not res then break;  //Se mostró mensaje de error
    ogGFac := BuscarOgGFac(nombGrup);
    if ogGfac = nil then begin
      //Llegó el estado de un grupo que no existe.
      debugln('Grupo no existente: ' + nombGrup);   //WARNING
      continue;
    end;
    //gfac.CadEstado := cad;   //No importa de que tipo sea
  end;
  //Carga el contenido del archivo de estado.
  lest.Destroy;

  ////--------- Refresco de objetos gráficos ----------
  ////Este código deberá reemplazar al anterior: grupos.CadEstado := cadEstado;
  //lest:= TStringList.Create;
  //lest.Text := cadEstado;  //carga texto
  ////Extrae los fragmentos correspondientes a cada Grupo facturable
  //while lest.Count>0 do begin
  //  res := ExtraerBloqueEstado(lest, cad, nombGrup, tipo);
  //  if not res then break;  //se mostró mensaje de error
  //  ogGfac := motedi.ObjPorNombre(nombGrup); //ItemPorNombre(nombGrup);
  //  if ogGfac = nil then begin
  //    //Llegó el estado de un grupo que no existe.
  //    debugln('Grupo no existente: ' + nombGrup);   //WARNING
  //    break;
  //  end;
  //  {Aquí deberíamos actualizar el estado del objeto gráfico que representa al grupo,
  //  y también el estado de cada objeto del grupo.}
  //  decodEst.Inic(cad, lin1);  //Inicia extracción con el decodificador.
  //  //"lin1" no nos sirve aquí. No se incluyen campos de estado para los GFAC.
  //  //Explora todos los otros objetos que represebtab a FAC
  //  while decodEst.Extraer(car, nomb, cad) do begin
  //    if cad = '' then continue;
  //    ogFac := motEdi.ObjPorNombre(nomb);
  //    //if ogFac<>nil then ogFac.CadEstado := cad;
  //  end;
  //end;
  ////carga el contenido del archivo de estado
  //lest.Destroy;

  //Los objetos gráficos "verán" los cambios, porque tienen referencias a sus objetos fuente
  motEdi.Refresh;
DebugLn('---');
end;
procedure TfraVista.EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word;
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
      //grupos.EjecRespuesta(comando, ParamX, ParamY, cad);  Se supone que funcionaba cuando se manejaba una instancia de "grupos" aquí en el visor.
    end;
  end;
end;
procedure TfraVista.AlinearSelecHor;
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
procedure TfraVista.AlinearSelecVer;
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
procedure TfraVista.EspacirSelecHor;
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
procedure TfraVista.EspacirSelecVer;
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
procedure TfraVista.motEdi_ObjectsMoved;
//Se ha producido el movimiento de uno o más objetos
begin
  if not FModDiseno then exit;   //se supone que no se pueden mover en este estado
  if OnObjectsMoved<>nil then OnObjectsMoved;
end;
procedure TfraVista.motEdi_InicArrastreFac(ogFac: TogFac; X, Y: Integer);
{Se inicia el arrastre de un objeto gráfico facturable.}
begin
  //Aquí se puede inciar el arrastre del objeto o su boleta
  if ogFac.Boleta.LoSelec(X,Y) and (ogFac.facBoleta.ItemCount>0)  then begin
    //Selecciona una boleta y está visible
    arrastEsBol:= true;  //Indica que el objeto, a arrastrar, es una boleta.
    facArrastrado := ogFac;   //
    PaintBox1.BeginDrag(true);
  end else if ogFac.IsSelectedBy(X,Y) then begin
    //Selecciona al facturable
    if ogFac is TogCabina then begin  //Es cabina
      arrastEsBol:= false;  //Indica que el objeto, a arrastrar, es una boleta.
      facArrastrado := ogFac;   //
      PaintBox1.BeginDrag(true);
    end;
    if ogFac is TogMesa then begin  //Es mesa
      arrastEsBol:= false;  //Indica que el objeto, a arrastrar, es una boleta.
      facArrastrado := ogFac;   //
      PaintBox1.BeginDrag(true);
    end;
  end;
end;
procedure TfraVista.motEdi_DblClick(Sender: TObject);
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
procedure TfraVista.motEdi_ClickDer(Shift: TShiftState; x, y: integer);
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
procedure TfraVista.motEdi_MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if OnMouseUp<>nil then OnMouseUp(Sender, Button, Shift, X, Y);
end;
procedure TfraVista.KeyDown(Sender: TObject; var Key: Word;
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
constructor TfraVista.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  motEdi := TEditionMot2.Create(PaintBox1);
  motEdi.OnObjectsMoved   := @motEdi_ObjectsMoved;
  motEdi.OnInicArrastreFac:= @motEdi_InicArrastreFac;
  motEdi.OnMouseUpRight   := @motEdi_ClickDer;
  motEdi.OnDblClick       := @motEdi_DblClick;
  motEdi.OnMouseUp        := @motEdi_MouseUp;
  decod  := TCPDecodCadEstado.Create;
  //Crea decoder para decodificar la cadena de estado
  decodEst  := TCPDecodCadEstado.Create;
end;
destructor TfraVista.Destroy;
begin
  decodEst.Destroy;
  decod.Destroy;
  motEdi.Destroy;
  inherited;
end;

end.

