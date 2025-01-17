#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <connection.h>
#include <song.h>
#include <queue.h>
#include <status.h>
#include <tcl.h>
#include "config.h"

int mpd_active();
int mpd_current_title(char *, int);
extern int MPD_ConnectObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int MPD_ActiveObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int MPD_CurrentTitleObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
