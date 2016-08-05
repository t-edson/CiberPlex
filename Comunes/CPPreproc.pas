{Unidad que implementa un preprocesador básico de texto al estilo del PreSQL, soportando
la misma sinatxis del NILOTER-m.
Solo se implementa el uso de definiciones, de una sola línea.
Se hace usao de la librería SynFacilSyn y Xpres, para emplementarel lexer.
No se usan las librerías del PreSQL (en su versión Lazarus), porque la implementación
a realizar aquí es muy sencilla, y porque la sintaxis es diferente (DEFINIR en lugar de
$DEFINIR).
                                                      Por Tito Hinostroza 06/07/2016
}
unit CPPreproc;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, LCLProc, SynFacilHighlighter, XpresBas;
Const
  MAX_DEFINICIONES = 50;
type
  tdefinicion = object  //estructura de definicion
      con : String;   //contenido de la definicion
      nom : String;   //nombre de la definicion
      nlin : Integer; //número de línea donde se encuentra la definición
  end;

var
  definiciones: array[0..MAX_DEFINICIONES] of Tdefinicion;
  ndefiniciones : integer;        //numero de definiciones
  xLex : TSynFacilSyn;
  xCon : TContext;

  Function ExisteDefinicion(def: String): integer;
  procedure IniProcesamiento();
  procedure ProcesaLinea2(linea : string; nlin : Integer);

implementation

Function ExisteDefinicion(def: String): integer;
//Si una variable está definida devuelve su índice. Si no existe devuelve -1.
var
  i : integer;
begin
  for i := 1 To ndefiniciones do begin
    if def = definiciones[i].nom Then exit(i);
  end;
  exit(-1);
end;

procedure IniProcesamiento();
//Inicia el procesamiento de líneas
begin
    ndefiniciones := 0;
end;
procedure ProcesaLinea2(linea : string; nlin : Integer);
{Hace la limpieza de una línea que va a ser leida del tarifario o del
archivo de rutas.
Los archivos a leer se procesan por líneas, pro eso esta rutina solo trabaja con
una línea.}
var
  ident : string;
  def : tdefinicion;
  i : Integer;
  tmp : String;
  lineaM : string;
begin
    xCon.SetSource(linea);
    while not xCon.Eof do begin
      debugln(xCon.TokenType.Name + ':' + xCon.Token);
      xCon.Next;
    end;
{
    //Quita comentarios
    If Left$(linea, 2) = '//*' Then linea = '': Exit Sub
    //Quita comentarios al final
    If linea Like '*//*' Then   //hay comentario al final
        linea = Mid$(linea, 1, InStr(linea, '//') - 1)
    End If
    //quita espacios al inicio y final
    linea = Replace(linea, vbTab, ' ')  //tabulaciones a espacios
    linea = Trim(linea)
    lineaM = UCase(linea)   //versión mayúscula.

    ReemplazarDefiniciones linea //reemplaza definiciones
    //---------verifica definición de variables especiales-----------
    If Left$(lineaM, 6) = 'MONEDA' Or Left$(lineaM, 7) = 'PREFIJO' Or _
       Left$(lineaM, 11) = 'ANTIPREFIJO' Then
        //estas variables se pueden definir sin la palabara 'DEFINIR'
        ident = UCase(cogerIdentificador(linea))  //coge identificador
        def.nom = ident //guarda el identificador
        def.nlin = nlin //guarda el número de línea
        linea = LTrim(linea)    //quita espacios
        If Left$(linea, 1) = '=' Then   //---única forma aceptada
            def.con = Mid$(linea, 2)    //toma hasta el fin de la línea
        Else
            msjError = 'Se esperaba //=//': Exit Sub
        End If
        //agrega definición
        ndefiniciones = ndefiniciones + 1
        definiciones(ndefiniciones) = def
        linea = ''  //indica que ya lo procesó
    //---------verifica definiciones----------
    ElseIf Left$(lineaM, 7) = 'DEFINIR' Then
        linea = Mid$(linea, 9)  //toma   'DEFINIR'
        ident = cogerIdentificador(linea)  //coge identificador
        If ident = '' Then msjError = 'Se esperaba identificador': Exit Sub
        def.nom = ident //guarda el identificador
        def.nlin = nlin //guarda el número de línea
        ident = UCase(cogerIdentificador(linea))  //coge 'COMO'
        If ident = 'COMO' Then          //---Versión común de DEFINIR
            If Left$(linea, 1) <> ' ' Then msjError = 'Se esperaba espacio después de //COMO//': Exit Sub
            linea = Mid$(linea, 2)  //quita espacio
            //busca 'FINDEFINIR'
            i = InStr(UCase(linea), 'FINDEFINIR')
            If i = 0 Then msjError = 'Se esperaba //FINDEFINIR//': Exit Sub
            def.con = Mid$(linea, 1, i - 1) //toma contenido
        ElseIf Left$(linea, 1) = '=' Then   //---Versión reducida de DEFINIR
            def.con = Mid$(linea, 2)    //toma hasta el fin de la línea
        Else
            msjError = 'Se esperaba //=//': Exit Sub
        End If
        //agrega definición
        ndefiniciones = ndefiniciones + 1
        definiciones(ndefiniciones) = def
        linea = ''  //indica que ya lo procesó
    End If
    //}
end;

initialization
  xCon := TContext.Create;
  xLex := TSynFacilSyn.Create(nil);   //crea lexer
  ///////////define syntax for the lexer
  xLex.ClearMethodTables;           //limpìa tabla de métodos
  xLex.ClearSpecials;               //para empezar a definir tokens
  //crea tokens por contenido
  xLex.DefTokIdentif('[$A-Za-z_]', '[A-Za-z0-9_]*');
  xLex.DefTokContent('[0-9]', '[0-9.]*', xLex.tkNumber); { TODO : Al parecer esta definición no es exacta para las series por el caracter "*" o '?' que pueden incluir las series }
  //define keywords
  xLex.AddIdentSpecList('begin end else elsif', xLex.tkKeyword);
  xLex.AddIdentSpecList('true false int string', xLex.tkKeyword);
  //create delimited tokens
  xLex.DefTokDelim('''','''', xLex.tkString);
  xLex.DefTokDelim('"','"', xLex.tkString);
  xLex.DefTokDelim('//','', xLex.tkComment);
  xLex.Rebuild;
  xCon.DefSyn(xLex);

finalization
  xLex.Destroy;
  xCon.Destroy;
end.

