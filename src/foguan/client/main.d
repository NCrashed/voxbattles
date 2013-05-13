module client.main;

import std.c.windows.windows; 
import core.sys.windows.dll; 
import core.runtime;
import client.api;

import client.input;
import client.game;
import client.sprite;
import util.log;
import std.conv;

__gshared HINSTANCE g_hInst; 

extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) 
{ 
	switch (ulReason) 
	{ 
		case DLL_PROCESS_ATTACH: 
			g_hInst = hInstance; 
			Runtime.initialize();
			dll_process_attach( hInstance, true );
			
			createCamera();
			registerGeneralInput();
			break;
		case DLL_PROCESS_DETACH:
			unregisterGeneralInput();
			freeAllSprites();
			
			dll_process_detach( hInstance, true ); 
			Runtime.terminate();
			break; 
		case DLL_THREAD_ATTACH: 
			dll_thread_attach( true, true ); 
			break; 
		case DLL_THREAD_DETACH: 
			dll_thread_detach( true, true ); 
			break; 
		default:
	} 
	return true; 
}