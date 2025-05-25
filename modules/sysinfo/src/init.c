#include "sysinfo.h"

EXTERN int
Sysinfo_Init(Tcl_Interp *interp)
{
	Tcl_Namespace *namespace;

	if (Tcl_InitStubs(interp, TCL_VERSION, 0) == NULL) {
		return TCL_ERROR;
	}

	if (Tcl_PkgRequire(interp, "Tcl", TCL_VERSION, 0) == NULL) {
		return TCL_ERROR;
	}

	if (Tcl_PkgProvide(interp, PACKAGE_PROVIDE, PACKAGE_VERSION) != TCL_OK) {
		return TCL_ERROR;
	}

	namespace = Tcl_CreateNamespace(interp, "sysinfo", (ClientData)NULL,
					(Tcl_NamespaceDeleteProc *)NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getloadavg",
				SysInfo_GetLoadAvgObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getmemstats",
				SysInfo_GetMemStatsObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getarcstats",
				SysInfo_GetArcStatsObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getacpitemp",
				SysInfo_GetAcpiTempObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getcputemp",
				SysInfo_GetCpuTempObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getcpufreq",
				SysInfo_GetCpuFreqObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getnetstats",
				SysInfo_GetNetStatsObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getmixervol",
				SysInfo_GetMixerVolObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	if (Tcl_Export(interp, namespace, "*", 0) == TCL_ERROR) {
		return TCL_ERROR;
	}

	return TCL_OK;
}
