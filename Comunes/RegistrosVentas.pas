unit RegistrosVentas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, fgl, strutils, MisUtils, LConvEncoding, Globales;
type
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

  //Estructura para un registro de eventos
  regEven = class
      ident    : String;      //caracter de identificación
      serie    : String;
      FECHA_LOG: TDate ;
      USUARIO  : String;     //Usuario
      descrip  : String;
  end;

  {Contenedor de valores para crear reprotes acumulados}

  { TCPCellValues }
  {Usado para reportes agrupados}
  TCPCellValues = class
    items : array of double;
    constructor Create(nCols: integer);
  end;

  procedure CreaListaArchivos(lista: TStringList; fec1, fec2: TDate;
             camino, nom_loc: string);
//  Function FechaLOG(const cad : string): TDate;
  function LeeIngreP(reg: regIng; var arc: text; f1, f2: TDate;
           incFactur, incDesech, incGast: Boolean): Boolean;
  procedure LeerIngresos(regs: regIng_list; f1, f2: TDate; local: string;
             incFactur, incDesech, incGast: Boolean);
  procedure LeerIngresosCatSub(regs: regIng_list; f1, f2: TDate; local: string;
    const categ, subcat, prod: string);
var
  msjError: string;
//**************************************************************************************//
implementation
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
  Result[n-1] := str;
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
     DateTimeToString(tmp, '_yyyy_mm', fec);
     AgregarMes(camino + '\' + nom_loc + '.0' + tmp + '.log');
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
procedure LeerIngresos(regs: regIng_list; f1, f2: TDate; local: string;
           incFactur, incDesech, incGast: Boolean);
{Lee los archivos, en el intervalo de fechas indicada.
Carga un alista de registros de tipo "regIng".}
var
  arc: text;
  arcLog: String;
  reg: regIng;
  lstArchivos: TStringList;
begin
  lstArchivos:= TStringList.Create;
  try
    CreaListaArchivos(lstArchivos, f1, f2, rutApp + '\datos', Local);
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
procedure LeerIngresosCatSub(regs: regIng_list; f1, f2: TDate; local: string;
  const categ, subcat, prod: string);
{Lee los registros del periodo indicado, los registros de venta. Realiza un filtrado
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
    CreaListaArchivos(lstArchivos, f1, f2, rutApp + '\datos', Local);
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
                      true, false, false) do begin
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

{ TCPCellValues }
constructor TCPCellValues.Create(nCols: integer);
begin
  setlength(items, nCols);  //define tamaño del contenedor
//  for i:=0 to high(items) do items[i] := 0;
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

