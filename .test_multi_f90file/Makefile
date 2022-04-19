FC = gfortran
FFLAGS = -g
runOBJS =  mod_parms.o main.o 

all: clean run 

%.o:%.f90
	$(FC) -c $(FFLAGS) $<

# $(runOBJS) 中.o文件顺序反过来会错误，说明，越是底层的.o文件，越是在前面；
# main.exe
run:$(runOBJS)  
	$(FC) $(FFLAGS) $(runOBJS) -o main 

clean:
	rm -f *.o *.exe *.mod main