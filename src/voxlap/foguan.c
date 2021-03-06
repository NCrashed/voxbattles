#if 0
foguan.exe: foguan.obj api.obj voxlap5.obj v5.obj kplib.obj winmain.obj foguan.c; link foguan api voxlap5 v5 kplib winmain ddraw.lib dinput.lib ole32.lib dxguid.lib user32.lib gdi32.lib /nodefaultlib:libcmt.lib
foguan.obj: foguan.c voxlap5.h sysmain.h api.h; cl /c /J /TP foguan.c /Ox /Ob2 /Gs /MD
voxlap5.obj: voxlap5.c voxlap5.h;     cl /c /J /TP voxlap5.c   /Ox /Ob2 /Gs /MD
v5.obj: v5.asm; ml /c /coff v5.asm
kplib.obj: kplib.c;                   cl /c /J /TP kplib.c     /Ox /Ob2 /Gs /MD
winmain.obj: winmain.cpp sysmain.h;   cl /c /J /TP winmain.cpp /Ox /Ob2 /Gs /DZOOM_TEST
api.obj: api.c api.h;                 cl /c /J /TP api.c     /Ox /Ob2 /Gs /MD
!if 0
#endif

#include <math.h>
#include <stdlib.h>
#include "sysmain.h"
#include "voxlap5.h"
#include "api.h"

#define CLIPRAD 5

dpoint3d ipos, istr, ihei, ifor;
float mx, my, mz;
long bstatus;
double dt, olddt;

long groucol[9] = {0x506050,0x605848,0x705040,0x804838,0x704030,0x603828,
  0x503020,0x402818,0x302010,};
long mycolfunc (lpoint3d *p)
{
  long i, j;
  j = groucol[(p->z>>5)+1]; i = groucol[p->z>>5];
  i = ((((((j&0xff00ff)-(i&0xff00ff))*(p->z&31))>>5)+i)&0xff00ff) +
     ((((((j&0x00ff00)-(i&0x00ff00))*(p->z&31))>>5)+i)&0x00ff00);
  i += (labs((p->x&31)-16)<<16)+(labs((p->y&31)-16)<<8)+labs((p->z&31)-16);
  j = rand(); i += (j&7) + ((j&0x70)<<4) + ((j&0x700)<<8);
  return(i+0x80000000);
}

bool needQuit = false;
void quitGame()
{
  needQuit = true;
}

long initapp (long argc, char **argv)
{
   if(loadFoguanCore() != 0)
   {
      exit(1);
   }

   exportMapEditFuncs(
      &setcube,
      &setsphere,
      &setellipsoid,
      &setcylinder,
      &setrect,
      &settri,
      &setsector,
      &setspans,
      &setheightmap,
      &setkv6
      );

   exportModelFuncs(
      &getkv6,
      &freekv6,
      &drawsprite,
      &genmipkv6,
      &curcolfunc,
      &floorcolfunc,
      &jitcolfunc,
      &manycolfunc,
      &sphcolfunc,
      &woodcolfunc,
      &pngcolfunc,
      &kv6colfunc
    );

   exportUtilFuncs(
      &quitGame
    );

   exportPhysicFuncs(
      &orthonormalize,
      &dorthonormalize,
      &orthorotate,
      &dorthorotate,
      &axisrotate,
      &slerp,
      &cansee,
      &hitscan,
      &sprhitscan,
      &findmaxcr,
      &clipmove,
      &triscan,
      &estnorm
    );

   dt = olddt = 0.0;
   debugPrint("Hi from voxlap!");

   xres = 1024; yres = 768; colbits = 32; fullscreen = 1;
   if (initvoxlap() < 0) return(-1);
   
   setsideshades(0,4,1,3,2,2);
   vx5.colfunc = mycolfunc; vx5.curcol = 0x80704030;

   char *vxlnam, *skynam, *userst;
   kzaddstack("voxdata.zip");
   loadsxl("sxl/default.sxl", &vxlnam, &skynam, &userst);
   loadvxl("vxl/untitled.vxl",&ipos,&istr,&ihei,&ifor);
   loadsky(skynam);

   vx5.mipscandist = 192;
   vx5.maxscandist = (long)(VSID*1.42);
   vx5.kv6mipfactor = 128;

   vx5.lightmode = 1;
   vx5.vxlmipuse = 9; 
   vx5.fallcheck = 1;
   updatevxl();

   initializeCamera(&ipos, &istr, &ihei, &ifor);
   initGame();

   updatevxl();

   return(0);
}

void doframe ()
{
   long frameptr, pitch, xdim, ydim;
   startdirectdraw(&frameptr,&pitch,&xdim,&ydim);
   voxsetframebuffer(frameptr,pitch,xdim,ydim);
   setcamera(&ipos,&istr,&ihei,&ifor,xdim*.5,ydim*.5,xdim*.5);
   opticast();

   foguanCustomDraw();

   stopdirectdraw();
   nextpage();
   readkeyboard(); //if (keystatus[1]) quitloop();

   updateKeyboardEvents(keystatus);

   if(needQuit)
   {
      quitloop();
   }

   readmouse(&mx, &my, &mz, &bstatus);
   updateMouseEvents(mx, my, mz, bstatus);

   readklock(&dt); 
   update(dt - olddt);
   olddt = dt;

   dpoint3d tipos;
   dpoint3d dp;
   getCamera(&tipos, &istr, &ihei, &ifor);
   dp.x = tipos.x-ipos.x;
   dp.y = tipos.y-ipos.y;
   dp.z = tipos.z-ipos.z;
   clipmove(&ipos, &dp, CLIPRAD);
   if(ipos.x != tipos.x || ipos.y != tipos.y || ipos.z != tipos.z)
   {
      correctCampos(&ipos);
   }
}

void uninitapp () 
{ 
  unloadFoguanCore();
  kzuninit(); 
  uninitvoxlap();
}


#if 0
//////////////////////////////////////////////////////////////////////////
A line-by-line explanation of this program:

>#include "sysmain.h"
   Function and variable declarations for WINMAIN.CPP or DOSMAIN.C.

>#include "voxlap5.h"
   I have all my function and structure declarations in here, so if you
   include this, you will be sure that you're calling my functions with the
   correct parameters.

>dpoint3d ipos, istr, ihei, ifor;
   The dpoint3d structure is defined in VOXLAP5.H as "double x, y, z".
      ipos           : specifies (x,y,z) position
      istr,ihei,ifor : specifies orientation, where:
          istr is the RIGHT unit vector ("strafe" direction)
          ihei is the DOWN unit vector ("height" direction)
          ifor is the FORWARD unit vector ("forward" direction)
      I like to put the letter "i" in front of these variables because "i"
      is pronounced like "eye". Cute, huh?

>vx5sprite desklamp;
   Example voxel sprite structure declaration. The sprite structure holds
   its position, orientation (3x3 matrix), flags and timing (for animation)
   and a pointer to the voxel data (voxnum).

>long initapp (long argc, char **argv)
   I have all the system dependent code (such as graphics initialization,
   page flipping, keyboard, mouse, timer, and file finding) inside
   WINMAIN/DOSMAIN. Since operating systems handle the program entry point
   differently (such as "main" vs. "WinMain"), I put the program entry
   point in WINMAIN/DOSMAIN. The first thing they do is call initapp().
   The parameters are formatted exactly like ANSI C's "main" function.

>   xres = 640; yres = 480; colbits = 32; fullscreen = 1;
   As soon as you return from your initapp function, WINMAIN/DOSMAIN will
   set the video mode. You MUST set these 4 variables (xres,yres,colbits,
   fullscreen) somewhere inside your initapp function.

>   initvoxlap();
   Call this before you use any other functions from VOXLAP5.H. I allocate
   memory and initialize lookup tables in this function.

>   kzaddstack("voxdata.zip");
   This call is not mandatory, but if you want your game to support files
   stored inside a .ZIP file, then you must call this before any functions
   that load those file types. You can use multiple .ZIP files for user
   patches. It gives highest priority to the last .ZIP file passed to this
   function. Any stand-alone files (not in a .ZIP) but with matching path&
   filename will have the highest priority.

>   loadvxl("vxl/untitled.vxl",&ipos,&istr,&ihei,&ifor);
   Call this function to load a map from file into memory. The voxlap engine
   handles the map structure in its own memory. You are responsible for
   dealing with the starting position and orientation. Loadvxl parameters:
      char *mapfilename : voxel map filename
      dpoint3d * : pointer to starting position
      dpoint3d * : pointer to starting RIGHT unit vector
      dpoint3d * : pointer to starting DOWN unit vector
      dpoint3d * : pointer to starting FORWARD unit vector

>   desklamp.voxnum = getkv6("kv6\\desklamp.kv6");
   Getkv6 loads the voxel object (desklamp.kv6) into memory and returns a
   pointer to its kv6data structure. The voxel data is cached, so if you call
   getkv6 again, it will share memory and return a pointer to the same data.

>   desklamp.p.x = 652; desklamp.p.y = 620; desklamp.p.z = 103.5;
   Place the lamp's position at a spot in the middle of the VXL map. Usually,
   you would load the sprite's location from the SXL file. This is just for
   demonstration.

>   desklamp.s.x = .4; desklamp.s.y = 0; desklamp.s.z = 0;
>   desklamp.h.x = 0; desklamp.h.y = .4; desklamp.h.z = 0;
>   desklamp.f.x = 0; desklamp.f.y = 0; desklamp.f.z = .4;
   Select the lamp's orientation. I use an identity matrix here, scaled by
   0.4 to make it 2.5 times smaller.

>   desklamp.kfatim = 0; desklamp.okfatim = 0; desklamp.flags = 0;
   Kfatim and okfatim are used for animation. See the description of vx5sprite
   in VOXLAP5.H for a description of flags. Flags=0 is fine for most purposes.

>   return(0);
    Return a 0 to tell WINMAIN/DOSMAIN that everything's ok and continue.
    If you return a -1 here, WINMAIN/DOSMAIN will clean all buffers and exit
       immediately. This is useful when you have a critical error like an
       invalid graphics mode or map file not found.

>void doframe ()
   Once you return from initapp, WINMAIN/DOSMAIN will call this function
   continuously. WINMAIN handles its windows message loop (PeekMessage,etc.)
   between doframe() calls. You should render exactly 1 frame in here,
   process movement/network code, and then return back to WINMAIN/DOSMAIN so
   it can update the status of things.

>   long frameptr, pitch, xdim, ydim;
>   startdirectdraw(&frameptr,&pitch,&xdim,&ydim);
   This function obtains and locks an offscreen surface for you to draw to.
   The 4 parameters fully specify a frame buffer:
      frameptr : 32-bit address pointing to the top-left corner of the frame
                 You can cast this as (long *)frameptr but but be careful with
                 the pitch when you do this, since pitch is in BYTES.
         pitch : the number of BYTES per scan line (NOTE: bytes, not pixels)
          xdim : the horizontal resolution of the frame in PIXELS
          ydim : the vertical resolution of the frame in PIXELS
    This example shows how you could draw a green pixel at coordinate (30,20):
       *(long *)((30<<2)+20*pitch+frameptr) = 0x00ff00;
    WARNING: Do NOT call hardware accelerator functions between startdirectdraw
       and stopdirectdraw since video memory will be locked between these 2
       calls. If you forget this rule, then your system may freeze.

>   voxsetframebuffer(frameptr,pitch,xdim,ydim);
   Since voxlap is currently a software renderer and I don't have any system
   dependent code in it, you must provide it with the frame buffer. You MUST
   call this once per frame, AFTER startdirectdraw(), but BEFORE any functions
   that access the frame buffer.

>   setcamera(&ipos,&istr,&ihei,&ifor,xdim*.5,ydim*.5,xdim*.5);
   Call this to set the current camera orientation. This information is used
   for future calls, such as opticast, drawsprite, spherefill, etc...
   The 5th & 6th parameters define the center of the screen projection - This
      is the point on the screen that the <ipos + ifor*t> vector intersects.
   The last parameter is the focal length - use it to control zoom. If you
      want a 90 degree field of view (left to right side of screen), then
      set it to half of the screen's width: (xdim*.5).

>   opticast();
   This is the where the screen actually gets drawn! Assuming you loaded a map
   into memory, it uses the current camera position & orientation.

>   drawsprite(&desklamp);
   Renders the voxel sprite, using the data from the desklamp structure.
   Drawsprite should be called after opticast and before stopdirectdraw. There
   is no need to sort sprites since Voxlap uses a depth buffer.

>   stopdirectdraw();
   If you called startdirectdraw, then you MUST call this before flipping
   pages. Once you do this, video memory is unlocked and you're free to draw
   to the frame buffer using hardware accelerator functions or GDI, etc...

>   nextpage();
   Call this WINMAIN/DOSMAIN function when you're finished drawing to the
   frame. This function flips video pages for double-buffering.

>   readkeyboard(); if (keystatus[1]) quitloop();
   The keystatus array is defined in SYSMAIN.H, and it tells you the status of
   every key on the keyboard. 0 means the key is up and 1 means the key is
   down. You MUST call readkeyboard() to update the keystatus array for
   WINMAIN to work properly.
   The scancode for ESC is 1. You tell WINMAIN/DOSMAIN to stop calling doframe
   by calling the quitloop() function.

>void uninitapp () { kzuninit(); uninitvoxlap(); }
   When you call quitloop(), WINMAIN/DOSMAIN stops calling doframe, and it
   calls uninitapp once before exiting. Call uninitvoxlap() in here so the
   voxlap engine can free any buffers that it created.

!endif
#endif
