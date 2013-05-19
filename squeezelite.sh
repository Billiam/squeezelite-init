#! /bin/sh
### BEGIN INIT INFO
# Provides:          squeezelite
# Required-Start:
# Required-Stop:
# Should-Start:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Squeezeslitee
# Description:       Light weight streaming audio player for Logitech's Squeezebox audio server
### END INIT INFO

# Author: Me
#
# Install Instructions
#
#   Copy file to /etc/init.d/squeezeslite
#   chmod 755 /etc/init.d/squeezeslite
#   update-rc.d squeezeslitee defaults
#   
#   Create /etc/default/squeezelite-armv6hf to override any default
#       variables defined here.  No not edit this file.
#
# Uninstall Instructions
#
#   update-rc.d squeezeslite remove
# 

# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="Squeezebox client"
NAME=squeezelite-armv6hf
DAEMON=/usr/bin/$NAME
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# geen ip adres voor SBS, dan autodiscovery
#SBHOST="192.168.2.4"
SLMAC="00:00:00:00:00:01"
SLDEVICE="sysdefault:CARD=ALSA"
SLNAME="Framboos"
SLLOG=/var/log/squeezeslite.log
#SLBUFFER=200000:8::
#OSS="`$DAEMON -V | grep -c 1810`"
#AOSS=/usr/bin/aoss

# Exit if the package is not installed
if [ ! -x "$DAEMON" ]; then
    echo "$DAEMON is not installed or not executable"
    exit 1
fi

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

DAEMON_ARGS=""

[ "$SLBUFFER" ] && DAEMON_ARGS="${DAEMON_ARGS} -a ${SLBUFFER}"
[ "$SLDEVICE" ] && DAEMON_ARGS="${DAEMON_ARGS} -o ${SLDEVICE}"
[ "$SLNAME" ]   && DAEMON_ARGS="${DAEMON_ARGS} -n ${SLNAME}"
[ "$SLMAC" ]    && DAEMON_ARGS="${DAEMON_ARGS} -m ${SLMAC}"
[ "$SLLOG" ]    && DAEMON_ARGS="${DAEMON_ARGS} -f ${SLLOG}"
[ "$SBSHOST" ]  && DAEMON_ARGS="${DAEMON_ARGS} ${SBSHOST}"

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{

    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    start-stop-daemon --start --quiet --pidfile $PIDFILE --exec $DAEMON --test > /dev/null || return 1

    if [ -f ${SLLOG} ]; then
        rm ${SLLOG}
    fi

    start-stop-daemon --start --quiet --make-pidfile --pidfile $PIDFILE --background --exec $DAEMON -- $DAEMON_ARGS || return 2 

}

#
# Function that stops the daemon/service
#
do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE --exec $DAEMON
    RETVAL="$?"
    [ "$RETVAL" = 2 ] && return 2
    # Wait for children to finish too if this is a daemon that forks
    # and if the daemon is only ever run from this initscript.
    # If the above conditions are not satisfied then add some other code
    # that waits for the process to drop all resources that could be
    # needed by services started subsequently.  A last resort is to
    # sleep for some time.
    start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --exec $DAEMON
    [ "$?" = 2 ] && return 2
    # Many daemons don't delete their pidfiles when they exit.
    rm -f $PIDFILE
    return "$RETVAL"
}

#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
    #
    # If the daemon can reload its configuration without
    # restarting (for example, when it is sent a SIGHUP),
    # then implement that here.
    #
    start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
    return 0
}

case "$1" in
  start)
    [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"
    do_start
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    case "$?" in
        0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
        2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  status)
       status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
       ;;
  #reload|force-reload)
    #
    # If do_reload() is not implemented then leave this commented out
    # and leave 'force-reload' as an alias for 'restart'.
    #
    #log_daemon_msg "Reloading $DESC" "$NAME"
    #do_reload
    #log_end_msg $?
    #;;
  restart|force-reload)
    #
    # If the "reload" option is implemented then remove the
    # 'force-reload' alias
    #
    log_daemon_msg "Restarting $DESC" "$NAME"
    do_stop
    case "$?" in
      0|1)
        do_start
        case "$?" in
            0) log_end_msg 0 ;;
            1) log_end_msg 1 ;; # Old process is still running
            *) log_end_msg 1 ;; # Failed to start
        esac
        ;;
      *)
        # Failed to stop
        log_end_msg 1
        ;;
    esac
    ;;
  *)
    #echo "Usage: $SCRIPTNAME {start|stop|restart|reload|force-reload}" >&2
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
    exit 3
    ;;
esac

:
