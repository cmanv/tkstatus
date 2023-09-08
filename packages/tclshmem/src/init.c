#include "shmem.h"

EXTERN int
Tclshmem_Init(Tcl_Interp *interp)
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

	namespace = Tcl_CreateNamespace(interp, "shmem", (ClientData)NULL,
					(Tcl_NamespaceDeleteProc *)NULL);

	Tcl_CreateObjCommand(	interp,
				"shmem::read",
				SharedMem_ReadObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"shmem::write",
				SharedMem_WriteObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"shmem::delete",
				SharedMem_DeleteObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	if (Tcl_Export(interp, namespace, "*", 0) == TCL_ERROR) {
		return TCL_ERROR;
	}

	return TCL_OK;
}
