module client.main;

import std.c.windows.windows; 
import core.sys.windows.dll; 
import core.runtime;
import client.api;

import client.input;
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

			/*addMouseListener("debugMouse",
				(mx, my, mz, event)
				{
					if(event == MouseEventType.LEFT_BUTTON_PRESS)
					{
						writeLog("Left press");
					} else if(event == MouseEventType.LEFT_BUTTON_RELEASE)
					{
						writeLog("Left release");
					} else if(event == MouseEventType.RIGHT_BUTTON_PRESS)
					{
						writeLog("Right press");
					} else if(event == MouseEventType.RIGHT_BUTTON_RELEASE)
					{
						writeLog("Right release");
					} 
					
					return true;
				}
			);*/

			break; 
		case DLL_PROCESS_DETACH: 
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