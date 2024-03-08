#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <tcl.h>
#include "version.h"

unsigned char *get_window_property(Window, Atom, unsigned long *);
int error_handler(Display *, XErrorEvent *);
extern int XLib_InitObjCmd(ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int XLib_SetDesktopsObjCmd(ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int XLib_GetActiveWindowNameObjCmd(ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int XLib_GetCurrentDesktopObjCmd(ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int XLib_GetListUsedDesktopObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
