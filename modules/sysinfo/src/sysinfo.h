#include <locale.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/types.h>
#include <sys/soundcard.h>
#include <sys/sysctl.h>
#include <vm/vm_param.h>
#include <unistd.h>
#include <net/if.h>
#include <ifaddrs.h>
#include <tcl.h>
#include "config.h"

extern int SysInfo_GetLoadAvgObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysInfo_GetUsedMemSwapObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysInfo_GetAcpiTempObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysInfo_GetCpuTempObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysInfo_GetCpuFreqObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysInfo_GetNetStatsObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysInfo_GetMixerVolObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
