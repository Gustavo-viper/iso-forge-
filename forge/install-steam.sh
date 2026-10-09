#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

dpkg --add-architecture i386
apt-get update
apt-get install -y steam-installer steam-devices

printf '%s\n' 'Steam foi instalado. Abra-o pelo menu do Forge OS.'
