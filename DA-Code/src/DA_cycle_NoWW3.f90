! #include <fintrf.h>
! #include <mat.h>
program DA_cycle
   use mod_params, only: step, nc_fileNameTxt, nc_fileNameNum, nc_pth, nc_AttTimeName, ndbc_pth, programs
   use mod_analysis
   use mod_matrix_A
   use netcdf
   use mod_read_coor, only: checknc  ! checknc和check是一样的程序
   use mod_inIndex_flag, only: inIndex_flag,inIndex_flag2
   use mod_nctime2date , only: nctime_day2date

   implicit none
   integer :: yyyy, mm, dd, hh, ff, ss, time(6)
   integer :: FID1 = 110, i, ncid, tmp_varid
   character(255) :: nc_fileName
   integer :: xtype, ndims, dimids, natts, leng, j, flag, ii
   character*10 :: vname
   character*15 :: dimname
   character*256 :: str, blank, blank2
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
   blank = '----step.'
   !!
   str = trim(blank)//'1.「函数」 A_matrix()，为了后面形成背景误差斜方差矩阵B'
   write (*, *) str
   if (step) then
      ! call A_matrix()     ! A matrix: run only 1 time before DA cycles
      ! step = .false.
   end if

   !!
   str = trim(blank)//'2. 在..apps/$(program)/下创建ndbc/$(program)/nc文件夹的软链接，'//&
      &'该文件夹包括：所有背景场nc文件，包含所有nc文件名称的txt文件（已按顺序）。'
   write (*, *) str
   call system('ln -snf '//ndbc_pth//programs//'/nc '//programs//'/nc')
   ! write (*,*) 'ln -snf '//ndbc_pth//programs//'/nc '//programs//'/nc'
   !
   open (unit=FID1, file=nc_fileNameTxt)
   do i = 1, nc_fileNameNum
      !!
      str = trim(blank)//'3. 对于每个nc文件，在..apps/$(program)/下创建ndbc/$(program)/下'//&
         & '所需文件的的软链接，包括：匹配的观测数据yo文件夹，匹配的Index1文件夹。'
      if (i .eq. 1) write (*, *) str
      read (FID1, '(a)') nc_fileName
      str = '--------例如'//nc_pth//trim(nc_fileName)
      if (i .eq. 1) write (*, *) str
      ii = index(nc_fileName,'.') ! . 在字符串的位置，
      str = programs//'/'//nc_fileName(1:ii-1)//'_nc_Index1 '
      call system('ln -snf '//ndbc_pth//str //str)
      ! write (*,*) 'ln -snf '//ndbc_pth//str //str
      str = programs//'/'//nc_fileName(1:ii-1)//'_nc_yo '
      call system('ln -snf '//ndbc_pth//str //str)

      !!
      str = trim(blank)//'4. 对于每个nc文件，读取time长度，存储在leng，'
      if (i .eq. 1) write (*, *) str

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



      do j = 1, 4 !leng
         !! 每一个时间步都需要确定days since 1990-01-01 00:00:00
         yyyy = 1990; mm = 1; dd = 1; hh = 0; ff = 0; ss = 0;
         !!
         str = trim(blank)//'5. 对于每个nc文件的每个时间节点，'//&
            &'根据matlab给出的需要同化的时间索引数据Index.txt，判断是否同化.（不用这个方法）'
         if ((i .eq. 1) .AND. (j .eq. 1)) write (*, *) str
         ! call inIndex_flag(blank2, j, nc_fileName, flag)
         !!
         str = trim(blank)//'5. 对于每个nc文件的每个时间节点，'//&
            &'根据每个时间节点对应的nc_time的数字，'//& !! 例如7912.833，
            &'结合初始日期，算出目前日期。'//& !!例如days since 1990-01-01 00:00:00，
            &'从算出的日期，根据每个nc文件的Index1或yo文件夹下的文件，判断是否同化.'
         if ((i .eq. 1) .AND. (j .eq. 1)) write (*, *) str
         blank2 = '----'//trim(blank)//'5.'
         call nctime_day2date(blank2,i,j,nc_time(j),&
            &yyyy, mm, dd, hh, ff, ss)
         ! write (*,*) yyyy,mm,dd,hh,ff,ss
         call inIndex_flag2(blank2,i,j,nc_fileName,yyyy, mm, dd, hh, ff, ss,flag)
         !!
         str = trim(blank)//'6. 如果需要同化，需传递背景场数据xb和time给analysis()，得到xa.'
         if ((i .eq. 1) .AND. (j .eq. 1)) write (*, *) str
         if (flag .eq. 1) then
            call analysis()
         endif
         !!
         str = trim(blank)//'7. 如果不需要同化，背景场数据直接作为xa.'
         if ((i .eq. 1) .AND. (j .eq. 1)) write (*, *) str  
         if (flag .eq. 0) then
         endif
         !!
         str = trim(blank)//'8. 对于每个nc文件，生成新的nc文件，'
         if ((i .eq. 1) .AND. (j .eq. 1)) write (*, *) str  

      end do
      !!
      deallocate(nc_time)
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
   !!
   write (*, *) '├──「FAQ」Fortran中的字符串函数,'
   ! Fortran中的字符串函数,https://wap.sciencenet.cn/home.php?mod=space&uid=456367&do=blog&quickforward=1&id=426706
   ! Fortran中的内置函数，https://blog.csdn.net/Leo_csdn_/article/details/83339776
   stop
   !!
   write (*, *) '├──「FAQ」读取数组,'
   ! Fortran读取txt两列数据分别定义为两个数组, https://zhidao.baidu.com/question/2054017625565749507.html
   !!
   write (*, *) '├──「FAQ」一行太长怎么办,'
   ! fortran 字符串太长 如何换行, https://zhidao.baidu.com/question/180559642.html
   !!
   write (*, *) '├──「FAQ」逻辑运算,'
   ! Fortran 逻辑运算 与 循环（DO）相关, https://blog.csdn.net/weixin_45492560/article/details/115102265
   !!
   write (*, *) '├──「FAQ」日期转换,'
   ! 用Fortran写的计算某一年几月几号是这一年的第几天，https://zhidao.baidu.com/question/429339313010184892.html
   ! 闰年的判断方法_Fortran 判断日期是此年的第几天, https://blog.csdn.net/weixin_39947351/article/details/111380448
   !!
   write (*, *) '├──「FAQ」DaysInYear多次调用出现的问题,'//&
      &'结论是，对于多次调用的函数，不建议初始化'
   ! 原因，DaysInYear的初始化只是在第一次打开才有，第二次打开后不会初始化了，恶心之处来了。
   !!
   write (*, *) '├──「FAQ，成功」在FORTRAN程序中使用shell命令,'
   ! 在FORTRAN程序中使用shell命令, https://wenku.baidu.com/view/0fde3c9dfe0a79563c1ec5da50e2524de518d015.html
   !!
   write (*, *) '├──「FAQ，成功」文件夹再次软链接,出现文件夹循环...，解决方法-snf'
   ! ln -sf 对目录，https://segmentfault.com/q/1010000006134627
   !!
   write (*, *) '├──「FAQ，成功」字符型与整型之间的转换'
   ! https://wenku.baidu.com/view/2995e2e14328915f804d2b160b4e767f5acf8082.html
   !!
   write (*, *) '├──「FAQ，成功」查询文件夹是否存在'
   ! https://blog.csdn.net/lixingwang0913/article/details/119697962
end program DA_cycle
