package require Tcl 9.0

namespace eval ::metar::decode {
	set metar_api 			https://aviationweather.gov/api/data/metar
	set station_api 		https://aviationweather.gov/api/data/stationinfo
	set report(prev_date)		""
	set report(prev_pressure)	""

	# default value
	array set station {\
		code		CYUL\
		name		Montréal/Dorval\
		timezone	America/Montreal\
		longitude	-73.59\
		latitude	45.525}

	array set const {\
		pi			3.14159265358979\
		obliquity 		23.4363\
		julian1970 		2440587.5\
		julian2000		2451545\
		km_mile			1.609344\
		km_nautical_mile	1.852\
		cm_inch			2.54\
		cm_feet			30.48\
		kp_mmhg			0.133322}

	array set remixicons {\
		inconnu		\ueba2\
		nuage0-jour	\uf155\
		nuage0-nuit	\uef1f\
		nuage1-jour	\uf154\
		nuage1-nuit	\uef24\
		nuage2-jour	\uf151\
		nuage2-nuit	\uef21\
		couvert		\ueb9d\
		brume		\ued29\
		pluie		\uec4a\
		averse		\uede0\
		neige		\uf0f8\
		grêle		\uedc0\
		orage		\uf196}

	array set intensities {\
		{-} 	{type pre m {faible_} f {faible_}}\
		{+} 	{type pre m {fort_} f {forte_}}\
		{VC} 	{type post m {au voisinage} f {au voisinage}}}

	array set qualifiers {\
		MI	{type pre m {mince_} f {mince_}}\
		BC	{type pre m {bancs de} genre m nombre p}\
		PR	{type post m {dispersé} f { dispersée_} }\
		DR	{type pre f {chasse basse de} genre f nombre s}\
		BL	{type pre f {chasse haute de} genre f nombre s}\
		SH	{type pre f {averses de} genre f nombre p}\
		TS	{type pre m {orages de} genre m nombre p}\
		FZ	{type post m {verglaçant_} f {verglaçante_}}}

	array set precip_codes {\
		DZ	{descr {bruine} genre f nombre s}\
		RA	{descr {pluie} genre f nombre s}\
		SN	{descr {neige} genre f nombre s}\
		SG	{descr {neige en grain} genre f nombre s}\
		IC	{descr {cristaux de glace} genre m nombre p}\
		PL	{descr {granules de neige} genre m nombre p}\
		GR	{descr {grêle} genre f nombre s}\
		GS	{descr {neige roulée} genre f nombre s}\
		UP	{descr {inconnue} genre f nombre s}\
		BR	{descr {brume} genre f nombre s}\
		FG	{descr {brouillard} genre m nombre s}\
		FU	{descr {fumée} genre f nombre s}\
		VA	{descr {cendre volcanique} genre f nombre s}\
		DU	{descr {poussière} genre f nombre s}\
		SA	{descr {sable} genre m nombre s}\
		HZ	{descr {brume sèche} genre f nombre s}\
		PO	{descr {tourbillons de poussière} genre m nombre p}\
		SQ	{descr {grains} genre m nombre p}\
		{+FC}	{descr {tornades} genre f nombre p}\
		FC	{descr {entonnoirs} genre m nombre p}\
		SS	{descr {tempête de sable} genre f nombre s}\
		DS	{descr {tempête de poussière} genre f nombre s}}

	array set cloud_codes {\
		SKC	{Ciel dégagé}\
		FEW	{Quelques nuages}\
		SCT	{Nuages dispersés}\
		BKN	{Éclaircies}\
		OVC	{Couvert}\
		CLR	{Aucun nuage bas}\
		VV	{Ciel obscurci}}

	array set cloud_types {\
		CB	{Cumulonimbus}\
		TCU	{Cumulus bourgeonnant}}

	array set direction {\
		{000}	N  	{010}	N\
		{020}	NNE  	{030}	NNE\
		{040}	NE 	{050}	NE\
		{060}	ENE 	{070}	ENE\
		{080}	E	{090}	E\
		{100}	E	{110}	ESE\
		{120}	ESE	{130}	SE\
		{140}	SE	{150}	SSE\
		{160}	SSE	{170}	S\
		{180}	S	{190}	S\
		{200}	SSO	{210}	SSO\
		{220}	SO	{230}	SO\
		{240}	OSO	{250}	OSO\
		{260}	O	{270}	O\
		{280}	O	{290}	ONO\
		{300}	ONO	{310}	NO\
		{320}	NO	{330}	NNO\
		{340}	NNO	{350}	N\
		{360}	N}

	namespace export get_station get_report
}

proc ::metar::decode::current_day {} {
	variable station

	set currenttime [clock seconds]
	set fixedtime [clock format $currenttime -format {%Y-%m-%d 12:00:00}\
			-timezone $station(timezone)]
	set currentday [expr round([clock scan $fixedtime -format {%Y-%m-%d %H:%M:%S}\
			-timezone $station(timezone)]/86400.0)]
}

proc ::metar::decode::current_date {} {
	variable station

	set currenttime [clock seconds]
	set datetime [clock format $currenttime -format {%Y-%m-%d}\
			-timezone $station(timezone)]
}

proc ::metar::decode::calc_seconds { datetime } {
	variable station

	set currenttime [clock scan $datetime -format {%Y-%m-%d %H:%M:%S}\
			-timezone $station(timezone)]
}

proc ::metar::decode::calc_timezone_offset {} {
	variable station

	set currenttime [clock seconds]
	set tzoffset [clock format $currenttime -format {%z} -timezone $station(timezone)]
	set len [string length $tzoffset]
	set moffset [expr [scan [string range $tzoffset $len-2 $len-1] %f]/60]
	set hoffset [expr [scan [string range $tzoffset 0 $len-3] %f]]
	if {$hoffset < 0} {
		set tzoffset [expr ($hoffset - $moffset)]
	} else {
		set tzoffset [expr ($hoffset + $moffset)]
	}
	return $tzoffset
}

proc ::metar::decode::get_station { } {
	variable station
	variable const

	set julian_day [expr [current_day] + $const(julian1970) - $const(julian2000)]

	# Anomalie moyenne de la terre
	set AM [expr fmod(357.5291 + 0.98560028*$julian_day, 360.0)]

	# Facteur d'excentricité
	set EC [expr 1.91476*sin($AM*$const(pi)/180.0) \
			+ 0.020*sin(2.0*$AM*$const(pi)/180.0) \
			+ 0.00029*sin(3.0*$AM*$const(pi)/180.0) ]

	# Longitude écliptique du soleil
	set LE [expr fmod(280.4665 + 0.98564736*$julian_day + $EC, 360.0)]

	# Facteur d'obliquité en degrés
	set OB [expr -2.46569*sin(2.0*$LE*$const(pi)/180.0) \
			+ 0.0530*sin(4.0*$LE*$const(pi)/180.0) \
			- 0.0014*sin(6.0*$LE*$const(pi)/180.0) ]

	# Equation du temps
	set EQT [expr $EC + $OB]

	set sun_dec [expr asin(sin($const(obliquity)*$const(pi)/180.0)\
			 *sin($LE*$const(pi)/180.0))]
	set station_lat [expr $station(latitude)*$const(pi)/180.0]
	set refract [expr -sin(0.6*$const(pi)/180.0)]

	# H0 est l'angle entre le méridien et les points de lever/coucher du soleil
	set H0 [expr acos($refract - tan($sun_dec)*tan($station_lat)) * 180.0/$const(pi)]

	set tzoffset [calc_timezone_offset]
	set sunrise [expr (180.0 - $H0 + $EQT - $station(longitude))/15.0 + $tzoffset]
	set sunset [expr (180.0 + $H0 + $EQT - $station(longitude))/15.0 + $tzoffset]

	set hour1 [expr int(floor($sunrise))]
	set min1 [format {%02d} [expr round(fmod($sunrise,1.0) * 60)]]
	set hour2 [expr int(floor($sunset))]
	set min2 [format {%02d} [expr round(fmod($sunset,1.0) * 60)]]

	if {$min1 == 60} {
		set hour1 [expr $hour1 + 1]
		set min1 "00"
	}
	if {$min2 == 60} {
		set hour2 [expr $hour2 + 1]
		set min2 "00"
	}

	set station(sunrise) "$hour1:$min1"
	set station(sunset) "$hour2:$min2"
	set station(julian) $julian_day

	set currenttime [clock seconds]
	set currentdate [current_date]
	set sunrisetime [calc_seconds "$currentdate $station(sunrise):00"]
	set sunsettime [calc_seconds "$currentdate $station(sunset):00"]
	if {$currenttime < $sunsettime && $currenttime > $sunrisetime} {
		set station(daylight) 1
	} else {
		set station(daylight) 0
	}

	return [array get station]
}

proc ::metar::decode::calc_windchill { temperature windspeed } {
	if {$windspeed < 4.0} {
		set windchill [expr $temperature + 0.2 * (0.1345 * $temperature -1.59)\
				* $windspeed]
	} else {
		set windchill [expr 13.12 + 0.6215 * $temperature \
				+ (0.3965 * $temperature - 11.37) * pow($windspeed, 0.16)]
	}
	set diff [expr round( $temperature - $windchill)]
	if {$diff >= 1} {
		set windchill [expr round($windchill)]
	} else {
		set windchill ""
	}
	return $windchill
}

proc ::metar::decode::calc_rel_humidity { temperature dew } {
	# Utilise l'équation de Buck pour calculer les pressions saturantes de vapeur d'eau
	set p1 [expr 0.01121 * exp((18.678 - $temperature/234.5) \
		* ($temperature/(257.14 + $temperature)))]
	set p2 [expr 0.01121 * exp((18.678 - $dew/234.5) \ * ($dew/(257.14 + $dew)))]
	set rel_humidity [expr round(100 * $p2/$p1)]
}

proc ::metar::decode::calc_humidex { temperature dew } {
	set humidex [expr $temperature + 0.5555 * (6.11 * exp( 5417.753 * \
		(1/273.16 - 1/($dew + 273.16))) - 10.0)]
	if {$humidex > 24} {
		set humidex [expr round($humidex)]
	} else {
		set humidex ""
	}
	return $humidex
}

proc ::metar::decode::decode_datetime { datetime } {
	variable station
	variable current

	set day [string range $datetime 0 1]
	set hour [string range $datetime 2 3]
	set minute [string range $datetime 4 5]

	set currenttime [clock seconds]
	set date [clock format $currenttime -format {%Y-%m} -timezone :UTC]
	set date "$date-$day $hour:$minute:00"
	set rtime [clock scan $date -format {%Y-%m-%d %H:%M:%S} -timezone :UTC]
	set date [clock format $rtime -format {%d %B %H:%M %Z} -locale fr \
			-timezone $station(timezone)]
	set current(date) $date
}

proc ::metar::decode::decode_wind { wdir wspeed wgust } {
	variable const
	variable current
	variable direction

	set current(speed) [expr round([scan $wspeed %d] * $const(km_nautical_mile))]
	if {[string length $wgust]} {
		set current(gust) [expr round([scan $wgust %d] * $const(km_nautical_mile))]
	}
	set current(direction) $direction($wdir)
}

proc ::metar::decode::decode_lightwind { wspeed } {
	variable current
	set current(speed) [expr round($wspeed * 1.852)]
}

proc ::metar::decode::decode_temp { m1 tcode m2 dcode } {
	variable current
	if {[string length $m1]} {
		set current(temp) [expr round(-[scan $tcode %d])]
	} else {
		set current(temp) [expr round([scan $tcode %d])]
	}
	if {[string length $m2]} {
		set current(dew) [expr round(-[scan $dcode %d])]
	} else {
		set current(dew) [expr round([scan $dcode %d])]
	}
}

proc ::metar::decode::decode_visibility { vcode } {
	variable const
	variable current
	set divider [expr [string first "/" $vcode]]
	if {$divider != -1} {
		set numerator [string range $vcode 0 $divider-1]
		set denominator [string range $vcode $divider+1 end]
		if {[string length $denominator] == 0} {
			set denominator "1"
		}
		set current(visibility) [format {%0.1f} [expr round(10 * $const(km_mile) \
					* $numerator / $denominator)/10.0]]
	} else {
		set current(visibility) [format {%0.1f} [expr round(10 * $const(km_mile) \
					* $vcode)/10.0]]
	}
}

proc ::metar::decode::decode_pressure { pcode } {
	variable const
	variable current
	set current(pressure) [format {%0.1f} [expr round([scan $pcode %d] \
				* $const(cm_inch) * $const(kp_mmhg))/10.0]]
}

proc ::metar::decode::decode_clouds { code alt type } {
	variable cloud_codes
	variable cloud_types
	variable const
	variable current

	set desc $cloud_codes($code)
	set current(cloud_code) $code
	set current(cloud_desc) $desc
	if {[string length $alt]} {
		set altitude [expr 100 * round([scan $alt %d] * $const(cm_feet) / 100)]
		if {[info exists current(clouds)]} {
			set current(clouds) "$current(clouds)\n$desc, $altitude m"
		} else {
			set current(clouds) "$desc, $altitude m"
		}
	} else {
		if {[info exists current(clouds)]} {
			set current(clouds) "$current(clouds)\n$desc"
		} else {
			set current(clouds) $desc
		}
	}
	if {[string length $type]} {
		set current(cloud_type) $cloud_types($type)
	}
}

proc ::metar::decode::decode_precips { icode qcode pcodes } {
	variable intensities
	variable qualifiers
	variable precip_codes
	variable current

	if {[string length $icode]} {
		array set intensity $intensities($icode)
	}
	if {[string length $qcode]} {
		array set qualifier $qualifiers($qcode)
		if {![info exists current(precip_qcode)]} {
			set current(precip_qcode) $qcode
		}
	}

	set codes {}
	set remaining $pcodes
	while {[string length $remaining]} {
		if {[regexp {^(DZ|RA|SN|SG|IC|PL|GR|GS|UP|BR|FG|FU|VA|DU|SA|HZ|PO|SQ|[+]FC|FC|SS|DS)([A-Z+]{2,})?$}\
			$remaining -> code remaining]} {
			if {![info exists current(precip_code)]} {
				set current(precip_code) $code
			}
			lappend codes $code
		}
		break
	}

	foreach code $codes {
		set post1 ""
		set post2 ""
		set pre1 ""
		set pre2 ""

		array set precip $precip_codes($code);
		set genre $precip(genre)
		set nombre $precip(nombre)
		if {[string length $qcode]} {
			if {[info exists qualifier(genre)]} {
				set genre $qualifier(genre)
				set nombre $qualifier(nombre)
			}
			if {$qualifier(type) == "post"} {
				set post2 $qualifier($genre)
			} else {
				set pre2 $qualifier($genre)
			}
		}
		if {[string length $icode]} {
			if {$intensity(type) == "post"} {
				set post1 $intensity($genre)
			} else {
				set pre1 $intensity($genre)
			}
		}

		set description [string trim "$pre1$pre2$precip(descr)$post2$post1"]
		if {$nombre == "p"} {
			set description [string map {_ s} $description]
		} else {
			set description [string map {_ {}} $description]
		}
		if {[info exists current(precips)]} {
			set current(precips) "$current(precips)\n$description"
		} else {
			set current(precips) $description
		}
	}
}

proc ::metar::decode::fetch_metar_report {} {
	variable station
	variable request_status
	variable metar_api

	set request_status {OK}
	if {[catch {set message [exec -ignorestderr -- curl -s \
			$metar_api?ids=$station(code)]}]} {
		set request_status {KO}
		return
	}
	if {![string length $message]} {
		set request_status {KO}
		return
	}
	return $message
}

proc ::metar::decode::decode_metar_report { message } {
	variable request_status
	variable current
	variable station

	if {$request_status != {OK}} {
		return
	}
	array unset current

	set tokens [split $message " "]
	foreach token $tokens {
		if {$token == "RMK"} break
		if {$token == $station(code)} continue

		if [regexp {^([0-9]{6})Z$} $token -> datetime] {
			decode_datetime $datetime
			continue
		} elseif [regexp {^([0-9]{3})([0-9]{2})(G([0-9]{2}))?KT$}\
			$token -> dir speed gust0 gust1] {
			decode_wind $dir $speed $gust1
			continue
		} elseif [regexp {^VRB([0-9]{2})KTS$} $token -> lspeed] {
			decode_lightwind $lspeed
			continue
		} elseif [regexp {^(M)?([0-9]{2})/(M)?([0-9]{2})$}\
			$token -> m1 temp m2 dew] {
			decode_temp $m1 $temp $m2 $dew
			continue
		} elseif [regexp {^([0-9/]{1,4})SM$} $token -> visibility] {
			decode_visibility $visibility
			continue
		} elseif [regexp {^A([0-9]{4})$} $token -> pressure] {
			decode_pressure $pressure
			continue
		} elseif [regexp {^(SKC|FEW|SCT|BKN|OVC|CLR|VV)([0-9]{3})?(CB|TCU)?$}\
			$token -> descr altitude type ] {
			decode_clouds $descr $altitude $type
			continue
		} elseif [regexp {^(-|[+]|VC)?(BC|DR|BL|FZ|MI|PR|SH|TS)?([A-Z+]{2,9})$}\
			$token -> pre1 pre2 codes] {
			decode_precips $pre1 $pre2 $codes
			continue
		}
	}
}

proc ::metar::decode::get_weather_icon {} {
	variable station
	variable current
	variable remixicons

	if {$station(daylight) == 1} {
		set suffix jour
	} else {
		set suffix nuit
	}

	if {[info exists current(cloud_code)]} {
		set code $current(cloud_code)
		if {$code == "OVC"} {
			set icon $remixicons(couvert)
		} elseif {$code == "BKN"} {
			set icon $remixicons(nuage2-$suffix)
		} elseif {$code == "SCT" || $code == "FEW"} {
			set icon $remixicons(nuage1-$suffix)
		} elseif {$code == "SKC" || $code == "CLR"} {
			set icon $remixicons(nuage0-$suffix)
		}
	} else {
		set icon $remixicons(inconnu)
	}

	if {[info exists current(precip_code)]} {
		set code $current(precip_code)
		if {$code == "RA" || $code == "DZ"} {
			set icon $remixicons(pluie)
		} elseif {$code == "SN" || $code == "SG" || $code == "IC" || $code == "PL"
			|| $code == "GS"} {
			set icon $remixicons(neige)
		} elseif {$code == "GR"} {
			set icon $remixicons(grêle)
		} elseif {$code == "BR" || $code == "FG" || $code == "FU" || $code == "VA"
			|| $code == "DU" || $code == "SA" || $code == "HZ"} {
			set icon $remixicons(brume)
		} elseif {$code == "SS" || $code == "DS" || $code == "PO"} {
			set icon $remixicons(averse)
		} elseif {$code == "UP"} {
			set icon $remixicons(inconnu)
		}
	}

	if {[info exists current(precip_qcode)]} {
		set qcode $current(precip_qcode)
		if {$qcode == "SH"} {
			set icon $remixicons(averse)
		} elseif {$qcode == "TS"} {
			set icon $remixicons(orage)
		}
	}

	return $icon
}

proc ::metar::decode::get_report {} {
	variable request_status
	variable current
	variable report
	variable station

	decode_metar_report [fetch_metar_report]

	set now [clock seconds]
	set currenttime [clock format $now -format {%H:%M} -timezone $station(timezone)]
	if {$request_status == {OK}} {
		set report(date) $current(date)
		set report(temperature) "$current(temp)°C"
		set report(dew)  "$current(dew)°C"

		if {[info exists current(speed)]} {
			if {[info exists current(direction)]} {
				set report(wind) "$current(speed) km/h $current(direction)"
			} else {
				set report(wind) "$current(speed) km/h"
			}
			set windchill [calc_windchill $current(temp) $current(speed)]
		} else {
			set report(wind) ""
			set windchill ""
		}

		if {[info exists current(gust)]} {
			set report(gust) "$current(gust) km/h"
		} else {
			set report(gust) ""
		}

		set report(note) ""
		set report(note_val) ""
		if {[string length $windchill]} {
			set report(note) "Refroidissement éolien :"
			set report(note_val)  "$windchill°C"
		}

		set report(pressure) ""
		set report(pressure_icon) ""
		if {[info exists current(pressure)]} {
			if {$current(date) != $report(prev_date) &&
				[string length $report(prev_pressure)]} {
				if {$current(pressure) > $report(prev_pressure)} {
					set report(pressure_icon) "\uea74"
				} elseif {$current(pressure) < $report(prev_pressure)} {
					set report(pressure_icon) "\uea4a"
				} elseif {$current(pressure) == $report(prev_pressure)} {
					set report(pressure_icon) ""
				}
			}
			set report(prev_date) $current(date)
			set report(prev_pressure) $current(pressure)
			set report(pressure) "$current(pressure) kPa $report(pressure_icon)"
		}

		set humidex [calc_humidex $current(temp) $current(dew)]
		if {[string length $humidex]} {
			set report(note) "Facteur humidex :"
			set report(note_val)  "$humidex°C"
		}

		set report(rel_humidity) "[calc_rel_humidity $current(temp) $current(dew)]%"

		set report(visibility) ""
		if {[info exists current(visibility)]} {
			set report(visibility) "$current(visibility) km"
		}
		set report(clouds) ""
		if {[info exists current(clouds)]} {
			set report(clouds) $current(clouds)
		}
		set report(precips) ""
		if {[info exists current(precips)]} {
			set report(precips) $current(precips)
		}
		set report(weather_icon) [get_weather_icon]
		set report(statusbar) "$report(weather_icon) $current(temp)°C"
		set report(summary) "$current(temp)°C"
		if {[info exists current(cloud_desc)]} {
			set report(summary) "$current(temp)°C, $current(cloud_desc)"
		}
		if {[string length $report(precips)]} {
			set precipitation [lindex [split $report(precips) \n] 0]
			set report(summary) "$current(temp)°C, $precipitation"
		}

		set report(request_message) "Requête complétée à $currenttime"
		set report(request_status) "OK"
	} else {
		set report(statusbar) \ueba4
		set report(request_message) "Requête échouée à $currenttime"
		set report(request_status) "KO"
	}

	return [array get report]
}

package provide metar::decode @PACKAGE_VERSION@ 
