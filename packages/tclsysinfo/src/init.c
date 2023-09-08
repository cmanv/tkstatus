#include "sysinfo.h"

EXTERN int
Tclsysinfo_Init(Tcl_Interp *interp)
{
	Tcl_Namespace *namespace;

	if (Tcl_InitStubs(interp, "8.6", 0) == NULL) {
		return TCL_ERROR;
	}

	if (Tcl_PkgRequire(interp, "Tcl", "8.6", 0) == NULL) {
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
				"sysinfo::getusedmemswap",
				SysInfo_GetUsedMemSwapObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"sysinfo::getacpitemp",
				SysInfo_GetAcpiTempObjCmd,
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
