package require Tcl 9.0

namespace eval utils {
	proc every {ms cmd} {
		after $ms [namespace code [info level 0]]
		eval $cmd
	}

	proc read_file { filename } {
		set content ""
		set file [open $filename r]
		catch {set content [chan read $file]}
		chan close $file
		return $content
	}

	namespace export every read_file
}

package provide utils @PACKAGE_VERSION@
