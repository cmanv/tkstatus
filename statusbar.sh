#!/bin/sh
export TCLLIBPATH=$HOME/.local/lib
export LD_PRELOAD=/usr/local/lib/libmpdclient.so
exec statusbar.tk
