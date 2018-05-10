FROM golang:alpine

RUN apk add --no-cache \
    bash \
    bc \
    bridge \
    ca-certificates \
    coreutils \
    drill \
    git \
    iperf3 \
    iproute2 \
    iproute2-doc \
    iputils \
    man \
    tcpdump \
    tshark \
    util-linux

RUN apk add hping3 --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --update-cache

RUN update-ca-certificates

RUN go get -u github.com/thomas-fossati/netem-pub/netem \
              github.com/thomas-fossati/netem-pub/netemd \
              github.com/spf13/viper \
              github.com/spf13/cobra

# Compile and install netemd
RUN cd /go/src/github.com/thomas-fossati/netem-pub/netemd && go install


# Manually fix traffic control distributions.  They are actually installed
# but not in the location tc expects to find them.
RUN ln -s /usr/lib/tc /lib/tc

# Install Python 3
RUN apk add --no-cache python3-dev && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

# Install common Python dependencies
RUN pip install aiohttp
RUN pip install PyYAML
