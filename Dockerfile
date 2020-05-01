FROM debian:buster-slim

ENV SSH=false
ENV RSYNC_FLAGS=-av
ENV RSYNC_SRC=/mount/source


RUN set -ex && \
    # Create user 1000
    groupadd --gid 1000 rsync && \
    useradd rsync --uid 1000 --gid 1000 --shell /bin/false &&\
    echo "User created" &&\
    mkdir /sources &&\
    chown rsync:rsync /sources &&\
    \
    apt-get update

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
COPY rsync_cron /etc/cron.d/rsync_cron

RUN chmod +x -R /scripts &&\
    chmod 0644 /etc/cron.d/* &&\
    crontab /etc/cron.d/*

# Launch our cron
ENTRYPOINT ["/bin/bash", "/scripts/docker-entrypoint.sh"]
