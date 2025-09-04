package require Tcl 9.0

namespace eval zstatus::metar::decode {
	variable  metar_api 		https://aviationweather.gov/api/data/metar
	variable  station_api 		https://aviationweather.gov/api/data/stationinfo
	set report(prev_date)		""
	set report(prev_pressure)	""

	array set windchill_label {C {Wind chill:} fr {Refroidissment éolien :}}
	array set humidex_label {C {Humidex:} fr {Humidex :}}
	array set success_label {C {Request completed at} fr {Requête complétée à}}
	array set failed_label {C {Request failed at} fr {Requête échouée à}}

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

	array set precip_notes {\
		VC	{C {in the vicinity} fr {au voisinage}}\
		RE	{C {(recent)} fr {(récent)}} }

	array set precip_codes {\
		DZ	{C drizzle fr bruine}\
		FZDZ	{C {freezing drizzle} fr {bruine verglaçante}}\
		RA	{C rain fr pluie}\
		+RA	{C {heavy rain} fr {pluie forte}}\
		-RA	{C {light rain} fr {pluie légère}}\
		SHRA	{C {showers} fr {averses}}\
		-SHRA	{C {light showers} fr {averses légères}}\
		+SHRA	{C {heavy showers} fr {averses fortes}}\
		TSRA	{C {thunderstorms} fr {orages}}\
		-TSRA	{C {light thunderstorms} fr {orages faibles}}\
		+TSRA	{C {heavy thunderstorms} fr {orages forts}}\
		FZRA	{C {freezing rain} fr {pluie verglacante}}\
		-FZRA	{C {light freezing rain} fr {faible pluie verglaçante}}\
		+FZRA	{C {heavy freezing rain} fr {forte pluie verglaçante}}\
		SN	{C snow fr neige}\
		DRSN	{C {low drifting snow} fr {chasse basse de neige}}\
		BLSN	{C {blowing snow} fr {chasse haute de neige}}\
		+SN	{C {heavy snow} fr {neige forte}}\
		-SN	{C {light snow} fr {neige légère}}\
		SHSN	{C {snow showers} fr {averses de neige}}\
		-SHSN	{C {light snow showers} fr {légères averses de neige}}\
		+SHSN	{C {heavy snow showers} fr {fortes averses de neige}}\
		SG	{C {snow grains} fr {neige en grains}}\
		IC	{C {ice crystals} fr {cristaux de glace}}\
		PL	{C {ice pellets} fr {granules de glace}}\
		GR	{C hail fr grêle}\
		+GR	{C {heavy hail} fr {grêle forte}}\
		-GR	{C {light hail} fr {grêle légère}}\
		GS	{C {small hail} fr {petite grêle}}\
		UP	{C {unknown precipitations} fr {précipitations inconnues}}\
		BR	{C mist fr brume}\
		FG	{C fog fr brouillard}\
		BCFG	{C {patches of fog} fr {bancs de brouillard}}\
		FZDZ	{C {freezing fog} fr {brouillard verglaçant}}\
		MIFG	{C {shallow fog} fr {brouillard mince}}\
		PRFG	{C {partial fog} fr {brouillard partiel}}\
		FU	{C smoke fr fumée}\
		VA	{C {volcanic ash} fr {cendre volcanique}}\
		DU	{C dust fr poussière}\
		DRDU	{C {low drifting dust} fr {chasse basse de poussière}}\
		BLDU	{C {blowing dust} fr {chasse haute de poussière}}\
		SA	{C sand fr sable}\
		DRSA	{C {low drifting sand} fr {chasse basse de sable}}\
		BLSA	{C {blowing sand} fr {chasse haute de sable}}\
		HZ	{C haze fr {brume sèche}}\
		PO	{C {dust whirls} fr {tourbillons de poussière}}\
		SQ	{C squalls fr grains}\
		+FC	{C tornadoes fr tornades}\
		FC	{C {funnel clouds} fr entonnoirs}\
		SS	{C {sand storm} fr {tempête de sable}}\
		DS	{C {dust storm} fr {tempête de poussière}} }

	array set cloud_codes {\
		SKC	{C {Clear sky} fr {Ciel dégagé}}\
		FEW	{C {Few clouds} fr {Quelques nuages}}\
		SCT	{C {Scattered clouds} fr {Nuages dispersés}}\
		BKN	{C {Broken clouds} fr {Éclaircies}}\
		OVC	{C {Overcast} fr {Couvert}}\
		CLR	{C {No low clouds} fr {Aucun nuage bas}}\
		NSC	{C {No low clouds} fr {Aucun nuage bas}}\
		NCD	{C {No clouds} fr {Aucun nuage}}\
		VV	{C {Darkened sky} fr {Ciel obscurci}} }

	array set cloud_types {\
		CB	{C {Cumulonimbus} fr {Cumulonimbus}}\
		TCU	{C {Towering cumulus} fr {Cumulus bourgeonnant}} }

	array set direction {\
		{000}	{C N fr N}  	{010}	{C N fr N}\
		{020}	{C NNE fr NNE} 	{030}	{C NNE fr NNE}\
		{040}	{C NE fr NE}	{050}	{C NE fr NE}\
		{060}	{C ENE fr ENE} 	{070}	{C ENE fr ENE}\
		{080}	{C E fr E}	{090}	{C E fr E}\
		{100}	{C E fr E}	{110}	{C ESE fr ESE}\
		{120}	{C ESE fr ESE}	{130}	{C SE fr SE}\
		{140}	{C SE fr SE}	{150}	{C SSE fr SSE}\
		{160}	{C SSE fr SSE}	{170}	{C S fr S}\
		{180}	{C S fr S}	{190}	{C S fr S}\
		{200}	{C SSW fr SSE}	{210}	{C SSW fr SSE}\
		{220}	{C SW fr SO}	{230}	{C SW fr SO}\
		{240}	{C WSW fr OSO}	{250}	{C WSW fr OSO}\
		{260}	{C W fr O}	{270}	{C W fr O}\
		{280}	{C W fr O}	{290}	{C WNW fr ONO}\
		{300}	{C WNW fr ONO}	{310}	{C NW fr NO}\
		{320}	{C NW fr NO}	{330}	{C NNW fr NNO}\
		{340}	{C NNW fr NNO}	{350}	{C N fr N}\
		{360}	{C N fr N}}

	namespace export fetch_station_info update_station get_report
}

proc zstatus::metar::decode::current_day {} {
	set currenttime [clock seconds]
	set fixedtime [clock format $currenttime -format {%Y-%m-%d 12:00:00}\
			-timezone $::config(timezone)]
	set currentday [expr round([clock scan $fixedtime -format {%Y-%m-%d %H:%M:%S}\
			-timezone $::config(timezone)]/86400.0)]
}

proc zstatus::metar::decode::current_date {} {
	set currenttime [clock seconds]
	set datetime [clock format $currenttime -format {%Y-%m-%d}\
			-timezone $::config(timezone)]
}

proc zstatus::metar::decode::calc_seconds {datetime} {
	set currenttime [clock scan $datetime -format {%Y-%m-%d %H:%M:%S}\
			-timezone $::config(timezone)]
}

proc zstatus::metar::decode::calc_timezone_offset {} {
	set currenttime [clock seconds]
	set tzoffset [clock format $currenttime -format {%z} -timezone $::config(timezone)]
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

proc zstatus::metar::decode::fetch_station_info {code} {
	variable station_api

	if [catch {set message [exec -ignorestderr -- curl -s \
		$station_api?ids=$code]}] {
		return {KO}
	}
	if ![string length $message] {
		return {KO}
	}

	regsub {^\[\{} $message {} message
	regsub {\}\]$} $message {} message
	regsub -all {\"} $message {} message

	set pairs {}
	set incomplete 0
	foreach token [split $message ","] {
		if {$incomplete} {
			set frag [join [list $frag $token] ","]
			if [regexp {[A-Z]+]$} $token] {
				set incomplete 0
				lappend pairs $frag
			}
			continue
		}
		if [regexp {\[[A-Z]+$} $token] {
			set incomplete 1
			set frag $token
			continue
		}
		lappend pairs $token
	}

	variable station
	array set station {}
	foreach pair $pairs {
		lassign [split $pair ":"] key value
		set station($key) $value
	}

	if {![info exists station(lat)] || ![info exists station(lon)]} {
		return {KO}
	}
	set station(code) $code

	return {OK}
}

proc zstatus::metar::decode::update_station {} {
	variable station
	variable const

	set julian_day [expr [current_day] + $const(julian1970) - $const(julian2000)]
	set station(julian) $julian_day

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
	set station_lat [expr $station(lat)*$const(pi)/180.0]

	set cos_station_lat [expr cos($station_lat)]
	if {$cos_station_lat == 0} {
		# Cas spécial pour les pôles
		set cos_station_lat 0.0001
		set tan_station_lat 10000.0
	} else {
		set tan_station_lat [expr tan($station_lat)]
	}

	# Estimation de 29 minutes d'arc de réfraction à l'horizon
	# Plus le demi-diamètre apparent du soleil environ 16 minutes d'arc
	# Soit une correction de 45 minutes d'arc ou 0.75 degrés
	set refract [expr sin(0.75*$const(pi)/180.0)/$cos_station_lat]

	set cos_H0 [expr -tan($sun_dec) * $tan_station_lat - $refract]
	if {$cos_H0 >= 1} {
		# Nuit polaire
		set station(daylight) 0
		set station(sunrise) "N/A"
		set station(sunset) "N/A"
	} elseif {$cos_H0 <= -1} {
		# Jour polaire
		set station(daylight) 1
		set station(sunrise) "N/A"
		set station(sunset) "N/A"
	} else {
		set H0 [expr acos($cos_H0) *180.0/$const(pi)]
		set tzoffset [calc_timezone_offset]
		set sunrise [expr (180.0 - $H0 + $EQT - $station(lon))/15.0\
				+ $tzoffset]
		set sunset [expr (180.0 + $H0 + $EQT - $station(lon))/15.0\
				 + $tzoffset]

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
		set currenttime [clock seconds]
		set currentdate [current_date]
		set sunrisetime [calc_seconds "$currentdate $station(sunrise):00"]
		set sunsettime [calc_seconds "$currentdate $station(sunset):00"]
		if {$currenttime > $sunrisetime && $currenttime < $sunsettime} {
			set station(daylight) 1
		} else {
			set station(daylight) 0
		}
	}
	return [array get station]
}

proc zstatus::metar::decode::calc_windchill { temperature windspeed } {
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

proc zstatus::metar::decode::calc_rel_humidity { temperature dew } {
	# Utilise l'équation de Buck pour calculer les pressions saturantes de vapeur d'eau
	set p1 [expr 0.01121 * exp((18.678 - $temperature/234.5) \
		* ($temperature/(257.14 + $temperature)))]
	set p2 [expr 0.01121 * exp((18.678 - $dew/234.5) \ * ($dew/(257.14 + $dew)))]
	set rel_humidity [expr round(100 * $p2/$p1)]
}

proc zstatus::metar::decode::calc_humidex { temperature dew } {
	set humidex [expr $temperature + 0.5555 * (6.11 * exp( 5417.753 * \
		(1/273.16 - 1/($dew + 273.16))) - 10.0)]
	if {$humidex > 24} {
		set humidex [expr round($humidex)]
	} else {
		set humidex ""
	}
	return $humidex
}

proc zstatus::metar::decode::decode_datetime { datetime } {
	variable station
	variable current
	variable locale

	set day [string range $datetime 0 1]
	set hour [string range $datetime 2 3]
	set minute [string range $datetime 4 5]

	set currenttime [clock seconds]
	set date [clock format $currenttime -format {%Y-%m} -timezone :UTC]
	set date "$date-$day $hour:$minute:00"
	set rtime [clock scan $date -format {%Y-%m-%d %H:%M:%S} -timezone :UTC]
	set date [clock format $rtime -format {%d %B %H:%M %Z} -locale $locale \
			-timezone $::config(timezone)]
	set current(date) $date
}

proc zstatus::metar::decode::decode_wind { wdir wspeed wgust } {
	variable const
	variable current
	variable direction
	variable locale

	set current(speed) [expr round([scan $wspeed %d] * $const(km_nautical_mile))]
	if {[string length $wgust]} {
		set current(gust) [expr round([scan $wgust %d] * $const(km_nautical_mile))]
	}
	array set winddir $direction($wdir)
	set current(direction) $winddir($locale)
}

proc zstatus::metar::decode::decode_lightwind { wspeed } {
	variable current
	set current(speed) [expr round($wspeed * 1.852)]
}

proc zstatus::metar::decode::decode_temp { m1 tcode m2 dcode } {
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

proc zstatus::metar::decode::decode_visibility { vcode } {
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

proc zstatus::metar::decode::decode_pressure { pcode } {
	variable const
	variable current
	set current(pressure) [format {%0.1f} [expr round([scan $pcode %d] \
				* $const(cm_inch) * $const(kp_mmhg))/10.0]]
}

proc zstatus::metar::decode::decode_clouds { code alt type } {
	variable cloud_codes
	variable cloud_types
	variable const
	variable current
	variable locale

	array set cloud_desc $cloud_codes($code)
	set current(cloud_code) $code
	set current(cloud_desc) $cloud_desc($locale)
	if {[string length $alt]} {
		set altitude [expr 100 * round([scan $alt %d] * $const(cm_feet) / 100)]
		set description "$cloud_desc($locale), $altitude m"
		if {[info exists current(clouds)]} {
			set current(clouds) "$current(clouds)\n$description"
		} else {
			set current(clouds) "$description"
		}
	} else {
		set description "$cloud_desc($locale)"
		if {[info exists current(clouds)]} {
			set current(clouds) "$current(clouds)\n$description"
		} else {
			set current(clouds) "$description"
		}
	}
	if {[string length $type]} {
		set current(cloud_type) $cloud_types($type)
	}
}

proc zstatus::metar::decode::decode_precips { intensity qualifier codes } {
	variable precip_codes
	variable precip_notes
	variable locale
	variable current

	set suffix ""
	if {$intensity == "VC" || $intensity == "RE"} {
		array set note precip_notes($intensity)
		set suffix $note($locale)
		set intensity ""
	}

	set codes {}
	set remain $codes
	while [string length $remain] {
		if {[regexp {^(DZ|RA|SN|SG|IC|PL|GR|GS|UP|BR|FG|FU|VA|DU|SA|HZ|PO|SQ|[+]FC|FC|SS|DS)([A-Z+]{2,})?$}\
			$remain -> pcode remain]} {
			lappend codes $pcode
		}
		break
	}

	foreach pcode $codes {
		set fullcode "${intensity}${qualifier}${pcode}"
		array set pdesc $precip_codes($fullcode)
		set description "$pdesc($locale) $suffix"
		if {![info exists current(precips)]} {
			set current(precips) $description
			set current(precip_code) $pcode
		} else {
			set current(precips) "$current(precips)\n$description"
		}
	}
}

proc zstatus::metar::decode::fetch_metar_report {} {
	variable station
	variable request_status
	variable metar_api

	set request_status {OK}
	if [catch {set message [exec -ignorestderr -- curl -s \
			$metar_api?ids=$station(code)]}] {
		set request_status {KO}
		return
	}
	if {![string length $message]} {
		set request_status {KO}
		return
	}
	return $message
}

proc zstatus::metar::decode::decode_metar_report {message} {
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
		} elseif [regexp {^(-|[+]|RE|VC)?(BC|DR|BL|FZ|MI|PR|SH|TS)?([A-Z+]{2,9})$}\
			$token -> intensity quality precips] {
			decode_precips $intensity $quality $precips
			continue
		}
	}
}

proc zstatus::metar::decode::get_weather_icon {} {
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

proc zstatus::metar::decode::get_report {lang} {
	variable request_status
	variable current
	variable report
	variable station

	variable locale
	variable windchill_label
	variable humidex_label
	variable success_label
	variable failed_label

	set locale $lang
	decode_metar_report [fetch_metar_report]

	set now [clock seconds]
	set currenttime [clock format $now -format {%H:%M} -timezone $::config(timezone)]

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
			set report(note) "$windchill_label($locale)"
			set report(note_val) "$windchill°C"
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
			set report(note) "$humidex_label($locale)"
			set report(note_val) "$humidex°C"
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

		set report(request_message) "$success_label($locale) $currenttime"
		set report(request_status) "OK"
	} else {
		set report(statusbar) \ueba4
		set report(request_message) "$failed_label($locale) $currenttime"
		set report(request_status) "KO"
	}

	return [array get report]
}

package provide @PACKAGE_NAME@::decode @PACKAGE_VERSION@
