% zstatus(1) zstatus version alpha1 | zstatus user's manual
% cmanv
% September 2025

# NAME

zstatus — a status bar for the zwm window manager

# SYNOPSIS

**status.tk** \[-display <display>\] \[-config <configfile>\] \[-theme <defaulttheme>t\] \[-help\]

# DESCRIPTION

**zstatus.tk** is a statusbar for ZWM written in Tcl/Tk and C.

# COMMAND LINE OPTIONS

**-display** _display_

> Use _display_ as the default X display.

**-config** _configfile_

> Use _configfile_ as the configuration file.

**-theme** _theme_

> Specify the startup theme as either "dark" or "light". This can also be specified
trough the configuration file.

**-help**

> Print brief usage information.

# CONFIGURATION FILE

The configuration file (_$HOME/.config/zstatus/config_ by default)
has the general format:

> [section1]

> option1=value

> option2=value

> ..

>

> [section2]

> option1=value

> option2=value

## MAIN SECTION

These are the options can be specified in the __[main]__ section.

* __lang__

> Locale of the application. (Default: _env(LANG)_)

* __timezone__

> This should be set to the user's timezone. (Default _UTC_)

* __delay__

> Refresh frequency of the statusbar. (Default _2000_ milliseconds)

* __fontname__

> Font family used for text in the statusbar. (Default: _NotoSans_)

* __fontsize__ 

> Font size for the statusbar. (Default: _11_)

* __geometry__

> Geometry of the status bar in the format _width_x_height_+_xpos_+_ypos_.

* __emojifontsize__

> Font family used for emojis in the statusbar. (Default: _NotoSansEmoji_)

* __barsocket__

> Unix socket of the statusbar. (Default: _$HOME/.cache/zstatus/socket_)

* __zwnsocket__

> Unix socket of the window manager. (Default: _$HOME/.cache/zwm/socket_)

* __widgets_left__ 

> Ordered list of widgets starting from the left hand side of the screen.

* __widgets_right__ 

> Ordered list of wigets starting from the right hand side of the screen.

## WIDGETS SECTIONS

The list of valid widgets are:

> __arcsize__, __datetime__, __desklist__, __deskmode__, __deskname__, __devices__,
> __loadavg__, __mail__, __memused__, __metar__, __mixer__, __musicpd__, __netin__,
> __netout__, __separator__, __wintitle__

Each of these widgets can be customized in its own section:

- __arcsize__: Shows current usage of the ZFS ARC.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __datetime__: Shows current date and time in the defined _timezone_

> Options:
> - _format_: Format of the date and time (as defined in strftime(3))
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __desklist__: List of desktops currently in use.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __deskmode__: Mode of the active desktop.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __deskname__: Name of the active desktop.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __devices__: Show transient devices connected to the machine.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __loadavg__: Shows current CPU load average.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __mail__: Shows icons of new mail. There must be at least one maildir section defined.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __memused__: Shows current used memory and swap usage if applicable.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __metar__: Shows an icon and current temperature from a METAR station.
Clicking on it opens a window showing current weather conditions.

> Options:
> - _code_: 4 characters code of the METAR station.
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __mixer__: Shows an icon and the volume level of _/dev/mixer_.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __musicpd__: Shows an icon when the music player daemon is in use. Hovering on
it shows the currently playing track.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __netin__: Shows the amount of inbound traffic on a given network interface.

> Options:
> - _interface_: Network interface to monitor
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __netout__: Shows the amount of outbound traffic on a given network interface.

> Options:
> - _interface_: Network interface to monitor
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __separator__: Widget acting as vertical separators between two widgets.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __wintitle__: Displays the title of the currently active window.

> Options:
>-  _maxlength_: Maximum length of text to display. (Default 110 characters)
> - _light_: color in light mode.
> - _dark_: color in dark mode.

## OTHER SECTIONS

- __maildir__: Defines a mailbox to watch in the __mail__ widget.
The mailbox __must__ be in the _maildir_ format.

> Options:
> - _name_: Name of the maildir (mandatory)
> - _path_: Path of the maildir (mandatory)
> - _light_: color in light mode.
> - _dark_: color in dark mode.

- __statusbar__: Used to define the background color of the statusbar.

> Options:
> - _light_: color in light mode.
> - _dark_: color in dark mode.

# FILES

If not specified at the command line, the configuration file _~/.config/zstatus/config_ is read at startup.

# BUGS

See GitHub Issues: <https://github.com/cmanv/zstatus/issues>
