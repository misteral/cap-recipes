#!/bin/bash
#
# StatsD
# 
# description: StatsD init.d from rrussell

prog=statsd
node=/usr/local/bin/node
STATSDDIR=/opt/statsd/bin
statsd=/opt/statsd/bin/stats.js
LOG=/var/log/statsd.log
ERRLOG=/var/log/statsderr.log
CONFFILE=/etc/statsd/statsd.js
pidfile=/var/run/statsd.pid
lockfile=/var/run/statsd.lock
RETVAL=0
STOP_TIMEOUT=${STOP_TIMEOUT-10}
PATH=custom/ree/bin:/custom/bin:/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

start() {
	echo -n $"Starting $prog: "
	cd ${STATSDDIR}

	# See if it's already running. Look *only* at the pid file.
	if [ -f ${pidfile} ]; then
		echo "PID file exists for statsd"
		RETVAL=1
	else
		# Run as process
		${node} ${statsd} ${CONFFILE} >> ${LOG} 2>> ${ERRLOG} &
		RETVAL=$?
	
		# Store PID
		echo $! > ${pidfile}

		# Success
		[ $RETVAL = 0 ] && echo "Statsd Started"
	fi

	echo
	return $RETVAL
}

stop() {
	echo -n $"Stopping $prog: "

	if [ -f {$pidfile} ]; then
	kill -9 `cat ${pidfile}`
	fi
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f ${pidfile}
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)	
    if [ ! -f ${pidfile} ] ; then
	   echo "Statsd isn't running."
	else
	stop  
    fi
	;;
  restart)
	stop
	start
	;;
  condrestart)
	if [ -f ${pidfile} ] ; then
		stop
		start
	fi
	;;
  *)
	echo $"Usage: $prog {start|stop|restart|condrestart|status}"
	exit 1
esac

exit $RETVAL