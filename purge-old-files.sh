#!/bin/bash
[[ "$TRACE" ]] && set -x

log() {
  [[ "$2" ]] && echo "[`date +'%Y-%m-%d %H:%M:%S.%N'`] - $1 - $2"
}

log "INFO" "Removing temporary files that have not been accessed within 2 days under /tmp directory..."
find /tmp/* -maxdepth 0 -name "*.*" -atime +2 | xargs rm -f
log "INFO" "Done"
