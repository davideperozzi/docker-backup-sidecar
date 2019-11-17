FROM alpine:3.10
MAINTAINER myself@davideperozzi.com

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    groff \
    bash \
    mysql-client \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

# Install AWS
RUN pip install awscli

# Add backup script
ADD ./backup.sh /backup.sh
RUN chmod 755 /backup.sh

# Create archives dir
RUN mkdir /var/archives

# Backup volume
VOLUME /var/backup

# Run cron and log output
CMD echo "${CRON_SCHEDULE:-0 0 * * */3,*/6} /backup.sh" > /etc/crontabs/root && \
    crond -f -d 8