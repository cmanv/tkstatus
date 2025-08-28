#!/usr/bin/env tclsh9.0
package require utils
namespace eval zconf {
	variable file "$::env(HOME)/.config/zstatus/config"

	array set config [ list \
		lang		fr\
		timezone	America/Montreal\
		fontname	NotoSans\
		fontsize	11\
		geometry	1920x26+0+0\
		emojifontname	NotoSansEmoji\
		emojifontsize	11\
		xscreen		0\
		socket		"$::env(XDG_CACHE_HOME)/zstatus/socket"\
		wmsocket 	"$::env(XDG_CACHE_HOME)/zwm/socket"\
		themefile 	"$::env(XDG_STATE_HOME)/theme/current"]

	namespace export readconfig
}

proc zconf::readconfig {} {
	variable file
	variable config
	variable lwidgets {}
	variable rwidgets {}

	set sections {general left_widgets right_widgets}
	set default_lwidgets {deskmode separator desklist separator\
			deskname separator wintitle}
	set default_rwidgets {datetime}

	set section ""
	set lines [utils::read_file $file]
	foreach line $lines {
		if {![string length $line]} { continue }
		if {[regexp -line {^#} $line]} { continue }
		if {[regexp {^\[([a-z_]+)\]} $line -> section]} {
			if {[lsearch $sections $section] < 0} {
				set section ""
			}
			continue
		}
		if {![string length $section]} { continue }
		process_$section $line
	}

	if ![llength $lwidgets] {
		set lwidgets $default_lwidgets
	}
	if ![llength $rwidgets] {
		set rwidgets $default_rwidgets
	}
	set config(lwidgets) $lwidgets
	set config(rwidgets) $rwidgets

	return [array get config]
}

proc zconf::process_general {line} {
	variable config
	regexp {^([^=]+)=(.+)} $line all key value
	set config($key) $value
}

proc zconf::process_left_widgets {line} {
	variable lwidgets
	lappend lwidgets $line
}

proc zconf::process_right_widgets {line} {
	variable rwidgets
	lappend rwidgets $line
}

package provide zconf 0.1
