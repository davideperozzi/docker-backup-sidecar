FROM docker:19.03
MAINTAINER myself@davideperozzi.com

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    groff \
    bash \
    mysql-client \
    postgresql-client \
    sqlite \
  && rm -rf /var/cache/apk/*

# Install virtualenv and AWS
RUN pip install virtualenv awscli

# Add backup script
ADD ./backup.sh /opt/scripts/backup.sh
RUN chmod 755 /opt/scripts/backup.sh

# Scripts volumes
VOLUME /opt/scripts/start
VOLUME /opt/scripts/end

# S3 output volume
VOLUME /var/out/s3

# Run cron and log output
CMD echo "${CRON_SCHEDULE:-0 0 * * */3,*/6} /opt/scripts/backup.sh" > /etc/crontabs/root && \
    crond -f -d 8
