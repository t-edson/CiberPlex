unit FrameSincroBD;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, LCLProc, Grids, MisUtils, UtilsGrilla, CibTramas,
  CibServidorPC, LazUTF8, LazFileUtils, LCLIntf, StdCtrls, Globales;
const
  ARC_CFG_SERV = 'CpxServer_i386.xml';   //Archivo de configuración en el servidor
type
  { TfraSincroBD }
  TfraSincroBD = class(TFrame)
    btnCancelar1: TBitBtn;
    btnSincronCfg: TBitBtn;
    btnCancelar: TBitBtn;
    btnCerrPanel: TSpeedButton;
    btnSincronReg: TBitBtn;
    ComboBox1: TComboBox;
    grillaRegis: TStringGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    grillaConf: TStringGrid;
    Timer1: TTimer;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnCerrPanelClick(Sender: TObject);
    procedure btnSincronCfgClick(Sender: TObject);
    procedure btnSincronRegClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ServCab: TCibServidorPC;
    local: string;
    arcSal: String;
    gri1, gri2: TUtilGrilla;
    tic: integer;
    procedure AgregarTablaReg(nom: string);
    procedure RefrescarAntiguedadTabla(grilla: TStringGrid);
    procedure RefrescarEstadoArcDeDisco;
  public
    OnSoliCerrar: procedure of object;
    procedure TramaLista(tram: TCPTrama);
  public  //Inicialización
    procedure AgregarTablaCfg(nom: string);
    procedure Ini(ServCab0: TCibServidorPC; local0: string);
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation
{$R *.lfm}
const
  COL_FECHA = 1;
  COL_NOMBRE = 2;
  COL_ANTIG = 3;
  COL_ESTADO = 4;

function FechaHoraACadena(fec: TDateTime): string;
begin
  DateTimeToString(Result, 'yyyy/mm/dd hh:nn:ss', fec);
end;
function CadenaAFechaHora(cad: string): TDateTime;
var
  YY, MM, DD, HH, NN, SS: LongInt;
begin
  YY := StrToInt(Copy(cad, 1, 4));
  MM := StrToInt(Copy(cad, 6, 2));
  DD := StrToInt(Copy(cad, 9, 2));
  HH := StrToInt(Copy(cad, 12, 2));
  NN := StrToInt(Copy(cad, 15, 2));
  SS := StrToInt(Copy(cad, 18, 2));
  Result := EncodeDate(YY, MM, DD) + EncodeTime(HH, NN, SS, 0);
end;
function VerEstadoArchivo(arc: string): string;
var
  SR: TSearchRec;
  fecMod: LongInt;
  fec: TDateTime;
begin
  if not FileExistsUTF8(arc) then begin
    Result := 'No existe.';
    exit;
  end;
  //Busca archivo
  if FindFirst(arc, faAnyFile, SR) = 0 then begin
//    nombre := SR.Name;
//    tamano := SR.Size;
    fecMod := SR.Time;
    FindClose(SR);
    //Verifica fecha de modifiación
    fec := FileDateToDateTime(fecMod);
    Result := FechaHoraACadena(fec);
  end else begin
    //Hubo algún error
    Result := '!Error';
  end;
end;

{ TfraSincroBD }
procedure TfraSincroBD.btnCerrPanelClick(Sender: TObject);
begin
  if OnSoliCerrar<>nil then OnSoliCerrar();
end;
procedure TfraSincroBD.btnCancelarClick(Sender: TObject);
begin
//  cancelado := true;
//  hide;
end;
procedure TfraSincroBD.Timer1Timer(Sender: TObject);
begin
  inc(tic);
  if tic mod 4 = 0 then begin
    RefrescarAntiguedadTabla(grillaConf);
    RefrescarAntiguedadTabla(grillaRegis);
  end;
  if ServCab.Conectado  then begin
    btnSincronCfg.Enabled := true;
    btnCancelar.Enabled := true;
    btnSincronReg.Enabled := true;
    btnCancelar1.Enabled := true;
  end else begin
    btnSincronCfg.Enabled := false;
    btnCancelar.Enabled := false;
    btnSincronReg.Enabled := false;
    btnCancelar1.Enabled := false;
  end;
end;
procedure TfraSincroBD.TramaLista(tram: TCPTrama);
var
  fil: Integer;
begin
  if not Visible then exit; //Se supone que ya terminó su trabajo.
  case tram.tipTra of
    C_FIJ_ARSAL: begin  //Llegó el nombre de un archivo
        arcSal := tram.traDat;
      end;
    M_ARC_SOLIC: begin  //Llego el archivo
        //Ver si se actualiza en la grilla de configuración
        for fil:=1 to grillaConf.RowCount-1 do begin
          if grillaConf.Cells[COL_NOMBRE, fil] = arcSal then begin
            grillaConf.Cells[COL_ESTADO, fil] := 'Listo.';
            //Actualiza fecha. Se evita leer de disco, para no cargar el proceso
            grillaConf.Cells[COL_FECHA, fil] := FechaHoraACadena(now);
            StringToFile(tram.traDat, rutApp+ DirectorySeparator + arcSal);  //Crea con el nombre indicado
          end;
        end;
        //Ver si se actualiza en la grilla de registros
        for fil:=1 to grillaRegis.RowCount-1 do begin
          if grillaRegis.Cells[COL_NOMBRE, fil] = arcSal then begin
            grillaRegis.Cells[COL_ESTADO, fil] := 'Listo.';
            //Actualiza fecha. Se evita leer de disco, para no cargar el proceso
            grillaRegis.Cells[COL_FECHA, fil] := FechaHoraACadena(now);
            StringToFile(tram.traDat, rutDatos + DirectorySeparator + arcSal);  //Crea con el nombre indicado
          end;
        end;
//        if arcSal = 'rutas.txt' then begin
//          //LLegó el último archivo.
//        end;
      end;
  end;
end;
procedure TfraSincroBD.RefrescarEstadoArcDeDisco;
{Refersca el estado de antiguedad de los archivos de la grilla, leyendo la información
desde el disco.}
var
  arc: String;
  fil: Integer;
begin
  for fil := 1 to grillaConf.RowCount-1 do begin
    //Verifica estado de antigüedad del archivo
    arc := grillaConf.Cells[COL_NOMBRE, fil];
    grillaConf.Cells[COL_FECHA, fil] := VerEstadoArchivo(rutApp+ DirectorySeparator + arc);
  end;
  for fil := 1 to grillaRegis.RowCount-1 do begin
    //Verifica estado de antigüedad del archivo
    arc := grillaRegis.Cells[COL_NOMBRE, fil];
    grillaRegis.Cells[COL_FECHA, fil] := VerEstadoArchivo(rutDatos+ DirectorySeparator + arc);
  end;
end;
procedure TfraSincroBD.RefrescarAntiguedadTabla(grilla: TStringGrid);
{Refresca la amtiguedad de los archivos, leyendo la columna de fecha}
const
  UNMIN = 1/24/60;
  UNHORA = 1/24;
var
  fec, dif: TDateTime;
  fil: Integer;
begin
  for fil := 1 to grilla.RowCount-1 do begin
    //Obtiene fecha
    if grilla.Cells[COL_FECHA, fil] = '' then begin
      grilla.Cells[COL_ANTIG, fil] := '<<Desconocido>>';
      continue;
    end;
    fec := CadenaAFechaHora(grilla.Cells[COL_FECHA, fil]);
    //Verifica estado de antigüedad del archivo
    dif := now - fec;
    if dif <= UNMIN then
      grilla.Cells[COL_ANTIG, fil] := 'Hace 1 minuto.'
    else if dif < UNHORA then
      grilla.Cells[COL_ANTIG, fil] := 'Hace ' + IntToSTr(round(dif*24*60)) + ' minutos.'
    else if dif < 1 then
      grilla.Cells[COL_ANTIG, fil] := 'Hace ' + IntToSTr(round(dif*24)) + ' horas.'
    else
      grilla.Cells[COL_ANTIG, fil] := 'Hace varios días.'
    ;
  end;
end;
procedure TfraSincroBD.btnSincronCfgClick(Sender: TObject);
{Sincronizar tablas de configuración.}
var
  arc: String;
  fil: Integer;
begin
  if not ServCab.Conectado then exit;
  ServCab.PonerComando(C_FIJ_RUT_A, 0, 0, '-');   //Fija ruta actual
  for fil := 1 to grillaConf.RowCount-1 do begin
    grillaConf.Cells[COL_ESTADO, fil] := 'Actualiz...';
    arc := grillaConf.Cells[COL_NOMBRE, fil];
    {Pide traer el archivo. El parámetro en "1", hará que llegue primero el nombre
    del archivo}
    ServCab.PonerComando(C_ARC_SOLIC, 0, 1, arc);
  end;
end;
procedure TfraSincroBD.btnSincronRegClick(Sender: TObject);
var
  fil: Integer;
  arc: string;
begin
  if not ServCab.Conectado then exit;
  ServCab.PonerComando(C_FIJ_RUT_A, 0, 0, '-datos\');   //Fija ruta de registros
  for fil := 1 to grillaRegis.RowCount-1 do begin
    grillaRegis.Cells[COL_ESTADO, fil] := 'Actualiz...';
    arc := grillaRegis.Cells[COL_NOMBRE, fil];
    {Pide traer el archivo. El parámetro en "1", hará que llegue primero el nombre
    del archivo}
    ServCab.PonerComando(C_ARC_SOLIC, 0, 1, arc);
  end;
end;
procedure TfraSincroBD.ComboBox1Change(Sender: TObject);
begin
  //Actualiza la lista de registros, de acuerdo al mes seleccionado:
  grillaRegis.RowCount := 1;
  AgregarTablaReg(local + '.0_' + ComboBox1.Text + '.log');
  AgregarTablaReg(local + '.1_' + ComboBox1.Text + '.dat');
end;
//Inicialización
procedure TfraSincroBD.AgregarTablaCfg(nom: string);
var
  fFin: Integer;
begin
  grillaConf.RowCount := grillaConf.RowCount+1;
  fFin := grillaConf.RowCount-1;
  grillaConf.Cells[COL_NOMBRE, fFin] := nom;
end;
procedure TfraSincroBD.AgregarTablaReg(nom: string);
var
  fFin: Integer;
begin
  grillaRegis.RowCount := grillaRegis.RowCount+1;
  fFin := grillaRegis.RowCount-1;
  grillaRegis.Cells[COL_NOMBRE, fFin] := nom;
end;
procedure TfraSincroBD.Ini(ServCab0: TCibServidorPC; local0: string);
{Inicia mostrando el formulario para iniciar sesión.
En "PtrArcCfg0", escribe el nombre del archivo de configuración.}
var
  m: Integer;
  tmp: string;
begin
  ServCab := ServCab0;
  local := local0;
  //Llena datos de registros
  ComboBox1.Clear;
  for m := 0 to 12 do begin
    DateTimeToString(tmp, 'yyyy_mm', now - m *30);
    ComboBox1.AddItem(tmp, nil);
  end;
  ComboBox1.ItemIndex := 0;
  ComboBox1Change(self);  //actualiza
  //Primera actualización de las grillas.
  RefrescarEstadoArcDeDisco;
end;
constructor TfraSincroBD.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  gri1 := TUtilGrilla.Create(grillaConf);
  gri1.IniEncab;
  gri1.AgrEncabNum('N°'          , 10).visible := false;
  gri1.AgrEncabTxt('Fecha de Actualización', 95).visible := false;
  gri1.AgrEncabTxt('Tabla'       , 90);
  gri1.AgrEncabTxt('Antigüedad.' , 85);
  gri1.AgrEncabTxt('Estado'      , 55);
  gri1.FinEncab;
  gri1.OpAutoNumeracion:=true;
  gri1.OpDimensColumnas:=true;
  gri1.OpEncabezPulsable:=true;
  gri1.OpResaltarEncabez:=true;
  gri1.OpResaltFilaSelec:=true;
  gri1.MenuCampos:=true;
  //Llena datos
  AgregarTablaCfg('config.xml');
  AgregarTablaCfg('productos.txt');
  AgregarTablaCfg('proveedores.txt');
  AgregarTablaCfg('insumos.txt');
  AgregarTablaCfg('mensajes.txt');
  AgregarTablaCfg('tarifario.txt');
  AgregarTablaCfg('rutas.txt');
  //coNFIGURA GRI2
  gri2 := TUtilGrilla.Create(grillaRegis);
  gri2.IniEncab;
  gri2.AgrEncabNum('N°'          , 10).visible := false;
  gri2.AgrEncabTxt('Fecha de Actualización', 95).visible := false;
  gri2.AgrEncabTxt('Tabla'       , 110);
  gri2.AgrEncabTxt('Antigüedad.' , 70);
  gri2.AgrEncabTxt('Estado'      , 55);
  gri2.FinEncab;
  gri2.OpAutoNumeracion:=true;
  gri2.OpDimensColumnas:=true;
  gri2.OpEncabezPulsable:=true;
  gri2.OpResaltarEncabez:=true;
  gri2.OpResaltFilaSelec:=true;
  gri2.MenuCampos:=true;
end;
destructor TfraSincroBD.Destroy;
begin
  gri2.Destroy;
  gri1.Destroy;
  inherited Destroy;
end;

end.

