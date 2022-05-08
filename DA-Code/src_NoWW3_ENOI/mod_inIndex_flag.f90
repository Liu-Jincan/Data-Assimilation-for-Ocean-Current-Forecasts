module mod_inIndex_flag
   use mod_params, only: programs
   implicit none

contains
   subroutine inIndex_flag(blank,j,nc_fileName,flag)
      implicit none
      !! in,out
      integer, intent(in) :: j
      character(255), intent(in) :: nc_fileName
      integer, intent(out) :: flag
      !! temp,
      character*256 :: blank,str
      integer :: i, FID=150, length
      integer, allocatable :: IndexVector(:) ! 列向量
      !!
      str = trim(blank)//'1. 生成Index路径，读取matlab生成的Index文件中向量的行数'
      if (j .eq. 1) write (*, *) str
      i = index(nc_fileName,'.') ! . 在字符串的位置，
      str = trim(programs)//'/'//nc_fileName(1:i-1)//'_nc'//'_Index'//'/Index.txt'
      ! if (j .eq. 1) write (*, *) str
      open(FID,FILE=str)
      read(FID,*) length

      !!
      str = trim(blank)//'2. 读取Index文件，生成数组IndexVector，关闭文件'
      if (j .eq. 1) write (*, *) str
      allocate(IndexVector(length))
      do i=1,length
         read(FID,*) IndexVector(i)
      enddo
      close(FID)
      !!
      str = trim(blank)//'3. 判断j是否在数组IndexVector，是flag=1，否flag=0'
      if (j .eq. 1) write (*, *) str
      flag = 0;
      do i = 1, length
         if ( j.eq.IndexVector(i) ) then
            flag = 1;
            exit
         endif
      end do
      
      
 
   end subroutine inIndex_flag

   subroutine inIndex_flag2(blank,iiii,jjjj,nc_fileName,yyyy, mm, dd, hh, ff, ss,flag,pth2)
      implicit none
      !!
      integer,intent(out) :: flag
      integer :: iiii,jjjj,yyyy, mm, dd, hh, ff, ss
      character*255 :: blank,str,nc_fileName
      !! tmp
      integer :: i
      character*256 :: pth1, pth2
      character :: year*4,month*2,day*2,hour*2,minute*2,second*2
      logical isExist

      str = trim(blank)//'1. yo路径'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! i = index(nc_fileName,'.') ! . 在字符串的位置，
      ! pth1 = programs//'/'//nc_fileName(1:i-1)//'_nc_yo/'
      pth1 = programs//'/yo/'

      str = trim(blank)//'2. yyyy-mm-dd...时间,，若在yo路径下存在，名称应该为$(pth2)'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      write(year,'(I4)') yyyy
      if ( mm<10 ) then
         write (month,'(I1)') mm
         month = '0'//month
      ELSE
         write (month,'(I2)') mm
      end if
      if ( dd<10 ) then
         write (day,'(I1)') dd
         day = '0'//day
      ELSE
         write (day,'(I2)') dd
      end if
      if ( hh<10 ) then
         write (hour,'(I1)') hh
         hour = '0'//hour
      ELSE
         write (hour,'(I2)') hh
      end if
      if ( ff<10 ) then
         write (minute,'(I1)') ff
         minute = '0'//minute
      ELSE
         write (minute,'(I2)') ff
      end if
      if ( ss<10 ) then
         write (second,'(I1)') ss
         second = '0'//second
      ELSE
         write (second,'(I2)') ss
      end if
      ! write(*,*) time(1)
      pth2 = year//month//day//'T'//hour//minute//second//'.txt'
      str = trim(blank)//'3. 判断$(pth2)是否在$(pth1)存在'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      str = trim(pth1)//trim(pth2)
      write (*,*) str
      ! write (*,*) str
      inquire(file=str,exist=isExist)
      flag = 0;
      if(isExist) then
         flag = 1; 
      endif
      ! write (*,*) flag

      
   end subroutine inIndex_flag2
end module mod_inIndex_flag