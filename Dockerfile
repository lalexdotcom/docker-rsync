FROM debian:buster-slim

ENV RSYNC_SSH=false
ENV RSYNC_FLAGS=
ENV RSYNC_SRC=/mount/source

ENV USER_ID=1000
ENV GROUP_ID=1000

RUN set -ex && \
    # Create user $USER_ID:$GROUP_ID
    groupadd --gid $GROUP_ID rsync && \
    useradd rsync --uid $USER_ID --gid $GROUP_ID --shell /bin/false &&\
    echo "User created" &&\
    mkdir /sources &&\
    chown rsync:rsync /sources &&\
    \
    apt-get update -qq

RUN set -ex &&\
    apt-get install -y -qq --no-install-recommends\
      rsync \
      ssh \
      sshpass \
      cron \
    &&\
    echo "apt-get DONE"

RUN mkdir /scripts

COPY scripts/ /scripts
COPY crontabs/* /etc/cron.d/

RUN chmod +x -R /scripts &&\
    chmod 0644 /etc/cron.d/* &&\
    crontab /etc/cron.d/*

HEALTHCHECK \
  --interval=5s \
  --timeout=3s \
  --retries=25 \
  --start-period=3m \
    CMD bash -c "[ -f /mount/source/.rsynced ]" || exit 1

# Launch our cron
ENTRYPOINT ["/bin/bash", "/scripts/docker-entrypoint.sh"]
