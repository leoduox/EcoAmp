
import subprocess
import os

import sys
# ✅ 1. 启动 loading_app.py 为子进程（不阻塞）
subprocess.Popen([sys.executable, "./main_app_Loding.py"])

import main_app

if __name__ == "__main__":
    main_app.run_app()