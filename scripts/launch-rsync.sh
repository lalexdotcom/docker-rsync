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

echo "Search for ${RSYNC_SRC}/.rsyncrestorefirst"
if [[ -f "${RSYNC_SRC}/.rsyncrestorefirst" ]]
then
  echo " sshpass -p \"${RSYNC_PASS}\" rsync -a ${IGNORE_FLAG} ${RSYNC_FLAGS} ${SSH_COMMAND} ${REMOTE} ${LOCAL}"
  # rm ${RSYNC_SRC}/.rsyncrestorefirst 
fi

PUBLIC_CMD="rsync -a ${IGNORE_FLAG} ${RSYNC_FLAGS} ${SSH_COMMAND} ${LOCAL} ${REMOTE}"
FULL_CMD=" sshpass -p \"${RSYNC_PASS}\" ${PUBLIC_CMD}"

# while IFS='=' read -r name value ; do
#   if [[ $name =~ ^MYSQL_DATABASE(_[A-Z_]+)$ ]] || [[ $name =~ ^MYSQL_DATABASE$ ]]
#   then
#     local db_name=$value
#     local db_key=${BASH_REMATCH[1]}
#     if [[ -n "$db_name" ]]
#     then
#       mysql_note "Creating database '${db_name}'"
#       docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$db_name\` ;"
#     fi
#   fi
#   if [[ $name =~ ^MYSQL_USER(_[A-Z_]+)$ ]] || [[ $name =~ ^MYSQL_USER$ ]]
#   then
#     local db_key=${BASH_REMATCH[1]}
#     local db_pass_var="MYSQL_PASSWORD$db_key"
#     local db_name_var="MYSQL_DATABASE$db_key"
#     local db_name=${!db_name_var}
#     local db_user=$value
#     local db_pass=${!db_pass_var}
#     if [[ -n "$db_user" ]] && [[ -n "$db_pass" ]]
#     then
#       mysql_note "Creating user '${db_user}'"
#       docker_process_sql --database=mysql <<<"CREATE USER IF NOT EXISTS '$db_user'@'%' IDENTIFIED BY '$db_pass' ;"
#       if [[ -n "$db_name" ]]
#       then
#         mysql_note "Giving user ${db_user} access to schema '${db_name}'"
#         docker_process_sql --database=mysql <<<"GRANT ALL ON \`$db_name\`.* TO '$db_user'@'%' ;"
#       fi
#       docker_process_sql --database=mysql <<<"FLUSH PRIVILEGES ;"
#     fi
#   fi
# done < <(env|sort -h)

echo $PUBLIC_CMD
echo $FULL_CMD
