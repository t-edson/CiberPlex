program CpxServer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, FormPrincipal, FormConfig, FormBoleta, FormInicio,
  CibGFacClientes, FormPropGFac, CibGFacNiloM, CibNiloMConex, CibNiloMTarifRut,
  FormBuscTarif, FormNiloMConex, FormNiloMEnrutam, FormNiloMProp, CibCabinaBase,
  CibCabinaTarifas, CibGFacCabinas, FormAdminCabinas, FormAdminTarCab,
  FormExplorCab, FormFijTiempo, FormRepIngresos, RegistrosVentas,
  FormAdminProduc, FormIngVentas, FormAgrupVert, FormAcercaDe, FormCalcul,
  FormContDinero;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmBoleta, frmBoleta);
  Application.CreateForm(TfrmRepIngresos, frmRepIngresos);
  Application.CreateForm(TfrmAdminProduc, frmAdminProduc);
  Application.CreateForm(TfrmIngVentas, frmIngVentas);
  Application.CreateForm(TfrmAgrupVert, frmAgrupVert);
  Application.CreateForm(TfrmInicio, frmInicio);
  Application.CreateForm(TfrmAcercaDe, frmAcercaDe);
  Application.CreateForm(TfrmCalcul, frmCalcul);
  Application.CreateForm(TfrmContDinero, frmContDinero);
  Application.Run;
end.

