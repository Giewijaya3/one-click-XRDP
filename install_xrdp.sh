#!/bin/bash

# pastikan skrip dijalankan dengan sudo
if [[ $EUID -ne 0 ]]; then
   echo "silakan jalankan dengan sudo: sudo ./install-xrdp-user.sh"
   exit 1
fi

# update sistem
apt update && apt upgrade -y

# install dependensi
apt install -y curl git sudo docker.io docker-compose

# enable docker
systemctl enable --now docker

# install node.js dan npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# buat user baru jika belum ada
read -p "masukkan nama pengguna baru (default: xrdpuser): " username
username=${username:-xrdpuser}

if id "$username" &>/dev/null; then
    echo "pengguna $username sudah ada."
else
    adduser --gecos "" $username
    echo "$username:password123" | chpasswd
    usermod -aG sudo $username
    echo "pengguna $username dibuat dengan password: password123"
fi

# buat folder untuk xrdp
mkdir -p /home/$username/xrdp && cd /home/$username/xrdp
chown -R $username:$username /home/$username/xrdp

# buat file docker-compose.yml
cat <<EOF > /home/$username/xrdp/docker-compose.yml
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

chown $username:$username /home/$username/xrdp/docker-compose.yml

# jalankan xrdp dengan docker
sudo -u $username docker-compose -f /home/$username/xrdp/docker-compose.yml up -d

echo "Xrdp berhasil diinstal untuk pengguna $username! Silakan koneksi via RDP ke your_server_ip:3389"
echo "username: $username | password: password123 (harap ubah setelah login)"
