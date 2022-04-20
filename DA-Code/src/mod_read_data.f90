module mod_read_data
   use netcdf
   use mod_params, only: TMP_NAME, sub_x, sub_y, sub_xy ! NLVLS, SAL_NAME, NLONS, NLATS, NDIMS, NRECS,
   implicit none

contains

   subroutine readdata_hs_total(tmp2, TimeNum, tmp,fname2)
      implicit none
      character(len=18), intent(in)  :: fname2
      integer, intent(out) :: TimeNum           ! 有多少个时间点
      real, intent(out) :: tmp2(sub_x, sub_y)   ! nc文件的所有时间节点累加

      real, allocatable, intent(out) :: tmp(:, :, :)  ! nc文件的包含时间节点信息

      real :: scale_factor   

      integer :: ncid
      integer :: start(3), counts(3), stride(3)
      integer :: tmp_varid 
      integer :: xtype, ndims, dimids(3), natts
      integer :: i, leng(3)
      character*10 vname
      character*15 dimname

      include 'netcdf.inc'

      ! (1) Open the file
      ! call check(nf90_open(fname2, nf90_nowrite, ncid))
      call check(nf_open(fname2, nf90_nowrite, ncid))

      ! (2) Get the varids
      ! call check(nf90_inq_varid(ncid, TMP_NAME, tmp_varid))
      call check(nf_inq_varid(ncid, TMP_NAME, tmp_varid))

      ! (3) Read
      ! refer: 在linux下用fortran读取netcdf文件(以WRF模式输出的数据为例),https://blog.csdn.net/weixin_35774805/article/details/115735558
      !        NetCDF User's Guide for FORTRAN, http://iprc.soest.hawaii.edu/users/xfu/tool/guidef-3.html
      call check(nf_inq_var(ncid, tmp_varid, vname, xtype, ndims, dimids, natts)) !获取变量信息
      !         Error: Function ‘nf_inq_var’ at (1) has no IMPLICIT type, 解决 include 'netcdf.inc'
      print *, '                  vname=', vname !变量名
      print *, '                  xtype=', xtype !变量类型，4表示整型，5表示实型，6表示双精度
      print *, '                  ndims=', ndims !变量维数
      print *, '                  dimids=', dimids !每一维的ID
      print *, '                  natts=', natts !
      print *, '                  scale='
      !
      do i = 1, ndims
         call check(nf_inq_dim(ncid, dimids(i), dimname, leng(i)))
         print *, '                  name of dimids', dimids(i), 'is ', dimname, ' length=', leng(i)
      end do
      !
      call check(nf_get_att_real(ncid, tmp_varid, 'scale_factor', scale_factor)) !获取变量属性信息
      print *, '                  scale_factor=', scale_factor
      !
      start = (/1, 1, 1/)
      counts = (/leng(1), leng(2), leng(3)/)
      stride = (/1, 1, 1/)
      TimeNum = leng(3)
      !   call check(nf90_get_var(ncid, tmp_varid, tmp)) ! 读取出来是错误的数据，
      !   call check(nf90_get_var(ncid, tmp_varid, tmp, start=start, count=counts, stride=stride)) ! 读取出来是错误的数据，
      allocate (tmp(leng(1), leng(2), leng(3)))
      call check(nf_get_vars_real(ncid, tmp_varid, start, counts, stride, tmp))
      tmp = tmp*scale_factor
      write (*, *) '                  最大值', maxval(tmp), ',可跟matlab结果验证,'
      write (*, *) '                  matlab验证,ncread("20141227_T.nc","hs",[1 1 1],[69 41 245],[1 1 1]);max(vardata(:));'
      ! (4) 累加, Close the file, 
      tmp2 = 0
      do i = 1, leng(3)
         tmp2 = tmp2 + tmp(sub_xy(1):sub_xy(3), sub_xy(2):sub_xy(4), i)
      end do
      call check(nf90_close(ncid))
      ! deallocate(tmp) ! 不能释放，因为是输出参数，
      print *, '                  *** SUCCESS Reading file ', fname2, "!"
      return
   end subroutine readdata_hs_total

   subroutine check(status)
      integer, intent(in) :: status

      if (status /= nf90_noerr) then
         print *, trim(nf90_strerror(status))
         stop "Stopped"
      end if

      return
   end subroutine check

   !    subroutine readdata_tmp_sal(tmp2, sal2, fname2)
!       implicit none
!       character(len=18), intent(in)  :: fname2
!       real, intent(out) :: tmp2(sub_x, sub_y, NLVLS)
!       real, intent(out) :: sal2(sub_x, sub_y, NLVLS)

!       real :: tmp(NLONS, NLATS, NLVLS)
!       real :: sal(NLONS, NLATS, NLVLS)

!       integer :: ncid, rec
!       integer :: start(NDIMS), count(NDIMS)
!       integer :: tmp_varid, sal_varid

!       ! (1) Open the file
!       call check(nf90_open(fname2, nf90_nowrite, ncid))

!       ! (2) Get the varids of T and S
!       call check(nf90_inq_varid(ncid, TMP_NAME, tmp_varid))
!       call check(nf90_inq_varid(ncid, SAL_NAME, sal_varid))

!       ! (3) Read T and S from the file, 1 record at a time
!       count = (/NLONS, NLATS, NLVLS, 1/)
!       start = (/1, 1, 1, 1/)
!       do rec = 1, NRECS
!          start(4) = rec
!          call check(nf90_get_var(ncid, tmp_varid, tmp, start=start, &
!                                  count=count))
!          call check(nf90_get_var(ncid, sal_varid, sal, start, count))
!       end do

!       ! (4) Close the file
!       call check(nf90_close(ncid))
!       write (*, *) "*** SUCCESS Reading file ", fname2, "!"

!       tmp2 = tmp(sub_xy(1):sub_xy(3), sub_xy(2):sub_xy(4), :)
!       sal2 = sal(sub_xy(1):sub_xy(3), sub_xy(2):sub_xy(4), :)

!       return
!    end subroutine readdata_tmp_sal

end module mod_read_data
