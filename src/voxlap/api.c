#include "api.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

typedef void (*pt_debugPrint)(char*);
typedef void (*pt_getCamera)(dpoint3d*, dpoint3d*, dpoint3d*, dpoint3d*);
typedef void (*pt_initializeCamera)(dpoint3d*, dpoint3d*, dpoint3d*, dpoint3d*);
typedef void (*pt_correctCampos)(dpoint3d*);
typedef void (*pt_updateKeyboardEvents)(char*);
typedef void (*pt_updateMouseEvents)(float, float, float, long);
typedef void (*pt_update)(double);

pt_debugPrint p_debugPrint;
pt_getCamera p_getCamera;
pt_initializeCamera p_initializeCamera;
pt_correctCampos p_correctCampos;
pt_updateKeyboardEvents p_updateKeyboardEvents;
pt_updateMouseEvents p_updateMouseEvents;
pt_update p_update;

#define CORE_DLL "core.dll"

void debugPrint(char* msg)
{
	p_debugPrint(msg);
}

void getCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor)
{
	p_getCamera(ipos, istr, ihei, ifor);
}

void initializeCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor)
{
	p_initializeCamera(ipos, istr, ihei, ifor);
}

void correctCampos(dpoint3d* ipos)
{
	p_correctCampos(ipos);
}

void updateKeyboardEvents(char* keyStatus)
{
	p_updateKeyboardEvents(keyStatus);
}

void updateMouseEvents(float mx, float my, float mz, long bstatus)
{
	p_updateMouseEvents(mx, my, mz, bstatus);
}

void update(double dt)
{
	p_update(dt);
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

	p_getCamera = (pt_getCamera)GetProcAddress(lib, TEXT("getCamera"));
	if(!p_getCamera)
	{
		return 1;
	}

	p_initializeCamera = (pt_initializeCamera)GetProcAddress(lib, TEXT("initializeCamera"));
	if(!p_initializeCamera)
	{
		return 1;
	}

	p_correctCampos = (pt_correctCampos)GetProcAddress(lib, TEXT("correctCampos"));
	if(!p_correctCampos)
	{
		return 1;
	}

	p_updateKeyboardEvents = (pt_updateKeyboardEvents)GetProcAddress(lib, TEXT("updateKeyboardEvents"));
	if(!p_updateKeyboardEvents)
	{
		return 1;
	}

	p_updateMouseEvents = (pt_updateMouseEvents)GetProcAddress(lib, TEXT("updateMouseEvents"));
	if(!p_updateMouseEvents)
	{
		return 1;
	}

	p_update = (pt_update)GetProcAddress(lib, TEXT("update"));
	if(!p_update)
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