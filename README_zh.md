



[English](https://github.com/leoduox/EcoAmp/blob/main/README.md) | [简体中文](https://github.com/leoduox/EcoAmp/blob/main/README%20_zh.md)

## 前言

EcoAmp 是一款专为生态学家用来分析扩增子数据设计的软件（a software for **<u>Eco</u>**logists to analyse **<u>Amp</u>**licon data）。EcoAmp 是一款跨平台的图形化应用程序，它整合了在 R 和 Python 中实现的广泛使用的微生物群落分析脚本。该软件提供了丰富的功能，包括 OTU/ASV 数据标准化、α和β多样性分析、差异丰度测试、群落结构可视化、环境因素解释以及随机森林建模。

![GA](http://image.leoduo.cn/uploads/20251207_imeta_stackbar/GA.jpg)



## 安装

**Windows：**

1、下载压缩包进行安装[EcoAmp.v0.16_Windows.zip](https://github.com/leoduox/EcoAmp/releases/download/EcoAmp_v0.16/EcoAmp.v0.16_Windows.zip)，解压之后即可成功安装

2、下载[EcoAmp_install_Windows.bat](https://github.com/leoduox/EcoAmp/blob/main/EcoAmp_install_Windows.bat) ，双击即可完成安装

**macOS：**

下载[EcoAmp_install_MacOS.sh](https://github.com/leoduox/EcoAmp/blob/main/EcoAmp_install_MacOS.sh) 一键安装脚本

然后运行下面的代码即可一键安装

```bash
# 进入安装脚本所在文件目录
cd /Users/zhangsan

# 查看文件是否存在
ls

# 赋予执行权限
chmod +x EcoAmp_install_MacOS.sh

# 替换一下尾行的^M，因为是在Windows环境下编写的
perl -pi -e 's/\r\n|\n|\r/\n/g' EcoAmp_install_MacOS.sh

# 执行一键安装的命令
./EcoAmp_install_MacOS.sh
```

详细步骤可以参考个人博客：https://www.leoduo.cn/ecoamp_install.html

## R语言环境配置

Windows用户需要在EcoAmp的设置中设置R语言的bin路径位置，确保EcoAmp可以调用R语言进行绘图。

macOS用户需要在R语言官网下载R语言，并进行默认安装即可。

## 开始使用

Windows用户启动EcoAmp.exe，macOS双击EcoAmp.command启动

可以选择功能进行填充示例数据，然后点击运行

![20260120004338](http://image.leoduo.cn/uploads/20251207_imeta_stackbar/20260120004338.png)

