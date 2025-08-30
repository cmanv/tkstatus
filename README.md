# zstatus
Status bar for ZWM written in tcl/tk and C.

TODO: rewrite this thing, as it is really outdated.

## Introduction
This is a personal project designed for a FreeBSD desktop with the zwm window manager. The main script uses tcl/tk 9.0.

The tcl language lacks the functions to access system information. But this is circumvented by using packages which are collections of C functions.

The shared libraries should be installed under **TCLLIBPATH**. The path of the relevant external libraries such as __libmpdclient.so__ should be defined in **LD_PRELOAD**. In my case, this is done in the calling shell script __zstatus.sh__.

## Files
### zstatus.sh
This shell script should be called at startup in __.xinitrc__ or __.xsession__.

### zstatus.tk
This is the main script. It's highly likely that you'll want to modify it for your own system.

## Modules
### devices
This module is used to report on the presence of removable devices on the system, such a disks or printers.

### mail
Report on the presence of new mail in specified maildirs directories.

### metar
This module is used to display a short weather report from a METAR station. Currently, the reports are in french only. ;)

### musicpd
This module is used to return the currently playing song on the Music Player Daemon. It requires the __libmpdclient__ package and corresponding header files to build.

* mpd::connect(host) :
Connects to the currently running Music Player Daemon. The host can be a Unix socket or a resolvable internet address.

* mpd::currenttitle :
Returns the title of the song currently playing.

### sysbsd
This module is system specific. The provided version was written for FreeBSD 14.X.
The following functions are provided:

* sysbsd::getloadavg :
Load average for the last minute.

* sysbsd::getusedmemswap :
Returns the used memory defined as active memory + wired memory. The amount of swap used is provided within parenthesis if any.

* sysbsd::getacpitemp :
Returns the content of __hw.acpi.thermal.tz0.temperature__ in celcius.

* sysbsd::getnetstats(if) :
Returns the amount data downloaded end uploaded on the given interface.

* sysbsd::getmixervol :
Returns the current volume of the mixer.
 
## Themes

The bar has a light and dark theme built-in. The theme can be selected by running the script __zstatus-send__. For example:
_zstatus-theme select-theme=dark_

![Light theme](png/statusbar-light.png)

![Dark theme](png/statusbar-dark.png)

## Unicode font

The script uses some icons from the __remixicon__ unicode font to be displayed next to some devices names. Theses need to be adjusted if you're using a different unicode font.

## Unix domain socket

The statusbar is listening to a UNIX domain socket. It is able to receive messages from applications for various status changes instead of polling for them. For example a window manager can send messages for active window change, desktop change etc.. The theme can also be toggled in this way. This mechanism helps keeping the CPU usage at a very low level.
