unit RegistrosVentas;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, fgl, strutils, MisUtils;
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
      posHor    : byte;       //Campo temporal para la generación de reportes
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

  TCPCellValues = class
    items : array of double;
    constructor Create(nCols: integer);
  end;
//  Function FechaLOG(const cad : string): TDate;
  function LeeIngreP(reg: regIng; var arc: text; f1, f2: TDate;
           incFactur, incDesech, incGast: Boolean): Boolean;
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
      reg.descrip   := a[11]         ;
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
      reg.descrip   := a[11]         ;
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
      reg.descrip   := a[11];     //toma descripción de llamada
      reg.coment    := a[12];     //aún no hay descripción de llamada
      exit;
  end;
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

{ TCPCellValues }
constructor TCPCellValues.Create(nCols: integer);
//var
//  i: Integer;
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

