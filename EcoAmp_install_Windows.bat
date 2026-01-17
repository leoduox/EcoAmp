@echo off
setlocal enabledelayedexpansion

:: 设置变量
set PYTHON_URL=https://www.python.org/ftp/python/3.11.5/python-3.11.5-embed-amd64.zip
set PIP_URL=https://bootstrap.pypa.io/get-pip.py
set HF_ENDPOINT=https://hf-mirror.com
set PIP_MIRROR=https://mirrors.aliyun.com/pypi/simple

:: 检查并安装Python
if not exist ./EcoAmp/python-3.11.5-embed-amd64\python.exe (
    powershell -Command "& {Invoke-WebRequest -Uri !PYTHON_URL! -OutFile python.zip}"
    powershell -Command "& {Expand-Archive -Path python.zip -DestinationPath ./EcoAmp/python-3.11.5-embed-amd64 -Force}"
    del python.zip
    (
	echo	python311.zip
        echo import site
        echo Lib
        echo Lib\site-packages
        echo .
        echo ..
        echo ../python_script
        echo ../python_script/display_ui_Storage
    ) > ./EcoAmp/python-3.11.5-embed-amd64\python311._pth
)

:: 切换到python目录
cd ./EcoAmp/python-3.11.5-embed-amd64

:: 检查并安装pip
if not exist Scripts\pip.exe (
    powershell -Command "& {Invoke-WebRequest -Uri !PIP_URL! -OutFile get-pip.py}"
    python get-pip.py
)

:: 配置环境变量
path Scripts

:: 安装指定的Python包到Lib\site-packages目录
python -m pip install --upgrade setuptools -i !PIP_MIRROR!
python -m pip install --upgrade pip -i !PIP_MIRROR!

:: 安装指定版本的包
python -m pip install et_xmlfile==2.0.0 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install numpy==2.2.0 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install openpyxl==3.1.5 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install python-dateutil==2.9.0.post0 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install pytz==2024.2 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install six==1.17.0 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install tzdata==2024.2 -t .\Lib\site-packages -i !PIP_MIRROR!

:: 安装最新版本的包
python -m pip install networkx -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install pandas==2.2.3 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install PyMuPDF==1.25.1 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install pyqt6==6.6.0 pyqt6-qt6==6.6.0 pyqt6_sip==13.8.0 -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install requests -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install markdown -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install flask -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install cryptography -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install wmi -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install tqdm -t .\Lib\site-packages -i !PIP_MIRROR!
python -m pip install psutil==7.1.2 -t .\Lib\site-packages -i !PIP_MIRROR!

:: 切换到原始的目录
cd ..\..

:: 准备生成下载EcoAmp最新版本的文件
echo import hmac > download_EcoAmp.py
echo import hashlib >> download_EcoAmp.py
echo import time >> download_EcoAmp.py
echo import requests >> download_EcoAmp.py
echo import json >> download_EcoAmp.py
echo import os >> download_EcoAmp.py
echo import zipfile >> download_EcoAmp.py
echo import shutil >> download_EcoAmp.py
echo from tqdm import tqdm >> download_EcoAmp.py
echo. >> download_EcoAmp.py
echo def generate_signature(timestamp): >> download_EcoAmp.py
echo     secret = '4x8KvFYnVJdK+6OV1GC4A5FGy8f6sDG9+0xDBWzRJ1Yx9eYgxqf0O0v8OzbnAH2d' >> download_EcoAmp.py
echo     message = f"{timestamp}{secret}" >> download_EcoAmp.py
echo     return hmac.new(secret.encode('utf-8'), message.encode('utf-8'), hashlib.sha256).hexdigest() >> download_EcoAmp.py
echo. >> download_EcoAmp.py
echo def get_latest_gonggao(): >> download_EcoAmp.py
echo     try: >> download_EcoAmp.py
echo         timestamp = int(time.time()) >> download_EcoAmp.py
echo         signature = generate_signature(timestamp) >> download_EcoAmp.py
echo         headers = {'X-API-TIMESTAMP': str(timestamp), 'X-API-SIGNATURE': signature} >> download_EcoAmp.py
echo         response = requests.get("http://count.leoduo.cn/get_latest_gonggao", headers=headers) >> download_EcoAmp.py
echo         if response.status_code == 502: >> download_EcoAmp.py
echo             print("Request failed with status code 502, skipping") >> download_EcoAmp.py
echo             return None >> download_EcoAmp.py
echo         if response.status_code == 200: >> download_EcoAmp.py
echo             return response.json()['version_url'] >> download_EcoAmp.py
echo         else: >> download_EcoAmp.py
echo             print(f"Request failed with status code: {response.status_code}, error: {response.text}") >> download_EcoAmp.py
echo             return None >> download_EcoAmp.py
echo     except Exception as e: >> download_EcoAmp.py
echo         print(f"Exception occurred: {str(e)}") >> download_EcoAmp.py
echo         return None >> download_EcoAmp.py
echo. >> download_EcoAmp.py
echo def get_download_link(share_url): >> download_EcoAmp.py
echo     shareId = share_url.split('/')[-1] >> download_EcoAmp.py
echo     url_info = "https://pan.cstcloud.cn/s/api/shareGetInfo" >> download_EcoAmp.py
echo     payload_info = json.dumps({"shareId": shareId, "password": ""}) >> download_EcoAmp.py
echo     url_download = "https://pan.cstcloud.cn/s/api/shareDownloadRequest" >> download_EcoAmp.py
echo     headers = { >> download_EcoAmp.py
echo         'User-Agent': "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0", >> download_EcoAmp.py
echo         'Accept': "application/json, text/javascript, */*; q=0.01", >> download_EcoAmp.py
echo         'Accept-Encoding': "gzip, deflate, br, zstd", >> download_EcoAmp.py
echo         'sec-ch-ua-platform': "\"Windows\"", >> download_EcoAmp.py
echo         'sec-ch-ua': "\"Chromium\";v=\"136\", \"Microsoft Edge\";v=\"136\", \"Not.A/Brand\";v=\"99\"", >> download_EcoAmp.py
echo         'sec-ch-ua-mobile': "?0", >> download_EcoAmp.py
echo         'X-Language': "zh", >> download_EcoAmp.py
echo         'X-Requested-With': "XMLHttpRequest", >> download_EcoAmp.py
echo         'X-Device': "Web", >> download_EcoAmp.py
echo         'Content-Type': "application/json; charset=UTF-8", >> download_EcoAmp.py
echo         'Origin': "https://pan.cstcloud.cn", >> download_EcoAmp.py
echo         'Sec-Fetch-Site': "same-origin", >> download_EcoAmp.py
echo         'Sec-Fetch-Mode': "cors", >> download_EcoAmp.py
echo         'Sec-Fetch-Dest': "empty", >> download_EcoAmp.py
echo         'Referer': "https://pan.cstcloud.cn/web/share.html?hash=fpsl717T3k", >> download_EcoAmp.py
echo         'Accept-Language': "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6,pt-BR;q=0.5,pt;q=0.4,de-DE;q=0.3,de;q=0.2", >> download_EcoAmp.py
echo         'Cookie': "token=4XVqyO_NQNk@607599" >> download_EcoAmp.py
echo     } >> download_EcoAmp.py
echo     response_info = requests.post(url_info, data=payload_info, headers=headers) >> download_EcoAmp.py
echo     fid = response_info.json()['share']['fid'] >> download_EcoAmp.py
echo     payload_download = json.dumps({"fid": fid, "shareId": shareId}) >> download_EcoAmp.py
echo     response_download = requests.post(url_download, data=payload_download, headers=headers) >> download_EcoAmp.py
echo     return response_download.json()['downloadUrl'] >> download_EcoAmp.py
echo. >> download_EcoAmp.py
echo def download_file(url, filename): >> download_EcoAmp.py
echo     response = requests.get(url, stream=True) >> download_EcoAmp.py
echo     total_size = int(response.headers.get('content-length', 0)) >> download_EcoAmp.py
echo     progress_bar = tqdm(total=total_size, unit='iB', unit_scale=True) >> download_EcoAmp.py
echo     with open(filename, 'wb') as file: >> download_EcoAmp.py
echo         for data in response.iter_content(chunk_size=1024): >> download_EcoAmp.py
echo             progress_bar.update(len(data)) >> download_EcoAmp.py
echo             file.write(data) >> download_EcoAmp.py
echo     progress_bar.close() >> download_EcoAmp.py
echo. >> download_EcoAmp.py
echo def extract_and_flatten(zip_path, target_dir): >> download_EcoAmp.py
echo     os.makedirs(target_dir, exist_ok=True) >> download_EcoAmp.py
echo     temp_dir = os.path.join(target_dir, "temp_extract") >> download_EcoAmp.py
echo     os.makedirs(temp_dir, exist_ok=True) >> download_EcoAmp.py
echo     try: >> download_EcoAmp.py
echo         with zipfile.ZipFile(zip_path, 'r') as zip_ref: >> download_EcoAmp.py
echo             for file_info in zip_ref.infolist(): >> download_EcoAmp.py
echo                 try: >> download_EcoAmp.py
echo                     file_info.filename = file_info.filename.encode('cp437').decode('gbk') >> download_EcoAmp.py
echo                 except: >> download_EcoAmp.py
echo                     pass >> download_EcoAmp.py
echo                 zip_ref.extract(file_info, temp_dir) >> download_EcoAmp.py
echo         extracted_items = os.listdir(temp_dir) >> download_EcoAmp.py
echo         if len(extracted_items) == 1: >> download_EcoAmp.py
echo             top_item = os.path.join(temp_dir, extracted_items[0]) >> download_EcoAmp.py
echo             if os.path.isdir(top_item): >> download_EcoAmp.py
echo                 for item in os.listdir(top_item): >> download_EcoAmp.py
echo                     src = os.path.join(top_item, item) >> download_EcoAmp.py
echo                     dst = os.path.join(target_dir, item) >> download_EcoAmp.py
echo                     if os.path.exists(dst): >> download_EcoAmp.py
echo                         if os.path.isdir(dst): >> download_EcoAmp.py
echo                             shutil.rmtree(dst) >> download_EcoAmp.py
echo                         else: >> download_EcoAmp.py
echo                             os.remove(dst) >> download_EcoAmp.py
echo                     shutil.move(src, dst) >> download_EcoAmp.py
echo                 if not os.listdir(top_item): >> download_EcoAmp.py
echo                     os.rmdir(top_item) >> download_EcoAmp.py
echo             else: >> download_EcoAmp.py
echo                 shutil.move(top_item, os.path.join(target_dir, extracted_items[0])) >> download_EcoAmp.py
echo     except Exception as e: >> download_EcoAmp.py
echo         print(f"Error during extraction: {str(e)}") >> download_EcoAmp.py
echo         raise >> download_EcoAmp.py
echo     finally: >> download_EcoAmp.py
echo         if os.path.exists(temp_dir): >> download_EcoAmp.py
echo             shutil.rmtree(temp_dir, ignore_errors=True) >> download_EcoAmp.py
echo         if os.path.exists(zip_path): >> download_EcoAmp.py
echo             try: >> download_EcoAmp.py
echo                 os.remove(zip_path) >> download_EcoAmp.py
echo             except: >> download_EcoAmp.py
echo                 pass >> download_EcoAmp.py
echo. >> download_EcoAmp.py
echo if __name__ == '__main__': >> download_EcoAmp.py
echo     download_link = get_latest_gonggao() >> download_EcoAmp.py
echo     if download_link and 'pan.cstcloud.cn' in download_link: >> download_EcoAmp.py
echo         download_link = get_download_link(download_link) >> download_EcoAmp.py
echo     print(download_link) >> download_EcoAmp.py
echo     download_file(download_link, 'EcoAmp_latest.rar') >> download_EcoAmp.py
echo     extract_and_flatten('EcoAmp_latest.rar', "./EcoAmp/") >> download_EcoAmp.py
echo File download_EcoAmp.py has been created successfully.

:: 运行下载文件
.\EcoAmp\python-3.11.5-embed-amd64\python.exe .\download_EcoAmp.py

:: 运行下载文件
del .\download_EcoAmp.py



:: 创建并写入config.json文件

(
    echo {
    echo     "R_bin": "set the bin path of the R package for the software to function properly",
    echo     "Current_language": "Simplified Chinese",
    echo     "current_name": "",
    echo     "temperature": 0.63,
    echo     "system": "You are an expert in ecological data analysis, assisting users in analyzing the results of image plotting. You reply to my questions in Chinese. As a built-in assistant of a software, your output environment supports Markdown format, but table output is only supported in HTML format. Remember not to output tables in Markdown format.",
    echo     "max_token": "5000",
    echo     "stream": true,
    echo     "entries": [],
    echo     "Vip_active_code": "",
    echo     "if_auto_sent_message": false
    echo }
) > ".\EcoAmp\config.json"

(
    echo 1. EcoAmp is a software designed specifically for ecologists to analyze amplicon data.
    echo 2. The name EcoAmp comes from its purpose, which is to provide ecologists with a convenient tool for processing and analyzing amplicon data.
    echo 3. The data analysis functions of EcoAmp are completely free. If you bought it, you were cheated.
    echo 4. WeChat Public Account: EcoAmp Bioinformatics Analysis
    echo     Blog URL: https://www.leoduo.cn
    echo     Technical Support QQ: 2733997298
    echo     Email: li@leoduo.cn
    echo If you encounter any issues during use, feel free to contact us through the above methods.
) > ".\EcoAmp\Readme.txt"



echo install_EcoAmp has been successfully

:: 暂停
pause