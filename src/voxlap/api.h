#ifndef API_H
#define API_H

#include "voxlap5.h"

// Map editing functions exporting to dll
typedef void (*pt_setcube)(long, long, long, long);
typedef void (*pt_setsphere)(lpoint3d*, long, long);
typedef void (*pt_setellipsoid)(lpoint3d*, lpoint3d*, long, long, long);
typedef void (*pt_setcylinder)(lpoint3d *, lpoint3d *, long, long, long);
typedef void (*pt_setrect)(lpoint3d *, lpoint3d *, long);
typedef void (*pt_settri)(point3d *, point3d *, point3d *, long);
typedef void (*pt_setsector)(point3d *, long *, long, float, long, long);
typedef void (*pt_setspans)(vspans *, long, lpoint3d *, long);
typedef void (*pt_setheightmap)(const unsigned char *, long, long, long, long, long, long, long);
typedef void (*pt_setkv6)(vx5sprite *, long);

typedef kv6data* (*pt_getkv6)(const char*);
typedef void (*pt_freekv6)(kv6data*);
typedef void (*pt_drawsprite)(vx5sprite *);
typedef kv6data* (pt_genmipkv6)(kv6data* );
typedef long (*pt_curcolfunc)(lpoint3d *);
typedef long (*pt_floorcolfunc)(lpoint3d *);
typedef long (*pt_jitcolfunc)(lpoint3d *);
typedef long (*pt_manycolfunc)(lpoint3d *);
typedef long (*pt_sphcolfunc)(lpoint3d *);
typedef long (*pt_woodcolfunc)(lpoint3d *);
typedef long (*pt_pngcolfunc)(lpoint3d *);
typedef long (*pt_kv6colfunc)(lpoint3d *);

typedef void (*pt_exitGame)();

typedef void (*pt_orthonormalize)(point3d *, point3d *, point3d *);
typedef void (*pt_dorthonormalize)(dpoint3d *, dpoint3d *, dpoint3d *);
typedef void (*pt_orthorotate)(float, float, float, point3d *, point3d *, point3d *);
typedef void (*pt_dorthorotate)(double, double, double, dpoint3d *, dpoint3d *, dpoint3d *);
typedef void (*pt_axisrotate)(point3d *, point3d *, float);
typedef void (*pt_slerp)(point3d *, point3d *, point3d *, point3d *, point3d *, point3d *, point3d *, point3d *, point3d *, float);
typedef long (*pt_cansee)(point3d *, point3d *, lpoint3d *);
typedef void (*pt_hitscan)(dpoint3d *, dpoint3d *, lpoint3d *, long **, long *);
typedef void (*pt_sprhitscan)(dpoint3d *, dpoint3d *, vx5sprite *, lpoint3d *, kv6voxtype **, float *vsc);
typedef double (*pt_findmaxcr)(double, double, double, double);
typedef void (*pt_clipmove)(dpoint3d *, dpoint3d *, double);
typedef long (*pt_triscan)(point3d *, point3d *, point3d *, point3d *, lpoint3d *);
typedef void (pt_estnorm)(long, long, long, point3d *);

int loadFoguanCore();
int unloadFoguanCore();

void debugPrint(char* msg);
void getCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor);
void initializeCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor);
void correctCampos(dpoint3d* ipos);
void updateKeyboardEvents(char* keyStatus);
void updateMouseEvents(float mx, float my, float mz, long bstatus);
void update(double dt);
void initGame();
void foguanCustomDraw();

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
	);

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
	);

void exportUtilFuncs
	(
		pt_exitGame fptr1
	);
	
void exportPhysicFuncs
	(
		pt_orthonormalize fptr1,
		pt_dorthonormalize fptr2,
		pt_orthorotate fptr3,
		pt_dorthorotate fptr4,
		pt_axisrotate fptr5,
		pt_slerp fptr6,
		pt_cansee fptr7,
		pt_hitscan fptr8,
		pt_sprhitscan fptr9,
		pt_findmaxcr fptr10,
		pt_clipmove fptr11,
		pt_triscan fptr12,
		pt_estnorm fptr13
	);
	
#endif /* API_H */