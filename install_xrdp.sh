#!/bin/bash

# update sistem
apt update && apt upgrade -y

# install dependensi
apt install -y curl git sudo docker.io docker-compose

# enable docker
systemctl enable --now docker

# install node.js dan npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# buat folder dan file docker-compose
mkdir -p ~/xrdp && cd ~/xrdp
cat <<EOF > docker-compose.yml
version: '3.8'
services:
  xrdp:
    image: danielguerra/ubuntu-xrdp
    container_name: xrdp_server
    restart: always
    ports:
      - "3389:3389"
    environment:
      - TZ=Asia/Jakarta
    volumes:
      - xrdp-data:/home
volumes:
  xrdp-data:
EOF

# jalankan xrdp dengan docker
docker-compose up -d

echo "Xrdp berhasil diinstal! Silakan koneksi via RDP ke your_server_ip:3389"
