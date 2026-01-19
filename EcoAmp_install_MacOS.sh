#!/bin/bash
set -e

echo "==============================================="
echo "      EcoAmp MacOS 一键安装程序 (便携安装版)"
echo "==============================================="

# 获取当前脚本运行的目录
CURRENT_RUN_DIR="$(pwd)"
# 定义安装目录为当前目录下的 EcoAmp 文件夹
INSTALL_DIR="$CURRENT_RUN_DIR/EcoAmp"

echo "[i] 安装目标位置: $INSTALL_DIR"
echo "[i] 注意：安装完成后，主程序和启动脚本都在此文件夹内。"
echo "==============================================="

ARCH="$(uname -m)"
echo "检测到系统架构: $ARCH"

# -----------------------------
# 工具函数：初始化 conda（适配各种安装位置）
# -----------------------------
init_conda() {
  # 1) 如果 conda 命令可用，优先用 conda info --base 获取 base
  if command -v conda >/dev/null 2>&1; then
    local base
    base="$(conda info --base 2>/dev/null || true)"
    if [ -n "$base" ] && [ -f "$base/etc/profile.d/conda.sh" ] && [ -x "$base/bin/conda" ]; then
      eval "$("$base/bin/conda" shell.bash hook)"
      export CONDA_BASE="$base"
      return 0
    fi
  fi

  # 2) 常见路径兜底
  local candidates=(
    "$HOME/miniconda3"
    "$HOME/anaconda3"
    "/opt/anaconda3"
    "/opt/miniconda3"
    "/opt/homebrew/Caskroom/miniconda/base"
    "/opt/homebrew/Caskroom/anaconda/base"
    "/usr/local/anaconda3"
    "/usr/local/miniconda3"
  )

  for base in "${candidates[@]}"; do
    if [ -f "$base/etc/profile.d/conda.sh" ] && [ -x "$base/bin/conda" ]; then
      eval "$("$base/bin/conda" shell.bash hook)"
      export CONDA_BASE="$base"
      return 0
    fi
  done

  return 1
}

# -----------------------------
# 1. 检测 conda，不存在则安装 Miniconda
# -----------------------------
if command -v conda >/dev/null 2>&1; then
  echo "[✔] 已检测到 conda, 尝试初始化..."
  if init_conda; then
    echo "[✔] Conda 初始化成功: $CONDA_BASE"
  else
    echo "[!] 检测到 conda 命令，但无法定位 base，将尝试安装 Miniconda..."
    INSTALL_MINICONDA=1
  fi
else
  echo "[!] 未检测到 conda，开始安装 Miniconda..."
  INSTALL_MINICONDA=1
fi

if [ "${INSTALL_MINICONDA:-0}" = "1" ]; then
  if [ "$ARCH" = "arm64" ]; then
    MINICONDA_SH="Miniconda3-latest-MacOSX-arm64.sh"
  else
    MINICONDA_SH="Miniconda3-latest-MacOSX-x86_64.sh"
  fi

  curl -L -O "https://repo.anaconda.com/miniconda/$MINICONDA_SH"
  bash "$MINICONDA_SH" -b -p "$HOME/miniconda3"
  rm -f "$MINICONDA_SH"

  export PATH="$HOME/miniconda3/bin:$PATH"

  echo "[+] Miniconda 安装完成，初始化 conda..."
  if init_conda; then
    echo "[✔] Conda 初始化成功: $CONDA_BASE"
  else
    echo "[✘] Miniconda 已安装但初始化失败，请检查 $HOME/miniconda3"
    exit 1
  fi
fi

# -----------------------------
# 2. 配置环境与安装依赖
# -----------------------------
echo "[+] 配置 conda 镜像源（清华源）"
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main || true
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free || true
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge || true
conda config --set show_channel_urls yes || true
conda config --set auto_activate_base false || true

ENV_NAME="EcoAmp_py3115"

echo "[+] 检查环境 $ENV_NAME 是否存在"
if conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
  echo "[✔] Conda 环境 $ENV_NAME 已存在，跳过创建"
else
  echo "[+] 创建 Conda 环境 $ENV_NAME"
  conda create -y -n "$ENV_NAME" python=3.11.5
fi

echo "[+] 激活环境 $ENV_NAME"
conda activate "$ENV_NAME"

echo "[+] 安装 Python 依赖"
python -m pip install --upgrade pip
python -m pip install \
  et_xmlfile==2.0.0 \
  numpy \
  openpyxl==3.1.5 \
  python-dateutil==2.9.0.post0 \
  pytz \
  six==1.17.0 \
  tzdata \
  networkx \
  pandas==2.2.3 \
  PyMuPDF==1.25.1 \
  pyqt6==6.6.0 \
  pyqt6-qt6==6.6.0 \
  pyqt6_sip==13.8.0 \
  requests \
  markdown \
  flask \
  cryptography \
  tqdm \
  psutil==7.1.2 \
  pyobjc-framework-Cocoa

# -----------------------------
# 3. 生成并运行下载脚本
# -----------------------------
# 创建安装目录
mkdir -p "$INSTALL_DIR"

echo "[+] 生成动态下载脚本 download_EcoAmp.py..."

# 这里我们将 INSTALL_DIR 通过环境变量传给 Python，避免硬编码
export ECOAMP_TARGET_DIR="$INSTALL_DIR"

cat << 'EOF' > download_EcoAmp.py
import hmac
import hashlib
import time
import requests
import json
import os
import zipfile
import shutil
from tqdm import tqdm

def generate_signature(timestamp):
    secret = '4x8KvFYnVJdK+6OV1GC4A5FGy8f6sDG9+0xDBWzRJ1Yx9eYgxqf0O0v8OzbnAH2d'
    message = f"{timestamp}{secret}"
    return hmac.new(secret.encode('utf-8'), message.encode('utf-8'), hashlib.sha256).hexdigest()

def get_latest_gonggao():
    try:
        timestamp = int(time.time())
        signature = generate_signature(timestamp)
        headers = {'X-API-TIMESTAMP': str(timestamp), 'X-API-SIGNATURE': signature}
        response = requests.get("http://count.leoduo.cn/get_latest_gonggao", headers=headers, timeout=30)
        if response.status_code == 200:
            return response.json().get('macos_url')
        return None
    except Exception as e:
        print(f"Exception: {str(e)}")
        return None

def get_download_link(share_url):
    try:
        shareId = share_url.split('/')[-1]
        url_info = "https://pan.cstcloud.cn/s/api/shareGetInfo"
        payload_info = json.dumps({"shareId": shareId, "password": ""})
        url_download = "https://pan.cstcloud.cn/s/api/shareDownloadRequest"
        headers = {
            'User-Agent': "Mozilla/5.0",
            'Content-Type': "application/json; charset=UTF-8",
            'Referer': f"https://pan.cstcloud.cn/web/share.html?hash={shareId}",
            'Cookie': "token=4XVqyO_NQNk@607599"
        }
        response_info = requests.post(url_info, data=payload_info, headers=headers, timeout=30)
        if response_info.status_code != 200: return None
        fid = response_info.json()['share']['fid']
        payload_download = json.dumps({"fid": fid, "shareId": shareId})
        response_download = requests.post(url_download, data=payload_download, headers=headers, timeout=30)
        return response_download.json().get('downloadUrl')
    except:
        return None

def download_file(url, filename):
    print(f"Downloading from: {url}")
    response = requests.get(url, stream=True, timeout=60)
    total_size = int(response.headers.get('content-length', 0))
    progress_bar = tqdm(total=total_size, unit='iB', unit_scale=True)
    with open(filename, 'wb') as file:
        for data in response.iter_content(chunk_size=1024):
            if not data: continue
            progress_bar.update(len(data))
            file.write(data)
    progress_bar.close()

def extract_and_flatten(zip_path, target_dir):
    print(f"Extracting to: {target_dir}")
    os.makedirs(target_dir, exist_ok=True)
    temp_dir = os.path.join(target_dir, "temp_extract")
    os.makedirs(temp_dir, exist_ok=True)
    
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            for file_info in zip_ref.infolist():
                try:
                    file_info.filename = file_info.filename.encode('cp437').decode('gbk')
                except:
                    pass
                zip_ref.extract(file_info, temp_dir)
        
        # Flatten logic: move contents of the inner folder to target_dir
        extracted_items = os.listdir(temp_dir)
        # Assuming typical structure: zip -> EcoAmp_macos/ -> files
        source_base = temp_dir
        if len(extracted_items) == 1 and os.path.isdir(os.path.join(temp_dir, extracted_items[0])):
            source_base = os.path.join(temp_dir, extracted_items[0])
            
        for item in os.listdir(source_base):
            src = os.path.join(source_base, item)
            dst = os.path.join(target_dir, item)
            if os.path.exists(dst):
                if os.path.isdir(dst): shutil.rmtree(dst)
                else: os.remove(dst)
            shutil.move(src, dst)
            
    finally:
        if os.path.exists(temp_dir): shutil.rmtree(temp_dir, ignore_errors=True)
        if os.path.exists(zip_path): os.remove(zip_path)

if __name__ == '__main__':
    # 获取环境变量中的安装目录
    target_dir = os.environ.get("ECOAMP_TARGET_DIR")
    if not target_dir:
        print("Error: Target directory not set.")
        exit(1)

    zip_name = "EcoAmp_macos.zip"
    print("Fetching download link...")
    link = get_latest_gonggao()
    if link:
        d_link = get_download_link(link)
        if d_link:
            download_file(d_link, zip_name)
            extract_and_flatten(zip_name, target_dir)
            print("Download and extraction complete.")
        else:
            print("Failed to get direct download link.")
    else:
        print("Failed to get update info.")
EOF

echo "[+] 开始执行下载..."
python download_EcoAmp.py
rm -f download_EcoAmp.py

# -----------------------------
# 4. 创建启动文件（放在同一目录下）
# -----------------------------
# 此时，主程序文件应已解压在 $INSTALL_DIR 下
LAUNCH_SCRIPT="$INSTALL_DIR/EcoAmp.command"

echo "[+] 创建启动文件: EcoAmp.command"
cat > "$LAUNCH_SCRIPT" <<EOF
#!/bin/bash
set -e

# 获取脚本所在目录（实现便携性的关键）
DIR="\$( cd "\$( dirname "\${BASH_SOURCE[0]}" )" && pwd )"

# 自动寻找 conda base
find_conda_base() {
  if command -v conda >/dev/null 2>&1; then
    local base
    base="\$(conda info --base 2>/dev/null || true)"
    if [ -n "\$base" ] && [ -x "\$base/bin/conda" ]; then
      echo "\$base"
      return 0
    fi
  fi

  local candidates=(
    "\$HOME/miniconda3"
    "\$HOME/anaconda3"
    "/opt/anaconda3"
    "/opt/miniconda3"
    "/opt/homebrew/Caskroom/miniconda/base"
    "/opt/homebrew/Caskroom/anaconda/base"
    "/usr/local/anaconda3"
    "/usr/local/miniconda3"
  )

  for base in "\${candidates[@]}"; do
    if [ -x "\$base/bin/conda" ]; then
      echo "\$base"
      return 0
    fi
  done
  return 1
}

CONDA_BASE="\$(find_conda_base || true)"

if [ -z "\$CONDA_BASE" ]; then
  # 尝试用 GUI 提示（如果是在 Finder 中双击运行）
  osascript -e 'display alert "错误" message "未检测到 Conda 环境，无法启动 EcoAmp。"' >/dev/null 2>&1 || echo "No Conda found."
  exit 1
fi

# 初始化并激活环境
eval "\$("\$CONDA_BASE/bin/conda" shell.bash hook)"
conda activate EcoAmp_py3115

# 进入脚本所在目录运行 Python 主程序
cd "\$DIR"
python main_app_start.py
EOF

chmod +x "$LAUNCH_SCRIPT"

# -----------------------------
# 5. 生成 Config 和 Readme
# -----------------------------
echo "[+] 生成配置文件 config.json"
cat > "$INSTALL_DIR/config.json" <<EOF
{
     "R_bin": "set the bin path of the R package for the software to function properly",
     "Current_language": "Simplified Chinese",
     "current_name": "",
     "temperature": 0.63,
     "system": "You are an expert in ecological data analysis...",
     "max_token": "5000",
     "stream": true,
     "entries": [],
     "Vip_active_code": "",
     "if_auto_sent_message": false
}
EOF

echo "[+] 生成说明文件 Readme.txt"
cat > "$INSTALL_DIR/Readme.txt" <<EOF
1. EcoAmp 文件夹包含所有程序文件，请勿随意删除内部文件。
2. 双击本文件夹内的 EcoAmp.command 即可启动软件。
3. 您可以移动整个 EcoAmp 文件夹到任何位置，不影响使用。
EOF

# -----------------------------
# 6. 设置图标
# -----------------------------
echo "[+] 设置 EcoAmp.command 图标..."
cat << 'EOF' > set_file_icon.py
import Cocoa
import sys
import os

def set_icon(icon_path, target_file):
    if not os.path.exists(icon_path):
        return
    image = Cocoa.NSImage.alloc().initWithContentsOfFile_(icon_path)
    if image:
        Cocoa.NSWorkspace.sharedWorkspace().setIcon_forFile_options_(image, target_file, 0)

if __name__ == "__main__":
    if len(sys.argv) > 2:
        set_icon(sys.argv[1], sys.argv[2])
EOF

# 图标路径现在在 INSTALL_DIR 下的 ico 文件夹中
python set_file_icon.py "$INSTALL_DIR/ico/EcoAmp.ico" "$LAUNCH_SCRIPT"
rm -f set_file_icon.py

echo "==============================================="
echo "🎉 EcoAmp 安装完成！"
echo "📂 安装位置: $INSTALL_DIR"
echo "✨ 启动方法: 双击文件夹内的 EcoAmp.command"
echo "==============================================="