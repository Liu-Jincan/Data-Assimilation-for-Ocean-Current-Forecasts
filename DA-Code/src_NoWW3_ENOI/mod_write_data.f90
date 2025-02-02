module mod_write_data
   use netcdf
   use mod_params, only: TMP_NAME, sub_x, sub_y, sub_xy, programs, N, nc_daOut! NLVLS, SAL_NAME, NLONS, NLATS, NDIMS, NRECS,
   implicit none

contains

   subroutine writedata_hs_xb_ENOI(blank, iiii, ncid, leng, nc_fileName)
      implicit none
      integer :: iiii, ncid, tmp_varid, i, j, k, m, leng, num, FID, FID2, new_ncid
      character*255 :: blank, str2, str, namefile, nc_fileName, outfile
      real :: scale_factor
      real :: hs(sub_x, sub_y, leng), tmp(sub_x, sub_y)
      real :: Xb(N),nan
      !!
      real :: nctime(leng), nclon(sub_x), nclat(sub_y)
      !! read_write_nc20190331.f90下的程序
      integer :: begin_lon, end_lon, begin_lat, end_lat, nx, ny, num_N, x_dimid,y_dimid,t_dimid, dimids(3), hs_dimid
      integer :: x_varid, y_varid, t_varid, hs_varid, tmp_varid1, tmp_varid2, tmp_varid3, tmp_varid4

      include 'netcdf.inc'
      !!
      str = trim(blank)//'1. 按顺序获取Xb文件夹下所有txt文件的名称，保存到Xb/dir.txt，以备读取，'&
          &//'需先将dir.txt保存到$(programs)下，再转移到Xb/下。'
      if ((iiii .eq. 1)) write (*, *) str
      str = programs//'/Xb/'
      str2 = programs
      call system("ls -1 "//trim(str)//" > "//trim(str2)//"dir.txt")
      call system("mv "//trim(str2)//"dir.txt"//" "//trim(str)//"dir.txt")
      FID = 199
      open (FID, file=trim(str)//'dir.txt', status='old')
      num = GetFileN(FID)
      close(FID)
      ! write (*,*) num  
      if (num /= leng) then 
        write (*,*) "维数不匹配！！！"
        stop ! 这里相当与验证了一次，没有同化的，也要在Xb生成.txt分析场文件～
      end if

      !! 
      str = trim(blank)//'2. 读取ncid的lon，lat，time，hs, 获取scale_factor,'
      if ((iiii .eq. 1) .AND. (i .eq. 1)) write (*, *) str
      call check(nf_inq_varid(ncid, 'longitude', tmp_varid1))
      call check(nf_inq_varid(ncid, 'latitude', tmp_varid2))
      call check(nf_inq_varid(ncid, 'time', tmp_varid3))
      call check(nf_inq_varid(ncid, 'hs', tmp_varid4)) 
      call check(nf_get_att_real(ncid, tmp_varid4, 'scale_factor', scale_factor)) !获取变量属性信息
      !! 
      str = trim(blank)//'3. 在$(programs)/$(nc_ENOI)下生成新的nc文件，copy原先文件的经纬度、时间、Hs，'
      if ((iiii .eq. 1) .AND. (i .eq. 1)) write (*, *) str
      outfile = programs//'/'//nc_daOut//'/'//nc_daOut//'_'//nc_fileName
      ! write (*,*) outfile
      call check(nf90_create(outfile,NF90_CLOBBER,new_ncid))
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! def_dim  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      begin_lon = 1
      end_lon = sub_x
      begin_lat = 1
      end_lat = sub_y
      nx = end_lon-begin_lon+1
      ny = end_lat-begin_lat+1
      num_N = num
      ! dimids = [ny,nx,num_N]
      call check(nf90_def_dim(new_ncid,"longitude",nx,x_dimid))
      call check(nf90_def_dim(new_ncid,"latitude",ny,y_dimid))
      call check(nf90_def_dim(new_ncid,"time",num_N,t_dimid))
      call check(nf90_def_dim(new_ncid,"hs",NF90_UNLIMITED,hs_dimid))  !! 
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! def_var !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! put_att !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! enddef  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      call check(nf90_enddef(new_ncid))
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! put_var !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      call check(nf_copy_var(ncid,tmp_varid1,new_ncid))  ! 从原来nc中获取longitude的变量，
      call check(nf_copy_var(ncid,tmp_varid2,new_ncid))  ! 从原来nc中获取latitude的变量，
      call check(nf_copy_var(ncid,tmp_varid3,new_ncid))  ! 从原来nc中获取time的变量，
      call check(nf_copy_var(ncid,tmp_varid4,new_ncid))  ! 从原来nc中获取hs的变量，
      !!
      call check(nf_inq_varid(new_ncid, 'hs', tmp_varid4))
      FID = 199
      str2 = programs//'/Xb/'
      open (FID, file=trim(str2)//'dir.txt', status='old')
      do i = 1, num
        !!
        str = trim(blank)//'4. 对copy得到的hs进行修改，遍历Xb，如果大于0修改Hs值，如果小于0,不修改,'
        ! nan = 0. / 0
        if ((iiii .eq. 1) .AND. (i .eq. 1)) write (*, *) str
        read (FID,*) namefile
        ! write (*,*) namefile
        FID2 = 200
        str2 = programs//'/Xb/'//trim(namefile)
        open (FID2, file=trim(str2), status='old')
            read(FID2,*) Xb ! 断点，debug看维度，
        close(FID2)
        m = 0
        do k = 1, sub_y
            do j = 1, sub_x
                m = m+1
                if ( Xb(m)<0 ) then
                    ! 什么都不做～～
                else
                    call check(nf90_put_var(new_ncid,tmp_varid4,Xb(m)*(1.0/scale_factor),start=(/j,k,i/) ))
                end if
            end do
        end do
      end do
      close(FID)
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! close   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      call check(nf90_close(new_ncid))
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! end     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

   end subroutine writedata_hs_xb_ENOI

   subroutine check(status)
      integer, intent(in) :: status

      if (status /= nf90_noerr) then
         print *, trim(nf90_strerror(status))
         stop "Stopped"
      end if

      return
   end subroutine check

   Integer Function GetFileN(iFileUnit)
      Implicit None
      Integer, Intent(IN)::iFileUnit
      Integer::ios
      Character(Len=1)::cDummy
      GetFileN = 0
      Rewind (iFileUnit)
      Do
         Read (iFileUnit, *, ioStat=ioS) cDummy
         if (ioS /= 0) Exit
         GetFileN = GetFileN + 1
      End Do
   end function

end module mod_write_data

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 之前的思路～～，不太好～
! module mod_write_data
!    use netcdf
!    use mod_params, only: TMP_NAME, sub_x, sub_y, sub_xy, programs, N! NLVLS, SAL_NAME, NLONS, NLATS, NDIMS, NRECS,
!    implicit none

! contains

!    subroutine writedata_hs_xb_ENOI(blank, iiii, ncid, leng, nc_fileName)
!       implicit none
!       integer :: iiii, ncid, tmp_varid, i, j, k, m, leng, num, FID, FID2, new_ncid
!       character*255 :: blank, str2, str, namefile, nc_fileName, outfile
!       real :: scale_factor
!       real :: hs(sub_x, sub_y, leng), tmp(sub_x, sub_y)
!       real :: Xb(N),nan
!       !!
!       real :: nctime(leng), nclon(sub_x), nclat(sub_y)
!       !! read_write_nc20190331.f90下的程序
!       integer :: begin_lon, end_lon, begin_lat, end_lat, nx, ny, num_N, x_dimid,y_dimid,t_dimid, dimids(3)
!       integer :: x_varid, y_varid, t_varid, hs_varid

!       include 'netcdf.inc'
!       !!
!       str = trim(blank)//'1. 按顺序获取Xb文件夹下所有txt文件的名称，保存到Xb/dir.txt，以备读取，'&
!           &//'需先将dir.txt保存到$(programs)下，再转移到Xb/下。'
!       if ((iiii .eq. 1)) write (*, *) str
!       str = programs//'/Xb/'
!       str2 = programs
!       call system("ls -1 "//trim(str)//" > "//trim(str2)//"dir.txt")
!       call system("mv "//trim(str2)//"dir.txt"//" "//trim(str)//"dir.txt")
!       FID = 199
!       open (FID, file=trim(str)//'dir.txt', status='old')
!       num = GetFileN(FID)
!       close(FID)
!       ! write (*,*) num  
!       if (num /= leng) then 
!         write (*,*) "维数不匹配！！！"
!         stop ! 这里相当与验证了一次，没有同化的，也要在Xb生成.txt分析场文件～
!       end if
!       !!
!       FID = 199
!       str2 = programs//'/Xb/'
!       open (FID, file=trim(str2)//'dir.txt', status='old')
!       do i = 1, num
!         !!
!         str = trim(blank)//'2. 读取Xb，将一维Xb转换成二维矩阵tmp，保存到对应的hs，如果小于0,用nan表示'
!         ! nan = 0. / 0
!         if ((iiii .eq. 1) .AND. (i .eq. 1)) write (*, *) str
!         read (FID,*) namefile
!         ! write (*,*) namefile
!         FID2 = 200
!         str2 = programs//'/Xb/'//trim(namefile)
!         open (FID2, file=trim(str2), status='old')
!             read(FID2,*) Xb ! 断点，debug看维度，
!         close(FID2)
!         m = 0
!         do k = 1, sub_y
!             do j = 1, sub_x
!                 m = m+1
!                 if ( Xb(m)<0 ) then
!                     ! tmp(j,k) = -9999.0
!                     ! tmp(j,k) = NaN
!                     ! tmp(j,k) = sqrt(-1)
!                     tmp(j,k) = 0
!                 else
!                     tmp(j,k) = Xb(m)
!                 end if
!             end do
!         end do
!         hs(:,:,i) = tmp(:,:)

!       end do
!       close(FID)

!       !! 
!       str = trim(blank)//'3. 读取ncid的lon，lat，time，'
!       if ((iiii .eq. 1) .AND. (i .eq. 1)) write (*, *) str
!       call check(nf_inq_varid(ncid, 'longitude', tmp_varid))
!       call check(nf90_get_var(ncid,tmp_varid,nclon))
!       call check(nf_inq_varid(ncid, 'latitude', tmp_varid))
!       call check(nf90_get_var(ncid,tmp_varid,nclat))
!       call check(nf_inq_varid(ncid, 'time', tmp_varid))
!       call check(nf90_get_var(ncid,tmp_varid,nctime))

!       !! 
!       str = trim(blank)//'4. 在$(programs)/nc_ENOI下生成新的nc文件，'
!       if ((iiii .eq. 1) .AND. (i .eq. 1)) write (*, *) str
!       outfile = programs//'/nc_ENOI/'//'ENOI_'//nc_fileName
!       ! write (*,*) outfile
!       call check(nf90_create(outfile,NF90_CLOBBER,new_ncid))
!       ! def_dim
!       begin_lon = 1
!       end_lon = sub_x
!       begin_lat = 1
!       end_lat = sub_y
!       nx = end_lon-begin_lon+1
!       ny = end_lat-begin_lat+1
!       num_N = num
!       call check(nf90_def_dim(new_ncid,"longitude",nx,x_dimid))
!       call check(nf90_def_dim(new_ncid,"latitude",ny,y_dimid))
!       call check(nf90_def_dim(new_ncid,"time",num_N,t_dimid))
!       ! def_var
!       call check(nf90_def_var(new_ncid,"longitude",NF90_DOUBLE,x_dimid,x_varid))
!       call check(nf90_def_var(new_ncid,"latitude",NF90_DOUBLE,y_dimid,y_varid))
!       ! call check(nf90_def_var(new_ncid,"time",NF90_DOUBLE,t_dimid,t_varid))
!       dimids = (/x_dimid,y_dimid,t_dimid/)
!       call check(nf90_def_var(new_ncid,"hs",NF90_DOUBLE,dimids,hs_varid))
!       ! put_att
!       ! call check(nf90_put_att(new_ncid,t_varid,"long_name","julian day (UT)"))
!       ! call check(nf90_put_att(new_ncid,t_varid,"standard_name","time"))
!       ! call check(nf90_put_att(new_ncid,t_varid,"units","days since 1990-01-01 00:00:00"))
!       ! call check(nf90_put_att(new_ncid,t_varid,"calendar","standard"))
!       ! call check(nf90_put_att(new_ncid,t_varid,"axis","T"))
!       ! call check(nf90_put_att(new_ncid,t_varid,"conventions","relative julian days with decimal part (as parts of the day )"))
!       ! call check(nf90_put_att(new_ncid,hs_varid,'units','m'))
!       ! call check(nf90_put_att(new_ncid,hs_varid,'_Fillvalue','-32767.0'))
!       ! enddef
!       call check(nf90_enddef(new_ncid))
!       ! put_var
!       call check(nf_copy_var(ncid,tmp_varid,new_ncid))  
!       call check(nf90_put_var(new_ncid,x_varid,nclon(begin_lon:end_lon)))
!       call check(nf90_put_var(new_ncid,y_varid,nclat(begin_lat:end_lat)))
!       !   call check(nf90_put_var(new_ncid,t_varid,nctime(1:num_N)))
!       ! call check(nf90_put_var(new_ncid,t_varid,nctime(:)))
      
!       !   call check(nf90_put_var(new_ncid,hs_varid,hs(begin_lon:end_lon,begin_lat:end_lat,1:num_N)))
!       call check(nf90_put_var(new_ncid,hs_varid,hs(begin_lon:end_lon,begin_lat:end_lat,:)))
!       ! close
!       call check(nf90_close(new_ncid))
      
!       !! end

!    end subroutine writedata_hs_xb_ENOI

!    subroutine check(status)
!       integer, intent(in) :: status

!       if (status /= nf90_noerr) then
!          print *, trim(nf90_strerror(status))
!          stop "Stopped"
!       end if

!       return
!    end subroutine check

!    Integer Function GetFileN(iFileUnit)
!       Implicit None
!       Integer, Intent(IN)::iFileUnit
!       Integer::ios
!       Character(Len=1)::cDummy
!       GetFileN = 0
!       Rewind (iFileUnit)
!       Do
!          Read (iFileUnit, *, ioStat=ioS) cDummy
!          if (ioS /= 0) Exit
!          GetFileN = GetFileN + 1
!       End Do
!    end function

! end module mod_write_data