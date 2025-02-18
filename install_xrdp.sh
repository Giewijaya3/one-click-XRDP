#!/bin/bash

# pastikan skrip dijalankan dengan sudo
if [[ $EUID -ne 0 ]]; then
   echo "silakan jalankan dengan sudo: sudo ./install_xrdp.sh"
   exit 1
fi

# update sistem
apt update && apt upgrade -y

# install dependensi
apt install -y curl git sudo docker.io docker-compose xrdp xfce4 xfce4-goodies

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

# buat file docker-compose.yml dengan port 3390
cat <<EOF > /home/$username/xrdp/docker-compose.yml
version: '3.8'
services:
  xrdp:
    image: danielguerra/ubuntu-xrdp
    container_name: xrdp_server
    restart: always
    ports:
      - "3390:3389"
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

# memastikan xrdp berjalan di port 3390
sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
systemctl restart xrdp xrdp-sesman

# buat file .xsession untuk user
echo "xfce4-session" > /home/$username/.xsession
chown $username:$username /home/$username/.xsession
chmod 644 /home/$username/.xsession

# set xrdp agar menggunakan xfce4
cat <<EOF > /etc/xrdp/startwm.sh
#!/bin/sh
if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi
exec startxfce4
EOF

chmod +x /etc/xrdp/startwm.sh
systemctl restart xrdp xrdp-sesman

echo "Xrdp berhasil diinstal untuk pengguna $username!"
echo "silakan koneksi via RDP ke your_server_ip:3390"
echo "username: $username | password: password123 (harap ubah setelah login)"
