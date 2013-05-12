module client.api;

import std.stdio;
import std.conv;
import std.string;
import util.vector;
import util.common;
import util.log;

import client.input;
import client.game;

enum DEBUG_LOG = "test.log";
enum CRASH_LOG = "CrashReport.log";

static this()
{
	createLog(DEBUG_LOG);
	createLog(CRASH_LOG);
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
		try
		{
			with(gameCamera)
			{
				immutable dvec = direction;
				immutable rvec = -left;
				ipos.x = position.x; ipos.y = position.y; ipos.z = position.z;
				istr.x = rvec.x; istr.y = rvec.y; istr.z = rvec.z;
				ihei.x = up.x; ihei.y = up.y; ihei.z = up.z;
				ifor.x = dvec.x; ifor.y = dvec.y; ifor.z = dvec.z;
				//writeLog(text("Pos:",*ipos));
				//writeLog(text("Right:",*istr));
				//writeLog(text("Up:",*ihei));
				//writeLog(text("Forward:",*ifor));
			}
		} 
		catch(Exception e)
		{
			writeLog(e.msg, LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}

	export void initializeCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor)
	{
		try
		{
			gameCamera.position = vec3(ipos.x, ipos.y, ipos.z);
			gameCamera.up = vec3(ihei.x, ihei.y, ihei.z);
			gameCamera.direction = vec3(ifor.x, ifor.y, ifor.z);
		} 
		catch(Exception e)
		{
			writeLog(e.msg, LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}

	export void correctCampos(dpoint3d* ipos)
	{
		try
		{	with(gameCamera)
				moveRel(position - vec3(ipos.x, ipos.y, ipos.z));
		} 
		catch(Exception e)
		{
			writeLog(e.msg, LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}

	export void updateKeyboardEvents(ubyte* keyStatus)
	{
		try
		{
			updateKeyboardBuffer(keyStatus);
		} 
		catch(Exception e)
		{
			writeLog(e.msg, LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}			
	}

	export void updateMouseEvents(float mx, float my, float mz, int bstatus)
	{
		try
		{
			updateMouseBuffer(mx, my, mz, bstatus);
		} 
		catch(Exception e)
		{
			writeLog(e.msg, LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}

	export void update(double dt)
	{
		try
		{
			updateGameCamera(dt);
		}
		catch(Exception e)
		{
			//writeLog("!", LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			writeLog(text(e.msg), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			writeLog(text(e.info), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}
}
static this()
{

}