#include "sysinfo.h"

int SysInfo_GetLoadAvgObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	double loadavg;

	if (getloadavg(&loadavg, 1) < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf("%.2f", loadavg)) != TCL_OK) {
		return TCL_ERROR;	
	}

	return TCL_OK;
}

int SysInfo_GetUsedMemSwapObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);

	long active = 0;
	size_t size = sizeof(long);
	int err = sysctlbyname("vm.stats.vm.v_active_count", &active, &size, (void *)NULL, (size_t)0); 
	if (err < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	long wired = 0;
	err = sysctlbyname("vm.stats.vm.v_wire_count", &wired, &size, (void *)NULL, (size_t)0); 
	if (err < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	long memused = (active + wired)>>8;

	/* Get amount of swap in use */
	struct xswdev xsw;
	int mib[16];
	size_t mibsize = sizeof mib / sizeof mib[0];
	if (sysctlnametomib("vm.swap_info", mib, &mibsize) == -1) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	long swapused = 0;
	for (int n=0; ; ++n) {
		mib[mibsize] = n;
		size = sizeof xsw;
		if (sysctl(mib, mibsize + 1, &xsw, &size, NULL, 0) == -1) break;
		swapused += (xsw.xsw_used >> 8);
	}

	/* Returned a string containing both used memory and swap if applicable */
	char vmemused[33];
	snprintf(vmemused, 32, "%ld Mo", memused);
	if (swapused) {
		char swap[17];
		snprintf(swap, 16, " (%ld Mo)", swapused); 
		strlcat(vmemused, swap, 31); 
	}

	if (Tcl_ListObjAppendElement(interp, resultObj,  Tcl_NewStringObj(vmemused, -1)) != TCL_OK) {
		return TCL_ERROR;	
	}

	return TCL_OK;
}

int SysInfo_GetAcpiTempObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	int temp;
	size_t size = sizeof(int);

	int err = sysctlbyname("hw.acpi.thermal.tz0.temperature", &temp, &size, 
				(void *)NULL, (size_t)0); 
	if (err < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	double tcelcius = (double)(temp - 2731)/10;
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf("%.f°C", tcelcius)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}

int SysInfo_GetCpuTempObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	int temp;
	size_t size = sizeof(int);

	int err = sysctlbyname("dev.cpu.0.temperature", &temp, &size, 
				(void *)NULL, (size_t)0); 
	if (err < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	double tcelcius = (double)(temp - 2731)/10;
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf("%.f°C", tcelcius)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}

int SysInfo_GetCpuFreqObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	int freq;
	size_t size = sizeof(int);

	int err = sysctlbyname("dev.cpu.0.freq", &freq, &size, 
				(void *)NULL, (size_t)0); 
	if (err < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}

	double fmhz = (double)(freq)/1000;
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf("%.1f Mhz", fmhz)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}

int SysInfo_GetNetStatsObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	long long ibytes, obytes;
	double inbound, outbound;
	char iface[33];
	struct ifaddrs *ifap, *ifa;
	struct if_data *ifd;

	if (objc < 2) {
		Tcl_SetStringObj(resultObj, "getnetstats: Interface manquante.", -1);
		return TCL_ERROR;
	}

	strlcpy(iface, Tcl_GetString(objv[1]), 32);

	if (getifaddrs(&ifap) < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;
	}
	for (ifa = ifap; ifa; ifa = ifa->ifa_next) {
		if (strcmp(ifa->ifa_name, iface)) continue;
		ifd = (struct if_data *)ifa->ifa_data;
		inbound = (double)(ifd->ifi_ibytes>>10);
		outbound = (double)(ifd->ifi_obytes>>10);
		break;
	}
	freeifaddrs(ifap);	

	char iunit[3], ounit[3];
	strcpy(iunit, "Ko");
	strcpy(ounit, "Ko");
	if (inbound>1024) { inbound /= 1024; strcpy(iunit, "Mo"); }
	if (outbound>1024) { outbound /= 1024; strcpy(ounit, "Mo"); }
	if (inbound>1024) { inbound /= 1024; strcpy(iunit, "Go"); }
	if (outbound>1024) { outbound /= 1024; strcpy(ounit, "Go"); }

	char ifmt[8], ofmt[8];
	strcpy(ifmt, "%.0f %s");
	if (inbound < 100) strcpy(ifmt, "%.1f %s");
	if (inbound < 10) strcpy(ifmt, "%.2f %s");
	strcpy(ofmt, "%.0f %s");
	if (outbound < 100) strcpy(ofmt, "%.1f %s");
	if (outbound < 10) strcpy(ofmt, "%.2f %s");

	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf(ifmt, inbound, iunit)) != TCL_OK) {
		return TCL_ERROR;	
	}
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf(ofmt, outbound, ounit)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}

int SysInfo_GetMixerVolObjCmd( ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *const objv[])
{
	Tcl_Obj	*resultObj = Tcl_GetObjResult(interp);
	int value;
	int device = 0;

	int fd = open("/dev/mixer", O_RDONLY);
	if (fd < 0) {
		Tcl_SetStringObj(resultObj, Tcl_PosixError(interp), -1);
		return TCL_ERROR;	
	}
	ioctl(fd, MIXER_READ(device), &value);
	close(fd);

	int vol = value & 0x7f;
	if (Tcl_ListObjAppendElement(interp, resultObj, Tcl_ObjPrintf("%d%%", vol)) != TCL_OK) {
		return TCL_ERROR;	
	}
	return TCL_OK;
}
