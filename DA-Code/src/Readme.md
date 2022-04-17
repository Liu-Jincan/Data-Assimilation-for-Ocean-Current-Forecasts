# wjc 老师创建的文件：myrecomand （已删除）
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

# 编译, src, makefile,
参考 Data-Assimilation-Code/src2/Makefile 进行修改，OK, 生成 DA-Code/build/apps/DA_cycle 可执行文件

# 运行 DA-Code/build/apps/DA_cycle 可执行文件
## error:
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
## 格式化文档
```
fprettify -i 4 -r  /home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/src
```
ok




