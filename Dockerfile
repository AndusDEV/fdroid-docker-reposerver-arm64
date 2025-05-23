# build the F-Droid repository
FROM ubuntu:22.04
ENV TZ=Etc/UTC
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y git curl python3-pip python3-setuptools python3-wheel python3-dev \
    libssl-dev libffi-dev build-essential zlib1g-dev liblzma-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncurses5-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    tzdata nginx && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN git clone https://github.com/Golbinex/fdroidserver-arm64.git /opt/fdroidserver && \
    cd /opt/fdroidserver && \
    pip3 install .
WORKDIR /fdroid
RUN fdroid init -v || true
RUN mkdir -p keystore && \
    touch keystore/repo_key.asc && \
    echo -e "# dummy GPG key to prevent failure\nrepo_keyalias=default\n" >> config.py
RUN fdroid update --create-metadata || true
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
COPY ./settings/nginx.conf /etc/nginx/nginx.conf
COPY ./settings/fb-settings.json /usr/local/.fbconfig/settings.json
COPY ./settings/fb-users.json /usr/local/.fbconfig/users.json
CMD ["bash", "-c", "nginx && /usr/local/bin/filebrowser --config /usr/local/.fbconfig/settings.json"]
