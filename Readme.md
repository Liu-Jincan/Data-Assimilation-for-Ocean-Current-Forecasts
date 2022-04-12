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

# .90格式化文档
## 使用fprettify命令格式化.90文件
可选：
 * 新建conda环境，`conda create -n Data-Assimilation-for-Ocean python=3.7`，
 * ubuntu修改默认打开的conda环境，[./bashrc方法](https://www.jianshu.com/p/27b0598d1b98)，

在对应的conda虚拟环境，`pip install fprettify`; 
帮助文档，`fprettify --help`;
格式化，`fprettify -i 4 -r 文件夹路径`；(感觉格式化前后区别不大呀)

## 2022-04-12 不知道为什么可以在.f90文件中右键格式化了，makefile文档也可以，但不知道怎么修改格式化的属性？

# fortran基本语法的学习
[视频：fcode实用编程基础篇](https://liu-jincan.github.io/2022/04/09/yan-jiu-sheng-justtry-function/fortran/07-shi-pin-fcode-shi-yong-bian-cheng-ji-chu-pian/),

# VScode进行gdb调试fortran
## 跨文件调试.f90文件 
Win10和Ubuntu对应的两个博客都记录了跨文件调试的过程；

## 思考如何才能快速的使用gdb调试fortran+修改错误（使用makefile模板项目）
1、在项目中创建一个test的子项目文件夹，子项目包含主程序
* main.f90，
* makefile，
* mod.f90，
2、写这个test项目的launch.json，在.vscode文件夹，用于调试，
3、根据情况更改相关文件，
4、make clean, make,

# 编译项目的.f90文件 (makefile文件的编译部分）
OK，生成了所有的.o文件，即目标文件。

## FAQ：如何在makefile中写上echo "开始编译"？
在链接的时候，makefile对应的第一行写吧～
## FAQ：编译顺序问题？需先编译底层.f90文件，即先编译被调用的文件。那么如何生成一个满足顺序要求的runOBJS

# 链接项目的.o文件(makefile文件的链接部分）
OK，生成了一个run可执行程序～
ldd run 可查看执行run所需的依赖库～
## FAQ：链接顺序问题？.o链接顺序没有要求，随意
前提是编译好了，即在编译时文件相互之间的依赖就需要搞清楚，那么链接就不用考虑顺序问题了；
# DA_cycle.f90入手