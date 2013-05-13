module client.api;

import std.stdio;
import std.conv;
import std.string;
import util.vector;
import util.common;
import util.log;

import client.input;
import client.game;
import client.sprite;

enum DEBUG_LOG = "test.log";
enum CRASH_LOG = "CrashReport.log";

static this()
{
	createLog(DEBUG_LOG);
	createLog(CRASH_LOG);
}

extern(C)
{
	enum VSID = 1024;   //Maximum .VXL dimensions in both x & y direction
	enum MAXZDIM = 256; //Maximum .VXL dimensions in z direction (height)

	align(1)
	{
		struct lpoint3d
		{ 
			int x, y, z; 
		} 

		struct dpoint3d
		{ 
			double x, y, z; 
		} 

		struct point3d
		{
			float x, y, z;
		}

		struct vspans
		{
			ubyte z1, z0, x, y;
		}

		struct kv6voxtype
		{
			int col;
			ushort z;
			ubyte vis, dir;
		}

		struct kv6data
		{
			int leng, xsiz, ysiz, zsiz;
			float xpiv, ypiv, zpiv;
			uint numvoxs;
			int namoff;
			kv6data* lowermip;
			kv6voxtype *vox;
			uint *xlen;
			ushort *ylen;
		}

		struct hingetype
		{
			int parent;
			point3d p[2];
			point3d v[2];
			short vmin, vmax;
			ubyte htype;
			ubyte[7] filler;
		}

		struct seqtyp
		{
			int tim, frm;
		}

		struct kfatype
		{
			int numspr, numhin, mumfrm, seqnum;
			int namoff;
			kv6data *basekv6;
			vx5sprite* spr;
			hingetype* hinge;
			int* hingesort;
			short* frmval;
			seqtyp* seq;
		}

		struct vx5sprite
		{
			point3d p;
			int flags;

			union
			{
				point3d s, x;
			}
			union
			{
				kv6data* voxnum;
				kfatype* kfaptr;
			}
			union
			{
				point3d h, y;
			}
			int kfatim;
			union
			{
				point3d f, z;
			}
			int okfatim;
		}
	}

	// Functions loaded from voxlap
	alias void function(int px, int py, int pz, int col) pt_voxlapSetCube;
	alias void function(lpoint3d* hit, int hitrad, int dacol) pt_voxlapSetSphere;
	alias void function(lpoint3d* hit, lpoint3d* hit2, int hitrad, int dacol, int bakit) pt_voxlapSetElipsoid;
	alias void function(lpoint3d* p0, lpoint3d* p1, int cr, int dacol, int bakit) pt_voxlapSetCylinder;
	alias void function(lpoint3d* hit, lpoint3d* hit2, int dacol) pt_voxlapSetRect;
	alias void function(point3d* p0, point3d* p1, point3d* p2, int bakit) pt_voxlapSetTri;
	alias void function(point3d* p, int* point2, int n, float thick, int dacol, int bakit) pt_voxlapSetSector;
	alias void function(vspans* lst, int lstnum, lpoint3d* offs, int dacol) pt_voxlapSetSpans;
	alias void function(const char* hptr, int hpitch, int hxdim, int hydim, int x0, int y0, int x1, int y1) pt_voxlapSetHeightmap;
	alias void function(vx5sprite* spr, int dacol) pt_voxlapSetKv6;

	alias void function(int function(lpoint3d* p) colfunc, int curcol) pt_voxlapSetColorFunc;
	
	alias kv6data* function(const char*) pt_voxlapGetKv6;
	alias void function(kv6data* kv6) pt_voxlapFreeKv6;
	alias void function(vx5sprite* sprite) pt_voxlapDrawSprite;
	alias kv6data* function(kv6data* kv6) pt_voxlapGenMipKv6;
	alias int function(lpoint3d *) pt_curcolfunc;
	alias int function(lpoint3d *) pt_floorcolfunc;
	alias int function(lpoint3d *) pt_jitcolfunc;
	alias int function(lpoint3d *) pt_manycolfunc;
	alias int function(lpoint3d *) pt_sphcolfunc;
	alias int function(lpoint3d *) pt_woodcolfunc;
	alias int function(lpoint3d *) pt_pngcolfunc;
	alias int function(lpoint3d *) pt_kv6colfunc;	

	__gshared
	{
		pt_voxlapSetCube voxlapSetCube;
		pt_voxlapSetSphere voxlapSetSphere;
		pt_voxlapSetElipsoid voxlapSetElipsoid;
		pt_voxlapSetCylinder voxlapSetCylinder;
		pt_voxlapSetRect voxlapSetRect;
		pt_voxlapSetTri voxlapSetTri;
		pt_voxlapSetSector voxlapSetSector;
		pt_voxlapSetSpans voxlapSetSpans;
		pt_voxlapSetHeightmap voxlapSetHeightmap;
		pt_voxlapSetKv6 voxlapSetKv6;

		pt_voxlapSetColorFunc voxlapSetColorFunc;

		pt_voxlapGetKv6 voxlapGetKv6;
		pt_voxlapFreeKv6 voxlapFreeKv6;
		pt_voxlapDrawSprite voxlapDrawSprite;
		pt_voxlapGenMipKv6 voxlapGenMipKv6;
		pt_curcolfunc curcolfunc;
		pt_floorcolfunc floorcolfunc;
		pt_jitcolfunc jitcolfunc;
		pt_manycolfunc manycolfunc;
		pt_sphcolfunc sphcolfunc;
		pt_woodcolfunc woodcolfunc;
		pt_pngcolfunc pngcolfunc;
		pt_kv6colfunc kv6colfunc;
	}
}
extern(C)
{
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
			writeLog(text(e.msg), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			writeLog(text(e.info), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}

	export void initGame()
	{
		initializeGame();
	}

	export void foguanCustomDraw()
	{
		try
		{
			drawAllSprites();
		}
		catch(Exception e)
		{
			writeLog(text(e.msg), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			writeLog(text(e.info), LOG_ERROR_LEVEL.FATAL, CRASH_LOG);
			closeLog(CRASH_LOG);
			assert(0);
		}
	}

	export void exportMapEditFuncs(
		pt_voxlapSetCube fptr1,
		pt_voxlapSetSphere fptr2,
		pt_voxlapSetElipsoid fptr3,
		pt_voxlapSetCylinder fptr4,
		pt_voxlapSetRect fptr5,
		pt_voxlapSetTri fptr6,
		pt_voxlapSetSector fptr7,
		pt_voxlapSetSpans fptr8,
		pt_voxlapSetHeightmap fptr9,
		pt_voxlapSetKv6 fptr10,

		pt_voxlapSetColorFunc fptr11	
		)
	{
		voxlapSetCube = fptr1;
		voxlapSetSphere = fptr2;
		voxlapSetElipsoid = fptr3;
		voxlapSetCylinder = fptr4;
		voxlapSetRect = fptr5;
		voxlapSetTri = fptr6;
		voxlapSetSector = fptr7;
		voxlapSetSpans = fptr8;
		voxlapSetHeightmap = fptr9;
		voxlapSetKv6 = fptr10;

		voxlapSetColorFunc = fptr11;
	}

	export void exportModelFuncs(
			pt_voxlapGetKv6 fptr1,
			pt_voxlapFreeKv6 fptr2,
			pt_voxlapDrawSprite fptr3,
			pt_voxlapGenMipKv6 fptr4,
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
		voxlapGetKv6 = fptr1;
		voxlapFreeKv6 = fptr2;
		voxlapDrawSprite = fptr3;
		voxlapGenMipKv6 = fptr4;
		curcolfunc = fptr5;
		floorcolfunc = fptr6;
		jitcolfunc = fptr7;
		manycolfunc = fptr8;
		sphcolfunc = fptr9;
		woodcolfunc = fptr10;
		pngcolfunc = fptr11;
		kv6colfunc = fptr12;
	}
}
static this()
{

}