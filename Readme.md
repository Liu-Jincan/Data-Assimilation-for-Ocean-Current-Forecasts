# 主要内容

This project constructs an EnOI (Ensemble Optimal Interpolation) data assimilation model for ocean current forecasts. 

The model 
* constructs the background file from the restart files; 
* reads in observation;
* calculates W matrix for generating an analysis file;
* updates the restart files with the newly generated analysis file.

Next, NEMO restarts with the updated restart files, and another cycle of data assimilation begins...

# 本分支目标
在v0.1.0的基础上，使用fpm对项目进行管理，并对项目的文件进行具体分析；
> `fpm`的内容看`FAQ：寻找关于fortran的项目管理方法`博客，
>
> 所有命令应在`Msys MinGW64`的bash(for windows,`Win10+VScode+Msys2+Mingw64+GFortran+Git`博客),或者`conda fpm`环境(for linux, `ubuntu+VScode+conda+GFortran+Git`博客)中运行。
>

## FAQ：fpm使用VScode中fortran-language-server(fortls)？
问题，app文件夹program函数跳转到src中的mod？ 
已经解决（Win10+VScode+Msys2+Mingw64+GFortran+Git博客），

# Data-Assimilation-Code文件夹
## makefile
我用的是 GNU 编译器，故需更改`FC`和`FFLAGS`,
```
# Portland Group Compiler
#FC = pgf90
#FFLAGS = -g -C

# GNU Compiler
FC = gfortran
#FFLAGS = -g -C -mcmodel=medium -fbackslash -fconvert=big-endian
FFLAGS = -g -C

# Intel Compiler
##FC = ifort
#FFLAGS = -g -C -shared-intel -convert big_endian -I${NFDIR}/include -L${NFDIR}/lib -lnetcdff
#FFLAGS = -g -C -O3 -mcmodel=medium -convert big_endian -I${NCDF_INC} -L${NCDF_LIB} -lnetcdf -lnetcdff
##FFLAGS = -g -C -O3 -xHost -ipo -no-prec-div -mcmodel=medium -convert big_endian -lnetcdf -lnetcdff
#FFLAGS = -g -C
#FFLAGS = -g -C -convert big_endian
#FFLAGS = -g -check bounds -fpe0 -ftrapuv -debug semantic_stepping -debug variable_locations -fpp
#FFLAGS = -O3 -ipo -no-prec-div
```
命令`make clean`，加上`-f`，
```
clean:
	rm -f *.mod *.o run /home/chako/Argo/bias_nay/Index* /home/chako/Argo/bias_nay/bin* ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* DA_time.txt input/*
```
命令`make run`，


# Data-Assimilation-fpm文件夹
## FAQ：Unable to find source for module dependency: "netcdf" used by "././src/mod_read_data.f90"
