if {![package vsatisfies [package provide Tk] 9.0]} {return}
package ifneeded metar 0.2 [list source [file join $dir metar.tk]]
package ifneeded metar::decode 0.2 [list source [file join $dir metar_decode.tcl]]
