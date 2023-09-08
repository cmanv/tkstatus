#include "shmem.h"
const int bsize = 129;

int SharedMem_ReadObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);

	if (objc < 2) {
		Tcl_SetStringObj(resultObj, "shmem:read: adresse manquante.", -1);
		return TCL_ERROR;
	}	

	char shmem[bsize];
	strlcpy(shmem, Tcl_GetString(objv[1]), bsize-1);

	char buffer[bsize];
	bzero(buffer, bsize);
	int fd = shm_open(shmem, O_RDONLY, 0600);
	if (fd >= 0) { 
		ssize_t len = read(fd, buffer, bsize-1);
		close(fd);
	}

	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_NewStringObj(buffer, -1)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}

int SharedMem_WriteObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);

	if (objc < 2) {
		Tcl_SetStringObj(resultObj, "shmem::write: adresse manquante.", -1);
		return TCL_ERROR;
	}

	if (objc < 3) {
		Tcl_SetStringObj(resultObj, "shmem::write: message manquant.", -1);
		return TCL_ERROR;
	}
	
	char shmem[bsize];
	strlcpy(shmem, Tcl_GetString(objv[1]), bsize-1);

	char buffer[bsize];
	strlcpy(buffer, Tcl_GetString(objv[2]), bsize-1);

	int fd = shm_open(shmem, O_CREAT|O_TRUNC|O_RDWR, 0600);
	if (fd < 0) { 
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;
	}

	int err = ftruncate(fd, bsize);
	if (err < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;
	}		

	ssize_t len = write(fd, buffer, bsize-1);
	if (len < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;
	}		
	close(fd);

	return TCL_OK;
}

int SharedMem_DeleteObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);

	if (objc < 2) {
		Tcl_SetStringObj(resultObj, "shmem:delete: adresse manquante.", -1);
		return TCL_ERROR;
	}	

	char shmem[bsize];
	strlcpy(shmem, Tcl_GetString(objv[1]), bsize-1);

	int err = shm_unlink(shmem);
	if (err < 0) { 
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;
	}

	return TCL_OK;
}
