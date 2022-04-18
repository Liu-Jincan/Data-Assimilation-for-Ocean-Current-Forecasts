# wjc 老师创建的文件：myrecomand （已删除）
```
gfortran -c -g -C -o3 mod_params.f90
gfortran -c -g -C -o3 mod_date.f90 
gfortran -c -g -C -o3 mod_namelist.f90
gfortran -c -g -C -o3 mod_matrix_read.f90
gfortran -c -g -C -o3 mod_matrix_write.f90 
gfortran -c -g -C -o3 mod_matrix_inverse.f90
gfortran -c -g -C -o3 mod_matrix_H.f90
gfortran -c -g -C -o3 mod_matrix_R.f90
gfortran -c -g -C -o3 mod_matrix_W.f90
gfortran -c -g -C -o3 mod_analysis.f90
gfortran -c -g -C -o3 DA_cycle.f90

gfortran -o da.exe DA_cycle.f90
```
 
# wjc 老师创建的文件：wjc_analysis （未删除，需借鉴思路）

## 同化公式-->模块功能-->数据维度
```
!!!!!------------------------------------------------!!!!!

!!!!! Xa=Xb+P*H'(H*P*H'+R)^(-1)*(yo-H*Xb)------------!!!!!

!!!!! because: P=A*A'/(N-1),(where: A=enxemble-mean)-!!!!!

!!!!!-----so, in this program,is the following-------!!!!!

!!!!!------------------------------------------------!!!!!

!!!!! Xa=Xb+A(HA)'*[HA*(HA)'+(N-1)R]^(-1)*(yo-H*Xb)--!!!!!

!!!!! Xa=Xb+AHAT*(HA*HAT+(N-1)R)^(-1)*(yo-HXb)-------!!!!!

!!!!! Xa=Xb+W*(yo-HXb)=Xb+dX-------------------------!!!!!

!!!!!------------------------------------------------!!!!!

compute: A                        -----mod_matrix_A.f90

compute: H,HA,HAT,AHAT            -----mod_matrix_H.f90

compute: R                        -----mod_matrix_R.f90

compute: W=AHAT*(HA*HAT+R)^(-1)   -----mod_matrix_W.f90

compute: HXb=H*Xb,
         yo=yo-HXb,
         dX=W*yo,
         Xa=Xb+dX                 -----mod_analysis.f90 


N---number of state varible
NN---ensemble size
M---number of observation

Xa:  N*1
Xb:  N*1
yo:  M*1
R:   M*M
H:   M*N
A:   N*NN
HA:  M*NN
HAT: NN*M
AHAT:N*M
HXb: M*1
W:   N*M
dX:  N*1

```
nice~

## 模块功能
!!!-------------------------------------------!!!!!

DA_cycle.f90

Da_time.f90

mod_date.f90

mod_matrix_inverse.f90

mod_matrix_L.f90  --Localization

mod_matrix_write.f90

mod_matrix_read.f90

mod_namelist.f90

mod_obs_sorting.f90

mod_obs_superobing.f90

mod_params.f90

mod_read_coor.f90

## mod_matrix_A
!!!------------------------------------------------

mod_matrix_A:生成集合增益矩阵A
1.首先调用mod_namelist,从mod_params中读取参数后,生成一个包含文件名的文件namelist.txt,里面存储了历史的模式数据的文件名如:20120312_T.nc,
这些文件,称为'集合池',共有NS个文件,存于data/文件夹;

2.然后调用mod_read_corr从任意一个集合池的文件中读取坐标信息,存储于ensemble/coordinate.dta;

3. 调用mod_read_data,将集合池中所有数据的求和取平均存储于ensemble/ensemble_mean_tmp.dta

4.mod_params中的三个参数NS为集合池中文件总数,DN为取样间隔(即每隔DN天取一个样),所以集合数NN=NS/DN.
这里计算A的第i列='按间隔确定的第i个文件中的值'减去'第三步得到的整个集合池的均值',存储于ensemble/Amatrix.txt中.
注意最后一步还存储了其他数据,比如ensemble_sprd_tmp.dta等,可能做局地化时用到.

## Tindex1D
!!!!!!------------------------------------------------




Tindex1D,存储温度观测数据相对于背景场的位置(找与观测最近的网格点的index),假如有5个观测,则Tindex1D=(10 15 20 22 30 36),其中'10'表示
第一个观测最近的网格点的index为10

## mod_params
在mod_params 中修改网格大小,集合大小等
makefile是进行编译,编译成可执行的run文件(make,./run)
./run 出来的中间变量文件以及最终的分析文件分别位于ensemble文件件和output文件夹(注意,这些文件夹的名字可以在 mod_params中设置)

# ENOI和OI的区别，ENOI和ENKF的区别
B，
流依赖，


# 初步运行 DA-Code/build/apps/DA_cycle 可执行文件 + makefile + debug
## error: input/Index1D.txt
```
$ ./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
At line 17 of file mod_matrix_H.f90 (unit = 55)
Fortran runtime error: Cannot open file '/home/wjc/wjc_work/DA_Code/input/Index1D.txt': 没有那个文件或目录

Error termination. Backtrace:
#0  0x7f9f9b2abd21 in ???
#1  0x7f9f9b2ac869 in ???
```

解决方法：open (55, file='input/Index1D.txt', status='old')

## error: ensemble/Hmatrix.txt + apps_makefile
```
$ ./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
         898        1035        1036        1173        1174
 *** Writing matrix H...
At line 17 of file mod_matrix_write.f90 (unit = 111)
Fortran runtime error: Cannot open file '/home/wjc/wjc_work/DA_Code/ensemble/Hmatrix.txt': 没有那个文件或目录

Error termination. Backtrace:
#0  0x7f14fdb11d21 in ???
```

解决方法：open (unit=111, file='ensemble/'//mat_name//'matrix.txt', status='new')


```
$ ./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
         898        1035        1036        1173        1174
 *** Writing matrix H...
At line 18 of file mod_matrix_write.f90 (unit = 111)
Fortran runtime error: Cannot open file 'ensemble/Hmatrix.txt': 文件已存在

Error termination. Backtrace:
#0  0x7fd04e4dcd21 in ???
```

解决方法：写一个关于apps的makefile，这个makefile应该在关于编译的makefile中完成，ok

* ubuntu 像另外一个文件中添加内容, https://blog.csdn.net/gntiler/article/details/52891318, 
* Ubuntu输出重定向, https://blog.csdn.net/weixin_51483516/article/details/120131047,

## error: ensemble/Amatrix.txt

```
$ make
rm -f ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
         898        1035        1036        1173        1174
 *** Writing matrix H...
     ...done.
 *** Reading matrix A...
At line 19 of file mod_matrix_read.f90 (unit = 110)
Fortran runtime error: Cannot open file '/home/wjc/wjc_work/DA_Code/ensemble/Amatrix.txt': 没有那个文件或目录

Error termination. Backtrace:
#0  0x7f40967e5d21 in ???
```

解决办法：open (unit=110, file='ensemble/'//mat_name//'matrix.txt', status='old')

* status='old', https://zhidao.baidu.com/question/990498714497853099.html
* 语句中STATUS=‘OLD’表明是一个已存在的老文件,打开后可顺序读取。

## 格式化文档
```
fprettify -i 4 -r  /home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/src
```
ok

## error: input/obs_data.txt

```
$ make
rm -f ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
         898        1035        1036        1173        1174
 *** Writing matrix H...
     ...done.
 *** Reading matrix A...
     ...done.
 sdsdsdsds
 *** Writing matrix HA...
     ...done.
 *** Writing matrix AHAT...
     ...done.
 *** Reading matrix HA...
     ...done.
 *** Reading matrix AHAT...
     ...done.
 *** Writing matrix W...
     ...done.
 Updating the background with observational data...
At line 47 of file mod_analysis.f90 (unit = 55)
Fortran runtime error: Cannot open file '/home/wjc/wjc_work/DA_Code/input/obs_data.txt': 没有那个文件或目录

Error termination. Backtrace:
#0  0x7f06086a7d21 in ???
#1  0x7f06086a8869 in ???
```

解决办法： open (55, file='input/obs_data.txt', status='old')


## error: input/bg_data.txt

```
$ make
rm -f ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
         898        1035        1036        1173        1174
 *** Writing matrix H...
     ...done.
 *** Reading matrix A...
     ...done.
 sdsdsdsds
 *** Writing matrix HA...
     ...done.
 *** Writing matrix AHAT...
     ...done.
 *** Reading matrix HA...
     ...done.
 *** Reading matrix AHAT...
     ...done.
 *** Writing matrix W...
     ...done.
 Updating the background with observational data...
 *** SUCCESS Sorted observation is read in!
At line 62 of file mod_analysis.f90 (unit = 55)
Fortran runtime error: Cannot open file '/home/wjc/wjc_work/DA_Code/input/bg_data.txt': 没有那个文件或目录

Error termination. Backtrace:
#0  0x7f7e65f92d21 in ???
#1  0x7f7e65f93869 in ???
```

解决方法：open (55, file='input/bg_data.txt', status='old')

## 初步运行成功

```
$ make
rm -f ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
./DA_cycle 
 Preparing observational data...
 Computing gain matrix...
         898        1035        1036        1173        1174
 *** Writing matrix H...
     ...done.
 *** Reading matrix A...
     ...done.
 sdsdsdsds
 *** Writing matrix HA...
     ...done.
 *** Writing matrix AHAT...
     ...done.
 *** Reading matrix HA...
     ...done.
 *** Reading matrix AHAT...
     ...done.
 *** Writing matrix W...
     ...done.
 Updating the background with observational data...
 *** SUCCESS Sorted observation is read in!
 *** SUCCESS Sorted observation is read in!
 *** Reading matrix H...
     ...done.
 *** Writing matrix HXb...
     ...done.
 *** Reading matrix W...
     ...done.
 *** SUCCESS Analysis is computed!
 *** SUCCESS Analysis is saved!
Time =       0.00 minutes.
 dfdfdf
```

## gdb debug launch.json 配置， （通过makefile实现）

先手动配置：ok

智能配置解决方法：

* 在src中的makefile中的apps_makefile目标中，echo重定向在apps中的makefile，生成gdb-debug目标（此目标实现make debug功能），gdb-debug-launch目标（此目标包含.vscode/launch.json对应的配置信息）

* FAQ: 命令行实现gdb debug，即运行VScode 中launch.json的配置文件；（暂时先不管吧，凑合着用）

nice～

# src 中的文件组成及其功能

## tree
```
$ tree
.
├── ceshi.f90
├── DA_cycle.f90
├── DA_time.f90
├── Makefile
├── mod_analysis.f90
├── mod_date.f90
├── mod_matrix_H.f90
├── mod_matrix_inverse.f90
├── mod_matrix_L.f90
├── mod_matrix_read.f90
├── mod_matrix_R.f90
├── mod_matrix_W.f90
├── mod_matrix_write.f90
├── mod_namelist.f90
├── mod_obs_sorting.f90
├── mod_obs_superobing.f90
├── mod_params.f90
├── mod_read_coor.f90
├── mod_read_data.f90
├── Readme.md
└── wjc_analysis

0 directories, 21 files
```
## DA_cycle.f90



## mod_analysis.f90



# build/apps 中的文件组成及其功能

## tree

```
$ tree
.
├── DA_cycle
├── data
│   └── README.txt
├── DA_time.txt
├── ensemble
│   ├── AHATmatrix.txt
│   ├── Amatrix.txt
│   ├── HAmatrix.txt
│   ├── Hmatrix.txt
│   ├── HXbmatrix.txt
│   └── Wmatrix.txt
├── input
│   ├── bg_data.txt
│   ├── DA_time.txt
│   ├── Index1D.txt
│   ├── obs_data.txt
│   ├── README.txt
│   ├── wjc_data.txt
│   └── wjcobs_data.txt
├── Makefile
└── output
    ├── analysis20080317.txt
    └── README.txt

4 directories, 19 files
```

## input/DA_time.txt

```
$ cat input/DA_time.txt 
2008 03 17 00 00 00
```