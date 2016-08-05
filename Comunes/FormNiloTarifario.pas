unit FormNiloTarifario;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  MisUtils, fgl, Types, strutils, CPRegistros, FormInicio,
  CPPreproc;
type

  //Define el tipo que almacena una tarifa (Una línea del archivo tarifario)
  regTarifa = class
    //Campos leidos directamente del archivo tarifario
    serie   : String;     //serie de la tarifa
    paso    : String;     //valor del paso en segundos tal y como se lee
                          //del archivo tarifario
    costop  : String;     //costo del paso tal y como se lee del tarifario
                          //(puede incluir sintaxis de subpaso o costo de paso 1)
    categoria : String ;  //categoría de llamada
    descripcion: String;  //Descripción de la serie
    //Campos calculados
    HaySubPaso : Boolean; //Indica si hay subpaso (y por lo tanto subcosto)
    npaso    : Integer;   //Valor del paso en segundos
    Nsubpaso : Integer;   //Valor del subpaso en segundos
    Ncosto   : Double;    //Valor del costo en flotante
    Nsubcosto: Double;    //Valor del subcosto en flotante
    HayCPaso1: Boolean;   //Indica si hay costo de paso 1
    NCpaso1  : Double;    //Costo del Paso 1 en flotante
    indNT    : Integer;   //índice a colección. Solo se usa en "tarifasA"
  end;
  regTarifa_list = specialize TFPGObjectList<regTarifa>;

  { TfrmNiloTarifario }
  TfrmNiloTarifario = class(TForm)
    SynEdit1: TSynEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    minCostop, maxCostop: Double;
    nlin : integer;
    procedure ActualizarMinMax;
    function BuscaTarifaI(num: String): regTarifa;
    function regTarif_DeEdi(r: regTarifa; cad: string): string;
    procedure VerificaTarifa(r: regTarifa; facCmoneda: double);
    procedure VerificFinal(var numlin: Integer);
  public
    lineas : TStringList;
    monNil : string;
    tarifasTmp: regTarifa_list;
    tarifas: regTarifa_list;
    tarNula: regTarifa;  //tarifa con valores nulos
    msjError: string;
    function BuscaTarifa(num: String): regTarifa;
    function CargarTarifas(archivo: String; facCmoneda: double): Integer;
  end;

var
  frmNiloTarifario: TfrmNiloTarifario;
implementation
{$R *.lfm}
Function SeriesIguales(ser1, ser2 : string): Boolean;
//Compara dos series considerando que "ser2" puede tener el comodín "?"
var
  i : Integer;
begin
    if Length(ser1) <> Length(ser2) Then exit(false);
    if Length(ser1) = 0 Then exit(true);
    For i := 1 To Length(ser1) do begin
        If MidStr(ser2, i, 1) <> '?' Then  begin //el comodín coincide con cualquier cosa
            If MidStr(ser1, i, 1) <> MidStr(ser2, i, 1) Then
                exit(false);
        End;
    end;
    SeriesIguales := True;   //concidieron
End;
function TfrmNiloTarifario.BuscaTarifaI(num: String): regTarifa;
{Devuelve la referencia a una Tarifa para la serie indicada. Si no
encuentra una concidencia, devuelve NIL.
Cuando hay pocos dígitos, no es preciso en ubicar la tarifa.}
var
  clave : string;
  tar: regTarifa;
begin
  clave := num;
  While Length(clave) > 0 do begin
      for tar in Tarifas do begin
          if SeriesIguales(clave, tar.serie) Then exit(tar);
      end;
      clave := LeftStr(num, Length(clave) - 1);
  end;
  //No encuentra concidencia
  Result := nil;
End;
function TfrmNiloTarifario.BuscaTarifa(num: String): regTarifa;
{Devuelve un registro de tipo Tarifa para la serie indicada. Si no
encuentra una concidencia, devuelve un registro con sus campos vacios.
Cuando hay pocos dígitos, no es preciso en ubicar la tarifa.}
begin
  Result := BuscaTarifaI(num);
  if Result = nil then Result := tarNula;
End;
function TfrmNiloTarifario.regTarif_DeEdi(r:regTarifa; cad: string): string;
{Convierte cadena de texto en registro. Se usa para leer del editor
Se asume que el editor sólo tiene espacios como separadores. Las tabulaciones
deben haberse reemplazado previamente. Si hay error, devuelve como cadena.}
begin
  xCon.SetSource(cad);  //carga lexer

  xCon.SkipWhites;
  if xCon.Eof then exit('Campos insuficientes');
  if xCon.TokenType <> xlex.tkNumber then exit('Se esperaba número.');
  r.serie := xCon.Token;
  xCon.Next;   //pasa al siguiente

  xCon.SkipWhites;
  if xCon.Eof then exit('Campos insuficientes');
  if xCon.TokenType <> xlex.tkNumber then exit('Se esperaba número.');
  r.paso := xCon.Token;
  xCon.Next;   //pasa al siguiente

  xCon.SkipWhites;
  if xCon.Eof then exit('Campos insuficientes');
  if xCon.TokenType <> xlex.tkNumber then exit('Se esperaba número.');
  r.costop := xCon.Token;
  xCon.Next;   //pasa al siguiente

  xCon.SkipWhites;
  if xCon.Eof then exit('Campos insuficientes');
  if xCon.TokenType <> xlex.tkString then exit('Se esperaba cadena.');
  r.categoria := xCon.Token;

  xCon.SkipWhites;
  if xCon.Eof then exit('Campos insuficientes');
  if xCon.TokenType <> xlex.tkString then exit('Se esperaba cadena.');
  r.descripcion := xCon.Token;

  xCon.SkipWhites;
  if not xCon.Eof then exit('Demasiados campos');
end;
function TfrmNiloTarifario.CargarTarifas(archivo : String; facCmoneda: double): Integer;
{Carga las tarifas del tarifario indicado.
En condiciones normales actualiza el tarifario y devuelve 0.
Si encuentra error, termina la carga y sale con "msjError" actualizado,
además de devolver el número de línea con error. En ese caso no modifica
el tarifario actual.}
var
  linea : String;
  n : Integer;        //Número de tarifas leidas
  i : Integer;
  tar: regTarifa;
begin
    msjError := '';
    //PLogInf MSJ_CARGAN_TARI     //Cargando Tarifas
    try
      lineas.LoadFromFile(archivo);
    except
      msjError := 'Error leyendo archivo: ' + archivo;
      PLogErr(usuario, msjError);
    end;
    n := 1;
    nlin := 0;
    minCostop := 1000000;
    maxCostop := 0;    //inicia máximo y mínimo
    IniProcesamiento;   //inicia preprocesador
    for linea in lineas do begin
        nlin := nlin + 1;
        ProcesaLinea2(linea, nlin);     //Quita caracteres no válidos
        if msjError <> '' Then begin
            msjError := 'Error cargando tarifas: ' + msjError + ' Línea: ' + IntToStr(nlin);
            break;
        end;
        if linea <> '' then  begin //tiene datos
            tar := regTarifa.Create;
            tarifasTmp.Add(tar);  //agrega nueva tarifa
            msjError := regTarif_DeEdi(tar, linea);
            If msjError <> '' Then break;
            //Verifica si hay duplicidad de serie
            for i:=0 to tarifasTmp.Count-2 do begin  //menos el último
              if tarifasTmp[i].serie = tar.serie then begin
                msjError := 'Serie duplicada: ' + tar.serie + '. Línea: ' + IntToStr(nlin);
                break;
              end;
            end;
            VerificaTarifa(tar, facCmoneda);    //Verifica consistencia y analiza
            If msjError <> '' Then break;
            //actualiza contador y estado de carga
            n := n + 1;
{            If n Mod 50 = 0 then begin   //va actualizando estado
                Call MDIPrincipal.RefrescarEstado
                frmEstado.lblMensaje = CStr(n - 1) + MSJ__TAR_CARGS
                DoEvents
            end;}
        end;
    end;
    //verifica si hubo errores
    if msjError <> '' then begin
      //Salió por error
      PLogErr(usuario, msjError);
      CargarTarifas := nlin;
      exit;    //sale con error y sin actualizar tarifas()
    end else begin
      //Salio sin errores
      VerificFinal(nlin);
      if msjError <> '' then begin
        //Salió por error
        PLogErr(usuario, msjError);
        CargarTarifas := nlin;
        exit;    //sale con error y sin actualizar tarifas()
      end;
    end;
    //terminó la lectura sin errores
    tarifas.Clear;
    tarifas.Assign(tarifasTmp);    //copia tarifas
    tarifasTmp.Clear;     //libera espacio
    PLogInf(usuario, IntToStr(tarifas.Count) + ' tarifas cargadas.');
    ActualizarMinMax;
end;
procedure TfrmNiloTarifario.FormCreate(Sender: TObject);
begin
  lineas:= TStringList.Create;
  tarifasTmp:= regTarifa_list.Create(true);
  tarifas:= regTarifa_list.Create(true);
  tarNula:= regTarifa.Create;  //crea tarifa con campos en blanco
end;
procedure TfrmNiloTarifario.FormDestroy(Sender: TObject);
begin
  tarNula.Destroy;
  tarifas.Destroy;
  tarifasTmp.Destroy;
  lineas.Destroy;
end;
procedure TfrmNiloTarifario.ActualizarMinMax();
//Actualiza valores máximo y mínimo
var
  tar: regTarifa;
  cp: Double;
begin
  For tar in tarifas  do begin
    cp := tar.Ncosto;
    If cp < minCostop Then minCostop := cp;
    If cp > maxCostop Then maxCostop := cp;
    If tar.HaySubPaso Then begin
        cp := tar.NCpaso1;
        If cp < minCostop Then minCostop := cp;
        If cp > maxCostop Then maxCostop := cp;
    End;
  end;
end;
procedure TfrmNiloTarifario.VerificFinal(var numlin : Integer);
//Hace las verificaciones de símbolo de moneda
var
  i : Integer;
  tmp : String;
begin
    i := ExisteDefinicion('MONEDA');
    If i <> -1 Then begin //Se definio la moneda
        tmp := Trim(definiciones[i].con);    //lee moneda
        If Length(tmp) > 2 Then begin
            msjError := 'Símbolo de moneda muy largo. Solo se permiten 2 caracteres.';
            numlin := definiciones[i].nlin;     //posiciona en la definición
        end Else begin
            monNil := LeftStr(tmp + '  ', 2)   //completa con espacios
        End;
    end Else begin           //no se definió la moneda
        msjError := 'No se encontró definición de moneda (MONEDA = XX)';
        numlin := 1;    //posicion al inicio

    End;
End;
procedure TfrmNiloTarifario.VerificaTarifa(r : regTarifa; facCmoneda: double);
//Verifica si el registro de tarifa cumple con la definición.
//Realiza además las adaptaciones necesarias con los campos y completa
//los campos calculados.
//El error se devuelve en "MsjError"
var
  costop: String;
  posi : Integer;
  a: TStringDynArray;
begin
    msjError := '';   //Inicia mensaje
    //------------------ Verifica serie -------------------
    If Not (r.serie[1] in ['0'..'9','*']) Then begin  //Verifica serie
      msjError := 'Error en campo //serie//. Se esperaba valor numérico.';
      Exit;
    end;
    //------------------ Verifica paso --------------------
    if (r.paso[1] in ['0'..'9']) then begin  //Verifica paso
      //Hasta aquí va normal
      if pos('/',  r.paso) <> 0 then begin    //formato con 'subpaso'
          r.HaySubPaso := True;
          a := Explode('/', r.paso);
          r.npaso := StrToInt(a[0]);         //toma paso
          r.Nsubpaso := StrToInt(a[1]);      //toma subpaso
      end Else begin       //Caso normal sólo hay paso
          r.HaySubPaso := False;
          r.npaso := StrToInt(r.paso);
      End;
    end else begin
      msjError := 'Error en serie: //' + r.serie + '//. Paso debe ser númerico';
      exit;
    end;

    //------------------ Verifica costo --------------------
    costop := r.costop;
    if costop[1] in ['0'..'9'] Then begin //Verifica costo
        if Pos(',', costop) <> 0 Then begin  //Verifica costo
            msjError := 'Error en serie: ' + r.serie + '. No se permite uso de coma en costo.';
            Exit;
        end;
        //Verifica si hay costo de paso 1
        If pos(':', costop) <> 0 Then begin
            posi := pos(':', costop);    //lee posición
            r.NCpaso1 := StrToFloat(LeftStr(costop, posi - 1));  //toma costo de paso 1
            r.HayCPaso1 := True;
            costop := copy(costop, posi + 1, length(costop));  //recorta para seguir leyendo
        End;
        //Continúa verficando
        If r.HaySubPaso Then begin
            If pos('/', costop) <> 0 Then begin    //Debería haber subcosto
                a := Explode('/', costop);
                r.Ncosto := StrToFloat(a[0]);       //toma costo de paso
                r.Nsubcosto := StrToFloat(a[1]);    //toma sub costo de paso 1
            end Else begin
                msjError := 'Error en serie: //' + r.serie + '//. Se esperaba subcosto';
                Exit;
            End;
        end Else begin   //No hay subpaso, No debe haber subcosto
            If pos('/', costop) <> 0 Then begin
                msjError := 'Error en serie: //' + r.serie + '//. No se esperaba subcosto';
                Exit;
            end Else begin
                r.Ncosto := StrToFloat(costop);       //toma costo
            End;
        End;
    end Else begin
        msjError := 'Error en serie: //' + r.serie + '//. Costo debe ser númerico';
        Exit;
    End;
    //--------------Verifica codificación de paso---------------
//    CPaso = CPSimple(r.costop)  //toma costo de paso ignorando el subpaso
    if (r.Ncosto / facCmoneda) - Round(r.Ncosto / facCmoneda) <> 0 Then begin
        msjError := 'Error en serie: //' + r.serie +
                    '//. Costo de paso: ' + FloatToStr(r.Ncosto) +
                    ' no se puede codificar con Factor de corrección de moneda actual.';
        Exit;
    end;
//    //--------------Verifica categoría---------------
//    categ = r.categoria
//    If Not (Left$(categ, 1) Like '[0123*]') Then
//        MsjError = 'Error en formato de categoría: //' + categ + '// '
//        Exit Sub
//    End If
end;

end.

