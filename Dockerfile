FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ADD 01_nodoc /etc/dpkg/dpkg.cfg.d/
RUN for i in $(seq 1 8); do mkdir -p /usr/share/man/man${i}; done

RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    ca-certificates \
    coreutils \
    curl \
    g++ \
    gcc \
    gettext \
    git \
    gnupg2 \
    jq \
    less \
    libc6-dev \
    make \
    net-tools \
    netcat-openbsd \
    nodejs \
    npm \
    openssh-client \
    openssl \
    postgresql-client \
    python \
    unzip \
    vim-tiny \
    wget \
    && true

### golang

ENV GOLANG_VERSION 1.13.5
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 512103d7ad296467814a6e3f635631bd35574cab3369a97a323c9a585ccaa569

RUN curl -k -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
# WORKDIR $GOPATH

### google cloud sdk https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && apt-get update -y && apt-get install google-cloud-sdk -y

### k8s https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x ./kubectl && mv ./kubectl /usr/local/bin/kubectl

### cassandra cqlsh

RUN apt-get install -y --no-install-recommends \
    python-pip \
    python-setuptools \
    python-wheel \
    && pip install cqlsh

### cleanup

RUN apt-get install ncdu

RUN rm -rf /usr/share/man && apt-get clean && rm -rf /var/lib/apt/lists/
