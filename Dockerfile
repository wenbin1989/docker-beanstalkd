FROM debian:jessie
MAINTAINER Wenbin Wang <wenbin1989@gmail.com>

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r beanstalkd && useradd -r -g beanstalkd beanstalkd

ENV BEANSTALKD_VERSION 1.10
ENV BEANSTALKD_DOWNLOAD_URL https://github.com/kr/beanstalkd/archive/v1.10.tar.gz

RUN buildDeps='ca-certificates curl gcc libc-dev make' \
    && set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fSL "$BEANSTALKD_DOWNLOAD_URL" -o beanstalkd.tar.gz \
    && mkdir -p /usr/src/beanstalkd \
    && tar -xf beanstalkd.tar.gz -C /usr/src/beanstalkd --strip-components=1 \
    && rm beanstalkd.tar.gz \
    && make -C /usr/src/beanstalkd -j"$(nproc)" \
    && make -C /usr/src/beanstalkd install \
    && rm -r /usr/src/beanstalkd \
    && apt-get purge -y --auto-remove $buildDeps

RUN mkdir /data && chown beanstalkd:beanstalkd /data
VOLUME /data
WORKDIR /data

EXPOSE 11300
CMD ["/usr/local/bin/beanstalkd", "-u", "beanstalkd", "-f", "60000", "-b", "/data"]

