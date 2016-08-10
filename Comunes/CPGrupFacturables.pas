{Unidad para definir al objeto TCPGruposFacturables.
Se define como una unidad separada de CPFacturables, porque se necesita incluir a las
unidades que dependen de CPFacturables, y se crearía una dependencia circular. }
unit CPGrupFacturables;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, LCLProc, Forms, CibFacturables,
  //Aquí se incluyen las unidades que definen clases descendientes de TCPFacturables
  CibGFacCabinas, CibGFacNiloM, MisUtils, CibRegistros, CibTramas, CPUtils,
  FormVisorMsjRed;
type
  TEvLeerCadPropiedades = procedure(var cadProp: string) of object;
  { TCibGruposFacturables }
  {Objeto que engloba a todos los grupos facturables. Debe haber solo una instancia para
   toda la aplicación, así que trabaja ccomo un SINGLETON.}
  TCibGruposFacturables = class
  private
    FModoCopia: boolean;
    function GetCadEstado: string;
    function GetCadPropiedades: string;
    procedure gfCambiaPropied;
    procedure gfLogInfo(cab: TCibFac; msj: string);
    procedure SetCadEstado(const AValue: string);
    procedure SetCadPropiedades(AValue: string);
    procedure SetModoCopia(AValue: boolean);
    function ExtraerBloqueEstado(lisEstado: TStringList; var estado, nomGrup: string;
      var tipo: TCibTipGFact): boolean;
    procedure TCibGFacCabinasDetenConteo(cab: TCibFacCabina);
  public
    nombre: string;      //Es un identificador del grupo. Es útil solo para depuración.
    items: TCibGFact_list;  //lista de grupos facturables
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad de algun grupo
    OnLogInfo      : TEvCabLogInfo;    //Indica que se quiere registrar un mensaje en el registro
    OnLeerCadPropiedades: TEvLeerCadPropiedades;
    OnGuardarEstado: procedure of object;
    property ModoCopia: boolean  {Indica si se quiere manejar al objeto sin conexión (como en un visor),
                                  debería hacerse antes de que se agreguen objetos a "items"}
             read FModoCopia write SetModoCopia;
    property CadPropiedades: string read GetCadPropiedades write SetCadPropiedades;
    property CadEstado: string read GetCadEstado write SetCadEstado;
    function NumGrupos: integer;
    function BuscarPorNombre(nomb: string): TCibGFac;
    procedure Agregar(gf: TCibGFac);
    procedure TCibGFacCabinasTramaLista(facOri: TCibFac; tram: TCPTrama;
      tramaLocal: boolean);
  public  //constructor y destructor
    constructor Create(nombre0: string);
    destructor Destroy; override;
  end;

implementation

{ TCibGruposFacturables }
function TCibGruposFacturables.ExtraerBloqueEstado(lisEstado: TStringList;
  var estado, nomGrup: string; var tipo: TCibTipGFact): boolean;
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
      tipo := TCibTipGFact(f2I(a[0]));
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

procedure TCibGruposFacturables.TCibGFacCabinasDetenConteo(cab: TCibFacCabina);
{Se usa este evento para guardar información en el registro, y actualizar la boleta.
Se hace desde fuera de CPGrupoCabinas, porque para estas acciones se requiere acceso a
campos de configuración propios de esta aplicación, que no corresponden a CPGRupoCabinas
que es usada también en el Ciberplex-Visor.}
var
  nser: Integer;
  r: TCibItemBoleta;
begin
  //Registra la venta en el archivo de registro
  if cab.horGra Then { TODO : Revisar si este código se puede uniformizar con las otras llamadas a VentaItem() }
    nser := PLogIntD(cab.RegVenta, cab.Costo)
  else
    nser := PLogInt(cab.RegVenta, cab.Costo);
  If msjError <> '' Then MsgErr(msjError);
  //agrega item a boleta
  r := TCibItemBoleta.Create;   //crea elemento
  r.vser := nser;
  r.Cant := 1;
  r.pUnit := cab.Costo;
  r.subtot := cab.Costo;
  r.cat := cab.Grupo.CategVenta;
  r.subcat := 'INTERNET';
  r.descr := 'Alquiler PC: ' + IntToStr(cab.tSolicMin) + 'm(' +
             TimeToStr(cab.TranscDat) + ')';
  r.vfec := date + Time;
  r.estado := IT_EST_NORMAL;
  r.fragmen := 0;
  r.conStk := False;     //No se descuenta stock
  cab.Boleta.VentaItem(r, False);
  //fBol.actConBoleta;   //Actualiza la boleta porque se hace "VentaItem" sin mostrar
  { TODO : Debería modificarse para generar eventos para escribir en el registro.
No parece buena idea acceder a lso registros desde aquí. }
end;
procedure TCibGruposFacturables.TCibGFacCabinasTramaLista(facOri: TCibFac;
  tram: TCPTrama; tramaLocal: boolean);
{Rutina de respuesta al mensaje OnTramaLista de un Grupo de Cabinas (tramaLocal=FALSE).
También se usa para ejecutar los comandos generados a través de un visor(tramaLocal=TRUE).
Los parámetros son:
 * tramaLocal -> Indica si la trama llegó de forma automática por medio de la conexión de
                 red (FALSE) o si se generó localmente en la misma aplicación.
 * facOri -> Es el objeto facturable origen, de donde llega la trama. Para comandos
             locales, apunta a la instancia del visor, no al modelo original.
 * tram -> Es la trama que contiene el comando que debe ejecutarse.

Como este método ejecuta todos los comandos solicitados por la cabinas de Internet, o de
la aplicación, hace uso de eventos para acceder a información que no está en este ámbito.}
  function IdentificaCabina(var cab: TCibFacCabina; var gru: TCibGFacCabinas): boolean;
  {Identifica al facurable facOri, para ver si es un cabina. De ser así, devuelve la
  referencia al objeto y al grupo en los parámetros y retorna TRUE, sino devuelve FALSE.
  Se asume que la referencia que llega en facOri, es a la copia no al modelo.}
  var
    gfac: TCibGFac;
  begin
    if facOri is TCibFacCabina then begin  //Es CAbina
      //Identifica al grupo.
      gfac := BuscarPorNombre(facOri.Grupo.Nombre);   //asume que "cab.Grupo" es el objeto copia, no el del modelo
      if gfac= nil then exit(false);  //no debería pasar
      gru := TCibGFacCabinas(gfac);  //se supone que es de este tipo
      //Identifica objeto cabina en el modelo, porque
      cab := gru.CabPorNombre(facOri.Nombre);
      exit(true);
    end else begin  //No es
      exit(false);
    end;
  end;
var
  frm: TfrmVisorMsjRed;
  arch: RawByteString;
  HoraPC, tSolic: TDateTime;
  NombrePC, Nomb, tmp: string;
  bloqueado: boolean;
  cabDest: TCibFacCabina;
  tLibre, horGra: boolean;
  itBol, itBol2: TCibItemBoleta;
  a: TStringDynArray;
  parte: Double;
  idx, idx2: LongInt;
  cab: TCibFacCabina;
  gru: TCibGFacCabinas;
begin
  //debugln(NomCab + ': Trama recibida: '+ tram.TipTraHex);
  if not tramaLocal then begin  //Ignora los mensajes locales
    //Valida la clase, aunque se supone que si la trana es remota, debe provenir de una cabina.
    if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
    frm := gru.BuscarVisorMensajes(facOri.Nombre);  //Ve si hay un formulario de mensajes para esta cabina
    {Aunque no se ha detectado consumo de CPU adicional, la búqsqueda regular con
     BuscarVisorMensajes() puede significar una carga innecesaria de CPU, considerando que
     se hace para todos los mensajes que llegan.
     }
    if frm<>nil then frm.PonerMsje('>>Recibido: ' + tram.TipTraNom);  //Envía mensaje a su formulario
  end;
  case tram.tipTra of
  M_ESTAD_CLI: begin  //Se recibió el estado remoto del clente
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      Decodificar_M_ESTAD_CLI(tram.traDat, NombrePC, HoraPC, bloqueado);
      cab.NombrePC:= NombrePC;
      cab.HoraPC  := HoraPC;
      cab.PantBloq:= bloqueado;
    end;
  C_SOL_T_PCS: begin  //Se solicita la lista de tiempos de las PC cliente
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      debugln(cab.Nombre + ': Tiempos de PC solicitado.');
      gru.TCP_envComando(cab.Nombre, M_SOL_T_PCS, 0, 0, gru.CadEstado);
    end;
  C_SOL_ARINI: begin  //Se solicita el archivo INI (No está bien definido)
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      if OnLeerCadPropiedades<>nil then begin
        OnLeerCadPropiedades(tmp);
        gru.TCP_envComando(cab.Nombre, M_SOL_ARINI, 0, 0, tmp);
      end;
    end;
  C_PAN_COMPL: begin  //se pide una captura de pantalla
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      debugln(cab.Nombre+ ': Pantalla completa solicitada.');
      if tram.posX = 0 then begin  //se pide de la PC local
        arch := ExtractFilePath(Application.ExeName) + '~00.tmp';
        PantallaAArchivo(arch);
        gru.TCP_envComando(cab.Nombre, M_PAN_COMP, 0, 0, StringFromFile(arch));
      end else begin

      end;
    end;
  C_INI_CTAPC: begin   //Se pide iniciar la cuenta de una PC
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      DecodActivCabina(tram.traDat, Nomb, tSolic, tLibre, horGra );
      if Nomb='' then exit; //protección
      cabDest := gru.CabPorNombre(Nomb);
      cabDest.InicConteo(tSolic, tLibre, horGra);
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_MOD_CTAPC: begin   //Se pide modificar la cuenta de una PC
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      DecodActivCabina(tram.traDat, Nomb, tSolic, tLibre, horGra );
      if Nomb='' then exit; //protección
      cabDest := gru.CabPorNombre(Nomb);
      cabDest.ModifConteo(tSolic, tLibre, horGra);
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_DET_CTAPC: begin  //Se pide detener la cuenta de las PC
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      cabDest := gru.CabPorNombre(tram.traDat);
      if cabDest=nil then exit;
      if tram.posX = 1 then begin  //Indica que se quiere poner en mantenimiento.
        cabDest.PonerManten();
      end else begin
        cabDest.DetenConteo();
      end;
      if OnGuardarEstado<>nil then OnGuardarEstado;
      { TODO : Por lo que se ve aquí, no sería necesario guardar regularmente el archivo
      de estado, (como se hace actualmente con el timer) , ya que se está detectando cada
      evento que geenra cambios. Verificar si  eso es cierto, sobre todo en el caso de la
      desconexión automático, o algún otro evento similar que requiera guardar el estado.}
    end;
  C_GRA_BOLPC: begin  //Se pide grabar la boleta de una PC
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      cabDest := gru.CabPorNombre(tram.traDat);
      if cabDest=nil then exit;
      for itBol in cabDest.boleta.items do begin
    {    If Pventa = '' Then //toma valor por defecto
            itBol.pVen = PVentaDef
        else    //escribe con punto de venta
            itBol.pVen = Me.Pventa
        end;}
        tmp := itBol.regIBol_AReg;
        If itBol.estado = IT_EST_NORMAL Then PLogIBol(tmp)        //item normal
        else PLogIBolD(tmp);       //item descartado
      end;
      //Graba los campos de la boleta
      cabDest.boleta.fec_grab := now;  //fecha de grabación
      PLogBol(cabDest.Boleta.RegVenta, cabDest.boleta.TotPag);
      //Config.escribirArchivoIni;
    if OnGuardarEstado<>nil then OnGuardarEstado;
      cabDest.LimpiarBol;          //Limpia los items
    end;
  C_AGR_ITBOL: begin  //Se pide agregar una venta
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      tmp := tram.traDat;
      cabDest := gru.CabPorNombre(copy(tmp,1,tram.posY));
      if cabDest=nil then exit;
      delete(tmp, 1, tram.posY);  //quita Nomb, deja cadena de estado
      itBol := TCibItemBoleta.Create;
      itBol.CadEstado := tmp;  //recupera ítem
      cabDest.Boleta.VentaItem(itBol, true);
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_DEV_ITBOL: begin  //Devolver ítem
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      itBol.Cant   := -itBol.Cant;   //pone cantidad negativa
      itBol.subtot := -itBol.subtot; //pone total negativo
      PLogVenD(ItBol.regIBol_AReg, itBol.subtot);  //registra mensaje
      cabDest.Boleta.ItemDelete(a[1]);  //quita de la lista
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_DES_ITBOL: begin  //Desechar ítem
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      itBol.estado := IT_EST_DESECH;
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_REC_ITBOL: begin  //Recuperar ítem
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := '';         //escribe comentario
      itBol.estado := IT_EST_NORMAL;
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_COM_ITBOL: begin  //Comentar ítem
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_DIV_ITBOL: begin
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      //actualiza ítem inicial
      parte := StrToFloat(a[2]);
      itBol.subtot:= itBol.subtot - parte;
      itBol.fragmen += 1;  //lleva cuenta
      //agrega elemento separado
      itBol2 := TCibItemBoleta.Create;
      itBol2.Assign(itBol);  //crea copia
      //actualiza separación
      itBol2.vfec:=now;   //El ítem debe tener otro ID
      itBol2.subtot := parte;
      itBol2.fragmen := 1;      //marca como separado
      itBol2.conStk := false;   //para que no descuente
      cabDest.Boleta.VentaItem(itBol2, true);  //agrega nuevo ítem
      //Reubica ítem
      idx := cabDest.Boleta.items.IndexOf(itBol);
      idx2 := cabDest.Boleta.items.IndexOf(itBol2);
      cabDest.Boleta.items.Move(idx2, idx+1);  //acomoda posición
      cabDest.Boleta.Recalcula;
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  C_GRA_ITBOL: begin
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      If itBol.estado = IT_EST_NORMAL Then PLogIBol(tmp)        //item normal
      else PLogIBolD(tmp);       //item descartado
      cabDest.Boleta.ItemDelete(a[1]);
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if OnGuardarEstado<>nil then OnGuardarEstado;
    end;
  else
    if frm<>nil then frm.PonerMsje('  ¡¡Comando no implementado!!');  //Envía mensaje a su formaulario
  end;
end;
function TCibGruposFacturables.GetCadPropiedades: string;
var
  gf : TCibGFac;
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
procedure TCibGruposFacturables.gfCambiaPropied;
begin
  if OnCambiaPropied<>nil then OnCambiaPropied;
end;
procedure TCibGruposFacturables.gfLogInfo(cab: TCibFac; msj: string);
begin
  if OnLogInfo<>nil then OnLogInfo(cab, msj);
end;

procedure TCibGruposFacturables.SetCadPropiedades(AValue: string);
var
  lin, tmp: string;
  lineas: TStringList;
  tipGru: LongInt;
  grupCab: TCibGFacCabinas;
  gruNiloM: TCibGFacNiloM;
begin
  if trim(AValue) = '' then exit;
  lineas := TStringList.Create;
  lineas.Text:=AValue;  //divide en líneas

debugln(' Limpiando lista para fijar propiedades.');
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
      case TCibTipGFact(tipGru) of
      tgfCabinas: begin
        grupCab := TCibGFacCabinas.Create('CabsSinProp');  //crea la instancia
        grupCab.ModoCopia := FModoCopia;   //fija modo de creación, antes de crear objetos
        grupCab.CadPropied:=tmp;    //asigna propiedades
        items.Add(grupCab);         //agrega a la lista
      end;
      tgfLocutNilo: begin
        gruNiloM := TCibGFacNiloM.Create('NiloSinProp','','','',0,'','');
        gruNiloM.ModoCopia := FModoCopia;   //fija modo de creación, antes de crear objetos
        gruNiloM.CadPropied:=tmp;
        items.Add(gruNiloM);         //agrega a la lista
      end;
      end;
    end else begin
      tmp := tmp + lin + LineEnding;
    end;
  end;
  lineas.Destroy;
end;
procedure TCibGruposFacturables.SetModoCopia(AValue: boolean);
var
  gf : TCibGFac;
begin
//  if FModoCopia=AValue then Exit;
  FModoCopia:=AValue;   //Fija modo
  for gf in items do begin   {Transfiere a todos los posibles objetos creados, aunque lo
                           normal sería que se asigne el modo, cuando no hay ítems}
    gf.ModoCopia:= AValue
  end;
end;
function TCibGruposFacturables.GetCadEstado: string;
var
  gf : TCibGFac;
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
procedure TCibGruposFacturables.SetCadEstado(const AValue: string);
var
  lest: TStringList;
  res: Boolean;
  cad, nombGrup: string;
  tipo: TCibTipGFact;
  gf: TCibGFac;
begin
//debugln('---');
//debugln(AValue);
  lest:= TStringList.Create;
  lest.Text := AValue;  //carga texto
  //Extrae los fragmentos correspondientes a cada Grupo facturable
  while lest.Count>0 do begin
    res := ExtraerBloqueEstado(lest, cad, nombGrup, tipo);
    if not res then break;  //se mostró mensaje de error
    gf := BuscarPorNombre(nombGrup);
    if gf = nil then begin
      //Llegó el estado de un grupo que no existe.
      debugln('Grupo no existente: ' + nombGrup);   //WARNING
      break;
    end;
    gf.CadEstado := cad;   //No importa de que tipo sea
  end;
  //carga el cobtendio del archivo de estado
  lest.Destroy;
end;
function TCibGruposFacturables.NumGrupos: integer;
begin
  Result := items.Count;
end;
function TCibGruposFacturables.BuscarPorNombre(nomb: string): TCibGFac;
{Busca a uno de los grupos de facturables, por su nombre. Si no encuentra, devuelve NIL}
var
  gf : TCibGFac;
begin
//  debugln('-busc:'+nomb);
  for gf in items do begin
    if gf.Nombre = nomb then exit(gf);
  end;
  //no encontró
  exit(nil);
end;
procedure TCibGruposFacturables.Agregar(gf: TCibGFac);
{Agrega un grupo de facturables al objeto}
begin
  //Configura eventos
  gf.OnCambiaPropied := @gfCambiaPropied;
  gf.OnLogInfo:=@gfLogInfo;
  if gf.tipo = tgfCabinas then begin
    TCibGFacCabinas(gf).OnDetenConteo:=@TCibGFacCabinasDetenConteo;
    TCibGFacCabinas(gf).OnTramaLista:=@TCibGFacCabinasTramaLista;
  end;
  //Agrega
  items.Add(gf);
end;
//constructor y destructor
constructor TCibGruposFacturables.Create(nombre0: string);
begin
  nombre := nombre0;
  items := TCibGFact_list.Create(true);
end;
destructor TCibGruposFacturables.Destroy;
begin
  items.Destroy;
  inherited Destroy;
end;

end.

