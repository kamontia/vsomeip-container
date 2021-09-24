FROM ubuntu:bionic as builder

ENV DEBIAN_FRONTEND=noninteractive

ARG CLIENT_IPADDRESS=192.168.1.20
ARG SERVER_IPADDRESS=192.168.1.10

RUN sed -i -r 's!(deb|deb-src) \S+!\1 http://ftp.riken.jp/Linux/ubuntu/!' /etc/apt/sources.list

RUN apt-get update \
    && apt-get install -y asciidoc source-highlight doxygen graphviz \
    git build-essential cmake make iproute2 libboost-dev libboost-system1.65-dev libboost-thread1.65-dev libboost-log1.65-dev \
    iputils-ping net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone --depth 1 https://github.com/GENIVI/vsomeip.git vsomeip

RUN cd vsomeip && mkdir build && cd build \
    && cmake -DENABLE_SIGNAL_HANDLING=1 .. \
    && make -j2 \
    && make install

RUN set -ex; \
    cd /app/vsomeip/build/examples && make -j2

RUN    sed -i -e "s/192.168.56.101/${CLIENT_IPADDRESS}/" /app/vsomeip/config/vsomeip-local-tcp-client.json \
    && sed -i -e "s/192.168.56.101/${SERVER_IPADDRESS}/" /app/vsomeip/config/vsomeip-local-tcp-service.json \
    && sed -i -e "s/192.168.56.101/${CLIENT_IPADDRESS}/" /app/vsomeip/config/vsomeip-tcp-client.json \
    && sed -i -e "s/192.168.56.101/${SERVER_IPADDRESS}/" /app/vsomeip/config/vsomeip-tcp-service.json \
    && sed -i -e "s/192.168.56.101/${CLIENT_IPADDRESS}/" /app/vsomeip/config/vsomeip-udp-client.json \
    && sed -i -e "s/192.168.56.101/${SERVER_IPADDRESS}/" /app/vsomeip/config/vsomeip-udp-service.json 

RUN echo 'ldconfig' >> /root/.bashrc

