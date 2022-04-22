#include <fintrf.h>
! #include <mat.h>
program DA_cycle
   use mod_params, only: step
   use mod_analysis
   use mod_matrix_A
   

   implicit none
   integer :: yyyy, mm, dd, hh, ff, ss, time(6), mp
   
   ! #include 'fintrf.h'
   ! #include 'mat.h'
   ! include 'mat.h' 
   ! include 'fintrf.h'
   ! 位于安装matlab位置，/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/extern/include/mat.h
   ! mwPointer matOpen
   mwPointer matOpen, matGetDir, matGetNextVariable

   write (*, *) 'DA_cycle.f90'
   write (*, *) '├──「函数」A_matrix()'
   
   if (step) call A_matrix()     ! A matrix: run only 1 time before DA cycles

   
   write (*, *) '├──「读取文件」input/DA_time.txt'
   open (unit=11, file='input/DA_time.txt')
   read (11, *) yyyy, mm, dd, hh, ff, ss
   close (11)

   time = (/yyyy, mm, dd, hh, ff, ss/)

   write (*, *) '├──「函数」analysis(time)'
   call analysis(time)

   write (*, *) '├──「FAQ」怎么生成Index1D.txt文件？sort_obs(M2, time)'
   write (*, *) '├──「FAQ」Fortran读取.mat文件，官方方法,看matdemo1.F文件,其实用的是c进行读取，' ! https://ww2.mathworks.cn/help/matlab/Fortran-applications-to-read-mat-file-data.html
   write (*, *) '   「error」无matopen函数，需在编译时导入matlab的include库，include mat.h,or, fintrf.h,'
   write (*, *) '   「error」include ".h" 失败,非法预处理指令，Warning: Illegal preprocessor directive,'
   write (*, *) '            -cpp+https://www.it1352.com/775977.html 解决了我的问题，注意-cpp放的位置讲究，'
   write (*, *) '            fortran和c混合编程？'
   write (*, *) '            查看mat.h文件?，' 
   !                      ! 链接导入MAT文件的Fortran代码时出错 ,https://www.it1352.com/775977.html
   write (*, *) '   「error」Error: Function ‘matopen800’ at (1) has no IMPLICIT type,'
   write (*, *) '            需要变量定义，mwPointer matOpen, matGetDir, matGetNextVariable,'
   write (*, *) '   「error 失败」libstdc++.so.6: error adding symbols: bad value,'
   mp = matopen('','r')
   ! if (mp .eq. 0) then
   !    write(*,*) '          Can''t open ''matdemo.mat''.'
   !    stop
   ! end if
   write (*, *) '├──「FAQ」温盐是每天同化一次？波高是每小时同化一次？'
   write (*, *) '├──「FAQ」这是一个时间点的同化，多个时间点？' ! Error: Function ‘matopen’ at (1) has no IMPLICIT type
   write (*, *) '├──「FAQ」不同浮标的观测值并不都能同步观测到，怎么处理无法观测到时间点？'
   write (*, *) '          观测算子的维度需要变化？'

   stop
end program DA_cycle
