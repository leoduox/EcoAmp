#!/bin/bash
# set -e 遇错立即停止，确保安全
set -e

echo "==============================================="
echo "        EcoAmp MacOS 一键安装程序 (自动更新版)"
echo "==============================================="

# 1. 检测系统架构与安装 Conda
# ------------------------------------------------
ARCH=$(uname -m)
echo "检测到系统架构: $ARCH"

if command -v conda &> /dev/null
then
    echo "[✔] 已检测到 conda, 跳过安装"
else
    echo "[!] 未检测到 conda，开始安装 Miniconda..."
    if [ "$ARCH" = "arm64" ]; then
        curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh
        bash Miniconda3-latest-MacOSX-arm64.sh -b -p $HOME/miniconda3
        rm Miniconda3-latest-MacOSX-arm64.sh
    else
        curl -L -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
        bash Miniconda3-latest-MacOSX-x86_64.sh -b -p $HOME/miniconda3
        rm Miniconda3-latest-MacOSX-x86_64.sh
    fi
    export PATH="$HOME/miniconda3/bin:$PATH"
fi

# 初始化 conda (兼容不同 shell)
source $HOME/miniconda3/etc/profile.d/conda.sh

# 2. 配置环境与安装依赖
# ------------------------------------------------
echo "[+] 配置 conda 镜像源（清华源）"
# 这里的配置为了防止报错，加了 || true
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main || true
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free || true
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge || true
conda config --set show_channel_urls yes || true
conda config --set auto_activate_base false || true

echo "[+] 检查环境 EcoAmp_py3115 是否存在"
if conda env list | grep -q "EcoAmp_py3115"; then
    echo "[✔] Conda 环境 EcoAmp_py3115 已存在，跳过创建"
else
    echo "[+] 创建 Conda 环境 EcoAmp_py3115"
    conda create -y -n EcoAmp_py3115 python=3.11.5
fi

# 激活环境
conda activate EcoAmp_py3115

echo "[+] 安装 Python 依赖"
python -m pip install --upgrade pip

# 注意：移除了 wmi (Windows专用)，保留了 requests, tqdm 用于下载脚本
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
psutil==7.1.2

# 3. 生成 Python 下载脚本 (核心修改)
# ------------------------------------------------
echo "[+] 生成动态下载脚本 download_EcoAmp.py..."

# 使用 cat EOF 将 Python 代码写入文件
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
        response = requests.get("http://count.leoduo.cn/get_latest_gonggao", headers=headers)
        if response.status_code == 502:
            print("Request failed with status code 502, skipping")
            return None
        if response.status_code == 200:
            # === 修改点：此处修改为获取 macos_url ===
            return response.json()['macos_url']
        else:
            print(f"Request failed with status code: {response.status_code}, error: {response.text}")
            return None
    except Exception as e:
        print(f"Exception occurred: {str(e)}")
        return None

def get_download_link(share_url):
    try:
        shareId = share_url.split('/')[-1]
        url_info = "https://pan.cstcloud.cn/s/api/shareGetInfo"
        payload_info = json.dumps({"shareId": shareId, "password": ""})
        url_download = "https://pan.cstcloud.cn/s/api/shareDownloadRequest"
        headers = {
            'User-Agent': "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            'Accept': "application/json, text/javascript, */*; q=0.01",
            'Content-Type': "application/json; charset=UTF-8",
            'Origin': "https://pan.cstcloud.cn",
            'Referer': f"https://pan.cstcloud.cn/web/share.html?hash={shareId}",
            'Cookie': "token=4XVqyO_NQNk@607599"
        }
        
        response_info = requests.post(url_info, data=payload_info, headers=headers)
        if response_info.status_code != 200:
             print(f"Error info: {response_info.text}")
             return None
             
        fid = response_info.json()['share']['fid']
        
        payload_download = json.dumps({"fid": fid, "shareId": shareId})
        response_download = requests.post(url_download, data=payload_download, headers=headers)
        return response_download.json()['downloadUrl']
    except Exception as e:
        print(f"Error getting download link: {str(e)}")
        return None

def download_file(url, filename):
    print(f"Downloading from: {url}")
    response = requests.get(url, stream=True)
    total_size = int(response.headers.get('content-length', 0))
    progress_bar = tqdm(total=total_size, unit='iB', unit_scale=True)
    with open(filename, 'wb') as file:
        for data in response.iter_content(chunk_size=1024):
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
                    # Windows下常见的编码修复逻辑，保留以防万一
                    file_info.filename = file_info.filename.encode('cp437').decode('gbk')
                except:
                    pass
                zip_ref.extract(file_info, temp_dir)
        
        # 扁平化处理逻辑：如果解压后只有一个文件夹，则移动内容到上一层
        extracted_items = os.listdir(temp_dir)
        if len(extracted_items) == 1:
            top_item = os.path.join(temp_dir, extracted_items[0])
            if os.path.isdir(top_item):
                for item in os.listdir(top_item):
                    src = os.path.join(top_item, item)
                    dst = os.path.join(target_dir, item)
                    if os.path.exists(dst):
                        if os.path.isdir(dst):
                            shutil.rmtree(dst)
                        else:
                            os.remove(dst)
                    shutil.move(src, dst)
                # 清理空文件夹
                if not os.listdir(top_item):
                    os.rmdir(top_item)
            else:
                shutil.move(top_item, os.path.join(target_dir, extracted_items[0]))
        else:
            # 如果不是单文件夹结构，将所有内容从 temp 移到 target
            for item in extracted_items:
                 src = os.path.join(temp_dir, item)
                 dst = os.path.join(target_dir, item)
                 if os.path.exists(dst):
                    if os.path.isdir(dst):
                        shutil.rmtree(dst)
                    else:
                        os.remove(dst)
                 shutil.move(src, dst)

    except Exception as e:
        print(f"Error during extraction: {str(e)}")
        raise
    finally:
        if os.path.exists(temp_dir):
            shutil.rmtree(temp_dir, ignore_errors=True)
        if os.path.exists(zip_path):
            try:
                os.remove(zip_path)
            except:
                pass

if __name__ == '__main__':
    # 目标安装路径
    INSTALL_DIR = os.path.expanduser("~/EcoAmp/EcoAmp_macos")
    ZIP_NAME = "EcoAmp_macos.zip"

    print("Fetching download link...")
    download_link = get_latest_gonggao()
    
    if download_link and 'pan.cstcloud.cn' in download_link:
        download_link = get_download_link(download_link)
        if download_link:
            download_file(download_link, ZIP_NAME)
            extract_and_flatten(ZIP_NAME, INSTALL_DIR)
            print("Download and extraction complete.")
        else:
            print("Failed to resolve download URL.")
    else:
        print(f"Could not get valid pan.cstcloud.cn link. Raw link: {download_link}")

EOF

# 4. 执行下载脚本并清理
# ------------------------------------------------
echo "[+] 开始执行下载..."
# 确保使用当前 Conda 环境的 Python
python download_EcoAmp.py

echo "[+] 清理临时脚本"
rm download_EcoAmp.py

# 5. 创建启动文件
# ------------------------------------------------
APP_DIR=~/EcoAmp/EcoAmp_macos

echo "[+] 创建 EcoAmp.command 启动文件"
cat > "$APP_DIR/EcoAmp.command" <<EOF
#!/bin/bash
export PATH="\$HOME/miniconda3/bin:\$PATH"
source \$HOME/miniconda3/etc/profile.d/conda.sh
conda activate EcoAmp_py3115
cd "$APP_DIR"
# 确保 main_app_start.py 存在，如果解压后的名字不同，请修改此处
python main_app_start.py
EOF

chmod +x "$APP_DIR/EcoAmp.command"

# 6. 生成 Config 和 Readme (参考 Windows 脚本补充)
# ------------------------------------------------
echo "[+] 生成配置文件 config.json"
cat > "$APP_DIR/config.json" <<EOF
{
     "R_bin": "set the bin path of the R package for the software to function properly",
     "Current_language": "Simplified Chinese",
     "current_name": "",
     "temperature": 0.63,
     "system": "You are an expert in ecological data analysis, assisting users in analyzing the results of image plotting. You reply to my questions in Chinese. As a built-in assistant of a software, your output environment supports Markdown format, but table output is only supported in HTML format. Remember not to output tables in Markdown format.",
     "max_token": "5000",
     "stream": true,
     "entries": [],
     "Vip_active_code": "",
     "if_auto_sent_message": false
}
EOF

echo "[+] 生成说明文件 Readme.txt"
cat > "$APP_DIR/Readme.txt" <<EOF
1. EcoAmp is a software designed specifically for ecologists to analyze amplicon data.
2. The name EcoAmp comes from its purpose, which is to provide ecologists with a convenient tool for processing and analyzing amplicon data.
3. The data analysis functions of EcoAmp are completely free. If you bought it, you were cheated.
4. WeChat Public Account: EcoAmp Bioinformatics Analysis
     Blog URL: https://www.leoduo.cn
     Technical Support QQ: 2733997298
     Email: li@leoduo.cn
If you encounter any issues during use, feel free to contact us through the above methods.
EOF

echo "==============================================="
echo "🎉 EcoAmp 已成功安装"
echo "📂 安装目录: $APP_DIR"
echo "✨ 双击启动: $APP_DIR/EcoAmp.command"
echo "==============================================="