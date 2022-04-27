! #include <fintrf.h>
! #include <mat.h>
program DA_cycle
   use mod_params, only: step, nc_fileNameTxt, nc_fileNameNum, nc_pth, nc_AttTimeName
   use mod_analysis
   use mod_matrix_A
   use netcdf
   use mod_read_coor, only: checknc  ! checknc和check是一样的程序

   implicit none
   integer :: yyyy, mm, dd, hh, ff, ss, time(6)
   integer :: FID1=11, i, ncid, tmp_varid
   character(255) :: nc_fileName
   integer :: xtype, ndims, dimids, natts, leng, j 
   character*10 :: vname
   character*15 :: dimname
   ! integer, parameter :: DP = Selected_Real_Kind(r=10,p=10)
   ! real(kind=8), allocatable :: nc_time(:)
   real, allocatable :: nc_time(:)
   integer :: start, counts, stride
   include 'netcdf.inc'

   ! #include 'fintrf.h'
   ! #include 'mat.h'
   ! include 'mat.h' 
   ! include 'fintrf.h'
   ! 位于安装matlab位置，/home/jincanliu/BaiduNetdiskWorkspace/Program_SetupPosition/matlab/R2021b/extern/include/mat.h
   ! mwPointer matOpen
   ! mwPointer matOpen, matGetDir, matGetNextVariable

   write (*, *) 'DA_cycle.f90'
   !!  
   write (*, *) '├──step1.「函数」 A_matrix()，为了后面形成背景误差斜方差矩阵B'
   if (step) then
      call A_matrix()     ! A matrix: run only 1 time before DA cycles
      ! step = .false.
   endif

   !!
   write (*, *) '├──step2. 循环读取背景场的nc文件，'
   write (*, *) '          对于每个nc文件，读取time长度，存储在leng，'
   write (*, *) '          循环时间，根据时间判断是否需要同化，matlab给出需要同化时间的索引数据.'
   write (*, *) '          如果需要同化，需传递背景场数据xb和time给analysis().'
   write (*, *) '          如果不需要同化，背景场数据直接上传到netcdf.'
   open (unit=FID1, file=nc_fileNameTxt)
   do i = 1, nc_fileNameNum
      read (FID1,'(a)') nc_fileName
      write (*,*) nc_pth//trim(nc_fileName)
      call checknc(nf_open(nc_pth//trim(nc_fileName), nf90_nowrite, ncid))
      call checknc(nf_inq_varid(ncid, nc_AttTimeName, tmp_varid))
      call checknc(nf_inq_var(ncid, tmp_varid, vname, xtype, ndims, dimids, natts)) !获取变量信息
      ! print *, '                  vname=', vname !变量名
      ! print *, '                  xtype=', xtype !变量类型，4表示整型，5表示实型，6表示双精度
      ! print *, '                  ndims=', ndims !变量维数
      ! print *, '                  dimids=', dimids !每一维的ID
      ! print *, '                  natts=', natts !
      call checknc(nf_inq_dim(ncid, dimids, dimname, leng))
      ! print *, '                  name of dimids', dimids, 'is ', dimname, ' length=', leng
      !!!!!!clear xtype, ndims, dimids, natts, vname, dimname

      allocate (nc_time(leng))
      ! write(*,*) leng
      start = 1
      counts = leng
      stride = 1
      call checknc(nf_get_vars_real(ncid, tmp_varid, start, counts, stride, nc_time))
      ! Matlab读取的nc_time和这里读取的是一致的～～
      ! UTtime = datetime('1990-01-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss')+nc_time; % Malltb可以直接进行转换～～，故用matlab提供索引
      !!!!!!clear start, counts, stride
      
   end do
   close (FID1)
   stop
   !! 
   ! write (*, *) '├──「读取文件」input/DA_time.txt'
   ! open (unit=11, file='input/DA_time.txt')
   ! read (11, *) yyyy, mm, dd, hh, ff, ss
   ! close (11)
   ! time = (/yyyy, mm, dd, hh, ff, ss/)
   
   !!
   write (*, *) '├──「函数」analysis(time)'
   call analysis(time)
   !!
   write (*, *) '├──「FAQ」怎么生成Index1D.txt文件？sort_obs(M2, time？'
   write (*, *) '            在ndbc解决～～'
   !!
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
   ! mp = matopen('','r')
   ! if (mp .eq. 0) then
   !    write(*,*) '          Can''t open ''matdemo.mat''.'
   !    stop
   ! end if
   !!
   write (*, *) '├──「FAQ」温盐是每天同化一次？波高是每小时同化一次？'
   !!
   write (*, *) '├──「FAQ」这是一个时间点的同化，多个时间点？' ! Error: Function ‘matopen’ at (1) has no IMPLICIT type
   !!
   write (*, *) '├──「FAQ」不同浮标的观测值并不都能同步观测到，怎么处理无法观测到时间点？'
   write (*, *) '          观测算子的维度需要变化？'
   !!
   write (*, *) '├──「FAQ，成功解决」fortran 循环读出文本文件的每一行'
   ! read (FID1,'(a)') nc_fileName    ! fortran 循环读出文本文件的每一行, https://zhidao.baidu.com/question/527967791.html
   ! write (*,*) trim(nc_fileName)//'1'
   ! read (FID1,'(a)') nc_fileName
   ! write (*,*) trim(nc_fileName)//'1'

   stop
end program DA_cycle
