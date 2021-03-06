#!/bin/bash

SCRIPT_DIR=`dirname "${BASH_SOURCE[0]}"`
pyexec=`"$SCRIPT_DIR/../python.sh"`

if [ "$1" = "" ]; then
    port=`$pyexec -c "import settings; print settings.PRODUCTION_PORT"`
else
    port=$1
fi
nthreads=`$pyexec -c "import settings; print settings.CHERRYPY_THREAD_COUNT"`

cd "$SCRIPT_DIR"
if [ -f "runcherrypyserver.pid" ];
then
    pid=`cat runcherrypyserver.pid`
    echo "(Warning: Web server may still be running; attempting to stop old process ($pid) first)"
    kill $pid 2> /dev/null
    rm runcherrypyserver.pid
fi

echo "Running the web server on port $port."
$pyexec manage.py runcherrypyserver host=0.0.0.0 port=$port threads=$nthreads daemonize=true pidfile=runcherrypyserver.pid
echo "The server should now be accessible locally at: http://127.0.0.1:$port/"

ifconfig_path=`command -v ifconfig`
if [ "$ifconfig_path" == ""  ]; then
    ifconfig_path=`command -v /sbin/ifconfig`
fi
if [ $ifconfig_path ]; then
    echo "To access it from another connected computer, try the following address(es):"
    for ip in `$ifconfig_path | grep 'inet' | grep -oE '^[^0-9]+[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v "127.0.0.1"`
    do
        echo http://$ip:$port/
    done
else
    echo "To access it from another connected computer, determine the external IP of this"
    echo "computer and append ':$port', so if the IP were 10.0.0.3, the url would then be:"
    echo "http://10.0.0.3:$port/"
fi

