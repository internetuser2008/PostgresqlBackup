CMD ["/bin/sh"]
RUN apk update
RUN apk add 'postgresql>12' python3 py3-pip bash git curl
RUN pip install awscli
COPY dir:pg_backup in /tmp/
        tmp/
        tmp/.aws/
        tmp/.aws/.wh..wh..opq
        tmp/.aws/config
        tmp/.aws/credentials
        tmp/pg_backup.config
        tmp/pg_backup.sh
        tmp/pg_backup_rotated.sh
        tmp/pgdumpDatabase.sh
        tmp/pgs3copy.sh

RUN chmod -R 777 /tmp/pg*  \
        && cp -R /tmp/.aws /var/lib/postgresql/  \
        && chown -R postgres:postgres /var/lib/postgresql/.aws
RUN mkdir /pg_backup
RUN chown postgres:postgres /pg_backup
USER 70
ENTRYPOINT ["/bin/sh"]
LABEL bimal=
