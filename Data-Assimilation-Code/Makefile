# Portland Group Compiler
#FC = pgf90
#FFLAGS = -g -C

# GNU Compiler
FC = gfortran

FFLAGS = -g -I/usr/include  -L/usr/lib/x86_64-linux-gnu -lnetcdff
#----- FFLAGS，gfortran编译器常用的参数，https://zhuanlan.zhihu.com/p/388598857
#
#----- FFLAGS，实际操作
#		FFLAGS = -g -C -mcmodel=medium -fbackslash -fconvert=big-endian 
#		FFLAGS = -g -I/usr/include -I/home/jincanliu/桌面  #可以多个include
#		-I 表示 include，一般是为了解决编译时的路径问题，在《视频：fcode实用编程基础篇》博客第三方库的引用，介绍了一个例子，
#
#----- FAQ：在链接时，FFLAGS需要放到 -o 的后面？为什么

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





################################################################################################
################################################################################################
#-----                                        编译（编译器）                                         -----#
################################################################################################
################################################################################################
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
#----- makefile编译常见错误及原因分析：https://liu-jincan.github.io/2022/03/31/yan-jiu-sheng-justtry-function/bian-yi-qi-bian-ji-qi-ji-cheng-kai-fa-huan-jing/make-02-makefile-bian-yi-linux-c-he-c-xiang-mu-kuai-su-ru-men/#toc-heading-17
#		找不到头文件，预处理会出错；有语法错误，编译时会出错；
#
#----- make后，会生成.o目标文件，和.mod模块文件
#
#----- error: netcdf module 外部依赖库～，头文件
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
#----- error: mat_name*name_length
# $ make
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_date.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_params.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_namelist.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_read_coor.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_read_data.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_read.f90
# mod_matrix_read.f90:9:42:
#     9 |         character, intent(in) :: mat_name*name_length
#       |                                          1
# Error: Syntax error in character length specification at (1)
#
# 暂时的解决方法：character, intent(in) :: mat_name !mat_name*name_length
#
#----- error: mat_name*name_length
# $ make
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_read.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_write.f90
# mod_matrix_write.f90:10:42:
#    10 |         character, intent(in) :: mat_name*name_length
#       |                                          1
# Error: Syntax error in character length specification at (1)
#
# 暂时的解决方法：character, intent(in) :: mat_name !mat_name*name_length
#
#----- error: .eqv. 问题
# $ make
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_write.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_obs_superobing.f90
# mod_obs_superobing.f90:213:16:
#   213 |             if (isnan(x(i)) .eq. .false.) then
#       |                1
# Error: Logicals at (1) must be compared with .eqv. instead of .eq.
#
# fortran中.eq.和.eqv.有什么区别？https://zhidao.baidu.com/question/142269105.html
# 		不一样的，eq为关系运算符，意为相等，与ne对应，
#		而eqv为与and，or一样为逻辑运算符，意为1 .eqv. 1 和 0 .eqv. 0返回都为真，1 .eqv. 0返回假，
# 
# 解决方法，if (isnan(x(i)) .eqv. .false.) then 
#
#----- error: .eqv. 问题
# $ make
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_date.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_params.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_namelist.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_read_coor.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_read_data.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_read.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_write.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_obs_superobing.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_obs_sorting.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_A.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_H.f90
# gfortran -c -g -I/usr/include -I/home/jincanliu/桌面 mod_matrix_L.f90
# mod_matrix_L.f90:107:30:
#   107 |         elseif (loc_Lh .and. (loc_Lv == .false.)) then
#       |                              1
# Error: Logicals at (1) must be compared with .eqv. instead of ==
#
# 解决方法，==换成.eqv.，(loc_Lh .eqv. .false.) .and. loc_Lv
#



################################################################################################
################################################################################################
#-----                                        运行(链接器)                                         -----#
################################################################################################
################################################################################################
run:$(runOBJS)
	@echo "编译完成"
	@#$(FC) $(FFLAGS) $(runOBJS) -o run  #这个为什么会失败，为什么把$(FFLAGS)放到-o后面才可以？
	@#$(FC) $(runOBJS) -o run $(FFLAGS) 
	$(FC) DA_cycle.o mod_date.o mod_params.o  mod_namelist.o mod_read_coor.o mod_read_data.o mod_matrix_read.o mod_matrix_write.o mod_obs_superobing.o mod_obs_sorting.o mod_matrix_A.o mod_matrix_H.o mod_matrix_L.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o -o 	run $(FFLAGS) 
	@echo "链接完成"
#
#----- 链接常见错误：https://liu-jincan.github.io/2022/03/31/yan-jiu-sheng-justtry-function/bian-yi-qi-bian-ji-qi-ji-cheng-kai-fa-huan-jing/make-02-makefile-bian-yi-linux-c-he-c-xiang-mu-kuai-su-ru-men/#toc-heading-17
#		找不到定义，动态库引用版本出错，链接会出错
#
#----- error: netcdf，undefined reference 问题
# $ make
# gfortran -g -I/usr/include -I/home/jincanliu/桌面 mod_date.o mod_params.o  mod_namelist.o mod_read_coor.o mod_read_data.o mod_matrix_read.o mod_matrix_write.o mod_obs_superobing.o mod_obs_sorting.o mod_matrix_A.o mod_matrix_H.o mod_matrix_L.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o DA_cycle.o -o run 
# /usr/bin/ld: mod_read_coor.o: in function `__mod_read_coor_MOD_check':
# /home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/Data-Assimilation-Code/mod_read_coor.f90:48: undefined reference to `__netcdf_MOD_nf90_strerror'
#
# https://blog.csdn.net/xylyounj/article/details/123913724
# 		确保 libnetcdff被链接，
#			查询netcdf，得到libnetcdff在/usr/lib/x86_64-linux-gnu,
#			如何链接可以看我的博客《视频：fcode实用编程基础篇+应用篇》第三方库使用，-L /usr/lib/x86_64-linux-gnu -llibnetcdff
#		确保各库链接顺序适当，
#
# https://blog.csdn.net/weixin_32475629/article/details/118908800（可行）
# ubuntu上编译fortran,在Ubuntu上编译Fortran netCDF程序,
#		/usr/lib/libnetcdf.a  (我没有这个文件？？)
#		/usr/lib/libnetcdff.a
#		/usr/include/netcdf.mod
#		f95 -o xy -I/usr/include/ -L/usr/lib/ -lnetcdff -lnetcdf simple_xy_wr.f90
#		simple_xy_wr.f90:(.text+0x72): undefined reference to `__netcdf_MOD_nf90_strerror' ...
#		f95 -o xy -I/usr/include/ simple_xy_wr.f90 -lnetcdff -lnetcdf
#
# 解决方法：FFLAGS = -g -I/usr/include  -L/usr/lib/x86_64-linux-gnu -lnetcdff，
#			$(FC) $(runOBJS) -o run $(FFLAGS) ,






################################################################################################
################################################################################################
#-----                                        清理                                         -----#
################################################################################################
################################################################################################
clean:
	@#rm -f *.mod *.o run /home/chako/Argo/bias_nay/Index* /home/chako/Argo/bias_nay/bin* ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* DA_time.txt input/*
	rm -f *.mod *.o run
.PHONY: clean



################################################################################################
################################################################################################
#-----                                        依赖(貌似没什么用)                                  
################################################################################################
################################################################################################
depend:
	sfmakedepend $(SOURCES)
# DO NOT DELETE THIS LINE - used by make depend
# mod_namelist.o: mod_params.o 

# mod_read_coor.o: mod_params.o  

# mod_read_data.o: mod_params.o 

# mod_obs_superobing.o: mod_params.o

# mod_obs_sorting.o: mod_params.o mod_obs_superobing.o

# mod_matrix_A.o: mod_params.o mod_namelist.o mod_read_coor.o mod_read_data.o mod_matrix_read.o mod_matrix_write.o

# mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

# mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

# mod_matrix_R.o: mod_params.o mod_matrix_write.o

# mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_L.o mod_matrix_R.o mod_matrix_inverse.o

# mod_analysis.o: mod_params.o mod_date.o mod_matrix_A.o mod_read_data.o mod_matrix_read.o mod_obs_sorting.o mod_matrix_W.o

# DA_cycle.o: mod_params.o mod_matrix_A.o mod_analysis.o
