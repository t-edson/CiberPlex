{Implementa el formulario explorador de la cabina}
unit FormExplorCab;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, LazFileUtils, LConvEncoding, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, ActnList, Menus, ComCtrls,
  Grids, LCLProc, CibFacturables, CibTramas, UtilsGrilla, MisUtils;
type
  { TfrmExplorCab }
  TfrmExplorCab = class(TForm)
  published
    acArcTraer: TAction;
    acPCVerPant: TAction;
    acPCReinic: TAction;
    acPCApag: TAction;
    acPCBloquear: TAction;
    acPCDesbloq: TAction;
    acArcPoner: TAction;
    acArcElim: TAction;
    acArcAbrir: TAction;
    acArcAbrirRem: TAction;
    acArcFijRut: TAction;
    acHerCancelTran: TAction;
    acVerRefresc: TAction;
    ActionList1: TActionList;
    btnChat: TBitBtn;
    btnMsje: TBitBtn;
    btnReinic: TBitBtn;
    btnApagar: TBitBtn;
    btnBloqDesb: TButton;
    Edit1: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    lblNomPC1: TStaticText;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    picPant: TImage;
    lblNomPC: TStaticText;
    PopupMenu1: TPopupMenu;
    btnIr: TSpeedButton;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    Timer1: TTimer;
    TreeView1: TTreeView;
    txtFec: TStaticText;
    procedure acArcAbrirExecute(Sender: TObject);
    procedure acArcAbrirRemExecute(Sender: TObject);
    procedure acArcElimExecute(Sender: TObject);
    procedure acArcFijRutExecute(Sender: TObject);
    procedure acArcPonerExecute(Sender: TObject);
    procedure acArcTraerExecute(Sender: TObject);
    procedure acHerCancelTranExecute(Sender: TObject);
    procedure acPCApagExecute(Sender: TObject);
    procedure acPCBloquearExecute(Sender: TObject);
    procedure acPCDesbloqExecute(Sender: TObject);
    procedure acPCReinicExecute(Sender: TObject);
    procedure acPCVerPantExecute(Sender: TObject);
    procedure acVerRefrescExecute(Sender: TObject);
    procedure btnApagarClick(Sender: TObject);
    procedure btnReinicClick(Sender: TObject);
    procedure btnBloqDesbClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure picPantClick(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TreeView1DblClick(Sender: TObject);
  private
    fac: TCibFac;
    FEsperandoRpta: boolean;
    UtilGrilla: TUtilGrilla;
    CancelEsp: Boolean;   //Para cancelar la espera de datos
    arcSal   : string;    //Archivo de salida. Usado para guardar el nombre de un archivo solicitado.
    nEspDatos: Integer;   //Contaodr de segundos que se esperan los datos
    ConectadoAnt: Boolean;
    EsWindows : boolean;   //Se usa para hacer las transformaciones de código de página
    function CarpetaSelec(out nom: string): boolean;
    function ArchivoSelec(out nom: string): boolean;
    procedure SetEsperandoRpta(AValue: boolean);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure EstadoControles(estad: boolean);
    procedure SubirArchivo(arc: string);
  public
    property EsperandoRpta: boolean //Indica que se espera la llegada de una respuesta
       read FEsperandoRpta write SetEsperandoRpta;
    procedure LlenarLista(lista: string);
    procedure Exec(fac0: TCibFac);
    procedure EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word;
      cad: string);
  end;

var
  frmExplorCab: TfrmExplorCab;

implementation
uses CibGFacCabinas;
{$R *.lfm}
const
  D_FOLDER = ' ';  //Descripción de tipo para carpetas
  COL_NOMB = 1;   //Columna con el nombre de archivo
  COL_TIPO = 2;   //Columna con el tipo de archivo
{ TfrmExplorCab }
function TfrmExplorCab.CarpetaSelec(out nom: string): boolean;
{Indica si hay una carpeta seleccionada. De ser así, devuelve TRUE, y el nombre en "nom".}
var
  fil: Integer;
  tip: String;
begin
  fil := StringGrid1.Row;
  if fil = -1 then exit(false);   //Verifica archivo seleccionado
  if fil = 0 then exit(false);   //Es el encabezado
  nom := StringGrid1.Cells[COL_NOMB, fil];  //lee nombre
  tip := StringGrid1.Cells[COL_TIPO, fil];
  if tip <> D_FOLDER then exit(false);   //es carpeta
  exit(true);
end;
function TfrmExplorCab.ArchivoSelec(out nom: string): boolean;
{Indica si hay un archivo seleccionado. De ser así, devuelve TRUE, y el nombre en "nom".}
var
  fil: Integer;
  tip: String;
begin
  fil := StringGrid1.Row;
  if fil = -1 then exit(false);   //Verifica archivo seleccionado
  if fil = 0 then exit(false);   //Es el encabezado
  nom := StringGrid1.Cells[COL_NOMB, fil];  //lee nombre
  tip := StringGrid1.Cells[COL_TIPO, fil];
  if tip = D_FOLDER then exit(false);   //es carpeta
  exit(true);
end;
procedure TfrmExplorCab.SetEsperandoRpta(AValue: boolean);
begin
//  if FEsperandoRpta=AValue then Exit;
  FEsperandoRpta:=AValue;
  Timer1Timer(self);   //Actualizamos de una vez, para no esperar al Timer
end;
procedure TfrmExplorCab.Timer1Timer(Sender: TObject);
var
  cab : TCibFacCabina;
begin
  if not self.Visible then exit;
  cab := TCibFacCabina(fac);
  //Actualiza campos
  if cab.Conectado then begin
    if not ConectadoAnt then begin
      //Ha retomado la conexión
      fEsperandoRpta := false;  //Cancela si había alguna transferencia anterior
    end;
    //Hay conexión con la PC remota
    if EsperandoRpta then EstadoControles(false) else EstadoControles(true);
    acHerCancelTran.Enabled:=true;
    TreeView1.Visible:=true;
    StringGrid1.Visible:=true;
    picPant.Visible:=true;

    //Actualiza información de estado
    lblNomPC.Caption:=cab.NombrePC;
    txtFec.Caption:= DateToStr(cab.HoraPC) + LineEnding +
                     TimeToStr(cab.HoraPC);
    if cab.PantBloq then
      btnBloqDesb.Caption:='Desbloquear'
    else
      btnBloqDesb.Caption:='Bloquear';
    StatusBar1.Panels[2].Text:='Conectado.';
  end else begin
    //No hay conexión remota
     EstadoControles(false);
     acHerCancelTran.Enabled:=false;
     TreeView1.Visible:=false;
     StringGrid1.Visible:=false;
     picPant.Visible:=false;

     StatusBar1.Panels[2].Text:='Desconectado.';
  end;
  ConectadoAnt := cab.Conectado;  //Estado anterior
end;
procedure TfrmExplorCab.picPantClick(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  acPCVerPantExecute(self);
end;
procedure TfrmExplorCab.StringGrid1DblClick(Sender: TObject);
begin
  acArcAbrirExecute(self);
end;
procedure TfrmExplorCab.btnBloqDesbClick(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  if btnBloqDesb.Caption='Bloquear' then begin
    acPCBloquearExecute(self);//Manda comando de bloqueo
  end else begin
    acPCDesbloqExecute(self);
  end;
end;
procedure TfrmExplorCab.btnReinicClick(Sender: TObject);
begin
  acPCReinicExecute(self);
end;
procedure TfrmExplorCab.btnApagarClick(Sender: TObject);
begin
  acPCApagExecute(self);
end;
procedure TfrmExplorCab.TreeView1DblClick(Sender: TObject);
var
  cab: TCibFacCabina;
  rut: String;
begin
  if TreeView1.Selected=nil then exit;
  cab := TCibFacCabina(fac);
  rut := TreeView1.Selected.Text;
  if rut = 'Escritorio' then begin
      Edit1.Text := '';  //Para el escritorio, se usa cadena vacía
  end else begin
      Edit1.Text := rut;  //pone ruta en la casilla de ruta
  end;
  acArcFijRutExecute(self);  //Ejecuta la acción
  Edit1.Text := '';   //limpara para que se actualice, cuando llegue la respuesta
end;
procedure TfrmExplorCab.LlenarLista(lista: string);
{Recibe la lista de archivos y la llena en la grilla}
var
  archivos: TStringList;
  fil: Integer;
  lin: String;
  ext, nom: String;
begin
  archivos := TStringList.Create;
  archivos.Text:=lista;   //divide en filas
  StringGrid1.RowCount:=archivos.Count+2;  //considera la entrada '..'
  //Agrega entrada al directoprio padre
  fil := 1;
  StringGrid1.Cells[1,fil] := '..';
  StringGrid1.Cells[2,fil] := D_FOLDER;
  Inc(fil);
  //Agrega el resto de archivos
  for lin in archivos do begin
    if lin='' then begin
      StringGrid1.Cells[1,fil] := '';
      StringGrid1.Cells[2,fil] := '???';
    end;
    if lin[1] = '[' then begin  //Es carpeta
      if EsWindows then nom := CP1252ToUTF8(lin) else nom := lin;
      StringGrid1.Cells[1,fil] := copy(nom,2,length(nom)-2);
      StringGrid1.Cells[2,fil] := D_FOLDER;
    end else begin   //Es archivo
      if EsWindows then nom := CP1252ToUTF8(lin) else nom := lin;
      StringGrid1.Cells[1,fil] := nom;   //pone nombre
      ext := ExtractFileExt(lin);  //extrae extensión
      if ext = '' then begin
        StringGrid1.Cells[2,fil] := 'sin tipo';
      end else begin
        StringGrid1.Cells[2,fil] := copy(ext, 2, length(ext));  //quita "."
      end;
    end;
    Inc(fil);
  end;
  StatusBar1.Panels[1].Text:= IntToStr(archivos.Count) + ' elementos.';
  archivos.Destroy;
end;
procedure TfrmExplorCab.StringGrid1DrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  txt: String;           // texto de la celda
  cv: TCanvas;           //referencia al lienzo
begin
  cv := StringGrid1.Canvas;  //referencia al Lienzo
  txt := StringGrid1.Cells[ACol,ARow];
  //cv.Font.Color := clBlack;
  //cv.Font.Style := [];
  if gdFixed in aState then begin
    //Es una celda fija
    cv.Brush.Color := clBtnFace;
    cv.FillRect(aRect);   //fondo
    cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
  end else begin
    //Es una celda común
    if aRow = StringGrid1.Row then begin
      cv.Brush.Color := clBtnFace;
    end else begin
      cv.Brush.Color := clWhite;  //fondo blanco
    end;
    if not StringGrid1.Enabled then begin
      //Si está deshabilitado, usa un solo color
      cv.Brush.Color := clBtnFace;
    end;
    cv.FillRect(aRect);   //fondo
    cv.TextOut(aRect.Left + 2, aRect.Top + 2, txt);
    // Dibuja ícono
    if (aCol=0) and (aRow>0) then begin
      case lowercase(StringGrid1.Cells[2,ARow]) of
      D_FOLDER: ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 4);
      'exe','com':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 16);
      'doc', 'docx':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 17);
      'xls', 'xlsx':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 18);
      'pdf':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 19);
      'bmp','jpg','png','gif','ico':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 20);
      'dll','ocx':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 21);
      'htm','html':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 22);
      'lnk':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 23);
      'txt','log':
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 24);
      else
        ImageList1.Draw(StringGrid1.Canvas, aRect.Left, aRect.Top, 5);
      end;
    end;
    //Dibuja borde en celda seleccionada
//    if gdFocused in aState then begin
//      cv.Pen.Color:=clGray;
//      cv.Frame(aRect);  //dibuja borde
//    end;
  end;
end;
procedure TfrmExplorCab.FormCreate(Sender: TObject);
var
  Item: TTreeNode;
begin
  UtilGrilla := TUtilGrilla.Create(StringGrid1);
  UtilGrilla.IniEncab;
  UtilGrilla.AgrEncabTxt('', 20);
  UtilGrilla.AgrEncabTxt('Nombre', 160);
  UtilGrilla.AgrEncabTxt('Tipo'  , 60);
  UtilGrilla.AgrEncabNum('Tamaño', 60).visible:=false;
  UtilGrilla.AgrEncabNum('Fecha' , 70).visible:=false;
  UtilGrilla.FinEncab;
  UtilGrilla.OpDimensColumnas:=true;
  UtilGrilla.OpEncabezPulsable:=true;
  UtilGrilla.OpOrdenarConClick:=true;
  UtilGrilla.MenuCampos:=true;

  StringGrid1.FixedCols:=0;
  StringGrid1.DefaultDrawing:=false;
  StringGrid1.OnDrawCell:=@StringGrid1DrawCell;
  StringGrid1.Options:=StringGrid1.Options+[goRowHighlight];
  StringGrid1.Options:=StringGrid1.Options-[goVertLine];
  StringGrid1.Options:=StringGrid1.Options-[goHorzLine];

  Item := TreeView1.Items.AddChild(nil, 'Escritorio');
  Item.ImageIndex:=0;    //cambia ícono del nodo
  Item.SelectedIndex := 0;
//  Item := TreeView1.Items.AddChild(nil, 'Equipo');
//  Item.ImageIndex:=1;    //cambia ícono del nodo
//  Item.SelectedIndex := 1;
//  Item := TreeView1.Items.AddChild(nil, 'Documentos');
//  Item.ImageIndex:=2;    //cambia ícono del nodo
//  Item.SelectedIndex := 2;
  Item := TreeView1.Items.AddChild(nil, 'C:\');
  Item.ImageIndex:=3;    //cambia ícono del nodo
  Item.SelectedIndex := 3;
  Item := TreeView1.Items.AddChild(nil, 'D:\');
  Item.ImageIndex:=3;    //cambia ícono del nodo
  Item.SelectedIndex := 3;

  EsWindows := true;   //se asume por defecto
end;
procedure TfrmExplorCab.FormDestroy(Sender: TObject);
begin
  UtilGrilla.Destroy;
end;
procedure TfrmExplorCab.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
//Se ahn soltado archivos aquí
begin
  if high(FileNames) > 0 then begin
    MsgExc('Solo se puede subir un archivo a la vez');
    exit;
  end;
  SubirArchivo(FileNames[0]);
end;
procedure TfrmExplorCab.Exec(fac0: TCibFac);
{Inicializa y muestra el formulario de Exploración de archivos. Se necesita la referencia
a un Visor de Cabinas, ya que se ha diseñado para trabajar con este objeto como fuente,
de modo que se pueda usar tanto en el CIBERPLEX-Server como en CIBERPLEX-Visor}
begin
  fac := fac0;
  Caption := 'Explorador de Archivos - ' + fac.Nombre;
  self.Show;
end;
procedure TfrmExplorCab.EstadoControles(estad: boolean);
begin
  acArcAbrir.Enabled:=estad;
  acArcTraer.Enabled:=estad;
  acArcPoner.Enabled:=estad;
  acArcAbrirRem.Enabled:=estad;
  acArcElim.Enabled :=estad;
  acArcFijRut.Enabled:=estad;

  acPCVerPant.Enabled:=estad;
  acPCBloquear.Enabled:=estad;
  acPCDesbloq.Enabled:=estad;
  acPCReinic.Enabled:=estad;
  acPCApag.Enabled:=estad;

  acVerRefresc.Enabled:=estad;

  lblNomPC.Enabled:=estad;
  txtFec.Enabled:=estad;
  btnBloqDesb.Enabled:=estad;

  btnChat.Enabled:=estad;
  btnMsje.Enabled:=estad;
  btnReinic.Enabled:=estad;
  btnApagar.Enabled:=estad;

  Edit1.Enabled:=estad;
  TreeView1.Enabled:=estad;
  StringGrid1.Enabled:=estad;
  Invalidate;
end;
procedure TfrmExplorCab.EjecRespuesta(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Recibe respuesras de los comandos. Se ejecuta en el Visor.}
var
  rutArc: string;
begin
  if ParamX = R_CABIN_DAT_RECIB then begin
    //Este tipo de mensajes se tarat de forma especial, porque son solo notificaciones
    //de llegada de Paquetes de datos, que pueden ser producto de un archivo garnde que se
    //ha solicitado.
    if EsperandoRpta then begin
      //De seguro que se mandó un comando largo, y se está esperando que termine de llegar
      nEspDatos := 0;   //reinicia contador de espera
      DebugLn('paquete recibido');
      //Indica visualmente que están llegando datos
      if copy(StatusBar1.Panels[0].Text,1,12)<>'Recibiendo: ' then begin
        //Había otro mensaje
        StatusBar1.Panels[0].Text := 'Recibiendo: ';
      end else begin
        //Ya está el mensaje
        if length(StatusBar1.Panels[0].Text) > 20 then
          StatusBar1.Panels[0].Text := 'Recibiendo: '
        else
          StatusBar1.Panels[0].Text := StatusBar1.Panels[0].Text + '#';
      end;
    end;
    exit;
  end;
  case ParamX of
  R_CABIN_PAN_COMP: begin
      //Se ha recibido una captura de pantalla. Se supone que ya la parte del id, ha sido
      //extraído de los datos.
      StringToFile(cad, 'd:\aaa.jpg');
      picPant.Picture.LoadFromFile('d:\aaa.jpg');
    end;
  R_CABIN_SOL_RUT_A: begin  //Llegó al ruta actual
      Edit1.Text:=cad;
    end;
  R_CABIN_SOL_L_ARC: begin  //Llego la lista de archivos
      LlenarLista(cad);
    end;
  R_CABIN_ARC_SOLIC: begin   //Llego un archivo solicitado "arcSal"
      rutArc :=  ExtractFilePath(Application.ExeName)+'archivos';  {Mejor sería que genere un evento para pedir esta ruta}
      StringToFile(cad, rutArc + '\' + arcSal);
    end;
  else
    MsgExc('Trama de respuesta desconocida.');
  end;
  //Se acepta cualquier respuesta, para salir del estado de "Esperando respuesta", pero
  //se podría ser más específico, para esperar la respuesta apropiada.
  EsperandoRpta := false;  //Para indicar que llego una respuesta
  StatusBar1.Panels[0].Text:='Recibido.';
end;
// Acciones de archivo
procedure TfrmExplorCab.SubirArchivo(arc: string);
{Envía un archivo a la PC remota}
var
  cad: string;
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  //Fija nombre
  EsperandoRpta := true;
  cad := ExtractFileName(arc);
  if EsWindows then cad:= UTF8ToCP1252(cad);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJ_ARSAL, 0, cab.IdFac + #9 + cad);
  //Envía contenido
  cad := StringFromFile(arc);
  if length(cad) > 259*256*256-1 then begin
    MsgExc('Archivo muy grande. No se puede enviar por Red.');
    exit;
  end;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_ARC_ENVIA, 0, cab.IdFac + #9 + cad);
  StatusBar1.Panels[0].Text:='Enviando archivo ...';
end;
procedure TfrmExplorCab.acArcTraerExecute(Sender: TObject);
var
  cab: TCibFacCabina;
  arc: String;
begin
  cab := TCibFacCabina(fac);
  if not ArchivoSelec(arc) then exit;
  //Envía solicitud de listar archivos a la PC cliente
  EsperandoRpta := true;
  arcSal := arc;    {Fija nombre de archivo para cuando llegue, porque la trama no
                         incluye el nombre de archivo (Ojo que estamos en el visor).
}
  if EsWindows then arc := UTF8ToCP1252(arc);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_ARC_SOLIC, 0, cab.IdFac + #9 + arc);
  StatusBar1.Panels[0].Text:='Trayendo archivo ...';
end;
procedure TfrmExplorCab.acArcPonerExecute(Sender: TObject);
var
  arc: String;
begin
  if not OpenDialog1.Execute then exit;
  arc := OpenDialog1.FileName;
  if not FileExistsUTF8(arc) then exit;
  SubirArchivo(arc);
end;
procedure TfrmExplorCab.acArcElimExecute(Sender: TObject);
var
  cab: TCibFacCabina;
  arc: String;
begin
  cab := TCibFacCabina(fac);
  if CarpetaSelec(arc) then begin
    MsgExc('No se puede eliminar una carpeta.');
    exit;
  end;
  if not ArchivoSelec(arc) then exit;
  if MsgYesNo('¿Está seguro de que desea eliminar el archivo "%s"?',[arc])<>1 then exit;
  //Envía solicitud de listar archivos a la PC cliente
  EsperandoRpta := true;
  if EsWindows then arc := UTF8ToCP1252(arc);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_ELI_ARCHI, 0, cab.IdFac + #9 + arc);
  StatusBar1.Panels[0].Text:='Eliminando archivo ...';
end;
procedure TfrmExplorCab.acArcFijRutExecute(Sender: TObject);
{Solicita fijar la ruta a la indicada en la barra de dirección.}
var
  rut: string;
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  rut := Edit1.Text;
  EsperandoRpta := true;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJ_RUT_A, 0, cab.IdFac + #9 + rut);
  StatusBar1.Panels[0].Text:='Leyendo directorio...';
end;
procedure TfrmExplorCab.acArcAbrirExecute(Sender: TObject);
var
  arc: String;
  cab: TCibFacCabina;
  rutArc: string;
begin
  cab := TCibFacCabina(fac);
  if CarpetaSelec(arc) then begin
    //Doble Click en Folder Envía comando de cambio de ruta
    if EsWindows then arc := UTF8ToCP1252(arc);
    cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_FIJ_RUT_A, 0, cab.IdFac + #9 + arc);
    StatusBar1.Panels[0].Text:='Accediendo directorio...';
    exit;
  end;
  if ArchivoSelec(arc) then begin
    //Es acrhivo
    acArcTraerExecute(self);   //Lo trae. Aquí se deshabilitan los controls
    //Espera a que llegue, verificando si se habilita la acción "acArcTraer".
    nEspDatos := 0;
    CancelEsp := False;
    while (nEspDatos < 300) and (Not CancelEsp) and EsperandoRpta do begin
        Sleep(100);
        Application.ProcessMessages;
        inc(nEspDatos);
    end;
    if nEspDatos >= 300 then begin
        //Salio por desbordó
        StatusBar1.Panels[0].Text := 'Tiempo de espera excedido.';
    end else if CancelEsp then begin
        //Se canceló la transferencia
        StatusBar1.Panels[0].Text := 'Transferencia cancelada.';
    end else begin
        //Llego normal
        rutArc :=  ExtractFilePath(Application.ExeName)+'archivos';  {Mejor sería que genere un evento para pedir esta ruta}
        //En windows, para ejecutar Start, es mejor movernos a la carpeta, primero.
        try
          chDir(rutArc);
          arc := UTF8ToCP1252(arc);
          MisUtils.Exec('CMD', '/C start "TITULO" "' + arc + '"');
        except
          MsgErr('Error abriendo "&s"', [arc]);
        end;
    end;
  end;
end;
procedure TfrmExplorCab.acArcAbrirRemExecute(Sender: TObject);
var
  cab: TCibFacCabina;
  arc: string;
begin
  cab := TCibFacCabina(fac);
  if CarpetaSelec(arc) then begin
    MsgExc('No se puede abrir remótamente una carpeta.');
    exit;
  end;
  if not ArchivoSelec(arc) then exit;
  //Envía solicitud de listar archivos a la PC cliente
  if EsWindows then arc := UTF8ToCP1252(arc);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_EJE_ARCHI, 0, cab.IdFac + #9 + arc);
  StatusBar1.Panels[0].Text:='Ejecutando archivo ...';
end;
// Acciones Ver
procedure TfrmExplorCab.acVerRefrescExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  StringGrid1.RowCount:=1;
  cab := TCibFacCabina(fac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_SOL_RUT_A, 0, cab.IdFac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_SOL_L_ARC, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Refrescando ...';
end;
// Acciones PC
procedure TfrmExplorCab.acPCVerPantExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  //Solicita captura de pantalla
  EsperandoRpta := true;
  picPant.Picture := nil;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_PAN_COMP, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Leyendo pantalla...';
end;
procedure TfrmExplorCab.acPCReinicExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  if MsgYesNo('¿Desea reiniciar PC: ' + cab.Nombre + '?')<>1 then exit;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_REIN_PC, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Reiniciando PC ...';
end;
procedure TfrmExplorCab.acPCApagExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  if MsgYesNo('¿Desea apagar PC: ' + cab.Nombre + '?')<>1 then exit;
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_APAG_PC, 0, cab.IdFac);
  StatusBar1.Panels[0].Text:='Apagando PC ...';
end;
procedure TfrmExplorCab.acPCBloquearExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_BLOQ_PC, 0, cab.IdFac);
end;
procedure TfrmExplorCab.acPCDesbloqExecute(Sender: TObject);
var
  cab: TCibFacCabina;
begin
  cab := TCibFacCabina(fac);
  cab.OnSolicEjecCom(CFAC_CABIN, C_CABIN_DESB_PC, 0, cab.IdFac);
end;
// Acciones Herramientas
procedure TfrmExplorCab.acHerCancelTranExecute(Sender: TObject);
{Cancela la oepración de transferencia de datos actual.}
begin
  CancelEsp := true;
  EsperandoRpta := false;
  StatusBar1.Panels[0].Text:='Cancelado.';
end;

end.

