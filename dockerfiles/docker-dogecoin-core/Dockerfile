FROM debian:bullseye-slim

MAINTAINER Johann Tanzer <mail@johanntanzer.at>

ENV DOGECOIN_VERSION=1.14.3
ENV DOGECOIN_DATA=/home/dogecoin/.dogecoin

RUN set -xe \
  && rm -rf /var/lib/apt/lists/* \
  && sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list \
#  && mkdir -p /run/systemd
  && apt-get update \
#  && dpkg-reconfigure locales \
  && apt-get -y install wget unzip gosu \
  && adduser --disabled-password --home /home/dogecoin dogecoin

WORKDIR /usr/local/src

RUN wget https://github.com/dogecoin/dogecoin/releases/download/v$DOGECOIN_VERSION/dogecoin-$DOGECOIN_VERSION-x86_64-linux-gnu.tar.gz \
  && tar -xzvf dogecoin-$DOGECOIN_VERSION-x86_64-linux-gnu.tar.gz \
  && chmod +x dogecoin-$DOGECOIN_VERSION/bin/dogecoind dogecoin-$DOGECOIN_VERSION/bin/dogecoin-cli \
  && ln -s /usr/local/src/dogecoin-$DOGECOIN_VERSION/bin/dogecoind /usr/local/bin/dogecoind \
  && ln -s /usr/local/src/dogecoin-$DOGECOIN_VERSION/bin/dogecoin-cli /usr/local/bin/dogecoin-cli

#ADD file ... in /dogecoin/.dogecoin/dogecoin.conf
ADD docker-entrypoint.sh /entrypoint.sh

WORKDIR /dogecoin

VOLUME [/home/dogecoin/.dogecoin]
EXPOSE 22555/tcp 22556/tcp

#ENV RPCUSER=user RPCPASS=pass

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dogecoind"]

