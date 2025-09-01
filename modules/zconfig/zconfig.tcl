#!/usr/bin/env tclsh9.0
package require utils
namespace eval zconfig {
	if [info exists ::env(XDG_CONFIG_HOME)] {
		set config_prefix $::env(XDG_CONFIG_HOME)
	} else {
		set config_prefix $::env(HOME)/.config
	}

	if [info exists ::env(XDG_CACHE_HOME)] {
		set cache_prefix $::env(XDG_CACHE_HOME)
	} else {
		set cache_prefix $::env(HOME)/.cache
	}
	if [info exists ::env(LANG)] {
		set config(lang) $::env(LANG)
	} else {
		set config(lang) C
	}

	variable defaultfile "$config_prefix/zstatus/config"

	array set config [ list \
		timezone	UTC\
		delay		2000\
		fontname	NotoSans\
		fontsize	11\
		emojifontname	NotoSansEmoji\
		emojifontsize	11\
		barsocket	"$cache_prefix/zstatus/socket"\
		zwmsocket 	"$cache_prefix/zwm/socket"]

	# Array of available widgets
	array set widgets {\
	    arcsize { type var source zstatus::arcsize periodic set_arcsize\
			font normal light black dark LightGray }\
	    datetime { type var source zstatus::datetime periodic set_datetime\
			format {%d %b %H:%M} font normal light black dark LightGray}\
	    desklist { type var source zstatus::desklist periodic nop\
			font normal light black dark LightGray }\
	    deskmode { type var source zstatus::deskmode periodic nop\
			font normal light black dark LightGray }\
	    deskname { type var source zstatus::deskname periodic nop\
			font normal light black dark LightGray }\
	    devices { type transient periodic devices::update\
			font normal light black dark LightGray }\
	    loadavg { type var source zstatus::loadavg periodic set_loadavg\
			font normal light black dark LightGray }\
	    mail { type transient periodic mail::update\
			font normal light black dark LightGray }\
	    memused { type var source zstatus::memused periodic set_memused\
			font normal light black dark LightGray }\
	    metar { type var source metar::report(statusbar) periodic nop\
			delay 600000 geometry {-1+26}\
			font normal light black dark LightGray }\
	    mixer { type var source zstatus::mixer periodic set_mixer\
			font normal light black dark LightGray }\
	    musicpd { type transient periodic musicpd::update\
			font normal light black dark LightGray }\
	    netin { type var source zstatus::netin periodic set_netin\
			interface em0 font normal light black dark LightGray }\
	    netout { type var source zstatus::netout periodic set_netout\
			interface em0 font normal light black dark LightGray }\
	    separator { type separator periodic nop light black dark gray }\
	    statusbar { type bar periodic nop light gray90 dark gray20 }\
	    wintitle { type text ref wintitle font normal periodic nop\
			maxlength 110 font normal light black dark LightGray }}

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

	# List of valid contexts in config file
	set contexts { main widgets_left widgets_right\
		arcsize datetime desklist deskmode deskname devices\
		loadavg mail maildir memused metar mixer musicpd\
		netin netout separator statusbar wintitle}

	# Cant change these from config file
	set immutables {type source ref periodic}

	if {$configfile == {default}} {
		set configfile $defaultfile
	}

	set config(widgets_left) {deskmode separator desklist separator\
			deskname separator wintitle}
	set config(widgets_right) {datetime}
	array set mailboxes {}

	if [file exists $configfile] {
		set index 0
		set context ""
		set lines [split [utils::read_file $configfile] "\n"]
		foreach line $lines {
			if ![string length $line] { continue }
			if [regexp {^#} $line] { continue }
			if [regexp {^\[([a-z_]+)\]} $line -> context] {
				if {[lsearch $contexts $context] < 0} {
					set context ""
				}
				if {$context == "widgets_left"} {
					set config(widgets_left) {}
				}
				if {$context == "widgets_right"} {
					set config(widgets_right) {}
				}
				if {$context == "maildir"} {
					incr index
				}
				continue
			}
			if ![string length $context] { continue }
			if {$context == "widgets_left" || $context == "widgets_right"} {
				lappend config($context) $line
			} elseif [regexp {^([a-z_]+)=(.+)} $line -> key value] {
				if {[lsearch $immutables $key] >= 0} {
					continue
				}
				if {$context == "main"} {
					set config($key) $value
				} elseif {$context == "maildir"} {
					if [info exists mailboxes($index)] {
						array set mailbox $mailboxes($index)
					}
					set mailbox($key) $value
					set mailboxes($index) [array get mailbox]
				} else {
					array set widget $widgets($context)
					set widget($key) $value
					set widgets($context) [array get widget]
				}
			}
		}
	}

	# Validate mailboxes
	foreach index [array names mailboxes] {
		array set mailbox $mailboxes($index)
		if ![info exists mailbox(light)] {
			set mailbox(light) black
		}
		if ![info exists mailbox(dark)] {
			set mailbox(dark) LightGray
		}
		if {![info exists mailbox(name)] || ![info exists mailbox(path)]} {
			array unset mailboxes $index
		} else {
			set mailboxes($index) [array get mailbox]
		}
	}
	set config(mailboxes) [array get mailboxes]
	set config(widgets) [array get widgets]

	return [array get config]
}

package provide zconfig @PACKAGE_VERSION@
