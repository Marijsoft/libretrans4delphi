{ *******************************************************}
{ Delphi component library for LibreTranslator service   }
{ relased under license AGPL 3.0                         }
{ Copyright (C) 2022 Created by MarijSoft. 28/09/2022    }
{ Last update:25/12/2025                                 }
{ ****************************************************** }
{ Platform supported:Win,Linux,MacOS,Android,IOS         }
{ ****************************************************** }

unit LibreDelphi;

interface

uses
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.Net.Mime, System.JSON, System.Types, System.UITypes, System.Classes,
  System.SysUtils, System.Variants, System.Generics.Collections,
  System.Messaging;

type
  TLibreEndpointSite = (
    lesLibreTranslateMain,      // libretranslate.com
    lesLibreTranslateDE,        // libretranslate.de
    lesArgosOpenTech,           // translate.argosopentech.com
    lesVernCC,                  // lt.vern.cc
    lesFortyTwoIT,              // translate.fortytwo-it.com
    lesTerraPrint,              // translate.terraprint.co
    lesSkitzen,                 // translate.api.skitzen.com
    lesZillyHuhn,               // trans.zillyhuhn.com
    lesFedilab                  // ok no api key
  );

[ComponentPlatforms(
  pidWin32 or pidWin64 or
  pidOSX32 or pidOSX64 or
  pidLinux64 or
  pidAndroid or
  pidIOSSimulator or pidIOSDevice
)]
  TLibreTrans = class(TComponent)
  private
    FAPI: string;
    FSite: TLibreEndpointSite;
    FEndpoint: string;
    FNet: TNetHTTPClient;
    procedure SetSite(const Value: TLibreEndpointSite);
    function SitOnline(const URL: string): Boolean;
  protected
    function DefaultApiKey: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CheckLng(const Text: string): string;
    function ListLng: TStringList;
    function CodLng: TStringList;
    function Translate(const Text, OrgLng, DstLng: string): string;
    function AutoTranslate(const Text, DstLng: string): string;
    function TranslateFile(const Orig, Dest, LngOrig, LngDest: string): string;
    procedure AutoEndpoint;
    property Endpoint: string read FEndpoint;
  published
    property API: string read FAPI write FAPI;
    property Site: TLibreEndpointSite read FSite write SetSite default lesLibreTranslateMain;
  end;

procedure Register;

implementation

const
  CEndpointUrls: array[TLibreEndpointSite] of string = (
    'https://libretranslate.com/',
    'https://libretranslate.de/',
    'https://translate.argosopentech.com/',
    'https://lt.vern.cc/',
    'https://translate.fortytwo-it.com/',
    'https://translate.terraprint.co/',
    'https://translate.api.skitzen.com/',
    'https://trans.zillyhuhn.com/',
    'https://translate.fedilab.app/'
  );

ty: TArray<String> = ['text/plain', 'application/vnd.oasis.opendocument.text',
'application/vnd.oasis.opendocument.presentation',
'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
'application/vnd.openxmlformats-officedocument.presentationml.presentation',
'application/epub+zip', 'type=text/html'];

procedure Register;
begin
  RegisterComponents('MarijSoft', [TLibreTrans]);
end;

{ TLibreTrans }

constructor TLibreTrans.Create(AOwner: TComponent);
begin
  inherited;
  FNet := TNetHTTPClient.Create(nil);
  FAPI := DefaultApiKey;
  Site := lesLibreTranslateMain; // default design-time
end;

destructor TLibreTrans.Destroy;
begin
  FreeAndNil(FNet);
  inherited;
end;

function TLibreTrans.DefaultApiKey: string;
begin
  Result := 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
end;

procedure TLibreTrans.SetSite(const Value: TLibreEndpointSite);
begin
  if FSite <> Value then
  begin
    FSite := Value;
    FEndpoint := CEndpointUrls[FSite];
  end;
end;

function TLibreTrans.SitOnline(const URL: string): Boolean;
begin
  Result := False;
  try
    Result := FNet.Get(URL).StatusCode = 200;
  except
    Result := False;
  end;
end;

procedure TLibreTrans.AutoEndpoint;
begin
  for var S := Low(TLibreEndpointSite) to High(TLibreEndpointSite) do
    if SitOnline(CEndpointUrls[S]) then
    begin
      Site := S;
      Break;
    end;
end;

function TLibreTrans.ListLng: TStringList;
var
  JSON: TJSONArray;
begin
  Result := TStringList.Create;
  JSON := TJSONObject.ParseJSONValue(
    FNet.Get(FEndpoint + 'languages').ContentAsString
  ) as TJSONArray;
  try
    for var Item in JSON do
      Result.Add(Item.GetValue<string>('name'));
  finally
    JSON.Free;
  end;
end;

function TLibreTrans.CodLng: TStringList;
var
  JSON: TJSONArray;
begin
  Result := TStringList.Create;
  JSON := TJSONObject.ParseJSONValue(
    FNet.Get(FEndpoint + 'languages').ContentAsString
  ) as TJSONArray;
  try
    for var Item in JSON do
      Result.Add(Item.GetValue<string>('code'));
  finally
    JSON.Free;
  end;
end;

function TLibreTrans.Translate(const Text, OrgLng, DstLng: string): string;
var
  Params: TStringList;
  JSON: TJSONObject;
begin
  Params := TStringList.Create;
  try
    Params.AddPair('q', Text);
    Params.AddPair('source', OrgLng);
    Params.AddPair('target', DstLng);
    Params.AddPair('format', 'text');
    Params.AddPair('api_key', FAPI);

    JSON := TJSONObject.ParseJSONValue(
      FNet.Post(FEndpoint + 'translate', Params)
        .ContentAsString(TEncoding.UTF8)
    ) as TJSONObject;
    try
      Result := JSON.GetValue<string>('translatedText');
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
  end;
end;

function TLibreTrans.AutoTranslate(const Text, DstLng: string): string;
begin
  Result := Translate(Text, 'auto', DstLng);
end;

function TLibreTrans.CheckLng(const Text: string): string;
var
  Params: TStringList;
  JSON: TJSONObject;
begin
  Params := TStringList.Create;
  try
    Params.AddPair('q', Text);
    Params.AddPair('api_key', FAPI);

    JSON := TJSONObject.ParseJSONValue(
      FNet.Post(FEndpoint + 'detect', Params).ContentAsString
    ) as TJSONObject;
    try
      Result := JSON.GetValue<string>('language');
    finally
      JSON.Free;
    end;
  finally
    Params.Free;
  end;
end;

function tipofile(tfile: string): string;
begin
  if tfile.Contains('.txt') then
    Result := ty[0]
  else if tfile.Contains('.odt') then
    Result := ty[1]
  else if tfile.Contains('.odp') then
    Result := ty[2]
  else if tfile.Contains('.docx') then
    Result := ty[3]
  else if tfile.Contains('.pptx') then
    Result := ty[4]
  else if tfile.Contains('.epub') then
    Result := ty[5]
  else if tfile.Contains('.html') then
    Result := ty[6]
  else
    raise Exception.Create('Tipo di file non supportato');
end;


function TLibreTrans.TranslateFile(
  const Orig, Dest, LngOrig, LngDest: string): string;
var
  Form: TMultipartFormData;
  JSON: TJSONObject;
  MS: TMemoryStream;
  URL,tipo: string;
begin
  Form := TMultipartFormData.Create(True);
  MS := TMemoryStream.Create;
  tipo:=tipofile(orig);
  try
    Form.AddFile('file', Orig);
    Form.AddField('type',tipo);
    Form.AddField('source', LngOrig);
    Form.AddField('target', LngDest);
    Form.AddField('api_key', FAPI);

    JSON := TJSONObject.ParseJSONValue(
      FNet.Post(FEndpoint + 'translate_file', Form).ContentAsString
    ) as TJSONObject;
    try
      URL := JSON.GetValue<string>('translatedFileUrl');
      FNet.Get(URL, MS);
      MS.SaveToFile(Dest);
      Result := Dest;
    finally
      JSON.Free;
    end;
  finally
    Form.Free;
    MS.Free;
  end;
end;

end.
