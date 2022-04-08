# 主要内容

This project constructs an EnOI (Ensemble Optimal Interpolation) data assimilation model for ocean current forecasts. 

The model constructs the background file from the restart files; 
          reads in observation;
          calculates W matrix for generating an analysis file;
          updates the restart files with the newly generated analysis file.

Next, NEMO restarts with the updated restart files, and another cycle of data assimilation begins...

# 主要目标：ubuntu下，解读文件结构，make自定义构建，学习fortran语法
本分支基于`v0.1.0`分支，～～
> 使用VScode技巧，文件斜体再点击其他文件，斜体的文件会改变；第一次打开的文件是斜体文件；双击文件，斜体的文件会变成正体；

# git上传更新

# 使用fprettify命令格式化.90文件
可选：
 * 新建conda环境，`conda create -n Data-Assimilation-for-Ocean python=3.7`，
 * ubuntu修改默认打开的conda环境，[./bashrc方法](https://www.jianshu.com/p/27b0598d1b98)，

在对应的conda虚拟环境，`pip install fprettify`; 
帮助文档，`fprettify --help`;
格式化，`fprettify -i 4 -r 文件夹路径`；(感觉格式化前后区别不大呀)

