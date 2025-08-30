#!/usr/bin/env tclsh9.0
package require utils
namespace eval zconfig {
	variable defaultfile "$::env(XDG_CONFIG_HOME)/zstatus/config"

	array set config [ list \
		lang		$::env(LANG)\
		delay		2000\
		fontname	NotoSans\
		fontsize	11\
		emojifontname	NotoSansEmoji\
		emojifontsize	11\
		geometry	"1600x26+0+0"\
		xscreen		0\
		socket		"$::env(XDG_CACHE_HOME)/zstatus/socket"\
		wmsocket 	"$::env(XDG_CACHE_HOME)/zwm/socket"]

	# Array of available widgets
	array set widgets [ list\
	    arcsize { type var source zstatus::arcsize periodic set_arcsize\
			font normal day black dark LightGray }\
	    datetime [ list type var source zstatus::datetime periodic set_datetime\
			format {%d %b %H:%M } font normal day black dark LightGray ]\
	    desklist { type var source zstatus::desklist periodic nop\
			font normal day black dark LightGray }\
	    deskmode { type var source zstatus::deskmode periodic nop\
			font normal day black dark LightGray }\
	    deskname { type var source zstatus::deskname periodic nop\
			font normal day black dark LightGray }\
	    devices { type transient periodic devices::update\
			font normal day black dark LightGray }\
	    loadavg { type var source zstatus::loadavg periodic set_loadavg\
			font normal day black dark LightGray }\
	    maildir { type transient periodic maildir::update\
			font normal day black dark LightGray }\
	    memused { type var source zstatus::memused periodic set_memused\
			font normal day black dark LightGray }\
	    metar { type var source metar::report(statusbar) periodic nop\
			font normal day black dark LightGray }\
	    mixer { type var source zstatus::mixer periodic set_mixer\
			font normal day black dark LightGray }\
	    musicpd { type transient periodic musicpd::update\
			font normal day black dark LightGray }\
	    netin { type var source zstatus::netin periodic set_netin\
			interface em0 font normal day black dark LightGray }\
	    netout { type var source zstatus::netout periodic set_netout\
			interface em0 font normal day black dark LightGray }\
	    separator { type separator periodic nop day black dark gray }\
	    statusbar { type bar periodic nop day gray90 dark gray10 }\
	    wintitle { type text ref wintitle font normal periodic nop\
			maxlength 110 font normal day black dark LightGray }]

	namespace export read get
}

proc zconfig::get {key configfile} {
	variable defaultfile
	variable config

	if {$configfile == "default"} {
		set configfile $defaultfile
	}

	set value ""
	if [info exists config($key)] {
		set value $config($key)
	}

	if [file exists $configfile] {
		set context ""
		set lines [utils::read_file $configfile]
		foreach line $lines {
			if ![string length $line] { continue }
			if [regexp {^#} $line] { continue }
			if [regexp {^\[([a-z_]+)\]} $line -> context] {
				if {$context != "main"} {
					set context ""
				}
				continue
			}
			if ![string length $context] { continue }
			if [regexp "^$key=(.+)" $line -> $value] {
				break
			}
		}
	}

	return $value
}

proc zconfig::read {configfile} {
	variable defaultfile
	variable widgets
	variable config

	set contexts { main widgets_left widgets_right\
		arcsize datetime desklist deskmode deskname devices\
		loadavg maildir memused metar mixer musicpd netin netout\
		separator wintitle }

	set default_left {deskmode separator desklist separator\
			deskname separator wintitle}
	set default_right {datetime separator}

	if {$configfile == {default}} {
		set configfile $defaultfile
	}

	set config(widgets_left) {}
	set config(widgets_right) {}

	if [file exists $configfile] {
		set context ""
		set lines [utils::read_file $configfile]
		foreach line $lines {
			if ![string length $line] { continue }
			if [regexp {^#} $line] { continue }
			if [regexp {^\[([a-z_]+)\]} $line -> context] {
				if {[lsearch $contexts $context] < 0} {
					set context ""
				}
				continue
			}
			if ![string length $context] { continue }
			if {$context == "widgets_left" || $context == "widgets_right"} {
				lappend config($context) $line
			} elseif [regexp -nocase {^([a-z_]+)=(.+)} $line -> key value] {
				if {$context == "main"} {
					set config($key) $value
				} else {
					array set widget $widgets($context)
					set widget($key) $value
					set widgets($context) [array get widget]
				}
			}
		}
	}

	if {[llength $config(widgets_left)] == 0} {
		set config(widgets_left) $default_left
	}
	if {[llength $config(widgets_right)] == 0} {
		set config(widgets_right) $default_right
	}

	set config(widgets) [array get widgets]

	return [array get config]
}

package provide zconfig @PACKAGE_VERSION@
