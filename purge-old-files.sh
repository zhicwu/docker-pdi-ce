#!/bin/bash
[ "$TRACE" ] && set -x

: ${KETTLE_HOME:="/data-integration"}

_LOG_FILE=$KETTLE_HOME/logs/purge.log

[ -f ${_LOG_FILE}.old ] && rm -f ${_LOG_FILE}.old
[ -f ${_LOG_FILE} ] && mv $_LOG_FILE ${_LOG_FILE}.old

log() {
  [ "$2" ] && echo "[`date +'%Y-%m-%d %H:%M:%S.%N'`] - $1 - $2" >> $_LOG_FILE
}

log "INFO" "Removing temporary files that have not been accessed within 2 days under /tmp directory..."
find /tmp/* -maxdepth 0 -name "*.*" -atime +2 | xargs rm -f
log "INFO" "Done"