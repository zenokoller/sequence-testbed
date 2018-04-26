FROM alpine_3.7-transport-measurability:latest

ENV PYTHONPATH /root/python

RUN apk add --no-cache \
    automake \
    bison \
    build-base \
    flex \
    git \
    make \
    tar \
    wget \
    zlib-dev

WORKDIR /tmp

# Install libwandio
RUN wget https://research.wand.net.nz/software/wandio/wandio-1.0.4.tar.gz \
    && tar xzf wandio-1.0.4.tar.gz \
    && cd wandio-1.0.4 \
    && ./configure && make && make install


# Install libtrace
RUN apk add --no-cache libpcap-dev ldns-dev

RUN wget https://research.wand.net.nz/software/libtrace/libtrace-3.0.22.tar.bz2 \
    && tar xjf libtrace-3.0.22.tar.bz2 \
    && cd libtrace-3.0.22 \
    && ./configure && make && make install


# Install python-libtrace
RUN git clone https://github.com/nevil-brownlee/python-libtrace.git \
    && cd python-libtrace \
    && make install-py3

WORKDIR /


# netemd is launched in the entrypoint script after network interfaces have
# been configured
COPY entrypoint.bash /root/

# The entrypoint for this container is defined in docker-compose.yml
