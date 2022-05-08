Build = /1t/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/#../build 不能用相对路径# 当前路径为 makefile 所在路径, 一般不改变
OBJ_dir = /1t/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/objs3/##
APP_dir = /1t/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/apps3/## 一般不改变，
MOD_dir = 0
SRC_dir = /1t/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/src_NoWW3_ENOI/#
EXEC = DA_cycle_NoWW3_ENOI#生成的可执行文件的名称，
RUN = DA_cycle_NoWW3_ENOI#所需跑的项目文件的名称，不包含.f90的扩展名

all : comp link trans clean apps_makefile # depend 

# Portland Group Compiler
#FC = pgf90
#FFLAGS = -g -C

# GNU Compiler
#FC = gfortran
#FFLAGS = -g -C -mcmodel=medium -fbackslash -fconvert=big-endian
#FFLAGS = -g -C

# Intel Compiler
FC = gfortran
#FFLAGS = -g -C -shared-intel -convert big_endian -I${NFDIR}/include -L${NFDIR}/lib -lnetcdff
#FFLAGS = -g -C -O3 -mcmodel=medium -convert big_endian -I${NCDF_INC} -L${NCDF_LIB} -lnetcdf -lnetcdff
#FFLAGS = -g -C -O3 -L/usr/lib/x86_64-linux-gnu -L/usr/lib/x86_64-linux-gnu/hdf5/serial -lnetcdf -lnetcdff -I /usr/include
#FFLAGS = -g -C -O3
gdb_debug = -g
netcdf = -I/usr/include  -L/usr/lib/x86_64-linux-gnu -lnetcdff
Matlab_mat_h = -I/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/extern/include -L/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/glnxa64 -L/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/ -cpp 
Matlab_mat_h2 = -lmat -lmx -lmex -lm -Wl,-rpath /home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/bin/glnxa64
FFLAGS = $(gdb_debug) $(netcdf) #$(Matlab_mat_h) $(Matlab_mat_h2)
#FFLAGS = -g -C -convert big_endian
#FFLAGS = -g -check bounds -fpe0 -ftrapuv -debug semantic_stepping -debug variable_locations -fpp
#FFLAGS = -O3 -ipo -no-prec-div

#SOURCES = mod_params.f90 mod_date.f90  mod_namelist.f90 mod_matrix_read.f90 mod_matrix_write.f90 mod_matrix_H.f90 mod_matrix_R.f90 mod_matrix_inverse.f90 mod_matrix_W.f90 mod_analysis.f90 DA_cycle.f90

#runOBJS = mod_params.o mod_date.o  mod_namelist.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o DA_cycle.o

runOBJS = $(RUN).o 
comp: $(runOBJS)

# mod_obs_superobing.o: mod_params.o

# mod_obs_sorting.o: mod_params.o mod_obs_superobing.o

mod_nctime2date.o: 

mod_write_data.o: 

mod_matrix_read.o: mod_params.o 

mod_inIndex_flag.o: mod_params.o 

mod_read_data.o: mod_params.o

mod_write_data.o: mod_params.o

mod_matrix_A.o: mod_read_coor.o mod_read_data.o mod_matrix_write.o 

mod_namelist.o: mod_params.o 

# mod_read_coor.o: mod_params.o  

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

# mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

# mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_W.o mod_matrix_A.o  # mod_obs_sorting.o

DA_cycle_NoWW3_ENOI.o: mod_params.o mod_analysis.o mod_read_coor.o mod_inIndex_flag.o mod_nctime2date.o mod_read_data.o mod_write_data.o

%.o:%.f90
	$(FC) $(Matlab_mat_h) -c  $(FFLAGS) $<


link:*.o
	@echo "编译完成"
	@#$(FC) $(FFLAGS) $(runOBJS) -o run
	$(FC) *.o $(Matlab_mat_h) -o $(EXEC) $(FFLAGS) $(Matlab_mat_h2)
	@echo "链接完成"

clean:
	@#rm  ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
	rm -f *.mod *.o $(EXEC) *.d
	@echo "清理完毕" 

trans:
	@-mkdir -p $(OBJ_dir) $(MOD_dir) $(APP_dir)  #在 mkdir 命令前加一个减号，可以避免文件夹已生成而报错。
	@-mv -f *.o $(OBJ_dir)						#在 mv 命令前加一个减号，可以避免无文件而报错。
	@-mv -f *.mod $(MOD_dir)
	@-mv -f $(EXEC) $(APP_dir)/
	@#-cp -f * $(APP_dir)/						# 为了在$(APP_dir)调试(废弃了)
	@#-cp -f $(OBJ_dir)/* $(APP_dir)/				# 为了在$(APP_dir)调试（废弃了）
	@echo "「目标文件转移到了$(OBJ_dir) ，可执行文件转移到了$(APP_dir)，MOD文件转移到了$(MOD_dir)」"

apps_makefile:
	-rm -f $(APP_dir)/Makefile && touch -f $(APP_dir)/Makefile 
	@-echo "all: clean run #gdb-debug" >> $(APP_dir)/Makefile
	@-echo "clean:" >> $(APP_dir)/Makefile 
	@-echo "	rm -f data/namelist.txt ensemble/coordinate.dta ensemble/ensemble_mean_tmp.dta ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*" >> $(APP_dir)/Makefile
	@-echo "	rm -f ensemble/Amatrix.txt" >> $(APP_dir)/Makefile  
	@-echo "run:" >> $(APP_dir)/Makefile  
	@-echo "	./$(EXEC)" >> $(APP_dir)/Makefile 
	@-echo ".PHONY: clean run" >> $(APP_dir)/Makefile

	@-echo "gdb-debug-launch:" >> $(APP_dir)/Makefile
	@-echo "		{" >> $(APP_dir)/Makefile
	@-echo '			"type": "cppdbg",' >> $(APP_dir)/Makefile
	@-echo '			"request": "launch",' >> $(APP_dir)/Makefile
	@-echo '			"name": "$(EXEC)",' >> $(APP_dir)/Makefile
	@-echo '			"program": "$(APP_dir)/DA_cycle",' >> $(APP_dir)/Makefile
	@-echo '			"args": [' >> $(APP_dir)/Makefile
	@-echo '				"$(OBJ_dir)/*.o"' >> $(APP_dir)/Makefile
	@-echo '				"$(SRC_dir)/*.f90"' >> $(APP_dir)/Makefile
	@-echo '			],' >> $(APP_dir)/Makefile
	@-echo '			"cwd": "$(APP_dir)/"' >> $(APP_dir)/Makefile
	@-echo "		}," >> $(APP_dir)/Makefile

	@-echo "debug-gdb:" >> $(APP_dir)/Makefile
	@-echo "	@make clean" >> $(APP_dir)/Makefile
	@-echo "	@cd $(SRC_dir) && make" >> $(APP_dir)/Makefile  # 为了方便调试
	@-echo "	# 在选择对应的调试项目，F5" >> $(APP_dir)/Makefile
	@echo "「已为apps生成makefile」"



.PHONY: clean trans 
# depend:
# 	sfmakedepend $(SOURCES)

# DO NOT DELETE THIS LINE - used by make depend

mod_namelist.o: mod_params.o 

mod_read_coor.o: mod_params.o  

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_W.o

DA_cycle.o: mod_params.o mod_analysis.o
