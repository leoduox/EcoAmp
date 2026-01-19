



[English](https://github.com/leoduox/EcoAmp/blob/main/README.md) | [简体中文](https://github.com/leoduox/EcoAmp/blob/main/README%20_zh.md)

## Overview

EcoAmp, a software for **<u>Eco</u>**logists to analyse **<u>Amp</u>**licon data. EcoAmp is a cross-platform graphical application that integrates widely used microbial community analysis scripts implemented in R and Python. It provides a comprehensive set of functions, including OTU/ASV data normalization, alpha and beta diversity analysis, differential abundance testing, community structure visualization, environmental factor interpretation, and random forest modeling.

![GA](https://www.leoduo.cn/wp-content/uploads/62b1fa162db5478170076828ba9e9b0d.webp)



## Install

**Windows：**

1、Download the compressed package for installation [EcoAmp.v0.16_Windows.zip](https://github.com/leoduox/EcoAmp/releases/download/EcoAmp_v0.16/EcoAmp.v0.16_Windows.zip)，and after decompression, the installation will be successful. 

2、Download [EcoAmp_install_Windows.bat](https://github.com/leoduox/EcoAmp/blob/main/EcoAmp_install_Windows.bat) ，and double-click to complete the installation. 

**macOS：**

Download the [EcoAmp_install_MacOS.sh](https://github.com/leoduox/EcoAmp/blob/main/EcoAmp_install_MacOS.sh) one-click installation script 

Then, simply run the following code to install it in one click.

```bash
# Enter the directory where the installation script is located
cd /Users/zhangsan

# Check if the file exists
ls

# Grant Execution Permission
chmod +x EcoAmp_install_MacOS.sh

# Replace the ^M at the end of the line, as it was written in a Windows environment.
perl -pi -e 's/\r\n|\n|\r/\n/g' EcoAmp_install_MacOS.sh

# Execute the command for one-click installation
./EcoAmp_install_MacOS.sh
```

Detailed steps can be referred to in the personal blog: https://www.leoduo.cn/ecoamp_install.html

## Configuration of the R language environment

Windows users need to set the bin path location of R language in the settings of EcoAmp, so that EcoAmp can call R language to perform plotting. 



 MacOS users need to download R language from the official website of R language and perform the default installation.



## Getting started

Windows users start EcoAmp.exe, while macOS users double-click EcoAmp.command to start. 
You can select the function to fill in the sample data, and then click "Start".



![20260120004338](https://www.leoduo.cn/wp-content/uploads/415f61e5f27dd9dc81881298037af7b5.webp)

