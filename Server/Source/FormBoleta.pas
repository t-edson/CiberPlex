{Formulario que permite mostrar el contendio de un objeto Boleta.
El formualrio requiere la referencia a un objeto TCPCabina, apra trabajar.
Se asume que la referecnia, es hacia un TCPCabina copia, que es parte de un visor y no
el TCPCabina original.
Todas las acciones realizadas sobre este formulario, se manifiestan como eventos. El
formulario en sí, no ejecuta ninguna acción sobre el TCPCabina, ya que se supone que
no es el objeto original, sino una copia en un visor.
                                                         Por Tito Hinostroza
}
unit FormBoleta;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, strutils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, Grids, StdCtrls, ActnList, Menus, LCLProc, UtilsGrilla,
  MisUtils, CibFacturables, FormConfig, FormIngVentas;
type
  TevAccionItemBol = procedure(CibFac: TCibFac; idItemtBol, coment: string) of object;
  TevAccionBoleta = procedure(CibFac: TCibFac; coment: string) of object;
  { TfrmBoleta }
  TfrmBoleta = class(TForm)
    acItemAgregar: TAction;
    acItemDevolv: TAction;
    acItemDesech: TAction;
    acItemRecup: TAction;
    acItemComent: TAction;
    acItemDividir: TAction;
    acItemGraSelec: TAction;
    acBolGrabar: TAction;
    ActionList1: TActionList;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    PopupMenu1: TPopupMenu;
    txtTotal: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    grilla: TStringGrid;
    procedure acBolGrabarExecute(Sender: TObject);
    procedure acItemAgregarExecute(Sender: TObject);
    procedure acItemComentExecute(Sender: TObject);
    procedure acItemDesechExecute(Sender: TObject);
    procedure acItemDevolvExecute(Sender: TObject);
    procedure acItemDividirExecute(Sender: TObject);
    procedure acItemGraSelecExecute(Sender: TObject);
    procedure acItemRecupExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    CibFac: TCibFac;
    gri: TUtilGrillaFil;
    function HayCambios(bol: TCibBoleta): boolean;
    function ItemSeleccionado: TCibItemBoleta;
    function LeerItemSeleccionado(var item: TCibItemBoleta; var codigo: string;
      var estado: TItemBoletaEstado): boolean;
    function LlenarFila(f: integer; it: TCibItemBoleta; Cambiar: boolean=true
      ): boolean;
  public  //Eventos que usa la boleta para comunciar sus acciones
    OnGrabarBoleta: TevAccionBoleta;
    OnDevolverItem: TevAccionItemBol;
    OnDesecharItem: TevAccionItemBol;
    OnRecuperarItem: TevAccionItemBol;
    OnComentarItem: TevAccionItemBol;
    OnDividirItem : TevAccionItemBol;
    OnGrabarItem  : TevAccionItemBol;
    procedure ActualizarDatos;
    procedure Exec(CibFac0: TCibFac);
  end;

var
  frmBoleta: TfrmBoleta;

implementation
{$R *.lfm}

{ TfrmBoleta }
function TfrmBoleta.ItemSeleccionado: TCibItemBoleta;
{Devuelve el ítem seleccionado en la grilla.}
begin
  if grilla.Row<1 then exit(nil);
  Result := CibFac.Boleta.items[grilla.Row-1];  //funciona porque se llena en orden
  //cod := grilla.Cells[1, grilla.Row];  //lee código de producto
end;
function TfrmBoleta.LlenarFila(f: integer; it: TCibItemBoleta; Cambiar: boolean = true): boolean;
{Escribe un ítem de boleta en una fila de la grilla, validando su contenido. Si
 debe realizar cambios, devuelve TRUE.}
  procedure ActualizarCelda(c, f: integer; const valor: string);
  begin
    if grilla.Cells[c,f] <> valor then begin
       if Cambiar then grilla.Cells[c,f] := valor;
       Result := true;  //para indicar que hubo o habría cambios.
    end;
  end;
begin
  Result := false;
  ActualizarCelda( 0,f, IntToStr(it.Index+1));
  ActualizarCelda( 1,f, FloatToStr(it.Cant));
  ActualizarCelda( 2,f, it.descr);
  ActualizarCelda( 3,f, CadMoneda(it.pUnit));
  ActualizarCelda( 4,f, CadMoneda(it.subtot));
  ActualizarCelda( 5,f, IntToStr(it.estadoN));
  ActualizarCelda( 6,f, DateTimeToStr(it.vfec));
  ActualizarCelda( 7,f, it.codPro);
  ActualizarCelda( 8,f, IntToSTr(it.fragmen));
  ActualizarCelda( 9,f, ifthen(it.conStk, 'Sí', 'No'));
  ActualizarCelda(10,f, it.coment);
  ActualizarCelda(11,f, it.pVen);
  ActualizarCelda(12,f, it.Id);
end;
function TfrmBoleta.HayCambios(bol: TCibBoleta): boolean;
{Indica si los datos de la grilla, son diferentes a los datos de la boleta que se
 prentende usar para llenar a la grilla.}
var
  itBol : TCibItemBoleta;
  f: Integer;
begin
  Result := false;  //por defecto se asume que no hay cambios
  if grilla.RowCount-1 <> bol.items.Count then
    exit(true);  //diferente cantidad de filas
  f := 1;
//  grilla.RowCount:=CibFac.Boleta.Fitems.Count+1;  //no modificará nada si no hay cambios
  for itBol in CibFac.Boleta.items do begin
    if LlenarFila(f, itBol, false) then
      exit(True);  //Hay diferencias
    f := f + 1;
  end;
end;
procedure TfrmBoleta.ActualizarDatos;
{Actualiza el contenido de la boleta, solo cuando detecta que ha habido cambios en
los ìtems.}
var
  itBol : TCibItemBoleta;
  f: Integer;
begin
  if not HayCambios(CibFac.Boleta) then exit;
  debugln('Actualizando Boleta.');
  grilla.BeginUpdate;
  f := 1;
  grilla.RowCount:=CibFac.Boleta.items.Count+1;  //no modificará nada si no hay cambios
  gri.FijColorFondoGrilla(clWhite);  //pinta de blanco a todas las celdas
  gri.FijColorTextoGrilla(clBlack);  //texto en colro negro pro defecto
  gri.FijAtribTextoGrilla(false, false, false);
  for itBol in CibFac.Boleta.items do begin
    LlenarFila(f, itBol);
    if itBol.fragmen>0 then begin
      gri.FijColorTexto(f, clGreen);
    end;
    if itBol.estado = IT_EST_DESECH then begin
      gri.FijColorTexto(f, clGray);
      gri.FijAtribTexto(f, false, true, false);
    end;
    f := f + 1;
  end;
  grilla.EndUpdate();
  txtTotal.Text := CadMoneda(CibFac.Boleta.TotPag);
end;
procedure TfrmBoleta.Exec(CibFac0: TCibFac);
begin
  CibFac := CibFac0;  //OJO que esta es la cabina de la interfaz gráfica, que es de solo lectura
  Caption := 'BOLETA DE: ' + CibFac.Nombre;
  ActualizarDatos;
  self.Show;
end;
procedure TfrmBoleta.FormCreate(Sender: TObject);
begin
  gri:= TUtilGrillaFil.Create(grilla);
  gri.IniEncab;
  gri.AgrEncabNum('N°'          , 25);
  gri.AgrEncabNum('CANTIDAD'    , 30);
  gri.AgrEncabTxt('DESCRIPCIÓN' ,180);
  gri.AgrEncabNum('PRC.UNITARIO', 55);
  gri.AgrEncabNum('SUBTOTAL'    , 50);
  gri.AgrEncabNum('ESTADO'      , 30).visible := false;
  gri.AgrEncabTxt('FECHA-VENTA' ,105).visible := false;
  gri.AgrEncabTxt('COD.PRODUCTO', 70).visible := false;
  gri.AgrEncabNum('FRAGMENTO'   , 30).visible := false;
  gri.AgrEncabTxt('CON_STOCK'   , 30).visible := false;
  gri.AgrEncabTxt('COMENTARIO'  ,150).visible := false;
  gri.AgrEncabTxt('PTO.VENTA'   , 70).visible := false;
  gri.AgrEncabTxt('ID'          ,105).visible := false;
  gri.FinEncab;
  gri.OpAutoNumeracion:=true;
  gri.OpDimensColumnas:=true;
  gri.OpEncabezPulsable:=true;
  gri.OpResaltarEncabez:=true;
  gri.OpResaltFilaSelec:=true;
  //gri.UsarFrameUtils(fraUtilsGrilla1, nil);
  //gri.UsarTodosCamposFiltro(4);
  gri.MenuCampos:=true;
  gri.PopUpCells := PopupMenu1;
//  fraUtilsGrilla1.OnFiltrado:=@fraUtilsGrilla1Filtrado;
end;
procedure TfrmBoleta.FormDestroy(Sender: TObject);
begin
  gri.Destroy;
end;
function TfrmBoleta.LeerItemSeleccionado(var item: TCibItemBoleta;
         var codigo: string; var estado: TItemBoletaEstado): boolean;
{Lee el ítem seleccionado, y copia el código. Si no hay ítem seleccionado, devuelve FALSE. }
begin
  item := ItemSeleccionado;
  if item = nil then exit(false);
  {En la mayoría de casos, será útil leer inmediatamente las propiedades del ítem, por
  seguridad, en lugar usar la referencia, ya que la referencia al objeto "TCibItemBoleta",
  al que se refiere "item", puede refrescarse si se está leyendo el ítem de un objeto
  gráfico.}
  codigo := item.Id;
  estado := item.estado;
  exit(true);
end;
///////////////////// Acciones
procedure TfrmBoleta.acBolGrabarExecute(Sender: TObject);
begin
  if OnGrabarBoleta<>nil then OnGrabarBoleta(CibFac, '');
end;
//Acciones de ítems
procedure TfrmBoleta.acItemAgregarExecute(Sender: TObject);  //Agrega venta
begin
  frmIngVentas.Exec(CibFac);
end;
procedure TfrmBoleta.acItemDevolvExecute(Sender: TObject);  //Devolver ítem
var
  itTmp: TCibItemBoleta;
  comen, cod: String;
  estado: TItemBoletaEstado;
begin
  if not LeerItemSeleccionado(itTmp, cod, estado) then exit;
  if not itTmp.conStk then begin
    MsgExc('No se puede devolver este ítem.');
    exit;
  end;
  comen := InputBox('', 'Comentario para devolver ítem:', '');
  if comen = '' then begin
    exit;
  end;
  //Genera el evento que debe enviar el comando de devolución de ítem
  if OnDevolverItem<>nil then OnDevolverItem(CibFac, cod, comen);
end;
procedure TfrmBoleta.acItemDesechExecute(Sender: TObject);  //Desechar Ítem
var
  itTmp: TCibItemBoleta;
  comen, cod: String;
  estado: TItemBoletaEstado;
begin
  if not LeerItemSeleccionado(itTmp, cod, estado) then exit;
  if estado = IT_EST_DESECH then begin
    MsgExc('Este ítem ya está desechado.');
    exit;
  end;
  comen := InputBox('', 'Comentario para desechar ítem:', '');
  if comen = '' then begin
    exit;
  end;
  //Genera el evento que debe enviar el comando de devolución de ítem
  if OnDesecharItem<>nil then OnDesecharItem(CibFac, cod, comen);
end;
procedure TfrmBoleta.acItemRecupExecute(Sender: TObject);  //Recuperar ítem desechado
var
  itTmp: TCibItemBoleta;
  cod: string;
  estado: TItemBoletaEstado;
begin
  if not LeerItemSeleccionado(itTmp, cod, estado) then exit;
  if estado = IT_EST_NORMAL then begin
    MsgExc('Este ítem ya está en estado normal.');
    exit;
  end;
  //Genera el evento que debe enviar el comando de devolución de ítem
  if OnRecuperarItem<>nil then OnRecuperarItem(CibFac, cod, '');
end;
procedure TfrmBoleta.acItemComentExecute(Sender: TObject);  //Comentar ítem
var
  itTmp: TCibItemBoleta;
  cod, comen: string;
  estado: TItemBoletaEstado;
begin
  if not LeerItemSeleccionado(itTmp, cod, estado) then exit;
  comen := InputBox('', 'Comentario:', '');
  if comen = '' then begin
    exit;
  end;
  //Genera el evento que debe enviar el comando de devolución de ítem
  if OnComentarItem<>nil then OnComentarItem(CibFac, cod, comen);
end;
procedure TfrmBoleta.acItemDividirExecute(Sender: TObject);  //Dividir ítem
var
  itTmp: TCibItemBoleta;
  cod, comen: string;
  parte, subtot: Double;
  estado: TItemBoletaEstado;
begin
  if not LeerItemSeleccionado(itTmp, cod, estado) then exit;
  subtot := itTmp.subtot;  {Es imporatnte leer el valor antes de usar InputBox, ya que
                           itTmp es una referencia a objetos que son destruidos y
                           construidos periódicamente.}
  if subtot=0 then begin
    MsgExc('No se puede separar un ítem sin costo.');
    exit;
  end;
  comen := InputBox('', 'Monto a separar:', '');
  if comen='' then exit;
  if not TryStrToFloat(comen, parte) then begin
    MsgExc('Error en monto.');
    exit;
  end;
  if parte > 0 then begin
    If parte > subtot Then begin
      MsgExc('Monto a separar muy grande');
      exit;
    end else begin
      //Genera el evento que debe enviar el comando de separación
      if OnDividirItem<>nil then OnDividirItem(CibFac, cod, comen);  //envía monto como cadena
    end;
  end;
end;
procedure TfrmBoleta.acItemGraSelecExecute(Sender: TObject);  //Grabar ítem
var
  itTmp: TCibItemBoleta;
  cod: string;
  estado: TItemBoletaEstado;
begin
  if not LeerItemSeleccionado(itTmp, cod, estado) then exit;
  if MsgYesNo('¿Grabar ítem seleccionado?')<>1 then exit;
  //Genera el evento que debe grabar el ítem.
  if OnGrabarItem<>nil then OnGrabarItem(CibFac, cod, '');
end;


end.

