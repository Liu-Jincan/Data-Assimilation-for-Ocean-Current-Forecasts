all: clean run #gdb-debug
clean:
	rm -f ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*
run:
	./DA_cycle
.PHONY: clean run
gdb-debug-launch:
		{
			"type": "cppdbg",
			"request": "launch",
			"name": "DA_cycle",
			"program": "/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/apps/DA_cycle",
			"args": [
				"/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/objs/*.o"
				"/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/../src/*.f90"
			],
			"cwd": "/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/DA-Code/build/apps/"
		},
debug-gdb:
	@make clean
	# 在选择对应的调试项目，F5
