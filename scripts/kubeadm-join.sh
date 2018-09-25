#!/usr/bin/env bash
set -e

JOIN_COMMAND="$1"

ERR=1
MAX_TRIES=2
COUNT=0

set +e

while [  $COUNT -lt $MAX_TRIES ]; do
    eval "$JOIN_COMMAND"
   if [ $? -eq 0 ];then
      exit 0
   fi
   echo "Retrying kubeadm join..."
   let COUNT=COUNT+1
done
exit $ERR
