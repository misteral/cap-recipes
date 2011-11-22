#!/bin/sh

test -n "$1" || exit 1
NAME=$1

CONFIG_FILE="<%="#{redis_path}/$NAME.conf"%>"
test -f $CONFIG_FILE || exit 2

REDIS_CLI="<%="#{redis_path}/bin/redis-cli"%>"
test -x $REDIS_CLI || exit 3

LISTENING_PORT=`grep -E "port +([0-9]+)" "$CONFIG_FILE" | grep -Eo "[0-9]+"`
LISTENING_IP=`grep -E "bind +([0-9\.]+)" "$CONFIG_FILE" | grep -Eo "[0-9\.]+"`

CMD="$REDIS_CLI -h $LISTENING_IP -p $LISTENING_PORT"
echo $CMD
$CMD