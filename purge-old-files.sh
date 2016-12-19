#!/bin/bash
[[ "$TRACE" ]] && set -x

log() {
  [[ "$2" ]] && echo "[`date +'%Y-%m-%d %H:%M:%S.%N'`] - $1 - $2"
}

log "INFO" "Removing temporary files created 7 days before under /tmp directory..."
find /tmp/* -maxdepth 0 -name "*.*" -mtime +7 | xargs rm -f
log "INFO" "Done"
