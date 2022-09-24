unit RegistraLibre;

interface
uses  Classes, Windows, ToolsApi, DesignIntf,DesignEditors,
  SysUtils;

procedure RegistraIDE;

implementation

ResourceString
  testo = 'LibreTranslator Component';

procedure RegistraIDE;
var
  bmp: HBITMAP;
begin
ForceDemandLoadState(dlDisable);
  if assigned(SplashScreenServices) then
  begin
  bmp := LoadBitmap(FindResourceHInstance(HInstance), 'TLibreTrans');
  try
    SplashScreenServices.AddPluginBitmap(testo,bmp,false,'by MarijSoft');
  finally
    DeleteObject(bmp);
  end;
  end;
end;


initialization
   RegistraIDE;
end.

