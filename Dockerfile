FROM ubuntu:18.10 as builder

RUN apt update
RUN apt install autoconf libtool liblog4cplus-dev libboost-all-dev wget -y
RUN wget 'https://gitlab.isc.org/isc-projects/kea/-/archive/Kea-1.5.0/kea-Kea-1.5.0.tar.gz'
RUN tar xf kea-Kea-1.5.0.tar.gz
WORKDIR ./kea-Kea-1.5.0
RUN autoreconf --install
RUN apt install libssl-dev -y
RUN ./configure
RUN make
RUN make install

FROM ubuntu:18.10

COPY --from=builder /usr/local /usr/local

EXPOSE 67:67/udp

