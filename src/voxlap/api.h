#ifndef API_H
#define API_H

#include "voxlap5.h"

int loadFoguanCore();
int unloadFoguanCore();

void debugPrint(char* msg);
void getCamera(dpoint3d* ipos, dpoint3d* istr, dpoint3d* ihei, dpoint3d* ifor);
void updateKeyboardEvents(char* keyStatus);
void updateMouseEvents(float mx, float my, float mz, long bstatus);

#endif /* API_H */