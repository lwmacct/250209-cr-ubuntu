#!/usr/bin/env bash
# shellcheck disable=SC2317
# document https://www.yuque.com/lwmacct/docker/buildx

# exit 0
__main() {
    # 准备工作
    _sh_path=$(realpath "$(ps -p $$ -o args= 2>/dev/null | awk '{print $2}')") # 当前脚本路径
    _pro_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-2)}')               # 当前项目名
    _dir_name=$(echo "$_sh_path" | awk -F '/' '{print $(NF-1)}')               # 当前目录名
    _image="${_pro_name}:$_dir_name"

    {
        #  生成Dockerfile
        cd "$(dirname "$_sh_path")" || exit 1
        cat <<"EOF" >Dockerfile
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
COPY Dockerfile /srv/dockerfile/SED_REPLACE
EOF
        sed -i "s/SED_REPLACE/$_image/g" Dockerfile
    }

    # 打包进行
    {
        cd "$(dirname "$_sh_path")" || exit 1
        # 开始构建
        jq 'del(.credsStore)' ~/.docker/config.json | sponge ~/.docker/config.json 2>/dev/null

        _registry="ghcr.io/lwmacct" # 远程注册地址, 如果是 hub.docker.com 则为用户名
        _repository="$_registry/$_image"

        docker buildx use default
        docker buildx build --platform linux/amd64 -t "$_repository" --network host --progress plain --load . && {
            if false; then
                docker rm -f sss
                docker run -itd --name=sss \
                    --ipc=host \
                    --network=host \
                    --cgroupns=host \
                    --privileged=true \
                    --security-opt apparmor=unconfined \
                    "$_repository"
                docker exec -it sss bash
            fi
        }

        docker push "$_repository"
        echo "images: $_repository"

    }

}

__main

__help() {
    cat >/dev/null <<"EOF"
这里可以写一些备注

ghcr.io/lwmacct/250209-cr-ubuntu:noble-t2502090

EOF
}
