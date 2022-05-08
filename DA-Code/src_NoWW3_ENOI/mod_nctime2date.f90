module mod_nctime2date
   implicit none

contains
   subroutine nctime_day2date(blank, iiii,j, nc_time, year, month, day, hour, minute, second)
      implicit none
      !! in,out
      real :: nc_time
      integer, intent(inout) :: year, month, day, hour, minute, second
      !! temp,
      character*256 :: blank, str
      integer :: j, i, FID = 150, Num, iiii
      real :: Num_real
      integer, allocatable :: IndexVector(:) ! 列向量
      Integer :: DaysInMonth(12)

      !!
      ! write(*,*) nc_time
      !!
      str = trim(blank)//'1. 将初始的year-month-day-hour-minute-second转换成yyyy-01-01-00-00-00，'&
         &//'nc_time需补上对应的数值。需通过matlab进行正确性的检验，还需确定同化时刻'&
         &//'确实进行了同化的检验（输出同化失败时刻）。'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      if ( month/=1 .or. day/=1 .or. hour/=0 .or. minute/=0 .or. second/=0  ) then
         stop
      endif
      !!
      str = trim(blank)//'2. 年份的确定.可以通过matlab进行正确性的检验。'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      call DaysInYear(year,Num)
      ! write(*,*) year,Num
      do while (nc_time > Num)
         nc_time = nc_time-Num
         year = year+1
         call DaysInYear(year,Num)
         ! write(*,*) year,Num
      end do
      !!
      str = trim(blank)//'3. 月份的确定.'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      ! write(*,*) year,Num
      DaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      if ( ((MOD(year, 4) == 0) .and. (MOD(year, 100) /= 0)) .or. (mod(year, 400) == 0) ) then
         DaysInMonth(2) = 29
      endif
      Num = DaysInMonth(month);
      do while (nc_time > Num)
         nc_time = nc_time-Num
         month = month+1
         Num = DaysInMonth(month)
      end do
      !!
      str = trim(blank)//'4. 天数的确定.'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      Num = 1
      do while (nc_time > Num)
         nc_time = nc_time-Num
         day = day+1
         Num = 1
      end do
      !!
      str = trim(blank)//'5. 小时的确定.'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      Num_real = 1.0/24.0
      ! write (*,*) Num_real
      do while (nc_time > Num_real)
         nc_time = nc_time-Num_real
         hour = hour+1
         Num_real = 1.0/24.0
      end do
      if ( nc_time>1.0/48.0 ) hour = hour+1  !! bug
      !! 如果满足是24小时，天数进1,小时归为0;
      if ( hour==24 ) then
         hour = 0
         day = day+1
         !! 如果天数大于本月的最大天数，月数进1,天数归为1;
         if ( day>DaysInMonth(month)) then
            day = 1
            month = month+1
            !! 如果月数大于12，年数进1,月数归为1;
            if ( month>12 ) then
               month = 1
               year = year+1
            end if
         end if
      end if
      

      !!
      str = trim(blank)//'6.  分钟的确定. 先定义为00，因为已经在matlab进行了处理：'&
         &'数据时刻小于30分钟的，记录在上一个小时；大于30分钟的，记录在下一个小时'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      ! Num_real = 1.0/(24.0*60.0)
      ! ! write (*,*) Num_real
      ! do while (nc_time > Num_real)
      !    nc_time = nc_time-Num_real
      !    minute = minute+1
      !    Num_real = 1.0/(24.0*60.0)
      ! end do
      !!
      minute = 0
      str = trim(blank)//'7.  秒数的确定. 先定义为00，已经在matlab处理'
      if ((iiii .eq. 1) .AND. (j .eq. 1)) write (*, *) str
      second = 0

   end subroutine nctime_day2date

   subroutine DaysInYear(year,Num)
      implicit none
      !! in, out
      integer, intent(in) :: year
      integer, intent(out) :: Num
      logical :: TF
      !! tmp
      ! Integer :: DaysInMonth(12) = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]  !! 初始化只有第一次会执行，多次调用不能放在初始化
      Integer :: DaysInMonth(12)

      DaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]  !! 
      TF = ((MOD(year, 4) == 0) .and. (MOD(year, 100) /= 0)) .or. (mod(year, 400) == 0)
      if (TF) then
         DaysInMonth(2) = 29
      end if
      Num = sum(DaysInMonth(:)) 
   end subroutine DaysInYear


end module mod_nctime2date
