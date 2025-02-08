# 使用示例

```bash
#!/usr/bin/env bash

__main() {

  {
    # 镜像准备
    _image1="ghcr.io/lwmacct/250209-cr-ubuntu:noble-t2502090"
    _image2="$(docker images -q $_image1)"
    if [[ "$_image2" == "" ]]; then
      docker pull $_image1
      _image2="$(docker images -q $_image1)"
    fi
  }

  _apps_name="ubuntu"
  _apps_data="/data/$_apps_name"
  cat <<EOF | docker compose -p "$_apps_name" -f - up -d --remove-orphans
services:
  main:
    container_name: $_apps_name
    image: "$_image2"
    restart: always
    network_mode: host
    volumes:
      - $_apps_data:/apps/data
    environment:
      - TZ=Asia/Shanghai
EOF
}

__help() {
  cat <<EOF

EOF
}

__main
```

