program CpxServer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormPrincipal, FormConfig, FormAdminCabinas, CibFacturables,
  FormAdminTarCab, CibCabinaTarifas,
  FormVisorMsjRed, FormBoleta, FormRepIngresos, RegistrosVentas,
  FormBusProductos, FormIngVentas, FormAgrupVert, CibGFacNiloM,
  FormNiloMTerminal, FormFijTiempo;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmAdminCabinas, frmAdminCabinas);
  Application.CreateForm(TfrmAdminTarCab, frmAdminTarCab);
  Application.CreateForm(TfrmBoleta, frmBoleta);
  Application.CreateForm(TfrmRepIngresos, frmRepIngresos);
  Application.CreateForm(TfrmBusProductos, frmBusProductos);
  Application.CreateForm(TfrmIngVentas, frmIngVentas);
  Application.CreateForm(TfrmAgrupVert, frmAgrupVert);
  Application.CreateForm(TfrmFijTiempo, frmFijTiempo);
  Application.Run;
end.

