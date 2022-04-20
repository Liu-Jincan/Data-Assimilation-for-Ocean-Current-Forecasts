program DA_cycle
   use mod_params, only: step
   use mod_analysis
   use mod_matrix_A

   implicit none
   integer :: yyyy, mm, dd, hh, ff, ss, time(6)

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

   write (*, *) '├──「FAQ」怎么生成Index1D.txt文件？'
   write (*, *) '├──「FAQ」这是一个时间点的同化，多个时间点？'
   write (*, *) '├──「FAQ」不同浮标的观测值并不都能同步观测到，怎么处理无法观测到时间点？'
   write (*, *) '          观测算子的维度需要变化？'

   stop
end program DA_cycle
