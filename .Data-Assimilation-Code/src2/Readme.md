# 编译项目的.f90文件 (makefile文件的编译部分）
OK，生成了所有的.o文件，即目标文件。

## FAQ：如何在makefile中写上echo "开始编译"？
在链接的时候，makefile对应的第一行写吧～
## FAQ：编译顺序问题？需先编译底层.f90文件，即先编译被调用的文件。那么如何生成一个满足顺序要求的runOBJS？（待解决，放弃）
...
放弃使用runOBJS,
## FAQ：可以不需要runOBJS吗？如何写大项目的makefile？（待解决, src2的makefile）
借鉴的makefile项目代码1：https://www.partow.net/programming/makefile/index.html
* SRC
* apps, objects
借鉴的makefile项目代码2：https://www.zhihu.com/question/23792247/answer/600773044
* wildcard, 扩展通配符，搜索指定文件。
* pastubst, 替换通配符，按指定规则做替换。
* 感觉可以推荐大家多看几遍GNU make官方手册，也有中文译版，看完前几章一般就对Makefile挺熟悉了，阅读上没啥问题哦
* 还有个问题: 版本四其实不需要, 因为虽然源码有在目录中,但不一定需要编译(临时扔进来). 最好的方式感觉应该是能够自动推导出项目依赖的所有的源文件和头文件.
* 缺了依赖关系的生成，修改了头文件没办法自动重新编译。把这个加上，基本上自己写个小工程玩玩足够了
Makefile 自动处理依赖关系: http://blog.szm.me/misc/manage_dependencies_with_gcc_and_make/
* 在命令前加一个减号，
* -MM, -M, -MT, 
makefile之创建依赖关系：https://blog.csdn.net/chun_1959/article/details/100151527
* -MM, -M, -MT，
* 貌似fortran无法使用，
快速的理解MakeFile+读懂一个MakeFile：https://zhuanlan.zhihu.com/p/350297509
* all:
* GNU make: https://www.gnu.org/software/make/manual/make.html
* 跟我一起写Makefile (PDF重制版)：https://github.com/seisman/how-to-write-makefile
## FAQ：最后一个核心问题，在src2的makefile中，如何自动生成src文件夹下所有文件的依赖列表？（待解决）
mod_namelist.o: mod_namelist.f90 mod_params.o 
mod_read_coor.o: mod_read_coor.f90 mod_params.o  
mod_read_data.o: mod_read_data.f90 mod_params.o 
mod_obs_superobing.o: mod_obs_superobing.f90 mod_params.o
mod_obs_sorting.o: mod_obs_sorting.f90 mod_params.o mod_obs_superobing.o
mod_matrix_A.o: mod_matrix_A.f90 mod_params.o mod_namelist.o mod_read_coor.o mod_read_data.o mod_matrix_read.o mod_matrix_write.o
mod_matrix_H.o: mod_matrix_H.f90 mod_params.o mod_matrix_read.o mod_matrix_write.o
mod_matrix_L.o: mod_matrix_L.f90 mod_params.o mod_matrix_write.o mod_matrix_read.o
mod_matrix_R.o: mod_matrix_R.f90 mod_params.o mod_matrix_write.o
mod_matrix_W.o: mod_matrix_W.f90 mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_L.o mod_matrix_R.o mod_matrix_inverse.o
mod_analysis.o: mod_analysis.f90 mod_params.o mod_date.o mod_matrix_A.o mod_read_data.o mod_matrix_read.o mod_obs_sorting.o mod_matrix_W.o
DA_cycle.o: DA_cycle.f90 mod_params.o mod_matrix_A.o mod_analysis.o

大佬说：cmake 或者 codeblocks，

# 链接项目的.o文件(makefile文件的链接部分）
OK，生成了一个run可执行程序～
ldd run 可查看执行run所需的依赖库～
## FAQ：链接顺序问题？.o链接顺序没有要求，随意
前提是编译好了，即在编译时文件相互之间的依赖就需要搞清楚，那么链接就不用考虑顺序问题了；

