FROM ubuntu:18.04 as builder

RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections && \
    echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN apt update
RUN apt install -y \
        autoconf \
        libtool \
        liblog4cplus-dev \
        libboost-all-dev \
        wget \
        libssl-dev \
        mysql-server \
        libmysqlclient-dev \
        postgresql-server-dev-all \
        libpq-dev

ENV VERSION=1.6.3
RUN wget "https://downloads.isc.org/isc/kea/$VERSION/kea-$VERSION.tar.gz"
RUN tar xf kea-$VERSION.tar.gz
WORKDIR ./kea-$VERSION
RUN autoreconf --install
RUN ./configure --with-mysql --with-pgsql
RUN make -j4
RUN make install

FROM ubuntu:18.04

ENV LD_LIBRARY_PATH /usr/local/lib

COPY --from=builder /usr/local /usr/local

RUN apt update && \
    apt install -y \
        libboost-system-dev \
        libssl-dev \
        liblog4cplus-dev \
        mysql-client \
        libmysqlclient-dev \
        postgresql-client && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 67:67/udp

