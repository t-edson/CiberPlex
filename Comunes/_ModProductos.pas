{Unidad con contenedores definiciones y rutinas para el manejo del alamace´n de productos.}
unit ModProductos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, Types, MisUtils;
type

  //Define el tipo que almacena una ruta (Una línea del archivo de rutas)

{ TregProdu }

TregProdu = class
    cod     : String;   //ALFANUMÉRICO. Código de producto
    cat     : String;   //ALFANUMÉRICO. Categoría de producto
    subcat  : String;   //ALFANUMÉRICO. Sub-categoría
    //nom    : String   'CADENA. Nombre
    desc    : String;   //CADENA. Descripción
//    est     : Boolean  'BOLEAN. Estado: Activado o desactivado
//    not:   : String   'CADENA. Comentarios
//    img     : String   'CADENA. Archivo de imagen
    pUnit   : Double;   //Precio unitario
    stock   : Double;   //Stock de producto
//    stockMin : String   'Stock mínimo de producto
//    rec     : String   'CADENA. Receta para stock de almacén
    tPre    : Double;   //NUMÉRICO. Tiempo de preparación
    //fCre  : date      'FECHA. fecha de creación
    //fMod  : date      'FECHA. fecha de modificación.
    ind     : Integer;  //NUMÉRICO. Posición dentro de la matriz
private
  function regProd_ADisco: String;
  procedure regProd_DeDisco(cad: string);
end;
TregProdu_list = specialize TFPGObjectList<TregProdu>;

var
  Productos: TregProdu_list;   //Almacena los productos
{'Private r As regProdu            'registro de rutas
Public nProd As Integer         'Número de productos leidos de la tabla de productos

Private ProCateg() As String     'Guarda las categorías
Private nProCateg As Integer     'Número de categorías leidas
Private ProSubCat() As String    'Guarda las sub-categorías
Private nProSubCat As Integer    'Número de sub-categorías leidas

Private nlin As Integer         'número de línea

'variables para indicar posición de la columnas. Se usan más como constantes
Public CPRO_CODIGO As Integer
Public CPRO_CATEG As Integer
Public CPRO_SUBCAT As Integer
Public CPRO_PREUNI As Integer
Public CPRO_DESCRI As Integer
Public CPRO_STOCK As Integer
}
  function CargarProductos(archivo: string): string;

implementation
Function TRegProdu.regProd_ADisco: String;
begin
    Result := cod + #9 +
              cat + #9 +
              subcat + #9 + #9 +
              S2f(desc) + #9 + #9 + #9 + #9 +
              N2f(pUnit) + #9 +
              N2f(stock) + #9 + #9 + #9 +
              N2f(tPre) + #9 +
              D2f(Time) + #9 + D2f(Time) + #9 + #9 + #9;
end;

procedure TregProdu.regProd_DeDisco(cad: string);
//Convierte cadena de texto en registro
var
  a: TStringDynArray;
begin
    a := Explode(#9, cad);
    cod := a[0];      //Carga código
    cat := a[1];      //Carga categoría
    subcat := a[2];   //Carga sub-categoría

    desc := f2S(a[4]);   //Carga descripción

    pUnit := f2N(a[8]);  //Carga precio unitario
    stock := f2N(a[9]);  //Carga stock
end;

Function VerificaProducto(r: TregProdu): string;
{Verifica si el registro de producto cumple con la definición.
El error se devuelve como cadena.}
var
  reg: TregProdu;
begin
    Result  := '';   //Inicia mensaje
    //------------------ Verifica Código --------------------
    if r.cod = '' then begin    //Verificación de Código
        Result  := 'No se ha especificado código para: ' + r.desc;
        Exit;       //sale con error
    end;
    //------------------- Verifica Descripción ------------------------
    if r.desc = '' then begin   //Verificación de descripción
        Result  := 'No se ha especificado descripción para CÓDIGO: ' + r.cod;
        Exit;    //sale con error
    end;
    //------------------- Verifica Unicidad de Código ----------------------
    for reg in Productos do begin
        If reg.cod = r.cod then begin
            Result  := 'Código duplicado. (' + r.cod + ')';
            exit;
        end;
    end;
end;

Function CargarProductos(archivo: string): string;
{Carga el archivo de productos indicado.
Si encuentra error, devuelve una cadena con el mensaje de error.}
var
  narc: text;
  linea : String;
  n , nlin: Integer;        //Número de productos leidas
  reg: TregProdu;
  a: TStringDynArray;
begin
  Result := '';
  try
    AssignFile(narc , archivo);
    reset(narc);
    n := 1;
    nlin := 0;
    Productos.Clear;
    while not eof(narc) do begin
        nlin := nlin + 1;
        readln(narc, linea);
        if linea <> '' then begin  //tiene datos
            a := Explode(#9, linea);
            if High(a) <> 17 Then begin      //Verifica cantidad de campos
                Result := 'Error de estructura de producto. Línea: ' + IntToStr(nlin);
                break;
            end;
            reg:= TregProdu.Create;  //crea registro de producto
            reg.regProd_DeDisco(linea);
            reg.ind := n;        //Carga ubicación
            Result := VerificaProducto(reg);  //Verifica consistencia
            Productos.Add(reg);
            If Result <> '' Then break;
            //actualiza contador y estado de carga
            n := n + 1;
            if n Mod 50 = 0 Then begin   //va actualizando estado
                //nProd = n - 1
                //Call MDIPrincipal.RefrescarEstado
                //frmEstado.lblMensaje = nRutas & " productos cargados."
                //DoEvents
            end;
        end;
    end;
    Close(narc);
    exit;  //Puede salir con mensaje de error en "Result".
  except
    on e:Exception do begin
      Result := 'Error cargando productos (' + archivo + '): ' + e.Message;
      //Close(narc);  No cierra ya que si falló al abrir, (lo más común) genera error al intentar cerralo.
    end;
  end;
end;
{
Public Sub ProdADisco()
'Vuelca la información de la tabla de productos a disco. Usa un archivo
'temporal para proteger los datos del archivo original.
'Actualiza la bandera "msjeError".
Dim i As Long, nar As Integer
Dim linea As String
Dim tmp_produc As String
    'Abre archivo de entrada y salida
    On Error GoTo as_error
    tmp_produc = arcProduc & ".tmp"
    nar = FreeFile
    Open tmp_produc For Output As #nar
    'Genera datos a archivo temporal
    For i = 1 To nProd
        Print #nar, regProd_ADisco(Productos(i))
    Next
    Close #nar
    'Actualiza archivo de productos
    Kill arcProduc    'Borra anterior
    Name tmp_produc As arcProduc     'Renombra nuevo
    On Error GoTo 0
    Exit Sub
as_error:
    PLogErr MSJ_ERR_ACTUAL_ALM_ & Err.Description
    msjError = MSJ_ERR_ACTUAL_ALM_ & Err.Description
    Close #nar
    On Error GoTo 0
End Sub

Public Sub ProActualRegistro(ind As Integer, pro As regProdu)
'Actualiza el producto (el que tiene la posición "ind") con el registro indicado
'en el archivo de productos.
    msjError = ""
    Productos(ind) = pro  'actualiza en memoria
    'actualiza archivo
    Call ProdADisco     'Actualiza msjError
End Sub

Public Sub ProNuevoRegistro(pro As regProdu)
'Agrega un nuevo producto al archivo de productos.
'
    msjError = ""
    'agrega registro
    nProd = UBound(Productos) + 1
    ReDim Preserve Productos(nProd)
    Productos(nProd) = pro  'agrega en memoria
    Productos(nProd).ind = nProd
    'actualiza archivo
    Call ProdADisco     'Actualiza msjError
End Sub

Public Sub ProElimRegistro(pro As regProdu)
'Elimina un producto del archivo de productos
'
Dim n As Integer
Dim i As Integer
    msjError = ""
    'elimina de memoria
    For i = pro.ind To nProd - 1
        Productos(i) = Productos(i + 1)
        Productos(i).ind = i  'actualiza el índice
    Next
    nProd = nProd - 1
    ReDim Preserve Productos(nProd)
    'elimina de archivo
    Call ProdADisco     'Actualiza msjError
End Sub

'Public Sub ReponeStock(r As regIBol)
''Repone el stock agregando de nuevo el ítem vendido
'Dim s As regIBol
'    s = r   'copia registro
'    s.Cant = -s.Cant    'cambia
'    ActualizarStock s
'End Sub

Public Sub ActualizarStock(r As regIBol)
'Actualiza el stock del producto indicado en el archivo de productos
'Se crea una copia actualizada y luego se reemplaza la anterior
Dim stock As Integer
Dim codigo As String
Dim pro As regProdu
    pro = BuscarProd(r.codPro)
    If pro.cod = "" Then
        MsgBox "Error en Código de producto": Exit Sub
    End If
    codigo = pro.cod        'toma código
    msjError = ""

    'Verifica cambio de stock
    stock = Productos(pro.ind).stock  'aqui se convierte cadena a número!!!!!
    stock = stock - r.Cant   'actualiza
    If stock < 0 Then
        'Se genera mensaje de error
        PLogErr "No hay disponibilidad de stock: " & pro.cod
    End If
    Productos(pro.ind).stock = stock      'actualiza estado en memoria
    Call ProdADisco     'Actualiza msjError
End Sub
}
{
'***************************************************************
'******************* FUNCIONES DE BÚSQUEDA *********************
'***************************************************************
Public Function BuscarProd(codigo As String) As regProdu
'Busca un producto por el código. Si no encuentra devuelve un
'registro en blanco.
Dim i As Integer
    codigo = UCase(codigo)
    For i = 1 To nProd
        If UCase(Productos(i).cod) = codigo Then
            BuscarProd = Productos(i)
            Exit Function
        End If
    Next
End Function

'Public Function BuscarProdD(descrip As String) As regProdu
''Busca un producto por la descripción. Si no encuentra devuelve un
''registro en blanco.
'Dim i As Integer
'    descrip = UCase(descrip)
'    For i = 1 To nProd
'        If Productos(i).desc = descrip Then
'            BuscarProdD = Productos(i)
'            Exit Function
'        End If
'    Next
'End Function

'**************************************************************************
'******* Funciones para la visualización en una lista de tipo CLista *******
'**************************************************************************

Public Sub InicListaAdmProd(lst As Clista)
'Inicia la lista con los campos que se usan en la ventana de administración
    lst.LimpiarCol
    lst.AgregarCol "CÓDIGO", 800
    lst.AgregarCol "CATEGORÍA", 1000
    lst.AgregarCol "SUB CATEG.", 1000
    lst.AgregarCol "P.UNIT", 600, 1
    lst.AgregarCol "DESCRIPCIÓN", 2500
    lst.AgregarCol "STOCK", 500
'    lst.AgregarCol "CONSUMO", 1000


'    lst.AgregarCol "IMAGEN", 800
'    lst.AgregarCol "ESTADO", 200
'    lst.AgregarCol "NOTAS", 1000
    'actualiza posición de las columnas
    CPRO_CODIGO = 1
    CPRO_CATEG = 2
    CPRO_SUBCAT = 3
    CPRO_PREUNI = 4
    CPRO_DESCRI = 5
    CPRO_STOCK = 6
End Sub

Public Sub InicListaAdmProd2(lst As Clista)
    lst.LimpiarCol
    lst.AgregarCol "CATEGORÍA", 1300
    lst.AgregarCol "SUB-CATEGORÍA", 1300
    lst.AgregarCol "INFORMACIÓN", 2000

    CPRO_CATEG = 1
    CPRO_SUBCAT = 2
End Sub

Public Sub AgregItemProd(lstResult As Clista, prod As regProdu)
'Agrega un ítem a la lista de resultado
Dim stk As Single
    stk = val(prod.stock)
    If stk <= 0 Then
        lstResult.agregar prod.cod & vbTab & prod.cat & vbTab & prod.subcat & vbTab & _
                prod.pUnit & vbTab & _
                prod.desc & vbTab & prod.stock, , RGB(255, 100, 100), False
    Else
        lstResult.agregar prod.cod & vbTab & prod.cat & vbTab & prod.subcat & vbTab & _
                prod.pUnit & vbTab & _
                prod.desc & vbTab & prod.stock, , , False
    End If
End Sub

Public Function ProBuscPorCateg(lista As Clista, clave As String) As Integer
'Raliza una búsqueda de productos por el campo "Sub-Categoría" y actualiza
'la lista con los resultados. Devuelve el número de ocurrencias.
Dim i As Integer
Dim nresul As Integer   'número de resultados
    Call InicListaAdmProd(lista)
    For i = 1 To nProd
        If UCase(Productos(i).cat) Like clave Then
            AgregItemProd lista, Productos(i)
            nresul = nresul + 1
        End If
    Next
    ProBuscPorCateg = nresul
End Function

Public Function ProBuscPorSubCat(lista As Clista, clave As String) As Integer
'Raliza una búsqueda de productos por el campo "Sub-Categoría" y actualiza
'la lista con los resultados. Devuelve el número de ocurrencias.
Dim i As Integer
Dim nresul As Integer   'número de resultados
    Call InicListaAdmProd(lista)
    For i = 1 To nProd
        If UCase(Productos(i).subcat) Like clave Then
            AgregItemProd lista, Productos(i)
            nresul = nresul + 1
        End If
    Next
    ProBuscPorSubCat = nresul
End Function

Public Function ProBuscPorCodigo(lista As Clista, clave As String) As Integer
'Raliza una búsqueda de productos por el campo "Código" y actualiza
'la lista con los resultados. Devuelve el número de ocurrencias.
Dim i As Integer
Dim nresul As Integer   'número de resultados
    Call InicListaAdmProd(lista)
    For i = 1 To nProd
        If UCase(Productos(i).cod) Like clave Then
            AgregItemProd lista, Productos(i)
            nresul = nresul + 1
        End If
    Next
    ProBuscPorCodigo = nresul
End Function

Public Function ProBuscPorDescri(lista As Clista, clave As String) As Integer
'Raliza una búsqueda de productos por el campo "Descripción" y actualiza
'la lista con los resultados. Devuelve el número de ocurrencias.
Dim i As Integer
Dim nresul As Integer   'número de resultados
    Call InicListaAdmProd(lista)
    For i = 1 To nProd
        If CadSim(Productos(i).desc) Like clave Then
            AgregItemProd lista, Productos(i)
            nresul = nresul + 1
        End If
    Next
    ProBuscPorDescri = nresul
End Function

Public Function ProBuscPorStock(lista As Clista, expStock As String) As Integer
'Raliza una búsqueda de productos por el campo "Stock" y actualiza
'la lista con los resultados. Devuelve el número de ocuerrencias.
Dim tmp As String
Dim i As Integer
Dim stock As Single
    Call InicListaAdmProd(lista)
    tmp = Trim(expStock)
    If tmp = "" Then  'búsca todos
        For i = 1 To nProd
            AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like "=*" Then  'búsqueda exacta
        stock = val(Mid$(tmp, 2))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).stock) = stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like ">=*" Then  'búsqueda "mayor que"
        stock = val(Mid$(tmp, 3))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).stock) >= stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like ">*" Then  'búsqueda "mayor que"
        stock = val(Mid$(tmp, 2))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).stock) > stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like "<=*" Then  'búsqueda "menor o igual que"
        stock = val(Mid$(tmp, 3))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).stock) <= stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like "<*" Then  'búsqueda "menor que"
        stock = val(Mid$(tmp, 2))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).stock) < stock Then AgregItemProd lista, Productos(i)
        Next
    Else 'búsqueda exacta
        stock = val(tmp)  'lee valor
        For i = 1 To nProd
            If val(Productos(i).stock) = stock Then AgregItemProd lista, Productos(i)
        Next
    End If
    ProBuscPorStock = lista.nfil
End Function

Public Function ProBuscPorPrecio(lista As Clista, expStock As String) As Integer
'Raliza una búsqueda de productos por el campo "Stock" y actualiza
'la lista con los resultados. Devuelve el número de ocuerrencias.
Dim tmp As String
Dim i As Integer
Dim stock As Single
    Call InicListaAdmProd(lista)
    tmp = Trim(expStock)
    If tmp = "" Then  'búsca todos
        For i = 1 To nProd
            AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like "=*" Then  'búsqueda exacta
        stock = val(Mid$(tmp, 2))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).pUnit) = stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like ">=*" Then  'búsqueda "mayor que"
        stock = val(Mid$(tmp, 3))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).pUnit) >= stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like ">*" Then  'búsqueda "mayor que"
        stock = val(Mid$(tmp, 2))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).pUnit) > stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like "<=*" Then  'búsqueda "menor o igual que"
        stock = val(Mid$(tmp, 3))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).pUnit) <= stock Then AgregItemProd lista, Productos(i)
        Next
    ElseIf tmp Like "<*" Then  'búsqueda "menor que"
        stock = val(Mid$(tmp, 2))  'lee valor
        For i = 1 To nProd
            If val(Productos(i).pUnit) < stock Then AgregItemProd lista, Productos(i)
        Next
    Else 'búsqueda exacta
        stock = val(tmp)  'lee valor
        For i = 1 To nProd
            If val(Productos(i).pUnit) = stock Then AgregItemProd lista, Productos(i)
        Next
    End If
    ProBuscPorPrecio = lista.nfil
End Function

Public Sub ProExplorarCateg()
'Explora las categorías y las guarda en la matriz "ProCateg".
'Actualiza el contador "nProCateg".
Dim i As Integer, j As Integer
Dim cat As String
Dim hay  As Boolean
    nProCateg = 0
    ReDim ProCateg(nProCateg)  'inicia categorías
    For i = 1 To nProd
        cat = Productos(i).cat
        hay = False
        For j = 1 To nProCateg
            If ProCateg(j) = cat Then hay = True: Exit For
        Next
        If Not hay Then 'agrega
            nProCateg = nProCateg + 1
            ReDim Preserve ProCateg(nProCateg)  'inicia categorías
            ProCateg(nProCateg) = cat
        End If
    Next
End Sub

Public Sub ProExplorarSubCat(cat As String)
'Explora las sub-categorías para una categoría y las guarda en la matriz "ProSubCat".
'Actualiza el contador "nProSubCat".
Dim i As Integer, j As Integer
Dim subcat As String
Dim hay  As Boolean
    nProSubCat = 0
    ReDim ProSubCat(nProCateg)  'inicia categorías
    For i = 1 To nProd
        If Productos(i).cat = cat Then
            subcat = Productos(i).subcat
            hay = False
            For j = 1 To nProSubCat
                If ProSubCat(j) = subcat Then hay = True: Exit For
            Next
            If Not hay Then 'agrega
                nProSubCat = nProSubCat + 1
                ReDim Preserve ProSubCat(nProSubCat)  'inicia categorías
                ProSubCat(nProSubCat) = subcat
            End If
        End If
    Next
End Sub

Public Function ProMostrarCateg(lista As Clista) As Integer
'Muestra las categorías encontradas en los productos. Devuelve la
'cantidad de categorías encontradas.
Dim i As Integer
    Call InicListaAdmProd2(lista)
    Call ProExplorarCateg
    For i = 1 To nProCateg
        lista.agregar ProCateg(i) & vbTab & "" & vbTab & "", , , False
    Next
    ProMostrarCateg = nProCateg
End Function

Public Function ProMostrarSubCat(lista As Clista, cat As String) As Integer
'Muestra las sub-categorías de una categoría. Devuelve la
'cantidad de sub-categorías encontradas.
Dim i As Integer
    Call InicListaAdmProd2(lista)
    'lista.vis_grilla = False
    Call ProExplorarSubCat(cat)
    For i = 1 To nProSubCat
        If i = 1 Then
            lista.agregar cat & vbTab & ProSubCat(i) & vbTab & "", , , False
        Else
            lista.agregar vbTab & ProSubCat(i) & vbTab & "", , , False
        End If
    Next
    ProMostrarSubCat = nProSubCat
End Function
}
initialization
  Productos:= TregProdu_list.Create(true);

finalization
  Productos.Destroy;
end.

