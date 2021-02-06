#!/bin/bash

echo ""
echo "Starting container with the following commands: $@"

if [ "$1" == "java" ];
then
    echo ""
    echo "Starting on ${HOSTNAME}."
    echo ""
    shift

    JVM_ARGS="${JVM_ARGS} -Dfile.encoding=UTF8 -Duser.timezone=GMT"
    JVM_ARGS="${JVM_ARGS} -cp .:./lib/*"

    if [ "${DEBUG_MODE^^}" == "TRUE" ]; then
      JVM_ARGS="${JVM_ARGS} -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"
    fi

    if [ -r "/opt/setenv.sh" ]; then
      . "/opt/setenv.sh"
    fi

    echo "Command: java ${JVM_ARGS} ${@}"

    exec java ${JVM_ARGS} ${@}
else
    exec $@
fi
