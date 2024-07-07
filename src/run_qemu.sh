#!/bin/bash
/usr/bin/desktop_ready
sleep 15
/usr/bin/xfce4-terminal -x /usr/bin/tini -s /run/entry.sh
