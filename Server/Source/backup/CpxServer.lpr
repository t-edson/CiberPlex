program CpxServer;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, tachartlazaruspkg, FormPrincipal, FormConfig, FormBoleta,
  FormInicio, FormRepIngresos, RegistrosVentas, FormAdminProduc, FormAgrupRep,
  FormAcercaDe, FormCalcul, FormContDinero, FormSelecObjetos, FormAdminProvee,
  FormAdminInsum, FormCambClave, FormRepProducto, FormRepEventos,
  FormRegCompras, FormIngVentas, FormValStock, FormIngStock, FormVista,
  ModuleBD, FormGRUCabinas, FormGRUNiloM, FormGRUMesas, FormGRUClientes;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmBoleta, frmBoleta);
  Application.CreateForm(TfrmRepIngresos, frmRepIngresos);
  Application.CreateForm(TfrmAdminProduc, frmAdminProduc);
  Application.CreateForm(TfrmAgrupRep, frmAgrupRep);
  Application.CreateForm(TfrmInicio, frmInicio);
  Application.CreateForm(TfrmAcercaDe, frmAcercaDe);
  Application.CreateForm(TfrmCalcul, frmCalcul);
  Application.CreateForm(TfrmContDinero, frmContDinero);
  Application.CreateForm(TfrmSelecObjetos, frmSelecObjetos);
  Application.CreateForm(TfrmAdminProvee, frmAdminProvee);
  Application.CreateForm(TfrmAdminInsum, frmAdminInsum);
  Application.CreateForm(TfrmCambClave, frmCambClave);
  Application.CreateForm(TfrmRepProducto, frmRepProducto);
  Application.CreateForm(TfrmRepEventos, frmRepEventos);
  Application.CreateForm(TfrmRegCompras, frmRegCompras);
  Application.CreateForm(TfrmIngVentas, frmIngVentas);
  Application.CreateForm(TfrmValStock, frmValStock);
  Application.CreateForm(TfrmIngStock, frmIngStock);
  Application.CreateForm(TfrmVisor, frmVisor);
  Application.CreateForm(TModBD, ModBD);
  Application.CreateForm(TfrmGRUCabinas, frmGRUCabinas);
  Application.CreateForm(TfrmGRUNiloM, frmGRUNiloM);
  Application.CreateForm(TfrmGRUMesas, frmGRUMesas);
  Application.CreateForm(TfrmGRUClientes, frmGRUClientes);
  Application.CreateForm(TfrmFijTiempo, frmFijTiempo);
  Application.Run;
end.

