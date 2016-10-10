{Unidad para definir al objeto TCPGruposFacturables.
Se define como una unidad separada de CPFacturables, porque se necesita incluir a las
unidades que dependen de CPFacturables, y se crearía una dependencia circular. }
unit CPGrupFacturables;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, LCLProc, Forms, CibFacturables,
  //Aquí se incluyen las unidades que definen clases descendientes de TCPFacturables
  CibGFacCabinas, CibGFacNiloM, MisUtils, CibTramas, CPUtils,
  FormVisorMsjRed;
type
  { TCibGruposFacturables }
  {Objeto que engloba a todos los grupos facturables. Debe haber solo una instancia para
   toda la aplicación, así que trabaja como un SINGLETON.}
  TCibGruposFacturables = class
  private
    FModoCopia: boolean;
    function GetCadEstado: string;
    function GetCadPropiedades: string;
    function gof_LogIngre(ident: char; msje: string; dCosto: Double): integer;
    function gof_LogError(msj: string): integer;
    function gof_LogVenta(ident: char; msje: string; dCosto: Double): integer;
    procedure gof_ActualizStock(const codPro: string; const Ctdad: double);
    function gof_ReqCadMoneda(valor: double): string;
    procedure gof_CambiaPropied;
    function gof_LogInfo(msj: string): integer;
    procedure SetCadEstado(const AValue: string);
    procedure SetCadPropiedades(AValue: string);
    function ExtraerBloqueEstado(lisEstado: TStringList; var estado, nomGrup: string;
      var tipo: TCibTipFact): boolean;
    procedure gof_RequiereInfo(var NombProg, NombLocal, Usuario: string);
  public  //Eventos.
    {Cuando este objeto forma parte del modelo, necesita comunciarse con la aplicación,
    para leer información o ejecutar acciones. Para esto se usan los eventos.}
    OnCambiaPropied: procedure of object; //cuando cambia alguna variable de propiedad de algun grupo
    OnLogInfo      : TEvFacLogInfo;       //Se quiere registrar un mensaje en el registro
    OnLogVenta     : TEvBolLogVenta;      //Se quiere registrar una venta en el registro
    OnLogIngre     : TEvBolLogVenta;      //Se quiere registrar un ingreso en el registro
    OnLogError     : TEvFacLogError;    //Requiere escribir un Msje de error en el registro
//    OnLeerCadPropied: TEvLeerCadPropied;  //requiere leer cadena de propiedades
//    OnLeerCadEstado: TEvLeerCadPropied;   //requiere leer cadena de estado
    OnGuardarEstado: procedure of object;
    OnReqConfigGen : TEvReqConfigGen; //Se requiere información de configruación
    OnReqCadMoneda : TevReqCadMoneda; //Se requiere convertir a formato de moneda
    OnActualizStock: TEvBolActStock;  //Se requiere actualizar el stock
  public
    nombre : string;      //Es un identificador del grupo. Es útil solo para depuración.
    items  : TCibGFact_list;  //lista de grupos facturables
    DeshabEven: boolean;     //deshabilita los eventos
    property ModoCopia: boolean  {Indica si se quiere manejar al objeto sin conexión (como en un visor),
                                  debería hacerse antes de que se agreguen objetos a "items"}
             read FModoCopia;
    property CadPropiedades: string read GetCadPropiedades write SetCadPropiedades;
    property CadEstado: string read GetCadEstado write SetCadEstado;
    function NumGrupos: integer;
    function BuscarPorNombre(nomb: string): TCibGFac;
    procedure Agregar(gof: TCibGFac);
    procedure Eliminar(gf: TCibGFac);
    procedure gof_TramaLista(facOri: TCibFac; tram: TCPTrama;
      tramaLocal: boolean);
  public  //constructor y destructor
    constructor Create(nombre0: string; ModoCopia0: boolean=false);
    destructor Destroy; override;
  end;

implementation

{ TCibGruposFacturables }
function TCibGruposFacturables.ExtraerBloqueEstado(lisEstado: TStringList;
  var estado, nomGrup: string; var tipo: TCibTipFact): boolean;
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
      tipo := TCibTipFact(f2I(a[0]));
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
procedure TCibGruposFacturables.gof_CambiaPropied;
begin
  if not DeshabEven and (OnCambiaPropied<>nil) then OnCambiaPropied;
end;
function TCibGruposFacturables.gof_LogInfo(msj: string): integer;
begin
  if not DeshabEven and (OnLogInfo<>nil) then Result := OnLogInfo(msj);
end;
function TCibGruposFacturables.gof_LogVenta(ident:char; msje:string; dCosto:Double): integer;
begin
  if not DeshabEven and (OnLogVenta<>nil) then
    Result := OnLogVenta(ident, msje, dCosto);
end;
function TCibGruposFacturables.gof_LogIngre(ident: char; msje: string;
  dCosto: Double): integer;
begin
  if not DeshabEven and (OnLogIngre<>nil) then
    Result := OnLogIngre(ident, msje, dCosto);
end;
function TCibGruposFacturables.gof_LogError(msj: string): integer;
begin
  if not DeshabEven and (OnLogError<>nil) then
    Result := OnLogError(msj);
end;
procedure TCibGruposFacturables.gof_TramaLista(facOri: TCibFac;
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
      tmp := CadEstado;
      gru.TCP_envComando(cab.Nombre, M_SOL_T_PCS, 0, 0, tmp);
    end;
  C_SOL_ARINI: begin  //Se solicita el archivo INI (No está bien definido)
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      tmp := CadPropiedades;
      gru.TCP_envComando(cab.Nombre, M_SOL_ARINI, 0, 0, tmp);
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
    end;
  C_MOD_CTAPC: begin   //Se pide modificar la cuenta de una PC
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      DecodActivCabina(tram.traDat, Nomb, tSolic, tLibre, horGra );
      if Nomb='' then exit; //protección
      cabDest := gru.CabPorNombre(Nomb);
      cabDest.ModifConteo(tSolic, tLibre, horGra);
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
      { TODO : Por lo que se ve aquí, no sería necesario guardar regularmente el archivo
      de estado, (como se hace actualmente con el Timer) , ya que se está detectando cada
      evento que genera cambios. Verificar si  eso es cierto, sobre todo en el caso de la
      desconexión automático, o algún otro evento similar que requiera guardar el estado.}
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
    end;
  C_DEV_ITBOL: begin  //Devolver ítem
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      IF itBol=nil then exit;
      itBol.coment := a[2];         //escribe comentario
      cabDest.Boleta.DevolItem(itBol);
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
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
        cabDest.boleta.IngresItem(itBol);   //ingresa el ítem
      end;
      //Graba los campos de la boleta
      cabDest.boleta.fec_grab := now;  //fecha de grabación
      if OnLogIngre<>nil then
        OnLogIngre(IDE_CIB_BOL, cabDest.Boleta.RegVenta, cabDest.boleta.TotPag);
      //Config.escribirArchivoIni;
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
      cabDest.LimpiarBol;          //Limpia los items
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
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
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
    end;
  C_GRA_ITBOL: begin
      if not IdentificaCabina(cab, gru) then exit;  //valida que venga de cabina
      a := Explode(#9, tram.traDat);
      cabDest := gru.CabPorNombre(a[0]);
      if cabDest=nil then exit;
      itBol := cabDest.Boleta.BuscaItem(a[1]);
      if itBol=nil then exit;
      cabDest.boleta.IngresItem(itBol);   //ingresa el ítem
      //Config.escribirArchivoIni;    { TODO : ¿Será necesario? }
      if not DeshabEven and (OnGuardarEstado<>nil) then OnGuardarEstado;
    end;
  else
    if frm<>nil then frm.PonerMsje('  ¡¡Comando no implementado!!');  //Envía mensaje a su formaulario
  end;
end;
procedure TCibGruposFacturables.gof_RequiereInfo(var NombProg,
  NombLocal, Usuario: string);
begin
  if OnReqConfigGen<>nil then begin
    OnReqConfigGen(NombProg, NombLocal, Usuario);
  end else begin
    NombProg := '';
    NombLocal := '';
    Usuario := '';
  end;
end;
function TCibGruposFacturables.gof_ReqCadMoneda(valor: double): string;
begin
  if OnReqCadMoneda=nil then Result := ''
  else Result := OnReqCadMoneda(valor);
end;
procedure TCibGruposFacturables.gof_ActualizStock(const codPro: string;
  const Ctdad: double);
begin
  {Porpaga el evento, ya que se supone que no se tiene acceso al alamacén desde aquí}
  if not DeshabEven and (OnActualizStock<>nil) then OnActualizStock(codPro, Ctdad);
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

  items.Clear;  //elimina todos para crearlos de nuevo
  lin := lineas[0];  //toma primera línea
  //
  lineas.Delete(0);   //elimina primera línea
  for lin in lineas do begin
    if copy(lin,1,2) = '[[' then begin  //Marca de inicio
      tipGru := StrToInt(copy(lin, 3, length(lin)));
      tmp:='';  //inicia acumulación
    end else if lin = ']]' then begin  //Marca de fin,
      //Ya se tiene la cadena de propiedades para el nuevo grupo
      //Crea al grupo, en el mismo modo (ModoCopia), con que se ha creado esre objeto.
      case TCibTipFact(tipGru) of
      ctfCabinas: begin
        grupCab := TCibGFacCabinas.Create('CabsSinProp', ModoCopia);  //crea la instancia
        grupCab.CadPropied:=tmp;    //asigna propiedades
        Agregar(grupCab);         //agrega a la lista
      end;
      ctfNiloM: begin
        gruNiloM := TCibGFacNiloM.Create('NiloSinProp', ModoCopia);
        gruNiloM.CadPropied:=tmp;
        Agregar(gruNiloM);         //agrega a la lista
      end;
      end;
    end else begin
      tmp := tmp + lin + LineEnding;
    end;
  end;
  lineas.Destroy;
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
  tipo: TCibTipFact;
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
procedure TCibGruposFacturables.Agregar(gof: TCibGFac);
{Agrega un grupo de facturables al objeto. Notar que esta rutina solo configura
los eventos, antes de agregar.}
begin
  //Configura eventos
  gof.OnCambiaPropied:= @gof_CambiaPropied;
  gof.OnLogInfo      := @gof_LogInfo;
  gof.OnLogVenta     := @gof_LogVenta;
  gof.OnLogIngre     := @gof_LogIngre;
  gof.OnLogError     := @gof_LogError;
  gof.OnReqConfigGen := @gof_RequiereInfo;
  gof.OnReqCadMoneda := @gof_ReqCadMoneda;
  gof.OnActualizStock:= @gof_ActualizStock;
  case gof.tipo of
  ctfCabinas: begin
    TCibGFacCabinas(gof).OnTramaLista:=@gof_TramaLista;
  end;
  ctfNiloM: begin
    {Se aprovecha aquí para leer los archivos de configuración. No se encontró un mejor
    lugar, ya que lo que se desea, es que los archivos de configuración se carguen solo
    una vez, sea que el NILO-m se agrege por el  menú principal o se carge del archivo
    de configuración.}
    if not TCibGFacNiloM(gof).ModoCopia then begin
      //En modo copia, no se cargan las configuraciones
      TCibGFacNiloM(gof).LeerArchivosConfig;   //si genera error, muestra su mensaje
    end;
  end;
  end;
  //Agrega
  items.Add(gof);
  if not DeshabEven and (OnCambiaPropied<>nil) then OnCambiaPropied;
end;
procedure TCibGruposFacturables.Eliminar(gf: TCibGFac);
begin
  items.Remove(gf);
  if not DeshabEven and (OnCambiaPropied<>nil) then OnCambiaPropied;
end;
//constructor y destructor
constructor TCibGruposFacturables.Create(nombre0: string; ModoCopia0: boolean = false);
begin
  nombre := nombre0;
  FModoCopia:=ModoCopia0;   //Define el modo de trabajo
  items := TCibGFact_list.Create(true);
end;
destructor TCibGruposFacturables.Destroy;
begin
  items.Destroy;
  inherited Destroy;
end;

end.

