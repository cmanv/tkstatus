#include <tcl.h>
extern int SysBSD_GetLoadAvgObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetMemStatsObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetArcStatsObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetAcpiTempObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetCpuTempObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetCpuFreqObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetNetInObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetNetOutObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
extern int SysBSD_GetMixerVolObjCmd( ClientData d, Tcl_Interp *i, int c, Tcl_Obj *const o[]);
