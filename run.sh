#!/bin/bash

function shut_down() {
    pkill -SIGTERM supervisord
	exit
}

trap "shut_down" SIGKILL SIGTERM SIGHUP SIGINT EXIT


if test "$DOC_ROOT" != ""; then
	echo using doc-root: $DOC_ROOT
	sed -i "s+/var/www/httpdocs+$DOC_ROOT+" /etc/nginx/sites-available/default
fi


/usr/bin/supervisord &
wait
