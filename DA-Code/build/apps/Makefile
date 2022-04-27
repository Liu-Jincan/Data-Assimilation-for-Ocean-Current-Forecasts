all: clean run #gdb-debug
clean:
	rm -f data/namelist.txt ensemble/coordinate.dta ensemble/ensemble_mean_tmp.dta ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
	rm -f ensemble/Amatrix.txt
run:
	./DA_cycle_NoWW3
.PHONY: clean run
gdb-debug-launch:
		{
			"type": "cppdbg",
			"request": "launch",
			"name": "DA_cycle_NoWW3",
			"program": "/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/apps/DA_cycle",
			"args": [
				"/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/objs/*.o"
				"/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/../src/*.f90"
			],
			"cwd": "/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/apps/"
		},
debug-gdb:
	@make clean
	@cd /home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/../src && make
	# 在选择对应的调试项目，F5
