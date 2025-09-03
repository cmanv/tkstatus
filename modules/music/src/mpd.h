#include <tcl.h>

int mpd_get_state();
int mpd_current_title(char *, int);
extern int MPD_ConnectObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int MPD_StateObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int MPD_CurrentTitleObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
