#include "config.h"
#include "sysbsd.h"

EXTERN int
Sysbsd_Init(Tcl_Interp *interp)
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

	namespace = Tcl_CreateNamespace(interp, "sysbsd", (ClientData)NULL,
					(Tcl_NamespaceDeleteProc *)NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getloadavg",
				SysBSD_GetLoadAvgObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getmemstats",
				SysBSD_GetMemStatsObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getarcstats",
				SysBSD_GetArcStatsObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getacpitemp",
				SysBSD_GetAcpiTempObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getcputemp",
				SysBSD_GetCpuTempObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getcpufreq",
				SysBSD_GetCpuFreqObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getnetin",
				SysBSD_GetNetInObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getnetout",
				SysBSD_GetNetOutObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysbsd::getmixervol",
				SysBSD_GetMixerVolObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	if (Tcl_Export(interp, namespace, "*", 0) == TCL_ERROR) {
		return TCL_ERROR;
	}

	return TCL_OK;
}
