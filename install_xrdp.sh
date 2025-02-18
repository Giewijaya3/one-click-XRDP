#!/bin/bash

echo "🚀 mulai instalasi xrdp dan lingkungan desktop..."

# update sistem
echo "🔄 update sistem..."
sudo apt update && sudo apt upgrade -y

# install xrdp
echo "💻 install xrdp..."
sudo apt install xrdp -y

# enable dan start xrdp
echo "⚙️ mengaktifkan xrdp..."
sudo systemctl enable xrdp
sudo systemctl start xrdp

# pilih lingkungan desktop
echo ""
echo "🎨 pilih lingkungan desktop:"
echo "1) xfce (ringan, direkomendasikan)"
echo "2) gnome (modern, lebih berat)"
echo "3) kde (mirip windows)"
read -p "masukkan pilihan (1/2/3): " choice

case $choice in
    1)
        echo "🟢 menginstall xfce..."
        sudo apt install xfce4 xfce4-goodies -y
        echo "xfce4-session" > ~/.xsession
        ;;
    2)
        echo "🟡 menginstall gnome..."
        sudo apt install ubuntu-desktop -y
        ;;
    3)
        echo "🔵 menginstall kde..."
        sudo apt install kde-plasma-desktop -y
        ;;
    *)
        echo "⚠️ pilihan tidak valid, default ke xfce..."
        sudo apt install xfce4 xfce4-goodies -y
        echo "xfce4-session" > ~/.xsession
        ;;
esac

# restart xrdp
echo "🔄 restart xrdp..."
sudo systemctl restart xrdp

# atur hak akses xrdp
echo "🔐 mengatur hak akses xrdp..."
sudo adduser xrdp ssl-cert
sudo systemctl restart xrdp

# konfigurasi firewall
echo "🛡️ mengaktifkan firewall (ufw) dan membuka port 3389..."
sudo ufw allow 3389/tcp
sudo ufw enable
sudo ufw reload

echo "✅ instalasi selesai! gunakan remote desktop untuk mengakses VPS."
