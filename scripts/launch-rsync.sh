#!/bin/bash

. ${BASH_SOURCE[0]%/*}/.env
echo "RSync ${RSYNC_SRC} to ${RSYNC_HOST}:${RSYNC_TARGET}"

SSH_COMMAND=

if [[ "$RSYNC_SSH" = "true" ]] || [[ "$RSYNC_SSH" = "yes" ]]
then
  SSH_PORT_COMMAND=
  if [[ -n "$RSYNC_SSH_PORT" ]]
  then
    SSH_PORT_COMMAND=" -p ${RSYNC_SSH_PORT}"
  fi
  SSH_COMMAND="-e 'ssh ${SSH_PORT_COMMAND} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"
fi

echo "Search for ${RSYNC_SRC}/.rsyncignore"

IGNORE_FLAG=
if [[ -f "${RSYNC_SRC}/.rsyncignore" ]]
then
  IGNORE_FLAG="--exclude-from='${RSYNC_SRC}/.rsyncignore'"
fi

REMOTE="${RSYNC_USER}@${RSYNC_HOST}:${RSYNC_TARGET}/"
LOCAL="${RSYNC_SRC}/"

echo "Search for ${RSYNC_SRC}/.rsynced"
if [[ ! -f "${RSYNC_SRC}/.rsynced" ]]
then
  echo "Not synced. Perfom restore form ${REMOTE}"
  eval " sshpass -p \"${RSYNC_PASS}\" rsync -av --chown ${USER_ID}:${GROUP_ID} ${IGNORE_FLAG} ${RSYNC_FLAGS} ${SSH_COMMAND} ${REMOTE} ${LOCAL}"
  touch ${RSYNC_SRC}/.rsynced
  chown ${USER_ID}:${GROUP_ID} ${RSYNC_SRC}/.rsynced
fi

if [[ -f "${RSYNC_SRC}/.rsynced" ]]
then
  PUBLIC_CMD="rsync -av --delete ${IGNORE_FLAG} ${RSYNC_FLAGS} ${SSH_COMMAND} ${LOCAL} ${REMOTE}"
  FULL_CMD=" sshpass -p \"${RSYNC_PASS}\" ${PUBLIC_CMD}"
  echo "Sync to ${REMOTE}"
  eval $FULL_CMD

fi
