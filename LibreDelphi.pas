{ *******************************************************}
{ Delphi component library for LibreTranslator service   }
{ relased under license AGPL 3.0                         }
{ Copyright (C) 2022 Created by MarijSoft. 28/09/2022    }
{ ****************************************************** }
{ Platform supported:Win,Linux,MacOS,Android,IOS         }
{ ****************************************************** }

unit LibreDelphi;

interface

uses
  System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.Net.Mime, System.JSON, System.Types, System.UITypes, System.Classes,
  System.SysUtils,
  System.Variants, System.Generics.Collections, System.Messaging;

type

  [ComponentPlatformsAttribute($000B945F)]
  TLibreTrans = class(TComponent)
  private
    resturl: string;
    function sitonline(sitoweb: string): boolean;
  protected
    apikey: string;
    function keyapi: string;
    function urlendpoint(index: integer): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property API: string read apikey write apikey;
    property Endpoint: string read resturl write resturl;
    function checklng(Text: string): string;
    function listlng: TStringList;
    function codlng: TStringList;
    function translatefile(orig, dest, lngorig, lngdest: string): string;
    function translate(Text, orglng, dstlng: string): string;
    function autotranslate(Text, dstlng: string): string;
    procedure autoendpoint;
  end;

const
  ty: TArray<String> = ['text/plain', 'application/vnd.oasis.opendocument.text',
    'application/vnd.oasis.opendocument.presentation',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/epub+zip', 'type=text/html'];

const
sito:
TArray < String >= ['https://lt.vern.cc/',
  'https://translate.argosopentech.com/', 'https://libretranslate.com/',
  'https://translate.fortytwo-it.com/', 'https://translate.terraprint.co/',
  'https://libretranslate.de/'];

Procedure Register;

implementation

{ TLibreTrans }

Procedure Register;
begin
  RegisterComponents('MarijSoft', [TLibreTrans]);
end;

function TLibreTrans.codlng: TStringList;
var
  lng: TJsonValue;
  risp, ris: string;
  x: integer;
  JAr: TJSONArray;
  Jobj: TJSONObject;
  Net: TNetHttpClient;
begin
  Net := TNetHttpClient.Create(nil);
  risp := Net.Get(Endpoint + '/languages').ContentAsString();
  lng := TJSONObject.ParseJSONValue(risp) as TJsonValue;
  Result := TStringList.Create;
  try
    JAr := lng as TJSONArray;
    for x := 0 to JAr.count - 1 do
    begin
      Jobj := JAr[x] as TJSONObject;
      Result.Add(Jobj.GetValue('code').Value);
    end;
  finally
    lng.DisposeOf;
    Net.DisposeOf;
  end;
end;

procedure TLibreTrans.autoendpoint;
begin
  for var I: integer := Low(sito) to High(sito) do
  begin
    if sitonline(sito[I]) then
    begin
      urlendpoint(I);
      break
    end;
  end;
end;

constructor TLibreTrans.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  apikey := keyapi;
end;

destructor TLibreTrans.Destroy;
begin
  inherited;
end;

function TLibreTrans.keyapi: string;
begin
  Result := 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx';
end;

function TLibreTrans.listlng: TStringList;
var
  lng: TJsonValue;
  risp: string;
  x: integer;
  JAr: TJSONArray;
  Jobj: TJSONObject;
  Net: TNetHttpClient;
begin
  Net := TNetHttpClient.Create(self);
  risp := Net.Get(Endpoint + 'languages').ContentAsString();
  lng := TJSONObject.ParseJSONValue(risp) as TJsonValue;
  Result := TStringList.Create;
  try
    JAr := lng as TJSONArray;
    for x := 0 to JAr.count - 1 do
    begin
      Jobj := JAr[x] as TJSONObject;
      Result.Add(Jobj.GetValue('name').Value);
    end;
  finally
    lng.DisposeOf;
    Net.DisposeOf;
  end;
end;

function TLibreTrans.sitonline(sitoweb: string): boolean;
var
  Net: TNetHttpClient;
  s: integer;
begin
  Net := TNetHttpClient.Create(nil);
  s := Net.Get(sitoweb, nil).StatusCode;
  if s = 200 then
    Result := true
  else
    Result := false;
  Net.DisposeOf;
end;

function TLibreTrans.translate(Text, orglng, dstlng: string): string;
var
  prm: TStringList;
  trad: string;
  val: TJsonValue;
  Net: TNetHttpClient;
begin
  prm := TStringList.Create;
  prm.AddPair('q', Text);
  prm.AddPair('source', orglng);
  prm.AddPair('target', dstlng);
  prm.AddPair('format', 'text');
  prm.AddPair('api_key', apikey);
  Net := TNetHttpClient.Create(nil);
  try
    with Net.Create(nil) do
      try
        trad := Net.Post(Endpoint + 'translate', prm)
          .ContentAsString(TEncoding.UTF8);
        val := TJSONObject.ParseJSONValue(trad) as TJsonValue;
        Result := val.GetValue<String>('translatedText');
      except
        on E: Exception do
          raise Exception.Create
            ('Error Translation check your internet connection' + #13 +
            'or try again later');
      end;
  finally
    prm.DisposeOf;
    Net.DisposeOf;
  end;
end;

function TLibreTrans.translatefile(orig, dest, lngorig,
  lngdest: string): string;
var
  prm: TMultipartFormData;
  ris, dwn, tipo: String;
  url: TJsonValue;
  tm: TMemoryStream;
  Net: TNetHttpClient;
  function tipofile(tfile: string): string;
  var
    ext: string;
  begin
    ext := LowerCase(ExtractFileExt(tfile));
    for var I: integer := Low(ty) to High(ty) do
    begin
      if Pos(ty[I], ext) > 0 then
      begin
        Result := ty[I];
        break;
      end;
    end;
  end;

begin
  Net := TNetHttpClient.Create(nil);
  prm := TMultipartFormData.Create(true);
  tipo := tipofile(orig);
  prm.AddFile('file', orig);
  prm.AddField('type', tipo);
  prm.AddField('source', lngorig);
  prm.AddField('target', lngdest);
  prm.AddField('api_key', apikey);
  try
    with Net.Create(nil) do
      try
        ris := Net.Post(Endpoint + 'translate_file', prm).ContentAsString();
        url := TJSONObject.ParseJSONValue(ris) as TJSONObject;
        dwn := url.GetValue<String>('translatedFileUrl');
        tm := TMemoryStream.Create;
        Net.Get(dwn, tm).ContentStream;
      except
        on E: Exception do
          raise Exception.Create
            ('Error Translate file check your internet connection' + #13 +
            'or try again later');
      end;
  finally
    tm.Position := 0;
    tm.SaveToFile(dest);
    FreeAndNil(tm);
    FreeAndNil(Net);
  end;
end;

function TLibreTrans.urlendpoint(index: integer): string;
begin
  Result := sito[index];
  Endpoint := Result;
end;

function TLibreTrans.autotranslate(Text, dstlng: string): string;
var
  prm: TStringList;
  trad: string;
  val: TJsonValue;
  Net: TNetHttpClient;
begin
  prm := TStringList.Create;
  prm.AddPair('q', Text);
  prm.AddPair('source', 'auto');
  prm.AddPair('target', dstlng);
  prm.AddPair('format', 'text');
  prm.AddPair('api_key', apikey);
  Net := TNetHttpClient.Create(nil);
  try
    with Net.Create(nil) do
      try
        trad := Net.Post(Endpoint + 'translate', prm)
          .ContentAsString(TEncoding.UTF8);
        val := TJSONObject.ParseJSONValue(trad) as TJsonValue;
        Result := val.GetValue<String>('translatedText');
      except
        on E: Exception do
          raise Exception.Create
            ('Error Translation check your internet connection' + #13 +
            'or try again later');
      end;
  finally
    Net.DisposeOf;
    prm.DisposeOf;
  end;
end;

function TLibreTrans.checklng(Text: string): string;
var
  risp: string;
  param: TStringList;
  lng: TJsonValue;
  Net: TNetHttpClient;
begin
  param := TStringList.Create;
  param.AddPair('q', Text);
  param.AddPair('api_key', apikey);
  Net := TNetHttpClient.Create(nil);
  try
    risp := Net.Post(Endpoint + 'detect', param).ContentAsString;
    risp := Trim(risp);
    risp := risp.Replace('[', '');
    risp := risp.Replace(']', '');
    lng := TJSONObject.ParseJSONValue(risp) as TJSONObject;
    Result := lng.GetValue<String>('language');
  finally
    param.DisposeOf;
    Net.DisposeOf;
  end;
end;

end.
