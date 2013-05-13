#include "api.h"

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

// exported funcs
void setColorFunc(long (*colfunc)(lpoint3d*), long curcol)
{
	vx5.colfunc = colfunc; vx5.curcol = curcol;
}
typedef void (*pt_setColorFunc)(long (*)(lpoint3d*), long);

typedef void (*pt_debugPrint)(char*);
typedef void (*pt_getCamera)(dpoint3d*, dpoint3d*, dpoint3d*, dpoint3d*);
typedef void (*pt_initializeCamera)(dpoint3d*, dpoint3d*, dpoint3d*, dpoint3d*);
typedef void (*pt_correctCampos)(dpoint3d*);
typedef void (*pt_updateKeyboardEvents)(char*);
typedef void (*pt_updateMouseEvents)(float, float, float, long);
typedef void (*pt_update)(double);
typedef void (*pt_initGame)();
typedef void (*pt_foguanCustomDraw)();

pt_debugPrint p_debugPrint;
pt_getCamera p_getCamera;
pt_initializeCamera p_initializeCamera;
pt_correctCampos p_correctCampos;
pt_updateKeyboardEvents p_updateKeyboardEvents;
pt_updateMouseEvents p_updateMouseEvents;
pt_update p_update;
pt_initGame p_initGame;
pt_foguanCustomDraw p_foguanCustomDraw;

typedef void (*pt_exportMapEditFuncs)
	(
		pt_setcube,
		pt_setsphere,
		pt_setellipsoid,
		pt_setcylinder,
		pt_setrect,
		pt_settri,
		pt_setsector,
		pt_setspans,
		pt_setheightmap,
		pt_setkv6,
		pt_setColorFunc
	);

pt_exportMapEditFuncs p_exportMapEditFuncs;
void exportMapEditFuncs
	(
		pt_setcube fptr1,
		pt_setsphere fptr2,
		pt_setellipsoid fptr3,
		pt_setcylinder fptr4,
		pt_setrect fptr5,
		pt_settri fptr6,
		pt_setsector fptr7,
		pt_setspans fptr8,
		pt_setheightmap fptr9,
		pt_setkv6 fptr10
	)
{
	p_exportMapEditFuncs(fptr1, fptr2, fptr3, fptr4, fptr5, fptr6, fptr7, fptr8, fptr9, fptr10,
		&setColorFunc
		);
}

typedef void (*pt_exportModelFuncs)
	(
		pt_getkv6, 
		pt_freekv6,
		pt_drawsprite,
		pt_genmipkv6,
		pt_curcolfunc,
		pt_floorcolfunc,
		pt_jitcolfunc,
		pt_manycolfunc,
		pt_sphcolfunc,
		pt_woodcolfunc,
		pt_pngcolfunc,
		pt_kv6colfunc
	);
pt_exportModelFuncs p_exportModelFuncs;
void exportModelFuncs
	(
		pt_getkv6 fptr1,
		pt_freekv6 fptr2,
		pt_drawsprite fptr3,
		pt_genmipkv6 fptr4,
		pt_curcolfunc fptr5,
		pt_floorcolfunc fptr6,
		pt_jitcolfunc fptr7,
		pt_manycolfunc fptr8,
		pt_sphcolfunc fptr9,
		pt_woodcolfunc fptr10,
		pt_pngcolfunc fptr11,
		pt_kv6colfunc fptr12
	)
{
	p_exportModelFuncs(fptr1, fptr2, fptr3, fptr4, fptr5, fptr6, fptr7, fptr8, fptr9, fptr10, fptr11, fptr12);
}

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

void initGame()
{
	p_initGame();
}

void foguanCustomDraw()
{
	p_foguanCustomDraw();
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

	p_initGame = (pt_initGame)GetProcAddress(lib, TEXT("initGame"));
	if(!p_initGame)
	{
		return 1;
	}

	p_exportMapEditFuncs = (pt_exportMapEditFuncs)GetProcAddress(lib, TEXT("exportMapEditFuncs"));
	if(!p_exportMapEditFuncs)
	{
		return 1;
	}

	p_exportModelFuncs = (pt_exportModelFuncs)GetProcAddress(lib, TEXT("exportModelFuncs"));
	if(!p_exportModelFuncs)
	{
		return 1;
	}

	p_foguanCustomDraw = (pt_foguanCustomDraw)GetProcAddress(lib, TEXT("foguanCustomDraw"));
	if(!p_foguanCustomDraw)
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