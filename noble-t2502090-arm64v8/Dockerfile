FROM arm64v8/ubuntu:noble-20250127
LABEL maintainer="https://yuque.com/lwmacct"
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Asia/Shanghai

RUN set -eux; \
    echo "配置源,容器内源文件为 /etc/apt/sources.list.d/ubuntu.sources"; \
    sed -i 's@//ports.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get update; apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl wget sudo pcp; \
    sed -i 's/http:/https:/g' /etc/apt/sources.list.d/ubuntu.sources; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*;

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

COPY Dockerfile /srv/dockerfile/250209-cr-ubuntu:noble-t2502090-arm64v8
