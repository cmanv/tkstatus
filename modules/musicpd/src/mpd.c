#include "mpd.h"
static const int titlelength = 128;
static char host[65] = "";
static int port = 0;
static int timeout = 0;
static struct mpd_connection *conn = NULL;

int MPD_ConnectObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	if (objc == 1) {
		Tcl_SetStringObj(resultObj, "** Erreur: host ou socket manquant **", -1);
		return TCL_ERROR;
	}

	strlcpy(host, Tcl_GetString(objv[1]), 64);

	if (objc > 2) {
		if (Tcl_GetIntFromObj(interp, objv[2], &port) != TCL_OK) {
			Tcl_SetStringObj(resultObj, "** Erreur: port non valide  **", -1);
			return TCL_ERROR;
		}
	}

	if (objc > 3) {
		if (Tcl_GetIntFromObj(interp, objv[3], &timeout) != TCL_OK) {
			Tcl_SetStringObj(resultObj, "** Erreur: timeout non valide  **", -1);
			return TCL_ERROR;
		}
	}

    	if (conn) mpd_connection_free(conn);
	conn = mpd_connection_new(host, port, timeout);

	return TCL_OK;
}

int MPD_CurrentTitleObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);

	char currenttitle[titlelength];
	mpd_current_title(currenttitle, titlelength);

	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_NewStringObj(currenttitle, -1)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}

int mpd_current_title(char *currenttitle, int len)
{
	bzero(currenttitle, len);

	if ((!conn) || (mpd_connection_get_error(conn) != MPD_ERROR_SUCCESS)) {
    		if (conn) mpd_connection_free(conn);
		conn = mpd_connection_new(host, port, timeout);
		if (!conn) return 1;
    		if (mpd_connection_get_error(conn) != MPD_ERROR_SUCCESS) return 1;
	}

	struct mpd_status *status = mpd_run_status(conn);
	if (!status) return 1;

	enum mpd_state s = mpd_status_get_state(status);
	if ((s != MPD_STATE_PLAY) && (s != MPD_STATE_PAUSE)) {
		mpd_status_free(status);
		return 0;
	}

	int id = mpd_status_get_song_id(status);
	if (id <0) {
		mpd_status_free(status);
		return 0;
	}

	struct mpd_song *song = mpd_run_get_queue_song_id(conn, id);
	if (song) {
	        char album[65];
	        char title[65];
	        strlcpy(album, mpd_song_get_tag(song, MPD_TAG_ALBUM, 0), 64); 
		strlcpy(title, mpd_song_get_tag(song, MPD_TAG_TITLE, 0), 64);
		snprintf(currenttitle, len, "%s - %s", title, album);
		mpd_song_free(song);
	}
	mpd_status_free(status);
	return 0;
}
