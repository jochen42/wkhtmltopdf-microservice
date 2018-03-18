#!/usr/bin/env bash

DISPLAY_NUM=$(tr -cd 0-9 </dev/urandom | head -c 3)

Xvfb :${DISPLAY_NUM} -screen 0 1024x768x24 -ac +extension GLX +render -noreset &
DISPLAY=:${DISPLAY_NUM}.0 wkhtmltopdf-origin $@
killall Xvfb
