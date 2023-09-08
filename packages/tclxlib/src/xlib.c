#include <time.h>
#include "xlib.h"
static Display *display = NULL;
static Window root;
static int errorlog = 0;
static int mindesktop = 0;
static int maxdesktop = 9;
static const int bsize = 256;

int XLib_InitObjCmd( ClientData clientData, Tcl_Interp *interp,
			int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	if (objc > 1) {
		if (Tcl_GetIntFromObj(interp, objv[1], &errorlog) != TCL_OK) {
			Tcl_SetStringObj(resultObj, "** Erreur: log non valide **", -1);
			return TCL_ERROR;
		}
	}

	display = XOpenDisplay(NULL);
	if (!display) {
		Tcl_SetStringObj(resultObj, "XOpenDisplay() failed", -1);
		return TCL_ERROR;
	}
	root = XDefaultRootWindow(display);
	XSetErrorHandler(error_handler);

	return TCL_OK;
}

int XLib_SetDesktopsObjCmd( ClientData clientData, Tcl_Interp *interp,
			int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	if (objc > 1) {
		if (Tcl_GetIntFromObj(interp, objv[1], &mindesktop) != TCL_OK) {
			Tcl_SetStringObj(resultObj, "** Erreur: mindesktop non valide **", -1);
			return TCL_ERROR;
		}
	}
	if (objc > 2) {
		if (Tcl_GetIntFromObj(interp, objv[2], &maxdesktop) != TCL_OK) {
			Tcl_SetStringObj(resultObj, "** Erreur: maxdesktop non valide **", -1);
			return TCL_ERROR;
		}
	}

	return TCL_OK;
}

int XLib_GetActiveWindowNameObjCmd( ClientData clientData, Tcl_Interp *interp,
					int objc, Tcl_Obj *const objv[])
{
	Window window;
	unsigned long num;

	Atom request = XInternAtom(display, "_NET_ACTIVE_WINDOW", False);
	unsigned char *property = get_window_property(root, request, &num);
	if (property) {
		window = *((Window *)property);
		free(property);
	} else
		window = 0;

	char buffer[bsize];
	*buffer = 0;
	if ((window) && (window != root)) {
		request = XInternAtom(display, "WM_NAME", False);
		property = get_window_property(window, request, &num);
		if (property) {
			char *dst = buffer;
			char *src = (char *)property;
			for (int i=0; i < bsize-1; i++) {
				if (!*src) break;
				/* Exclure les caratères de 4 octets */
 				while (*src < '\xf5' && *src > '\xef') src+=4;

				/* Copier les caractères de 3 octets */
 				if (*src < '\xf0' && *src > '\xdf') {
					if (i > bsize-3) break;
					*dst++ = *src++;
					*dst++ = *src++;
					*dst++ = *src++;
					i += 2;
					continue;
				}
				/* Copier les caractères de 2 octets */
 				if (*src < '\xe0' && *src > '\xc1') {
					if (i > bsize-2) break;
					*dst++ = *src++;
					*dst++ = *src++;
					i++;
					continue;
				}
				*dst++ = *src++;
			}
			*dst = 0;
			free(property);
		}
	}

	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_NewStringObj(buffer, -1)) != TCL_OK) {
		return TCL_ERROR;
	}

	return TCL_OK;
}

int XLib_GetCurrentDesktopObjCmd( ClientData clientData, Tcl_Interp *interp,
					int objc, Tcl_Obj *const objv[])
{
	unsigned long num;
	int desktop;

	Atom request = XInternAtom(display, "_NET_CURRENT_DESKTOP", False);
	unsigned char *property = get_window_property(root, request, &num);
	if (property) {
		desktop = *((int *)property);
		free(property);
	} else
		desktop = -1;

	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_NewIntObj(desktop)) != TCL_OK) {
		return TCL_ERROR;
	}
	return TCL_OK;
}

int XLib_GetListUsedDesktopObjCmd( ClientData clientData, Tcl_Interp *interp,
					int objc, Tcl_Obj *const objv[])
{
	unsigned long numclients;
	unsigned char *property;
	unsigned long num;

	/* Get a list of clients and their associated desktop */
	Atom request = XInternAtom(display, "_NET_CLIENT_LIST", False);
	unsigned char *clients = get_window_property(root, request, &numclients);
	int *clientdesktoplist = NULL;
	if ((clients) && (numclients)) {
		clientdesktoplist = malloc(numclients * sizeof(int));
		request = XInternAtom(display, "_NET_WM_DESKTOP", False);
		Window *winptr = (Window *)clients;
		int *clientptr = clientdesktoplist;
		for (int i=0; i<numclients; i++, clientptr++, winptr++) {
			property = get_window_property(*winptr, request, &num);
			if (property) {
				*clientptr = *((int *)property);
				free(property);
			} else
				*clientptr = -1;
		}
		free(clients);
	}

	/* Get current desktop */
	int currentdesktop;
	request = XInternAtom(display, "_NET_CURRENT_DESKTOP", False);
	property = get_window_property(root, request, &num);
	if (property) {
		currentdesktop = *((int *)property);
		free(property);
	} else
		currentdesktop = -1;

	/* Make a list of desktops with clients including current desktop */
	char desktoplist[65];
	char desktopitem[5];
	*desktoplist = 0;
	for (int d = mindesktop; d <= maxdesktop; d++) {
		if (d == currentdesktop) {
			snprintf(desktopitem, 5, " *%d", d);
			strlcat(desktoplist, desktopitem, 64);
			continue;
		}
		int *clientptr = clientdesktoplist;
		for (int i = 0; i < numclients; i++) {
			if (*clientptr == d) {
				snprintf(desktopitem, 5, "  %d", d);
				strlcat(desktoplist, desktopitem, 64);
				break;
			}
			clientptr++;
		}
	}
	if (clientdesktoplist) free(clientdesktoplist);

	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_NewStringObj(desktoplist, -1)) != TCL_OK) {
		return TCL_ERROR;
	}
	return TCL_OK;
}

unsigned char *get_window_property(Window window, Atom request, unsigned long *nitems)
{
	unsigned long bytes_after; /* unused */
	unsigned char *prop;
	Atom type;
	int size;

	int status = XGetWindowProperty(display, window, request, 0, (~0L), False,
					AnyPropertyType, &type, &size, nitems, &bytes_after, &prop);
	if (status != Success) return NULL;
	return prop;
}

/* Error handler for X11 functions */
int error_handler(Display *display, XErrorEvent *event)
{
	char buf[256], datetime[16];
	struct tm *local;
	if (errorlog) {
		time_t sec = time(0);
		strftime(datetime, 16, "%y%m%d %H:%M:%S", localtime(&sec));
		XGetErrorText(display, event->error_code, buf, 255);
		fprintf(stderr, "%s: tclxlib: X error raised.\n", datetime);
		fprintf(stderr, "%s: [%s]\n", datetime, buf);
	}
	return 0;
}
