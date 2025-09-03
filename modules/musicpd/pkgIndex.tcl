package ifneeded MPD @PACKAGE_VERSION@ [list load [file join $dir lib@TARGET_LIB@.so]]
package ifneeded musicpd @PACKAGE_VERSION@ [list source [file join $dir musicpd.tk]]
