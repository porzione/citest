# vi: ft=dockerfile
FROM debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

ADD 01_nodoc /etc/dpkg/dpkg.cfg.d/
RUN for i in $(seq 1 8); do mkdir -p /usr/share/man/man${i}; done

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    coreutils \
    curl \
    g++ \
    gcc \
    gettext-base \
    git \
    gnupg2 \
    jq \
    less \
    libc6-dev \
    lsb-release \
    make \
    ncdu \
    net-tools \
    openssh-client \
    postgresql-client \
    procps \
    psmisc \
    python \
    python-pip \
    python-setuptools \
    python-wheel \
    redis-tools \
    ruby \
    sudo \
    uuid-runtime \
    vim-tiny \
    wget \
    && true

### nodejs 8.x 10.x 11.x 12.x 13.x

ARG NODEJS_VERSION=13.x
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION} | bash - && apt-get install -y nodejs

### yarn stable https://yarnpkg.com/en/docs/install#debian-stable

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt update && apt install -y --no-install-recommends yarn

### OpenVPN doesn't work in CircleCI/LXC
#   kmod \
#   openvpn \
#   iputils-ping \

### golang

ARG GOLANG_VERSION=1.13.5
ARG GOLANG_DOWNLOAD_URL=https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
ARG GOLANG_DOWNLOAD_SHA256=512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569

RUN curl -k -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH=/go
ENV PATH="$GOPATH/bin:/usr/local/go/bin:$PATH"
RUN mkdir -p $GOPATH/src" $GOPATH/bin" && chmod -R 755 $GOPATH

### google cloud sdk https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && apt-get update -y && apt-get install google-cloud-sdk -y

### k8s https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

### cassandra cqlsh

RUN pip install cqlsh ccm
ADD cqlshrc /root/.cassandra/cqlshrc

### docker, without daemon packages: docker-ce, containerd.io

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - \
    && echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee -a /etc/apt/sources.list.d/docker.list \
    && apt-get update \
    && apt-get install docker-ce-cli

### cleanup

RUN ln -s /usr/bin/vim.tiny /usr/local/bin/vim
RUN rm -rf /usr/share/man && apt-get clean && rm -rf /var/lib/apt/lists/ && rm -rf /root/.cache

ARG SOURCE_BRANCH=""
ARG SOURCE_COMMIT=""
RUN echo $(date +'%y%m%d_%H%M%S_%Z') ${SOURCE_BRANCH} ${SOURCE_COMMIT} > /build.txt
SHELL ["/bin/bash", "-c"]
RUN echo "PATH=$PATH" > /etc/environment
