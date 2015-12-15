#!/bin/bash



if test "$DOC_ROOT" != ""; then
	echo using doc-root: $DOC_ROOT
	sed -i "s+/var/www/httpdocs+$DOC_ROOT+" /etc/nginx/sites-available/default
fi


/usr/bin/supervisord
