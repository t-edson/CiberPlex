{                                frameVista
Frame, que implementa un editor/visor de objetos gráficos de trabajo de CiberPlex.
La idea es encapsular en este Frame, el complicado motor de edición de objetos en pantalla.

                                              Por Tito Hinostroza  11/03/2014}
unit frameVista;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, FileUtil, Forms, Controls, ExtCtrls, Graphics,
  GraphType, lclType, dialogs, lclProc, Menus, ActnList, ogDefObjGraf,
  ObjGraficos, CibFacturables, CibGFacCabinas, CibGFacMesas, CibModelo,
  CibTramas, FormBoleta, FormOgCabinas, FormOgClientes, FormOgNiloM,
  FormOgMesas, ogEditionMot, MisUtils;
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
    acEdiAlinHor: TAction;
    acEdiAlinVer: TAction;
    acEdiElimGru: TAction;
    acEdiEspHor: TAction;
    acEdiEspVer: TAction;
    acEdiInsEnrut: TAction;
    acEdiInsGrCab: TAction;
    acEdiInsGrCli: TAction;
    acEdiInsGrMes: TAction;
    acFacAgrVen: TAction;
    acFacGraBol: TAction;
    acFacMovBol: TAction;
    acFacVerBol: TAction;
    ActionList1: TActionList;
    ImageList16: TImageList;
    ImageList32: TImageList;
    MenuItem37: TMenuItem;
    PaintBox1: TPaintBox;
    PopupMenu1: TPopupMenu;
    Timer1: TTimer;
    procedure acEdiElimGruExecute(Sender: TObject);
    procedure acFacAgrVenExecute(Sender: TObject);
    procedure acFacGraBolExecute(Sender: TObject);
    procedure acFacMovBolExecute(Sender: TObject);
    procedure acFacVerBolExecute(Sender: TObject);
    procedure PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure PaintBox1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Timer1Timer(Sender: TObject);
  private   //Eventos de la ventana de Boletas
    procedure frmBoleta_GrabarItem(idFac: string; idItemtBol, coment: string);
    procedure frmBoleta_AgregarItem(idFac: string; coment: string);
    procedure frmBoleta_ComentarItem(idFac: string; idItemtBol, coment: string);
    procedure frmBoleta_DesecharItem(idFac: string; idItemtBol, coment: string);
    procedure frmBoleta_DevolverItem(idFac: string; idItemtBol, coment: string);
    procedure frmBoleta_DividirItem(idFac: string; idItemtBol, coment: string);
    procedure frmBoleta_GrabarBoleta(idFac: string; coment: string);
    procedure frmBoleta_RecuperarItem(idFac: string; idItemtBol, coment: string);
  private
    FModDiseno: boolean;
    arrastEsBol: boolean;     //Indica si el objeto arrastrado es una boleta.
    facArrastrado : TogFac;  //Objeto facturable arrastrado
    decodEst  : TCPDecodCadEstado;
    frmBol    : TfrmBoleta;
    function AgregarOgGrupo(tipGFac: TCibTipGFact): TogGFac;
    function BuscarOgFac(facNombre, gFacNombre: string): TogFac;
    function BuscarOgGFac(nomGrup: string): TogGFac;
    function BuscarOgFacID(idFac: string): TogFac;
    procedure ConfigurarPopUpFac(ogFac: TogFac; PopUp: TPopupMenu);
    procedure ConfigurarPopUpGru(ogGFac: TogGFac; PopUp: TPopupMenu);
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
  public  //Eventos prop
    OnObjectsMoved  : procedure of object;  //Los objetos se han movido
    OnSolicEjecCom  : TEvSolicEjecCom; //Se solicita ejecutar una acción
    OnReqCadMoneda  : TevReqCadMoneda; //Se requiere convertir a formato de moneda
    //OnMouseUp: TMouseEvent;          //se usa el que está definido en el frame
    OnClickDer      : TEvMouse;        //Click derecho en el visor
    OnClickDerFac   : TEvMouseFac;     //Click derecho en un facturable del visor
    OnClickDerGFac  : TEvMouseGFac;    //Click derecho en un grupo del visor
    OnDobleClick    : TNotifyEvent;    //Doble click en el visor
    OnDobleClickFac : TEvMouseFac;     //Doble click en un facturable del visor
    OnDobleClickGFac: TEvMouseGFac;    //Doble click en un grupo del visor
    OnAgrVentaProd  : TEvAccionFact;   //Solicita elegir un producto
    //OnMostrarBoleta : TEvAccionFact; //Solicita mostrar la boleta de un facturable.
  public
    motEdi          : TEditionMot2;  //motor de edición
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
    procedure EspaciarSelecHor;   //Espaciar la selección
    procedure EspaciarSelecVer;   //Espaciar la selección
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public  //Inicialización
    procedure CargarIconos;
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
  end else begin
      If CapturoEvento <> NIL Then begin
         CapturoEvento.MouseMove(X, Y, seleccion.Count);
         Refresh;
      end Else begin  //Movimiento simple
          s := VerifyMouseMove(X, Y);
          if s <> NIL then s.MouseOver(Sender, Shift, X, Y);  //pasa el evento
      end;
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
begin
  Result := nil;
  case tipFac of
  ctfClientes: begin
    Result := TogCliente.Create(motEdi.v2d);
  end;
  ctfCabinas: begin
    Result := TogCabina.Create(motEdi.v2d);
  end;
  ctfNiloM: begin
    Result := TogNiloM.Create(motEdi.v2d);
  end;
  ctfMesas: begin
    Result := TogMesa.Create(motEdi.v2d);
  end;
  end;
  motEdi.AddGraphObject(Result, false);
  Result.SizeLocked := true;
  Result.PosLocked  := not FModDiseno;  //depende del estado actual
end;
function TfraVista.AgregarOgGrupo(tipGFac: TCibTipGFact): TogGFac;
{Agrega un objeto de tipo Grupo de Cabinas, al editor. Notar que parte de este código
existe también en la función CrearGFACdeTipo() en la unidad CibModelo.}
begin
  Result := nil;   //valor por defecto
  case tipGFac of
  ctfClientes: begin
    Result := TogGClientes.Create(motEdi.v2d);
  end;
  ctfCabinas : begin
    Result := TogGCabinas.Create(motEdi.v2d);
  end;
  ctfNiloM: begin
    Result := TogGNiloM.Create(motEdi.v2d);
  end;
  ctfMesas: begin
    Result := TogGMesas.Create(motEdi.v2d);
  end;
  end;
  motEdi.AddGraphObject(Result, false);
  Result.SizeLocked := true;
  Result.PosLocked := not FModDiseno;  //depende del esatdo actual
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
        Accept := TogFac(og).ogBoleta.LoSelec(X,Y);
      end else begin
        //Se arrastra un Facturable Cabina
//        Accept := true;
        Accept := ((og is TogCabina) or (og is TogMesa)) and
                  not TogFac(og).ogBoleta.LoSelec(X,Y);
      end;
      exit;
    end;
  end;
  //No lo selecciona
  Accept := false;
end;
procedure TfraVista.Timer1Timer(Sender: TObject);
begin
  if (frmBol<>nil) and frmBol.Visible then
    frmBol.ActualizarDatos;
end;
procedure TfraVista.PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer
  );
var
  og: TObjGraf;
  ogFac: TogFac;
begin
  //A este punto llega solo si pasa el filtro de PaintBox1DragOver()
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
        if TogFac(og).ogBoleta.LoSelec(X,Y) then begin
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
        if (og is TogCabina) and  not TogFac(og).ogBoleta.LoSelec(X,Y) then begin
          if MsgYesNo('¿Trasladar cabina: ' + facArrastrado.IdFac + ' a ' +
                       ogFac.IdFac + '?') <> 1 then exit;
          //Se traslada la cabina
          OnSolicEjecCom(CFAC_CABIN, C_CABIN_TRASLA, 0, facArrastrado.IdFac + #9 + ogFac.IdFac);
        end;
      end else if facArrastrado.tipGFac = ctfMesas then begin
        //Se soltó un Facturable Mesa
        if (og is TogMesa) and  not TogFac(og).ogBoleta.LoSelec(X,Y) then begin
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
function TfraVista.BuscarOgFac(facNombre, gFacNombre: string): TogFac;
{Devuelve la referencia a un objeto gráfico facturable, del motor de edición, que tenga
 el nombre del facturable indicado y que pertenezca al mismo grupo. Si no existe
 devuelve NIL. }
var
  og: TObjGraf;
  ogFac: TogFac;
begin
  for og in Motedi.objetos do if og.Tipo = OBJ_FACT then begin
    ogFac := TogFac(og);  //restaura tipo
    if (ogFac.grupo.Name = gFacNombre) and (ogFac.Name = facNombre) then begin
      //hay, devuelve la referencia
      Result := ogFac;  //restaura tipo
      exit;
    end;
  end;
  Result := nil;
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
function TfraVista.BuscarOgFacID(idFac: string): TogFac;
var
  og: TObjGraf;
  ogFac: TogFac;
begin
  for og in Motedi.objetos do if og.Tipo = OBJ_FACT then begin
    ogFac := TogFac(og);  //restaura tipo
    if ogFac.IdFac = idFac then begin
      //hay, devuelve la referencia
      Result := ogFac;  //restaura tipo
      exit;
    end;
  end;
  Result := nil;
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
  nomGrup, propGru, Err: string;
  tipGru: TCibTipGFact;
begin
  if trim(cadProp) = '' then exit;
  lineas := TStringList.Create;
  linGru := TStringList.Create;

  lineas.Text:=cadProp;  //divide en líneas
  lineas.Delete(0);   //Elimina primera línea ( No tiene información.)
  for og in motEdi.objetos do og.Data:='x';  //marca todos para eliminación
  while ExtraerPropiedGFAC(lineas, tipGru, nomGrup, propGru, Err) do begin
    ogGFac := BuscarOgGFac(nomGrup);
    if ogGFac=nil then begin
      //Es un objeto nuevo
      ogGFac := AgregarOgGrupo(tipGru);  //Crea grupo ogGFac
      ogGFac.OnReqCadMoneda := @gruposReqCadMoneda;
    end;
    ogGFac.Data := '';  //Para que no se elimine
    //Ya se tiene el ogGFac accesible, actualizamos sus propiedades
    linGru.Text := propGru;
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
  lineas, linGru: TStringList;
  res: Boolean;
  estGrup, nomGrup, Err, nombFac, lin1, cad: string;
  tipGru: TCibTipGFact;
  ogGfac: TogGFac;
  car: char;
  ogFac: TogFac;
begin
  if cadEstado='' then exit;

  //-------- Refresca los facturables de los objetos gráficos -------
  //grupos.CadEstado := cadEstado;  //solo cambia las variables de estado de "grupos"
  lineas := TStringList.Create;
  linGru := TStringList.Create;

  lineas.Text := cadEstado;  //carga texto
  //Extrae los fragmentos correspondientes a cada Grupo facturable
  while lineas.Count>0 do begin
    res := ExtraerEstadoGFAC(lineas, tipGru, nomGrup, estGrup, Err);
    if not res then break;  //Se mostró mensaje de error
    ogGFac := BuscarOgGFac(nomGrup);
    if ogGfac = nil then begin
      //Llegó el estado de un grupo que no existe.
      debugln('Grupo no existente: ' + nomGrup);   //WARNING
      continue;
    end;
    //Ya se tiene al ogGfac accesible
    decodEst.Inic(estGrup, lin1);
    ogGfac.SetCadEstado(lin1);  //Actualiza ogGfac
    //Actualiza los ogFac
    while decodEst.Extraer(car, nombFac, cad) do begin
      ogFac := BuscarOgFac(nombFac, ogGFac.Name);
      if ogFac = nil then begin
        debugln('Facturable no existente: ' + nomGrup);   //WARNING
        continue;
      end;
      ogFac.SetCadEstado(cad);
    end;
  end;
  //Carga el contenido del archivo de estado.
  lineas.Destroy;
  linGru.Destroy;
  if Err<>'' then begin
    DebugLn('--'+Err);
  end;
  //Los objetos gráficos "verán" los cambios, porque tienen referencias a sus objetos fuente
  motEdi.Refresh;
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
procedure TfraVista.EspaciarSelecHor;
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
procedure TfraVista.EspaciarSelecVer;
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
procedure TfraVista.ConfigurarPopUpFac(ogFac: TogFac; PopUp: TPopupMenu);
{Configura un menú PopUp, con las acciones que corresponden a un objeto gráfico,
facturable.}
var
  mn: TMenuItem;
begin
  PopUp.Items.Clear;

  //Agrega los ítems del menú que son comunes a todos los facturables
  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacAgrVen;
  mn.Caption:= '&0. ' + mn.Caption;
  PopUp.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacVerBol;
  mn.Caption:= '&1. ' + mn.Caption;
  PopUp.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacGraBol;
  mn.Caption:= '&2. ' + mn.Caption;
  PopUp.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Action := acFacMovBol;
  mn.Caption:= '&3. ' + mn.Caption;
  PopUp.Items.Add(mn);

  mn :=  TMenuItem.Create(nil);
  mn.Caption:='-';
  PopUp.Items.Add(mn);

  if ogFac is TogCabina then begin
    frmOgCabinas.MenuAccionesFac(ogFac as TogCabina, modDiseno, PopUp, 4);
  end else if ogFac is TogNiloM then begin
    frmOgNiloM.MenuAccionesFac(ogFac as TogNiloM, modDiseno, PopUp, 4);
  end else if ogFac is TogMesa then begin
    frmOgMesas.MenuAccionesFac(ogFac as TogMesa, modDiseno, PopUp);
  end else if ogFac is TogCliente then begin
    frmOgClientes.MenuAccionesFac(ogFac as TogCliente, modDiseno, PopUp);
  end;
end;
procedure TfraVista.ConfigurarPopUpGru(ogGFac: TogGFac; PopUp: TPopupMenu);
{Configura un menú PopUp, con las acciones que corresponden a un objeto gráfico,
grupo.}
var
  mn: TMenuItem;
begin
  PopUp.Items.Clear;   //reusamos el PopUp
  if ogGFac is TogGCabinas then begin
    frmOgCabinas.MenuAccionesGru(ogGFac as TogGCabinas, modDiseno, PopUp);
  end else if ogGFac is TogGNiloM then begin
    frmOgNiloM.MenuAccionesGru(ogGFac as TogGNiloM, ModDiseno, PopUp);
  end else if ogGFac is TogGMesas then begin
    frmOgMesas.MenuAccionesGru(ogGFac as TogGMesas, ModDiseno, PopUp);
  end else if ogGFac is TogGClientes then begin
    frmOgClientes.MenuAccionesGru(ogGFac as TogGClientes, modDiseno, PopUp);
  end;
  //Acciones comunes en modo de diseño.
  //Todos los grupos se pueden eliminar.
  if modDiseno then begin
    mn :=  TMenuItem.Create(nil);
    mn.Caption:='-';
    PopUp.Items.Add(mn);

    mn :=  TMenuItem.Create(nil);
    mn.Action := acEdiElimGru;
    PopUp.Items.Add(mn);
  end;
end;
//Eventos de la ventana de Boletas
procedure TfraVista.frmBoleta_GrabarItem(idFac: string; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := IdFac + #9 + idItemtBol + #9 + coment;  //junta nombre de objeto con cadena de estado
  OnSolicEjecCom(CVIS_ACBOLET, ACCITM_GRA, 0, txt);
end;
procedure TfraVista.frmBoleta_AgregarItem(idFac: string; coment: string);
begin
  //Debería bastar llamar a este evento
  OnAgrVentaProd(IdFac);
end;
procedure TfraVista.frmBoleta_ComentarItem(idFac: string; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := IdFac + #9 + idItemtBol + #9 + coment;
  OnSolicEjecCom(CVIS_ACBOLET, ACCITM_COM, 0, txt);
end;
procedure TfraVista.frmBoleta_DesecharItem(idFac: string; idItemtBol,
  coment: string);
{Evento que solicita desechar un ítem de una boleta}
var
  txt: string;
begin
  txt := IdFac + #9 + idItemtBol + #9 + coment;
  OnSolicEjecCom(CVIS_ACBOLET, ACCITM_DES, 0, txt);
end;
procedure TfraVista.frmBoleta_DevolverItem(idFac: string; idItemtBol,
  coment: string);
{Evento que solicita eliminar un ítem de la boleta}
var
  txt: string;
begin
  txt := IdFac + #9 + idItemtBol + #9 + coment;
  OnSolicEjecCom(CVIS_ACBOLET, ACCITM_DEV, 0, txt);  //envía con tamaño en Y
end;
procedure TfraVista.frmBoleta_DividirItem(idFac: string; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := IdFac + #9 + idItemtBol + #9 + coment;  //aquí coment contiene un número
  OnSolicEjecCom(CVIS_ACBOLET, ACCITM_DIV, 0, txt);
end;
procedure TfraVista.frmBoleta_GrabarBoleta(idFac: string; coment: string);
begin
  if OnSolicEjecCom = nil then exit;
  if MsgYesNo('Grabar Boleta de: ' + idFac + '?')<>1 then exit;
  OnSolicEjecCom(CVIS_ACBOLET, ACCBOL_GRA, 0, IdFac);
end;
procedure TfraVista.frmBoleta_RecuperarItem(idFac: string; idItemtBol,
  coment: string);
var
  txt: String;
begin
  txt := IdFac + #9 + idItemtBol + #9 + coment;
  OnSolicEjecCom(CVIS_ACBOLET, ACCITM_REC, 0, txt);
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
  if ogFac.ogBoleta.LoSelec(X,Y) and (ogFac.Boleta.ItemCount>0)  then begin
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
    ogFac := FacSeleccionado;  //Obtiene facturable
    if OnClickDerFac<>nil then OnClickDerFac(ogFac, x, y);  //Genera evento
    ConfigurarPopUpFac(ogFac, PopupMenu1); //Configura menú
    PopupMenu1.PopUp;          //Abré Popup
  end;
  if GFacSeleccionado <> nil then begin
    ogGfac := GFacSeleccionado;
    if OnClickDerGFac<>nil then OnClickDerGFac(ogGFac, x, y);
    ConfigurarPopUpGru(ogGFac, PopupMenu1); //Configura menú
    PopupMenu1.PopUp;          //Abré Popup
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
//Inicialización
procedure TfraVista.CargarIconos;
begin
  //Agrega íconos de los objetos gráfiocs
  FormOgClientes.CargarIconos(ImageList16, ImageList32);
  FormOgNiloM.CargarIconos(ImageList16, ImageList32);
  FormOgCabinas.CargarIconos(ImageList16, ImageList32);
  FormOgMesas.CargarIconos(ImageList16, ImageList32);
  //Aprovecha para configurar eventos
  frmOgCabinas.OnSolicEjecCom := @gruposSolicEjecCom;  //Prepara para recibir comandos
  frmOgNiloM.OnSolicEjecCom := @gruposSolicEjecCom;  //Prepara para recibir comandos
  frmOgMesas.OnSolicEjecCom := @gruposSolicEjecCom;  //Prepara para recibir comandos
  frmOgClientes.OnSolicEjecCom := @gruposSolicEjecCom;  //Prepara para recibir comandos

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
  //Crea decoder para decodificar la cadena de estado
  decodEst := TCPDecodCadEstado.Create;
  //La vista maneja su propia instancia del formulario de boletas
  frmBol   := TfrmBoleta.Create(self);
  //Configura formulario de boleta
  frmBol.OnAgregarItem  := @frmBoleta_AgregarItem;
  frmBol.OnGrabarBoleta := @frmBoleta_GrabarBoleta;
  frmBol.OnDevolverItem := @frmBoleta_DevolverItem;
  frmBol.OnDesecharItem := @frmBoleta_DesecharItem;
  frmBol.OnRecuperarItem:= @frmBoleta_RecuperarItem;
  frmBol.OnComentarItem := @frmBoleta_ComentarItem;
  frmBol.OnDividirItem  := @frmBoleta_DividirItem;
  frmBol.OnGrabarItem   := @frmBoleta_GrabarItem;
  frmBol.OnReqCadMoneda := @gruposReqCadMoneda;
end;
destructor TfraVista.Destroy;
begin
  decodEst.Destroy;
  motEdi.Destroy;
  inherited;
end;
//Acciones
procedure TfraVista.acFacAgrVenExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  if OnAgrVentaProd = nil then exit;  //No se configuró
  ogFac := FacSeleccionado;
  //if ogFac = nil then exit;
  {Genera comando porque la venta está ligada a la base de datos y esta vista es
  independiente de la base de datos}
  OnAgrVentaProd(ogFac.IdFac);
end;
procedure TfraVista.acEdiElimGruExecute(Sender: TObject);
var
  ogGfac: TogGFac;
begin
  ogGfac := GFacSeleccionado;
  if ogGfac = nil then exit;
  OnSolicEjecCom(CFAC_G_ELIM, 0, 0, ogGfac.IdFac + #9);
end;
procedure TfraVista.acFacGraBolExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  if OnSolicEjecCom = nil then exit;
  ogFac := FacSeleccionado;
  if ogFac = nil then exit;
  if MsgYesNo('Grabar Boleta de: ' + ogFac.Name + '?')<>1 then exit;
  OnSolicEjecCom(CVIS_ACBOLET, ACCBOL_GRA, 0, ogFac.IdFac);
end;
procedure TfraVista.acFacVerBolExecute(Sender: TObject);
var
  ogFac: TogFac;
begin
  ogFac := FacSeleccionado;
  if ogFac = nil then exit;
  frmBol.Exec(ogFac.IdFac, ogFac.Boleta, 'BOLETA DE: ' + ogFac.Name);
end;
procedure TfraVista.acFacMovBolExecute(Sender: TObject);
var
  cabDest: String;
  ogFac: TogFac;
  Fac2: TogFac;
begin
  if OnSolicEjecCom = nil then exit;
  ogFac := FacSeleccionado;
  if ogFac = nil then exit;
  cabDest := InputBox('','Indique ID del destino (Grupo:Nombre): ','');
  if cabDest='' then exit;
  Fac2 := BuscarOgFacID(cabDest);
  if Fac2 = nil then begin
    MsgExc('No se encuentra objeto: ' + Fac2.Name);
    exit;
  end;
  OnSolicEjecCom(CVIS_ACBOLET, ACCBOL_TRA, 0, ogFac.IdFac + #9 + Fac2.idFac);
end;

end.

