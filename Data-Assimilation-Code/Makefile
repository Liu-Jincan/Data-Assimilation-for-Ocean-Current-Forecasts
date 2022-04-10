# Portland Group Compiler
#FC = pgf90
#FFLAGS = -g -C

# GNU Compiler
FC = gfortran
#FFLAGS = -g -C -mcmodel=medium -fbackslash -fconvert=big-endian
FFLAGS = -g -I/usr/include -I/home/jincanliu/桌面

# Intel Compiler
#FC = ifort
#FFLAGS = -g -C -shared-intel -convert big_endian -I${NFDIR}/include -L${NFDIR}/lib -lnetcdff
#FFLAGS = -g -C -O3 -mcmodel=medium -convert big_endian -I${NCDF_INC} -L${NCDF_LIB} -lnetcdf -lnetcdff
#FFLAGS = -g -C -O3 -xHost -ipo -no-prec-div -mcmodel=medium -convert big_endian -lnetcdf -lnetcdff
#FFLAGS = -g -C
#FFLAGS = -g -C -convert big_endian
#FFLAGS = -g -check bounds -fpe0 -ftrapuv -debug semantic_stepping -debug variable_locations -fpp
#FFLAGS = -O3 -ipo -no-prec-div



SOURCES = mod_params.f90 mod_date.f90 mod_namelist.f90 mod_read_coor.f90 mod_read_data.f90 mod_matrix_read.f90 mod_matrix_write.f90 mod_obs_superobing.f90 mod_obs_sorting.f90 mod_matrix_A.f90 mod_matrix_H.f90 mod_matrix_L.f90 mod_matrix_R.f90 mod_matrix_inverse.f90 mod_matrix_W.f90 mod_analysis.f90 DA_cycle.f90

runOBJS = mod_date.o mod_params.o  mod_namelist.o mod_read_coor.o mod_read_data.o mod_matrix_read.o mod_matrix_write.o mod_obs_superobing.o mod_obs_sorting.o mod_matrix_A.o mod_matrix_H.o mod_matrix_L.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o DA_cycle.o

#
#-----                                        编译                                         -----#
#
#----- Makefile的静态模式%.o : %.c，https://blog.csdn.net/u012351051/article/details/88600562 
#
%.o:%.f90  
	$(FC) -c $(FFLAGS) $<
#
#----- 编译的顺序在 $(runOBJS)调整, 可通过命令make进行验证；
#
#----- makefile编译常见错误及原因分析，https://blog.csdn.net/Bgm_Nilbb/article/details/122996596，
#      错误原因：makefile里面的文件依赖关系有问题，导致头文件找不到。（不一定是头文件找不到，但基本跟依赖关系有关）
#
#----- make后，会生成.o目标文件，和.mod模块文件
#
#----- error: netcdf module 外部依赖库～
# $ make
# gfortran -c -g mod_date.f90
# gfortran -c -g mod_params.f90
# gfortran -c -g mod_namelist.f90
# gfortran -c -g mod_read_coor.f90
# mod_read_coor.f90:2:8:
#     2 |     use netcdf
#       |        1
# Fatal Error: Cannot open module file ‘netcdf.mod’ for reading at (1): 没有那个文件或目录
#
# NetCDF Fortran 90 Interface Guide，https://cluster.earlham.edu/bccd-ng/testing/mobeen/GALAXSEEHPC/netcdf-4.1.3/man4/netcdf-f90.html
#
# github上的issue，How to resolve ''Fatal Error: Can't open module file ‘netcdf.mod’ for reading....."	
# 		Unidata /netcdf-fortran，https://github.com/Unidata/netcdf-fortran/issues/205，
#		situation, conda install -c conda-forge netcdf-fortran
#				check the directory of ‘netcdf.mod’, which locates in ''/Users/Jim/anaconda3/include".				
# 		solution 1,  FFLAGS="-I/Users/Jim/anaconda3/include
#		solution 2,	 sudo apt-get install netcdf-bin
#
#
# 我电脑中netcdf.mod文件位置在哪里？
# 		可以通过ubuntu自带的文件夹搜索到，/usr/include
#  
# 解决方法，FFLAGS = -g -I/usr/include
#		FFLAGS = -g -I/usr/include -I/home/jincanliu/桌面，
# 
# netcdf.mod文件怎么生成的？
#		猜测是在./w3_make的过程中实现的，https://liu-jincan.github.io/2021/12/25/yan-jiu-sheng-justtry-function/wavewatch3/01-ww3-v6.07.1-xia-zai.w3-make/#toc-heading-3
#
# 问题，虽然可以使用netcdf.mod，但是fortls语言服务器无法跳转到netcdf module？
#		是因为netcdf module不在我的项目文件夹下？

#
#-----                                        运行                                         -----#
run:$(runOBJS)
	$(FC) $(FFLAGS) $(runOBJS) -o run 

#
#-----                                        清理                                         -----#
clean:
	rm -f *.mod *.o run /home/chako/Argo/bias_nay/Index* /home/chako/Argo/bias_nay/bin* ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* DA_time.txt input/*

depend:
	sfmakedepend $(SOURCES)

# DO NOT DELETE THIS LINE - used by make depend
mod_namelist.o: mod_params.o 

mod_read_coor.o: mod_params.o  

mod_read_data.o: mod_params.o 

mod_obs_superobing.o: mod_params.o

mod_obs_sorting.o: mod_params.o mod_obs_superobing.o

mod_matrix_A.o: mod_params.o mod_namelist.o mod_read_coor.o mod_read_data.o mod_matrix_read.o mod_matrix_write.o

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_L.o mod_matrix_R.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_A.o mod_read_data.o mod_matrix_read.o mod_obs_sorting.o mod_matrix_W.o

DA_cycle.o: mod_params.o mod_matrix_A.o mod_analysis.o
