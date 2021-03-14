#!/bin/bash

# Downloading the Necessary files
echo "Building Kali ISO"
echo "Getting the Files"
keyring_url=http://http.kali.org/pool/main/k/kali-archive-keyring/
live_build_url=https://archive.kali.org/kali/pool/main/l/live-build/

keyring_url_deb=$(wget $keyring_url -qO -  | grep -o "kali-archive-keyring_[0-9]*.[0-9]*_all.deb" | head -n 1)
live_build_url_deb=$(wget $live_build_url -qO - | grep -o "live-build_[0-9]*_all.deb" | head -n 1)

wget $keyring_url/$keyring_url_deb
wget $live_build_url/$live_build_url_deb

echo "Files saved successfully"

# Installing the requirements
echo "Installing the requirements"
sudo apt install -y git live-build cdebootstrap debootstrap curl
sudo dpkg -i kali-archive-keyring_2018.2_all.deb
sudo dpkg -i live-build_20190311_all.deb

# Setting up the build scripts and Live Build config
echo "Setting up build scripts and live build config"
cd /usr/share/debootstrap/scripts/
echo "default_mirror http://http.kali.org/kali"; sed -e "s/debian-archive-keyring.gpg/kali-archive-keyring.gpg/g" sid > /tmp/kali
sudo mv /tmp/kali .
sudo ln -s kali kali-rolling

cd ~/
git clone https://gitlab.com/kalilinux/build-scripts/live-build-config.git

cd live-build-config/

echo "Checking the debootstrap"
# Check if good debootstrap is installed
ver_debootstrap=$(dpkg-query -f '${Version}' -W debootstrap)
if dpkg --compare-versions "$ver_debootstrap" lt "1.0.97"; then
if ! echo "$ver_debootstrap" | grep -q kali; then
echo "ERROR: You need debootstrap >= 1.0.97 (or a Kali patched debootstrap). Your current version: $ver_debootstrap" >&2
exit 1
fi
fi

# read variant
echo "Enter the variant"
printf "\t1. GNOME\n"
printf "\t2. KDE\n"
printf "\t3. XFCE\n"
printf "\t4. MATE\n"
printf "\t5. E17\n"
printf "\t6. LXDE\n"
printf "\t7. I3WM\n"
printf "Enter your option (default 1): "
read variant_num
case $variant_num in
  1)
  variant="gnome"
  ;;

  2)
  variant="kde"
  ;;

  3)
  variant="xfce"
  ;;

  4)
  variant="mate"
  ;;

  5)
  variant="e17"
  ;;

  6)
  variant="lxde"
  ;;

  7)
  variant="i3wm"
  ;;

  *)
    echo "Unknown option! selecting GNOME"
    variant="gnome"
    ;;
esac

echo "Building ${variant} variant"
sudo ./build.sh --variant $variant --verbose