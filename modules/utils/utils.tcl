package require Tcl 9.0

namespace eval utils {
	proc every {ms cmd} {
		eval $cmd
		after $ms [namespace code [info level 0]]
	}

	proc read_file { filename } {
		set file [open $filename r]
		set content [read $file]
		close $file
		return $content
	}

	proc scrub_utf8_4bytes_chars { s } {
		return [regsub -all {[\U010000-\U10ffff]} $s " "]
	}

	namespace export every read_file
}

package provide utils 0.1
