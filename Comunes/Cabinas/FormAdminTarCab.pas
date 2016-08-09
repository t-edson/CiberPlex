unit FormAdminTarCab;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, dateutils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, ActnList, Menus, StdCtrls, Buttons, LCLProc, Spin,
  MisUtils, CibCabinaTarifas, FrameCPTarifDia;
type

  TfraCPTarifDia_list = specialize TFPGObjectList<TfraCPTarifDia>;

  { TfrmAdminTarCab }
  TfrmAdminTarCab = class(TForm)
    acTAlqNuev: TAction;
    acTAlqElim: TAction;
    acTAlqModif: TAction;
    acTAlqNuePas: TAction;
    acPasNuev: TAction;
    acPasElim: TAction;
    acPasEdit: TAction;
    acTDiaNueFra: TAction;
    acTDiaElimTod: TAction;
    acTDiaReporte: TAction;
    acTAlqCons: TAction;
    ActionList1: TActionList;
    BitAceptar: TBitBtn;
    BitAplicar: TBitBtn;
    BitCancel: TBitBtn;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    menTarDia: TPopupMenu;
    menTarAlqList: TPopupMenu;
    menPaso: TPopupMenu;
    MenuItem1: TMenuItem;
    menTarAlq: TPopupMenu;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    spnToler: TSpinEdit;
    TreeView1: TTreeView;
    procedure acPasEditExecute(Sender: TObject);
    procedure acPasElimExecute(Sender: TObject);
    procedure acPasNuevExecute(Sender: TObject);
    procedure acTAlqConsExecute(Sender: TObject);
    procedure acTAlqElimExecute(Sender: TObject);
    procedure acTAlqModifExecute(Sender: TObject);
    procedure acTAlqNuePasExecute(Sender: TObject);
    procedure acTAlqNuevExecute(Sender: TObject);
    procedure acTDiaElimTodExecute(Sender: TObject);
    procedure acTDiaNueFraExecute(Sender: TObject);
    procedure acTDiaReporteExecute(Sender: TObject);
    procedure BitAceptarClick(Sender: TObject);
    procedure BitAplicarClick(Sender: TObject);
    procedure BitCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tarDiaClickDerecho(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TreeView1Edited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure TreeView1EditingEnd(Sender: TObject; Node: TTreeNode;
      Cancel: Boolean);
    procedure TreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    dias        : TfraCPTarifDia_list;  //lista de frames
    diaActual: TfraCPTarifDia;
    msjAgregFranja: string;
    function AgregarFrame(nomObj: string; nomTar: string): TfraCPTarifDia;
    function AgregaNodoTarAlq(nomb: string): TTreeNode;
    function AgregaNodoPaso(nodTarAlq: TTreeNode; nomb: string): TTreeNode;
    function NumNodosTAlq: integer;
    procedure ValidaPasoDeTexto(txt: string; var paso: integer; var costo: double);
    procedure MostEnVentana;
    procedure LeerDeVentana(grpTarAlq0: TGrupoTarAlquiler;
      tarCabinas0: TCPTarifCabinas);
  public
    grpTarAlq: TGrupoTarAlquiler;
    grpTarAlq_tmp: TGrupoTarAlquiler;  //temporal
    tarCabinas: TCPTarifCabinas;
    tarCabinas_tmp: TCPTarifCabinas;  //temporal
    MsjErr : string;
    OnModificado: procedure of object;
    procedure IniciarPorDefecto;
  end;

var
  frmAdminTarCab: TfrmAdminTarCab;

implementation
{$R *.lfm}
const
  MAX_TAR_ALQ = 5;
  //Colores para las tarifas de alquiler y franjas
  colores:array[1..MAX_TAR_ALQ] of TColor =(
    TColor($A0A0FF),
    TColor($A0FFA0),
    TColor($FFA0A0),
    TColor($A0FFFF),
    TColor($5050A0));
{ TfrmAdminTarCab }
//Rutinas Auxiliares
function TfrmAdminTarCab.NumNodosTAlq: integer;
{Devuelve la cantidad de tarifas de alquiler en el TreeView}
var
  nod: TTreeNode;
begin
  Result := 0;
  for nod in  TreeView1.Items do begin
    if nod.Level = 0 then inc(Result);
  end;
end;
function TfrmAdminTarCab.AgregaNodoTarAlq(nomb: string): TTreeNode;
//Agrega un nodo de Traifa de Alquiler
begin
  Result := TreeView1.Items.AddChild(nil, nomb);
  Result.ImageIndex:=0;
  Result.SelectedIndex:=0;
  //carga información de color como refer. a objeto
  Result.Data:= Pointer(colores[NumNodosTAlq]);
end;
function TfrmAdminTarCab.AgregaNodoPaso(nodTarAlq: TTreeNode; nomb: string
  ): TTreeNode;
begin
  Result := TreeView1.Items.AddChild(nodTarAlq, nomb);
  Result.ImageIndex:=3;
  Result.SelectedIndex:=3;
end;
procedure TfrmAdminTarCab.ValidaPasoDeTexto(txt: string; var paso: integer;
  var costo: double);
{Valida si un texto tiene el formato definido para un paso. El formato es de tipo:
  60 min = 2.0
  30 min = 1.0
  20 min = 0.6
  ...
Si el formato es apropiado, devuelve los valores en "paso" y "costo". En caso
contrario, actualiza "MsjErr"}
var
  p: Integer;
  costoStr: String;
  pasoStr: String;
begin
  //ignora los epsacios
  txt := StringReplace(txt,' ','', [rfReplaceAll]);
  txt := Upcase(txt);
  p := pos('MIN=',txt);
  if p = 0 then begin
    MsjErr := 'Error en paso. Se espera la forma: 60 min = 1.0';
    exit;
  end;
  costoStr := copy(txt, p+4, 10);
  pasoStr := copy(txt, 1, p-1);
  try
    paso := StrToInt(pasoStr);
    costo := StrToFloat(costoStr);
  except
    MsjErr := 'Error en paso. Se espera la forma: 60 min = 1.0';
    debugln('Error en paso. Se espera la forma: 60 min = 1.0');
    exit;
  end;
end;
function TfrmAdminTarCab.AgregarFrame(nomObj: string; nomTar: string): TfraCPTarifDia;
{Crea un frame y lo agrega a la lista de frames. El nombre "nomTar", se muestra
 como título del Frame, y es el nombre que se usará por defecto para la tarifa, cuando
 no exista un archivo INI en Ciberplex}
var
  tarDia: TfraCPTarifDia;
begin
  tarDia := TfraCPTarifDia.Create(self);
  tarDia.Name := nomObj;
  tarDia.Parent := self;
  tarDia.OnClickDerecho:=@tarDiaClickDerecho;  //No usa OnMouseUp, proque es usado por el frame
  tarDia.nombre := nomTar;  //eset nombre aparcerá como ´titulo del Frame
  dias.Add(tarDia);
  Result := tarDia;
end;
procedure TfrmAdminTarCab.tarDiaClickDerecho(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  it: TMenuItem;
  nod: TTreeNode;
begin
  //actualiza el día que se está editando
  diaActual := TfraCPTarifDia(Sender);
  menTarDia.Items.Clear;
  for nod in  TreeView1.Items do begin
    if nod.Level = 0 then begin
      it := AddItemToMenu(menTarDia.Items,
                          msjAgregFranja + nod.text, @acTDiaNueFraExecute);
      it.ImageIndex:=0;
    end;
  end;

  AddItemToMenu(menTarDia.Items,'-', nil);
  it := AddItemToMenu(menTarDia.Items,
                      '&Eliminar todas las Tarifas', @acTDiaElimTodExecute);
  it.imageIndex := 1;
  it := AddItemToMenu(menTarDia.Items,
                      '&Reporte de Tarifas', @acTDiaReporteExecute);
  it.imageIndex := 4;
  menTarDia.PopUp;
end;
//Eventos del formulario
procedure TfrmAdminTarCab.FormCreate(Sender: TObject);
var
  dia: TfraCPTarifDia;
  xIni: Integer;
  xFin: Integer;
  sep: Integer;
begin
  msjAgregFranja := 'Agregar tarifa: ';
  dias := TfraCPTarifDia_list.Create(false);
  AgregarFrame('lun', 'Lunes');
  AgregarFrame('mar', 'Martes');
  AgregarFrame('mie', 'Miércoles');
  AgregarFrame('jue', 'Jueves');
  AgregarFrame('vie','Viernes');
  AgregarFrame('sab','Sábado');
  AgregarFrame('dom','Domingo');
  AgregarFrame('fer','Feriado');
  //ubica frames
  xIni := TreeView1.Left+ TreeView1.Width + 10;
  xFin := self.Width-5;
  sep := (xFin-xIni) div 8;
  for dia in dias do begin
    dia.Top := 24;
    dia.Left := xIni;
    dia.Width:= sep;
    dia.Height:=260;
    Inc(xIni, sep)
  end;
  //configura eventos
  TreeView1.OnMouseUp:=@TreeView1MouseUp;
  TreeView1.OnEditingEnd:=@TreeView1EditingEnd;
  TreeView1.OnEdited:=@TreeView1Edited;
  //Crea objetos temporales
  grpTarAlq_tmp:= TGrupoTarAlquiler.Create;  //temporal
  tarCabinas_tmp:= TCPTarifCabinas.Create(grpTarAlq_tmp);  //temporal
end;
procedure TfrmAdminTarCab.FormDestroy(Sender: TObject);
begin
  tarCabinas_tmp.Destroy;
  grpTarAlq_tmp.Destroy;
  dias.Destroy;
end;
procedure TfrmAdminTarCab.FormShow(Sender: TObject);
begin
  MostEnVentana;
end;
procedure TfrmAdminTarCab.TreeView1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then begin
    //botón derecho
    if TreeView1.Selected=nil then begin
      //no hay elemento seleccionado
      menTarAlqList.PopUp(Mouse.CursorPos.x, Mouse.CursorPos.y);
    end else begin
      //hay seleccionado
      if TreeView1.Selected.Level=0 then begin
        //Tarifa de alquiler seleccionada
        menTarAlq.PopUp(Mouse.CursorPos.x, Mouse.CursorPos.y);
      end else begin
        //Paso seleeccionado
        menPaso.PopUp(Mouse.CursorPos.x, Mouse.CursorPos.y);
      end;
    end;
  end;
end;
procedure TfrmAdminTarCab.TreeView1EditingEnd(Sender: TObject; Node: TTreeNode;
  Cancel: Boolean);
begin
end;
procedure TfrmAdminTarCab.TreeView1Edited(Sender: TObject; Node: TTreeNode;
  var S: string);
var
  paso: integer;
  costo: double;
begin
  if Node.Level = 1 then begin
    //Es nodo de paso
    MsjErr := '';
    ValidaPasoDeTexto(S, paso, costo);
    if self.MsjErr<>'' then  begin
      MsgExc(self.MsjErr);
//      Node.Selected:=true;
//      Node.EditText;
//      Cancel := true;
      exit;
    end;
  end;
end;
procedure TfrmAdminTarCab.MostEnVentana;
{Refresca lasa tarifas de alquiler y las tarifas de cabinas}
var
  ta: TTarAlquiler;
  pa: TTarPaso;
  nod: TTreeNode;
  dia : TfraCPTarifDia;
begin
  if not Self.Visible then exit;
  //muestra grupo de tarifas de aluiler
  if grpTarAlq = nil then exit;
  //Refresca el arbol con la lista de Tarifas de Alquiler
  TreeView1.BeginUpdate;
  TreeView1.Items.Clear;
  for ta in grpTarAlq.items do begin
    nod := AgregaNodoTarAlq(ta.nombre);
    for pa in ta.pasos do begin
      AgregaNodoPaso(nod, IntToStr(pa.paso) + 'min=' + FloatToStr(pa.cost));
    end;
    nod.Expanded:=true;
  end;
  TreeView1.EndUpdate;
  //muestra tarifas de cabinas
  dias[0].strObj:= tarCabinas.horLunes.StrObj;
  dias[1].strObj:= tarCabinas.horMartes.StrObj;
  dias[2].strObj:= tarCabinas.horMiercol.StrObj;
  dias[3].strObj:= tarCabinas.horJueves.StrObj;
  dias[4].strObj:= tarCabinas.horViernes.StrObj;
  dias[5].strObj:= tarCabinas.horSabado.StrObj;
  dias[6].strObj:= tarCabinas.horDomingo.StrObj;
  dias[7].strObj:= tarCabinas.horFeriado.StrObj;
  for dia in dias do begin
    dia.ActualizColorFranjas(TreeView1); //asigna colores de fondo
  end;
  spnToler.Value := tarCabinas.tolerMin;
end;
procedure TfrmAdminTarCab.LeerDeVentana(grpTarAlq0: TGrupoTarAlquiler;
                                        tarCabinas0: TCPTarifCabinas );
{Hace lo inverso a MostEnVentana. Lee las propiedades de la ventana y lo actualiza en
 los objetos grpTarAlq0 y grpTarAlq0.
 OJO: Si encuentra un error en las Tarifas de alquiler, deja a "grpTarAlq0", a medio
 modificar.}
var
  nod: TTreeNode;
  nodPas: TTreeNode;
  ta: TTarAlquiler;
  paso: integer;
  costo: double;
begin
  //Graba grupo de tarifas de alquiler
  //Debe hacerse antes de modificar tarCabinas0, para la validación
  grpTarAlq0.items.Clear;
  self.MsjErr := '';
  for nod in  TreeView1.Items do begin
    if nod.Level = 0 then begin
      //agrega la tarifa de alquiler
      ta := grpTarAlq0.Agregar(nod.Text);
      if grpTarAlq0.msjError<>'' then begin
        MsgExc(grpTarAlq0.msjError);
        nod.Selected:=true;
        exit;
      end;
      //agrega los pasos
      nodPas := nod.GetFirstChild;
      while nodPas<>nil do begin
        //extrae campos del texto del nodo
        ValidaPasoDeTexto(nodPas.Text, paso, costo);
        if self.MsjErr<>'' then  begin
          nodPas.Selected:=true;
          exit;
        end;
        ta.AgregaPaso(paso, costo);
        if ta.msjError<>'' then begin
          self.MsjErr := ta.msjError;
          nodPas.Selected:=true;
          exit;
        end;
        nodPas := nod.GetNextChild(nodPas);
      end;
    end;
  end;
  //Graba tarifas de cabinas
  tarCabinas0.horLunes.StrObj   := dias[0].strObj;
  tarCabinas0.horMartes.StrObj  := dias[1].strObj;
  tarCabinas0.horMiercol.StrObj := dias[2].strObj;
  tarCabinas0.horJueves.StrObj  := dias[3].strObj;
  tarCabinas0.horViernes.StrObj := dias[4].strObj;
  tarCabinas0.horSabado.StrObj  := dias[5].strObj;
  tarCabinas0.horDomingo.StrObj := dias[6].strObj;
  tarCabinas0.horFeriado.StrObj := dias[7].strObj;
  tarCabinas0.Validar;
  if tarCabinas0.msjError<>'' then begin
    self.MsjErr:= tarCabinas0.msjError;  //hace suyo el error
  end;
  tarCabinas.tolerMin := spnToler.Value;
end;
procedure TfrmAdminTarCab.IniciarPorDefecto;
{Llena el frame con valores por defecto}
var
  dia: TfraCPTarifDia;
  nod: TTreeNode;
begin
   TreeView1.Items.Clear;
   acTAlqNuevExecute(nil);  //crea tarifa por defecto
   nod := TreeView1.Items[0];
   //agrega la tarifa
   for dia in dias do begin
     dia.EliminarFranjas;
     dia.AgregarFranja(nod.Text);
     dia.ActualizColorFranjas(TreeView1); //asigna colores de fondo
   end;
end;
procedure TfrmAdminTarCab.BitAceptarClick(Sender: TObject);
begin
  BitAplicarClick(Self);
  if self.MsjErr<>'' then exit;  //hubo error
  self.Close;  //sale si no hay error
end;
procedure TfrmAdminTarCab.BitAplicarClick(Sender: TObject);
{Se aceptan los cambios, en el objeto "grpTarAlq". }
begin
  //valida primero en objetos temporales, para no malogralos en caso de error
  LeerDeVentana(grpTarAlq_tmp, tarCabinas_tmp);      //Escribe propiedades de los frames
  if self.MsjErr<>'' then begin
    MsgExc(self.MsjErr);
    exit;
  end;
  //ahora aplica a los objetos reales
  LeerDeVentana(grpTarAlq, tarCabinas);      //Escribe propiedades de los frames
  MostEnVentana;  //para refrescar lo que se ha modificado en "grpTarAlq"
  if OnModificado<>nil then OnModificado();
end;
procedure TfrmAdminTarCab.BitCancelClick(Sender: TObject);
begin
  self.Hide;
end;
procedure TfrmAdminTarCab.acTAlqNuevExecute(Sender: TObject);
{Agrega tarifa de alquiler}
var
  idx: Integer;
  nomb: String;
  nod: TTreeNode;
begin
  //Genera nombre distinto
  idx := NumNodosTAlq+1;
  nomb := 'Tarifa' + IntToStr(idx);
  while BuscaNodoTarAlquiler(TreeView1, nomb)<>nil do begin
    Inc(idx);
    nomb := 'Tarifa' + IntToStr(idx);
  end;
  //Agrega Nodo y sus pasos por defecto
  if NumNodosTAlq >= MAX_TAR_ALQ then begin
    MsgExc('No se puede agregar más tarifas de alquiler');
    exit;
  end;
  nod := AgregaNodoTarAlq(nomb);
  AgregaNodoPaso(nod, '60 min=' + FloatToStr(2.0));
  AgregaNodoPaso(nod, '30 min=' + FloatToStr(1.0));
  AgregaNodoPaso(nod, '15 min=' + FloatToStr(0.5));
  nod.Expanded:=true;
end;
procedure TfrmAdminTarCab.acTAlqElimExecute(Sender: TObject);
var
  nod: TTreeNode;
begin
  nod := TreeView1.Selected;
  if nod = nil then exit;
//  if MsgYesNo('¿Eliminar Tarifa de Alquiler ' + nom + '?') = 2 then exit;
  TreeView1.Items.Delete(nod);
end;
procedure TfrmAdminTarCab.acTAlqModifExecute(Sender: TObject);
var
  nod: TTreeNode;
begin
  nod := TreeView1.Selected;
  if nod = nil then exit;
  nod.EditText;
end;
procedure TfrmAdminTarCab.acTAlqConsExecute(Sender: TObject);
var
  tmp: String;
  nod: TTreeNode;
  ta: TTarAlquiler;
  tiempo: TDateTime;
  transc: Integer;
  costo: Double;
begin
  //primero valida la consistencia de las tarifas
  LeerDeVentana(grpTarAlq_tmp, tarCabinas_tmp);      //Escribe propiedades de los frames
  if self.MsjErr<>'' then begin
    MsgExc(self.MsjErr);
    exit;
  end;
  //ubica tarifa temporal creada
  nod := TreeView1.Selected;
  if nod = nil then exit;
  ta := grpTarAlq_tmp.TarAlqPorNombre(nod.Text);
  if ta = nil then exit;
  //pide tiempo
  while true do begin
    tmp := InputBox('', 'Ingrese tiempo(hh:mm:ss):', '');
    if tmp = '' then exit;
    try
      tiempo := StrToTime(tmp);
    except
      MsgExc('Error en fecha');
      exit;
    end;
    transc := HourOf(tiempo)*3600+MinuteOf(tiempo)*60+SecondOf(tiempo);
    costo := ta.CostoAlq(transc);
    msgbox('El costo de alquiler es: %n', [costo]);
  end;
end;
procedure TfrmAdminTarCab.acTAlqNuePasExecute(Sender: TObject);
{Agrega nuevo paso a tarifa de alquiler}
var
  nod: TTreeNode;
begin
  nod := TreeView1.Selected;
  if nod = nil then exit;
  if nod.Level<>0 then exit;
  nod := AgregaNodoPaso(nod, '60 min=' + FloatToStr(2.0));
  nod.EditText;
end;
procedure TfrmAdminTarCab.acTDiaNueFraExecute(Sender: TObject);
{Agrega uan franja}
var
  mn: TMenuItem;
  txt: string;
  tam: Integer;
begin
  //MsgBox(Sender.ClassName);
  if Sender.ClassName<>'TMenuItem' then exit;
  mn := TMenuItem(Sender);
  txt := mn.Caption;
  tam := length(msjAgregFranja);
  txt := copy(txt, tam+1, 1000);

  diaActual.AgregarFranja(txt);
  if diaActual.msjError<>'' then begin
    MsgExc(diaActual.msjError);
    exit;
  end;
  diaActual.ActualizColorFranjas(TreeView1); //asigna colores de fondo
end;
procedure TfrmAdminTarCab.acTDiaElimTodExecute(Sender: TObject);
begin
  if Sender.ClassName<>'TMenuItem' then exit;
  diaActual.EliminarFranjas;
end;
procedure TfrmAdminTarCab.acTDiaReporteExecute(Sender: TObject);
begin
  msgbox(diaActual.ReporteTarifas);
end;
procedure TfrmAdminTarCab.acPasNuevExecute(Sender: TObject);
var
  nod: TTreeNode;
begin
  nod := TreeView1.Selected;
  if nod = nil then exit;
  if nod.Parent=nil then exit;
  nod := AgregaNodoPaso(nod.Parent, '60 min=' + FloatToStr(2.0));
  nod.EditText;
end;
procedure TfrmAdminTarCab.acPasElimExecute(Sender: TObject);
var
  nod: TTreeNode;
begin
  nod := TreeView1.Selected;
  if nod = nil then exit;
//  if MsgYesNo('¿Eliminar Tarifa de Alquiler ' + nom + '?') = 2 then exit;
  TreeView1.Items.Delete(nod);
end;
procedure TfrmAdminTarCab.acPasEditExecute(Sender: TObject);
var
  nod: TTreeNode;
begin
  nod := TreeView1.Selected;
  if nod = nil then exit;
  nod.EditText;
end;

end.

