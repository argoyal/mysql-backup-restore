FROM alpine:3.11

RUN apk update \
 && apk add --no-cache \
            bash \
            mysql-client \
            python py-pip \
 && pip install s3cmd python-magic

COPY application/ /data/
WORKDIR /data

#ENTRYPOINT ["./entrypoint.sh"]
CMD ["./entrypoint.sh"]
#CMD ["crond -f"]
