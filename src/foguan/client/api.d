module client.api;

import std.stdio;
import std.conv;
import std.string;
import util.common;
import util.log;

import client.input;

enum DEBUG_LOG = "test.log";

static this()
{
	createLog(DEBUG_LOG);
}

extern(C)
{
	struct lpoint3d
	{ 
		long x, y, z; 
	} 

	struct dpoint3d
	{ 
		double x, y, z; 
	} 

	export void debugPrint(char* msg) 
	{ 
		writeLog(fromStringz(msg), LOG_ERROR_LEVEL.DEBUG, DEBUG_LOG);
	}

	export void getCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor)
	{
		writeLog(text(*ipos));
		writeLog(text(*istr));
		writeLog(text(*ihei));
		writeLog(text(*ifor));
	}

	export void updateKeyboardEvents(ubyte* keyStatus)
	{
		updateKeyboardBuffer(keyStatus);
	}

	export void updateMouseEvents(float mx, float my, float mz, int bstatus)
	{
		updateMouseBuffer(mx, my, mz, bstatus);
	}
}
static this()
{

}