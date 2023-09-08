#include "xlib.h"

EXTERN int
Tclxlib_Init(Tcl_Interp *interp)
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

	namespace = Tcl_CreateNamespace(interp, "xlib", (ClientData)NULL,
					(Tcl_NamespaceDeleteProc *)NULL);

	Tcl_CreateObjCommand(	interp,
				"xlib::init",
				XLib_InitObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"xlib::setdesktops",
				XLib_SetDesktopsObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"xlib::getactivewindowname",
				XLib_GetActiveWindowNameObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"xlib::getcurrentdesktop",
				XLib_GetCurrentDesktopObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);

	Tcl_CreateObjCommand(	interp,
				"xlib::getlistuseddesktop",
				XLib_GetListUsedDesktopObjCmd,
				(ClientData) NULL,
				(Tcl_CmdDeleteProc*) NULL);


	if (Tcl_Export(interp, namespace, "*", 0) == TCL_ERROR) {
		return TCL_ERROR;
	}

	return TCL_OK;
}
