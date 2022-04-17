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
FFLAGS = -g -C -O3
#FFLAGS = -g -C -convert big_endian
#FFLAGS = -g -check bounds -fpe0 -ftrapuv -debug semantic_stepping -debug variable_locations -fpp
#FFLAGS = -O3 -ipo -no-prec-div

%.o:%.f90
	$(FC) -c $(FFLAGS) $<

SOURCES = mod_params.f90 mod_date.f90  mod_namelist.f90 mod_matrix_read.f90 mod_matrix_write.f90 mod_matrix_H.f90 mod_matrix_R.f90 mod_matrix_inverse.f90 mod_matrix_W.f90 mod_analysis.f90 DA_cycle.f90

runOBJS = mod_params.o mod_date.o  mod_namelist.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o mod_matrix_W.o mod_analysis.o DA_cycle.o

run:$(runOBJS)
	$(FC) $(FFLAGS) $(runOBJS) -o run

clean:
	rm  ensemble/R* ensemble/W* ensemble/H* ensemble/L* ensemble/AH* output/ana*

depend:
	sfmakedepend $(SOURCES)

# DO NOT DELETE THIS LINE - used by make depend

mod_namelist.o: mod_params.o 

mod_read_coor.o: mod_params.o  

mod_matrix_H.o: mod_params.o mod_matrix_read.o mod_matrix_write.o

mod_matrix_L.o: mod_params.o mod_matrix_write.o mod_matrix_read.o

mod_matrix_R.o: mod_params.o mod_matrix_write.o

mod_matrix_W.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_write.o mod_matrix_H.o mod_matrix_R.o mod_matrix_inverse.o

mod_analysis.o: mod_params.o mod_date.o mod_matrix_read.o mod_matrix_W.o

DA_cycle.o: mod_params.o mod_analysis.o

