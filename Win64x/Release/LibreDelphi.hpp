// CodeGear C++Builder
// Copyright (c) 1995, 2025 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'LibreDelphi.pas' rev: 37.00 (Windows)

#ifndef LibreDelphiHPP
#define LibreDelphiHPP

#pragma delphiheader begin
#pragma option push
#if defined(__BORLANDC__) && !defined(__clang__)
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member 
#endif
#pragma pack(push,8)
#include <System.hpp>
#include <SysInit.hpp>
#include <System.Net.URLClient.hpp>
#include <System.Net.HttpClient.hpp>
#include <System.Net.HttpClientComponent.hpp>
#include <System.Net.Mime.hpp>
#include <System.JSON.hpp>
#include <System.Types.hpp>
#include <System.UITypes.hpp>
#include <System.Classes.hpp>
#include <System.SysUtils.hpp>
#include <System.Variants.hpp>
#include <System.Generics.Collections.hpp>
#include <System.Messaging.hpp>

//-- user supplied -----------------------------------------------------------

namespace Libredelphi
{
//-- forward type declarations -----------------------------------------------
class DELPHICLASS TLibreTrans;
//-- type declarations -------------------------------------------------------
enum DECLSPEC_DENUM TLibreEndpointSite : unsigned char { lesLibreTranslateMain, lesLibreTranslateDE, lesArgosOpenTech, lesVernCC, lesFortyTwoIT, lesTerraPrint, lesSkitzen, lesZillyHuhn, lesFedilab };

class PASCALIMPLEMENTATION TLibreTrans : public System::Classes::TComponent
{
	typedef System::Classes::TComponent inherited;
	
private:
	System::UnicodeString FAPI;
	TLibreEndpointSite FSite;
	System::UnicodeString FEndpoint;
	System::Net::Httpclientcomponent::TNetHTTPClient* FNet;
	void __fastcall SetSite(const TLibreEndpointSite Value);
	bool __fastcall SitOnline(const System::UnicodeString URL);
	
protected:
	System::UnicodeString __fastcall DefaultApiKey();
	
public:
	__fastcall virtual TLibreTrans(System::Classes::TComponent* AOwner);
	__fastcall virtual ~TLibreTrans();
	System::UnicodeString __fastcall CheckLng(const System::UnicodeString Text);
	System::Classes::TStringList* __fastcall ListLng();
	System::Classes::TStringList* __fastcall CodLng();
	System::UnicodeString __fastcall Translate(const System::UnicodeString Text, const System::UnicodeString OrgLng, const System::UnicodeString DstLng);
	System::UnicodeString __fastcall AutoTranslate(const System::UnicodeString Text, const System::UnicodeString DstLng);
	System::UnicodeString __fastcall TranslateFile(const System::UnicodeString Orig, const System::UnicodeString Dest, const System::UnicodeString LngOrig, const System::UnicodeString LngDest);
	void __fastcall AutoEndpoint();
	__property System::UnicodeString Endpoint = {read=FEndpoint};
	
__published:
	__property System::UnicodeString API = {read=FAPI, write=FAPI};
	__property TLibreEndpointSite Site = {read=FSite, write=SetSite, default=0};
};


//-- var, const, procedure ---------------------------------------------------
extern DELPHI_PACKAGE void __fastcall Register(void);
}	/* namespace Libredelphi */
#if !defined(DELPHIHEADER_NO_IMPLICIT_NAMESPACE_USE) && !defined(NO_USING_NAMESPACE_LIBREDELPHI)
using namespace Libredelphi;
#endif
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// LibreDelphiHPP
