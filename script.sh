#!/bin/bash
# Tải Nanominer v3.9.1
echo "Downloading Nanominer v3.9.1..."
wget https://github.com/nanopool/nanominer/releases/download/v3.9.1/nanominer-linux-3.9.1.tar.gz | tar xvz
cd nanominer-linux-3.9.1

# Tạo tệp tin cấu hình
cat <<EOF > config.ini
[Common]
wallet = ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB
rigName = x

[Zephyr]
wallet = ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB
pool1 = ssl://us-zephyr.miningocean.org:5432
# Sử dụng "ssl://" và cổng 5432 cho kết nối SSL
EOF

# Cài đặt các gói cần thiết (vd: NVIDIA driver và CUDA Toolkit cho GPU NVIDIA)
# Thực hiện các bước cài đặt phù hợp với GPU của bạn

# Chạy Nanominer
echo "Starting Nanominer..."
./nanominer config.ini
