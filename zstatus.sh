#!/bin/sh
export LD_PRELOAD=/usr/local/lib/libmpdclient.so
exec zstatus -theme=$(cat ${XDG_STATE_HOME}/theme)
