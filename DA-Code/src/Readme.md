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

* VScode有个断点面板～

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

# 在调试中debug过程中，生成DA_cycle的整体流程～
断点面板，

变量查看面板，

write (*, *)，

有及时反馈，不担心编辑的文件是另一个文件夹下的文件，F12跳转的坑点～

* 根本解决方法：在VScode中，F12不想跳转的文件夹，在文件夹前加上点～

nice～

```
DA_cycle.f90
 ├──「读取文件」input/DA_time.txt
 ├──「函数」analysis(time)
       ├── 「cpu_time」start
       ├── Preparing observational data...
       ├── 「函数」W_matrix(M, time)，Computing gain matrix...
              ├── 「函数」H_matrix(M), use 1D locations to compute H,HA,AHAT...
                     ├── 「读取文件」input/Index1D.txt, 
                                   Tindex1D,存储温度观测数据相对于背景场的位置，
                                   假如有5个观测,则Tindex1D=(10 15 20 22 30 36),
                                   其中10表示第一个观测最近的网格点的index为10,
                                   Index1D(M)的输出,         898        1035        1036        1173        1174
                     ├── 「函数」writematrix(H, M, N, “H”, 1),
                                输出H二维矩阵到文本文件, 
                                H大部分元素是0,稀疏,
                                H其他元素为1,为1的个数与观测数一致,
                                H的第一个维度是观测数量M,
                                H的第二个维度是总共的网格点数N,
                         「生成文件」ensemble/Hmatrix.txt,
                                Writing matrix H(           5 ,        4819 ),
                     ├── 「函数」readmatrix(A, N, NN, "A", 1),
                                读取文本文件的A二维矩阵,
                                A的第一个维度是总共的网格点数N,
                                A的第二个维度是集合的尺寸NN,
                         「读取文件」ensemble/Amatrix.txt,
                                Reading matrix A(        4819 ,          20 ),
                     ├── 「函数」writematrix(HA, M, NN, “HA”, 2),
                                输出H*A二维矩阵到文本文件,
                                HA的计算不应使用matmul,需考虑H的稀疏,
                                HA的第一个维度是观测数量M,
                                HA的第二个维度是集合的尺寸NN,
                         「生成文件」ensemble/HAmatrix.txt,
                                Writing matrix HA(           5 ,          20 ),
                     ├── 「函数」writematrix(AHAT, N, M, "AHAT", 4),
                                输出A*(HA)'二维矩阵到文本文件,
                                AHAT的计算使用matmul,
                                AHAT的第一个维度是总共的网格点数N,
                                AHAT的第二个维度是观测数量M,
                         「生成文件」ensemble/AHATmatrix.txt,
                                Writing matrix AHAT(        4819 ,           5 ),
                     ├── 「done」H_matrix(M), 
              ├── 「函数」readmatrix(HA, M, NN, "HA", 2),
                  「读取文件」ensemble/HAmatrix.txt,
                         Reading matrix HA(           5 ,          20 ),
              ├── 「变量」W0，为增益矩阵W中的H*B*(H)',
                         W=BH'(alpha*HBH'+(NN-1)*R)^(-1),
                         B=AA',这是ENOI与OI区别所在，
              ├── 「变量」R，为增益矩阵W中的R,
                         R是观测矩阵协防差矩阵，
              ├── 「变量」W0，进行更新，加上缩放因子和R，
                         FAQ：alpha，背景误差斜方差矩阵的缩放因子，
                         FAQ：观测误差斜方差矩阵R前需乘以（NN-1），
              ├── 「变量」W2，求逆矩阵，
              ├── 「函数」readmatrix(AHAT, N, M, "AHAT", 4),
                  「读取文件」ensemble/AHATmatrix.txt,
                         Reading matrix AHAT(        4819 ,           5 ),
              ├── 「函数」writematrix(W_wjc_ljc, N, M, "W", 1),
                  「生成文件」ensemble/Wmatrix.txt,
                         Writing matrix W(        4819 ,           5 ),
              ├── 「done」W_matrix(M, time)
       ├── Updating the background with observational data...
       ├── 「读取文件」input/obs_data.txt,
                     得到yo，其维度为M*1,
                     *** SUCCESS Sorted observation is read in!
       ├── 「读取文件」input/bg_data.txt,
                     得到Xb，其维度为N*1,
                      *** SUCCESS Sorted background is read in!
       ├── 「函数」readmatrix(H, M, N, “H”, 1),
           「读取文件」ensemble/Hmatrix.txt,
                     Reading matrix H(           5 ,        4819 ),
       ├── 「函数」writematrix(HXb, M, 1, "HXb", 3),
           「生成文件」ensemble/HXbmatrix.txt,
                     Writing matrix HXb(           5 ,           1 ),
       ├── 「变量」dX = W*(yo-HXb),其维度为N*1，
       ├── 「变量」Xa = Xb+dX，其维度为N*1，
                 *** SUCCESS Analysis is computed!
       ├── 「生成文件」output/analysis20080317.txt,
                 *** SUCCESS Analysis is saved!
       ├── 「cpu_time」finish
                        7.08189979E-02 seconds,
                        1.18031667E-03 minutes,
```

# input/Index1D.txt的生成

# ensemble/Amatrix.txt的生成

# input/obs_data.txt的生成

# input/bg_data.txt的生成

# FAQ：DA_cycle实现的是某一时刻同化，如何脚本自动实现多个时刻的同化？

# FAQ：此程序是对某一时刻的同化，为什么不能对某一段连续时间段进行同行？

# FAQ：mod_parms无用的都注释～