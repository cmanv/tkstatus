#!/usr/bin/env tclsh9.0
package require utils
namespace eval zconfig {
	variable defaultfile "$::env(HOME)/.config/zstatus/config"

	array set config [ list \
		fontname	NotoSans\
		fontsize	11\
		emojifontname	NotoSansEmoji\
		emojifontsize	11\
		geometry	"1600x26+0+0"\
		xscreen		0\
		socket		"$::env(XDG_CACHE_HOME)/zstatus/socket"\
		wmsocket 	"$::env(XDG_CACHE_HOME)/zwm/socket"\
		themefile 	"$::env(XDG_STATE_HOME)/theme/current"]

	namespace export read get
}

proc zconfig::get {context key configfile} {
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
		set section ""
		set lines [utils::read_file $configfile]
		foreach line $lines {
			if ![string length $line] { continue }
			if [regexp {^#} $line] { continue }
			if [regexp {^\[([a-z_]+)\]} $line -> section] {
				if {$section != $context} {
					set section ""
				}
				continue
			}
			if ![string length $section] { continue }
			if [regexp "^$key=(.+)" $line -> $value] {
				break
			}
		}
	}

	return $value
}

proc zconfig::read {configfile} {
	variable defaultfile
	variable config
	variable lwidgets {}
	variable rwidgets {}

	set sections {general left_widgets right_widgets}
	set default_lwidgets {deskmode separator desklist separator\
			deskname separator wintitle}
	set default_rwidgets {datetime}

	if {$configfile == {default}} {
		set configfile $defaultfile
	}

	if [file exists $configfile] {
		set section ""
		set lines [utils::read_file $configfile]
		foreach line $lines {
			if ![string length $line] { continue }
			if [regexp {^#} $line] { continue }
			if [regexp {^\[([a-z_]+)\]} $line -> section] {
				if {[lsearch $sections $section] < 0} {
					set section ""
				}
				continue
			}
			if ![string length $section] { continue }
			process_$section $line
		}
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

proc zconfig::process_general {line} {
	variable config
	if [regexp {^([^=]+)=(.+)} $line -> key value] {
		set config($key) $value
	}
}

proc zconfig::process_left_widgets {line} {
	variable lwidgets
	lappend lwidgets $line
}

proc zconfig::process_right_widgets {line} {
	variable rwidgets
	lappend rwidgets $line
}

package provide zconfig 0.1
