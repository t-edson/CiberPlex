program CpxVisor;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormPrincipal, FormPant, FormLog, FormPantCli, ogMotGraf2d,
  ogDefObjGraf, CibServidorPC, CibTramas, CibFacturables, FormFijTiempo,
  FormBoleta, FormSincronBD, FormInicio, FormConfig, FormAdminProduc,
  FormAdminInsum, FormAdminProvee, FormExplorServ, FormCalcul, FormRepIngresos;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfrmPant, frmPant);
  Application.CreateForm(TfrmLog, frmLog);
  Application.CreateForm(TfrmPantCli, frmPantCli);
  Application.CreateForm(TfrmFijTiempo, frmFijTiempo);
  Application.CreateForm(TfrmBoleta, frmBoleta);
  Application.CreateForm(TfrmSincronBD, frmSincronBD);
  Application.CreateForm(TfrmInicio, frmInicio);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmExplorServ, frmExplorServ);
  Application.CreateForm(TfrmAdminProduc, frmAdminProduc);
  Application.CreateForm(TfrmAdminInsum, frmAdminInsum);
  Application.CreateForm(TfrmAdminProvee, frmAdminProvee);
  Application.CreateForm(TfrmCalcul, frmCalcul);
  Application.CreateForm(TfrmRepIngresos, frmRepIngresos);
  Application.Run;
end.

