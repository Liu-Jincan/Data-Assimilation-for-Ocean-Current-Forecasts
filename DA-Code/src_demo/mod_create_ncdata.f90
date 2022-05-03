module mod_create_ncdata
   use netcdf
   use mod_params, only: TMP_NAME
   implicit none

contains


   !!
   subroutine readdata_hs_xb(blank, iiii, jjjj, nc_fileName, Xb,ncid,leng)
      implicit none
      integer :: iiii, jjjj, ncid, tmp_varid,i,j,m, leng
      character*255 :: blank, nc_fileName, str2, str
      real :: scale_factor
      real :: tmp2(sub_x, sub_y,leng), tmp(sub_x,sub_y)
      real, intent(out) :: Xb(N)
      include 'netcdf.inc'
      !!
      str = trim(blank)//'1. 读取对应时刻的Xb二维矩阵，'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      ! str2 = programs//'/nc/'//nc_fileName
      ! write (*,*) str2
      ! call check(nf_open(str2, nf90_nowrite, ncid))
      call check(nf_inq_varid(ncid, TMP_NAME, tmp_varid))
      call check(nf_get_att_real(ncid, tmp_varid, 'scale_factor', scale_factor))
      ! start = (/1, 1, 1/)
      call check(nf_get_vars_real(ncid, tmp_varid, (/1,1,1/),(/sub_x, sub_y,leng/),(/1,1,1/),tmp2))
      ! write (*,*) ncid, tmp_varid, jjjj, sub_x, sub_y, scale_factor
      tmp = tmp2(sub_x, sub_y,jjjj)
      tmp = tmp*scale_factor;
      !!
      str = trim(blank)//'2. Xb二维矩阵变成一维数组，nclat和nclon是从小到大排列，'&
         &//'才能满足同化中网格点（先是纬度、经度最小-->后经度从小到大-->'&
         &//'后纬度变大一个分度值-->）排成一列的特点'
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      m = 0
      do i = 1, sub_y
         do j = 1, sub_x
            m = m+1
            Xb(m) = tmp(j,i)
         end do
      end do
      if ((iiii .eq. 1) .AND. (jjjj .eq. 1)) write (*, *) str
      !!
      ! call check(nf_close(ncid)) ! 因为ncid作为参数过来了，所以这里不用close 

   end subroutine readdata_hs_xb

   subroutine check(status)
      integer, intent(in) :: status

      if (status /= nf90_noerr) then
         print *, trim(nf90_strerror(status))
         stop "Stopped"
      end if

      return
   end subroutine check


end module mod_create_ncdata
