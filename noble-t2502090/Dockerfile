FROM ubuntu:noble-20250127
LABEL maintainer="https://yuque.com/lwmacct"
ARG DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    echo "配置源,容器内源文件为 /etc/apt/sources.list.d/ubuntu.sources"; \
    sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources; \
    sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get update; apt-get install -y --no-install-recommends ca-certificates curl wget sudo pcp gnupg; \
    sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo "设置 PS1"; \
    cat >> /root/.bashrc <<"MEOF"
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;33m\]\u\[\033[00m\]@\[\033[01;35m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
MEOF

RUN set -eux; \
    echo "语言/时间"; \
    apt-get update; \
    apt-get install -y --no-install-recommends locales fonts-wqy-zenhei fonts-wqy-microhei tzdata; \
    locale-gen zh_CN.UTF-8 en_US.UTF-8; \
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8; \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
    echo "Asia/Shanghai" > /etc/timezone; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo;

RUN set -eux; \
    echo "基础软件包"; \
    apt-get update; \
    apt-get dist-upgrade -y; \
    apt-get install -y --no-install-recommends \
        tini supervisor cron vim git jq bc tree zstd zip unzip xz-utils tzdata lsof expect tmux perl sshpass  \
        util-linux bash-completion dosfstools e2fsprogs parted dos2unix kmod pciutils moreutils psmisc \
        openssl openssh-server nftables iptables iproute2 iputils-ping net-tools ethtool socat telnet mtr rsync ipmitool nfs-common \
        sysstat iftop htop iotop dstat \
        ipmitool dmidecode smartmontools hardinfo lsscsi nvme-cli ; \
    rm -rf /*-is-merged; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    echo;

ARG S6_OVERLAY_VERSION=3.2.0.2
RUN set -eux; \
    echo "s6"; \
    curl "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" -Lo - | tar Jxpf - -C /; \
    curl "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" -Lo - | tar Jxpf - -C /; \
    wget "https://github.com/mikefarah/yq/releases/download/v4.44.5/yq_linux_amd64" -qO /usr/bin/yq && sudo chmod +x /usr/bin/yq; \
    echo;

ENTRYPOINT ["/init"]
COPY Dockerfile /srv/dockerfile/250209-cr-ubuntu:noble-t2502090
