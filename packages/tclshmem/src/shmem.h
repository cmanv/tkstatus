#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <tcl.h>
#include "config.h"

extern int SharedMem_ReadObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SharedMem_WriteObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SharedMem_DeleteObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
