#include "api.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

typedef void (*pt_debugPrint)();

pt_debugPrint p_debugPrint;

#define CORE_DLL "core.dll"

void debugPrint()
{
	p_debugPrint();
}

int loadFoguanCore()
{
	HINSTANCE lib = LoadLibrary(TEXT(CORE_DLL));
	if(!lib)
	{
		return 1;
	}

	p_debugPrint = (pt_debugPrint)GetProcAddress(lib, TEXT("debugPrint"));
	if(!p_debugPrint)
	{
		return 1;
	}

	return 0;
}

int unloadFoguanCore()
{
	if(!FreeLibrary(GetModuleHandle(TEXT(CORE_DLL))))
	{
		return 0;
	}

	return 0;
}