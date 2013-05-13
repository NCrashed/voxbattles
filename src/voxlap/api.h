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

#endif /* API_H */