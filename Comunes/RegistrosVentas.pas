{Unidad con definiciones sobre los datos generados en el archivo de registro de Ciberplex.
Se incluyen también, rutinas útiles para el procesamiento de estos registros y para la
generación de reportes.}
unit RegistrosVentas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, fgl, strutils, dateutils, MisUtils, LConvEncoding;
type
  TevReqCadMoneda = function(valor: double): string of object;

  //Estructura para registros de venta:
  regVen = class
      ident     : String;      //caracter de identificación
      serie     : String;     //Número de serie del registro
      FECHA_LOG : TDate ;     //Fecha en que se genera el registro de venta
      USUARIO   : String;     //Usuario
      vfec      : TDate ;     //fecha de la venta
      cat       : String;     //categoría o tipo de la llamada
      subcat    : String;     //sub-categoría
      codPro    : String;     //código de producto
      Cant      : String;     //cantidad de productos
      pUnit     : String;     //precio unitario
      total     : Double;     //total
      stkIni    : String;     //stock inicial
      descrip   : String;     //descripción
      coment    : String;     //comentario
      pUnitR    : Double;     //precio unitario real
  end;

  { regIng }
  //Estructura para registros de ingresos
  regIng = class
      ident     : String;      //caracter de identificación
      serie     : String;     //Número de serie del registro
      FECHA_LOG : TDate ;     //Fecha en que se genera el registro de venta
      USUARIO   : String;     //Usuario
      vser      : String;     //número de serie de la venta :ociada
      vfec      : TDate ;     //fecha de la venta
      cat       : String;     //categoría o tipo del ítem
      subcat    : String;     //sub-categoría
      codPro    : String;     //código de producto
      Cant      : Double;     //cantidad de productos
      pUnit     : String;     //precio unitario
      total     : Double;     //total
      estado    : String;     //estado del item
      descrip   : String;     //decsripción
      fragment  : String;     //propiedad "fragment"
      coment    : String;     //comentario
      pVen      : String;     //punto de venta
  public
      posHor    : word;       //Campo temporal para la generación de reportes
      function FECHA_LOG_str: string; inline;
      function vfec_str: string; inline;
  end;
  regIng_list = specialize TFPGObjectList<regIng>;

  //Estructura para cdrs de alquiler de cabin:
  regCab = class
      ident     : String ;    //caracter de identificación
      serie     : String ;    //Número de serie del registro
      FECHA_LOG : TDate  ;    //Fecha en que se genera el registro de venta
      fecha_ini : TDate  ;    //Fecha-hora de inicio de alquiler
      USUARIO   : String ;    //Usuario
      codigo    : String ;    //código de producto
      categoria : String ;    //categoría o tipo de alquiler
      T_TRANS   : integer;    //tiempo transcurrido en segundos (***Se mantiene por compatibilidad***)
      total     : String ;    //costo actual
      tipo      : String ;    //tipo de servicio "NORMAL, GRATIS o LIBRE "
      T_SOLIC   : String ;    //Tiempo solicitado en minutos (***Se mantiene por compatibilidad***)
      tTrans    : TDate  ;    //Tiempo transcurrido
      tSolic    : TDate  ;    //Tiempo solicitado
      NOMB_PC   : String ;    //Nombre de PC
      estCon    : integer;    //Estado de conexión
      T_PAUSS   : Integer;    //Tiempo que estuvo pausado en segundos
  end;

  //Estructura para un registro de eventos o de error

  { regEven }

  regEven = class
      ident    : String;      //caracter de identificación
      serie    : String;
      FECHA_LOG: TDate ;
      USUARIO  : String;     //Usuario
      descrip  : String;
  public
    posHor    : word;       //Campo temporal para la generación de reportes
    function FECHA_LOG_str: string; inline;
  end;
  regEven_list = specialize TFPGObjectList<regEven>;

  {Contenedor de valores para crear reprotes acumulados}

  //Tipo de agrupamiento de fechas
  TAgrVer = (
    tavDia,  //por día
    tavSem,  //por semana
    tavMes,  //por mes
    tavTot   //total, un solo agrupamiento
  );

  { TCPCellValues }
  {Usado para reportes agrupados. Es una lista de valores numéricos ubicados
  horizontalmente en una tabla. Representa a los contadores o mediciones de una fila.}
  TCPCellValues = class
  public
    items : array of double;
  public  //Campo usados solamente para el calculo de los reportes agrupados por promedio
    {"dias" se usa para llevar la cuenta de los días que agrupa esta categoría de fecha,
    ya que se espera tener un TCPCellValues por cada fila que representa a una fecha.}
    dias : TStringList;
    procedure RegistrarFecha(fec: TDateTime; agrVert: TAgrVer; fecAgrup: string);
  public  //Inicialización
    constructor Create(nCols: integer);
    destructor Destroy; override;
  end;

  function FechaACad(const fec: TDateTime; agrupVert: TAgrVer; correcDia: integer): string;
  Function FechaLOG(const cad : string): TDate;
  procedure CreaListaArchivos(lista: TStringList; fec1, fec2: TDate;
             camino, nom_loc: string);
  function LeeIngreP(reg: regIng; var arc: text; f1, f2: TDate;
           incFactur, incDesech, incGast: Boolean): Boolean;
  procedure LeerIngresos(regs: regIng_list; f1, f2: TDate; local: string;
             incFactur, incDesech, incGast: Boolean; rutDatos: string);
  procedure LeerIngresosCatSub(regs: regIng_list; f1, f2: TDate; local: string;
             const categ, subcat, prod: string; rutDatos: string);
  procedure LeerIngresosCatSubExc(regs: regIng_list; f1, f2: TDate; local: string;
             const categ, subcat: string; excList: TStrings; rutDatos: string);
  procedure LeerEventos(regs: regEven_list; f1, f2: TDate; local: string;
    const incInfo, incError: Boolean; rutDatos: string);
var
  msjError: string;
//**************************************************************************************//
implementation
function FechaACad(const fec: TDateTime; agrupVert: TAgrVer; correcDia: integer): string;
{Convierte uan fecha en una cadena, de acuerdo al formato indicado en "agrupVert".}
var
  fec2: TDateTime;
  numAno, numSem: Word;
begin
  case agrupVert of
  tavDia:
    DateTimeToString(Result, 'yyyy/mm/dd', fec);
  tavSem: begin
      //Se debe generar el número de año y semana: yyyy-ww
      fec2 := fec - correcDia + 6;  //corrección de inicio de semana
      numSem := WeekOfTheYear(fec2, numAno);
      Result := Format('%d-%.2d', [numAno, numSem]);
    end;
  tavMes:
    DateTimeToString(Result, 'yyyy-mm', fec);  //agrupa por mes
  tavTot:
    Result := 'Todos';
  end;
end;
Function FechaLOG(const cad : string): TDate;
//Lee una fecha en formato "yyyy/mm/dd hh:nn:ss"
var
  y, m, d, h, n, s: word;
  dat: TDateTime;
begin
  {Rutina rápida de conversión, ya que usando IntToStr(), se obtenía un tiempo que
  era 5 veces más lento. }
  y := 2000 + 10*(ord(cad[3])-48) + ord(cad[4]) - 48;
  m := 10*(ord(cad[6])-48) + ord(cad[7]) - 48;
  d := 10*(ord(cad[9])-48) + ord(cad[10]) - 48;
  h := 10*(ord(cad[12])-48) + ord(cad[13]) - 48;
  n := 10*(ord(cad[15])-48) + ord(cad[16]) - 48;
  s := 10*(ord(cad[18])-48) + ord(cad[19]) - 48;
  TryEncodeDate(y,m,d, dat);  //Es más rápido que EncodeDate():
  Result := dat + h/HoursPerDay + n/MinsPerDay +  s/SecsPerDay;
end;
function Explotar(delimiter:char; const str:string; nCam: integer):TStringDynArray;
{Rutina optimizada para esta unidad. "nCam" es la cantidad de campos a extraer.}
var
  p, n, ini:integer;
begin
  n := 0;
  SetLength(Result, nCam);  //hace espacio
  ini := 1;
  while true do begin
    p := posEx(delimiter,str, ini);
    if p > 0 then begin
      inc(n);
      Result[n-1] := copy(str, ini, p-ini);
      ini := p+1;
    end else break;
    if n>=nCam then exit;  //ya no sigue extrayendo
  end;
  inc(n);
  Result[n-1] := copy(str, ini, length(str));
end;
Function LeeIngre(const linea : String; reg: regIng) : boolean;
//Lee un registro de venta de una línea de texto.
var
  a: TStringDynArray;
begin
  Result := false;
  If linea[1] = 'b' then begin  //ítem de boleta
      a := Explotar(#9, linea, 17);
      if high(a) < 16 then begin
          msjError := 'Error en estructura de registro de Ítem: ' + a[0] + #9 + a[1];
          MsgErr(msjError);
          exit;
      end;
      reg.ident     := a[0][1];
      reg.serie     := copy(a[0], 3, 100);
      //reg.FECHA_LOG := FechaLOG(a[1]);  Ya se tiene calculado
      reg.USUARIO   := a[2]          ;
      reg.vser      := a[3]          ;
      reg.vfec      := FechaLOG(a[8])     ;
      reg.subcat    := a[4]          ;
      reg.Cant      := StrToFloat(a[5]);
      reg.pUnit     := a[6]          ;
      reg.total     := StrToFloat(a[7]);
      reg.estado    := a[9]          ;
      reg.descrip   := CP1252ToUTF8(a[11]);
      reg.coment    := a[12]         ;
      reg.fragment  := a[13]         ;
      reg.cat       := a[14]         ;
      reg.codPro    := a[15]         ;
      reg.pVen      := a[16]         ;
      exit;
  end else If linea[1] = 'x' then begin  //ítem de boleta descartado
      a := Explotar(#9, linea, 17);
      if high(a) < 13 then begin
          msjError := 'Error en estructura de registro de Ítem descartado';
          exit;
      end;
      reg.ident     := a[0][1];
      reg.serie     := copy(a[0], 3, 100);
      //reg.FECHA_LOG := FechaLOG(a[1]);  Ya se tiene calculado
      reg.USUARIO   := a[2]          ;
      reg.vser      := a[3]          ;
      reg.vfec      := FechaLOG(a[8])     ;
      reg.subcat    := a[4]          ;
      reg.Cant      := StrToFloat(a[5]);
      reg.pUnit     := a[6]          ;
      reg.total     := StrToFloat(a[7]);
      reg.estado    := a[9]          ;
      reg.descrip   := CP1252ToUTF8(a[11]);
      reg.coment    := a[12]         ;
      reg.fragment  := a[13]         ;
      reg.cat       := a[14]         ;
      reg.codPro    := a[15]         ;
      reg.pVen      := a[16]         ;
      exit;
  end else if linea[1] = 'g' then begin   //gasto
      a := Explotar(#9, linea, 13);
      if High(a) < 12 then begin
          msjError := 'Error en estructura de registro de Gasto';
          exit;
      end;
      reg.ident     := a[0][1];
      reg.serie     := copy(a[0], 3, 100);
      //reg.FECHA_LOG := FechaLOG(a[1]);  Ya se tiene calculado
      reg.USUARIO   := a[2];
      reg.vser      := a[3];      //toma el código del gasto
      reg.cat       := a[4];      //lee categoría
//        reg.CANTIDAD = 1
//        reg.p_unit  = a(9)      //toma costo de NILOTER
      reg.total     := -StrToFloat(a[7]);  //se toma como negativo
      reg.estado    := a[8] ;     //lee stock
      reg.descrip   := CP1252ToUTF8(a[11]);     //toma descripción de llamada
      reg.coment    := a[12];     //aún no hay descripción de llamada
      exit;
  end;
end;
function LeeEvent(const linea : String; reg: regEven) : boolean;
//Lee un registro de evento de una línea de texto.
var
  a: TStringDynArray;
begin
  Result := false;
  If linea[1] = 'i' then begin  //ítem de boleta
      a := Explotar(#9, linea, 4);
      if high(a) < 3 then begin  {¿Se ejecutará alguna vez?}
          msjError := 'Error en estructura de registro de Ítem: ' + a[0] + #9 + a[1];
          MsgErr(msjError);
          exit;
      end;
      reg.ident     := a[0][1];
      reg.serie     := copy(a[0], 3, 100);
      //reg.FECHA_LOG := FechaLOG(a[1]);  Ya se tiene calculado
      reg.USUARIO   := a[2]          ;
      reg.descrip   := CP1252ToUTF8(a[3]);
      exit;
  end else If linea[1] = 'e' then begin  //ítem de boleta descartado
      a := Explotar(#9, linea, 4);
      if high(a) < 3 then begin
          msjError := 'Error en estructura de registro de Ítem descartado';
          exit;
      end;
      reg.ident     := a[0][1];
      reg.serie     := copy(a[0], 3, 100);
      //reg.FECHA_LOG := FechaLOG(a[1]);  Ya se tiene calculado
      reg.USUARIO   := a[2]          ;
      reg.descrip   := CP1252ToUTF8(a[3]);
      exit;
  end;
end;
procedure CreaListaArchivos(lista: TStringList; fec1, fec2: TDate;
  camino, nom_loc: string);
{Devuelve en "lista", una lista de los archivos que incluyen registros del intervalo
de días entre fec1 y fec2.}
  procedure AgregarMes(mes: string);
  begin
    if lista.IndexOf(mes)<>-1 then exit;
    lista.Add(mes);
  end;
var
  fec: TDate;
  tmp: string;
begin
  lista.Clear;
  //calcula los meses necesarios a consultar
  fec := fec1;
  while fec <= fec2 do begin
     DateTimeToString(tmp, 'yyyy_mm', fec);
     AgregarMes(camino + DirectorySeparator + nom_loc + '.' + tmp + '.GENERAL.log');
     fec := fec +1;
  end
end;
function LeeIngreP(reg: regIng; var arc: text; f1, f2: TDate;
           incFactur, incDesech, incGast: Boolean): Boolean;
{Lee del archivo hasta encontrar una línea de registro de ingreso (item de
boleta, egreso o gasto) entre las fechas indicadas y con los filtros indicados.
Si encuentra el reegistro, devuelve TRUE.}
var
  fec: TDate;
  p: integer;
  linea: string;
begin
  while Not EOF(arc) do begin
    readln(arc, linea);
    if linea = '' then continue;
    //inicio de registro de venta (venta, internet o llamada)
    If (incFactur And (linea[1] = 'b')) Or
       (incDesech And (linea[1] = 'x')) Or
       (incGast   And (linea[1] = 'g')) Then begin
        p := pos(#9, linea);
        If p = 0 Then begin
            msjError := 'Error en estructura de Registro de Ingreso';
            exit(false);
        end;
        fec := FechaLOG(copy(linea,p+1,19));
        if (fec >= f1) And (fec <= f2) Then begin
            LeeIngre(linea, reg);    //lee completo
            reg.FECHA_LOG:=fec;    //se escribe fuera porque ya se tiene calculado
            exit(true);     //está en el rango de fechas
        end;
    end;
  end;
  Result := False;   //Es el fin de archivo
end;
function LeeEventP(reg: regEven; var arc: text; f1, f2: TDate;
           const incInfo, incError: Boolean): Boolean;
{Lee del archivo hasta encontrar una línea de registro de evento o error,
entre las fechas indicadas y con los filtros indicados.
Si encuentra el reegistro, devuelve TRUE.}
var
  fec: TDate;
  p: integer;
  linea: string;
begin
  while Not EOF(arc) do begin
    readln(arc, linea);
    if linea = '' then continue;
    //inicio de registro de venta (venta, internet o llamada)
    If (incInfo And (linea[1] = 'i')) Or
       (incError And (linea[1] = 'e')) Then begin
        p := pos(#9, linea);
        If p = 0 Then begin
            msjError := 'Error en estructura de Registro de Eventos';
            exit(false);
        end;
        fec := FechaLOG(copy(linea,p+1,19));
        if (fec >= f1) And (fec <= f2) Then begin
            LeeEvent(linea, reg);    //lee completo
            reg.FECHA_LOG:=fec;    //se escribe fuera porque ya se tiene calculado
            exit(true);     //está en el rango de fechas
        end;
    end;
  end;
  Result := False;   //Es el fin de archivo
end;
function SiCumpleFiltCatSub(reg: regIng; const categ, subcat, prod: string): boolean;
{Verifica si un registro, cumple con el filtrado de categoría/subcategoría/producto.}
begin
  if categ = '' then begin
    Result := true;
  end else begin
    //Hay una categoría seleccioada
    if subcat = '' then begin
      //Solo es filtro de categoría
      Result := reg.cat = categ;
    end else begin
      //Hay filtro de categoría-subcategoría
      if prod = '' then begin
        Result := (reg.cat = categ) and (reg.subcat = subcat);
      end else begin
        Result := (reg.cat = categ) and (reg.subcat = subcat) and (reg.descrip = prod);
      end;
    end;
  end;
end;
function SiCumpleFiltCatSubExc(reg: regIng; const categ, subcat: string; excList: TStrings): boolean;
{Verifica si un registro, cumple con el filtrado de categoría/subcategoría y que además no
esté en la lista de productos indicada.}
var
  prod: String;
begin
  if categ = '' then begin
    Result := true;
  end else begin
    //Hay una categoría seleccioada
    if subcat = '' then begin
      //Solo es filtro de categoría
      Result := reg.cat = categ;
    end else begin
      //Hay filtro de categoría-subcategoría
      if (reg.cat <> categ) or (reg.subcat <> subcat) then
        exit(false);   //Falla en categoría-subcategoría
      //Ahora busca en la lista
      for prod in excList do begin
        if reg.descrip = prod then exit(false);  //ya está
      end;
      exit(true);  //no está en la lista
    end;
  end;
end;
procedure LeerIngresos(regs: regIng_list; f1, f2: TDate; local: string;
           incFactur, incDesech, incGast: Boolean; rutDatos: string);
{Lee los archivos, en el intervalo de fechas indicada.
Carga una lista de registros de tipo "regIng".}
var
  arc: text;
  arcLog: String;
  reg: regIng;
  lstArchivos: TStringList;
begin
  lstArchivos:= TStringList.Create;
  try
    CreaListaArchivos(lstArchivos, f1, f2, rutDatos, Local);
    //Genera lista de registros en "regs".
    regs.Clear;
    reg:= regIng.Create;  //crea primer objeto
    for arcLog in lstArchivos do begin
      if not FileExists(arcLog) then begin
        MsgExc('No se encuentra archivo: ' + arcLog);
        continue;
      end;
      AssignFile(arc , arcLog);
      reset(arc);
      while LeeIngreP(reg, arc, f1, f2 + 1-1/23/60/60,
                      incFactur, incDesech, incGast) do begin
  //      debugln(reg.ident + ',' + reg.serie + ',' + reg.descrip);
        regs.Add(reg);  //agrega el actual
        reg:= regIng.Create;  //Deja otro listo para el siguiente
      end;
      CloseFile(arc);
    end;
    reg.Destroy;  //Destruye el siguiente
  finally
    lstArchivos.Destroy;
  end;
end;
procedure LeerIngresosCatSub(regs: regIng_list; f1, f2: TDate; local: string;
  const categ, subcat, prod: string; rutDatos: string);
{Lee los registros de venta del periodo indicado. Realiza un filtrado
de acuerdo a la categoría, subcategoría o producto indicado.
Carga un alista de registros de tipo "regIng".}
var
  arc: text;
  arcLog: String;
  reg: regIng;
  lstArchivos: TStringList;
begin
  lstArchivos:= TStringList.Create;
  try
    CreaListaArchivos(lstArchivos, f1, f2, rutDatos, Local);
    //Genera lista de registros en "regs".
    regs.Clear;
    reg:= regIng.Create;  //crea primer objeto
    for arcLog in lstArchivos do begin
      if not FileExists(arcLog) then begin
        MsgExc('No se encuentra archivo: ' + arcLog);
        continue;
      end;
      AssignFile(arc , arcLog);
      reset(arc);
      while LeeIngreP(reg, arc, f1, f2 + 1-1/23/60/60, true, false, false) do begin
        //Agrega registro, si cumple con filtro
        if SiCumpleFiltCatSub(reg, categ, subcat, prod) then begin
          regs.Add(reg);  //agrega el actual
          reg:= regIng.Create;  //Deja otro listo para el siguiente
        end;
      end;
      CloseFile(arc);
    end;
    reg.Destroy;  //Destruye el siguiente
  finally
    lstArchivos.Destroy;
  end;
end;
procedure LeerIngresosCatSubExc(regs: regIng_list; f1, f2: TDate; local: string;
  const categ, subcat: string; excList: TStrings; rutDatos: string);
{Versión de LeerIngresosCatSub(), que incluye una lista de productos. Solo considera a los
 que no están en la lista.}
var
  arc: text;
  arcLog: String;
  reg: regIng;
  lstArchivos: TStringList;
begin
  lstArchivos:= TStringList.Create;
  try
    CreaListaArchivos(lstArchivos, f1, f2, rutDatos, Local);
    //Genera lista de registros en "regs".
    regs.Clear;
    reg:= regIng.Create;  //crea primer objeto
    for arcLog in lstArchivos do begin
      if not FileExists(arcLog) then begin
        MsgExc('No se encuentra archivo: ' + arcLog);
        continue;
      end;
      AssignFile(arc , arcLog);
      reset(arc);
      while LeeIngreP(reg, arc, f1, f2 + 1-1/23/60/60, true, false, false) do begin
        //Agrega registro, si cumple con filtro
        if SiCumpleFiltCatSubExc(reg, categ, subcat, excList) then begin
          regs.Add(reg);  //agrega el actual
          reg:= regIng.Create;  //Deja otro listo para el siguiente
        end;
      end;
      CloseFile(arc);
    end;
    reg.Destroy;  //Destruye el siguiente
  finally
    lstArchivos.Destroy;
  end;
end;
procedure LeerEventos(regs: regEven_list; f1, f2: TDate; local: string;
  const incInfo, incError: Boolean; rutDatos: string);
{Lee los registros de eventos o errores del periodo indicado. Realiza un filtrado
de acuerdo a una palabra de búsqueda.
Carga una lista de registros de tipo "regIng".}
var
  arc: text;
  arcLog: String;
  reg: regEven;
  lstArchivos: TStringList;
begin
  lstArchivos:= TStringList.Create;
  try
    CreaListaArchivos(lstArchivos, f1, f2, rutDatos, Local);
    //Genera lista de registros en "regs".
    regs.Clear;
    reg:= regEven.Create;  //crea primer objeto
    for arcLog in lstArchivos do begin
      if not FileExists(arcLog) then begin
        MsgExc('No se encuentra archivo: ' + arcLog);
        continue;
      end;
      AssignFile(arc , arcLog);
      reset(arc);
      while LeeEventP(reg, arc, f1, f2 + 1-1/23/60/60,
                      incInfo, incError) do begin
        regs.Add(reg);  //agrega el actual
        reg:= regEven.Create;  //Deja otro listo para el siguiente
      end;
      CloseFile(arc);
    end;
    reg.Destroy;  //Destruye el siguiente
  finally
    lstArchivos.Destroy;
  end;
end;

{ regEven }
function regEven.FECHA_LOG_str: string;
begin
  DateTimeToString(Result, 'yyyy/mm/dd hh:nn:ss', FECHA_LOG);
end;

{ TCPCellValues }
procedure TCPCellValues.RegistrarFecha(fec: TDateTime; agrVert: TAgrVer;
  fecAgrup: string);
{Actualiza la lista "dias" con la fecha que corresponde de "fec", porque esto se
necesita para los reportes que muestran promedio por día.}
var
  fecYYYYMMDD: String;
  i: Integer;
begin
  //Obtiene "fec" en formato de cadena YYYYMMDD,
  if agrVert = tavDia then begin
    fecYYYYMMDD := fecAgrup;  //Ya se hizo la onversión
  end else begin
    //Convierte a fec a formato de "yyyy/mm/dd".
    DateTimeToString(fecYYYYMMDD, 'yyyy/mm/dd', fec);
  end;
  //Agrega a la lista "días"
  if dias.Find(fecYYYYMMDD, i) then begin
    //Ya existe
  end else begin
    dias.Add(fecYYYYMMDD);  //Agrega
  end;
end;
constructor TCPCellValues.Create(nCols: integer);
begin
  setlength(items, nCols);  //define tamaño del contenedor
//  for i:=0 to high(items) do items[i] := 0;
  dias := TStringList.Create;
  dias.Sorted := true;  //Para poder realizar las búsquedas con Find
end;
destructor TCPCellValues.Destroy;
begin
  dias.Destroy;
  inherited Destroy;
end;

{ regIng }
function regIng.FECHA_LOG_str: string;
begin
  DateTimeToString(Result, 'yyyy/mm/dd hh:nn:ss', FECHA_LOG);
end;
function regIng.vfec_str: string;
begin
  DateTimeToString(Result, 'yyyy/mm/dd hh:nn:ss', vfec);
end;

end.

